From: bphilips@suse.de
Subject: [PATCH 2/2][RFC] Update e100 driver to use devres.
Date: Tue, 24 Jul 2007 15:42:43 -0700
Message-ID: <1185316963408-git-send-email-bphilips@suse.de>
Cc: Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:36789 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbXGXWmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:42:47 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 6BCEA124DF
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 00:42:46 +0200 (CEST)
In-Reply-To: 11853167964115-git-send-email-bphilips@suse.de
References: 11853167964115-git-send-email-bphilips@suse.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devres manages device resources and is currently used by all libata low level
drivers.   It can greatly reduce the complexity of the error handling on probe
and the device removal functions.

For example the e100_free() function and all of the gotos in e100_probe have
been removed.  Also, e100_remove() has been deleted and replaced with a much
simpler netdev_pci_remove_one() function that should be able to handle any PCI
net device that doesn't require any teardown besides resource deallocation.

Applies against 2.6.22.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/e100.c |   73 +++++++++++++----------------------------------------
 1 file changed, 19 insertions(+), 54 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2514,18 +2514,11 @@ static int e100_do_ioctl(struct net_devi
 
 static int e100_alloc(struct nic *nic)
 {
-	nic->mem = pci_alloc_consistent(nic->pdev, sizeof(struct mem),
-		&nic->dma_addr);
-	return nic->mem ? 0 : -ENOMEM;
-}
+	struct device *dev = &nic->pdev->dev;
 
-static void e100_free(struct nic *nic)
-{
-	if(nic->mem) {
-		pci_free_consistent(nic->pdev, sizeof(struct mem),
-			nic->mem, nic->dma_addr);
-		nic->mem = NULL;
-	}
+	nic->mem = dmam_alloc_coherent(dev, sizeof(struct mem),
+		&nic->dma_addr, GFP_ATOMIC);
+	return nic->mem ? 0 : -ENOMEM;
 }
 
 static int e100_open(struct net_device *netdev)
@@ -2552,7 +2545,7 @@ static int __devinit e100_probe(struct p
 	struct nic *nic;
 	int err;
 
-	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
+	if (!(netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct nic)))) {
 		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
 		return -ENOMEM;
@@ -2582,26 +2575,26 @@ static int __devinit e100_probe(struct p
 	nic->msg_enable = (1 << debug) - 1;
 	pci_set_drvdata(pdev, netdev);
 
-	if((err = pci_enable_device(pdev))) {
+	if ((err = pcim_enable_device(pdev))) {
 		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");
-		goto err_out_free_dev;
+		return err;
 	}
 
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		DPRINTK(PROBE, ERR, "Cannot find proper PCI device "
 			"base address, aborting.\n");
 		err = -ENODEV;
-		goto err_out_disable_pdev;
+		return err;
 	}
 
 	if((err = pci_request_regions(pdev, DRV_NAME))) {
 		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
-		goto err_out_disable_pdev;
+		return err;
 	}
 
 	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
+		return err;
 	}
 
 	SET_MODULE_OWNER(netdev);
@@ -2610,11 +2603,11 @@ static int __devinit e100_probe(struct p
 	if (use_io)
 		DPRINTK(PROBE, INFO, "using i/o access mode\n");
 
-	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
+	nic->csr = pcim_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
 	if(!nic->csr) {
 		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
 		err = -ENOMEM;
-		goto err_out_free_res;
+		return err;
 	}
 
 	if(ent->driver_data)
@@ -2647,11 +2640,11 @@ static int __devinit e100_probe(struct p
 
 	if((err = e100_alloc(nic))) {
 		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
-		goto err_out_iounmap;
+		return err;
 	}
 
 	if((err = e100_eeprom_load(nic)))
-		goto err_out_free;
+		return err;
 
 	e100_phy_init(nic);
 
@@ -2661,8 +2654,8 @@ static int __devinit e100_probe(struct p
 		if (!eeprom_bad_csum_allow) {
 			DPRINTK(PROBE, ERR, "Invalid MAC address from "
 			        "EEPROM, aborting.\n");
-			err = -EAGAIN;
-			goto err_out_free;
+
+			return -EAGAIN;
 		} else {
 			DPRINTK(PROBE, ERR, "Invalid MAC address from EEPROM, "
 			        "you MUST configure one.\n");
@@ -2682,7 +2675,7 @@ static int __devinit e100_probe(struct p
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
-		goto err_out_free;
+		return err;
 	}
 
 	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
@@ -2692,36 +2685,8 @@ static int __devinit e100_probe(struct p
 		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
 
 	return 0;
-
-err_out_free:
-	e100_free(nic);
-err_out_iounmap:
-	pci_iounmap(pdev, nic->csr);
-err_out_free_res:
-	pci_release_regions(pdev);
-err_out_disable_pdev:
-	pci_disable_device(pdev);
-err_out_free_dev:
-	pci_set_drvdata(pdev, NULL);
-	free_netdev(netdev);
-	return err;
 }
 
-static void __devexit e100_remove(struct pci_dev *pdev)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-
-	if(netdev) {
-		struct nic *nic = netdev_priv(netdev);
-		unregister_netdev(netdev);
-		e100_free(nic);
-		iounmap(nic->csr);
-		free_netdev(netdev);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
-	}
-}
 
 #ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -2825,7 +2790,7 @@ static pci_ers_result_t e100_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	if (pci_enable_device(pdev)) {
+	if (pcim_enable_device(pdev)) {
 		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -2872,7 +2837,7 @@ static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
 	.id_table =     e100_id_table,
 	.probe =        e100_probe,
-	.remove =       __devexit_p(e100_remove),
+	.remove =       __devexit_p(netdev_pci_remove_one),
 #ifdef CONFIG_PM
 	/* Power Management hooks */
 	.suspend =      e100_suspend,
