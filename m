From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c oops in rmmod
Date: Thu, 19 Feb 2004 13:46:17 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402192146.i1JLkHl05440@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When doing rmmod pcnet32 with more than one adapter, the system will oops.
This fix was already applied to 2.6.  Now needed in 2.4.25.  Tested in IA32.

--- linux-2.4.25/drivers/net/jon.pcnet32.c	Thu Feb 19 09:14:17 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 13:32:26 2004
@@ -1700,6 +1700,7 @@
 /* An additional parameter that may be passed in... */
 static int debug = -1;
 static int tx_start_pt = -1;
+static int pcnet32_have_pci;
 
 static int __init pcnet32_init_module(void)
 {
@@ -1712,7 +1713,8 @@
 	tx_start = tx_start_pt;
 
     /* find the PCI devices */
-    pci_module_init(&pcnet32_driver);
+    if (!pci_module_init(&pcnet32_driver))
+	pcnet32_have_pci = 1;
 
     /* should we find any remaining VLbus devices ? */
     if (pcnet32vlb)
@@ -1721,7 +1723,7 @@
     if (cards_found)
 	printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
     
-    return cards_found ? 0 : -ENODEV;
+    return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
 }
 
 static void __exit pcnet32_cleanup_module(void)
@@ -1734,12 +1736,12 @@
 	next_dev = lp->next;
 	unregister_netdev(pcnet32_dev);
 	release_region(pcnet32_dev->base_addr, PCNET32_TOTAL_SIZE);
-	if (lp->pci_dev)
-	    pci_unregister_driver(&pcnet32_driver);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-	kfree(pcnet32_dev);
+	free_netdev(pcnet32_dev);
 	pcnet32_dev = next_dev;
     }
+    if (pcnet32_have_pci)
+	pci_unregister_driver(&pcnet32_driver);
 }
 
 module_init(pcnet32_init_module);

-- 
Don Fry
brazilnut@us.ibm.com
