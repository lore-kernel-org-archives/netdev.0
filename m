From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 01/10] sock: skb_copy_ubufs support for compound pages
Date: Thu, 20 Aug 2015 10:36:40 -0400
Message-ID: <1440081408-12302-2-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33693 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbHTOgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:53 -0400
Received: by qged69 with SMTP id d69so29057663qge.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:53 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Refine skb_copy_ubufs to support compount pages. With upcoming TCP
and UDP zerocopy sendmsg, such fragments may appear.

These skbuffs can also combine kernel and user fragments, e.g., when
corking. Skip the copy for fragments that have only 1 (kernel)
reference.

It is not safe to modify skb frags when the skbuff is shared. This
should not happen. Fail loudly if we find an unexpected edge case.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6a19ca..f1aa781 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -870,6 +870,9 @@ EXPORT_SYMBOL_GPL(skb_morph);
  *	If this function is called from an interrupt gfp_mask() must be
  *	%GFP_ATOMIC.
  *
+ *	skb_shinfo(skb) can only be safely modified when not accessed
+ *	concurrently. Fail if the skb is shared or cloned.
+ *
  *	Returns 0 on success or a negative error code on failure
  *	to allocate kernel memory to copy to.
  */
@@ -880,11 +883,29 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	struct page *page, *head = NULL;
 	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 
+	if (skb_shared(skb) || skb_cloned(skb)) {
+		WARN_ON(1);
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
@@ -897,6 +918,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		memcpy(page_address(page),
 		       vaddr + f->page_offset, skb_frag_size(f));
 		kunmap_atomic(vaddr);
+copy_done:
 		set_page_private(page, (unsigned long)head);
 		head = page;
 	}
-- 
2.5.0.276.gf5e568e
