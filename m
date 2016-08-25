From: Sean Wang <sean.wang@mediatek.com>
Subject: [RESEND PATCH net 06/10] net: ethernet: mediatek: fix the loss of pin-mux setting for GMAC2
Date: Thu, 25 Aug 2016 18:44:57 +0800
Message-ID: <1472121901-15629-7-git-send-email-sean.wang@mediatek.com>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:29662 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932911AbcHYKpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:45:13 -0400
In-Reply-To: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ommited the setting about pin-mux which results in incorrect signals
being routed on GMAC2.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 14 ++++++++++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  3 +++
 2 files changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 5bd31f8..0a4c782 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1415,6 +1415,7 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	usleep_range(10, 20);
 	reset_control_deassert(eth->rstc);
 	usleep_range(10, 20);
+	pinctrl_select_state(eth->pins, eth->ephy_default);
 
 	/* Set GE2 driving and slew rate */
 	regmap_write(eth->pctl, GPIO_DRV_SEL10, 0xa00);
@@ -1858,6 +1859,19 @@ static int mtk_probe(struct platform_device *pdev)
 			return -ENODEV;
 	}
 
+	eth->pins = devm_pinctrl_get(&pdev->dev);
+	if (IS_ERR(eth->pins)) {
+		dev_err(&pdev->dev, "cannot get pinctrl\n");
+		return PTR_ERR(eth->pins);
+	}
+
+	eth->ephy_default =
+		pinctrl_lookup_state(eth->pins, "default");
+	if (IS_ERR(eth->ephy_default)) {
+		dev_err(&pdev->dev, "cannot get pinctrl state\n");
+		return PTR_ERR(eth->ephy_default);
+	}
+
 	clk_prepare_enable(eth->clk_ethif);
 	clk_prepare_enable(eth->clk_esw);
 	clk_prepare_enable(eth->clk_gp1);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index f82e3ac..13d3f1b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -404,6 +404,9 @@ struct mtk_eth {
 	struct clk			*clk_esw;
 	struct clk			*clk_gp1;
 	struct clk			*clk_gp2;
+	struct pinctrl			*pins;
+	struct pinctrl_state		*ephy_default;
+
 	struct mii_bus			*mii_bus;
 	struct work_struct		pending_work;
 };
-- 
1.9.1
