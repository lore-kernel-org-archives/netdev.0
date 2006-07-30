From: Sergei Shtylylov <sshtylyov@ru.mvista.com>
Subject: [PATCH] 3x59x: fix PCI resource management
Date: Sun, 30 Jul 2006 22:51:58 +0400
Message-ID: <200607302251.58427.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:38573 "HELO
	mail.dev.rtsoft.ru") by vger.kernel.org with SMTP id S932404AbWG3SxV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 14:53:21 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver wrongly claimed I/O ports at an address returned by pci_iomap() -- 
even if it was passed an MMIO address. Fix this by claiming/releasing all PCI 
resources in the PCI driver probe/remove handlers instead and get rid of the 
must_free_region flag weirdness (why would Cardbus claim anything for us?).

Also, the remove handler was trying to talk to the chip after having disabled 
its address decoders (at least on x86) -- fix this and get rid of useless 
VORTEX_PCI() calls.

While at it, fix some cases of the overly indented code...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Index: linux-2.6/drivers/net/3c59x.c
===================================================================
--- linux-2.6.orig/drivers/net/3c59x.c
+++ linux-2.6/drivers/net/3c59x.c
@@ -630,7 +630,6 @@ struct vortex_private {
 		pm_state_valid:1,				/* pci_dev->saved_config_space has sane contents */
 		open:1,
 		medialock:1,
-		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region */
 		large_frames:1;			/* accept large frames */
 	int drv_flags;
 	u16 status_enable;
@@ -956,7 +955,13 @@ static int __devinit vortex_init_one(str
 	/* wake up and enable device */		
 	rc = pci_enable_device(pdev);
 	if (rc < 0)
-		goto out;
+		return rc;
+
+	rc = pci_request_regions(pdev, "3c59x");
+	if (rc < 0) {
+		pci_disable_device(pdev);
+		return rc;
+	}
 
 	unit = vortex_cards_found;
 
@@ -976,13 +981,13 @@ static int __devinit vortex_init_one(str
 	rc = vortex_probe1(&pdev->dev, ioaddr, pdev->irq,
 			   ent->driver_data, unit);
 	if (rc < 0) {
-		pci_disable_device(pdev);
-		goto out;
+		pci_release_regions(pdev);
+		pci_disable_device (pdev);
+		return rc;
 	}
 
 	vortex_cards_found++;
 
-out:
 	return rc;
 }
 
@@ -1084,11 +1089,6 @@ static int __devinit vortex_probe1(struc
 
 	/* PCI-only startup logic */
 	if (pdev) {
-		/* EISA resources already marked, so only PCI needs to do this here */
-		/* Ignore return value, because Cardbus drivers already allocate for us */
-		if (request_region(dev->base_addr, vci->io_size, print_name) != NULL)
-			vp->must_free_region = 1;
-
 		/* enable bus-mastering if necessary */		
 		if (vci->flags & PCI_USES_MASTER)
 			pci_set_master(pdev);
@@ -1120,12 +1120,13 @@ static int __devinit vortex_probe1(struc
 	vp->mii.reg_num_mask = 0x1f;
 
 	/* Makes sure rings are at least 16 byte aligned. */
-	vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct boom_rx_desc) * 
RX_RING_SIZE
-					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
+	vp->rx_ring = pci_alloc_consistent(pdev,
+					   sizeof(struct boom_rx_desc) * RX_RING_SIZE +
+					   sizeof(struct boom_tx_desc) * TX_RING_SIZE,
 					   &vp->rx_ring_dma);
 	retval = -ENOMEM;
 	if (vp->rx_ring == 0)
-		goto free_region;
+		goto free_device;
 
 	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
 	vp->tx_ring_dma = vp->rx_ring_dma + sizeof(struct boom_rx_desc) * 
RX_RING_SIZE;
@@ -1406,13 +1407,11 @@ static int __devinit vortex_probe1(struc
 
 free_ring:
 	pci_free_consistent(pdev,
-						sizeof(struct boom_rx_desc) * RX_RING_SIZE
-							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
-						vp->rx_ring,
-						vp->rx_ring_dma);
-free_region:
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vci->io_size);
+			    sizeof(struct boom_rx_desc) * RX_RING_SIZE +
+			    sizeof(struct boom_tx_desc) * TX_RING_SIZE,
+			    vp->rx_ring,
+			    vp->rx_ring_dma);
+free_device:
 	free_netdev(dev);
 	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
@@ -3122,29 +3121,28 @@ static void __devexit vortex_remove_one(
 	vp = netdev_priv(dev);
 
 	if (vp->cb_fn_base)
-		pci_iounmap(VORTEX_PCI(vp), vp->cb_fn_base);
+		pci_iounmap(pdev, vp->cb_fn_base);
 
 	unregister_netdev(dev);
 
-	if (VORTEX_PCI(vp)) {
-		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
-		if (vp->pm_state_valid)
-			pci_restore_state(VORTEX_PCI(vp));
-		pci_disable_device(VORTEX_PCI(vp));
-	}
+	pci_set_power_state(pdev, PCI_D0);	/* Go active */
+	if (vp->pm_state_valid)
+		pci_restore_state(pdev);
+
 	/* Should really use issue_and_wait() here */
 	iowrite16(TotalReset | ((vp->drv_flags & EEPROM_RESET) ? 0x04 : 0x14),
 	     vp->ioaddr + EL3_CMD);
 
-	pci_iounmap(VORTEX_PCI(vp), vp->ioaddr);
+	pci_iounmap(pdev, vp->ioaddr);
 
 	pci_free_consistent(pdev,
-						sizeof(struct boom_rx_desc) * RX_RING_SIZE
-							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
-						vp->rx_ring,
-						vp->rx_ring_dma);
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vp->io_size);
+			    sizeof(struct boom_rx_desc) * RX_RING_SIZE +
+			    sizeof(struct boom_tx_desc) * TX_RING_SIZE,
+			    vp->rx_ring,
+			    vp->rx_ring_dma);
+
+	pci_release_regions(pdev);
+	pci_disable_device (pdev);
 	free_netdev(dev);
 }
 

