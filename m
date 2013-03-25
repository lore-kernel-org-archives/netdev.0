From: Sekhar Nori <nsekhar@ti.com>
Subject: [PATCH net-next 1/2] net/davinci_emac: use devres APIs
Date: Mon, 25 Mar 2013 14:55:46 +0530
Message-ID: <1364203547-2960-2-git-send-email-nsekhar@ti.com>
References: <1364203547-2960-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Sekhar Nori <nsekhar@ti.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:40101 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758121Ab3CYJ1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 05:27:12 -0400
In-Reply-To: <1364203547-2960-1-git-send-email-nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devres APIs where possible to simplify error handling
in driver probe.

While at it, also rename the goto targets in error path to
introduce some consistency in how they are named.

Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   46 +++++++++++---------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index ae1b77a..b1349b5 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1865,21 +1865,18 @@ static int davinci_emac_probe(struct platform_device *pdev)
 
 
 	/* obtain emac clock from kernel */
-	emac_clk = clk_get(&pdev->dev, NULL);
+	emac_clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(emac_clk)) {
 		dev_err(&pdev->dev, "failed to get EMAC clock\n");
 		return -EBUSY;
 	}
 	emac_bus_frequency = clk_get_rate(emac_clk);
-	clk_put(emac_clk);
 
 	/* TODO: Probe PHY here if possible */
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
-	if (!ndev) {
-		rc = -ENOMEM;
-		goto no_ndev;
-	}
+	if (!ndev)
+		return -ENOMEM;
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
@@ -1893,7 +1890,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (!pdata) {
 		dev_err(&pdev->dev, "no platform data\n");
 		rc = -ENODEV;
-		goto probe_quit;
+		goto no_pdata;
 	}
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
@@ -1913,23 +1910,23 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (!res) {
 		dev_err(&pdev->dev,"error getting res\n");
 		rc = -ENOENT;
-		goto probe_quit;
+		goto no_pdata;
 	}
 
 	priv->emac_base_phys = res->start + pdata->ctrl_reg_offset;
 	size = resource_size(res);
-	if (!request_mem_region(res->start, size, ndev->name)) {
+	if (!devm_request_mem_region(&pdev->dev, res->start,
+				     size, ndev->name)) {
 		dev_err(&pdev->dev, "failed request_mem_region() for regs\n");
 		rc = -ENXIO;
-		goto probe_quit;
+		goto no_pdata;
 	}
 
-	priv->remap_addr = ioremap(res->start, size);
+	priv->remap_addr = devm_ioremap(&pdev->dev, res->start, size);
 	if (!priv->remap_addr) {
 		dev_err(&pdev->dev, "unable to map IO\n");
 		rc = -ENOMEM;
-		release_mem_region(res->start, size);
-		goto probe_quit;
+		goto no_pdata;
 	}
 	priv->emac_base = priv->remap_addr + pdata->ctrl_reg_offset;
 	ndev->base_addr = (unsigned long)priv->remap_addr;
@@ -1962,7 +1959,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (!priv->dma) {
 		dev_err(&pdev->dev, "error initializing DMA\n");
 		rc = -ENOMEM;
-		goto no_dma;
+		goto no_pdata;
 	}
 
 	priv->txchan = cpdma_chan_create(priv->dma, tx_chan_num(EMAC_DEF_TX_CH),
@@ -1971,14 +1968,14 @@ static int davinci_emac_probe(struct platform_device *pdev)
 				       emac_rx_handler);
 	if (WARN_ON(!priv->txchan || !priv->rxchan)) {
 		rc = -ENOMEM;
-		goto no_irq_res;
+		goto no_cpdma_chan;
 	}
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!res) {
 		dev_err(&pdev->dev, "error getting irq res\n");
 		rc = -ENOENT;
-		goto no_irq_res;
+		goto no_cpdma_chan;
 	}
 	ndev->irq = res->start;
 
@@ -2000,7 +1997,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (rc) {
 		dev_err(&pdev->dev, "error in register_netdev\n");
 		rc = -ENODEV;
-		goto no_irq_res;
+		goto no_cpdma_chan;
 	}
 
 
@@ -2015,20 +2012,14 @@ static int davinci_emac_probe(struct platform_device *pdev)
 
 	return 0;
 
-no_irq_res:
+no_cpdma_chan:
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
 	if (priv->rxchan)
 		cpdma_chan_destroy(priv->rxchan);
 	cpdma_ctlr_destroy(priv->dma);
-no_dma:
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-	iounmap(priv->remap_addr);
-
-probe_quit:
+no_pdata:
 	free_netdev(ndev);
-no_ndev:
 	return rc;
 }
 
@@ -2041,14 +2032,12 @@ no_ndev:
  */
 static int davinci_emac_remove(struct platform_device *pdev)
 {
-	struct resource *res;
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct emac_priv *priv = netdev_priv(ndev);
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
 	platform_set_drvdata(pdev, NULL);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
@@ -2056,10 +2045,7 @@ static int davinci_emac_remove(struct platform_device *pdev)
 		cpdma_chan_destroy(priv->rxchan);
 	cpdma_ctlr_destroy(priv->dma);
 
-	release_mem_region(res->start, resource_size(res));
-
 	unregister_netdev(ndev);
-	iounmap(priv->remap_addr);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.7.10.1
