From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next RFC 2/5] xen-netback: Change TX path from grant copy to mapping
Date: Wed, 30 Oct 2013 00:50:17 +0000
Message-ID: <1383094220-14775-3-git-send-email-zoltan.kiss@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the grant copy on the TX patch to grant mapping

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/interface.c |   39 +++++-
 drivers/net/xen-netback/netback.c   |  241 +++++++++++++----------------------
 2 files changed, 126 insertions(+), 154 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f5c3c57..fb16ede 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -336,8 +336,20 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->pending_prod = MAX_PENDING_REQS;
 	for (i = 0; i < MAX_PENDING_REQS; i++)
 		vif->pending_ring[i] = i;
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		vif->mmap_pages[i] = NULL;
+	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
+		vif->mmap_pages,
+		false);
+	if (err) {
+		netdev_err(dev, "Could not reserve mmap_pages\n");
+		return NULL;
+	}
+	for (i = 0; i < MAX_PENDING_REQS; i++) {
+		vif->pending_tx_info[i].callback_struct = (struct ubuf_info)
+			{ .callback = xenvif_zerocopy_callback,
+			  .ctx = NULL,
+			  .desc = i };
+		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
+	}
 
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
@@ -481,11 +493,34 @@ void xenvif_disconnect(struct xenvif *vif)
 
 void xenvif_free(struct xenvif *vif)
 {
+	int i;
+
 	netif_napi_del(&vif->napi);
 
 	unregister_netdev(vif->dev);
 
 	free_netdev(vif->dev);
 
+	/* FIXME: This is a workaround for 2 problems:
+	 * - the guest sent a packet just before teardown, and it is still not
+	 *   delivered
+	 * - the stack forgot to notify us that we can give back a slot
+	 * For the first problem we shouldn't do this, as the skb might still
+	 * access that page. I will come up with a more robust solution later.
+	 * The second is definitely a bug, it leaks a slot from the ring
+	 * forever.
+	 * Classic kernel patchset has delayed copy for that, we might want to
+	 * reuse that?
+	 */
+	for (i = 0; i < MAX_PENDING_REQS; ++i) {
+		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
+			netdev_err(vif->dev,
+				"Page still granted! Index: %x\n", i);
+			xenvif_idx_unmap(vif, i);
+		}
+	}
+
+	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
+
 	module_put(THIS_MODULE);
 }
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 10470dc..e544e9f 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -883,10 +883,10 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
 
 }
 
-static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
+static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 					       struct sk_buff *skb,
 					       struct xen_netif_tx_request *txp,
-					       struct gnttab_copy *gop)
+					       struct gnttab_map_grant_ref *gop)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
@@ -907,83 +907,12 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
-	/* Coalesce tx requests, at this point the packet passed in
-	 * should be <= 64K. Any packets larger than 64K have been
-	 * handled in xenvif_count_requests().
-	 */
-	for (shinfo->nr_frags = slot = start; slot < nr_slots;
-	     shinfo->nr_frags++) {
-		struct pending_tx_info *pending_tx_info =
-			vif->pending_tx_info;
-
-		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
-		if (!page)
-			goto err;
-
-		dst_offset = 0;
-		first = NULL;
-		while (dst_offset < PAGE_SIZE && slot < nr_slots) {
-			gop->flags = GNTCOPY_source_gref;
-
-			gop->source.u.ref = txp->gref;
-			gop->source.domid = vif->domid;
-			gop->source.offset = txp->offset;
-
-			gop->dest.domid = DOMID_SELF;
-
-			gop->dest.offset = dst_offset;
-			gop->dest.u.gmfn = virt_to_mfn(page_address(page));
-
-			if (dst_offset + txp->size > PAGE_SIZE) {
-				/* This page can only merge a portion
-				 * of tx request. Do not increment any
-				 * pointer / counter here. The txp
-				 * will be dealt with in future
-				 * rounds, eventually hitting the
-				 * `else` branch.
-				 */
-				gop->len = PAGE_SIZE - dst_offset;
-				txp->offset += gop->len;
-				txp->size -= gop->len;
-				dst_offset += gop->len; /* quit loop */
-			} else {
-				/* This tx request can be merged in the page */
-				gop->len = txp->size;
-				dst_offset += gop->len;
-
+	for (shinfo->nr_frags = start; shinfo->nr_frags < nr_slots;
+	     shinfo->nr_frags++, txp++, gop++) {
 				index = pending_index(vif->pending_cons++);
-
 				pending_idx = vif->pending_ring[index];
-
-				memcpy(&pending_tx_info[pending_idx].req, txp,
-				       sizeof(*txp));
-
-				/* Poison these fields, corresponding
-				 * fields for head tx req will be set
-				 * to correct values after the loop.
-				 */
-				vif->mmap_pages[pending_idx] = (void *)(~0UL);
-				pending_tx_info[pending_idx].head =
-					INVALID_PENDING_RING_IDX;
-
-				if (!first) {
-					first = &pending_tx_info[pending_idx];
-					start_idx = index;
-					head_idx = pending_idx;
-				}
-
-				txp++;
-				slot++;
-			}
-
-			gop++;
-		}
-
-		first->req.offset = 0;
-		first->req.size = dst_offset;
-		first->head = start_idx;
-		vif->mmap_pages[head_idx] = page;
-		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
+		xenvif_tx_create_gop(vif, pending_idx, txp, gop);
+		frag_set_pending_idx(&frags[shinfo->nr_frags], pending_idx);
 	}
 
 	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
@@ -1005,9 +934,9 @@ err:
 
 static int xenvif_tx_check_gop(struct xenvif *vif,
 			       struct sk_buff *skb,
-			       struct gnttab_copy **gopp)
+			       struct gnttab_map_grant_ref **gopp)
 {
-	struct gnttab_copy *gop = *gopp;
+	struct gnttab_map_grant_ref *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	struct pending_tx_info *tx_info;
@@ -1019,6 +948,16 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	err = gop->status;
 	if (unlikely(err))
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
+	else {
+		if (vif->grant_tx_handle[pending_idx] !=
+			NETBACK_INVALID_HANDLE) {
+			netdev_err(vif->dev,
+				"Stale mapped handle! pending_idx %x handle %x\n",
+				pending_idx, vif->grant_tx_handle[pending_idx]);
+			xenvif_fatal_tx_err(vif);
+		}
+		vif->grant_tx_handle[pending_idx] = gop->handle;
+	}
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
@@ -1032,18 +971,24 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		head = tx_info->head;
 
 		/* Check error status: if okay then remember grant handle. */
-		do {
 			newerr = (++gop)->status;
-			if (newerr)
-				break;
-			peek = vif->pending_ring[pending_index(++head)];
-		} while (!pending_tx_is_head(vif, peek));
 
 		if (likely(!newerr)) {
+			if (vif->grant_tx_handle[pending_idx] !=
+				NETBACK_INVALID_HANDLE) {
+				netdev_err(vif->dev,
+					"Stale mapped handle! pending_idx %x handle %x\n",
+					pending_idx,
+					vif->grant_tx_handle[pending_idx]);
+				xenvif_fatal_tx_err(vif);
+			}
+			vif->grant_tx_handle[pending_idx] = gop->handle;
 			/* Had a previous error? Invalidate this fragment. */
-			if (unlikely(err))
+			if (unlikely(err)) {
+				xenvif_idx_unmap(vif, pending_idx);
 				xenvif_idx_release(vif, pending_idx,
 						   XEN_NETIF_RSP_OKAY);
+			}
 			continue;
 		}
 
@@ -1056,9 +1001,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
+		xenvif_idx_unmap(vif, pending_idx);
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
+			xenvif_idx_unmap(vif, pending_idx);
 			xenvif_idx_release(vif, pending_idx,
 					   XEN_NETIF_RSP_OKAY);
 		}
@@ -1071,7 +1018,8 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	return err;
 }
 
-static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
+static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb,
+		u16 prev_pending_idx)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -1085,6 +1033,15 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 
 		pending_idx = frag_get_pending_idx(frag);
 
+		/* If this is not the first frag, chain it to the previous*/
+		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
+		if (pending_idx != prev_pending_idx) {
+			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
+				&(vif->pending_tx_info[pending_idx].callback_struct);
+			prev_pending_idx = pending_idx;
+		}
+
+
 		txp = &vif->pending_tx_info[pending_idx].req;
 		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
@@ -1092,10 +1049,15 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 		skb->data_len += txp->size;
 		skb->truesize += txp->size;
 
-		/* Take an extra reference to offset xenvif_idx_release */
+		/* Take an extra reference to offset network stack's put_page */
 		get_page(vif->mmap_pages[pending_idx]);
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 	}
+	/* FIXME: __skb_fill_page_desc set this to true because page->pfmemalloc
+	 * overlaps with "index", and "mapping" is not set. I think mapping
+	 * should be set. If delivered to local stack, it would drop this
+	 * skb in sk_filter unless the socket has the right to use it.
+	 */
+	skb->pfmemalloc	= false;
 }
 
 static int xenvif_get_extras(struct xenvif *vif,
@@ -1426,7 +1388,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 
 static unsigned xenvif_tx_build_gops(struct xenvif *vif)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops, *request_gop;
+	struct gnttab_map_grant_ref *gop = vif->tx_map_ops, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 
@@ -1533,30 +1495,10 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
 			}
 		}
 
-		/* XXX could copy straight to head */
-		page = xenvif_alloc_page(vif, pending_idx);
-		if (!page) {
-			kfree_skb(skb);
-			xenvif_tx_err(vif, &txreq, idx);
-			break;
-		}
-
-		gop->source.u.ref = txreq.gref;
-		gop->source.domid = vif->domid;
-		gop->source.offset = txreq.offset;
-
-		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
-		gop->dest.domid = DOMID_SELF;
-		gop->dest.offset = txreq.offset;
-
-		gop->len = txreq.size;
-		gop->flags = GNTCOPY_source_gref;
+		xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
 
 		gop++;
 
-		memcpy(&vif->pending_tx_info[pending_idx].req,
-		       &txreq, sizeof(txreq));
-		vif->pending_tx_info[pending_idx].head = index;
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1585,17 +1527,17 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-vif->tx_copy_ops) >= ARRAY_SIZE(vif->tx_copy_ops))
+		if ((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops))
 			break;
 	}
 
-	return gop - vif->tx_copy_ops;
+	return gop - vif->tx_map_ops;
 }
 
 
 static int xenvif_tx_submit(struct xenvif *vif, int budget)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops;
+	struct gnttab_map_grant_ref *gop = vif->tx_map_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
@@ -1620,14 +1562,25 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 		memcpy(skb->data,
 		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
 		       data_len);
+		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
 			txp->offset += data_len;
 			txp->size -= data_len;
-		} else {
+			skb_shinfo(skb)->destructor_arg =
+				&vif->pending_tx_info[pending_idx].callback_struct;
+		} else if (!skb_shinfo(skb)->nr_frags) {
 			/* Schedule a response immediately. */
+			skb_shinfo(skb)->destructor_arg = NULL;
+			xenvif_idx_unmap(vif, pending_idx);
 			xenvif_idx_release(vif, pending_idx,
 					   XEN_NETIF_RSP_OKAY);
+		} else {
+			/* FIXME: first request fits linear space, I don't know
+			 * if any guest would do that, but I think it's possible
+			 */
+			skb_shinfo(skb)->destructor_arg =
+				&vif->pending_tx_info[pending_idx].callback_struct;
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1635,13 +1588,19 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xenvif_fill_frags(vif, skb);
+		xenvif_fill_frags(vif, skb, pending_idx);
 
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
 		}
 
+		/* Set this flag after __pskb_pull_tail, as it can trigger
+		 * skb_copy_ubufs, while we are still in control of the skb
+		 */
+		if (skb_shinfo(skb)->destructor_arg)
+			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+
 		skb->dev      = vif->dev;
 		skb->protocol = eth_type_trans(skb, skb->dev);
 		skb_reset_network_header(skb);
@@ -1770,17 +1729,25 @@ static inline void xenvif_tx_action_dealloc(struct xenvif *vif)
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
 	unsigned nr_gops;
-	int work_done;
+	int work_done, ret;
 
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
+	xenvif_tx_action_dealloc(vif);
+
 	nr_gops = xenvif_tx_build_gops(vif);
 
 	if (nr_gops == 0)
 		return 0;
 
-	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
+	if (nr_gops) {
+		ret = gnttab_map_refs(vif->tx_map_ops,
+			NULL,
+			vif->pages_to_gnt,
+			nr_gops);
+		BUG_ON(ret);
+	}
 
 	work_done = xenvif_tx_submit(vif, nr_gops);
 
@@ -1791,45 +1758,13 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 			       u8 status)
 {
 	struct pending_tx_info *pending_tx_info;
-	pending_ring_idx_t head;
+	pending_ring_idx_t index;
 	u16 peek; /* peek into next tx request */
 
-	BUG_ON(vif->mmap_pages[pending_idx] == (void *)(~0UL));
-
-	/* Already complete? */
-	if (vif->mmap_pages[pending_idx] == NULL)
-		return;
-
-	pending_tx_info = &vif->pending_tx_info[pending_idx];
-
-	head = pending_tx_info->head;
-
-	BUG_ON(!pending_tx_is_head(vif, head));
-	BUG_ON(vif->pending_ring[pending_index(head)] != pending_idx);
-
-	do {
-		pending_ring_idx_t index;
-		pending_ring_idx_t idx = pending_index(head);
-		u16 info_idx = vif->pending_ring[idx];
-
-		pending_tx_info = &vif->pending_tx_info[info_idx];
+		pending_tx_info = &vif->pending_tx_info[pending_idx];
 		make_tx_response(vif, &pending_tx_info->req, status);
-
-		/* Setting any number other than
-		 * INVALID_PENDING_RING_IDX indicates this slot is
-		 * starting a new packet / ending a previous packet.
-		 */
-		pending_tx_info->head = 0;
-
 		index = pending_index(vif->pending_prod++);
-		vif->pending_ring[index] = vif->pending_ring[info_idx];
-
-		peek = vif->pending_ring[pending_index(++head)];
-
-	} while (!pending_tx_is_head(vif, peek));
-
-	put_page(vif->mmap_pages[pending_idx]);
-	vif->mmap_pages[pending_idx] = NULL;
+		vif->pending_ring[index] = pending_idx;
 }
 
 void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
@@ -1904,6 +1839,8 @@ static inline int rx_work_todo(struct xenvif *vif)
 
 static inline int tx_work_todo(struct xenvif *vif)
 {
+	if (vif->dealloc_cons != vif->dealloc_prod)
+		return 1;
 
 	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
 	    (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
