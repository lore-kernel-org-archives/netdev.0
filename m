From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 16/24] ixgbe: move disabling of relaxed ordering in start_hw()
Date: Wed, 13 Apr 2011 18:02:12 -0700
Message-ID: <1302742940-22141-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758164Ab1DNBCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:36 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Relaxed ordering can lead to issues with some chipsets.

This patch makes sure that it is disabled by default and
not only when DCA is on.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |   21 ++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_common.c |   15 +++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c   |    4 ----
 3 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index c9b6574..a93275f 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -197,14 +197,33 @@ out:
  *  @hw: pointer to hardware structure
  *
  *  Starts the hardware using the generic start_hw function.
- *  Then set pcie completion timeout
+ *  Disables relaxed ordering Then set pcie completion timeout
+ *
  **/
 static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 {
+	u32 regval;
+	u32 i;
 	s32 ret_val = 0;
 
 	ret_val = ixgbe_start_hw_generic(hw);
 
+	/* Disable relaxed ordering */
+	for (i = 0; ((i < hw->mac.max_tx_queues) &&
+	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		regval &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
+	}
+
+	for (i = 0; ((i < hw->mac.max_rx_queues) &&
+	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+		regval &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
+			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+	}
+
 	/* set the completion timeout for interface */
 	if (ret_val == 0)
 		ixgbe_set_pcie_completion_timeout(hw);
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index c66fd95..1b8b3cd 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -108,6 +108,7 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 {
 	u32 i;
+	u32 regval;
 
 	/* Clear the rate limiters */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
@@ -116,6 +117,20 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* Disable relaxed ordering */
+	for (i = 0; i < hw->mac.max_tx_queues; i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
+		regval &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
+	}
+
+	for (i = 0; i < hw->mac.max_rx_queues; i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+		regval &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
+					IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3dbe689..3148e21 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -947,8 +947,6 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 	rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 	rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 	rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
-	rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-		    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
 	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
 }
 
@@ -966,7 +964,6 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
 		txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(reg_idx), txctrl);
 		break;
 	case ixgbe_mac_82599EB:
@@ -976,7 +973,6 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 		txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
 			   IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx), txctrl);
 		break;
 	default:
-- 
1.7.4.2

