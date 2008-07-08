From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND NET-NEXT PATCH 13/20] igb: add 82576 MAC support
Date: Tue, 08 Jul 2008 15:10:12 -0700
Message-ID: <20080708220942.1518.54857.stgit@localhost.localdomain>
References: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44595 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590AbYGHWKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:10:21 -0400
In-Reply-To: <20080708220046.1518.88457.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |  208 +++++++++++++++++++++++++++++++++++++--
 drivers/net/igb/e1000_82575.h   |    9 ++
 drivers/net/igb/e1000_defines.h |   10 ++
 drivers/net/igb/e1000_hw.h      |    8 ++
 drivers/net/igb/e1000_mac.c     |    3 -
 drivers/net/igb/e1000_mac.h     |    1 
 drivers/net/igb/e1000_regs.h    |    7 +
 drivers/net/igb/igb_ethtool.c   |  146 +++++++++++++++++++++------
 drivers/net/igb/igb_main.c      |  170 +++++++++++++++++++++++++-------
 9 files changed, 476 insertions(+), 86 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 2c8b910..e098f23 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -31,6 +31,7 @@
 
 #include <linux/types.h>
 #include <linux/slab.h>
+#include <linux/if_ether.h>
 
 #include "e1000_mac.h"
 #include "e1000_82575.h"
@@ -45,7 +46,6 @@ static s32  igb_get_cfg_done_82575(struct e1000_hw *);
 static s32  igb_init_hw_82575(struct e1000_hw *);
 static s32  igb_phy_hw_reset_sgmii_82575(struct e1000_hw *);
 static s32  igb_read_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16 *);
-static void igb_rar_set_82575(struct e1000_hw *, u8 *, u32);
 static s32  igb_reset_hw_82575(struct e1000_hw *);
 static s32  igb_set_d0_lplu_state_82575(struct e1000_hw *, bool);
 static s32  igb_setup_copper_link_82575(struct e1000_hw *);
@@ -84,6 +84,12 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
 		mac->type = e1000_82575;
 		break;
+	case E1000_DEV_ID_82576:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		mac->type = e1000_82576;
+		break;
 	default:
 		return -E1000_ERR_MAC_INIT;
 		break;
@@ -128,6 +134,8 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	mac->mta_reg_count = 128;
 	/* Set rar entry count */
 	mac->rar_entry_count = E1000_RAR_ENTRIES_82575;
+	if (mac->type == e1000_82576)
+		mac->rar_entry_count = E1000_RAR_ENTRIES_82576;
 	/* Set if part includes ASF firmware */
 	mac->asf_firmware_present = true;
 	/* Set if manageability features are enabled. */
@@ -694,13 +702,12 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
 	if ((hw->phy.media_type != e1000_media_type_copper) ||
 	    (igb_sgmii_active_82575(hw)))
 		ret_val = igb_get_pcs_speed_and_duplex_82575(hw, &speed,
-							       &duplex);
+		                                             &duplex);
 	else
 		ret_val = igb_check_for_copper_link(hw);
 
 	return ret_val;
 }
-
 /**
  *  igb_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
@@ -757,18 +764,129 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  igb_rar_set_82575 - Set receive address register
+ *  igb_init_rx_addrs_82575 - Initialize receive address's
+ *  @hw: pointer to the HW structure
+ *  @rar_count: receive address registers
+ *
+ *  Setups the receive address registers by setting the base receive address
+ *  register to the devices MAC address and clearing all the other receive
+ *  address registers to 0.
+ **/
+static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count)
+{
+	u32 i;
+	u8 addr[6] = {0,0,0,0,0,0};
+	/*
+	 * This function is essentially the same as that of
+	 * e1000_init_rx_addrs_generic. However it also takes care
+	 * of the special case where the register offset of the
+	 * second set of RARs begins elsewhere. This is implicitly taken care by
+	 * function e1000_rar_set_generic.
+	 */
+
+	hw_dbg("e1000_init_rx_addrs_82575");
+
+	/* Setup the receive address */
+	hw_dbg("Programming MAC Address into RAR[0]\n");
+	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
+
+	/* Zero out the other (rar_entry_count - 1) receive addresses */
+	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	for (i = 1; i < rar_count; i++)
+	    hw->mac.ops.rar_set(hw, addr, i);
+}
+
+/**
+ *  igb_update_mc_addr_list_82575 - Update Multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @mc_addr_list: array of multicast addresses to program
+ *  @mc_addr_count: number of multicast addresses to program
+ *  @rar_used_count: the first RAR register free to program
+ *  @rar_count: total number of supported Receive Address Registers
+ *
+ *  Updates the Receive Address Registers and Multicast Table Array.
+ *  The caller must have a packed mc_addr_list of multicast addresses.
+ *  The parameter rar_count will usually be hw->mac.rar_entry_count
+ *  unless there are workarounds that change this.
+ **/
+void igb_update_mc_addr_list_82575(struct e1000_hw *hw,
+                                   u8 *mc_addr_list, u32 mc_addr_count,
+                                   u32 rar_used_count, u32 rar_count)
+{
+	u32 hash_value;
+	u32 i;
+	u8 addr[6] = {0,0,0,0,0,0};
+	/*
+	 * This function is essentially the same as that of 
+	 * igb_update_mc_addr_list_generic. However it also takes care 
+	 * of the special case where the register offset of the 
+	 * second set of RARs begins elsewhere. This is implicitly taken care by 
+	 * function e1000_rar_set_generic.
+	 */
+
+	/*
+	 * Load the first set of multicast addresses into the exact
+	 * filters (RAR).  If there are not enough to fill the RAR
+	 * array, clear the filters.
+	 */
+	for (i = rar_used_count; i < rar_count; i++) {
+		if (mc_addr_count) {
+			igb_rar_set(hw, mc_addr_list, i);
+			mc_addr_count--;
+			mc_addr_list += ETH_ALEN;
+		} else {
+			igb_rar_set(hw, addr, i);
+		}
+	}
+
+	/* Clear the old settings from the MTA */
+	hw_dbg("Clearing MTA\n");
+	for (i = 0; i < hw->mac.mta_reg_count; i++) {
+		array_wr32(E1000_MTA, i, 0);
+		wrfl();
+	}
+
+	/* Load any remaining multicast addresses into the hash table. */
+	for (; mc_addr_count > 0; mc_addr_count--) {
+		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
+		hw_dbg("Hash value = 0x%03X\n", hash_value);
+		hw->mac.ops.mta_set(hw, hash_value);
+		mc_addr_list += ETH_ALEN;
+	}
+}
+
+/**
+ *  igb_shutdown_fiber_serdes_link_82575 - Remove link during power down
  *  @hw: pointer to the HW structure
- *  @addr: pointer to the receive address
- *  @index: receive address array register
  *
- *  Sets the receive address array register at index to the address passed
- *  in by addr.
+ *  In the case of fiber serdes, shut down optics and PCS on driver unload
+ *  when management pass thru is not enabled.
  **/
-static void igb_rar_set_82575(struct e1000_hw *hw, u8 *addr, u32 index)
+void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
 {
-	if (index < E1000_RAR_ENTRIES_82575)
-		igb_rar_set(hw, addr, index);
+	u32 reg;
+
+	if (hw->mac.type != e1000_82576 ||
+	    (hw->phy.media_type != e1000_media_type_fiber &&
+	     hw->phy.media_type != e1000_media_type_internal_serdes))
+		return;
+
+	/* if the management interface is not enabled, then power down */
+	if (!igb_enable_mng_pass_thru(hw)) {
+		/* Disable PCS to turn off link */
+		reg = rd32(E1000_PCS_CFG0);
+		reg &= ~E1000_PCS_CFG_PCS_EN;
+		wr32(E1000_PCS_CFG0, reg);
+
+		/* shutdown the laser */
+		reg = rd32(E1000_CTRL_EXT);
+		reg |= E1000_CTRL_EXT_SDP7_DATA;
+		wr32(E1000_CTRL_EXT, reg);
+
+		/* flush the write to verify completion */
+		wrfl();
+		msleep(1);
+	}
 
 	return;
 }
@@ -854,7 +972,7 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	igb_clear_vfta(hw);
 
 	/* Setup the receive address */
-	igb_init_rx_addrs(hw, rar_count);
+	igb_init_rx_addrs_82575(hw, rar_count);
 	/* Zero out the Multicast HASH table */
 	hw_dbg("Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
@@ -1114,6 +1232,70 @@ out:
 }
 
 /**
+ *  igb_translate_register_82576 - Translate the proper register offset
+ *  @reg: e1000 register to be read
+ *
+ *  Registers in 82576 are located in different offsets than other adapters
+ *  even though they function in the same manner.  This function takes in
+ *  the name of the register to read and returns the correct offset for
+ *  82576 silicon.
+ **/
+u32 igb_translate_register_82576(u32 reg)
+{
+	/*
+	 * Some of the Kawela registers are located at different
+	 * offsets than they are in older adapters.
+	 * Despite the difference in location, the registers
+	 * function in the same manner.
+	 */
+	switch (reg) {
+	case E1000_TDBAL(0):
+		reg = 0x0E000;
+		break;
+	case E1000_TDBAH(0):
+		reg = 0x0E004;
+		break;
+	case E1000_TDLEN(0):
+		reg = 0x0E008;
+		break;
+	case E1000_TDH(0):
+		reg = 0x0E010;
+		break;
+	case E1000_TDT(0):
+		reg = 0x0E018;
+		break;
+	case E1000_TXDCTL(0):
+		reg = 0x0E028;
+		break;
+	case E1000_RDBAL(0):
+		reg = 0x0C000;
+		break;
+	case E1000_RDBAH(0):
+		reg = 0x0C004;
+		break;
+	case E1000_RDLEN(0):
+		reg = 0x0C008;
+		break;
+	case E1000_RDH(0):
+		reg = 0x0C010;
+		break;
+	case E1000_RDT(0):
+		reg = 0x0C018;
+		break;
+	case E1000_RXDCTL(0):
+		reg = 0x0C028;
+		break;
+	case E1000_SRRCTL(0):
+		reg = 0x0C00C;
+		break;
+	default:
+		break;
+	}
+
+	return reg;
+}
+
+/**
  *  igb_reset_init_script_82575 - Inits HW defaults after reset
  *  @hw: pointer to the HW structure
  *
@@ -1304,7 +1486,7 @@ static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.reset_hw             = igb_reset_hw_82575,
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
-	.rar_set              = igb_rar_set_82575,
+	.rar_set              = igb_rar_set,
 	.read_mac_addr        = igb_read_mac_addr_82575,
 	.get_speed_and_duplex = igb_get_speed_and_duplex_copper,
 };
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 02e57a8..d273236 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -28,9 +28,13 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
 
+u32 igb_translate_register_82576(u32 reg);
+void igb_update_mc_addr_list_82575(struct e1000_hw*, u8*, u32, u32, u32);
+extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 
 #define E1000_RAR_ENTRIES_82575   16
+#define E1000_RAR_ENTRIES_82576   24
 
 /* SRRCTL bit definitions */
 #define E1000_SRRCTL_BSIZEPKT_SHIFT                     10 /* Shift _right_ */
@@ -159,5 +163,10 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
 #define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 
+/* Additional DCA related definitions, note change in position of CPUID */
+#define E1000_DCA_TXCTRL_CPUID_MASK_82576 0xFF000000 /* Tx CPUID Mask */
+#define E1000_DCA_RXCTRL_CPUID_MASK_82576 0xFF000000 /* Rx CPUID Mask */
+#define E1000_DCA_TXCTRL_CPUID_SHIFT 24 /* Tx CPUID now in the last byte */
+#define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last byte */
 
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ed748dc..afdba3c 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -90,6 +90,11 @@
 #define E1000_I2CCMD_ERROR            0x80000000
 #define E1000_MAX_SGMII_PHY_REG_ADDR  255
 #define E1000_I2CCMD_PHY_TIMEOUT      200
+#define E1000_IVAR_VALID              0x80
+#define E1000_GPIE_NSICR              0x00000001
+#define E1000_GPIE_MSIX_MODE          0x00000010
+#define E1000_GPIE_EIAME              0x40000000
+#define E1000_GPIE_PBA                0x80000000
 
 /* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
@@ -213,6 +218,7 @@
 /* Device Control */
 #define E1000_CTRL_FD       0x00000001  /* Full duplex.0=half; 1=full */
 #define E1000_CTRL_GIO_MASTER_DISABLE 0x00000004 /*Blocks new Master requests */
+#define E1000_CTRL_LRST     0x00000008  /* Link reset. 0=normal,1=reset */
 #define E1000_CTRL_ASDE     0x00000020  /* Auto-speed detect enable */
 #define E1000_CTRL_SLU      0x00000040  /* Set link up (Force Link) */
 #define E1000_CTRL_ILOS     0x00000080  /* Invert Loss-Of Signal */
@@ -244,6 +250,7 @@
  */
 
 #define E1000_CONNSW_ENRGSRC             0x4
+#define E1000_PCS_CFG_PCS_EN             8
 #define E1000_PCS_LCTL_FLV_LINK_UP       1
 #define E1000_PCS_LCTL_FSV_100           2
 #define E1000_PCS_LCTL_FSV_1000          4
@@ -253,6 +260,7 @@
 #define E1000_PCS_LCTL_AN_ENABLE         0x10000
 #define E1000_PCS_LCTL_AN_RESTART        0x20000
 #define E1000_PCS_LCTL_AN_TIMEOUT        0x40000
+#define E1000_ENABLE_SERDES_LOOPBACK     0x0410
 
 #define E1000_PCS_LSTS_LINK_OK           1
 #define E1000_PCS_LSTS_SPEED_100         2
@@ -360,6 +368,7 @@
 #define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
 #define E1000_PBA_24K 0x0018
 #define E1000_PBA_34K 0x0022
+#define E1000_PBA_64K 0x0040    /* 64KB */
 
 #define IFS_MAX       80
 #define IFS_MIN       40
@@ -528,6 +537,7 @@
 /* PHY Control Register */
 #define MII_CR_FULL_DUPLEX      0x0100  /* FDX =1, half duplex =0 */
 #define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
+#define MII_CR_POWER_DOWN       0x0800  /* Power down */
 #define MII_CR_AUTO_NEG_EN      0x1000  /* Auto Neg Enable */
 #define MII_CR_LOOPBACK         0x4000  /* 0 = normal, 1 = loopback */
 #define MII_CR_RESET            0x8000  /* 0 = normal, 1 = PHY reset */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 746c3ea..19fa4ee 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -38,6 +38,10 @@
 
 struct e1000_hw;
 
+#define E1000_DEV_ID_82576                    0x10C9
+#define E1000_DEV_ID_82576_FIBER              0x10E6
+#define E1000_DEV_ID_82576_SERDES             0x10E7
+#define E1000_DEV_ID_82576_QUAD_COPPER        0x10E8
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
 #define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
@@ -50,6 +54,7 @@ struct e1000_hw;
 enum e1000_mac_type {
 	e1000_undefined = 0,
 	e1000_82575,
+	e1000_82576,
 	e1000_num_macs  /* List is 1-based, so subtract 1 for true count. */
 };
 
@@ -410,14 +415,17 @@ struct e1000_mac_operations {
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
+	bool (*check_mng_mode)(struct e1000_hw *);
 	s32  (*setup_physical_interface)(struct e1000_hw *);
 	void (*rar_set)(struct e1000_hw *, u8 *, u32);
 	s32  (*read_mac_addr)(struct e1000_hw *);
 	s32  (*get_speed_and_duplex)(struct e1000_hw *, u16 *, u16 *);
+	void (*mta_set)(struct e1000_hw *, u32);
 };
 
 struct e1000_phy_operations {
 	s32  (*acquire_phy)(struct e1000_hw *);
+	s32  (*check_reset_block)(struct e1000_hw *);
 	s32  (*force_speed_duplex)(struct e1000_hw *);
 	s32  (*get_cfg_done)(struct e1000_hw *hw);
 	s32  (*get_cable_length)(struct e1000_hw *);
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 47ad2c4..20408aa 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -36,7 +36,6 @@
 
 static s32 igb_set_default_fc(struct e1000_hw *hw);
 static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
-static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
 /**
  *  igb_remove_device - Free device specific structure
@@ -360,7 +359,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
  *  the multicast filter table array address and new table value.  See
  *  igb_mta_set()
  **/
-static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
+u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 {
 	u32 hash_value, hash_mask;
 	u8 bit_shift = 0;
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 326b659..dc2f8cc 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -94,5 +94,6 @@ enum e1000_mng_mode {
 #define E1000_HICR_C               0x02
 
 extern void e1000_init_function_pointers_82575(struct e1000_hw *hw);
+extern u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
 #endif
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index d25e914..b95093d 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -56,6 +56,9 @@
 #define E1000_EIMC     0x01528  /* Ext. Interrupt Mask Clear - WO */
 #define E1000_EIAC     0x0152C  /* Ext. Interrupt Auto Clear - RW */
 #define E1000_EIAM     0x01530  /* Ext. Interrupt Ack Auto Clear Mask - RW */
+#define E1000_GPIE     0x01514  /* General Purpose Interrupt Enable - RW */
+#define E1000_IVAR0    0x01700  /* Interrupt Vector Allocation (array) - RW */
+#define E1000_IVAR_MISC 0x01740 /* IVAR for "other" causes - RW */
 #define E1000_TCTL     0x00400  /* TX Control - RW */
 #define E1000_TCTL_EXT 0x00404  /* Extended TX Control - RW */
 #define E1000_TIPG     0x00410  /* TX Inter-packet gap -RW */
@@ -217,6 +220,7 @@
 #define E1000_RFCTL    0x05008  /* Receive Filter Control*/
 #define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
 #define E1000_RA       0x05400  /* Receive Address - RW Array */
+#define E1000_RA2      0x054E0  /* 2nd half of receive address array - RW Array */
 #define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array */
 #define E1000_VMD_CTL  0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
@@ -258,7 +262,8 @@
 #define E1000_RETA(_i)  (0x05C00 + ((_i) * 4))
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
 
-#define E1000_REGISTER(a, reg) reg
+#define E1000_REGISTER(a, reg) (((a)->mac.type < e1000_82576) \
+                               ? reg : e1000_translate_register_82576(reg))
 
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ed756c1..e27d5a5 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -827,8 +827,9 @@ err_setup:
 /* ethtool register test data */
 struct igb_reg_test {
 	u16 reg;
-	u8  array_len;
-	u8  test_type;
+	u16 reg_offset;
+	u16 array_len;
+	u16 test_type;
 	u32 mask;
 	u32 write;
 };
@@ -850,34 +851,72 @@ struct igb_reg_test {
 #define TABLE64_TEST_LO	5
 #define TABLE64_TEST_HI	6
 
-/* default register test */
+/* 82576 reg test */
+static struct igb_reg_test reg_test_82576[] = {
+	{ E1000_FCAL,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_FCAH,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_FCT,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_VET,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RDBAL(4),  0x40,  8, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(4),  0x40,  8, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(4),  0x40,  8, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	/* Enable all four RX queues before testing. */
+	{ E1000_RXDCTL(0), 0x100, 1,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	/* RDH is read-only for 82576, only test RDT. */
+	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, 0 },
+	{ E1000_FCRTH,	   0x100, 1,  PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
+	{ E1000_FCTTV,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TIPG,	   0x100, 1,  PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
+	{ E1000_TDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDBAL(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(4),  0x40, 8,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0x003FFFFB },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0xFFFFFFFF },
+	{ E1000_TCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_HI, 0x83FFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 8, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 8, TABLE64_TEST_HI, 0x83FFFFFF, 0xFFFFFFFF },
+	{ E1000_MTA,	   0, 128,TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ 0, 0, 0, 0 }
+};
+
+/* 82575 register test */
 static struct igb_reg_test reg_test_82575[] = {
-	{ E1000_FCAL, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_FCAH, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
-	{ E1000_FCT, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
-	{ E1000_VET, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_RDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ E1000_FCAL,      0x100, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_FCAH,      0x100, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_FCT,       0x100, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_VET,       0x100, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	/* Enable all four RX queues before testing. */
-	{ E1000_RXDCTL(0), 4, WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
 	/* RDH is read-only for 82575, only test RDT. */
-	{ E1000_RDT(0), 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
-	{ E1000_RXDCTL(0), 4, WRITE_NO_TEST, 0, 0 },
-	{ E1000_FCRTH, 1, PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
-	{ E1000_FCTTV, 1, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
-	{ E1000_TIPG, 1, PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
-	{ E1000_TDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_TDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_TDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0x04CFB3FE, 0x003FFFFB },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0x04CFB3FE, 0xFFFFFFFF },
-	{ E1000_TCTL, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
-	{ E1000_TXCW, 1, PATTERN_TEST, 0xC000FFFF, 0x0000FFFF },
-	{ E1000_RA, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RA, 16, TABLE64_TEST_HI, 0x800FFFFF, 0xFFFFFFFF },
-	{ E1000_MTA, 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDT(0),    0x100, 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, 0 },
+	{ E1000_FCRTH,     0x100, 1, PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
+	{ E1000_FCTTV,     0x100, 1, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TIPG,      0x100, 1, PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
+	{ E1000_TDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0x04CFB3FE, 0x003FFFFB },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0x04CFB3FE, 0xFFFFFFFF },
+	{ E1000_TCTL,      0x100, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_TXCW,      0x100, 1, PATTERN_TEST, 0xC000FFFF, 0x0000FFFF },
+	{ E1000_RA,        0, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA,        0, 16, TABLE64_TEST_HI, 0x800FFFFF, 0xFFFFFFFF },
+	{ E1000_MTA,       0, 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ 0, 0, 0, 0 }
 };
 
@@ -937,7 +976,15 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 	u32 i, toggle;
 
 	toggle = 0x7FFFF3FF;
-	test = reg_test_82575;
+
+	switch (adapter->hw.mac.type) {
+	case e1000_82576:
+		test = reg_test_82576;
+		break;
+	default:
+		test = reg_test_82575;
+		break;
+	}
 
 	/* Because the status register is such a special case,
 	 * we handle it separately from the rest of the register
@@ -964,19 +1011,19 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 		for (i = 0; i < test->array_len; i++) {
 			switch (test->test_type) {
 			case PATTERN_TEST:
-				REG_PATTERN_TEST(test->reg + (i * 0x100),
+				REG_PATTERN_TEST(test->reg + (i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
 			case SET_READ_TEST:
-				REG_SET_AND_CHECK(test->reg + (i * 0x100),
+				REG_SET_AND_CHECK(test->reg + (i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
 			case WRITE_NO_TEST:
 				writel(test->write,
 				    (adapter->hw.hw_addr + test->reg)
-					+ (i * 0x100));
+					+ (i * test->reg_offset));
 				break;
 			case TABLE32_TEST:
 				REG_PATTERN_TEST(test->reg + (i * 4),
@@ -1392,13 +1439,39 @@ static int igb_set_phy_loopback(struct igb_adapter *adapter)
 static int igb_setup_loopback_test(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl;
+	u32 reg;
 
 	if (hw->phy.media_type == e1000_media_type_fiber ||
 	    hw->phy.media_type == e1000_media_type_internal_serdes) {
-		rctl = rd32(E1000_RCTL);
-		rctl |= E1000_RCTL_LBM_TCVR;
-		wr32(E1000_RCTL, rctl);
+		reg = rd32(E1000_RCTL);
+		reg |= E1000_RCTL_LBM_TCVR;
+		wr32(E1000_RCTL, reg);
+
+		wr32(E1000_SCTL, E1000_ENABLE_SERDES_LOOPBACK);
+
+		reg = rd32(E1000_CTRL);
+		reg &= ~(E1000_CTRL_RFCE |
+			 E1000_CTRL_TFCE |
+			 E1000_CTRL_LRST);
+		reg |= E1000_CTRL_SLU |
+		       E1000_CTRL_FD; 
+		wr32(E1000_CTRL, reg);
+
+		/* Unset switch control to serdes energy detect */
+		reg = rd32(E1000_CONNSW);
+		reg &= ~E1000_CONNSW_ENRGSRC;
+		wr32(E1000_CONNSW, reg);
+
+		/* Set PCS register for forced speed */
+		reg = rd32(E1000_PCS_LCTL);
+		reg &= ~E1000_PCS_LCTL_AN_ENABLE;     /* Disable Autoneg*/
+		reg |= E1000_PCS_LCTL_FLV_LINK_UP |   /* Force link up */
+		       E1000_PCS_LCTL_FSV_1000 |      /* Force 1000    */
+		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
+		       E1000_PCS_LCTL_FSD |           /* Force Speed */
+		       E1000_PCS_LCTL_FORCE_LINK;     /* Force Link */
+		wr32(E1000_PCS_LCTL, reg);
+
 		return 0;
 	} else if (hw->phy.media_type == e1000_media_type_copper) {
 		return igb_set_phy_loopback(adapter);
@@ -1654,10 +1727,13 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
 		/* WoL not supported */
 		wol->supported = 0;
 		break;
 	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
 		/* Wake events not supported on port B */
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1436326..ba043c4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -51,7 +51,7 @@ char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
-static const char igb_copyright[] = "Copyright (c) 2007 Intel Corporation.";
+static const char igb_copyright[] = "Copyright (c) 2008 Intel Corporation.";
 
 
 static const struct e1000_info *igb_info_tbl[] = {
@@ -59,6 +59,10 @@ static const struct e1000_info *igb_info_tbl[] = {
 };
 
 static struct pci_device_id igb_pci_tbl[] = {
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_QUAD_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_FIBER_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575GB_QUAD_COPPER), board_82575 },
@@ -268,6 +272,10 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 {
 	u32 msixbm = 0;
 	struct e1000_hw *hw = &adapter->hw;
+	u32 ivar, index;
+
+	switch (hw->mac.type) {
+	case e1000_82575:
 		/* The 82575 assigns vectors using a bitmask, which matches the
 		   bitmask for the EICR/EIMS/EIMC registers.  To assign one
 		   or more queues to a vector, we write the appropriate bits
@@ -282,6 +290,47 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 				  E1000_EICR_TX_QUEUE0 << tx_queue;
 		}
 		array_wr32(E1000_MSIXBM(0), msix_vector, msixbm);
+		break;
+	case e1000_82576:
+		/* Kawela uses a table-based method for assigning vectors.
+		   Each queue has a single entry in the table to which we write
+		   a vector number along with a "valid" bit.  Sadly, the layout
+		   of the table is somewhat counterintuitive. */
+		if (rx_queue > IGB_N0_QUEUE) {
+			index = (rx_queue & 0x7);
+			ivar = array_rd32(E1000_IVAR0, index);
+			if (rx_queue < 8) {
+				/* vector goes into low byte of register */
+				ivar = ivar & 0xFFFFFF00;
+				ivar |= msix_vector | E1000_IVAR_VALID;
+			} else {
+				/* vector goes into third byte of register */
+				ivar = ivar & 0xFF00FFFF;
+				ivar |= (msix_vector | E1000_IVAR_VALID) << 16;
+			}
+			adapter->rx_ring[rx_queue].eims_value= 1 << msix_vector;
+			array_wr32(E1000_IVAR0, index, ivar);
+		}
+		if (tx_queue > IGB_N0_QUEUE) {
+			index = (tx_queue & 0x7);
+			ivar = array_rd32(E1000_IVAR0, index);
+			if (tx_queue < 8) {
+				/* vector goes into second byte of register */
+				ivar = ivar & 0xFFFF00FF;
+				ivar |= (msix_vector | E1000_IVAR_VALID) << 8;
+			} else {
+				/* vector goes into high byte of register */
+				ivar = ivar & 0x00FFFFFF;
+				ivar |= (msix_vector | E1000_IVAR_VALID) << 24;
+			}
+			adapter->tx_ring[tx_queue].eims_value= 1 << msix_vector;
+			array_wr32(E1000_IVAR0, index, ivar);
+		}
+		break;
+	default:
+		BUG();
+		break;
+	}
 }
 
 /**
@@ -297,6 +346,12 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	adapter->eims_enable_mask = 0;
+	if (hw->mac.type == e1000_82576)
+		/* Turn on MSI-X capability first, or our settings
+		 * won't stick.  And it will take days to debug. */
+		wr32(E1000_GPIE, E1000_GPIE_MSIX_MODE |
+				   E1000_GPIE_PBA | E1000_GPIE_EIAME | 
+ 				   E1000_GPIE_NSICR);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *tx_ring = &adapter->tx_ring[i];
@@ -322,6 +377,8 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 
 	/* set vector for other causes, i.e. link changes */
+	switch (hw->mac.type) {
+	case e1000_82575:
 		array_wr32(E1000_MSIXBM(0), vector++,
 				      E1000_EIMS_OTHER);
 
@@ -337,6 +394,19 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		adapter->eims_enable_mask |= E1000_EIMS_OTHER;
 		adapter->eims_other = E1000_EIMS_OTHER;
 
+		break;
+
+	case e1000_82576:
+		tmp = (vector++ | E1000_IVAR_VALID) << 8;
+		wr32(E1000_IVAR_MISC, tmp);
+
+		adapter->eims_enable_mask = (1 << (vector)) - 1;
+		adapter->eims_other = 1 << (vector - 1);
+		break;
+	default:
+		/* do nothing, since nothing else supports MSI-X */
+		break;
+	} /* switch (hw->mac.type) */
 	wrfl();
 }
 
@@ -474,8 +544,17 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		adapter->num_rx_queues = 1;
 		igb_alloc_queues(adapter);
 	} else {
-		wr32(E1000_MSIXBM(0), (E1000_EICR_RX_QUEUE0 |
-		                       E1000_EIMS_OTHER));
+		switch (hw->mac.type) {
+		case e1000_82575:
+			wr32(E1000_MSIXBM(0),
+			     (E1000_EICR_RX_QUEUE0 | E1000_EIMS_OTHER));
+			break;
+		case e1000_82576:
+			wr32(E1000_IVAR0, E1000_IVAR_VALID);
+			break;
+		default:
+			break;
+		}
 	}
 
 	if (adapter->msi_enabled) {
@@ -770,16 +849,23 @@ void igb_reinit_locked(struct igb_adapter *adapter)
 void igb_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_fc_info *fc = &adapter->hw.fc;
+	struct e1000_mac_info *mac = &hw->mac;
+	struct e1000_fc_info *fc = &hw->fc;
 	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
 	u16 hwm;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
+	if (mac->type != e1000_82576) {
 	pba = E1000_PBA_34K;
+	}
+	else {
+		pba = E1000_PBA_64K;
+	}
 
-	if (adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) {
+	if ((adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) &&
+	    (mac->type < e1000_82576)) {
 		/* adjust PBA for jumbo frames */
 		wr32(E1000_PBA, pba);
 
@@ -818,8 +904,8 @@ void igb_reset(struct igb_adapter *adapter)
 			if (pba < min_rx_space)
 				pba = min_rx_space;
 		}
+		wr32(E1000_PBA, pba);
 	}
-	wr32(E1000_PBA, pba);
 
 	/* flow control settings */
 	/* The high water mark must be low enough to fit one full frame
@@ -828,10 +914,15 @@ void igb_reset(struct igb_adapter *adapter)
 	 * - 90% of the Rx FIFO size, or
 	 * - the full Rx FIFO size minus one full frame */
 	hwm = min(((pba << 10) * 9 / 10),
-		  ((pba << 10) - adapter->max_frame_size));
+			((pba << 10) - 2 * adapter->max_frame_size));
 
-	fc->high_water = hwm & 0xFFF8;	/* 8-byte granularity */
-	fc->low_water = fc->high_water - 8;
+	if (mac->type < e1000_82576) {
+		fc->high_water = hwm & 0xFFF8;	/* 8-byte granularity */
+		fc->low_water = fc->high_water - 8;
+	} else {
+		fc->high_water = hwm & 0xFFF0;	/* 16-byte granularity */
+		fc->low_water = fc->high_water - 16;
+	}
 	fc->pause_time = 0xFFFF;
 	fc->send_xon = 1;
 	fc->type = fc->original_type;
@@ -1118,9 +1209,12 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	 * lan on a particular port */
 	switch (pdev->device) {
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
 		adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
 		/* Wake events only supported on port A for dual fiber
 		 * regardless of eeprom setting */
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1)
@@ -1801,7 +1895,10 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 
 		get_random_bytes(&random[0], 40);
 
-		shift = 6;
+		if (hw->mac.type >= e1000_82576)
+			shift = 0;
+		else
+			shift = 6;
 		for (j = 0; j < (32 * 4); j++) {
 			reta.bytes[j & 3] =
 				(j % adapter->num_rx_queues) << shift;
@@ -2127,7 +2224,7 @@ static void igb_set_multi(struct net_device *netdev)
 
 	if (!netdev->mc_count) {
 		/* nothing to program, so clear mc list */
-		igb_update_mc_addr_list(hw, NULL, 0, 1,
+		igb_update_mc_addr_list_82575(hw, NULL, 0, 1,
 					  mac->rar_entry_count);
 		return;
 	}
@@ -2145,7 +2242,8 @@ static void igb_set_multi(struct net_device *netdev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr = mc_ptr->next;
 	}
-	igb_update_mc_addr_list(hw, mta_list, i, 1, mac->rar_entry_count);
+	igb_update_mc_addr_list_82575(hw, mta_list, i, 1,
+	                              mac->rar_entry_count);
 	kfree(mta_list);
 }
 
@@ -3211,8 +3309,14 @@ static void igb_update_rx_dca(struct igb_ring *rx_ring)
 
 	if (rx_ring->cpu != cpu) {
 		dca_rxctrl = rd32(E1000_DCA_RXCTRL(q));
-		dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK;
-		dca_rxctrl |= dca_get_tag(cpu);
+		if (hw->mac.type == e1000_82576) {
+			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK_82576;
+			dca_rxctrl |= dca_get_tag(cpu) <<
+			              E1000_DCA_RXCTRL_CPUID_SHIFT;
+		} else {
+			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK;
+			dca_rxctrl |= dca_get_tag(cpu);
+		}
 		dca_rxctrl |= E1000_DCA_RXCTRL_DESC_DCA_EN;
 		dca_rxctrl |= E1000_DCA_RXCTRL_HEAD_DCA_EN;
 		dca_rxctrl |= E1000_DCA_RXCTRL_DATA_DCA_EN;
@@ -3232,8 +3336,14 @@ static void igb_update_tx_dca(struct igb_ring *tx_ring)
 
 	if (tx_ring->cpu != cpu) {
 		dca_txctrl = rd32(E1000_DCA_TXCTRL(q));
-		dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK;
-		dca_txctrl |= dca_get_tag(cpu);
+		if (hw->mac.type == e1000_82576) {
+			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK_82576;
+			dca_txctrl |= dca_get_tag(cpu) <<
+			              E1000_DCA_TXCTRL_CPUID_SHIFT;
+		} else {
+			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK;
+			dca_txctrl |= dca_get_tag(cpu);
+		}
 		dca_txctrl |= E1000_DCA_TXCTRL_DESC_DCA_EN;
 		wr32(E1000_DCA_TXCTRL(q), dca_txctrl);
 		tx_ring->cpu = cpu;
@@ -3572,7 +3682,7 @@ done_cleaning:
 			/* detected Tx unit hang */
 			dev_err(&adapter->pdev->dev,
 				"Detected Tx Unit Hang\n"
-				"  Tx Queue             <%lu>\n"
+				"  Tx Queue             <%d>\n"
 				"  TDH                  <%x>\n"
 				"  TDT                  <%x>\n"
 				"  next_to_use          <%x>\n"
@@ -3582,8 +3692,7 @@ done_cleaning:
 				"  time_stamp           <%lx>\n"
 				"  jiffies              <%lx>\n"
 				"  desc.status          <%x>\n",
-				(unsigned long)((tx_ring - adapter->tx_ring) /
-					sizeof(struct igb_ring)),
+				tx_ring->queue_index,
 				readl(adapter->hw.hw_addr + tx_ring->head),
 				readl(adapter->hw.hw_addr + tx_ring->tail),
 				tx_ring->next_to_use,
@@ -4098,7 +4207,7 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl, ctrl_ext, rctl, status;
+	u32 ctrl, rctl, status;
 	u32 wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
@@ -4141,33 +4250,24 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 		ctrl |= E1000_CTRL_ADVD3WUC;
 		wr32(E1000_CTRL, ctrl);
 
-		if (adapter->hw.phy.media_type == e1000_media_type_fiber ||
-		   adapter->hw.phy.media_type ==
-					e1000_media_type_internal_serdes) {
-			/* keep the laser running in D3 */
-			ctrl_ext = rd32(E1000_CTRL_EXT);
-			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
-			wr32(E1000_CTRL_EXT, ctrl_ext);
-		}
-
 		/* Allow time for pending master requests to run */
 		igb_disable_pcie_master(&adapter->hw);
 
 		wr32(E1000_WUC, E1000_WUC_PME_EN);
 		wr32(E1000_WUFC, wufc);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
 		wr32(E1000_WUC, 0);
 		wr32(E1000_WUFC, 0);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->en_mng_pt) {
+	/* make sure adapter isn't asleep if manageability/wol is enabled */
+	if (wufc || adapter->en_mng_pt) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		igb_shutdown_fiber_serdes_link_82575(hw);
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this

