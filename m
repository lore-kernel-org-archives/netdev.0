From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 3/4] Altera TSE: Fix Panic in probe routine when phy probe fails
Date: Thu, 24 Apr 2014 16:58:10 -0500
Message-ID: <1398376691-15265-4-git-send-email-vbridgers2013@gmail.com>
References: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, Vince Bridgers <vbridger@altera.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:57675 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbaDXWCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:02:40 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so2428120pbc.35
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:02:39 -0700 (PDT)
In-Reply-To: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridger@altera.com>

This patch addresses a fault in the error recovery path of the probe
routine where the netdev structure was not being unregistered properly
leading to a panic only when the phy probe failed.

Abbreviated panic stack seen is as follows:

(free_netdev+0xXX) from (altera_tse_probe+0xXX)
(altera_tse_probe+0xXX) from (platform_drv_probe+0xXX)
(platform_drv_probe+0xXX) from (driver_probe_device+0xXX)
(driver_probe_device+0xXX) from (__driver_attach+0xXX)
(__driver_attach+0xXX) from (bus_for_each_dev+0xXX)
(bus_for_each_dev+0xXX) from (driver_attach+0xXX)
(driver_attach+0xXX) from (bus_add_driver+0xXX)
(bus_add_driver+0xXX) from (driver_register+0xXX)
(driver_register+0xXX) from (__platform_driver_register+0xXX)
(__platform_driver_register+0xXX) from (altera_tse_driver_init+0xXX)
(altera_tse_driver_init+0xXX) from (do_one_initcall+0xXX)
(do_one_initcall+0xXX) from (kernel_init_freeable+0xXX)
(kernel_init_freeable+0xXX) from (kernel_init+0xXX)
(kernel_init+0xXX) from (ret_from_fork+0xXX)

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c |   45 +++++++++++++------------
 1 file changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 6371283..e44a4ae 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1245,7 +1245,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 		/* Get the mapped address to the SGDMA descriptor memory */
 		ret = request_and_map(pdev, "s1", &dma_res, &descmap);
 		if (ret)
-			goto out_free;
+			goto err_free_netdev;
 
 		/* Start of that memory is for transmit descriptors */
 		priv->tx_dma_desc = descmap;
@@ -1264,24 +1264,24 @@ static int altera_tse_probe(struct platform_device *pdev)
 		if (upper_32_bits(priv->rxdescmem_busaddr)) {
 			dev_dbg(priv->device,
 				"SGDMA bus addresses greater than 32-bits\n");
-			goto out_free;
+			goto err_free_netdev;
 		}
 		if (upper_32_bits(priv->txdescmem_busaddr)) {
 			dev_dbg(priv->device,
 				"SGDMA bus addresses greater than 32-bits\n");
-			goto out_free;
+			goto err_free_netdev;
 		}
 	} else if (priv->dmaops &&
 		   priv->dmaops->altera_dtype == ALTERA_DTYPE_MSGDMA) {
 		ret = request_and_map(pdev, "rx_resp", &dma_res,
 				      &priv->rx_dma_resp);
 		if (ret)
-			goto out_free;
+			goto err_free_netdev;
 
 		ret = request_and_map(pdev, "tx_desc", &dma_res,
 				      &priv->tx_dma_desc);
 		if (ret)
-			goto out_free;
+			goto err_free_netdev;
 
 		priv->txdescmem = resource_size(dma_res);
 		priv->txdescmem_busaddr = dma_res->start;
@@ -1289,13 +1289,13 @@ static int altera_tse_probe(struct platform_device *pdev)
 		ret = request_and_map(pdev, "rx_desc", &dma_res,
 				      &priv->rx_dma_desc);
 		if (ret)
-			goto out_free;
+			goto err_free_netdev;
 
 		priv->rxdescmem = resource_size(dma_res);
 		priv->rxdescmem_busaddr = dma_res->start;
 
 	} else {
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	if (!dma_set_mask(priv->device, DMA_BIT_MASK(priv->dmaops->dmamask)))
@@ -1304,26 +1304,26 @@ static int altera_tse_probe(struct platform_device *pdev)
 	else if (!dma_set_mask(priv->device, DMA_BIT_MASK(32)))
 		dma_set_coherent_mask(priv->device, DMA_BIT_MASK(32));
 	else
-		goto out_free;
+		goto err_free_netdev;
 
 	/* MAC address space */
 	ret = request_and_map(pdev, "control_port", &control_port,
 			      (void __iomem **)&priv->mac_dev);
 	if (ret)
-		goto out_free;
+		goto err_free_netdev;
 
 	/* xSGDMA Rx Dispatcher address space */
 	ret = request_and_map(pdev, "rx_csr", &dma_res,
 			      &priv->rx_dma_csr);
 	if (ret)
-		goto out_free;
+		goto err_free_netdev;
 
 
 	/* xSGDMA Tx Dispatcher address space */
 	ret = request_and_map(pdev, "tx_csr", &dma_res,
 			      &priv->tx_dma_csr);
 	if (ret)
-		goto out_free;
+		goto err_free_netdev;
 
 
 	/* Rx IRQ */
@@ -1331,7 +1331,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	if (priv->rx_irq == -ENXIO) {
 		dev_err(&pdev->dev, "cannot obtain Rx IRQ\n");
 		ret = -ENXIO;
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	/* Tx IRQ */
@@ -1339,7 +1339,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	if (priv->tx_irq == -ENXIO) {
 		dev_err(&pdev->dev, "cannot obtain Tx IRQ\n");
 		ret = -ENXIO;
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	/* get FIFO depths from device tree */
@@ -1347,14 +1347,14 @@ static int altera_tse_probe(struct platform_device *pdev)
 				 &priv->rx_fifo_depth)) {
 		dev_err(&pdev->dev, "cannot obtain rx-fifo-depth\n");
 		ret = -ENXIO;
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	if (of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
 				 &priv->rx_fifo_depth)) {
 		dev_err(&pdev->dev, "cannot obtain tx-fifo-depth\n");
 		ret = -ENXIO;
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	/* get hash filter settings for this instance */
@@ -1403,7 +1403,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	      ((priv->phy_addr >= 0) && (priv->phy_addr < PHY_MAX_ADDR)))) {
 		dev_err(&pdev->dev, "invalid phy-addr specified %d\n",
 			priv->phy_addr);
-		goto out_free;
+		goto err_free_netdev;
 	}
 
 	/* Create/attach to MDIO bus */
@@ -1411,7 +1411,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 				     atomic_add_return(1, &instance_count));
 
 	if (ret)
-		goto out_free;
+		goto err_free_netdev;
 
 	/* initialize netdev */
 	ether_setup(ndev);
@@ -1448,7 +1448,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	ret = register_netdev(ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register TSE net device\n");
-		goto out_free_mdio;
+		goto err_register_netdev;
 	}
 
 	platform_set_drvdata(pdev, ndev);
@@ -1465,13 +1465,16 @@ static int altera_tse_probe(struct platform_device *pdev)
 	ret = init_phy(ndev);
 	if (ret != 0) {
 		netdev_err(ndev, "Cannot attach to PHY (error: %d)\n", ret);
-		goto out_free_mdio;
+		goto err_init_phy;
 	}
 	return 0;
 
-out_free_mdio:
+err_init_phy:
+	unregister_netdev(ndev);
+err_register_netdev:
+	netif_napi_del(&priv->napi);
 	altera_tse_mdio_destroy(ndev);
-out_free:
+err_free_netdev:
 	free_netdev(ndev);
 	return ret;
 }
-- 
1.7.9.5
