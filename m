From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 02/10] net: ethernet: mediatek: fix incorrect return value of devm_clk_get with EPROBE_DEFER
Date: Thu, 25 Aug 2016 18:22:29 +0800
Message-ID: <1472120557-15216-3-git-send-email-sean.wang@mediatek.com>
References: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:21429 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752134AbcHYKXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:23:50 -0400
In-Reply-To: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

If the return value of devm_clk_get is EPROBE_DEFER, we should
defer probing the driver. The change is verified and works based
on 4.8-rc1 staying with the latest clk-next code for MT7623.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6e4a6ca..02b048f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1851,8 +1851,15 @@ static int mtk_probe(struct platform_device *pdev)
 	eth->clk_gp1 = devm_clk_get(&pdev->dev, "gp1");
 	eth->clk_gp2 = devm_clk_get(&pdev->dev, "gp2");
 	if (IS_ERR(eth->clk_esw) || IS_ERR(eth->clk_gp1) ||
-	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif))
-		return -ENODEV;
+	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif)) {
+		if (PTR_ERR(eth->clk_esw) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp1) == -EPROBE_DEFER ||
+		    PTR_ERR(eth->clk_gp2) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		else
+			return -ENODEV;
+	}
 
 	clk_prepare_enable(eth->clk_ethif);
 	clk_prepare_enable(eth->clk_esw);
-- 
1.9.1
