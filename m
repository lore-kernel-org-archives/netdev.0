From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/6] ixgbe: Fix 82599 adapter link flickering issues
Date: Thu, 04 Jun 2009 14:11:13 -0700
Message-ID: <20090604211113.5011.20701.stgit@localhost.localdomain>
References: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakakla@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:35604
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZFDVLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:11:33 -0400
In-Reply-To: <20090604210941.5011.31995.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Fix autoneg restart issues in flow control path which might create
endless link flickering due to known timing issues with 82599
adapters.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakakla@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c     |  115 ++++------------
 drivers/net/ixgbe/ixgbe_82599.c     |   13 +-
 drivers/net/ixgbe/ixgbe_common.c    |  245 ++++++++++++++++++-----------------
 drivers/net/ixgbe/ixgbe_common.h    |    4 -
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    2 
 drivers/net/ixgbe/ixgbe_ethtool.c   |   28 +++-
 drivers/net/ixgbe/ixgbe_main.c      |    6 -
 drivers/net/ixgbe/ixgbe_type.h      |    7 -
 8 files changed, 193 insertions(+), 227 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 88e8350..b992304 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -293,6 +293,17 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	u32 rmcs_reg;
 	u32 reg;
 
+#ifdef CONFIG_DCB
+	if (hw->fc.requested_mode == ixgbe_fc_pfc)
+		goto out;
+
+#endif /* CONFIG_DCB */
+	/* Negotiate the fc mode to use */
+	ret_val = ixgbe_fc_autoneg(hw);
+	if (ret_val)
+		goto out;
+
+	/* Disable any previous flow control settings */
 	fctrl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 	fctrl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
 
@@ -304,14 +315,20 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 0: Flow control is completely disabled
 	 * 1: Rx flow control is enabled (we can receive pause frames,
 	 *    but not send pause frames).
-	 * 2:  Tx flow control is enabled (we can send pause frames but
+	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *     we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
 	 * other: Invalid.
+#ifdef CONFIG_DCB
+	 * 4: Priority Flow Control is enabled.
+#endif
 	 */
 	switch (hw->fc.current_mode) {
 	case ixgbe_fc_none:
-		/* Flow control completely disabled by software override. */
+		/*
+		 * Flow control is disabled by software override or autoneg.
+		 * The code below will actually disable it in the HW.
+		 */
 		break;
 	case ixgbe_fc_rx_pause:
 		/*
@@ -336,6 +353,11 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 		fctrl_reg |= IXGBE_FCTRL_RFCE;
 		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
 		break;
+#ifdef CONFIG_DCB
+	case ixgbe_fc_pfc:
+		goto out;
+		break;
+#endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = -IXGBE_ERR_CONFIG;
@@ -343,7 +365,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 		break;
 	}
 
-	/* Enable 802.3x based flow control settings. */
+	/* Set 802.3x based flow control settings. */
 	fctrl_reg |= IXGBE_FCTRL_DPF;
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
@@ -377,79 +399,6 @@ out:
 }
 
 /**
- *  ixgbe_setup_fc_82598 - Configure flow control settings
- *  @hw: pointer to hardware structure
- *  @packetbuf_num: packet buffer number (0-7)
- *
- *  Configures the flow control settings based on SW configuration.  This
- *  function is used for 802.3x flow control configuration only.
- **/
-static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
-{
-	s32 ret_val = 0;
-	ixgbe_link_speed speed;
-	bool link_up;
-
-	/* Validate the packetbuf configuration */
-	if (packetbuf_num < 0 || packetbuf_num > 7) {
-		hw_dbg(hw, "Invalid packet buffer number [%d], expected range is"
-		          " 0-7\n", packetbuf_num);
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
-	}
-
-	/*
-	 * Validate the water mark configuration.  Zero water marks are invalid
-	 * because it causes the controller to just blast out fc packets.
-	 */
-	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		if (hw->fc.requested_mode != ixgbe_fc_none) {
-			hw_dbg(hw, "Invalid water mark configuration\n");
-			ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-			goto out;
-		}
-	}
-
-	/*
-	 * Validate the requested mode.  Strict IEEE mode does not allow
-	 * ixgbe_fc_rx_pause because it will cause testing anomalies.
-	 */
-	if (hw->fc.strict_ieee && hw->fc.requested_mode == ixgbe_fc_rx_pause) {
-		hw_dbg(hw, "ixgbe_fc_rx_pause not valid in strict IEEE mode\n");
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
-	}
-
-	/*
-	 * 10gig parts do not have a word in the EEPROM to determine the
-	 * default flow control setting, so we explicitly set it to full.
-	 */
-	if (hw->fc.requested_mode == ixgbe_fc_default)
-		hw->fc.requested_mode = ixgbe_fc_full;
-
-	/*
-	 * Save off the requested flow control mode for use later.  Depending
-	 * on the link partner's capabilities, we may or may not use this mode.
-	 */
-
-	hw->fc.current_mode = hw->fc.requested_mode;
-
-	/* Decide whether to use autoneg or not. */
-	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	if (!hw->fc.disable_fc_autoneg && hw->phy.multispeed_fiber &&
-	    (speed == IXGBE_LINK_SPEED_1GB_FULL))
-		ret_val = ixgbe_fc_autoneg(hw);
-
-	if (ret_val)
-		goto out;
-
-	ret_val = ixgbe_fc_enable_82598(hw, packetbuf_num);
-
-out:
-	return ret_val;
-}
-
-/**
  *  ixgbe_setup_mac_link_82598 - Configures MAC link settings
  *  @hw: pointer to hardware structure
  *
@@ -488,13 +437,6 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 		}
 	}
 
-	/*
-	 * We want to save off the original Flow Control configuration just in
-	 * case we get disconnected and then reconnected into a different hub
-	 * or switch with different Flow Control capabilities.
-	 */
-	ixgbe_setup_fc_82598(hw, 0);
-
 	/* Add delay to filter out noises during initial link setup */
 	msleep(50);
 
@@ -581,6 +523,11 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 	else
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 
+	/* if link is down, zero out the current_mode */
+	if (*link_up == false) {
+		hw->fc.current_mode = ixgbe_fc_none;
+		hw->fc.fc_was_autonegged = false;
+	}
 out:
 	return 0;
 }
@@ -1168,7 +1115,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.disable_mc		= &ixgbe_disable_mc_generic,
 	.clear_vfta		= &ixgbe_clear_vfta_82598,
 	.set_vfta		= &ixgbe_set_vfta_82598,
-	.setup_fc		= &ixgbe_setup_fc_82598,
+	.fc_enable		= &ixgbe_fc_enable_82598,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 84b83f7..4d83e59 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -413,9 +413,6 @@ s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
 		}
 	}
 
-	/* Set up flow control */
-	status = ixgbe_setup_fc_generic(hw, 0);
-
 	/* Add delay to filter out noises during initial link setup */
 	msleep(50);
 
@@ -641,6 +638,11 @@ s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 	else
 		*speed = IXGBE_LINK_SPEED_100_FULL;
 
+	/* if link is down, zero out the current_mode */
+	if (*link_up == false) {
+		hw->fc.current_mode = ixgbe_fc_none;
+		hw->fc.fc_was_autonegged = false;
+	}
 
 	return 0;
 }
@@ -747,9 +749,6 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 			}
 		}
 
-		/* Set up flow control */
-		status = ixgbe_setup_fc_generic(hw, 0);
-
 		/* Add delay to filter out noises during initial link setup */
 		msleep(50);
 	}
@@ -1509,7 +1508,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.disable_mc             = &ixgbe_disable_mc_generic,
 	.clear_vfta             = &ixgbe_clear_vfta_82599,
 	.set_vfta               = &ixgbe_set_vfta_82599,
-	.setup_fc               = &ixgbe_setup_fc_generic,
+	.fc_enable               = &ixgbe_fc_enable_generic,
 	.init_uta_tables        = &ixgbe_init_uta_tables_82599,
 	.setup_sfp              = &ixgbe_setup_sfp_modules_82599,
 };
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 4d36cd3..db339d6 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -85,6 +85,9 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* Setup flow control */
+	ixgbe_setup_fc(hw, 0);
+
 	/* Clear adapter stopped flag */
 	hw->adapter_stopped = false;
 
@@ -1577,17 +1580,16 @@ s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_fc_enable - Enable flow control
+ *  ixgbe_fc_enable_generic - Enable flow control
  *  @hw: pointer to hardware structure
  *  @packetbuf_num: packet buffer number (0-7)
  *
  *  Enable flow control according to the current settings.
  **/
-s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
+s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 {
 	s32 ret_val = 0;
-	u32 mflcn_reg;
-	u32 fccfg_reg;
+	u32 mflcn_reg, fccfg_reg;
 	u32 reg;
 	u32 rx_pba_size;
 
@@ -1596,7 +1598,12 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 		goto out;
 
 #endif /* CONFIG_DCB */
+	/* Negotiate the fc mode to use */
+	ret_val = ixgbe_fc_autoneg(hw);
+	if (ret_val)
+		goto out;
 
+	/* Disable any previous flow control settings */
 	mflcn_reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 	mflcn_reg &= ~(IXGBE_MFLCN_RFCE | IXGBE_MFLCN_RPFCE);
 
@@ -1616,7 +1623,10 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 */
 	switch (hw->fc.current_mode) {
 	case ixgbe_fc_none:
-		/* Flow control completely disabled by software override. */
+		/*
+		 * Flow control is disabled by software override or autoneg.
+		 * The code below will actually disable it in the HW.
+		 */
 		break;
 	case ixgbe_fc_rx_pause:
 		/*
@@ -1645,7 +1655,7 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	case ixgbe_fc_pfc:
 		goto out;
 		break;
-#endif
+#endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = -IXGBE_ERR_CONFIG;
@@ -1653,7 +1663,7 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 		break;
 	}
 
-	/* Enable 802.3x based flow control settings. */
+	/* Set 802.3x based flow control settings. */
 	mflcn_reg |= IXGBE_MFLCN_DPF;
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
@@ -1661,10 +1671,12 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	reg = IXGBE_READ_REG(hw, IXGBE_MTQC);
 	/* Thresholds are different for link flow control when in DCB mode */
 	if (reg & IXGBE_MTQC_RT_ENA) {
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
+
 		/* Always disable XON for LFC when in DCB mode */
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), 0);
+		reg = (rx_pba_size >> 5) & 0xFFE0;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), reg);
 
-		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
 		reg = (rx_pba_size >> 2) & 0xFFE0;
 		if (hw->fc.current_mode & ixgbe_fc_tx_pause)
 			reg |= IXGBE_FCRTH_FCEN;
@@ -1709,100 +1721,41 @@ out:
  *  ixgbe_fc_autoneg - Configure flow control
  *  @hw: pointer to hardware structure
  *
- *  Negotiates flow control capabilities with link partner using autoneg and
- *  applies the results.
+ *  Compares our advertised flow control capabilities to those advertised by
+ *  our link partner, and determines the proper flow control mode to use.
  **/
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
-	u32 i, reg, pcs_anadv_reg, pcs_lpab_reg;
-
-	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
+	ixgbe_link_speed speed;
+	u32 pcs_anadv_reg, pcs_lpab_reg, linkstat;
+	bool link_up;
 
 	/*
-	 * The possible values of fc.current_mode are:
-	 * 0:  Flow control is completely disabled
-	 * 1:  Rx flow control is enabled (we can receive pause frames,
-	 *     but not send pause frames).
-	 * 2:  Tx flow control is enabled (we can send pause frames but
-	 *     we do not support receiving pause frames).
-	 * 3:  Both Rx and Tx flow control (symmetric) are enabled.
-	 * 4:  Priority Flow Control is enabled.
-	 * other: Invalid.
+	 * AN should have completed when the cable was plugged in.
+	 * Look for reasons to bail out.  Bail out if:
+	 * - FC autoneg is disabled, or if
+	 * - we don't have multispeed fiber, or if
+	 * - we're not running at 1G, or if
+	 * - link is not up, or if
+	 * - link is up but AN did not complete, or if
+	 * - link is up and AN completed but timed out
+	 *
+	 * Since we're being called from an LSC, link is already know to be up.
+	 * So use link_up_wait_to_complete=false.
 	 */
-	switch (hw->fc.current_mode) {
-	case ixgbe_fc_none:
-		/* Flow control completely disabled by software override. */
-		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
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
-		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
-		break;
-	case ixgbe_fc_tx_pause:
-		/*
-		 * Tx Flow control is enabled, and Rx Flow control is
-		 * disabled by software override.
-		 */
-		reg |= (IXGBE_PCS1GANA_ASM_PAUSE);
-		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE);
-		break;
-	case ixgbe_fc_full:
-		/* Flow control (both Rx and Tx) is enabled by SW override. */
-		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
-		break;
-#ifdef CONFIG_DCB
-	case ixgbe_fc_pfc:
-		goto out;
-		break;
-#endif
-	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -IXGBE_ERR_CONFIG;
-		goto out;
-		break;
-	}
-
-	IXGBE_WRITE_REG(hw, IXGBE_PCS1GANA, reg);
-	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLCTL);
-
-	/* Set PCS register for autoneg */
-	/* Enable and restart autoneg */
-	reg |= IXGBE_PCS1GLCTL_AN_ENABLE | IXGBE_PCS1GLCTL_AN_RESTART;
-
-	/* Disable AN timeout */
-	if (hw->fc.strict_ieee)
-		reg &= ~IXGBE_PCS1GLCTL_AN_1G_TIMEOUT_EN;
-
-	hw_dbg(hw, "Configuring Autoneg; PCS_LCTL = 0x%08X\n", reg);
-	IXGBE_WRITE_REG(hw, IXGBE_PCS1GLCTL, reg);
-
-	/* See if autonegotiation has succeeded */
-	hw->mac.autoneg_succeeded = 0;
-	for (i = 0; i < FIBER_LINK_UP_LIMIT; i++) {
-		msleep(10);
-		reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
-		if ((reg & (IXGBE_PCS1GLSTA_LINK_OK |
-		     IXGBE_PCS1GLSTA_AN_COMPLETE)) ==
-		    (IXGBE_PCS1GLSTA_LINK_OK |
-		     IXGBE_PCS1GLSTA_AN_COMPLETE)) {
-			if (!(reg & IXGBE_PCS1GLSTA_AN_TIMED_OUT))
-				hw->mac.autoneg_succeeded = 1;
-			break;
-		}
-	}
-
-	if (!hw->mac.autoneg_succeeded) {
-		/* Autoneg failed to achieve a link, so we turn fc off */
-		hw->fc.current_mode = ixgbe_fc_none;
-		hw_dbg(hw, "Flow Control = NONE.\n");
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+	linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
+
+	if (hw->fc.disable_fc_autoneg ||
+	    !hw->phy.multispeed_fiber ||
+	    (speed != IXGBE_LINK_SPEED_1GB_FULL) ||
+	    !link_up ||
+	    ((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
+	    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
+		hw->fc.fc_was_autonegged = false;
+		hw->fc.current_mode = hw->fc.requested_mode;
+		hw_dbg(hw, "Autoneg FC was skipped.\n");
 		goto out;
 	}
 
@@ -1845,21 +1798,23 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Flow Control = NONE.\n");
 	}
 
+	/* Record that current_mode is the result of a successful autoneg */
+	hw->fc.fc_was_autonegged = true;
+
 out:
 	return ret_val;
 }
 
 /**
- *  ixgbe_setup_fc_generic - Set up flow control
+ *  ixgbe_setup_fc - Set up flow control
  *  @hw: pointer to hardware structure
  *
- *  Sets up flow control.
+ *  Called at init time to set up flow control.
  **/
-s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
+s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 {
 	s32 ret_val = 0;
-	ixgbe_link_speed speed;
-	bool link_up;
+	u32 reg;
 
 #ifdef CONFIG_DCB
 	if (hw->fc.requested_mode == ixgbe_fc_pfc) {
@@ -1881,16 +1836,14 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * because it causes the controller to just blast out fc packets.
 	 */
 	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		if (hw->fc.requested_mode != ixgbe_fc_none) {
-			hw_dbg(hw, "Invalid water mark configuration\n");
-			ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-			goto out;
-		}
+		hw_dbg(hw, "Invalid water mark configuration\n");
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+		goto out;
 	}
 
 	/*
 	 * Validate the requested mode.  Strict IEEE mode does not allow
-	 * ixgbe_fc_rx_pause because it will cause testing anomalies.
+	 * ixgbe_fc_rx_pause because it will cause us to fail at UNH.
 	 */
 	if (hw->fc.strict_ieee && hw->fc.requested_mode == ixgbe_fc_rx_pause) {
 		hw_dbg(hw, "ixgbe_fc_rx_pause not valid in strict "
@@ -1907,21 +1860,77 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 		hw->fc.requested_mode = ixgbe_fc_full;
 
 	/*
-	 * Save off the requested flow control mode for use later.  Depending
-	 * on the link partner's capabilities, we may or may not use this mode.
+	 * Set up the 1G flow control advertisement registers so the HW will be
+	 * able to do fc autoneg once the cable is plugged in.  If we end up
+	 * using 10g instead, this is harmless.
 	 */
-	hw->fc.current_mode = hw->fc.requested_mode;
-
-	/* Decide whether to use autoneg or not. */
-	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	if (!hw->fc.disable_fc_autoneg && hw->phy.multispeed_fiber &&
-	    (speed == IXGBE_LINK_SPEED_1GB_FULL))
-		ret_val = ixgbe_fc_autoneg(hw);
+	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
 
-	if (ret_val)
+	/*
+	 * The possible values of fc.requested_mode are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames,
+	 *    but not send pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but
+	 *    we do not support receiving pause frames).
+	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+#ifdef CONFIG_DCB
+	 * 4: Priority Flow Control is enabled.
+#endif
+	 * other: Invalid.
+	 */
+	switch (hw->fc.requested_mode) {
+	case ixgbe_fc_none:
+		/* Flow control completely disabled by software override. */
+		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is
+		 * disabled by software override. Since there really
+		 * isn't a way to advertise that we are capable of RX
+		 * Pause ONLY, we will advertise that we support both
+		 * symmetric and asymmetric Rx PAUSE.  Later, we will
+		 * disable the adapter's ability to send PAUSE frames.
+		 */
+		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
+		 * disabled by software override.
+		 */
+		reg |= (IXGBE_PCS1GANA_ASM_PAUSE);
+		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE);
+		break;
+	case ixgbe_fc_full:
+		/* Flow control (both Rx and Tx) is enabled by SW override. */
+		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		break;
+#ifdef CONFIG_DCB
+	case ixgbe_fc_pfc:
 		goto out;
+		break;
+#endif /* CONFIG_DCB */
+	default:
+		hw_dbg(hw, "Flow control param set incorrectly\n");
+		ret_val = -IXGBE_ERR_CONFIG;
+		goto out;
+		break;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_PCS1GANA, reg);
+	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLCTL);
 
-	ret_val = ixgbe_fc_enable(hw, packetbuf_num);
+	/* Enable and restart autoneg to inform the link partner */
+	reg |= IXGBE_PCS1GLCTL_AN_ENABLE | IXGBE_PCS1GLCTL_AN_RESTART;
+
+	/* Disable AN timeout */
+	if (hw->fc.strict_ieee)
+		reg &= ~IXGBE_PCS1GLCTL_AN_1G_TIMEOUT_EN;
+
+	IXGBE_WRITE_REG(hw, IXGBE_PCS1GLCTL, reg);
+	hw_dbg(hw, "Set up FC; PCS1GLCTL = 0x%08X\n", reg);
 
 out:
 	return ret_val;
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index b2a4b2c..0d34d4d 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -64,8 +64,8 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
-s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num);
-s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packtetbuf_num);
+s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
+s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packtetbuf_num);
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index f4417fc..589f62c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -295,7 +295,7 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 	/* If PFC is disabled globally then fall back to LFC. */
 	if (!dcb_config->pfc_mode_enable) {
 		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-			hw->mac.ops.setup_fc(hw, i);
+			hw->mac.ops.fc_enable(hw, i);
 		goto out;
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 583cc5a..1c11045 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -283,6 +283,7 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_fc_info fc;
 
 #ifdef CONFIG_DCB
 	if (adapter->dcb_cfg.pfc_mode_enable ||
@@ -291,26 +292,37 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 		return -EINVAL;
 
 #endif
+
+	fc = hw->fc;
+
 	if (pause->autoneg != AUTONEG_ENABLE)
-		hw->fc.disable_fc_autoneg = true;
+		fc.disable_fc_autoneg = true;
 	else
-		hw->fc.disable_fc_autoneg = false;
+		fc.disable_fc_autoneg = false;
 
 	if (pause->rx_pause && pause->tx_pause)
-		hw->fc.requested_mode = ixgbe_fc_full;
+		fc.requested_mode = ixgbe_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
-		hw->fc.requested_mode = ixgbe_fc_rx_pause;
+		fc.requested_mode = ixgbe_fc_rx_pause;
 	else if (!pause->rx_pause && pause->tx_pause)
-		hw->fc.requested_mode = ixgbe_fc_tx_pause;
+		fc.requested_mode = ixgbe_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->fc.requested_mode = ixgbe_fc_none;
+		fc.requested_mode = ixgbe_fc_none;
 	else
 		return -EINVAL;
 
 #ifdef CONFIG_DCB
-	adapter->last_lfc_mode = hw->fc.requested_mode;
+	adapter->last_lfc_mode = fc.requested_mode;
 #endif
-	hw->mac.ops.setup_fc(hw, 0);
+
+	/* if the thing changed then we'll update and use new autoneg */
+	if (memcmp(&fc, &hw->fc, sizeof(struct ixgbe_fc_info))) {
+		hw->fc = fc;
+		if (netif_running(netdev))
+			ixgbe_reinit_locked(adapter);
+		else
+			ixgbe_reset(adapter);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0a3e8a3..9684632 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4344,12 +4344,12 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 #ifdef CONFIG_DCB
 			if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 				for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-					hw->mac.ops.setup_fc(hw, i);
+					hw->mac.ops.fc_enable(hw, i);
 			} else {
-				hw->mac.ops.setup_fc(hw, 0);
+				hw->mac.ops.fc_enable(hw, 0);
 			}
 #else
-			hw->mac.ops.setup_fc(hw, 0);
+			hw->mac.ops.fc_enable(hw, 0);
 #endif
 		}
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 199b288..4402552 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1368,8 +1368,6 @@
 #define IXGBE_LINK_UP_TIME      90 /* 9.0 Seconds */
 #define IXGBE_AUTO_NEG_TIME     45 /* 4.5 Seconds */
 
-#define FIBER_LINK_UP_LIMIT     50
-
 /* PCS1GLSTA Bit Masks */
 #define IXGBE_PCS1GLSTA_LINK_OK         1
 #define IXGBE_PCS1GLSTA_SYNK_OK         0x10
@@ -2094,7 +2092,8 @@ struct ixgbe_fc_info {
 	u16 pause_time; /* Flow Control Pause timer */
 	bool send_xon; /* Flow control send XON */
 	bool strict_ieee; /* Strict IEEE mode */
-	bool disable_fc_autoneg; /* Turn off autoneg FC mode */
+	bool disable_fc_autoneg; /* Do not autonegotiate FC */
+	bool fc_was_autonegged; /* Is current_mode the result of autonegging? */
 	enum ixgbe_fc_mode current_mode; /* FC mode in effect */
 	enum ixgbe_fc_mode requested_mode; /* FC mode requested by caller */
 };
@@ -2236,7 +2235,7 @@ struct ixgbe_mac_operations {
 	s32 (*init_uta_tables)(struct ixgbe_hw *);
 
 	/* Flow Control */
-	s32 (*setup_fc)(struct ixgbe_hw *, s32);
+	s32 (*fc_enable)(struct ixgbe_hw *, s32);
 };
 
 struct ixgbe_phy_operations {

