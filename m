From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 07/10] net: ethernet: mediatek: fix issue of driver removal with interface is up
Date: Thu, 25 Aug 2016 18:22:34 +0800
Message-ID: <1472120557-15216-8-git-send-email-sean.wang@mediatek.com>
References: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:33063 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754023AbcHYKXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:23:50 -0400
In-Reply-To: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

1) mtk_stop() must be called to stop for freeing DMA resources 
acquired and restoring state changed by mtk_open() when module 
removal.

2) group clock disabled related function into mtk_hw_deinit which 
could be reused with others functionality such as the whole ethernet 
reset that would be posted in the later series of patches.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 0a4c782..c573475 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1478,6 +1478,16 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	return 0;
 }
 
+static int mtk_hw_deinit(struct mtk_eth *eth)
+{
+	clk_disable_unprepare(eth->clk_esw);
+	clk_disable_unprepare(eth->clk_gp1);
+	clk_disable_unprepare(eth->clk_gp2);
+	clk_disable_unprepare(eth->clk_ethif);
+
+	return 0;
+}
+
 static int __init mtk_init(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -1919,11 +1929,15 @@ err_free_dev:
 static int mtk_remove(struct platform_device *pdev)
 {
 	struct mtk_eth *eth = platform_get_drvdata(pdev);
+	int i;
 
-	clk_disable_unprepare(eth->clk_ethif);
-	clk_disable_unprepare(eth->clk_esw);
-	clk_disable_unprepare(eth->clk_gp1);
-	clk_disable_unprepare(eth->clk_gp2);
+	/* stop all devices to make sure that dma is properly shut down */
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+		mtk_stop(eth->netdev[i]);
+	}
+	mtk_hw_deinit(eth);
 
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
-- 
1.9.1
