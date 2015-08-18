From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] igb: add support for 1512 PHY
Date: Tue, 18 Aug 2015 14:09:12 -0700
Message-ID: <1439932162-1995-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17210 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453AbbHRVJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:27 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

This patch adds support for Marvell PHY 1512 (required for I354).

Submitted by: Maciej Szwed <maciej.szwed@intel.com>
Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 20 +++++-
 drivers/net/ethernet/intel/igb/e1000_defines.h |  5 ++
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 93 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_phy.h     |  1 +
 4 files changed, 114 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index d192569..7a73510 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -231,6 +231,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 	/* Verify phy id and set remaining function pointers */
 	switch (phy->id) {
 	case M88E1543_E_PHY_ID:
+	case M88E1512_E_PHY_ID:
 	case I347AT4_E_PHY_ID:
 	case M88E1112_E_PHY_ID:
 	case M88E1111_I_PHY_ID:
@@ -243,7 +244,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 		else
 			phy->ops.get_cable_length = igb_get_cable_length_m88;
 		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_m88;
-		/* Check if this PHY is confgured for media swap. */
+		/* Check if this PHY is configured for media swap. */
 		if (phy->id == M88E1112_E_PHY_ID) {
 			u16 data;
 
@@ -266,6 +267,11 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 				hw->mac.ops.check_for_link =
 						igb_check_for_link_media_swap;
 		}
+		if (phy->id == M88E1512_E_PHY_ID) {
+			ret_val = igb_initialize_M88E1512_phy(hw);
+			if (ret_val)
+				goto out;
+		}
 		break;
 	case IGP03E1000_E_PHY_ID:
 		phy->type = e1000_phy_igp_3;
@@ -897,6 +903,7 @@ out:
  **/
 static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 {
+	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
 
 	/* This isn't a true "hard" reset, but is the only reset
@@ -913,7 +920,11 @@ static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 		goto out;
 
 	ret_val = igb_phy_sw_reset(hw);
+	if (ret_val)
+		goto out;
 
+	if (phy->id == M88E1512_E_PHY_ID)
+		ret_val = igb_initialize_M88E1512_phy(hw);
 out:
 	return ret_val;
 }
@@ -1587,6 +1598,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		case I347AT4_E_PHY_ID:
 		case M88E1112_E_PHY_ID:
 		case M88E1543_E_PHY_ID:
+		case M88E1512_E_PHY_ID:
 		case I210_I_PHY_ID:
 			ret_val = igb_copper_link_setup_m88_gen2(hw);
 			break;
@@ -2629,7 +2641,8 @@ s32 igb_set_eee_i354(struct e1000_hw *hw, bool adv1G, bool adv100M)
 	u16 phy_data;
 
 	if ((hw->phy.media_type != e1000_media_type_copper) ||
-	    (phy->id != M88E1543_E_PHY_ID))
+	    ((phy->id != M88E1543_E_PHY_ID) &&
+	     (phy->id != M88E1512_E_PHY_ID)))
 		goto out;
 
 	if (!hw->dev_spec._82575.eee_disable) {
@@ -2709,7 +2722,8 @@ s32 igb_get_eee_status_i354(struct e1000_hw *hw, bool *status)
 
 	/* Check if EEE is supported on this device. */
 	if ((hw->phy.media_type != e1000_media_type_copper) ||
-	    (phy->id != M88E1543_E_PHY_ID))
+	    ((phy->id != M88E1543_E_PHY_ID) &&
+	     (phy->id != M88E1512_E_PHY_ID)))
 		goto out;
 
 	ret_val = igb_read_xmdio_reg(hw, E1000_PCS_STATUS_ADDR_I354,
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index f8684aa..b191504 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -604,6 +604,10 @@
 #define E1000_M88E1112_MAC_CTRL_1_MODE_SHIFT	7
 #define E1000_M88E1112_PAGE_ADDR		0x16
 #define E1000_M88E1112_STATUS			0x01
+#define E1000_M88E1512_CFG_REG_1		0x0010
+#define E1000_M88E1512_CFG_REG_2		0x0011
+#define E1000_M88E1512_CFG_REG_3		0x0007
+#define E1000_M88E1512_MODE			0x0014
 
 /* PCI Express Control */
 #define E1000_GCR_CMPL_TMOUT_MASK       0x0000F000
@@ -861,6 +865,7 @@
 #define M88_VENDOR           0x0141
 #define I210_I_PHY_ID        0x01410C00
 #define M88E1543_E_PHY_ID    0x01410EA0
+#define M88E1512_E_PHY_ID    0x01410DD0
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 987c9de..23ec28f 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1262,6 +1262,8 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			switch (hw->phy.id) {
 			case I347AT4_E_PHY_ID:
 			case M88E1112_E_PHY_ID:
+			case M88E1543_E_PHY_ID:
+			case M88E1512_E_PHY_ID:
 			case I210_I_PHY_ID:
 				reset_dsp = false;
 				break;
@@ -1270,9 +1272,9 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 					reset_dsp = false;
 				break;
 			}
-			if (!reset_dsp)
+			if (!reset_dsp) {
 				hw_dbg("Link taking longer than expected.\n");
-			else {
+			} else {
 				/* We didn't get link.
 				 * Reset the DSP and cross our fingers.
 				 */
@@ -1297,6 +1299,8 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (hw->phy.type != e1000_phy_m88 ||
 	    hw->phy.id == I347AT4_E_PHY_ID ||
 	    hw->phy.id == M88E1112_E_PHY_ID ||
+	    hw->phy.id == M88E1543_E_PHY_ID ||
+	    hw->phy.id == M88E1512_E_PHY_ID ||
 	    hw->phy.id == I210_I_PHY_ID)
 		goto out;
 
@@ -1737,6 +1741,7 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 		phy->cable_length = phy_data / (is_cm ? 100 : 1);
 		break;
 	case M88E1543_E_PHY_ID:
+	case M88E1512_E_PHY_ID:
 	case I347AT4_E_PHY_ID:
 		/* Remember the original page select and set it to 7 */
 		ret_val = phy->ops.read_reg(hw, I347AT4_PAGE_SELECT,
@@ -2189,6 +2194,90 @@ s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 }
 
 /**
+ *  igb_initialize_M88E1512_phy - Initialize M88E1512 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Initialize Marvel 1512 to work correctly with Avoton.
+ **/
+s32 igb_initialize_M88E1512_phy(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = 0;
+
+	/* Switch to PHY page 0xFF. */
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1543_PAGE_ADDR, 0x00FF);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_2, 0x214B);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_1, 0x2144);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_2, 0x0C28);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_1, 0x2146);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_2, 0xB233);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_1, 0x214D);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_2, 0xCC0C);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_1, 0x2159);
+	if (ret_val)
+		goto out;
+
+	/* Switch to PHY page 0xFB. */
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1543_PAGE_ADDR, 0x00FB);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_CFG_REG_3, 0x000D);
+	if (ret_val)
+		goto out;
+
+	/* Switch to PHY page 0x12. */
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1543_PAGE_ADDR, 0x12);
+	if (ret_val)
+		goto out;
+
+	/* Change mode to SGMII-to-Copper */
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1512_MODE, 0x8001);
+	if (ret_val)
+		goto out;
+
+	/* Return the PHY to page 0. */
+	ret_val = phy->ops.write_reg(hw, E1000_M88E1543_PAGE_ADDR, 0);
+	if (ret_val)
+		goto out;
+
+	ret_val = igb_phy_sw_reset(hw);
+	if (ret_val) {
+		hw_dbg("Error committing the PHY changes\n");
+		return ret_val;
+	}
+
+	/* msec_delay(1000); */
+	usleep_range(1000, 2000);
+out:
+	return ret_val;
+}
+
+/**
  * igb_power_up_phy_copper - Restore copper link in case of PHY power down
  * @hw: pointer to the HW structure
  *
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 7af4ffa..24d55ed 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -61,6 +61,7 @@ s32  igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 void igb_power_up_phy_copper(struct e1000_hw *hw);
 void igb_power_down_phy_copper(struct e1000_hw *hw);
 s32  igb_phy_init_script_igp3(struct e1000_hw *hw);
+s32  igb_initialize_M88E1512_phy(struct e1000_hw *hw);
 s32  igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
 s32  igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data);
-- 
2.4.3
