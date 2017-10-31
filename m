From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 08/14] i40e: AF_PACKET V4 ndo_tp4_zerocopy Rx support
Date: Tue, 31 Oct 2017 13:41:39 +0100
Message-ID: <20171031124145.9667-9-bjorn.topel@gmail.com>
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
Received: from mga07.intel.com ([134.134.136.100]:38033 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753141AbdJaMmw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:52 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This commit adds an implementation for ndo_tp4_zerocopy.

When an AF_PACKET V4 socket enables zerocopy, it will trigger the
ndo_tp4_zerocopy implementation. The selected queue pair is disabled,
TP4 mode is enabled and the queue pair is re-enabled.

Instead of allocating buffers from the page allocator, buffers from
the userland TP4 socket are used. The i40e_alloc_rx_buffers_tp4
function does the allocation.

Pulling buffers from the hardware descriptor queue, validation and
passing descriptor to userland is done in i40e_clean_rx_tp4_irq.

Common code for updating stats in i40e_clean_rx_irq and
i40e_clean_rx_tp4_irq has been refactored out into a function.

As Rx allocation, descriptor configuration and hardware descriptor
ring clean up now has multiple implementations, a couple of new
members has been introduced into the struct i40e_ring. Two function
pointers, one for Rx buffer allocation, and one for Rx clean up. The
i40e_ring also contains some Rx descriptor configuration parameters
(rx_buf_len and rx_max_frame), since each Rx ring potentionally can
have different configuration. This also opens up for future 16B
descriptor usage for TP4 rings.

The TP4 implementation does not use the struct i40e_rx_buffer to track
hardware descriptor metadata, but instead uses the packet array
directly from tpacket4.h.

All TP4 state is kept in the struct i40e_ring. However, to support
that a zerocopy context can survive a soft reset, e.g. when changing
the number of queue pairs via ethtool, functionality for storing the
TP4 context in the vsi is required. When a soft reset is done, we
store the TP4 state in the vsi. The vsi rings are tore down, and when
setting the rings up again, the TP4 state from vsi is restored.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   3 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   9 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 751 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 196 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |  34 ++
 include/linux/tpacket4.h                       |  85 +++
 6 files changed, 1033 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index eb017763646d..56dff7d314c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -744,6 +744,9 @@ struct i40e_vsi {
 
 	/* VSI specific handlers */
 	irqreturn_t (*irq_handler)(int irq, void *data);
+
+	struct i40e_tp4_ctx **tp4_ctxs; /* Rx context */
+	u16 num_tp4_ctxs;
 } ____cacheline_internodealigned_in_smp;
 
 struct i40e_netdev_priv {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9eb618799a30..da64776108c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1515,6 +1515,15 @@ static int i40e_set_ringparam(struct net_device *netdev,
 		goto done;
 	}
 
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		if (ring_uses_tp4(vsi->rx_rings[i])) {
+			netdev_warn(netdev,
+				    "FIXME TP4 zerocopy does not support changing descriptors. Take down the interface first\n");
+			err = -ENOTSUPP;
+			goto done;
+		}
+	}
+
 	/* We can't just free everything and then setup again,
 	 * because the ISRs in MSI-X mode get passed pointers
 	 * to the Tx and Rx ring structs.
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54ff34faca37..5456ef6cce1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3187,8 +3187,6 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	/* clear the context structure first */
 	memset(&rx_ctx, 0, sizeof(rx_ctx));
 
-	ring->rx_buf_len = vsi->rx_buf_len;
-
 	rx_ctx.dbuff = DIV_ROUND_UP(ring->rx_buf_len,
 				    BIT_ULL(I40E_RXQ_CTX_DBUFF_SHIFT));
 
@@ -3203,7 +3201,8 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	 */
 	rx_ctx.hsplit_0 = 0;
 
-	rx_ctx.rxmax = min_t(u16, vsi->max_frame, chain_len * ring->rx_buf_len);
+	rx_ctx.rxmax = min_t(u16, ring->rx_max_frame,
+			     chain_len * ring->rx_buf_len);
 	if (hw->revision_id == 0)
 		rx_ctx.lrxqthresh = 0;
 	else
@@ -3243,7 +3242,7 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	ring->tail = hw->hw_addr + I40E_QRX_TAIL(pf_q);
 	writel(0, ring->tail);
 
-	i40e_alloc_rx_buffers(ring, I40E_DESC_UNUSED(ring));
+	ring->rx_alloc_fn(ring, I40E_DESC_UNUSED(ring));
 
 	return 0;
 }
@@ -3282,21 +3281,6 @@ static int i40e_vsi_configure_rx(struct i40e_vsi *vsi)
 	int err = 0;
 	u16 i;
 
-	if (!vsi->netdev || (vsi->back->flags & I40E_FLAG_LEGACY_RX)) {
-		vsi->max_frame = I40E_MAX_RXBUFFER;
-		vsi->rx_buf_len = I40E_RXBUFFER_2048;
-#if (PAGE_SIZE < 8192)
-	} else if (!I40E_2K_TOO_SMALL_WITH_PADDING &&
-		   (vsi->netdev->mtu <= ETH_DATA_LEN)) {
-		vsi->max_frame = I40E_RXBUFFER_1536 - NET_IP_ALIGN;
-		vsi->rx_buf_len = I40E_RXBUFFER_1536 - NET_IP_ALIGN;
-#endif
-	} else {
-		vsi->max_frame = I40E_MAX_RXBUFFER;
-		vsi->rx_buf_len = (PAGE_SIZE < 8192) ? I40E_RXBUFFER_3072 :
-						       I40E_RXBUFFER_2048;
-	}
-
 	/* set up individual rings */
 	for (i = 0; i < vsi->num_queue_pairs && !err; i++)
 		err = i40e_configure_rx_ring(vsi->rx_rings[i]);
@@ -4778,6 +4762,193 @@ static void i40e_pf_unquiesce_all_vsi(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_vsi_free_tp4_ctxs - Free TP4 contexts
+ * @vsi: vsi
+ */
+static void i40e_vsi_free_tp4_ctxs(struct i40e_vsi *vsi)
+{
+	int i;
+
+	if (!vsi->tp4_ctxs)
+		return;
+
+	for (i = 0; i < vsi->num_tp4_ctxs; i++)
+		kfree(vsi->tp4_ctxs[i]);
+
+	kfree(vsi->tp4_ctxs);
+	vsi->tp4_ctxs = NULL;
+}
+
+/**
+ * i40e_qp_error_report_tp4 - Trigger the TP4 error handler
+ * @vsi: vsi
+ * @queue_pair: queue_pair to report
+ * @errno: the error code
+ **/
+static void i40e_qp_error_report_tp4(struct i40e_vsi *vsi, int queue_pair,
+				     int errno)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+
+	rxr->tp4.err_handler(rxr->tp4.err_opaque, errno);
+}
+
+/**
+ * i40e_qp_uses_tp4 - Check for TP4 usage
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ *
+ * Returns true if TP4 is enabled, else false.
+ **/
+static bool i40e_qp_uses_tp4(struct i40e_vsi *vsi, int queue_pair)
+{
+	return ring_uses_tp4(vsi->rx_rings[queue_pair]);
+}
+
+/**
+ * i40e_vsi_save_tp4_ctxs - Save TP4 context to a vsi
+ * @vsi: vsi
+ */
+static void i40e_vsi_save_tp4_ctxs(struct i40e_vsi *vsi)
+{
+	int i = 0;
+
+	if (test_bit(__I40E_VSI_DOWN, vsi->state))
+		return;
+
+	kfree(vsi->tp4_ctxs); /* Let's be cautious */
+
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		if (i40e_qp_uses_tp4(vsi, i)) {
+			if (!vsi->tp4_ctxs) {
+				vsi->tp4_ctxs = kcalloc(vsi->num_queue_pairs,
+							sizeof(*vsi->tp4_ctxs),
+							GFP_KERNEL);
+				if (!vsi->tp4_ctxs)
+					goto out;
+
+				vsi->num_tp4_ctxs = vsi->num_queue_pairs;
+			}
+
+			vsi->tp4_ctxs[i] = kzalloc(sizeof(struct i40e_tp4_ctx),
+						   GFP_KERNEL);
+			if (!vsi->tp4_ctxs[i])
+				goto out_elmn;
+
+			*vsi->tp4_ctxs[i] = vsi->rx_rings[i]->tp4;
+		}
+	}
+
+	return;
+
+out_elmn:
+	i40e_vsi_free_tp4_ctxs(vsi);
+out:
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		if (i40e_qp_uses_tp4(vsi, i))
+			i40e_qp_error_report_tp4(vsi, i, ENOMEM);
+	}
+}
+
+/**
+ * i40e_tp4_set_rx_handler - Sets the Rx clean_irq function for TP4
+ * @rxr: ingress ring
+ **/
+static void i40e_tp4_set_rx_handler(struct i40e_ring *rxr)
+{
+	unsigned int buf_len;
+
+	buf_len = min_t(unsigned int,
+			tp4a_max_data_size(rxr->tp4.arr),
+			I40E_MAX_RXBUFFER) &
+		  ~(BIT(I40E_RXQ_CTX_DBUFF_SHIFT) - 1);
+
+	/* Currently we don't allow packets spanning multiple
+	 * buffers.
+	 */
+	rxr->rx_buf_len = buf_len;
+	rxr->rx_max_frame = buf_len;
+	rxr->rx_alloc_fn = i40e_alloc_rx_buffers_tp4;
+	rxr->clean_irq = i40e_clean_rx_tp4_irq;
+}
+
+/**
+ * i40e_tp4_flush_all - Flush all outstanding descriptors to userland
+ * @a: pointer to the packet array
+ **/
+static void i40e_tp4_flush_all(struct tp4_packet_array *a)
+{
+	struct tp4_frame_set f;
+
+	/* Flush all outstanding requests. */
+	if (tp4a_get_flushable_frame_set(a, &f)) {
+		do {
+			tp4f_set_frame(&f, 0, 0, true);
+		} while (tp4f_next_frame(&f));
+	}
+
+	WARN_ON(tp4a_flush(a));
+}
+
+/**
+ * i40e_tp4_restore - Restores to a previous TP4 state
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ * @rx_ctx: the Rx TP4 context
+ **/
+static void i40e_tp4_restore(struct i40e_vsi *vsi, int queue_pair,
+			     struct i40e_tp4_ctx *rx_ctx)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+
+	rxr->tp4 = *rx_ctx;
+	i40e_tp4_flush_all(rxr->tp4.arr);
+	i40e_tp4_set_rx_handler(rxr);
+
+	set_ring_tp4(rxr);
+}
+
+/**
+ * i40e_vsi_restore_tp4_ctxs - Restores all contexts
+ * @vsi: vsi
+ **/
+static void i40e_vsi_restore_tp4_ctxs(struct i40e_vsi *vsi)
+{
+	u16 i, elms;
+
+	if (!vsi->tp4_ctxs)
+		return;
+
+	elms = min(vsi->num_queue_pairs, vsi->num_tp4_ctxs);
+	for (i = 0; i < elms; i++) {
+		if (!vsi->tp4_ctxs[i])
+			continue;
+		i40e_tp4_restore(vsi, i, vsi->tp4_ctxs[i]);
+	}
+
+	i40e_vsi_free_tp4_ctxs(vsi);
+}
+
+/**
+ * i40e_pf_save_tp4_ctx_all_vsi - Saves all TP4 contexts
+ ' @pf: pf
+ */
+static void i40e_pf_save_tp4_ctx_all_vsi(struct i40e_pf *pf)
+{
+	struct i40e_vsi *vsi;
+	int v;
+
+	/* The rings are about to be removed at reset; Saving the TP4
+	 * context in the vsi temporarily
+	 */
+	for (v = 0; v < pf->num_alloc_vsi; v++) {
+		vsi = pf->vsi[v];
+		if (vsi && vsi->netdev)
+			i40e_vsi_save_tp4_ctxs(vsi);
+	}
+}
+
+/**
  * i40e_vsi_wait_queues_disabled - Wait for VSI's queues to be disabled
  * @vsi: the VSI being configured
  *
@@ -6511,6 +6682,8 @@ int i40e_up(struct i40e_vsi *vsi)
 	return err;
 }
 
+static void __i40e_tp4_disable(struct i40e_vsi *vsi, int queue_pair);
+
 /**
  * i40e_down - Shutdown the connection processing
  * @vsi: the VSI being stopped
@@ -6531,6 +6704,7 @@ void i40e_down(struct i40e_vsi *vsi)
 	i40e_napi_disable_all(vsi);
 
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		__i40e_tp4_disable(vsi, i);
 		i40e_clean_tx_ring(vsi->tx_rings[i]);
 		if (i40e_enabled_xdp_vsi(vsi))
 			i40e_clean_tx_ring(vsi->xdp_rings[i]);
@@ -8224,6 +8398,7 @@ static void i40e_prep_for_reset(struct i40e_pf *pf, bool lock_acquired)
 	/* pf_quiesce_all_vsi modifies netdev structures -rtnl_lock needed */
 	if (!lock_acquired)
 		rtnl_lock();
+	i40e_pf_save_tp4_ctx_all_vsi(pf);
 	i40e_pf_quiesce_all_vsi(pf);
 	if (!lock_acquired)
 		rtnl_unlock();
@@ -9082,7 +9257,7 @@ static int i40e_vsi_clear(struct i40e_vsi *vsi)
 
 	i40e_vsi_free_arrays(vsi, true);
 	i40e_clear_rss_config_user(vsi);
-
+	i40e_vsi_free_tp4_ctxs(vsi);
 	pf->vsi[vsi->idx] = NULL;
 	if (vsi->idx < pf->next_vsi)
 		pf->next_vsi = vsi->idx;
@@ -9115,6 +9290,28 @@ static void i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_vsi_setup_rx_size - Setup Rx buffer sizes
+ * @vsi: vsi
+ **/
+static void i40e_vsi_setup_rx_size(struct i40e_vsi *vsi)
+{
+	if (!vsi->netdev || (vsi->back->flags & I40E_FLAG_LEGACY_RX)) {
+		vsi->max_frame = I40E_MAX_RXBUFFER;
+		vsi->rx_buf_len = I40E_RXBUFFER_2048;
+#if (PAGE_SIZE < 8192)
+	} else if (!I40E_2K_TOO_SMALL_WITH_PADDING &&
+		   (vsi->netdev->mtu <= ETH_DATA_LEN)) {
+		vsi->max_frame = I40E_RXBUFFER_1536 - NET_IP_ALIGN;
+		vsi->rx_buf_len = I40E_RXBUFFER_1536 - NET_IP_ALIGN;
+#endif
+	} else {
+		vsi->max_frame = I40E_MAX_RXBUFFER;
+		vsi->rx_buf_len = (PAGE_SIZE < 8192) ? I40E_RXBUFFER_3072 :
+				  I40E_RXBUFFER_2048;
+	}
+}
+
+/**
  * i40e_alloc_rings - Allocates the Rx and Tx rings for the provided VSI
  * @vsi: the VSI being configured
  **/
@@ -9124,6 +9321,8 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_ring *ring;
 
+	i40e_vsi_setup_rx_size(vsi);
+
 	/* Set basic values in the rings to be used later during open() */
 	for (i = 0; i < vsi->alloc_queue_pairs; i++) {
 		/* allocate space for both Tx and Rx in one shot */
@@ -9171,6 +9370,10 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		ring->netdev = vsi->netdev;
 		ring->dev = &pf->pdev->dev;
 		ring->count = vsi->num_desc;
+		ring->rx_buf_len = vsi->rx_buf_len;
+		ring->rx_max_frame = vsi->max_frame;
+		ring->rx_alloc_fn = i40e_alloc_rx_buffers;
+		ring->clean_irq = i40e_clean_rx_irq;
 		ring->size = 0;
 		ring->dcb_tc = 0;
 		ring->rx_itr_setting = pf->rx_itr_default;
@@ -9909,7 +10112,7 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 {
 	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
-	int new_rss_size;
+	int i, new_rss_size;
 
 	if (!(pf->flags & I40E_FLAG_RSS_ENABLED))
 		return 0;
@@ -9919,6 +10122,11 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 	if (queue_count != vsi->num_queue_pairs) {
 		u16 qcount;
 
+		for (i = queue_count; i < vsi->num_queue_pairs; i++) {
+			if (i40e_qp_uses_tp4(vsi, i))
+				i40e_qp_error_report_tp4(vsi, i, ENOENT);
+		}
+
 		vsi->req_queue_pairs = queue_count;
 		i40e_prep_for_reset(pf, true);
 
@@ -10762,6 +10970,505 @@ static int i40e_xdp(struct net_device *dev,
 	}
 }
 
+/**
+ * i40e_enter_busy_conf - Enters busy config state
+ * @vsi: vsi
+ *
+ * Returns 0 on success, <0 for failure.
+ **/
+static int i40e_enter_busy_conf(struct i40e_vsi *vsi)
+{
+	struct i40e_pf *pf = vsi->back;
+	int timeout = 50;
+
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, pf->state)) {
+		timeout--;
+		if (!timeout)
+			return -EBUSY;
+		usleep_range(1000, 2000);
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_exit_busy_conf - Exits busy config state
+ * @vsi: vsi
+ **/
+static void i40e_exit_busy_conf(struct i40e_vsi *vsi)
+{
+	struct i40e_pf *pf = vsi->back;
+
+	clear_bit(__I40E_CONFIG_BUSY, pf->state);
+}
+
+/**
+ * i40e_qp_reset_stats - Resets all statistics for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ **/
+static void i40e_qp_reset_stats(struct i40e_vsi *vsi, int queue_pair)
+{
+	memset(&vsi->rx_rings[queue_pair]->rx_stats, 0,
+	       sizeof(vsi->rx_rings[queue_pair]->rx_stats));
+	memset(&vsi->tx_rings[queue_pair]->stats, 0,
+	       sizeof(vsi->tx_rings[queue_pair]->stats));
+	if (i40e_enabled_xdp_vsi(vsi)) {
+		memset(&vsi->xdp_rings[queue_pair]->stats, 0,
+		       sizeof(vsi->xdp_rings[queue_pair]->stats));
+	}
+}
+
+/**
+ * i40e_qp_clean_rings - Cleans all the rings of a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ **/
+static void i40e_qp_clean_rings(struct i40e_vsi *vsi, int queue_pair)
+{
+	i40e_clean_tx_ring(vsi->tx_rings[queue_pair]);
+	if (i40e_enabled_xdp_vsi(vsi))
+		i40e_clean_tx_ring(vsi->xdp_rings[queue_pair]);
+	i40e_clean_rx_ring(vsi->rx_rings[queue_pair]);
+}
+
+/**
+ * i40e_qp_control_napi - Enables/disables NAPI for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ * @enable: true for enable, false for disable
+ **/
+static void i40e_qp_control_napi(struct i40e_vsi *vsi, int queue_pair,
+				 bool enable)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+	struct i40e_q_vector *q_vector = rxr->q_vector;
+
+	if (!vsi->netdev)
+		return;
+
+	/* All rings in a qp belong to the same qvector. */
+	if (q_vector->rx.ring || q_vector->tx.ring) {
+		if (enable)
+			napi_enable(&q_vector->napi);
+		else
+			napi_disable(&q_vector->napi);
+	}
+}
+
+/**
+ * i40e_qp_control_rings - Enables/disables all rings for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ * @enable: true for enable, false for disable
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_qp_control_rings(struct i40e_vsi *vsi, int queue_pair,
+				 bool enable)
+{
+	struct i40e_pf *pf = vsi->back;
+	int pf_q, ret = 0;
+
+	pf_q = vsi->base_queue + queue_pair;
+	ret = i40e_control_wait_tx_q(vsi->seid, pf, pf_q,
+				     false /*is xdp*/, enable);
+	if (ret) {
+		dev_info(&pf->pdev->dev,
+			 "VSI seid %d Tx ring %d %sable timeout\n",
+			 vsi->seid, pf_q, (enable ? "en" : "dis"));
+		return ret;
+	}
+
+	i40e_control_rx_q(pf, pf_q, enable);
+	ret = i40e_pf_rxq_wait(pf, pf_q, enable);
+	if (ret) {
+		dev_info(&pf->pdev->dev,
+			 "VSI seid %d Rx ring %d %sable timeout\n",
+			 vsi->seid, pf_q, (enable ? "en" : "dis"));
+		return ret;
+	}
+
+	/* Due to HW errata, on Rx disable only, the register can
+	 * indicate done before it really is. Needs 50ms to be sure
+	 */
+	if (!enable)
+		mdelay(50);
+
+	if (!i40e_enabled_xdp_vsi(vsi))
+		return ret;
+
+	ret = i40e_control_wait_tx_q(vsi->seid, pf,
+				     pf_q + vsi->alloc_queue_pairs,
+				     true /*is xdp*/, enable);
+	if (ret) {
+		dev_info(&pf->pdev->dev,
+			 "VSI seid %d XDP Tx ring %d %sable timeout\n",
+			 vsi->seid, pf_q, (enable ? "en" : "dis"));
+	}
+
+	return ret;
+}
+
+/**
+ * i40e_qp_enable_irq - Enables interrupts for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue_pair
+ **/
+static void i40e_qp_enable_irq(struct i40e_vsi *vsi, int queue_pair)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+
+	/* All rings in a qp belong to the same qvector. */
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
+		i40e_irq_dynamic_enable(vsi, rxr->q_vector->v_idx);
+	else
+		i40e_irq_dynamic_enable_icr0(pf);
+
+	i40e_flush(hw);
+}
+
+/**
+ * i40e_qp_disable_irq - Disables interrupts for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue_pair
+ **/
+static void i40e_qp_disable_irq(struct i40e_vsi *vsi, int queue_pair)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+
+	/* For simplicity, instead of removing the qp interrupt causes
+	 * from the interrupt linked list, we simply disable the interrupt, and
+	 * leave the list intact.
+	 *
+	 * All rings in a qp belong to the same qvector.
+	 */
+
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
+		u32 intpf = vsi->base_vector + rxr->q_vector->v_idx;
+
+		wr32(hw, I40E_PFINT_DYN_CTLN(intpf - 1), 0);
+		i40e_flush(hw);
+		synchronize_irq(pf->msix_entries[intpf].vector);
+	} else {
+		/* Legacy and MSI mode - this stops all interrupt handling */
+		wr32(hw, I40E_PFINT_ICR0_ENA, 0);
+		wr32(hw, I40E_PFINT_DYN_CTL0, 0);
+		i40e_flush(hw);
+		synchronize_irq(pf->pdev->irq);
+	}
+}
+
+/**
+ * i40e_qp_disable - Disables a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_qp_disable(struct i40e_vsi *vsi, int queue_pair)
+{
+	int err;
+
+	err = i40e_enter_busy_conf(vsi);
+	if (err)
+		return err;
+
+	i40e_qp_disable_irq(vsi, queue_pair);
+	err = i40e_qp_control_rings(vsi, queue_pair, false /* disable */);
+	i40e_qp_control_napi(vsi, queue_pair, false /* disable */);
+	i40e_qp_clean_rings(vsi, queue_pair);
+	i40e_qp_reset_stats(vsi, queue_pair);
+
+	return err;
+}
+
+/**
+ * i40e_qp_enable - Enables a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_qp_enable(struct i40e_vsi *vsi, int queue_pair)
+{
+	int err;
+
+	err = i40e_configure_tx_ring(vsi->tx_rings[queue_pair]);
+	if (err)
+		return err;
+
+	if (i40e_enabled_xdp_vsi(vsi)) {
+		err = i40e_configure_tx_ring(vsi->xdp_rings[queue_pair]);
+		if (err)
+			return err;
+	}
+
+	err = i40e_configure_rx_ring(vsi->rx_rings[queue_pair]);
+	if (err)
+		return err;
+
+	err = i40e_qp_control_rings(vsi, queue_pair, true /* enable */);
+	i40e_qp_control_napi(vsi, queue_pair, true /* enable */);
+	i40e_qp_enable_irq(vsi, queue_pair);
+
+	i40e_exit_busy_conf(vsi);
+
+	return err;
+}
+
+/**
+ * i40e_qp_kick_napi - Schedules a NAPI run
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ **/
+static void i40e_qp_kick_napi(struct i40e_vsi *vsi, int queue_pair)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+
+	napi_schedule(&rxr->q_vector->napi);
+}
+
+/**
+ * i40e_vsi_get_tp4_rx_ctx - Retrieves the Rx TP4 context, if any.
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ *
+ * Returns NULL if there's no context available.
+ **/
+static struct i40e_tp4_ctx *i40e_vsi_get_tp4_rx_ctx(struct i40e_vsi *vsi,
+						    int queue_pair)
+{
+	if (!vsi->tp4_ctxs)
+		return NULL;
+
+	return vsi->tp4_ctxs[queue_pair];
+}
+
+/**
+ * i40e_tp4_disable_rx - Disables TP4 Rx mode
+ * @rxr: ingress ring
+ **/
+static void i40e_tp4_disable_rx(struct i40e_ring *rxr)
+{
+	/* Don't free, if the context is saved! */
+	if (i40e_vsi_get_tp4_rx_ctx(rxr->vsi, rxr->queue_index))
+		rxr->tp4.arr = NULL;
+	else
+		tp4a_free(rxr->tp4.arr);
+
+	memset(&rxr->tp4, 0, sizeof(rxr->tp4));
+	clear_ring_tp4(rxr);
+
+	rxr->rx_buf_len = rxr->vsi->rx_buf_len;
+	rxr->rx_max_frame = rxr->vsi->max_frame;
+	rxr->rx_alloc_fn = i40e_alloc_rx_buffers;
+	rxr->clean_irq = i40e_clean_rx_irq;
+}
+
+/**
+ * __i40e_tp4_disable - Disables TP4 for a queue pair
+ * @vsi: vsi
+ * @queue_pair: queue pair
+ **/
+static void __i40e_tp4_disable(struct i40e_vsi *vsi, int queue_pair)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[queue_pair];
+
+	if (!i40e_qp_uses_tp4(vsi, queue_pair))
+		return;
+
+	i40e_tp4_disable_rx(rxr);
+}
+
+/**
+ * i40e_tp4_disable - Disables zerocopy
+ * @netdev: netdevice
+ * @params: tp4 params
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_tp4_disable(struct net_device *netdev,
+			    struct tp4_netdev_parms *params)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	int err;
+
+	if (params->queue_pair < 0 ||
+	    params->queue_pair >= vsi->num_queue_pairs)
+		return -EINVAL;
+
+	if (!i40e_qp_uses_tp4(vsi, params->queue_pair))
+		return 0;
+
+	netdev_info(
+		netdev,
+		"disabling TP4 zerocopy qp=%d, failed Rx allocations: %llu\n",
+		params->queue_pair,
+		vsi->rx_rings[params->queue_pair]->rx_stats.alloc_page_failed);
+
+	err =  i40e_qp_disable(vsi, params->queue_pair);
+	if (err) {
+		netdev_warn(
+			netdev,
+			"could not disable qp=%d err=%d, failed disabling TP4 zerocopy\n",
+			params->queue_pair,
+			err);
+		return err;
+	}
+
+	__i40e_tp4_disable(vsi, params->queue_pair);
+
+	err =  i40e_qp_enable(vsi, params->queue_pair);
+	if (err) {
+		netdev_warn(
+			netdev,
+			"could not re-enable qp=%d err=%d, failed disabling TP4 zerocopy\n",
+			params->queue_pair,
+			err);
+		return err;
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_tp4_enable_rx - Enables TP4 Tx
+ * @rxr: ingress ring
+ * @params: tp4 params
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_tp4_enable_rx(struct i40e_ring *rxr,
+			      struct tp4_netdev_parms *params)
+{
+	size_t elems = __roundup_pow_of_two(rxr->count * 8);
+	struct tp4_packet_array *arr;
+
+	arr = tp4a_rx_new(params->rx_opaque, elems, rxr->dev);
+	if (!arr)
+		return -ENOMEM;
+
+	rxr->tp4.arr = arr;
+	rxr->tp4.ev_handler = params->data_ready;
+	rxr->tp4.ev_opaque = params->data_ready_opaque;
+	rxr->tp4.err_handler = params->error_report;
+	rxr->tp4.err_opaque = params->error_report_opaque;
+
+	i40e_tp4_set_rx_handler(rxr);
+
+	set_ring_tp4(rxr);
+
+	return 0;
+}
+
+/**
+ * __i40e_tp4_enable - Enables TP4
+ * @vsi: vsi
+ * @params: tp4 params
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int __i40e_tp4_enable(struct i40e_vsi *vsi,
+			     struct tp4_netdev_parms *params)
+{
+	struct i40e_ring *rxr = vsi->rx_rings[params->queue_pair];
+	int err;
+
+	err = i40e_tp4_enable_rx(rxr, params);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+/**
+ * i40e_tp4_enable - Enables zerocopy
+ * @netdev: netdevice
+ * @params: tp4 params
+ *
+ * Returns 0 on success, <0 on failure.
+ **/
+static int i40e_tp4_enable(struct net_device *netdev,
+			   struct tp4_netdev_parms *params)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	int err;
+
+	if (vsi->type != I40E_VSI_MAIN)
+		return -EINVAL;
+
+	if (params->queue_pair < 0 ||
+	    params->queue_pair >= vsi->num_queue_pairs)
+		return -EINVAL;
+
+	if (!netif_running(netdev))
+		return -ENETDOWN;
+
+	if (i40e_qp_uses_tp4(vsi, params->queue_pair))
+		return -EBUSY;
+
+	if (!params->rx_opaque)
+		return -EINVAL;
+
+	err =  i40e_qp_disable(vsi, params->queue_pair);
+	if (err) {
+		netdev_warn(netdev, "could not disable qp=%d err=%d, failed enabling TP4 zerocopy\n",
+			    params->queue_pair, err);
+		return err;
+	}
+
+	err =  __i40e_tp4_enable(vsi, params);
+	if (err) {
+		netdev_warn(netdev, "__i40e_tp4_enable qp=%d err=%d, failed enabling TP4 zerocopy\n",
+			    params->queue_pair, err);
+		return err;
+	}
+
+	err = i40e_qp_enable(vsi, params->queue_pair);
+	if (err) {
+		netdev_warn(netdev, "could not re-enable qp=%d err=%d, failed enabling TP4 zerocopy\n",
+			    params->queue_pair, err);
+		return err;
+	}
+
+	/* Kick NAPI to make sure that alloction from userland
+	 * acctually worked.
+	 */
+	i40e_qp_kick_napi(vsi, params->queue_pair);
+
+	netdev_info(netdev, "enabled TP4 zerocopy\n");
+	return 0;
+}
+
+/**
+ * i40e_tp4_zerocopy - enables/disables zerocopy
+ * @netdev: netdevice
+ * @params: tp4 params
+ *
+ * Returns zero on success
+ **/
+static int i40e_tp4_zerocopy(struct net_device *netdev,
+			     struct tp4_netdev_parms *params)
+{
+	switch (params->command) {
+	case TP4_ENABLE:
+		return i40e_tp4_enable(netdev, params);
+
+	case TP4_DISABLE:
+		return i40e_tp4_disable(netdev, params);
+
+	default:
+		return -ENOTSUPP;
+	}
+}
+
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -10795,6 +11502,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
 	.ndo_xdp		= i40e_xdp,
+	.ndo_tp4_zerocopy	= i40e_tp4_zerocopy,
 };
 
 /**
@@ -11439,6 +12147,7 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 	ret = i40e_alloc_rings(vsi);
 	if (ret)
 		goto err_rings;
+	i40e_vsi_restore_tp4_ctxs(vsi);
 
 	/* map all of the rings to the q_vectors */
 	i40e_vsi_map_rings_to_vectors(vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c5cd233c8fee..54c5b7975066 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1083,6 +1083,21 @@ static inline bool i40e_rx_is_programming_status(u64 qw)
 }
 
 /**
+ * i40e_inc_rx_next_to_clean - Bumps the next to clean
+ * @ring: ingress ring
+ */
+static inline void i40e_inc_rx_next_to_clean(struct i40e_ring *ring)
+{
+	u32 ntc;
+
+	ntc = ring->next_to_clean + 1;
+	ntc = (ntc < ring->count) ? ntc : 0;
+	ring->next_to_clean = ntc;
+
+	prefetch(I40E_RX_DESC(ring, ntc));
+}
+
+/**
  * i40e_clean_programming_status - clean the programming status descriptor
  * @rx_ring: the rx ring that has this descriptor
  * @rx_desc: the rx descriptor written back by HW
@@ -1098,15 +1113,10 @@ static void i40e_clean_programming_status(struct i40e_ring *rx_ring,
 					  u64 qw)
 {
 	struct i40e_rx_buffer *rx_buffer;
-	u32 ntc = rx_ring->next_to_clean;
 	u8 id;
 
-	/* fetch, update, and store next to clean */
-	rx_buffer = &rx_ring->rx_bi[ntc++];
-	ntc = (ntc < rx_ring->count) ? ntc : 0;
-	rx_ring->next_to_clean = ntc;
-
-	prefetch(I40E_RX_DESC(rx_ring, ntc));
+	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
+	i40e_inc_rx_next_to_clean(rx_ring);
 
 	/* place unused page back on the ring */
 	i40e_reuse_rx_page(rx_ring, rx_buffer);
@@ -1958,6 +1968,18 @@ static void i40e_put_rx_buffer(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_is_rx_desc_eof - Checks if Rx descriptor is end of frame
+ * @rx_desc: rx_desc
+ *
+ * Returns true if EOF, false otherwise.
+ **/
+static inline bool i40e_is_rx_desc_eof(union i40e_rx_desc *rx_desc)
+{
+#define I40E_RXD_EOF BIT(I40E_RX_DESC_STATUS_EOF_SHIFT)
+	return i40e_test_staterr(rx_desc, I40E_RXD_EOF);
+}
+
+/**
  * i40e_is_non_eop - process handling of non-EOP buffers
  * @rx_ring: Rx ring being processed
  * @rx_desc: Rx descriptor for current buffer
@@ -1972,17 +1994,10 @@ static bool i40e_is_non_eop(struct i40e_ring *rx_ring,
 			    union i40e_rx_desc *rx_desc,
 			    struct sk_buff *skb)
 {
-	u32 ntc = rx_ring->next_to_clean + 1;
-
-	/* fetch, update, and store next to clean */
-	ntc = (ntc < rx_ring->count) ? ntc : 0;
-	rx_ring->next_to_clean = ntc;
-
-	prefetch(I40E_RX_DESC(rx_ring, ntc));
+	i40e_inc_rx_next_to_clean(rx_ring);
 
 	/* if we are the last buffer then there is nothing else to do */
-#define I40E_RXD_EOF BIT(I40E_RX_DESC_STATUS_EOF_SHIFT)
-	if (likely(i40e_test_staterr(rx_desc, I40E_RXD_EOF)))
+	if (likely(i40e_is_rx_desc_eof(rx_desc)))
 		return false;
 
 	rx_ring->rx_stats.non_eop_descs++;
@@ -2060,6 +2075,24 @@ static void i40e_rx_buffer_flip(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_update_rx_stats - Updates the Rx statistics
+ * @rxr: ingress ring
+ * @rx_bytes: number of bytes
+ * @rx_packets: number of packets
+ **/
+static inline void i40e_update_rx_stats(struct i40e_ring *rxr,
+					unsigned int rx_bytes,
+					unsigned int rx_packets)
+{
+	u64_stats_update_begin(&rxr->syncp);
+	rxr->stats.packets += rx_packets;
+	rxr->stats.bytes += rx_bytes;
+	u64_stats_update_end(&rxr->syncp);
+	rxr->q_vector->rx.total_packets += rx_packets;
+	rxr->q_vector->rx.total_bytes += rx_bytes;
+}
+
+/**
  * i40e_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @rx_ring: rx descriptor ring to transact packets on
  * @budget: Total limit on number of packets to process
@@ -2071,7 +2104,7 @@ static void i40e_rx_buffer_flip(struct i40e_ring *rx_ring,
  *
  * Returns amount of work completed
  **/
-static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
+int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	struct sk_buff *skb = rx_ring->skb;
@@ -2205,17 +2238,84 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 	rx_ring->skb = skb;
 
-	u64_stats_update_begin(&rx_ring->syncp);
-	rx_ring->stats.packets += total_rx_packets;
-	rx_ring->stats.bytes += total_rx_bytes;
-	u64_stats_update_end(&rx_ring->syncp);
-	rx_ring->q_vector->rx.total_packets += total_rx_packets;
-	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
+	i40e_update_rx_stats(rx_ring, total_rx_bytes, total_rx_packets);
 
 	/* guarantee a trip back through this routine if there was a failure */
 	return failure ? budget : (int)total_rx_packets;
 }
 
+/**
+ * i40e_get_rx_desc_size - Returns the size of a received frame
+ * @rxd: rx descriptor
+ *
+ * Returns numbers of bytes received.
+ **/
+static inline unsigned int i40e_get_rx_desc_size(union i40e_rx_desc *rxd)
+{
+	u64 qword = le64_to_cpu(rxd->wb.qword1.status_error_len);
+	unsigned int size;
+
+	size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+	       I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+
+	return size;
+}
+
+/**
+ * i40e_clean_rx_tp4_irq - Pulls received packets of the descriptor ring
+ * @rxr: ingress ring
+ * @budget: NAPI budget
+ *
+ * Returns number of received packets.
+ **/
+int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget)
+{
+	int total_rx_bytes = 0, total_rx_packets = 0;
+	u16 cleaned_count = I40E_DESC_UNUSED(rxr);
+	struct tp4_frame_set frame_set;
+	bool failure;
+
+	if (!tp4a_get_flushable_frame_set(rxr->tp4.arr, &frame_set))
+		goto out;
+
+	while (total_rx_packets < budget) {
+		union i40e_rx_desc *rxd = I40E_RX_DESC(rxr, rxr->next_to_clean);
+		unsigned int size = i40e_get_rx_desc_size(rxd);
+
+		if (!size)
+			break;
+
+		/* This memory barrier is needed to keep us from
+		 * reading any other fields out of the rxd until we
+		 * have verified the descriptor has been written back.
+		 */
+		dma_rmb();
+
+		tp4f_set_frame_no_offset(&frame_set, size,
+					 i40e_is_rx_desc_eof(rxd));
+
+		total_rx_bytes += size;
+		total_rx_packets++;
+
+		i40e_inc_rx_next_to_clean(rxr);
+
+		WARN_ON(!tp4f_next_frame(&frame_set));
+	}
+
+	WARN_ON(tp4a_flush_n(rxr->tp4.arr, total_rx_packets));
+
+	rxr->tp4.ev_handler(rxr->tp4.ev_opaque);
+
+	i40e_update_rx_stats(rxr, total_rx_bytes, total_rx_packets);
+
+	cleaned_count += total_rx_packets;
+out:
+	failure = (cleaned_count >= I40E_RX_BUFFER_WRITE) ?
+		  i40e_alloc_rx_buffers_tp4(rxr, cleaned_count) : false;
+
+	return failure ? budget : total_rx_packets;
+}
+
 static u32 i40e_buildreg_itr(const int type, const u16 itr)
 {
 	u32 val;
@@ -2372,7 +2472,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	budget_per_ring = max(budget/q_vector->num_ringpairs, 1);
 
 	i40e_for_each_ring(ring, q_vector->rx) {
-		int cleaned = i40e_clean_rx_irq(ring, budget_per_ring);
+		int cleaned = ring->clean_irq(ring, budget_per_ring);
 
 		work_done += cleaned;
 		/* if we clean as many as budgeted, we must not be done */
@@ -3434,3 +3534,51 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	return i40e_xmit_frame_ring(skb, tx_ring);
 }
+
+/**
+ * i40e_alloc_rx_buffers_tp4 - Allocate buffers from the TP4 userland ring
+ * @rxr: ingress ring
+ * @cleaned_count: number of buffers to allocate
+ *
+ * Returns true on failure, false on success.
+ **/
+bool i40e_alloc_rx_buffers_tp4(struct i40e_ring *rxr, u16 cleaned_count)
+{
+	u16 i, ntu = rxr->next_to_use;
+	union i40e_rx_desc *rx_desc;
+	struct tp4_frame_set frame;
+	bool ret = false;
+	dma_addr_t dma;
+
+	rx_desc = I40E_RX_DESC(rxr, ntu);
+
+	for (i = 0; i < cleaned_count; i++) {
+		if (unlikely(!tp4a_next_frame_populate(rxr->tp4.arr, &frame))) {
+			rxr->rx_stats.alloc_page_failed++;
+			ret = true;
+			break;
+		}
+
+		dma = tp4f_get_dma(&frame);
+		dma_sync_single_for_device(rxr->dev, dma, rxr->rx_buf_len,
+					   DMA_FROM_DEVICE);
+
+		rx_desc->read.pkt_addr = cpu_to_le64(dma);
+
+		rx_desc++;
+		ntu++;
+		if (unlikely(ntu == rxr->count)) {
+			rx_desc = I40E_RX_DESC(rxr, 0);
+			ntu = 0;
+		}
+
+		/* clear the status bits for the next_to_use descriptor */
+		rx_desc->wb.qword1.status_error_len = 0;
+	}
+
+	if (rxr->next_to_use != ntu)
+		i40e_release_rx_desc(rxr, ntu);
+
+	return ret;
+}
+
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index fbae1182e2ea..602dcd111938 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -27,6 +27,8 @@
 #ifndef _I40E_TXRX_H_
 #define _I40E_TXRX_H_
 
+#include <linux/tpacket4.h>
+
 /* Interrupt Throttling and Rate Limiting Goodies */
 
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
@@ -347,6 +349,14 @@ enum i40e_ring_state_t {
 	__I40E_RING_STATE_NBITS /* must be last */
 };
 
+struct i40e_tp4_ctx {
+	struct tp4_packet_array *arr;
+	void (*ev_handler)(void *);
+	void *ev_opaque;
+	void (*err_handler)(void *, int);
+	void *err_opaque;
+};
+
 /* some useful defines for virtchannel interface, which
  * is the only remaining user of header split
  */
@@ -385,6 +395,7 @@ struct i40e_ring {
 	u16 count;			/* Number of descriptors */
 	u16 reg_idx;			/* HW register index of the ring */
 	u16 rx_buf_len;
+	u16 rx_max_frame;
 
 	/* used in interrupt processing */
 	u16 next_to_use;
@@ -401,6 +412,7 @@ struct i40e_ring {
 #define I40E_TXR_FLAGS_WB_ON_ITR		BIT(0)
 #define I40E_RXR_FLAGS_BUILD_SKB_ENABLED	BIT(1)
 #define I40E_TXR_FLAGS_XDP			BIT(2)
+#define I40E_R_FLAGS_TP4			BIT(3)
 
 	/* stats structs */
 	struct i40e_queue_stats	stats;
@@ -428,6 +440,10 @@ struct i40e_ring {
 					 */
 
 	struct i40e_channel *ch;
+
+	bool (*rx_alloc_fn)(struct i40e_ring *rxr, u16 cleaned_count);
+	int (*clean_irq)(struct i40e_ring *ring, int budget);
+	struct i40e_tp4_ctx tp4;
 } ____cacheline_internodealigned_in_smp;
 
 static inline bool ring_uses_build_skb(struct i40e_ring *ring)
@@ -455,6 +471,21 @@ static inline void set_ring_xdp(struct i40e_ring *ring)
 	ring->flags |= I40E_TXR_FLAGS_XDP;
 }
 
+static inline bool ring_uses_tp4(struct i40e_ring *ring)
+{
+	return !!(ring->flags & I40E_R_FLAGS_TP4);
+}
+
+static inline void set_ring_tp4(struct i40e_ring *ring)
+{
+	ring->flags |= I40E_R_FLAGS_TP4;
+}
+
+static inline void clear_ring_tp4(struct i40e_ring *ring)
+{
+	ring->flags &= ~I40E_R_FLAGS_TP4;
+}
+
 enum i40e_latency_range {
 	I40E_LOWEST_LATENCY = 0,
 	I40E_LOW_LATENCY = 1,
@@ -488,6 +519,9 @@ static inline unsigned int i40e_rx_pg_order(struct i40e_ring *ring)
 #define i40e_rx_pg_size(_ring) (PAGE_SIZE << i40e_rx_pg_order(_ring))
 
 bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
+int i40e_clean_rx_irq(struct i40e_ring *rxr, int budget);
+bool i40e_alloc_rx_buffers_tp4(struct i40e_ring *rxr, u16 cleaned_count);
+int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index 839485108b2d..80bc20543599 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -658,6 +658,19 @@ static inline void *tp4q_get_data(struct tp4_queue *q,
 }
 
 /**
+ * tp4q_get_dma_addr - Get kernel dma address of page
+ *
+ * @q: Pointer to the tp4 queue that this frame resides in
+ * @pg: Pointer to the page of this frame
+ *
+ * Returns the dma address associated with the page
+ **/
+static inline dma_addr_t tp4q_get_dma_addr(struct tp4_queue *q, u64 pg)
+{
+	return q->dma_info[pg].dma;
+}
+
+/**
  * tp4q_get_desc - Get descriptor associated with frame
  *
  * @p: Pointer to the packet to examine
@@ -722,6 +735,18 @@ static inline u32 tp4f_get_frame_len(struct tp4_frame_set *p)
 }
 
 /**
+ * tp4f_get_data_offset - Get offset of packet data in packet buffer
+ * @p: pointer to frame set
+ *
+ * Returns the offset to the data in the packet buffer of the current
+ * frame
+ **/
+static inline u32 tp4f_get_data_offset(struct tp4_frame_set *p)
+{
+	return p->pkt_arr->items[p->curr & p->pkt_arr->mask].offset;
+}
+
+/**
  * tp4f_set_error - Set an error on the current frame
  * @p: pointer to frame set
  * @errno: the errno to be assigned
@@ -762,6 +787,41 @@ static inline void tp4f_set_frame(struct tp4_frame_set *p, u32 len, u16 offset,
 		d->flags |= TP4_PKT_CONT;
 }
 
+/**
+ * tp4f_set_frame_no_offset - Sets the properties of a frame
+ * @p: pointer to frame
+ * @len: the length in bytes of the data in the frame
+ * @is_eop: Set if this is the last frame of the packet
+ **/
+static inline void tp4f_set_frame_no_offset(struct tp4_frame_set *p,
+					    u32 len, bool is_eop)
+{
+	struct tpacket4_desc *d =
+		&p->pkt_arr->items[p->curr & p->pkt_arr->mask];
+
+	d->len = len;
+	if (!is_eop)
+		d->flags |= TP4_PKT_CONT;
+}
+
+/**
+ * tp4f_get_dma - Returns DMA address of the frame
+ * @f: pointer to frame
+ *
+ * Returns the DMA address of the frame
+ **/
+static inline dma_addr_t tp4f_get_dma(struct tp4_frame_set *f)
+{
+	struct tp4_queue *tp4q = f->pkt_arr->tp4q;
+	dma_addr_t dma;
+	u64 pg, off;
+
+	tp4q_get_page_offset(tp4q, tp4f_get_frame_id(f), &pg, &off);
+	dma = tp4q_get_dma_addr(tp4q, pg);
+
+	return dma + off + tp4f_get_data_offset(f);
+}
+
 /*************** PACKET OPERATIONS *******************************/
 /* A packet consists of one or more frames. Both frames and packets
  * are represented by a tp4_frame_set. The only difference is that
@@ -1023,6 +1083,31 @@ static inline bool tp4a_next_packet(struct tp4_packet_array *a,
 }
 
 /**
+ * tp4a_flush_n - Flush n processed packets to associated tp4q
+ * @a: pointer to packet array
+ * @n: number of items to flush
+ *
+ * Returns 0 for success and -1 for failure
+ **/
+static inline int tp4a_flush_n(struct tp4_packet_array *a, unsigned int n)
+{
+	u32 avail = a->curr - a->start;
+	int ret;
+
+	if (avail == 0 || n == 0)
+		return 0; /* nothing to flush */
+
+	avail = (n > avail) ? avail : n; /* XXX trust user? remove? */
+
+	ret = tp4q_enqueue_from_array(a, avail);
+	if (ret < 0)
+		return -1;
+
+	a->start += avail;
+	return 0;
+}
+
+/**
  * tp4a_flush_completed - Flushes only frames marked as completed
  * @a: pointer to packet array
  *
-- 
2.11.0
