From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: [4/8] orinoco: Introduce free_orinocodev() function
Date: Wed, 12 Jan 2005 16:27:11 +1100
Message-ID: <20050112052711.GE30426@localhost.localdomain>
References: <20050112052352.GA30426@localhost.localdomain> <20050112052434.GB30426@localhost.localdomain> <20050112052543.GC30426@localhost.localdomain> <20050112052630.GD30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, orinoco-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050112052630.GD30426@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduce a free_orinocodev() function into the orinoco driver, used
by the hardware type/initialization modules to free the device
structure in preference to directly calling free_netdev().  At the
moment free_orinocodev() just calls free_netdev().  Future merges will
make it clean up internal scanning state, so merging this now will
reduce the diff noise.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.h	2005-01-12 15:22:34.300627960 +1100
+++ working-2.6/drivers/net/wireless/orinoco.h	2005-01-12 15:22:34.360618840 +1100
@@ -107,6 +107,7 @@
 
 extern struct net_device *alloc_orinocodev(int sizeof_card,
 					   int (*hard_reset)(struct orinoco_private *));
+extern void free_orinocodev(struct net_device *dev);
 extern int __orinoco_up(struct net_device *dev);
 extern int __orinoco_down(struct net_device *dev);
 extern int orinoco_stop(struct net_device *dev);
Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-01-12 15:22:34.300627960 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-01-12 15:22:34.362618536 +1100
@@ -2398,6 +2398,11 @@
 
 }
 
+void free_orinocodev(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+
 /********************************************************************/
 /* Wireless extensions                                              */
 /********************************************************************/
Index: working-2.6/drivers/net/wireless/orinoco_cs.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_cs.c	2005-01-12 15:22:34.265633280 +1100
+++ working-2.6/drivers/net/wireless/orinoco_cs.c	2005-01-12 15:22:34.363618384 +1100
@@ -249,7 +249,7 @@
 		      dev);
 		unregister_netdev(dev);
 	}
-	free_netdev(dev);
+	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
 /*
Index: working-2.6/drivers/net/wireless/orinoco_pci.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_pci.c	2005-01-12 15:22:34.330623400 +1100
+++ working-2.6/drivers/net/wireless/orinoco_pci.c	2005-01-12 15:22:34.363618384 +1100
@@ -254,7 +254,7 @@
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 
-		free_netdev(dev);
+		free_orinocodev(dev);
 	}
 
 	if (pci_ioaddr)
@@ -279,7 +279,7 @@
 		iounmap(priv->hw.iobase);
 
 	pci_set_drvdata(pdev, NULL);
-	free_netdev(dev);
+	free_orinocodev(dev);
 
 	pci_disable_device(pdev);
 }
Index: working-2.6/drivers/net/wireless/orinoco_plx.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_plx.c	2005-01-12 15:22:34.330623400 +1100
+++ working-2.6/drivers/net/wireless/orinoco_plx.c	2005-01-12 15:22:34.363618384 +1100
@@ -279,7 +279,7 @@
  fail:
 	free_irq(dev->irq, dev);
  fail_irq:
-	free_netdev(dev);
+	free_orinocodev(dev);
  fail_alloc:
 	pci_iounmap(pdev, mem);
  fail_map:
@@ -304,7 +304,7 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	free_netdev(dev);
+	free_orinocodev(dev);
 
 	release_region(pci_resource_start(pdev, 3), pci_resource_len(pdev, 3));
 
Index: working-2.6/drivers/net/wireless/orinoco_tmd.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_tmd.c	2005-01-12 15:22:34.331623248 +1100
+++ working-2.6/drivers/net/wireless/orinoco_tmd.c	2005-01-12 15:22:34.364618232 +1100
@@ -164,7 +164,7 @@
 out4:
 	pci_iounmap(pdev, mem);
 out3:
-	free_netdev(dev);
+	free_orinocodev(dev);
 out2:
 	release_region(pccard_ioaddr, pccard_iolen);
 out:
@@ -188,7 +188,7 @@
 
 	pci_set_drvdata(pdev, NULL);
 
-	free_netdev(dev);
+	free_orinocodev(dev);
 
 	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
 
Index: working-2.6/drivers/net/wireless/airport.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/airport.c	2005-01-12 15:22:34.265633280 +1100
+++ working-2.6/drivers/net/wireless/airport.c	2005-01-12 15:25:06.000000000 +1100
@@ -149,7 +149,7 @@
 	ssleep(1);
 
 	macio_set_drvdata(mdev, NULL);
-	free_netdev(dev);
+	free_orinocodev(dev);
 
 	return 0;
 }
@@ -211,7 +211,7 @@
 
 	if (macio_request_resource(mdev, 0, "airport")) {
 		printk(KERN_ERR PFX "can't request IO resource !\n");
-		free_netdev(dev);
+		free_orinocodev(dev);
 		return -EBUSY;
 	}
 


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
