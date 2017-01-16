From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: marvell: skge: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 16 Jan 2017 22:46:08 +0100
Message-ID: <1484603168-18120-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: mlindner@marvell.com, stephen@networkplumber.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36562 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdAPVq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

The callback set_link_ksettings no longer update the value
of advertising, as the struct ethtool_link_ksettings is
defined as const.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- update the commit log with a note to explain that this code
  was not tested on hardware (feedback from Stephen Hemminger)

 drivers/net/ethernet/marvell/skge.c |   63 ++++++++++++++++++++--------------
 1 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 9146a51..81106b7 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -300,65 +300,76 @@ static u32 skge_supported_modes(const struct skge_hw *hw)
 	return supported;
 }
 
-static int skge_get_settings(struct net_device *dev,
-			     struct ethtool_cmd *ecmd)
+static int skge_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
+	u32 supported, advertising;
 
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->supported = skge_supported_modes(hw);
+	supported = skge_supported_modes(hw);
 
 	if (hw->copper) {
-		ecmd->port = PORT_TP;
-		ecmd->phy_address = hw->phy_addr;
+		cmd->base.port = PORT_TP;
+		cmd->base.phy_address = hw->phy_addr;
 	} else
-		ecmd->port = PORT_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+
+	advertising = skge->advertising;
+	cmd->base.autoneg = skge->autoneg;
+	cmd->base.speed = skge->speed;
+	cmd->base.duplex = skge->duplex;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
-	ecmd->advertising = skge->advertising;
-	ecmd->autoneg = skge->autoneg;
-	ethtool_cmd_speed_set(ecmd, skge->speed);
-	ecmd->duplex = skge->duplex;
 	return 0;
 }
 
-static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int skge_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	const struct skge_hw *hw = skge->hw;
 	u32 supported = skge_supported_modes(hw);
 	int err = 0;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		ecmd->advertising = supported;
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		advertising = supported;
 		skge->duplex = -1;
 		skge->speed = -1;
 	} else {
 		u32 setting;
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 
 		switch (speed) {
 		case SPEED_1000:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_1000baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_1000baseT_Half;
 			else
 				return -EINVAL;
 			break;
 		case SPEED_100:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_100baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_100baseT_Half;
 			else
 				return -EINVAL;
 			break;
 
 		case SPEED_10:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_10baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_10baseT_Half;
 			else
 				return -EINVAL;
@@ -371,11 +382,11 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			return -EINVAL;
 
 		skge->speed = speed;
-		skge->duplex = ecmd->duplex;
+		skge->duplex = cmd->base.duplex;
 	}
 
-	skge->autoneg = ecmd->autoneg;
-	skge->advertising = ecmd->advertising;
+	skge->autoneg = cmd->base.autoneg;
+	skge->advertising = advertising;
 
 	if (netif_running(dev)) {
 		skge_down(dev);
@@ -875,8 +886,6 @@ static int skge_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 }
 
 static const struct ethtool_ops skge_ethtool_ops = {
-	.get_settings	= skge_get_settings,
-	.set_settings	= skge_set_settings,
 	.get_drvinfo	= skge_get_drvinfo,
 	.get_regs_len	= skge_get_regs_len,
 	.get_regs	= skge_get_regs,
@@ -899,6 +908,8 @@ static int skge_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 	.set_phys_id	= skge_set_phys_id,
 	.get_sset_count = skge_get_sset_count,
 	.get_ethtool_stats = skge_get_ethtool_stats,
+	.get_link_ksettings = skge_get_link_ksettings,
+	.set_link_ksettings = skge_set_link_ksettings,
 };
 
 /*
-- 
1.7.4.4
