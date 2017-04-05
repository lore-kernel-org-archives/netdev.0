From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 09/13] ftgmac100: Move the bulk of inits to a separate function
Date: Wed,  5 Apr 2017 12:28:49 +1000
Message-ID: <20170405022853.8238-10-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50542 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdDECny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:43:54 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link monitoring and error handling code will have to
redo the ring inits and HW setup so move the code out of
ftgmac100_open() into a dedicated function.

This forces a bit of re-ordering of ftgmac100_open() but
nothing dramatic.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 71 +++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index fdb8638..36f2905 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1109,10 +1109,35 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 	return rx;
 }
 
+static int ftgmac100_init_all(struct ftgmac100 *priv, bool ignore_alloc_err)
+{
+	int err = 0;
+
+	/* Re-init descriptors (adjust queue sizes) */
+	ftgmac100_init_rings(priv);
+
+	/* Realloc rx descriptors */
+	err = ftgmac100_alloc_rx_buffers(priv);
+	if (err && !ignore_alloc_err)
+		return err;
+
+	/* Reinit and restart HW */
+	ftgmac100_init_hw(priv);
+	ftgmac100_start_hw(priv);
+
+	/* Re-enable the device */
+	napi_enable(&priv->napi);
+	netif_start_queue(priv->netdev);
+
+	/* Enable all interrupts */
+	iowrite32(priv->int_mask_all, priv->base + FTGMAC100_OFFSET_IER);
+
+	return err;
+}
+
 static int ftgmac100_open(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
-	unsigned int status;
 	int err;
 
 	/* Allocate ring buffers  */
@@ -1122,13 +1147,6 @@ static int ftgmac100_open(struct net_device *netdev)
 		return err;
 	}
 
-	/* Initialize the rings */
-	ftgmac100_init_rings(priv);
-
-	/* Allocate receive buffers */
-	if (ftgmac100_alloc_rx_buffers(priv))
-		goto err_alloc;
-
 	/* When using NC-SI we force the speed to 100Mbit/s full duplex,
 	 *
 	 * Otherwise we leave it set to 0 (no link), the link
@@ -1162,26 +1180,21 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_irq;
 	}
 
-	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv);
-
-	/* Clear stale interrupts */
-	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
-	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
+	/* Start things up */
+	err = ftgmac100_init_all(priv, false);
+	if (err) {
+		netdev_err(netdev, "Failed to allocate packet buffers\n");
+		goto err_alloc;
+	}
 
-	if (netdev->phydev)
+	if (netdev->phydev) {
+		/* If we have a PHY, start polling */
 		phy_start(netdev->phydev);
-	else if (priv->use_ncsi)
+	} else if (priv->use_ncsi) {
+		/* If using NC-SI, set our carrier on and start the stack */
 		netif_carrier_on(netdev);
 
-	napi_enable(&priv->napi);
-	netif_start_queue(netdev);
-
-	/* enable all interrupts */
-	iowrite32(priv->int_mask_all, priv->base + FTGMAC100_OFFSET_IER);
-
-	/* Start the NCSI device */
-	if (priv->use_ncsi) {
+		/* Start the NCSI device */
 		err = ncsi_start_dev(priv->ndev);
 		if (err)
 			goto err_ncsi;
@@ -1189,16 +1202,16 @@ static int ftgmac100_open(struct net_device *netdev)
 
 	return 0;
 
-err_ncsi:
+ err_ncsi:
 	napi_disable(&priv->napi);
 	netif_stop_queue(netdev);
+ err_alloc:
+	ftgmac100_free_buffers(priv);
 	free_irq(netdev->irq, netdev);
-err_irq:
+ err_irq:
 	netif_napi_del(&priv->napi);
-err_hw:
-err_alloc:
+ err_hw:
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-	ftgmac100_free_buffers(priv);
 	ftgmac100_free_rings(priv);
 	return err;
 }
-- 
2.9.3
