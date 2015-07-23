From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e/i40evf: Fix and refactor dynamic ITR code
Date: Thu, 23 Jul 2015 06:52:35 -0700
Message-ID: <1437659564-48822-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7061 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbbGWNwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:47 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes the switch statement for dynamic interrupt throttling
and adds a default case. With this patch, we check the latency setting
instead of the current ITR settings and the included refactor improves
performance.

Without this patch, the ITR setting would never change dynamically, and
there was no default.

Change-ID: Idb5a8a14c7109ec47c90f6e94bd43baa17d7ee37
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 146 ++++++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 113 +++++++++++++-------
 2 files changed, 161 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1fe230d..a72278c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -892,7 +892,7 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 *  20-1249MB/s bulk   (8000 ints/s)
 	 */
 	bytes_per_int = rc->total_bytes / rc->itr;
-	switch (rc->itr) {
+	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
 			new_latency_range = I40E_LOW_LATENCY;
@@ -905,9 +905,14 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	case I40E_BULK_LATENCY:
 		if (bytes_per_int <= 20)
-			rc->latency_range = I40E_LOW_LATENCY;
+			new_latency_range = I40E_LOW_LATENCY;
+		break;
+	default:
+		if (bytes_per_int <= 20)
+			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
+	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
@@ -923,42 +928,14 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
-	if (new_itr != rc->itr) {
-		/* do an exponential smoothing */
-		new_itr = (10 * new_itr * rc->itr) /
-			  ((9 * new_itr) + rc->itr);
-		rc->itr = new_itr & I40E_MAX_ITR;
-	}
+	if (new_itr != rc->itr)
+		rc->itr = new_itr;
 
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
 }
 
 /**
- * i40e_update_dynamic_itr - Adjust ITR based on bytes per int
- * @q_vector: the vector to adjust
- **/
-static void i40e_update_dynamic_itr(struct i40e_q_vector *q_vector)
-{
-	u16 vector = q_vector->vsi->base_vector + q_vector->v_idx;
-	struct i40e_hw *hw = &q_vector->vsi->back->hw;
-	u32 reg_addr;
-	u16 old_itr;
-
-	reg_addr = I40E_PFINT_ITRN(I40E_RX_ITR, vector - 1);
-	old_itr = q_vector->rx.itr;
-	i40e_set_new_dynamic_itr(&q_vector->rx);
-	if (old_itr != q_vector->rx.itr)
-		wr32(hw, reg_addr, q_vector->rx.itr);
-
-	reg_addr = I40E_PFINT_ITRN(I40E_TX_ITR, vector - 1);
-	old_itr = q_vector->tx.itr;
-	i40e_set_new_dynamic_itr(&q_vector->tx);
-	if (old_itr != q_vector->tx.itr)
-		wr32(hw, reg_addr, q_vector->tx.itr);
-}
-
-/**
  * i40e_clean_programming_status - clean the programming status descriptor
  * @rx_ring: the rx ring that has this descriptor
  * @rx_desc: the rx descriptor written back by HW
@@ -1827,6 +1804,68 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 }
 
 /**
+ * i40e_update_enable_itr - Update itr and re-enable MSIX interrupt
+ * @vsi: the VSI we care about
+ * @q_vector: q_vector for which itr is being updated and interrupt enabled
+ *
+ **/
+static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
+					  struct i40e_q_vector *q_vector)
+{
+	struct i40e_hw *hw = &vsi->back->hw;
+	u16 old_itr;
+	int vector;
+	u32 val;
+
+	vector = (q_vector->v_idx + vsi->base_vector);
+	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
+		old_itr = q_vector->rx.itr;
+		i40e_set_new_dynamic_itr(&q_vector->rx);
+		if (old_itr != q_vector->rx.itr) {
+			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+			I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+			(I40E_RX_ITR <<
+				I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+			(q_vector->rx.itr <<
+				I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
+		} else {
+			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+			I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+			(I40E_ITR_NONE <<
+				I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
+		}
+		if (!test_bit(__I40E_DOWN, &vsi->state))
+			wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
+	} else {
+		i40e_irq_dynamic_enable(vsi,
+					q_vector->v_idx + vsi->base_vector);
+	}
+	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
+		old_itr = q_vector->tx.itr;
+		i40e_set_new_dynamic_itr(&q_vector->tx);
+		if (old_itr != q_vector->tx.itr) {
+			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+				I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+				(I40E_TX_ITR <<
+				   I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+				(q_vector->tx.itr <<
+				   I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
+		} else {
+			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+				I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+				(I40E_ITR_NONE <<
+				   I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
+		}
+		if (!test_bit(__I40E_DOWN, &vsi->state))
+			wr32(hw, I40E_PFINT_DYN_CTLN(q_vector->v_idx +
+			      vsi->base_vector - 1), val);
+	} else {
+		i40e_irq_dynamic_enable(vsi,
+					q_vector->v_idx + vsi->base_vector);
+	}
+}
+
+/**
  * i40e_napi_poll - NAPI polling Rx/Tx cleanup routine
  * @napi: napi struct with our devices info in it
  * @budget: amount of work driver is allowed to do this pass, in packets
@@ -1882,33 +1921,24 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 
 	/* Work is done so exit the polling mode and re-enable the interrupt */
 	napi_complete(napi);
-	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting) ||
-	    ITR_IS_DYNAMIC(vsi->tx_itr_setting))
-		i40e_update_dynamic_itr(q_vector);
-
-	if (!test_bit(__I40E_DOWN, &vsi->state)) {
-		if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
-			i40e_irq_dynamic_enable(vsi,
-					q_vector->v_idx + vsi->base_vector);
-		} else {
-			struct i40e_hw *hw = &vsi->back->hw;
-			/* We re-enable the queue 0 cause, but
-			 * don't worry about dynamic_enable
-			 * because we left it on for the other
-			 * possible interrupts during napi
-			 */
-			u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
-			qval |= I40E_QINT_RQCTL_CAUSE_ENA_MASK;
-			wr32(hw, I40E_QINT_RQCTL(0), qval);
-
-			qval = rd32(hw, I40E_QINT_TQCTL(0));
-			qval |= I40E_QINT_TQCTL_CAUSE_ENA_MASK;
-			wr32(hw, I40E_QINT_TQCTL(0), qval);
-
-			i40e_irq_dynamic_enable_icr0(vsi->back);
-		}
+	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
+		i40e_update_enable_itr(vsi, q_vector);
+	} else { /* Legacy mode */
+		struct i40e_hw *hw = &vsi->back->hw;
+		/* We re-enable the queue 0 cause, but
+		 * don't worry about dynamic_enable
+		 * because we left it on for the other
+		 * possible interrupts during napi
+		 */
+		u32 qval = rd32(hw, I40E_QINT_RQCTL(0)) |
+			   I40E_QINT_RQCTL_CAUSE_ENA_MASK;
+
+		wr32(hw, I40E_QINT_RQCTL(0), qval);
+		qval = rd32(hw, I40E_QINT_TQCTL(0)) |
+		       I40E_QINT_TQCTL_CAUSE_ENA_MASK;
+		wr32(hw, I40E_QINT_TQCTL(0), qval);
+		i40e_irq_dynamic_enable_icr0(vsi->back);
 	}
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 0f0e185..cf35303 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -404,7 +404,7 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 *  20-1249MB/s bulk   (8000 ints/s)
 	 */
 	bytes_per_int = rc->total_bytes / rc->itr;
-	switch (rc->itr) {
+	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
 			new_latency_range = I40E_LOW_LATENCY;
@@ -417,9 +417,14 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	case I40E_BULK_LATENCY:
 		if (bytes_per_int <= 20)
-			rc->latency_range = I40E_LOW_LATENCY;
+			new_latency_range = I40E_LOW_LATENCY;
+		break;
+	default:
+		if (bytes_per_int <= 20)
+			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
+	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
@@ -435,42 +440,14 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
-	if (new_itr != rc->itr) {
-		/* do an exponential smoothing */
-		new_itr = (10 * new_itr * rc->itr) /
-			  ((9 * new_itr) + rc->itr);
-		rc->itr = new_itr & I40E_MAX_ITR;
-	}
+	if (new_itr != rc->itr)
+		rc->itr = new_itr;
 
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
 }
 
-/**
- * i40e_update_dynamic_itr - Adjust ITR based on bytes per int
- * @q_vector: the vector to adjust
- **/
-static void i40e_update_dynamic_itr(struct i40e_q_vector *q_vector)
-{
-	u16 vector = q_vector->vsi->base_vector + q_vector->v_idx;
-	struct i40e_hw *hw = &q_vector->vsi->back->hw;
-	u32 reg_addr;
-	u16 old_itr;
-
-	reg_addr = I40E_VFINT_ITRN1(I40E_RX_ITR, vector - 1);
-	old_itr = q_vector->rx.itr;
-	i40e_set_new_dynamic_itr(&q_vector->rx);
-	if (old_itr != q_vector->rx.itr)
-		wr32(hw, reg_addr, q_vector->rx.itr);
-
-	reg_addr = I40E_VFINT_ITRN1(I40E_TX_ITR, vector - 1);
-	old_itr = q_vector->tx.itr;
-	i40e_set_new_dynamic_itr(&q_vector->tx);
-	if (old_itr != q_vector->tx.itr)
-		wr32(hw, reg_addr, q_vector->tx.itr);
-}
-
-/**
+/*
  * i40evf_setup_tx_descriptors - Allocate the Tx descriptors
  * @tx_ring: the tx ring to set up
  *
@@ -1281,6 +1258,68 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 }
 
 /**
+ * i40e_update_enable_itr - Update itr and re-enable MSIX interrupt
+ * @vsi: the VSI we care about
+ * @q_vector: q_vector for which itr is being updated and interrupt enabled
+ *
+ **/
+static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
+					  struct i40e_q_vector *q_vector)
+{
+	struct i40e_hw *hw = &vsi->back->hw;
+	u16 old_itr;
+	int vector;
+	u32 val;
+
+	vector = (q_vector->v_idx + vsi->base_vector);
+	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
+		old_itr = q_vector->rx.itr;
+		i40e_set_new_dynamic_itr(&q_vector->rx);
+		if (old_itr != q_vector->rx.itr) {
+			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
+			I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			(I40E_RX_ITR <<
+				I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+			(q_vector->rx.itr <<
+				I40E_VFINT_DYN_CTLN_INTERVAL_SHIFT);
+		} else {
+			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
+			I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			(I40E_ITR_NONE <<
+				I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT);
+		}
+		if (!test_bit(__I40E_DOWN, &vsi->state))
+			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
+	} else {
+		i40evf_irq_enable_queues(vsi->back, 1
+			<< q_vector->v_idx);
+	}
+	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
+		old_itr = q_vector->tx.itr;
+		i40e_set_new_dynamic_itr(&q_vector->tx);
+		if (old_itr != q_vector->tx.itr) {
+			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
+				I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+				(I40E_TX_ITR <<
+				   I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+				(q_vector->tx.itr <<
+				   I40E_VFINT_DYN_CTLN_INTERVAL_SHIFT);
+
+		} else {
+			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
+				I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+				(I40E_ITR_NONE <<
+				   I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT);
+		}
+		if (!test_bit(__I40E_DOWN, &vsi->state))
+			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
+	} else {
+		i40evf_irq_enable_queues(vsi->back,
+					 1 << q_vector->v_idx);
+	}
+}
+
+/**
  * i40evf_napi_poll - NAPI polling Rx/Tx cleanup routine
  * @napi: napi struct with our devices info in it
  * @budget: amount of work driver is allowed to do this pass, in packets
@@ -1336,13 +1375,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 
 	/* Work is done so exit the polling mode and re-enable the interrupt */
 	napi_complete(napi);
-	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting) ||
-	    ITR_IS_DYNAMIC(vsi->tx_itr_setting))
-		i40e_update_dynamic_itr(q_vector);
-
-	if (!test_bit(__I40E_DOWN, &vsi->state))
-		i40evf_irq_enable_queues(vsi->back, 1 << q_vector->v_idx);
-
+	i40e_update_enable_itr(vsi, q_vector);
 	return 0;
 }
 
-- 
2.4.3
