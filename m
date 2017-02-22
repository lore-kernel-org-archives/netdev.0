From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 02/12] sock: skb_copy_ubufs support for compound pages
Date: Wed, 22 Feb 2017 11:38:51 -0500
Message-ID: <20170222163901.90834-3-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36815 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932364AbdBVQjV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:21 -0500
Received: by mail-qk0-f194.google.com with SMTP id r90so1163728qki.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:15 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Refine skb_copy_ubufs to support compount pages. With upcoming TCP
and UDP zerocopy sendmsg, such fragments may appear.

These skbuffs can have both kernel and zerocopy fragments, e.g., when
corking. Avoid unnecessary copying of fragments that have no userspace
reference.

It is not safe to modify skb frags when the skbuff is shared. This
should not happen. Fail loudly if we find an unexpected edge case.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f3557958e9bf..67e4216fca01 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -944,6 +944,9 @@ EXPORT_SYMBOL_GPL(skb_morph);
  *	If this function is called from an interrupt gfp_mask() must be
  *	%GFP_ATOMIC.
  *
+ *	skb_shinfo(skb) can only be safely modified when not accessed
+ *	concurrently. Fail if the skb is shared or cloned.
+ *
  *	Returns 0 on success or a negative error code on failure
  *	to allocate kernel memory to copy to.
  */
@@ -954,11 +957,29 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	struct page *page, *head = NULL;
 	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 
+	if (skb_shared(skb) || skb_cloned(skb)) {
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+
 	for (i = 0; i < num_frags; i++) {
 		u8 *vaddr;
+		unsigned int order = 0;
+		gfp_t mask = gfp_mask;
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 
-		page = alloc_page(gfp_mask);
+		page = skb_frag_page(f);
+		if (page_count(page) == 1) {
+			skb_frag_ref(skb, i);
+			goto copy_done;
+		}
+
+		if (f->size > PAGE_SIZE) {
+			order = get_order(f->size);
+			mask |= __GFP_COMP;
+		}
+
+		page = alloc_pages(mask, order);
 		if (!page) {
 			while (head) {
 				struct page *next = (struct page *)page_private(head);
@@ -971,6 +992,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		memcpy(page_address(page),
 		       vaddr + f->page_offset, skb_frag_size(f));
 		kunmap_atomic(vaddr);
+copy_done:
 		set_page_private(page, (unsigned long)head);
 		head = page;
 	}
-- 
2.11.0.483.g087da7b7c-goog
