From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: use [get|set]_link_ksettings
Date: Thu, 22 Sep 2016 16:42:03 +0800
Message-ID: <1474533723-22629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:13405 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754117AbcIVImK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 04:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

1) use new api [get|set]_link_ksettings instead
of [get|set]_settings old ones.

2) dev->phydev is sure being ready before calling
these callbacks, so removing all the sanity check
if it is existing.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 33 +++++++++++------------------
 1 file changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 1918c39..a65801a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2034,35 +2034,26 @@ static int mtk_cleanup(struct mtk_eth *eth)
 	return 0;
 }
 
-static int mtk_get_settings(struct net_device *dev,
-			    struct ethtool_cmd *cmd)
+int mtk_get_link_ksettings(struct net_device *ndev,
+			   struct ethtool_link_ksettings *cmd)
 {
-	struct mtk_mac *mac = netdev_priv(dev);
-	int err;
+	struct mtk_mac *mac = netdev_priv(ndev);
 
 	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
 		return -EBUSY;
 
-	err = phy_read_status(dev->phydev);
-	if (err)
-		return -ENODEV;
-
-	return phy_ethtool_gset(dev->phydev, cmd);
+	return phy_ethtool_ksettings_get(ndev->phydev, cmd);
 }
 
-static int mtk_set_settings(struct net_device *dev,
-			    struct ethtool_cmd *cmd)
+int mtk_set_link_ksettings(struct net_device *ndev,
+			   const struct ethtool_link_ksettings *cmd)
 {
-	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_mac *mac = netdev_priv(ndev);
 
-	if (cmd->phy_address != dev->phydev->mdio.addr) {
-		dev->phydev = mdiobus_get_phy(mac->hw->mii_bus,
-					       cmd->phy_address);
-		if (!dev->phydev)
-			return -ENODEV;
-	}
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return -EBUSY;
 
-	return phy_ethtool_sset(dev->phydev, cmd);
+	return phy_ethtool_ksettings_set(ndev->phydev, cmd);
 }
 
 static void mtk_get_drvinfo(struct net_device *dev,
@@ -2225,8 +2216,8 @@ static int mtk_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 }
 
 static const struct ethtool_ops mtk_ethtool_ops = {
-	.get_settings		= mtk_get_settings,
-	.set_settings		= mtk_set_settings,
+	.get_link_ksettings	= mtk_get_link_ksettings,
+	.set_link_ksettings	= mtk_set_link_ksettings,
 	.get_drvinfo		= mtk_get_drvinfo,
 	.get_msglevel		= mtk_get_msglevel,
 	.set_msglevel		= mtk_set_msglevel,
-- 
1.9.1
