From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 01/13] ftgmac100: Use netdev->irq instead of private copy
Date: Wed,  5 Apr 2017 12:28:41 +1000
Message-ID: <20170405022853.8238-2-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48177 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754971AbdDEC3v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:29:51 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a placeholder already for the irq, use it

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 928b0df..bf7b1c0 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -55,7 +55,6 @@ struct ftgmac100_descs {
 struct ftgmac100 {
 	struct resource *res;
 	void __iomem *base;
-	int irq;
 
 	struct ftgmac100_descs *descs;
 	dma_addr_t descs_dma_addr;
@@ -1119,9 +1118,9 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_alloc;
 	}
 
-	err = request_irq(priv->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
+	err = request_irq(netdev->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
 	if (err) {
-		netdev_err(netdev, "failed to request irq %d\n", priv->irq);
+		netdev_err(netdev, "failed to request irq %d\n", netdev->irq);
 		goto err_irq;
 	}
 
@@ -1168,7 +1167,7 @@ static int ftgmac100_open(struct net_device *netdev)
 	netif_stop_queue(netdev);
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 err_hw:
-	free_irq(priv->irq, netdev);
+	free_irq(netdev->irq, netdev);
 err_irq:
 	ftgmac100_free_buffers(priv);
 err_alloc:
@@ -1194,7 +1193,7 @@ static int ftgmac100_stop(struct net_device *netdev)
 		ncsi_stop_dev(priv->ndev);
 
 	ftgmac100_stop_hw(priv);
-	free_irq(priv->irq, netdev);
+	free_irq(netdev->irq, netdev);
 	ftgmac100_free_buffers(priv);
 
 	return 0;
@@ -1381,7 +1380,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		goto err_ioremap;
 	}
 
-	priv->irq = irq;
+	netdev->irq = irq;
 
 	/* MAC address from chip or random one */
 	ftgmac100_setup_mac(priv);
@@ -1438,7 +1437,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		goto err_register_netdev;
 	}
 
-	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
+	netdev_info(netdev, "irq %d, mapped at %p\n", netdev->irq, priv->base);
 
 	return 0;
 
-- 
2.9.3
