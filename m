From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/42) cs89x0
Date: Wed, 12 Nov 2003 16:41:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0fS230153@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE31-cs89x0
	* switched cs89x0 to dynamic allocation
	* cs89x0: embedded ->priv
	* cs89x0: fixed resource leaks on failure exits
	* cs89x0: fixed clobbering on autoprobe
	* NB: cs89x0 calls request_region() with very odd arguments.  Somebody
	  ought to check WTF is going on there.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:40 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:40 2003
@@ -81,7 +81,7 @@
 extern int apne_probe(struct net_device *);
 extern int bionet_probe(struct net_device *);
 extern int pamsnet_probe(struct net_device *);
-extern int cs89x0_probe(struct net_device *dev);
+extern struct net_device *cs89x0_probe(int unit);
 extern int hplance_probe(struct net_device *dev);
 extern int bagetlance_probe(struct net_device *);
 extern int mvme147lance_probe(struct net_device *dev);
@@ -238,13 +238,13 @@
 #ifdef CONFIG_AT1500
 	{at1500_probe, 0},
 #endif
-#ifdef CONFIG_CS89x0
- 	{cs89x0_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_CS89x0
+ 	{cs89x0_probe, 0},
+#endif
 #ifdef CONFIG_AT1700
 	{at1700_probe, 0},
 #endif
diff -Nru a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c	Tue Nov 11 09:35:40 2003
+++ b/drivers/net/cs89x0.c	Tue Nov 11 09:35:40 2003
@@ -212,9 +212,7 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int cs89x0_probe(struct net_device *dev);
-
-static int cs89x0_probe1(struct net_device *dev, int ioaddr);
+static int cs89x0_probe1(struct net_device *dev, int ioaddr, int modular);
 static int net_open(struct net_device *dev);
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id, struct pt_regs *regs);
@@ -274,27 +272,51 @@
    Return 0 on success.
    */
 
-int __init cs89x0_probe(struct net_device *dev)
+struct net_device * __init cs89x0_probe(int unit)
 {
-	int i;
-	int base_addr = dev ? dev->base_addr : 0;
-
-	SET_MODULE_OWNER(dev);
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	unsigned *port;
+	int err = 0;
+	int irq;
+	int io;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+	io = dev->base_addr;
+	irq = dev->irq;
 
 	if (net_debug)
-		printk("cs89x0:cs89x0_probe(0x%x)\n", base_addr);
+		printk("cs89x0:cs89x0_probe(0x%x)\n", io);
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return cs89x0_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; netcard_portlist[i]; i++) {
-		if (cs89x0_probe1(dev, netcard_portlist[i]) == 0)
-			return 0;
+	if (io > 0x1ff)	{	/* Check a single specified location. */
+		err = cs89x0_probe1(dev, io, 0);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = netcard_portlist; *port; port++) {
+			if (cs89x0_probe1(dev, *port, 0) == 0)
+				break;
+			dev->irq = irq;
+		}
+		if (!*port)
+			err = -ENODEV;
 	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	outw(PP_ChipID, dev->base_addr + ADD_PORT);
+	release_region(dev->base_addr, NETCARD_IO_EXTENT);
+out:
+	free_netdev(dev);
 	printk(KERN_WARNING "cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
-	return -ENODEV;
+	return ERR_PTR(err);
 }
 
 static int
@@ -375,39 +397,34 @@
  */
 
 static int __init
-cs89x0_probe1(struct net_device *dev, int ioaddr)
+cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 {
-	struct net_local *lp;
+	struct net_local *lp = (struct net_local *)dev->priv;
 	static unsigned version_printed;
 	int i;
 	unsigned rev_type = 0;
 	int eeprom_buff[CHKSUM_LEN];
 	int retval;
 
+	SET_MODULE_OWNER(dev);
 	/* Initialize the device structure. */
-	if (dev->priv == NULL) {
-		dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-		if (dev->priv == 0) {
-			retval = -ENOMEM;
-			goto out;
-		}
-		lp = (struct net_local *)dev->priv;
+	if (!modular) {
 		memset(lp, 0, sizeof(*lp));
 		spin_lock_init(&lp->lock);
-#if !defined(MODULE) && (ALLOW_DMA != 0)
+#ifndef MODULE
+#if ALLOW_DMA
 		if (g_cs89x0_dma) {
 			lp->use_dma = 1;
 			lp->dma = g_cs89x0_dma;
 			lp->dmasize = 16;	/* Could make this an option... */
 		}
 #endif
-#ifndef MODULE
 		lp->force = g_cs89x0_media__force;
 #endif
         }
-	lp = (struct net_local *)dev->priv;
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
+	/* WTF is going on here? */
 	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, dev->name)) {
 		printk(KERN_ERR "%s: request_region(0x%x, 0x%x) failed\n",
 				dev->name, ioaddr, NETCARD_IO_EXTENT);
@@ -696,9 +713,6 @@
 	dev->set_multicast_list = set_multicast_list;
 	dev->set_mac_address 	= set_mac_address;
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
 	printk("\n");
 	if (net_debug)
 		printk("cs89x0_probe1() successful\n");
@@ -706,9 +720,6 @@
 out2:
 	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
 out1:
-	kfree(dev->priv);
-	dev->priv = 0;
-out:
 	return retval;
 }
 
@@ -1655,7 +1666,7 @@
 
 #ifdef MODULE
 
-static struct net_device dev_cs89x0;
+static struct net_device *dev_cs89x0;
 
 /*
  * Support the 'debug' module parm even if we're compiled for non-debug to 
@@ -1733,6 +1744,7 @@
 int
 init_module(void)
 {
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
 	struct net_local *lp;
 	int ret = 0;
 
@@ -1741,18 +1753,12 @@
 #else
 	debug = 0;
 #endif
-
-	dev_cs89x0.irq = irq;
-	dev_cs89x0.base_addr = io;
-
-        dev_cs89x0.init = cs89x0_probe;
-        dev_cs89x0.priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev_cs89x0.priv == 0) {
-		printk(KERN_ERR "cs89x0.c: Out of memory.\n");
+	if (!dev)
 		return -ENOMEM;
-	}
-	memset(dev_cs89x0.priv, 0, sizeof(struct net_local));
-	lp = (struct net_local *)dev_cs89x0.priv;
+
+	dev->irq = irq;
+	dev->base_addr = io;
+	lp = dev->priv;
 
 #if ALLOW_DMA
 	if (use_dma) {
@@ -1782,7 +1788,10 @@
                 printk(KERN_ERR "cs89x0.c: Append io=0xNNN\n");
                 ret = -EPERM;
 		goto out;
-        }
+        } else if (io <= 0x1ff) {
+		ret = -ENXIO;
+		goto out;
+	}
 
 #if ALLOW_DMA
 	if (use_dma && dmasize != 16 && dmasize != 64) {
@@ -1791,30 +1800,31 @@
 		goto out;
 	}
 #endif
+	ret = cs89x0_probe1(dev, io, 1);
+	if (ret)
+		goto out;
 
-        if (register_netdev(&dev_cs89x0) != 0) {
+        if (register_netdev(dev) != 0) {
                 printk(KERN_ERR "cs89x0.c: No card found at 0x%x\n", io);
                 ret = -ENXIO;
+		outw(PP_ChipID, dev->base_addr + ADD_PORT);
+		release_region(dev->base_addr, NETCARD_IO_EXTENT);
 		goto out;
         }
+	dev_cs89x0 = dev;
+	return 0;
 out:
-	if (ret)
-		kfree(dev_cs89x0.priv);
+	free_netdev(dev);
 	return ret;
 }
 
 void
 cleanup_module(void)
 {
-        if (dev_cs89x0.priv != NULL) {
-                /* Free up the private structure, or leak memory :-)  */
-                unregister_netdev(&dev_cs89x0);
-		outw(PP_ChipID, dev_cs89x0.base_addr + ADD_PORT);
-                kfree(dev_cs89x0.priv);
-                dev_cs89x0.priv = NULL;	/* gets re-allocated by cs89x0_probe1 */
-                /* If we don't do this, we can't re-insmod it later. */
-                release_region(dev_cs89x0.base_addr, NETCARD_IO_EXTENT);
-        }
+	unregister_netdev(dev_cs89x0);
+	outw(PP_ChipID, dev_cs89x0->base_addr + ADD_PORT);
+	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
+	free_netdev(dev_cs89x0);
 }
 #endif /* MODULE */
 
