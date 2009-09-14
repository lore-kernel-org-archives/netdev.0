From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] igb: reset sgmii phy at start of init
Date: Mon, 14 Sep 2009 11:22:54 -0700
Message-ID: <20090914182253.4859.11176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:51857 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932989AbZINSXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 14:23:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Our SGMII phy code was incomplete in that it was not actually placing the
phy in SGMII mode and as a result the PHY was not able to establish a link
when connected to a non serdes link partner.  This patch updates the code
to combine the SGMII/serdes PCS init and to add the necessary reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/igb/e1000_82575.c   |  198 ++++++++++++++++++---------------------
 drivers/net/igb/e1000_82575.h   |    2 
 drivers/net/igb/e1000_defines.h |    2 
 drivers/net/igb/igb_main.c      |    2 
 4 files changed, 95 insertions(+), 109 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 6158c0f..f8f5772 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -49,11 +49,10 @@ static s32  igb_read_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16 *);
 static s32  igb_reset_hw_82575(struct e1000_hw *);
 static s32  igb_set_d0_lplu_state_82575(struct e1000_hw *, bool);
 static s32  igb_setup_copper_link_82575(struct e1000_hw *);
-static s32  igb_setup_fiber_serdes_link_82575(struct e1000_hw *);
+static s32  igb_setup_serdes_link_82575(struct e1000_hw *);
 static s32  igb_write_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16);
 static void igb_clear_hw_cntrs_82575(struct e1000_hw *);
 static s32  igb_acquire_swfw_sync_82575(struct e1000_hw *, u16);
-static void igb_configure_pcs_link_82575(struct e1000_hw *);
 static s32  igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *, u16 *,
 						 u16 *);
 static s32  igb_get_phy_id_82575(struct e1000_hw *);
@@ -105,16 +104,20 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	dev_spec->sgmii_active = false;
 
 	ctrl_ext = rd32(E1000_CTRL_EXT);
-	if ((ctrl_ext & E1000_CTRL_EXT_LINK_MODE_MASK) ==
-	    E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES) {
-		hw->phy.media_type = e1000_media_type_internal_serdes;
-		ctrl_ext |= E1000_CTRL_I2C_ENA;
-	} else if (ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII) {
+	switch (ctrl_ext & E1000_CTRL_EXT_LINK_MODE_MASK) {
+	case E1000_CTRL_EXT_LINK_MODE_SGMII:
 		dev_spec->sgmii_active = true;
 		ctrl_ext |= E1000_CTRL_I2C_ENA;
-	} else {
+		break;
+	case E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES:
+		hw->phy.media_type = e1000_media_type_internal_serdes;
+		ctrl_ext |= E1000_CTRL_I2C_ENA;
+		break;
+	default:
 		ctrl_ext &= ~E1000_CTRL_I2C_ENA;
+		break;
 	}
+
 	wr32(E1000_CTRL_EXT, ctrl_ext);
 
 	/* Set mta register count */
@@ -134,7 +137,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	mac->ops.setup_physical_interface =
 		(hw->phy.media_type == e1000_media_type_copper)
 			? igb_setup_copper_link_82575
-			: igb_setup_fiber_serdes_link_82575;
+			: igb_setup_serdes_link_82575;
 
 	/* NVM initialization */
 	eecd = rd32(E1000_EECD);
@@ -379,6 +382,7 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	struct e1000_phy_info *phy = &hw->phy;
 	s32  ret_val = 0;
 	u16 phy_id;
+	u32 ctrl_ext;
 
 	/*
 	 * For SGMII PHYs, we try the list of possible addresses until
@@ -393,6 +397,12 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 		goto out;
 	}
 
+	/* Power on sgmii phy if it is disabled */
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+	wr32(E1000_CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_SDP3_DATA);
+	wrfl();
+	msleep(300);
+
 	/*
 	 * The address field in the I2CCMD register is 3 bits and 0 is invalid.
 	 * Therefore, we need to test 1-7
@@ -418,9 +428,12 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 		phy->addr = 0;
 		ret_val = -E1000_ERR_PHY;
 		goto out;
+	} else {
+		ret_val = igb_get_phy_id(hw);
 	}
 
-	ret_val = igb_get_phy_id(hw);
+	/* restore previous sfp cage power state */
+	wr32(E1000_CTRL_EXT, ctrl_ext);
 
 out:
 	return ret_val;
@@ -766,17 +779,18 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  igb_shutdown_fiber_serdes_link_82575 - Remove link during power down
+ *  igb_shutdown_serdes_link_82575 - Remove link during power down
  *  @hw: pointer to the HW structure
  *
  *  In the case of fiber serdes, shut down optics and PCS on driver unload
  *  when management pass thru is not enabled.
  **/
-void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
+void igb_shutdown_serdes_link_82575(struct e1000_hw *hw)
 {
 	u32 reg;
 
-	if (hw->phy.media_type != e1000_media_type_internal_serdes)
+	if (hw->phy.media_type != e1000_media_type_internal_serdes ||
+	    igb_sgmii_active_82575(hw))
 		return;
 
 	/* if the management interface is not enabled, then power down */
@@ -788,7 +802,7 @@ void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
 
 		/* shutdown the laser */
 		reg = rd32(E1000_CTRL_EXT);
-		reg |= E1000_CTRL_EXT_SDP7_DATA;
+		reg |= E1000_CTRL_EXT_SDP3_DATA;
 		wr32(E1000_CTRL_EXT, reg);
 
 		/* flush the write to verify completion */
@@ -927,6 +941,17 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	wr32(E1000_CTRL, ctrl);
 
+	ret_val = igb_setup_serdes_link_82575(hw);
+	if (ret_val)
+		goto out;
+
+	if (igb_sgmii_active_82575(hw) && !hw->phy.reset_disable) {
+		ret_val = hw->phy.ops.reset(hw);
+		if (ret_val) {
+			hw_dbg("Error resetting the PHY.\n");
+			goto out;
+		}
+	}
 	switch (hw->phy.type) {
 	case e1000_phy_m88:
 		ret_val = igb_copper_link_setup_m88(hw);
@@ -963,8 +988,6 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		}
 	}
 
-	igb_configure_pcs_link_82575(hw);
-
 	/*
 	 * Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
@@ -987,14 +1010,18 @@ out:
 }
 
 /**
- *  igb_setup_fiber_serdes_link_82575 - Setup link for fiber/serdes
+ *  igb_setup_serdes_link_82575 - Setup link for fiber/serdes
  *  @hw: pointer to the HW structure
  *
  *  Configures speed and duplex for fiber and serdes links.
  **/
-static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
+static s32 igb_setup_serdes_link_82575(struct e1000_hw *hw)
 {
-	u32 reg;
+	u32 ctrl_reg, reg;
+
+	if ((hw->phy.media_type != e1000_media_type_internal_serdes) &&
+	    !igb_sgmii_active_82575(hw))
+		return 0;
 
 	/*
 	 * On the 82575, SerDes loopback mode persists until it is
@@ -1004,26 +1031,38 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 	 */
 	wr32(E1000_SCTL, E1000_SCTL_DISABLE_SERDES_LOOPBACK);
 
-	/* Force link up, set 1gb, set both sw defined pins */
-	reg = rd32(E1000_CTRL);
-	reg |= E1000_CTRL_SLU |
-	       E1000_CTRL_SPD_1000 |
-	       E1000_CTRL_FRCSPD |
-	       E1000_CTRL_SWDPIN0 |
-	       E1000_CTRL_SWDPIN1;
-	wr32(E1000_CTRL, reg);
-
-	/* Power on phy for 82576 fiber adapters */
-	if (hw->mac.type == e1000_82576) {
-		reg = rd32(E1000_CTRL_EXT);
-		reg &= ~E1000_CTRL_EXT_SDP7_DATA;
-		wr32(E1000_CTRL_EXT, reg);
+	/* power on the sfp cage if present */
+	reg = rd32(E1000_CTRL_EXT);
+	reg &= ~E1000_CTRL_EXT_SDP3_DATA;
+	wr32(E1000_CTRL_EXT, reg);
+
+	ctrl_reg = rd32(E1000_CTRL);
+	ctrl_reg |= E1000_CTRL_SLU;
+
+	if (hw->mac.type == e1000_82575 || hw->mac.type == e1000_82576) {
+		/* set both sw defined pins */
+		ctrl_reg |= E1000_CTRL_SWDPIN0 | E1000_CTRL_SWDPIN1;
+
+		/* Set switch control to serdes energy detect */
+		reg = rd32(E1000_CONNSW);
+		reg |= E1000_CONNSW_ENRGSRC;
+		wr32(E1000_CONNSW, reg);
+	}
+
+	reg = rd32(E1000_PCS_LCTL);
+
+	if (igb_sgmii_active_82575(hw)) {
+		/* allow time for SFP cage to power up phy */
+		msleep(300);
+
+		/* AN time out should be disabled for SGMII mode */
+		reg &= ~(E1000_PCS_LCTL_AN_TIMEOUT);
+	} else {
+		ctrl_reg |= E1000_CTRL_SPD_1000 | E1000_CTRL_FRCSPD |
+		            E1000_CTRL_FD | E1000_CTRL_FRCDPX;
 	}
 
-	/* Set switch control to serdes energy detect */
-	reg = rd32(E1000_CONNSW);
-	reg |= E1000_CONNSW_ENRGSRC;
-	wr32(E1000_CONNSW, reg);
+	wr32(E1000_CTRL, ctrl_reg);
 
 	/*
 	 * New SerDes mode allows for forcing speed or autonegotiating speed
@@ -1031,12 +1070,21 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 	 * mode that will be compatible with older link partners and switches.
 	 * However, both are supported by the hardware and some drivers/tools.
 	 */
-	reg = rd32(E1000_PCS_LCTL);
 
 	reg &= ~(E1000_PCS_LCTL_AN_ENABLE | E1000_PCS_LCTL_FLV_LINK_UP |
 		E1000_PCS_LCTL_FSD | E1000_PCS_LCTL_FORCE_LINK);
 
-	if (hw->mac.autoneg) {
+	/*
+	 * We force flow control to prevent the CTRL register values from being
+	 * overwritten by the autonegotiated flow control values
+	 */
+	reg |= E1000_PCS_LCTL_FORCE_FCTRL;
+
+	/*
+	 * we always set sgmii to autoneg since it is the phy that will be
+	 * forcing the link and the serdes is just a go-between
+	 */
+	if (hw->mac.autoneg || igb_sgmii_active_82575(hw)) {
 		/* Set PCS register for autoneg */
 		reg |= E1000_PCS_LCTL_FSV_1000 |      /* Force 1000    */
 		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
@@ -1053,75 +1101,12 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		hw_dbg("Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
 	}
 
-	if (hw->mac.type == e1000_82576) {
-		reg |= E1000_PCS_LCTL_FORCE_FCTRL;
-		igb_force_mac_fc(hw);
-	}
-
 	wr32(E1000_PCS_LCTL, reg);
 
-	return 0;
-}
-
-/**
- *  igb_configure_pcs_link_82575 - Configure PCS link
- *  @hw: pointer to the HW structure
- *
- *  Configure the physical coding sub-layer (PCS) link.  The PCS link is
- *  only used on copper connections where the serialized gigabit media
- *  independent interface (sgmii) is being used.  Configures the link
- *  for auto-negotiation or forces speed/duplex.
- **/
-static void igb_configure_pcs_link_82575(struct e1000_hw *hw)
-{
-	struct e1000_mac_info *mac = &hw->mac;
-	u32 reg = 0;
-
-	if (hw->phy.media_type != e1000_media_type_copper ||
-	    !(igb_sgmii_active_82575(hw)))
-		return;
-
-	/* For SGMII, we need to issue a PCS autoneg restart */
-	reg = rd32(E1000_PCS_LCTL);
-
-	/* AN time out should be disabled for SGMII mode */
-	reg &= ~(E1000_PCS_LCTL_AN_TIMEOUT);
-
-	if (mac->autoneg) {
-		/* Make sure forced speed and force link are not set */
-		reg &= ~(E1000_PCS_LCTL_FSD | E1000_PCS_LCTL_FORCE_LINK);
-
-		/*
-		 * The PHY should be setup prior to calling this function.
-		 * All we need to do is restart autoneg and enable autoneg.
-		 */
-		reg |= E1000_PCS_LCTL_AN_RESTART | E1000_PCS_LCTL_AN_ENABLE;
-	} else {
-		/* Set PCS register for forced speed */
-
-		/* Turn off bits for full duplex, speed, and autoneg */
-		reg &= ~(E1000_PCS_LCTL_FSV_1000 |
-			 E1000_PCS_LCTL_FSV_100 |
-			 E1000_PCS_LCTL_FDV_FULL |
-			 E1000_PCS_LCTL_AN_ENABLE);
-
-		/* Check for duplex first */
-		if (mac->forced_speed_duplex & E1000_ALL_FULL_DUPLEX)
-			reg |= E1000_PCS_LCTL_FDV_FULL;
-
-		/* Now set speed */
-		if (mac->forced_speed_duplex & E1000_ALL_100_SPEED)
-			reg |= E1000_PCS_LCTL_FSV_100;
-
-		/* Force speed and force link */
-		reg |= E1000_PCS_LCTL_FSD |
-		       E1000_PCS_LCTL_FORCE_LINK |
-		       E1000_PCS_LCTL_FLV_LINK_UP;
+	if (!igb_sgmii_active_82575(hw))
+		igb_force_mac_fc(hw);
 
-		hw_dbg("Wrote 0x%08X to PCS_LCTL to configure forced link\n",
-		       reg);
-	}
-	wr32(E1000_PCS_LCTL, reg);
+	return 0;
 }
 
 /**
@@ -1248,7 +1233,8 @@ static void igb_clear_hw_cntrs_82575(struct e1000_hw *hw)
 	temp = rd32(E1000_LENERRS);
 
 	/* This register should not be read in copper configurations */
-	if (hw->phy.media_type == e1000_media_type_internal_serdes)
+	if (hw->phy.media_type == e1000_media_type_internal_serdes ||
+	    igb_sgmii_active_82575(hw))
 		temp = rd32(E1000_SCVPC);
 }
 
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 8a1e659..ebd146f 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -28,7 +28,7 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
 
-extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
+extern void igb_shutdown_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 
 #define ID_LED_DEFAULT_82575_SERDES ((ID_LED_DEF1_DEF2 << 12) | \
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index c858293..cb91683 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -44,7 +44,7 @@
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
 
 /* Extended Device Control */
-#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
+#define E1000_CTRL_EXT_SDP3_DATA 0x00000080 /* Value of SW Defineable Pin 3 */
 /* Physical Func Reset Done Indication */
 #define E1000_CTRL_EXT_PFRSTD    0x00004000
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 290555c..8832c05 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5322,7 +5322,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	*enable_wake = wufc || adapter->en_mng_pt;
 	if (!*enable_wake)
-		igb_shutdown_fiber_serdes_link_82575(hw);
+		igb_shutdown_serdes_link_82575(hw);
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */

