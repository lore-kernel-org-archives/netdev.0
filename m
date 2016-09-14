From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 1/7] net: ethernet: mediatek: refactoring mtk_hw_init to be reused
Date: Wed, 14 Sep 2016 23:13:15 +0800
Message-ID: <1473866001-9805-2-git-send-email-sean.wang@mediatek.com>
References: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:56373 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756348AbcINPNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:13:32 -0400
In-Reply-To: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

the existing mtk_hw_init includes hardware and software
initialization inside so that it is slightly hard to reuse
them for the process of the reset recovery, so some splitting
is made here for keeping hardware initializing relevant thing
and the else such as IRQ registration and MDIO initialization
what are all about to the interface of core driver moved to the
other proper place because they have no needs to register IRQ and
re-initialize structure again during the reset process.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 62 ++++++++++++++++-------------
 1 file changed, 34 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 66fd45a..ca46e82 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1415,7 +1415,12 @@ static int mtk_stop(struct net_device *dev)
 
 static int __init mtk_hw_init(struct mtk_eth *eth)
 {
-	int err, i;
+	int i;
+
+	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
+	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
+	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
+	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
 
 	/* reset the frame engine */
 	reset_control_assert(eth->rstc);
@@ -1441,19 +1446,6 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	/* Enable RX VLan Offloading */
 	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
 
-	err = devm_request_irq(eth->dev, eth->irq[1], mtk_handle_irq_tx, 0,
-			       dev_name(eth->dev), eth);
-	if (err)
-		return err;
-	err = devm_request_irq(eth->dev, eth->irq[2], mtk_handle_irq_rx, 0,
-			       dev_name(eth->dev), eth);
-	if (err)
-		return err;
-
-	err = mtk_mdio_init(eth);
-	if (err)
-		return err;
-
 	/* disable delay and normal interrupt */
 	mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
 	mtk_w32(eth, 0, MTK_PDMA_DELAY_INT);
@@ -1783,16 +1775,7 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	eth->netdev[id]->features |= MTK_HW_FEATURES;
 	eth->netdev[id]->ethtool_ops = &mtk_ethtool_ops;
 
-	err = register_netdev(eth->netdev[id]);
-	if (err) {
-		dev_err(eth->dev, "error bringing up device\n");
-		goto free_netdev;
-	}
 	eth->netdev[id]->irq = eth->irq[0];
-	netif_info(eth, probe, eth->netdev[id],
-		   "mediatek frame engine at 0x%08lx, irq %d\n",
-		   eth->netdev[id]->base_addr, eth->irq[0]);
-
 	return 0;
 
 free_netdev:
@@ -1862,11 +1845,6 @@ static int mtk_probe(struct platform_device *pdev)
 		}
 	}
 
-	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
-	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
-	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
-	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
-
 	eth->msg_enable = netif_msg_init(mtk_msg_level, MTK_DEFAULT_MSG_ENABLE);
 	INIT_WORK(&eth->pending_work, mtk_pending_work);
 
@@ -1887,6 +1865,34 @@ static int mtk_probe(struct platform_device *pdev)
 			goto err_free_dev;
 	}
 
+	err = devm_request_irq(eth->dev, eth->irq[1], mtk_handle_irq_tx, 0,
+			       dev_name(eth->dev), eth);
+	if (err)
+		goto err_free_dev;
+
+	err = devm_request_irq(eth->dev, eth->irq[2], mtk_handle_irq_rx, 0,
+			       dev_name(eth->dev), eth);
+	if (err)
+		goto err_free_dev;
+
+	err = mtk_mdio_init(eth);
+	if (err)
+		goto err_free_dev;
+
+	for (i = 0; i < MTK_MAX_DEVS; i++) {
+		if (!eth->netdev[i])
+			continue;
+
+		err = register_netdev(eth->netdev[i]);
+		if (err) {
+			dev_err(eth->dev, "error bringing up device\n");
+			goto err_free_dev;
+		} else
+			netif_info(eth, probe, eth->netdev[i],
+				   "mediatek frame engine at 0x%08lx, irq %d\n",
+				   eth->netdev[i]->base_addr, eth->irq[0]);
+	}
+
 	/* we run 2 devices on the same DMA ring so we need a dummy device
 	 * for NAPI to work
 	 */
-- 
1.9.1
