From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 18/29] ixgbe: update to latest common code
	module
Date: Thu, 11 Sep 2008 19:59:59 -0700
Message-ID: <20080912025945.6234.18348.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbYILDAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:00:03 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:00:02 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is a massive update that includes infrastructure for further patches
where we will add support for more phy types and eeprom types.

This code is shared as much as possible with other drivers, so the code may
seem a little obtuse at times but wherever possible we keep to the linux
style and methods.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    2 
 drivers/net/ixgbe/ixgbe_82598.c   |  600 +++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_common.c  |  914 +++++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_common.h  |   59 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |   20 -
 drivers/net/ixgbe/ixgbe_main.c    |  105 +++-
 drivers/net/ixgbe/ixgbe_phy.c     |  241 ++++------
 drivers/net/ixgbe/ixgbe_phy.h     |   60 ++
 drivers/net/ixgbe/ixgbe_type.h    |  513 ++++++++++++++-------
 9 files changed, 1700 insertions(+), 814 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 27db64f..2388af2 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -41,8 +41,6 @@
 #include <linux/dca.h>
 #endif
 
-#define IXGBE_ERR(args...) printk(KERN_ERR "ixgbe: " args)
-
 #define PFX "ixgbe: "
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 0726140..a08a267 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -39,68 +39,80 @@
 #define IXGBE_82598_MC_TBL_SIZE  128
 #define IXGBE_82598_VFT_TBL_SIZE 128
 
-static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
-					 bool *autoneg);
-static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
-						u32 *speed, bool *autoneg);
+static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg);
 static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw);
+static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num);
 static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-                                      bool *link_up,
-                                      bool link_up_wait_to_complete);
-static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
-					    bool autoneg,
-					    bool autoneg_wait_to_complete);
+static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
+                               ixgbe_link_speed *speed,
+                               bool *link_up, bool link_up_wait_to_complete);
+static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
+                                            ixgbe_link_speed speed,
+                                            bool autoneg,
+                                            bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
-					       bool autoneg,
-					       bool autoneg_wait_to_complete);
+static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete);
 static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
+static s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
+static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
+static s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan,
+                         u32 vind, bool vlan_on);
+static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw);
+static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index);
+static s32 ixgbe_blink_led_start_82598(struct ixgbe_hw *hw, u32 index);
+static s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val);
+static s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val);
+static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw);
+static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw);
 
-
+/**
+ */
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
-	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
-	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.mcft_size = IXGBE_82598_MC_TBL_SIZE;
-	hw->mac.vft_size = IXGBE_82598_VFT_TBL_SIZE;
-	hw->mac.num_rar_entries = IXGBE_82598_RAR_ENTRIES;
-
-	/* PHY ops are filled in by default properly for Fiber only */
-	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper) {
-		hw->mac.ops.setup_link = &ixgbe_setup_copper_link_82598;
-		hw->mac.ops.setup_link_speed = &ixgbe_setup_copper_link_speed_82598;
-		hw->mac.ops.get_link_settings =
-				&ixgbe_get_copper_link_settings_82598;
-
-		/* Call PHY identify routine to get the phy type */
-		ixgbe_identify_phy(hw);
-
-		switch (hw->phy.type) {
-		case ixgbe_phy_tn:
-			hw->phy.ops.setup_link = &ixgbe_setup_tnx_phy_link;
-			hw->phy.ops.check_link = &ixgbe_check_tnx_phy_link;
-			hw->phy.ops.setup_link_speed =
-					&ixgbe_setup_tnx_phy_link_speed;
-			break;
-		default:
-			break;
-		}
+	struct ixgbe_mac_info *mac = &hw->mac;
+	struct ixgbe_phy_info *phy = &hw->phy;
+
+	/* Call PHY identify routine to get the phy type */
+	ixgbe_identify_phy_generic(hw);
+
+	/* PHY Init */
+	switch (phy->type) {
+	default:
+		break;
+	}
+
+	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
+		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
+		mac->ops.setup_link_speed =
+		                     &ixgbe_setup_copper_link_speed_82598;
+		mac->ops.get_link_capabilities =
+		                     &ixgbe_get_copper_link_capabilities_82598;
 	}
 
+	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
+
 	return 0;
 }
 
 /**
- *  ixgbe_get_link_settings_82598 - Determines default link settings
+ *  ixgbe_get_link_capabilities_82598 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @autoneg: boolean auto-negotiation value
  *
- *  Determines the default link settings by reading the AUTOC register.
+ *  Determines the link capabilities by reading the AUTOC register.
  **/
-static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
+static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed,
 					 bool *autoneg)
 {
 	s32 status = 0;
@@ -150,15 +162,16 @@ static s32 ixgbe_get_link_settings_82598(struct ixgbe_hw *hw, u32 *speed,
 }
 
 /**
- *  ixgbe_get_copper_link_settings_82598 - Determines default link settings
+ *  ixgbe_get_copper_link_capabilities_82598 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @autoneg: boolean auto-negotiation value
  *
- *  Determines the default link settings by reading the AUTOC register.
+ *  Determines the link capabilities by reading the AUTOC register.
  **/
-static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
-						u32 *speed, bool *autoneg)
+s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg)
 {
 	s32 status = IXGBE_ERR_LINK_SETUP;
 	u16 speed_ability;
@@ -166,7 +179,7 @@ static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
 	*speed = 0;
 	*autoneg = true;
 
-	status = ixgbe_read_phy_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
 				    IXGBE_MDIO_PMA_PMD_DEV_TYPE,
 				    &speed_ability);
 
@@ -199,9 +212,6 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 		media_type = ixgbe_media_type_fiber;
 		break;
-	case IXGBE_DEV_ID_82598AT_DUAL_PORT:
-		media_type = ixgbe_media_type_copper;
-		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
@@ -211,6 +221,122 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_setup_fc_82598 - Configure flow control settings
+ *  @hw: pointer to hardware structure
+ *  @packetbuf_num: packet buffer number (0-7)
+ *
+ *  Configures the flow control settings based on SW configuration.  This
+ *  function is used for 802.3x flow control configuration only.
+ **/
+s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	u32 frctl_reg;
+	u32 rmcs_reg;
+
+	if (packetbuf_num < 0 || packetbuf_num > 7) {
+		hw_dbg(hw, "Invalid packet buffer number [%d], expected range is"
+		          " 0-7\n", packetbuf_num);
+	}
+
+	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	frctl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
+
+	rmcs_reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
+
+	/*
+	 * 10 gig parts do not have a word in the EEPROM to determine the
+	 * default flow control setting, so we explicitly set it to full.
+	 */
+	if (hw->fc.type == ixgbe_fc_default)
+		hw->fc.type = ixgbe_fc_full;
+
+	/*
+	 * We want to save off the original Flow Control configuration just in
+	 * case we get disconnected and then reconnected into a different hub
+	 * or switch with different Flow Control capabilities.
+	 */
+	hw->fc.original_type = hw->fc.type;
+
+	/*
+	 * The possible values of the "flow_control" parameter are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames but not
+	 *    send pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but we do not
+	 *    support receiving pause frames)
+	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+	 * other: Invalid.
+	 */
+	switch (hw->fc.type) {
+	case ixgbe_fc_none:
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled,
+		 * and Tx Flow control is disabled.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is disabled,
+		 * by a software over-ride.
+		 */
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	case ixgbe_fc_full:
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
+		 * over-ride.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	default:
+		/* We should never get here.  The value should be 0-3. */
+		hw_dbg(hw, "Flow control param set incorrectly\n");
+		break;
+	}
+
+	/* Enable 802.3x based flow control settings. */
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, frctl_reg);
+	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
+
+	/*
+	 * Check for invalid software configuration, zeros are completely
+	 * invalid for all parameters used past this point, and if we enable
+	 * flow control with zero water marks, we blast flow control packets.
+	 */
+	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
+		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
+		return IXGBE_ERR_INVALID_LINK_SETTINGS;
+	}
+
+	/*
+	 * We need to set up the Receive Threshold high and low water
+	 * marks as well as (optionally) enabling the transmission of
+	 * XON frames.
+	 */
+	if (hw->fc.type & ixgbe_fc_tx_pause) {
+		if (hw->fc.send_xon) {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+			                (hw->fc.low_water | IXGBE_FCRTL_XONE));
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+			                hw->fc.low_water);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
+		                (hw->fc.high_water)|IXGBE_FCRTH_FCEN);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(0), hw->fc.pause_time);
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+
+	return 0;
+}
+
+/**
  *  ixgbe_setup_mac_link_82598 - Configures MAC link settings
  *  @hw: pointer to hardware structure
  *
@@ -254,8 +380,7 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 			}
 			if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
 				status = IXGBE_ERR_AUTONEG_NOT_COMPLETE;
-				hw_dbg(hw,
-				       "Autonegotiation did not complete.\n");
+				hw_dbg(hw, "Autonegotiation did not complete.\n");
 			}
 		}
 	}
@@ -265,8 +390,8 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 	 * case we get disconnected and then reconnected into a different hub
 	 * or switch with different Flow Control capabilities.
 	 */
-	hw->fc.type = hw->fc.original_type;
-	ixgbe_setup_fc(hw, 0);
+	hw->fc.original_type = hw->fc.type;
+	ixgbe_setup_fc_82598(hw, 0);
 
 	/* Add delay to filter out noises during initial link setup */
 	msleep(50);
@@ -283,15 +408,13 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
-static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-                                      bool *link_up,
-                                      bool link_up_wait_to_complete)
+static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
+                               bool *link_up, bool link_up_wait_to_complete)
 {
 	u32 links_reg;
 	u32 i;
 
 	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
-
 	if (link_up_wait_to_complete) {
 		for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
 			if (links_reg & IXGBE_LINKS_UP) {
@@ -318,6 +441,7 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
 	return 0;
 }
 
+
 /**
  *  ixgbe_setup_mac_link_speed_82598 - Set MAC link speed
  *  @hw: pointer to hardware structure
@@ -328,18 +452,18 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
  *  Set the link speed in the AUTOC register and restarts link.
  **/
 static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
-					    u32 speed, bool autoneg,
+					    ixgbe_link_speed speed, bool autoneg,
 					    bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 
 	/* If speed is 10G, then check for CX4 or XAUI. */
 	if ((speed == IXGBE_LINK_SPEED_10GB_FULL) &&
-	    (!(hw->mac.link_attach_type & IXGBE_AUTOC_10G_KX4)))
+	    (!(hw->mac.link_attach_type & IXGBE_AUTOC_10G_KX4))) {
 		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-	else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg))
+	} else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg)) {
 		hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_LINK_NO_AN;
-	else if (autoneg) {
+	} else if (autoneg) {
 		/* BX mode - Autonegotiate 1G */
 		if (!(hw->mac.link_attach_type & IXGBE_AUTOC_1G_PMA_PMD))
 			hw->mac.link_mode_select = IXGBE_AUTOC_LMS_1G_AN;
@@ -358,7 +482,7 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		hw->mac.ops.setup_link(hw);
+		ixgbe_setup_mac_link_82598(hw);
 	}
 
 	return status;
@@ -376,18 +500,17 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
 {
-	s32 status = 0;
+	s32 status;
 
 	/* Restart autonegotiation on PHY */
-	if (hw->phy.ops.setup_link)
-		status = hw->phy.ops.setup_link(hw);
+	status = hw->phy.ops.setup_link(hw);
 
-	/* Set MAC to KX/KX4 autoneg, which defaultis to Parallel detection */
+	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
 	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
 	/* Set up MAC */
-	hw->mac.ops.setup_link(hw);
+	ixgbe_setup_mac_link_82598(hw);
 
 	return status;
 }
@@ -401,14 +524,14 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
  *
  *  Sets the link speed in the AUTOC register in the MAC and restarts link.
  **/
-static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
+static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw,
+					       ixgbe_link_speed speed,
 					       bool autoneg,
 					       bool autoneg_wait_to_complete)
 {
-	s32 status = 0;
+	s32 status;
 
 	/* Setup the PHY according to input speed */
-	if (hw->phy.ops.setup_link_speed)
 		status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
 						autoneg_wait_to_complete);
 
@@ -417,7 +540,7 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
 	/* Set up MAC */
-	hw->mac.ops.setup_link(hw);
+	ixgbe_setup_mac_link_82598(hw);
 
 	return status;
 }
@@ -426,7 +549,7 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
  *  ixgbe_reset_hw_82598 - Performs hardware reset
  *  @hw: pointer to hardware structure
  *
- *  Resets the hardware by reseting the transmit and receive units, masks and
+ *  Resets the hardware by resetting the transmit and receive units, masks and
  *  clears all interrupts, performing a PHY reset, and performing a link (MAC)
  *  reset.
  **/
@@ -440,35 +563,44 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	u8  analog_val;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
-	ixgbe_stop_adapter(hw);
+	hw->mac.ops.stop_adapter(hw);
 
 	/*
-	 * Power up the Atlas TX lanes if they are currently powered down.
-	 * Atlas TX lanes are powered down for MAC loopback tests, but
+	 * Power up the Atlas Tx lanes if they are currently powered down.
+	 * Atlas Tx lanes are powered down for MAC loopback tests, but
 	 * they are not automatically restored on reset.
 	 */
-	ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
+	hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
 	if (analog_val & IXGBE_ATLAS_PDN_TX_REG_EN) {
-		/* Enable TX Atlas so packets can be transmitted again */
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &analog_val);
+		/* Enable Tx Atlas so packets can be transmitted again */
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_REG_EN;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_10G,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_10G_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_10G,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_1G,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_1G_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_1G,
+		                              analog_val);
 
-		ixgbe_read_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, &analog_val);
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_AN,
+		                             &analog_val);
 		analog_val &= ~IXGBE_ATLAS_PDN_TX_AN_QL_ALL;
-		ixgbe_write_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, analog_val);
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_AN,
+		                              analog_val);
 	}
 
 	/* Reset PHY */
-	ixgbe_reset_phy(hw);
+	if (hw->phy.reset_disable == false)
+		hw->phy.ops.reset(hw);
 
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
@@ -527,23 +659,305 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	}
 
 	/* Store the permanent mac address */
-	ixgbe_get_mac_addr(hw, hw->mac.perm_addr);
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
 	return status;
 }
 
+/**
+ *  ixgbe_set_vmdq_82598 - Associate a VMDq set index with a rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to associate with a VMDq index
+ *  @vmdq: VMDq set index
+ **/
+s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
+	rar_high &= ~IXGBE_RAH_VIND_MASK;
+	rar_high |= ((vmdq << IXGBE_RAH_VIND_SHIFT) & IXGBE_RAH_VIND_MASK);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_vmdq_82598 - Disassociate a VMDq set index from an rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to associate with a VMDq index
+ *  @vmdq: VMDq clear index (not used in 82598, but elsewhere)
+ **/
+static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	if (rar < rar_entries) {
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(rar));
+		if (rar_high & IXGBE_RAH_VIND_MASK) {
+			rar_high &= ~IXGBE_RAH_VIND_MASK;
+			IXGBE_WRITE_REG(hw, IXGBE_RAH(rar), rar_high);
+		}
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+	}
+
+	return 0;
+}
+
+/**
+ *  ixgbe_set_vfta_82598 - Set VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vlan: VLAN id to write to VLAN filter
+ *  @vind: VMDq output index that maps queue to VLAN id in VFTA
+ *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
+ *
+ *  Turn on/off specified VLAN in the VLAN filter table.
+ **/
+s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+	                                              bool vlan_on)
+{
+	u32 regindex;
+	u32 bitindex;
+	u32 bits;
+	u32 vftabyte;
+
+	if (vlan > 4095)
+		return IXGBE_ERR_PARAM;
+
+	/* Determine 32-bit word position in array */
+	regindex = (vlan >> 5) & 0x7F;   /* upper seven bits */
+
+	/* Determine the location of the (VMD) queue index */
+	vftabyte =  ((vlan >> 3) & 0x03); /* bits (4:3) indicating byte array */
+	bitindex = (vlan & 0x7) << 2;    /* lower 3 bits indicate nibble */
+
+	/* Set the nibble for VMD queue index */
+	bits = IXGBE_READ_REG(hw, IXGBE_VFTAVIND(vftabyte, regindex));
+	bits &= (~(0x0F << bitindex));
+	bits |= (vind << bitindex);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vftabyte, regindex), bits);
+
+	/* Determine the location of the bit for this VLAN id */
+	bitindex = vlan & 0x1F;   /* lower five bits */
+
+	bits = IXGBE_READ_REG(hw, IXGBE_VFTA(regindex));
+	if (vlan_on)
+		/* Turn on this VLAN id */
+		bits |= (1 << bitindex);
+	else
+		/* Turn off this VLAN id */
+		bits &= ~(1 << bitindex);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTA(regindex), bits);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_vfta_82598 - Clear VLAN filter table
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ **/
+static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw)
+{
+	u32 offset;
+	u32 vlanbyte;
+
+	for (offset = 0; offset < hw->mac.vft_size; offset++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+
+	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
+		for (offset = 0; offset < hw->mac.vft_size; offset++)
+			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
+			                                                  0);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_start_82598 - Blink LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ **/
+static s32 ixgbe_blink_led_start_82598(struct ixgbe_hw *hw, u32 index)
+{
+	ixgbe_link_speed speed = 0;
+	bool link_up = 0;
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/*
+	 * Link must be up to auto-blink the LEDs on the 82598EB MAC;
+	 * force it if link is down.
+	 */
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+
+	if (!link_up) {
+		autoc_reg |= IXGBE_AUTOC_FLU;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+		msleep(10);
+	}
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_stop_82598 - Stop blinking LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to stop blinking
+ **/
+static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index)
+{
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	autoc_reg &= ~IXGBE_AUTOC_FLU;
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg &= ~IXGBE_LED_BLINK(index);
+	led_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_read_analog_reg8_82598 - Reads 8 bit Atlas analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: analog register to read
+ *  @val: read value
+ *
+ *  Performs read operation to Atlas analog register specified.
+ **/
+s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
+{
+	u32  atlas_ctl;
+
+	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL,
+	                IXGBE_ATLASCTL_WRITE_CMD | (reg << 8));
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+	atlas_ctl = IXGBE_READ_REG(hw, IXGBE_ATLASCTL);
+	*val = (u8)atlas_ctl;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_write_analog_reg8_82598 - Writes 8 bit Atlas analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: atlas register to write
+ *  @val: value to write
+ *
+ *  Performs write operation to Atlas analog register specified.
+ **/
+s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
+{
+	u32  atlas_ctl;
+
+	atlas_ctl = (reg << 8) | val;
+	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL, atlas_ctl);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_get_supported_physical_layer_82598 - Returns physical layer type
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines physical layer capabilities of the current configuration.
+ **/
+s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
+{
+	s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
+		break;
+	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+		break;
+	case IXGBE_DEV_ID_82598EB_XF_LR:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+		break;
+
+	default:
+		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+		break;
+	}
+
+	return physical_layer;
+}
+
 static struct ixgbe_mac_operations mac_ops_82598 = {
-	.reset			= &ixgbe_reset_hw_82598,
+	.init_hw		= &ixgbe_init_hw_generic,
+	.reset_hw		= &ixgbe_reset_hw_82598,
+	.start_hw		= &ixgbe_start_hw_generic,
+	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type		= &ixgbe_get_media_type_82598,
+	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82598,
+	.get_mac_addr		= &ixgbe_get_mac_addr_generic,
+	.stop_adapter		= &ixgbe_stop_adapter_generic,
+	.read_analog_reg8	= &ixgbe_read_analog_reg8_82598,
+	.write_analog_reg8	= &ixgbe_write_analog_reg8_82598,
 	.setup_link		= &ixgbe_setup_mac_link_82598,
-	.check_link		= &ixgbe_check_mac_link_82598,
 	.setup_link_speed	= &ixgbe_setup_mac_link_speed_82598,
-	.get_link_settings	= &ixgbe_get_link_settings_82598,
+	.check_link		= &ixgbe_check_mac_link_82598,
+	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
+	.led_on			= &ixgbe_led_on_generic,
+	.led_off		= &ixgbe_led_off_generic,
+	.blink_led_start	= &ixgbe_blink_led_start_82598,
+	.blink_led_stop		= &ixgbe_blink_led_stop_82598,
+	.set_rar		= &ixgbe_set_rar_generic,
+	.clear_rar		= &ixgbe_clear_rar_generic,
+	.set_vmdq		= &ixgbe_set_vmdq_82598,
+	.clear_vmdq		= &ixgbe_clear_vmdq_82598,
+	.init_rx_addrs		= &ixgbe_init_rx_addrs_generic,
+	.update_uc_addr_list	= &ixgbe_update_uc_addr_list_generic,
+	.update_mc_addr_list	= &ixgbe_update_mc_addr_list_generic,
+	.enable_mc		= &ixgbe_enable_mc_generic,
+	.disable_mc		= &ixgbe_disable_mc_generic,
+	.clear_vfta		= &ixgbe_clear_vfta_82598,
+	.set_vfta		= &ixgbe_set_vfta_82598,
+	.setup_fc		= &ixgbe_setup_fc_82598,
+};
+
+static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
+	.init_params		= &ixgbe_init_eeprom_params_generic,
+	.read			= &ixgbe_read_eeprom_generic,
+	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
+	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
+};
+
+static struct ixgbe_phy_operations phy_ops_82598 = {
+	.identify		= &ixgbe_identify_phy_generic,
+	/* .identify_sfp	= &ixgbe_identify_sfp_module_generic, */
+	.reset			= &ixgbe_reset_phy_generic,
+	.read_reg		= &ixgbe_read_phy_reg_generic,
+	.write_reg		= &ixgbe_write_phy_reg_generic,
+	.setup_link		= &ixgbe_setup_phy_link_generic,
+	.setup_link_speed	= &ixgbe_setup_phy_link_speed_generic,
 };
 
 struct ixgbe_info ixgbe_82598_info = {
 	.mac			= ixgbe_mac_82598EB,
 	.get_invariants		= &ixgbe_get_invariants_82598,
 	.mac_ops		= &mac_ops_82598,
+	.eeprom_ops		= &eeprom_ops_82598,
+	.phy_ops		= &phy_ops_82598,
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index f5b2617..a11ff0d 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -33,20 +33,28 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
-static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw);
-
 static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw);
+static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw);
 static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw);
 static void ixgbe_release_eeprom_semaphore(struct ixgbe_hw *hw);
+static s32 ixgbe_ready_eeprom(struct ixgbe_hw *hw);
+static void ixgbe_standby_eeprom(struct ixgbe_hw *hw);
+static void ixgbe_shift_out_eeprom_bits(struct ixgbe_hw *hw, u16 data,
+                                        u16 count);
+static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count);
+static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
 static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw);
 
-static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw);
-static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw);
+static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
+static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr);
+static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
 
 /**
- *  ixgbe_start_hw - Prepare hardware for TX/RX
+ *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
  *  @hw: pointer to hardware structure
  *
  *  Starts the hardware by filling the bus info structure and media type, clears
@@ -54,7 +62,7 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr);
  *  table, VLAN filter table, calls routine to set up link and flow control
  *  settings, and leaves transmit and receive units disabled and uninitialized
  **/
-s32 ixgbe_start_hw(struct ixgbe_hw *hw)
+s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 {
 	u32 ctrl_ext;
 
@@ -62,22 +70,22 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 	hw->phy.media_type = hw->mac.ops.get_media_type(hw);
 
 	/* Identify the PHY */
-	ixgbe_identify_phy(hw);
+	hw->phy.ops.identify(hw);
 
 	/*
 	 * Store MAC address from RAR0, clear receive address registers, and
 	 * clear the multicast table
 	 */
-	ixgbe_init_rx_addrs(hw);
+	hw->mac.ops.init_rx_addrs(hw);
 
 	/* Clear the VLAN filter table */
-	ixgbe_clear_vfta(hw);
+	hw->mac.ops.clear_vfta(hw);
 
 	/* Set up link */
 	hw->mac.ops.setup_link(hw);
 
 	/* Clear statistics registers */
-	ixgbe_clear_hw_cntrs(hw);
+	hw->mac.ops.clear_hw_cntrs(hw);
 
 	/* Set No Snoop Disable */
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
@@ -92,34 +100,34 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_init_hw - Generic hardware initialization
+ *  ixgbe_init_hw_generic - Generic hardware initialization
  *  @hw: pointer to hardware structure
  *
- *  Initialize the hardware by reseting the hardware, filling the bus info
+ *  Initialize the hardware by resetting the hardware, filling the bus info
  *  structure and media type, clears all on chip counters, initializes receive
  *  address registers, multicast table, VLAN filter table, calls routine to set
  *  up link and flow control settings, and leaves transmit and receive units
  *  disabled and uninitialized
  **/
-s32 ixgbe_init_hw(struct ixgbe_hw *hw)
+s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw)
 {
 	/* Reset the hardware */
-	hw->mac.ops.reset(hw);
+	hw->mac.ops.reset_hw(hw);
 
 	/* Start the HW */
-	ixgbe_start_hw(hw);
+	hw->mac.ops.start_hw(hw);
 
 	return 0;
 }
 
 /**
- *  ixgbe_clear_hw_cntrs - Generic clear hardware counters
+ *  ixgbe_clear_hw_cntrs_generic - Generic clear hardware counters
  *  @hw: pointer to hardware structure
  *
  *  Clears all hardware statistics counters by reading them from the hardware
  *  Statistics counters are clear on read.
  **/
-static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
+s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 {
 	u16 i = 0;
 
@@ -191,7 +199,36 @@ static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_get_mac_addr - Generic get MAC address
+ *  ixgbe_read_pba_num_generic - Reads part number from EEPROM
+ *  @hw: pointer to hardware structure
+ *  @pba_num: stores the part number from the EEPROM
+ *
+ *  Reads the part number from the EEPROM.
+ **/
+s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num)
+{
+	s32 ret_val;
+	u16 data;
+
+	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM0_PTR, &data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*pba_num = (u32)(data << 16);
+
+	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM1_PTR, &data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*pba_num |= data;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_get_mac_addr_generic - Generic get MAC address
  *  @hw: pointer to hardware structure
  *  @mac_addr: Adapter MAC address
  *
@@ -199,7 +236,7 @@ static s32 ixgbe_clear_hw_cntrs(struct ixgbe_hw *hw)
  *  A reset of the adapter must be performed prior to calling this function
  *  in order for the MAC address to have been loaded from the EEPROM into RAR0
  **/
-s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
+s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr)
 {
 	u32 rar_high;
 	u32 rar_low;
@@ -217,30 +254,8 @@ s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
 	return 0;
 }
 
-s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num)
-{
-	s32 ret_val;
-	u16 data;
-
-	ret_val = ixgbe_read_eeprom(hw, IXGBE_PBANUM0_PTR, &data);
-	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
-		return ret_val;
-	}
-	*part_num = (u32)(data << 16);
-
-	ret_val = ixgbe_read_eeprom(hw, IXGBE_PBANUM1_PTR, &data);
-	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
-		return ret_val;
-	}
-	*part_num |= data;
-
-	return 0;
-}
-
 /**
- *  ixgbe_stop_adapter - Generic stop TX/RX units
+ *  ixgbe_stop_adapter_generic - Generic stop Tx/Rx units
  *  @hw: pointer to hardware structure
  *
  *  Sets the adapter_stopped flag within ixgbe_hw struct. Clears interrupts,
@@ -248,7 +263,7 @@ s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num)
  *  the shared code and drivers to determine if the adapter is in a stopped
  *  state and should not touch the hardware.
  **/
-s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
+s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw)
 {
 	u32 number_of_queues;
 	u32 reg_val;
@@ -264,6 +279,7 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 	reg_val = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	reg_val &= ~(IXGBE_RXCTRL_RXEN);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_val);
+	IXGBE_WRITE_FLUSH(hw);
 	msleep(2);
 
 	/* Clear interrupt mask to stop from interrupts being generated */
@@ -273,7 +289,7 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 	IXGBE_READ_REG(hw, IXGBE_EICR);
 
 	/* Disable the transmit unit.  Each queue must be disabled. */
-	number_of_queues = hw->mac.num_tx_queues;
+	number_of_queues = hw->mac.max_tx_queues;
 	for (i = 0; i < number_of_queues; i++) {
 		reg_val = IXGBE_READ_REG(hw, IXGBE_TXDCTL(i));
 		if (reg_val & IXGBE_TXDCTL_ENABLE) {
@@ -282,15 +298,22 @@ s32 ixgbe_stop_adapter(struct ixgbe_hw *hw)
 		}
 	}
 
+	/*
+	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
+	 * access and verify no pending requests
+	 */
+	if (ixgbe_disable_pcie_master(hw) != 0)
+		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+
 	return 0;
 }
 
 /**
- *  ixgbe_led_on - Turns on the software controllable LEDs.
+ *  ixgbe_led_on_generic - Turns on the software controllable LEDs.
  *  @hw: pointer to hardware structure
  *  @index: led number to turn on
  **/
-s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
+s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
@@ -304,11 +327,11 @@ s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
 }
 
 /**
- *  ixgbe_led_off - Turns off the software controllable LEDs.
+ *  ixgbe_led_off_generic - Turns off the software controllable LEDs.
  *  @hw: pointer to hardware structure
  *  @index: led number to turn off
  **/
-s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
+s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
@@ -321,15 +344,14 @@ s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
 	return 0;
 }
 
-
 /**
- *  ixgbe_init_eeprom - Initialize EEPROM params
+ *  ixgbe_init_eeprom_params_generic - Initialize EEPROM params
  *  @hw: pointer to hardware structure
  *
  *  Initializes the EEPROM parameters ixgbe_eeprom_info within the
  *  ixgbe_hw struct in order to set up EEPROM access.
  **/
-s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
+s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 {
 	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
 	u32 eec;
@@ -337,6 +359,9 @@ s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
 
 	if (eeprom->type == ixgbe_eeprom_uninitialized) {
 		eeprom->type = ixgbe_eeprom_none;
+		/* Set default semaphore delay to 10ms which is a well
+		 * tested value */
+		eeprom->semaphore_delay = 10;
 
 		/*
 		 * Check for EEPROM present first.
@@ -369,18 +394,85 @@ s32 ixgbe_init_eeprom(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_read_eeprom - Read EEPROM word using EERD
+ *  ixgbe_read_eeprom_bit_bang_generic - Read EEPROM word using bit-bang
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @data: read 16 bit value from EEPROM
+ *
+ *  Reads 16 bit value from EEPROM through bit-bang method
+ **/
+s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+                                       u16 *data)
+{
+	s32 status;
+	u16 word_in;
+	u8 read_opcode = IXGBE_EEPROM_READ_OPCODE_SPI;
+
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
+	/* Prepare the EEPROM for reading  */
+	status = ixgbe_acquire_eeprom(hw);
+
+	if (status == 0) {
+		if (ixgbe_ready_eeprom(hw) != 0) {
+			ixgbe_release_eeprom(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	if (status == 0) {
+		ixgbe_standby_eeprom(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
+			read_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+		/* Send the READ command (opcode + addr) */
+		ixgbe_shift_out_eeprom_bits(hw, read_opcode,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+		ixgbe_shift_out_eeprom_bits(hw, (u16)(offset*2),
+		                            hw->eeprom.address_bits);
+
+		/* Read the data. */
+		word_in = ixgbe_shift_in_eeprom_bits(hw, 16);
+		*data = (word_in >> 8) | (word_in << 8);
+
+		/* End this read operation */
+		ixgbe_release_eeprom(hw);
+	}
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_read_eeprom_generic - Read EEPROM word using EERD
  *  @hw: pointer to hardware structure
  *  @offset: offset of  word in the EEPROM to read
  *  @data: word read from the EEPROM
  *
  *  Reads a 16 bit word from the EEPROM using the EERD register.
  **/
-s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data)
+s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
 	u32 eerd;
 	s32 status;
 
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
 	eerd = (offset << IXGBE_EEPROM_READ_ADDR_SHIFT) +
 	       IXGBE_EEPROM_READ_REG_START;
 
@@ -393,6 +485,7 @@ s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data)
 	else
 		hw_dbg(hw, "Eeprom read timed out\n");
 
+out:
 	return status;
 }
 
@@ -420,6 +513,58 @@ static s32 ixgbe_poll_eeprom_eerd_done(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_acquire_eeprom - Acquire EEPROM using bit-bang
+ *  @hw: pointer to hardware structure
+ *
+ *  Prepares EEPROM for access using bit-bang method. This function should
+ *  be called before issuing a command to the EEPROM.
+ **/
+static s32 ixgbe_acquire_eeprom(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u32 eec;
+	u32 i;
+
+	if (ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) != 0)
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	if (status == 0) {
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		/* Request EEPROM Access */
+		eec |= IXGBE_EEC_REQ;
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+		for (i = 0; i < IXGBE_EEPROM_GRANT_ATTEMPTS; i++) {
+			eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+			if (eec & IXGBE_EEC_GNT)
+				break;
+			udelay(5);
+		}
+
+		/* Release if grant not acquired */
+		if (!(eec & IXGBE_EEC_GNT)) {
+			eec &= ~IXGBE_EEC_REQ;
+			IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+			hw_dbg(hw, "Could not acquire EEPROM grant\n");
+
+			ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	/* Setup EEPROM for Read/Write */
+	if (status == 0) {
+		/* Clear CS and SK */
+		eec &= ~(IXGBE_EEC_CS | IXGBE_EEC_SK);
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+		udelay(1);
+	}
+	return status;
+}
+
+/**
  *  ixgbe_get_eeprom_semaphore - Get hardware semaphore
  *  @hw: pointer to hardware structure
  *
@@ -503,6 +648,217 @@ static void ixgbe_release_eeprom_semaphore(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_ready_eeprom - Polls for EEPROM ready
+ *  @hw: pointer to hardware structure
+ **/
+static s32 ixgbe_ready_eeprom(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u16 i;
+	u8 spi_stat_reg;
+
+	/*
+	 * Read "Status Register" repeatedly until the LSB is cleared.  The
+	 * EEPROM will signal that the command has been completed by clearing
+	 * bit 0 of the internal status register.  If it's not cleared within
+	 * 5 milliseconds, then error out.
+	 */
+	for (i = 0; i < IXGBE_EEPROM_MAX_RETRY_SPI; i += 5) {
+		ixgbe_shift_out_eeprom_bits(hw, IXGBE_EEPROM_RDSR_OPCODE_SPI,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+		spi_stat_reg = (u8)ixgbe_shift_in_eeprom_bits(hw, 8);
+		if (!(spi_stat_reg & IXGBE_EEPROM_STATUS_RDY_SPI))
+			break;
+
+		udelay(5);
+		ixgbe_standby_eeprom(hw);
+	};
+
+	/*
+	 * On some parts, SPI write time could vary from 0-20mSec on 3.3V
+	 * devices (and only 0-5mSec on 5V devices)
+	 */
+	if (i >= IXGBE_EEPROM_MAX_RETRY_SPI) {
+		hw_dbg(hw, "SPI EEPROM Status error\n");
+		status = IXGBE_ERR_EEPROM;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_standby_eeprom - Returns EEPROM to a "standby" state
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_standby_eeprom(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/* Toggle CS to flush commands */
+	eec |= IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+	eec &= ~IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_shift_out_eeprom_bits - Shift data bits out to the EEPROM.
+ *  @hw: pointer to hardware structure
+ *  @data: data to send to the EEPROM
+ *  @count: number of bits to shift out
+ **/
+static void ixgbe_shift_out_eeprom_bits(struct ixgbe_hw *hw, u16 data,
+                                        u16 count)
+{
+	u32 eec;
+	u32 mask;
+	u32 i;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/*
+	 * Mask is used to shift "count" bits of "data" out to the EEPROM
+	 * one bit at a time.  Determine the starting bit based on count
+	 */
+	mask = 0x01 << (count - 1);
+
+	for (i = 0; i < count; i++) {
+		/*
+		 * A "1" is shifted out to the EEPROM by setting bit "DI" to a
+		 * "1", and then raising and then lowering the clock (the SK
+		 * bit controls the clock input to the EEPROM).  A "0" is
+		 * shifted out to the EEPROM by setting "DI" to "0" and then
+		 * raising and then lowering the clock.
+		 */
+		if (data & mask)
+			eec |= IXGBE_EEC_DI;
+		else
+			eec &= ~IXGBE_EEC_DI;
+
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+
+		udelay(1);
+
+		ixgbe_raise_eeprom_clk(hw, &eec);
+		ixgbe_lower_eeprom_clk(hw, &eec);
+
+		/*
+		 * Shift mask to signify next bit of data to shift in to the
+		 * EEPROM
+		 */
+		mask = mask >> 1;
+	};
+
+	/* We leave the "DI" bit set to "0" when we leave this routine. */
+	eec &= ~IXGBE_EEC_DI;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+}
+
+/**
+ *  ixgbe_shift_in_eeprom_bits - Shift data bits in from the EEPROM
+ *  @hw: pointer to hardware structure
+ **/
+static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count)
+{
+	u32 eec;
+	u32 i;
+	u16 data = 0;
+
+	/*
+	 * In order to read a register from the EEPROM, we need to shift
+	 * 'count' bits in from the EEPROM. Bits are "shifted in" by raising
+	 * the clock input to the EEPROM (setting the SK bit), and then reading
+	 * the value of the "DO" bit.  During this "shifting in" process the
+	 * "DI" bit should always be clear.
+	 */
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec &= ~(IXGBE_EEC_DO | IXGBE_EEC_DI);
+
+	for (i = 0; i < count; i++) {
+		data = data << 1;
+		ixgbe_raise_eeprom_clk(hw, &eec);
+
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		eec &= ~(IXGBE_EEC_DI);
+		if (eec & IXGBE_EEC_DO)
+			data |= 1;
+
+		ixgbe_lower_eeprom_clk(hw, &eec);
+	}
+
+	return data;
+}
+
+/**
+ *  ixgbe_raise_eeprom_clk - Raises the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eec: EEC register's current value
+ **/
+static void ixgbe_raise_eeprom_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Raise the clock input to the EEPROM
+	 * (setting the SK bit), then delay
+	 */
+	*eec = *eec | IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_lower_eeprom_clk - Lowers the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eecd: EECD's current value
+ **/
+static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Lower the clock input to the EEPROM (clearing the SK bit), then
+	 * delay
+	 */
+	*eec = *eec & ~IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_release_eeprom - Release EEPROM, release semaphores
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec |= IXGBE_EEC_CS;  /* Pull CS high */
+	eec &= ~IXGBE_EEC_SK; /* Lower SCK */
+
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+
+	udelay(1);
+
+	/* Stop requesting EEPROM access */
+	eec &= ~IXGBE_EEC_REQ;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+	ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+}
+
+/**
  *  ixgbe_calc_eeprom_checksum - Calculates and returns the checksum
  *  @hw: pointer to hardware structure
  **/
@@ -517,7 +873,7 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 
 	/* Include 0x0-0x3F in the checksum */
 	for (i = 0; i < IXGBE_EEPROM_CHECKSUM; i++) {
-		if (ixgbe_read_eeprom(hw, i, &word) != 0) {
+		if (hw->eeprom.ops.read(hw, i, &word) != 0) {
 			hw_dbg(hw, "EEPROM read failed\n");
 			break;
 		}
@@ -526,15 +882,15 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 
 	/* Include all data from pointers except for the fw pointer */
 	for (i = IXGBE_PCIE_ANALOG_PTR; i < IXGBE_FW_PTR; i++) {
-		ixgbe_read_eeprom(hw, i, &pointer);
+		hw->eeprom.ops.read(hw, i, &pointer);
 
 		/* Make sure the pointer seems valid */
 		if (pointer != 0xFFFF && pointer != 0) {
-			ixgbe_read_eeprom(hw, pointer, &length);
+			hw->eeprom.ops.read(hw, pointer, &length);
 
 			if (length != 0xFFFF && length != 0) {
 				for (j = pointer+1; j <= pointer+length; j++) {
-					ixgbe_read_eeprom(hw, j, &word);
+					hw->eeprom.ops.read(hw, j, &word);
 					checksum += word;
 				}
 			}
@@ -547,14 +903,15 @@ static u16 ixgbe_calc_eeprom_checksum(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_validate_eeprom_checksum - Validate EEPROM checksum
+ *  ixgbe_validate_eeprom_checksum_generic - Validate EEPROM checksum
  *  @hw: pointer to hardware structure
  *  @checksum_val: calculated checksum
  *
  *  Performs checksum calculation and validates the EEPROM checksum.  If the
  *  caller does not need checksum_val, the value can be NULL.
  **/
-s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
+s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
+                                           u16 *checksum_val)
 {
 	s32 status;
 	u16 checksum;
@@ -565,12 +922,12 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
 	 * not continue or we could be in for a very long wait while every
 	 * EEPROM read fails
 	 */
-	status = ixgbe_read_eeprom(hw, 0, &checksum);
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
 
 	if (status == 0) {
 		checksum = ixgbe_calc_eeprom_checksum(hw);
 
-		ixgbe_read_eeprom(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
+		hw->eeprom.ops.read(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
 
 		/*
 		 * Verify read checksum from EEPROM is the same as
@@ -590,6 +947,33 @@ s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
 }
 
 /**
+ *  ixgbe_update_eeprom_checksum_generic - Updates the EEPROM checksum
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw)
+{
+	s32 status;
+	u16 checksum;
+
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
+
+	if (status == 0) {
+		checksum = ixgbe_calc_eeprom_checksum(hw);
+		status = hw->eeprom.ops.write(hw, IXGBE_EEPROM_CHECKSUM,
+		                            checksum);
+	} else {
+		hw_dbg(hw, "EEPROM read failed\n");
+	}
+
+	return status;
+}
+
+/**
  *  ixgbe_validate_mac_addr - Validate MAC address
  *  @mac_addr: pointer to MAC address.
  *
@@ -607,58 +991,137 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
-		 mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
+	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
 		status = IXGBE_ERR_INVALID_MAC_ADDR;
 
 	return status;
 }
 
 /**
- *  ixgbe_set_rar - Set RX address register
+ *  ixgbe_set_rar_generic - Set Rx address register
  *  @hw: pointer to hardware structure
- *  @addr: Address to put into receive address register
  *  @index: Receive address register to write
- *  @vind: Vind to set RAR to
+ *  @addr: Address to put into receive address register
+ *  @vmdq: VMDq "set" or "pool" index
  *  @enable_addr: set flag that address is active
  *
  *  Puts an ethernet address into a receive address register.
  **/
-s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
-		  u32 enable_addr)
+s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
+                          u32 enable_addr)
 {
 	u32 rar_low, rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	/* setup VMDq pool selection before this RAR gets enabled */
+	hw->mac.ops.set_vmdq(hw, index, vmdq);
 
+	/* Make sure we are using a valid rar index range */
+	if (index < rar_entries) {
 	/*
-	 * HW expects these in little endian so we reverse the byte order from
-	 * network order (big endian) to little endian
+		 * HW expects these in little endian so we reverse the byte
+		 * order from network order (big endian) to little endian
 	 */
 	rar_low = ((u32)addr[0] |
 		   ((u32)addr[1] << 8) |
 		   ((u32)addr[2] << 16) |
 		   ((u32)addr[3] << 24));
-
-	rar_high = ((u32)addr[4] |
-		    ((u32)addr[5] << 8) |
-		    ((vind << IXGBE_RAH_VIND_SHIFT) & IXGBE_RAH_VIND_MASK));
+		/*
+		 * Some parts put the VMDq setting in the extra RAH bits,
+		 * so save everything except the lower 16 bits that hold part
+		 * of the address and the address valid bit.
+		 */
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+		rar_high |= ((u32)addr[4] | ((u32)addr[5] << 8));
 
 	if (enable_addr != 0)
 		rar_high |= IXGBE_RAH_AV;
 
 	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
 	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+	}
+
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_rar_generic - Remove Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: Receive address register to write
+ *
+ *  Clears an ethernet address from a receive address register.
+ **/
+s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	/* Make sure we are using a valid rar index range */
+	if (index < rar_entries) {
+		/*
+		 * Some parts put the VMDq setting in the extra RAH bits,
+		 * so save everything except the lower 16 bits that hold part
+		 * of the address and the address valid bit.
+		 */
+		rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+		rar_high &= ~(0x0000FFFF | IXGBE_RAH_AV);
+
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(index), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+	}
+
+	/* clear VMDq pool/queue selection for this RAR */
+	hw->mac.ops.clear_vmdq(hw, index, IXGBE_CLEAR_VMDQ_ALL);
 
 	return 0;
 }
 
 /**
- *  ixgbe_init_rx_addrs - Initializes receive address filters.
+ *  ixgbe_enable_rar - Enable Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Enables the select receive address register.
+ **/
+static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high |= IXGBE_RAH_AV;
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_disable_rar - Disable Rx address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Disables the select receive address register.
+ **/
+static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high &= (~IXGBE_RAH_AV);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_init_rx_addrs_generic - Initializes receive address filters.
  *  @hw: pointer to hardware structure
  *
  *  Places the MAC address in receive address register 0 and clears the rest
- *  of the receive addresss registers. Clears the multicast table. Assumes
+ *  of the receive address registers. Clears the multicast table. Assumes
  *  the receiver is in reset when the routine is called.
  **/
-static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
+s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 {
 	u32 i;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -671,7 +1134,7 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 	if (ixgbe_validate_mac_addr(hw->mac.addr) ==
 	    IXGBE_ERR_INVALID_MAC_ADDR) {
 		/* Get the MAC address from the RAR0 for later reference */
-		ixgbe_get_mac_addr(hw, hw->mac.addr);
+		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
 		hw_dbg(hw, " Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
 			  hw->mac.addr[0], hw->mac.addr[1],
@@ -687,13 +1150,14 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
 			  hw->mac.addr[4], hw->mac.addr[5]);
 
-		ixgbe_set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 	}
+	hw->addr_ctrl.overflow_promisc = 0;
 
 	hw->addr_ctrl.rar_used_count = 1;
 
 	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[1-15]\n");
+	hw_dbg(hw, "Clearing RAR[1-%d]\n", rar_entries - 1);
 	for (i = 1; i < rar_entries; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
@@ -708,6 +1172,9 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
 	for (i = 0; i < hw->mac.mcft_size; i++)
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
+	if (hw->mac.ops.init_uta_tables)
+		hw->mac.ops.init_uta_tables(hw);
+
 	return 0;
 }
 
@@ -718,7 +1185,7 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
  *
  *  Adds it to unused receive address register or goes into promiscuous mode.
  **/
-void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
+static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
 {
 	u32 rar_entries = hw->mac.num_rar_entries;
 	u32 rar;
@@ -733,7 +1200,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
 		rar = hw->addr_ctrl.rar_used_count -
 		      hw->addr_ctrl.mc_addr_in_rar_count;
-		ixgbe_set_rar(hw, rar, addr, 0, IXGBE_RAH_AV);
+		hw->mac.ops.set_rar(hw, rar, addr, vmdq, IXGBE_RAH_AV);
 		hw_dbg(hw, "Added a secondary address to RAR[%d]\n", rar);
 		hw->addr_ctrl.rar_used_count++;
 	} else {
@@ -744,7 +1211,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
 }
 
 /**
- *  ixgbe_update_uc_addr_list - Updates MAC list of secondary addresses
+ *  ixgbe_update_uc_addr_list_generic - Updates MAC list of secondary addresses
  *  @hw: pointer to hardware structure
  *  @addr_list: the list of new addresses
  *  @addr_count: number of addresses
@@ -757,7 +1224,7 @@ void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr)
  *  Drivers using secondary unicast addresses must set user_set_promisc when
  *  manually putting the device into promiscuous mode.
  **/
-s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
                               u32 addr_count, ixgbe_mc_addr_itr next)
 {
 	u8 *addr;
@@ -787,7 +1254,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
 	for (i = 0; i < addr_count; i++) {
 		hw_dbg(hw, " Adding the secondary addresses:\n");
 		addr = next(hw, &addr_list, &vmdq);
-		ixgbe_add_uc_addr(hw, addr);
+		ixgbe_add_uc_addr(hw, addr, vmdq);
 	}
 
 	if (hw->addr_ctrl.overflow_promisc) {
@@ -808,7 +1275,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
 		}
 	}
 
-	hw_dbg(hw, "ixgbe_update_uc_addr_list Complete\n");
+	hw_dbg(hw, "ixgbe_update_uc_addr_list_generic Complete\n");
 	return 0;
 }
 
@@ -821,7 +1288,7 @@ s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *addr_list,
  *  bit-vector to set in the multicast table. The hardware uses 12 bits, from
  *  incoming rx multicast addresses, to determine the bit-vector to check in
  *  the MTA. Which of the 4 combination, of 12-bits, the hardware uses is set
- *  by the MO field of the MCSTCTRL. The MO field is set during initalization
+ *  by the MO field of the MCSTCTRL. The MO field is set during initialization
  *  to mc_filter_type.
  **/
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
@@ -907,10 +1374,10 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 	 * else put it in the MTA
 	 */
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
+		/* use RAR from the end up for multicast */
 		rar = rar_entries - hw->addr_ctrl.mc_addr_in_rar_count - 1;
-		ixgbe_set_rar(hw, rar, mc_addr, 0, IXGBE_RAH_AV);
-		hw_dbg(hw, "Added a multicast address to RAR[%d]\n",
-			  hw->addr_ctrl.rar_used_count);
+		hw->mac.ops.set_rar(hw, rar, mc_addr, 0, IXGBE_RAH_AV);
+		hw_dbg(hw, "Added a multicast address to RAR[%d]\n", rar);
 		hw->addr_ctrl.rar_used_count++;
 		hw->addr_ctrl.mc_addr_in_rar_count++;
 	} else {
@@ -921,18 +1388,18 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  ixgbe_update_mc_addr_list - Updates MAC list of multicast addresses
+ *  ixgbe_update_mc_addr_list_generic - Updates MAC list of multicast addresses
  *  @hw: pointer to hardware structure
  *  @mc_addr_list: the list of new multicast addresses
  *  @mc_addr_count: number of addresses
  *  @next: iterator function to walk the multicast address list
  *
  *  The given list replaces any existing list. Clears the MC addrs from receive
- *  address registers and the multicast table. Uses unsed receive address
+ *  address registers and the multicast table. Uses unused receive address
  *  registers for the first multicast addresses, and hashes the rest into the
  *  multicast table.
  **/
-s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
 			      u32 mc_addr_count, ixgbe_mc_addr_itr next)
 {
 	u32 i;
@@ -949,7 +1416,8 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	hw->addr_ctrl.mta_in_use = 0;
 
 	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[1-15]\n");
+	hw_dbg(hw, "Clearing RAR[%d-%d]\n", hw->addr_ctrl.rar_used_count,
+	          rar_entries - 1);
 	for (i = hw->addr_ctrl.rar_used_count; i < rar_entries; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
@@ -971,188 +1439,53 @@ s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
 		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL,
 				IXGBE_MCSTCTRL_MFE | hw->mac.mc_filter_type);
 
-	hw_dbg(hw, "ixgbe_update_mc_addr_list Complete\n");
+	hw_dbg(hw, "ixgbe_update_mc_addr_list_generic Complete\n");
 	return 0;
 }
 
 /**
- *  ixgbe_clear_vfta - Clear VLAN filter table
+ *  ixgbe_enable_mc_generic - Enable multicast address in RAR
  *  @hw: pointer to hardware structure
  *
- *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ *  Enables multicast address in RAR and the use of the multicast hash table.
  **/
-static s32 ixgbe_clear_vfta(struct ixgbe_hw *hw)
+s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 offset;
-	u32 vlanbyte;
+	u32 i;
+	u32 rar_entries = hw->mac.num_rar_entries;
+	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	for (offset = 0; offset < hw->mac.vft_size; offset++)
-		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (rar_entries - a->mc_addr_in_rar_count);
+		     i < rar_entries; i++)
+			ixgbe_enable_rar(hw, i);
 
-	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
-		for (offset = 0; offset < hw->mac.vft_size; offset++)
-			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte, offset),
-					0);
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, IXGBE_MCSTCTRL_MFE |
+		                hw->mac.mc_filter_type);
 
 	return 0;
 }
 
 /**
- *  ixgbe_set_vfta - Set VLAN filter table
+ *  ixgbe_disable_mc_generic - Disable multicast address in RAR
  *  @hw: pointer to hardware structure
- *  @vlan: VLAN id to write to VLAN filter
- *  @vind: VMDq output index that maps queue to VLAN id in VFTA
- *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
  *
- *  Turn on/off specified VLAN in the VLAN filter table.
+ *  Disables multicast address in RAR and the use of the multicast hash table.
  **/
-s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind,
-		   bool vlan_on)
+s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 {
-	u32 VftaIndex;
-	u32 BitOffset;
-	u32 VftaReg;
-	u32 VftaByte;
-
-	/* Determine 32-bit word position in array */
-	VftaIndex = (vlan >> 5) & 0x7F;   /* upper seven bits */
-
-	/* Determine the location of the (VMD) queue index */
-	VftaByte =  ((vlan >> 3) & 0x03); /* bits (4:3) indicating byte array */
-	BitOffset = (vlan & 0x7) << 2;    /* lower 3 bits indicate nibble */
-
-	/* Set the nibble for VMD queue index */
-	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex));
-	VftaReg &= (~(0x0F << BitOffset));
-	VftaReg |= (vind << BitOffset);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex), VftaReg);
-
-	/* Determine the location of the bit for this VLAN id */
-	BitOffset = vlan & 0x1F;	   /* lower five bits */
-
-	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTA(VftaIndex));
-	if (vlan_on)
-		/* Turn on this VLAN id */
-		VftaReg |= (1 << BitOffset);
-	else
-		/* Turn off this VLAN id */
-		VftaReg &= ~(1 << BitOffset);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTA(VftaIndex), VftaReg);
-
-	return 0;
-}
-
-/**
- *  ixgbe_setup_fc - Configure flow control settings
- *  @hw: pointer to hardware structure
- *  @packetbuf_num: packet buffer number (0-7)
- *
- *  Configures the flow control settings based on SW configuration.
- *  This function is used for 802.3x flow control configuration only.
- **/
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
-{
-	u32 frctl_reg;
-	u32 rmcs_reg;
-
-	if (packetbuf_num < 0 || packetbuf_num > 7)
-		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
-		       "is 0-7\n", packetbuf_num);
-
-	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-	frctl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
-
-	rmcs_reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
-	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
-
-	/*
-	 * 10 gig parts do not have a word in the EEPROM to determine the
-	 * default flow control setting, so we explicitly set it to full.
-	 */
-	if (hw->fc.type == ixgbe_fc_default)
-		hw->fc.type = ixgbe_fc_full;
-
-	/*
-	 * We want to save off the original Flow Control configuration just in
-	 * case we get disconnected and then reconnected into a different hub
-	 * or switch with different Flow Control capabilities.
-	 */
-	hw->fc.type = hw->fc.original_type;
-
-	/*
-	 * The possible values of the "flow_control" parameter are:
-	 * 0: Flow control is completely disabled
-	 * 1: Rx flow control is enabled (we can receive pause frames but not
-	 *    send pause frames).
-	 * 2: Tx flow control is enabled (we can send pause frames but we do not
-	 *    support receiving pause frames)
-	 * 3: Both Rx and TX flow control (symmetric) are enabled.
-	 * other: Invalid.
-	 */
-	switch (hw->fc.type) {
-	case ixgbe_fc_none:
-		break;
-	case ixgbe_fc_rx_pause:
-		/*
-		 * RX Flow control is enabled,
-		 * and TX Flow control is disabled.
-		 */
-		frctl_reg |= IXGBE_FCTRL_RFCE;
-		break;
-	case ixgbe_fc_tx_pause:
-		/*
-		 * TX Flow control is enabled, and RX Flow control is disabled,
-		 * by a software over-ride.
-		 */
-		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
-		break;
-	case ixgbe_fc_full:
-		/*
-		 * Flow control (both RX and TX) is enabled by a software
-		 * over-ride.
-		 */
-		frctl_reg |= IXGBE_FCTRL_RFCE;
-		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
-		break;
-	default:
-		/* We should never get here.  The value should be 0-3. */
-		hw_dbg(hw, "Flow control param set incorrectly\n");
-		break;
-	}
-
-	/* Enable 802.3x based flow control settings. */
-	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, frctl_reg);
-	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
-
-	/*
-	 * Check for invalid software configuration, zeros are completely
-	 * invalid for all parameters used past this point, and if we enable
-	 * flow control with zero water marks, we blast flow control packets.
-	 */
-	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		hw_dbg(hw, "Flow control structure initialized incorrectly\n");
-		return IXGBE_ERR_INVALID_LINK_SETTINGS;
-	}
+	u32 i;
+	u32 rar_entries = hw->mac.num_rar_entries;
+	struct ixgbe_addr_filter_info *a = &hw->addr_ctrl;
 
-	/*
-	 * We need to set up the Receive Threshold high and low water
-	 * marks as well as (optionally) enabling the transmission of
-	 * XON frames.
-	 */
-	if (hw->fc.type & ixgbe_fc_tx_pause) {
-		if (hw->fc.send_xon) {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-					(hw->fc.low_water | IXGBE_FCRTL_XONE));
-		} else {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
-					hw->fc.low_water);
-		}
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
-				(hw->fc.high_water)|IXGBE_FCRTH_FCEN);
-	}
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (rar_entries - a->mc_addr_in_rar_count);
+		     i < rar_entries; i++)
+			ixgbe_disable_rar(hw, i);
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(0), hw->fc.pause_time);
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mac.mc_filter_type);
 
 	return 0;
 }
@@ -1168,13 +1501,24 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
  **/
 s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 {
-	u32 ctrl;
-	s32 i;
+	u32 i;
+	u32 reg_val;
+	u32 number_of_queues;
 	s32 status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
 
-	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	ctrl |= IXGBE_CTRL_GIO_DIS;
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
+	/* Disable the receive unit by stopping each queue */
+	number_of_queues = hw->mac.max_rx_queues;
+	for (i = 0; i < number_of_queues; i++) {
+		reg_val = IXGBE_READ_REG(hw, IXGBE_RXDCTL(i));
+		if (reg_val & IXGBE_RXDCTL_ENABLE) {
+			reg_val &= ~IXGBE_RXDCTL_ENABLE;
+			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(i), reg_val);
+		}
+	}
+
+	reg_val = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	reg_val |= IXGBE_CTRL_GIO_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, reg_val);
 
 	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
 		if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO)) {
@@ -1189,11 +1533,11 @@ s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 
 
 /**
- *  ixgbe_acquire_swfw_sync - Aquire SWFW semaphore
+ *  ixgbe_acquire_swfw_sync - Acquire SWFW semaphore
  *  @hw: pointer to hardware structure
- *  @mask: Mask to specify wich semaphore to acquire
+ *  @mask: Mask to specify which semaphore to acquire
  *
- *  Aquires the SWFW semaphore throught the GSSR register for the specified
+ *  Acquires the SWFW semaphore thought the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
@@ -1235,9 +1579,9 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 /**
  *  ixgbe_release_swfw_sync - Release SWFW semaphore
  *  @hw: pointer to hardware structure
- *  @mask: Mask to specify wich semaphore to release
+ *  @mask: Mask to specify which semaphore to release
  *
- *  Releases the SWFW semaphore throught the GSSR register for the specified
+ *  Releases the SWFW semaphore thought the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
@@ -1254,45 +1598,3 @@ void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 	ixgbe_release_eeprom_semaphore(hw);
 }
 
-/**
- *  ixgbe_read_analog_reg8 - Reads 8 bit Atlas analog register
- *  @hw: pointer to hardware structure
- *  @reg: analog register to read
- *  @val: read value
- *
- *  Performs write operation to analog register specified.
- **/
-s32 ixgbe_read_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 *val)
-{
-	u32  atlas_ctl;
-
-	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL,
-			IXGBE_ATLASCTL_WRITE_CMD | (reg << 8));
-	IXGBE_WRITE_FLUSH(hw);
-	udelay(10);
-	atlas_ctl = IXGBE_READ_REG(hw, IXGBE_ATLASCTL);
-	*val = (u8)atlas_ctl;
-
-	return 0;
-}
-
-/**
- *  ixgbe_write_analog_reg8 - Writes 8 bit Atlas analog register
- *  @hw: pointer to hardware structure
- *  @reg: atlas register to write
- *  @val: value to write
- *
- *  Performs write operation to Atlas analog register specified.
- **/
-s32 ixgbe_write_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 val)
-{
-	u32  atlas_ctl;
-
-	atlas_ctl = (reg << 8) | val;
-	IXGBE_WRITE_REG(hw, IXGBE_ATLASCTL, atlas_ctl);
-	IXGBE_WRITE_FLUSH(hw);
-	udelay(10);
-
-	return 0;
-}
-
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index c75ecba..13ed8d2 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -31,36 +31,45 @@
 
 #include "ixgbe_type.h"
 
-s32 ixgbe_init_hw(struct ixgbe_hw *hw);
-s32 ixgbe_start_hw(struct ixgbe_hw *hw);
-s32 ixgbe_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr);
-s32 ixgbe_stop_adapter(struct ixgbe_hw *hw);
-s32 ixgbe_read_part_num(struct ixgbe_hw *hw, u32 *part_num);
-
-s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index);
-s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index);
-
-s32 ixgbe_init_eeprom(struct ixgbe_hw *hw);
-s32 ixgbe_read_eeprom(struct ixgbe_hw *hw, u16 offset, u16 *data);
-s32 ixgbe_validate_eeprom_checksum(struct ixgbe_hw *hw, u16 *checksum_val);
-
-s32 ixgbe_set_rar(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
-		  u32 enable_addr);
-s32 ixgbe_update_mc_addr_list(struct ixgbe_hw *hw, u8 *mc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
-s32 ixgbe_update_uc_addr_list(struct ixgbe_hw *hw, u8 *uc_addr_list,
-			      u32 mc_addr_count, ixgbe_mc_addr_itr next);
-s32 ixgbe_set_vfta(struct ixgbe_hw *hw, u32 vlan, u32 vind, bool vlan_on);
-s32 ixgbe_validate_mac_addr(u8 *mac_addr);
-
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packtetbuf_num);
+s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
+s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw);
+s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw);
+s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num);
+s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr);
+s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw);
+s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw);
+
+s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
+
+s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+                                       u16 *data);
+s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
+                                           u16 *checksum_val);
+s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw);
+
+s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
+                          u32 enable_addr);
+s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw);
+s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
+                                      u32 mc_addr_count,
+                                      ixgbe_mc_addr_itr func);
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
+                                      u32 addr_count, ixgbe_mc_addr_itr func);
+s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
+s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 
+s32 ixgbe_validate_mac_addr(u8 *mac_addr);
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
 s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
 
-s32 ixgbe_read_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 *val);
-s32 ixgbe_write_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 val);
+s32 ixgbe_read_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 *val);
+s32 ixgbe_write_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 val);
 
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 4701abf..ff4fac3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -128,9 +128,10 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		ecmd->advertising = (ADVERTISED_10000baseT_Full |
 				     ADVERTISED_FIBRE);
 		ecmd->port = PORT_FIBRE;
+		ecmd->autoneg = AUTONEG_DISABLE;
 	}
 
-	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up, false);
+	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	if (link_up) {
 		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
 				SPEED_10000 : SPEED_1000;
@@ -327,7 +328,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[25] = IXGBE_READ_REG(hw, IXGBE_IVAR(0));
 	regs_buff[26] = IXGBE_READ_REG(hw, IXGBE_MSIXT);
 	regs_buff[27] = IXGBE_READ_REG(hw, IXGBE_MSIXPBA);
-	regs_buff[28] = IXGBE_READ_REG(hw, IXGBE_PBACL);
+	regs_buff[28] = IXGBE_READ_REG(hw, IXGBE_PBACL(0));
 	regs_buff[29] = IXGBE_READ_REG(hw, IXGBE_GPIE);
 
 	/* Flow Control */
@@ -373,7 +374,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 		regs_buff[482 + i] = IXGBE_READ_REG(hw, IXGBE_RAL(i));
 	for (i = 0; i < 16; i++)
 		regs_buff[498 + i] = IXGBE_READ_REG(hw, IXGBE_RAH(i));
-	regs_buff[514] = IXGBE_READ_REG(hw, IXGBE_PSRTYPE);
+	regs_buff[514] = IXGBE_READ_REG(hw, IXGBE_PSRTYPE(0));
 	regs_buff[515] = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 	regs_buff[516] = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 	regs_buff[517] = IXGBE_READ_REG(hw, IXGBE_MCSTCTRL);
@@ -605,8 +606,8 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 		return -ENOMEM;
 
 	for (i = 0; i < eeprom_len; i++) {
-		if ((ret_val = ixgbe_read_eeprom(hw, first_word + i,
-						 &eeprom_buff[i])))
+		if ((ret_val = hw->eeprom.ops.read(hw, first_word + i,
+						   &eeprom_buff[i])))
 			break;
 	}
 
@@ -807,7 +808,7 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			      u8 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 *p = data;
+	char *p = (char *)data;
 	int i;
 
 	switch (stringset) {
@@ -857,16 +858,17 @@ static int ixgbe_nway_reset(struct net_device *netdev)
 static int ixgbe_phys_id(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 led_reg = IXGBE_READ_REG(&adapter->hw, IXGBE_LEDCTL);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 	u32 i;
 
 	if (!data || data > 300)
 		data = 300;
 
 	for (i = 0; i < (data * 1000); i += 400) {
-		ixgbe_led_on(&adapter->hw, IXGBE_LED_ON);
+		hw->mac.ops.led_on(hw, IXGBE_LED_ON);
 		msleep_interruptible(200);
-		ixgbe_led_off(&adapter->hw, IXGBE_LED_ON);
+		hw->mac.ops.led_off(hw, IXGBE_LED_ON);
 		msleep_interruptible(200);
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e18afa4..df093ec 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1749,14 +1749,16 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	/* add VID to filter table */
-	ixgbe_set_vfta(&adapter->hw, vid, 0, true);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, true);
 }
 
 static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_disable(adapter);
@@ -1767,7 +1769,7 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 		ixgbe_irq_enable(adapter);
 
 	/* remove VID from filter table */
-	ixgbe_set_vfta(&adapter->hw, vid, 0, false);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, false);
 }
 
 static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
@@ -1843,15 +1845,15 @@ static void ixgbe_set_rx_mode(struct net_device *netdev)
 	addr_count = netdev->uc_count;
 	if (addr_count)
 		addr_list = netdev->uc_list->dmi_addr;
-	ixgbe_update_uc_addr_list(hw, addr_list, addr_count,
-	                          ixgbe_addr_list_itr);
+	hw->mac.ops.update_uc_addr_list(hw, addr_list, addr_count,
+	                                  ixgbe_addr_list_itr);
 
 	/* reprogram multicast list */
 	addr_count = netdev->mc_count;
 	if (addr_count)
 		addr_list = netdev->mc_list->dmi_addr;
-	ixgbe_update_mc_addr_list(hw, addr_list, addr_count,
-	                          ixgbe_addr_list_itr);
+	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
+	                                ixgbe_addr_list_itr);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -2016,11 +2018,12 @@ int ixgbe_up(struct ixgbe_adapter *adapter)
 
 void ixgbe_reset(struct ixgbe_adapter *adapter)
 {
-	if (ixgbe_init_hw(&adapter->hw))
-		DPRINTK(PROBE, ERR, "Hardware Error\n");
+	struct ixgbe_hw *hw = &adapter->hw;
+	if (hw->mac.ops.init_hw(hw))
+		dev_err(&adapter->pdev->dev, "Hardware Error\n");
 
 	/* reprogram the RAR[0] in case user changed it. */
-	ixgbe_set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 
 }
 
@@ -2637,6 +2640,14 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss;
 
+	/* PCI config space info */
+
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->revision_id = pdev->revision;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_device_id = pdev->subsystem_device;
+
 	/* Set capability flags */
 	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
@@ -2652,15 +2663,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 	/* select 10G link by default */
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
-	if (hw->mac.ops.reset(hw)) {
-		dev_err(&pdev->dev, "HW Init failed\n");
-		return -EIO;
-	}
-	if (hw->mac.ops.setup_link_speed(hw, IXGBE_LINK_SPEED_10GB_FULL, true,
-					 false)) {
-		dev_err(&pdev->dev, "Link Speed setup failed\n");
-		return -EIO;
-	}
 
 	/* enable itr by default in dynamic mode */
 	adapter->itr_setting = 1;
@@ -2675,7 +2677,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
 	/* initialize eeprom parameters */
-	if (ixgbe_init_eeprom(hw)) {
+	if (ixgbe_init_eeprom_params_generic(hw)) {
 		dev_err(&pdev->dev, "EEPROM initialization failed\n");
 		return -EIO;
 	}
@@ -3622,7 +3624,7 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
 
-	ixgbe_set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
+	adapter->hw.mac.ops.set_rar(&adapter->hw, 0, adapter->hw.mac.addr, 0, IXGBE_RAH_AV);
 
 	return 0;
 }
@@ -3646,6 +3648,22 @@ static void ixgbe_netpoll(struct net_device *netdev)
 #endif
 
 /**
+ * ixgbe_link_config - set up initial link with default speed and duplex
+ * @hw: pointer to private hardware struct
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int ixgbe_link_config(struct ixgbe_hw *hw)
+{
+	u32 autoneg = IXGBE_LINK_SPEED_10GB_FULL;
+
+	/* must always autoneg for both 1G and 10G link */
+	hw->mac.autoneg = true;
+
+	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
+}
+
+/**
  * ixgbe_napi_add_all - prep napi structs for use
  * @adapter: private struct
  * helper function to napi_add each possible q_vector->napi
@@ -3691,7 +3709,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	static int cards_found;
 	int i, err, pci_using_dac;
 	u16 link_status, link_speed, link_width;
-	u32 part_num;
+	u32 part_num, eec;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -3705,8 +3723,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		if (err) {
 			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (err) {
-				dev_err(&pdev->dev, "No usable DMA "
-					"configuration, aborting\n");
+				dev_err(&pdev->dev, "No usable DMA configuration, "
+				          "aborting\n");
 				goto err_dma;
 			}
 		}
@@ -3772,17 +3790,21 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	adapter->bd_number = cards_found;
 
-	/* PCI config space info */
-	hw->vendor_id = pdev->vendor;
-	hw->device_id = pdev->device;
-	hw->revision_id = pdev->revision;
-	hw->subsystem_vendor_id = pdev->subsystem_vendor;
-	hw->subsystem_device_id = pdev->subsystem_device;
-
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type  = ii->mac;
 
+	/* EEPROM */
+	memcpy(&hw->eeprom.ops, ii->eeprom_ops, sizeof(hw->eeprom.ops));
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+	/* If EEPROM is valid (bit 8 = 1), use default otherwise use bit bang */
+	if (!(eec & (1 << 8)))
+		hw->eeprom.ops.read = &ixgbe_read_eeprom_bit_bang_generic;
+
+	/* PHY */
+	memcpy(&hw->phy.ops, ii->phy_ops, sizeof(hw->phy.ops));
+	/* phy->sfp_type = ixgbe_sfp_type_unknown; */
+
 	err = ii->get_invariants(hw);
 	if (err)
 		goto err_hw_init;
@@ -3792,6 +3814,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	/* reset_hw fills in the perm_addr as well */
+	err = hw->mac.ops.reset_hw(hw);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "HW Init failed: %d\n", err);
+		goto err_sw_init;
+	}
+
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
 			   NETIF_F_HW_VLAN_TX |
@@ -3812,7 +3841,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
-	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
+	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
 		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -3821,7 +3850,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac.perm_addr, netdev->addr_len);
 
-	if (ixgbe_validate_mac_addr(netdev->dev_addr)) {
+	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
+		dev_err(&pdev->dev, "invalid MAC address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -3853,7 +3883,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		 "Unknown"),
 		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
 		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
-	ixgbe_read_part_num(hw, &part_num);
+	ixgbe_read_pba_num_generic(hw, &part_num);
 	dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
 		 hw->mac.type, hw->phy.type,
 		 (part_num >> 8), (part_num & 0xff));
@@ -3867,7 +3897,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	/* reset the hardware with the new settings */
-	ixgbe_start_hw(hw);
+	hw->mac.ops.start_hw(hw);
+
+	/* link_config depends on start_hw being called at least once */
+	err = ixgbe_link_config(hw);
+	if (err) {
+		dev_err(&pdev->dev, "setup_link_speed FAILED %d\n", err);
+		goto err_register;
+	}
 
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 8002931..63a7017 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -33,32 +33,36 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
 static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id);
 static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw);
-static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
-static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 phy_data);
 
 /**
- *  ixgbe_identify_phy - Get physical layer module
+ *  ixgbe_identify_phy_generic - Get physical layer module
  *  @hw: pointer to hardware structure
  *
  *  Determines the physical layer module found on the current adapter.
  **/
-s32 ixgbe_identify_phy(struct ixgbe_hw *hw)
+s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u32 phy_addr;
 
-	for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
-		if (ixgbe_validate_phy_addr(hw, phy_addr)) {
-			hw->phy.addr = phy_addr;
-			ixgbe_get_phy_id(hw);
-			hw->phy.type = ixgbe_get_phy_type_from_id(hw->phy.id);
-			status = 0;
-			break;
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
+			if (ixgbe_validate_phy_addr(hw, phy_addr)) {
+				hw->phy.addr = phy_addr;
+				ixgbe_get_phy_id(hw);
+				hw->phy.type =
+				        ixgbe_get_phy_type_from_id(hw->phy.id);
+				status = 0;
+				break;
+			}
 		}
+	} else {
+		status = 0;
 	}
+
 	return status;
 }
 
@@ -73,10 +77,8 @@ static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr)
 	bool valid = false;
 
 	hw->phy.addr = phy_addr;
-	ixgbe_read_phy_reg(hw,
-			   IXGBE_MDIO_PHY_ID_HIGH,
-			   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-			   &phy_id);
+	hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
+	                     IXGBE_MDIO_PMA_PMD_DEV_TYPE, &phy_id);
 
 	if (phy_id != 0xFFFF && phy_id != 0x0)
 		valid = true;
@@ -95,21 +97,18 @@ static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw)
 	u16 phy_id_high = 0;
 	u16 phy_id_low = 0;
 
-	status = ixgbe_read_phy_reg(hw,
-				   IXGBE_MDIO_PHY_ID_HIGH,
-				   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-				   &phy_id_high);
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
+	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	                              &phy_id_high);
 
 	if (status == 0) {
 		hw->phy.id = (u32)(phy_id_high << 16);
-		status = ixgbe_read_phy_reg(hw,
-					   IXGBE_MDIO_PHY_ID_LOW,
-					   IXGBE_MDIO_PMA_PMD_DEV_TYPE,
-					   &phy_id_low);
+		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_LOW,
+		                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+		                              &phy_id_low);
 		hw->phy.id |= (u32)(phy_id_low & IXGBE_PHY_REVISION_MASK);
 		hw->phy.revision = (u32)(phy_id_low & ~IXGBE_PHY_REVISION_MASK);
 	}
-
 	return status;
 }
 
@@ -123,9 +122,6 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	enum ixgbe_phy_type phy_type;
 
 	switch (phy_id) {
-	case TN1010_PHY_ID:
-		phy_type = ixgbe_phy_tn;
-		break;
 	case QT2022_PHY_ID:
 		phy_type = ixgbe_phy_qt;
 		break;
@@ -138,32 +134,31 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 }
 
 /**
- *  ixgbe_reset_phy - Performs a PHY reset
+ *  ixgbe_reset_phy_generic - Performs a PHY reset
  *  @hw: pointer to hardware structure
  **/
-s32 ixgbe_reset_phy(struct ixgbe_hw *hw)
+s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw)
 {
 	/*
 	 * Perform soft PHY reset to the PHY_XS.
 	 * This will cause a soft reset to the PHY
 	 */
-	return ixgbe_write_phy_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-				   IXGBE_MDIO_PHY_XS_DEV_TYPE,
-				   IXGBE_MDIO_PHY_XS_RESET);
+	return hw->phy.ops.write_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
+	                             IXGBE_MDIO_PHY_XS_DEV_TYPE,
+	                             IXGBE_MDIO_PHY_XS_RESET);
 }
 
 /**
- *  ixgbe_read_phy_reg - Reads a value from a specified PHY register
+ *  ixgbe_read_phy_reg_generic - Reads a value from a specified PHY register
  *  @hw: pointer to hardware structure
  *  @reg_addr: 32 bit address of PHY register to read
  *  @phy_data: Pointer to read data from PHY register
  **/
-s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-		       u32 device_type, u16 *phy_data)
+s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                               u32 device_type, u16 *phy_data)
 {
 	u32 command;
 	u32 i;
-	u32 timeout = 10;
 	u32 data;
 	s32 status = 0;
 	u16 gssr;
@@ -179,9 +174,9 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 	if (status == 0) {
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -190,7 +185,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 		 * The MDI Command bit will clear when the operation is
 		 * complete
 		 */
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 			udelay(10);
 
 			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
@@ -210,9 +205,9 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * command
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-				   (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
+			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -221,7 +216,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * completed. The MDI Command bit will clear when the
 			 * operation is complete
 			 */
-			for (i = 0; i < timeout; i++) {
+			for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 				udelay(10);
 
 				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
@@ -231,8 +226,7 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			}
 
 			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
-				hw_dbg(hw,
-				       "PHY read command didn't complete\n");
+				hw_dbg(hw, "PHY read command didn't complete\n");
 				status = IXGBE_ERR_PHY;
 			} else {
 				/*
@@ -247,22 +241,22 @@ s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 
 		ixgbe_release_swfw_sync(hw, gssr);
 	}
+
 	return status;
 }
 
 /**
- *  ixgbe_write_phy_reg - Writes a value to specified PHY register
+ *  ixgbe_write_phy_reg_generic - Writes a value to specified PHY register
  *  @hw: pointer to hardware structure
  *  @reg_addr: 32 bit PHY register to write
  *  @device_type: 5 bit device type
  *  @phy_data: Data to write to the PHY register
  **/
-static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 phy_data)
+s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                                u32 device_type, u16 phy_data)
 {
 	u32 command;
 	u32 i;
-	u32 timeout = 10;
 	s32 status = 0;
 	u16 gssr;
 
@@ -280,9 +274,9 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -291,19 +285,19 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 		 * The MDI Command bit will clear when the operation is
 		 * complete
 		 */
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 			udelay(10);
 
 			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
 
-			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
-				hw_dbg(hw, "PHY address cmd didn't complete\n");
+			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0)
 				break;
-			}
 		}
 
-		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+			hw_dbg(hw, "PHY address cmd didn't complete\n");
 			status = IXGBE_ERR_PHY;
+		}
 
 		if (status == 0) {
 			/*
@@ -311,9 +305,9 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * command
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
-				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
-				   (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
+			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
 
@@ -322,20 +316,19 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 			 * completed. The MDI Command bit will clear when the
 			 * operation is complete
 			 */
-			for (i = 0; i < timeout; i++) {
+			for (i = 0; i < IXGBE_MDIO_COMMAND_TIMEOUT; i++) {
 				udelay(10);
 
 				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
 
-				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
-					hw_dbg(hw, "PHY write command did not "
-						  "complete.\n");
+				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0)
 					break;
-				}
 			}
 
-			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+				hw_dbg(hw, "PHY address cmd didn't complete\n");
 				status = IXGBE_ERR_PHY;
+			}
 		}
 
 		ixgbe_release_swfw_sync(hw, gssr);
@@ -345,67 +338,54 @@ static s32 ixgbe_write_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
 }
 
 /**
- *  ixgbe_setup_tnx_phy_link - Set and restart autoneg
+ *  ixgbe_setup_phy_link_generic - Set and restart autoneg
  *  @hw: pointer to hardware structure
  *
  *  Restart autonegotiation and PHY and waits for completion.
  **/
-s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw)
+s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_NOT_IMPLEMENTED;
 	u32 time_out;
 	u32 max_time_out = 10;
-	u16 autoneg_speed_selection_register = 0x10;
-	u16 autoneg_restart_mask = 0x0200;
-	u16 autoneg_complete_mask = 0x0020;
-	u16 autoneg_reg = 0;
+	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
 
 	/*
 	 * Set advertisement settings in PHY based on autoneg_advertised
 	 * settings. If autoneg_advertised = 0, then advertise default values
-	 * txn devices cannot be "forced" to a autoneg 10G and fail.  But can
+	 * tnx devices cannot be "forced" to a autoneg 10G and fail.  But can
 	 * for a 1G.
 	 */
-	ixgbe_read_phy_reg(hw,
-		  autoneg_speed_selection_register,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  &autoneg_reg);
+	hw->phy.ops.read_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
+	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
 
 	if (hw->phy.autoneg_advertised == IXGBE_LINK_SPEED_1GB_FULL)
 		autoneg_reg &= 0xEFFF; /* 0 in bit 12 is 1G operation */
 	else
 		autoneg_reg |= 0x1000; /* 1 in bit 12 is 10G/1G operation */
 
-	ixgbe_write_phy_reg(hw,
-		  autoneg_speed_selection_register,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  autoneg_reg);
-
+	hw->phy.ops.write_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
+	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
 
 	/* Restart PHY autonegotiation and wait for completion */
-	ixgbe_read_phy_reg(hw,
-		  IXGBE_MDIO_AUTO_NEG_CONTROL,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  &autoneg_reg);
+	hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
+	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
 
-	autoneg_reg |= autoneg_restart_mask;
+	autoneg_reg |= IXGBE_MII_RESTART;
 
-	ixgbe_write_phy_reg(hw,
-		  IXGBE_MDIO_AUTO_NEG_CONTROL,
-		  IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-		  autoneg_reg);
+	hw->phy.ops.write_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
+	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
 
 	/* Wait for autonegotiation to finish */
 	for (time_out = 0; time_out < max_time_out; time_out++) {
 		udelay(10);
 		/* Restart PHY autonegotiation and wait for completion */
-		status = ixgbe_read_phy_reg(hw,
-					    IXGBE_MDIO_AUTO_NEG_STATUS,
-					    IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
-					    &autoneg_reg);
+		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_STATUS,
+		                              IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
+		                              &autoneg_reg);
 
-		autoneg_reg &= autoneg_complete_mask;
-		if (autoneg_reg == autoneg_complete_mask) {
+		autoneg_reg &= IXGBE_MII_AUTONEG_COMPLETE;
+		if (autoneg_reg == IXGBE_MII_AUTONEG_COMPLETE) {
 			status = 0;
 			break;
 		}
@@ -418,64 +398,17 @@ s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_check_tnx_phy_link - Determine link and speed status
- *  @hw: pointer to hardware structure
- *
- *  Reads the VS1 register to determine if link is up and the current speed for
- *  the PHY.
- **/
-s32 ixgbe_check_tnx_phy_link(struct ixgbe_hw *hw, u32 *speed,
-			     bool *link_up)
-{
-	s32 status = 0;
-	u32 time_out;
-	u32 max_time_out = 10;
-	u16 phy_link = 0;
-	u16 phy_speed = 0;
-	u16 phy_data = 0;
-
-	/* Initialize speed and link to default case */
-	*link_up = false;
-	*speed = IXGBE_LINK_SPEED_10GB_FULL;
-
-	/*
-	 * Check current speed and link status of the PHY register.
-	 * This is a vendor specific register and may have to
-	 * be changed for other copper PHYs.
-	 */
-	for (time_out = 0; time_out < max_time_out; time_out++) {
-		udelay(10);
-		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
-			*link_up = true;
-			if (phy_speed ==
-			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
-				*speed = IXGBE_LINK_SPEED_1GB_FULL;
-			break;
-		} else {
-			status = ixgbe_read_phy_reg(hw,
-				     IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
-				     IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
-				     &phy_data);
-			phy_link = phy_data &
-				IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
-			phy_speed = phy_data &
-				IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
-		}
-	}
-
-	return status;
-}
-
-/**
- *  ixgbe_setup_tnx_phy_link_speed - Sets the auto advertised capabilities
+ *  ixgbe_setup_phy_link_speed_generic - Sets the auto advertised capabilities
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
  *  @autoneg: true if autonegotiation enabled
  **/
-s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed,
-				   bool autoneg,
-				   bool autoneg_wait_to_complete)
+s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
+                                       ixgbe_link_speed speed,
+                                       bool autoneg,
+                                       bool autoneg_wait_to_complete)
 {
+
 	/*
 	 * Clear autoneg_advertised and set new values based on input link
 	 * speed.
@@ -484,11 +417,13 @@ s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed,
 
 	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
 	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
 	/* Setup link based on the new speed settings */
-	ixgbe_setup_tnx_phy_link(hw);
+	hw->phy.ops.setup_link(hw);
 
 	return 0;
 }
+
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index aa3ea72..f88c913 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -30,20 +30,52 @@
 #define _IXGBE_PHY_H_
 
 #include "ixgbe_type.h"
+#define IXGBE_I2C_EEPROM_DEV_ADDR    0xA0
 
-s32 ixgbe_setup_phy_link(struct ixgbe_hw *hw);
-s32 ixgbe_check_phy_link(struct ixgbe_hw *hw, u32 *speed, bool *link_up);
-s32 ixgbe_setup_phy_link_speed(struct ixgbe_hw *hw, u32 speed, bool autoneg,
-			       bool autoneg_wait_to_complete);
-s32 ixgbe_identify_phy(struct ixgbe_hw *hw);
-s32 ixgbe_reset_phy(struct ixgbe_hw *hw);
-s32 ixgbe_read_phy_reg(struct ixgbe_hw *hw, u32 reg_addr,
-			       u32 device_type, u16 *phy_data);
-
-/* PHY specific */
-s32 ixgbe_setup_tnx_phy_link(struct ixgbe_hw *hw);
-s32 ixgbe_check_tnx_phy_link(struct ixgbe_hw *hw, u32 *speed, bool *link_up);
-s32 ixgbe_setup_tnx_phy_link_speed(struct ixgbe_hw *hw, u32 speed, bool autoneg,
-				  bool autoneg_wait_to_complete);
+/* EEPROM byte offsets */
+#define IXGBE_SFF_IDENTIFIER         0x0
+#define IXGBE_SFF_IDENTIFIER_SFP     0x3
+#define IXGBE_SFF_VENDOR_OUI_BYTE0   0x25
+#define IXGBE_SFF_VENDOR_OUI_BYTE1   0x26
+#define IXGBE_SFF_VENDOR_OUI_BYTE2   0x27
+#define IXGBE_SFF_1GBE_COMP_CODES    0x6
+#define IXGBE_SFF_10GBE_COMP_CODES   0x3
+#define IXGBE_SFF_TRANSMISSION_MEDIA 0x9
+
+/* Bitmasks */
+#define IXGBE_SFF_TWIN_AX_CAPABLE            0x80
+#define IXGBE_SFF_1GBASESX_CAPABLE           0x1
+#define IXGBE_SFF_10GBASESR_CAPABLE          0x10
+#define IXGBE_SFF_10GBASELR_CAPABLE          0x20
+#define IXGBE_I2C_EEPROM_READ_MASK           0x100
+#define IXGBE_I2C_EEPROM_STATUS_MASK         0x3
+#define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION 0x0
+#define IXGBE_I2C_EEPROM_STATUS_PASS         0x1
+#define IXGBE_I2C_EEPROM_STATUS_FAIL         0x2
+#define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS  0x3
+
+/* Bit-shift macros */
+#define IXGBE_SFF_VENDOR_OUI_BYTE0_SHIFT    12
+#define IXGBE_SFF_VENDOR_OUI_BYTE1_SHIFT    8
+#define IXGBE_SFF_VENDOR_OUI_BYTE2_SHIFT    4
+
+/* Vendor OUIs: format of OUI is 0x[byte0][byte1][byte2][00] */
+#define IXGBE_SFF_VENDOR_OUI_TYCO     0x00407600
+#define IXGBE_SFF_VENDOR_OUI_FTL      0x00906500
+#define IXGBE_SFF_VENDOR_OUI_AVAGO    0x00176A00
+
+
+s32 ixgbe_init_phy_ops_generic(struct ixgbe_hw *hw);
+s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw);
+s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw);
+s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                               u32 device_type, u16 *phy_data);
+s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
+                                u32 device_type, u16 phy_data);
+s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw);
+s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
+                                       ixgbe_link_speed speed,
+                                       bool autoneg,
+                                       bool autoneg_wait_to_complete);
 
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 7057aa3..c76e30b 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -37,7 +37,6 @@
 /* Device IDs */
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
-#define IXGBE_DEV_ID_82598AT_DUAL_PORT   0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
@@ -71,11 +70,11 @@
 #define IXGBE_EIMC      0x00888
 #define IXGBE_EIAC      0x00810
 #define IXGBE_EIAM      0x00890
-#define IXGBE_EITR(_i) (0x00820 + ((_i) * 4)) /* 0x820-0x86c */
-#define IXGBE_IVAR(_i) (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */
+#define IXGBE_EITR(_i)  (((_i) <= 23) ? (0x00820 + ((_i) * 4)) : (0x012300 + ((_i) * 4)))
+#define IXGBE_IVAR(_i)  (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */
 #define IXGBE_MSIXT     0x00000 /* MSI-X Table. 0x0000 - 0x01C */
 #define IXGBE_MSIXPBA   0x02000 /* MSI-X Pending bit array */
-#define IXGBE_PBACL     0x11068
+#define IXGBE_PBACL(_i) (((_i) == 0) ? (0x11068) : (0x110C0 + ((_i) * 4)))
 #define IXGBE_GPIE      0x00898
 
 /* Flow Control Registers */
@@ -87,20 +86,33 @@
 #define IXGBE_TFCS      0x0CE00
 
 /* Receive DMA Registers */
-#define IXGBE_RDBAL(_i) (0x01000 + ((_i) * 0x40)) /* 64 of each (0-63)*/
-#define IXGBE_RDBAH(_i) (0x01004 + ((_i) * 0x40))
-#define IXGBE_RDLEN(_i) (0x01008 + ((_i) * 0x40))
-#define IXGBE_RDH(_i)   (0x01010 + ((_i) * 0x40))
-#define IXGBE_RDT(_i)   (0x01018 + ((_i) * 0x40))
-#define IXGBE_RXDCTL(_i) (0x01028 + ((_i) * 0x40))
-#define IXGBE_RSCCTL(_i) (0x0102C + ((_i) * 0x40))
-#define IXGBE_SRRCTL(_i) (0x02100 + ((_i) * 4))
-					     /* array of 16 (0x02100-0x0213C) */
-#define IXGBE_DCA_RXCTRL(_i)    (0x02200 + ((_i) * 4))
-					     /* array of 16 (0x02200-0x0223C) */
-#define IXGBE_RDRXCTL    0x02F00
+#define IXGBE_RDBAL(_i) (((_i) < 64) ? (0x01000 + ((_i) * 0x40)) : (0x0D000 + ((_i - 64) * 0x40)))
+#define IXGBE_RDBAH(_i) (((_i) < 64) ? (0x01004 + ((_i) * 0x40)) : (0x0D004 + ((_i - 64) * 0x40)))
+#define IXGBE_RDLEN(_i) (((_i) < 64) ? (0x01008 + ((_i) * 0x40)) : (0x0D008 + ((_i - 64) * 0x40)))
+#define IXGBE_RDH(_i)   (((_i) < 64) ? (0x01010 + ((_i) * 0x40)) : (0x0D010 + ((_i - 64) * 0x40)))
+#define IXGBE_RDT(_i)   (((_i) < 64) ? (0x01018 + ((_i) * 0x40)) : (0x0D018 + ((_i - 64) * 0x40)))
+#define IXGBE_RXDCTL(_i) (((_i) < 64) ? (0x01028 + ((_i) * 0x40)) : (0x0D028 + ((_i - 64) * 0x40)))
+/*
+ * Split and Replication Receive Control Registers
+ * 00-15 : 0x02100 + n*4
+ * 16-64 : 0x01014 + n*0x40
+ * 64-127: 0x0D014 + (n-64)*0x40
+ */
+#define IXGBE_SRRCTL(_i) (((_i) <= 15) ? (0x02100 + ((_i) * 4)) : \
+                          (((_i) < 64) ? (0x01014 + ((_i) * 0x40)) : \
+                          (0x0D014 + ((_i - 64) * 0x40))))
+/*
+ * Rx DCA Control Register:
+ * 00-15 : 0x02200 + n*4
+ * 16-64 : 0x0100C + n*0x40
+ * 64-127: 0x0D00C + (n-64)*0x40
+ */
+#define IXGBE_DCA_RXCTRL(_i)    (((_i) <= 15) ? (0x02200 + ((_i) * 4)) : \
+                                 (((_i) < 64) ? (0x0100C + ((_i) * 0x40)) : \
+                                 (0x0D00C + ((_i - 64) * 0x40))))
+#define IXGBE_RDRXCTL           0x02F00
 #define IXGBE_RXPBSIZE(_i)      (0x03C00 + ((_i) * 4))
-					     /* 8 of these 0x03C00 - 0x03C1C */
+                                             /* 8 of these 0x03C00 - 0x03C1C */
 #define IXGBE_RXCTRL    0x03000
 #define IXGBE_DROPEN    0x03D04
 #define IXGBE_RXPBSIZE_SHIFT 10
@@ -108,29 +120,32 @@
 /* Receive Registers */
 #define IXGBE_RXCSUM    0x05000
 #define IXGBE_RFCTL     0x05008
+#define IXGBE_DRECCCTL  0x02F08
+#define IXGBE_DRECCCTL_DISABLE 0
+/* Multicast Table Array - 128 entries */
 #define IXGBE_MTA(_i)   (0x05200 + ((_i) * 4))
-				   /* Multicast Table Array - 128 entries */
-#define IXGBE_RAL(_i)   (0x05400 + ((_i) * 8)) /* 16 of these (0-15) */
-#define IXGBE_RAH(_i)   (0x05404 + ((_i) * 8)) /* 16 of these (0-15) */
-#define IXGBE_PSRTYPE   0x05480
-				   /* 0x5480-0x54BC Packet split receive type */
+#define IXGBE_RAL(_i)   (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : (0x0A200 + ((_i) * 8)))
+#define IXGBE_RAH(_i)   (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : (0x0A204 + ((_i) * 8)))
+/* Packet split receive type */
+#define IXGBE_PSRTYPE(_i)    (((_i) <= 15) ? (0x05480 + ((_i) * 4)) : (0x0EA00 + ((_i) * 4)))
+/* array of 4096 1-bit vlan filters */
 #define IXGBE_VFTA(_i)  (0x0A000 + ((_i) * 4))
-					 /* array of 4096 1-bit vlan filters */
+/*array of 4096 4-bit vlan vmdq indices */
 #define IXGBE_VFTAVIND(_j, _i)  (0x0A200 + ((_j) * 0x200) + ((_i) * 4))
-				     /*array of 4096 4-bit vlan vmdq indicies */
 #define IXGBE_FCTRL     0x05080
 #define IXGBE_VLNCTRL   0x05088
 #define IXGBE_MCSTCTRL  0x05090
 #define IXGBE_MRQC      0x05818
-#define IXGBE_VMD_CTL   0x0581C
 #define IXGBE_IMIR(_i)  (0x05A80 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIREXT(_i)       (0x05AA0 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIRVP    0x05AC0
+#define IXGBE_VMD_CTL   0x0581C
 #define IXGBE_RETA(_i)  (0x05C00 + ((_i) * 4))  /* 32 of these (0-31) */
 #define IXGBE_RSSRK(_i) (0x05C80 + ((_i) * 4))  /* 10 of these (0-9) */
 
+
 /* Transmit DMA registers */
-#define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40))/* 32 of these (0-31)*/
+#define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40)) /* 32 of these (0-31)*/
 #define IXGBE_TDBAH(_i) (0x06004 + ((_i) * 0x40))
 #define IXGBE_TDLEN(_i) (0x06008 + ((_i) * 0x40))
 #define IXGBE_TDH(_i)   (0x06010 + ((_i) * 0x40))
@@ -139,11 +154,10 @@
 #define IXGBE_TDWBAL(_i) (0x06038 + ((_i) * 0x40))
 #define IXGBE_TDWBAH(_i) (0x0603C + ((_i) * 0x40))
 #define IXGBE_DTXCTL    0x07E00
-#define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4))
-					      /* there are 16 of these (0-15) */
+
+#define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4)) /* 16 of these (0-15) */
 #define IXGBE_TIPG      0x0CB00
-#define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) *0x04))
-						      /* there are 8 of these */
+#define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) * 4)) /* 8 of these */
 #define IXGBE_MNGTXMAP  0x0CD10
 #define IXGBE_TIPG_FIBER_DEFAULT 3
 #define IXGBE_TXPBSIZE_SHIFT    10
@@ -155,6 +169,7 @@
 #define IXGBE_IPAV      0x05838
 #define IXGBE_IP4AT     0x05840 /* IPv4 table 0x5840-0x5858 */
 #define IXGBE_IP6AT     0x05880 /* IPv6 table 0x5880-0x588F */
+
 #define IXGBE_WUPL      0x05900
 #define IXGBE_WUPM      0x05A00 /* wake up pkt memory 0x5A00-0x5A7C */
 #define IXGBE_FHFT      0x09000 /* Flex host filter table 9000-93FC */
@@ -171,6 +186,8 @@
 #define IXGBE_TDPT2TCCR(_i)     (0x0CD20 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_TDPT2TCSR(_i)     (0x0CD40 + ((_i) * 4)) /* 8 of these (0-7) */
 
+
+
 /* Stats registers */
 #define IXGBE_CRCERRS   0x04000
 #define IXGBE_ILLERRC   0x04004
@@ -225,7 +242,7 @@
 #define IXGBE_XEC       0x04120
 
 #define IXGBE_RQSMR(_i) (0x02300 + ((_i) * 4)) /* 16 of these */
-#define IXGBE_TQSMR(_i) (0x07300 + ((_i) * 4)) /* 8 of these */
+#define IXGBE_TQSMR(_i) (((_i) <= 7) ? (0x07300 + ((_i) * 4)) : (0x08600 + ((_i) * 4)))
 
 #define IXGBE_QPRC(_i) (0x01030 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QPTC(_i) (0x06030 + ((_i) * 0x40)) /* 16 of these */
@@ -276,17 +293,17 @@
 #define IXGBE_DCA_CTRL  0x11074
 
 /* Diagnostic Registers */
-#define IXGBE_RDSTATCTL 0x02C20
-#define IXGBE_RDSTAT(_i) (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
-#define IXGBE_RDHMPN    0x02F08
+#define IXGBE_RDSTATCTL   0x02C20
+#define IXGBE_RDSTAT(_i)  (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
+#define IXGBE_RDHMPN      0x02F08
 #define IXGBE_RIC_DW(_i)  (0x02F10 + ((_i) * 4))
-#define IXGBE_RDPROBE   0x02F20
-#define IXGBE_TDSTATCTL 0x07C20
-#define IXGBE_TDSTAT(_i) (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
-#define IXGBE_TDHMPN    0x07F08
+#define IXGBE_RDPROBE     0x02F20
+#define IXGBE_TDSTATCTL   0x07C20
+#define IXGBE_TDSTAT(_i)  (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
+#define IXGBE_TDHMPN      0x07F08
 #define IXGBE_TIC_DW(_i)  (0x07F10 + ((_i) * 4))
-#define IXGBE_TDPROBE   0x07F20
-#define IXGBE_TXBUFCTRL 0x0C600
+#define IXGBE_TDPROBE     0x07F20
+#define IXGBE_TXBUFCTRL   0x0C600
 #define IXGBE_TXBUFDATA0  0x0C610
 #define IXGBE_TXBUFDATA1  0x0C614
 #define IXGBE_TXBUFDATA2  0x0C618
@@ -387,7 +404,7 @@
 
 #define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
 #define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
-#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* TX Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 #define IXGBE_DCA_MAX_QUEUES_82598   16 /* DCA regs only on 16 queues */
 
 /* MSCA Bit Masks */
@@ -411,10 +428,10 @@
 #define IXGBE_MSCA_MDI_IN_PROG_EN    0x80000000 /* MDI in progress enable */
 
 /* MSRWD bit masks */
-#define IXGBE_MSRWD_WRITE_DATA_MASK  0x0000FFFF
-#define IXGBE_MSRWD_WRITE_DATA_SHIFT 0
-#define IXGBE_MSRWD_READ_DATA_MASK   0xFFFF0000
-#define IXGBE_MSRWD_READ_DATA_SHIFT  16
+#define IXGBE_MSRWD_WRITE_DATA_MASK     0x0000FFFF
+#define IXGBE_MSRWD_WRITE_DATA_SHIFT    0
+#define IXGBE_MSRWD_READ_DATA_MASK      0xFFFF0000
+#define IXGBE_MSRWD_READ_DATA_SHIFT     16
 
 /* Atlas registers */
 #define IXGBE_ATLAS_PDN_LPBK    0x24
@@ -429,6 +446,7 @@
 #define IXGBE_ATLAS_PDN_TX_1G_QL_ALL    0xF0
 #define IXGBE_ATLAS_PDN_TX_AN_QL_ALL    0xF0
 
+
 /* Device Type definitions for new protocol MDIO commands */
 #define IXGBE_MDIO_PMA_PMD_DEV_TYPE               0x1
 #define IXGBE_MDIO_PCS_DEV_TYPE                   0x3
@@ -436,6 +454,8 @@
 #define IXGBE_MDIO_AUTO_NEG_DEV_TYPE              0x7
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE     0x1E   /* Device 30 */
 
+#define IXGBE_MDIO_COMMAND_TIMEOUT     100 /* PHY Timeout for 1 GB mode */
+
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_CONTROL      0x0    /* VS1 Control Reg */
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS       0x1    /* VS1 Status Reg */
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS  0x0008 /* 1 = Link Up */
@@ -449,23 +469,39 @@
 #define IXGBE_MDIO_PHY_XS_RESET        0x8000 /* PHY_XS Reset */
 #define IXGBE_MDIO_PHY_ID_HIGH         0x2 /* PHY ID High Reg*/
 #define IXGBE_MDIO_PHY_ID_LOW          0x3 /* PHY ID Low Reg*/
-#define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Abilty Reg */
+#define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Ability Reg */
 #define IXGBE_MDIO_PHY_SPEED_10G       0x0001 /* 10G capable */
 #define IXGBE_MDIO_PHY_SPEED_1G        0x0010 /* 1G capable */
 
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Address Reg */
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
+
+/* MII clause 22/28 definitions */
+#define IXGBE_MDIO_PHY_LOW_POWER_MODE  0x0800
+
+#define IXGBE_MII_SPEED_SELECTION_REG  0x10
+#define IXGBE_MII_RESTART              0x200
+#define IXGBE_MII_AUTONEG_COMPLETE     0x20
+#define IXGBE_MII_AUTONEG_REG          0x0
+
 #define IXGBE_PHY_REVISION_MASK        0xFFFFFFF0
 #define IXGBE_MAX_PHY_ADDR             32
 
 /* PHY IDs*/
-#define TN1010_PHY_ID    0x00A19410
 #define QT2022_PHY_ID    0x0043A400
 
+/* PHY Types */
+#define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
+
 /* General purpose Interrupt Enable */
-#define IXGBE_GPIE_MSIX_MODE      0x00000010 /* MSI-X mode */
-#define IXGBE_GPIE_OCD            0x00000020 /* Other Clear Disable */
-#define IXGBE_GPIE_EIMEN          0x00000040 /* Immediate Interrupt Enable */
-#define IXGBE_GPIE_EIAME          0x40000000
-#define IXGBE_GPIE_PBA_SUPPORT    0x80000000
+#define IXGBE_SDP0_GPIEN         0x00000001 /* SDP0 */
+#define IXGBE_SDP1_GPIEN         0x00000002 /* SDP1 */
+#define IXGBE_GPIE_MSIX_MODE     0x00000010 /* MSI-X mode */
+#define IXGBE_GPIE_OCD           0x00000020 /* Other Clear Disable */
+#define IXGBE_GPIE_EIMEN         0x00000040 /* Immediate Interrupt Enable */
+#define IXGBE_GPIE_EIAME         0x40000000
+#define IXGBE_GPIE_PBA_SUPPORT   0x80000000
 
 /* Transmit Flow Control status */
 #define IXGBE_TFCS_TXOFF         0x00000001
@@ -526,7 +562,7 @@
 #define IXGBE_PAP_TXPAUSECNT_MASK   0x0000FFFF /* Pause counter mask */
 
 /* RMCS Bit Masks */
-#define IXGBE_RMCS_RRM          0x00000002 /* Receive Recylce Mode enable */
+#define IXGBE_RMCS_RRM          0x00000002 /* Receive Recycle Mode enable */
 /* Receive Arbitration Control: 0 Round Robin, 1 DFP */
 #define IXGBE_RMCS_RAC          0x00000004
 #define IXGBE_RMCS_DFP          IXGBE_RMCS_RAC /* Deficit Fixed Priority ena */
@@ -534,12 +570,15 @@
 #define IXGBE_RMCS_TFCE_PRIORITY 0x00000010 /* Tx Priority flow control ena */
 #define IXGBE_RMCS_ARBDIS       0x00000040 /* Arbitration disable bit */
 
+
 /* Interrupt register bitmasks */
 
 /* Extended Interrupt Cause Read */
 #define IXGBE_EICR_RTX_QUEUE    0x0000FFFF /* RTx Queue Interrupt */
 #define IXGBE_EICR_LSC          0x00100000 /* Link Status Change */
-#define IXGBE_EICR_MNG          0x00400000 /* Managability Event Interrupt */
+#define IXGBE_EICR_MNG          0x00400000 /* Manageability Event Interrupt */
+#define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
+#define IXGBE_EICR_GPI_SDP1     0x02000000 /* Gen Purpose Interrupt on SDP1 */
 #define IXGBE_EICR_PBUR         0x10000000 /* Packet Buffer Handler Error */
 #define IXGBE_EICR_DHER         0x20000000 /* Descriptor Handler Error */
 #define IXGBE_EICR_TCP_TIMER    0x40000000 /* TCP Timer */
@@ -547,11 +586,12 @@
 
 /* Extended Interrupt Cause Set */
 #define IXGBE_EICS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
-#define IXGBE_EICS_LSC          IXGBE_EICR_LSC /* Link Status Change */
-#define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
-#define IXGBE_EICS_MNG          IXGBE_EICR_MNG /* MNG Event Interrupt */
-#define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR /* Pkt Buf Handler Error */
-#define IXGBE_EICS_DHER         IXGBE_EICR_DHER /* Desc Handler Error */
+#define IXGBE_EICS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
+#define IXGBE_EICS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
+#define IXGBE_EICS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EICS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
+#define IXGBE_EICS_DHER         IXGBE_EICR_DHER      /* Desc Handler Error */
 #define IXGBE_EICS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EICS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
 
@@ -559,7 +599,9 @@
 #define IXGBE_EIMS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
 #define IXGBE_EIMS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
-#define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Error */
+#define IXGBE_EIMS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EIMS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
 #define IXGBE_EIMS_DHER         IXGBE_EICR_DHER      /* Descr Handler Error */
 #define IXGBE_EIMS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EIMS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
@@ -568,18 +610,20 @@
 #define IXGBE_EIMC_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
 #define IXGBE_EIMC_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMC_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
-#define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Error */
-#define IXGBE_EIMC_DHER         IXGBE_EICR_DHER      /* Desc Handler Error */
+#define IXGBE_EIMC_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
+#define IXGBE_EIMC_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
+#define IXGBE_EIMC_DHER         IXGBE_EICR_DHER      /* Desc Handler Err */
 #define IXGBE_EIMC_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
 #define IXGBE_EIMC_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
 
-#define IXGBE_EIMS_ENABLE_MASK (\
-				IXGBE_EIMS_RTX_QUEUE       | \
-				IXGBE_EIMS_LSC             | \
-				IXGBE_EIMS_TCP_TIMER       | \
-				IXGBE_EIMS_OTHER)
+#define IXGBE_EIMS_ENABLE_MASK ( \
+                                IXGBE_EIMS_RTX_QUEUE       | \
+                                IXGBE_EIMS_LSC             | \
+                                IXGBE_EIMS_TCP_TIMER       | \
+                                IXGBE_EIMS_OTHER)
 
-/* Immediate Interrupt RX (A.K.A. Low Latency Interrupt) */
+/* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
 #define IXGBE_IMIR_PORT_IM_EN     0x00010000  /* TCP port enable */
 #define IXGBE_IMIR_PORT_BP        0x00020000  /* TCP port check bypass */
 #define IXGBE_IMIREXT_SIZE_BP     0x00001000  /* Packet size bypass */
@@ -616,6 +660,7 @@
 #define IXGBE_VLNCTRL_VFE       0x40000000  /* bit 30 */
 #define IXGBE_VLNCTRL_VME       0x80000000  /* bit 31 */
 
+
 #define IXGBE_ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.1q protocol */
 
 /* STATUS Bit Masks */
@@ -663,16 +708,16 @@
 #define IXGBE_AUTOC_AN_RESTART  0x00001000
 #define IXGBE_AUTOC_FLU         0x00000001
 #define IXGBE_AUTOC_LMS_SHIFT   13
-#define IXGBE_AUTOC_LMS_MASK   (0x7 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_1G_LINK_NO_AN  (0x0 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_10G_LINK_NO_AN (0x1 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_1G_AN  (0x2 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_KX4_AN (0x4 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_KX4_AN_1G_AN   (0x6 << IXGBE_AUTOC_LMS_SHIFT)
-#define IXGBE_AUTOC_LMS_ATTACH_TYPE    (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
-
-#define IXGBE_AUTOC_1G_PMA_PMD      0x00000200
-#define IXGBE_AUTOC_10G_PMA_PMD     0x00000180
+#define IXGBE_AUTOC_LMS_MASK            (0x7 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_LINK_NO_AN   (0x0 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_10G_LINK_NO_AN  (0x1 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_AN           (0x2 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN          (0x4 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN_1G_AN    (0x6 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_ATTACH_TYPE     (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+
+#define IXGBE_AUTOC_1G_PMA_PMD         0x00000200
+#define IXGBE_AUTOC_10G_PMA_PMD        0x00000180
 #define IXGBE_AUTOC_10G_PMA_PMD_SHIFT 7
 #define IXGBE_AUTOC_1G_PMA_PMD_SHIFT 9
 #define IXGBE_AUTOC_10G_XAUI   (0x0 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
@@ -753,6 +798,11 @@
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
 
+/* Legacy EEPROM word offsets */
+#define IXGBE_ISCSI_BOOT_CAPS           0x0033
+#define IXGBE_ISCSI_SETUP_PORT_0        0x0030
+#define IXGBE_ISCSI_SETUP_PORT_1        0x0034
+
 /* EEPROM Commands - SPI */
 #define IXGBE_EEPROM_MAX_RETRY_SPI      5000 /* Max wait 5ms for RDY signal */
 #define IXGBE_EEPROM_STATUS_RDY_SPI     0x01
@@ -760,7 +810,7 @@
 #define IXGBE_EEPROM_WRITE_OPCODE_SPI   0x02  /* EEPROM write opcode */
 #define IXGBE_EEPROM_A8_OPCODE_SPI      0x08  /* opcode bit-3 = addr bit-8 */
 #define IXGBE_EEPROM_WREN_OPCODE_SPI    0x06  /* EEPROM set Write Ena latch */
-/* EEPROM reset Write Enbale latch */
+/* EEPROM reset Write Enable latch */
 #define IXGBE_EEPROM_WRDI_OPCODE_SPI    0x04
 #define IXGBE_EEPROM_RDSR_OPCODE_SPI    0x05  /* EEPROM read Status reg */
 #define IXGBE_EEPROM_WRSR_OPCODE_SPI    0x01  /* EEPROM write Status reg */
@@ -799,22 +849,20 @@
 /* Number of 100 microseconds we wait for PCI Express master disable */
 #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
 
-/* PHY Types */
-#define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
-
 /* Check whether address is multicast.  This is little-endian specific check.*/
 #define IXGBE_IS_MULTICAST(Address) \
-		(bool)(((u8 *)(Address))[0] & ((u8)0x01))
+                (bool)(((u8 *)(Address))[0] & ((u8)0x01))
 
 /* Check whether an address is broadcast. */
 #define IXGBE_IS_BROADCAST(Address)                      \
-		((((u8 *)(Address))[0] == ((u8)0xff)) && \
-		(((u8 *)(Address))[1] == ((u8)0xff)))
+                ((((u8 *)(Address))[0] == ((u8)0xff)) && \
+                (((u8 *)(Address))[1] == ((u8)0xff)))
 
 /* RAH */
 #define IXGBE_RAH_VIND_MASK     0x003C0000
 #define IXGBE_RAH_VIND_SHIFT    18
 #define IXGBE_RAH_AV            0x80000000
+#define IXGBE_CLEAR_VMDQ_ALL    0xFFFFFFFF
 
 /* Header split receive */
 #define IXGBE_RFCTL_ISCSI_DIS       0x00000001
@@ -843,7 +891,7 @@
 #define IXGBE_MAX_FRAME_SZ      0x40040000
 
 #define IXGBE_TDWBAL_HEAD_WB_ENABLE   0x1      /* Tx head write-back enable */
-#define IXGBE_TDWBAL_SEQNUM_WB_ENABLE 0x2      /* Tx seq. # write-back enable */
+#define IXGBE_TDWBAL_SEQNUM_WB_ENABLE 0x2      /* Tx seq# write-back enable */
 
 /* Receive Config masks */
 #define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
@@ -856,7 +904,7 @@
 #define IXGBE_FCTRL_BAM 0x00000400 /* Broadcast Accept Mode */
 #define IXGBE_FCTRL_PMCF 0x00001000 /* Pass MAC Control Frames */
 #define IXGBE_FCTRL_DPF 0x00002000 /* Discard Pause Frame */
-/* Receive Priority Flow Control Enbale */
+/* Receive Priority Flow Control Enable */
 #define IXGBE_FCTRL_RPFCE 0x00004000
 #define IXGBE_FCTRL_RFCE 0x00008000 /* Receive Flow Control Ena */
 
@@ -886,9 +934,8 @@
 /* Receive Descriptor bit definitions */
 #define IXGBE_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define IXGBE_RXD_STAT_EOP      0x02    /* End of Packet */
-#define IXGBE_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define IXGBE_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define IXGBE_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define IXGBE_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define IXGBE_RXD_STAT_L4CS     0x20    /* L4 xsum calculated */
 #define IXGBE_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
 #define IXGBE_RXD_STAT_PIF      0x80    /* passed in-exact filter */
@@ -904,7 +951,7 @@
 #define IXGBE_RXD_ERR_USE       0x20    /* Undersize Error */
 #define IXGBE_RXD_ERR_TCPE      0x40    /* TCP/UDP Checksum Error */
 #define IXGBE_RXD_ERR_IPE       0x80    /* IP Checksum Error */
-#define IXGBE_RXDADV_HBO        0x00800000
+#define IXGBE_RXDADV_ERR_HBO    0x00800000 /*Header Buffer Overflow */
 #define IXGBE_RXDADV_ERR_CE     0x01000000 /* CRC Error */
 #define IXGBE_RXDADV_ERR_LE     0x02000000 /* Length Error */
 #define IXGBE_RXDADV_ERR_PE     0x08000000 /* Packet Error */
@@ -918,15 +965,17 @@
 #define IXGBE_RXD_CFI_MASK      0x1000  /* CFI is bit 12 */
 #define IXGBE_RXD_CFI_SHIFT     12
 
+
 /* SRRCTL bit definitions */
-#define IXGBE_SRRCTL_BSIZEPKT_SHIFT 10     /* so many KBs */
-#define IXGBE_SRRCTL_BSIZEPKT_MASK  0x0000007F
-#define IXGBE_SRRCTL_BSIZEHDR_MASK  0x00003F00
-#define IXGBE_SRRCTL_DESCTYPE_LEGACY 0x00000000
+#define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */
+#define IXGBE_SRRCTL_BSIZEPKT_MASK      0x0000007F
+#define IXGBE_SRRCTL_BSIZEHDR_MASK      0x00003F00
+#define IXGBE_SRRCTL_DESCTYPE_LEGACY    0x00000000
 #define IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF 0x02000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT  0x04000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS 0x0A000000
+#define IXGBE_SRRCTL_DESCTYPE_MASK      0x0E000000
 
 #define IXGBE_RXDPS_HDRSTAT_HDRSP       0x00008000
 #define IXGBE_RXDPS_HDRSTAT_HDRLEN_MASK 0x000003FF
@@ -960,21 +1009,20 @@
 #define IXGBE_RXDADV_PKTTYPE_UDP        0x00000200 /* UDP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_SCTP       0x00000400 /* SCTP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_NFS        0x00000800 /* NFS hdr present */
-
 /* Masks to determine if packets should be dropped due to frame errors */
-#define IXGBE_RXD_ERR_FRAME_ERR_MASK (\
-				      IXGBE_RXD_ERR_CE | \
-				      IXGBE_RXD_ERR_LE | \
-				      IXGBE_RXD_ERR_PE | \
-				      IXGBE_RXD_ERR_OSE | \
-				      IXGBE_RXD_ERR_USE)
-
-#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK (\
-				      IXGBE_RXDADV_ERR_CE | \
-				      IXGBE_RXDADV_ERR_LE | \
-				      IXGBE_RXDADV_ERR_PE | \
-				      IXGBE_RXDADV_ERR_OSE | \
-				      IXGBE_RXDADV_ERR_USE)
+#define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
+                                      IXGBE_RXD_ERR_CE | \
+                                      IXGBE_RXD_ERR_LE | \
+                                      IXGBE_RXD_ERR_PE | \
+                                      IXGBE_RXD_ERR_OSE | \
+                                      IXGBE_RXD_ERR_USE)
+
+#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK ( \
+                                      IXGBE_RXDADV_ERR_CE | \
+                                      IXGBE_RXDADV_ERR_LE | \
+                                      IXGBE_RXDADV_ERR_PE | \
+                                      IXGBE_RXDADV_ERR_OSE | \
+                                      IXGBE_RXDADV_ERR_USE)
 
 /* Multicast bit mask */
 #define IXGBE_MCSTCTRL_MFE      0x4
@@ -990,6 +1038,7 @@
 #define IXGBE_RX_DESC_SPECIAL_PRI_SHIFT  0x000D /* Priority in upper 3 of 16 */
 #define IXGBE_TX_DESC_SPECIAL_PRI_SHIFT  IXGBE_RX_DESC_SPECIAL_PRI_SHIFT
 
+
 /* Transmit Descriptor - Legacy */
 struct ixgbe_legacy_tx_desc {
 	u64 buffer_addr;       /* Address of the descriptor's data buffer */
@@ -1004,8 +1053,8 @@ struct ixgbe_legacy_tx_desc {
 	union {
 		__le32 data;
 		struct {
-			u8 status;     /* Descriptor status */
-			u8 css;        /* Checksum start */
+			u8 status;        /* Descriptor status */
+			u8 css;           /* Checksum start */
 			__le16 vlan;
 		} fields;
 	} upper;
@@ -1014,7 +1063,7 @@ struct ixgbe_legacy_tx_desc {
 /* Transmit Descriptor - Advanced */
 union ixgbe_adv_tx_desc {
 	struct {
-		__le64 buffer_addr;       /* Address of descriptor's data buf */
+		__le64 buffer_addr;      /* Address of descriptor's data buf */
 		__le32 cmd_type_len;
 		__le32 olinfo_status;
 	} read;
@@ -1046,8 +1095,8 @@ union ixgbe_adv_rx_desc {
 			union {
 				__le32 data;
 				struct {
-					__le16 pkt_info; /* RSS type, Packet type */
-					__le16 hdr_info; /* Split Header, header len */
+					__le16 pkt_info; /* RSS, Pkt type */
+					__le16 hdr_info; /* Splithdr, hdrlen */
 				} hs_rss;
 			} lo_dword;
 			union {
@@ -1075,49 +1124,69 @@ struct ixgbe_adv_tx_context_desc {
 };
 
 /* Adv Transmit Descriptor Config Masks */
-#define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buffer length(bytes) */
+#define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buf length(bytes) */
 #define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
 #define IXGBE_ADVTXD_DTYP_CTXT  0x00200000 /* Advanced Context Desc */
 #define IXGBE_ADVTXD_DTYP_DATA  0x00300000 /* Advanced Data Descriptor */
 #define IXGBE_ADVTXD_DCMD_EOP   IXGBE_TXD_CMD_EOP  /* End of Packet */
 #define IXGBE_ADVTXD_DCMD_IFCS  IXGBE_TXD_CMD_IFCS /* Insert FCS */
-#define IXGBE_ADVTXD_DCMD_RDMA  0x04000000 /* RDMA */
 #define IXGBE_ADVTXD_DCMD_RS    IXGBE_TXD_CMD_RS   /* Report Status */
-#define IXGBE_ADVTXD_DCMD_DDTYP_ISCSI 0x10000000     /* DDP hdr type or iSCSI */
+#define IXGBE_ADVTXD_DCMD_DDTYP_ISCSI 0x10000000    /* DDP hdr type or iSCSI */
 #define IXGBE_ADVTXD_DCMD_DEXT  IXGBE_TXD_CMD_DEXT /* Desc ext (1=Adv) */
 #define IXGBE_ADVTXD_DCMD_VLE   IXGBE_TXD_CMD_VLE  /* VLAN pkt enable */
 #define IXGBE_ADVTXD_DCMD_TSE   0x80000000 /* TCP Seg enable */
 #define IXGBE_ADVTXD_STAT_DD    IXGBE_TXD_STAT_DD  /* Descriptor Done */
-#define IXGBE_ADVTXD_STAT_SN_CRC      0x00000002 /* NXTSEQ/SEED present in WB */
+#define IXGBE_ADVTXD_STAT_SN_CRC      0x00000002 /* NXTSEQ/SEED pres in WB */
 #define IXGBE_ADVTXD_STAT_RSV   0x0000000C /* STA Reserved */
 #define IXGBE_ADVTXD_IDX_SHIFT  4 /* Adv desc Index shift */
+#define IXGBE_ADVTXD_CC         0x00000080 /* Check Context */
 #define IXGBE_ADVTXD_POPTS_SHIFT      8  /* Adv desc POPTS shift */
 #define IXGBE_ADVTXD_POPTS_IXSM (IXGBE_TXD_POPTS_IXSM << \
-				IXGBE_ADVTXD_POPTS_SHIFT)
+                                 IXGBE_ADVTXD_POPTS_SHIFT)
 #define IXGBE_ADVTXD_POPTS_TXSM (IXGBE_TXD_POPTS_TXSM << \
-				IXGBE_ADVTXD_POPTS_SHIFT)
-#define IXGBE_ADVTXD_POPTS_EOM  0x00000400 /* Enable L bit-RDMA DDP hdr */
-#define IXGBE_ADVTXD_POPTS_ISCO_1ST   0x00000000 /* 1st TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_MDL   0x00000800 /* Middle TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_LAST  0x00001000 /* Last TSO of iSCSI PDU */
-#define IXGBE_ADVTXD_POPTS_ISCO_FULL 0x00001800 /* 1st&Last TSO-full iSCSI PDU*/
-#define IXGBE_ADVTXD_POPTS_RSV  0x00002000 /* POPTS Reserved */
-#define IXGBE_ADVTXD_PAYLEN_SHIFT  14 /* Adv desc PAYLEN shift */
-#define IXGBE_ADVTXD_MACLEN_SHIFT  9  /* Adv ctxt desc mac len shift */
-#define IXGBE_ADVTXD_VLAN_SHIFT    16  /* Adv ctxt vlan tag shift */
-#define IXGBE_ADVTXD_TUCMD_IPV4    0x00000400  /* IP Packet Type: 1=IPv4 */
-#define IXGBE_ADVTXD_TUCMD_IPV6    0x00000000  /* IP Packet Type: 0=IPv6 */
-#define IXGBE_ADVTXD_TUCMD_L4T_UDP 0x00000000  /* L4 Packet TYPE of UDP */
-#define IXGBE_ADVTXD_TUCMD_L4T_TCP 0x00000800  /* L4 Packet TYPE of TCP */
-#define IXGBE_ADVTXD_TUCMD_MKRREQ  0x00002000 /* Req requires Markers and CRC */
-#define IXGBE_ADVTXD_L4LEN_SHIFT   8  /* Adv ctxt L4LEN shift */
-#define IXGBE_ADVTXD_MSS_SHIFT     16  /* Adv ctxt MSS shift */
-
+                                 IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_POPTS_ISCO_1ST  0x00000000 /* 1st TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_MDL  0x00000800 /* Middle TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_LAST 0x00001000 /* Last TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_FULL 0x00001800 /* 1st&Last TSO-full iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_RSV       0x00002000 /* POPTS Reserved */
+#define IXGBE_ADVTXD_PAYLEN_SHIFT    14 /* Adv desc PAYLEN shift */
+#define IXGBE_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
+#define IXGBE_ADVTXD_VLAN_SHIFT      16  /* Adv ctxt vlan tag shift */
+#define IXGBE_ADVTXD_TUCMD_IPV4      0x00000400  /* IP Packet Type: 1=IPv4 */
+#define IXGBE_ADVTXD_TUCMD_IPV6      0x00000000  /* IP Packet Type: 0=IPv6 */
+#define IXGBE_ADVTXD_TUCMD_L4T_UDP   0x00000000  /* L4 Packet TYPE of UDP */
+#define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
+#define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
+#define IXGBE_ADVTXD_TUCMD_MKRREQ    0x00002000 /*Req requires Markers and CRC*/
+#define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
+#define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
+
+/* Autonegotiation advertised speeds */
+typedef u32 ixgbe_autoneg_advertised;
 /* Link speed */
+typedef u32 ixgbe_link_speed;
 #define IXGBE_LINK_SPEED_UNKNOWN   0
 #define IXGBE_LINK_SPEED_100_FULL  0x0008
 #define IXGBE_LINK_SPEED_1GB_FULL  0x0020
 #define IXGBE_LINK_SPEED_10GB_FULL 0x0080
+#define IXGBE_LINK_SPEED_82598_AUTONEG (IXGBE_LINK_SPEED_1GB_FULL | \
+                                        IXGBE_LINK_SPEED_10GB_FULL)
+
+/* Physical layer type */
+typedef u32 ixgbe_physical_layer;
+#define IXGBE_PHYSICAL_LAYER_UNKNOWN      0
+#define IXGBE_PHYSICAL_LAYER_10GBASE_T    0x0001
+#define IXGBE_PHYSICAL_LAYER_1000BASE_T   0x0002
+#define IXGBE_PHYSICAL_LAYER_100BASE_T    0x0004
+#define IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU  0x0008
+#define IXGBE_PHYSICAL_LAYER_10GBASE_LR   0x0010
+#define IXGBE_PHYSICAL_LAYER_10GBASE_LRM  0x0020
+#define IXGBE_PHYSICAL_LAYER_10GBASE_SR   0x0040
+#define IXGBE_PHYSICAL_LAYER_10GBASE_KX4  0x0080
+#define IXGBE_PHYSICAL_LAYER_10GBASE_CX4  0x0100
+#define IXGBE_PHYSICAL_LAYER_1000BASE_KX  0x0200
+#define IXGBE_PHYSICAL_LAYER_1000BASE_BX  0x0400
 
 
 enum ixgbe_eeprom_type {
@@ -1134,16 +1203,38 @@ enum ixgbe_mac_type {
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
-	ixgbe_phy_tn,
 	ixgbe_phy_qt,
-	ixgbe_phy_xaui
+	ixgbe_phy_xaui,
+	ixgbe_phy_tw_tyco,
+	ixgbe_phy_tw_unknown,
+	ixgbe_phy_sfp_avago,
+	ixgbe_phy_sfp_ftl,
+	ixgbe_phy_sfp_unknown,
+	ixgbe_phy_generic
+};
+
+/*
+ * SFP+ module type IDs:
+ *
+ * ID	Module Type
+ * =============
+ * 0	SFP_DA_CU
+ * 1	SFP_SR
+ * 2	SFP_LR
+ */
+enum ixgbe_sfp_type {
+	ixgbe_sfp_type_da_cu = 0,
+	ixgbe_sfp_type_sr = 1,
+	ixgbe_sfp_type_lr = 2,
+	ixgbe_sfp_type_unknown = 0xFFFF
 };
 
 enum ixgbe_media_type {
 	ixgbe_media_type_unknown = 0,
 	ixgbe_media_type_fiber,
 	ixgbe_media_type_copper,
-	ixgbe_media_type_backplane
+	ixgbe_media_type_backplane,
+	ixgbe_media_type_virtual
 };
 
 /* Flow Control Settings */
@@ -1241,59 +1332,114 @@ struct ixgbe_hw;
 typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
                                   u32 *vmdq);
 
+/* Function pointer table */
+struct ixgbe_eeprom_operations {
+	s32 (*init_params)(struct ixgbe_hw *);
+	s32 (*read)(struct ixgbe_hw *, u16, u16 *);
+	s32 (*write)(struct ixgbe_hw *, u16, u16);
+	s32 (*validate_checksum)(struct ixgbe_hw *, u16 *);
+	s32 (*update_checksum)(struct ixgbe_hw *);
+};
+
 struct ixgbe_mac_operations {
-	s32 (*reset)(struct ixgbe_hw *);
+	s32 (*init_hw)(struct ixgbe_hw *);
+	s32 (*reset_hw)(struct ixgbe_hw *);
+	s32 (*start_hw)(struct ixgbe_hw *);
+	s32 (*clear_hw_cntrs)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
+	s32 (*get_supported_physical_layer)(struct ixgbe_hw *);
+	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
+	s32 (*stop_adapter)(struct ixgbe_hw *);
+	s32 (*get_bus_info)(struct ixgbe_hw *);
+	s32 (*read_analog_reg8)(struct ixgbe_hw*, u32, u8*);
+	s32 (*write_analog_reg8)(struct ixgbe_hw*, u32, u8);
+
+	/* Link */
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *, bool);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
-	s32 (*get_link_settings)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
+	                        bool);
+	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
+	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
+	                             bool *);
+
+	/* LED */
+	s32 (*led_on)(struct ixgbe_hw *, u32);
+	s32 (*led_off)(struct ixgbe_hw *, u32);
+	s32 (*blink_led_start)(struct ixgbe_hw *, u32);
+	s32 (*blink_led_stop)(struct ixgbe_hw *, u32);
+
+	/* RAR, Multicast, VLAN */
+	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32, u32);
+	s32 (*clear_rar)(struct ixgbe_hw *, u32);
+	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
+	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
+	s32 (*init_rx_addrs)(struct ixgbe_hw *);
+	s32 (*update_uc_addr_list)(struct ixgbe_hw *, u8 *, u32,
+	                           ixgbe_mc_addr_itr);
+	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
+	                           ixgbe_mc_addr_itr);
+	s32 (*enable_mc)(struct ixgbe_hw *);
+	s32 (*disable_mc)(struct ixgbe_hw *);
+	s32 (*clear_vfta)(struct ixgbe_hw *);
+	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
+	s32 (*init_uta_tables)(struct ixgbe_hw *);
+
+	/* Flow Control */
+	s32 (*setup_fc)(struct ixgbe_hw *, s32);
 };
 
 struct ixgbe_phy_operations {
+	s32 (*identify)(struct ixgbe_hw *);
+	s32 (*identify_sfp)(struct ixgbe_hw *);
+	s32 (*reset)(struct ixgbe_hw *);
+	s32 (*read_reg)(struct ixgbe_hw *, u32, u32, u16 *);
+	s32 (*write_reg)(struct ixgbe_hw *, u32, u32, u16);
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
-};
-
-struct ixgbe_mac_info {
-	struct ixgbe_mac_operations	ops;
-	enum ixgbe_mac_type		type;
-	u8				addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	u8				perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	s32				mc_filter_type;
-	u32				mcft_size;
-	u32				vft_size;
-	u32				num_rar_entries;
-	u32				num_rx_queues;
-	u32				num_tx_queues;
-	u32				link_attach_type;
-	u32				link_mode_select;
-	bool				link_settings_loaded;
+	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
+	                        bool);
+	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
+	s32 (*write_i2c_byte)(struct ixgbe_hw *, u8, u8, u8);
+	s32 (*read_i2c_eeprom)(struct ixgbe_hw *, u8 , u8 *);
+	s32 (*write_i2c_eeprom)(struct ixgbe_hw *, u8, u8);
 };
 
 struct ixgbe_eeprom_info {
-	enum ixgbe_eeprom_type		type;
-	u16				word_size;
-	u16				address_bits;
+	struct ixgbe_eeprom_operations  ops;
+	enum ixgbe_eeprom_type          type;
+	u32				semaphore_delay;
+	u16                             word_size;
+	u16                             address_bits;
 };
 
-struct ixgbe_phy_info {
-	struct ixgbe_phy_operations	ops;
-
-	enum ixgbe_phy_type		type;
-	u32				addr;
-	u32				id;
-	u32				revision;
-	enum ixgbe_media_type		media_type;
-	u32				autoneg_advertised;
-	bool				autoneg_wait_to_complete;
+struct ixgbe_mac_info {
+	struct ixgbe_mac_operations     ops;
+	enum ixgbe_mac_type             type;
+	u8                              addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	u8                              perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	s32                             mc_filter_type;
+	u32                             mcft_size;
+	u32                             vft_size;
+	u32                             num_rar_entries;
+	u32                             max_tx_queues;
+	u32                             max_rx_queues;
+	u32                             link_attach_type;
+	u32                             link_mode_select;
+	bool                            link_settings_loaded;
+	bool                            autoneg;
+	bool                            autoneg_failed;
 };
 
-struct ixgbe_info {
-	enum ixgbe_mac_type		mac;
-	s32 				(*get_invariants)(struct ixgbe_hw *);
-	struct ixgbe_mac_operations	*mac_ops;
+struct ixgbe_phy_info {
+	struct ixgbe_phy_operations     ops;
+	enum ixgbe_phy_type             type;
+	u32                             addr;
+	u32                             id;
+	enum ixgbe_sfp_type             sfp_type;
+	u32                             revision;
+	enum ixgbe_media_type           media_type;
+	bool                            reset_disable;
+	ixgbe_autoneg_advertised        autoneg_advertised;
+	bool                            autoneg_wait_to_complete;
 };
 
 struct ixgbe_hw {
@@ -1312,6 +1458,15 @@ struct ixgbe_hw {
 	bool				adapter_stopped;
 };
 
+struct ixgbe_info {
+	enum ixgbe_mac_type		mac;
+	s32 				(*get_invariants)(struct ixgbe_hw *);
+	struct ixgbe_mac_operations	*mac_ops;
+	struct ixgbe_eeprom_operations	*eeprom_ops;
+	struct ixgbe_phy_operations	*phy_ops;
+};
+
+
 /* Error Codes */
 #define IXGBE_ERR_EEPROM                        -1
 #define IXGBE_ERR_EEPROM_CHECKSUM               -2
@@ -1330,6 +1485,8 @@ struct ixgbe_hw {
 #define IXGBE_ERR_RESET_FAILED                  -15
 #define IXGBE_ERR_SWFW_SYNC                     -16
 #define IXGBE_ERR_PHY_ADDR_INVALID              -17
+#define IXGBE_ERR_I2C                           -18
+#define IXGBE_ERR_SFP_NOT_SUPPORTED             -19
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */

