From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dlink: dl2k: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 20:49:26 +0100
Message-ID: <1483300166-22297-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35859 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932229AbdAATtd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 14:49:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

The previous implementation of set_settings was modifying
the value of speed and duplex, but with the new API, it's not
possible. The structure ethtool_link_ksettings is defined
as const.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dlink/dl2k.c |   71 +++++++++++++++++++++---------------
 1 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 8c95a8a..1e35013 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1256,52 +1256,63 @@ static void rio_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->bus_info, pci_name(np->pdev), sizeof(info->bus_info));
 }
 
-static int rio_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rio_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	u32 supported, advertising;
+
 	if (np->phy_media) {
 		/* fiber device */
-		cmd->supported = SUPPORTED_Autoneg | SUPPORTED_FIBRE;
-		cmd->advertising= ADVERTISED_Autoneg | ADVERTISED_FIBRE;
-		cmd->port = PORT_FIBRE;
-		cmd->transceiver = XCVR_INTERNAL;
+		supported = SUPPORTED_Autoneg | SUPPORTED_FIBRE;
+		advertising = ADVERTISED_Autoneg | ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 	} else {
 		/* copper device */
-		cmd->supported = SUPPORTED_10baseT_Half |
+		supported = SUPPORTED_10baseT_Half |
 			SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half
 			| SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Full |
 			SUPPORTED_Autoneg | SUPPORTED_MII;
-		cmd->advertising = ADVERTISED_10baseT_Half |
+		advertising = ADVERTISED_10baseT_Half |
 			ADVERTISED_10baseT_Full | ADVERTISED_100baseT_Half |
-			ADVERTISED_100baseT_Full | ADVERTISED_1000baseT_Full|
+			ADVERTISED_100baseT_Full | ADVERTISED_1000baseT_Full |
 			ADVERTISED_Autoneg | ADVERTISED_MII;
-		cmd->port = PORT_MII;
-		cmd->transceiver = XCVR_INTERNAL;
+		cmd->base.port = PORT_MII;
 	}
-	if ( np->link_status ) {
-		ethtool_cmd_speed_set(cmd, np->speed);
-		cmd->duplex = np->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	if (np->link_status) {
+		cmd->base.speed = np->speed;
+		cmd->base.duplex = np->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
-	if ( np->an_enable)
-		cmd->autoneg = AUTONEG_ENABLE;
+	if (np->an_enable)
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
+
+	cmd->base.phy_address = np->phy_addr;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
-	cmd->phy_address = np->phy_addr;
 	return 0;
 }
 
-static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rio_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	u32 speed = cmd->base.speed;
+	u8 duplex = cmd->base.duplex;
+
 	netif_carrier_off(dev);
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (np->an_enable)
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if (np->an_enable) {
 			return 0;
-		else {
+		} else {
 			np->an_enable = 1;
 			mii_set_media(dev);
 			return 0;
@@ -1309,18 +1320,18 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	} else {
 		np->an_enable = 0;
 		if (np->speed == 1000) {
-			ethtool_cmd_speed_set(cmd, SPEED_100);
-			cmd->duplex = DUPLEX_FULL;
+			speed = SPEED_100;
+			duplex = DUPLEX_FULL;
 			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, change to Manual 100Mbps, Full duplex.\n");
 		}
-		switch (ethtool_cmd_speed(cmd)) {
+		switch (speed) {
 		case SPEED_10:
 			np->speed = 10;
-			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
+			np->full_duplex = (duplex == DUPLEX_FULL);
 			break;
 		case SPEED_100:
 			np->speed = 100;
-			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
+			np->full_duplex = (duplex == DUPLEX_FULL);
 			break;
 		case SPEED_1000: /* not supported */
 		default:
@@ -1339,9 +1350,9 @@ static u32 rio_get_link(struct net_device *dev)
 
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo = rio_get_drvinfo,
-	.get_settings = rio_get_settings,
-	.set_settings = rio_set_settings,
 	.get_link = rio_get_link,
+	.get_link_ksettings = rio_get_link_ksettings,
+	.set_link_ksettings = rio_set_link_ksettings,
 };
 
 static int
-- 
1.7.4.4
