From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Add support for BM PHYs on ICH9
Date: Tue, 29 Apr 2008 09:16:05 -0700
Message-ID: <20080429161605.16923.73468.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34664 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294AbYD2QQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 12:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This patch adds support for the BM PHY, a new PHY model being used
on ICH9-based implementations.

This new PHY exposes issues in the ICH9 silicon when receiving
jumbo frames large enough to use more than a certain part of the
Rx FIFO, and this unfortunately breaks packet split jumbo receives.
For this reason we re-introduce (for affected adapters only) the
jumbo single-skb receive routine back so that people who do
wish to use jumbo frames on these ich9 platforms can do so.
Part of this problem has to do with CPU sleep states and to make
sure that all the wake up timings are correctly we force them
with the recently merged pm_qos infrastructure written by Mark
Gross. (See http://lkml.org/lkml/2007/10/4/400).

To make code read a bit easier we introduce a _IS_ICH flag so
that we don't need to do mac type checks over the code.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/defines.h |   10 +
 drivers/net/e1000e/e1000.h   |    7 +
 drivers/net/e1000e/ethtool.c |   39 ++++-
 drivers/net/e1000e/hw.h      |   22 +++
 drivers/net/e1000e/ich8lan.c |   83 ++++++++++-
 drivers/net/e1000e/netdev.c  |  330 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/e1000e/phy.c     |  278 +++++++++++++++++++++++++++++++++++
 7 files changed, 748 insertions(+), 21 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 2a53875..f823b8b 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -648,6 +648,8 @@
 #define IFE_E_PHY_ID         0x02A80330
 #define IFE_PLUS_E_PHY_ID    0x02A80320
 #define IFE_C_E_PHY_ID       0x02A80310
+#define BME1000_E_PHY_ID     0x01410CB0
+#define BME1000_E_PHY_ID_R2  0x01410CB1
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
@@ -701,6 +703,14 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
+/* BME1000 PHY Specific Control Register */
+#define BME1000_PSCR_ENABLE_DOWNSHIFT   0x0800 /* 1 = enable downshift */
+
+
+#define PHY_PAGE_SHIFT 5
+#define PHY_REG(page, reg) (((page) << PHY_PAGE_SHIFT) | \
+                           ((reg) & MAX_PHY_REG_ADDRESS))
+
 /*
  * Bits...
  * 15-5: page
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 38bfd0d..d3bc6f8 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -127,7 +127,7 @@ struct e1000_buffer {
 		/* arrays of page information for packet split */
 		struct e1000_ps_page *ps_pages;
 	};
-
+	struct page *page;
 };
 
 struct e1000_ring {
@@ -304,6 +304,7 @@ struct e1000_info {
 #define FLAG_HAS_CTRLEXT_ON_LOAD          (1 << 5)
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
+#define FLAG_IS_ICH                       (1 << 9)
 #define FLAG_HAS_SMART_POWER_DOWN         (1 << 11)
 #define FLAG_IS_QUAD_PORT_A               (1 << 12)
 #define FLAG_IS_QUAD_PORT                 (1 << 13)
@@ -386,6 +387,7 @@ extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state);
 extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
 extern void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
+extern void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw);
 
 extern s32 e1000e_check_for_copper_link(struct e1000_hw *hw);
 extern s32 e1000e_check_for_fiber_link(struct e1000_hw *hw);
@@ -443,6 +445,9 @@ extern s32 e1000e_get_phy_info_m88(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data);
 extern enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id);
+extern s32 e1000e_determine_phy_address(struct e1000_hw *hw);
+extern s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data);
 extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index ce045ac..2bb6da0 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -803,8 +803,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	/* restore previous status */
 	ew32(STATUS, before);
 
-	if ((mac->type != e1000_ich8lan) &&
-	    (mac->type != e1000_ich9lan)) {
+	if (!(adapter->flags & FLAG_IS_ICH)) {
 		REG_PATTERN_TEST(E1000_FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCAH, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCT, 0x0000FFFF, 0xFFFFFFFF);
@@ -824,15 +823,13 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x00000000);
 
-	before = (((mac->type == e1000_ich8lan) ||
-		   (mac->type == e1000_ich9lan)) ? 0x06C3B33E : 0x06DFB3FE);
+	before = ((adapter->flags & FLAG_IS_ICH) ? 0x06C3B33E : 0x06DFB3FE);
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
 	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-	if ((mac->type != e1000_ich8lan) &&
-	    (mac->type != e1000_ich9lan))
+	if (!(adapter->flags & FLAG_IS_ICH))
 		REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
 	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
@@ -911,9 +908,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Test each interrupt */
 	for (i = 0; i < 10; i++) {
-
-		if (((adapter->hw.mac.type == e1000_ich8lan) ||
-		     (adapter->hw.mac.type == e1000_ich9lan)) && i == 8)
+		if ((adapter->flags & FLAG_IS_ICH) && (i == 8))
 			continue;
 
 		/* Interrupt to test */
@@ -1184,6 +1179,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
+	u16 phy_reg = 0;
 
 	hw->mac.autoneg = 0;
 
@@ -1211,6 +1207,28 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_SPD_100 |/* Force Speed to 100 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 		break;
+	case e1000_phy_bm:
+		/* Set Default MAC Interface speed to 1GB */
+		e1e_rphy(hw, PHY_REG(2, 21), &phy_reg);
+		phy_reg &= ~0x0007;
+		phy_reg |= 0x006;
+		e1e_wphy(hw, PHY_REG(2, 21), phy_reg);
+		/* Assert SW reset for above settings to take effect */
+		e1000e_commit_phy(hw);
+		mdelay(1);
+		/* Force Full Duplex */
+		e1e_rphy(hw, PHY_REG(769, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 16), phy_reg | 0x000C);
+		/* Set Link Up (in force link) */
+		e1e_rphy(hw, PHY_REG(776, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(776, 16), phy_reg | 0x0040);
+		/* Force Link */
+		e1e_rphy(hw, PHY_REG(769, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 16), phy_reg | 0x0040);
+		/* Set Early Link Enable */
+		e1e_rphy(hw, PHY_REG(769, 20), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 20), phy_reg | 0x0400);
+		/* fall through */
 	default:
 		/* force 1000, set loopback */
 		e1e_wphy(hw, PHY_CONTROL, 0x4140);
@@ -1224,8 +1242,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 
-		if ((adapter->hw.mac.type == e1000_ich8lan) ||
-		    (adapter->hw.mac.type == e1000_ich9lan))
+		if (adapter->flags & FLAG_IS_ICH)
 			ctrl_reg |= E1000_CTRL_SLU;	/* Set Link Up */
 	}
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a930e6d..74f263a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -216,6 +216,21 @@ enum e1e_registers {
 #define IGP01E1000_PHY_LINK_HEALTH	0x13 /* PHY Link Health */
 #define IGP02E1000_PHY_POWER_MGMT	0x19 /* Power Management */
 #define IGP01E1000_PHY_PAGE_SELECT	0x1F /* Page Select */
+#define BM_PHY_PAGE_SELECT		22   /* Page Select for BM */
+#define IGP_PAGE_SHIFT			5
+#define PHY_REG_MASK			0x1F
+
+#define BM_WUC_PAGE			800
+#define BM_WUC_ADDRESS_OPCODE		0x11
+#define BM_WUC_DATA_OPCODE		0x12
+#define BM_WUC_ENABLE_PAGE		769
+#define BM_WUC_ENABLE_REG		17
+#define BM_WUC_ENABLE_BIT		(1 << 2)
+#define BM_WUC_HOST_WU_BIT		(1 << 4)
+
+#define BM_WUC	PHY_REG(BM_WUC_PAGE, 1)
+#define BM_WUFC PHY_REG(BM_WUC_PAGE, 2)
+#define BM_WUS	PHY_REG(BM_WUC_PAGE, 3)
 
 #define IGP01E1000_PHY_PCS_INIT_REG	0x00B4
 #define IGP01E1000_PHY_POLARITY_MASK	0x0078
@@ -331,10 +346,16 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH8_IFE_G			0x10C5
 #define E1000_DEV_ID_ICH8_IGP_M			0x104D
 #define E1000_DEV_ID_ICH9_IGP_AMT		0x10BD
+#define E1000_DEV_ID_ICH9_IGP_M_AMT		0x10F5
+#define E1000_DEV_ID_ICH9_IGP_M			0x10BF
+#define E1000_DEV_ID_ICH9_IGP_M_V		0x10CB
 #define E1000_DEV_ID_ICH9_IGP_C			0x294C
 #define E1000_DEV_ID_ICH9_IFE			0x10C0
 #define E1000_DEV_ID_ICH9_IFE_GT		0x10C3
 #define E1000_DEV_ID_ICH9_IFE_G			0x10C2
+#define E1000_DEV_ID_ICH10_R_BM_LM		0x10CC
+#define E1000_DEV_ID_ICH10_R_BM_LF		0x10CD
+#define E1000_DEV_ID_ICH10_R_BM_V		0x10CE
 
 #define E1000_FUNC_1 1
 
@@ -378,6 +399,7 @@ enum e1000_phy_type {
 	e1000_phy_gg82563,
 	e1000_phy_igp_3,
 	e1000_phy_ife,
+	e1000_phy_bm,
 };
 
 enum e1000_bus_width {
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 768485d..9e38452 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -38,6 +38,12 @@
  * 82566DM Gigabit Network Connection
  * 82566MC Gigabit Network Connection
  * 82566MM Gigabit Network Connection
+ * 82567LM Gigabit Network Connection
+ * 82567LF Gigabit Network Connection
+ * 82567LM-2 Gigabit Network Connection
+ * 82567LF-2 Gigabit Network Connection
+ * 82567V-2 Gigabit Network Connection
+ * 82562GT-3 10/100 Network Connection
  */
 
 #include <linux/netdevice.h>
@@ -198,6 +204,19 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	phy->addr			= 1;
 	phy->reset_delay_us		= 100;
 
+	/*
+	 * We may need to do this twice - once for IGP and if that fails,
+	 * we'll set BM func pointers and try again
+	 */
+	ret_val = e1000e_determine_phy_address(hw);
+	if (ret_val) {
+		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
+		hw->phy.ops.read_phy_reg  = e1000e_read_phy_reg_bm;
+		ret_val = e1000e_determine_phy_address(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	phy->id = 0;
 	while ((e1000_phy_unknown == e1000e_get_phy_type_from_id(phy->id)) &&
 	       (i++ < 100)) {
@@ -219,6 +238,13 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		phy->type = e1000_phy_ife;
 		phy->autoneg_mask = E1000_ALL_NOT_GIG;
 		break;
+	case BME1000_E_PHY_ID:
+		phy->type = e1000_phy_bm;
+		phy->autoneg_mask = AUTONEG_ADVERTISE_SPEED_DEFAULT;
+		hw->phy.ops.read_phy_reg = e1000e_read_phy_reg_bm;
+		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
+		hw->phy.ops.commit_phy = e1000e_phy_sw_reset;
+		break;
 	default:
 		return -E1000_ERR_PHY;
 		break;
@@ -664,6 +690,7 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
 		return e1000_get_phy_info_ife_ich8lan(hw);
 		break;
 	case e1000_phy_igp_3:
+	case e1000_phy_bm:
 		return e1000e_get_phy_info_igp(hw);
 		break;
 	default:
@@ -728,7 +755,7 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	s32 ret_val = 0;
 	u16 data;
 
-	if (phy->type != e1000_phy_igp_3)
+	if (phy->type == e1000_phy_ife)
 		return ret_val;
 
 	phy_ctrl = er32(PHY_CTRL);
@@ -1918,8 +1945,35 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 		ret_val = e1000e_copper_link_setup_igp(hw);
 		if (ret_val)
 			return ret_val;
+	} else if (hw->phy.type == e1000_phy_bm) {
+		ret_val = e1000e_copper_link_setup_m88(hw);
+		if (ret_val)
+			return ret_val;
 	}
 
+	if (hw->phy.type == e1000_phy_ife) {
+		ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		reg_data &= ~IFE_PMC_AUTO_MDIX;
+
+		switch (hw->phy.mdix) {
+		case 1:
+			reg_data &= ~IFE_PMC_FORCE_MDIX;
+			break;
+		case 2:
+			reg_data |= IFE_PMC_FORCE_MDIX;
+			break;
+		case 0:
+		default:
+			reg_data |= IFE_PMC_AUTO_MDIX;
+			break;
+		}
+		ret_val = e1e_wphy(hw, IFE_PHY_MDIX_CONTROL, reg_data);
+		if (ret_val)
+			return ret_val;
+	}
 	return e1000e_setup_copper_link(hw);
 }
 
@@ -2127,6 +2181,31 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000e_disable_gig_wol_ich8lan - disable gig during WoL
+ *  @hw: pointer to the HW structure
+ *
+ *  During S0 to Sx transition, it is possible the link remains at gig
+ *  instead of negotiating to a lower speed.  Before going to Sx, set
+ *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
+ *  to a lower speed.
+ *
+ *  Should only be called for ICH9 devices.
+ **/
+void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
+{
+	u32 phy_ctrl;
+
+	if (hw->mac.type == e1000_ich9lan) {
+		phy_ctrl = er32(PHY_CTRL);
+		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU |
+		            E1000_PHY_CTRL_GBE_DISABLE;
+		ew32(PHY_CTRL, phy_ctrl);
+	}
+
+	return;
+}
+
+/**
  *  e1000_cleanup_led_ich8lan - Restore the default LED operation
  *  @hw: pointer to the HW structure
  *
@@ -2247,6 +2326,7 @@ static struct e1000_nvm_operations ich8_nvm_ops = {
 struct e1000_info e1000_ich8_info = {
 	.mac			= e1000_ich8lan,
 	.flags			= FLAG_HAS_WOL
+				  | FLAG_IS_ICH
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
@@ -2262,6 +2342,7 @@ struct e1000_info e1000_ich8_info = {
 struct e1000_info e1000_ich9_info = {
 	.mac			= e1000_ich9lan,
 	.flags			= FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_IS_ICH
 				  | FLAG_HAS_WOL
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8991ab8..8cbb40f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -43,10 +43,11 @@
 #include <linux/if_vlan.h>
 #include <linux/cpu.h>
 #include <linux/smp.h>
+#include <linux/pm_qos_params.h>
 
 #include "e1000.h"
 
-#define DRV_VERSION "0.2.1"
+#define DRV_VERSION "0.3.3.3-k2"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -341,6 +342,89 @@ no_buffers:
 }
 
 /**
+ * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
+ * @adapter: address of board private structure
+ * @rx_ring: pointer to receive ring structure
+ * @cleaned_count: number of buffers to allocate this pass
+ **/
+
+static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
+                                         int cleaned_count)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_rx_desc *rx_desc;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int bufsz = 256 -
+	                     16 /* for skb_reserve */ -
+	                     NET_IP_ALIGN;
+
+	i = rx_ring->next_to_use;
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (cleaned_count--) {
+		skb = buffer_info->skb;
+		if (skb) {
+			skb_trim(skb, 0);
+			goto check_page;
+		}
+
+		skb = netdev_alloc_skb(netdev, bufsz);
+		if (unlikely(!skb)) {
+			/* Better luck next round */
+			adapter->alloc_rx_buff_failed++;
+			break;
+		}
+
+		/* Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		buffer_info->skb = skb;
+check_page:
+		/* allocate a new page if necessary */
+		if (!buffer_info->page) {
+			buffer_info->page = alloc_page(GFP_ATOMIC);
+			if (unlikely(!buffer_info->page)) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+		}
+
+		if (!buffer_info->dma)
+			buffer_info->dma = pci_map_page(pdev,
+			                                buffer_info->page, 0,
+			                                PAGE_SIZE,
+			                                PCI_DMA_FROMDEVICE);
+
+		rx_desc = E1000_RX_DESC(*rx_ring, i);
+		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
+
+		if (unlikely(++i == rx_ring->count))
+			i = 0;
+		buffer_info = &rx_ring->buffer_info[i];
+	}
+
+	if (likely(rx_ring->next_to_use != i)) {
+		rx_ring->next_to_use = i;
+		if (unlikely(i-- == 0))
+			i = (rx_ring->count - 1);
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64). */
+		wmb();
+		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+	}
+}
+
+/**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  *
@@ -783,6 +867,186 @@ next_desc:
 }
 
 /**
+ * e1000_consume_page - helper function
+ **/
+static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
+                               u16 length)
+{
+	bi->page = NULL;
+	skb->len += length;
+	skb->data_len += length;
+	skb->truesize += length;
+}
+
+/**
+ * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
+ * @adapter: board private structure
+ *
+ * the return value indicates whether actual cleaning was done, there
+ * is no guarantee that everything was cleaned
+ **/
+
+static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
+                                     int *work_done, int work_to_do)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_rx_desc *rx_desc, *next_rxd;
+	struct e1000_buffer *buffer_info, *next_buffer;
+	u32 length;
+	unsigned int i;
+	int cleaned_count = 0;
+	bool cleaned = false;
+	unsigned int total_rx_bytes=0, total_rx_packets=0;
+
+	i = rx_ring->next_to_clean;
+	rx_desc = E1000_RX_DESC(*rx_ring, i);
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (rx_desc->status & E1000_RXD_STAT_DD) {
+		struct sk_buff *skb;
+		u8 status;
+
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+
+		status = rx_desc->status;
+		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
+
+		++i;
+		if (i == rx_ring->count)
+			i = 0;
+		next_rxd = E1000_RX_DESC(*rx_ring, i);
+		prefetch(next_rxd);
+
+		next_buffer = &rx_ring->buffer_info[i];
+
+		cleaned = true;
+		cleaned_count++;
+		pci_unmap_page(pdev, buffer_info->dma, PAGE_SIZE,
+		               PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
+
+		length = le16_to_cpu(rx_desc->length);
+
+		/* errors is only valid for DD + EOP descriptors */
+		if (unlikely((status & E1000_RXD_STAT_EOP) &&
+		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
+				/* recycle both page and skb */
+				buffer_info->skb = skb;
+				/* an error means any chain goes out the window
+				 * too */
+				if (rx_ring->rx_skb_top)
+					dev_kfree_skb(rx_ring->rx_skb_top);
+				rx_ring->rx_skb_top = NULL;
+				goto next_desc;
+		}
+
+#define rxtop rx_ring->rx_skb_top
+		if (!(status & E1000_RXD_STAT_EOP)) {
+			/* this descriptor is only the beginning (or middle) */
+			if (!rxtop) {
+				/* this is the beginning of a chain */
+				rxtop = skb;
+				skb_fill_page_desc(rxtop, 0, buffer_info->page,
+				                   0, length);
+			} else {
+				/* this is the middle of a chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the skb, only consumed the page */
+				buffer_info->skb = skb;
+			}
+			e1000_consume_page(buffer_info, rxtop, length);
+			goto next_desc;
+		} else {
+			if (rxtop) {
+				/* end of the chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the current skb, we only consumed the
+				 * page */
+				buffer_info->skb = skb;
+				skb = rxtop;
+				rxtop = NULL;
+				e1000_consume_page(buffer_info, skb, length);
+			} else {
+				/* no chain, got EOP, this buf is the packet
+				 * copybreak to save the put_page/alloc_page */
+				if (length <= copybreak &&
+				    skb_tailroom(skb) >= length) {
+					u8 *vaddr;
+					vaddr = kmap_atomic(buffer_info->page,
+					                   KM_SKB_DATA_SOFTIRQ);
+					memcpy(skb_tail_pointer(skb), vaddr,
+					       length);
+					kunmap_atomic(vaddr,
+					              KM_SKB_DATA_SOFTIRQ);
+					/* re-use the page, so don't erase
+					 * buffer_info->page */
+					skb_put(skb, length);
+				} else {
+					skb_fill_page_desc(skb, 0,
+					                   buffer_info->page, 0,
+				                           length);
+					e1000_consume_page(buffer_info, skb,
+					                   length);
+				}
+			}
+		}
+
+		/* Receive Checksum Offload XXX recompute due to CRC strip? */
+		e1000_rx_checksum(adapter,
+		                  (u32)(status) |
+		                  ((u32)(rx_desc->errors) << 24),
+		                  le16_to_cpu(rx_desc->csum), skb);
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
+		/* eth type trans needs skb->data to point to something */
+		if (!pskb_may_pull(skb, ETH_HLEN)) {
+			ndev_err(netdev, "pskb_may_pull failed.\n");
+			dev_kfree_skb(skb);
+			goto next_desc;
+		}
+
+		e1000_receive_skb(adapter, netdev, skb, status,
+		                  rx_desc->special);
+
+next_desc:
+		rx_desc->status = 0;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
+			adapter->alloc_rx_buf(adapter, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		/* use prefetched values */
+		rx_desc = next_rxd;
+		buffer_info = next_buffer;
+	}
+	rx_ring->next_to_clean = i;
+
+	cleaned_count = e1000_desc_unused(rx_ring);
+	if (cleaned_count)
+		adapter->alloc_rx_buf(adapter, cleaned_count);
+
+	adapter->total_rx_bytes += total_rx_bytes;
+	adapter->total_rx_packets += total_rx_packets;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+	return cleaned;
+}
+
+/**
  * e1000_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
  **/
@@ -802,6 +1066,10 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_buffer_len,
 						 PCI_DMA_FROMDEVICE);
+			else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq)
+				pci_unmap_page(pdev, buffer_info->dma,
+				               PAGE_SIZE,
+				               PCI_DMA_FROMDEVICE);
 			else if (adapter->clean_rx == e1000_clean_rx_irq_ps)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_ps_bsize0,
@@ -809,6 +1077,11 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 			buffer_info->dma = 0;
 		}
 
+		if (buffer_info->page) {
+			put_page(buffer_info->page);
+			buffer_info->page = NULL;
+		}
+
 		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
@@ -1755,10 +2028,12 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	 * a lot of memory, since we allocate 3 pages at all times
 	 * per packet.
 	 */
-	adapter->rx_ps_pages = 0;
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((pages <= 3) && (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
+	if (!(adapter->flags & FLAG_IS_ICH) && (pages <= 3) &&
+	    (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
+	else
+		adapter->rx_ps_pages = 0;
 
 	if (adapter->rx_ps_pages) {
 		/* Configure extra packet-split registers */
@@ -1819,9 +2094,12 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			sizeof(union e1000_rx_desc_packet_split);
 		adapter->clean_rx = e1000_clean_rx_irq_ps;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
+	} else if (adapter->netdev->mtu > ETH_FRAME_LEN + ETH_FCS_LEN) {
+		rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
+		adapter->clean_rx = e1000_clean_jumbo_rx_irq;
+		adapter->alloc_rx_buf = e1000_alloc_jumbo_rx_buffers;
 	} else {
-		rdlen = rx_ring->count *
-			sizeof(struct e1000_rx_desc);
+		rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
 		adapter->clean_rx = e1000_clean_rx_irq;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
 	}
@@ -1885,8 +2163,21 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
 	 */
 	if ((adapter->flags & FLAG_HAS_ERT) &&
-	    (adapter->netdev->mtu > ETH_DATA_LEN))
-		ew32(ERT, E1000_ERT_2048);
+	    (adapter->netdev->mtu > ETH_DATA_LEN)) {
+		u32 rxdctl = er32(RXDCTL(0));
+		ew32(RXDCTL(0), rxdctl | 0x3);
+		ew32(ERT, E1000_ERT_2048 | (1 << 13));
+		/*
+		 * With jumbo frames and early-receive enabled, excessive
+		 * C4->C2 latencies result in dropped transactions.
+		 */
+		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+					  e1000e_driver_name, 55);
+	} else {
+		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+					  e1000e_driver_name,
+					  PM_QOS_DEFAULT_VALUE);
+	}
 
 	/* Enable Receives */
 	ew32(RCTL, rctl);
@@ -2155,6 +2446,14 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
+
+	/*
+	 * For parts with AMT enabled, let the firmware know
+	 * that the network interface is in control
+	 */
+	if ((adapter->flags & FLAG_HAS_AMT) && e1000e_check_mng_mode(hw))
+		e1000_get_hw_control(adapter);
+
 	ew32(WUC, 0);
 
 	if (mac->ops.init_hw(hw))
@@ -3469,6 +3768,8 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
 	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 * However with the new *_jumbo_rx* routines, jumbo receives will use
+	 * fragmented skbs
 	 */
 
 	if (max_frame <= 256)
@@ -3626,6 +3927,9 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 			ew32(CTRL_EXT, ctrl_ext);
 		}
 
+		if (adapter->flags & FLAG_IS_ICH)
+			e1000e_disable_gig_wol_ich8lan(&adapter->hw);
+
 		/* Allow time for pending master requests to run */
 		e1000e_disable_pcie_master(&adapter->hw);
 
@@ -4292,6 +4596,13 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_C), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_AMT), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_V), board_ich9lan },
+
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_LM), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_LF), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_V), board_ich9lan },
 
 	{ }	/* terminate list */
 };
@@ -4326,7 +4637,9 @@ static int __init e1000_init_module(void)
 	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
-
+	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name,
+			       PM_QOS_DEFAULT_VALUE);
+				
 	return ret;
 }
 module_init(e1000_init_module);
@@ -4340,6 +4653,7 @@ module_init(e1000_init_module);
 static void __exit e1000_exit_module(void)
 {
 	pci_unregister_driver(&e1000_driver);
+	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name);
 }
 module_exit(e1000_exit_module);
 
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index e102332..b133dcf 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -34,6 +34,9 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
+static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg);
+static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
+					  u16 *data, bool read);
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
@@ -465,6 +468,10 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	if (phy->disable_polarity_correction == 1)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
+	/* Enable downshift on BM (disabled by default) */
+	if (phy->type == e1000_phy_bm)
+		phy_data |= BME1000_PSCR_ENABLE_DOWNSHIFT;
+
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
 		return ret_val;
@@ -1776,6 +1783,10 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 	case IFE_C_E_PHY_ID:
 		phy_type = e1000_phy_ife;
 		break;
+	case BME1000_E_PHY_ID:
+	case BME1000_E_PHY_ID_R2:
+		phy_type = e1000_phy_bm;
+		break;
 	default:
 		phy_type = e1000_phy_unknown;
 		break;
@@ -1784,6 +1795,273 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 }
 
 /**
+ *  e1000e_determine_phy_address - Determines PHY address.
+ *  @hw: pointer to the HW structure
+ *
+ *  This uses a trial and error method to loop through possible PHY
+ *  addresses. It tests each by reading the PHY ID registers and
+ *  checking for a match.
+ **/
+s32 e1000e_determine_phy_address(struct e1000_hw *hw)
+{
+	s32 ret_val = -E1000_ERR_PHY_TYPE;
+	u32 phy_addr= 0;
+	u32 i = 0;
+	enum e1000_phy_type phy_type = e1000_phy_unknown;
+
+	do {
+		for (phy_addr = 0; phy_addr < 4; phy_addr++) {
+			hw->phy.addr = phy_addr;
+			e1000e_get_phy_id(hw);
+			phy_type = e1000e_get_phy_type_from_id(hw->phy.id);
+
+			/* 
+			 * If phy_type is valid, break - we found our
+			 * PHY address
+			 */
+			if (phy_type  != e1000_phy_unknown) {
+				ret_val = 0;
+				break;
+			}
+		}
+		i++;
+	} while ((ret_val != 0) && (i < 100));
+
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_addr_for_bm_page - Retrieve PHY page address
+ *  @page: page to access
+ *
+ *  Returns the phy address for the page requested.
+ **/
+static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg)
+{
+	u32 phy_addr = 2;
+
+	if ((page >= 768) || (page == 0 && reg == 25) || (reg == 31))
+		phy_addr = 1;
+
+	return phy_addr;
+}
+
+/**
+ *  e1000e_write_phy_reg_bm - Write BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	s32 ret_val;
+	u32 page_select = 0;
+	u32 page = offset >> IGP_PAGE_SHIFT;
+	u32 page_shift = 0;
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
+							 false);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		/*
+		 * Page select is register 31 for phy address 1 and 22 for
+		 * phy address 2 and 3. Page select is shifted only for
+		 * phy address 1.
+		 */
+		if (hw->phy.addr == 1) {
+			page_shift = IGP_PAGE_SHIFT;
+			page_select = IGP01E1000_PHY_PAGE_SELECT;
+		} else {
+			page_shift = 0;
+			page_select = BM_PHY_PAGE_SELECT;
+		}
+
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
+		                                    (page << page_shift));
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                    data);
+
+	hw->phy.ops.release_phy(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000e_read_phy_reg_bm - Read BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting.
+ **/
+s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	s32 ret_val;
+	u32 page_select = 0;
+	u32 page = offset >> IGP_PAGE_SHIFT;
+	u32 page_shift = 0;
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
+							 true);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		/*
+		 * Page select is register 31 for phy address 1 and 22 for
+		 * phy address 2 and 3. Page select is shifted only for
+		 * phy address 1.
+		 */
+		if (hw->phy.addr == 1) {
+			page_shift = IGP_PAGE_SHIFT;
+			page_select = IGP01E1000_PHY_PAGE_SELECT;
+		} else {
+			page_shift = 0;
+			page_select = BM_PHY_PAGE_SELECT;
+		}
+
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
+		                                    (page << page_shift));
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                   data);
+	hw->phy.ops.release_phy(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_access_phy_wakeup_reg_bm - Read BM PHY wakeup register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read or written
+ *  @data: pointer to the data to read or write
+ *  @read: determines if operation is read or write
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting. Note that procedure to read the wakeup
+ *  registers are different. It works as such:
+ *  1) Set page 769, register 17, bit 2 = 1
+ *  2) Set page to 800 for host (801 if we were manageability)
+ *  3) Write the address using the address opcode (0x11)
+ *  4) Read or write the data using the data opcode (0x12)
+ *  5) Restore 769_17.2 to its original value
+ **/
+static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
+					  u16 *data, bool read)
+{
+	s32 ret_val;
+	u16 reg = ((u16)offset) & PHY_REG_MASK;
+	u16 phy_reg = 0;
+	u8  phy_acquired = 1;
+
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val) {
+		phy_acquired = 0;
+		goto out;
+	}
+
+	/* All operations in this function are phy address 1 */
+	hw->phy.addr = 1;
+
+	/* Set page 769 */
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+
+	ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
+	if (ret_val)
+		goto out;
+
+	/* First clear bit 4 to avoid a power state change */
+	phy_reg &= ~(BM_WUC_HOST_WU_BIT);
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+	if (ret_val)
+		goto out;
+
+	/* Write bit 2 = 1, and clear bit 4 to 769_17 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG,
+	                                    phy_reg | BM_WUC_ENABLE_BIT);
+	if (ret_val)
+		goto out;
+
+	/* Select page 800 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                                    (BM_WUC_PAGE << IGP_PAGE_SHIFT));
+
+	/* Write the page 800 offset value using opcode 0x11 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ADDRESS_OPCODE, reg);
+	if (ret_val)
+		goto out;
+
+	if (read) {
+	        /* Read the page 800 value using opcode 0x12 */
+		ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
+		                                   data);
+	} else {
+	        /* Read the page 800 value using opcode 0x12 */
+		ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
+						    *data);
+	}
+
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Restore 769_17.2 to its original value
+	 * Set page 769
+	 */
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+
+	/* Clear 769_17.2 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+
+out:
+	if (phy_acquired == 1)
+		hw->phy.ops.release_phy(hw);
+	return ret_val;
+}
+
+/**
  *  e1000e_commit_phy - Soft PHY reset
  *  @hw: pointer to the HW structure
  *

