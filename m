From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (25/42) lne390
Date: Wed, 12 Nov 2003 16:44:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0iSG30954@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE49-lne390
	* switched lne390 to dynamic allocation
	* lne390: fixed order of freeing bugs
	* lne390: fixed clobbering on autoprobe
	* lne390: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 13:59:56 2003
+++ b/drivers/net/Space.c	Tue Nov 11 13:59:56 2003
@@ -65,7 +65,7 @@
 extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
-extern int lne390_probe(struct net_device *);
+extern struct net_device *lne390_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
@@ -170,6 +170,10 @@
 #ifdef CONFIG_ES3210
 	{es_probe, 0},
 #endif
+	{NULL, 0},
+};
+
+static struct devprobe2 eisa_probes2[] __initdata = {
 #ifdef CONFIG_LNE390
 	{lne390_probe, 0},
 #endif
@@ -392,6 +396,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, eisa_probes2, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
 	probe_list2(unit, isa_probes, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
diff -Nru a/drivers/net/lne390.c b/drivers/net/lne390.c
--- a/drivers/net/lne390.c	Tue Nov 11 13:59:56 2003
+++ b/drivers/net/lne390.c	Tue Nov 11 13:59:56 2003
@@ -49,7 +49,6 @@
 
 #include "8390.h"
 
-int lne390_probe(struct net_device *dev);
 static int lne390_probe1(struct net_device *dev, int ioaddr);
 
 static int lne390_open(struct net_device *dev);
@@ -103,9 +102,11 @@
  *	PROM for a match against the value assigned to Mylex.
  */
 
-int __init lne390_probe(struct net_device *dev)
+static int __init do_lne390_probe(struct net_device *dev)
 {
 	unsigned short ioaddr = dev->base_addr;
+	int irq = dev->irq;
+	int mem_start = dev->mem_start;
 	int ret;
 
 	SET_MODULE_OWNER(dev);
@@ -135,11 +136,49 @@
 		if (lne390_probe1(dev, ioaddr) == 0)
 			return 0;
 		release_region(ioaddr, LNE390_IO_EXTENT);
+		dev->irq = irq;
+		dev->mem_start = mem_start;
 	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, LNE390_IO_EXTENT);
+	if (ei_status.reg0)
+		iounmap((void *)dev->mem_start);
+	kfree(dev->priv);
+}
+
+struct net_device * __init lne390_probe(int unit)
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
+	err = do_lne390_probe(dev);
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
 static int __init lne390_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, revision, ret;
@@ -373,7 +412,7 @@
 
 #ifdef MODULE
 #define MAX_LNE_CARDS	4	/* Max number of LNE390 cards per module */
-static struct net_device dev_lne[MAX_LNE_CARDS];
+static struct net_device *dev_lne[MAX_LNE_CARDS];
 static int io[MAX_LNE_CARDS];
 static int irq[MAX_LNE_CARDS];
 static int mem[MAX_LNE_CARDS];
@@ -389,26 +428,33 @@
 
 int init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_LNE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_lne[this_dev];
+		if (io[this_dev] == 0 && this_dev != 0)
+			break;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];
-		dev->init = lne390_probe;
-		/* Default is to only install one card. */
-		if (io[this_dev] == 0 && this_dev != 0) break;
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "lne390.c: No LNE390 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		if (do_lne390_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_lne[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
-	}
-	return 0;
+		free_netdev(dev);
+		printk(KERN_WARNING "lne390.c: No LNE390 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
+	}
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void cleanup_module(void)
@@ -416,15 +462,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_LNE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_lne[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, LNE390_IO_EXTENT);
-			if (ei_status.reg0)
-				iounmap((void *)dev->mem_start);
+		struct net_device *dev = dev_lne[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
