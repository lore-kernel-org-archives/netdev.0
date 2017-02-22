From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 04/12] sock: enable sendmsg zerocopy
Date: Wed, 22 Feb 2017 11:38:53 -0500
Message-ID: <20170222163901.90834-5-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33428 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754738AbdBVQjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:16 -0500
Received: by mail-qt0-f193.google.com with SMTP id n13so1078539qtc.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:15 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Prepare the datapath for refcounted ubuf_info. Clone ubuf_info with
skb_zerocopy_clone() wherever needed due to skb split, merge, resize
or clone.

Split skb_orphan_frags into two variants. The split, merge, .. paths
support reference counted zerocopy buffers, so do not do a deep copy.
Add skb_orphan_frags_rx for paths that may loop packets to receive
sockets. That is not allowed, as it may cause unbounded latency.
Deep copy all zerocopy copy buffers, ref-counted or not, in this path.

The exact locations to modify were chosen by exhaustively searching
through all code that might modify skb_frag references and/or the
the SKBTX_DEV_ZEROCOPY tx_flags bit.

The changes err on the safe side, in two ways.

(1) legacy ubuf_info paths virtio and tap are not modified. They keep
    a 1:1 ubuf_info to sk_buff relationship. Calls to skb_orphan_frags
    still call skb_copy_ubufs and thus copy frags in this case.

(2) not all copies deep in the stack are addressed yet. skb_shift,
    skb_split and skb_try_coalesce can be refined to avoid copying.
    These are not in the hot path and this patch is hairy enough as
    is, so that is left for future refinement.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/tun.c      |  2 +-
 drivers/vhost/net.c    |  1 +
 include/linux/skbuff.h | 16 ++++++++++++++--
 net/core/dev.c         |  4 ++--
 net/core/skbuff.c      | 52 +++++++++++++++++++++-----------------------------
 5 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 30863e378925..b80c7fdcb05b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -880,7 +880,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	    sk_filter(tfile->socket.sk, skb))
 		goto drop;
 
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+	if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 		goto drop;
 
 	skb_tx_timestamp(skb);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2fe35354f20e..f7ff72ed892f 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -454,6 +454,7 @@ static void handle_tx(struct vhost_net *net)
 			ubuf->callback = vhost_zerocopy_callback;
 			ubuf->ctx = nvq->ubufs;
 			ubuf->desc = nvq->upend_idx;
+			atomic_set(&ubuf->refcnt, 1);
 			msg.msg_control = ubuf;
 			msg.msg_controllen = sizeof(ubuf);
 			ubufs = nvq->ubufs;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c99538b258c9..c7b42272b409 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2448,7 +2448,7 @@ static inline void skb_orphan(struct sk_buff *skb)
 }
 
 /**
- *	skb_orphan_frags - orphan the frags contained in a buffer
+ *	skb_orphan_frags - make a local copy of non-refcounted user frags
  *	@skb: buffer to orphan frags from
  *	@gfp_mask: allocation mask for replacement pages
  *
@@ -2458,7 +2458,17 @@ static inline void skb_orphan(struct sk_buff *skb)
  */
 static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
+	if (likely(!skb_zcopy(skb)))
+		return 0;
+	if (skb_uarg(skb)->callback == sock_zerocopy_callback)
+		return 0;
+	return skb_copy_ubufs(skb, gfp_mask);
+}
+
+/* Frags must be orphaned, even if refcounted, if skb might loop to rx path */
+static inline int skb_orphan_frags_rx(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	if (likely(!skb_zcopy(skb)))
 		return 0;
 	return skb_copy_ubufs(skb, gfp_mask);
 }
@@ -2890,6 +2900,8 @@ static inline int skb_add_data(struct sk_buff *skb,
 static inline bool skb_can_coalesce(struct sk_buff *skb, int i,
 				    const struct page *page, int off)
 {
+	if (skb_zcopy(skb))
+		return false;
 	if (i) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 304f2deae5f9..7879225818da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1801,7 +1801,7 @@ static inline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+	if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 		return -ENOMEM;
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
@@ -4173,7 +4173,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	}
 
 	if (pt_prev) {
-		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 			goto drop;
 		else
 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d566f85a7690..fcbdc91b2d24 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -592,21 +592,10 @@ static void skb_release_data(struct sk_buff *skb)
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
 
@@ -725,14 +714,7 @@ EXPORT_SYMBOL(kfree_skb_list);
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
 
@@ -1033,9 +1015,7 @@ int skb_zerocopy_add_frags_iter(struct sock *sk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(skb_zerocopy_add_frags_iter);
 
-/* unused only until next patch in the series; will remove attribute */
-static int __attribute__((unused))
-	   skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
+static int skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
 			      gfp_t gfp_mask)
 {
 	if (skb_zcopy(orig)) {
@@ -1044,6 +1024,8 @@ static int __attribute__((unused))
 			BUG_ON(!gfp_mask);
 			if (skb_uarg(nskb) == skb_uarg(orig))
 				return 0;
+			/* nskb is always new, writable, so copy ubufs is ok */
+			BUG_ON(skb_shared(nskb) || skb_cloned(nskb));
 			if (skb_copy_ubufs(nskb, GFP_ATOMIC))
 				return -EIO;
 		}
@@ -1075,12 +1057,13 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	int i;
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
-	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 
-	if (skb_shared(skb) || skb_cloned(skb)) {
+	if (skb_shared(skb)) {
 		WARN_ON_ONCE(1);
 		return -EINVAL;
 	}
+	if (skb_unclone(skb, gfp_mask))
+		return -EINVAL;
 
 	for (i = 0; i < num_frags; i++) {
 		u8 *vaddr;
@@ -1121,8 +1104,6 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
 
-	uarg->callback(uarg, false);
-
 	/* skb frags point to kernel buffers */
 	for (i = num_frags - 1; i >= 0; i--) {
 		__skb_fill_page_desc(skb, i, head, 0,
@@ -1130,7 +1111,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		head = (struct page *)page_private(head);
 	}
 
-	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	skb_zcopy_clear(skb);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(skb_copy_ubufs);
@@ -1291,11 +1272,13 @@ struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
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
@@ -1368,9 +1351,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
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
 
@@ -2466,6 +2450,7 @@ skb_zerocopy(struct sk_buff *to, struct sk_buff *from, int len, int hlen)
 		skb_tx_error(from);
 		return -ENOMEM;
 	}
+	skb_zerocopy_clone(to, from, GFP_ATOMIC);
 
 	for (i = 0; i < skb_shinfo(from)->nr_frags; i++) {
 		if (!len)
@@ -2762,6 +2747,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 	int pos = skb_headlen(skb);
 
 	skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
+	skb_zerocopy_clone(skb1, skb, 0);
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -2805,6 +2791,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 
 	if (skb_headlen(skb))
 		return 0;
+	if (skb_zcopy(tgt) || skb_zcopy(skb))
+		return 0;
 
 	todo = shiftlen;
 	from = 0;
@@ -3368,6 +3356,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
 			SKBTX_SHARED_FRAG;
+		if (skb_zerocopy_clone(nskb, head_skb, GFP_ATOMIC))
+			goto err;
 
 		while (pos < offset + len) {
 			if (i >= nfrags) {
@@ -4446,6 +4436,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
+	if (skb_zcopy(to) || skb_zcopy(from))
+		return false;
 
 	if (skb_headlen(from) != 0) {
 		struct page *page;
-- 
2.11.0.483.g087da7b7c-goog
