From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v5 2/9] xen-netback: Change TX path from grant copy to mapping
Date: Mon, 20 Jan 2014 21:24:22 +0000
Message-ID: <1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the grant copy on the TX patch to grant mapping

v2:
- delete branch for handling fragmented packets fit PKT_PROT_LEN sized first
  request
- mark the effect of using ballooned pages in a comment
- place setting of skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY right
  before netif_receive_skb, and mark the importance of it
- grab dealloc_lock before __napi_complete to avoid contention with the
  callback's napi_schedule
- handle fragmented packets where first request < PKT_PROT_LEN
- fix up error path when checksum_setup failed
- check before teardown for pending grants, and start complain if they are
  there after 10 second

v3:
- delete a surplus checking from tx_action
- remove stray line
- squash xenvif_idx_unmap changes into the first patch
- init spinlocks
- call map hypercall directly instead of gnttab_map_refs()
- fix unmapping timeout in xenvif_free()

v4:
- fix indentations and comments
- handle errors of set_phys_to_machine
- go back to gnttab_map_refs instead of direct hypercall. Now we rely on the
  modified API

v5:
- BUG_ON(vif->dealloc_task) in xenvif_connect
- use 'task' in xenvif_connect for thread creation
- proper return value if alloc_xenballooned_pages fails
- BUG in xenvif_tx_check_gop if stale handle found

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/interface.c |   63 ++++++++-
 drivers/net/xen-netback/netback.c   |  254 ++++++++++++++---------------------
 2 files changed, 160 insertions(+), 157 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f0f0c3d..b3daae2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -122,7 +122,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	BUG_ON(skb->dev != dev);
 
 	/* Drop the packet if vif is not ready */
-	if (vif->task == NULL || !xenvif_schedulable(vif))
+	if (vif->task == NULL ||
+	    vif->dealloc_task == NULL ||
+	    !xenvif_schedulable(vif))
 		goto drop;
 
 	/* At best we'll need one slot for the header and one for each
@@ -344,8 +346,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->pending_prod = MAX_PENDING_REQS;
 	for (i = 0; i < MAX_PENDING_REQS; i++)
 		vif->pending_ring[i] = i;
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		vif->mmap_pages[i] = NULL;
+	spin_lock_init(&vif->dealloc_lock);
+	spin_lock_init(&vif->response_lock);
+	/* If ballooning is disabled, this will consume real memory, so you
+	 * better enable it. The long term solution would be to use just a
+	 * bunch of valid page descriptors, without dependency on ballooning
+	 */
+	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
+				       vif->mmap_pages,
+				       false);
+	if (err) {
+		netdev_err(dev, "Could not reserve mmap_pages\n");
+		return ERR_PTR(-ENOMEM);
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
@@ -383,12 +403,14 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	BUG_ON(vif->tx_irq);
 	BUG_ON(vif->task);
+	BUG_ON(vif->dealloc_task);
 
 	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
 
 	init_waitqueue_head(&vif->wq);
+	init_waitqueue_head(&vif->dealloc_wq);
 
 	if (tx_evtchn == rx_evtchn) {
 		/* feature-split-event-channels == 0 */
@@ -432,6 +454,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	vif->task = task;
 
+	task = kthread_create(xenvif_dealloc_kthread,
+					   (void *)vif,
+					   "%s-dealloc",
+					   vif->dev->name);
+	if (IS_ERR(task)) {
+		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
+		err = PTR_ERR(task);
+		goto err_rx_unbind;
+	}
+
+	vif->dealloc_task = task;
+
 	rtnl_lock();
 	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
 		dev_set_mtu(vif->dev, ETH_DATA_LEN);
@@ -442,6 +476,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	rtnl_unlock();
 
 	wake_up_process(vif->task);
+	wake_up_process(vif->dealloc_task);
 
 	return 0;
 
@@ -479,6 +514,11 @@ void xenvif_disconnect(struct xenvif *vif)
 		vif->task = NULL;
 	}
 
+	if (vif->dealloc_task) {
+		kthread_stop(vif->dealloc_task);
+		vif->dealloc_task = NULL;
+	}
+
 	if (vif->tx_irq) {
 		if (vif->tx_irq == vif->rx_irq)
 			unbind_from_irqhandler(vif->tx_irq, vif);
@@ -494,6 +534,23 @@ void xenvif_disconnect(struct xenvif *vif)
 
 void xenvif_free(struct xenvif *vif)
 {
+	int i, unmap_timeout = 0;
+
+	for (i = 0; i < MAX_PENDING_REQS; ++i) {
+		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
+			unmap_timeout++;
+			schedule_timeout(msecs_to_jiffies(1000));
+			if (unmap_timeout > 9 &&
+			    net_ratelimit())
+				netdev_err(vif->dev,
+					   "Page still granted! Index: %x\n",
+					   i);
+			i = -1;
+		}
+	}
+
+	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
+
 	netif_napi_del(&vif->napi);
 
 	unregister_netdev(vif->dev);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 195602f..747b428 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -646,9 +646,12 @@ static void xenvif_tx_err(struct xenvif *vif,
 			  struct xen_netif_tx_request *txp, RING_IDX end)
 {
 	RING_IDX cons = vif->tx.req_cons;
+	unsigned long flags;
 
 	do {
+		spin_lock_irqsave(&vif->response_lock, flags);
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
+		spin_unlock_irqrestore(&vif->response_lock, flags);
 		if (cons == end)
 			break;
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
@@ -787,10 +790,10 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif,
 	       sizeof(*txp));
 }
 
-static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
-					       struct sk_buff *skb,
-					       struct xen_netif_tx_request *txp,
-					       struct gnttab_copy *gop)
+static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
+							struct sk_buff *skb,
+							struct xen_netif_tx_request *txp,
+							struct gnttab_map_grant_ref *gop)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
@@ -811,83 +814,12 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
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
@@ -909,9 +841,9 @@ err:
 
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
@@ -923,6 +855,17 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	err = gop->status;
 	if (unlikely(err))
 		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
+	else {
+		if (vif->grant_tx_handle[pending_idx] !=
+		    NETBACK_INVALID_HANDLE) {
+			netdev_err(vif->dev,
+				   "Stale mapped handle! pending_idx %x handle %x\n",
+				   pending_idx,
+				   vif->grant_tx_handle[pending_idx]);
+			BUG();
+		}
+		vif->grant_tx_handle[pending_idx] = gop->handle;
+	}
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
@@ -936,18 +879,24 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
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
+			    NETBACK_INVALID_HANDLE) {
+				netdev_err(vif->dev,
+					   "Stale mapped handle! pending_idx %x handle %x\n",
+					   pending_idx,
+					   vif->grant_tx_handle[pending_idx]);
+				BUG();
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
 
@@ -960,9 +909,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 
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
@@ -975,7 +926,9 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	return err;
 }
 
-static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
+static void xenvif_fill_frags(struct xenvif *vif,
+			      struct sk_buff *skb,
+			      u16 prev_pending_idx)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -989,6 +942,17 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 
 		pending_idx = frag_get_pending_idx(frag);
 
+		/* If this is not the first frag, chain it to the previous*/
+		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
+			skb_shinfo(skb)->destructor_arg =
+				&vif->pending_tx_info[pending_idx].callback_struct;
+		else if (likely(pending_idx != prev_pending_idx))
+			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
+				&(vif->pending_tx_info[pending_idx].callback_struct);
+
+		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
+		prev_pending_idx = pending_idx;
+
 		txp = &vif->pending_tx_info[pending_idx].req;
 		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
@@ -996,10 +960,15 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
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
@@ -1372,7 +1341,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 
 static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops, *request_gop;
+	struct gnttab_map_grant_ref *gop = vif->tx_map_ops, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 
@@ -1480,30 +1449,10 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
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
@@ -1532,17 +1481,17 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-vif->tx_copy_ops) >= ARRAY_SIZE(vif->tx_copy_ops))
+		if ((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif->tx_map_ops))
 			break;
 	}
 
-	return gop - vif->tx_copy_ops;
+	return gop - vif->tx_map_ops;
 }
 
 
 static int xenvif_tx_submit(struct xenvif *vif)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops;
+	struct gnttab_map_grant_ref *gop = vif->tx_map_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
@@ -1566,12 +1515,17 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		memcpy(skb->data,
 		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
 		       data_len);
+		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
 			txp->offset += data_len;
 			txp->size -= data_len;
+			skb_shinfo(skb)->destructor_arg =
+				&vif->pending_tx_info[pending_idx].callback_struct;
 		} else {
 			/* Schedule a response immediately. */
+			skb_shinfo(skb)->destructor_arg = NULL;
+			xenvif_idx_unmap(vif, pending_idx);
 			xenvif_idx_release(vif, pending_idx,
 					   XEN_NETIF_RSP_OKAY);
 		}
@@ -1581,7 +1535,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xenvif_fill_frags(vif, skb);
+		xenvif_fill_frags(vif,
+				  skb,
+				  skb_shinfo(skb)->destructor_arg ?
+				  pending_idx :
+				  INVALID_PENDING_IDX);
 
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
@@ -1595,6 +1553,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		if (checksum_setup(vif, skb)) {
 			netdev_dbg(vif->dev,
 				   "Can't setup checksum in net_tx_action\n");
+			/* We have to set this flag so the dealloc thread can
+			 * send the slots back
+			 */
+			if (skb_shinfo(skb)->destructor_arg)
+				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 			kfree_skb(skb);
 			continue;
 		}
@@ -1620,6 +1583,14 @@ static int xenvif_tx_submit(struct xenvif *vif)
 
 		work_done++;
 
+		/* Set this flag right before netif_receive_skb, otherwise
+		 * someone might think this packet already left netback, and
+		 * do a skb_copy_ubufs while we are still in control of the
+		 * skb. E.g. the __pskb_pull_tail earlier can do such thing.
+		 */
+		if (skb_shinfo(skb)->destructor_arg)
+			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+
 		netif_receive_skb(skb);
 	}
 
@@ -1731,7 +1702,7 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
 	unsigned nr_gops;
-	int work_done;
+	int work_done, ret;
 
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
@@ -1741,7 +1712,8 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
 	if (nr_gops == 0)
 		return 0;
 
-	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
+	ret = gnttab_map_refs(vif->tx_map_ops, vif->pages_to_map, nr_gops);
+	BUG_ON(ret);
 
 	work_done = xenvif_tx_submit(vif);
 
@@ -1752,45 +1724,19 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 			       u8 status)
 {
 	struct pending_tx_info *pending_tx_info;
-	pending_ring_idx_t head;
+	pending_ring_idx_t index;
 	u16 peek; /* peek into next tx request */
+	unsigned long flags;
 
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
+		spin_lock_irqsave(&vif->response_lock, flags);
 		make_tx_response(vif, &pending_tx_info->req, status);
-
-		/* Setting any number other than
-		 * INVALID_PENDING_RING_IDX indicates this slot is
-		 * starting a new packet / ending a previous packet.
-		 */
-		pending_tx_info->head = 0;
-
-		index = pending_index(vif->pending_prod++);
-		vif->pending_ring[index] = vif->pending_ring[info_idx];
-
-		peek = vif->pending_ring[pending_index(++head)];
-
-	} while (!pending_tx_is_head(vif, peek));
-
-	put_page(vif->mmap_pages[pending_idx]);
-	vif->mmap_pages[pending_idx] = NULL;
+		index = pending_index(vif->pending_prod);
+		vif->pending_ring[index] = pending_idx;
+		/* TX shouldn't use the index before we give it back here */
+		mb();
+		vif->pending_prod++;
+		spin_unlock_irqrestore(&vif->response_lock, flags);
 }
 
 void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
