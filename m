From: Brandon Philips <bphilips@suse.de>
Subject: [patch 2/4] Update e100 driver to use devres.
Date: Wed, 15 Aug 2007 11:59:49 -0700
Message-ID: <20070815185949.GC7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename="e100-devres.patch"
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

devres manages device resources and is currently used by all libata low level
drivers.   When devres is used in a driver the complexity of error handling in
the device probe and remove functions can be reduced.

In this case e100_free(), e100_remove() and all of the gotos in e100_probe have
been removed.  

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/e100.c |   78 +++++++++++++----------------------------------------
 1 file changed, 20 insertions(+), 58 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2517,18 +2517,11 @@ static int e100_do_ioctl(struct net_devi
 
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
@@ -2554,8 +2547,10 @@ static int __devinit e100_probe(struct p
 	struct net_device *netdev;
 	struct nic *nic;
 	int err;
+	void __iomem **iomap;
+	int bar;
 
-	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
+	if (!(netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct nic)))) {
 		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
 		return -ENOMEM;
@@ -2585,26 +2580,28 @@ static int __devinit e100_probe(struct p
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
 
-	if((err = pci_request_regions(pdev, DRV_NAME))) {
+	bar = use_io ? 1 : 0;
+	if((err = pcim_iomap_regions(pdev, 1 << bar, DRV_NAME))) {
 		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
-		goto err_out_disable_pdev;
+		return err;
 	}
+	iomap = pcim_iomap_table(pdev)[bar];
 
 	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
-		goto err_out_free_res;
+		return err;
 	}
 
 	SET_MODULE_OWNER(netdev);
@@ -2613,12 +2610,6 @@ static int __devinit e100_probe(struct p
 	if (use_io)
 		DPRINTK(PROBE, INFO, "using i/o access mode\n");
 
-	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
-	if(!nic->csr) {
-		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
-		err = -ENOMEM;
-		goto err_out_free_res;
-	}
 
 	if(ent->driver_data)
 		nic->flags |= ich;
@@ -2650,11 +2641,11 @@ static int __devinit e100_probe(struct p
 
 	if((err = e100_alloc(nic))) {
 		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
-		goto err_out_iounmap;
+		return err;
 	}
 
 	if((err = e100_eeprom_load(nic)))
-		goto err_out_free;
+		return err;
 
 	e100_phy_init(nic);
 
@@ -2664,8 +2655,7 @@ static int __devinit e100_probe(struct p
 		if (!eeprom_bad_csum_allow) {
 			DPRINTK(PROBE, ERR, "Invalid MAC address from "
 			        "EEPROM, aborting.\n");
-			err = -EAGAIN;
-			goto err_out_free;
+			return -EAGAIN;
 		} else {
 			DPRINTK(PROBE, ERR, "Invalid MAC address from EEPROM, "
 			        "you MUST configure one.\n");
@@ -2685,7 +2675,7 @@ static int __devinit e100_probe(struct p
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
-		goto err_out_free;
+		return err;
 	}
 
 	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
@@ -2695,36 +2685,8 @@ static int __devinit e100_probe(struct p
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
@@ -2875,7 +2837,7 @@ static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
 	.id_table =     e100_id_table,
 	.probe =        e100_probe,
-	.remove =       __devexit_p(e100_remove),
+	.remove =       __devexit_p(netdev_pci_remove_one),
 #ifdef CONFIG_PM
 	/* Power Management hooks */
 	.suspend =      e100_suspend,

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
