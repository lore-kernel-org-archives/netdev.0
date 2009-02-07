From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 08/26] igb: rename phy ops
Date: Sat, 07 Feb 2009 01:17:26 -0800
Message-ID: <20090207091726.15697.16363.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:42971 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbZBGJRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:17:47 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch renames write_phy_reg to write_reg and read_phy_reg to read_reg.
It seems redundant to call out phy in an operation that is part of the
phy_ops struct.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   38 ++--
 drivers/net/igb/e1000_hw.h    |   10 +
 drivers/net/igb/e1000_mac.c   |    8 -
 drivers/net/igb/e1000_phy.c   |  347 +++++++++++++++--------------------------
 drivers/net/igb/e1000_phy.h   |    1 
 drivers/net/igb/igb.h         |   12 +
 6 files changed, 162 insertions(+), 254 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index ed9e8c0..9a66e34 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -179,13 +179,13 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 
 	/* PHY function pointers */
 	if (igb_sgmii_active_82575(hw)) {
-		phy->ops.reset_phy          = igb_phy_hw_reset_sgmii_82575;
-		phy->ops.read_phy_reg       = igb_read_phy_reg_sgmii_82575;
-		phy->ops.write_phy_reg      = igb_write_phy_reg_sgmii_82575;
+		phy->ops.reset              = igb_phy_hw_reset_sgmii_82575;
+		phy->ops.read_reg           = igb_read_phy_reg_sgmii_82575;
+		phy->ops.write_reg          = igb_write_phy_reg_sgmii_82575;
 	} else {
-		phy->ops.reset_phy          = igb_phy_hw_reset;
-		phy->ops.read_phy_reg       = igb_read_phy_reg_igp;
-		phy->ops.write_phy_reg      = igb_write_phy_reg_igp;
+		phy->ops.reset              = igb_phy_hw_reset;
+		phy->ops.read_reg           = igb_read_phy_reg_igp;
+		phy->ops.write_reg          = igb_write_phy_reg_igp;
 	}
 
 	/* Set phy->phy_addr and phy->id. */
@@ -435,7 +435,7 @@ static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 	 * SFP documentation requires the following to configure the SPF module
 	 * to work on SGMII.  No further documentation is given.
 	 */
-	ret_val = hw->phy.ops.write_phy_reg(hw, 0x1B, 0x8084);
+	ret_val = hw->phy.ops.write_reg(hw, 0x1B, 0x8084);
 	if (ret_val)
 		goto out;
 
@@ -464,28 +464,28 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = phy->ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
+	ret_val = phy->ops.read_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
 		goto out;
 
 	if (active) {
 		data |= IGP02E1000_PM_D0_LPLU;
-		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 						 data);
 		if (ret_val)
 			goto out;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = phy->ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+		ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
 						&data);
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = phy->ops.write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+		ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
 						 data);
 		if (ret_val)
 			goto out;
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
-		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 						 data);
 		/*
 		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
@@ -494,24 +494,24 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 		 * SmartSpeed, so performance is maintained.
 		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = phy->ops.read_phy_reg(hw,
+			ret_val = phy->ops.read_reg(hw,
 					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = phy->ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = phy->ops.read_phy_reg(hw,
+			ret_val = phy->ops.read_reg(hw,
 					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = phy->ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
@@ -1035,7 +1035,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		 * depending on user settings.
 		 */
 		hw_dbg("Forcing Speed and Duplex\n");
-		ret_val = igb_phy_force_speed_duplex(hw);
+		ret_val = hw->phy.ops.force_speed_duplex(hw);
 		if (ret_val) {
 			hw_dbg("Error Forcing Speed and Duplex\n");
 			goto out;
@@ -1423,9 +1423,9 @@ static struct e1000_mac_operations e1000_mac_ops_82575 = {
 };
 
 static struct e1000_phy_operations e1000_phy_ops_82575 = {
-	.acquire_phy          = igb_acquire_phy_82575,
+	.acquire              = igb_acquire_phy_82575,
 	.get_cfg_done         = igb_get_cfg_done_82575,
-	.release_phy          = igb_release_phy_82575,
+	.release              = igb_release_phy_82575,
 };
 
 static struct e1000_nvm_operations e1000_nvm_ops_82575 = {
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 06f72ae..5acb849 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -422,18 +422,18 @@ struct e1000_mac_operations {
 };
 
 struct e1000_phy_operations {
-	s32  (*acquire_phy)(struct e1000_hw *);
+	s32  (*acquire)(struct e1000_hw *);
 	s32  (*check_reset_block)(struct e1000_hw *);
 	s32  (*force_speed_duplex)(struct e1000_hw *);
 	s32  (*get_cfg_done)(struct e1000_hw *hw);
 	s32  (*get_cable_length)(struct e1000_hw *);
 	s32  (*get_phy_info)(struct e1000_hw *);
-	s32  (*read_phy_reg)(struct e1000_hw *, u32, u16 *);
-	void (*release_phy)(struct e1000_hw *);
-	s32  (*reset_phy)(struct e1000_hw *);
+	s32  (*read_reg)(struct e1000_hw *, u32, u16 *);
+	void (*release)(struct e1000_hw *);
+	s32  (*reset)(struct e1000_hw *);
 	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
 	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
-	s32  (*write_phy_reg)(struct e1000_hw *, u32, u16);
+	s32  (*write_reg)(struct e1000_hw *, u32, u16);
 };
 
 struct e1000_nvm_operations {
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 16fa083..d0b695c 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -707,11 +707,11 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 * has completed.  We read this twice because this reg has
 		 * some "sticky" (latched) bits.
 		 */
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS,
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS,
 						   &mii_status_reg);
 		if (ret_val)
 			goto out;
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS,
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS,
 						   &mii_status_reg);
 		if (ret_val)
 			goto out;
@@ -729,11 +729,11 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 * Page Ability Register (Address 5) to determine how
 		 * flow control was negotiated.
 		 */
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_AUTONEG_ADV,
+		ret_val = hw->phy.ops.read_reg(hw, PHY_AUTONEG_ADV,
 					    &mii_nway_adv_reg);
 		if (ret_val)
 			goto out;
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_LP_ABILITY,
+		ret_val = hw->phy.ops.read_reg(hw, PHY_LP_ABILITY,
 					    &mii_nway_lp_ability_reg);
 		if (ret_val)
 			goto out;
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 17fddb9..d73ea71 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -31,10 +31,6 @@
 #include "e1000_mac.h"
 #include "e1000_phy.h"
 
-static s32  igb_get_phy_cfg_done(struct e1000_hw *hw);
-static void igb_release_phy(struct e1000_hw *hw);
-static s32  igb_acquire_phy(struct e1000_hw *hw);
-static s32  igb_phy_reset_dsp(struct e1000_hw *hw);
 static s32  igb_phy_setup_autoneg(struct e1000_hw *hw);
 static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 					       u16 *phy_ctrl);
@@ -91,13 +87,13 @@ s32 igb_get_phy_id(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 phy_id;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_ID1, &phy_id);
+	ret_val = phy->ops.read_reg(hw, PHY_ID1, &phy_id);
 	if (ret_val)
 		goto out;
 
 	phy->id = (u32)(phy_id << 16);
 	udelay(20);
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_ID2, &phy_id);
+	ret_val = phy->ops.read_reg(hw, PHY_ID2, &phy_id);
 	if (ret_val)
 		goto out;
 
@@ -118,11 +114,11 @@ static s32 igb_phy_reset_dsp(struct e1000_hw *hw)
 {
 	s32 ret_val;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xC1);
+	ret_val = hw->phy.ops.write_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xC1);
 	if (ret_val)
 		goto out;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0);
+	ret_val = hw->phy.ops.write_reg(hw, M88E1000_PHY_GEN_CONTROL, 0);
 
 out:
 	return ret_val;
@@ -257,9 +253,12 @@ out:
  **/
 s32 igb_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
 
-	ret_val = igb_acquire_phy(hw);
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		goto out;
 
@@ -268,16 +267,15 @@ s32 igb_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
 						   IGP01E1000_PHY_PAGE_SELECT,
 						   (u16)offset);
 		if (ret_val) {
-			igb_release_phy(hw);
+			hw->phy.ops.release(hw);
 			goto out;
 		}
 	}
 
-	ret_val = igb_read_phy_reg_mdic(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val = igb_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+					data);
 
-	igb_release_phy(hw);
+	hw->phy.ops.release(hw);
 
 out:
 	return ret_val;
@@ -294,9 +292,12 @@ out:
  **/
 s32 igb_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
 
-	ret_val = igb_acquire_phy(hw);
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		goto out;
 
@@ -305,16 +306,15 @@ s32 igb_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
 						   IGP01E1000_PHY_PAGE_SELECT,
 						   (u16)offset);
 		if (ret_val) {
-			igb_release_phy(hw);
+			hw->phy.ops.release(hw);
 			goto out;
 		}
 	}
 
-	ret_val = igb_write_phy_reg_mdic(hw,
-					   MAX_PHY_REG_ADDRESS & offset,
+	ret_val = igb_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
 					   data);
 
-	igb_release_phy(hw);
+	hw->phy.ops.release(hw);
 
 out:
 	return ret_val;
@@ -339,8 +339,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 	}
 
 	/* Enable CRS on TX. This must be set for half-duplex operation. */
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
@@ -383,8 +382,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 	if (phy->disable_polarity_correction == 1)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					    phy_data);
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -393,8 +391,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
 		 */
-		ret_val = hw->phy.ops.read_phy_reg(hw,
-					     M88E1000_EXT_PHY_SPEC_CTRL,
+		ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
 					     &phy_data);
 		if (ret_val)
 			goto out;
@@ -413,8 +410,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 			phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
 				     M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X);
 		}
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					     M88E1000_EXT_PHY_SPEC_CTRL,
+		ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
 					     phy_data);
 		if (ret_val)
 			goto out;
@@ -449,7 +445,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.reset_phy(hw);
+	ret_val = phy->ops.reset(hw);
 	if (ret_val) {
 		hw_dbg("Error resetting the PHY.\n");
 		goto out;
@@ -464,8 +460,8 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 	 */
 	if (phy->type == e1000_phy_igp) {
 		/* disable lplu d3 during driver init */
-		if (hw->phy.ops.set_d3_lplu_state)
-			ret_val = hw->phy.ops.set_d3_lplu_state(hw, false);
+		if (phy->ops.set_d3_lplu_state)
+			ret_val = phy->ops.set_d3_lplu_state(hw, false);
 		if (ret_val) {
 			hw_dbg("Error Disabling LPLU D3\n");
 			goto out;
@@ -473,13 +469,13 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 	}
 
 	/* disable lplu d0 during driver init */
-	ret_val = hw->phy.ops.set_d0_lplu_state(hw, false);
+	ret_val = phy->ops.set_d0_lplu_state(hw, false);
 	if (ret_val) {
 		hw_dbg("Error Disabling LPLU D0\n");
 		goto out;
 	}
 	/* Configure mdi-mdix settings */
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, &data);
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CTRL, &data);
 	if (ret_val)
 		goto out;
 
@@ -497,7 +493,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		data |= IGP01E1000_PSCR_AUTO_MDIX;
 		break;
 	}
-	ret_val = hw->phy.ops.write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, data);
+	ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CTRL, data);
 	if (ret_val)
 		goto out;
 
@@ -510,33 +506,31 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		 */
 		if (phy->autoneg_advertised == ADVERTISE_1000_FULL) {
 			/* Disable SmartSpeed */
-			ret_val = hw->phy.ops.read_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+			ret_val = phy->ops.read_reg(hw,
+						    IGP01E1000_PHY_PORT_CONFIG,
+						    &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
 				goto out;
 
 			/* Set auto Master/Slave resolution process */
-			ret_val = hw->phy.ops.read_phy_reg(hw, PHY_1000T_CTRL,
-							   &data);
+			ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL, &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~CR_1000T_MS_ENABLE;
-			ret_val = hw->phy.ops.write_phy_reg(hw, PHY_1000T_CTRL,
-							    data);
+			ret_val = phy->ops.write_reg(hw, PHY_1000T_CTRL, data);
 			if (ret_val)
 				goto out;
 		}
 
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_1000T_CTRL, &data);
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL, &data);
 		if (ret_val)
 			goto out;
 
@@ -560,7 +554,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		default:
 			break;
 		}
-		ret_val = hw->phy.ops.write_phy_reg(hw, PHY_1000T_CTRL, data);
+		ret_val = phy->ops.write_reg(hw, PHY_1000T_CTRL, data);
 		if (ret_val)
 			goto out;
 	}
@@ -609,12 +603,12 @@ s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
 	 * the Auto Neg Restart bit in the PHY control register.
 	 */
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_ctrl);
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_ctrl);
 	if (ret_val)
 		goto out;
 
 	phy_ctrl |= (MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG);
-	ret_val = hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, phy_ctrl);
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_ctrl);
 	if (ret_val)
 		goto out;
 
@@ -656,15 +650,13 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 	phy->autoneg_advertised &= phy->autoneg_mask;
 
 	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_AUTONEG_ADV,
-					   &mii_autoneg_adv_reg);
+	ret_val = phy->ops.read_reg(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_reg);
 	if (ret_val)
 		goto out;
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		/* Read the MII 1000Base-T Control Register (Address 9). */
-		ret_val = hw->phy.ops.read_phy_reg(hw,
-					    PHY_1000T_CTRL,
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL,
 					    &mii_1000t_ctrl_reg);
 		if (ret_val)
 			goto out;
@@ -785,17 +777,16 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, PHY_AUTONEG_ADV,
-					    mii_autoneg_adv_reg);
+	ret_val = phy->ops.write_reg(hw, PHY_AUTONEG_ADV, mii_autoneg_adv_reg);
 	if (ret_val)
 		goto out;
 
 	hw_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      PHY_1000T_CTRL,
-					      mii_1000t_ctrl_reg);
+		ret_val = phy->ops.write_reg(hw,
+					     PHY_1000T_CTRL,
+					     mii_1000t_ctrl_reg);
 		if (ret_val)
 			goto out;
 	}
@@ -819,13 +810,13 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	igb_phy_force_speed_duplex_setup(hw, &phy_data);
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, phy_data);
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -833,16 +824,14 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	 * Clear Auto-Crossover to force MDI manually.  IGP requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy_data &= ~IGP01E1000_PSCR_AUTO_MDIX;
 	phy_data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
-					    phy_data);
+	ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CTRL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -897,20 +886,18 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					    phy_data);
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
 		goto out;
 
 	hw_dbg("M88E1000 PSCR: %X\n", phy_data);
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
 		goto out;
 
@@ -919,7 +906,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	/* Reset the phy to commit changes. */
 	phy_data |= MII_CR_RESET;
 
-	ret_val = hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, phy_data);
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -940,7 +927,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			 * We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
-			ret_val = hw->phy.ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 						      M88E1000_PHY_PAGE_SELECT,
 						      0x001d);
 			if (ret_val)
@@ -957,8 +944,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			goto out;
 	}
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
@@ -968,8 +954,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	 * the reset value of 2.5MHz.
 	 */
 	phy_data |= M88E1000_EPSCR_TX_CLK_25;
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
-					    phy_data);
+	ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
 		goto out;
 
@@ -977,14 +962,12 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	 * In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
-	ret_val = hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					    phy_data);
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 
 out:
 	return ret_val;
@@ -1071,15 +1054,13 @@ s32 igb_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-					   &data);
+	ret_val = phy->ops.read_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
 		goto out;
 
 	if (!active) {
 		data &= ~IGP02E1000_PM_D3_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					     IGP02E1000_PHY_POWER_MGMT,
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 					     data);
 		if (ret_val)
 			goto out;
@@ -1090,27 +1071,27 @@ s32 igb_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 		 * SmartSpeed, so performance is maintained.
 		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
+			ret_val = phy->ops.read_reg(hw,
 						    IGP01E1000_PHY_PORT_CONFIG,
 						    &data);
 			if (ret_val)
 				goto out;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
 				goto out;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
+			ret_val = phy->ops.read_reg(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
+			ret_val = phy->ops.write_reg(hw,
 						     IGP01E1000_PHY_PORT_CONFIG,
 						     data);
 			if (ret_val)
@@ -1120,22 +1101,19 @@ s32 igb_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 		   (phy->autoneg_advertised == E1000_ALL_NOT_GIG) ||
 		   (phy->autoneg_advertised == E1000_ALL_10_SPEED)) {
 		data |= IGP02E1000_PM_D3_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP02E1000_PHY_POWER_MGMT,
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 					      data);
 		if (ret_val)
 			goto out;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = hw->phy.ops.read_phy_reg(hw,
-					     IGP01E1000_PHY_PORT_CONFIG,
+		ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
 					     &data);
 		if (ret_val)
 			goto out;
 
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP01E1000_PHY_PORT_CONFIG,
+		ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
 					      data);
 	}
 
@@ -1176,7 +1154,7 @@ s32 igb_check_downshift(struct e1000_hw *hw)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, offset, &phy_data);
+	ret_val = phy->ops.read_reg(hw, offset, &phy_data);
 
 	if (!ret_val)
 		phy->speed_downgraded = (phy_data & mask) ? true : false;
@@ -1199,7 +1177,7 @@ static s32 igb_check_polarity_m88(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &data);
 
 	if (!ret_val)
 		phy->cable_polarity = (data & M88E1000_PSSR_REV_POLARITY)
@@ -1228,8 +1206,7 @@ static s32 igb_check_polarity_igp(struct e1000_hw *hw)
 	 * Polarity is determined based on the speed of
 	 * our connection.
 	 */
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
-					   &data);
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
 		goto out;
 
@@ -1246,7 +1223,7 @@ static s32 igb_check_polarity_igp(struct e1000_hw *hw)
 		mask	= IGP01E1000_PSSR_POLARITY_REVERSED;
 	}
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, offset, &data);
+	ret_val = phy->ops.read_reg(hw, offset, &data);
 
 	if (!ret_val)
 		phy->cable_polarity = (data & mask)
@@ -1271,10 +1248,10 @@ static s32 igb_wait_autoneg(struct e1000_hw *hw)
 
 	/* Break after autoneg completes or PHY_AUTO_NEG_LIMIT expires. */
 	for (i = PHY_AUTO_NEG_LIMIT; i > 0; i--) {
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS, &phy_status);
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS, &phy_status);
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;
 		if (phy_status & MII_SR_AUTONEG_COMPLETE)
@@ -1310,10 +1287,10 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 		 * twice due to the link bit being sticky.  No harm doing
 		 * it across the board.
 		 */
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS, &phy_status);
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_STATUS, &phy_status);
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;
 		if (phy_status & MII_SR_LINK_STATUS)
@@ -1350,8 +1327,7 @@ s32 igb_get_cable_length_m88(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data, index;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 	if (ret_val)
 		goto out;
 
@@ -1372,8 +1348,8 @@ out:
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
  *  received signal, adjusting for the attenuation produced by the
- *  cable.  By reading the AGC registers, which reperesent the
- *  cobination of course and fine gain value, the value can be put
+ *  cable.  By reading the AGC registers, which represent the
+ *  combination of coarse and fine gain value, the value can be put
  *  into a lookup table to obtain the approximate cable length
  *  for each channel.
  **/
@@ -1392,14 +1368,13 @@ s32 igb_get_cable_length_igp_2(struct e1000_hw *hw)
 
 	/* Read the AGC registers for all channels */
 	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
-		ret_val = hw->phy.ops.read_phy_reg(hw, agc_reg_array[i],
-						   &phy_data);
+		ret_val = phy->ops.read_reg(hw, agc_reg_array[i], &phy_data);
 		if (ret_val)
 			goto out;
 
 		/*
 		 * Getting bits 15:9, which represent the combination of
-		 * course and fine gain values.  The result is a number
+		 * coarse and fine gain values.  The result is a number
 		 * that can be put into the lookup table to obtain the
 		 * approximate cable length.
 		 */
@@ -1456,7 +1431,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	if (hw->phy.media_type != e1000_media_type_copper) {
+	if (phy->media_type != e1000_media_type_copper) {
 		hw_dbg("Phy info is only valid for copper media\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
@@ -1472,33 +1447,29 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 		goto out;
 	}
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy->polarity_correction = (phy_data & M88E1000_PSCR_POLARITY_REVERSAL)
-				   ? true
-				   : false;
+				   ? true : false;
 
 	ret_val = igb_check_polarity_m88(hw);
 	if (ret_val)
 		goto out;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
-					   &phy_data);
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
 	if (ret_val)
 		goto out;
 
 	phy->is_mdix = (phy_data & M88E1000_PSSR_MDIX) ? true : false;
 
 	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
-		ret_val = hw->phy.ops.get_cable_length(hw);
+		ret_val = phy->ops.get_cable_length(hw);
 		if (ret_val)
 			goto out;
 
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_1000T_STATUS,
-						   &phy_data);
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_STATUS, &phy_data);
 		if (ret_val)
 			goto out;
 
@@ -1552,8 +1523,7 @@ s32 igb_get_phy_info_igp(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
-					   &data);
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
 		goto out;
 
@@ -1561,12 +1531,11 @@ s32 igb_get_phy_info_igp(struct e1000_hw *hw)
 
 	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
 	    IGP01E1000_PSSR_SPEED_1000MBPS) {
-		ret_val = hw->phy.ops.get_cable_length(hw);
+		ret_val = phy->ops.get_cable_length(hw);
 		if (ret_val)
 			goto out;
 
-		ret_val = hw->phy.ops.read_phy_reg(hw, PHY_1000T_STATUS,
-						   &data);
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_STATUS, &data);
 		if (ret_val)
 			goto out;
 
@@ -1599,12 +1568,12 @@ s32 igb_phy_sw_reset(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_ctrl;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_ctrl);
+	ret_val = hw->phy.ops.read_reg(hw, PHY_CONTROL, &phy_ctrl);
 	if (ret_val)
 		goto out;
 
 	phy_ctrl |= MII_CR_RESET;
-	ret_val = hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, phy_ctrl);
+	ret_val = hw->phy.ops.write_reg(hw, PHY_CONTROL, phy_ctrl);
 	if (ret_val)
 		goto out;
 
@@ -1635,7 +1604,7 @@ s32 igb_phy_hw_reset(struct e1000_hw *hw)
 		goto out;
 	}
 
-	ret_val = igb_acquire_phy(hw);
+	ret_val = phy->ops.acquire(hw);
 	if (ret_val)
 		goto out;
 
@@ -1650,74 +1619,14 @@ s32 igb_phy_hw_reset(struct e1000_hw *hw)
 
 	udelay(150);
 
-	igb_release_phy(hw);
+	phy->ops.release(hw);
 
-	ret_val = igb_get_phy_cfg_done(hw);
+	ret_val = phy->ops.get_cfg_done(hw);
 
 out:
 	return ret_val;
 }
 
-/* Internal function pointers */
-
-/**
- *  igb_get_phy_cfg_done - Generic PHY configuration done
- *  @hw: pointer to the HW structure
- *
- *  Return success if silicon family did not implement a family specific
- *  get_cfg_done function.
- **/
-static s32 igb_get_phy_cfg_done(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.get_cfg_done)
-		return hw->phy.ops.get_cfg_done(hw);
-
-	return 0;
-}
-
-/**
- *  igb_release_phy - Generic release PHY
- *  @hw: pointer to the HW structure
- *
- *  Return if silicon family does not require a semaphore when accessing the
- *  PHY.
- **/
-static void igb_release_phy(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.release_phy)
-		hw->phy.ops.release_phy(hw);
-}
-
-/**
- *  igb_acquire_phy - Generic acquire PHY
- *  @hw: pointer to the HW structure
- *
- *  Return success if silicon family does not require a semaphore when
- *  accessing the PHY.
- **/
-static s32 igb_acquire_phy(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.acquire_phy)
-		return hw->phy.ops.acquire_phy(hw);
-
-	return 0;
-}
-
-/**
- *  igb_phy_force_speed_duplex - Generic force PHY speed/duplex
- *  @hw: pointer to the HW structure
- *
- *  When the silicon family has not implemented a forced speed/duplex
- *  function for the PHY, simply return 0.
- **/
-s32 igb_phy_force_speed_duplex(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.force_speed_duplex)
-		return hw->phy.ops.force_speed_duplex(hw);
-
-	return 0;
-}
-
 /**
  *  igb_phy_init_script_igp3 - Inits the IGP3 PHY
  *  @hw: pointer to the HW structure
@@ -1730,75 +1639,75 @@ s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 
 	/* PHY init IGP 3 */
 	/* Enable rise/fall, 10-mode work in class-A */
-	hw->phy.ops.write_phy_reg(hw, 0x2F5B, 0x9018);
+	hw->phy.ops.write_reg(hw, 0x2F5B, 0x9018);
 	/* Remove all caps from Replica path filter */
-	hw->phy.ops.write_phy_reg(hw, 0x2F52, 0x0000);
+	hw->phy.ops.write_reg(hw, 0x2F52, 0x0000);
 	/* Bias trimming for ADC, AFE and Driver (Default) */
-	hw->phy.ops.write_phy_reg(hw, 0x2FB1, 0x8B24);
+	hw->phy.ops.write_reg(hw, 0x2FB1, 0x8B24);
 	/* Increase Hybrid poly bias */
-	hw->phy.ops.write_phy_reg(hw, 0x2FB2, 0xF8F0);
+	hw->phy.ops.write_reg(hw, 0x2FB2, 0xF8F0);
 	/* Add 4% to TX amplitude in Giga mode */
-	hw->phy.ops.write_phy_reg(hw, 0x2010, 0x10B0);
+	hw->phy.ops.write_reg(hw, 0x2010, 0x10B0);
 	/* Disable trimming (TTT) */
-	hw->phy.ops.write_phy_reg(hw, 0x2011, 0x0000);
+	hw->phy.ops.write_reg(hw, 0x2011, 0x0000);
 	/* Poly DC correction to 94.6% + 2% for all channels */
-	hw->phy.ops.write_phy_reg(hw, 0x20DD, 0x249A);
+	hw->phy.ops.write_reg(hw, 0x20DD, 0x249A);
 	/* ABS DC correction to 95.9% */
-	hw->phy.ops.write_phy_reg(hw, 0x20DE, 0x00D3);
+	hw->phy.ops.write_reg(hw, 0x20DE, 0x00D3);
 	/* BG temp curve trim */
-	hw->phy.ops.write_phy_reg(hw, 0x28B4, 0x04CE);
+	hw->phy.ops.write_reg(hw, 0x28B4, 0x04CE);
 	/* Increasing ADC OPAMP stage 1 currents to max */
-	hw->phy.ops.write_phy_reg(hw, 0x2F70, 0x29E4);
+	hw->phy.ops.write_reg(hw, 0x2F70, 0x29E4);
 	/* Force 1000 ( required for enabling PHY regs configuration) */
-	hw->phy.ops.write_phy_reg(hw, 0x0000, 0x0140);
+	hw->phy.ops.write_reg(hw, 0x0000, 0x0140);
 	/* Set upd_freq to 6 */
-	hw->phy.ops.write_phy_reg(hw, 0x1F30, 0x1606);
+	hw->phy.ops.write_reg(hw, 0x1F30, 0x1606);
 	/* Disable NPDFE */
-	hw->phy.ops.write_phy_reg(hw, 0x1F31, 0xB814);
+	hw->phy.ops.write_reg(hw, 0x1F31, 0xB814);
 	/* Disable adaptive fixed FFE (Default) */
-	hw->phy.ops.write_phy_reg(hw, 0x1F35, 0x002A);
+	hw->phy.ops.write_reg(hw, 0x1F35, 0x002A);
 	/* Enable FFE hysteresis */
-	hw->phy.ops.write_phy_reg(hw, 0x1F3E, 0x0067);
+	hw->phy.ops.write_reg(hw, 0x1F3E, 0x0067);
 	/* Fixed FFE for short cable lengths */
-	hw->phy.ops.write_phy_reg(hw, 0x1F54, 0x0065);
+	hw->phy.ops.write_reg(hw, 0x1F54, 0x0065);
 	/* Fixed FFE for medium cable lengths */
-	hw->phy.ops.write_phy_reg(hw, 0x1F55, 0x002A);
+	hw->phy.ops.write_reg(hw, 0x1F55, 0x002A);
 	/* Fixed FFE for long cable lengths */
-	hw->phy.ops.write_phy_reg(hw, 0x1F56, 0x002A);
+	hw->phy.ops.write_reg(hw, 0x1F56, 0x002A);
 	/* Enable Adaptive Clip Threshold */
-	hw->phy.ops.write_phy_reg(hw, 0x1F72, 0x3FB0);
+	hw->phy.ops.write_reg(hw, 0x1F72, 0x3FB0);
 	/* AHT reset limit to 1 */
-	hw->phy.ops.write_phy_reg(hw, 0x1F76, 0xC0FF);
+	hw->phy.ops.write_reg(hw, 0x1F76, 0xC0FF);
 	/* Set AHT master delay to 127 msec */
-	hw->phy.ops.write_phy_reg(hw, 0x1F77, 0x1DEC);
+	hw->phy.ops.write_reg(hw, 0x1F77, 0x1DEC);
 	/* Set scan bits for AHT */
-	hw->phy.ops.write_phy_reg(hw, 0x1F78, 0xF9EF);
+	hw->phy.ops.write_reg(hw, 0x1F78, 0xF9EF);
 	/* Set AHT Preset bits */
-	hw->phy.ops.write_phy_reg(hw, 0x1F79, 0x0210);
+	hw->phy.ops.write_reg(hw, 0x1F79, 0x0210);
 	/* Change integ_factor of channel A to 3 */
-	hw->phy.ops.write_phy_reg(hw, 0x1895, 0x0003);
+	hw->phy.ops.write_reg(hw, 0x1895, 0x0003);
 	/* Change prop_factor of channels BCD to 8 */
-	hw->phy.ops.write_phy_reg(hw, 0x1796, 0x0008);
+	hw->phy.ops.write_reg(hw, 0x1796, 0x0008);
 	/* Change cg_icount + enable integbp for channels BCD */
-	hw->phy.ops.write_phy_reg(hw, 0x1798, 0xD008);
+	hw->phy.ops.write_reg(hw, 0x1798, 0xD008);
 	/*
 	 * Change cg_icount + enable integbp + change prop_factor_master
 	 * to 8 for channel A
 	 */
-	hw->phy.ops.write_phy_reg(hw, 0x1898, 0xD918);
+	hw->phy.ops.write_reg(hw, 0x1898, 0xD918);
 	/* Disable AHT in Slave mode on channel A */
-	hw->phy.ops.write_phy_reg(hw, 0x187A, 0x0800);
+	hw->phy.ops.write_reg(hw, 0x187A, 0x0800);
 	/*
 	 * Enable LPLU and disable AN to 1000 in non-D0a states,
 	 * Enable SPD+B2B
 	 */
-	hw->phy.ops.write_phy_reg(hw, 0x0019, 0x008D);
+	hw->phy.ops.write_reg(hw, 0x0019, 0x008D);
 	/* Enable restart AN on an1000_dis change */
-	hw->phy.ops.write_phy_reg(hw, 0x001B, 0x2080);
+	hw->phy.ops.write_reg(hw, 0x001B, 0x2080);
 	/* Enable wh_fifo read clock in 10/100 modes */
-	hw->phy.ops.write_phy_reg(hw, 0x0014, 0x0045);
+	hw->phy.ops.write_reg(hw, 0x0014, 0x0045);
 	/* Restart AN, Speed selection is 1000 */
-	hw->phy.ops.write_phy_reg(hw, 0x0000, 0x1340);
+	hw->phy.ops.write_reg(hw, 0x0000, 0x1340);
 
 	return 0;
 }
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index 8f8fe0a..7499e5d 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -44,7 +44,6 @@ enum e1000_smart_speed {
 s32  igb_check_downshift(struct e1000_hw *hw);
 s32  igb_check_reset_block(struct e1000_hw *hw);
 s32  igb_copper_link_autoneg(struct e1000_hw *hw);
-s32  igb_phy_force_speed_duplex(struct e1000_hw *hw);
 s32  igb_copper_link_setup_igp(struct e1000_hw *hw);
 s32  igb_copper_link_setup_m88(struct e1000_hw *hw);
 s32  igb_phy_force_speed_duplex_igp(struct e1000_hw *hw);
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 530d7aa..a2a812d 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -313,24 +313,24 @@ extern void igb_set_ethtool_ops(struct net_device *);
 
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
 {
-	if (hw->phy.ops.reset_phy)
-		return hw->phy.ops.reset_phy(hw);
+	if (hw->phy.ops.reset)
+		return hw->phy.ops.reset(hw);
 
 	return 0;
 }
 
 static inline s32 igb_read_phy_reg(struct e1000_hw *hw, u32 offset, u16 *data)
 {
-	if (hw->phy.ops.read_phy_reg)
-		return hw->phy.ops.read_phy_reg(hw, offset, data);
+	if (hw->phy.ops.read_reg)
+		return hw->phy.ops.read_reg(hw, offset, data);
 
 	return 0;
 }
 
 static inline s32 igb_write_phy_reg(struct e1000_hw *hw, u32 offset, u16 data)
 {
-	if (hw->phy.ops.write_phy_reg)
-		return hw->phy.ops.write_phy_reg(hw, offset, data);
+	if (hw->phy.ops.write_reg)
+		return hw->phy.ops.write_reg(hw, offset, data);
 
 	return 0;
 }

