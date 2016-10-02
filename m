From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: mv643xx_eth: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  2 Oct 2016 12:06:49 +0200
Message-ID: <1475402809-11593-2-git-send-email-tremyfr@gmail.com>
References: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: sebastian.hesselbarth@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34283 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbcJBKG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 06:06:59 -0400
In-Reply-To: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   84 +++++++++++++++++----------
 1 files changed, 53 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index ae7370d..18e6bb6 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1495,56 +1495,69 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 };
 
 static int
-mv643xx_eth_get_settings_phy(struct mv643xx_eth_private *mp,
-			     struct ethtool_cmd *cmd)
+mv643xx_eth_get_link_ksettings_phy(struct mv643xx_eth_private *mp,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct net_device *dev = mp->dev;
 	int err;
+	u32 supported, advertising;
 
 	err = phy_read_status(dev->phydev);
 	if (err == 0)
-		err = phy_ethtool_gset(dev->phydev, cmd);
+		err = phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
 	 */
-	cmd->supported &= ~SUPPORTED_1000baseT_Half;
-	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+	supported &= ~SUPPORTED_1000baseT_Half;
+	advertising &= ~ADVERTISED_1000baseT_Half;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return err;
 }
 
 static int
-mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
-				 struct ethtool_cmd *cmd)
+mv643xx_eth_get_link_ksettings_phyless(struct mv643xx_eth_private *mp,
+				       struct ethtool_link_ksettings *cmd)
 {
 	u32 port_status;
+	u32 supported, advertising;
 
 	port_status = rdlp(mp, PORT_STATUS);
 
-	cmd->supported = SUPPORTED_MII;
-	cmd->advertising = ADVERTISED_MII;
+	supported = SUPPORTED_MII;
+	advertising = ADVERTISED_MII;
 	switch (port_status & PORT_SPEED_MASK) {
 	case PORT_SPEED_10:
-		ethtool_cmd_speed_set(cmd, SPEED_10);
+		cmd->base.speed = SPEED_10;
 		break;
 	case PORT_SPEED_100:
-		ethtool_cmd_speed_set(cmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 		break;
 	case PORT_SPEED_1000:
-		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 		break;
 	default:
-		cmd->speed = -1;
+		cmd->base.speed = -1;
 		break;
 	}
-	cmd->duplex = (port_status & FULL_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = PORT_MII;
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
+	cmd->base.duplex = (port_status & FULL_DUPLEX) ?
+		DUPLEX_FULL : DUPLEX_HALF;
+	cmd->base.port = PORT_MII;
+	cmd->base.phy_address = 0;
+	cmd->base.autoneg = AUTONEG_DISABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
@@ -1576,19 +1589,23 @@ mv643xx_eth_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 }
 
 static int
-mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+mv643xx_eth_get_link_ksettings(struct net_device *dev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
 	if (dev->phydev)
-		return mv643xx_eth_get_settings_phy(mp, cmd);
+		return mv643xx_eth_get_link_ksettings_phy(mp, cmd);
 	else
-		return mv643xx_eth_get_settings_phyless(mp, cmd);
+		return mv643xx_eth_get_link_ksettings_phyless(mp, cmd);
 }
 
 static int
-mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+mv643xx_eth_set_link_ksettings(struct net_device *dev,
+			       const struct ethtool_link_ksettings *cmd)
 {
+	struct ethtool_link_ksettings c = *cmd;
+	u32 advertising;
 	int ret;
 
 	if (!dev->phydev)
@@ -1597,9 +1614,13 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	/*
 	 * The MAC does not support 1000baseT_Half.
 	 */
-	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						c.link_modes.advertising);
+	advertising &= ~ADVERTISED_1000baseT_Half;
+	ethtool_convert_legacy_u32_to_link_mode(c.link_modes.advertising,
+						advertising);
 
-	ret = phy_ethtool_sset(dev->phydev, cmd);
+	ret = phy_ethtool_ksettings_set(dev->phydev, &c);
 	if (!ret)
 		mv643xx_eth_adjust_link(dev);
 	return ret;
@@ -1746,8 +1767,6 @@ static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset)
 }
 
 static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
-	.get_settings		= mv643xx_eth_get_settings,
-	.set_settings		= mv643xx_eth_set_settings,
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
 	.nway_reset		= mv643xx_eth_nway_reset,
 	.get_link		= ethtool_op_get_link,
@@ -1761,6 +1780,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_wol                = mv643xx_eth_get_wol,
 	.set_wol                = mv643xx_eth_set_wol,
+	.get_link_ksettings	= mv643xx_eth_get_link_ksettings,
+	.set_link_ksettings	= mv643xx_eth_set_link_ksettings,
 };
 
 
@@ -2328,11 +2349,12 @@ static void port_start(struct mv643xx_eth_private *mp)
 	 * Perform PHY reset, if there is a PHY.
 	 */
 	if (dev->phydev) {
-		struct ethtool_cmd cmd;
+		struct ethtool_link_ksettings cmd;
 
-		mv643xx_eth_get_settings(dev, &cmd);
+		mv643xx_eth_get_link_ksettings(dev, &cmd);
 		phy_init_hw(dev->phydev);
-		mv643xx_eth_set_settings(dev, &cmd);
+		mv643xx_eth_set_link_ksettings(
+			dev, (const struct ethtool_link_ksettings *)&cmd);
 		phy_start(dev->phydev);
 	}
 
-- 
1.7.4.4
