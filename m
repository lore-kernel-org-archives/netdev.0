From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 6/7] net/fsl-pq-mdio: coalesce multiple memory allocations into one
Date: Wed, 29 Aug 2012 13:08:02 -0500
Message-ID: <1346263683-3664-6-git-send-email-timur@freescale.com>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:31126
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754468Ab2H2SIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 14:08:39 -0400
In-Reply-To: <1346263683-3664-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of the new mdiobus_alloc_size() function to combine three
different memory allocations into one.  This also simplies the error
handling.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   42 ++++++++-----------------
 1 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 7eef1bb..ebd4638 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -68,6 +68,7 @@ struct fsl_pq_mdio {
 struct fsl_pq_mdio_priv {
 	void __iomem *map;
 	struct fsl_pq_mii __iomem *regs;
+	int irqs[PHY_MAX_ADDR];
 };
 
 /*
@@ -359,26 +360,21 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 
 	dev_dbg(&pdev->dev, "found %s compatible node\n", id->compatible);
 
-	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
+	new_bus = mdiobus_alloc_size(sizeof(*priv));
+	if (!new_bus)
 		return -ENOMEM;
 
-	new_bus = mdiobus_alloc();
-	if (!new_bus) {
-		err = -ENOMEM;
-		goto err_free_priv;
-	}
-
+	priv = new_bus->priv;
 	new_bus->name = "Freescale PowerQUICC MII Bus",
 	new_bus->read = &fsl_pq_mdio_read;
 	new_bus->write = &fsl_pq_mdio_write;
 	new_bus->reset = &fsl_pq_mdio_reset;
-	new_bus->priv = priv;
+	new_bus->irq = priv->irqs;
 
 	err = of_address_to_resource(np, 0, &res);
 	if (err < 0) {
 		dev_err(&pdev->dev, "could not obtain address information\n");
-		goto err_free_bus;
+		goto error;
 	}
 
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s@%llx", np->name,
@@ -387,7 +383,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	priv->map = of_iomap(np, 0);
 	if (!priv->map) {
 		err = -ENOMEM;
-		goto err_free_bus;
+		goto error;
 	}
 
 	/*
@@ -399,16 +395,10 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	if (data->mii_offset > resource_size(&res)) {
 		dev_err(&pdev->dev, "invalid register map\n");
 		err = -EINVAL;
-		goto err_unmap_regs;
+		goto error;
 	}
 	priv->regs = priv->map + data->mii_offset;
 
-	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
-	if (NULL == new_bus->irq) {
-		err = -ENOMEM;
-		goto err_unmap_regs;
-	}
-
 	new_bus->parent = &pdev->dev;
 	dev_set_drvdata(&pdev->dev, new_bus);
 
@@ -446,19 +436,17 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	if (err) {
 		dev_err(&pdev->dev, "cannot register %s as MDIO bus\n",
 			new_bus->name);
-		goto err_free_irqs;
+		goto error;
 	}
 
 	return 0;
 
-err_free_irqs:
-	kfree(new_bus->irq);
-err_unmap_regs:
-	iounmap(priv->map);
-err_free_bus:
+error:
+	if (priv->map)
+		iounmap(priv->map);
+
 	kfree(new_bus);
-err_free_priv:
-	kfree(priv);
+
 	return err;
 }
 
@@ -474,9 +462,7 @@ static int fsl_pq_mdio_remove(struct platform_device *pdev)
 	dev_set_drvdata(device, NULL);
 
 	iounmap(priv->map);
-	bus->priv = NULL;
 	mdiobus_free(bus);
-	kfree(priv);
 
 	return 0;
 }
-- 
1.7.3.4
