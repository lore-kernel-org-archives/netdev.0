From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ti: netcp_ethss: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  8 Oct 2016 19:48:15 +0200
Message-ID: <1475948895-27614-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: w-kwok2@ti.com, m-karicheri2@ti.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36125 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbcJHRtg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 13:49:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |   42 +++++++++++++++++++-------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index d543298..48cb04f 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1840,8 +1840,8 @@ static void keystone_get_ethtool_stats(struct net_device *ndev,
 	spin_unlock_bh(&gbe_dev->hw_stats_lock);
 }
 
-static int keystone_get_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
+static int keystone_get_link_ksettings(struct net_device *ndev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
 	struct phy_device *phy = ndev->phydev;
@@ -1858,20 +1858,28 @@ static int keystone_get_settings(struct net_device *ndev,
 	if (!gbe_intf->slave)
 		return -EINVAL;
 
-	ret = phy_ethtool_gset(phy, cmd);
+	ret = phy_ethtool_ksettings_get(phy, cmd);
 	if (!ret)
-		cmd->port = gbe_intf->slave->phy_port_t;
+		cmd->base.port = gbe_intf->slave->phy_port_t;
 
 	return ret;
 }
 
-static int keystone_set_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
+static int keystone_set_link_ksettings(struct net_device *ndev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
 	struct phy_device *phy = ndev->phydev;
 	struct gbe_intf *gbe_intf;
-	u32 features = cmd->advertising & cmd->supported;
+	u8 port = cmd->base.port;
+	u32 advertising, supported;
+	u32 features;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	features = advertising & supported;
 
 	if (!phy)
 		return -EINVAL;
@@ -1883,25 +1891,25 @@ static int keystone_set_settings(struct net_device *ndev,
 	if (!gbe_intf->slave)
 		return -EINVAL;
 
-	if (cmd->port != gbe_intf->slave->phy_port_t) {
-		if ((cmd->port == PORT_TP) && !(features & ADVERTISED_TP))
+	if (port != gbe_intf->slave->phy_port_t) {
+		if ((port == PORT_TP) && !(features & ADVERTISED_TP))
 			return -EINVAL;
 
-		if ((cmd->port == PORT_AUI) && !(features & ADVERTISED_AUI))
+		if ((port == PORT_AUI) && !(features & ADVERTISED_AUI))
 			return -EINVAL;
 
-		if ((cmd->port == PORT_BNC) && !(features & ADVERTISED_BNC))
+		if ((port == PORT_BNC) && !(features & ADVERTISED_BNC))
 			return -EINVAL;
 
-		if ((cmd->port == PORT_MII) && !(features & ADVERTISED_MII))
+		if ((port == PORT_MII) && !(features & ADVERTISED_MII))
 			return -EINVAL;
 
-		if ((cmd->port == PORT_FIBRE) && !(features & ADVERTISED_FIBRE))
+		if ((port == PORT_FIBRE) && !(features & ADVERTISED_FIBRE))
 			return -EINVAL;
 	}
 
-	gbe_intf->slave->phy_port_t = cmd->port;
-	return phy_ethtool_sset(phy, cmd);
+	gbe_intf->slave->phy_port_t = port;
+	return phy_ethtool_ksettings_set(phy, cmd);
 }
 
 static const struct ethtool_ops keystone_ethtool_ops = {
@@ -1912,8 +1920,8 @@ static const struct ethtool_ops keystone_ethtool_ops = {
 	.get_strings		= keystone_get_stat_strings,
 	.get_sset_count		= keystone_get_sset_count,
 	.get_ethtool_stats	= keystone_get_ethtool_stats,
-	.get_settings		= keystone_get_settings,
-	.set_settings		= keystone_set_settings,
+	.get_link_ksettings	= keystone_get_link_ksettings,
+	.set_link_ksettings	= keystone_set_link_ksettings,
 };
 
 #define mac_hi(mac)	(((mac)[0] << 0) | ((mac)[1] << 8) |	\
-- 
1.7.4.4
