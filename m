From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/12) Probe2 -- 82596
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAJ30190@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Originally by Al Viro (NE23-82596)
	* switched 82596 to dynamic allocation
	* 82596: fixed resource leaks on failure exits
Updated to apply agains jgarzik/net-drivers-2.5-exp

diff -Nru a/drivers/net/82596.c b/drivers/net/82596.c
--- a/drivers/net/82596.c	Tue Oct 14 14:46:31 2003
+++ b/drivers/net/82596.c	Tue Oct 14 14:46:31 2003
@@ -1129,21 +1129,40 @@
 	printk(" %02X%02X, %s\n", add[12], add[13], str);
 }
 
-int __init i82596_probe(struct net_device *dev)
+static int io = 0x300;
+static int irq = 10;
+
+struct net_device * __init i82596_probe(int unit)
 {
+	struct net_device *dev;
 	int i;
 	struct i596_private *lp;
 	char eth_addr[8];
 	static int probed;
+	int err;
 
 	if (probed)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
 	probed++;
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	} else {
+		dev->base_addr = io;
+		dev->irq = irq;
+	}
+
 #ifdef ENABLE_MVME16x_NET
 	if (MACH_IS_MVME16x) {
 		if (mvme16x_config & MVME16x_CONFIG_NO_ETHERNET) {
 			printk(KERN_NOTICE "Ethernet probe disabled - chip not present\n");
-			return -ENODEV;
+			err = -ENODEV;
+			goto out;
 		}
 		memcpy(eth_addr, (void *) 0xfffc1f2c, 6);	/* YUCK! Get addr from NOVRAM */
 		dev->base_addr = MVME_I596_BASE;
@@ -1174,7 +1193,8 @@
 
 		if (!request_region(ioaddr, I596_TOTAL_SIZE, dev->name)) {
 			printk(KERN_ERR "82596: IO address 0x%04x in use\n", ioaddr);
-			return -EBUSY;
+			err = -EBUSY;
+			goto out;
 		}
 
 		for (i = 0; i < 8; i++) {
@@ -1190,8 +1210,8 @@
 
 		if ((checksum % 0x100) || 
 		    (memcmp(eth_addr, "\x00\x00\x49", 3) != 0)) {
-			release_region(ioaddr, I596_TOTAL_SIZE);
-			return -ENODEV;
+			err = -ENODEV;
+			goto out1;
 		}
 
 		dev->base_addr = ioaddr;
@@ -1200,13 +1220,10 @@
 #endif
 	dev->mem_start = (int)__get_free_pages(GFP_ATOMIC, 0);
 	if (!dev->mem_start) {
-#ifdef ENABLE_APRICOT
-		release_region(dev->base_addr, I596_TOTAL_SIZE);
-#endif
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out1;
 	}
 
-	ether_setup(dev);
 	DEB(DEB_PROBE,printk(KERN_INFO "%s: 82596 at %#3lx,", dev->name, dev->base_addr));
 
 	for (i = 0; i < 6; i++)
@@ -1244,7 +1261,26 @@
 	lp->scb.rfd = I596_NULL;
 	lp->lock = SPIN_LOCK_UNLOCKED;
 
-	return 0;
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	return dev;
+out2:
+#ifdef __mc68000__
+	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
+	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
+	 */
+	kernel_set_cachemode((void *)(dev->mem_start), 4096,
+			IOMAP_FULL_CACHING);
+#endif
+	free_page ((u32)(dev->mem_start));
+out1:
+#ifdef ENABLE_APRICOT
+	release_region(dev->base_addr, I596_TOTAL_SIZE);
+#endif
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static irqreturn_t i596_interrupt(int irq, void *dev_id, struct pt_regs *regs)
@@ -1532,11 +1568,9 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_82596 = { .init = i82596_probe };
+static struct net_device *dev_82596;
 
 #ifdef ENABLE_APRICOT
-static int io = 0x300;
-static int irq = 10;
 MODULE_PARM(irq, "i");
 MODULE_PARM_DESC(irq, "Apricot IRQ number");
 #endif
@@ -1547,34 +1581,31 @@
 
 int init_module(void)
 {
-#ifdef ENABLE_APRICOT
-	dev_82596.base_addr = io;
-	dev_82596.irq = irq;
-#endif
 	if (debug >= 0)
 		i596_debug = debug;
-	if (register_netdev(&dev_82596) != 0)
-		return -EIO;
+	dev_82596 = i82596_probe(-1);
+	if (IS_ERR(dev_82596))
+		return PTR_ERR(dev_82596);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_82596);
+	unregister_netdev(dev_82596);
 #ifdef __mc68000__
 	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
 	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
 	 */
 
-	kernel_set_cachemode((void *)(dev_82596.mem_start), 4096,
+	kernel_set_cachemode((void *)(dev_82596->mem_start), 4096,
 			IOMAP_FULL_CACHING);
 #endif
-	free_page ((u32)(dev_82596.mem_start));
-	dev_82596.priv = NULL;
+	free_page ((u32)(dev_82596->mem_start));
 #ifdef ENABLE_APRICOT
 	/* If we don't do this, we can't re-insmod it later. */
-	release_region(dev_82596.base_addr, I596_TOTAL_SIZE);
+	release_region(dev_82596->base_addr, I596_TOTAL_SIZE);
 #endif
+	free_netdev(dev_82596);
 }
 
 #endif				/* MODULE */
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Oct 14 14:46:31 2003
+++ b/drivers/net/Space.c	Tue Oct 14 14:46:31 2003
@@ -55,7 +55,7 @@
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
 extern int eth16i_probe(struct net_device *);
-extern int i82596_probe(struct net_device *);
+extern struct net_device *i82596_probe(int unit);
 extern int ewrk3_probe(struct net_device *);
 extern struct net_device *el1_probe(int unit);
 extern struct net_device *wavelan_probe(int unit);
@@ -259,13 +259,13 @@
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
-#if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
-	{i82596_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
+	{i82596_probe, 0},
+#endif
 #ifdef CONFIG_EL1		/* 3c501 */
 	{el1_probe, 0},
 #endif
