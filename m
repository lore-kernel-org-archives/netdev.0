From: Jeff Garzik <jgarzik@pobox.com>
Subject: [patch 2/2][fyi] alloc_ei_netdev() example: ne2k-pci
Date: Mon, 1 Sep 2003 13:56:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901175657.GA31874@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1120  -> 1.1121 
#	drivers/net/ne2k-pci.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/01	jgarzik@redhat.com	1.1121
# [netdrvr ne2k-pci] allocate netdev+8390 struct using new alloc_ei_netdev()
# 
# Also, call pci_disable_device() in PCI ->remove handler,
# to match pci_enable_device() in PCI ->probe handler.
# --------------------------------------------
#
diff -Nru a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c	Mon Sep  1 13:48:30 2003
+++ b/drivers/net/ne2k-pci.c	Mon Sep  1 13:48:30 2003
@@ -259,7 +259,8 @@
 		}
 	}
 
-	dev = alloc_etherdev(0);
+	/* Allocate net_device, dev->priv; fill in 8390 specific dev fields. */
+	dev = alloc_ei_netdev();
 	if (!dev) {
 		printk (KERN_ERR PFX "cannot allocate ethernet device\n");
 		goto err_out_free_res;
@@ -330,13 +331,6 @@
 	dev->base_addr = ioaddr;
 	pci_set_drvdata(pdev, dev);
 
-	/* Allocate dev->priv and fill in 8390 specific dev fields. */
-	if (ethdev_init(dev)) {
-		printk (KERN_ERR "ne2kpci(%s): unable to get memory for dev->priv.\n",
-			pdev->slot_name);
-		goto err_out_free_netdev;
-	}
-
 	ei_status.name = pci_clone_list[chip_idx].name;
 	ei_status.tx_start_page = start_page;
 	ei_status.stop_page = stop_page;
@@ -365,7 +359,7 @@
 
 	i = register_netdev(dev);
 	if (i)
-		goto err_out_free_8390;
+		goto err_out_free_netdev;
 
 	printk("%s: %s found at %#lx, IRQ %d, ",
 		   dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq);
@@ -376,8 +370,6 @@
 
 	return 0;
 
-err_out_free_8390:
-	kfree(dev->priv);
 err_out_free_netdev:
 	kfree (dev);
 err_out_free_res:
@@ -634,7 +626,7 @@
 
 	unregister_netdev(dev);
 	release_region(dev->base_addr, NE_IO_EXTENT);
-	kfree(dev->priv);
+	pci_disable_device(pdev);
 	kfree(dev);
 	pci_set_drvdata(pdev, NULL);
 }
