From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom 5461S
Date: Fri, 17 Apr 2015 13:23:59 -0700
Message-ID: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com, Alan Liebthal <alanl@cumulusnetworks.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34673 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbbDQUYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 16:24:12 -0400
Received: by pdbqa5 with SMTP id qa5so138465685pdb.1
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 13:24:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Liebthal <alanl@cumulusnetworks.com>

The Quanta LY8 Ethernet management port uses a Broadcom 5461S chip for
the PHY layer. This adds support for this PHY to the Intel igb driver.

Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   |   20 +++++-
 drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      |    1 +
 drivers/net/ethernet/intel/igb/e1000_phy.c     |   79 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_phy.h     |    2 +
 5 files changed, 102 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 2dcc808..e222804 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -178,7 +178,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 
 	ctrl_ext = rd32(E1000_CTRL_EXT);
 
-	if (igb_sgmii_active_82575(hw)) {
+	if (igb_sgmii_active_82575(hw) && phy->type != e1000_phy_bcm5461s) {
 		phy->ops.reset = igb_phy_hw_reset_sgmii_82575;
 		ctrl_ext |= E1000_CTRL_I2C_ENA;
 	} else {
@@ -289,6 +289,11 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 	case BCM54616_E_PHY_ID:
 		phy->type = e1000_phy_bcm54616;
 		break;
+	case BCM5461S_E_PHY_ID:
+		phy->type                   = e1000_phy_bcm5461s;
+		phy->ops.get_phy_info       = igb_get_phy_info_5461s;
+		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_82580;
+		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
 		goto out;
@@ -841,6 +846,15 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 			goto out;
 		}
 		ret_val = igb_get_phy_id(hw);
+		if (ret_val && hw->mac.type == e1000_i354) {
+			/* We do a special check for bcm5461s phy by setting
+			 * the phy->addr to 5 and doing the phy check again.
+			 * This call will succeed and retrieve a valid phy
+			 * id if we have the bcm5461s phy.
+			 */
+			phy->addr = 5;
+			ret_val = igb_get_phy_id(hw);
+		}
 		goto out;
 	}
 
@@ -1221,6 +1235,9 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 	    (hw->phy.type == e1000_phy_igp_3))
 		igb_phy_init_script_igp3(hw);
 
+	if (hw->phy.type == e1000_phy_bcm5461s)
+		igb_phy_init_script_5461s(hw);
+
 	return 0;
 }
 
@@ -1597,6 +1614,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		ret_val = igb_copper_link_setup_82580(hw);
 		break;
 	case e1000_phy_bcm54616:
+	case e1000_phy_bcm5461s:
 		break;
 	default:
 		ret_val = -E1000_ERR_PHY;
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 50d51e4..787224d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -861,6 +861,7 @@
 #define I210_I_PHY_ID        0x01410C00
 #define M88E1543_E_PHY_ID    0x01410EA0
 #define BCM54616_E_PHY_ID    0x03625D10
+#define BCM5461S_E_PHY_ID    0x002060C0
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index d82c96b..408a3e5 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -129,6 +129,7 @@ enum e1000_phy_type {
 	e1000_phy_82580,
 	e1000_phy_i210,
 	e1000_phy_bcm54616,
+	e1000_phy_bcm5461s,
 };
 
 enum e1000_bus_type {
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c1bb64d..0f5a55b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -148,6 +148,13 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
+	if (phy->type == e1000_phy_bcm5461s) {
+		mdic = rd32(E1000_MDICNFG);
+		mdic &= ~E1000_MDICNFG_PHY_MASK;
+		mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
+		wr32(E1000_MDICNFG, mdic);
+	}
+
 	mdic = ((offset << E1000_MDIC_REG_SHIFT) |
 		(phy->addr << E1000_MDIC_PHY_SHIFT) |
 		(E1000_MDIC_OP_READ));
@@ -204,6 +211,13 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
+	if (phy->type == e1000_phy_bcm5461s) {
+		mdic = rd32(E1000_MDICNFG);
+		mdic &= ~E1000_MDICNFG_PHY_MASK;
+		mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
+		wr32(E1000_MDICNFG, mdic);
+	}
+
 	mdic = (((u32)data) |
 		(offset << E1000_MDIC_REG_SHIFT) |
 		(phy->addr << E1000_MDIC_PHY_SHIFT) |
@@ -2509,3 +2523,68 @@ static s32 igb_set_master_slave_mode(struct e1000_hw *hw)
 
 	return hw->phy.ops.write_reg(hw, PHY_1000T_CTRL, phy_data);
 }
+
+/**
+ *  igb_phy_init_script_5461s - Inits the BCM5461S PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes a Broadcom Gigabit PHY.
+ **/
+s32 igb_phy_init_script_5461s(struct e1000_hw *hw)
+{
+	u16 mii_reg_led = 0;
+
+	/* 1. Speed LED (Set the Link LED mode), Shadow 00010, 0x1C.bit2=1 */
+	hw->phy.ops.write_reg(hw, 0x1C, 0x0800);
+	hw->phy.ops.read_reg(hw, 0x1C, &mii_reg_led);
+	mii_reg_led |= 0x0004;
+	hw->phy.ops.write_reg(hw, 0x1C, mii_reg_led | 0x8000);
+
+	/* 2. Active LED (Set the Link LED mode), Shadow 01001, 0x1C.bit4=1,
+	 *    0x10.bit5=0
+	 */
+	hw->phy.ops.write_reg(hw, 0x1C, 0x2400);
+	hw->phy.ops.read_reg(hw, 0x1C, &mii_reg_led);
+	mii_reg_led |= 0x0010;
+	hw->phy.ops.write_reg(hw, 0x1C, mii_reg_led | 0x8000);
+	hw->phy.ops.read_reg(hw, 0x10, &mii_reg_led);
+	mii_reg_led &= 0xffdf;
+	hw->phy.ops.write_reg(hw, 0x10, mii_reg_led);
+
+	return 0;
+}
+
+/**
+ *  igb_get_phy_info_5461s - Retrieve 5461s PHY information
+ *  @hw: pointer to the HW structure
+ *
+ *  Read PHY status to determine if link is up.  If link is up, then
+ *  set/determine 10base-T extended distance and polarity correction.  Read
+ *  PHY port status to determine MDI/MDIx and speed.  Based on the speed,
+ *  determine on the cable length, local and remote receiver.
+ **/
+s32 igb_get_phy_info_5461s(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	bool link;
+
+	ret_val = igb_phy_has_link(hw, 1, 0, &link);
+	if (ret_val)
+		goto out;
+
+	if (!link) {
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	phy->polarity_correction = true;
+
+	phy->is_mdix = true;
+	phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
+	phy->local_rx = e1000_1000t_rx_status_ok;
+	phy->remote_rx = e1000_1000t_rx_status_ok;
+
+out:
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 7af4ffa..fcdd84c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -61,6 +61,8 @@ s32  igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 void igb_power_up_phy_copper(struct e1000_hw *hw);
 void igb_power_down_phy_copper(struct e1000_hw *hw);
 s32  igb_phy_init_script_igp3(struct e1000_hw *hw);
+s32  igb_phy_init_script_5461s(struct e1000_hw *hw);
+s32  igb_get_phy_info_5461s(struct e1000_hw *hw);
 s32  igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
 s32  igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data);
-- 
1.7.10.4
