From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v2 6/9] xen-netback: Handle guests with too many frags
Date: Thu, 12 Dec 2013 23:48:14 +0000
Message-ID: <1386892097-15502-7-git-send-email-zoltan.kiss@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46743 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab3LLXsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:48:51 -0500
In-Reply-To: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
- create a new skb
- map the leftover slots to its frags (no linear buffer here!)
- chain it to the previous through skb_shinfo(skb)->frag_list
- map them
- copy the whole stuff into a brand new skb and send it to the stack
- unmap the 2 old skb's pages

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

---
 drivers/net/xen-netback/netback.c |   99 +++++++++++++++++++++++++++++++++++--
 1 file changed, 94 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index e26cdda..f6ed1c8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -906,11 +906,15 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	u16 pending_idx = *((u16 *)skb->data);
 	int start;
 	pending_ring_idx_t index;
-	unsigned int nr_slots;
+	unsigned int nr_slots, frag_overflow = 0;
 
 	/* At this point shinfo->nr_frags is in fact the number of
 	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
 	 */
+	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
+		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
+		shinfo->nr_frags = MAX_SKB_FRAGS;
+	}
 	nr_slots = shinfo->nr_frags;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
@@ -926,6 +930,33 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 
 	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
 
+	if (frag_overflow) {
+		struct sk_buff *nskb = alloc_skb(NET_SKB_PAD + NET_IP_ALIGN,
+				GFP_ATOMIC | __GFP_NOWARN);
+		if (unlikely(nskb == NULL)) {
+			netdev_err(vif->dev,
+				   "Can't allocate the frag_list skb.\n");
+			return NULL;
+		}
+
+		/* Packets passed to netif_rx() must have some headroom. */
+		skb_reserve(nskb, NET_SKB_PAD + NET_IP_ALIGN);
+
+		shinfo = skb_shinfo(nskb);
+		frags = shinfo->frags;
+
+		for (shinfo->nr_frags = 0; shinfo->nr_frags < frag_overflow;
+		     shinfo->nr_frags++, txp++, gop++) {
+			index = pending_index(vif->pending_cons++);
+			pending_idx = vif->pending_ring[index];
+			xenvif_tx_create_gop(vif, pending_idx, txp, gop);
+			frag_set_pending_idx(&frags[shinfo->nr_frags],
+				pending_idx);
+		}
+
+		skb_shinfo(skb)->frag_list = nskb;
+	}
+
 	return gop;
 }
 
@@ -939,6 +970,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
+	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
 	err = gop->status;
@@ -958,6 +990,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
+check_frags:
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
 
@@ -992,11 +1025,20 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
 			continue;
-
 		/* First error: invalidate header and preceding fragments. */
-		pending_idx = *((u16 *)skb->data);
-		xenvif_idx_unmap(vif, pending_idx);
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
+		if (!first_skb) {
+			pending_idx = *((u16 *)skb->data);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif,
+				pending_idx,
+				XEN_NETIF_RSP_OKAY);
+		} else {
+			pending_idx = *((u16 *)first_skb->data);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif,
+				pending_idx,
+				XEN_NETIF_RSP_OKAY);
+		}
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xenvif_idx_unmap(vif, pending_idx);
@@ -1008,6 +1050,32 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		err = newerr;
 	}
 
+	if (shinfo->frag_list) {
+		first_skb = skb;
+		skb = shinfo->frag_list;
+		shinfo = skb_shinfo(skb);
+		nr_frags = shinfo->nr_frags;
+		start = 0;
+
+		goto check_frags;
+	}
+
+	/* There was a mapping error in the frag_list skb. We have to unmap
+	 * the first skb's frags
+	 */
+	if (first_skb && err) {
+		int j;
+		shinfo = skb_shinfo(first_skb);
+		pending_idx = *((u16 *)first_skb->data);
+		start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
+		for (j = start; j < shinfo->nr_frags; j++) {
+			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif, pending_idx,
+					   XEN_NETIF_RSP_OKAY);
+		}
+	}
+
 	*gopp = gop + 1;
 	return err;
 }
@@ -1541,6 +1609,7 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
 		unsigned data_len;
+		struct sk_buff *nskb = NULL;
 
 		pending_idx = *((u16 *)skb->data);
 		txp = &vif->pending_tx_info[pending_idx].req;
@@ -1583,6 +1652,23 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 					pending_idx :
 					INVALID_PENDING_IDX);
 
+		if (skb_shinfo(skb)->frag_list) {
+			nskb = skb_shinfo(skb)->frag_list;
+			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
+			skb->len += nskb->len;
+			skb->data_len += nskb->len;
+			skb->truesize += nskb->truesize;
+			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			vif->tx_zerocopy_sent += 2;
+			nskb = skb;
+
+			skb = skb_copy_expand(skb,
+					0,
+					0,
+					GFP_ATOMIC | __GFP_NOWARN);
+			skb_shinfo(skb)->destructor_arg = NULL;
+		}
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
@@ -1619,6 +1705,9 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 		}
 
 		netif_receive_skb(skb);
+
+		if (nskb)
+			kfree_skb(nskb);
 	}
 
 	return work_done;
