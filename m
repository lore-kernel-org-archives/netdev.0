From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 05/13] sock: enable MSG_ZEROCOPY
Date: Wed, 21 Jun 2017 16:36:44 -0400
Message-ID: <20170621203652.15306-6-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34588 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751487AbdFUUhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:37:01 -0400
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
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
 include/linux/skbuff.h | 14 +++++++++++++-
 net/core/dev.c         |  4 ++--
 net/core/skbuff.c      | 48 +++++++++++++++++++-----------------------------
 5 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ae49f4b99b67..9b1225cf555f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -892,7 +892,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	    sk_filter(tfile->socket.sk, skb))
 		goto drop;
 
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+	if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 		goto drop;
 
 	skb_tx_timestamp(skb);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index e3d7ea1288c6..614a577a0a66 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -533,6 +533,7 @@ static void handle_tx(struct vhost_net *net)
 			ubuf->callback = vhost_zerocopy_callback;
 			ubuf->ctx = nvq->ubufs;
 			ubuf->desc = nvq->upend_idx;
+			atomic_set(&ubuf->refcnt, 1);
 			msg.msg_control = ubuf;
 			msg.msg_controllen = sizeof(ubuf);
 			ubufs = nvq->ubufs;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0d1b088f1c9f..0be25226b725 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2473,7 +2473,17 @@ static inline void skb_orphan(struct sk_buff *skb)
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
@@ -2905,6 +2915,8 @@ static inline int skb_add_data(struct sk_buff *skb,
 static inline bool skb_can_coalesce(struct sk_buff *skb, int i,
 				    const struct page *page, int off)
 {
+	if (skb_zcopy(skb))
+		return false;
 	if (i) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d1830b8d2cf..c0b4c54f3b52 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1860,7 +1860,7 @@ static inline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+	if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 		return -ENOMEM;
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
@@ -4292,7 +4292,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	}
 
 	if (pt_prev) {
-		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		if (unlikely(skb_orphan_frags_rx(skb, GFP_ATOMIC)))
 			goto drop;
 		else
 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 34fa1f2b7ff2..89ba5ad024a5 100644
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
 
+	skb_zcopy_clear(skb, true);
 	skb_free_head(skb);
 }
 
@@ -720,14 +709,7 @@ EXPORT_SYMBOL(kfree_skb_list);
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
+	skb_zcopy_clear(skb, true);
 }
 EXPORT_SYMBOL(skb_tx_error);
 
@@ -1079,9 +1061,7 @@ int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(skb_zerocopy_iter_stream);
 
-/* unused only until next patch in the series; will remove attribute */
-static int __attribute__((unused))
-	   skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
+static int skb_zerocopy_clone(struct sk_buff *nskb, struct sk_buff *orig,
 			      gfp_t gfp_mask)
 {
 	if (skb_zcopy(orig)) {
@@ -1120,7 +1100,6 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
-	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 	int i, new_frags;
 	u32 d_off;
 
@@ -1174,8 +1153,6 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
 
-	uarg->callback(uarg, false);
-
 	/* skb frags point to kernel buffers */
 	for (i = 0; i < new_frags - 1; i++) {
 		__skb_fill_page_desc(skb, i, head, 0, PAGE_SIZE);
@@ -1184,7 +1161,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	__skb_fill_page_desc(skb, new_frags - 1, head, 0, d_off);
 	skb_shinfo(skb)->nr_frags = new_frags;
 
-	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	skb_zcopy_clear(skb, false);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(skb_copy_ubufs);
@@ -1345,7 +1322,8 @@ struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
 	if (skb_shinfo(skb)->nr_frags) {
 		int i;
 
-		if (skb_orphan_frags(skb, gfp_mask)) {
+		if (skb_orphan_frags(skb, gfp_mask) ||
+		    skb_zerocopy_clone(n, skb, gfp_mask)) {
 			kfree_skb(n);
 			n = NULL;
 			goto out;
@@ -1422,9 +1400,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
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
 
@@ -1916,6 +1895,9 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	skb->tail     += delta;
 	skb->data_len -= delta;
 
+	if (!skb->data_len)
+		skb_zcopy_clear(skb, false);
+
 	return skb_tail_pointer(skb);
 }
 EXPORT_SYMBOL(__pskb_pull_tail);
@@ -2547,6 +2529,7 @@ skb_zerocopy(struct sk_buff *to, struct sk_buff *from, int len, int hlen)
 		skb_tx_error(from);
 		return -ENOMEM;
 	}
+	skb_zerocopy_clone(to, from, GFP_ATOMIC);
 
 	for (i = 0; i < skb_shinfo(from)->nr_frags; i++) {
 		if (!len)
@@ -2844,6 +2827,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 
 	skb_shinfo(skb1)->tx_flags |= skb_shinfo(skb)->tx_flags &
 				      SKBTX_SHARED_FRAG;
+	skb_zerocopy_clone(skb1, skb, 0);
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -2887,6 +2871,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 
 	if (skb_headlen(skb))
 		return 0;
+	if (skb_zcopy(tgt) || skb_zcopy(skb))
+		return 0;
 
 	todo = shiftlen;
 	from = 0;
@@ -3460,6 +3446,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 		skb_shinfo(nskb)->tx_flags |= skb_shinfo(head_skb)->tx_flags &
 					      SKBTX_SHARED_FRAG;
+		if (skb_zerocopy_clone(nskb, head_skb, GFP_ATOMIC))
+			goto err;
 
 		while (pos < offset + len) {
 			if (i >= nfrags) {
@@ -4583,6 +4571,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
+	if (skb_zcopy(to) || skb_zcopy(from))
+		return false;
 
 	if (skb_headlen(from) != 0) {
 		struct page *page;
-- 
2.13.1.611.g7e3b11ae1-goog
