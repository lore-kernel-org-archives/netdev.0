From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [4/14] Orinoco driver updates - add free_orinocodev()
Date: Thu, 24 Feb 2005 14:57:18 +1100
Message-ID: <20050224035718.GE32001@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050224035650.GD32001-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Introduce a free_orinocodev() function into the orinoco driver, used
by the hardware type/initialization modules to free the device
structure in preference to directly calling free_netdev().  At the
moment free_orinocodev() just calls free_netdev().  Future merges will
make it clean up internal scanning state, so merging this now will
reduce the diff noise.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.h	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.h	2005-02-18 12:04:03.000000000 +1100
@@ -107,6 +107,7 @@
 
 extern struct net_device *alloc_orinocodev(int sizeof_card,
 					   int (*hard_reset)(struct orinoco_private *));
+extern void free_orinocodev(struct net_device *dev);
 extern int __orinoco_up(struct net_device *dev);
 extern int __orinoco_down(struct net_device *dev);
 extern int orinoco_stop(struct net_device *dev);
Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-18 13:03:51.846593520 +1100
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
@@ -4131,6 +4136,7 @@
 /********************************************************************/
 
 EXPORT_SYMBOL(alloc_orinocodev);
+EXPORT_SYMBOL(free_orinocodev);
 
 EXPORT_SYMBOL(__orinoco_up);
 EXPORT_SYMBOL(__orinoco_down);
Index: working-2.6/drivers/net/wireless/orinoco_cs.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_cs.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco_cs.c	2005-02-18 12:04:03.000000000 +1100
@@ -235,7 +235,7 @@
 		      dev);
 		unregister_netdev(dev);
 	}
-	free_netdev(dev);
+	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
 /*
Index: working-2.6/drivers/net/wireless/orinoco_pci.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_pci.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco_pci.c	2005-02-18 12:04:03.000000000 +1100
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
--- working-2.6.orig/drivers/net/wireless/orinoco_plx.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco_plx.c	2005-02-18 12:04:03.000000000 +1100
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
--- working-2.6.orig/drivers/net/wireless/orinoco_tmd.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco_tmd.c	2005-02-18 12:04:03.000000000 +1100
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
--- working-2.6.orig/drivers/net/wireless/airport.c	2005-02-18 12:04:03.000000000 +1100
+++ working-2.6/drivers/net/wireless/airport.c	2005-02-18 12:04:03.000000000 +1100
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


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
