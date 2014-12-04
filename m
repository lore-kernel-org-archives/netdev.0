From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCHES] iov_iter.c rewrite
Date: Thu, 4 Dec 2014 20:20:11 +0000
Message-ID: <20141204202011.GO29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	First of all, I want to apologize for the nastiness of preprocessor
use in this series.  Seeing that the whole "macros that look like new kinds
of C statements" thing (including list_for_each_...(), etc) is very much not
to my liking, I really don't trust my taste on finer details and I'd very
much like some feedback.

	The reason for doing that kind of tricks is that iov_iter.c keeps
growing more and more boilerplate code.  For iov_iter-net series we need
	* csum_and_copy_from_iter()
	* csum_and_copy_to_iter()
	* copy_from_iter_nocache()
That's 3 new primitives, each in 2 variants (iovec and bvec).
	* ITER_KVEC handled without going through uaccess.h stuff (and
independent of set_fs() state).
And *that* means 3 variants intstead of 2 for most of the existing primitives.
That's far too much, and the amount of copies of the same logics would pretty
much guarantee that it will be a breeding ground for hard-to-kill bugs.

	The following series (also in vfs.git#iov_iter) actually manages to
do all of the above *and* shrink the damn thing quite a bit.  The generated
code appears to be no worse than before.  The price is a couple of iterator
macros - iterate_all_kinds() and iterate_and_advance().  They are given an
iov_iter, size (i.e. the amount of data in iov_iter beginning we want to go
through), name of the loop variable and 3 variants of loop body - for iovec,
bvec and kvec resp.  Loop variable is declared *inside* the expansion of those
suckers according to the kind of iov_iter - it's struct iovec, struct bio_vec
or struct kvec, covering the current range to deal with.
	The difference between those two is that iterate_and_advance() will
advance the iov_iter by the amount it has handled and iterate_all_kinds()
will leave iov_iter unchanged.

	Unless I hear anybody yelling, it goes into vfs.git#for-next today,
so if you have objections, suggestions, etc., give those *now*.

Al Viro (13):
      iov_iter.c: macros for iterating over iov_iter
      iov_iter.c: iterate_and_advance
      iov_iter.c: convert iov_iter_npages() to iterate_all_kinds
      iov_iter.c: convert iov_iter_get_pages() to iterate_all_kinds
      iov_iter.c: convert iov_iter_get_pages_alloc() to iterate_all_kinds
      iov_iter.c: convert iov_iter_zero() to iterate_and_advance
      iov_iter.c: get rid of bvec_copy_page_{to,from}_iter()
      iov_iter.c: convert copy_from_iter() to iterate_and_advance
      iov_iter.c: convert copy_to_iter() to iterate_and_advance
      iov_iter.c: handle ITER_KVEC directly
      csum_and_copy_..._iter()
      new helper: iov_iter_kvec()
      copy_from_iter_nocache()

Diffstat:
 include/linux/uio.h |    6 +
 mm/iov_iter.c       | 1077 +++++++++++++++++++++------------------------------
 2 files changed, 445 insertions(+), 638 deletions(-)
