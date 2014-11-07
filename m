From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 07 Nov 2014 21:22:22 +0800
Message-ID: <E1XmjUc-0005Dm-M3@gondolin.me.apana.org.au>
References: <20141107132135.GA20022@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcrl@kvack.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds skb_copy_datagram_iter, which is identical to
skb_copy_datagram_iovec except that it operates on iov_iter
instead of iovec.

Eventually all users of skb_copy_datagram_iovec should switch
over to iov_iter and then we can remove skb_copy_datagram_iovec.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    3 +
 net/core/datagram.c    |   87 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 53f4f6c..933cfce 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -150,6 +150,7 @@
 struct net_device;
 struct scatterlist;
 struct pipe_inode_info;
+struct iov_iter;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 struct nf_conntrack {
@@ -2653,6 +2654,8 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *frm,
 int skb_copy_datagram_const_iovec(const struct sk_buff *from, int offset,
 				  const struct iovec *to, int to_offset,
 				  int size);
+int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
+			   struct iov_iter *to, int size);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index fdbc9a8..84d90d0 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -49,6 +49,7 @@
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/pagemap.h>
+#include <linux/uio.h>
 
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -482,6 +483,92 @@ fault:
 EXPORT_SYMBOL(skb_copy_datagram_const_iovec);
 
 /**
+ *	skb_copy_datagram_iter - Copy a datagram to an iovec iterator.
+ *	@skb: buffer to copy
+ *	@offset: offset in the buffer to start copying from
+ *	@to: iovec iterator to copy to
+ *	@len: amount of data to copy from buffer to iovec
+ */
+int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
+			   struct iov_iter *to, int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
+
+	trace_skb_copy_datagram_iovec(skb, len);
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		if (copy_to_iter(skb->data + offset, copy, to) != copy)
+			goto short_copy;
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
+	}
+
+	/* Copy paged appendix. Hmm... why does this look so complicated? */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		WARN_ON(start > offset + len);
+
+		end = start + skb_frag_size(frag);
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			if (copy_page_to_iter(skb_frag_page(frag),
+					      frag->page_offset + offset -
+					      start, copy, to) != copy)
+				goto short_copy;
+			if (!(len -= copy))
+				return 0;
+			offset += copy;
+		}
+		start = end;
+	}
+
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		if ((copy = end - offset) > 0) {
+			if (copy > len)
+				copy = len;
+			if (skb_copy_datagram_iter(frag_iter, offset - start,
+						   to, copy))
+				goto fault;
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
+		}
+		start = end;
+	}
+	if (!len)
+		return 0;
+
+	/* This is not really a user copy fault, but rather someone
+	 * gave us a bogus length on the skb.  We should probably
+	 * print a warning here as it may indicate a kernel bug.
+	 */
+
+fault:
+	return -EFAULT;
+
+short_copy:
+	if (iov_iter_count(to))
+		goto fault;
+
+	return 0;
+}
+EXPORT_SYMBOL(skb_copy_datagram_iter);
+
+/**
  *	skb_copy_datagram_from_iovec - Copy a datagram from an iovec.
  *	@skb: buffer to copy
  *	@offset: offset in the buffer to start copying to
