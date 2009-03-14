From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 04/11] ixgbe: Fix interrupt configuration for 82599
Date: Sat, 14 Mar 2009 01:13:28 -0700
Message-ID: <20090314081328.4687.35574.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:37979
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbZCNITj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:19:39 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The interrupt models using EITR have changed in 82599.  The way the register
is laid out, the change is transparent to some of the existing code.
However, some of it isn't.  This patch fixes all the cases where EITR
handling is different than 82598.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    6 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c |   21 ++++++++----
 drivers/net/ixgbe/ixgbe_main.c    |   64 +++++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_type.h    |   11 ++++++
 4 files changed, 71 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 0b54717..c26433d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -189,10 +189,11 @@ struct ixgbe_q_vector {
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
- * And yes, it's the same math going both ways.
+ * And yes, it's the same math going both ways.  The lowest value
+ * supported by all of the ixgbe hardware is 8.
  */
 #define EITR_INTS_PER_SEC_TO_REG(_eitr) \
-	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 0)
+	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 8)
 #define EITR_REG_TO_INTS_PER_SEC EITR_INTS_PER_SEC_TO_REG
 
 #define IXGBE_DESC_UNUSED(R) \
@@ -366,5 +367,6 @@ extern void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 void ixgbe_napi_add_all(struct ixgbe_adapter *adapter);
 void ixgbe_napi_del_all(struct ixgbe_adapter *adapter);
+extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index ae38bca..3a99781 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -977,40 +977,47 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
                               struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
 	if (ec->tx_max_coalesced_frames_irq)
 		adapter->tx_ring[0].work_limit = ec->tx_max_coalesced_frames_irq;
 
 	if (ec->rx_coalesce_usecs > 1) {
+		/* check the limits */
+		if ((1000000/ec->rx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
+		    (1000000/ec->rx_coalesce_usecs < IXGBE_MIN_INT_RATE))
+			return -EINVAL;
+
 		/* store the value in ints/second */
 		adapter->eitr_param = 1000000/ec->rx_coalesce_usecs;
 
 		/* static value of interrupt rate */
 		adapter->itr_setting = adapter->eitr_param;
-		/* clear the lower bit */
+		/* clear the lower bit as its used for dynamic state */
 		adapter->itr_setting &= ~1;
 	} else if (ec->rx_coalesce_usecs == 1) {
 		/* 1 means dynamic mode */
 		adapter->eitr_param = 20000;
 		adapter->itr_setting = 1;
 	} else {
-		/* any other value means disable eitr, which is best
-		 * served by setting the interrupt rate very high */
-		adapter->eitr_param = 3000000;
+		/*
+		 * any other value means disable eitr, which is best
+		 * served by setting the interrupt rate very high
+		 */
+		adapter->eitr_param = IXGBE_MAX_INT_RATE;
 		adapter->itr_setting = 0;
 	}
 
 	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
 		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
 		if (q_vector->txr_count && !q_vector->rxr_count)
+			/* tx vector gets half the rate */
 			q_vector->eitr = (adapter->eitr_param >> 1);
 		else
 			/* rx only or mixed */
 			q_vector->eitr = adapter->eitr_param;
-		IXGBE_WRITE_REG(hw, IXGBE_EITR(i),
-		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
+		ixgbe_write_eitr(adapter, i,
+		                 EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 320da14..78cc517 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -808,10 +808,14 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		/* if this is a tx only vector halve the interrupt rate */
 		if (q_vector->txr_count && !q_vector->rxr_count)
 			q_vector->eitr = (adapter->eitr_param >> 1);
-		else
+		else if (q_vector->rxr_count)
 			/* rx only */
 			q_vector->eitr = adapter->eitr_param;
 
+		/*
+		 * since ths is initial set up don't need to call
+		 * ixgbe_write_eitr helper
+		 */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
 		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
@@ -896,10 +900,35 @@ update_itr_done:
 	return retval;
 }
 
+/**
+ * ixgbe_write_eitr - write EITR register in hardware specific way
+ * @adapter: pointer to adapter struct
+ * @v_idx: vector index into q_vector array
+ * @itr_reg: new value to be written in *register* format, not ints/s
+ *
+ * This function is made to be called by ethtool and by the driver
+ * when it needs to update EITR registers at runtime.  Hardware
+ * specific quirks/differences are taken care of here.
+ */
+void ixgbe_write_eitr(struct ixgbe_adapter *adapter, int v_idx, u32 itr_reg)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		/* must write high and low 16 bits to reset counter */
+		itr_reg |= (itr_reg << 16);
+	} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		/*
+		 * set the WDIS bit to not clear the timer bits and cause an
+		 * immediate assertion of the interrupt
+		 */
+		itr_reg |= IXGBE_EITR_CNT_WDIS;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg);
+}
+
 static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_hw *hw = &adapter->hw;
 	u32 new_itr;
 	u8 current_itr, ret_itr;
 	int i, r_idx, v_idx = ((void *)q_vector - (void *)(adapter->q_vector)) /
@@ -954,17 +983,13 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 	if (new_itr != q_vector->eitr) {
 		u32 itr_reg;
+
+		/* save the algorithm value here, not the smoothed one */
+		q_vector->eitr = new_itr;
 		/* do an exponential smoothing */
 		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
-		q_vector->eitr = new_itr;
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			/* Resolution is 2 usec on 82599, so halve the rate */
-			itr_reg >>= 1;
-		/* must write high and low 16 bits to reset counter */
-		DPRINTK(TX_ERR, DEBUG, "writing eitr(%d): %08X\n", v_idx,
-		        itr_reg);
-		IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg | (itr_reg)<<16);
+		ixgbe_write_eitr(adapter, v_idx, itr_reg);
 	}
 
 	return;
@@ -1141,7 +1166,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 3)
+		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
@@ -1190,7 +1215,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 3)
+		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, enable_mask);
@@ -1360,7 +1385,6 @@ out:
 
 static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_q_vector *q_vector = adapter->q_vector;
 	u8 current_itr;
 	u32 new_itr = q_vector->eitr;
@@ -1395,15 +1419,13 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 
 	if (new_itr != q_vector->eitr) {
 		u32 itr_reg;
+
+		/* save the algorithm value here, not the smoothed one */
+		q_vector->eitr = new_itr;
 		/* do an exponential smoothing */
 		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
-		q_vector->eitr = new_itr;
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			/* Resolution is 2 usec on 82599, so halve the rate */
-			itr_reg >>= 1;
-		/* must write high and low 16 bits to reset counter */
-		IXGBE_WRITE_REG(hw, IXGBE_EITR(0), itr_reg | (itr_reg)<<16);
+		ixgbe_write_eitr(adapter, 0, itr_reg);
 	}
 
 	return;
@@ -1701,7 +1723,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
 	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 fctrl, hlreg0;
-	u32 reta = 0, mrqc;
+	u32 reta = 0, mrqc = 0;
 	u32 rdrxctl;
 	int rx_buf_len;
 
@@ -2589,7 +2611,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		if (adapter->itr_setting & 3)
+		if (adapter->itr_setting & 1)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 6090593..95fc36c 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -98,9 +98,18 @@
 #define IXGBE_EIMS_EX(_i)   (0x00AA0 + (_i) * 4)
 #define IXGBE_EIMC_EX(_i)   (0x00AB0 + (_i) * 4)
 #define IXGBE_EIAM_EX(_i)   (0x00AD0 + (_i) * 4)
+/*
+ * 82598 EITR is 16 bits but set the limits based on the max
+ * supported by all ixgbe hardware.  82599 EITR is only 12 bits,
+ * with the lower 3 always zero.
+ */
+#define IXGBE_MAX_INT_RATE 488281
+#define IXGBE_MIN_INT_RATE 956
+#define IXGBE_MAX_EITR     0x00000FF8
+#define IXGBE_MIN_EITR     8
 #define IXGBE_EITR(_i)  (((_i) <= 23) ? (0x00820 + ((_i) * 4)) : \
                          (0x012300 + (((_i) - 24) * 4)))
-#define IXGBE_EITR_ITR_INT_MASK 0x00000FFF
+#define IXGBE_EITR_ITR_INT_MASK 0x00000FF8
 #define IXGBE_EITR_LLI_MOD      0x00008000
 #define IXGBE_EITR_CNT_WDIS     0x80000000
 #define IXGBE_IVAR(_i)  (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */

