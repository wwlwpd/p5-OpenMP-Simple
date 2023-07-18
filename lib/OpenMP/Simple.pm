package OpenMP::Simple;

use strict;
use warnings;

sub helpers {
return<<EOC;
#define PerlOMP_ENV_UPDATE_NUM_THREADS char *num = getenv("OMP_NUM_THREADS"); omp_set_num_threads(atoi(num));
#define PerlOMP_RET_ARRAY_REF_ret AV* ret = newAV();sv_2mortal((SV*)ret);

void PerlOMP_2D_AoA_TO_FLOAT_ARRAY_2D(SV *AoA, int numRows, int rowSize, float retArray[numRows][rowSize]) {
  SV **AVref;
  for (int i=0; i<numRows; i++) {
    AVref = av_fetch((AV*)SvRV(AoA), i, 0);
    for (int j=0; j<rowSize;j++) {
      SV **element = av_fetch((AV*)SvRV(*AVref), j, 0);
      retArray[i][j] = SvNV(*element);
    }
  }
}
EOC
}

1;

__END__

=head1 NAME OpenMP::Simple

=head1 SYNOPSIS

    use Alien::OpenMP;
    use OpenMP::Simple;
    use OpenMP::Environment;
    
    use Inline (
        C                 => 'DATA',
        auto_include      => OpenMP::Simple::helpers(),
        with              => qw/Alien::OpenMP/,
    );
    
=head1 DESCRIPTION

This module attempts to ease the transition for those more familiar with programming C with OpenMP
than they are with Perl or using C<Inline::C> within their Perl programs.

In addition to helping to deal with getting data structures that are very common in the computational
domains into and out of these C<Inline::C>'d routines that leverage I<OpenMP>, this module provides
macros that are designed to provide behavior that is assumed to work when executing a binary that has
been compiled with OpenMP support, such as the awareness of the current state of the C<OMP_NUM_THREADS>
environmental variable.

=head1 PROVIDED MACROS

=over 4

=item C<PerlOMP_ENV_UPDATE_NUM_THREADS>

When used, the value of C<OMP_NUM_THREADS> will be read and be used to update with the runtime the
number of threads via OpenMP standard runtime function, C<omp_set_num_threads> (as implemented by
GCC's GOMP).

=item C<PerlOMP_RET_ARRAY_REF_ret>

(may not be needed) - creates a new C<AV*> and sets it I<mortal> (doesn't survive outside of the
current scope). Used when wanting to return an array reference that's been populated via C<av_push>.

=back

=head1 PROVIDED PERL TO C CONVERSION FUNCTIONS

=over 4

=item C<PerlOMP_2D_AoA_TO_FLOAT_ARRAY_2D(AoA, num_nodes, dims, nodes)>

Used to extract the contents of a 2D rectangular Perl array reference that has been used to
represent a 2D matrix.

    float nodes[num_nodes][dims];
    PerlOMP_2D_AoA_TO_FLOAT_ARRAY_2D(AoA, num_nodes, dims, nodes);

=back

=head1 COPYRIGHT

Same as Perl.
