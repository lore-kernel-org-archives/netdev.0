From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 08/13] ftgmac100: Request the interrupt only after HW is reset
Date: Sun,  2 Apr 2017 13:35:18 +1000
Message-ID: <20170402033523.9482-9-benh@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48975 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbdDBDgI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 23:36:08 -0400
In-Reply-To: <20170402033523.9482-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt isn't shared, so this will keep it masked
until we have the HW in a known sane state.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index ac22f71..0f7fd20 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1131,12 +1131,6 @@ static int ftgmac100_open(struct net_device *netdev)
 	if (ftgmac100_alloc_rx_buffers(priv))
 		goto err_alloc;
 
-	err = request_irq(netdev->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
-	if (err) {
-		netdev_err(netdev, "failed to request irq %d\n", netdev->irq);
-		goto err_irq;
-	}
-
 	/* When using NC-SI we force the speed to 100Mbit/s full duplex,
 	 *
 	 * Otherwise we leave it set to 0 (no link), the link
@@ -1163,6 +1157,13 @@ static int ftgmac100_open(struct net_device *netdev)
 	/* Initialize NAPI */
 	netif_napi_add(netdev, &priv->napi, ftgmac100_poll, 64);
 
+	/* Grab our interrupt */
+	err = request_irq(netdev->irq, ftgmac100_interrupt, 0, netdev->name, netdev);
+	if (err) {
+		netdev_err(netdev, "failed to request irq %d\n", netdev->irq);
+		goto err_irq;
+	}
+
 	ftgmac100_init_hw(priv);
 	ftgmac100_start_hw(priv);
 
@@ -1193,12 +1194,12 @@ static int ftgmac100_open(struct net_device *netdev)
 err_ncsi:
 	napi_disable(&priv->napi);
 	netif_stop_queue(netdev);
-	netif_napi_del(&priv->napi);
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-err_hw:
 	free_irq(netdev->irq, netdev);
 err_irq:
+	netif_napi_del(&priv->napi);
+err_hw:
 err_alloc:
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 	ftgmac100_free_buffers(priv);
 	ftgmac100_free_rings(priv);
 	return err;
-- 
2.9.3
