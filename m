From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 1/2] net/davinci_emac: use devres APIs
Date: Tue, 27 Nov 2012 20:17:14 +0530
Message-ID: <1354027635-32627-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Use devres APIs where possible to simplify error handling
in driver probe.

While at it, also rename the goto targets in error path to
introduce some consistency in how they are named.

Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_emac.c |   46 +++++++++++---------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index fce89a0..7be04dc 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1865,21 +1865,18 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 
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
@@ -1893,7 +1890,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	if (!pdata) {
 		dev_err(&pdev->dev, "no platform data\n");
 		rc = -ENODEV;
-		goto probe_quit;
+		goto no_pdata;
 	}
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
@@ -1913,23 +1910,23 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
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
@@ -1962,7 +1959,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	if (!priv->dma) {
 		dev_err(&pdev->dev, "error initializing DMA\n");
 		rc = -ENOMEM;
-		goto no_dma;
+		goto no_pdata;
 	}
 
 	priv->txchan = cpdma_chan_create(priv->dma, tx_chan_num(EMAC_DEF_TX_CH),
@@ -1971,14 +1968,14 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
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
 
@@ -2000,7 +1997,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	if (rc) {
 		dev_err(&pdev->dev, "error in register_netdev\n");
 		rc = -ENODEV;
-		goto no_irq_res;
+		goto no_cpdma_chan;
 	}
 
 
@@ -2015,20 +2012,14 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
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
 static int __devexit davinci_emac_remove(struct platform_device *pdev)
 {
-	struct resource *res;
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct emac_priv *priv = netdev_priv(ndev);
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
 	platform_set_drvdata(pdev, NULL);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
@@ -2056,10 +2045,7 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
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
