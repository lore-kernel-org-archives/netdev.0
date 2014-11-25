From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 09/17] kill zerocopy_sg_from_iovec()
Date: Tue, 25 Nov 2014 14:02:23 +0000
Message-ID: <1416924151-28698-9-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

no users left

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |    2 --
 net/core/datagram.c    |   65 ++----------------------------------------------
 2 files changed, 2 insertions(+), 65 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a01cd9a..178cdbd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2661,8 +2661,6 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 				 int len);
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from, int len);
-int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *frm,
-			   int offset, size_t count);
 int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
 			   struct iov_iter *to, int size);
 int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *frm);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 3ea0384..c4d832e 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -645,76 +645,15 @@ fault:
 EXPORT_SYMBOL(skb_copy_datagram_from_iter);
 
 /**
- *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
+ *	zerocopy_sg_from_iter - Build a zerocopy datagram from an iov_iter
  *	@skb: buffer to copy
- *	@from: io vector to copy from
- *	@offset: offset in the io vector to start copying from
- *	@count: amount of vectors to copy to buffer from
+ *	@from: the source to copy from
  *
  *	The function will first copy up to headlen, and then pin the userspace
  *	pages and build frags through them.
  *
  *	Returns 0, -EFAULT or -EMSGSIZE.
- *	Note: the iovec is not modified during the copy
  */
-int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
-				  int offset, size_t count)
-{
-	int len = iov_length(from, count) - offset;
-	int copy = min_t(int, skb_headlen(skb), len);
-	int size;
-	int i = 0;
-
-	/* copy up to skb headlen */
-	if (skb_copy_datagram_from_iovec(skb, 0, from, offset, copy))
-		return -EFAULT;
-
-	if (len == copy)
-		return 0;
-
-	offset += copy;
-	while (count--) {
-		struct page *page[MAX_SKB_FRAGS];
-		int num_pages;
-		unsigned long base;
-		unsigned long truesize;
-
-		/* Skip over from offset and copied */
-		if (offset >= from->iov_len) {
-			offset -= from->iov_len;
-			++from;
-			continue;
-		}
-		len = from->iov_len - offset;
-		base = (unsigned long)from->iov_base + offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		if (i + size > MAX_SKB_FRAGS)
-			return -EMSGSIZE;
-		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
-		if (num_pages != size) {
-			release_pages(&page[i], num_pages, 0);
-			return -EFAULT;
-		}
-		truesize = size * PAGE_SIZE;
-		skb->data_len += len;
-		skb->len += len;
-		skb->truesize += truesize;
-		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
-		while (len) {
-			int off = base & ~PAGE_MASK;
-			int size = min_t(int, len, PAGE_SIZE - off);
-			skb_fill_page_desc(skb, i, page[i], off, size);
-			base += size;
-			len -= size;
-			i++;
-		}
-		offset = 0;
-		++from;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(zerocopy_sg_from_iovec);
-
 int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 {
 	int len = iov_iter_count(from);
-- 
1.7.10.4
