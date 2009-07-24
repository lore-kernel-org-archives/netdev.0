From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/13] igb: remove media type fiber as it is
	misleading
Date: Thu, 23 Jul 2009 21:07:20 -0700
Message-ID: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:34998 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbZGXEHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current igb driver only supports copper and serdes.  The fiber media
type is a holdover from earlier NICs as the current nics supported by igb
all use serdes when communicating over a fiber connection.  As a result we
can remove media type fiber without losing any functionality.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    3 +--
 drivers/net/igb/e1000_hw.h    |    3 +--
 drivers/net/igb/e1000_mac.c   |   37 +++++++++++--------------------------
 drivers/net/igb/igb_ethtool.c |   25 +++++++++----------------
 drivers/net/igb/igb_main.c    |   12 ------------
 5 files changed, 22 insertions(+), 58 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index ac28dd5..bd3efdb 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -867,8 +867,7 @@ void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
 	u32 reg;
 
 	if (hw->mac.type != e1000_82576 ||
-	    (hw->phy.media_type != e1000_media_type_fiber &&
-	     hw->phy.media_type != e1000_media_type_internal_serdes))
+	    hw->phy.media_type != e1000_media_type_internal_serdes)
 		return;
 
 	/* if the management interface is not enabled, then power down */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 68aac20..f096ddd 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -61,8 +61,7 @@ enum e1000_mac_type {
 enum e1000_media_type {
 	e1000_media_type_unknown = 0,
 	e1000_media_type_copper = 1,
-	e1000_media_type_fiber = 2,
-	e1000_media_type_internal_serdes = 3,
+	e1000_media_type_internal_serdes = 2,
 	e1000_num_media_types
 };
 
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 472f3f1..37706d9 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -713,8 +713,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 	 * configuration of the MAC to match the "fc" parameter.
 	 */
 	if (mac->autoneg_failed) {
-		if (hw->phy.media_type == e1000_media_type_fiber ||
-		    hw->phy.media_type == e1000_media_type_internal_serdes)
+		if (hw->phy.media_type == e1000_media_type_internal_serdes)
 			ret_val = igb_force_mac_fc(hw);
 	} else {
 		if (hw->phy.media_type == e1000_media_type_copper)
@@ -1161,22 +1160,16 @@ s32 igb_blink_led(struct e1000_hw *hw)
 	u32 ledctl_blink = 0;
 	u32 i;
 
-	if (hw->phy.media_type == e1000_media_type_fiber) {
-		/* always blink LED0 for PCI-E fiber */
-		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
-		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
-	} else {
-		/*
-		 * set the blink bit for each LED that's "on" (0x0E)
-		 * in ledctl_mode2
-		 */
-		ledctl_blink = hw->mac.ledctl_mode2;
-		for (i = 0; i < 4; i++)
-			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
-			    E1000_LEDCTL_MODE_LED_ON)
-				ledctl_blink |= (E1000_LEDCTL_LED0_BLINK <<
-						 (i * 8));
-	}
+	/*
+	 * set the blink bit for each LED that's "on" (0x0E)
+	 * in ledctl_mode2
+	 */
+	ledctl_blink = hw->mac.ledctl_mode2;
+	for (i = 0; i < 4; i++)
+		if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
+		    E1000_LEDCTL_MODE_LED_ON)
+			ledctl_blink |= (E1000_LEDCTL_LED0_BLINK <<
+					 (i * 8));
 
 	wr32(E1000_LEDCTL, ledctl_blink);
 
@@ -1191,15 +1184,7 @@ s32 igb_blink_led(struct e1000_hw *hw)
  **/
 s32 igb_led_off(struct e1000_hw *hw)
 {
-	u32 ctrl;
-
 	switch (hw->phy.media_type) {
-	case e1000_media_type_fiber:
-		ctrl = rd32(E1000_CTRL);
-		ctrl |= E1000_CTRL_SWDPIN0;
-		ctrl |= E1000_CTRL_SWDPIO0;
-		wr32(E1000_CTRL, ctrl);
-		break;
 	case e1000_media_type_copper:
 		wr32(E1000_LEDCTL, hw->mac.ledctl_mode1);
 		break;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 9598ac0..a9c37cb 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -168,8 +168,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
-			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	ecmd->autoneg = hw->mac.autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -191,23 +190,18 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
-		if (hw->phy.media_type == e1000_media_type_fiber)
-			hw->phy.autoneg_advertised = ADVERTISED_1000baseT_Full |
-						     ADVERTISED_FIBRE |
-						     ADVERTISED_Autoneg;
-		else
-			hw->phy.autoneg_advertised = ecmd->advertising |
-						     ADVERTISED_TP |
-						     ADVERTISED_Autoneg;
+		hw->phy.autoneg_advertised = ecmd->advertising |
+					     ADVERTISED_TP |
+					     ADVERTISED_Autoneg;
 		ecmd->advertising = hw->phy.autoneg_advertised;
-	} else
+	} else {
 		if (igb_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
+	}
 
 	/* reset the link */
-
 	if (netif_running(adapter->netdev)) {
 		igb_down(adapter);
 		igb_up(adapter);
@@ -267,8 +261,8 @@ static int igb_set_pauseparam(struct net_device *netdev,
 		} else
 			igb_reset(adapter);
 	} else
-		retval = ((hw->phy.media_type == e1000_media_type_fiber) ?
-			  igb_setup_link(hw) : igb_force_mac_fc(hw));
+		retval = ((hw->phy.media_type == e1000_media_type_copper) ?
+			  igb_force_mac_fc(hw) : igb_setup_link(hw));
 
 	clear_bit(__IGB_RESETTING, &adapter->state);
 	return retval;
@@ -1483,8 +1477,7 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 reg;
 
-	if (hw->phy.media_type == e1000_media_type_fiber ||
-	    hw->phy.media_type == e1000_media_type_internal_serdes) {
+	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
 		reg = rd32(E1000_RCTL);
 		reg |= E1000_RCTL_LBM_TCVR;
 		wr32(E1000_RCTL, reg);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..39b3b6a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2618,10 +2618,6 @@ static bool igb_has_link(struct igb_adapter *adapter)
 			link_active = true;
 		}
 		break;
-	case e1000_media_type_fiber:
-		ret_val = hw->mac.ops.check_for_link(hw);
-		link_active = !!(rd32(E1000_STATUS) & E1000_STATUS_LU);
-		break;
 	case e1000_media_type_internal_serdes:
 		ret_val = hw->mac.ops.check_for_link(hw);
 		link_active = hw->mac.serdes_has_link;
@@ -5136,14 +5132,6 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 
 	mac->autoneg = 0;
 
-	/* Fiber NICs only allow 1000 gbps Full duplex */
-	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
-		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		dev_err(&adapter->pdev->dev,
-			"Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
-	}
-
 	switch (spddplx) {
 	case SPEED_10 + DUPLEX_HALF:
 		mac->forced_speed_duplex = ADVERTISE_10_HALF;

