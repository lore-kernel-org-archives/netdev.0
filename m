From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 2/9] sock: skb_copy_ubufs support for compound pages
Date: Thu,  3 Aug 2017 16:29:38 -0400
Message-ID: <20170803202945.70750-3-willemdebruijn.kernel@gmail.com>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Refine skb_copy_ubufs to support compound pages. With upcoming TCP
zerocopy sendmsg, such fragments may appear.

The existing code replaces each page one for one. Splitting each
compound page into an independent number of regular pages can result
in exceeding limit MAX_SKB_FRAGS if data is not exactly page aligned.

Instead, fill all destination pages but the last to PAGE_SIZE.
Split the existing alloc + copy loop into separate stages:
1. compute bytelength and minimum number of pages to store this.
2. allocate
3. copy, filling each page except the last to PAGE_SIZE bytes
4. update skb frag array

Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/linux/skbuff.h |  9 +++++++--
 net/core/skbuff.c      | 53 ++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 45 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index be76082f48aa..2f64e2bbb592 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1796,13 +1796,18 @@ static inline unsigned int skb_headlen(const struct sk_buff *skb)
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
index 0f0933b338d7..a95877a8ac8b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -932,17 +932,20 @@ EXPORT_SYMBOL_GPL(skb_morph);
  */
 int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	int i;
+	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
-	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
+	int i, new_frags;
+	u32 d_off;
 
-	for (i = 0; i < num_frags; i++) {
-		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
-		u32 p_off, p_len, copied;
-		struct page *p;
-		u8 *vaddr;
+	if (!num_frags)
+		return 0;
+
+	if (skb_shared(skb) || skb_unclone(skb, gfp_mask))
+		return -EINVAL;
 
+	new_frags = (__skb_pagelen(skb) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < new_frags; i++) {
 		page = alloc_page(gfp_mask);
 		if (!page) {
 			while (head) {
@@ -952,17 +955,36 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 			}
 			return -ENOMEM;
 		}
+		set_page_private(page, (unsigned long)head);
+		head = page;
+	}
+
+	page = head;
+	d_off = 0;
+	for (i = 0; i < num_frags; i++) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		u32 p_off, p_len, copied;
+		struct page *p;
+		u8 *vaddr;
 
 		skb_frag_foreach_page(f, f->page_offset, skb_frag_size(f),
 				      p, p_off, p_len, copied) {
+			u32 copy, done = 0;
 			vaddr = kmap_atomic(p);
-			memcpy(page_address(page) + copied, vaddr + p_off,
-			       p_len);
+
+			while (done < p_len) {
+				if (d_off == PAGE_SIZE) {
+					d_off = 0;
+					page = (struct page *)page_private(page);
+				}
+				copy = min_t(u32, PAGE_SIZE - d_off, p_len - done);
+				memcpy(page_address(page) + d_off,
+				       vaddr + p_off + done, copy);
+				done += copy;
+				d_off += copy;
+			}
 			kunmap_atomic(vaddr);
 		}
-
-		set_page_private(page, (unsigned long)head);
-		head = page;
 	}
 
 	/* skb frags release userspace buffers */
@@ -972,11 +994,12 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
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
2.14.0.rc1.383.gd1ce394fe2-goog
