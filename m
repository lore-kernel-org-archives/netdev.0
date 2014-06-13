From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH v2] net/nxp/lpc_eth: use devm_ functions
Date: Fri, 13 Jun 2014 23:33:56 +0530
Message-ID: <20140613180356.GA8582@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The various devm_ functions allocate memory that is released when a
driver detaches. This patch uses dmam_alloc_coherent, devm_ioremap
devm_clk_get etc. for data that is allocated in the probe function of
platform device and is only freed in the remove function. The
corresponding free functions are removed and many labels are done
away with.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
v2: undo use of devm_request_irq
Not compile tested
To send to: netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 drivers/net/ethernet/nxp/lpc_eth.c | 31 ++++++++-----------------------
 1 file changed, 8 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 422d9b5..35bdbad9 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1350,7 +1350,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	ndev->irq = irq;
 
 	/* Get clock for the device */
-	pldat->clk = clk_get(&pdev->dev, NULL);
+	pldat->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pldat->clk)) {
 		dev_err(&pdev->dev, "error getting clock.\n");
 		ret = PTR_ERR(pldat->clk);
@@ -1361,7 +1361,8 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Map IO space */
-	pldat->net_base = ioremap(res->start, res->end - res->start + 1);
+	pldat->net_base = devm_ioremap(&pdev->dev, res->start,
+				       resource_size(res));
 	if (!pldat->net_base) {
 		dev_err(&pdev->dev, "failed to map registers\n");
 		ret = -ENOMEM;
@@ -1371,7 +1372,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 			  ndev->name, ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "error requesting interrupt.\n");
-		goto err_out_iounmap;
+		goto err_out_disable_clocks;
 	}
 
 	/* Fill in the fields of the device structure with ethernet values. */
@@ -1407,9 +1408,9 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 		/* Allocate a chunk of memory for the DMA ethernet buffers
 		   and descriptors */
 		pldat->dma_buff_base_v =
-			dma_alloc_coherent(&pldat->pdev->dev,
-					   pldat->dma_buff_size, &dma_handle,
-					   GFP_KERNEL);
+			dmam_alloc_coherent(&pldat->pdev->dev,
+					    pldat->dma_buff_size, &dma_handle,
+					    GFP_KERNEL);
 		if (pldat->dma_buff_base_v == NULL) {
 			ret = -ENOMEM;
 			goto err_out_free_irq;
@@ -1465,7 +1466,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	ret = register_netdev(ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_dma_unmap;
+		goto err_out_free_irq;
 	}
 	platform_set_drvdata(pdev, ndev);
 
@@ -1485,19 +1486,10 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 
 err_out_unregister_netdev:
 	unregister_netdev(ndev);
-err_out_dma_unmap:
-	if (!use_iram_for_net(&pldat->pdev->dev) ||
-	    pldat->dma_buff_size > lpc32xx_return_iram_size())
-		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
-				  pldat->dma_buff_base_v,
-				  pldat->dma_buff_base_p);
 err_out_free_irq:
 	free_irq(ndev->irq, ndev);
-err_out_iounmap:
-	iounmap(pldat->net_base);
 err_out_disable_clocks:
 	clk_disable(pldat->clk);
-	clk_put(pldat->clk);
 err_out_free_dev:
 	free_netdev(ndev);
 err_exit:
@@ -1512,17 +1504,10 @@ static int lpc_eth_drv_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 
-	if (!use_iram_for_net(&pldat->pdev->dev) ||
-	    pldat->dma_buff_size > lpc32xx_return_iram_size())
-		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
-				  pldat->dma_buff_base_v,
-				  pldat->dma_buff_base_p);
 	free_irq(ndev->irq, ndev);
-	iounmap(pldat->net_base);
 	mdiobus_unregister(pldat->mii_bus);
 	mdiobus_free(pldat->mii_bus);
 	clk_disable(pldat->clk);
-	clk_put(pldat->clk);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.1
