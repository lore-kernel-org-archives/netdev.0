From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 13/16] netback: stub for multi receive protocol support.
Date: Mon, 30 Jan 2012 14:45:31 +0000
Message-ID: <1327934734-8908-14-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45960 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2A3Opv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:51 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor netback, make stub for mutli receive protocols. Also stub
existing code as protocol 0.

Now the file layout becomes:

 - interface.c: xenvif interfaces
 - xenbus.c: xenbus related functions
 - netback.c: common functions for various protocols

For different protocols:

 - xenvif_rx_protocolX.h: header file for the protocol, including
                          protocol structures and functions
 - xenvif_rx_protocolX.c: implementations

To add a new protocol:

 - include protocol header in common.h
 - modify XENVIF_MAX_RX_PROTOCOL in common.h
 - add protocol structure in xenvif.rx union
 - stub in xenbus.c
 - modify Makefile

A protocol should define five functions:

 - setup: setup frontend / backend ring connections
 - teardown: teardown frontend / backend ring connections
 - start_xmit: host start xmit (i.e. guest need to do rx)
 - event: rx completion event
 - action: prepare host side data for guest rx

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/Makefile              |    2 +-
 drivers/net/xen-netback/common.h              |   34 +-
 drivers/net/xen-netback/interface.c           |   49 +-
 drivers/net/xen-netback/netback.c             |  528 +---------------------
 drivers/net/xen-netback/xenbus.c              |    8 +-
 drivers/net/xen-netback/xenvif_rx_protocol0.c |  616 +++++++++++++++++++++++++
 drivers/net/xen-netback/xenvif_rx_protocol0.h |   53 +++
 7 files changed, 732 insertions(+), 558 deletions(-)
 create mode 100644 drivers/net/xen-netback/xenvif_rx_protocol0.c
 create mode 100644 drivers/net/xen-netback/xenvif_rx_protocol0.h

diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback/Makefile
index dc4b8b1..fed8add 100644
--- a/drivers/net/xen-netback/Makefile
+++ b/drivers/net/xen-netback/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_XEN_NETDEV_BACKEND) := xen-netback.o
 
-xen-netback-y := netback.o xenbus.o interface.o page_pool.o
+xen-netback-y := netback.o xenbus.o interface.o page_pool.o xenvif_rx_protocol0.o
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 3cf9b8f..f3d95b3 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -46,6 +46,7 @@
 #include <xen/xenbus.h>
 
 #include "page_pool.h"
+#include "xenvif_rx_protocol0.h"
 
 struct xenvif_rx_meta {
 	int id;
@@ -79,6 +80,9 @@ struct xen_comms {
 	unsigned int      nr_handles;
 };
 
+#define XENVIF_MIN_RX_PROTOCOL 0
+#define XENVIF_MAX_RX_PROTOCOL 0
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -99,9 +103,13 @@ struct xenvif {
 	/* Physical parameters of the comms window. */
 	unsigned int     irq;
 
-	/* The shared rings and indexes. */
+	/* The shared tx ring and index. */
 	struct xen_netif_tx_back_ring tx;
-	struct xen_netif_rx_back_ring rx;
+
+	/* Multi receive protocol support */
+	union {
+		struct xenvif_rx_protocol0 p0;
+	} rx;
 
 	/* Frontend feature information. */
 	u8 can_sg:1;
@@ -112,13 +120,6 @@ struct xenvif {
 	/* Internal feature information. */
 	u8 can_queue:1;	    /* can queue packets for receiver? */
 
-	/*
-	 * Allow xenvif_start_xmit() to peek ahead in the rx request
-	 * ring.  This is a prediction of what rx_req_cons will be
-	 * once all queued skbs are put on the ring.
-	 */
-	RING_IDX rx_req_cons_peek;
-
 	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
 	unsigned long   credit_bytes;
 	unsigned long   credit_usec;
@@ -128,6 +129,13 @@ struct xenvif {
 	/* Statistics */
 	unsigned long rx_gso_checksum_fixup;
 
+	/* Hooks for multi receive protocol support */
+	int  (*setup)(struct xenvif *);
+	void (*start_xmit)(struct xenvif *, struct sk_buff *);
+	void (*teardown)(struct xenvif *);
+	void (*event)(struct xenvif *);
+	void (*action)(struct xenvif *);
+
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
 
@@ -154,7 +162,7 @@ struct xenvif *xenvif_alloc(struct device *parent,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_order,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_order,
-		   unsigned int evtchn);
+		   unsigned int evtchn, unsigned int rx_protocol);
 void xenvif_disconnect(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
@@ -178,8 +186,6 @@ void xenvif_check_rx_xenvif(struct xenvif *vif);
 
 /* Queue an SKB for transmission to the frontend */
 void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
-/* Notify xenvif that ring now has space to send an skb to the frontend */
-void xenvif_notify_tx_completion(struct xenvif *vif);
 
 /* Returns number of ring slots required to send an skb to the frontend */
 unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
@@ -188,7 +194,11 @@ int xenvif_tx_action(struct xenvif *vif, int budget);
 void xenvif_rx_action(struct xenvif *vif);
 
 int xenvif_kthread(void *data);
+void xenvif_kick_thread(struct xenvif *vif);
+
+int xenvif_max_required_rx_slots(struct xenvif *vif);
 
+extern unsigned int MODPARM_netback_max_rx_protocol;
 extern unsigned int MODPARM_netback_max_tx_ring_page_order;
 extern unsigned int MODPARM_netback_max_rx_ring_page_order;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 29f4fd9..0f05f03 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -46,17 +46,12 @@ int xenvif_schedulable(struct xenvif *vif)
 	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
 }
 
-static int xenvif_rx_schedulable(struct xenvif *vif)
-{
-	return xenvif_schedulable(vif) && !xenvif_rx_ring_full(vif);
-}
-
 static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (xenvif_rx_schedulable(vif))
-		netif_wake_queue(vif->dev);
+	if (xenvif_schedulable(vif) && vif->event != NULL)
+		vif->event(vif);
 
 	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
 		napi_schedule(&vif->napi);
@@ -100,17 +95,11 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (vif->task == NULL)
 		goto drop;
 
-	/* Drop the packet if the target domain has no receive buffers. */
-	if (!xenvif_rx_schedulable(vif))
+	/* Drop the packet if vif does not support transmit */
+	if (vif->start_xmit == NULL)
 		goto drop;
 
-	/* Reserve ring slots for the worst-case number of fragments. */
-	vif->rx_req_cons_peek += xenvif_count_skb_slots(vif, skb);
-
-	if (vif->can_queue && xenvif_must_stop_queue(vif))
-		netif_stop_queue(dev);
-
-	xenvif_queue_tx_skb(vif, skb);
+	vif->start_xmit(vif, skb);
 
 	return NETDEV_TX_OK;
 
@@ -120,12 +109,6 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-void xenvif_notify_tx_completion(struct xenvif *vif)
-{
-	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
-		netif_wake_queue(vif->dev);
-}
-
 static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -325,11 +308,10 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_ref_count,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_ref_count,
-		   unsigned int evtchn)
+		   unsigned int evtchn, unsigned int rx_protocol)
 {
 	int err = -ENOMEM;
 	struct xen_netif_tx_sring *txs;
-	struct xen_netif_rx_sring *rxs;
 
 	/* Already connected through? */
 	if (vif->irq)
@@ -348,8 +330,20 @@ int xenvif_connect(struct xenvif *vif,
 					rx_ring_ref, rx_ring_ref_count);
 	if (err)
 		goto err_tx_unmap;
-	rxs = (struct xen_netif_rx_sring *)vif->rx_comms.ring_area->addr;
-	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
+	switch (rx_protocol) {
+	case 0:
+		vif->setup = xenvif_p0_setup;
+		vif->start_xmit = xenvif_p0_start_xmit;
+		vif->teardown = xenvif_p0_teardown;
+		vif->event = xenvif_p0_event;
+		vif->action = xenvif_p0_action;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		goto err_rx_unmap;
+	}
+	if (vif->setup(vif))
+		goto err_rx_unmap;
 
 	err = bind_interdomain_evtchn_to_irqhandler(
 		vif->domid, evtchn, xenvif_interrupt, 0,
@@ -422,6 +416,9 @@ void xenvif_disconnect(struct xenvif *vif)
 	xenvif_unmap_frontend_rings(&vif->tx_comms);
 	xenvif_unmap_frontend_rings(&vif->rx_comms);
 
+	if (vif->teardown)
+		vif->teardown(vif);
+
 	free_netdev(vif->dev);
 
 	if (need_module_put)
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 96f354c..2ea43d4 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -49,6 +49,12 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
+unsigned int MODPARM_netback_max_rx_protocol = XENVIF_MAX_RX_PROTOCOL;
+module_param_named(netback_max_rx_protocol,
+		   MODPARM_netback_max_rx_protocol, uint, 0);
+MODULE_PARM_DESC(netback_max_rx_protocol,
+		 "Maximum supported receiver protocol version");
+
 unsigned int MODPARM_netback_max_rx_ring_page_order = NETBK_MAX_RING_PAGE_ORDER;
 module_param_named(netback_max_rx_ring_page_order,
 		   MODPARM_netback_max_rx_ring_page_order, uint, 0);
@@ -79,13 +85,6 @@ static void make_tx_response(struct xenvif *vif,
 static inline int tx_work_todo(struct xenvif *vif);
 static inline int rx_work_todo(struct xenvif *vif);
 
-static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
-					     u16      id,
-					     s8       st,
-					     u16      offset,
-					     u16      size,
-					     u16      flags);
-
 static inline unsigned long idx_to_pfn(struct xenvif *vif,
 				       u16 idx)
 {
@@ -129,7 +128,7 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
 		vif->pending_prod + vif->pending_cons;
 }
 
-static int max_required_rx_slots(struct xenvif *vif)
+int xenvif_max_required_rx_slots(struct xenvif *vif)
 {
 	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
 
@@ -139,495 +138,11 @@ static int max_required_rx_slots(struct xenvif *vif)
 	return max;
 }
 
-int xenvif_rx_ring_full(struct xenvif *vif)
-{
-	RING_IDX peek   = vif->rx_req_cons_peek;
-	RING_IDX needed = max_required_rx_slots(vif);
-	struct xen_comms *comms = &vif->rx_comms;
-
-	return ((vif->rx.sring->req_prod - peek) < needed) ||
-	       ((vif->rx.rsp_prod_pvt +
-		 NETBK_RX_RING_SIZE(comms->nr_handles) - peek) < needed);
-}
-
-int xenvif_must_stop_queue(struct xenvif *vif)
-{
-	if (!xenvif_rx_ring_full(vif))
-		return 0;
-
-	vif->rx.sring->req_event = vif->rx_req_cons_peek +
-		max_required_rx_slots(vif);
-	mb(); /* request notification /then/ check the queue */
-
-	return xenvif_rx_ring_full(vif);
-}
-
-/*
- * Returns true if we should start a new receive buffer instead of
- * adding 'size' bytes to a buffer which currently contains 'offset'
- * bytes.
- */
-static bool start_new_rx_buffer(int offset, unsigned long size, int head)
-{
-	/* simple case: we have completely filled the current buffer. */
-	if (offset == MAX_BUFFER_OFFSET)
-		return true;
-
-	/*
-	 * complex case: start a fresh buffer if the current frag
-	 * would overflow the current buffer but only if:
-	 *     (i)   this frag would fit completely in the next buffer
-	 * and (ii)  there is already some data in the current buffer
-	 * and (iii) this is not the head buffer.
-	 *
-	 * Where:
-	 * - (i) stops us splitting a frag into two copies
-	 *   unless the frag is too large for a single buffer.
-	 * - (ii) stops us from leaving a buffer pointlessly empty.
-	 * - (iii) stops us leaving the first buffer
-	 *   empty. Strictly speaking this is already covered
-	 *   by (ii) but is explicitly checked because
-	 *   netfront relies on the first buffer being
-	 *   non-empty and can crash otherwise.
-	 *
-	 * This means we will effectively linearise small
-	 * frags but do not needlessly split large buffers
-	 * into multiple copies tend to give large frags their
-	 * own buffers as before.
-	 */
-	if ((offset + size > MAX_BUFFER_OFFSET) &&
-	    (size <= MAX_BUFFER_OFFSET) && offset && !head)
-		return true;
-
-	return false;
-}
-
-/*
- * Figure out how many ring slots we're going to need to send @skb to
- * the guest. This function is essentially a dry run of
- * xenvif_gop_frag_copy.
- */
-unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
-{
-	unsigned int count;
-	int i, copy_off;
-
-	count = DIV_ROUND_UP(
-			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
-
-	copy_off = skb_headlen(skb) % PAGE_SIZE;
-
-	if (skb_shinfo(skb)->gso_size)
-		count++;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-		unsigned long bytes;
-		while (size > 0) {
-			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
-
-			if (start_new_rx_buffer(copy_off, size, 0)) {
-				count++;
-				copy_off = 0;
-			}
-
-			bytes = size;
-			if (copy_off + bytes > MAX_BUFFER_OFFSET)
-				bytes = MAX_BUFFER_OFFSET - copy_off;
-
-			copy_off += bytes;
-			size -= bytes;
-		}
-	}
-	return count;
-}
-
-struct netrx_pending_operations {
-	unsigned copy_prod, copy_cons;
-	unsigned meta_prod, meta_cons;
-	struct gnttab_copy *copy;
-	struct xenvif_rx_meta *meta;
-	int copy_off;
-	grant_ref_t copy_gref;
-};
-
-static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
-					struct netrx_pending_operations *npo)
-{
-	struct xenvif_rx_meta *meta;
-	struct xen_netif_rx_request *req;
-
-	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
-
-	meta = npo->meta + npo->meta_prod++;
-	meta->gso_size = 0;
-	meta->size = 0;
-	meta->id = req->id;
-
-	npo->copy_off = 0;
-	npo->copy_gref = req->gref;
-
-	return meta;
-}
-
-/*
- * Set up the grant operations for this fragment. If it's a flipping
- * interface, we also set up the unmap request from here.
- */
-static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
-				 struct netrx_pending_operations *npo,
-				 struct page *page, unsigned long size,
-				 unsigned long offset, int *head)
-{
-	struct gnttab_copy *copy_gop;
-	struct xenvif_rx_meta *meta;
-	/*
-	 * These variables are used iff get_page_ext returns true,
-	 * in which case they are guaranteed to be initialized.
-	 */
-	unsigned int uninitialized_var(idx);
-	int foreign = is_in_pool(page, &idx);
-	unsigned long bytes;
-
-	/* Data must not cross a page boundary. */
-	BUG_ON(size + offset > PAGE_SIZE);
-
-	meta = npo->meta + npo->meta_prod - 1;
-
-	while (size > 0) {
-		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
-
-		if (start_new_rx_buffer(npo->copy_off, size, *head)) {
-			/*
-			 * Netfront requires there to be some data in the head
-			 * buffer.
-			 */
-			BUG_ON(*head);
-
-			meta = get_next_rx_buffer(vif, npo);
-		}
-
-		bytes = size;
-		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
-			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
-
-		copy_gop = npo->copy + npo->copy_prod++;
-		copy_gop->flags = GNTCOPY_dest_gref;
-		if (foreign) {
-			struct pending_tx_info *src_pend = to_txinfo(idx);
-			struct xenvif *rvif = to_vif(idx);
-
-			copy_gop->source.domid = rvif->domid;
-			copy_gop->source.u.ref = src_pend->req.gref;
-			copy_gop->flags |= GNTCOPY_source_gref;
-		} else {
-			void *vaddr = page_address(page);
-			copy_gop->source.domid = DOMID_SELF;
-			copy_gop->source.u.gmfn = virt_to_mfn(vaddr);
-		}
-		copy_gop->source.offset = offset;
-		copy_gop->dest.domid = vif->domid;
-
-		copy_gop->dest.offset = npo->copy_off;
-		copy_gop->dest.u.ref = npo->copy_gref;
-		copy_gop->len = bytes;
-
-		npo->copy_off += bytes;
-		meta->size += bytes;
-
-		offset += bytes;
-		size -= bytes;
-
-		/* Leave a gap for the GSO descriptor. */
-		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
-			vif->rx.req_cons++;
-
-		*head = 0; /* There must be something in this buffer now. */
-
-	}
-}
-
-/*
- * Prepare an SKB to be transmitted to the frontend.
- *
- * This function is responsible for allocating grant operations, meta
- * structures, etc.
- *
- * It returns the number of meta structures consumed. The number of
- * ring slots used is always equal to the number of meta slots used
- * plus the number of GSO descriptors used. Currently, we use either
- * zero GSO descriptors (for non-GSO packets) or one descriptor (for
- * frontend-side LRO).
- */
-static int xenvif_gop_skb(struct sk_buff *skb,
-			  struct netrx_pending_operations *npo)
-{
-	struct xenvif *vif = netdev_priv(skb->dev);
-	int nr_frags = skb_shinfo(skb)->nr_frags;
-	int i;
-	struct xen_netif_rx_request *req;
-	struct xenvif_rx_meta *meta;
-	unsigned char *data;
-	int head = 1;
-	int old_meta_prod;
-
-	old_meta_prod = npo->meta_prod;
-
-	/* Set up a GSO prefix descriptor, if necessary */
-	if (skb_shinfo(skb)->gso_size && vif->gso_prefix) {
-		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
-		meta = npo->meta + npo->meta_prod++;
-		meta->gso_size = skb_shinfo(skb)->gso_size;
-		meta->size = 0;
-		meta->id = req->id;
-	}
-
-	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
-	meta = npo->meta + npo->meta_prod++;
-
-	if (!vif->gso_prefix)
-		meta->gso_size = skb_shinfo(skb)->gso_size;
-	else
-		meta->gso_size = 0;
-
-	meta->size = 0;
-	meta->id = req->id;
-	npo->copy_off = 0;
-	npo->copy_gref = req->gref;
-
-	data = skb->data;
-	while (data < skb_tail_pointer(skb)) {
-		unsigned int offset = offset_in_page(data);
-		unsigned int len = PAGE_SIZE - offset;
-
-		if (data + len > skb_tail_pointer(skb))
-			len = skb_tail_pointer(skb) - data;
-
-		xenvif_gop_frag_copy(vif, skb, npo,
-				     virt_to_page(data), len, offset, &head);
-		data += len;
-	}
-
-	for (i = 0; i < nr_frags; i++) {
-		xenvif_gop_frag_copy(vif, skb, npo,
-				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				     skb_shinfo(skb)->frags[i].page_offset,
-				     &head);
-	}
-
-	return npo->meta_prod - old_meta_prod;
-}
-
-/*
- * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
- * used to set up the operations on the top of
- * netrx_pending_operations, which have since been done.  Check that
- * they didn't give any errors and advance over them.
- */
-static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
-			    struct netrx_pending_operations *npo)
-{
-	struct gnttab_copy     *copy_op;
-	int status = XEN_NETIF_RSP_OKAY;
-	int i;
-
-	for (i = 0; i < nr_meta_slots; i++) {
-		copy_op = npo->copy + npo->copy_cons++;
-		if (copy_op->status != GNTST_okay) {
-			netdev_dbg(vif->dev,
-				   "Bad status %d from copy to DOM%d.\n",
-				   copy_op->status, vif->domid);
-			status = XEN_NETIF_RSP_ERROR;
-		}
-	}
-
-	return status;
-}
-
-static void xenvif_add_frag_responses(struct xenvif *vif, int status,
-				      struct xenvif_rx_meta *meta,
-				      int nr_meta_slots)
-{
-	int i;
-	unsigned long offset;
-
-	/* No fragments used */
-	if (nr_meta_slots <= 1)
-		return;
-
-	nr_meta_slots--;
-
-	for (i = 0; i < nr_meta_slots; i++) {
-		int flags;
-		if (i == nr_meta_slots - 1)
-			flags = 0;
-		else
-			flags = XEN_NETRXF_more_data;
-
-		offset = 0;
-		make_rx_response(vif, meta[i].id, status, offset,
-				 meta[i].size, flags);
-	}
-}
-
-struct skb_cb_overlay {
-	int meta_slots_used;
-};
-
-static void xenvif_kick_thread(struct xenvif *vif)
+void xenvif_kick_thread(struct xenvif *vif)
 {
 	wake_up(&vif->wq);
 }
 
-void xenvif_rx_action(struct xenvif *vif)
-{
-	s8 status;
-	u16 flags;
-	struct xen_netif_rx_response *resp;
-	struct sk_buff_head rxq;
-	struct sk_buff *skb;
-	LIST_HEAD(notify);
-	int ret;
-	int nr_frags;
-	int count;
-	unsigned long offset;
-	struct skb_cb_overlay *sco;
-	int need_to_notify = 0;
-	struct xen_comms *comms = &vif->rx_comms;
-
-	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
-	struct xenvif_rx_meta *m = get_cpu_var(meta);
-
-	struct netrx_pending_operations npo = {
-		.copy  = gco,
-		.meta  = m,
-	};
-
-	if (gco == NULL || m == NULL) {
-		put_cpu_var(grant_copy_op);
-		put_cpu_var(meta);
-		printk(KERN_ALERT "netback: CPU %x scratch space is not usable,"
-		       " not doing any TX work for vif%u.%u\n",
-		       smp_processor_id(), vif->domid, vif->handle);
-		return;
-	}
-
-	skb_queue_head_init(&rxq);
-
-	count = 0;
-
-	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
-		vif = netdev_priv(skb->dev);
-		nr_frags = skb_shinfo(skb)->nr_frags;
-
-		sco = (struct skb_cb_overlay *)skb->cb;
-		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
-
-		count += nr_frags + 1;
-
-		__skb_queue_tail(&rxq, skb);
-
-		/* Filled the batch queue? */
-		if (count + MAX_SKB_FRAGS >=
-		    NETBK_RX_RING_SIZE(comms->nr_handles))
-			break;
-	}
-
-	BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
-
-	if (!npo.copy_prod) {
-		put_cpu_var(grant_copy_op);
-		put_cpu_var(meta);
-		return;
-	}
-
-	BUG_ON(npo.copy_prod > (2 * NETBK_MAX_RX_RING_SIZE));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
-					npo.copy_prod);
-	BUG_ON(ret != 0);
-
-	while ((skb = __skb_dequeue(&rxq)) != NULL) {
-		sco = (struct skb_cb_overlay *)skb->cb;
-
-		if (m[npo.meta_cons].gso_size && vif->gso_prefix) {
-			resp = RING_GET_RESPONSE(&vif->rx,
-						vif->rx.rsp_prod_pvt++);
-
-			resp->flags = XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
-
-			resp->offset = m[npo.meta_cons].gso_size;
-			resp->id = m[npo.meta_cons].id;
-			resp->status = sco->meta_slots_used;
-
-			npo.meta_cons++;
-			sco->meta_slots_used--;
-		}
-
-
-		vif->dev->stats.tx_bytes += skb->len;
-		vif->dev->stats.tx_packets++;
-
-		status = xenvif_check_gop(vif, sco->meta_slots_used, &npo);
-
-		if (sco->meta_slots_used == 1)
-			flags = 0;
-		else
-			flags = XEN_NETRXF_more_data;
-
-		if (skb->ip_summed == CHECKSUM_PARTIAL) /* local packet? */
-			flags |= XEN_NETRXF_csum_blank | XEN_NETRXF_data_validated;
-		else if (skb->ip_summed == CHECKSUM_UNNECESSARY)
-			/* remote but checksummed. */
-			flags |= XEN_NETRXF_data_validated;
-
-		offset = 0;
-		resp = make_rx_response(vif, m[npo.meta_cons].id,
-					status, offset,
-					m[npo.meta_cons].size,
-					flags);
-
-		if (m[npo.meta_cons].gso_size && !vif->gso_prefix) {
-			struct xen_netif_extra_info *gso =
-				(struct xen_netif_extra_info *)
-				RING_GET_RESPONSE(&vif->rx,
-						  vif->rx.rsp_prod_pvt++);
-
-			resp->flags |= XEN_NETRXF_extra_info;
-
-			gso->u.gso.size = m[npo.meta_cons].gso_size;
-			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
-			gso->u.gso.pad = 0;
-			gso->u.gso.features = 0;
-
-			gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
-			gso->flags = 0;
-		}
-
-		xenvif_add_frag_responses(vif, status,
-					  m + npo.meta_cons + 1,
-					  sco->meta_slots_used);
-
-		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
-		if (ret)
-			need_to_notify = 1;
-
-		xenvif_notify_tx_completion(vif);
-
-		npo.meta_cons += sco->meta_slots_used;
-		dev_kfree_skb(skb);
-	}
-
-	if (need_to_notify)
-		notify_remote_via_irq(vif->irq);
-
-	if (!skb_queue_empty(&vif->rx_queue))
-		xenvif_kick_thread(vif);
-
-	put_cpu_var(grant_copy_op);
-	put_cpu_var(meta);
-}
-
 void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
 {
 	skb_queue_tail(&vif->rx_queue, skb);
@@ -1383,29 +898,6 @@ static void make_tx_response(struct xenvif *vif,
 		notify_remote_via_irq(vif->irq);
 }
 
-static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
-					     u16      id,
-					     s8       st,
-					     u16      offset,
-					     u16      size,
-					     u16      flags)
-{
-	RING_IDX i = vif->rx.rsp_prod_pvt;
-	struct xen_netif_rx_response *resp;
-
-	resp = RING_GET_RESPONSE(&vif->rx, i);
-	resp->offset     = offset;
-	resp->flags      = flags;
-	resp->id         = id;
-	resp->status     = (s16)size;
-	if (st < 0)
-		resp->status = (s16)st;
-
-	vif->rx.rsp_prod_pvt = ++i;
-
-	return resp;
-}
-
 static inline int rx_work_todo(struct xenvif *vif)
 {
 	return !skb_queue_empty(&vif->rx_queue);
@@ -1507,8 +999,8 @@ int xenvif_kthread(void *data)
 		if (kthread_should_stop())
 			break;
 
-		if (rx_work_todo(vif))
-			xenvif_rx_action(vif);
+		if (rx_work_todo(vif) && vif->action)
+			vif->action(vif);
 	}
 
 	return 0;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 79499fc..4067286 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -415,6 +415,7 @@ static int connect_rings(struct backend_info *be)
 	unsigned long rx_ring_ref[NETBK_MAX_RING_PAGES];
 	unsigned int  tx_ring_order;
 	unsigned int  rx_ring_order;
+	unsigned int  rx_protocol;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
 			    "event-channel", "%u", &evtchn, NULL);
@@ -510,6 +511,11 @@ static int connect_rings(struct backend_info *be)
 		}
 	}
 
+	err = xenbus_scanf(XBT_NIL, dev->otherend, "rx-protocol",
+			   "%u", &rx_protocol);
+	if (err < 0)
+		rx_protocol = XENVIF_MIN_RX_PROTOCOL;
+
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
 			   &rx_copy);
 	if (err == -ENOENT) {
@@ -559,7 +565,7 @@ static int connect_rings(struct backend_info *be)
 	err = xenvif_connect(vif,
 			     tx_ring_ref, (1U << tx_ring_order),
 			     rx_ring_ref, (1U << rx_ring_order),
-			     evtchn);
+			     evtchn, rx_protocol);
 	if (err) {
 		int i;
 		xenbus_dev_fatal(dev, err,
diff --git a/drivers/net/xen-netback/xenvif_rx_protocol0.c b/drivers/net/xen-netback/xenvif_rx_protocol0.c
new file mode 100644
index 0000000..3c95d65
--- /dev/null
+++ b/drivers/net/xen-netback/xenvif_rx_protocol0.c
@@ -0,0 +1,616 @@
+/*
+ * netback rx protocol 0 implementation.
+ *
+ * Copyright (c) 2012, Citrix Systems Inc.
+ *
+ * Author: Wei Liu <wei.liu2@citrix.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+
+#include <xen/events.h>
+#include <xen/interface/memory.h>
+
+#include <asm/xen/hypercall.h>
+#include <asm/xen/page.h>
+
+struct xenvif_rx_meta;
+
+#define MAX_BUFFER_OFFSET PAGE_SIZE
+
+DECLARE_PER_CPU(struct gnttab_copy *, grant_copy_op);
+DECLARE_PER_CPU(struct xenvif_rx_meta *, meta);
+
+struct netrx_pending_operations {
+	unsigned copy_prod, copy_cons;
+	unsigned meta_prod, meta_cons;
+	struct gnttab_copy *copy;
+	struct xenvif_rx_meta *meta;
+	int copy_off;
+	grant_ref_t copy_gref;
+};
+
+struct skb_cb_overlay {
+	int meta_slots_used;
+};
+
+static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
+					     u16      id,
+					     s8       st,
+					     u16      offset,
+					     u16      size,
+					     u16      flags)
+{
+	RING_IDX i = vif->rx.p0.back.rsp_prod_pvt;
+	struct xen_netif_rx_response *resp;
+
+	resp = RING_GET_RESPONSE(&vif->rx.p0.back, i);
+	resp->offset     = offset;
+	resp->flags      = flags;
+	resp->id         = id;
+	resp->status     = (s16)size;
+	if (st < 0)
+		resp->status = (s16)st;
+
+	vif->rx.p0.back.rsp_prod_pvt = ++i;
+
+	return resp;
+}
+
+int xenvif_rx_ring_full(struct xenvif *vif)
+{
+	RING_IDX peek   = vif->rx.p0.rx_req_cons_peek;
+	RING_IDX needed = xenvif_max_required_rx_slots(vif);
+	struct xen_comms *comms = &vif->rx_comms;
+
+	return ((vif->rx.p0.back.sring->req_prod - peek) < needed) ||
+		((vif->rx.p0.back.rsp_prod_pvt +
+		  NETBK_RX_RING_SIZE(comms->nr_handles) - peek) < needed);
+}
+
+int xenvif_must_stop_queue(struct xenvif *vif)
+{
+	if (!xenvif_rx_ring_full(vif))
+		return 0;
+
+	vif->rx.p0.back.sring->req_event = vif->rx.p0.rx_req_cons_peek +
+		xenvif_max_required_rx_slots(vif);
+	mb(); /* request notification /then/ check the queue */
+
+	return xenvif_rx_ring_full(vif);
+}
+
+/*
+ * Returns true if we should start a new receive buffer instead of
+ * adding 'size' bytes to a buffer which currently contains 'offset'
+ * bytes.
+ */
+static bool start_new_rx_buffer(int offset, unsigned long size, int head)
+{
+	/* simple case: we have completely filled the current buffer. */
+	if (offset == MAX_BUFFER_OFFSET)
+		return true;
+
+	/*
+	 * complex case: start a fresh buffer if the current frag
+	 * would overflow the current buffer but only if:
+	 *     (i)   this frag would fit completely in the next buffer
+	 * and (ii)  there is already some data in the current buffer
+	 * and (iii) this is not the head buffer.
+	 *
+	 * Where:
+	 * - (i) stops us splitting a frag into two copies
+	 *   unless the frag is too large for a single buffer.
+	 * - (ii) stops us from leaving a buffer pointlessly empty.
+	 * - (iii) stops us leaving the first buffer
+	 *   empty. Strictly speaking this is already covered
+	 *   by (ii) but is explicitly checked because
+	 *   netfront relies on the first buffer being
+	 *   non-empty and can crash otherwise.
+	 *
+	 * This means we will effectively linearise small
+	 * frags but do not needlessly split large buffers
+	 * into multiple copies tend to give large frags their
+	 * own buffers as before.
+	 */
+	if ((offset + size > MAX_BUFFER_OFFSET) &&
+	    (size <= MAX_BUFFER_OFFSET) && offset && !head)
+		return true;
+
+	return false;
+}
+
+static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
+				struct netrx_pending_operations *npo)
+{
+	struct xenvif_rx_meta *meta;
+	struct xen_netif_rx_request *req;
+
+	req = RING_GET_REQUEST(&vif->rx.p0.back, vif->rx.p0.back.req_cons++);
+
+	meta = npo->meta + npo->meta_prod++;
+	meta->gso_size = 0;
+	meta->size = 0;
+	meta->id = req->id;
+
+	npo->copy_off = 0;
+	npo->copy_gref = req->gref;
+
+	return meta;
+}
+
+/*
+ * Set up the grant operations for this fragment. If it's a flipping
+ * interface, we also set up the unmap request from here.
+ */
+static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
+				struct netrx_pending_operations *npo,
+				struct page *page, unsigned long size,
+				unsigned long offset, int *head)
+{
+	struct gnttab_copy *copy_gop;
+	struct xenvif_rx_meta *meta;
+	/*
+	 * These variables are used iff get_page_ext returns true,
+	 * in which case they are guaranteed to be initialized.
+	 */
+	unsigned int uninitialized_var(idx);
+	int foreign = is_in_pool(page, &idx);
+	unsigned long bytes;
+
+	/* Data must not cross a page boundary. */
+	BUG_ON(size + offset > PAGE_SIZE);
+
+	meta = npo->meta + npo->meta_prod - 1;
+
+	while (size > 0) {
+		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
+
+		if (start_new_rx_buffer(npo->copy_off, size, *head)) {
+			/*
+			 * Netfront requires there to be some data in the head
+			 * buffer.
+			 */
+			BUG_ON(*head);
+
+			meta = get_next_rx_buffer(vif, npo);
+		}
+
+		bytes = size;
+		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
+
+		copy_gop = npo->copy + npo->copy_prod++;
+		copy_gop->flags = GNTCOPY_dest_gref;
+		if (foreign) {
+			struct pending_tx_info *src_pend = to_txinfo(idx);
+			struct xenvif *rvif = to_vif(idx);
+
+			copy_gop->source.domid = rvif->domid;
+			copy_gop->source.u.ref = src_pend->req.gref;
+			copy_gop->flags |= GNTCOPY_source_gref;
+		} else {
+			void *vaddr = page_address(page);
+			copy_gop->source.domid = DOMID_SELF;
+			copy_gop->source.u.gmfn = virt_to_mfn(vaddr);
+		}
+		copy_gop->source.offset = offset;
+		copy_gop->dest.domid = vif->domid;
+
+		copy_gop->dest.offset = npo->copy_off;
+		copy_gop->dest.u.ref = npo->copy_gref;
+		copy_gop->len = bytes;
+
+		npo->copy_off += bytes;
+		meta->size += bytes;
+
+		offset += bytes;
+		size -= bytes;
+
+		/* Leave a gap for the GSO descriptor. */
+		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+			vif->rx.p0.back.req_cons++;
+
+		*head = 0; /* There must be something in this buffer now. */
+	}
+}
+
+/*
+ * Prepare an SKB to be transmitted to the frontend.
+ *
+ * This function is responsible for allocating grant operations, meta
+ * structures, etc.
+ *
+ * It returns the number of meta structures consumed. The number of
+ * ring slots used is always equal to the number of meta slots used
+ * plus the number of GSO descriptors used. Currently, we use either
+ * zero GSO descriptors (for non-GSO packets) or one descriptor (for
+ * frontend-side LRO).
+ */
+static int xenvif_gop_skb(struct sk_buff *skb,
+			 struct netrx_pending_operations *npo)
+{
+	struct xenvif *vif = netdev_priv(skb->dev);
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int i;
+	struct xen_netif_rx_request *req;
+	struct xenvif_rx_meta *meta;
+	unsigned char *data;
+	int head = 1;
+	int old_meta_prod;
+
+	old_meta_prod = npo->meta_prod;
+
+	/* Set up a GSO prefix descriptor, if necessary */
+	if (skb_shinfo(skb)->gso_size && vif->gso_prefix) {
+		req = RING_GET_REQUEST(&vif->rx.p0.back,
+				       vif->rx.p0.back.req_cons++);
+		meta = npo->meta + npo->meta_prod++;
+		meta->gso_size = skb_shinfo(skb)->gso_size;
+		meta->size = 0;
+		meta->id = req->id;
+	}
+
+	req = RING_GET_REQUEST(&vif->rx.p0.back, vif->rx.p0.back.req_cons++);
+	meta = npo->meta + npo->meta_prod++;
+
+	if (!vif->gso_prefix)
+		meta->gso_size = skb_shinfo(skb)->gso_size;
+	else
+		meta->gso_size = 0;
+
+	meta->size = 0;
+	meta->id = req->id;
+	npo->copy_off = 0;
+	npo->copy_gref = req->gref;
+
+	data = skb->data;
+
+	while (data < skb_tail_pointer(skb)) {
+		unsigned int offset = offset_in_page(data);
+		unsigned int len = PAGE_SIZE - offset;
+
+		if (data + len > skb_tail_pointer(skb))
+			len = skb_tail_pointer(skb) - data;
+
+		xenvif_gop_frag_copy(vif, skb, npo,
+				    virt_to_page(data), len, offset, &head);
+		data += len;
+	}
+
+	for (i = 0; i < nr_frags; i++) {
+		xenvif_gop_frag_copy(vif, skb, npo,
+				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				    skb_shinfo(skb)->frags[i].page_offset,
+				    &head);
+	}
+
+	return npo->meta_prod - old_meta_prod;
+}
+
+/*
+ * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
+ * used to set up the operations on the top of
+ * netrx_pending_operations, which have since been done.  Check that
+ * they didn't give any errors and advance over them.
+ */
+static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
+			   struct netrx_pending_operations *npo)
+{
+	struct gnttab_copy     *copy_op;
+	int status = XEN_NETIF_RSP_OKAY;
+	int i;
+
+	for (i = 0; i < nr_meta_slots; i++) {
+		copy_op = npo->copy + npo->copy_cons++;
+		if (copy_op->status != GNTST_okay) {
+			netdev_dbg(vif->dev,
+				   "Bad status %d from copy to DOM%d.\n",
+				   copy_op->status, vif->domid);
+			status = XEN_NETIF_RSP_ERROR;
+		}
+	}
+
+	return status;
+}
+
+static void xenvif_add_frag_responses(struct xenvif *vif, int status,
+				     struct xenvif_rx_meta *meta,
+				     int nr_meta_slots)
+{
+	int i;
+	unsigned long offset;
+
+	/* No fragments used */
+	if (nr_meta_slots <= 1)
+		return;
+
+	nr_meta_slots--;
+
+	for (i = 0; i < nr_meta_slots; i++) {
+		int flags;
+		if (i == nr_meta_slots - 1)
+			flags = 0;
+		else
+			flags = XEN_NETRXF_more_data;
+
+		offset = 0;
+		make_rx_response(vif, meta[i].id, status, offset,
+				 meta[i].size, flags);
+	}
+}
+
+/*
+ * Figure out how many ring slots we're going to need to send @skb to
+ * the guest. This function is essentially a dry run of
+ * xenvif_gop_frag_copy.
+ */
+unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+{
+	unsigned int count;
+	int i, copy_off;
+
+	count = DIV_ROUND_UP(
+			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
+
+	copy_off = skb_headlen(skb) % PAGE_SIZE;
+
+	if (skb_shinfo(skb)->gso_size)
+		count++;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		unsigned long bytes;
+		while (size > 0) {
+			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
+
+			if (start_new_rx_buffer(copy_off, size, 0)) {
+				count++;
+				copy_off = 0;
+			}
+
+			bytes = size;
+			if (copy_off + bytes > MAX_BUFFER_OFFSET)
+				bytes = MAX_BUFFER_OFFSET - copy_off;
+
+			copy_off += bytes;
+			size -= bytes;
+		}
+	}
+	return count;
+}
+
+
+void xenvif_rx_action(struct xenvif *vif)
+{
+	s8 status;
+	u16 flags;
+	struct xen_netif_rx_response *resp;
+	struct sk_buff_head rxq;
+	struct sk_buff *skb;
+	LIST_HEAD(notify);
+	int ret;
+	int nr_frags;
+	int count;
+	unsigned long offset;
+	struct skb_cb_overlay *sco;
+	int need_to_notify = 0;
+	struct xen_comms *comms = &vif->rx_comms;
+
+	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
+	struct xenvif_rx_meta *m = get_cpu_var(meta);
+
+	struct netrx_pending_operations npo = {
+		.copy  = gco,
+		.meta  = m,
+	};
+
+	if (gco == NULL || m == NULL) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
+		printk(KERN_ALERT "netback: CPU %x scratch space is not usable,"
+		       " not doing any TX work for vif%u.%u\n",
+		       smp_processor_id(), vif->domid, vif->handle);
+		return;
+	}
+
+	skb_queue_head_init(&rxq);
+
+	count = 0;
+
+	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
+		vif = netdev_priv(skb->dev);
+		nr_frags = skb_shinfo(skb)->nr_frags;
+
+		sco = (struct skb_cb_overlay *)skb->cb;
+		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
+
+		count += nr_frags + 1;
+
+		__skb_queue_tail(&rxq, skb);
+
+		/* Filled the batch queue? */
+		if (count + MAX_SKB_FRAGS >=
+		    NETBK_RX_RING_SIZE(comms->nr_handles))
+			break;
+	}
+
+	BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
+
+	if (!npo.copy_prod) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
+		return;
+	}
+
+	BUG_ON(npo.copy_prod > (2 * NETBK_MAX_RX_RING_SIZE));
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
+					npo.copy_prod);
+	BUG_ON(ret != 0);
+
+	while ((skb = __skb_dequeue(&rxq)) != NULL) {
+		sco = (struct skb_cb_overlay *)skb->cb;
+
+		if (m[npo.meta_cons].gso_size && vif->gso_prefix) {
+			resp = RING_GET_RESPONSE(&vif->rx.p0.back,
+					 vif->rx.p0.back.rsp_prod_pvt++);
+
+			resp->flags =
+				XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
+
+			resp->offset = m[npo.meta_cons].gso_size;
+			resp->id = m[npo.meta_cons].id;
+			resp->status = sco->meta_slots_used;
+
+			npo.meta_cons++;
+			sco->meta_slots_used--;
+		}
+
+
+		vif->dev->stats.tx_bytes += skb->len;
+		vif->dev->stats.tx_packets++;
+
+		status = xenvif_check_gop(vif, sco->meta_slots_used, &npo);
+
+		if (sco->meta_slots_used == 1)
+			flags = 0;
+		else
+			flags = XEN_NETRXF_more_data;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) /* local packet? */
+			flags |= XEN_NETRXF_csum_blank |
+				XEN_NETRXF_data_validated;
+		else if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+			/* remote but checksummed. */
+			flags |= XEN_NETRXF_data_validated;
+
+		offset = 0;
+		resp = make_rx_response(vif, m[npo.meta_cons].id,
+					status, offset,
+					m[npo.meta_cons].size,
+					flags);
+
+		if (m[npo.meta_cons].gso_size && !vif->gso_prefix) {
+			struct xen_netif_extra_info *gso =
+				(struct xen_netif_extra_info *)
+				RING_GET_RESPONSE(&vif->rx.p0.back,
+					  vif->rx.p0.back.rsp_prod_pvt++);
+
+			resp->flags |= XEN_NETRXF_extra_info;
+
+			gso->u.gso.size = m[npo.meta_cons].gso_size;
+			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
+			gso->u.gso.pad = 0;
+			gso->u.gso.features = 0;
+
+			gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
+			gso->flags = 0;
+		}
+
+		xenvif_add_frag_responses(vif, status,
+					  m + npo.meta_cons + 1,
+					  sco->meta_slots_used);
+
+		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx.p0.back, ret);
+		if (ret)
+			need_to_notify = 1;
+
+		if (netif_queue_stopped(vif->dev) &&
+		    xenvif_schedulable(vif) &&
+		    !xenvif_rx_ring_full(vif))
+			netif_wake_queue(vif->dev);
+
+		npo.meta_cons += sco->meta_slots_used;
+		dev_kfree_skb(skb);
+	}
+
+	if (need_to_notify)
+		notify_remote_via_irq(vif->irq);
+
+	if (!skb_queue_empty(&vif->rx_queue))
+		xenvif_kick_thread(vif);
+
+	put_cpu_var(grant_copy_op);
+	put_cpu_var(meta);
+}
+
+int xenvif_p0_setup(struct xenvif *vif)
+{
+	struct xenvif_rx_protocol0 *p0 = &vif->rx.p0;
+	struct xen_netif_rx_sring *sring;
+
+	p0->rx_req_cons_peek = 0;
+
+	sring = (struct xen_netif_rx_sring *)vif->rx_comms.ring_area->addr;
+	BACK_RING_INIT(&p0->back, sring, PAGE_SIZE * vif->rx_comms.nr_handles);
+
+	return 0;
+}
+
+void xenvif_p0_start_xmit(struct xenvif *vif, struct sk_buff *skb)
+{
+	struct net_device *dev = vif->dev;
+
+	/* Drop the packet if there is no carrier */
+	if (unlikely(!xenvif_schedulable(vif)))
+		goto drop;
+
+	/* Drop the packet if the target domain has no receive buffers. */
+	if (unlikely(xenvif_rx_ring_full(vif)))
+		goto drop;
+
+	/* Reserve ring slots for the worst-case number of fragments. */
+	vif->rx.p0.rx_req_cons_peek += xenvif_count_skb_slots(vif, skb);
+
+	if (vif->can_queue && xenvif_must_stop_queue(vif))
+		netif_stop_queue(dev);
+
+	xenvif_queue_tx_skb(vif, skb);
+
+	return;
+
+drop:
+	vif->dev->stats.tx_dropped++;
+	dev_kfree_skb(skb);
+}
+
+void xenvif_p0_teardown(struct xenvif *vif)
+{
+	/* Nothing to teardown, relax */
+}
+
+void xenvif_p0_event(struct xenvif *vif)
+{
+	if (!xenvif_rx_ring_full(vif))
+		netif_wake_queue(vif->dev);
+}
+
+void xenvif_p0_action(struct xenvif *vif)
+{
+	xenvif_rx_action(vif);
+}
diff --git a/drivers/net/xen-netback/xenvif_rx_protocol0.h b/drivers/net/xen-netback/xenvif_rx_protocol0.h
new file mode 100644
index 0000000..aceb2ec
--- /dev/null
+++ b/drivers/net/xen-netback/xenvif_rx_protocol0.h
@@ -0,0 +1,53 @@
+/*
+ * netback rx protocol 0 implementation.
+ *
+ * Copyright (c) 2012, Citrix Systems Inc.
+ *
+ * Author: Wei Liu <wei.liu2@citrix.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __XENVIF_RX_PROTOCOL0_H__
+#define __XENVIF_RX_PROTOCOL0_H__
+
+struct xenvif_rx_protocol0 {
+	struct xen_netif_rx_back_ring back;
+	/*
+	 * Allow xenvif_start_xmit() to peek ahead in the rx request
+	 * ring.  This is a prediction of what rx_req_cons will be
+	 * once all queued skbs are put on the ring.
+	 */
+	RING_IDX rx_req_cons_peek;
+};
+
+
+int  xenvif_p0_setup(struct xenvif *vif);
+void xenvif_p0_start_xmit(struct xenvif *vif, struct sk_buff *skb);
+void xenvif_p0_teardown(struct xenvif *vif);
+void xenvif_p0_event(struct xenvif *vif);
+void xenvif_p0_action(struct xenvif *vif);
+
+#endif /* __XENVIF_RX_PROTOCOL0_H__ */
-- 
1.7.2.5
