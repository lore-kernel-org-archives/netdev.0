From: Sergei Shtylylov <sshtylyov@ru.mvista.com>
Subject: [PATCH] Don't call request_region() for 3C90x chips
Date: Mon, 10 Jul 2006 22:25:49 +0400
Message-ID: <200607102225.49253.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:38883 "HELO
	mail.dev.rtsoft.ru") by vger.kernel.org with SMTP id S1422748AbWGJS07
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:26:59 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's generally not a good idea to call request_region() on an address returned 
by pci_iomap(), even less so on a MMIO address. And there was absolutely no 
point in claiming the region already claimed by the PCI core, especially with 
the same PCI generic owner's name. As this is the only case of the 
must_free_region flag being set, this flag may go away as well...

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
@@ -1084,11 +1083,6 @@ static int __devinit vortex_probe1(struc
 
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
@@ -1125,7 +1119,7 @@ static int __devinit vortex_probe1(struc
 					   &vp->rx_ring_dma);
 	retval = -ENOMEM;
 	if (vp->rx_ring == 0)
-		goto free_region;
+		goto free_netdev;
 
 	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
 	vp->tx_ring_dma = vp->rx_ring_dma + sizeof(struct boom_rx_desc) * 
RX_RING_SIZE;
@@ -1410,9 +1404,7 @@ free_ring:
 							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
 						vp->rx_ring,
 						vp->rx_ring_dma);
-free_region:
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vci->io_size);
+free_netdev:
 	free_netdev(dev);
 	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
@@ -3143,8 +3135,6 @@ static void __devexit vortex_remove_one(
 							+ sizeof(struct boom_tx_desc) * TX_RING_SIZE,
 						vp->rx_ring,
 						vp->rx_ring_dma);
-	if (vp->must_free_region)
-		release_region(dev->base_addr, vp->io_size);
 	free_netdev(dev);
 }
 

