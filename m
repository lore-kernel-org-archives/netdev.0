From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 13/14] i40e: added XDP support for TP4 enabled queue pairs
Date: Tue, 31 Oct 2017 13:41:44 +0100
Message-ID: <20171031124145.9667-14-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35439 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbdJaMnT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:43:19 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

In this commit the packet array learned to execute XDP programs on
it's flushable range. This means that before the kernel flush
completed/filled Rx frame to userspace, an XDP program will be
executed and acted upon.

Currently, a packet array user still have to explicitly call the
tp4a_run_xdp function, prior a tp4a_flush/tp4a_flush_n call, but this
will change in a future patch set.

The XDP_TX/XDP_REDIRECT is doing page allocation, so exepect lousy
performance. The i40e XDP infrastructure needs to be aligned to handle
TP4 properly.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  70 +++++++++++-
 drivers/net/veth.c                          |   6 +-
 include/linux/tpacket4.h                    | 160 +++++++++++++++++++++++++++-
 net/packet/af_packet.c                      |   4 +-
 5 files changed, 233 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ff6d44dae8d0..b63cc4c8957f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11398,7 +11398,7 @@ static int i40e_tp4_enable_rx(struct i40e_ring *rxr,
 	size_t elems = __roundup_pow_of_two(rxr->count * 8);
 	struct tp4_packet_array *arr;
 
-	arr = tp4a_rx_new(params->rx_opaque, elems, rxr->dev);
+	arr = tp4a_rx_new(params->rx_opaque, elems, rxr->netdev, rxr->dev);
 	if (!arr)
 		return -ENOMEM;
 
@@ -11428,7 +11428,7 @@ static int i40e_tp4_enable_tx(struct i40e_ring *txr,
 	size_t elems = __roundup_pow_of_two(txr->count * 8);
 	struct tp4_packet_array *arr;
 
-	arr = tp4a_tx_new(params->tx_opaque, elems, txr->dev);
+	arr = tp4a_tx_new(params->tx_opaque, elems, txr->netdev, txr->dev);
 	if (!arr)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 712e10e14aec..730fe57ca8ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2277,6 +2277,9 @@ static inline unsigned int i40e_get_rx_desc_size(union i40e_rx_desc *rxd)
 	return size;
 }
 
+static void i40e_run_xdp_tp4(struct tp4_frame_set *f, bool *recycled,
+			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr);
+
 /**
  * i40e_clean_rx_tp4_irq - Pulls received packets of the descriptor ring
  * @rxr: ingress ring
@@ -2286,14 +2289,18 @@ static inline unsigned int i40e_get_rx_desc_size(union i40e_rx_desc *rxd)
  **/
 int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget)
 {
-	int total_rx_bytes = 0, total_rx_packets = 0;
+	int total_rx_bytes = 0, total_rx_packets = 0, nflush = 0;
 	u16 cleaned_count = I40E_DESC_UNUSED(rxr);
 	struct tp4_frame_set frame_set;
+	struct bpf_prog *xdp_prog;
+	struct i40e_ring *xdpr;
 	bool failure;
 
 	if (!tp4a_get_flushable_frame_set(rxr->tp4.arr, &frame_set))
 		goto out;
 
+	rcu_read_lock();
+	xdp_prog = READ_ONCE(rxr->xdp_prog);
 	while (total_rx_packets < budget) {
 		union i40e_rx_desc *rxd = I40E_RX_DESC(rxr, rxr->next_to_clean);
 		unsigned int size = i40e_get_rx_desc_size(rxd);
@@ -2310,6 +2317,19 @@ int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget)
 		tp4f_set_frame_no_offset(&frame_set, size,
 					 i40e_is_rx_desc_eof(rxd));
 
+		if (xdp_prog) {
+			bool recycled;
+
+			xdpr = rxr->vsi->xdp_rings[rxr->queue_index];
+			i40e_run_xdp_tp4(&frame_set, &recycled,
+					 xdp_prog, xdpr);
+
+			if (!recycled)
+				nflush++;
+		} else {
+			nflush++;
+		}
+
 		total_rx_bytes += size;
 		total_rx_packets++;
 
@@ -2317,8 +2337,9 @@ int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget)
 
 		WARN_ON(!tp4f_next_frame(&frame_set));
 	}
+	rcu_read_unlock();
 
-	WARN_ON(tp4a_flush_n(rxr->tp4.arr, total_rx_packets));
+	WARN_ON(tp4a_flush_n(rxr->tp4.arr, nflush));
 
 	rxr->tp4.ev_handler(rxr->tp4.ev_opaque);
 
@@ -3800,3 +3821,48 @@ int i40e_clean_tx_tp4_irq(struct i40e_ring *txr, int budget)
 
 	return clean_done && xmit_done;
 }
+
+/**
+ * i40e_tp4_xdp_tx_handler - XDP xmit
+ * @ctx: context
+ * @xdp: XDP buff
+ *
+ * Returns >=0 on success, <0 on failure.
+ **/
+static int i40e_tp4_xdp_tx_handler(void *ctx, struct xdp_buff *xdp)
+{
+	struct i40e_ring *xdpr = ctx;
+
+	return i40e_xmit_xdp_ring(xdp, xdpr);
+}
+
+/**
+ * i40e_tp4_xdp_tx_flush_handler - XDP flush
+ * @ctx: context
+ **/
+static void i40e_tp4_xdp_tx_flush_handler(void *ctx)
+{
+	struct i40e_ring *xdpr = ctx;
+
+	/* Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.
+	 */
+	wmb();
+
+	writel(xdpr->next_to_use, xdpr->tail);
+}
+
+/**
+ * i40e_run_xdp_tp4 - Runs an XDP program on a the flushable range of packets
+ * @a: pointer to frame set
+ * @recycled: true if element was removed from flushable range
+ * @xdp_prog: XDP program
+ * @xdpr: XDP Tx ring
+ **/
+static void i40e_run_xdp_tp4(struct tp4_frame_set *f, bool *recycled,
+			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr)
+{
+	tp4a_run_xdp(f, recycled, xdp_prog,
+		     i40e_tp4_xdp_tx_handler, xdpr,
+		     i40e_tp4_xdp_tx_flush_handler, xdpr);
+}
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3dfb5fb89460..eea1eab00624 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -400,13 +400,15 @@ static int veth_tp4_enable(struct net_device *netdev,
 	netif_napi_add(netdev, priv->napi, veth_napi_poll,
 		       NAPI_POLL_WEIGHT);
 
-	priv->tp4a_rx = tp4a_rx_new(params->rx_opaque, NAPI_POLL_WEIGHT, NULL);
+	priv->tp4a_rx = tp4a_rx_new(params->rx_opaque, NAPI_POLL_WEIGHT, NULL,
+				    NULL);
 	if (!priv->tp4a_rx) {
 		err = -ENOMEM;
 		goto rxa_err;
 	}
 
-	priv->tp4a_tx = tp4a_tx_new(params->tx_opaque, NAPI_POLL_WEIGHT, NULL);
+	priv->tp4a_tx = tp4a_tx_new(params->tx_opaque, NAPI_POLL_WEIGHT, NULL,
+				    NULL);
 	if (!priv->tp4a_tx) {
 		err = -ENOMEM;
 		goto txa_err;
diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index 360d80086104..cade34e48a2d 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -15,6 +15,8 @@
 #ifndef _LINUX_TPACKET4_H
 #define _LINUX_TPACKET4_H
 
+#include <linux/bpf_trace.h>
+
 #define TP4_UMEM_MIN_FRAME_SIZE 2048
 #define TP4_KERNEL_HEADROOM 256 /* Headrom for XDP */
 
@@ -73,6 +75,7 @@ struct tp4_queue {
  **/
 struct tp4_packet_array {
 	struct tp4_queue *tp4q;
+	struct net_device *netdev;
 	struct device *dev;
 	enum dma_data_direction direction;
 	enum tp4_validation validation;
@@ -890,6 +893,7 @@ static inline void tp4f_packet_completed(struct tp4_frame_set *p)
 
 static inline struct tp4_packet_array *__tp4a_new(
 	struct tp4_queue *tp4q,
+	struct net_device *netdev,
 	struct device *dev,
 	enum dma_data_direction direction,
 	enum tp4_validation validation,
@@ -913,6 +917,7 @@ static inline struct tp4_packet_array *__tp4a_new(
 	}
 
 	arr->tp4q = tp4q;
+	arr->netdev = netdev;
 	arr->dev = dev;
 	arr->direction = direction;
 	arr->validation = validation;
@@ -930,11 +935,12 @@ static inline struct tp4_packet_array *__tp4a_new(
  **/
 static inline struct tp4_packet_array *tp4a_rx_new(void *rx_opaque,
 						   size_t elems,
+						   struct net_device *netdev,
 						   struct device *dev)
 {
 	enum dma_data_direction direction = dev ? DMA_FROM_DEVICE : DMA_NONE;
 
-	return __tp4a_new(rx_opaque, dev, direction, TP4_VALIDATION_IDX,
+	return __tp4a_new(rx_opaque, netdev, dev, direction, TP4_VALIDATION_IDX,
 			  elems);
 }
 
@@ -948,12 +954,13 @@ static inline struct tp4_packet_array *tp4a_rx_new(void *rx_opaque,
  **/
 static inline struct tp4_packet_array *tp4a_tx_new(void *tx_opaque,
 						   size_t elems,
+						   struct net_device *netdev,
 						   struct device *dev)
 {
 	enum dma_data_direction direction = dev ? DMA_TO_DEVICE : DMA_NONE;
 
-	return __tp4a_new(tx_opaque, dev, direction, TP4_VALIDATION_DESC,
-			  elems);
+	return __tp4a_new(tx_opaque, netdev, dev, direction,
+			  TP4_VALIDATION_DESC, elems);
 }
 
 /**
@@ -1330,4 +1337,151 @@ static inline void tp4a_return_packet(struct tp4_packet_array *a,
 	a->curr = p->start;
 }
 
+static inline struct tpacket4_desc __tp4a_swap_out(struct tp4_packet_array *a,
+						   u32 idx)
+{
+	struct tpacket4_desc tmp, *d;
+
+	/* NB! idx is already masked, so 0 <= idx < size holds! */
+	d = &a->items[a->start & a->mask];
+	tmp = *d;
+	*d = a->items[idx];
+	a->items[idx] = tmp;
+	a->start++;
+
+	return tmp;
+}
+
+static inline void  __tp4a_recycle(struct tp4_packet_array *a,
+				   struct tpacket4_desc *d)
+{
+	/* NB! No bound checking, assume paired with __tp4a_swap_out
+	 * to guarantee space.
+	 */
+	d->offset = tp4q_get_data_headroom(a->tp4q);
+	a->items[a->end++ & a->mask] = *d;
+}
+
+static inline void __tp4a_fill_xdp_buff(struct tp4_packet_array *a,
+					struct xdp_buff *xdp,
+					struct tpacket4_desc *d)
+{
+	xdp->data = tp4q_get_data(a->tp4q, d);
+	xdp->data_end = xdp->data + d->len;
+	xdp->data_meta = xdp->data;
+	xdp->data_hard_start = xdp->data - TP4_KERNEL_HEADROOM;
+}
+
+#define TP4_XDP_PASS 0
+#define TP4_XDP_CONSUMED 1
+#define TP4_XDP_TX 2
+
+/**
+ * tp4a_run_xdp - Execute an XDP program on the flushable range
+ * @a: pointer to frame set
+ * @recycled: the element was removed from flushable range
+ * @xdp_prog: XDP program
+ * @xdp_tx_handler: XDP xmit handler
+ * @xdp_tx_ctx: XDP xmit handler ctx
+ * @xdp_tx_flush_handler: XDP xmit flush handler
+ * @xdp_tx_flush_ctx: XDP xmit flush ctx
+ **/
+static inline void tp4a_run_xdp(struct tp4_frame_set *f,
+				bool *recycled,
+				struct bpf_prog *xdp_prog,
+				int (*xdp_tx_handler)(void *ctx,
+						      struct xdp_buff *xdp),
+				void *xdp_tx_ctx,
+				void (*xdp_tx_flush_handler)(void *ctx),
+				void *xdp_tx_flush_ctx)
+{
+	struct tp4_packet_array *a = f->pkt_arr;
+	struct tpacket4_desc *d, tmp;
+	bool xdp_xmit = false;
+	struct xdp_buff xdp;
+	ptrdiff_t diff, len;
+	struct page *page;
+	u32 act, idx;
+	void *data;
+	int err;
+
+	*recycled = false;
+
+	idx = f->curr & a->mask;
+	d = &a->items[idx];
+	__tp4a_fill_xdp_buff(a, &xdp, d);
+	data = xdp.data;
+
+	act = bpf_prog_run_xdp(xdp_prog, &xdp);
+	switch (act) {
+	case XDP_PASS:
+		if (data != xdp.data) {
+			diff = data - xdp.data;
+			d->offset += diff;
+		}
+		break;
+	case XDP_TX:
+	case XDP_REDIRECT:
+		*recycled = true;
+		tmp = __tp4a_swap_out(a, idx);
+		__tp4a_recycle(a, &tmp);
+
+		/* Ick! ndo_xdp_xmit is missing a destructor,
+		 * meaning that we cannot do proper completion
+		 * to userland, so we need to resort to
+		 * copying. Also, we need to rethink XDP Tx to
+		 * unify it with the existing patch, so we'll
+		 * do a copy here as well. So much for
+		 * "fast-path"...
+		 */
+		page = dev_alloc_pages(0);
+		if (!page)
+			break;
+
+		len = xdp.data_end - xdp.data;
+		if (len > PAGE_SIZE) {
+			put_page(page);
+			break;
+		}
+		data = page_address(page);
+		memcpy(data, xdp.data, len);
+
+		xdp.data = data;
+		xdp.data_end = data + len;
+		xdp_set_data_meta_invalid(&xdp);
+		xdp.data_hard_start = xdp.data;
+		if (act == XDP_TX) {
+			err = xdp_tx_handler(xdp_tx_ctx, &xdp);
+			/* XXX Clean this return value ugliness up... */
+			if (err != TP4_XDP_TX) {
+				put_page(page);
+				break;
+			}
+		} else {
+			err = xdp_do_redirect(a->netdev, &xdp, xdp_prog);
+			if (err) {
+				put_page(page);
+				break;
+			}
+		}
+		xdp_xmit = true;
+		break;
+	default:
+		bpf_warn_invalid_xdp_action(act);
+		/* fallthrough */
+	case XDP_ABORTED:
+		trace_xdp_exception(a->netdev, xdp_prog, act);
+		/* fallthrough -- handle aborts by dropping packet */
+	case XDP_DROP:
+		*recycled = true;
+		tmp = __tp4a_swap_out(a, idx);
+		__tp4a_recycle(a, &tmp);
+	}
+
+	if (xdp_xmit) {
+		xdp_tx_flush_handler(xdp_tx_ctx);
+		xdp_do_flush_map();
+	}
+}
+
 #endif /* _LINUX_TPACKET4_H */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fbfada773463..105cdac13343 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -5038,8 +5038,8 @@ packet_v4_ring_new(struct sock *sk, struct tpacket_req4 *req, int tx_ring)
 		  (struct tpacket4_desc *)rb->pg_vec->buffer);
 	spin_unlock_bh(&rb_queue->lock);
 
-	rb->tp4a = tx_ring ? tp4a_tx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL)
-		   : tp4a_rx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL);
+	rb->tp4a = tx_ring ? tp4a_tx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL, NULL)
+		   : tp4a_rx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL, NULL);
 
 	if (!rb->tp4a) {
 		err = -ENOMEM;
-- 
2.11.0
