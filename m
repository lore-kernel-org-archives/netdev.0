From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: get out of potential invalid pointer access
Date: Thu, 22 Sep 2016 16:44:16 +0800
Message-ID: <1474533856-22753-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:15606 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752591AbcIVIoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 04:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Potential dangerous invalid pointer might be accessed if
the error happens when couple phy_device to net_device so
cleanup the error path.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a65801a..3d7e0cb 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -296,7 +296,9 @@ static int mtk_phy_connect(struct net_device *dev)
 	regmap_write(eth->ethsys, ETHSYS_SYSCFG0, val);
 
 	/* couple phydev to net_device */
-	mtk_phy_connect_node(eth, mac, np);
+	if (mtk_phy_connect_node(eth, mac, np))
+		goto err_phy;
+
 	dev->phydev->autoneg = AUTONEG_ENABLE;
 	dev->phydev->speed = 0;
 	dev->phydev->duplex = 0;
@@ -317,7 +319,7 @@ static int mtk_phy_connect(struct net_device *dev)
 
 err_phy:
 	of_node_put(np);
-	dev_err(eth->dev, "invalid phy_mode\n");
+	dev_err(eth->dev, "%s: invalid phy\n", __func__);
 	return -EINVAL;
 }
 
-- 
1.9.1
