From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (07/12) Probe2 -- 3c505
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAg30167@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

from viro NE18-3c505
	* switched 3c505 to dynamic allocation
	* 3c505: embedded ->priv
	* 3c505: fixed use of uninitialized variable
	* 3c505: fixed resource leaks on failure exits
Additional:
	* add free_netdev

diff -Nru a/drivers/net/3c505.c b/drivers/net/3c505.c
--- a/drivers/net/3c505.c	Mon Sep 29 09:45:12 2003
+++ b/drivers/net/3c505.c	Mon Sep 29 09:45:12 2003
@@ -1293,42 +1293,6 @@
 	}
 }
 
-/******************************************************
- *
- * initialise Etherlink Plus board
- *
- ******************************************************/
-
-static inline void elp_init(struct net_device *dev)
-{
-	elp_device *adapter = dev->priv;
-
-	/*
-	 * set ptrs to various functions
-	 */
-	dev->open = elp_open;				/* local */
-	dev->stop = elp_close;				/* local */
-	dev->get_stats = elp_get_stats;			/* local */
-	dev->hard_start_xmit = elp_start_xmit;		/* local */
-	dev->tx_timeout = elp_timeout;			/* local */
-	dev->watchdog_timeo = 10*HZ;
-	dev->set_multicast_list = elp_set_mc_list;	/* local */
-	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
-
-	/* Setup the generic properties */
-	ether_setup(dev);
-
-	/*
-	 * setup ptr to adapter specific information
-	 */
-	memset(&(adapter->stats), 0, sizeof(struct net_device_stats));
-
-	/*
-	 * memory information
-	 */
-	dev->mem_start = dev->mem_end = 0;
-}
-
 /************************************************************
  *
  * A couple of tests to see if there's 3C505 or not
@@ -1442,12 +1406,13 @@
  * work at all if it was in a weird state).
  */
 
-int __init elplus_probe(struct net_device *dev)
+static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter;
+	elp_device *adapter = dev->priv;
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
+	int err = -ENODEV;
 
 	SET_MODULE_OWNER(dev);
 
@@ -1456,17 +1421,8 @@
 	 */
 
 	dev->base_addr = elp_autodetect(dev);
-	if (!(dev->base_addr))
-		return -ENODEV;
-
-	/*
-	 * setup ptr to adapter specific information
-	 */
-	adapter = (elp_device *) (dev->priv = kmalloc(sizeof(elp_device), GFP_KERNEL));
-	if (adapter == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", dev->name);
+	if (!dev->base_addr)
 		return -ENODEV;
-	}
 
 	adapter->send_pcb_semaphore = 0;
 
@@ -1544,8 +1500,7 @@
 		outb_control(adapter->hcr_val & ~(FLSH | ATTN), dev);
 	}
 	printk(KERN_ERR "%s: failed to initialise 3c505\n", dev->name);
-	release_region(dev->base_addr, ELP_IO_EXTENT);
-	return -ENODEV;
+	goto out;
 
       okay:
 	if (dev->irq) {		/* Is there a preset IRQ? */
@@ -1560,14 +1515,14 @@
 	case 0:
 		printk(KERN_ERR "%s: IRQ probe failed: check 3c505 jumpers.\n",
 		       dev->name);
-		return -ENODEV;
+		goto out;
 	case 1:
 	case 6:
 	case 8:
 	case 13:
 		printk(KERN_ERR "%s: Impossible IRQ %d reported by probe_irq_off().\n",
 		       dev->name, dev->irq);
-		return -ENODEV;
+		       goto out;
 	}
 	/*
 	 *  Now we have the IRQ number so we can disable the interrupts from
@@ -1636,16 +1591,48 @@
 		printk(KERN_ERR "%s: adapter configuration failed\n", dev->name);
 	}
 
-	/*
-	 * initialise the device
-	 */
-	elp_init(dev);
+	dev->open = elp_open;				/* local */
+	dev->stop = elp_close;				/* local */
+	dev->get_stats = elp_get_stats;			/* local */
+	dev->hard_start_xmit = elp_start_xmit;		/* local */
+	dev->tx_timeout = elp_timeout;			/* local */
+	dev->watchdog_timeo = 10*HZ;
+	dev->set_multicast_list = elp_set_mc_list;	/* local */
+	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
+
+	memset(&(adapter->stats), 0, sizeof(struct net_device_stats));
+	dev->mem_start = dev->mem_end = 0;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out;
 
 	return 0;
+out:
+	release_region(dev->base_addr, ELP_IO_EXTENT);
+	return err;
+}
+
+struct net_device * __init elplus_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(elp_device));
+	int err;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = elplus_setup(dev);
+	if (err) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+	return dev;
 }
 
 #ifdef MODULE
-static struct net_device dev_3c505[ELP_MAX_CARDS];
+static struct net_device *dev_3c505[ELP_MAX_CARDS];
 static int io[ELP_MAX_CARDS];
 static int irq[ELP_MAX_CARDS];
 static int dma[ELP_MAX_CARDS];
@@ -1661,10 +1648,12 @@
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < ELP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_3c505[this_dev];
+		struct net_device *dev = alloc_etherdev(sizeof(elp_device));
+		if (!dev)
+			break;
+
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->init = elplus_probe;
 		if (dma[this_dev]) {
 			dev->dma = dma[this_dev];
 		} else {
@@ -1672,16 +1661,22 @@
 			printk(KERN_WARNING "3c505.c: warning, using default DMA channel,\n");
 		}
 		if (io[this_dev] == 0) {
-			if (this_dev) break;
+			if (this_dev) {
+				free_netdev(dev);
+				break;
+			}
 			printk(KERN_NOTICE "3c505.c: module autoprobe not recommended, give io=xx.\n");
 		}
-		if (register_netdev(dev) != 0) {
+		if (elplus_setup(dev) != 0) {
 			printk(KERN_WARNING "3c505.c: Failed to register card at 0x%x.\n", io[this_dev]);
-			if (found != 0) return 0;
-			return -ENXIO;
+			free_netdev(dev);
+			break;
 		}
+		dev_3c505[this_dev] = dev;
 		found++;
 	}
+	if (!found)
+		return -ENODEV;
 	return 0;
 }
 
@@ -1690,12 +1685,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < ELP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_3c505[this_dev];
-		if (dev->priv != NULL) {
+		struct net_device *dev = dev_3c505[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
 			release_region(dev->base_addr, ELP_IO_EXTENT);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:45:12 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:45:12 2003
@@ -63,7 +63,7 @@
 extern int el16_probe(struct net_device *);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
-extern int elplus_probe(struct net_device *);
+extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
 extern int lne390_probe(struct net_device *);
@@ -274,13 +274,13 @@
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
-#ifdef CONFIG_ELPLUS		/* 3c505 */
-	{elplus_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ELPLUS		/* 3c505 */
+	{elplus_probe, 0},
+#endif
 #ifdef CONFIG_SK_G16
 	{SK_init, 0},
 #endif
