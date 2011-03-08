From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/14] ixgbe: cleanup PHY init
Date: Mon,  7 Mar 2011 18:25:01 -0800
Message-ID: <1299551108-23663-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55556 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032Ab1CHC0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:08 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change cleans up several situations in which we were either stepping
over possible errors, or calling initialization routines multiple times.
Also includes whitespace fixes where applicable.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c |   31 ++++++++--
 drivers/net/ixgbe/ixgbe_82599.c |  121 +++++++++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_phy.c   |   21 ++++++-
 3 files changed, 114 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index fc41329..dc977b1 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -280,10 +280,22 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 {
 	enum ixgbe_media_type media_type;
 
+	/* Detect if there is a copper PHY attached. */
+	switch (hw->phy.type) {
+	case ixgbe_phy_cu_unknown:
+	case ixgbe_phy_tn:
+	case ixgbe_phy_aq:
+		media_type = ixgbe_media_type_copper;
+		goto out;
+	default:
+		break;
+	}
+
 	/* Media type for I82598 is based on device ID */
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82598:
 	case IXGBE_DEV_ID_82598_BX:
+		/* Default device ID is mezzanine card KX/KX4 */
 		media_type = ixgbe_media_type_backplane;
 		break;
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
@@ -306,7 +318,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 		media_type = ixgbe_media_type_unknown;
 		break;
 	}
-
+out:
 	return media_type;
 }
 
@@ -632,7 +644,7 @@ out:
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if auto-negotiation enabled
- *  @autoneg_wait_to_complete: true if waiting is needed to complete
+ *  @autoneg_wait_to_complete: true when waiting for completion is needed
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
@@ -671,7 +683,8 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw,
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		status = ixgbe_start_mac_link_82598(hw, autoneg_wait_to_complete);
+		status = ixgbe_start_mac_link_82598(hw,
+						    autoneg_wait_to_complete);
 	}
 
 	return status;
@@ -1090,10 +1103,12 @@ static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 
 	/* Copper PHY must be checked before AUTOC LMS to determine correct
 	 * physical layer because 10GBase-T PHYs use LMS = KX4/KX */
-	if (hw->phy.type == ixgbe_phy_tn ||
-	    hw->phy.type == ixgbe_phy_cu_unknown) {
-		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
-				     &ext_ability);
+	switch (hw->phy.type) {
+	case ixgbe_phy_tn:
+	case ixgbe_phy_aq:
+	case ixgbe_phy_cu_unknown:
+		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE,
+		MDIO_MMD_PMAPMD, &ext_ability);
 		if (ext_ability & MDIO_PMA_EXTABLE_10GBT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
 		if (ext_ability & MDIO_PMA_EXTABLE_1000BT)
@@ -1101,6 +1116,8 @@ static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 		if (ext_ability & MDIO_PMA_EXTABLE_100BTX)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
 		goto out;
+	default:
+		break;
 	}
 
 	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5ef968a..2f8b9f4 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -470,8 +470,6 @@ static void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
  **/
 static void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
-	hw_dbg(hw, "ixgbe_flap_tx_laser_multispeed_fiber\n");
-
 	if (hw->mac.autotry_restart) {
 		ixgbe_disable_tx_laser_multispeed_fiber(hw);
 		ixgbe_enable_tx_laser_multispeed_fiber(hw);
@@ -494,17 +492,21 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
                                           bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
-	ixgbe_link_speed phy_link_speed;
+	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_UNKNOWN;
 	ixgbe_link_speed highest_link_speed = IXGBE_LINK_SPEED_UNKNOWN;
 	u32 speedcnt = 0;
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
+	u32 i = 0;
 	bool link_up = false;
 	bool negotiation;
-	int i;
 
 	/* Mask off requested but non-supported speeds */
-	hw->mac.ops.get_link_capabilities(hw, &phy_link_speed, &negotiation);
-	speed &= phy_link_speed;
+	status = hw->mac.ops.get_link_capabilities(hw, &link_speed,
+						   &negotiation);
+	if (status != 0)
+		return status;
+
+	speed &= link_speed;
 
 	/*
 	 * Try each speed one by one, highest priority first.  We do this in
@@ -515,9 +517,12 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		highest_link_speed = IXGBE_LINK_SPEED_10GB_FULL;
 
 		/* If we already have link at this speed, just jump out */
-		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+		status = hw->mac.ops.check_link(hw, &link_speed, &link_up,
+						false);
+		if (status != 0)
+			return status;
 
-		if ((phy_link_speed == IXGBE_LINK_SPEED_10GB_FULL) && link_up)
+		if ((link_speed == IXGBE_LINK_SPEED_10GB_FULL) && link_up)
 			goto out;
 
 		/* Set the module link speed */
@@ -529,9 +534,9 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		msleep(40);
 
 		status = ixgbe_setup_mac_link_82599(hw,
-		                               IXGBE_LINK_SPEED_10GB_FULL,
-		                               autoneg,
-		                               autoneg_wait_to_complete);
+						    IXGBE_LINK_SPEED_10GB_FULL,
+						    autoneg,
+						    autoneg_wait_to_complete);
 		if (status != 0)
 			return status;
 
@@ -548,8 +553,11 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			msleep(100);
 
 			/* If we have link, just jump out */
-			hw->mac.ops.check_link(hw, &phy_link_speed,
-			                       &link_up, false);
+			status = hw->mac.ops.check_link(hw, &link_speed,
+							&link_up, false);
+			if (status != 0)
+				return status;
+
 			if (link_up)
 				goto out;
 		}
@@ -561,9 +569,12 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			highest_link_speed = IXGBE_LINK_SPEED_1GB_FULL;
 
 		/* If we already have link at this speed, just jump out */
-		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+		status = hw->mac.ops.check_link(hw, &link_speed, &link_up,
+						false);
+		if (status != 0)
+			return status;
 
-		if ((phy_link_speed == IXGBE_LINK_SPEED_1GB_FULL) && link_up)
+		if ((link_speed == IXGBE_LINK_SPEED_1GB_FULL) && link_up)
 			goto out;
 
 		/* Set the module link speed */
@@ -576,9 +587,9 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		msleep(40);
 
 		status = ixgbe_setup_mac_link_82599(hw,
-		                                      IXGBE_LINK_SPEED_1GB_FULL,
-		                                      autoneg,
-		                                      autoneg_wait_to_complete);
+						    IXGBE_LINK_SPEED_1GB_FULL,
+						    autoneg,
+						    autoneg_wait_to_complete);
 		if (status != 0)
 			return status;
 
@@ -589,7 +600,11 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		msleep(100);
 
 		/* If we have link, just jump out */
-		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+		status = hw->mac.ops.check_link(hw, &link_speed, &link_up,
+						false);
+		if (status != 0)
+			return status;
+
 		if (link_up)
 			goto out;
 	}
@@ -632,13 +647,10 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 				     bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
-	ixgbe_link_speed link_speed;
+	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_UNKNOWN;
 	s32 i, j;
 	bool link_up = false;
 	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	struct ixgbe_adapter *adapter = hw->back;
-
-	hw_dbg(hw, "ixgbe_setup_mac_link_smartspeed.\n");
 
 	 /* Set autoneg_advertised value based on input link speed */
 	hw->phy.autoneg_advertised = 0;
@@ -664,7 +676,7 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 	for (j = 0; j < IXGBE_SMARTSPEED_MAX_RETRIES; j++) {
 		status = ixgbe_setup_mac_link_82599(hw, speed, autoneg,
 						    autoneg_wait_to_complete);
-		if (status)
+		if (status != 0)
 			goto out;
 
 		/*
@@ -677,8 +689,11 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 			mdelay(100);
 
 			/* If we have link, just jump out */
-			hw->mac.ops.check_link(hw, &link_speed,
-			                       &link_up, false);
+			status = hw->mac.ops.check_link(hw, &link_speed,
+							&link_up, false);
+			if (status != 0)
+				goto out;
+
 			if (link_up)
 				goto out;
 		}
@@ -696,7 +711,7 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 	hw->phy.smart_speed_active = true;
 	status = ixgbe_setup_mac_link_82599(hw, speed, autoneg,
 					    autoneg_wait_to_complete);
-	if (status)
+	if (status != 0)
 		goto out;
 
 	/*
@@ -709,8 +724,11 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 		mdelay(100);
 
 		/* If we have link, just jump out */
-		hw->mac.ops.check_link(hw, &link_speed,
-		                       &link_up, false);
+		status = hw->mac.ops.check_link(hw, &link_speed,
+						&link_up, false);
+		if (status != 0)
+			goto out;
+
 		if (link_up)
 			goto out;
 	}
@@ -722,7 +740,7 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 
 out:
 	if (link_up && (link_speed == IXGBE_LINK_SPEED_1GB_FULL))
-		e_info(hw, "Smartspeed has downgraded the link speed from "
+		hw_dbg(hw, "Smartspeed has downgraded the link speed from "
 		       "the maximum advertised\n");
 	return status;
 }
@@ -883,7 +901,7 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 
 	/* PHY ops must be identified and initialized prior to reset */
 
-	/* Init PHY and function pointers, perform SFP setup */
+	/* Identify PHY and related function pointers */
 	status = hw->phy.ops.init(hw);
 
 	if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
@@ -895,6 +913,9 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 		hw->phy.sfp_setup_needed = false;
 	}
 
+	if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		goto reset_hw_out;
+
 	/* Reset PHY */
 	if (hw->phy.reset_disable == false && hw->phy.ops.reset != NULL)
 		hw->phy.ops.reset(hw);
@@ -2051,28 +2072,28 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
-	.init_params            = &ixgbe_init_eeprom_params_generic,
-	.read                   = &ixgbe_read_eerd_generic,
-	.write                  = &ixgbe_write_eeprom_generic,
-	.calc_checksum          = &ixgbe_calc_eeprom_checksum_generic,
-	.validate_checksum      = &ixgbe_validate_eeprom_checksum_generic,
-	.update_checksum        = &ixgbe_update_eeprom_checksum_generic,
+	.init_params		= &ixgbe_init_eeprom_params_generic,
+	.read			= &ixgbe_read_eerd_generic,
+	.write			= &ixgbe_write_eeprom_generic,
+	.calc_checksum		= &ixgbe_calc_eeprom_checksum_generic,
+	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
+	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
 };
 
 static struct ixgbe_phy_operations phy_ops_82599 = {
-	.identify               = &ixgbe_identify_phy_82599,
-	.identify_sfp           = &ixgbe_identify_sfp_module_generic,
-	.init			            = &ixgbe_init_phy_ops_82599,
-	.reset                  = &ixgbe_reset_phy_generic,
-	.read_reg               = &ixgbe_read_phy_reg_generic,
-	.write_reg              = &ixgbe_write_phy_reg_generic,
-	.setup_link             = &ixgbe_setup_phy_link_generic,
-	.setup_link_speed       = &ixgbe_setup_phy_link_speed_generic,
-	.read_i2c_byte          = &ixgbe_read_i2c_byte_generic,
-	.write_i2c_byte         = &ixgbe_write_i2c_byte_generic,
-	.read_i2c_eeprom        = &ixgbe_read_i2c_eeprom_generic,
-	.write_i2c_eeprom       = &ixgbe_write_i2c_eeprom_generic,
-	.check_overtemp         = &ixgbe_tn_check_overtemp,
+	.identify		= &ixgbe_identify_phy_82599,
+	.identify_sfp		= &ixgbe_identify_sfp_module_generic,
+	.init			= &ixgbe_init_phy_ops_82599,
+	.reset			= &ixgbe_reset_phy_generic,
+	.read_reg		= &ixgbe_read_phy_reg_generic,
+	.write_reg		= &ixgbe_write_phy_reg_generic,
+	.setup_link		= &ixgbe_setup_phy_link_generic,
+	.setup_link_speed	= &ixgbe_setup_phy_link_speed_generic,
+	.read_i2c_byte		= &ixgbe_read_i2c_byte_generic,
+	.write_i2c_byte		= &ixgbe_write_i2c_byte_generic,
+	.read_i2c_eeprom	= &ixgbe_read_i2c_eeprom_generic,
+	.write_i2c_eeprom	= &ixgbe_write_i2c_eeprom_generic,
+	.check_overtemp		= &ixgbe_tn_check_overtemp,
 };
 
 struct ixgbe_info ixgbe_82599_info = {
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 197230b..9190a8f 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -57,6 +57,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u32 phy_addr;
+	u16 ext_ability = 0;
 
 	if (hw->phy.type == ixgbe_phy_unknown) {
 		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
@@ -65,12 +66,29 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 				ixgbe_get_phy_id(hw);
 				hw->phy.type =
 				        ixgbe_get_phy_type_from_id(hw->phy.id);
+
+				if (hw->phy.type == ixgbe_phy_unknown) {
+					hw->phy.ops.read_reg(hw,
+							     MDIO_PMA_EXTABLE,
+							     MDIO_MMD_PMAPMD,
+							     &ext_ability);
+					if (ext_ability &
+					    (MDIO_PMA_EXTABLE_10GBT |
+					     MDIO_PMA_EXTABLE_1000BT))
+						hw->phy.type =
+							 ixgbe_phy_cu_unknown;
+					else
+						hw->phy.type =
+							 ixgbe_phy_generic;
+				}
+
 				status = 0;
 				break;
 			}
 		}
 		/* clear value if nothing found */
-		hw->phy.mdio.prtad = 0;
+		if (status != 0)
+			hw->phy.mdio.prtad = 0;
 	} else {
 		status = 0;
 	}
@@ -823,7 +841,6 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			goto out;
 		}
 
-		/* This is guaranteed to be 82599, no need to check for NULL */
 		hw->mac.ops.get_device_caps(hw, &enforce_sfp);
 		if (!(enforce_sfp & IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP) &&
 		    !((hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0) ||
-- 
1.7.4

