From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 02/13] sock: skb_copy_ubufs support for compound pages
Date: Wed, 21 Jun 2017 16:36:41 -0400
Message-ID: <20170621203652.15306-3-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33490 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdFUUg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:36:58 -0400
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Refine skb_copy_ubufs to support compound pages. With upcoming TCP
and UDP zerocopy sendmsg, such fragments may appear.

The existing code replaces each page one for one. Splitting each
compound page into an independent number of regular pages can result
in exceeding limit MAX_SKB_FRAGS.

Instead, fill all destination pages but the last to PAGE_SIZE.
Split the existing alloc + copy loop into separate stages. Compute
the bytelength and allocate the minimum number of pages needed to
hold this. Revise the copy loop to fill each destination page.

It is not safe to modify skb frags when the skbuff is shared. No
existing codepath should hit this case.

Eventually, this fragile function can perhaps be replaced with calls
to skb_linearize -- when converted to not always require GFP_ATOMIC.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  9 +++++++--
 net/core/skbuff.c      | 49 ++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 45 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 852feacf4bbf..4f520cc9b914 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1783,13 +1783,18 @@ static inline unsigned int skb_headlen(const struct sk_buff *skb)
 	return skb->len - skb->data_len;
 }
 
-static inline unsigned int skb_pagelen(const struct sk_buff *skb)
+static inline unsigned int __skb_pagelen(const struct sk_buff *skb)
 {
 	unsigned int i, len = 0;
 
 	for (i = skb_shinfo(skb)->nr_frags - 1; (int)i >= 0; i--)
 		len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
-	return len + skb_headlen(skb);
+	return len;
+}
+
+static inline unsigned int skb_pagelen(const struct sk_buff *skb)
+{
+	return skb_headlen(skb) + __skb_pagelen(skb);
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f75897a33fa4..96db26594192 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -958,15 +958,20 @@ EXPORT_SYMBOL_GPL(skb_morph);
  */
 int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	int i;
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
 	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
+	int i, new_frags;
+	u32 d_off;
 
-	for (i = 0; i < num_frags; i++) {
-		u8 *vaddr;
-		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+	if (!num_frags)
+		return 0;
 
+	if (skb_shared(skb) || skb_unclone(skb, gfp_mask))
+		return -EINVAL;
+
+	new_frags = (__skb_pagelen(skb) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < new_frags; i++) {
 		page = alloc_page(gfp_mask);
 		if (!page) {
 			while (head) {
@@ -976,14 +981,35 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 			}
 			return -ENOMEM;
 		}
-		vaddr = kmap_atomic(skb_frag_page(f));
-		memcpy(page_address(page),
-		       vaddr + f->page_offset, skb_frag_size(f));
-		kunmap_atomic(vaddr);
 		set_page_private(page, (unsigned long)head);
 		head = page;
 	}
 
+	page = head;
+	d_off = 0;
+	for (i = 0; i < num_frags; i++) {
+		u8 *vaddr;
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		u32 f_off, f_size, copy;
+
+		f_off = f->page_offset;
+		f_size = f->size;
+
+		vaddr = kmap_atomic(skb_frag_page(f));
+		while (f_size) {
+			if (d_off == PAGE_SIZE) {
+				d_off = 0;
+				page = (struct page *)page_private(page);
+			}
+			copy = min_t(u32, PAGE_SIZE - d_off, f_size);
+			memcpy(page_address(page) + d_off, vaddr + f_off, copy);
+			f_size -= copy;
+			d_off += copy;
+			f_off += copy;
+		}
+		kunmap_atomic(vaddr);
+	}
+
 	/* skb frags release userspace buffers */
 	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
@@ -991,11 +1017,12 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	uarg->callback(uarg, false);
 
 	/* skb frags point to kernel buffers */
-	for (i = num_frags - 1; i >= 0; i--) {
-		__skb_fill_page_desc(skb, i, head, 0,
-				     skb_shinfo(skb)->frags[i].size);
+	for (i = 0; i < new_frags - 1; i++) {
+		__skb_fill_page_desc(skb, i, head, 0, PAGE_SIZE);
 		head = (struct page *)page_private(head);
 	}
+	__skb_fill_page_desc(skb, new_frags - 1, head, 0, d_off);
+	skb_shinfo(skb)->nr_frags = new_frags;
 
 	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	return 0;
-- 
2.13.1.611.g7e3b11ae1-goog
