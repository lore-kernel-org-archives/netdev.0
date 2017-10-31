From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 09/14] i40e: AF_PACKET V4 ndo_tp4_zerocopy Tx support
Date: Tue, 31 Oct 2017 13:41:40 +0100
Message-ID: <20171031124145.9667-10-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6507 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751651AbdJaMm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:58 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

Here, egress support for TP4 is added, and hence implementing
ndo_tp4_xmit. The ndo_tp4_xmit simply kicks the NAPI context.

In the NAPI poll, pulling egress frames from userland, posting the
frames to the hardware descriptor queue and clearing completed frames
from the egress hardware descriptor ring is done.

The clean_irq i40e_ring member is extended to include the Tx ring
clean up as well, resulting in some function signature changes for
i40e_clean_tx_irq.

As in the Rx case, we're not using i40e_tx_buffer for storing
metadata.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c |  98 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 266 +++++++++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |   4 +
 include/linux/tpacket4.h                    |  34 ++++
 5 files changed, 373 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 56dff7d314c4..b33b64b87725 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -745,7 +745,7 @@ struct i40e_vsi {
 	/* VSI specific handlers */
 	irqreturn_t (*irq_handler)(int irq, void *data);
 
-	struct i40e_tp4_ctx **tp4_ctxs; /* Rx context */
+	struct i40e_tp4_ctx **tp4_ctxs; /* Rx, Tx context */
 	u16 num_tp4_ctxs;
 } ____cacheline_internodealigned_in_smp;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5456ef6cce1b..ff6d44dae8d0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4830,12 +4830,14 @@ static void i40e_vsi_save_tp4_ctxs(struct i40e_vsi *vsi)
 				vsi->num_tp4_ctxs = vsi->num_queue_pairs;
 			}
 
-			vsi->tp4_ctxs[i] = kzalloc(sizeof(struct i40e_tp4_ctx),
+			vsi->tp4_ctxs[i] = kcalloc(2, /* rx, tx */
+						   sizeof(struct i40e_tp4_ctx),
 						   GFP_KERNEL);
 			if (!vsi->tp4_ctxs[i])
 				goto out_elmn;
 
-			*vsi->tp4_ctxs[i] = vsi->rx_rings[i]->tp4;
+			vsi->tp4_ctxs[i][0] = vsi->rx_rings[i]->tp4;
+			vsi->tp4_ctxs[i][1] = vsi->tx_rings[i]->tp4;
 		}
 	}
 
@@ -4897,15 +4899,22 @@ static void i40e_tp4_flush_all(struct tp4_packet_array *a)
  * @rx_ctx: the Rx TP4 context
  **/
 static void i40e_tp4_restore(struct i40e_vsi *vsi, int queue_pair,
-			     struct i40e_tp4_ctx *rx_ctx)
+			     struct i40e_tp4_ctx *rx_ctx,
+			     struct i40e_tp4_ctx *tx_ctx)
 {
 	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+	struct i40e_ring *txr = vsi->tx_rings[queue_pair];
 
 	rxr->tp4 = *rx_ctx;
 	i40e_tp4_flush_all(rxr->tp4.arr);
 	i40e_tp4_set_rx_handler(rxr);
 
+	txr->tp4 = *tx_ctx;
+	i40e_tp4_flush_all(txr->tp4.arr);
+	txr->clean_irq = i40e_clean_tx_tp4_irq;
+
 	set_ring_tp4(rxr);
+	set_ring_tp4(txr);
 }
 
 /**
@@ -4923,7 +4932,8 @@ static void i40e_vsi_restore_tp4_ctxs(struct i40e_vsi *vsi)
 	for (i = 0; i < elms; i++) {
 		if (!vsi->tp4_ctxs[i])
 			continue;
-		i40e_tp4_restore(vsi, i, vsi->tp4_ctxs[i]);
+		i40e_tp4_restore(vsi, i, &vsi->tp4_ctxs[i][0],
+				 &vsi->tp4_ctxs[i][1]);
 	}
 
 	i40e_vsi_free_tp4_ctxs(vsi);
@@ -9337,6 +9347,7 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		ring->netdev = vsi->netdev;
 		ring->dev = &pf->pdev->dev;
 		ring->count = vsi->num_desc;
+		ring->clean_irq = i40e_clean_tx_irq;
 		ring->size = 0;
 		ring->dcb_tc = 0;
 		if (vsi->back->hw_features & I40E_HW_WB_ON_ITR_CAPABLE)
@@ -9354,6 +9365,7 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		ring->netdev = NULL;
 		ring->dev = &pf->pdev->dev;
 		ring->count = vsi->num_desc;
+		ring->clean_irq = i40e_clean_tx_irq;
 		ring->size = 0;
 		ring->dcb_tc = 0;
 		if (vsi->back->hw_features & I40E_HW_WB_ON_ITR_CAPABLE)
@@ -11246,7 +11258,23 @@ static struct i40e_tp4_ctx *i40e_vsi_get_tp4_rx_ctx(struct i40e_vsi *vsi,
 	if (!vsi->tp4_ctxs)
 		return NULL;
 
-	return vsi->tp4_ctxs[queue_pair];
+	return &vsi->tp4_ctxs[queue_pair][0];
+}
+
+/**
+ * i40e_vsi_get_tp4_tx_ctx - Retrieves the Tx TP4 context, if any.
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ *
+ * Returns NULL if there's no context available.
+ **/
+static struct i40e_tp4_ctx *i40e_vsi_get_tp4_tx_ctx(struct i40e_vsi *vsi,
+						    int queue_pair)
+{
+	if (!vsi->tp4_ctxs)
+		return NULL;
+
+	return &vsi->tp4_ctxs[queue_pair][1];
 }
 
 /**
@@ -11271,6 +11299,24 @@ static void i40e_tp4_disable_rx(struct i40e_ring *rxr)
 }
 
 /**
+ * i40e_tp4_disable_tx - Disables TP4 Rx mode
+ * @txr: egress ring
+ **/
+static void i40e_tp4_disable_tx(struct i40e_ring *txr)
+{
+	/* Don't free, if the context is saved! */
+	if (i40e_vsi_get_tp4_tx_ctx(txr->vsi, txr->queue_index))
+		txr->tp4.arr = NULL;
+	else
+		tp4a_free(txr->tp4.arr);
+
+	memset(&txr->tp4, 0, sizeof(txr->tp4));
+	clear_ring_tp4(txr);
+
+	txr->clean_irq = i40e_clean_tx_irq;
+}
+
+/**
  * __i40e_tp4_disable - Disables TP4 for a queue pair
  * @vsi: vsi
  * @queue_pair: queue pair
@@ -11278,11 +11324,13 @@ static void i40e_tp4_disable_rx(struct i40e_ring *rxr)
 static void __i40e_tp4_disable(struct i40e_vsi *vsi, int queue_pair)
 {
 	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+	struct i40e_ring *txr = vsi->tx_rings[queue_pair];
 
 	if (!i40e_qp_uses_tp4(vsi, queue_pair))
 		return;
 
 	i40e_tp4_disable_rx(rxr);
+	i40e_tp4_disable_tx(txr);
 }
 
 /**
@@ -11368,6 +11416,36 @@ static int i40e_tp4_enable_rx(struct i40e_ring *rxr,
 }
 
 /**
+ * i40e_tp4_enable_tx - Enables TP4 Tx
+ * @txr: egress ring
+ * @params: tp4 params
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_tp4_enable_tx(struct i40e_ring *txr,
+			      struct tp4_netdev_parms *params)
+{
+	size_t elems = __roundup_pow_of_two(txr->count * 8);
+	struct tp4_packet_array *arr;
+
+	arr = tp4a_tx_new(params->tx_opaque, elems, txr->dev);
+	if (!arr)
+		return -ENOMEM;
+
+	txr->tp4.arr = arr;
+	txr->tp4.ev_handler = params->write_space;
+	txr->tp4.ev_opaque = params->write_space_opaque;
+	txr->tp4.err_handler = params->error_report;
+	txr->tp4.err_opaque = params->error_report_opaque;
+
+	txr->clean_irq = i40e_clean_tx_tp4_irq;
+
+	set_ring_tp4(txr);
+
+	return 0;
+}
+
+/**
  * __i40e_tp4_enable - Enables TP4
  * @vsi: vsi
  * @params: tp4 params
@@ -11378,12 +11456,19 @@ static int __i40e_tp4_enable(struct i40e_vsi *vsi,
 			     struct tp4_netdev_parms *params)
 {
 	struct i40e_ring *rxr = vsi->rx_rings[params->queue_pair];
+	struct i40e_ring *txr = vsi->tx_rings[params->queue_pair];
 	int err;
 
 	err = i40e_tp4_enable_rx(rxr, params);
 	if (err)
 		return err;
 
+	err = i40e_tp4_enable_tx(txr, params);
+	if (err) {
+		i40e_tp4_disable_rx(rxr);
+		return err;
+	}
+
 	return 0;
 }
 
@@ -11414,7 +11499,7 @@ static int i40e_tp4_enable(struct net_device *netdev,
 	if (i40e_qp_uses_tp4(vsi, params->queue_pair))
 		return -EBUSY;
 
-	if (!params->rx_opaque)
+	if (!params->rx_opaque || !params->tx_opaque)
 		return -EINVAL;
 
 	err =  i40e_qp_disable(vsi, params->queue_pair);
@@ -11503,6 +11588,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
 	.ndo_xdp		= i40e_xdp,
 	.ndo_tp4_zerocopy	= i40e_tp4_zerocopy,
+	.ndo_tp4_xmit		= i40e_tp4_xmit,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 54c5b7975066..712e10e14aec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -728,16 +728,50 @@ u32 i40e_get_tx_pending(struct i40e_ring *ring)
 #define WB_STRIDE 4
 
 /**
+ * i40e_update_tx_stats_and_arm_wb - Update Tx stats and possibly arm writeback
+ * @txr: egress ring
+ * @tx_bytes: numbers of bytes sent
+ * @tx_packets: number of packets sent
+ * @done: true if writeback should be armed
+ **/
+static inline void i40e_update_tx_stats_and_arm_wb(struct i40e_ring *txr,
+						   unsigned int tx_bytes,
+						   unsigned int tx_packets,
+						   bool done)
+{
+	u64_stats_update_begin(&txr->syncp);
+	txr->stats.bytes += tx_bytes;
+	txr->stats.packets += tx_packets;
+	u64_stats_update_end(&txr->syncp);
+	txr->q_vector->tx.total_bytes += tx_bytes;
+	txr->q_vector->tx.total_packets += tx_packets;
+
+	if (txr->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		/* check to see if there are < 4 descriptors
+		 * waiting to be written back, then kick the hardware to force
+		 * them to be written back in case we stay in NAPI.
+		 * In this mode on X722 we do not enable interrupts.
+		 */
+		unsigned int j = i40e_get_tx_pending(txr);
+
+		if (done &&
+		    ((j / WB_STRIDE) == 0) && j > 0 &&
+		    !test_bit(__I40E_VSI_DOWN, txr->vsi->state) &&
+		    (I40E_DESC_UNUSED(txr) != txr->count))
+			txr->arm_wb = true;
+	}
+}
+
+/**
  * i40e_clean_tx_irq - Reclaim resources after transmit completes
- * @vsi: the VSI we care about
  * @tx_ring: Tx ring to clean
  * @napi_budget: Used to determine if we are in netpoll
  *
  * Returns true if there's any budget left (e.g. the clean is finished)
  **/
-static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
-			      struct i40e_ring *tx_ring, int napi_budget)
+int i40e_clean_tx_irq(struct i40e_ring *tx_ring, int napi_budget)
 {
+	struct i40e_vsi *vsi = tx_ring->vsi;
 	u16 i = tx_ring->next_to_clean;
 	struct i40e_tx_buffer *tx_buf;
 	struct i40e_tx_desc *tx_head;
@@ -831,27 +865,9 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 
 	i += tx_ring->count;
 	tx_ring->next_to_clean = i;
-	u64_stats_update_begin(&tx_ring->syncp);
-	tx_ring->stats.bytes += total_bytes;
-	tx_ring->stats.packets += total_packets;
-	u64_stats_update_end(&tx_ring->syncp);
-	tx_ring->q_vector->tx.total_bytes += total_bytes;
-	tx_ring->q_vector->tx.total_packets += total_packets;
-
-	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
-		/* check to see if there are < 4 descriptors
-		 * waiting to be written back, then kick the hardware to force
-		 * them to be written back in case we stay in NAPI.
-		 * In this mode on X722 we do not enable Interrupt.
-		 */
-		unsigned int j = i40e_get_tx_pending(tx_ring);
 
-		if (budget &&
-		    ((j / WB_STRIDE) == 0) && (j > 0) &&
-		    !test_bit(__I40E_VSI_DOWN, vsi->state) &&
-		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
-			tx_ring->arm_wb = true;
-	}
+	i40e_update_tx_stats_and_arm_wb(tx_ring, total_bytes, total_packets,
+					budget);
 
 	if (ring_is_xdp(tx_ring))
 		return !!budget;
@@ -2454,10 +2470,11 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
 	i40e_for_each_ring(ring, q_vector->tx) {
-		if (!i40e_clean_tx_irq(vsi, ring, budget)) {
+		if (!ring->clean_irq(ring, budget)) {
 			clean_complete = false;
 			continue;
 		}
+
 		arm_wb |= ring->arm_wb;
 		ring->arm_wb = false;
 	}
@@ -3524,6 +3541,7 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
 	struct i40e_ring *tx_ring = vsi->tx_rings[skb->queue_mapping];
 
 	/* hardware can't handle really short frames, hardware padding works
@@ -3532,6 +3550,18 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (skb_put_padto(skb, I40E_MIN_TX_LEN))
 		return NETDEV_TX_OK;
 
+	if (unlikely(ring_uses_tp4(tx_ring) ||
+		     test_bit(__I40E_CONFIG_BUSY, pf->state))) {
+		/* XXX ndo_select_queue is being deprecated, so we
+		 * need another method for routing stack originated
+		 * packets away from the TP4 ring.
+		 *
+		 * For now, silently drop the skbuff.
+		 */
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	return i40e_xmit_frame_ring(skb, tx_ring);
 }
 
@@ -3582,3 +3612,191 @@ bool i40e_alloc_rx_buffers_tp4(struct i40e_ring *rxr, u16 cleaned_count)
 	return ret;
 }
 
+/**
+ * i40e_napi_is_scheduled - If napi is running, set the NAPIF_STATE_MISSED
+ * @n: napi context
+ *
+ * Returns true if NAPI is scheduled.
+ **/
+static bool i40e_napi_is_scheduled(struct napi_struct *n)
+{
+	unsigned long val, new;
+
+	do {
+		val = READ_ONCE(n->state);
+		if (val & NAPIF_STATE_DISABLE)
+			return true;
+
+		if (!(val & NAPIF_STATE_SCHED))
+			return false;
+
+		new = val | NAPIF_STATE_MISSED;
+	} while (cmpxchg(&n->state, val, new) != val);
+
+	return true;
+}
+
+/**
+ * i40e_tp4_xmit - ndo_tp4_xmit implementation
+ * @netdev: netdev
+ * @queue_pair: queue_pair
+ *
+ * Returns >=0 on success, <0 on failure.
+ **/
+int i40e_tp4_xmit(struct net_device *netdev, int queue_pair)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_ring *txr;
+
+	if (test_bit(__I40E_VSI_DOWN, vsi->state))
+		return -EAGAIN;
+
+	txr = vsi->tx_rings[queue_pair];
+	if (!ring_uses_tp4(txr))
+		return -EINVAL;
+
+	WRITE_ONCE(txr->tp4_xmit, 1);
+	if (!i40e_napi_is_scheduled(&txr->q_vector->napi))
+		i40e_force_wb(vsi, txr->q_vector);
+
+	return 0;
+}
+
+/**
+ * i40e_tp4_xmit_irq - Pull packets from userland, post them to the HW ring
+ * @txr: ingress ring
+ *
+ * Returns true if there no more work to be done.
+ **/
+static bool i40e_tp4_xmit_irq(struct i40e_ring *txr)
+{
+	struct i40e_tx_desc *txd;
+	struct tp4_frame_set pkt;
+	u32 size, td_cmd;
+	bool done = true;
+	int cleaned = 0;
+	dma_addr_t dma;
+	u16 unused;
+
+	if (READ_ONCE(txr->tp4_xmit)) {
+		tp4a_populate(txr->tp4.arr);
+		WRITE_ONCE(txr->tp4_xmit, 0);
+	}
+
+	for (;;) {
+		if (!tp4a_next_packet(txr->tp4.arr, &pkt)) {
+			if (cleaned == 0)
+				return true;
+			break;
+		}
+
+		unused = I40E_DESC_UNUSED(txr);
+		if (unused < tp4f_num_frames(&pkt)) {
+			tp4a_return_packet(txr->tp4.arr, &pkt);
+			done = false;
+			break;
+		}
+
+		do {
+			dma = tp4f_get_dma(&pkt);
+			size = tp4f_get_frame_len(&pkt);
+			dma_sync_single_for_device(txr->dev, dma, size,
+						   DMA_TO_DEVICE);
+
+			txd = I40E_TX_DESC(txr, txr->next_to_use);
+			txd->buffer_addr = cpu_to_le64(dma);
+
+			td_cmd = I40E_TX_DESC_CMD_ICRC | I40E_TX_DESC_CMD_RS;
+			if (tp4f_is_last_frame(&pkt))
+				td_cmd |= I40E_TX_DESC_CMD_EOP;
+
+			txd->cmd_type_offset_bsz = build_ctob(td_cmd, 0,
+							      size, 0);
+
+			cleaned++;
+			txr->next_to_use++;
+			if (txr->next_to_use == txr->count)
+				txr->next_to_use = 0;
+
+		} while (tp4f_next_frame(&pkt));
+	}
+
+	/* Force memory writes to complete before letting h/w know
+	 * there are new descriptors to fetch.
+	 */
+	wmb();
+	writel(txr->next_to_use, txr->tail);
+
+	return done;
+}
+
+/**
+ * i40e_inc_tx_next_to_clean - Bumps the next to clean
+ * @ring: egress ring
+ **/
+static inline void i40e_inc_tx_next_to_clean(struct i40e_ring *ring)
+{
+	u32 ntc;
+
+	ntc = ring->next_to_clean + 1;
+	ntc = (ntc < ring->count) ? ntc : 0;
+	ring->next_to_clean = ntc;
+
+	prefetch(I40E_TX_DESC(ring, ntc));
+}
+
+/**
+ * i40e_clean_tx_tp4_irq - Cleans the egress ring for completed packets
+ * @txr: egress ring
+ * @budget: napi budget
+ *
+ * Returns >0 if there's no more work to be done.
+ **/
+int i40e_clean_tx_tp4_irq(struct i40e_ring *txr, int budget)
+{
+	int total_tx_bytes = 0, total_tx_packets = 0;
+	struct i40e_tx_desc *txd, *txdh;
+	struct tp4_frame_set frame_set;
+	bool clean_done, xmit_done;
+
+	budget = txr->vsi->work_limit;
+
+	if (!tp4a_get_flushable_frame_set(txr->tp4.arr, &frame_set)) {
+		clean_done = true;
+		goto xmit;
+	}
+
+	txdh = I40E_TX_DESC(txr, i40e_get_head(txr));
+
+	while (total_tx_packets < budget) {
+		txd = I40E_TX_DESC(txr, txr->next_to_clean);
+		if (txdh == txd)
+			break;
+
+		txd->buffer_addr = 0;
+		txd->cmd_type_offset_bsz = 0;
+
+		total_tx_packets++;
+		total_tx_bytes += tp4f_get_frame_len(&frame_set);
+
+		i40e_inc_tx_next_to_clean(txr);
+
+		if (!tp4f_next_frame(&frame_set))
+			break;
+	}
+
+	WARN_ON(tp4a_flush_n(txr->tp4.arr, total_tx_packets));
+	clean_done = (total_tx_packets < budget);
+
+	txr->tp4.ev_handler(txr->tp4.ev_opaque);
+
+	i40e_update_tx_stats_and_arm_wb(txr,
+					total_tx_bytes,
+					total_tx_packets,
+					clean_done);
+xmit:
+	xmit_done = i40e_tp4_xmit_irq(txr);
+
+	return clean_done && xmit_done;
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 602dcd111938..b50215ddabd1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -430,6 +430,7 @@ struct i40e_ring {
 
 	struct rcu_head rcu;		/* to avoid race on free */
 	u16 next_to_alloc;
+	int tp4_xmit;
 	struct sk_buff *skb;		/* When i40e_clean_rx_ring_irq() must
 					 * return before it sees the EOP for
 					 * the current packet, we save that skb
@@ -520,9 +521,12 @@ static inline unsigned int i40e_rx_pg_order(struct i40e_ring *ring)
 
 bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
 int i40e_clean_rx_irq(struct i40e_ring *rxr, int budget);
+int i40e_clean_tx_irq(struct i40e_ring *tx_ring, int napi_budget);
 bool i40e_alloc_rx_buffers_tp4(struct i40e_ring *rxr, u16 cleaned_count);
 int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget);
+int i40e_clean_tx_tp4_irq(struct i40e_ring *txr, int napi_budget);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+int i40e_tp4_xmit(struct net_device *dev, int queue_pair);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
 int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring);
diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index 80bc20543599..beaf23f713eb 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -757,6 +757,28 @@ static inline void tp4f_set_error(struct tp4_frame_set *p, int errno)
 }
 
 /**
+ * tp4f_is_last_frame - Is this the last frame of the frame set
+ * @p: pointer to frame set
+ *
+ * Returns true if this is the last frame of the frame set, otherwise 0
+ **/
+static inline bool tp4f_is_last_frame(struct tp4_frame_set *p)
+{
+	return p->curr + 1 == p->end;
+}
+
+/**
+ * tp4f_num_frames - Number of frames in a frame set
+ * @p: pointer to frame set
+ *
+ * Returns the number of frames this frame set consists of
+ **/
+static inline u32 tp4f_num_frames(struct tp4_frame_set *p)
+{
+	return p->end - p->start;
+}
+
+/**
  * tp4f_get_data - Gets a pointer to the frame the frame set is on
  * @p: pointer to the frame set
  *
@@ -1165,4 +1187,16 @@ static inline bool tp4a_next_frame_populate(struct tp4_packet_array *a,
 	return more_frames;
 }
 
+/**
+ * tp4a_return_packet - Return packet to the packet array
+ *
+ * @a: pointer to packet array
+ * @p: pointer to the packet to return
+ **/
+static inline void tp4a_return_packet(struct tp4_packet_array *a,
+				      struct tp4_frame_set *p)
+{
+	a->curr = p->start;
+}
+
 #endif /* _LINUX_TPACKET4_H */
-- 
2.11.0
