From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/6] mv643xx_eth: unify ethtool ops for phy'd and phy-less interfaces
Date: Fri, 13 Feb 2009 01:06:46 +0100
Message-ID: <20090213000646.GK17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42997 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbZBMAGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:06:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a waste having two different versions of this structure around
when the differences between ethtool ops for phy'd and phy-less
interfaces are so minor.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   56 ++++++++++++++++++--------------------------
 1 files changed, 23 insertions(+), 33 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 5f31bbb..7a67181 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1279,9 +1279,9 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 };
 
 static int
-mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+mv643xx_eth_get_settings_phy(struct mv643xx_eth_private *mp,
+			     struct ethtool_cmd *cmd)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
 	err = phy_read_status(mp->phy);
@@ -1298,10 +1298,9 @@ mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 }
 
 static int
-mv643xx_eth_get_settings_phyless(struct net_device *dev,
+mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
 				 struct ethtool_cmd *cmd)
 {
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 port_status;
 
 	port_status = rdlp(mp, PORT_STATUS);
@@ -1334,10 +1333,24 @@ mv643xx_eth_get_settings_phyless(struct net_device *dev,
 }
 
 static int
+mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	if (mp->phy != NULL)
+		return mv643xx_eth_get_settings_phy(mp, cmd);
+	else
+		return mv643xx_eth_get_settings_phyless(mp, cmd);
+}
+
+static int
 mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
+	if (mp->phy == NULL)
+		return -EINVAL;
+
 	/*
 	 * The MAC does not support 1000baseT_Half.
 	 */
@@ -1346,13 +1359,6 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(mp->phy, cmd);
 }
 
-static int
-mv643xx_eth_set_settings_phyless(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
-{
-	return -EINVAL;
-}
-
 static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *drvinfo)
 {
@@ -1367,12 +1373,10 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return genphy_restart_aneg(mp->phy);
-}
+	if (mp->phy == NULL)
+		return -EINVAL;
 
-static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
-{
-	return -EINVAL;
+	return genphy_restart_aneg(mp->phy);
 }
 
 static u32 mv643xx_eth_get_link(struct net_device *dev)
@@ -1440,18 +1444,6 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_sset_count		= mv643xx_eth_get_sset_count,
 };
 
-static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
-	.get_settings		= mv643xx_eth_get_settings_phyless,
-	.set_settings		= mv643xx_eth_set_settings_phyless,
-	.get_drvinfo		= mv643xx_eth_get_drvinfo,
-	.nway_reset		= mv643xx_eth_nway_reset_phyless,
-	.get_link		= mv643xx_eth_get_link,
-	.set_sg			= ethtool_op_set_sg,
-	.get_strings		= mv643xx_eth_get_strings,
-	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
-	.get_sset_count		= mv643xx_eth_get_sset_count,
-};
-
 
 /* address handling *********************************************************/
 static void uc_addr_get(struct mv643xx_eth_private *mp, unsigned char *addr)
@@ -2673,12 +2665,10 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
 		mp->phy = phy_scan(mp, pd->phy_addr);
 
-	if (mp->phy != NULL) {
+	if (mp->phy != NULL)
 		phy_init(mp, pd->speed, pd->duplex);
-		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
-	} else {
-		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
-	}
+
+	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 
 	init_pscr(mp, pd->speed, pd->duplex);
 
-- 
1.5.6.4
