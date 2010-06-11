From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 7/7] ethoc: use devres resource management
Date: Fri, 11 Jun 2010 14:47:40 +0200
Message-ID: <1276260460-14531-7-git-send-email-jonas@southpole.se>
References: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49430 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760229Ab0FKMrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:53 -0400
In-Reply-To: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The point of using the devres resource management routines is that they
simplify the driver by taking care of releasing resources on failure and
release.  A recent commit added a bunch of error handling that is unnecessary
in this context.

This patch removes this redundant error handling, as well as using
dmam_alloc_coherent in place of dma_alloc_coherent in order to use this
framework consistenly throughout the driver.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   28 +---------------------------
 1 files changed, 1 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 1681f08..37ce8ac 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -964,7 +964,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		}
 	} else {
 		/* Allocate buffer memory */
-		priv->membase = dma_alloc_coherent(NULL,
+		priv->membase = dmam_alloc_coherent(&pdev->dev,
 			buffer_size, (void *)&netdev->mem_start,
 			GFP_KERNEL);
 		if (!priv->membase) {
@@ -1074,21 +1074,6 @@ free_mdio:
 	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 free:
-	if (priv) {
-		if (priv->dma_alloc)
-			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
-					  netdev->mem_start);
-		else if (priv->membase)
-			devm_iounmap(&pdev->dev, priv->membase);
-		if (priv->iobase)
-			devm_iounmap(&pdev->dev, priv->iobase);
-	}
-	if (mem)
-		devm_release_mem_region(&pdev->dev, mem->start,
-					mem->end - mem->start + 1);
-	if (mmio)
-		devm_release_mem_region(&pdev->dev, mmio->start,
-					mmio->end - mmio->start + 1);
 	free_netdev(netdev);
 out:
 	return ret;
@@ -1115,17 +1100,6 @@ static int ethoc_remove(struct platform_device *pdev)
 			kfree(priv->mdio->irq);
 			mdiobus_free(priv->mdio);
 		}
-		if (priv->dma_alloc)
-			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
-				netdev->mem_start);
-		else {
-			devm_iounmap(&pdev->dev, priv->membase);
-			devm_release_mem_region(&pdev->dev, netdev->mem_start,
-				netdev->mem_end - netdev->mem_start + 1);
-		}
-		devm_iounmap(&pdev->dev, priv->iobase);
-		devm_release_mem_region(&pdev->dev, netdev->base_addr,
-			priv->io_region_size);
 		unregister_netdev(netdev);
 		free_netdev(netdev);
 	}
-- 
1.7.0.4

