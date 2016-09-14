From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 3/7] net: ethernet: mediatek: cleanup error path inside mtk_hw_init
Date: Wed, 14 Sep 2016 11:50:37 +0800
Message-ID: <1473825041-21072-4-git-send-email-sean.wang@mediatek.com>
References: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:1727 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754811AbcINDuw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:50:52 -0400
In-Reply-To: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

This cleans up the error path inside mtk_hw_init call, causing it able
to exit appropriately when something fails and also includes refactoring
mtk_cleanup call to make the partial logic reusable on the error path.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 34 ++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c71b0b3..917a49c6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1564,17 +1564,36 @@ static void mtk_pending_work(struct work_struct *work)
 	rtnl_unlock();
 }
 
-static int mtk_cleanup(struct mtk_eth *eth)
+static int mtk_free_dev(struct mtk_eth *eth)
 {
 	int i;
 
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
 		if (!eth->netdev[i])
 			continue;
+		free_netdev(eth->netdev[i]);
+	}
+
+	return 0;
+}
 
+static int mtk_unreg_dev(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
 		unregister_netdev(eth->netdev[i]);
-		free_netdev(eth->netdev[i]);
 	}
+
+	return 0;
+}
+
+static int mtk_cleanup(struct mtk_eth *eth)
+{
+	mtk_unreg_dev(eth);
+	mtk_free_dev(eth);
 	cancel_work_sync(&eth->pending_work);
 
 	return 0;
@@ -1872,7 +1891,7 @@ static int mtk_probe(struct platform_device *pdev)
 
 		err = mtk_add_mac(eth, mac_np);
 		if (err)
-			goto err_free_dev;
+			goto err_deinit_hw;
 	}
 
 	err = devm_request_irq(eth->dev, eth->irq[1], mtk_handle_irq_tx, 0,
@@ -1896,7 +1915,7 @@ static int mtk_probe(struct platform_device *pdev)
 		err = register_netdev(eth->netdev[i]);
 		if (err) {
 			dev_err(eth->dev, "error bringing up device\n");
-			goto err_free_dev;
+			goto err_deinit_mdio;
 		} else
 			netif_info(eth, probe, eth->netdev[i],
 				   "mediatek frame engine at 0x%08lx, irq %d\n",
@@ -1916,8 +1935,13 @@ static int mtk_probe(struct platform_device *pdev)
 
 	return 0;
 
+err_deinit_mdio:
+	mtk_mdio_cleanup(eth);
 err_free_dev:
-	mtk_cleanup(eth);
+	mtk_free_dev(eth);
+err_deinit_hw:
+	mtk_hw_deinit(eth);
+
 	return err;
 }
 
-- 
1.9.1
