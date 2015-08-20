From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 03/10] sock: enable sendmsg zerocopy
Date: Thu, 20 Aug 2015 10:36:42 -0400
Message-ID: <1440081408-12302-4-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35159 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbbHTOgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:55 -0400
Received: by qkbm65 with SMTP id m65so16086037qkb.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:54 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Prepare the datapath for refcounted ubuf_info. Clone ubuf_info with
skb_zerocopy_clone() wherever needed due to skb split, merge, resize
or clone.

The exact locations to modify were chosen by exhaustively searching
through all code that might modify skb_frag references and/or the
the SKBTX_DEV_ZEROCOPY tx_flags bit.

The changes err on the safe side, in two ways.

(1) legacy ubuf_info paths virtio and tap are not modified. They keep
    a 1:1 ubuf_info to sk_buff relationship. Calls to skb_orphan_frags
    still call skb_copy_ubufs and thus copy frags in this case.
    For this reason, the skb_orphan_frags calls are not (yet) removed.

(2) not all copies deep in the stack are addressed yet. skb_shift,
    skb_split and skb_try_coalesce can be refined to avoid copying.
    These are not in the hot path and this patch is hairy enough as
    is, so that is left for future refinement.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/vhost/net.c    |  1 +
 include/linux/skbuff.h |  6 +++++-
 net/core/skbuff.c      | 48 +++++++++++++++++++-----------------------------
 3 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7d137a4..f3456e1 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -380,6 +380,7 @@ static void handle_tx(struct vhost_net *net)
 			ubuf->callback = vhost_zerocopy_callback;
 			ubuf->ctx = nvq->ubufs;
 			ubuf->desc = nvq->upend_idx;
+			atomic_set(&ubuf->refcnt, 1);
 			msg.msg_control = ubuf;
 			msg.msg_controllen = sizeof(ubuf);
 			ubufs = nvq->ubufs;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a93e17c..3372f1c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2199,7 +2199,9 @@ static inline void skb_orphan(struct sk_buff *skb)
  */
 static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
+	if (likely(!skb_zcopy(skb)))
+		return 0;
+	if (likely(skb_uarg(skb)->callback == sock_zerocopy_callback))
 		return 0;
 	return skb_copy_ubufs(skb, gfp_mask);
 }
@@ -2618,6 +2620,8 @@ static inline int skb_add_data(struct sk_buff *skb,
 static inline bool skb_can_coalesce(struct sk_buff *skb, int i,
 				    const struct page *page, int off)
 {
+	if (skb_zcopy(skb))
+		return false;
 	if (i) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 85dc612..6ee7282 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -582,21 +582,10 @@ static void skb_release_data(struct sk_buff *skb)
 	for (i = 0; i < shinfo->nr_frags; i++)
 		__skb_frag_unref(&shinfo->frags[i]);
 
-	/*
-	 * If skb buf is from userspace, we need to notify the caller
-	 * the lower device DMA has done;
-	 */
-	if (shinfo->tx_flags & SKBTX_DEV_ZEROCOPY) {
-		struct ubuf_info *uarg;
-
-		uarg = shinfo->destructor_arg;
-		if (uarg->callback)
-			uarg->callback(uarg, true);
-	}
-
 	if (shinfo->frag_list)
 		kfree_skb_list(shinfo->frag_list);
 
+	skb_zcopy_clear(skb);
 	skb_free_head(skb);
 }
 
@@ -715,14 +704,7 @@ EXPORT_SYMBOL(kfree_skb_list);
  */
 void skb_tx_error(struct sk_buff *skb)
 {
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-		struct ubuf_info *uarg;
-
-		uarg = skb_shinfo(skb)->destructor_arg;
-		if (uarg->callback)
-			uarg->callback(uarg, false);
-		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
-	}
+	skb_zcopy_clear(skb);
 }
 EXPORT_SYMBOL(skb_tx_error);
 
@@ -953,9 +935,7 @@ int skb_zerocopy_add_frags_iter(struct sock *sk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(skb_zerocopy_add_frags_iter);
 
-/* unused only until next patch in the series; will remove attribute */
-static int __attribute__((unused))
-	   skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
+static int skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
 			      gfp_t gfp_mask)
 {
 	if (skb_zcopy(orig)) {
@@ -964,6 +944,8 @@ static int __attribute__((unused))
 			BUG_ON(!gfp_mask);
 			if (skb_uarg(nskb) == skb_uarg(orig))
 				return 0;
+			/* nskb is always new, writable, so copy ubufs is ok */
+			BUG_ON(skb_shared(nskb) || skb_cloned(nskb));
 			if (skb_copy_ubufs(nskb, GFP_ATOMIC))
 				return -EIO;
 		}
@@ -995,7 +977,6 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	int i;
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
-	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 
 	if (skb_shared(skb) || skb_cloned(skb)) {
 		WARN_ON(1);
@@ -1041,8 +1022,6 @@ copy_done:
 	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
 
-	uarg->callback(uarg, false);
-
 	/* skb frags point to kernel buffers */
 	for (i = num_frags - 1; i >= 0; i--) {
 		__skb_fill_page_desc(skb, i, head, 0,
@@ -1050,7 +1029,7 @@ copy_done:
 		head = (struct page *)page_private(head);
 	}
 
-	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	skb_zcopy_clear(skb);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(skb_copy_ubufs);
@@ -1211,11 +1190,13 @@ struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
 	if (skb_shinfo(skb)->nr_frags) {
 		int i;
 
-		if (skb_orphan_frags(skb, gfp_mask)) {
+		if (skb_orphan_frags(skb, gfp_mask) ||
+		    skb_zerocopy_clone(n, skb, gfp_mask)) {
 			kfree_skb(n);
 			n = NULL;
 			goto out;
 		}
+
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
 			skb_frag_ref(skb, i);
@@ -1288,9 +1269,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	 * be since all we did is relocate the values
 	 */
 	if (skb_cloned(skb)) {
-		/* copy this zero copy skb frags */
 		if (skb_orphan_frags(skb, gfp_mask))
 			goto nofrags;
+		if (skb_zcopy(skb))
+			atomic_inc(&skb_uarg(skb)->refcnt);
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			skb_frag_ref(skb, i);
 
@@ -2409,6 +2391,7 @@ skb_zerocopy(struct sk_buff *to, struct sk_buff *from, int len, int hlen)
 		skb_tx_error(from);
 		return -ENOMEM;
 	}
+	skb_zerocopy_clone(to, from, GFP_ATOMIC);
 
 	for (i = 0; i < skb_shinfo(from)->nr_frags; i++) {
 		if (!len)
@@ -2686,6 +2669,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 	int pos = skb_headlen(skb);
 
 	skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
+	skb_zerocopy_clone(skb1, skb, 0);
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -2727,6 +2711,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 
 	BUG_ON(shiftlen > skb->len);
 	BUG_ON(skb_headlen(skb));	/* Would corrupt stream */
+	if (skb_zcopy(tgt) || skb_zcopy(skb))
+		return 0;
 
 	todo = shiftlen;
 	from = 0;
@@ -3250,6 +3236,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
 			SKBTX_SHARED_FRAG;
+		if (skb_zerocopy_clone(nskb, head_skb, GFP_ATOMIC))
+			goto err;
 
 		while (pos < offset + len) {
 			if (i >= nfrags) {
@@ -4279,6 +4267,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
+	if (skb_zcopy(to) || skb_zcopy(from))
+		return false;
 
 	if (skb_headlen(from) != 0) {
 		struct page *page;
-- 
2.5.0.276.gf5e568e
