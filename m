From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 07/17] new helpers: skb_copy_datagram_from_iter() and
 zerocopy_sg_from_iter()
Date: Sat, 22 Nov 2014 04:33:20 +0000
Message-ID: <20141122043320.GG30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |    3 ++
 net/core/datagram.c    |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 118 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 18ce42e..ce69d48 100644
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
index 26391a3..34d82f8 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -572,6 +572,77 @@ fault:
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
@@ -643,6 +714,50 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 }
 EXPORT_SYMBOL(zerocopy_sg_from_iovec);
 
+int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
+{
+	int len = iov_iter_count(from);
+	int copy = min_t(int, skb_headlen(skb), len);
+	int i = 0;
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
+		copied = iov_iter_get_pages(from, pages, ~0U, MAX_SKB_FRAGS, &start);
+		if (copied < 0)
+			return -EFAULT;
+
+		truesize = DIV_ROUND_UP(copied + start, PAGE_SIZE) * PAGE_SIZE;
+		skb->data_len += copied;
+		skb->len += copied;
+		skb->truesize += truesize;
+		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		while (copied) {
+			int off = start;
+			int size = min_t(int, copied, PAGE_SIZE - off);
+			start = 0;
+			if (i < MAX_SKB_FRAGS)
+				skb_fill_page_desc(skb, i, pages[n], off, size);
+			else
+				put_page(pages[n]);
+			copied -= size;
+			i++, n++;
+		}
+		if (i > MAX_SKB_FRAGS)
+			return -EMSGSIZE;
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
