From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (17/42) wd
Date: Wed, 12 Nov 2003 16:43:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0h8G30660@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE41-wd
	* switched wd to dynamic allocation
	* wd: fixed order of freeing bugs
	* wd: fixed resource leaks on failure exits
	* wd: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:36:05 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:36:05 2003
@@ -44,7 +44,7 @@
 extern int hp100_probe(struct net_device *dev);
 extern int ultra_probe(struct net_device *dev);
 extern int ultra32_probe(struct net_device *dev);
-extern int wd_probe(struct net_device *dev);
+extern struct net_device *wd_probe(int unit);
 extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
 extern struct net_device *hp_probe(int unit);
@@ -207,13 +207,13 @@
 #ifdef CONFIG_ULTRA 
 	{ultra_probe, 0},
 #endif
-#ifdef CONFIG_WD80x3 
-	{wd_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_WD80x3 
+	{wd_probe, 0},
+#endif
 #ifdef CONFIG_EL2 		/* 3c503 */
 	{el2_probe, 0},
 #endif
diff -Nru a/drivers/net/wd.c b/drivers/net/wd.c
--- a/drivers/net/wd.c	Tue Nov 11 09:36:05 2003
+++ b/drivers/net/wd.c	Tue Nov 11 09:36:05 2003
@@ -47,7 +47,6 @@
 static unsigned int wd_portlist[] __initdata =
 {0x300, 0x280, 0x380, 0x240, 0};
 
-int wd_probe(struct net_device *dev);
 static int wd_probe1(struct net_device *dev, int ioaddr);
 
 static int wd_open(struct net_device *dev);
@@ -83,11 +82,14 @@
 	The wd_probe1() routine initializes the card and fills the
 	station address field. */
 
-int __init wd_probe(struct net_device *dev)
+static int __init do_wd_probe(struct net_device *dev)
 {
 	int i;
 	struct resource *r;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
+	int mem_start = dev->mem_start;
+	int mem_end = dev->mem_end;
 
 	SET_MODULE_OWNER(dev);
 
@@ -115,11 +117,48 @@
 			return 0;
 		}
 		release_region(ioaddr, WD_IO_EXTENT);
+		dev->irq = irq;
+		dev->mem_start = mem_start;
+		dev->mem_end = mem_end;
 	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr - WD_NIC_OFFSET, WD_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init wd_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(0);
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	dev->priv = NULL;	/* until all 8390-based use alloc_etherdev() */
+
+	err = do_wd_probe(dev);
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	cleanup_card(dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+
 static int __init wd_probe1(struct net_device *dev, int ioaddr)
 {
 	int i;
@@ -446,7 +485,7 @@
 
 #ifdef MODULE
 #define MAX_WD_CARDS	4	/* Max number of wd cards per module */
-static struct net_device dev_wd[MAX_WD_CARDS];
+static struct net_device *dev_wd[MAX_WD_CARDS];
 static int io[MAX_WD_CARDS];
 static int irq[MAX_WD_CARDS];
 static int mem[MAX_WD_CARDS];
@@ -468,29 +507,36 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_WD_CARDS; this_dev++) {
-		struct net_device *dev = &dev_wd[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->mem_start = mem[this_dev];
-		dev->mem_end = mem_end[this_dev];
-		dev->init = wd_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "wd.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "wd.c: No wd80x3 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		dev->mem_start = mem[this_dev];
+		dev->mem_end = mem_end[this_dev];
+		if (do_wd_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_wd[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "wd.c: No wd80x3 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -499,14 +545,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_WD_CARDS; this_dev++) {
-		struct net_device *dev = &dev_wd[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			int ioaddr = dev->base_addr - WD_NIC_OFFSET;
-			free_irq(dev->irq, dev);
-			release_region(ioaddr, WD_IO_EXTENT);
+		struct net_device *dev = dev_wd[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
