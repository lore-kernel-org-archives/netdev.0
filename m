From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 1/2] xen-netback: Rename map ops
Date: Wed, 2 Apr 2014 18:04:57 +0100
Message-ID: <1396458298-30041-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename identifiers to state explicitly that they refer to map ops.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v3:
- rename xenvif_tx_create_gop to xenvif_tx_create_map_op

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ae34f5f..8f468ab 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -819,13 +819,13 @@ struct xenvif_tx_cb {
 
 #define XENVIF_TX_CB(skb) ((struct xenvif_tx_cb *)(skb)->cb)
 
-static inline void xenvif_tx_create_gop(struct xenvif *vif,
-					u16 pending_idx,
-					struct xen_netif_tx_request *txp,
-					struct gnttab_map_grant_ref *gop)
+static inline void xenvif_tx_create_map_op(struct xenvif *vif,
+					  u16 pending_idx,
+					  struct xen_netif_tx_request *txp,
+					  struct gnttab_map_grant_ref *mop)
 {
-	vif->pages_to_map[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
-	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
+	vif->pages_to_map[mop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
+	gnttab_set_map_op(mop, idx_to_kaddr(vif, pending_idx),
 			  GNTMAP_host_map | GNTMAP_readonly,
 			  txp->gref, vif->domid);
 
@@ -879,7 +879,7 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	     shinfo->nr_frags++, txp++, gop++) {
 		index = pending_index(vif->pending_cons++);
 		pending_idx = vif->pending_ring[index];
-		xenvif_tx_create_gop(vif, pending_idx, txp, gop);
+		xenvif_tx_create_map_op(vif, pending_idx, txp, gop);
 		frag_set_pending_idx(&frags[shinfo->nr_frags], pending_idx);
 	}
 
@@ -899,7 +899,7 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 		     shinfo->nr_frags++, txp++, gop++) {
 			index = pending_index(vif->pending_cons++);
 			pending_idx = vif->pending_ring[index];
-			xenvif_tx_create_gop(vif, pending_idx, txp, gop);
+			xenvif_tx_create_map_op(vif, pending_idx, txp, gop);
 			frag_set_pending_idx(&frags[shinfo->nr_frags],
 					     pending_idx);
 		}
@@ -939,9 +939,9 @@ static inline void xenvif_grant_handle_reset(struct xenvif *vif,
 
 static int xenvif_tx_check_gop(struct xenvif *vif,
 			       struct sk_buff *skb,
-			       struct gnttab_map_grant_ref **gopp)
+			       struct gnttab_map_grant_ref **gopp_map)
 {
-	struct gnttab_map_grant_ref *gop = *gopp;
+	struct gnttab_map_grant_ref *gop_map = *gopp_map;
 	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	struct pending_tx_info *tx_info;
@@ -950,11 +950,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
-	err = gop->status;
+	err = gop_map->status;
 	if (unlikely(err))
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
 	else
-		xenvif_grant_handle_set(vif, pending_idx , gop->handle);
+		xenvif_grant_handle_set(vif, pending_idx , gop_map->handle);
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
@@ -967,10 +967,12 @@ check_frags:
 		tx_info = &vif->pending_tx_info[pending_idx];
 
 		/* Check error status: if okay then remember grant handle. */
-		newerr = (++gop)->status;
+		newerr = (++gop_map)->status;
 
 		if (likely(!newerr)) {
-			xenvif_grant_handle_set(vif, pending_idx , gop->handle);
+			xenvif_grant_handle_set(vif,
+						pending_idx,
+						gop_map->handle);
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
 				xenvif_idx_unmap(vif, pending_idx);
@@ -1022,7 +1024,7 @@ check_frags:
 		}
 	}
 
-	*gopp = gop + 1;
+	*gopp_map = gop_map + 1;
 	return err;
 }
 
@@ -1291,7 +1293,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			}
 		}
 
-		xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
+		xenvif_tx_create_map_op(vif, pending_idx, &txreq, gop);
 
 		gop++;
 
@@ -1398,7 +1400,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 
 static int xenvif_tx_submit(struct xenvif *vif)
 {
-	struct gnttab_map_grant_ref *gop = vif->tx_map_ops;
+	struct gnttab_map_grant_ref *gop_map = vif->tx_map_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
@@ -1411,7 +1413,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		txp = &vif->pending_tx_info[pending_idx].req;
 
 		/* Check the remap error code. */
-		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop))) {
+		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1610,21 +1612,21 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
 /* Called after netfront has transmitted */
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
-	unsigned nr_gops;
+	unsigned nr_mops;
 	int work_done, ret;
 
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
-	nr_gops = xenvif_tx_build_gops(vif, budget);
+	nr_mops = xenvif_tx_build_gops(vif, budget);
 
-	if (nr_gops == 0)
+	if (nr_mops == 0)
 		return 0;
 
 	ret = gnttab_map_refs(vif->tx_map_ops,
 			      NULL,
 			      vif->pages_to_map,
-			      nr_gops);
+			      nr_mops);
 	BUG_ON(ret);
 
 	work_done = xenvif_tx_submit(vif);
