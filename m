From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 4/4] ethoc: use system memory as buffer
Date: Mon,  5 Oct 2009 17:33:20 +0800
Message-ID: <1254735200-2718-4-git-send-email-thomas@wytron.com.tw>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
 <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
 <1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Cc: netdev@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr33.hinet.net ([168.95.4.133]:57909 "EHLO msr33.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442AbZJEKC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 06:02:56 -0400
In-Reply-To: <1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enabled the ethoc to allocate system memory as buffer
when there is no dedicated buffer memory.

Some hardware designs may not have dedicated buffer memory such as
on chip or off chip SRAM. In this case, only one memory resource is
supplied in the platform data instead of two. Then a DMA buffer can
be allocated from system memory and used for the transfer.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |   64 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 0c6c7f4..6d82dc6 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -19,6 +19,10 @@
 #include <linux/platform_device.h>
 #include <net/ethoc.h>
 
+static int buffer_size = 0x8000; /* 32 KBytes */
+module_param(buffer_size, int, 0);
+MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
+
 /* register offsets */
 #define	MODER		0x00
 #define	INT_SOURCE	0x04
@@ -167,6 +171,7 @@
  * struct ethoc - driver-private device structure
  * @iobase:	pointer to I/O memory region
  * @membase:	pointer to buffer memory region
+ * @dma_alloc:	dma allocated buffer size
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
  * @dty_tx:	last buffer actually sent
@@ -185,6 +190,7 @@
 struct ethoc {
 	void __iomem *iobase;
 	void __iomem *membase;
+	int dma_alloc;
 
 	unsigned int num_tx;
 	unsigned int cur_tx;
@@ -906,22 +912,19 @@ static int ethoc_probe(struct platform_device *pdev)
 
 	/* obtain buffer memory space */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	if (!res) {
-		dev_err(&pdev->dev, "cannot obtain memory space\n");
-		ret = -ENXIO;
-		goto free;
-	}
-
-	mem = devm_request_mem_region(&pdev->dev, res->start,
+	if (res) {
+		mem = devm_request_mem_region(&pdev->dev, res->start,
 			res->end - res->start + 1, res->name);
-	if (!mem) {
-		dev_err(&pdev->dev, "cannot request memory space\n");
-		ret = -ENXIO;
-		goto free;
+		if (!mem) {
+			dev_err(&pdev->dev, "cannot request memory space\n");
+			ret = -ENXIO;
+			goto free;
+		}
+
+		netdev->mem_start = mem->start;
+		netdev->mem_end   = mem->end;
 	}
 
-	netdev->mem_start = mem->start;
-	netdev->mem_end   = mem->end;
 
 	/* obtain device IRQ number */
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -936,6 +939,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	/* setup driver-private data */
 	priv = netdev_priv(netdev);
 	priv->netdev = netdev;
+	priv->dma_alloc = 0;
 
 	priv->iobase = devm_ioremap_nocache(&pdev->dev, netdev->base_addr,
 			mmio->end - mmio->start + 1);
@@ -945,12 +949,27 @@ static int ethoc_probe(struct platform_device *pdev)
 		goto error;
 	}
 
-	priv->membase = devm_ioremap_nocache(&pdev->dev, netdev->mem_start,
-			mem->end - mem->start + 1);
-	if (!priv->membase) {
-		dev_err(&pdev->dev, "cannot remap memory space\n");
-		ret = -ENXIO;
-		goto error;
+	if (netdev->mem_end) {
+		priv->membase = devm_ioremap_nocache(&pdev->dev,
+			netdev->mem_start, mem->end - mem->start + 1);
+		if (!priv->membase) {
+			dev_err(&pdev->dev, "cannot remap memory space\n");
+			ret = -ENXIO;
+			goto error;
+		}
+	} else {
+		/* Allocate buffer memory */
+		priv->membase = dma_alloc_coherent(NULL,
+			buffer_size, (void *)&netdev->mem_start,
+			GFP_KERNEL);
+		if (!priv->membase) {
+			dev_err(&pdev->dev, "cannot allocate %dB buffer\n",
+				buffer_size);
+			ret = -ENOMEM;
+			goto error;
+		}
+		netdev->mem_end = netdev->mem_start + buffer_size;
+		priv->dma_alloc = buffer_size;
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
@@ -1037,6 +1056,9 @@ free_mdio:
 	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 free:
+	if (priv->dma_alloc)
+		dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
+			netdev->mem_start);
 	free_netdev(netdev);
 out:
 	return ret;
@@ -1062,7 +1084,9 @@ static int ethoc_remove(struct platform_device *pdev)
 			kfree(priv->mdio->irq);
 			mdiobus_free(priv->mdio);
 		}
-
+		if (priv->dma_alloc)
+			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
+				netdev->mem_start);
 		unregister_netdev(netdev);
 		free_netdev(netdev);
 	}
-- 
1.6.2.5

