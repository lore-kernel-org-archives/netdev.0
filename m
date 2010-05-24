From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH] ethoc: fix null dereference in ethoc_probe
Date: Mon, 24 May 2010 10:44:02 +0800
Message-ID: <1274669042-1901-1-git-send-email-thomas@wytron.com.tw>
References: <20100522155455.GE22515@bicker>
Cc: linux-kernel@vger.kernel.org, thierry.reding@avionic-design.de,
	nios2-dev@sopc.et.ntust.edu.tw, Dan Carpenter <error27@gmail.com>,
	Thomas Chou <thomas@wytron.com.tw>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr12.hinet.net ([168.95.4.112]:65198 "EHLO msr12.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab0EXCpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 May 2010 22:45:04 -0400
In-Reply-To: <20100522155455.GE22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan reported the patch 0baa080c75c: "ethoc: use system memory
as buffer" introduced a potential null dereference.

  1060  free:
  1061          if (priv->dma_alloc)
                    ^^^^^^^^^^^^^^^
	priv can be null here.

He also suggested that the error handling is not complete.

This patch fixes the null priv issue and improves resources
releasing in ethoc_probe() and ethoc_remove().

Reported-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |   34 ++++++++++++++++++++++++++++++----
 1 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index a8d9250..fddd5f5 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -174,6 +174,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @iobase:	pointer to I/O memory region
  * @membase:	pointer to buffer memory region
  * @dma_alloc:	dma allocated buffer size
+ * @io_region_size:	I/O memory region size
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
  * @dty_tx:	last buffer actually sent
@@ -193,6 +194,7 @@ struct ethoc {
 	void __iomem *iobase;
 	void __iomem *membase;
 	int dma_alloc;
+	resource_size_t io_region_size;
 
 	unsigned int num_tx;
 	unsigned int cur_tx;
@@ -944,6 +946,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	priv = netdev_priv(netdev);
 	priv->netdev = netdev;
 	priv->dma_alloc = 0;
+	priv->io_region_size = mmio->end - mmio->start + 1;
 
 	priv->iobase = devm_ioremap_nocache(&pdev->dev, netdev->base_addr,
 			resource_size(mmio));
@@ -1049,20 +1052,34 @@ static int ethoc_probe(struct platform_device *pdev)
 	ret = register_netdev(netdev);
 	if (ret < 0) {
 		dev_err(&netdev->dev, "failed to register interface\n");
-		goto error;
+		goto error2;
 	}
 
 	goto out;
 
+error2:
+	netif_napi_del(&priv->napi);
 error:
 	mdiobus_unregister(priv->mdio);
 free_mdio:
 	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 free:
-	if (priv->dma_alloc)
-		dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
-			netdev->mem_start);
+	if (priv) {
+		if (priv->dma_alloc)
+			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
+					  netdev->mem_start);
+		else if (priv->membase)
+			devm_iounmap(&pdev->dev, priv->membase);
+		if (priv->iobase)
+			devm_iounmap(&pdev->dev, priv->iobase);
+	}
+	if (mem)
+		devm_release_mem_region(&pdev->dev, mem->start,
+					mem->end - mem->start + 1);
+	if (mmio)
+		devm_release_mem_region(&pdev->dev, mmio->start,
+					mmio->end - mmio->start + 1);
 	free_netdev(netdev);
 out:
 	return ret;
@@ -1080,6 +1097,7 @@ static int ethoc_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 
 	if (netdev) {
+		netif_napi_del(&priv->napi);
 		phy_disconnect(priv->phy);
 		priv->phy = NULL;
 
@@ -1091,6 +1109,14 @@ static int ethoc_remove(struct platform_device *pdev)
 		if (priv->dma_alloc)
 			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
 				netdev->mem_start);
+		else {
+			devm_iounmap(&pdev->dev, priv->membase);
+			devm_release_mem_region(&pdev->dev, netdev->mem_start,
+				netdev->mem_end - netdev->mem_start + 1);
+		}
+		devm_iounmap(&pdev->dev, priv->iobase);
+		devm_release_mem_region(&pdev->dev, netdev->base_addr,
+			priv->io_region_size);
 		unregister_netdev(netdev);
 		free_netdev(netdev);
 	}
-- 
1.7.1.86.g0e460

