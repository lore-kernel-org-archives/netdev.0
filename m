From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/17] i40e/i40evf: refactor IRQ enable function
Date: Mon, 19 Oct 2015 15:49:20 -0700
Message-ID: <1445294971-44714-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12471 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbbJSWtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:36 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change moves a multi-line register setting into a function
which simplifies reading the flow of the enable function.

This also fixes a bug where the enable function was enabling
the interrupt twice while trying to update the two interrupt
throttle rate thresholds for Rx and Tx.

Change-ID: Ie308f9d0d48540204590cb9d7a5a7b1196f959bb
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 112 +++++++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 108 ++++++++++++++-----------
 2 files changed, 128 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 512707c..889d25d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -815,6 +815,8 @@ void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
  * i40e_set_new_dynamic_itr - Find new ITR level
  * @rc: structure containing ring performance data
  *
+ * Returns true if ITR changed, false if not
+ *
  * Stores a new ITR value based on packets and byte counts during
  * the last interrupt.  The advantage of per interrupt computation
  * is faster updates and more accurate ITR for the current traffic
@@ -823,14 +825,14 @@ void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
  * testing data as well as attempting to minimize response time
  * while increasing bulk throughput.
  **/
-static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
+static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
 
 	if (rc->total_packets == 0 || !rc->itr)
-		return;
+		return false;
 
 	/* simple throttlerate management
 	 *   0-10MB/s   lowest (100000 ints/s)
@@ -874,11 +876,15 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
-	if (new_itr != rc->itr)
-		rc->itr = new_itr;
-
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
+
+	if (new_itr != rc->itr) {
+		rc->itr = new_itr;
+		return true;
+	}
+
+	return false;
 }
 
 /**
@@ -1747,6 +1753,21 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	return total_rx_packets;
 }
 
+static u32 i40e_buildreg_itr(const int type, const u16 itr)
+{
+	u32 val;
+
+	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+	      (type << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+	      (itr << I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
+
+	return val;
+}
+
+/* a small macro to shorten up some long lines */
+#define INTREG I40E_PFINT_DYN_CTLN
+
 /**
  * i40e_update_enable_itr - Update itr and re-enable MSIX interrupt
  * @vsi: the VSI we care about
@@ -1757,54 +1778,53 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 					  struct i40e_q_vector *q_vector)
 {
 	struct i40e_hw *hw = &vsi->back->hw;
-	u16 old_itr;
+	bool rx = false, tx = false;
+	u32 rxval, txval;
 	int vector;
-	u32 val;
 
 	vector = (q_vector->v_idx + vsi->base_vector);
+
+	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
+
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
-		old_itr = q_vector->rx.itr;
-		i40e_set_new_dynamic_itr(&q_vector->rx);
-		if (old_itr != q_vector->rx.itr) {
-			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-			I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
-			(I40E_RX_ITR <<
-				I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
-			(q_vector->rx.itr <<
-				I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
-		} else {
-			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-			I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
-			(I40E_ITR_NONE <<
-				I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
-		}
-		if (!test_bit(__I40E_DOWN, &vsi->state))
-			wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
-	} else {
-		i40e_irq_dynamic_enable(vsi, q_vector->v_idx);
+		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
+		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
 	}
+
 	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
-		old_itr = q_vector->tx.itr;
-		i40e_set_new_dynamic_itr(&q_vector->tx);
-		if (old_itr != q_vector->tx.itr) {
-			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-				I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
-				(I40E_TX_ITR <<
-				   I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
-				(q_vector->tx.itr <<
-				   I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
-		} else {
-			val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-				I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
-				(I40E_ITR_NONE <<
-				   I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
-		}
-		if (!test_bit(__I40E_DOWN, &vsi->state))
-			wr32(hw, I40E_PFINT_DYN_CTLN(q_vector->v_idx +
-			      vsi->base_vector - 1), val);
-	} else {
-		i40e_irq_dynamic_enable(vsi, q_vector->v_idx);
+		tx = i40e_set_new_dynamic_itr(&q_vector->tx);
+		txval = i40e_buildreg_itr(I40E_TX_ITR, q_vector->tx.itr);
 	}
+
+	if (rx || tx) {
+		/* get the higher of the two ITR adjustments and
+		 * use the same value for both ITR registers
+		 * when in adaptive mode (Rx and/or Tx)
+		 */
+		u16 itr = max(q_vector->tx.itr, q_vector->rx.itr);
+
+		q_vector->tx.itr = q_vector->rx.itr = itr;
+		txval = i40e_buildreg_itr(I40E_TX_ITR, itr);
+		tx = true;
+		rxval = i40e_buildreg_itr(I40E_RX_ITR, itr);
+		rx = true;
+	}
+
+	/* only need to enable the interrupt once, but need
+	 * to possibly update both ITR values
+	 */
+	if (rx) {
+		/* set the INTENA_MSK_MASK so that this first write
+		 * won't actually enable the interrupt, instead just
+		 * updating the ITR (it's bit 31 PF and VF)
+		 */
+		rxval |= BIT(31);
+		/* don't check _DOWN because interrupt isn't being enabled */
+		wr32(hw, INTREG(vector - 1), rxval);
+	}
+
+	if (!test_bit(__I40E_DOWN, &vsi->state))
+		wr32(hw, INTREG(vector - 1), txval);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 97493a4..597e096 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -318,6 +318,8 @@ static void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector
  * i40e_set_new_dynamic_itr - Find new ITR level
  * @rc: structure containing ring performance data
  *
+ * Returns true if ITR changed, false if not
+ *
  * Stores a new ITR value based on packets and byte counts during
  * the last interrupt.  The advantage of per interrupt computation
  * is faster updates and more accurate ITR for the current traffic
@@ -326,14 +328,14 @@ static void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector
  * testing data as well as attempting to minimize response time
  * while increasing bulk throughput.
  **/
-static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
+static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
 
 	if (rc->total_packets == 0 || !rc->itr)
-		return;
+		return false;
 
 	/* simple throttlerate management
 	 *   0-10MB/s   lowest (100000 ints/s)
@@ -377,11 +379,15 @@ static void i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
-	if (new_itr != rc->itr)
-		rc->itr = new_itr;
-
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
+
+	if (new_itr != rc->itr) {
+		rc->itr = new_itr;
+		return true;
+	}
+
+	return false;
 }
 
 /*
@@ -1187,6 +1193,21 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	return total_rx_packets;
 }
 
+static u32 i40e_buildreg_itr(const int type, const u16 itr)
+{
+	u32 val;
+
+	val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+	      I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
+	      (type << I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
+	      (itr << I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
+
+	return val;
+}
+
+/* a small macro to shorten up some long lines */
+#define INTREG I40E_VFINT_DYN_CTLN1
+
 /**
  * i40e_update_enable_itr - Update itr and re-enable MSIX interrupt
  * @vsi: the VSI we care about
@@ -1197,55 +1218,50 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 					  struct i40e_q_vector *q_vector)
 {
 	struct i40e_hw *hw = &vsi->back->hw;
-	u16 old_itr;
+	bool rx = false, tx = false;
+	u32 rxval, txval;
 	int vector;
-	u32 val;
 
 	vector = (q_vector->v_idx + vsi->base_vector);
+	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
+
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
-		old_itr = q_vector->rx.itr;
-		i40e_set_new_dynamic_itr(&q_vector->rx);
-		if (old_itr != q_vector->rx.itr) {
-			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
-			I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
-			(I40E_RX_ITR <<
-				I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
-			(q_vector->rx.itr <<
-				I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
-		} else {
-			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
-			I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
-			(I40E_ITR_NONE <<
-				I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT);
-		}
-		if (!test_bit(__I40E_DOWN, &vsi->state))
-			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
-	} else {
-		i40evf_irq_enable_queues(vsi->back, 1
-			<< q_vector->v_idx);
+		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
+		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
 	}
 	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
-		old_itr = q_vector->tx.itr;
-		i40e_set_new_dynamic_itr(&q_vector->tx);
-		if (old_itr != q_vector->tx.itr) {
-			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
-				I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
-				(I40E_TX_ITR <<
-				   I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
-				(q_vector->tx.itr <<
-				   I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
+		tx = i40e_set_new_dynamic_itr(&q_vector->tx);
+		txval = i40e_buildreg_itr(I40E_TX_ITR, q_vector->tx.itr);
+	}
+	if (rx || tx) {
+		/* get the higher of the two ITR adjustments and
+		 * use the same value for both ITR registers
+		 * when in adaptive mode (Rx and/or Tx)
+		 */
+		u16 itr = max(q_vector->tx.itr, q_vector->rx.itr);
 
-		} else {
-			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
-				I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
-				(I40E_ITR_NONE <<
-				   I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT);
-		}
-		if (!test_bit(__I40E_DOWN, &vsi->state))
-			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
-	} else {
-		i40evf_irq_enable_queues(vsi->back, BIT(q_vector->v_idx));
+		q_vector->tx.itr = q_vector->rx.itr = itr;
+		txval = i40e_buildreg_itr(I40E_TX_ITR, itr);
+		tx = true;
+		rxval = i40e_buildreg_itr(I40E_RX_ITR, itr);
+		rx = true;
 	}
+
+	/* only need to enable the interrupt once, but need
+	 * to possibly update both ITR values
+	 */
+	if (rx) {
+		/* set the INTENA_MSK_MASK so that this first write
+		 * won't actually enable the interrupt, instead just
+		 * updating the ITR (it's bit 31 PF and VF)
+		 */
+		rxval |= BIT(31);
+		/* don't check _DOWN because interrupt isn't being enabled */
+		wr32(hw, INTREG(vector - 1), rxval);
+	}
+
+	if (!test_bit(__I40E_DOWN, &vsi->state))
+		wr32(hw, INTREG(vector - 1), txval);
 }
 
 /**
-- 
2.4.3
