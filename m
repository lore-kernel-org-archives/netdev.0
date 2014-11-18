From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 3/5] remove a bunch of now-pointless access_ok() in net
Date: Tue, 18 Nov 2014 19:42:39 +0000
Message-ID: <20141118194239.GD14641@ZenIV.linux.org.uk>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
 <20141118194053.GA14641@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141118194053.GA14641@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following set of functions
	skb_add_data_nocache
	skb_copy_to_page_nocache
	skb_do_copy_data_nocache
	skb_copy_to_page
	skb_add_data
	csum_and_copy_from_user
	skb_copy_and_csum_datagram
	csum_and_copy_to_user
	memcpy_fromiovec
	memcpy_toiovec
	memcpy_toiovecend
	memcpy_fromiovecend
are never given a userland range that would not satisfy access_ok().

Proof:

1) skb_add_data_nocache() and skb_copy_to_page_nocache() are called only
by tcp_sendmsg() and given a range covered by ->msg_iov[].

2) skb_do_copy_data_nocache() is called only by skb_add_data_nocache() and
skb_copy_to_page_nocache() and range comes from their arguments.

3) skb_copy_to_page() is never called at all (dead code since 3.0; killed in
the next commit).

4) skb_add_data() is called by rxrpc_send_data() and tcp_send_syn_data(),
both passing it a range covered by ->msg_iov[].

5) all callers of csum_partial_copy_fromiovecend() are giving it iovecs from
->msg_iov[].  Proof: it is called by ip_generic_getfrag() and ping_getfrag(),
both are called only as callbacks by ip_append_data(), ip6_append_data() and
ip_make_skb() and argument passed to those callbacks in all such invocations
is ->msg_iov.

6) csum_and_copy_from_user() is called by skb_add_data(), skb_copy_to_page(),
skb_do_copy_data_nocache() and csum_partial_copy_fromiovecend().  In all cases
the range is covered by ->msg_iov[]

7) skb_copy_and_csum_datagram_iovec() is always getting an iovec from ->msg_iov.
Proof: it is called by tcp_copy_to_iovec(), which gives it tp->ucopy.iov,
and by several recvmsg instances (udp, raw, raw6) which give it ->msg_iov.
But tp->ucopy.iov is initialized only by ->msg_iov.

8) skb_copy_and_csum_datagram() is called only by itself (for fragments)
and by skb_copy_and_csum_datagram_iovec().  The range is covered by the range
passed to caller (in the first case) or by an iovec passed to
skb_copy_and_csum_datagram_iovec().

9) csum_and_copy_to_user() is called only by skb_copy_and_csum_datagram().
Range is covered by the range given to caller...

10) skb_copy_datagram_iovec() is always getting an iovec that would pass
access_ok() on all elements.  Proof: cases when ->msg_iov or ->ucopy.iov are
passed are trivial.  Other than those, we have
	* ppp_read() (single-element iovec, range passed to ->read() has been
validated by caller)
	* skb_copy_and_csum_datagram_iovec() (see (7)), itself (covered by
the ranges in array given to its caller)
	* rds_tcp_inc_copy_to_user(), which is called only as
->inc_copy_to_user(), which is always given ->msg_iov.

11) aside of the callers of memcpy_toiovec() that immediately pass it ->msg_iov,
there are 3 call sites: one in __qp_memcpy_from_queue() (when called from
qp_memcpy_from_queue_iov()) and two in skb_copy_datagram_iovec().  The latter
is OK due to (10), the former has the call chain coming through
vmci_qpair_dequev() and vmci_transport_stream_dequeue(), which is called as
->stream_dequeue(), which is always given ->msg_iov.
Types in vmw_vmci blow, film at 11...

12) memcpy_toiovecend() is always given a subset of something we'd just given
to ->recvmsg() in ->msg_iov.

13) most of the memcpy_fromiovec() callers are explicitly passing it ->msg_iov.
There are few exceptions:
	* l2cap_skbuff_fromiovec().  Called only as bluetooth
->memcpy_fromiovec(), which always gets ->msg_iov as argument.
	* __qp_memcpy_to_queue(), from qp_memcpy_to_queue_iov(), from
vmci_qpair_enquev(), from vmci_transport_stream_enqueue(), which is always
called as ->stream_enqueue(), which always gets ->msg_iov.  Don't ask me what
I think of vmware...
	* ipxrtr_route_packet(), which is always given ->msg_iov by its caller.
	* vmci_transport_dgram_enqueue(), which is always called as
->dgram_enqueue(), which always gets ->msg_iov.
	* vhost get_indirect(), which is passing it iovec filled by
translate_desc().  Ranges are subsets of those that had been validated by
vq_memory_access_ok() back when we did vhost_set_memory().

14) zerocopy_sg_from_iovec() always gets a validated iovec.
Proof: callers are {tun,macvtap}_get_user(), which are called either from
->aio_write() (and given iovec validated by caller of ->aio_write()), or
from ->sendmsg() (and given ->msg_iov).

15) skb_copy_datagram_from_iovec() always gets an validated iovec.
Proof: for callers in macvtap and tun, same as in (14).  Ones in net/unix
and net/packet are given ->msg_iov.  Other than those, there's one
in zerocopy_sg_from_iovec() (see (14)) and one in skb_copy_datagram_from_iovec()
itself (fragments handling) - that one gets the iovec its caller was given.

16) callers of memcpy_fromiovecend() are
	* {macvtap,tun}_get_user().  Same as (14).
	* skb_copy_datagram_from_iovec().  See (15).
	* raw_send_hdrinc(), raw6_send_hdrinv().  Both get ->msg_iov as argument
from their callers and pass it to memcpy_fromiovecend().
	* sctp_user_addto_chunk().  Ditto.
	* tipc_msg_build().  Again, iovec argument is always ->msg_iov.
	* ip_generic_getfrag() and udplite_getfrag().  Same as (5).
	* vhost_scsi_handle_vq() - that one gets vq->iov as iovec, and
vq->iov is filled ultimately by translate_desc().  Validated by
vq_memory_access_ok() back when we did vhost_set_memory().

And anything that might end up in ->msg_iov[] has to pass access_ok().  It's
trivial
for kernel_{send,recv}msg() users (there we are under set_fs(KERNEL_DS)), it's
verified by rw_copy_check_uvector() in sendmsg()/recvmsg()/sendmmsg()/recvmmsg()
and in the only place where we call ->sendmsg()/->recvmsg() not via net/socket.c
helpers (drivers/vhost/net.c) they are getting vq->iov.  As mentioned above,
this one is guaranteed to pass the checks since it's filled by translate_desc(),
and ranges it fills are subsets of ranges that had been validated when we
did vhost_set_memory().

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 arch/alpha/lib/csum_partial_copy.c      |    5 ----
 arch/frv/lib/checksum.c                 |    2 +-
 arch/m32r/lib/csum_partial_copy.c       |    2 +-
 arch/mips/include/asm/checksum.h        |   30 +++++++--------------
 arch/mn10300/lib/checksum.c             |    4 +--
 arch/parisc/include/asm/checksum.h      |    2 +-
 arch/parisc/lib/checksum.c              |    2 +-
 arch/powerpc/lib/checksum_wrappers_64.c |    6 ++---
 arch/s390/include/asm/checksum.h        |    2 +-
 arch/score/include/asm/checksum.h       |    2 +-
 arch/score/lib/checksum_copy.c          |    2 +-
 arch/sh/include/asm/checksum_32.h       |    8 +-----
 arch/sparc/include/asm/checksum_32.h    |   43 ++++++++++++++-----------------
 arch/x86/include/asm/checksum_32.h      |   17 ++++--------
 arch/x86/lib/csum-wrappers_64.c         |    3 ---
 arch/x86/um/asm/checksum.h              |    2 +-
 arch/x86/um/asm/checksum_32.h           |   12 ++++-----
 arch/xtensa/include/asm/checksum.h      |    8 +-----
 include/linux/skbuff.h                  |    2 +-
 include/net/checksum.h                  |   14 +++-------
 include/net/sock.h                      |    7 +++--
 lib/iovec.c                             |    8 +++---
 net/core/iovec.c                        |    6 ++---
 23 files changed, 67 insertions(+), 122 deletions(-)

diff --git a/arch/alpha/lib/csum_partial_copy.c b/arch/alpha/lib/csum_partial_copy.c
index 5675dca..1ee80e8 100644
--- a/arch/alpha/lib/csum_partial_copy.c
+++ b/arch/alpha/lib/csum_partial_copy.c
@@ -338,11 +338,6 @@ csum_partial_copy_from_user(const void __user *src, void *dst, int len,
 	unsigned long doff = 7 & (unsigned long) dst;
 
 	if (len) {
-		if (!access_ok(VERIFY_READ, src, len)) {
-			if (errp) *errp = -EFAULT;
-			memset(dst, 0, len);
-			return sum;
-		}
 		if (!doff) {
 			if (!soff)
 				checksum = csum_partial_cfu_aligned(
diff --git a/arch/frv/lib/checksum.c b/arch/frv/lib/checksum.c
index 44e16d5..f3fd6cd 100644
--- a/arch/frv/lib/checksum.c
+++ b/arch/frv/lib/checksum.c
@@ -140,7 +140,7 @@ csum_partial_copy_from_user(const void __user *src, void *dst,
 	if (csum_err)
 		*csum_err = 0;
 
-	rem = copy_from_user(dst, src, len);
+	rem = __copy_from_user(dst, src, len);
 	if (rem != 0) {
 		if (csum_err)
 			*csum_err = -EFAULT;
diff --git a/arch/m32r/lib/csum_partial_copy.c b/arch/m32r/lib/csum_partial_copy.c
index 5596f3d..f307c53 100644
--- a/arch/m32r/lib/csum_partial_copy.c
+++ b/arch/m32r/lib/csum_partial_copy.c
@@ -47,7 +47,7 @@ csum_partial_copy_from_user (const void __user *src, void *dst,
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
 		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
diff --git a/arch/mips/include/asm/checksum.h b/arch/mips/include/asm/checksum.h
index 3418c51..80f48c4 100644
--- a/arch/mips/include/asm/checksum.h
+++ b/arch/mips/include/asm/checksum.h
@@ -59,13 +59,7 @@ static inline
 __wsum csum_and_copy_from_user(const void __user *src, void *dst,
 			       int len, __wsum sum, int *err_ptr)
 {
-	if (access_ok(VERIFY_READ, src, len))
-		return csum_partial_copy_from_user(src, dst, len, sum,
-						   err_ptr);
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return sum;
+	return csum_partial_copy_from_user(src, dst, len, sum, err_ptr);
 }
 
 /*
@@ -77,20 +71,14 @@ __wsum csum_and_copy_to_user(const void *src, void __user *dst, int len,
 			     __wsum sum, int *err_ptr)
 {
 	might_fault();
-	if (access_ok(VERIFY_WRITE, dst, len)) {
-		if (segment_eq(get_fs(), get_ds()))
-			return __csum_partial_copy_kernel(src,
-							  (__force void *)dst,
-							  len, sum, err_ptr);
-		else
-			return __csum_partial_copy_to_user(src,
-							   (__force void *)dst,
-							   len, sum, err_ptr);
-	}
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return (__force __wsum)-1; /* invalid checksum */
+	if (segment_eq(get_fs(), get_ds()))
+		return __csum_partial_copy_kernel(src,
+						  (__force void *)dst,
+						  len, sum, err_ptr);
+	else
+		return __csum_partial_copy_to_user(src,
+						   (__force void *)dst,
+						   len, sum, err_ptr);
 }
 
 /*
diff --git a/arch/mn10300/lib/checksum.c b/arch/mn10300/lib/checksum.c
index b6580f5..d080d5e 100644
--- a/arch/mn10300/lib/checksum.c
+++ b/arch/mn10300/lib/checksum.c
@@ -73,7 +73,7 @@ __wsum csum_partial_copy_from_user(const void *src, void *dst,
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
 		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
@@ -89,7 +89,7 @@ __wsum csum_and_copy_to_user(const void *src, void *dst,
 {
 	int missing;
 
-	missing = copy_to_user(dst, src, len);
+	missing = __copy_to_user(dst, src, len);
 	if (missing) {
 		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
diff --git a/arch/parisc/include/asm/checksum.h b/arch/parisc/include/asm/checksum.h
index c84b2fc..6ca9a6f 100644
--- a/arch/parisc/include/asm/checksum.h
+++ b/arch/parisc/include/asm/checksum.h
@@ -198,7 +198,7 @@ static __inline__ __wsum csum_and_copy_to_user(const void *src,
 	/* code stolen from include/asm-mips64 */
 	sum = csum_partial(src, len, sum);
 	 
-	if (copy_to_user(dst, src, len)) {
+	if (__copy_to_user(dst, src, len)) {
 		*err_ptr = -EFAULT;
 		return (__force __wsum)-1;
 	}
diff --git a/arch/parisc/lib/checksum.c b/arch/parisc/lib/checksum.c
index ae66d31..e52fdba 100644
--- a/arch/parisc/lib/checksum.c
+++ b/arch/parisc/lib/checksum.c
@@ -138,7 +138,7 @@ __wsum csum_partial_copy_from_user(const void __user *src,
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
 		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
diff --git a/arch/powerpc/lib/checksum_wrappers_64.c b/arch/powerpc/lib/checksum_wrappers_64.c
index 08e3a33..4c783c8 100644
--- a/arch/powerpc/lib/checksum_wrappers_64.c
+++ b/arch/powerpc/lib/checksum_wrappers_64.c
@@ -37,7 +37,7 @@ __wsum csum_and_copy_from_user(const void __user *src, void *dst,
 		goto out;
 	}
 
-	if (unlikely((len < 0) || !access_ok(VERIFY_READ, src, len))) {
+	if (unlikely(len < 0)) {
 		*err_ptr = -EFAULT;
 		csum = (__force unsigned int)sum;
 		goto out;
@@ -78,7 +78,7 @@ __wsum csum_and_copy_to_user(const void *src, void __user *dst, int len,
 		goto out;
 	}
 
-	if (unlikely((len < 0) || !access_ok(VERIFY_WRITE, dst, len))) {
+	if (unlikely(len < 0)) {
 		*err_ptr = -EFAULT;
 		csum = -1; /* invalid checksum */
 		goto out;
@@ -90,7 +90,7 @@ __wsum csum_and_copy_to_user(const void *src, void __user *dst, int len,
 	if (unlikely(*err_ptr)) {
 		csum = csum_partial(src, len, sum);
 
-		if (copy_to_user(dst, src, len)) {
+		if (__copy_to_user(dst, src, len)) {
 			*err_ptr = -EFAULT;
 			csum = -1; /* invalid checksum */
 		}
diff --git a/arch/s390/include/asm/checksum.h b/arch/s390/include/asm/checksum.h
index 7403648..fdc9532 100644
--- a/arch/s390/include/asm/checksum.h
+++ b/arch/s390/include/asm/checksum.h
@@ -51,7 +51,7 @@ csum_partial_copy_from_user(const void __user *src, void *dst,
                                           int len, __wsum sum,
                                           int *err_ptr)
 {
-	if (unlikely(copy_from_user(dst, src, len)))
+	if (unlikely(__copy_from_user(dst, src, len)))
 		*err_ptr = -EFAULT;
 	return csum_partial(dst, len, sum);
 }
diff --git a/arch/score/include/asm/checksum.h b/arch/score/include/asm/checksum.h
index 961bd64..d783634 100644
--- a/arch/score/include/asm/checksum.h
+++ b/arch/score/include/asm/checksum.h
@@ -36,7 +36,7 @@ __wsum csum_and_copy_to_user(const void *src, void __user *dst, int len,
 			__wsum sum, int *err_ptr)
 {
 	sum = csum_partial(src, len, sum);
-	if (copy_to_user(dst, src, len)) {
+	if (__copy_to_user(dst, src, len)) {
 		*err_ptr = -EFAULT;
 		return (__force __wsum) -1; /* invalid checksum */
 	}
diff --git a/arch/score/lib/checksum_copy.c b/arch/score/lib/checksum_copy.c
index 9b770b3..7d6b9b4 100644
--- a/arch/score/lib/checksum_copy.c
+++ b/arch/score/lib/checksum_copy.c
@@ -42,7 +42,7 @@ unsigned int csum_partial_copy_from_user(const char *src, char *dst,
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
 		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
diff --git a/arch/sh/include/asm/checksum_32.h b/arch/sh/include/asm/checksum_32.h
index 14b7ac2..9749277 100644
--- a/arch/sh/include/asm/checksum_32.h
+++ b/arch/sh/include/asm/checksum_32.h
@@ -203,13 +203,7 @@ static inline __wsum csum_and_copy_to_user(const void *src,
 					   int len, __wsum sum,
 					   int *err_ptr)
 {
-	if (access_ok(VERIFY_WRITE, dst, len))
-		return csum_partial_copy_generic((__force const void *)src,
+	return csum_partial_copy_generic((__force const void *)src,
 						dst, len, sum, NULL, err_ptr);
-
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return (__force __wsum)-1; /* invalid checksum */
 }
 #endif /* __ASM_SH_CHECKSUM_H */
diff --git a/arch/sparc/include/asm/checksum_32.h b/arch/sparc/include/asm/checksum_32.h
index 426b238..be2e295 100644
--- a/arch/sparc/include/asm/checksum_32.h
+++ b/arch/sparc/include/asm/checksum_32.h
@@ -86,30 +86,25 @@ static inline __wsum
 csum_partial_copy_to_user(const void *src, void __user *dst, int len,
 			  __wsum sum, int *err)
 {
-	if (!access_ok (VERIFY_WRITE, dst, len)) {
-		*err = -EFAULT;
-		return sum;
-	} else {
-		register unsigned long ret asm("o0") = (unsigned long)src;
-		register char __user *d asm("o1") = dst;
-		register int l asm("g1") = len;
-		register __wsum s asm("g7") = sum;
-
-		__asm__ __volatile__ (
-		".section __ex_table,#alloc\n\t"
-		".align 4\n\t"
-		".word 1f,1\n\t"
-		".previous\n"
-		"1:\n\t"
-		"call __csum_partial_copy_sparc_generic\n\t"
-		" st %8, [%%sp + 64]\n"
-		: "=&r" (ret), "=&r" (d), "=&r" (l), "=&r" (s)
-		: "0" (ret), "1" (d), "2" (l), "3" (s), "r" (err)
-		: "o2", "o3", "o4", "o5", "o7",
-		  "g2", "g3", "g4", "g5",
-		  "cc", "memory");
-		return (__force __wsum)ret;
-	}
+	register unsigned long ret asm("o0") = (unsigned long)src;
+	register char __user *d asm("o1") = dst;
+	register int l asm("g1") = len;
+	register __wsum s asm("g7") = sum;
+
+	__asm__ __volatile__ (
+	".section __ex_table,#alloc\n\t"
+	".align 4\n\t"
+	".word 1f,1\n\t"
+	".previous\n"
+	"1:\n\t"
+	"call __csum_partial_copy_sparc_generic\n\t"
+	" st %8, [%%sp + 64]\n"
+	: "=&r" (ret), "=&r" (d), "=&r" (l), "=&r" (s)
+	: "0" (ret), "1" (d), "2" (l), "3" (s), "r" (err)
+	: "o2", "o3", "o4", "o5", "o7",
+	  "g2", "g3", "g4", "g5",
+	  "cc", "memory");
+	return (__force __wsum)ret;
 }
 
 #define HAVE_CSUM_COPY_USER
diff --git a/arch/x86/include/asm/checksum_32.h b/arch/x86/include/asm/checksum_32.h
index f50de69..4d96e08 100644
--- a/arch/x86/include/asm/checksum_32.h
+++ b/arch/x86/include/asm/checksum_32.h
@@ -185,18 +185,11 @@ static inline __wsum csum_and_copy_to_user(const void *src,
 	__wsum ret;
 
 	might_sleep();
-	if (access_ok(VERIFY_WRITE, dst, len)) {
-		stac();
-		ret = csum_partial_copy_generic(src, (__force void *)dst,
-						len, sum, NULL, err_ptr);
-		clac();
-		return ret;
-	}
-
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return (__force __wsum)-1; /* invalid checksum */
+	stac();
+	ret = csum_partial_copy_generic(src, (__force void *)dst,
+					len, sum, NULL, err_ptr);
+	clac();
+	return ret;
 }
 
 #endif /* _ASM_X86_CHECKSUM_32_H */
diff --git a/arch/x86/lib/csum-wrappers_64.c b/arch/x86/lib/csum-wrappers_64.c
index 7609e0e..b6b5626 100644
--- a/arch/x86/lib/csum-wrappers_64.c
+++ b/arch/x86/lib/csum-wrappers_64.c
@@ -26,9 +26,6 @@ csum_partial_copy_from_user(const void __user *src, void *dst,
 	might_sleep();
 	*errp = 0;
 
-	if (!likely(access_ok(VERIFY_READ, src, len)))
-		goto out_err;
-
 	/*
 	 * Why 6, not 7? To handle odd addresses aligned we
 	 * would need to do considerable complications to fix the
diff --git a/arch/x86/um/asm/checksum.h b/arch/x86/um/asm/checksum.h
index 4b181b7..3a5166c 100644
--- a/arch/x86/um/asm/checksum.h
+++ b/arch/x86/um/asm/checksum.h
@@ -46,7 +46,7 @@ static __inline__
 __wsum csum_partial_copy_from_user(const void __user *src, void *dst,
 					 int len, __wsum sum, int *err_ptr)
 {
-	if (copy_from_user(dst, src, len)) {
+	if (__copy_from_user(dst, src, len)) {
 		*err_ptr = -EFAULT;
 		return (__force __wsum)-1;
 	}
diff --git a/arch/x86/um/asm/checksum_32.h b/arch/x86/um/asm/checksum_32.h
index ab77b6f..e047748 100644
--- a/arch/x86/um/asm/checksum_32.h
+++ b/arch/x86/um/asm/checksum_32.h
@@ -43,14 +43,12 @@ static __inline__ __wsum csum_and_copy_to_user(const void *src,
 						     void __user *dst,
 						     int len, __wsum sum, int *err_ptr)
 {
-	if (access_ok(VERIFY_WRITE, dst, len)) {
-		if (copy_to_user(dst, src, len)) {
-			*err_ptr = -EFAULT;
-			return (__force __wsum)-1;
-		}
-
-		return csum_partial(src, len, sum);
+	if (__copy_to_user(dst, src, len)) {
+		*err_ptr = -EFAULT;
+		return (__force __wsum)-1;
 	}
+	return csum_partial(src, len, sum);
+}
 
 	if (len)
 		*err_ptr = -EFAULT;
diff --git a/arch/xtensa/include/asm/checksum.h b/arch/xtensa/include/asm/checksum.h
index 0593de6..e2fd018 100644
--- a/arch/xtensa/include/asm/checksum.h
+++ b/arch/xtensa/include/asm/checksum.h
@@ -245,12 +245,6 @@ static __inline__ __wsum csum_and_copy_to_user(const void *src,
 					       void __user *dst, int len,
 					       __wsum sum, int *err_ptr)
 {
-	if (access_ok(VERIFY_WRITE, dst, len))
-		return csum_partial_copy_generic(src,dst,len,sum,NULL,err_ptr);
-
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return (__force __wsum)-1; /* invalid checksum */
+	return csum_partial_copy_generic(src,dst,len,sum,NULL,err_ptr);
 }
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 73c370e..df99075 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2483,7 +2483,7 @@ static inline int skb_add_data(struct sk_buff *skb,
 			skb->csum = csum_block_add(skb->csum, csum, off);
 			return 0;
 		}
-	} else if (!copy_from_user(skb_put(skb, copy), from, copy))
+	} else if (!__copy_from_user(skb_put(skb, copy), from, copy))
 		return 0;
 
 	__skb_trim(skb, off);
diff --git a/include/net/checksum.h b/include/net/checksum.h
index 6465bae..3ed85c8 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -30,13 +30,7 @@ static inline
 __wsum csum_and_copy_from_user (const void __user *src, void *dst,
 				      int len, __wsum sum, int *err_ptr)
 {
-	if (access_ok(VERIFY_READ, src, len))
-		return csum_partial_copy_from_user(src, dst, len, sum, err_ptr);
-
-	if (len)
-		*err_ptr = -EFAULT;
-
-	return sum;
+	return csum_partial_copy_from_user(src, dst, len, sum, err_ptr);
 }
 #endif
 
@@ -46,10 +40,8 @@ static __inline__ __wsum csum_and_copy_to_user
 {
 	sum = csum_partial(src, len, sum);
 
-	if (access_ok(VERIFY_WRITE, dst, len)) {
-		if (copy_to_user(dst, src, len) == 0)
-			return sum;
-	}
+	if (__copy_to_user(dst, src, len) == 0)
+		return sum;
 	if (len)
 		*err_ptr = -EFAULT;
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 83a669f..94e0ead 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1842,10 +1842,9 @@ static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
 			return err;
 		skb->csum = csum_block_add(skb->csum, csum, offset);
 	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
-		if (!access_ok(VERIFY_READ, from, copy) ||
-		    __copy_from_user_nocache(to, from, copy))
+		if (__copy_from_user_nocache(to, from, copy))
 			return -EFAULT;
-	} else if (copy_from_user(to, from, copy))
+	} else if (__copy_from_user(to, from, copy))
 		return -EFAULT;
 
 	return 0;
@@ -1896,7 +1895,7 @@ static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 		if (err)
 			return err;
 		skb->csum = csum_block_add(skb->csum, csum, skb->len);
-	} else if (copy_from_user(page_address(page) + off, from, copy))
+	} else if (__copy_from_user(page_address(page) + off, from, copy))
 		return -EFAULT;
 
 	skb->len	     += copy;
diff --git a/lib/iovec.c b/lib/iovec.c
index df3abd1..021d53f 100644
--- a/lib/iovec.c
+++ b/lib/iovec.c
@@ -13,7 +13,7 @@ int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
 	while (len > 0) {
 		if (iov->iov_len) {
 			int copy = min_t(unsigned int, len, iov->iov_len);
-			if (copy_from_user(kdata, iov->iov_base, copy))
+			if (__copy_from_user(kdata, iov->iov_base, copy))
 				return -EFAULT;
 			len -= copy;
 			kdata += copy;
@@ -38,7 +38,7 @@ int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len)
 	while (len > 0) {
 		if (iov->iov_len) {
 			int copy = min_t(unsigned int, iov->iov_len, len);
-			if (copy_to_user(iov->iov_base, kdata, copy))
+			if (__copy_to_user(iov->iov_base, kdata, copy))
 				return -EFAULT;
 			kdata += copy;
 			len -= copy;
@@ -67,7 +67,7 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
 			continue;
 		}
 		copy = min_t(unsigned int, iov->iov_len - offset, len);
-		if (copy_to_user(iov->iov_base + offset, kdata, copy))
+		if (__copy_to_user(iov->iov_base + offset, kdata, copy))
 			return -EFAULT;
 		offset = 0;
 		kdata += copy;
@@ -100,7 +100,7 @@ int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 		int copy = min_t(unsigned int, len, iov->iov_len - offset);
 
 		offset = 0;
-		if (copy_from_user(kdata, base, copy))
+		if (__copy_from_user(kdata, base, copy))
 			return -EFAULT;
 		len -= copy;
 		kdata += copy;
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 86beeea..4a35b21 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -97,7 +97,7 @@ int csum_partial_copy_fromiovecend(unsigned char *kdata, struct iovec *iov,
 
 			/* iov component is too short ... */
 			if (par_len > copy) {
-				if (copy_from_user(kdata, base, copy))
+				if (__copy_from_user(kdata, base, copy))
 					goto out_fault;
 				kdata += copy;
 				base += copy;
@@ -110,7 +110,7 @@ int csum_partial_copy_fromiovecend(unsigned char *kdata, struct iovec *iov,
 							 partial_cnt, csum);
 				goto out;
 			}
-			if (copy_from_user(kdata, base, par_len))
+			if (__copy_from_user(kdata, base, par_len))
 				goto out_fault;
 			csum = csum_partial(kdata - partial_cnt, 4, csum);
 			kdata += par_len;
@@ -124,7 +124,7 @@ int csum_partial_copy_fromiovecend(unsigned char *kdata, struct iovec *iov,
 			partial_cnt = copy % 4;
 			if (partial_cnt) {
 				copy -= partial_cnt;
-				if (copy_from_user(kdata + copy, base + copy,
+				if (__copy_from_user(kdata + copy, base + copy,
 						partial_cnt))
 					goto out_fault;
 			}
-- 
1.7.10.4
