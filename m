From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] situation with csum_and_copy_... API
Date: Tue, 18 Nov 2014 08:47:45 +0000
Message-ID: <20141118084745.GT7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've spent the last weekend crawling through the copy-and-calculate-csum
primitives on all architectures.  It came up during iov_iter work; below
are the results of that review and, in the end, several questions about
the short-term tactics of a change that needs to be done for iov_iter-net.

The API apparently consists of 3 functions - present and exported on all
architectures:
	1) csum_and_copy_from_user()
	2) csum_and_copy_to_user()
	3) csum_partial_copy_nocheck().
There are very few places _using_ those, all but one in net stack (the only
exception is in drivers/net).
The minimal implementations would be

__wsum csum_and_copy_from_user(const void __user *src, void *dst, int len,
			       __wsum sum, int *err_ptr)
{
	if (unlikely(copy_from_user(dst, src, len) < 0)) {
		*err_ptr = -EFAULT;
		return <whatever>;
	}
	return csum_partial(dst, len, sum);
}

__wsum csum_and_copy_to_user(const void *src, void __user *dst, int len,
			     __wsum sum, int *err_ptr)
{
	sum = csum_partial(src, len, sum);
	if (unlikely(copy_to_user(dst, src, len) < 0)) {
		*err_ptr = -EFAULT;
		return <whatever>;
	}
	return sum;
}

__wsum csum_partial_copy_nocheck(const void *src, void *dst, int len,
				 __wsum sum)
{
	memcpy(dst, src, len);
	return csum_partial(dst, len, sum);
}

Note that we are *not* guaranteed that *err_ptr is touched in case of success
- not all architectures zero it in that case.  Callers must (and do) zero it
before the call of csum_and_copy_{from,to}_user().  Furthermore, return value
in case of error is undefined.  On the "from" side result is really "anything
whatsoever", on the "to" side most of the architectures end up returning ~0U.
However, even that is not guaranteed - e.g. avr32 and xtensa might return 0
in that case.  All existing callers discard the return value in case of error -
most of them by jumping out of the scope of variable it's assigned to.  The
only exception is skb_copy_and_csum_datagram(); in that case return value is
discarded by caller of skb_copy_and_csum_datagram() itself (also by jumping
out of scope of the variable it had been put into).

Generally, error in copying from userland ends up zeroing the rest of
destination.  However, there are exceptions (which might be considered bugs)
*and* callers discard all the copied data in case of error anyway.  There
are several call chains:
	1) from skb_add_data(): calls skb_trim() immediately after the failure.
	2) from skb_do_copy_data_nocache() called from skb_add_data_nocache():
__skb_trim() in skb_add_data_nocache()
	3) from skb_do_copy_data_nocache() called from
skb_copy_to_page_nocache(): we do not increase skb->len until after successful
copying.
	4) from skb_copy_to_page(): we do not increase skb->len until after
successful copying.
	5) from csum_partial_copy_fromiovecend() from ip_generic_getfrag()
or ping_getfrag(): those are passed as getfrag callback to ip_make_skb(),
ip_append_data() or ip6_append_data().  ip_make_skb() and ip_append_data()
just pass it to __ip_append_data(), so we are left with two fairly similar
functions to analyse.
	* __ip_append_data() has 3 places where getfrag() is called directly and
one where it's passed to ip_ufo_append_data().  Direct ones either free skb, or
do __skb_trim() or do not increment skb->len on error.  ip_ufo_append_data()
passes it further to skb_append_datato_frags(), where we do not increment skb->len
and friends in case of getfrag() failure.
	* ip6_append_data() the situation is identical, with ip6_ufo_append_data()
in place of ip_ufo_append_data().

So for all in-tree users of that sucker we are guaranteed to discard the whole
thing in case of error and this zeroing the tail is pointless.

Note also that the order of src and dest is opposite to normal for memcpy-like
functions.  Compared to the rest of the ugliness it's trivial, but it's still
not nice.

IMO the calling conventions are atrocious.

And then there are architecture-specific warts.  A relatively minor one is that
csum_partial_copy_nocheck() has a slightly saner name on some architectures -
there it's called csum_partial_copy().  Of course, those architectures have
#define csum_partial_copy_nocheck csum_partial_copy...  Worse ones are related
to csum_and_copy_from_user() - on everything other than ppc64 it is an
inlined wrapper around csum_partial_copy_from_user(), which is what's actually
exported.  On ppc64 csum_partial_copy_from_user() simply doesn't exist.
The _only_ difference between it and csum_and_copy_from_user() is that the
wrapper does access_ok() check.  However, some architectures repeat that
access_ok() in csum_partial_copy_from_user() (and on x86 we have
#define csum_and_copy_from_user csum_partial_copy_from_user, with no
access_ok() in the wrapper).  As it is, it's architecture-dependent whether
csum_partial_copy_from_user() does or does not access_ok(); on
alpha, frv, m32r, mn10300, parisc, s390, score and x86 it does, on the
rest it doesn't.

To make it even more fun, converting verify_iovec() and its compat equivalent
to use of {,compat_}rw_copy_check_uvector() would guarantee that all those
access_ok() are redundant to start with, both on send and receive side of
things.  Note, BTW, that for read()/write()/readv()/writev() it's already
redundant.  Moreover, we have a very good reason to do that anyway - conversion
of sendmsg/recvmsg to iov_iter primitives would pretty much require that,
since copy_{to,from}_iter() assume that iovec behind the iov_iter has been
validated wrt access_ok().

I do have a patch doing just that; the question is what to do with csum-and-copy
primitives.  Originally I planned to simply strip those access_ok() from those
(both the explicit calls and use of copy_from_user() where we ought to use
__copy_from_user(), etc.), but that's not nice to potential out-of-tree callers
of those suckers.  If any of those exist and manage to cope with the wonderful
calling conventions, that is.  As it is, we have the total of 4 callers of
csum_and_copy_from_user() and 2 callers of csum_and_copy_to_user(), all in
networking code.  Do we care about potential out-of-tree users existing and
getting screwed by such change?  Davem, Linus?

Alternatively, we could introduce __csum_and_copy_{from,to}_user() that would
_not_ do access_ok() (and wouldn't be required to do zeroing the tail, etc.),
convert the existing callers to that and leave csum_and_copy_{to,from}_user()
as architecture-independent wrappers around those - "do access_ok(),
then try to call __csum_and... variant, then fall back to dumb implementation
if that fails".  For almost all architectures csum_and_partial_copy_from_user()
would get stripped of access_ok() and renamed to __csum_and_copy_from_user();
for ppc64 we'd define __csum_and_copy_from_user(src,dst,len,sum,errp) as
csum_and_partial_copy_generic(src,dst,len,sum,errp,NULL) - they already
have that kind of code structure.  This variant still buggers the out-of-tree
code using csum_and_partial_copy_from_user() directly, but users of
csum_and_copy_{from,to}_user() are left intact, such modules were already
broken on ppc64 *and* breakage is of obvious "it won't link" kind.

Comments, suggestions?

PS: there are some really amusing brainos - e.g. mn10300 csum_and_copy_to_user()
starts with this:
	missing = copy_to_user(dst, src, len);
	if (missing) {
		memset(dst + len - missing, 0, missing);
		*err_ptr = -EFAULT;
	}
that's right, if copy_to_user() has returned non-zero, try to do
memset() on userland addresses it has failed to write into...
