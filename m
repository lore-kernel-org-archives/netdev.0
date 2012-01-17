From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V2 7/8] netback: alter internal function/structure names.
Date: Tue, 17 Jan 2012 13:47:03 +0000
Message-ID: <1326808024-3744-8-git-send-email-wei.liu2@citrix.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: konrad.wilk@oracle.com, david.vrabel@citrix.com,
	paul.durrant@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34152 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200Ab2AQNsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 08:48:16 -0500
In-Reply-To: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we've melted xen_netbk into xenvif, so it is better to give
functions clearer names.

Also alter napi poll handler function prototypes a bit.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   26 ++--
 drivers/net/xen-netback/interface.c |   20 ++--
 drivers/net/xen-netback/netback.c   |  229 ++++++++++++++++++-----------------
 3 files changed, 141 insertions(+), 134 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 17d4e1a..53141c7 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -47,7 +47,7 @@
 
 #include "page_pool.h"
 
-struct netbk_rx_meta {
+struct xenvif_rx_meta {
 	int id;
 	int size;
 	int gso_size;
@@ -140,32 +140,32 @@ void xenvif_xenbus_exit(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
-int xen_netbk_rx_ring_full(struct xenvif *vif);
+int xenvif_rx_ring_full(struct xenvif *vif);
 
-int xen_netbk_must_stop_queue(struct xenvif *vif);
+int xenvif_must_stop_queue(struct xenvif *vif);
 
 /* (Un)Map communication rings. */
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
-int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref);
+void xenvif_unmap_frontend_rings(struct xenvif *vif);
+int xenvif_map_frontend_rings(struct xenvif *vif,
+			      grant_ref_t tx_ring_ref,
+			      grant_ref_t rx_ring_ref);
 
 /* Check for SKBs from frontend and schedule backend processing */
-void xen_netbk_check_rx_xenvif(struct xenvif *vif);
+void xenvif_check_rx_xenvif(struct xenvif *vif);
 /* Receive an SKB from the frontend */
 void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb);
 
 /* Queue an SKB for transmission to the frontend */
-void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
+void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
 /* Notify xenvif that ring now has space to send an skb to the frontend */
 void xenvif_notify_tx_completion(struct xenvif *vif);
 
 /* Returns number of ring slots required to send an skb to the frontend */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
+unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
 
-void xen_netbk_tx_action(struct xenvif *vif, int *work_done, int budget);
-void xen_netbk_rx_action(struct xenvif *vif);
+int xenvif_tx_action(struct xenvif *vif, int budget);
+void xenvif_rx_action(struct xenvif *vif);
 
-int xen_netbk_kthread(void *data);
+int xenvif_kthread(void *data);
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 11e638b..05caccc 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -48,7 +48,7 @@ int xenvif_schedulable(struct xenvif *vif)
 
 static int xenvif_rx_schedulable(struct xenvif *vif)
 {
-	return xenvif_schedulable(vif) && !xen_netbk_rx_ring_full(vif);
+	return xenvif_schedulable(vif) && !xenvif_rx_ring_full(vif);
 }
 
 static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
@@ -69,7 +69,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	struct xenvif *vif = container_of(napi, struct xenvif, napi);
 	int work_done = 0;
 
-	xen_netbk_tx_action(vif, &work_done, budget);
+	work_done = xenvif_tx_action(vif, budget);
 
 	if (work_done < budget) {
 		int more_to_do = 0;
@@ -101,12 +101,12 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	/* Reserve ring slots for the worst-case number of fragments. */
-	vif->rx_req_cons_peek += xen_netbk_count_skb_slots(vif, skb);
+	vif->rx_req_cons_peek += xenvif_count_skb_slots(vif, skb);
 
-	if (vif->can_queue && xen_netbk_must_stop_queue(vif))
+	if (vif->can_queue && xenvif_must_stop_queue(vif))
 		netif_stop_queue(dev);
 
-	xen_netbk_queue_tx_skb(vif, skb);
+	xenvif_queue_tx_skb(vif, skb);
 
 	return NETDEV_TX_OK;
 
@@ -137,7 +137,7 @@ static void xenvif_up(struct xenvif *vif)
 {
 	napi_enable(&vif->napi);
 	enable_irq(vif->irq);
-	xen_netbk_check_rx_xenvif(vif);
+	xenvif_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
@@ -334,7 +334,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	__module_get(THIS_MODULE);
 
-	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
+	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
 
@@ -347,7 +347,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	disable_irq(vif->irq);
 
 	init_waitqueue_head(&vif->wq);
-	vif->task = kthread_create(xen_netbk_kthread,
+	vif->task = kthread_create(xenvif_kthread,
 				   (void *)vif,
 				   "vif%d.%d", vif->domid, vif->handle);
 	if (IS_ERR(vif->task)) {
@@ -371,7 +371,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 err_unbind:
 	unbind_from_irqhandler(vif->irq, vif);
 err_unmap:
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 err:
 	return err;
 }
@@ -400,7 +400,7 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 
 	free_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1842e4e..fa864f4 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -57,9 +57,9 @@ struct gnttab_copy *tx_copy_ops;
  * straddles two buffers in the frontend.
  */
 struct gnttab_copy *grant_copy_op;
-struct netbk_rx_meta *meta;
+struct xenvif_rx_meta *meta;
 
-static void xen_netbk_idx_release(struct xenvif *vif, u16 pending_idx);
+static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx);
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
@@ -127,7 +127,7 @@ static int max_required_rx_slots(struct xenvif *vif)
 	return max;
 }
 
-int xen_netbk_rx_ring_full(struct xenvif *vif)
+int xenvif_rx_ring_full(struct xenvif *vif)
 {
 	RING_IDX peek   = vif->rx_req_cons_peek;
 	RING_IDX needed = max_required_rx_slots(vif);
@@ -136,16 +136,16 @@ int xen_netbk_rx_ring_full(struct xenvif *vif)
 	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
 }
 
-int xen_netbk_must_stop_queue(struct xenvif *vif)
+int xenvif_must_stop_queue(struct xenvif *vif)
 {
-	if (!xen_netbk_rx_ring_full(vif))
+	if (!xenvif_rx_ring_full(vif))
 		return 0;
 
 	vif->rx.sring->req_event = vif->rx_req_cons_peek +
 		max_required_rx_slots(vif);
 	mb(); /* request notification /then/ check the queue */
 
-	return xen_netbk_rx_ring_full(vif);
+	return xenvif_rx_ring_full(vif);
 }
 
 /*
@@ -191,9 +191,9 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
 /*
  * Figure out how many ring slots we're going to need to send @skb to
  * the guest. This function is essentially a dry run of
- * netbk_gop_frag_copy.
+ * xenvif_gop_frag_copy.
  */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 {
 	unsigned int count;
 	int i, copy_off;
@@ -232,15 +232,15 @@ struct netrx_pending_operations {
 	unsigned copy_prod, copy_cons;
 	unsigned meta_prod, meta_cons;
 	struct gnttab_copy *copy;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	int copy_off;
 	grant_ref_t copy_gref;
 };
 
-static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
-						struct netrx_pending_operations *npo)
+static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
+					struct netrx_pending_operations *npo)
 {
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	struct xen_netif_rx_request *req;
 
 	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
@@ -260,13 +260,13 @@ static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
  * Set up the grant operations for this fragment. If it's a flipping
  * interface, we also set up the unmap request from here.
  */
-static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
-				struct netrx_pending_operations *npo,
-				struct page *page, unsigned long size,
-				unsigned long offset, int *head)
+static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
+				 struct netrx_pending_operations *npo,
+				 struct page *page, unsigned long size,
+				 unsigned long offset, int *head)
 {
 	struct gnttab_copy *copy_gop;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	/*
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
@@ -344,14 +344,14 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
  * zero GSO descriptors (for non-GSO packets) or one descriptor (for
  * frontend-side LRO).
  */
-static int netbk_gop_skb(struct sk_buff *skb,
-			 struct netrx_pending_operations *npo)
+static int xenvif_gop_skb(struct sk_buff *skb,
+			  struct netrx_pending_operations *npo)
 {
 	struct xenvif *vif = netdev_priv(skb->dev);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int i;
 	struct xen_netif_rx_request *req;
-	struct netbk_rx_meta *meta;
+	struct xenvif_rx_meta *meta;
 	unsigned char *data;
 	int head = 1;
 	int old_meta_prod;
@@ -388,30 +388,30 @@ static int netbk_gop_skb(struct sk_buff *skb,
 		if (data + len > skb_tail_pointer(skb))
 			len = skb_tail_pointer(skb) - data;
 
-		netbk_gop_frag_copy(vif, skb, npo,
-				    virt_to_page(data), len, offset, &head);
+		xenvif_gop_frag_copy(vif, skb, npo,
+				     virt_to_page(data), len, offset, &head);
 		data += len;
 	}
 
 	for (i = 0; i < nr_frags; i++) {
-		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				    skb_shinfo(skb)->frags[i].page_offset,
-				    &head);
+		xenvif_gop_frag_copy(vif, skb, npo,
+				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				     skb_shinfo(skb)->frags[i].page_offset,
+				     &head);
 	}
 
 	return npo->meta_prod - old_meta_prod;
 }
 
 /*
- * This is a twin to netbk_gop_skb.  Assume that netbk_gop_skb was
+ * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
  * used to set up the operations on the top of
  * netrx_pending_operations, which have since been done.  Check that
  * they didn't give any errors and advance over them.
  */
-static int netbk_check_gop(struct xenvif *vif, int nr_meta_slots,
-			   struct netrx_pending_operations *npo)
+static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
+			    struct netrx_pending_operations *npo)
 {
 	struct gnttab_copy     *copy_op;
 	int status = XEN_NETIF_RSP_OKAY;
@@ -430,9 +430,9 @@ static int netbk_check_gop(struct xenvif *vif, int nr_meta_slots,
 	return status;
 }
 
-static void netbk_add_frag_responses(struct xenvif *vif, int status,
-				     struct netbk_rx_meta *meta,
-				     int nr_meta_slots)
+static void xenvif_add_frag_responses(struct xenvif *vif, int status,
+				      struct xenvif_rx_meta *meta,
+				      int nr_meta_slots)
 {
 	int i;
 	unsigned long offset;
@@ -460,12 +460,12 @@ struct skb_cb_overlay {
 	int meta_slots_used;
 };
 
-static void xen_netbk_kick_thread(struct xenvif *vif)
+static void xenvif_kick_thread(struct xenvif *vif)
 {
 	wake_up(&vif->wq);
 }
 
-void xen_netbk_rx_action(struct xenvif *vif)
+void xenvif_rx_action(struct xenvif *vif)
 {
 	s8 status;
 	u16 flags;
@@ -481,7 +481,7 @@ void xen_netbk_rx_action(struct xenvif *vif)
 	int need_to_notify = 0;
 
 	struct gnttab_copy *gco = get_cpu_ptr(grant_copy_op);
-	struct netbk_rx_meta *m = get_cpu_ptr(meta);
+	struct xenvif_rx_meta *m = get_cpu_ptr(meta);
 
 	struct netrx_pending_operations npo = {
 		.copy  = gco,
@@ -497,7 +497,7 @@ void xen_netbk_rx_action(struct xenvif *vif)
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		sco = (struct skb_cb_overlay *)skb->cb;
-		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
+		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
 
 		count += nr_frags + 1;
 
@@ -544,7 +544,7 @@ void xen_netbk_rx_action(struct xenvif *vif)
 		vif->dev->stats.tx_bytes += skb->len;
 		vif->dev->stats.tx_packets++;
 
-		status = netbk_check_gop(vif, sco->meta_slots_used, &npo);
+		status = xenvif_check_gop(vif, sco->meta_slots_used, &npo);
 
 		if (sco->meta_slots_used == 1)
 			flags = 0;
@@ -580,9 +580,9 @@ void xen_netbk_rx_action(struct xenvif *vif)
 			gso->flags = 0;
 		}
 
-		netbk_add_frag_responses(vif, status,
-					 m + npo.meta_cons + 1,
-					 sco->meta_slots_used);
+		xenvif_add_frag_responses(vif, status,
+					  m + npo.meta_cons + 1,
+					  sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
 		if (ret)
@@ -598,20 +598,20 @@ void xen_netbk_rx_action(struct xenvif *vif)
 		notify_remote_via_irq(vif->irq);
 
 	if (!skb_queue_empty(&vif->rx_queue))
-		xen_netbk_kick_thread(vif);
+		xenvif_kick_thread(vif);
 
 	put_cpu_ptr(gco);
 	put_cpu_ptr(m);
 }
 
-void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
+void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
 {
 	skb_queue_tail(&vif->rx_queue, skb);
 
-	xen_netbk_kick_thread(vif);
+	xenvif_kick_thread(vif);
 }
 
-void xen_netbk_check_rx_xenvif(struct xenvif *vif)
+void xenvif_check_rx_xenvif(struct xenvif *vif)
 {
 	int more_to_do;
 
@@ -648,11 +648,11 @@ static void tx_credit_callback(unsigned long data)
 {
 	struct xenvif *vif = (struct xenvif *)data;
 	tx_add_credit(vif);
-	xen_netbk_check_rx_xenvif(vif);
+	xenvif_check_rx_xenvif(vif);
 }
 
-static void netbk_tx_err(struct xenvif *vif,
-			 struct xen_netif_tx_request *txp, RING_IDX end)
+static void xenvif_tx_err(struct xenvif *vif,
+			  struct xen_netif_tx_request *txp, RING_IDX end)
 {
 	RING_IDX cons = vif->tx.req_cons;
 
@@ -663,10 +663,10 @@ static void netbk_tx_err(struct xenvif *vif,
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
 	} while (1);
 	vif->tx.req_cons = cons;
-	xen_netbk_check_rx_xenvif(vif);
+	xenvif_check_rx_xenvif(vif);
 }
 
-static int netbk_count_requests(struct xenvif *vif,
+static int xenvif_count_requests(struct xenvif *vif,
 				struct xen_netif_tx_request *first,
 				struct xen_netif_tx_request *txp,
 				int work_to_do)
@@ -707,9 +707,9 @@ static int netbk_count_requests(struct xenvif *vif,
 	return frags;
 }
 
-static struct page *xen_netbk_alloc_page(struct xenvif *vif,
-					 struct sk_buff *skb,
-					 u16 pending_idx)
+static struct page *xenvif_alloc_page(struct xenvif *vif,
+				      struct sk_buff *skb,
+				      u16 pending_idx)
 {
 	struct page *page;
 	int idx;
@@ -720,10 +720,10 @@ static struct page *xen_netbk_alloc_page(struct xenvif *vif,
 	return page;
 }
 
-static struct gnttab_copy *xen_netbk_get_requests(struct xenvif *vif,
-						  struct sk_buff *skb,
-						  struct xen_netif_tx_request *txp,
-						  struct gnttab_copy *gop)
+static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
+					       struct sk_buff *skb,
+					       struct xen_netif_tx_request *txp,
+					       struct gnttab_copy *gop)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
@@ -741,7 +741,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xenvif *vif,
 
 		index = pending_index(vif->pending_cons++);
 		pending_idx = vif->pending_ring[index];
-		page = xen_netbk_alloc_page(vif, skb, pending_idx);
+		page = xenvif_alloc_page(vif, skb, pending_idx);
 		if (!page)
 			return NULL;
 
@@ -769,9 +769,9 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xenvif *vif,
 	return gop;
 }
 
-static int xen_netbk_tx_check_gop(struct xenvif *vif,
-				  struct sk_buff *skb,
-				  struct gnttab_copy **gopp)
+static int xenvif_tx_check_gop(struct xenvif *vif,
+			       struct sk_buff *skb,
+			       struct gnttab_copy **gopp)
 {
 	struct gnttab_copy *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
@@ -808,7 +808,7 @@ static int xen_netbk_tx_check_gop(struct xenvif *vif,
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
-				xen_netbk_idx_release(vif, pending_idx);
+				xenvif_idx_release(vif, pending_idx);
 			continue;
 		}
 
@@ -825,10 +825,10 @@ static int xen_netbk_tx_check_gop(struct xenvif *vif,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
-		xen_netbk_idx_release(vif, pending_idx);
+		xenvif_idx_release(vif, pending_idx);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xen_netbk_idx_release(vif, pending_idx);
+			xenvif_idx_release(vif, pending_idx);
 		}
 
 		/* Remember the error: invalidate all subsequent fragments. */
@@ -839,7 +839,7 @@ static int xen_netbk_tx_check_gop(struct xenvif *vif,
 	return err;
 }
 
-static void xen_netbk_fill_frags(struct xenvif *vif, struct sk_buff *skb)
+static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -865,15 +865,15 @@ static void xen_netbk_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 		skb->data_len += txp->size;
 		skb->truesize += txp->size;
 
-		/* Take an extra reference to offset xen_netbk_idx_release */
+		/* Take an extra reference to offset xenvif_idx_release */
 		get_page(page);
-		xen_netbk_idx_release(vif, pending_idx);
+		xenvif_idx_release(vif, pending_idx);
 	}
 }
 
-static int xen_netbk_get_extras(struct xenvif *vif,
-				struct xen_netif_extra_info *extras,
-				int work_to_do)
+static int xenvif_get_extras(struct xenvif *vif,
+			     struct xen_netif_extra_info *extras,
+			     int work_to_do)
 {
 	struct xen_netif_extra_info extra;
 	RING_IDX cons = vif->tx.req_cons;
@@ -901,9 +901,9 @@ static int xen_netbk_get_extras(struct xenvif *vif,
 	return work_to_do;
 }
 
-static int netbk_set_skb_gso(struct xenvif *vif,
-			     struct sk_buff *skb,
-			     struct xen_netif_extra_info *gso)
+static int xenvif_set_skb_gso(struct xenvif *vif,
+			      struct sk_buff *skb,
+			      struct xen_netif_extra_info *gso)
 {
 	if (!gso->u.gso.size) {
 		netdev_dbg(vif->dev, "GSO size must not be zero.\n");
@@ -1028,8 +1028,8 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
-					struct gnttab_copy *tco)
+static unsigned xenvif_tx_build_gops(struct xenvif *vif,
+				     struct gnttab_copy *tco)
 {
 	struct gnttab_copy *gop = tco, *request_gop;
 	struct sk_buff *skb;
@@ -1070,18 +1070,18 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 
 		memset(extras, 0, sizeof(extras));
 		if (txreq.flags & XEN_NETTXF_extra_info) {
-			work_to_do = xen_netbk_get_extras(vif, extras,
+			work_to_do = xenvif_get_extras(vif, extras,
 							  work_to_do);
 			idx = vif->tx.req_cons;
 			if (unlikely(work_to_do < 0)) {
-				netbk_tx_err(vif, &txreq, idx);
+				xenvif_tx_err(vif, &txreq, idx);
 				break;
 			}
 		}
 
-		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
+		ret = xenvif_count_requests(vif, &txreq, txfrags, work_to_do);
 		if (unlikely(ret < 0)) {
-			netbk_tx_err(vif, &txreq, idx - ret);
+			xenvif_tx_err(vif, &txreq, idx - ret);
 			break;
 		}
 		idx += ret;
@@ -1089,7 +1089,7 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 		if (unlikely(txreq.size < ETH_HLEN)) {
 			netdev_dbg(vif->dev,
 				   "Bad packet size: %d\n", txreq.size);
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 
@@ -1099,7 +1099,7 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 				   "txreq.offset: %x, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 
@@ -1115,7 +1115,7 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 		if (unlikely(skb == NULL)) {
 			netdev_dbg(vif->dev,
 				   "Can't allocate a skb in start_xmit.\n");
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 
@@ -1126,18 +1126,18 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
 
-			if (netbk_set_skb_gso(vif, skb, gso)) {
+			if (xenvif_set_skb_gso(vif, skb, gso)) {
 				kfree_skb(skb);
-				netbk_tx_err(vif, &txreq, idx);
+				xenvif_tx_err(vif, &txreq, idx);
 				break;
 			}
 		}
 
 		/* XXX could copy straight to head */
-		page = xen_netbk_alloc_page(vif, skb, pending_idx);
+		page = xenvif_alloc_page(vif, skb, pending_idx);
 		if (!page) {
 			kfree_skb(skb);
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 
@@ -1178,17 +1178,17 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 
 		vif->pending_cons++;
 
-		request_gop = xen_netbk_get_requests(vif,
+		request_gop = xenvif_get_requests(vif,
 						     skb, txfrags, gop);
 		if (request_gop == NULL) {
 			kfree_skb(skb);
-			netbk_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(vif, &txreq, idx);
 			break;
 		}
 		gop = request_gop;
 
 		vif->tx.req_cons = idx;
-		xen_netbk_check_rx_xenvif(vif);
+		xenvif_check_rx_xenvif(vif);
 
 		if ((gop - tco) >= MAX_PENDING_REQS)
 			break;
@@ -1197,14 +1197,15 @@ static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 	return gop - tco;
 }
 
-static void xen_netbk_tx_submit(struct xenvif *vif,
-				struct gnttab_copy *tco,
-				int *work_done, int budget)
+static int xenvif_tx_submit(struct xenvif *vif,
+			    struct gnttab_copy *tco,
+			    int budget)
 {
 	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
+	int work_done = 0;
 
-	while ((*work_done < budget) &&
+	while ((work_done < budget) &&
 	       (skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
@@ -1220,7 +1221,7 @@ static void xen_netbk_tx_submit(struct xenvif *vif,
 		txp = &pending_tx_info->req;
 
 		/* Check the remap error code. */
-		if (unlikely(xen_netbk_tx_check_gop(vif, skb, &gop))) {
+		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1237,7 +1238,7 @@ static void xen_netbk_tx_submit(struct xenvif *vif,
 			txp->size -= data_len;
 		} else {
 			/* Schedule a response immediately. */
-			xen_netbk_idx_release(vif, pending_idx);
+			xenvif_idx_release(vif, pending_idx);
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1245,7 +1246,7 @@ static void xen_netbk_tx_submit(struct xenvif *vif,
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xen_netbk_fill_frags(vif, skb);
+		xenvif_fill_frags(vif, skb);
 
 		/*
 		 * If the initial fragment was < PKT_PROT_LEN then
@@ -1270,25 +1271,28 @@ static void xen_netbk_tx_submit(struct xenvif *vif,
 		vif->dev->stats.rx_bytes += skb->len;
 		vif->dev->stats.rx_packets++;
 
-		(*work_done)++;
+		work_done++;
 
 		xenvif_receive_skb(vif, skb);
 	}
+
+	return work_done;
 }
 
 /* Called after netfront has transmitted */
-void xen_netbk_tx_action(struct xenvif *vif, int *work_done, int budget)
+int xenvif_tx_action(struct xenvif *vif, int budget)
 {
 	unsigned nr_gops;
 	int ret;
 	struct gnttab_copy *tco;
+	int work_done;
 
 	if (unlikely(!tx_work_todo(vif)))
-		return;
+		return 0;
 
 	tco = get_cpu_ptr(tx_copy_ops);
 
-	nr_gops = xen_netbk_tx_build_gops(vif, tco);
+	nr_gops = xenvif_tx_build_gops(vif, tco);
 
 	if (nr_gops == 0) {
 		put_cpu_ptr(tco);
@@ -1298,11 +1302,14 @@ void xen_netbk_tx_action(struct xenvif *vif, int *work_done, int budget)
 	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, tco, nr_gops);
 	BUG_ON(ret);
 
-	xen_netbk_tx_submit(vif, tco, work_done, budget);
+	work_done = xenvif_tx_submit(vif, tco, budget);
+
 	put_cpu_ptr(tco);
+
+	return work_done;
 }
 
-static void xen_netbk_idx_release(struct xenvif *vif, u16 pending_idx)
+static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx)
 {
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
@@ -1383,7 +1390,7 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
+void xenvif_unmap_frontend_rings(struct xenvif *vif)
 {
 	if (vif->tx.sring)
 		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
@@ -1393,9 +1400,9 @@ void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 					vif->rx.sring);
 }
 
-int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref)
+int xenvif_map_frontend_rings(struct xenvif *vif,
+			      grant_ref_t tx_ring_ref,
+			      grant_ref_t rx_ring_ref)
 {
 	void *addr;
 	struct xen_netif_tx_sring *txs;
@@ -1424,11 +1431,11 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
 	return 0;
 
 err:
-	xen_netbk_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(vif);
 	return err;
 }
 
-int xen_netbk_kthread(void *data)
+int xenvif_kthread(void *data)
 {
 	struct xenvif *vif = data;
 
@@ -1442,7 +1449,7 @@ int xen_netbk_kthread(void *data)
 			break;
 
 		if (rx_work_todo(vif))
-			xen_netbk_rx_action(vif);
+			xenvif_rx_action(vif);
 	}
 
 	return 0;
@@ -1468,9 +1475,9 @@ static int __init netback_init(void)
 	if (!grant_copy_op)
 		goto failed_init_gco;
 
-	meta = __alloc_percpu(sizeof(struct netbk_rx_meta)
+	meta = __alloc_percpu(sizeof(struct xenvif_rx_meta)
 			      * 2 * XEN_NETIF_RX_RING_SIZE,
-			      __alignof__(struct netbk_rx_meta));
+			      __alignof__(struct xenvif_rx_meta));
 	if (!meta)
 		goto failed_init_meta;
 
-- 
1.7.2.5
