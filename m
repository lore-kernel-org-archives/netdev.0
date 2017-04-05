From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 08/13] ftgmac100: Request the interrupt only after HW is reset
Date: Wed,  5 Apr 2017 12:28:48 +1000
Message-ID: <20170405022853.8238-9-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50542 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751870AbdDECnx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:43:53 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt isn't shared, so this will keep it masked
until we have the HW in a known sane state.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bb444d2..fdb8638 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1129,12 +1129,6 @@ static int ftgmac100_open(struct net_device *netdev)
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
@@ -1161,6 +1155,13 @@ static int ftgmac100_open(struct net_device *netdev)
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
 
@@ -1191,12 +1192,12 @@ static int ftgmac100_open(struct net_device *netdev)
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
