From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v2 2/2] xen-netback: Grant copy the header instead of map and memcpy
Date: Mon, 31 Mar 2014 16:08:59 +0100
Message-ID: <1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:60483 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbaCaPJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:09:23 -0400
In-Reply-To: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Note, we only grant copy PKT_PROT_LEN bytes from the first slot, the rest (if
any) will be on the first frag, which is grant mapped. If the first slot is
smaller than PKT_PROT_LEN, then we grant copy that, and later __pskb_pull_tail
will pull more from the frags (if any)

Unrelated, but I've made a small refactoring in xenvif_get_extras as well.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v2:
- extend commit message
- add patch to rename map ops

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
index e781366..ba11ff5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -915,35 +915,30 @@ static inline void xenvif_grant_handle_reset(struct xenvif *vif,
 
 static int xenvif_tx_check_gop(struct xenvif *vif,
 			       struct sk_buff *skb,
-			       struct gnttab_map_grant_ref **gopp_map)
+			       struct gnttab_map_grant_ref **gopp_map,
+			       struct gnttab_copy **gopp_copy)
 {
 	struct gnttab_map_grant_ref *gop_map = *gopp_map;
 	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
-	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
-	int i, err, start;
+	int i, err;
 	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
-	err = gop_map->status;
+	err = (*gopp_copy)->status;
+	(*gopp_copy)++;
 	if (unlikely(err))
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
-	else
-		xenvif_grant_handle_set(vif, pending_idx , gop_map->handle);
-
-	/* Skip first skb fragment if it is on same page as header fragment. */
-	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 check_frags:
-	for (i = start; i < nr_frags; i++) {
+	for (i = 0; i < nr_frags; i++, gop_map++) {
 		int j, newerr;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
-		tx_info = &vif->pending_tx_info[pending_idx];
 
 		/* Check error status: if okay then remember grant handle. */
-		newerr = (++gop_map)->status;
+		newerr = (gop_map)->status;
 
 		if (likely(!newerr)) {
 			xenvif_grant_handle_set(vif,
@@ -961,13 +956,8 @@ check_frags:
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
@@ -981,7 +971,6 @@ check_frags:
 		skb = shinfo->frag_list;
 		shinfo = skb_shinfo(skb);
 		nr_frags = shinfo->nr_frags;
-		start = 0;
 
 		goto check_frags;
 	}
@@ -992,15 +981,13 @@ check_frags:
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
 
-	*gopp_map = gop_map + 1;
+	*gopp_map = gop_map;
 	return err;
 }
 
@@ -1011,9 +998,6 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 	int i;
 	u16 prev_pending_idx = INVALID_PENDING_IDX;
 
-	if (skb_shinfo(skb)->destructor_arg)
-		prev_pending_idx = XENVIF_TX_CB(skb)->pending_idx;
-
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = shinfo->frags + i;
 		struct xen_netif_tx_request *txp;
@@ -1023,10 +1007,10 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
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
 
@@ -1067,9 +1051,9 @@ static int xenvif_get_extras(struct xenvif *vif,
 
 		memcpy(&extra, RING_GET_REQUEST(&vif->tx, cons),
 		       sizeof(extra));
+		vif->tx.req_cons = ++cons;
 		if (unlikely(!extra.type ||
 			     extra.type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
-			vif->tx.req_cons = ++cons;
 			netdev_err(vif->dev,
 				   "Invalid extra type: %d\n", extra.type);
 			xenvif_fatal_tx_err(vif);
@@ -1077,7 +1061,6 @@ static int xenvif_get_extras(struct xenvif *vif,
 		}
 
 		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
-		vif->tx.req_cons = ++cons;
 	} while (extra.flags & XEN_NETIF_EXTRA_FLAG_MORE);
 
 	return work_to_do;
@@ -1166,7 +1149,10 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
+static void xenvif_tx_build_gops(struct xenvif *vif,
+				     int budget,
+				     unsigned *copy_ops,
+				     unsigned *map_ops)
 {
 	struct gnttab_map_grant_ref *gop = vif->tx_map_ops, *request_gop;
 	struct sk_buff *skb;
@@ -1269,24 +1255,39 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
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
+		vif->tx_copy_ops[*copy_ops].dest.u.gmfn =
+			virt_to_mfn(skb->data);
+		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
+		vif->tx_copy_ops[*copy_ops].dest.offset =
+			offset_in_page(skb->data);
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
@@ -1301,11 +1302,13 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops))
+		if (((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops)) ||
+		    (*copy_ops >= ARRAY_SIZE(vif->tx_map_ops)))
 			break;
 	}
 
-	return gop - vif->tx_map_ops;
+	(*map_ops) = gop - vif->tx_map_ops;
+	return;
 }
 
 /* Consolidate skb with a frag_list into a brand new one with local pages on
@@ -1377,6 +1380,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 static int xenvif_tx_submit(struct xenvif *vif)
 {
 	struct gnttab_map_grant_ref *gop_map = vif->tx_map_ops;
+	struct gnttab_copy *gop_copy = vif->tx_copy_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
@@ -1389,7 +1393,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		txp = &vif->pending_tx_info[pending_idx].req;
 
 		/* Check the remap error code. */
-		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map))) {
+		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map, &gop_copy))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1397,19 +1401,15 @@ static int xenvif_tx_submit(struct xenvif *vif)
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
@@ -1588,22 +1588,26 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
 /* Called after netfront has transmitted */
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
-	unsigned nr_mops;
+	unsigned nr_mops, nr_cops = 0;
 	int work_done, ret;
 
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
-	nr_mops = xenvif_tx_build_gops(vif, budget);
+	xenvif_tx_build_gops(vif, budget, &nr_cops, &nr_mops);
 
-	if (nr_mops == 0)
+	if (nr_cops == 0)
 		return 0;
-
-	ret = gnttab_map_refs(vif->tx_map_ops,
-			      NULL,
-			      vif->pages_to_map,
-			      nr_mops);
-	BUG_ON(ret);
+	else {
+		gnttab_batch_copy(vif->tx_copy_ops, nr_cops);
+		if (nr_mops != 0) {
+			ret = gnttab_map_refs(vif->tx_map_ops,
+					      NULL,
+					      vif->pages_to_map,
+					      nr_mops);
+			BUG_ON(ret);
+		}
+	}
 
 	work_done = xenvif_tx_submit(vif);
 
