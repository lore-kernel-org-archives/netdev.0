From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.26-rc1] pcnet32.c
Date: Tue, 30 Mar 2004 14:17:34 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403302217.i2UMHYY12182@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch against 2.4.26-rc1 to restore the code which
was added to 2.4.20 and removed from 2.4.21.  This brings the 2.4 source
to the equivalent level of 2.6.5 (minus the white-space only changes).

--- linux-2.4.26-rc1/drivers/net/orig.pcnet32.c	Mon Mar 29 11:42:05 2004
+++ linux-2.4.26-rc1/drivers/net/pcnet32.c	Tue Mar 30 13:56:23 2004
@@ -30,11 +30,8 @@
 DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " tsbogend@alpha.franken.de\n";
 
 #include <linux/module.h>
-
 #include <linux/kernel.h>
-#include <linux/sched.h>
 #include <linux/string.h>
-#include <linux/ptrace.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
@@ -45,16 +42,16 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/crc32.h>
-#include <asm/bitops.h>
-#include <asm/io.h>
-#include <asm/dma.h>
-#include <asm/uaccess.h>
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 
+#include <asm/bitops.h>
+#include <asm/io.h>
+#include <asm/dma.h>
+#include <asm/uaccess.h>
+
 /*
  * PCI device identifiers for "new style" Linux PCI Device Drivers
  */
@@ -103,6 +100,8 @@
 
 #define PCNET32_DMA_MASK 0xffffffff
 
+#define PCNET32_WATCHDOG_TIMEOUT (jiffies + (2 * HZ))
+
 /*
  * table to translate option values from tulip
  * to internal options
@@ -223,6 +222,8 @@
  *	   fix pci probe not increment cards_found
  *	   FD auto negotiate error workaround for xSeries250
  *	   clean up and using new mii module
+ * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
+ *	   Added timer for cable connection state changes.
  * v1.28   20 Feb 2004 Don Fry <brazilnut@us.ibm.com>
  *	   Jon Mason <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
  *	   Now uses ethtool_ops, netif_msg_* and generic_mii_ioctl.
@@ -337,6 +338,7 @@
 	mii:1;				/* mii port available */
     struct net_device	*next;
     struct mii_if_info mii_if;
+    struct timer_list	watchdog_timer;
     u32			msg_enable;	/* debug message level */
 };
 
@@ -353,6 +355,7 @@
 static struct net_device_stats *pcnet32_get_stats(struct net_device *);
 static void pcnet32_set_multicast_list(struct net_device *);
 static int  pcnet32_ioctl(struct net_device *, struct ifreq *, int);
+static void pcnet32_watchdog(struct net_device *);
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num);
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val);
 static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits);
@@ -476,6 +479,14 @@
     .reset	= pcnet32_dwio_reset
 };
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void pcnet32_poll_controller(struct net_device *dev)
+{ 
+	disable_irq(dev->irq);
+	pcnet32_interrupt(0, dev, NULL);
+	enable_irq(dev->irq);
+} 
+#endif
 
 
 static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -622,6 +633,8 @@
     spin_lock_irqsave(&lp->lock, flags);
     lp->a.write_csr(ioaddr, 0, 0x7904);
 
+    del_timer_sync(&lp->watchdog_timer);
+
     netif_stop_queue(dev);
 
     /* purge & init rings but don't actually restart */
@@ -721,6 +734,8 @@
 
     netif_wake_queue(dev);
 
+    mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
+
     /* Clear interrupts, and set interrupt enable. */
     lp->a.write_csr(ioaddr, 0, 0x7940);
     spin_unlock_irqrestore(&lp->lock, flags);
@@ -754,10 +769,13 @@
     
     /* search for PCnet32 VLB cards at known addresses */
     for (port = pcnet32_portlist; (ioaddr = *port); port++) {
-	if (!check_region(ioaddr, PCNET32_TOTAL_SIZE)) {
+	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_vlbus")) {
 	    /* check if there is really a pcnet chip on that ioaddr */
-	    if ((inb(ioaddr + 14) == 0x57) && (inb(ioaddr + 15) == 0x57))
+	    if ((inb(ioaddr + 14) == 0x57) && (inb(ioaddr + 15) == 0x57)) {
 		pcnet32_probe1(ioaddr, 0, 0, NULL);
+	    } else {
+		release_region(ioaddr, PCNET32_TOTAL_SIZE);
+	    }
 	}
     }
 }
@@ -786,6 +804,10 @@
 	printk(KERN_ERR PFX "architecture does not support 32bit PCI busmaster DMA\n");
 	return -ENODEV;
     }
+    if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_pci") == NULL) {
+	printk(KERN_ERR PFX "io address range already allocated\n");
+	return -EBUSY;
+    }
 
     return pcnet32_probe1(ioaddr, pdev->irq, 1, pdev);
 }
@@ -808,6 +830,7 @@
     struct net_device *dev;
     struct pcnet32_access *a = NULL;
     u8 promaddr[6];
+    int ret = -ENODEV;
 
     /* reset the chip */
     pcnet32_wio_reset(ioaddr);
@@ -820,7 +843,7 @@
 	if (pcnet32_dwio_read_csr(ioaddr, 0) == 4 && pcnet32_dwio_check(ioaddr)) {
 	    a = &pcnet32_dwio;
 	} else
-	    return -ENODEV;
+	    goto err_release_region;
     }
 
     chip_version = a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr,89) << 16);
@@ -828,7 +851,7 @@
 	printk(KERN_INFO "  PCnet chip version is %#x.\n", chip_version);
     if ((chip_version & 0xfff) != 0x003) {
 	printk(KERN_INFO PFX "Unsupported chip version.\n");
-	return -ENODEV;
+	goto err_release_region;
     }
     
     /* initialize variables */
@@ -891,7 +914,7 @@
     default:
 	printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
 			chip_version);
-	return -ENODEV;
+	goto err_release_region;
     }
 
     /*
@@ -912,8 +935,10 @@
     dev = alloc_etherdev(0);
     if (!dev) {
 	printk(KERN_ERR PFX "Memory allocation failed.\n");
-	return -ENOMEM;
+	ret = -ENOMEM;
+	goto err_release_region;
     }
+    SET_NETDEV_DEV(dev, &pdev->dev);
 
     printk(KERN_INFO PFX "%s at %#3lx,", chipname, ioaddr);
 
@@ -981,14 +1006,12 @@
     }
 
     dev->base_addr = ioaddr;
-    if (request_region(ioaddr, PCNET32_TOTAL_SIZE, chipname) == NULL)
-	return -EBUSY;
     
     /* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
     if ((lp = pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
 	printk(KERN_ERR PFX "Consistent memory allocation failed.\n");
-	release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	return -ENOMEM;
+	ret = -ENOMEM;
+	goto err_free_netdev;
     }
 
     memset(lp, 0, sizeof(*lp));
@@ -997,6 +1020,8 @@
 
     spin_lock_init(&lp->lock);
     
+    SET_MODULE_OWNER(dev);
+    SET_NETDEV_DEV(dev, &pdev->dev);
     dev->priv = lp;
     lp->name = chipname;
     lp->shared_irq = shared;
@@ -1020,10 +1045,9 @@
 	lp->options |= PCNET32_PORT_FD;
     
     if (!a) {
-      printk(KERN_ERR PFX "No access methods\n");
-      pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-      release_region(ioaddr, PCNET32_TOTAL_SIZE);
-      return -ENODEV;
+	printk(KERN_ERR PFX "No access methods\n");
+	ret = -ENODEV;
+	goto err_free_consistent;
     }
     lp->a = *a;
     
@@ -1065,20 +1089,22 @@
 	mdelay (1);
 	
 	dev->irq = probe_irq_off (irq_mask);
-	if (dev->irq)
-	    printk(", probed IRQ %d.\n", dev->irq);
-	else {
+	if (!dev->irq) {
 	    printk(", failed to detect IRQ line.\n");
-	    pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-	    release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	    return -ENODEV;
+	    ret = -ENODEV;
+	    goto err_free_consistent;
 	}
+	printk(", probed IRQ %d.\n", dev->irq);
     }
 
     /* Set the mii phy_id so that we can query the link state */
     if (lp->mii)
 	lp->mii_if.phy_id = ((lp->a.read_bcr (ioaddr, 33)) >> 5) & 0x1f;
     
+    init_timer (&lp->watchdog_timer);
+    lp->watchdog_timer.data = (unsigned long) dev;
+    lp->watchdog_timer.function = (void *) &pcnet32_watchdog;
+
     /* The PCNET32-specific entries in the device structure. */
     dev->open = &pcnet32_open;
     dev->hard_start_xmit = &pcnet32_start_xmit;
@@ -1090,6 +1116,14 @@
     dev->tx_timeout = pcnet32_tx_timeout;
     dev->watchdog_timeo = (5*HZ);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+    dev->poll_controller = pcnet32_poll_controller;
+#endif    
+
+    /* Fill in the generic fields of the device structure. */
+    if (register_netdev(dev))
+	goto err_free_consistent;
+
     if (pdev) {
 	pci_set_drvdata(pdev, dev);
     } else {
@@ -1097,11 +1131,17 @@
 	pcnet32_dev = dev;
     }
 
-    /* Fill in the generic fields of the device structure. */
-    register_netdev(dev);
     printk(KERN_INFO "%s: registered as %s\n",dev->name, lp->name);
     cards_found++;
     return 0;
+
+err_free_consistent:
+    pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+err_free_netdev:
+    free_netdev(dev);
+err_release_region:
+    release_region(ioaddr, PCNET32_TOTAL_SIZE);
+    return ret;
 }
 
 
@@ -1212,6 +1252,12 @@
 
     netif_start_queue(dev);
 
+    /* If we have mii, print the link status and start the watchdog */
+    if (lp->mii) {
+	mii_check_media (&lp->mii_if, 1, 1);
+	mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
+    }
+
     i = 0;
     while (i++ < 100)
 	if (lp->a.read_csr (ioaddr, 0) & 0x0100)
@@ -1228,8 +1274,6 @@
 	       lp->a.read_csr(ioaddr, 0));
 
 
-    MOD_INC_USE_COUNT;
-    
     return 0;	/* Always succeed */
 
 err_free_ring:
@@ -1721,6 +1765,8 @@
     struct pcnet32_private *lp = dev->priv;
     int i;
 
+    del_timer_sync(&lp->watchdog_timer);
+
     netif_stop_queue(dev);
 
     lp->stats.rx_missed_errors = lp->a.read_csr (ioaddr, 112);
@@ -1761,8 +1807,6 @@
         lp->tx_dma_addr[i] = 0;
     }
     
-    MOD_DEC_USE_COUNT;
-
     return 0;
 }
 
@@ -1901,6 +1945,21 @@
     return rc;
 }
 
+static void pcnet32_watchdog(struct net_device *dev)
+{
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
+
+    /* Print the link status if it has changed */
+    if (lp->mii) {
+	spin_lock_irqsave(&lp->lock, flags);
+	mii_check_media (&lp->mii_if, 1, 0);
+	spin_unlock_irqrestore(&lp->lock, flags);
+    }
+
+    mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
+}
+
 static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
 {
     struct net_device *dev = pci_get_drvdata(pdev);

-- 
Don Fry
brazilnut@us.ibm.com
