From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] xen-netback: Grant copy the header instead of map and memcpy
Date: Wed, 26 Mar 2014 21:18:27 +0000
Message-ID: <1395868707-22683-1-git-send-email-zoltan.kiss@citrix.com>
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

An old inefficiency of the TX path that we are grant mapping the first slot,
and then copy the header part to the linear area. Instead, doing a grant copy
for that header straight on is more reasonable. Especially because there are
ongoing efforts to make Xen avoiding TLB flush after unmap when the page were
not touched in Dom0. In the original way the memcpy ruined that.
The key changes:
- the vif has a tx_copy_ops array again
- xenvif_tx_build_gops sets up the grant copy operations
- we don't have to figure out whether the header and first frag are on the same
  grant mapped page or not

Unrelated, but I've made a small refactoring in xenvif_get_extras as well.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |  100 ++++++++++++++++++-------------------
 2 files changed, 49 insertions(+), 52 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 89b2d42..c995532 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -119,6 +119,7 @@ struct xenvif {
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
 	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
 
+	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
 	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
 	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
 	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 0efa32d..2d33078 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -915,35 +915,30 @@ static inline void xenvif_grant_handle_reset(struct xenvif *vif,
 
 static int xenvif_tx_check_gop(struct xenvif *vif,
 			       struct sk_buff *skb,
-			       struct gnttab_map_grant_ref **gopp)
+			       struct gnttab_map_grant_ref **gopp,
+			       struct gnttab_copy **gopp_copy)
 {
 	struct gnttab_map_grant_ref *gop = *gopp;
 	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
-	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
-	int i, err, start;
+	int i, err;
 	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
-	err = gop->status;
+	err = (*gopp_copy)->status;
+	(*gopp_copy)++;
 	if (unlikely(err))
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
-	else
-		xenvif_grant_handle_set(vif, pending_idx , gop->handle);
-
-	/* Skip first skb fragment if it is on same page as header fragment. */
-	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 check_frags:
-	for (i = start; i < nr_frags; i++) {
+	for (i = 0; i < nr_frags; i++, gop++) {
 		int j, newerr;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
-		tx_info = &vif->pending_tx_info[pending_idx];
 
 		/* Check error status: if okay then remember grant handle. */
-		newerr = (++gop)->status;
+		newerr = (gop)->status;
 
 		if (likely(!newerr)) {
 			xenvif_grant_handle_set(vif, pending_idx , gop->handle);
@@ -959,13 +954,8 @@ check_frags:
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
 			continue;
-		/* First error: invalidate header and preceding fragments. */
-		if (!first_skb)
-			pending_idx = XENVIF_TX_CB(skb)->pending_idx;
-		else
-			pending_idx = XENVIF_TX_CB(skb)->pending_idx;
-		xenvif_idx_unmap(vif, pending_idx);
-		for (j = start; j < i; j++) {
+		/* First error: invalidate preceding fragments. */
+		for (j = 0; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xenvif_idx_unmap(vif, pending_idx);
 		}
@@ -979,7 +969,6 @@ check_frags:
 		skb = shinfo->frag_list;
 		shinfo = skb_shinfo(skb);
 		nr_frags = shinfo->nr_frags;
-		start = 0;
 
 		goto check_frags;
 	}
@@ -990,15 +979,13 @@ check_frags:
 	if (first_skb && err) {
 		int j;
 		shinfo = skb_shinfo(first_skb);
-		pending_idx = XENVIF_TX_CB(skb)->pending_idx;
-		start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
-		for (j = start; j < shinfo->nr_frags; j++) {
+		for (j = 0; j < shinfo->nr_frags; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xenvif_idx_unmap(vif, pending_idx);
 		}
 	}
 
-	*gopp = gop + 1;
+	*gopp = gop;
 	return err;
 }
 
@@ -1009,9 +996,6 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 	int i;
 	u16 prev_pending_idx = INVALID_PENDING_IDX;
 
-	if (skb_shinfo(skb)->destructor_arg)
-		prev_pending_idx = XENVIF_TX_CB(skb)->pending_idx;
-
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = shinfo->frags + i;
 		struct xen_netif_tx_request *txp;
@@ -1021,10 +1005,10 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 		pending_idx = frag_get_pending_idx(frag);
 
 		/* If this is not the first frag, chain it to the previous*/
-		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
+		if (prev_pending_idx == INVALID_PENDING_IDX)
 			skb_shinfo(skb)->destructor_arg =
 				&callback_param(vif, pending_idx);
-		else if (likely(pending_idx != prev_pending_idx))
+		else
 			callback_param(vif, prev_pending_idx).ctx =
 				&callback_param(vif, pending_idx);
 
@@ -1065,9 +1049,9 @@ static int xenvif_get_extras(struct xenvif *vif,
 
 		memcpy(&extra, RING_GET_REQUEST(&vif->tx, cons),
 		       sizeof(extra));
+		vif->tx.req_cons = ++cons;
 		if (unlikely(!extra.type ||
 			     extra.type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
-			vif->tx.req_cons = ++cons;
 			netdev_err(vif->dev,
 				   "Invalid extra type: %d\n", extra.type);
 			xenvif_fatal_tx_err(vif);
@@ -1075,7 +1059,6 @@ static int xenvif_get_extras(struct xenvif *vif,
 		}
 
 		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
-		vif->tx.req_cons = ++cons;
 	} while (extra.flags & XEN_NETIF_EXTRA_FLAG_MORE);
 
 	return work_to_do;
@@ -1164,7 +1147,9 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
+static unsigned xenvif_tx_build_gops(struct xenvif *vif,
+				     int budget,
+				     unsigned *copy_ops)
 {
 	struct gnttab_map_grant_ref *gop = vif->tx_map_ops, *request_gop;
 	struct sk_buff *skb;
@@ -1267,24 +1252,37 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			}
 		}
 
-		xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
-
-		gop++;
-
 		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
 
 		__skb_put(skb, data_len);
+		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
+		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
+		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
+
+		vif->tx_copy_ops[*copy_ops].dest.u.gmfn = virt_to_mfn(skb->data);
+		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
+		vif->tx_copy_ops[*copy_ops].dest.offset = offset_in_page(skb->data);
+
+		vif->tx_copy_ops[*copy_ops].len = data_len;
+		vif->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
+
+		(*copy_ops)++;
 
 		skb_shinfo(skb)->nr_frags = ret;
 		if (data_len < txreq.size) {
 			skb_shinfo(skb)->nr_frags++;
 			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
 					     pending_idx);
+			xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
+			gop++;
 		} else {
 			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
 					     INVALID_PENDING_IDX);
+			memcpy(&vif->pending_tx_info[pending_idx].req, &txreq,
+			       sizeof(txreq));
 		}
 
+
 		vif->pending_cons++;
 
 		request_gop = xenvif_get_requests(vif, skb, txfrags, gop);
@@ -1299,7 +1297,8 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops))
+		if (((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops)) ||
+		    (*copy_ops >= ARRAY_SIZE(vif->tx_map_ops)))
 			break;
 	}
 
@@ -1375,6 +1374,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 static int xenvif_tx_submit(struct xenvif *vif)
 {
 	struct gnttab_map_grant_ref *gop = vif->tx_map_ops;
+	struct gnttab_copy *gop_copy = vif->tx_copy_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
@@ -1387,7 +1387,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		txp = &vif->pending_tx_info[pending_idx].req;
 
 		/* Check the remap error code. */
-		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop))) {
+		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop, &gop_copy))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1395,19 +1395,15 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		}
 
 		data_len = skb->len;
-		memcpy(skb->data,
-		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
-		       data_len);
 		callback_param(vif, pending_idx).ctx = NULL;
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
 			txp->offset += data_len;
 			txp->size -= data_len;
-			skb_shinfo(skb)->destructor_arg =
-				&callback_param(vif, pending_idx);
 		} else {
 			/* Schedule a response immediately. */
-			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif, pending_idx,
+					   XEN_NETIF_RSP_OKAY);
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1586,17 +1582,19 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
 /* Called after netfront has transmitted */
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
-	unsigned nr_gops;
+	unsigned nr_gops, nr_cops = 0;
 	int work_done, ret;
 
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
-	nr_gops = xenvif_tx_build_gops(vif, budget);
+	nr_gops = xenvif_tx_build_gops(vif, budget, &nr_cops);
 
-	if (nr_gops == 0)
+	if ((nr_cops == 0) && (nr_gops == 0))
 		return 0;
 
+	gnttab_batch_copy(vif->tx_copy_ops, nr_cops);
+
 	ret = gnttab_map_refs(vif->tx_map_ops,
 			      NULL,
 			      vif->pages_to_map,
