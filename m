From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/12) Probe2 -- 3c501
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYA130180@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From viro NE22-3c501
	* switched 3c501 to dynamic allocation
	* 3c501: embedded ->priv
	* 3c501: fixed clobbering on autoprobe
	* 3c501: fixed resource leaks on failure exits
Additional:
	* probe correctly when no device present
	* fix loop forever bug in probing
	* free_netdev

diff -Nru a/drivers/net/3c501.c b/drivers/net/3c501.c
--- a/drivers/net/3c501.c	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/3c501.c	Mon Sep 29 10:27:33 2003
@@ -136,17 +136,14 @@
 
 #include "3c501.h"
 
-/* A zero-terminated list of I/O addresses to be probed.
-   The 3c501 can be at many locations, but here are the popular ones. */
-static unsigned int netcard_portlist[] __initdata = { 
-	0x280, 0x300, 0
-};
-
-
 /*
  *	The boilerplate probe code.
  */
 
+static int io=0x280;
+static int irq=5;
+static int mem_start;
+
 /**
  * el1_probe:		-	probe for a 3c501
  * @dev: The device structure passed in to probe. 
@@ -160,23 +157,47 @@
  * probe and failing to find anything.
  */
  
-int __init el1_probe(struct net_device *dev)
+struct net_device * __init el1_probe(int unit)
 {
-	int i;
-	int base_addr = dev->base_addr;
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	static unsigned ports[] = { 0x280, 0x300, 0};
+	unsigned *port;
+	int err = 0;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		irq = dev->irq;
+		mem_start = dev->mem_start & 7;
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	if (base_addr > 0x1ff)	/* Check a single specified location. */
-		return el1_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; netcard_portlist[i]; i++)
-		if (el1_probe1(dev, netcard_portlist[i]) == 0)
-			return 0;
-
-	return -ENODEV;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = el1_probe1(dev, io);
+	} else if (io != 0) {
+		err = -ENXIO;		/* Don't probe at all. */
+	} else {
+		for (port = ports; *port && el1_probe1(dev, *port); port++)
+			;
+		if (!*port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, EL1_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /**
@@ -240,6 +261,8 @@
 	 *	high.
 	 */
 
+	dev->irq = irq;
+
 	if (dev->irq < 2)
 	{
 		unsigned long irq_mask;
@@ -267,8 +290,8 @@
 	dev->base_addr = ioaddr;
 	memcpy(dev->dev_addr, station_addr, ETH_ALEN);
 
-	if (dev->mem_start & 0xf)
-		el_debug = dev->mem_start & 0x7;
+	if (mem_start & 0xf)
+		el_debug = mem_start & 0x7;
 	if (autoirq)
 		dev->irq = autoirq;
 
@@ -282,17 +305,7 @@
 	if (el_debug)
 		printk(KERN_DEBUG "%s", version);
 
-	/*
-	 *	Initialize the device structure.
-	 */
-
-	dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		release_region(ioaddr, EL1_IO_EXTENT);
-		return -ENOMEM;
-	}
 	memset(dev->priv, 0, sizeof(struct net_local));
-
 	lp=dev->priv;
 	spin_lock_init(&lp->lock);
 	
@@ -308,13 +321,6 @@
 	dev->get_stats = &el1_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-
-	/*
-	 *	Setup the generic properties
-	 */
-
-	ether_setup(dev);
-
 	return 0;
 }
 
@@ -884,14 +890,8 @@
 
 #ifdef MODULE
 
-static struct net_device dev_3c501 = {
-	.init		= el1_probe,
-	.base_addr	= 0x280,
-	.irq		= 5,
-};
+static struct net_device *dev_3c501;
 
-static int io=0x280;
-static int irq=5;
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
 MODULE_PARM_DESC(io, "EtherLink I/O base address");
@@ -911,10 +911,9 @@
  
 int init_module(void)
 {
-	dev_3c501.irq=irq;
-	dev_3c501.base_addr=io;
-	if (register_netdev(&dev_3c501) != 0)
-		return -EIO;
+	dev_3c501 = el1_probe(-1);
+	if (IS_ERR(dev_3c501))
+		return PTR_ERR(dev_3c501);
 	return 0;
 }
 
@@ -927,19 +926,10 @@
  
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_3c501);
-
-	/*
-	 *	Free up the private structure, or leak memory :-)
-	 */
-
-	kfree(dev_3c501.priv);
-	dev_3c501.priv = NULL;	/* gets re-allocated by el1_probe1 */
-
-	/*
-	 *	If we don't do this, we can't re-insmod it later.
-	 */
-	release_region(dev_3c501.base_addr, EL1_IO_EXTENT);
+	struct net_device *dev = dev_3c501;
+	unregister_netdev(dev);
+	release_region(dev->base_addr, EL1_IO_EXTENT);
+	free_netdev(dev);
 }
 
 #endif /* MODULE */
diff -Nru a/drivers/net/3c501.h b/drivers/net/3c501.h
--- a/drivers/net/3c501.h	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/3c501.h	Mon Sep 29 10:27:33 2003
@@ -3,7 +3,6 @@
  *	Index to functions.
  */
 
-int el1_probe(struct net_device *dev);
 static int  el1_probe1(struct net_device *dev, int ioaddr);
 static int  el_open(struct net_device *dev);
 static void el_timeout(struct net_device *dev);
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:27:33 2003
@@ -57,7 +57,7 @@
 extern int eth16i_probe(struct net_device *);
 extern int i82596_probe(struct net_device *);
 extern int ewrk3_probe(struct net_device *);
-extern int el1_probe(struct net_device *);
+extern struct net_device *el1_probe(int unit);
 extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
@@ -262,13 +262,13 @@
 #if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_EL1		/* 3c501 */
-	{el1_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EL1		/* 3c501 */
+	{el1_probe, 0},
+#endif
 #ifdef CONFIG_WAVELAN		/* WaveLAN */
 	{wavelan_probe, 0},
 #endif
