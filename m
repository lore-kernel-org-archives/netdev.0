From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v3] 3c59x: fix PCI resource management
Date: Fri, 10 May 2013 01:14:07 +0400
Message-ID: <201305100114.08149.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:63135 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab3EIVOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 17:14:07 -0400
Received: by mail-lb0-f181.google.com with SMTP id w10so3578984lbi.12
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 14:14:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>

The driver wrongly claimed I/O ports at an address returned by pci_iomap() --
even if it was passed an MMIO address.  Fix this by claiming/releasing all PCI
resources in the PCI driver's probe()/remove() methods instead and get rid of
'must_free_region' flag weirdness (why would Cardbus claim anything for us?).

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against David Miller's 'net.git' repo.

Changes since version 2:
- removed the fix to the PCI driver's remove() method where pci_disable_device()
  call was  moved to the end of the method because no pcibios_disable_device()
  implementation disables the address decoders anymore;
- removed all fixes to the 80-column rule violations;
- removed changes deleting VORTEX_PCI() from the PCI driver's remove() method;
- amended the changelog, removed Andrew Morton's signoff since all his changes
  have been removed.

Changes since 2009:
- don't change *goto* to *return* in vortex_init_one();
- added a new pci_release_regions() call in pci_iomap() error cleanup code;
- used DRV_NAME in pci_request_regions() call;
- somewhat rephrased the changelog.

 drivers/net/ethernet/3com/3c59x.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

Index: net/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- net.orig/drivers/net/ethernet/3com/3c59x.c
+++ net/drivers/net/ethernet/3com/3c59x.c
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
@@ -1220,7 +1222,7 @@ static int vortex_probe1(struct device *
 					   &vp->rx_ring_dma);
 	retval = -ENOMEM;
 	if (!vp->rx_ring)
-		goto free_region;
+		goto free_device;
 
 	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
 	vp->tx_ring_dma = vp->rx_ring_dma + sizeof(struct boom_rx_desc) * RX_RING_SIZE;
@@ -1484,9 +1486,7 @@ free_ring:
 							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
 						vp->rx_ring,
 						vp->rx_ring_dma);
-free_region:
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vci->io_size);
+free_device:
 	free_netdev(dev);
 	pr_err(PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
@@ -3254,8 +3254,9 @@ static void vortex_remove_one(struct pci
 							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
 						vp->rx_ring,
 						vp->rx_ring_dma);
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vp->io_size);
+
+	pci_release_regions(pdev);
+
 	free_netdev(dev);
 }
 
