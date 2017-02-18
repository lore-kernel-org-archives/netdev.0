From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Sat, 18 Feb 2017 00:02:14 +0000
Message-ID: <20170218000214.GA19777@ZenIV.linux.org.uk>
References: <20170212054209.GQ13195@ZenIV.linux.org.uk>
 <2337836.67BmyCWMtR@debian64>
 <20170214013306.GS13195@ZenIV.linux.org.uk>
 <20170217.105420.2167024053308682803.davem@davemloft.net>
 <20170217170315.GE29622@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rlwinm@sdf.org,
        alexmcwhirter@triadic.us, chunkeey@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34222 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdBRACW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 19:02:22 -0500
Content-Disposition: inline
In-Reply-To: <20170217170315.GE29622@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 05:03:15PM +0000, Al Viro wrote:
> On Fri, Feb 17, 2017 at 10:54:20AM -0500, David Miller wrote:
> > From: Al Viro <viro@ZenIV.linux.org.uk>
> > Date: Tue, 14 Feb 2017 01:33:06 +0000
> > 
> > > OK...  Remaining interesting question is whether it adds a noticable
> > > overhead.  Could somebody try it on assorted benchmarks and see if
> > > it slows the things down?  The patch in question follows:
> > 
> > That's about a 40 byte copy onto the stack for each invocation of this
> > thing.  You can benchmark all you want, but it's clear that this is
> > non-trivial amount of work and will take some operations from fitting
> > in the cache to not doing so for sure.
> 
> In principle, that could be reduced a bit (32 bytes - ->type is never
> changed, so we don't need to restore it), but that's not much of improvement...

Actually, I've a better solution.  Namely, analogue of iov_iter_advance()
for going backwards.  The restriction is that you should never unroll
further than where you've initially started *or* have the iovec, etc.
array modified under you.  For iovec/kvec/bio_vec it's trivial, for pipe -
a bit more convoluted, but still doable.  Then net/core/datagram.c stuff
could simply use iov_iter_unroll() in case of error - all we need to keep
track of is how much had we copied and that's easy to do.

The patch below is completely untested, but if it works it should avoid
buggering the fast paths at all, still giving the same semantics re
reverting ->msg_iter both on EINVAL and EFAULT.  Comments?

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 804e34c6f981..237965348bc2 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -39,7 +39,10 @@ struct iov_iter {
 	};
 	union {
 		unsigned long nr_segs;
-		int idx;
+		struct {
+			int idx;
+			int start_idx;
+		};
 	};
 };
 
@@ -81,6 +84,7 @@ unsigned long iov_shorten(struct iovec *iov, unsigned long nr_segs, size_t to);
 size_t iov_iter_copy_from_user_atomic(struct page *page,
 		struct iov_iter *i, unsigned long offset, size_t bytes);
 void iov_iter_advance(struct iov_iter *i, size_t bytes);
+void iov_iter_unroll(struct iov_iter *i, size_t bytes);
 int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes);
 size_t iov_iter_single_seg_count(const struct iov_iter *i);
 size_t copy_page_to_iter(struct page *page, size_t offset, size_t bytes,
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index e68604ae3ced..afdaca37f5c9 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -786,6 +786,68 @@ void iov_iter_advance(struct iov_iter *i, size_t size)
 }
 EXPORT_SYMBOL(iov_iter_advance);
 
+void iov_iter_unroll(struct iov_iter *i, size_t unroll)
+{
+	if (!unroll)
+		return;
+	i->count += unroll;
+	if (unlikely(i->type & ITER_PIPE)) {
+		struct pipe_inode_info *pipe = i->pipe;
+		int idx = i->idx;
+		size_t off = i->iov_offset;
+		while (1) {
+			size_t n = off - pipe->bufs[idx].offset;
+			if (unroll < n) {
+				off -= (n - unroll);
+				break;
+			}
+			unroll -= n;
+			if (!unroll && idx == i->start_idx) {
+				off = 0;
+				break;
+			}
+			if (!idx--)
+				idx = pipe->buffers - 1;
+			off = pipe->bufs[idx].offset + pipe->bufs[idx].len;
+		}
+		i->iov_offset = off;
+		i->idx = idx;
+		pipe_truncate(i);
+		return;
+	}
+	if (unroll <= i->iov_offset) {
+		i->iov_offset -= unroll;
+		return;
+	}
+	unroll -= i->iov_offset;
+	if (i->type & ITER_BVEC) {
+		const struct bio_vec *bvec = i->bvec;
+		while (1) {
+			size_t n = (--bvec)->bv_len;
+			i->nr_segs++;
+			if (unroll <= n) {
+				i->bvec = bvec;
+				i->iov_offset = n - unroll;
+				return;
+			}
+			unroll -= n;
+		}
+	} else { /* same logics for iovec and kvec */
+		const struct iovec *iov = i->iov;
+		while (1) {
+			size_t n = (--iov)->iov_len;
+			i->nr_segs++;
+			if (unroll <= n) {
+				i->iov = iov;
+				i->iov_offset = n - unroll;
+				return;
+			}
+			unroll -= n;
+		}
+	}
+}
+EXPORT_SYMBOL(iov_iter_unroll);
+
 /*
  * Return the count of just the current iov_iter segment.
  */
@@ -839,6 +901,7 @@ void iov_iter_pipe(struct iov_iter *i, int direction,
 	i->idx = (pipe->curbuf + pipe->nrbufs) & (pipe->buffers - 1);
 	i->iov_offset = 0;
 	i->count = count;
+	i->start_idx = i->idx;
 }
 EXPORT_SYMBOL(iov_iter_pipe);
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 662bea587165..63c7353a6ba2 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -394,7 +394,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 			   struct iov_iter *to, int len)
 {
 	int start = skb_headlen(skb);
-	int i, copy = start - offset;
+	int i, copy = start - offset, start_off = offset, n;
 	struct sk_buff *frag_iter;
 
 	trace_skb_copy_datagram_iovec(skb, len);
@@ -403,11 +403,12 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
-		if (copy_to_iter(skb->data + offset, copy, to) != copy)
+		n = copy_to_iter(skb->data + offset, copy, to);
+		offset += n;
+		if (n != copy)
 			goto short_copy;
 		if ((len -= copy) == 0)
 			return 0;
-		offset += copy;
 	}
 
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
@@ -421,13 +422,14 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 		if ((copy = end - offset) > 0) {
 			if (copy > len)
 				copy = len;
-			if (copy_page_to_iter(skb_frag_page(frag),
+			n = copy_page_to_iter(skb_frag_page(frag),
 					      frag->page_offset + offset -
-					      start, copy, to) != copy)
+					      start, copy, to);
+			offset += n;
+			if (n != copy)
 				goto short_copy;
 			if (!(len -= copy))
 				return 0;
-			offset += copy;
 		}
 		start = end;
 	}
@@ -459,6 +461,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 	 */
 
 fault:
+	iov_iter_unroll(to, offset - start_off);
 	return -EFAULT;
 
 short_copy:
@@ -609,7 +612,7 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 				      __wsum *csump)
 {
 	int start = skb_headlen(skb);
-	int i, copy = start - offset;
+	int i, copy = start - offset, start_off = offset;
 	struct sk_buff *frag_iter;
 	int pos = 0;
 	int n;
@@ -619,11 +622,11 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		if (copy > len)
 			copy = len;
 		n = csum_and_copy_to_iter(skb->data + offset, copy, csump, to);
+		offset += n;
 		if (n != copy)
 			goto fault;
 		if ((len -= copy) == 0)
 			return 0;
-		offset += copy;
 		pos = copy;
 	}
 
@@ -645,12 +648,12 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 						  offset - start, copy,
 						  &csum2, to);
 			kunmap(page);
+			offset += n;
 			if (n != copy)
 				goto fault;
 			*csump = csum_block_add(*csump, csum2, pos);
 			if (!(len -= copy))
 				return 0;
-			offset += copy;
 			pos += copy;
 		}
 		start = end;
@@ -683,6 +686,7 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 		return 0;
 
 fault:
+	iov_iter_unroll(to, offset - start_off);
 	return -EFAULT;
 }
 
@@ -767,6 +771,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 	}
 	return 0;
 csum_error:
+	iov_iter_unroll(&msg->msg_iter, chunk);
 	return -EINVAL;
 fault:
 	return -EFAULT;
