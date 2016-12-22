From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH net 1/1] tipc: revert use of copy_from_iter_full()
Date: Thu, 22 Dec 2016 03:07:54 +0000
Message-ID: <20161222030754.GG1555@ZenIV.linux.org.uk>
References: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
 <20161222012101.GF1555@ZenIV.linux.org.uk>
 <20161222014321.GA2805@ZenIV.linux.org.uk>
 <A2BAEFC30C8FD34388F02C9B3121859D225E8E2B@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "maloy@donjonn.com" <maloy@donjonn.com>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50664 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756027AbcLVDIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 22:08:00 -0500
Content-Disposition: inline
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D225E8E2B@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2016 at 02:47:09AM +0000, Jon Maloy wrote:

> > OK, I see what's going on there - unlike iterate_and_advance(), which
> > explicitly skips any work in case of empty iterator, iterate_all_kind()
> > does not.  Could you check if the following fixes your problem?
> 
> Confirmed. The crash disappeared and everything works fine.

OK...  This is the somewhat cleaned version of the same that will go to Linus,
assuming it survives the local beating.  Hopefully, cleanups hadn't broken it
in your case...

[iov_iter] fix iterate_all_kinds() on empty iterators

Problem similar to ones dealt with in "fold checks into iterate_and_advance()"
and followups, except that in this case we really want to do nothing when
asked for zero-length operation - unlike zero-length iterate_and_advance(),
zero-length iterate_all_kinds() has no side effects, and callers are simpler
that way.

That got exposed when copy_from_iter_full() had been used by tipc, which
builds an msghdr with zero payload and (now) feeds it to a primitive
based on iterate_all_kinds() instead of iterate_and_advance().

Reported-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 228892dabba6..25f572303801 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -73,19 +73,21 @@
 }
 
 #define iterate_all_kinds(i, n, v, I, B, K) {			\
-	size_t skip = i->iov_offset;				\
-	if (unlikely(i->type & ITER_BVEC)) {			\
-		struct bio_vec v;				\
-		struct bvec_iter __bi;				\
-		iterate_bvec(i, n, v, __bi, skip, (B))		\
-	} else if (unlikely(i->type & ITER_KVEC)) {		\
-		const struct kvec *kvec;			\
-		struct kvec v;					\
-		iterate_kvec(i, n, v, kvec, skip, (K))		\
-	} else {						\
-		const struct iovec *iov;			\
-		struct iovec v;					\
-		iterate_iovec(i, n, v, iov, skip, (I))		\
+	if (likely(n)) {					\
+		size_t skip = i->iov_offset;			\
+		if (unlikely(i->type & ITER_BVEC)) {		\
+			struct bio_vec v;			\
+			struct bvec_iter __bi;			\
+			iterate_bvec(i, n, v, __bi, skip, (B))	\
+		} else if (unlikely(i->type & ITER_KVEC)) {	\
+			const struct kvec *kvec;		\
+			struct kvec v;				\
+			iterate_kvec(i, n, v, kvec, skip, (K))	\
+		} else {					\
+			const struct iovec *iov;		\
+			struct iovec v;				\
+			iterate_iovec(i, n, v, iov, skip, (I))	\
+		}						\
 	}							\
 }
 
@@ -576,7 +578,7 @@ bool copy_from_iter_full(void *addr, size_t bytes, struct iov_iter *i)
 		WARN_ON(1);
 		return false;
 	}
-	if (unlikely(i->count < bytes))				\
+	if (unlikely(i->count < bytes))
 		return false;
 
 	iterate_all_kinds(i, bytes, v, ({
@@ -620,7 +622,7 @@ bool copy_from_iter_full_nocache(void *addr, size_t bytes, struct iov_iter *i)
 		WARN_ON(1);
 		return false;
 	}
-	if (unlikely(i->count < bytes))				\
+	if (unlikely(i->count < bytes))
 		return false;
 	iterate_all_kinds(i, bytes, v, ({
 		if (__copy_from_user_nocache((to += v.iov_len) - v.iov_len,
@@ -837,11 +839,8 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 	unsigned long res = 0;
 	size_t size = i->count;
 
-	if (!size)
-		return 0;
-
 	if (unlikely(i->type & ITER_PIPE)) {
-		if (i->iov_offset && allocated(&i->pipe->bufs[i->idx]))
+		if (size && i->iov_offset && allocated(&i->pipe->bufs[i->idx]))
 			return size | i->iov_offset;
 		return size;
 	}
@@ -856,10 +855,8 @@ EXPORT_SYMBOL(iov_iter_alignment);
 
 unsigned long iov_iter_gap_alignment(const struct iov_iter *i)
 {
-        unsigned long res = 0;
+	unsigned long res = 0;
 	size_t size = i->count;
-	if (!size)
-		return 0;
 
 	if (unlikely(i->type & ITER_PIPE)) {
 		WARN_ON(1);
@@ -874,7 +871,7 @@ unsigned long iov_iter_gap_alignment(const struct iov_iter *i)
 		(res |= (!res ? 0 : (unsigned long)v.iov_base) |
 			(size != v.iov_len ? size : 0))
 		);
-		return res;
+	return res;
 }
 EXPORT_SYMBOL(iov_iter_gap_alignment);
 
@@ -908,6 +905,9 @@ static ssize_t pipe_get_pages(struct iov_iter *i,
 	size_t capacity;
 	int idx;
 
+	if (!maxsize)
+		return 0;
+
 	if (!sanity(i))
 		return -EFAULT;
 
@@ -926,9 +926,6 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 	if (maxsize > i->count)
 		maxsize = i->count;
 
-	if (!maxsize)
-		return 0;
-
 	if (unlikely(i->type & ITER_PIPE))
 		return pipe_get_pages(i, pages, maxsize, maxpages, start);
 	iterate_all_kinds(i, maxsize, v, ({
@@ -975,6 +972,9 @@ static ssize_t pipe_get_pages_alloc(struct iov_iter *i,
 	int idx;
 	int npages;
 
+	if (!maxsize)
+		return 0;
+
 	if (!sanity(i))
 		return -EFAULT;
 
@@ -1006,9 +1006,6 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 	if (maxsize > i->count)
 		maxsize = i->count;
 
-	if (!maxsize)
-		return 0;
-
 	if (unlikely(i->type & ITER_PIPE))
 		return pipe_get_pages_alloc(i, pages, maxsize, start);
 	iterate_all_kinds(i, maxsize, v, ({
