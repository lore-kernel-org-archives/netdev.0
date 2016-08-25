From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 09/10] net: ethernet: mediatek: use devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
Date: Thu, 25 Aug 2016 18:22:36 +0800
Message-ID: <1472120557-15216-10-git-send-email-sean.wang@mediatek.com>
References: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:39410 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753748AbcHYKXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:23:52 -0400
In-Reply-To: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

a lot of parts in the driver uses devm_* APIs to gain benefits from the
device resource management, so devm_mdiobus_alloc is also used instead
of mdiobus_alloc to have more elegant code flow.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index e3baa63..05d85da 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -304,7 +304,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 		goto err_put_node;
 	}
 
-	eth->mii_bus = mdiobus_alloc();
+	eth->mii_bus = devm_mdiobus_alloc(eth->dev);
 	if (!eth->mii_bus) {
 		err = -ENOMEM;
 		goto err_put_node;
@@ -318,18 +318,9 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 
 	snprintf(eth->mii_bus->id, MII_BUS_ID_SIZE, "%s", mii_np->name);
 	err = of_mdiobus_register(eth->mii_bus, mii_np);
-	if (err)
-		goto err_free_bus;
-	of_node_put(mii_np);
-
-	return 0;
-
-err_free_bus:
-	mdiobus_free(eth->mii_bus);
 
 err_put_node:
 	of_node_put(mii_np);
-	eth->mii_bus = NULL;
 	return err;
 }
 
@@ -339,8 +330,6 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 		return;
 
 	mdiobus_unregister(eth->mii_bus);
-	of_node_put(eth->mii_bus->dev.of_node);
-	mdiobus_free(eth->mii_bus);
 }
 
 static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
-- 
1.9.1
