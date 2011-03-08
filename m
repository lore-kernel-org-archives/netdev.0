From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/14] ixgbe: Enable flow control pause parameter auto-negotiation support
Date: Mon,  7 Mar 2011 18:25:04 -0800
Message-ID: <1299551108-23663-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14586 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756004Ab1CHC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:07 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch enables flow control pause parameters auto-negotiation support
to 82599 based 10G Base-T, backplane devices and multi-speed fiber optics
modules at 1G speed

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |    7 +-
 drivers/net/ixgbe/ixgbe_82599.c  |    3 +
 drivers/net/ixgbe/ixgbe_common.c |  460 ++++++++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_main.c   |    3 +-
 drivers/net/ixgbe/ixgbe_phy.h    |    4 +
 drivers/net/ixgbe/ixgbe_type.h   |    3 +
 6 files changed, 281 insertions(+), 199 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index dc977b1..ff23907 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -366,7 +366,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 
 	/* Negotiate the fc mode to use */
 	ret_val = ixgbe_fc_autoneg(hw);
-	if (ret_val)
+	if (ret_val == IXGBE_ERR_FLOW_CONTROL)
 		goto out;
 
 	/* Disable any previous flow control settings */
@@ -384,10 +384,10 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *     we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
-	 * other: Invalid.
 #ifdef CONFIG_DCB
 	 * 4: Priority Flow Control is enabled.
 #endif
+	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
 	case ixgbe_fc_none:
@@ -444,9 +444,10 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 		reg = (rx_pba_size - hw->fc.low_water) << 6;
 		if (hw->fc.send_xon)
 			reg |= IXGBE_FCRTL_XONE;
+
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num), reg);
 
-		reg = (rx_pba_size - hw->fc.high_water) << 10;
+		reg = (rx_pba_size - hw->fc.high_water) << 6;
 		reg |= IXGBE_FCRTH_FCEN;
 
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num), reg);
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 2f8b9f4..00aeba3 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -772,6 +772,9 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 
 	/* Check to see if speed passed in is supported. */
 	hw->mac.ops.get_link_capabilities(hw, &link_capabilities, &autoneg);
+	if (status != 0)
+		goto out;
+
 	speed &= link_capabilities;
 
 	if (speed == IXGBE_LINK_SPEED_UNKNOWN) {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 561f666..7a6a3fb 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -47,6 +47,12 @@ static void ixgbe_lower_eeprom_clk(struct ixgbe_hw *hw, u32 *eec);
 static void ixgbe_release_eeprom(struct ixgbe_hw *hw);
 
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
+static s32 ixgbe_fc_autoneg_fiber(struct ixgbe_hw *hw);
+static s32 ixgbe_fc_autoneg_backplane(struct ixgbe_hw *hw);
+static s32 ixgbe_fc_autoneg_copper(struct ixgbe_hw *hw);
+static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
+static s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
+			      u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
 
 /**
@@ -1566,7 +1572,7 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 #endif /* CONFIG_DCB */
 	/* Negotiate the fc mode to use */
 	ret_val = ixgbe_fc_autoneg(hw);
-	if (ret_val)
+	if (ret_val == IXGBE_ERR_FLOW_CONTROL)
 		goto out;
 
 	/* Disable any previous flow control settings */
@@ -1674,12 +1680,13 @@ out:
  **/
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 {
-	s32 ret_val = 0;
+	s32 ret_val = IXGBE_ERR_FC_NOT_NEGOTIATED;
 	ixgbe_link_speed speed;
-	u32 pcs_anadv_reg, pcs_lpab_reg, linkstat;
-	u32 links2, anlp1_reg, autoc_reg, links;
 	bool link_up;
 
+	if (hw->fc.disable_fc_autoneg)
+		goto out;
+
 	/*
 	 * AN should have completed when the cable was plugged in.
 	 * Look for reasons to bail out.  Bail out if:
@@ -1690,153 +1697,199 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 	 * So use link_up_wait_to_complete=false.
 	 */
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-
-	if (hw->fc.disable_fc_autoneg || (!link_up)) {
-		hw->fc.fc_was_autonegged = false;
-		hw->fc.current_mode = hw->fc.requested_mode;
+	if (!link_up) {
+		ret_val = IXGBE_ERR_FLOW_CONTROL;
 		goto out;
 	}
 
-	/*
-	 * On backplane, bail out if
-	 * - backplane autoneg was not completed, or if
-	 * - we are 82599 and link partner is not AN enabled
-	 */
-	if (hw->phy.media_type == ixgbe_media_type_backplane) {
-		links = IXGBE_READ_REG(hw, IXGBE_LINKS);
-		if ((links & IXGBE_LINKS_KX_AN_COMP) == 0) {
-			hw->fc.fc_was_autonegged = false;
-			hw->fc.current_mode = hw->fc.requested_mode;
-			goto out;
-		}
+	switch (hw->phy.media_type) {
+	/* Autoneg flow control on fiber adapters */
+	case ixgbe_media_type_fiber:
+		if (speed == IXGBE_LINK_SPEED_1GB_FULL)
+			ret_val = ixgbe_fc_autoneg_fiber(hw);
+		break;
 
-		if (hw->mac.type == ixgbe_mac_82599EB) {
-			links2 = IXGBE_READ_REG(hw, IXGBE_LINKS2);
-			if ((links2 & IXGBE_LINKS2_AN_SUPPORTED) == 0) {
-				hw->fc.fc_was_autonegged = false;
-				hw->fc.current_mode = hw->fc.requested_mode;
-				goto out;
-			}
-		}
+	/* Autoneg flow control on backplane adapters */
+	case ixgbe_media_type_backplane:
+		ret_val = ixgbe_fc_autoneg_backplane(hw);
+		break;
+
+	/* Autoneg flow control on copper adapters */
+	case ixgbe_media_type_copper:
+		if (ixgbe_device_supports_autoneg_fc(hw) == 0)
+			ret_val = ixgbe_fc_autoneg_copper(hw);
+		break;
+
+	default:
+		break;
+	}
+
+out:
+	if (ret_val == 0) {
+		hw->fc.fc_was_autonegged = true;
+	} else {
+		hw->fc.fc_was_autonegged = false;
+		hw->fc.current_mode = hw->fc.requested_mode;
 	}
+	return ret_val;
+}
+
+/**
+ *  ixgbe_fc_autoneg_fiber - Enable flow control on 1 gig fiber
+ *  @hw: pointer to hardware structure
+ *
+ *  Enable flow control according on 1 gig fiber.
+ **/
+static s32 ixgbe_fc_autoneg_fiber(struct ixgbe_hw *hw)
+{
+	u32 pcs_anadv_reg, pcs_lpab_reg, linkstat;
+	s32 ret_val;
 
 	/*
 	 * On multispeed fiber at 1g, bail out if
 	 * - link is up but AN did not complete, or if
 	 * - link is up and AN completed but timed out
 	 */
-	if (hw->phy.multispeed_fiber && (speed == IXGBE_LINK_SPEED_1GB_FULL)) {
-		linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
-		if (((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
-		    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
-			hw->fc.fc_was_autonegged = false;
-			hw->fc.current_mode = hw->fc.requested_mode;
-			goto out;
-		}
+
+	linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
+	if (((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
+	    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
+		ret_val = IXGBE_ERR_FC_NOT_NEGOTIATED;
+		goto out;
 	}
 
+	pcs_anadv_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
+	pcs_lpab_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANLP);
+
+	ret_val =  ixgbe_negotiate_fc(hw, pcs_anadv_reg,
+			       pcs_lpab_reg, IXGBE_PCS1GANA_SYM_PAUSE,
+			       IXGBE_PCS1GANA_ASM_PAUSE,
+			       IXGBE_PCS1GANA_SYM_PAUSE,
+			       IXGBE_PCS1GANA_ASM_PAUSE);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_fc_autoneg_backplane - Enable flow control IEEE clause 37
+ *  @hw: pointer to hardware structure
+ *
+ *  Enable flow control according to IEEE clause 37.
+ **/
+static s32 ixgbe_fc_autoneg_backplane(struct ixgbe_hw *hw)
+{
+	u32 links2, anlp1_reg, autoc_reg, links;
+	s32 ret_val;
+
 	/*
-	 * Bail out on
-	 * - copper or CX4 adapters
-	 * - fiber adapters running at 10gig
+	 * On backplane, bail out if
+	 * - backplane autoneg was not completed, or if
+	 * - we are 82599 and link partner is not AN enabled
 	 */
-	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
-	     (hw->phy.media_type == ixgbe_media_type_cx4) ||
-	     ((hw->phy.media_type == ixgbe_media_type_fiber) &&
-	     (speed == IXGBE_LINK_SPEED_10GB_FULL))) {
+	links = IXGBE_READ_REG(hw, IXGBE_LINKS);
+	if ((links & IXGBE_LINKS_KX_AN_COMP) == 0) {
 		hw->fc.fc_was_autonegged = false;
 		hw->fc.current_mode = hw->fc.requested_mode;
+		ret_val = IXGBE_ERR_FC_NOT_NEGOTIATED;
 		goto out;
 	}
 
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		links2 = IXGBE_READ_REG(hw, IXGBE_LINKS2);
+		if ((links2 & IXGBE_LINKS2_AN_SUPPORTED) == 0) {
+			hw->fc.fc_was_autonegged = false;
+			hw->fc.current_mode = hw->fc.requested_mode;
+			ret_val = IXGBE_ERR_FC_NOT_NEGOTIATED;
+			goto out;
+		}
+	}
 	/*
-	 * Read the AN advertisement and LP ability registers and resolve
+	 * Read the 10g AN autoc and LP ability registers and resolve
 	 * local flow control settings accordingly
 	 */
-	if ((speed == IXGBE_LINK_SPEED_1GB_FULL) &&
-	    (hw->phy.media_type != ixgbe_media_type_backplane)) {
-		pcs_anadv_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
-		pcs_lpab_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANLP);
-		if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		    (pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE)) {
-			/*
-			 * Now we need to check if the user selected Rx ONLY
-			 * of pause frames.  In this case, we had to advertise
-			 * FULL flow control because we could not advertise RX
-			 * ONLY. Hence, we must now check to see if we need to
-			 * turn OFF the TRANSMISSION of PAUSE frames.
-			 */
-			if (hw->fc.requested_mode == ixgbe_fc_full) {
-				hw->fc.current_mode = ixgbe_fc_full;
-				hw_dbg(hw, "Flow Control = FULL.\n");
-			} else {
-				hw->fc.current_mode = ixgbe_fc_rx_pause;
-				hw_dbg(hw, "Flow Control=RX PAUSE only\n");
-			}
-		} else if (!(pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-			   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
-			   (pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-			   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
-			hw->fc.current_mode = ixgbe_fc_tx_pause;
-			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
-		} else if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-			   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
-			   !(pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-			   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
-			hw->fc.current_mode = ixgbe_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
-		} else {
-			hw->fc.current_mode = ixgbe_fc_none;
-			hw_dbg(hw, "Flow Control = NONE.\n");
-		}
-	}
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	anlp1_reg = IXGBE_READ_REG(hw, IXGBE_ANLP1);
 
-	if (hw->phy.media_type == ixgbe_media_type_backplane) {
+	ret_val = ixgbe_negotiate_fc(hw, autoc_reg,
+		anlp1_reg, IXGBE_AUTOC_SYM_PAUSE, IXGBE_AUTOC_ASM_PAUSE,
+		IXGBE_ANLP1_SYM_PAUSE, IXGBE_ANLP1_ASM_PAUSE);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_fc_autoneg_copper - Enable flow control IEEE clause 37
+ *  @hw: pointer to hardware structure
+ *
+ *  Enable flow control according to IEEE clause 37.
+ **/
+static s32 ixgbe_fc_autoneg_copper(struct ixgbe_hw *hw)
+{
+	u16 technology_ability_reg = 0;
+	u16 lp_technology_ability_reg = 0;
+
+	hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
+			     MDIO_MMD_AN,
+			     &technology_ability_reg);
+	hw->phy.ops.read_reg(hw, MDIO_AN_LPA,
+			     MDIO_MMD_AN,
+			     &lp_technology_ability_reg);
+
+	return ixgbe_negotiate_fc(hw, (u32)technology_ability_reg,
+				  (u32)lp_technology_ability_reg,
+				  IXGBE_TAF_SYM_PAUSE, IXGBE_TAF_ASM_PAUSE,
+				  IXGBE_TAF_SYM_PAUSE, IXGBE_TAF_ASM_PAUSE);
+}
+
+/**
+ *  ixgbe_negotiate_fc - Negotiate flow control
+ *  @hw: pointer to hardware structure
+ *  @adv_reg: flow control advertised settings
+ *  @lp_reg: link partner's flow control settings
+ *  @adv_sym: symmetric pause bit in advertisement
+ *  @adv_asm: asymmetric pause bit in advertisement
+ *  @lp_sym: symmetric pause bit in link partner advertisement
+ *  @lp_asm: asymmetric pause bit in link partner advertisement
+ *
+ *  Find the intersection between advertised settings and link partner's
+ *  advertised settings
+ **/
+static s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
+			      u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm)
+{
+	if ((!(adv_reg)) ||  (!(lp_reg)))
+		return IXGBE_ERR_FC_NOT_NEGOTIATED;
+
+	if ((adv_reg & adv_sym) && (lp_reg & lp_sym)) {
 		/*
-		 * Read the 10g AN autoc and LP ability registers and resolve
-		 * local flow control settings accordingly
+		 * Now we need to check if the user selected Rx ONLY
+		 * of pause frames.  In this case, we had to advertise
+		 * FULL flow control because we could not advertise RX
+		 * ONLY. Hence, we must now check to see if we need to
+		 * turn OFF the TRANSMISSION of PAUSE frames.
 		 */
-		autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-		anlp1_reg = IXGBE_READ_REG(hw, IXGBE_ANLP1);
-
-		if ((autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
-		    (anlp1_reg & IXGBE_ANLP1_SYM_PAUSE)) {
-			/*
-			 * Now we need to check if the user selected Rx ONLY
-			 * of pause frames.  In this case, we had to advertise
-			 * FULL flow control because we could not advertise RX
-			 * ONLY. Hence, we must now check to see if we need to
-			 * turn OFF the TRANSMISSION of PAUSE frames.
-			 */
-			if (hw->fc.requested_mode == ixgbe_fc_full) {
-				hw->fc.current_mode = ixgbe_fc_full;
-				hw_dbg(hw, "Flow Control = FULL.\n");
-			} else {
-				hw->fc.current_mode = ixgbe_fc_rx_pause;
-				hw_dbg(hw, "Flow Control=RX PAUSE only\n");
-			}
-		} else if (!(autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
-			   (autoc_reg & IXGBE_AUTOC_ASM_PAUSE) &&
-			   (anlp1_reg & IXGBE_ANLP1_SYM_PAUSE) &&
-			   (anlp1_reg & IXGBE_ANLP1_ASM_PAUSE)) {
-			hw->fc.current_mode = ixgbe_fc_tx_pause;
-			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
-		} else if ((autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
-			   (autoc_reg & IXGBE_AUTOC_ASM_PAUSE) &&
-			   !(anlp1_reg & IXGBE_ANLP1_SYM_PAUSE) &&
-			   (anlp1_reg & IXGBE_ANLP1_ASM_PAUSE)) {
-			hw->fc.current_mode = ixgbe_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
+		if (hw->fc.requested_mode == ixgbe_fc_full) {
+			hw->fc.current_mode = ixgbe_fc_full;
+			hw_dbg(hw, "Flow Control = FULL.\n");
 		} else {
-			hw->fc.current_mode = ixgbe_fc_none;
-			hw_dbg(hw, "Flow Control = NONE.\n");
+			hw->fc.current_mode = ixgbe_fc_rx_pause;
+			hw_dbg(hw, "Flow Control=RX PAUSE frames only\n");
 		}
+	} else if (!(adv_reg & adv_sym) && (adv_reg & adv_asm) &&
+		   (lp_reg & lp_sym) && (lp_reg & lp_asm)) {
+		hw->fc.current_mode = ixgbe_fc_tx_pause;
+		hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
+	} else if ((adv_reg & adv_sym) && (adv_reg & adv_asm) &&
+		   !(lp_reg & lp_sym) && (lp_reg & lp_asm)) {
+		hw->fc.current_mode = ixgbe_fc_rx_pause;
+		hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
+	} else {
+		hw->fc.current_mode = ixgbe_fc_none;
+		hw_dbg(hw, "Flow Control = NONE.\n");
 	}
-	/* Record that current_mode is the result of a successful autoneg */
-	hw->fc.fc_was_autonegged = true;
-
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1848,7 +1901,8 @@ out:
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 {
 	s32 ret_val = 0;
-	u32 reg;
+	u32 reg = 0, reg_bp = 0;
+	u16 reg_cu = 0;
 
 #ifdef CONFIG_DCB
 	if (hw->fc.requested_mode == ixgbe_fc_pfc) {
@@ -1856,7 +1910,7 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		goto out;
 	}
 
-#endif
+#endif /* CONFIG_DCB */
 	/* Validate the packetbuf configuration */
 	if (packetbuf_num < 0 || packetbuf_num > 7) {
 		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
@@ -1894,11 +1948,26 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		hw->fc.requested_mode = ixgbe_fc_full;
 
 	/*
-	 * Set up the 1G flow control advertisement registers so the HW will be
-	 * able to do fc autoneg once the cable is plugged in.  If we end up
-	 * using 10g instead, this is harmless.
+	 * Set up the 1G and 10G flow control advertisement registers so the
+	 * HW will be able to do fc autoneg once the cable is plugged in.  If
+	 * we link at 10G, the 1G advertisement is harmless and vice versa.
 	 */
-	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
+
+	switch (hw->phy.media_type) {
+	case ixgbe_media_type_fiber:
+	case ixgbe_media_type_backplane:
+		reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
+		reg_bp = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+		break;
+
+	case ixgbe_media_type_copper:
+		hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
+					MDIO_MMD_AN, &reg_cu);
+		break;
+
+	default:
+		;
+	}
 
 	/*
 	 * The possible values of fc.requested_mode are:
@@ -1917,6 +1986,11 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	case ixgbe_fc_none:
 		/* Flow control completely disabled by software override. */
 		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		if (hw->phy.media_type == ixgbe_media_type_backplane)
+			reg_bp &= ~(IXGBE_AUTOC_SYM_PAUSE |
+				    IXGBE_AUTOC_ASM_PAUSE);
+		else if (hw->phy.media_type == ixgbe_media_type_copper)
+			reg_cu &= ~(IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
 		break;
 	case ixgbe_fc_rx_pause:
 		/*
@@ -1928,6 +2002,11 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		 * disable the adapter's ability to send PAUSE frames.
 		 */
 		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		if (hw->phy.media_type == ixgbe_media_type_backplane)
+			reg_bp |= (IXGBE_AUTOC_SYM_PAUSE |
+				   IXGBE_AUTOC_ASM_PAUSE);
+		else if (hw->phy.media_type == ixgbe_media_type_copper)
+			reg_cu |= (IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
 		break;
 	case ixgbe_fc_tx_pause:
 		/*
@@ -1936,10 +2015,22 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		 */
 		reg |= (IXGBE_PCS1GANA_ASM_PAUSE);
 		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE);
+		if (hw->phy.media_type == ixgbe_media_type_backplane) {
+			reg_bp |= (IXGBE_AUTOC_ASM_PAUSE);
+			reg_bp &= ~(IXGBE_AUTOC_SYM_PAUSE);
+		} else if (hw->phy.media_type == ixgbe_media_type_copper) {
+			reg_cu |= (IXGBE_TAF_ASM_PAUSE);
+			reg_cu &= ~(IXGBE_TAF_SYM_PAUSE);
+		}
 		break;
 	case ixgbe_fc_full:
 		/* Flow control (both Rx and Tx) is enabled by SW override. */
 		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		if (hw->phy.media_type == ixgbe_media_type_backplane)
+			reg_bp |= (IXGBE_AUTOC_SYM_PAUSE |
+				   IXGBE_AUTOC_ASM_PAUSE);
+		else if (hw->phy.media_type == ixgbe_media_type_copper)
+			reg_cu |= (IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
 		break;
 #ifdef CONFIG_DCB
 	case ixgbe_fc_pfc:
@@ -1953,80 +2044,37 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		break;
 	}
 
-	IXGBE_WRITE_REG(hw, IXGBE_PCS1GANA, reg);
-	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLCTL);
-
-	/* Disable AN timeout */
-	if (hw->fc.strict_ieee)
-		reg &= ~IXGBE_PCS1GLCTL_AN_1G_TIMEOUT_EN;
+	if (hw->mac.type != ixgbe_mac_X540) {
+		/*
+		 * Enable auto-negotiation between the MAC & PHY;
+		 * the MAC will advertise clause 37 flow control.
+		 */
+		IXGBE_WRITE_REG(hw, IXGBE_PCS1GANA, reg);
+		reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLCTL);
 
-	IXGBE_WRITE_REG(hw, IXGBE_PCS1GLCTL, reg);
-	hw_dbg(hw, "Set up FC; PCS1GLCTL = 0x%08X\n", reg);
+		/* Disable AN timeout */
+		if (hw->fc.strict_ieee)
+			reg &= ~IXGBE_PCS1GLCTL_AN_1G_TIMEOUT_EN;
 
-	/*
-	 * Set up the 10G flow control advertisement registers so the HW
-	 * can do fc autoneg once the cable is plugged in.  If we end up
-	 * using 1g instead, this is harmless.
-	 */
-	reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+		IXGBE_WRITE_REG(hw, IXGBE_PCS1GLCTL, reg);
+		hw_dbg(hw, "Set up FC; PCS1GLCTL = 0x%08X\n", reg);
+	}
 
 	/*
-	 * The possible values of fc.requested_mode are:
-	 * 0: Flow control is completely disabled
-	 * 1: Rx flow control is enabled (we can receive pause frames,
-	 *    but not send pause frames).
-	 * 2: Tx flow control is enabled (we can send pause frames but
-	 *    we do not support receiving pause frames).
-	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
-	 * other: Invalid.
+	 * AUTOC restart handles negotiation of 1G and 10G on backplane
+	 * and copper. There is no need to set the PCS1GCTL register.
+	 *
 	 */
-	switch (hw->fc.requested_mode) {
-	case ixgbe_fc_none:
-		/* Flow control completely disabled by software override. */
-		reg &= ~(IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
-		break;
-	case ixgbe_fc_rx_pause:
-		/*
-		 * Rx Flow control is enabled and Tx Flow control is
-		 * disabled by software override. Since there really
-		 * isn't a way to advertise that we are capable of RX
-		 * Pause ONLY, we will advertise that we support both
-		 * symmetric and asymmetric Rx PAUSE.  Later, we will
-		 * disable the adapter's ability to send PAUSE frames.
-		 */
-		reg |= (IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
-		break;
-	case ixgbe_fc_tx_pause:
-		/*
-		 * Tx Flow control is enabled, and Rx Flow control is
-		 * disabled by software override.
-		 */
-		reg |= (IXGBE_AUTOC_ASM_PAUSE);
-		reg &= ~(IXGBE_AUTOC_SYM_PAUSE);
-		break;
-	case ixgbe_fc_full:
-		/* Flow control (both Rx and Tx) is enabled by SW override. */
-		reg |= (IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
-		break;
-#ifdef CONFIG_DCB
-	case ixgbe_fc_pfc:
-		goto out;
-		break;
-#endif /* CONFIG_DCB */
-	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = IXGBE_ERR_CONFIG;
-		goto out;
-		break;
+	if (hw->phy.media_type == ixgbe_media_type_backplane) {
+		reg_bp |= IXGBE_AUTOC_AN_RESTART;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg_bp);
+	} else if ((hw->phy.media_type == ixgbe_media_type_copper) &&
+		    (ixgbe_device_supports_autoneg_fc(hw) == 0)) {
+		hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE,
+				      MDIO_MMD_AN, reg_cu);
 	}
-	/*
-	 * AUTOC restart handles negotiation of 1G and 10G. There is
-	 * no need to set the PCS1GCTL register.
-	 */
-	reg |= IXGBE_AUTOC_AN_RESTART;
-	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg);
-	hw_dbg(hw, "Set up FC; IXGBE_AUTOC = 0x%08X\n", reg);
 
+	hw_dbg(hw, "Set up FC; IXGBE_AUTOC = 0x%08X\n", reg);
 out:
 	return ret_val;
 }
@@ -2751,6 +2799,28 @@ wwn_prefix_out:
 }
 
 /**
+ *  ixgbe_device_supports_autoneg_fc - Check if phy supports autoneg flow
+ *  control
+ *  @hw: pointer to hardware structure
+ *
+ *  There are several phys that do not support autoneg flow control. This
+ *  function check the device id to see if the associated phy supports
+ *  autoneg flow control.
+ **/
+static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
+{
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_X540T:
+		return 0;
+	case IXGBE_DEV_ID_82599_T3_LOM:
+		return 0;
+	default:
+		return IXGBE_ERR_FC_NOT_SUPPORTED;
+	}
+}
+
+/**
  *  ixgbe_set_mac_anti_spoofing - Enable/Disable MAC anti-spoofing
  *  @hw: pointer to hardware structure
  *  @enable: enable or disable switch for anti-spoofing
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5e8c39d..5998dc9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3775,7 +3775,8 @@ static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 	if (ret)
 		goto link_cfg_out;
 
-	if (hw->mac.ops.get_link_capabilities)
+	autoneg = hw->phy.autoneg_advertised;
+	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
 		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg,
 							&negotiation);
 	if (ret)
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 2327baf..9bf2783 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -58,6 +58,10 @@
 #define IXGBE_I2C_EEPROM_STATUS_FAIL         0x2
 #define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS  0x3
 
+/* Flow control defines */
+#define IXGBE_TAF_SYM_PAUSE                  0x400
+#define IXGBE_TAF_ASM_PAUSE                  0x800
+
 /* Bit-shift macros */
 #define IXGBE_SFF_VENDOR_OUI_BYTE0_SHIFT    24
 #define IXGBE_SFF_VENDOR_OUI_BYTE1_SHIFT    16
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 76bf21b..f190a4a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2698,6 +2698,9 @@ struct ixgbe_info {
 #define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_ERR_NO_SPACE                      -25
 #define IXGBE_ERR_OVERTEMP                      -26
+#define IXGBE_ERR_FC_NOT_NEGOTIATED             -27
+#define IXGBE_ERR_FC_NOT_SUPPORTED              -28
+#define IXGBE_ERR_FLOW_CONTROL                  -29
 #define IXGBE_ERR_SFP_SETUP_NOT_COMPLETE        -30
 #define IXGBE_ERR_PBA_SECTION                   -31
 #define IXGBE_ERR_INVALID_ARGUMENT              -32
-- 
1.7.4

