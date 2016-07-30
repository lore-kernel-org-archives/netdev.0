From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: marvell: mvneta: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 30 Jul 2016 17:42:12 +0200
Message-ID: <1469893332-24535-2-git-send-email-tremyfr@gmail.com>
References: <1469893332-24535-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: thomas.petazzoni@free-electrons.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35219 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbcG3PmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 11:42:22 -0400
In-Reply-To: <1469893332-24535-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move the mvneta driver to new api {get|set}_link_ksettings.

We use the generic function phy_ethtool_get_link_ksettings,
and update old mvneta_ethtool_set_settings to the new api.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/mvneta.c |   34 ++++++++++++--------------------
 1 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 410adc7..2021863 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3505,30 +3505,22 @@ static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 /* Ethtool methods */
 
-/* Get settings (phy address, speed) for ethtools */
-int mvneta_ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+/* Set link ksettings (phy address, speed) for ethtools */
+int mvneta_ethtool_set_link_ksettings(struct net_device *ndev,
+				      const struct ethtool_link_ksettings *cmd)
 {
-	if (!dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-/* Set settings (phy address, speed) for ethtools */
-int mvneta_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct mvneta_port *pp = netdev_priv(dev);
-	struct phy_device *phydev = dev->phydev;
+	struct mvneta_port *pp = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
 
-	if ((cmd->autoneg == AUTONEG_ENABLE) != pp->use_inband_status) {
+	if ((cmd->base.autoneg == AUTONEG_ENABLE) != pp->use_inband_status) {
 		u32 val;
 
-		mvneta_set_autoneg(pp, cmd->autoneg == AUTONEG_ENABLE);
+		mvneta_set_autoneg(pp, cmd->base.autoneg == AUTONEG_ENABLE);
 
-		if (cmd->autoneg == AUTONEG_DISABLE) {
+		if (cmd->base.autoneg == AUTONEG_DISABLE) {
 			val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 			val &= ~(MVNETA_GMAC_CONFIG_MII_SPEED |
 				 MVNETA_GMAC_CONFIG_GMII_SPEED |
@@ -3545,17 +3537,17 @@ int mvneta_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
 		}
 
-		pp->use_inband_status = (cmd->autoneg == AUTONEG_ENABLE);
+		pp->use_inband_status = (cmd->base.autoneg == AUTONEG_ENABLE);
 		netdev_info(pp->dev, "autoneg status set to %i\n",
 			    pp->use_inband_status);
 
-		if (netif_running(dev)) {
+		if (netif_running(ndev)) {
 			mvneta_port_down(pp);
 			mvneta_port_up(pp);
 		}
 	}
 
-	return phy_ethtool_sset(dev->phydev, cmd);
+	return phy_ethtool_ksettings_set(ndev->phydev, cmd);
 }
 
 /* Set interrupt coalescing for ethtools */
@@ -3819,8 +3811,6 @@ static const struct net_device_ops mvneta_netdev_ops = {
 
 const struct ethtool_ops mvneta_eth_tool_ops = {
 	.get_link       = ethtool_op_get_link,
-	.get_settings   = mvneta_ethtool_get_settings,
-	.set_settings   = mvneta_ethtool_set_settings,
 	.set_coalesce   = mvneta_ethtool_set_coalesce,
 	.get_coalesce   = mvneta_ethtool_get_coalesce,
 	.get_drvinfo    = mvneta_ethtool_get_drvinfo,
@@ -3833,6 +3823,8 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 	.get_rxnfc	= mvneta_ethtool_get_rxnfc,
 	.get_rxfh	= mvneta_ethtool_get_rxfh,
 	.set_rxfh	= mvneta_ethtool_set_rxfh,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
 };
 
 /* Initialize hw */
-- 
1.7.4.4
