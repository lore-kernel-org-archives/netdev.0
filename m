From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH] xen-netback: Allocate fraglist early to avoid complex rollback
Date: Mon, 3 Aug 2015 15:38:03 +0100
Message-ID: <1438612683-5783-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xenproject.org>, Wei Liu <wei.liu2@citrix.com>,
	"Ian Campbell" <ian.campbell@citrix.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46684 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbbHCOih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 10:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Determine if a fraglist is needed in the tx path, and allocate it if
necessary before setting up the copy and map operations.
Otherwise, undoing the copy and map operations is tricky.

This fixes a use-after-free: if allocating the fraglist failed, the copy
and map operations that had been set up were still executed, writing
over the data area of a freed skb.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---
 drivers/net/xen-netback/netback.c | 61 +++++++++++++++++++++------------------
 1 file changed, 33 insertions(+), 28 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7d50711..1b406e7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -810,23 +810,17 @@ static inline struct sk_buff *xenvif_alloc_skb(unsigned int size)
 static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif_queue *queue,
 							struct sk_buff *skb,
 							struct xen_netif_tx_request *txp,
-							struct gnttab_map_grant_ref *gop)
+							struct gnttab_map_grant_ref *gop,
+							unsigned int frag_overflow,
+							struct sk_buff *nskb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
 	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
 	int start;
 	pending_ring_idx_t index;
-	unsigned int nr_slots, frag_overflow = 0;
+	unsigned int nr_slots;
 
-	/* At this point shinfo->nr_frags is in fact the number of
-	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
-	 */
-	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
-		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
-		BUG_ON(frag_overflow > MAX_SKB_FRAGS);
-		shinfo->nr_frags = MAX_SKB_FRAGS;
-	}
 	nr_slots = shinfo->nr_frags;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
@@ -841,13 +835,6 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif_queue *que
 	}
 
 	if (frag_overflow) {
-		struct sk_buff *nskb = xenvif_alloc_skb(0);
-		if (unlikely(nskb == NULL)) {
-			if (net_ratelimit())
-				netdev_err(queue->vif->dev,
-					   "Can't allocate the frag_list skb.\n");
-			return NULL;
-		}
 
 		shinfo = skb_shinfo(nskb);
 		frags = shinfo->frags;
@@ -1175,9 +1162,10 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 				     unsigned *copy_ops,
 				     unsigned *map_ops)
 {
-	struct gnttab_map_grant_ref *gop = queue->tx_map_ops, *request_gop;
-	struct sk_buff *skb;
+	struct gnttab_map_grant_ref *gop = queue->tx_map_ops;
+	struct sk_buff *skb, *nskb;
 	int ret;
+	unsigned int frag_overflow;
 
 	while (skb_queue_len(&queue->tx_queue) < budget) {
 		struct xen_netif_tx_request txreq;
@@ -1265,6 +1253,29 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			break;
 		}
 
+		skb_shinfo(skb)->nr_frags = ret;
+		if (data_len < txreq.size)
+			skb_shinfo(skb)->nr_frags++;
+		/* At this point shinfo->nr_frags is in fact the number of
+		 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
+		 */
+		frag_overflow = 0;
+		nskb = NULL;
+		if (skb_shinfo(skb)->nr_frags > MAX_SKB_FRAGS) {
+			frag_overflow = skb_shinfo(skb)->nr_frags - MAX_SKB_FRAGS;
+			BUG_ON(frag_overflow > MAX_SKB_FRAGS);
+			skb_shinfo(skb)->nr_frags = MAX_SKB_FRAGS;
+			nskb = xenvif_alloc_skb(0);
+			if (unlikely(nskb == NULL)) {
+				kfree_skb(skb);
+				xenvif_tx_err(queue, &txreq, idx);
+				if (net_ratelimit())
+					netdev_err(queue->vif->dev,
+						   "Can't allocate the frag_list skb.\n");
+				break;
+			}
+		}
+
 		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
@@ -1272,6 +1283,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			if (xenvif_set_skb_gso(queue->vif, skb, gso)) {
 				/* Failure in xenvif_set_skb_gso is fatal. */
 				kfree_skb(skb);
+				kfree_skb(nskb);
 				break;
 			}
 		}
@@ -1294,9 +1306,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 
 		(*copy_ops)++;
 
-		skb_shinfo(skb)->nr_frags = ret;
 		if (data_len < txreq.size) {
-			skb_shinfo(skb)->nr_frags++;
 			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
 					     pending_idx);
 			xenvif_tx_create_map_op(queue, pending_idx, &txreq, gop);
@@ -1310,13 +1320,8 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 
 		queue->pending_cons++;
 
-		request_gop = xenvif_get_requests(queue, skb, txfrags, gop);
-		if (request_gop == NULL) {
-			kfree_skb(skb);
-			xenvif_tx_err(queue, &txreq, idx);
-			break;
-		}
-		gop = request_gop;
+		gop = xenvif_get_requests(queue, skb, txfrags, gop,
+				          frag_overflow, nskb);
 
 		__skb_queue_tail(&queue->tx_queue, skb);
 
-- 
2.1.0
