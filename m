From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: hisilicon: hns: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 20 Sep 2016 22:30:12 +0200
Message-ID: <1474403412-18748-2-git-send-email-tremyfr@gmail.com>
References: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com,
        xieqianqian@huawei.com, arnd@arndb.de, lipeng321@huawei.com,
        andrew@lunn.ch, chenny.xu@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34338 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbcITUaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 16:30:23 -0400
In-Reply-To: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |  105 ++++++++++++----------
 1 files changed, 58 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 0e2c174..47e59bb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -64,14 +64,14 @@ static u32 hns_nic_get_link(struct net_device *net_dev)
 }
 
 static void hns_get_mdix_mode(struct net_device *net_dev,
-			      struct ethtool_cmd *cmd)
+			      struct ethtool_link_ksettings *cmd)
 {
 	int mdix_ctrl, mdix, retval, is_resolved;
 	struct phy_device *phy_dev = net_dev->phydev;
 
 	if (!phy_dev || !phy_dev->mdio.bus) {
-		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
-		cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
 		return;
 	}
 
@@ -88,35 +88,35 @@ static void hns_get_mdix_mode(struct net_device *net_dev,
 
 	switch (mdix_ctrl) {
 	case 0x0:
-		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI;
 		break;
 	case 0x1:
-		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_X;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_X;
 		break;
 	case 0x3:
-		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
 		break;
 	default:
-		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
 		break;
 	}
 
 	if (!is_resolved)
-		cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
 	else if (mdix)
-		cmd->eth_tp_mdix = ETH_TP_MDI_X;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI_X;
 	else
-		cmd->eth_tp_mdix = ETH_TP_MDI;
+		cmd->base.eth_tp_mdix = ETH_TP_MDI;
 }
 
 /**
- *hns_nic_get_settings - implement ethtool get settings
+ *hns_nic_get_link_ksettings - implement ethtool get link ksettings
  *@net_dev: net_device
- *@cmd: ethtool_cmd
+ *@cmd: ethtool_link_ksettings
  *retuen 0 - success , negative --fail
  */
-static int hns_nic_get_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
+static int hns_nic_get_link_ksettings(struct net_device *net_dev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_handle *h;
@@ -124,6 +124,7 @@ static int hns_nic_get_settings(struct net_device *net_dev,
 	int ret;
 	u8 duplex;
 	u16 speed;
+	u32 supported, advertising;
 
 	if (!priv || !priv->ae_handle)
 		return -ESRCH;
@@ -138,38 +139,43 @@ static int hns_nic_get_settings(struct net_device *net_dev,
 		return -EINVAL;
 	}
 
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
 	/* When there is no phy, autoneg is off. */
-	cmd->autoneg = false;
-	ethtool_cmd_speed_set(cmd, speed);
-	cmd->duplex = duplex;
+	cmd->base.autoneg = false;
+	cmd->base.cmd = speed;
+	cmd->base.duplex = duplex;
 
 	if (net_dev->phydev)
-		(void)phy_ethtool_gset(net_dev->phydev, cmd);
+		(void)phy_ethtool_ksettings_get(net_dev->phydev, cmd);
 
 	link_stat = hns_nic_get_link(net_dev);
 	if (!link_stat) {
-		ethtool_cmd_speed_set(cmd, (u32)SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = (u32)SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	if (cmd->autoneg)
-		cmd->advertising |= ADVERTISED_Autoneg;
+	if (cmd->base.autoneg)
+		advertising |= ADVERTISED_Autoneg;
 
-	cmd->supported |= h->if_support;
+	supported |= h->if_support;
 	if (h->phy_if == PHY_INTERFACE_MODE_SGMII) {
-		cmd->supported |= SUPPORTED_TP;
-		cmd->advertising |= ADVERTISED_1000baseT_Full;
+		supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_1000baseT_Full;
 	} else if (h->phy_if == PHY_INTERFACE_MODE_XGMII) {
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_10000baseKR_Full;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_10000baseKR_Full;
 	}
 
 	switch (h->media_type) {
 	case HNAE_MEDIA_TYPE_FIBER:
-		cmd->port = PORT_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 		break;
 	case HNAE_MEDIA_TYPE_COPPER:
-		cmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 		break;
 	case HNAE_MEDIA_TYPE_UNKNOWN:
 	default:
@@ -177,23 +183,27 @@ static int hns_nic_get_settings(struct net_device *net_dev,
 	}
 
 	if (!(AE_IS_VER1(priv->enet_ver) && h->port_type == HNAE_PORT_DEBUG))
-		cmd->supported |= SUPPORTED_Pause;
+		supported |= SUPPORTED_Pause;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->mdio_support = (ETH_MDIO_SUPPORTS_C45 | ETH_MDIO_SUPPORTS_C22);
+	cmd->base.mdio_support = ETH_MDIO_SUPPORTS_C45 | ETH_MDIO_SUPPORTS_C22;
 	hns_get_mdix_mode(net_dev, cmd);
 
 	return 0;
 }
 
 /**
- *hns_nic_set_settings - implement ethtool set settings
+ *hns_nic_set_link_settings - implement ethtool set link ksettings
  *@net_dev: net_device
- *@cmd: ethtool_cmd
+ *@cmd: ethtool_link_ksettings
  *retuen 0 - success , negative --fail
  */
-static int hns_nic_set_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
+static int hns_nic_set_link_ksettings(struct net_device *net_dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_handle *h;
@@ -207,24 +217,25 @@ static int hns_nic_set_settings(struct net_device *net_dev,
 		return -ENODEV;
 
 	h = priv->ae_handle;
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
 
 	if (h->phy_if == PHY_INTERFACE_MODE_XGMII) {
-		if (cmd->autoneg == AUTONEG_ENABLE || speed != SPEED_10000 ||
-		    cmd->duplex != DUPLEX_FULL)
+		if (cmd->base.autoneg == AUTONEG_ENABLE ||
+		    speed != SPEED_10000 ||
+		    cmd->base.duplex != DUPLEX_FULL)
 			return -EINVAL;
 	} else if (h->phy_if == PHY_INTERFACE_MODE_SGMII) {
-		if (!net_dev->phydev && cmd->autoneg == AUTONEG_ENABLE)
+		if (!net_dev->phydev && cmd->base.autoneg == AUTONEG_ENABLE)
 			return -EINVAL;
 
-		if (speed == SPEED_1000 && cmd->duplex == DUPLEX_HALF)
+		if (speed == SPEED_1000 && cmd->base.duplex == DUPLEX_HALF)
 			return -EINVAL;
 		if (net_dev->phydev)
-			return phy_ethtool_sset(net_dev->phydev, cmd);
+			return phy_ethtool_ksettings_set(net_dev->phydev, cmd);
 
 		if ((speed != SPEED_10 && speed != SPEED_100 &&
-		     speed != SPEED_1000) || (cmd->duplex != DUPLEX_HALF &&
-		     cmd->duplex != DUPLEX_FULL))
+		     speed != SPEED_1000) || (cmd->base.duplex != DUPLEX_HALF &&
+		     cmd->base.duplex != DUPLEX_FULL))
 			return -EINVAL;
 	} else {
 		netdev_err(net_dev, "Not supported!");
@@ -232,7 +243,7 @@ static int hns_nic_set_settings(struct net_device *net_dev,
 	}
 
 	if (h->dev->ops->adjust_link) {
-		h->dev->ops->adjust_link(h, (int)speed, cmd->duplex);
+		h->dev->ops->adjust_link(h, (int)speed, cmd->base.duplex);
 		return 0;
 	}
 
@@ -1264,8 +1275,6 @@ static int hns_get_rxnfc(struct net_device *netdev,
 static const struct ethtool_ops hns_ethtool_ops = {
 	.get_drvinfo = hns_nic_get_drvinfo,
 	.get_link  = hns_nic_get_link,
-	.get_settings  = hns_nic_get_settings,
-	.set_settings  = hns_nic_set_settings,
 	.get_ringparam = hns_get_ringparam,
 	.get_pauseparam = hns_get_pauseparam,
 	.set_pauseparam = hns_set_pauseparam,
@@ -1285,6 +1294,8 @@ static const struct ethtool_ops hns_ethtool_ops = {
 	.get_rxfh = hns_get_rss,
 	.set_rxfh = hns_set_rss,
 	.get_rxnfc = hns_get_rxnfc,
+	.get_link_ksettings  = hns_nic_get_link_ksettings,
+	.set_link_ksettings  = hns_nic_set_link_ksettings,
 };
 
 void hns_ethtool_set_ops(struct net_device *ndev)
-- 
1.7.4.4
