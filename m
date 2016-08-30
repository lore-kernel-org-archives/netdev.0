From: <sean.wang@mediatek.com>
Subject: [PATCH net v3 6/9] net: ethernet: mediatek: fix issue of driver removal with interface is up
Date: Tue, 30 Aug 2016 10:59:22 +0800
Message-ID: <1472525965-10661-7-git-send-email-sean.wang@mediatek.com>
References: <1472525965-10661-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:49056 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757091AbcH3C74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 22:59:56 -0400
In-Reply-To: <1472525965-10661-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

mtk_stop() must be called to stop for freeing DMA
resources acquired and restoring state changed by mtk_open()
firstly when module removal.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 5bfca65..8dcd008 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1903,6 +1903,14 @@ err_free_dev:
 static int mtk_remove(struct platform_device *pdev)
 {
 	struct mtk_eth *eth = platform_get_drvdata(pdev);
+	int i;
+
+	/* stop all devices to make sure that dma is properly shut down */
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+		mtk_stop(eth->netdev[i]);
+	}
 
 	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
 	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
-- 
1.9.1
