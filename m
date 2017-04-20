From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: factor out queue control from i40e_vsi_control_(tx|rx)
Date: Wed, 19 Apr 2017 18:57:44 -0700
Message-ID: <20170420015750.6828-9-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939049AbdDTB57 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:59 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A future patch will need to be able to handle controlling queues without
waiting until all VSIs are handled. Factor out the direct queue
modification so that we can easily re-use this code. The result is also
a bit easier to read since we don't embed multiple single-letter loop
counters.

Change-ID: Id923cbfa43127b1c24d8ed4f809b1012c736d9ac
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 139 ++++++++++++++++++----------
 1 file changed, 89 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5c2ceb247959..2bf5bb1b4627 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3919,6 +3919,8 @@ static void i40e_netpoll(struct net_device *netdev)
 }
 #endif
 
+#define I40E_QTX_ENA_WAIT_COUNT 50
+
 /**
  * i40e_pf_txq_wait - Wait for a PF's Tx queue to be enabled or disabled
  * @pf: the PF being configured
@@ -3949,6 +3951,50 @@ static int i40e_pf_txq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 }
 
 /**
+ * i40e_control_tx_q - Start or stop a particular Tx queue
+ * @pf: the PF structure
+ * @pf_q: the PF queue to configure
+ * @enable: start or stop the queue
+ *
+ * This function enables or disables a single queue. Note that any delay
+ * required after the operation is expected to be handled by the caller of
+ * this function.
+ **/
+static void i40e_control_tx_q(struct i40e_pf *pf, int pf_q, bool enable)
+{
+	struct i40e_hw *hw = &pf->hw;
+	u32 tx_reg;
+	int i;
+
+	/* warn the TX unit of coming changes */
+	i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
+	if (!enable)
+		usleep_range(10, 20);
+
+	for (i = 0; i < I40E_QTX_ENA_WAIT_COUNT; i++) {
+		tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
+		if (((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT) & 1) ==
+		    ((tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT) & 1))
+			break;
+		usleep_range(1000, 2000);
+	}
+
+	/* Skip if the queue is already in the requested state */
+	if (enable == !!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+		return;
+
+	/* turn on/off the queue */
+	if (enable) {
+		wr32(hw, I40E_QTX_HEAD(pf_q), 0);
+		tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK;
+	} else {
+		tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
+	}
+
+	wr32(hw, I40E_QTX_ENA(pf_q), tx_reg);
+}
+
+/**
  * i40e_vsi_control_tx - Start or stop a VSI's rings
  * @vsi: the VSI being configured
  * @enable: start or stop the rings
@@ -3956,39 +4002,13 @@ static int i40e_pf_txq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 {
 	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	int i, j, pf_q, ret = 0;
-	u32 tx_reg;
+	int i, pf_q, ret = 0;
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
+		i40e_control_tx_q(pf, pf_q, enable);
 
-		/* warn the TX unit of coming changes */
-		i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
-		if (!enable)
-			usleep_range(10, 20);
-
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
-
-		/* turn on/off the queue */
-		if (enable) {
-			wr32(hw, I40E_QTX_HEAD(pf_q), 0);
-			tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK;
-		} else {
-			tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
-		}
-
-		wr32(hw, I40E_QTX_ENA(pf_q), tx_reg);
-		/* No waiting for the Tx queue to disable */
+		/* Don't wait to disable when port Tx is suspended */
 		if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
 			continue;
 
@@ -4035,6 +4055,43 @@ static int i40e_pf_rxq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 }
 
 /**
+ * i40e_control_rx_q - Start or stop a particular Rx queue
+ * @pf: the PF structure
+ * @pf_q: the PF queue to configure
+ * @enable: start or stop the queue
+ *
+ * This function enables or disables a single queue. Note that any delay
+ * required after the operation is expected to be handled by the caller of
+ * this function.
+ **/
+static void i40e_control_rx_q(struct i40e_pf *pf, int pf_q, bool enable)
+{
+	struct i40e_hw *hw = &pf->hw;
+	u32 rx_reg;
+	int i;
+
+	for (i = 0; i < I40E_QTX_ENA_WAIT_COUNT; i++) {
+		rx_reg = rd32(hw, I40E_QRX_ENA(pf_q));
+		if (((rx_reg >> I40E_QRX_ENA_QENA_REQ_SHIFT) & 1) ==
+		    ((rx_reg >> I40E_QRX_ENA_QENA_STAT_SHIFT) & 1))
+			break;
+		usleep_range(1000, 2000);
+	}
+
+	/* Skip if the queue is already in the requested state */
+	if (enable == !!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
+		return;
+
+	/* turn on/off the queue */
+	if (enable)
+		rx_reg |= I40E_QRX_ENA_QENA_REQ_MASK;
+	else
+		rx_reg &= ~I40E_QRX_ENA_QENA_REQ_MASK;
+
+	wr32(hw, I40E_QRX_ENA(pf_q), rx_reg);
+}
+
+/**
  * i40e_vsi_control_rx - Start or stop a VSI's rings
  * @vsi: the VSI being configured
  * @enable: start or stop the rings
@@ -4042,31 +4099,13 @@ static int i40e_pf_rxq_wait(struct i40e_pf *pf, int pf_q, bool enable)
 static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 {
 	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	int i, j, pf_q, ret = 0;
-	u32 rx_reg;
+	int i, pf_q, ret = 0;
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
-		for (j = 0; j < 50; j++) {
-			rx_reg = rd32(hw, I40E_QRX_ENA(pf_q));
-			if (((rx_reg >> I40E_QRX_ENA_QENA_REQ_SHIFT) & 1) ==
-			    ((rx_reg >> I40E_QRX_ENA_QENA_STAT_SHIFT) & 1))
-				break;
-			usleep_range(1000, 2000);
-		}
+		i40e_control_rx_q(pf, pf_q, enable);
 
-		/* Skip if the queue is already in the requested state */
-		if (enable == !!(rx_reg & I40E_QRX_ENA_QENA_STAT_MASK))
-			continue;
-
-		/* turn on/off the queue */
-		if (enable)
-			rx_reg |= I40E_QRX_ENA_QENA_REQ_MASK;
-		else
-			rx_reg &= ~I40E_QRX_ENA_QENA_REQ_MASK;
-		wr32(hw, I40E_QRX_ENA(pf_q), rx_reg);
-		/* No waiting for the Tx queue to disable */
+		/* Don't wait to disable when port Tx is suspended */
 		if (!enable && test_bit(__I40E_PORT_TX_SUSPENDED, &pf->state))
 			continue;
 
-- 
2.12.2
