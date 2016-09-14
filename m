From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 6/7] net: ethernet: mediatek: add more resets for internal ethernet circuit block
Date: Wed, 14 Sep 2016 23:13:20 +0800
Message-ID: <1473866001-9805-7-git-send-email-sean.wang@mediatek.com>
References: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:26317 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1760246AbcINPNb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:13:31 -0400
In-Reply-To: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

struct mtk_eth has already contained struct regmap ethsys pointer
to the address range of the internal circuit reset, so we reuse it
to reset more internal blocks on ethernet hardware such as packet
processing engine (PPE) and frame engine (FE) instead of rstc which
deals with FE only.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 27 +++++++++++++++------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  6 +++++-
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a7e2e77..cde9cd6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1414,6 +1414,19 @@ static int mtk_stop(struct net_device *dev)
 	return 0;
 }
 
+static void ethsys_reset(struct mtk_eth *eth, u32 reset_bits)
+{
+	regmap_update_bits(eth->ethsys, ETHSYS_RSTCTRL,
+			   reset_bits,
+			   reset_bits);
+
+	usleep_range(1000, 1100);
+	regmap_update_bits(eth->ethsys, ETHSYS_RSTCTRL,
+			   reset_bits,
+			   ~reset_bits);
+	mdelay(10);
+}
+
 static int mtk_hw_init(struct mtk_eth *eth)
 {
 	int i, val;
@@ -1428,12 +1441,8 @@ static int mtk_hw_init(struct mtk_eth *eth)
 	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
 	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
 	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
-
-	/* reset the frame engine */
-	reset_control_assert(eth->rstc);
-	usleep_range(10, 20);
-	reset_control_deassert(eth->rstc);
-	usleep_range(10, 20);
+	ethsys_reset(eth, RSTCTRL_FE);
+	ethsys_reset(eth, RSTCTRL_PPE);
 
 	regmap_read(eth->ethsys, ETHSYS_SYSCFG0, &val);
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
@@ -1893,12 +1902,6 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->pctl);
 	}
 
-	eth->rstc = devm_reset_control_get(&pdev->dev, "eth");
-	if (IS_ERR(eth->rstc)) {
-		dev_err(&pdev->dev, "no eth reset found\n");
-		return PTR_ERR(eth->rstc);
-	}
-
 	for (i = 0; i < 3; i++) {
 		eth->irq[i] = platform_get_irq(pdev, i);
 		if (eth->irq[i] < 0) {
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 388cbe7..7efa00f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -266,6 +266,11 @@
 #define SYSCFG0_GE_MASK		0x3
 #define SYSCFG0_GE_MODE(x, y)	(x << (12 + (y * 2)))
 
+/*ethernet reset control register*/
+#define ETHSYS_RSTCTRL		0x34
+#define RSTCTRL_FE		BIT(6)
+#define RSTCTRL_PPE		BIT(31)
+
 struct mtk_rx_dma {
 	unsigned int rxd1;
 	unsigned int rxd2;
@@ -423,7 +428,6 @@ struct mtk_rx_ring {
 struct mtk_eth {
 	struct device			*dev;
 	void __iomem			*base;
-	struct reset_control		*rstc;
 	spinlock_t			page_lock;
 	spinlock_t			irq_lock;
 	struct net_device		dummy_dev;
-- 
1.9.1
