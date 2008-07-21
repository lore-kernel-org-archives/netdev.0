From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH 05/10] r6040: call napi_disable when puting down the interface and set lp->dev accordingly.
Date: Mon, 21 Jul 2008 12:32:29 +0200
Message-ID: <200807211232.30809.florian.fainelli@telecomint.eu>
References: <200807131432.46495.florian.fainelli@telecomint.eu> <20080716210138.GB27394@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:56546 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbYGUKdJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 06:33:09 -0400
In-Reply-To: <20080716210138.GB27394@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

Le Wednesday 16 July 2008 23:01:38 Francois Romieu, vous avez =E9crit=A0=
:
> Can you fix the error paths of r6040_init_one as well ?

Patch attached below, are you okay with the other patches ?

--
=46rom: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] r6040: rework init_one error handling

This patch reworks the error handling in r6040_init_one
in order not to leak resources and correcly unmap and release
PCI regions of the MAC. Also prefix printk's with the driver name
for clarity.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 1cafa92..6531ff5 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1054,24 +1054,27 @@ static int __devinit r6040_init_one(struct pci_=
dev *pdev,
=20
 	err =3D pci_enable_device(pdev);
 	if (err)
-		return err;
+		goto err_out;
=20
 	/* this should always be supported */
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	if (err) {
 		printk(KERN_ERR DRV_NAME "32-bit PCI DMA addresses"
 				"not supported by the card\n");
-		return -ENODEV;
+		goto err_out;
 	}
-	if (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	err =3D pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	if (err) {
 		printk(KERN_ERR DRV_NAME "32-bit PCI DMA addresses"
 				"not supported by the card\n");
-		return -ENODEV;
+		goto err_out;
 	}
=20
 	/* IO Size check */
 	if (pci_resource_len(pdev, 0) < io_size) {
-		printk(KERN_ERR "Insufficient PCI resources, aborting\n");
-		return -EIO;
+		printk(KERN_ERR DRV_NAME "Insufficient PCI resources, aborting\n");
+		err =3D -EIO;
+		goto err_out;
 	}
=20
 	pioaddr =3D pci_resource_start(pdev, 0);	/* IO map base address */
@@ -1079,23 +1082,26 @@ static int __devinit r6040_init_one(struct pci_=
dev *pdev,
=20
 	dev =3D alloc_etherdev(sizeof(struct r6040_private));
 	if (!dev) {
-		printk(KERN_ERR "Failed to allocate etherdev\n");
-		return -ENOMEM;
+		printk(KERN_ERR DRV_NAME "Failed to allocate etherdev\n");
+		err =3D -ENOMEM;
+		goto err_out;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp =3D netdev_priv(dev);
=20
-	if (pci_request_regions(pdev, DRV_NAME)) {
+	err =3D pci_request_regions(pdev, DRV_NAME);
+
+	if (err) {
 		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
-		err =3D -ENODEV;
-		goto err_out_disable;
+		goto err_out_free_dev;
 	}
=20
 	ioaddr =3D pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
 		printk(KERN_ERR "ioremap failed for device %s\n",
 			pci_name(pdev));
-		return -EIO;
+		err =3D -EIO;
+		goto err_out_free_res;
 	}
=20
 	/* Init system & device */
@@ -1147,17 +1153,17 @@ static int __devinit r6040_init_one(struct pci_=
dev *pdev,
 	err =3D register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR DRV_NAME ": Failed to register net device\n");
-		goto err_out_res;
+		goto err_out_unmap;
 	}
 	return 0;
=20
-err_out_res:
+err_out_unmap:
+	pci_iounmap(pdev, ioaddr);
+err_out_free_res:
 	pci_release_regions(pdev);
-err_out_disable:
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
+err_out_free_dev:
 	free_netdev(dev);
-
+err_out:
 	return err;
 }
=20
