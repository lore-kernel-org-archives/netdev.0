From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] ixgbe: Do not disable read relaxed ordering when DCA is enabled
Date: Wed, 14 Mar 2012 00:55:21 -0700
Message-ID: <1331711726-9439-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7678 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab2CNHza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:30 -0400
In-Reply-To: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

A previous fix had gone though and disabled relaxed ordering for Rx
descriptor read fetching.  This was not necessary as this functions
correctly and has no ill effects on the system.

In addition several of the defines used for the DCA control registers were
incorrect in that they indicated descriptor effects when they actually had
an impact on either data or header write back.  As such I have update these
to correctly reflect either DATA or HEAD.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   71 ++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    8 ++-
 4 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 752dbe6..85d2e2c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -213,15 +213,15 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 	for (i = 0; ((i < hw->mac.max_tx_queues) &&
 	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
-		regval &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
 	}
 
 	for (i = 0; ((i < hw->mac.max_rx_queues) &&
 	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 87f6b4f..67ec37b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -128,14 +128,14 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	/* Disable relaxed ordering */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
-		regval &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
 	}
 
 	for (i = 0; i < hw->mac.max_rx_queues; i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
-					IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
+		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 95240ab..ac35324 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -860,63 +860,68 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 }
 
 #ifdef CONFIG_IXGBE_DCA
-static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rx_ring,
+static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *tx_ring,
 				int cpu)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 rxctrl;
-	u8 reg_idx = rx_ring->reg_idx;
+	u32 txctrl = dca3_get_tag(tx_ring->dev, cpu);
+	u16 reg_offset;
 
-	rxctrl = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(reg_idx));
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-		rxctrl |= dca3_get_tag(rx_ring->dev, cpu);
+		reg_offset = IXGBE_DCA_TXCTRL(tx_ring->reg_idx);
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
-		rxctrl |= (dca3_get_tag(rx_ring->dev, cpu) <<
-			   IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
+		reg_offset = IXGBE_DCA_TXCTRL_82599(tx_ring->reg_idx);
+		txctrl <<= IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599;
 		break;
 	default:
-		break;
+		/* for unknown hardware do not write register */
+		return;
 	}
-	rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
-	rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
-	rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
-	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
+
+	/*
+	 * We can enable relaxed ordering for reads, but not writes when
+	 * DCA is enabled.  This is due to a known issue in some chipsets
+	 * which will cause the DCA tag to be cleared.
+	 */
+	txctrl |= IXGBE_DCA_TXCTRL_DESC_RRO_EN |
+		  IXGBE_DCA_TXCTRL_DATA_RRO_EN |
+		  IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+
+	IXGBE_WRITE_REG(hw, reg_offset, txctrl);
 }
 
-static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *tx_ring,
+static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *rx_ring,
 				int cpu)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 txctrl;
-	u8 reg_idx = tx_ring->reg_idx;
+	u32 rxctrl = dca3_get_tag(rx_ring->dev, cpu);
+	u8 reg_idx = rx_ring->reg_idx;
+
 
 	switch (hw->mac.type) {
-	case ixgbe_mac_82598EB:
-		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(reg_idx));
-		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-		txctrl |= dca3_get_tag(tx_ring->dev, cpu);
-		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(reg_idx), txctrl);
-		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx));
-		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
-		txctrl |= (dca3_get_tag(tx_ring->dev, cpu) <<
-			   IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
-		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx), txctrl);
+		rxctrl <<= IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599;
 		break;
 	default:
 		break;
 	}
+
+	/*
+	 * We can enable relaxed ordering for reads, but not writes when
+	 * DCA is enabled.  This is due to a known issue in some chipsets
+	 * which will cause the DCA tag to be cleared.
+	 */
+	rxctrl |= IXGBE_DCA_RXCTRL_DESC_RRO_EN |
+		  IXGBE_DCA_RXCTRL_DATA_DCA_EN |
+		  IXGBE_DCA_RXCTRL_DESC_DCA_EN;
+
+	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
 }
 
 static void ixgbe_update_dca(struct ixgbe_q_vector *q_vector)
@@ -991,8 +996,8 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 
 	return 0;
 }
-#endif /* CONFIG_IXGBE_DCA */
 
+#endif /* CONFIG_IXGBE_DCA */
 static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 				 union ixgbe_adv_rx_desc *rx_desc,
 				 struct sk_buff *skb)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 4c06029..54e2a5e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1021,14 +1021,16 @@
 #define IXGBE_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
 #define IXGBE_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
 #define IXGBE_DCA_RXCTRL_DESC_RRO_EN (1 << 9) /* DCA Rx rd Desc Relax Order */
-#define IXGBE_DCA_RXCTRL_DESC_WRO_EN (1 << 13) /* DCA Rx wr Desc Relax Order */
-#define IXGBE_DCA_RXCTRL_DESC_HSRO_EN (1 << 15) /* DCA Rx Split Header RO */
+#define IXGBE_DCA_RXCTRL_DATA_WRO_EN (1 << 13) /* Rx wr data Relax Order */
+#define IXGBE_DCA_RXCTRL_HEAD_WRO_EN (1 << 15) /* Rx wr header RO */
 
 #define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
 #define IXGBE_DCA_TXCTRL_CPUID_MASK_82599  0xFF000000 /* Tx CPUID Mask */
 #define IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599 24 /* Tx CPUID Shift */
 #define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
-#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_DESC_RRO_EN (1 << 9) /* Tx rd Desc Relax Order */
+#define IXGBE_DCA_TXCTRL_DESC_WRO_EN (1 << 11) /* Tx Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_DATA_RRO_EN (1 << 13) /* Tx rd data Relax Order */
 #define IXGBE_DCA_MAX_QUEUES_82598   16 /* DCA regs only on 16 queues */
 
 /* MSCA Bit Masks */
-- 
1.7.7.6
