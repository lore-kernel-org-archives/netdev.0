From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 2/6] net: move zerocopy_sg_from_iovec() to net/core/datagram.c
Date: Tue,  6 Aug 2013 17:45:04 +0800
Message-ID: <1375782308-10565-3-git-send-email-jasowang@redhat.com>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To let it be reused and reduce code duplication. Also document this function.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c  |   80 -----------------------------------------
 drivers/net/tun.c      |   80 -----------------------------------------
 include/linux/skbuff.h |    4 ++
 net/core/datagram.c    |   93 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 97 insertions(+), 160 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index dfec20d..182364a 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -536,86 +536,6 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 	return skb;
 }
 
-/* set skb frags from iovec, this can move to core network code for reuse */
-static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
-				  int offset, size_t count)
-{
-	int len = iov_length(from, count) - offset;
-	int copy = skb_headlen(skb);
-	int size, offset1 = 0;
-	int i = 0;
-
-	/* Skip over from offset */
-	while (count && (offset >= from->iov_len)) {
-		offset -= from->iov_len;
-		++from;
-		--count;
-	}
-
-	/* copy up to skb headlen */
-	while (count && (copy > 0)) {
-		size = min_t(unsigned int, copy, from->iov_len - offset);
-		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
-				   size))
-			return -EFAULT;
-		if (copy > size) {
-			++from;
-			--count;
-			offset = 0;
-		} else
-			offset += size;
-		copy -= size;
-		offset1 += size;
-	}
-
-	if (len == offset1)
-		return 0;
-
-	while (count--) {
-		struct page *page[MAX_SKB_FRAGS];
-		int num_pages;
-		unsigned long base;
-		unsigned long truesize;
-
-		len = from->iov_len - offset;
-		if (!len) {
-			offset = 0;
-			++from;
-			continue;
-		}
-		base = (unsigned long)from->iov_base + offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		if (i + size > MAX_SKB_FRAGS)
-			return -EMSGSIZE;
-		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
-		if (num_pages != size) {
-			int j;
-
-			for (j = 0; j < num_pages; j++)
-				put_page(page[i + j]);
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
-			__skb_fill_page_desc(skb, i, page[i], off, size);
-			skb_shinfo(skb)->nr_frags++;
-			/* increase sk_wmem_alloc */
-			base += size;
-			len -= size;
-			i++;
-		}
-		offset = 0;
-		++from;
-	}
-	return 0;
-}
-
 /*
  * macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
  * be shared with the tun/tap driver.
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 18527ef..b163047 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -961,86 +961,6 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 	return skb;
 }
 
-/* set skb frags from iovec, this can move to core network code for reuse */
-static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
-				  int offset, size_t count)
-{
-	int len = iov_length(from, count) - offset;
-	int copy = skb_headlen(skb);
-	int size, offset1 = 0;
-	int i = 0;
-
-	/* Skip over from offset */
-	while (count && (offset >= from->iov_len)) {
-		offset -= from->iov_len;
-		++from;
-		--count;
-	}
-
-	/* copy up to skb headlen */
-	while (count && (copy > 0)) {
-		size = min_t(unsigned int, copy, from->iov_len - offset);
-		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
-				   size))
-			return -EFAULT;
-		if (copy > size) {
-			++from;
-			--count;
-			offset = 0;
-		} else
-			offset += size;
-		copy -= size;
-		offset1 += size;
-	}
-
-	if (len == offset1)
-		return 0;
-
-	while (count--) {
-		struct page *page[MAX_SKB_FRAGS];
-		int num_pages;
-		unsigned long base;
-		unsigned long truesize;
-
-		len = from->iov_len - offset;
-		if (!len) {
-			offset = 0;
-			++from;
-			continue;
-		}
-		base = (unsigned long)from->iov_base + offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		if (i + size > MAX_SKB_FRAGS)
-			return -EMSGSIZE;
-		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
-		if (num_pages != size) {
-			int j;
-
-			for (j = 0; j < num_pages; j++)
-				put_page(page[i + j]);
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
-			__skb_fill_page_desc(skb, i, page[i], off, size);
-			skb_shinfo(skb)->nr_frags++;
-			/* increase sk_wmem_alloc */
-			base += size;
-			len -= size;
-			i++;
-		}
-		offset = 0;
-		++from;
-	}
-	return 0;
-}
-
 /* Get packet from user space buffer */
 static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			    void *msg_control, const struct iovec *iv,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ae46475..5ac96f3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2359,6 +2359,10 @@ extern int	       skb_copy_datagram_from_iovec(struct sk_buff *skb,
 						    const struct iovec *from,
 						    int from_offset,
 						    int len);
+extern int	       zerocopy_sg_from_iovec(struct sk_buff *skb,
+					      const struct iovec *frm,
+					      int offset,
+					      size_t count);
 extern int	       skb_copy_datagram_const_iovec(const struct sk_buff *from,
 						     int offset,
 						     const struct iovec *to,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 8ab48cd..f987fae 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -573,6 +573,99 @@ fault:
 }
 EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
 
+/**
+ *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
+ *	@skb: buffer to copy
+ *	@from: io vector to copy to
+ *	@offset: offset in the io vector to start copying from
+ *	@count: amount of vectors to copy to buffer from
+ *
+ *	The function will first copy up to headlen, and then pin the userspace
+ *	pages and build frags through them.
+ *
+ *	Returns 0, -EFAULT or -EMSGSIZE.
+ *	Note: the iovec is not modified during the copy
+ */
+int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
+				  int offset, size_t count)
+{
+	int len = iov_length(from, count) - offset;
+	int copy = skb_headlen(skb);
+	int size, offset1 = 0;
+	int i = 0;
+
+	/* Skip over from offset */
+	while (count && (offset >= from->iov_len)) {
+		offset -= from->iov_len;
+		++from;
+		--count;
+	}
+
+	/* copy up to skb headlen */
+	while (count && (copy > 0)) {
+		size = min_t(unsigned int, copy, from->iov_len - offset);
+		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
+				   size))
+			return -EFAULT;
+		if (copy > size) {
+			++from;
+			--count;
+			offset = 0;
+		} else
+			offset += size;
+		copy -= size;
+		offset1 += size;
+	}
+
+	if (len == offset1)
+		return 0;
+
+	while (count--) {
+		struct page *page[MAX_SKB_FRAGS];
+		int num_pages;
+		unsigned long base;
+		unsigned long truesize;
+
+		len = from->iov_len - offset;
+		if (!len) {
+			offset = 0;
+			++from;
+			continue;
+		}
+		base = (unsigned long)from->iov_base + offset;
+		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		if (i + size > MAX_SKB_FRAGS)
+			return -EMSGSIZE;
+		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
+		if (num_pages != size) {
+			int j;
+
+			for (j = 0; j < num_pages; j++)
+				put_page(page[i + j]);
+			return -EFAULT;
+		}
+		truesize = size * PAGE_SIZE;
+		skb->data_len += len;
+		skb->len += len;
+		skb->truesize += truesize;
+		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
+		while (len) {
+			int off = base & ~PAGE_MASK;
+			int size = min_t(int, len, PAGE_SIZE - off);
+			__skb_fill_page_desc(skb, i, page[i], off, size);
+			skb_shinfo(skb)->nr_frags++;
+			/* increase sk_wmem_alloc */
+			base += size;
+			len -= size;
+			i++;
+		}
+		offset = 0;
+		++from;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(zerocopy_sg_from_iovec);
+
 static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 				      u8 __user *to, int len,
 				      __wsum *csump)
-- 
1.7.1
