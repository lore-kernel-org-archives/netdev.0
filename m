From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/13] igb: cleanup flow control configuration to
	make requested/current more clear
Date: Thu, 23 Jul 2009 21:10:24 -0700
Message-ID: <20090724041023.30709.30186.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:48723
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751798AbZGXEKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:10:41 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up the flow control configuration for igb to make it a
bit more readable in regards to what the requested and current modes are.
This should help with the maintainability of the current igb driver in
regards to flow control.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_hw.h    |    6 ++---
 drivers/net/igb/e1000_mac.c   |   50 +++++++++++++++++++++++------------------
 drivers/net/igb/e1000_phy.c   |    4 ++-
 drivers/net/igb/igb_ethtool.c |   34 ++++++++++++++++------------
 drivers/net/igb/igb_main.c    |    6 ++---
 5 files changed, 55 insertions(+), 45 deletions(-)

diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 0469e2e..119869b 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -137,7 +137,7 @@ enum e1000_rev_polarity {
 	e1000_rev_polarity_undefined = 0xFF
 };
 
-enum e1000_fc_type {
+enum e1000_fc_mode {
 	e1000_fc_none = 0,
 	e1000_fc_rx_pause,
 	e1000_fc_tx_pause,
@@ -429,8 +429,8 @@ struct e1000_fc_info {
 	u16 pause_time;     /* Flow control pause timer */
 	bool send_xon;      /* Flow control send XON */
 	bool strict_ieee;   /* Strict IEEE mode */
-	enum e1000_fc_type type; /* Type of flow control */
-	enum e1000_fc_type original_type;
+	enum e1000_fc_mode current_mode; /* Type of flow control */
+	enum e1000_fc_mode requested_mode;
 };
 
 struct e1000_mbx_operations {
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index a1e3da7..a0231cd 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -536,18 +536,24 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	if (igb_check_reset_block(hw))
 		goto out;
 
-	ret_val = igb_set_default_fc(hw);
-	if (ret_val)
-		goto out;
+	/*
+	 * If requested flow control is set to default, set flow control
+	 * based on the EEPROM flow control settings.
+	 */
+	if (hw->fc.requested_mode == e1000_fc_default) {
+		ret_val = igb_set_default_fc(hw);
+		if (ret_val)
+			goto out;
+	}
 
 	/*
 	 * We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
 	 * hub or switch with different Flow Control capabilities.
 	 */
-	hw->fc.original_type = hw->fc.type;
+	hw->fc.current_mode = hw->fc.requested_mode;
 
-	hw_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.type);
+	hw_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = hw->mac.ops.setup_physical_interface(hw);
@@ -614,7 +620,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw)
 	 * ability to transmit pause frames is not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if (hw->fc.type & e1000_fc_tx_pause) {
+	if (hw->fc.current_mode & e1000_fc_tx_pause) {
 		/*
 		 * We need to set up the Receive Threshold high and low water
 		 * marks as well as (optionally) enabling the transmission of
@@ -661,12 +667,12 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
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
 
 out:
 	return ret_val;
@@ -696,7 +702,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 	 * receive flow control.
 	 *
 	 * The "Case" statement below enables/disable flow control
-	 * according to the "hw->fc.type" parameter.
+	 * according to the "hw->fc.current_mode" parameter.
 	 *
 	 * The possible values of the "fc" parameter are:
 	 *      0:  Flow control is completely disabled
@@ -707,9 +713,9 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg("hw->fc.type = %u\n", hw->fc.type);
+	hw_dbg("hw->fc.current_mode = %u\n", hw->fc.current_mode);
 
-	switch (hw->fc.type) {
+	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
 		ctrl &= (~(E1000_CTRL_TFCE | E1000_CTRL_RFCE));
 		break;
@@ -857,11 +863,11 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 * ONLY. Hence, we must now check to see if we need to
 			 * turn OFF  the TRANSMISSION of PAUSE frames.
 			 */
-			if (hw->fc.original_type == e1000_fc_full) {
-				hw->fc.type = e1000_fc_full;
+			if (hw->fc.requested_mode == e1000_fc_full) {
+				hw->fc.current_mode = e1000_fc_full;
 				hw_dbg("Flow Control = FULL.\r\n");
 			} else {
-				hw->fc.type = e1000_fc_rx_pause;
+				hw->fc.current_mode = e1000_fc_rx_pause;
 				hw_dbg("Flow Control = "
 				       "RX PAUSE frames only.\r\n");
 			}
@@ -878,7 +884,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			hw->fc.type = e1000_fc_tx_pause;
+			hw->fc.current_mode = e1000_fc_tx_pause;
 			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
 		}
 		/*
@@ -893,7 +899,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
-			hw->fc.type = e1000_fc_rx_pause;
+			hw->fc.current_mode = e1000_fc_rx_pause;
 			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 		/*
@@ -917,13 +923,13 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 * be asked to delay transmission of packets than asking
 		 * our link partner to pause transmission of frames.
 		 */
-		else if ((hw->fc.original_type == e1000_fc_none ||
-			  hw->fc.original_type == e1000_fc_tx_pause) ||
+		else if ((hw->fc.requested_mode == e1000_fc_none ||
+			  hw->fc.requested_mode == e1000_fc_tx_pause) ||
 			 hw->fc.strict_ieee) {
-			hw->fc.type = e1000_fc_none;
+			hw->fc.current_mode = e1000_fc_none;
 			hw_dbg("Flow Control = NONE.\r\n");
 		} else {
-			hw->fc.type = e1000_fc_rx_pause;
+			hw->fc.current_mode = e1000_fc_rx_pause;
 			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 
@@ -939,7 +945,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		}
 
 		if (duplex == HALF_DUPLEX)
-			hw->fc.type = e1000_fc_none;
+			hw->fc.current_mode = e1000_fc_none;
 
 		/*
 		 * Now we call a subroutine to actually force the MAC
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index f50fac2..c1f4da6 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -735,7 +735,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 	 *  other:  No software override.  The flow control configuration
 	 *          in the EEPROM is used.
 	 */
-	switch (hw->fc.type) {
+	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
 		/*
 		 * Flow control (RX & TX) is completely disabled by a
@@ -992,7 +992,7 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 	u32 ctrl;
 
 	/* Turn off flow control when forcing speed/duplex */
-	hw->fc.type = e1000_fc_none;
+	hw->fc.current_mode = e1000_fc_none;
 
 	/* Force speed/duplex on the mac */
 	ctrl = rd32(E1000_CTRL);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index df2d234..114ccab 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -194,6 +194,8 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 					     ADVERTISED_TP |
 					     ADVERTISED_Autoneg;
 		ecmd->advertising = hw->phy.autoneg_advertised;
+		if (adapter->fc_autoneg)
+			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		if (igb_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
@@ -221,11 +223,11 @@ static void igb_get_pauseparam(struct net_device *netdev,
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->fc.type == e1000_fc_rx_pause)
+	if (hw->fc.current_mode == e1000_fc_rx_pause)
 		pause->rx_pause = 1;
-	else if (hw->fc.type == e1000_fc_tx_pause)
+	else if (hw->fc.current_mode == e1000_fc_tx_pause)
 		pause->tx_pause = 1;
-	else if (hw->fc.type == e1000_fc_full) {
+	else if (hw->fc.current_mode == e1000_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -243,26 +245,28 @@ static int igb_set_pauseparam(struct net_device *netdev,
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
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
+		hw->fc.requested_mode = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
 			igb_down(adapter);
 			igb_up(adapter);
 		} else
 			igb_reset(adapter);
-	} else
+	} else {
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
 		retval = ((hw->phy.media_type == e1000_media_type_copper) ?
 			  igb_force_mac_fc(hw) : igb_setup_link(hw));
+	}
 
 	clear_bit(__IGB_RESETTING, &adapter->state);
 	return retval;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 12d8683..fb32735 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1130,7 +1130,7 @@ void igb_reset(struct igb_adapter *adapter)
 	}
 	fc->pause_time = 0xFFFF;
 	fc->send_xon = 1;
-	fc->type = fc->original_type;
+	fc->current_mode = fc->requested_mode;
 
 	/* disable receive for all VFs and wait one second */
 	if (adapter->vfs_allocated_count) {
@@ -1427,8 +1427,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	hw->mac.autoneg = true;
 	hw->phy.autoneg_advertised = 0x2f;
 
-	hw->fc.original_type = e1000_fc_default;
-	hw->fc.type = e1000_fc_default;
+	hw->fc.requested_mode = e1000_fc_default;
+	hw->fc.current_mode = e1000_fc_default;
 
 	adapter->itr_setting = IGB_DEFAULT_ITR;
 	adapter->itr = IGB_START_ITR;

