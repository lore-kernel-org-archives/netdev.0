From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [PATCH 2/3] i40e: Add XDP_TX support
Date: Thu,  8 Dec 2016 18:00:21 +0100
Message-ID: <20161208170022.11555-3-bjorn.topel@gmail.com>
References: <20161208170022.11555-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        john.r.fastabend@intel.com, magnus.karlsson@intel.com,
        netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65461 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932109AbcLHRBd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 12:01:33 -0500
In-Reply-To: <20161208170022.11555-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This patch adds proper XDP_TX support.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |   5 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 273 ++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 304 +++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |   5 +
 4 files changed, 491 insertions(+), 96 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 05d805f439e6..adc1f3f32729 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -545,6 +545,10 @@ struct i40e_vsi {
 	struct i40e_ring **rx_rings;
 	struct i40e_ring **tx_rings;
 
+	/* The XDP rings are Tx only, and follows the count of the
+	 * regular rings, i.e. alloc_queue_pairs/num_queue_pairs
+	 */
+	struct i40e_ring **xdp_rings;
 	struct bpf_prog *xdp_prog;
 
 	u32  active_filters;
@@ -622,6 +626,7 @@ struct i40e_q_vector {
 
 	struct i40e_ring_container rx;
 	struct i40e_ring_container tx;
+	struct i40e_ring_container xdp;
 
 	u8 num_ringpairs;	/* total number of ring pairs in vector */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index db0240213f3b..9310a5712ae3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -107,6 +107,18 @@ MODULE_VERSION(DRV_VERSION);
 static struct workqueue_struct *i40e_wq;
 
 /**
+ * i40e_alloc_queue_pairs_xdp_vsi - required # of XDP queue pairs
+ * @vsi: pointer to a vsi
+ **/
+static u16 i40e_alloc_queue_pairs_xdp_vsi(const struct i40e_vsi *vsi)
+{
+	if (i40e_enabled_xdp_vsi(vsi))
+		return vsi->alloc_queue_pairs;
+
+	return 0;
+}
+
+/**
  * i40e_allocate_dma_mem_d - OS specific memory alloc for shared code
  * @hw:   pointer to the HW structure
  * @mem:  ptr to mem struct to fill out
@@ -2828,6 +2840,12 @@ static int i40e_vsi_setup_tx_resources(struct i40e_vsi *vsi)
 	for (i = 0; i < vsi->num_queue_pairs && !err; i++)
 		err = i40e_setup_tx_descriptors(vsi->tx_rings[i]);
 
+	if (!i40e_enabled_xdp_vsi(vsi))
+		return err;
+
+	for (i = 0; i < vsi->num_queue_pairs && !err; i++)
+		err = i40e_setup_tx_descriptors(vsi->xdp_rings[i]);
+
 	return err;
 }
 
@@ -2841,12 +2859,17 @@ static void i40e_vsi_free_tx_resources(struct i40e_vsi *vsi)
 {
 	int i;
 
-	if (!vsi->tx_rings)
-		return;
+	if (vsi->tx_rings) {
+		for (i = 0; i < vsi->num_queue_pairs; i++)
+			if (vsi->tx_rings[i] && vsi->tx_rings[i]->desc)
+				i40e_free_tx_resources(vsi->tx_rings[i]);
+	}
 
-	for (i = 0; i < vsi->num_queue_pairs; i++)
-		if (vsi->tx_rings[i] && vsi->tx_rings[i]->desc)
-			i40e_free_tx_resources(vsi->tx_rings[i]);
+	if (vsi->xdp_rings) {
+		for (i = 0; i < vsi->num_queue_pairs; i++)
+			if (vsi->xdp_rings[i] && vsi->xdp_rings[i]->desc)
+				i40e_free_tx_resources(vsi->xdp_rings[i]);
+	}
 }
 
 /**
@@ -3121,6 +3144,12 @@ static int i40e_vsi_configure_tx(struct i40e_vsi *vsi)
 	for (i = 0; (i < vsi->num_queue_pairs) && !err; i++)
 		err = i40e_configure_tx_ring(vsi->tx_rings[i]);
 
+	if (!i40e_enabled_xdp_vsi(vsi))
+		return err;
+
+	for (i = 0; (i < vsi->num_queue_pairs) && !err; i++)
+		err = i40e_configure_tx_ring(vsi->xdp_rings[i]);
+
 	return err;
 }
 
@@ -3269,7 +3298,7 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
 	struct i40e_hw *hw = &pf->hw;
 	u16 vector;
 	int i, q;
-	u32 qp;
+	u32 qp, qp_idx = 0;
 
 	/* The interrupt indexing is offset by 1 in the PFINT_ITRn
 	 * and PFINT_LNKLSTn registers, e.g.:
@@ -3296,16 +3325,33 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
 		wr32(hw, I40E_PFINT_LNKLSTN(vector - 1), qp);
 		for (q = 0; q < q_vector->num_ringpairs; q++) {
 			u32 val;
+			u32 nqp = qp;
+
+			if (i40e_enabled_xdp_vsi(vsi)) {
+				nqp = vsi->base_queue +
+				      vsi->xdp_rings[qp_idx]->queue_index;
+			}
 
 			val = I40E_QINT_RQCTL_CAUSE_ENA_MASK |
-			      (I40E_RX_ITR << I40E_QINT_RQCTL_ITR_INDX_SHIFT)  |
-			      (vector      << I40E_QINT_RQCTL_MSIX_INDX_SHIFT) |
-			      (qp          << I40E_QINT_RQCTL_NEXTQ_INDX_SHIFT)|
+			      (I40E_RX_ITR << I40E_QINT_RQCTL_ITR_INDX_SHIFT)   |
+			      (vector      << I40E_QINT_RQCTL_MSIX_INDX_SHIFT)  |
+			      (nqp         << I40E_QINT_RQCTL_NEXTQ_INDX_SHIFT) |
 			      (I40E_QUEUE_TYPE_TX
 				      << I40E_QINT_RQCTL_NEXTQ_TYPE_SHIFT);
 
 			wr32(hw, I40E_QINT_RQCTL(qp), val);
 
+			if (i40e_enabled_xdp_vsi(vsi)) {
+				val = I40E_QINT_TQCTL_CAUSE_ENA_MASK |
+				      (I40E_TX_ITR << I40E_QINT_TQCTL_ITR_INDX_SHIFT)   |
+				      (vector      << I40E_QINT_TQCTL_MSIX_INDX_SHIFT)  |
+				      (qp          << I40E_QINT_TQCTL_NEXTQ_INDX_SHIFT) |
+				      (I40E_QUEUE_TYPE_TX
+				       << I40E_QINT_TQCTL_NEXTQ_TYPE_SHIFT);
+
+				wr32(hw, I40E_QINT_TQCTL(nqp), val);
+			}
+
 			val = I40E_QINT_TQCTL_CAUSE_ENA_MASK |
 			      (I40E_TX_ITR << I40E_QINT_TQCTL_ITR_INDX_SHIFT)  |
 			      (vector      << I40E_QINT_TQCTL_MSIX_INDX_SHIFT) |
@@ -3320,6 +3366,7 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
 
 			wr32(hw, I40E_QINT_TQCTL(qp), val);
 			qp++;
+			qp_idx++;
 		}
 	}
 
@@ -3562,6 +3609,10 @@ static void i40e_vsi_disable_irq(struct i40e_vsi *vsi)
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		wr32(hw, I40E_QINT_TQCTL(vsi->tx_rings[i]->reg_idx), 0);
 		wr32(hw, I40E_QINT_RQCTL(vsi->rx_rings[i]->reg_idx), 0);
+		if (i40e_enabled_xdp_vsi(vsi)) {
+			wr32(hw, I40E_QINT_TQCTL(vsi->xdp_rings[i]->reg_idx),
+			     0);
+		}
 	}
 
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
@@ -3871,6 +3922,24 @@ static void i40e_map_vector_to_qp(struct i40e_vsi *vsi, int v_idx, int qp_idx)
 }
 
 /**
+ * i40e_map_vector_to_xdp_ring - Assigns the XDP Tx queue to the vector
+ * @vsi: the VSI being configured
+ * @v_idx: vector index
+ * @xdp_idx: XDP Tx queue index
+ **/
+static void i40e_map_vector_to_xdp_ring(struct i40e_vsi *vsi, int v_idx,
+					int xdp_idx)
+{
+	struct i40e_q_vector *q_vector = vsi->q_vectors[v_idx];
+	struct i40e_ring *xdp_ring = vsi->xdp_rings[xdp_idx];
+
+	xdp_ring->q_vector = q_vector;
+	xdp_ring->next = q_vector->xdp.ring;
+	q_vector->xdp.ring = xdp_ring;
+	q_vector->xdp.count++;
+}
+
+/**
  * i40e_vsi_map_rings_to_vectors - Maps descriptor rings to vectors
  * @vsi: the VSI being configured
  *
@@ -3903,11 +3972,17 @@ static void i40e_vsi_map_rings_to_vectors(struct i40e_vsi *vsi)
 
 		q_vector->rx.count = 0;
 		q_vector->tx.count = 0;
+		q_vector->xdp.count = 0;
 		q_vector->rx.ring = NULL;
 		q_vector->tx.ring = NULL;
+		q_vector->xdp.ring = NULL;
 
 		while (num_ringpairs--) {
 			i40e_map_vector_to_qp(vsi, v_start, qp_idx);
+			if (i40e_enabled_xdp_vsi(vsi)) {
+				i40e_map_vector_to_xdp_ring(vsi, v_start,
+							    qp_idx);
+			}
 			qp_idx++;
 			qp_remaining--;
 		}
@@ -4001,56 +4076,82 @@ static int i40e_pf_txq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 }
 
 /**
- * i40e_vsi_control_tx - Start or stop a VSI's rings
+ * i40e_vsi_control_txq - Start or stop a VSI's queue
  * @vsi: the VSI being configured
  * @enable: start or stop the rings
+ * @pf_q: the PF queue
  **/
-static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
+static int i40e_vsi_control_txq(struct i40e_vsi *vsi, bool enable, int pf_q)
 {
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
-	int i, j, pf_q, ret = 0;
+	int j, ret = 0;
 	u32 tx_reg;
 
-	pf_q = vsi->base_queue;
-	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
+	/* warn the TX unit of coming changes */
+	i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
+	if (!enable)
+		usleep_range(10, 20);
 
-		/* warn the TX unit of coming changes */
-		i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
-		if (!enable)
-			usleep_range(10, 20);
+	for (j = 0; j < 50; j++) {
+		tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
+		if (((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT) & 1) ==
+		    ((tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT) & 1))
+			break;
+		usleep_range(1000, 2000);
+	}
+	/* Skip if the queue is already in the requested state */
+	if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+		return 0;
 
-		for (j = 0; j < 50; j++) {
-			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
-			if (((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT) & 1) ==
-			    ((tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT) & 1))
-				break;
-			usleep_range(1000, 2000);
-		}
-		/* Skip if the queue is already in the requested state */
-		if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
-			continue;
+	/* turn on/off the queue */
+	if (enable) {
+		wr32(hw, I40E_QTX_HEAD(pf_q), 0);
+		tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK;
+	} else {
+		tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
+	}
 
-		/* turn on/off the queue */
-		if (enable) {
-			wr32(hw, I40E_QTX_HEAD(pf_q), 0);
-			tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK;
-		} else {
-			tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
-		}
+	wr32(hw, I40E_QTX_ENA(pf_q), tx_reg);
+	/* No waiting for the Tx queue to disable */
+	if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
+		return 0;
 
-		wr32(hw, I40E_QTX_ENA(pf_q), tx_reg);
-		/* No waiting for the Tx queue to disable */
-		if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
-			continue;
+	/* wait for the change to finish */
+	ret = i40e_pf_txq_wait(pf, pf_q, enable);
+	if (ret) {
+		dev_info(&pf->pdev->dev,
+			 "VSI seid %d Tx ring %d %sable timeout\n",
+			 vsi->seid, pf_q, (enable ? "en" : "dis"));
+		return ret;
+	}
+	return 0;
+}
 
-		/* wait for the change to finish */
-		ret = i40e_pf_txq_wait(pf, pf_q, enable);
-		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "VSI seid %d Tx ring %d %sable timeout\n",
-				 vsi->seid, pf_q, (enable ? "en" : "dis"));
+/**
+ * i40e_vsi_control_tx - Start or stop a VSI's rings
+ * @vsi: the VSI being configured
+ * @enable: start or stop the rings
+ **/
+static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
+{
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	int i, pf_q, ret = 0;
+
+	pf_q = vsi->base_queue;
+	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
+		ret = i40e_vsi_control_txq(vsi, enable, pf_q);
+		if (ret)
 			break;
+	}
+
+	if (!ret && i40e_enabled_xdp_vsi(vsi)) {
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			pf_q = vsi->base_queue + vsi->xdp_rings[i]->queue_index;
+			ret = i40e_vsi_control_txq(vsi, enable, pf_q);
+			if (ret)
+				break;
 		}
 	}
 
@@ -4311,6 +4412,9 @@ static void i40e_free_q_vector(struct i40e_vsi *vsi, int v_idx)
 	i40e_for_each_ring(ring, q_vector->rx)
 		ring->q_vector = NULL;
 
+	i40e_for_each_ring(ring, q_vector->xdp)
+		ring->q_vector = NULL;
+
 	/* only VSI w/ an associated netdev is set up w/ NAPI */
 	if (vsi->netdev)
 		netif_napi_del(&q_vector->napi);
@@ -4534,6 +4638,21 @@ static int i40e_vsi_wait_queues_disabled(struct i40e_vsi *vsi)
 		}
 	}
 
+	if (!i40e_enabled_xdp_vsi(vsi))
+		return 0;
+
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		pf_q = vsi->base_queue + vsi->xdp_rings[i]->queue_index;
+		/* Check and wait for the disable status of the queue */
+		ret = i40e_pf_txq_wait(pf, pf_q, false);
+		if (ret) {
+			dev_info(&pf->pdev->dev,
+				 "VSI seid %d XDP Tx ring %d disable timeout\n",
+				 vsi->seid, pf_q);
+			return ret;
+		}
+	}
+
 	return 0;
 }
 
@@ -5474,6 +5593,8 @@ void i40e_down(struct i40e_vsi *vsi)
 
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		i40e_clean_tx_ring(vsi->tx_rings[i]);
+		if (i40e_enabled_xdp_vsi(vsi))
+			i40e_clean_tx_ring(vsi->xdp_rings[i]);
 		i40e_clean_rx_ring(vsi->rx_rings[i]);
 	}
 
@@ -7446,6 +7567,16 @@ static int i40e_vsi_alloc_arrays(struct i40e_vsi *vsi, bool alloc_qvectors)
 		return -ENOMEM;
 	vsi->rx_rings = &vsi->tx_rings[vsi->alloc_queue_pairs];
 
+	if (i40e_enabled_xdp_vsi(vsi)) {
+		size = sizeof(struct i40e_ring *) *
+		       i40e_alloc_queue_pairs_xdp_vsi(vsi);
+		vsi->xdp_rings = kzalloc(size, GFP_KERNEL);
+		if (!vsi->xdp_rings) {
+			ret = -ENOMEM;
+			goto err_xdp_rings;
+		}
+	}
+
 	if (alloc_qvectors) {
 		/* allocate memory for q_vector pointers */
 		size = sizeof(struct i40e_q_vector *) * vsi->num_q_vectors;
@@ -7458,6 +7589,8 @@ static int i40e_vsi_alloc_arrays(struct i40e_vsi *vsi, bool alloc_qvectors)
 	return ret;
 
 err_vectors:
+	kfree(vsi->xdp_rings);
+err_xdp_rings:
 	kfree(vsi->tx_rings);
 	return ret;
 }
@@ -7564,6 +7697,8 @@ static void i40e_vsi_free_arrays(struct i40e_vsi *vsi, bool free_qvectors)
 	kfree(vsi->tx_rings);
 	vsi->tx_rings = NULL;
 	vsi->rx_rings = NULL;
+	kfree(vsi->xdp_rings);
+	vsi->xdp_rings = NULL;
 }
 
 /**
@@ -7649,6 +7784,13 @@ static void i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 			vsi->rx_rings[i] = NULL;
 		}
 	}
+
+	if (vsi->xdp_rings && vsi->xdp_rings[0]) {
+		for (i = 0; i < vsi->alloc_queue_pairs; i++) {
+			kfree_rcu(vsi->xdp_rings[i], rcu);
+			vsi->xdp_rings[i] = NULL;
+		}
+	}
 }
 
 /**
@@ -7696,6 +7838,31 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		vsi->rx_rings[i] = rx_ring;
 	}
 
+	if (!i40e_enabled_xdp_vsi(vsi))
+		return 0;
+
+	for (i = 0; i < vsi->alloc_queue_pairs; i++) {
+		tx_ring = kzalloc(sizeof(*tx_ring), GFP_KERNEL);
+		if (!tx_ring)
+			goto err_out;
+
+		tx_ring->queue_index = vsi->alloc_queue_pairs + i;
+		tx_ring->reg_idx = vsi->base_queue + vsi->alloc_queue_pairs + i;
+		tx_ring->ring_active = false;
+		tx_ring->vsi = vsi;
+		tx_ring->netdev = NULL;
+		tx_ring->dev = &pf->pdev->dev;
+		tx_ring->count = vsi->num_desc;
+		tx_ring->size = 0;
+		tx_ring->dcb_tc = 0;
+		if (vsi->back->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
+			tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
+		tx_ring->tx_itr_setting = pf->tx_itr_default;
+		tx_ring->xdp_sibling = vsi->rx_rings[i];
+		vsi->xdp_rings[i] = tx_ring;
+		vsi->rx_rings[i]->xdp_sibling = tx_ring;
+	}
+
 	return 0;
 
 err_out:
@@ -9921,6 +10088,7 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 	struct i40e_pf *pf;
 	u8 enabled_tc;
 	int ret;
+	u16 alloc_queue_pairs;
 
 	if (!vsi)
 		return NULL;
@@ -9936,11 +10104,13 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 	if (ret)
 		goto err_vsi;
 
-	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs, vsi->idx);
+	alloc_queue_pairs = vsi->alloc_queue_pairs +
+			    i40e_alloc_queue_pairs_xdp_vsi(vsi);
+	ret = i40e_get_lump(pf, pf->qp_pile, alloc_queue_pairs, vsi->idx);
 	if (ret < 0) {
 		dev_info(&pf->pdev->dev,
 			 "failed to get tracking for %d queues for VSI %d err %d\n",
-			 vsi->alloc_queue_pairs, vsi->seid, ret);
+			 alloc_queue_pairs, vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
@@ -9998,6 +10168,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	struct i40e_veb *veb = NULL;
 	int ret, i;
 	int v_idx;
+	u16 alloc_queue_pairs;
 
 	/* The requested uplink_seid must be either
 	 *     - the PF's port seid
@@ -10082,13 +10253,15 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 		pf->lan_vsi = v_idx;
 	else if (type == I40E_VSI_SRIOV)
 		vsi->vf_id = param1;
+
+	alloc_queue_pairs = vsi->alloc_queue_pairs +
+			    i40e_alloc_queue_pairs_xdp_vsi(vsi);
 	/* assign it some queues */
-	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs,
-				vsi->idx);
+	ret = i40e_get_lump(pf, pf->qp_pile, alloc_queue_pairs,	vsi->idx);
 	if (ret < 0) {
 		dev_info(&pf->pdev->dev,
 			 "failed to get tracking for %d queues for VSI %d err=%d\n",
-			 vsi->alloc_queue_pairs, vsi->seid, ret);
+			 alloc_queue_pairs, vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d835a51dafa6..fccdec7ae102 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -520,6 +520,8 @@ static void i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
 	if (tx_buffer->skb) {
 		if (tx_buffer->tx_flags & I40E_TX_FLAGS_FD_SB)
 			kfree(tx_buffer->raw_buf);
+		else if (tx_buffer->tx_flags & I40E_TX_FLAGS_XDP)
+			put_page(tx_buffer->page);
 		else
 			dev_kfree_skb_any(tx_buffer->skb);
 		if (dma_unmap_len(tx_buffer, len))
@@ -620,6 +622,15 @@ u32 i40e_get_tx_pending(struct i40e_ring *ring, bool in_sw)
 #define WB_STRIDE 4
 
 /**
+ * i40e_page_is_reserved - check if reuse is possible
+ * @page: page struct to check
+ */
+static inline bool i40e_page_is_reserved(struct page *page)
+{
+	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
+}
+
+/**
  * i40e_clean_tx_irq - Reclaim resources after transmit completes
  * @vsi: the VSI we care about
  * @tx_ring: Tx ring to clean
@@ -762,6 +773,98 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 	return !!budget;
 }
 
+static bool i40e_clean_xdp_irq(struct i40e_vsi *vsi,
+			       struct i40e_ring *tx_ring)
+{
+	u16 i = tx_ring->next_to_clean;
+	struct i40e_tx_buffer *tx_buf;
+	struct i40e_tx_desc *tx_head;
+	struct i40e_tx_desc *tx_desc;
+	unsigned int total_bytes = 0, total_packets = 0;
+	unsigned int budget = vsi->work_limit;
+
+	tx_buf = &tx_ring->tx_bi[i];
+	tx_desc = I40E_TX_DESC(tx_ring, i);
+	i -= tx_ring->count;
+
+	tx_head = I40E_TX_DESC(tx_ring, i40e_get_head(tx_ring));
+
+	do {
+		struct i40e_tx_desc *eop_desc = tx_buf->next_to_watch;
+
+		/* if next_to_watch is not set then there is no work pending */
+		if (!eop_desc)
+			break;
+
+		/* prevent any other reads prior to eop_desc */
+		read_barrier_depends();
+
+		/* we have caught up to head, no work left to do */
+		if (tx_head == tx_desc)
+			break;
+
+		/* clear next_to_watch to prevent false hangs */
+		tx_buf->next_to_watch = NULL;
+
+		/* update the statistics for this packet */
+		total_bytes += tx_buf->bytecount;
+		total_packets += tx_buf->gso_segs;
+
+		put_page(tx_buf->page);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buf, dma),
+				 dma_unmap_len(tx_buf, len),
+				 DMA_TO_DEVICE);
+
+		/* clear tx_buffer data */
+		tx_buf->skb = NULL;
+		dma_unmap_len_set(tx_buf, len, 0);
+
+		/* move us one more past the eop_desc for start of next pkt */
+		tx_buf++;
+		tx_desc++;
+		i++;
+		if (unlikely(!i)) {
+			i -= tx_ring->count;
+			tx_buf = tx_ring->tx_bi;
+			tx_desc = I40E_TX_DESC(tx_ring, 0);
+		}
+
+		prefetch(tx_desc);
+
+		/* update budget accounting */
+		budget--;
+	} while (likely(budget));
+
+	i += tx_ring->count;
+	tx_ring->next_to_clean = i;
+	u64_stats_update_begin(&tx_ring->syncp);
+	tx_ring->stats.bytes += total_bytes;
+	tx_ring->stats.packets += total_packets;
+	u64_stats_update_end(&tx_ring->syncp);
+	tx_ring->q_vector->tx.total_bytes += total_bytes;
+	tx_ring->q_vector->tx.total_packets += total_packets;
+
+	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		/* check to see if there are < 4 descriptors
+		 * waiting to be written back, then kick the hardware to force
+		 * them to be written back in case we stay in NAPI.
+		 * In this mode on X722 we do not enable Interrupt.
+		 */
+		unsigned int j = i40e_get_tx_pending(tx_ring, false);
+
+		if (budget &&
+		    ((j / WB_STRIDE) == 0) && (j > 0) &&
+		    !test_bit(__I40E_DOWN, &vsi->state) &&
+		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
+			tx_ring->arm_wb = true;
+	}
+
+	return !!budget;
+}
+
 /**
  * i40e_enable_wb_on_itr - Arm hardware to do a wb, interrupts are not enabled
  * @vsi: the VSI we care about
@@ -1496,35 +1599,46 @@ static bool i40e_cleanup_headers(struct i40e_ring *rx_ring, struct sk_buff *skb)
 }
 
 /**
- * i40e_reuse_rx_page - page flip buffer and store it back on the ring
- * @rx_ring: rx descriptor ring to store buffers on
- * @old_buff: donor buffer to have page reused
+ * i40e_try_flip_rx_page - attempts to flip a page for reuse
+ * @rx_buffer: The buffer to alter
  *
- * Synchronizes page for reuse by the adapter
- **/
-static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
-			       struct i40e_rx_buffer *old_buff)
+ * Returns true if the page was successfully flipped and can be
+ * reused.
+ */
+static bool i40e_try_flip_rx_page(struct i40e_rx_buffer *rx_buffer)
 {
-	struct i40e_rx_buffer *new_buff;
-	u16 nta = rx_ring->next_to_alloc;
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = I40E_RXBUFFER_2048;
+#else
+	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
+#endif
 
-	new_buff = &rx_ring->rx_bi[nta];
+	/* avoid re-using remote pages */
+	if (unlikely(i40e_page_is_reserved(rx_buffer->page)))
+		return false;
 
-	/* update, and store next to alloc */
-	nta++;
-	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
+#if (PAGE_SIZE < 8192)
+	/* if we are only owner of page we can reuse it */
+	if (unlikely(page_count(rx_buffer->page) != 1))
+		return false;
 
-	/* transfer page from old buffer to new buffer */
-	*new_buff = *old_buff;
-}
+	/* flip page offset to other buffer */
+	rx_buffer->page_offset ^= truesize;
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
 
-/**
- * i40e_page_is_reserved - check if reuse is possible
- * @page: page struct to check
- */
-static inline bool i40e_page_is_reserved(struct page *page)
-{
-	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
+	if (rx_buffer->page_offset > last_offset)
+		return false;
+#endif
+
+	/* Even if we own the page, we are not allowed to use atomic_set()
+	 * This would break get_page_unless_zero() users.
+	 */
+	get_page(rx_buffer->page);
+
+	return true;
 }
 
 /**
@@ -1555,7 +1669,6 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	unsigned int truesize = I40E_RXBUFFER_2048;
 #else
 	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
-	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
 #endif
 
 	/* will the data fit in the skb we allocated? if so, just
@@ -1578,34 +1691,107 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			rx_buffer->page_offset, size, truesize);
 
-	/* avoid re-using remote pages */
-	if (unlikely(i40e_page_is_reserved(page)))
-		return false;
+	return i40e_try_flip_rx_page(rx_buffer);
+}
 
-#if (PAGE_SIZE < 8192)
-	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+/**
+ * i40e_xdp_xmit_tail_bump - updates the tail and sets the RS bit
+ * @xdp_ring: XDP Tx ring
+ **/
+static
+void i40e_xdp_xmit_tail_bump(struct i40e_ring *xdp_ring)
+{
+	struct i40e_tx_desc *tx_desc;
+
+	/* Set RS and bump tail */
+	tx_desc = I40E_TX_DESC(xdp_ring, xdp_ring->curr_in_use);
+	tx_desc->cmd_type_offset_bsz |=
+		cpu_to_le64(I40E_TX_DESC_CMD_RS << I40E_TXD_QW1_CMD_SHIFT);
+	/* Force memory writes to complete before letting h/w know
+	 * there are new descriptors to fetch.  (Only applicable for
+	 * weak-ordered memory model archs, such as IA-64).
+	 */
+	wmb();
+	writel(xdp_ring->curr_in_use, xdp_ring->tail);
+
+	xdp_ring->xdp_needs_tail_bump = false;
+}
+
+/**
+ * i40e_xdp_xmit - transmit a frame on the XDP Tx queue
+ * @xdp_ring: XDP Tx ring
+ * @page: current page containing the frame
+ * @page_offset: offset where the frame resides
+ * @dma: Bus address of the frame
+ * @size: size of the frame
+ *
+ * Returns true successfully sent.
+ **/
+static bool i40e_xdp_xmit(void *data, size_t size, struct page *page,
+			  struct i40e_ring *xdp_ring)
+{
+	struct i40e_tx_buffer *tx_bi;
+	struct i40e_tx_desc *tx_desc;
+	u16 i = xdp_ring->next_to_use;
+	dma_addr_t dma;
+
+	if (unlikely(I40E_DESC_UNUSED(xdp_ring) < 1)) {
+		if (xdp_ring->xdp_needs_tail_bump)
+			i40e_xdp_xmit_tail_bump(xdp_ring);
+		xdp_ring->tx_stats.tx_busy++;
 		return false;
+	}
 
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
-#else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
+	tx_bi = &xdp_ring->tx_bi[i];
+	tx_bi->bytecount = size;
+	tx_bi->gso_segs = 1;
+	tx_bi->tx_flags = I40E_TX_FLAGS_XDP;
+	tx_bi->page = page;
 
-	if (rx_buffer->page_offset > last_offset)
+	dma = dma_map_single(xdp_ring->dev, data, size, DMA_TO_DEVICE);
+	if (dma_mapping_error(xdp_ring->dev, dma))
 		return false;
-#endif
 
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
-	 */
-	get_page(rx_buffer->page);
+	/* record length, and DMA address */
+	dma_unmap_len_set(tx_bi, len, size);
+	dma_unmap_addr_set(tx_bi, dma, dma);
 
+	tx_desc = I40E_TX_DESC(xdp_ring, i);
+	tx_desc->buffer_addr = cpu_to_le64(dma);
+	tx_desc->cmd_type_offset_bsz = build_ctob(I40E_TX_DESC_CMD_ICRC
+						  | I40E_TX_DESC_CMD_EOP,
+						  0, size, 0);
+	tx_bi->next_to_watch = tx_desc;
+	xdp_ring->curr_in_use = i++;
+	xdp_ring->next_to_use = (i < xdp_ring->count) ? i : 0;
+	xdp_ring->xdp_needs_tail_bump = true;
 	return true;
 }
 
 /**
+ * i40e_reuse_rx_page - page flip buffer and store it back on the ring
+ * @rx_ring: rx descriptor ring to store buffers on
+ * @old_buff: donor buffer to have page reused
+ *
+ * Synchronizes page for reuse by the adapter
+ **/
+static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
+			       struct i40e_rx_buffer *old_buff)
+{
+	struct i40e_rx_buffer *new_buff;
+	u16 nta = rx_ring->next_to_alloc;
+
+	new_buff = &rx_ring->rx_bi[nta];
+
+	/* update, and store next to alloc */
+	nta++;
+	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
+
+	/* transfer page from old buffer to new buffer */
+	*new_buff = *old_buff;
+}
+
+/**
  * i40e_run_xdp - Runs an XDP program for an Rx ring
  * @rx_ring: Rx ring used for XDP
  * @rx_buffer: current Rx buffer
@@ -1625,6 +1811,7 @@ static bool i40e_run_xdp(struct i40e_ring *rx_ring,
 			    I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 	struct xdp_buff xdp;
 	u32 xdp_action;
+	bool tx_ok;
 
 	WARN_ON(!i40e_test_staterr(rx_desc,
 				   BIT(I40E_RX_DESC_STATUS_EOF_SHIFT)));
@@ -1636,21 +1823,34 @@ static bool i40e_run_xdp(struct i40e_ring *rx_ring,
 	switch (xdp_action) {
 	case XDP_PASS:
 		return false;
-	default:
-		bpf_warn_invalid_xdp_action(xdp_action);
-	case XDP_ABORTED:
 	case XDP_TX:
+		tx_ok = i40e_xdp_xmit(xdp.data, size, rx_buffer->page,
+				      rx_ring->xdp_sibling);
+		if (likely(tx_ok)) {
+			if (i40e_try_flip_rx_page(rx_buffer)) {
+				i40e_reuse_rx_page(rx_ring, rx_buffer);
+				rx_ring->rx_stats.page_reuse_count++;
+			} else {
+				dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+					       PAGE_SIZE, DMA_FROM_DEVICE);
+			}
+			break;
+		}
+	case XDP_ABORTED:
 	case XDP_DROP:
+do_drop:
 		if (likely(!i40e_page_is_reserved(rx_buffer->page))) {
 			i40e_reuse_rx_page(rx_ring, rx_buffer);
 			rx_ring->rx_stats.page_reuse_count++;
 			break;
 		}
-
-		/* we are not reusing the buffer so unmap it */
 		dma_unmap_page(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
 			       DMA_FROM_DEVICE);
 		__free_pages(rx_buffer->page, 0);
+		break;
+	default:
+		bpf_warn_invalid_xdp_action(xdp_action);
+		goto do_drop;
 	}
 
 	/* clear contents of buffer_info */
@@ -2065,6 +2265,15 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 		ring->arm_wb = false;
 	}
 
+	i40e_for_each_ring(ring, q_vector->xdp) {
+		if (!i40e_clean_xdp_irq(vsi, ring)) {
+			clean_complete = false;
+			continue;
+		}
+		arm_wb |= ring->arm_wb;
+		ring->arm_wb = false;
+	}
+
 	/* Handle case where we are called by netpoll with a budget of 0 */
 	if (budget <= 0)
 		goto tx_only;
@@ -2077,6 +2286,9 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	i40e_for_each_ring(ring, q_vector->rx) {
 		int cleaned = i40e_clean_rx_irq(ring, budget_per_ring);
 
+		if (ring->xdp_sibling && ring->xdp_sibling->xdp_needs_tail_bump)
+			i40e_xdp_xmit_tail_bump(ring->xdp_sibling);
+
 		work_done += cleaned;
 		/* if we clean as many as budgeted, we must not be done */
 		if (cleaned >= budget_per_ring)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 957d856a82c4..4d9459134e69 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -220,6 +220,7 @@ static inline unsigned int i40e_txd_use_count(unsigned int size)
 #define I40E_TX_FLAGS_TSYN		BIT(8)
 #define I40E_TX_FLAGS_FD_SB		BIT(9)
 #define I40E_TX_FLAGS_UDP_TUNNEL	BIT(10)
+#define I40E_TX_FLAGS_XDP		BIT(11)
 #define I40E_TX_FLAGS_VLAN_MASK		0xffff0000
 #define I40E_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define I40E_TX_FLAGS_VLAN_PRIO_SHIFT	29
@@ -230,6 +231,7 @@ struct i40e_tx_buffer {
 	union {
 		struct sk_buff *skb;
 		void *raw_buf;
+		struct page *page;
 	};
 	unsigned int bytecount;
 	unsigned short gso_segs;
@@ -343,6 +345,9 @@ struct i40e_ring {
 	u16 next_to_alloc;
 
 	struct bpf_prog *xdp_prog;
+	struct i40e_ring *xdp_sibling;  /* rx to xdp, and xdp to rx */
+	bool xdp_needs_tail_bump;
+	u16 curr_in_use;
 } ____cacheline_internodealigned_in_smp;
 
 enum i40e_latency_range {
-- 
2.9.3
