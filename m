From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] 3c59x: fix PCI resource management
Date: Thu, 2 May 2013 02:40:34 +0400
Message-ID: <201305020240.34487.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:50038 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757711Ab3EAWkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 18:40:43 -0400
Received: by mail-la0-f49.google.com with SMTP id eh20so3325lab.22
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 15:40:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>

The driver wrongly claimed I/O ports at an address returned by pci_iomap() --
even if it was passed an MMIO address.  Fix this by claiming/releasing all PCI
resources in the PCI driver probe()/remove() methods instead and get rid of the
'must_free_region' flag weirdness (why would Cardbus claim anything for us?).

Also, the remove() method was trying to talk to the chip after having disabled
its address decoders (at least on x86) -- fix this and while doing it get rid
of the useless VORTEX_PCI() invocations.

While at it, fix some cases of the overly indented code and the code crossing
a 80-column boundary...

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

---
The patch is against David Miller's 'net-next.git' repo.
Matthew, please test it on one of your 3c59x EISA boards.
Steffen, here's my second try to get this patch past you, the last one was back
in 2009...

Changes since 2009:
- don't change *goto* to *return* in vortex_init_one();
- added a new pci_release_regions() call in pci_iomap() error cleanup code;
- used DRV_NAME in pci_request_regions() call;
- somewhat rephrased the changelog.

 drivers/net/ethernet/3com/3c59x.c |   62 +++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

Index: net-next/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- net-next.orig/drivers/net/ethernet/3com/3c59x.c
+++ net-next/drivers/net/ethernet/3com/3c59x.c
@@ -632,7 +632,6 @@ struct vortex_private {
 		pm_state_valid:1,				/* pci_dev->saved_config_space has sane contents */
 		open:1,
 		medialock:1,
-		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region */
 		large_frames:1,			/* accept large frames */
 		handling_irq:1;			/* private in_irq indicator */
 	/* {get|set}_wol operations are already serialized by rtnl.
@@ -1012,6 +1011,12 @@ static int vortex_init_one(struct pci_de
 	if (rc < 0)
 		goto out;
 
+	rc = pci_request_regions(pdev, DRV_NAME);
+	if (rc < 0) {
+		pci_disable_device(pdev);
+		goto out;
+	}
+
 	unit = vortex_cards_found;
 
 	if (global_use_mmio < 0 && (unit >= MAX_UNITS || use_mmio[unit] < 0)) {
@@ -1027,6 +1032,7 @@ static int vortex_init_one(struct pci_de
 	if (!ioaddr) /* If mapping fails, fall-back to BAR 0... */
 		ioaddr = pci_iomap(pdev, 0, 0);
 	if (!ioaddr) {
+		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		rc = -ENOMEM;
 		goto out;
@@ -1036,6 +1042,7 @@ static int vortex_init_one(struct pci_de
 			   ent->driver_data, unit);
 	if (rc < 0) {
 		pci_iounmap(pdev, ioaddr);
+		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		goto out;
 	}
@@ -1178,11 +1185,6 @@ static int vortex_probe1(struct device *
 
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
@@ -1215,12 +1217,13 @@ static int vortex_probe1(struct device *
 	vp->mii.reg_num_mask = 0x1f;
 
 	/* Makes sure rings are at least 16 byte aligned. */
-	vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct boom_rx_desc) * RX_RING_SIZE
-					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
-					   &vp->rx_ring_dma);
+	vp->rx_ring = pci_alloc_consistent(pdev,
+				sizeof(struct boom_rx_desc) * RX_RING_SIZE +
+				sizeof(struct boom_tx_desc) * TX_RING_SIZE,
+				&vp->rx_ring_dma);
 	retval = -ENOMEM;
 	if (!vp->rx_ring)
-		goto free_region;
+		goto free_device;
 
 	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
 	vp->tx_ring_dma = vp->rx_ring_dma + sizeof(struct boom_rx_desc) * RX_RING_SIZE;
@@ -1480,13 +1483,11 @@ static int vortex_probe1(struct device *
 
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
 	pr_err(PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
@@ -3233,29 +3234,28 @@ static void vortex_remove_one(struct pci
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
+	pci_disable_device(pdev);
 	free_netdev(dev);
 }
 
