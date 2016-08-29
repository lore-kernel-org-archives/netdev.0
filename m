From: <sean.wang@mediatek.com>
Subject: [PATCH net v2 8/9] net: ethernet: mediatek: use devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
Date: Mon, 29 Aug 2016 13:03:22 +0800
Message-ID: <1472447003-30726-9-git-send-email-sean.wang@mediatek.com>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:9927 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751271AbcH2FEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 01:04:47 -0400
In-Reply-To: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

a lot of parts in the driver uses devm_* APIs to gain benefits from the
device resource management, so devm_mdiobus_alloc is also used instead
of mdiobus_alloc to have more elegant code flow.

Using common code provided by the devm_* helps to
1) have simplified the code flow as [1] says
2) decrease the risk of incorrect error handling by human
3) only a few drivers used it since it ware proposed on linux 3.16,
so just hope to promote for this.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>

---
ref.
[1] https://patchwork.ozlabs.org/patch/344093/
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 85a527a..f741c6a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -295,7 +295,7 @@ err_phy:
 static int mtk_mdio_init(struct mtk_eth *eth)
 {
 	struct device_node *mii_np;
-	int err;
+	int ret;
 
 	mii_np = of_get_child_by_name(eth->dev->of_node, "mdio-bus");
 	if (!mii_np) {
@@ -304,13 +304,13 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	}
 
 	if (!of_device_is_available(mii_np)) {
-		err = 0;
+		ret = 0;
 		goto err_put_node;
 	}
 
-	eth->mii_bus = mdiobus_alloc();
+	eth->mii_bus = devm_mdiobus_alloc(eth->dev);
 	if (!eth->mii_bus) {
-		err = -ENOMEM;
+		ret = -ENOMEM;
 		goto err_put_node;
 	}
 
@@ -321,20 +321,11 @@ static int mtk_mdio_init(struct mtk_eth *eth)
 	eth->mii_bus->parent = eth->dev;
 
 	snprintf(eth->mii_bus->id, MII_BUS_ID_SIZE, "%s", mii_np->name);
-	err = of_mdiobus_register(eth->mii_bus, mii_np);
-	if (err)
-		goto err_free_bus;
-	of_node_put(mii_np);
-
-	return 0;
-
-err_free_bus:
-	mdiobus_free(eth->mii_bus);
+	ret = of_mdiobus_register(eth->mii_bus, mii_np);
 
 err_put_node:
 	of_node_put(mii_np);
-	eth->mii_bus = NULL;
-	return err;
+	return ret;
 }
 
 static void mtk_mdio_cleanup(struct mtk_eth *eth)
@@ -343,8 +334,6 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 		return;
 
 	mdiobus_unregister(eth->mii_bus);
-	of_node_put(eth->mii_bus->dev.of_node);
-	mdiobus_free(eth->mii_bus);
 }
 
 static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
-- 
1.9.1
