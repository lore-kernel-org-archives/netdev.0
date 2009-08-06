From: Andrew Morton <akpm@linux-foundation.org>
Subject: 3x59x-fix-pci-resource-management.patch
Date: Thu, 6 Aug 2009 15:42:23 -0700
Message-ID: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44263 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751777AbZHFWnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 18:43:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Guys, I seem to have been sitting on the below patch for, err, three years.

I generally do this because there's some issue which needs to be
addressed, but the patch didn't address it right.

Can we please have a revisit and work out what we should do with this?

Thanks.


From: Sergei Shtylyov <sshtylyov@ru.mvista.com>

The driver wrongly claimed I/O ports at an address returned by pci_iomap()
-- even if it was passed an MMIO address.  Fix this by claiming/releasing
all PCI resources in the PCI driver probe/remove handlers instead and get
rid of the must_free_region flag weirdness (why would Cardbus claim
anything for us?).

Also, the remove handler was trying to talk to the chip after having
disabled its address decoders (at least on x86) -- fix this and get rid of
useless VORTEX_PCI() calls.

While at it, fix some cases of the overly indented code...

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c59x.c |   66 ++++++++++++++++++++----------------------
 1 file changed, 32 insertions(+), 34 deletions(-)

diff -puN drivers/mtd/devices/Kconfig~3x59x-fix-pci-resource-management drivers/mtd/devices/Kconfig
diff -puN drivers/mtd/devices/Makefile~3x59x-fix-pci-resource-management drivers/mtd/devices/Makefile
diff -puN drivers/mtd/devices/sst25l.c~3x59x-fix-pci-resource-management drivers/mtd/devices/sst25l.c
diff -puN drivers/net/3c59x.c~3x59x-fix-pci-resource-management drivers/net/3c59x.c
--- a/drivers/net/3c59x.c~3x59x-fix-pci-resource-management
+++ a/drivers/net/3c59x.c
@@ -629,7 +629,6 @@ struct vortex_private {
 		pm_state_valid:1,				/* pci_dev->saved_config_space has sane contents */
 		open:1,
 		medialock:1,
-		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region */
 		large_frames:1;			/* accept large frames */
 	int drv_flags;
 	u16 status_enable;
@@ -962,7 +961,13 @@ static int __devinit vortex_init_one(str
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
 
@@ -982,13 +987,13 @@ static int __devinit vortex_init_one(str
 	rc = vortex_probe1(&pdev->dev, ioaddr, pdev->irq,
 			   ent->driver_data, unit);
 	if (rc < 0) {
+		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		goto out;
+		return rc;
 	}
 
 	vortex_cards_found++;
 
-out:
 	return rc;
 }
 
@@ -1125,11 +1130,6 @@ static int __devinit vortex_probe1(struc
 
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
@@ -1160,12 +1160,13 @@ static int __devinit vortex_probe1(struc
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
@@ -1432,13 +1433,11 @@ static int __devinit vortex_probe1(struc
 
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
@@ -3167,29 +3166,28 @@ static void __devexit vortex_remove_one(
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
 
_

