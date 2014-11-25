From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 07/17] new helpers: skb_copy_datagram_from_iter() and zerocopy_sg_from_iter()
Date: Tue, 25 Nov 2014 14:02:21 +0000
Message-ID: <1416924151-28698-7-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |    3 ++
 net/core/datagram.c    |  116 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d048347..a01cd9a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2659,10 +2659,13 @@ static inline int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
 int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 				 const struct iovec *from, int from_offset,
 				 int len);
+int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
+				 struct iov_iter *from, int len);
 int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *frm,
 			   int offset, size_t count);
 int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
 			   struct iov_iter *to, int size);
+int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *frm);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 26391a3..3ea0384 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -572,6 +572,78 @@ fault:
 }
 EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
 
+int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
+				 struct iov_iter *from,
+				 int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		if (copy_from_iter(skb->data + offset, copy, from) != copy)
+			goto fault;
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
+			size_t copied;
+
+			if (copy > len)
+				copy = len;
+			copied = copy_page_from_iter(skb_frag_page(frag),
+					  frag->page_offset + offset - start,
+					  copy, from);
+			if (copied != copy)
+				goto fault;
+
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
+			if (skb_copy_datagram_from_iter(frag_iter,
+							offset - start,
+							from, copy))
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
+fault:
+	return -EFAULT;
+}
+EXPORT_SYMBOL(skb_copy_datagram_from_iter);
+
 /**
  *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
  *	@skb: buffer to copy
@@ -643,6 +715,50 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 }
 EXPORT_SYMBOL(zerocopy_sg_from_iovec);
 
+int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
+{
+	int len = iov_iter_count(from);
+	int copy = min_t(int, skb_headlen(skb), len);
+	int frag = 0;
+
+	/* copy up to skb headlen */
+	if (skb_copy_datagram_from_iter(skb, 0, from, copy))
+		return -EFAULT;
+
+	while (iov_iter_count(from)) {
+		struct page *pages[MAX_SKB_FRAGS];
+		size_t start;
+		ssize_t copied;
+		unsigned long truesize;
+		int n = 0;
+
+		if (frag == MAX_SKB_FRAGS)
+			return -EMSGSIZE;
+
+		copied = iov_iter_get_pages(from, pages, ~0U,
+					    MAX_SKB_FRAGS - frag, &start);
+		if (copied < 0)
+			return -EFAULT;
+
+		iov_iter_advance(from, copied);
+
+		truesize = PAGE_ALIGN(copied + start);
+		skb->data_len += copied;
+		skb->len += copied;
+		skb->truesize += truesize;
+		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		while (copied) {
+			int size = min_t(int, copied, PAGE_SIZE - start);
+			skb_fill_page_desc(skb, frag++, pages[n], start, size);
+			start = 0;
+			copied -= size;
+			n++;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(zerocopy_sg_from_iter);
+
 static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 				      u8 __user *to, int len,
 				      __wsum *csump)
-- 
1.7.10.4
