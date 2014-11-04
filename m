From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] net: Kill skb_copy_datagram_const_iovec
Date: Tue, 04 Nov 2014 16:31:35 +0800
Message-ID: <E1XlZWZ-0003II-QE@gondolin.me.apana.org.au>
References: <20141104033818.GA11149@gondor.apana.org.au>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that both macvtap and tun are using skb_copy_datagram_iter, we
can kill the abomination that is skb_copy_datagram_const_iovec.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    3 -
 net/core/datagram.c    |   89 -------------------------------------------------
 2 files changed, 92 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ff7054..dfd8623 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2639,9 +2639,6 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 				 int len);
 int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *frm,
 			   int offset, size_t count);
-int skb_copy_datagram_const_iovec(const struct sk_buff *from, int offset,
-				  const struct iovec *to, int to_offset,
-				  int size);
 int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
 			   struct iov_iter *to, int size);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 45a9d4d..93054b9 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -394,95 +394,6 @@ fault:
 EXPORT_SYMBOL(skb_copy_datagram_iovec);
 
 /**
- *	skb_copy_datagram_const_iovec - Copy a datagram to an iovec.
- *	@skb: buffer to copy
- *	@offset: offset in the buffer to start copying from
- *	@to: io vector to copy to
- *	@to_offset: offset in the io vector to start copying to
- *	@len: amount of data to copy from buffer to iovec
- *
- *	Returns 0 or -EFAULT.
- *	Note: the iovec is not modified during the copy.
- */
-int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
-				  const struct iovec *to, int to_offset,
-				  int len)
-{
-	int start = skb_headlen(skb);
-	int i, copy = start - offset;
-	struct sk_buff *frag_iter;
-
-	/* Copy header. */
-	if (copy > 0) {
-		if (copy > len)
-			copy = len;
-		if (memcpy_toiovecend(to, skb->data + offset, to_offset, copy))
-			goto fault;
-		if ((len -= copy) == 0)
-			return 0;
-		offset += copy;
-		to_offset += copy;
-	}
-
-	/* Copy paged appendix. Hmm... why does this look so complicated? */
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		int end;
-		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-		WARN_ON(start > offset + len);
-
-		end = start + skb_frag_size(frag);
-		if ((copy = end - offset) > 0) {
-			int err;
-			u8  *vaddr;
-			struct page *page = skb_frag_page(frag);
-
-			if (copy > len)
-				copy = len;
-			vaddr = kmap(page);
-			err = memcpy_toiovecend(to, vaddr + frag->page_offset +
-						offset - start, to_offset, copy);
-			kunmap(page);
-			if (err)
-				goto fault;
-			if (!(len -= copy))
-				return 0;
-			offset += copy;
-			to_offset += copy;
-		}
-		start = end;
-	}
-
-	skb_walk_frags(skb, frag_iter) {
-		int end;
-
-		WARN_ON(start > offset + len);
-
-		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
-			if (copy > len)
-				copy = len;
-			if (skb_copy_datagram_const_iovec(frag_iter,
-							  offset - start,
-							  to, to_offset,
-							  copy))
-				goto fault;
-			if ((len -= copy) == 0)
-				return 0;
-			offset += copy;
-			to_offset += copy;
-		}
-		start = end;
-	}
-	if (!len)
-		return 0;
-
-fault:
-	return -EFAULT;
-}
-EXPORT_SYMBOL(skb_copy_datagram_const_iovec);
-
-/**
  *	skb_copy_datagram_iter - Copy a datagram to an iovec iterator.
  *	@skb: buffer to copy
  *	@offset: offset in the buffer to start copying from
