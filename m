From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 10/14] e1000e: sync change flow control variables
	with ixgbe
Date: Fri, 21 Nov 2008 11:01:46 -0800
Message-ID: <20081121190146.32313.62142.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:45804 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754216AbYKUTCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:02:19 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Sync flow control variables and usage model with that found in the ixgbe
driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    4 ++--
 drivers/net/e1000e/ethtool.c |   32 +++++++++++++++--------------
 drivers/net/e1000e/hw.h      |    6 +++--
 drivers/net/e1000e/ich8lan.c |   13 ++++++++----
 drivers/net/e1000e/lib.c     |   46 +++++++++++++++++++++---------------------
 drivers/net/e1000e/netdev.c  |    6 +++--
 drivers/net/e1000e/phy.c     |    4 ++--
 7 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 11e72b6..60c15cb 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1118,8 +1118,8 @@ static s32 e1000_setup_link_82571(struct e1000_hw *hw)
 	 * set it to full.
 	 */
 	if ((hw->mac.type == e1000_82573 || hw->mac.type == e1000_82574) &&
-	    hw->fc.type == e1000_fc_default)
-		hw->fc.type = e1000_fc_full;
+	    hw->fc.requested_mode == e1000_fc_default)
+		hw->fc.requested_mode = e1000_fc_full;
 
 	return e1000e_setup_link(hw);
 }
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 62421ce..875d769 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -249,7 +249,7 @@ static int e1000_set_settings(struct net_device *netdev,
 						     ADVERTISED_Autoneg;
 		ecmd->advertising = hw->phy.autoneg_advertised;
 		if (adapter->fc_autoneg)
-			hw->fc.original_type = e1000_fc_default;
+			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->state);
@@ -279,11 +279,11 @@ static void e1000_get_pauseparam(struct net_device *netdev,
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->fc.type == e1000_fc_rx_pause) {
+	if (hw->fc.current_mode == e1000_fc_rx_pause) {
 		pause->rx_pause = 1;
-	} else if (hw->fc.type == e1000_fc_tx_pause) {
+	} else if (hw->fc.current_mode == e1000_fc_tx_pause) {
 		pause->tx_pause = 1;
-	} else if (hw->fc.type == e1000_fc_full) {
+	} else if (hw->fc.current_mode == e1000_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -301,19 +301,8 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
 
-	if (pause->rx_pause && pause->tx_pause)
-		hw->fc.type = e1000_fc_full;
-	else if (pause->rx_pause && !pause->tx_pause)
-		hw->fc.type = e1000_fc_rx_pause;
-	else if (!pause->rx_pause && pause->tx_pause)
-		hw->fc.type = e1000_fc_tx_pause;
-	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->fc.type = e1000_fc_none;
-
-	hw->fc.original_type = hw->fc.type;
-
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
-		hw->fc.type = e1000_fc_default;
+		hw->fc.requested_mode = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
 			e1000e_down(adapter);
 			e1000e_up(adapter);
@@ -321,6 +310,17 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 			e1000e_reset(adapter);
 		}
 	} else {
+		if (pause->rx_pause && pause->tx_pause)
+			hw->fc.requested_mode = e1000_fc_full;
+		else if (pause->rx_pause && !pause->tx_pause)
+			hw->fc.requested_mode = e1000_fc_rx_pause;
+		else if (!pause->rx_pause && pause->tx_pause)
+			hw->fc.requested_mode = e1000_fc_tx_pause;
+		else if (!pause->rx_pause && !pause->tx_pause)
+			hw->fc.requested_mode = e1000_fc_none;
+
+		hw->fc.current_mode = hw->fc.requested_mode;
+
 		retval = ((hw->phy.media_type == e1000_media_type_fiber) ?
 			  hw->mac.ops.setup_link(hw) : e1000e_force_mac_fc(hw));
 	}
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index ac1efb9..f25e961 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -437,7 +437,7 @@ enum e1000_rev_polarity{
 	e1000_rev_polarity_undefined = 0xFF
 };
 
-enum e1000_fc_type {
+enum e1000_fc_mode {
 	e1000_fc_none = 0,
 	e1000_fc_rx_pause,
 	e1000_fc_tx_pause,
@@ -850,8 +850,8 @@ struct e1000_fc_info {
 	u16 pause_time;          /* Flow control pause timer */
 	bool send_xon;           /* Flow control send XON */
 	bool strict_ieee;        /* Strict IEEE mode */
-	enum e1000_fc_type type; /* Type of flow control */
-	enum e1000_fc_type original_type;
+	enum e1000_fc_mode current_mode; /* FC mode in effect */
+	enum e1000_fc_mode requested_mode; /* FC mode requested by caller */
 };
 
 struct e1000_dev_spec_82571 {
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 11f0dd3..5d85f5b 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2071,12 +2071,17 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
-	if (hw->fc.type == e1000_fc_default)
-		hw->fc.type = e1000_fc_full;
+	if (hw->fc.requested_mode == e1000_fc_default)
+		hw->fc.requested_mode = e1000_fc_full;
 
-	hw->fc.original_type = hw->fc.type;
+	/*
+	 * Save off the requested flow control mode for use later.  Depending
+	 * on the link partner's capabilities, we may or may not use this mode.
+	 */
+	hw->fc.current_mode = hw->fc.requested_mode;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
+	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n",
+		hw->fc.current_mode);
 
 	/* Continue to configure the copper link. */
 	ret_val = e1000_setup_copper_link_ich8lan(hw);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 37753d1..6674110 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -645,12 +645,12 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	}
 
 	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
-		hw->fc.type = e1000_fc_none;
+		hw->fc.requested_mode = e1000_fc_none;
 	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) ==
 		 NVM_WORD0F_ASM_DIR)
-		hw->fc.type = e1000_fc_tx_pause;
+		hw->fc.requested_mode = e1000_fc_tx_pause;
 	else
-		hw->fc.type = e1000_fc_full;
+		hw->fc.requested_mode = e1000_fc_full;
 
 	return 0;
 }
@@ -678,23 +678,23 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 		return 0;
 
 	/*
-	 * If flow control is set to default, set flow control based on
-	 * the EEPROM flow control settings.
+	 * If requested flow control is set to default, set flow control
+	 * based on the EEPROM flow control settings.
 	 */
-	if (hw->fc.type == e1000_fc_default) {
+	if (hw->fc.requested_mode == e1000_fc_default) {
 		ret_val = e1000_set_default_fc_generic(hw);
 		if (ret_val)
 			return ret_val;
 	}
 
 	/*
-	 * We want to save off the original Flow Control configuration just
-	 * in case we get disconnected and then reconnected into a different
-	 * hub or switch with different Flow Control capabilities.
+	 * Save off the requested flow control mode for use later.  Depending
+	 * on the link partner's capabilities, we may or may not use this mode.
 	 */
-	hw->fc.original_type = hw->fc.type;
+	hw->fc.current_mode = hw->fc.requested_mode;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
+	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n",
+		hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = mac->ops.setup_physical_interface(hw);
@@ -746,7 +746,7 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	 *	  do not support receiving pause frames).
 	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
 	 */
-	switch (hw->fc.type) {
+	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
 		/* Flow control completely disabled by a software over-ride. */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD);
@@ -928,7 +928,7 @@ s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
 	 * ability to transmit pause frames is not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if (hw->fc.type & e1000_fc_tx_pause) {
+	if (hw->fc.current_mode & e1000_fc_tx_pause) {
 		/*
 		 * We need to set up the Receive Threshold high and low water
 		 * marks as well as (optionally) enabling the transmission of
@@ -967,7 +967,7 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 	 * receive flow control.
 	 *
 	 * The "Case" statement below enables/disable flow control
-	 * according to the "hw->fc.type" parameter.
+	 * according to the "hw->fc.current_mode" parameter.
 	 *
 	 * The possible values of the "fc" parameter are:
 	 *      0:  Flow control is completely disabled
@@ -978,9 +978,9 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and Tx flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg(hw, "hw->fc.type = %u\n", hw->fc.type);
+	hw_dbg(hw, "hw->fc.current_mode = %u\n", hw->fc.current_mode);
 
-	switch (hw->fc.type) {
+	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
 		ctrl &= (~(E1000_CTRL_TFCE | E1000_CTRL_RFCE));
 		break;
@@ -1124,11 +1124,11 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 * ONLY. Hence, we must now check to see if we need to
 			 * turn OFF  the TRANSMISSION of PAUSE frames.
 			 */
-			if (hw->fc.original_type == e1000_fc_full) {
-				hw->fc.type = e1000_fc_full;
+			if (hw->fc.requested_mode == e1000_fc_full) {
+				hw->fc.current_mode = e1000_fc_full;
 				hw_dbg(hw, "Flow Control = FULL.\r\n");
 			} else {
-				hw->fc.type = e1000_fc_rx_pause;
+				hw->fc.current_mode = e1000_fc_rx_pause;
 				hw_dbg(hw, "Flow Control = "
 					 "RX PAUSE frames only.\r\n");
 			}
@@ -1146,7 +1146,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			hw->fc.type = e1000_fc_tx_pause;
+			hw->fc.current_mode = e1000_fc_tx_pause;
 			hw_dbg(hw, "Flow Control = Tx PAUSE frames only.\r\n");
 		}
 		/*
@@ -1162,14 +1162,14 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			hw->fc.type = e1000_fc_rx_pause;
+			hw->fc.current_mode = e1000_fc_rx_pause;
 			hw_dbg(hw, "Flow Control = Rx PAUSE frames only.\r\n");
 		} else {
 			/*
 			 * Per the IEEE spec, at this point flow control
 			 * should be disabled.
 			 */
-			hw->fc.type = e1000_fc_none;
+			hw->fc.current_mode = e1000_fc_none;
 			hw_dbg(hw, "Flow Control = NONE.\r\n");
 		}
 
@@ -1185,7 +1185,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		}
 
 		if (duplex == HALF_DUPLEX)
-			hw->fc.type = e1000_fc_none;
+			hw->fc.current_mode = e1000_fc_none;
 
 		/*
 		 * Now we call a subroutine to actually force the MAC
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index cd6d132..f10252b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2785,7 +2785,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	else
 		fc->pause_time = E1000_FC_PAUSE_TIME;
 	fc->send_xon = 1;
-	fc->type = fc->original_type;
+	fc->current_mode = fc->requested_mode;
 
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
@@ -4983,8 +4983,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
 	adapter->fc_autoneg = 1;
-	adapter->hw.fc.original_type = e1000_fc_default;
-	adapter->hw.fc.type = e1000_fc_default;
+	adapter->hw.fc.requested_mode = e1000_fc_default;
+	adapter->hw.fc.current_mode = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
 
 	/* ring size defaults */
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index d3aa6b7..85f8a74 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -746,7 +746,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	 *  other:  No software override.  The flow control configuration
 	 *	  in the EEPROM is used.
 	 */
-	switch (hw->fc.type) {
+	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
 		/*
 		 * Flow control (Rx & Tx) is completely disabled by a
@@ -1116,7 +1116,7 @@ void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 	u32 ctrl;
 
 	/* Turn off flow control when forcing speed/duplex */
-	hw->fc.type = e1000_fc_none;
+	hw->fc.current_mode = e1000_fc_none;
 
 	/* Force speed/duplex on the mac */
 	ctrl = er32(CTRL);

