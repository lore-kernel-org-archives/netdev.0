From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 4/4] fec_mpc52xx: fix error path
Date: Thu,  8 Jul 2010 16:10:16 +0400
Message-ID: <1278591018-3724-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sean MacLennan <smaclennan@pikatech.com>,
	netdev@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54488 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab0GHMKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 08:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error path in mpc52xx_fec_probe() is broken.
We must free everything that we've allocated.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/fec_mpc52xx.c |   38 +++++++++++++++++---------------------
 1 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 25e6cc6..5f83463 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -875,17 +875,21 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	if (rv) {
 		printk(KERN_ERR DRIVER_NAME ": "
 				"Error while parsing device node resource\n" );
-		return rv;
+		goto err_netdev;
 	}
 	if ((mem.end - mem.start + 1) < sizeof(struct mpc52xx_fec)) {
 		printk(KERN_ERR DRIVER_NAME
 			" - invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
 			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
-		return -EINVAL;
+		rv = -EINVAL;
+		goto err_netdev;
 	}
 
-	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec), DRIVER_NAME))
-		return -EBUSY;
+	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec),
+				DRIVER_NAME)) {
+		rv = -EBUSY;
+		goto err_netdev;
+	}
 
 	/* Init ether ndev with what we have */
 	ndev->netdev_ops	= &mpc52xx_fec_netdev_ops;
@@ -901,7 +905,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 
 	if (!priv->fec) {
 		rv = -ENOMEM;
-		goto probe_error;
+		goto err_mem_region;
 	}
 
 	/* Bestcomm init */
@@ -914,7 +918,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	if (!priv->rx_dmatsk || !priv->tx_dmatsk) {
 		printk(KERN_ERR DRIVER_NAME ": Can not init SDMA tasks\n" );
 		rv = -ENOMEM;
-		goto probe_error;
+		goto err_rx_tx_dmatsk;
 	}
 
 	/* Get the IRQ we need one by one */
@@ -966,33 +970,25 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 
 	rv = register_netdev(ndev);
 	if (rv < 0)
-		goto probe_error;
+		goto err_node;
 
 	/* We're done ! */
 	dev_set_drvdata(&op->dev, ndev);
 
 	return 0;
 
-
-	/* Error handling - free everything that might be allocated */
-probe_error:
-
-	if (priv->phy_node)
-		of_node_put(priv->phy_node);
-	priv->phy_node = NULL;
-
+err_node:
+	of_node_put(priv->phy_node);
 	irq_dispose_mapping(ndev->irq);
-
+err_rx_tx_dmatsk:
 	if (priv->rx_dmatsk)
 		bcom_fec_rx_release(priv->rx_dmatsk);
 	if (priv->tx_dmatsk)
 		bcom_fec_tx_release(priv->tx_dmatsk);
-
-	if (priv->fec)
-		iounmap(priv->fec);
-
+	iounmap(priv->fec);
+err_mem_region:
 	release_mem_region(mem.start, sizeof(struct mpc52xx_fec));
-
+err_netdev:
 	free_netdev(ndev);
 
 	return rv;
-- 
1.7.0.4

