From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (26/42) es3210
Date: Wed, 12 Nov 2003 16:44:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0icV30973@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE50-es3210
	* switched es3210 to dynamic allocation
	* es3210: fixed order of freeing bugs
	* es3210: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:38:12 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:38:12 2003
@@ -64,7 +64,7 @@
 extern struct net_device *skmca_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
-extern int es_probe(struct net_device *);
+extern struct net_device *es_probe(int unit);
 extern struct net_device *lne390_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
@@ -167,13 +167,13 @@
 #ifdef CONFIG_AC3200	
 	{ac3200_probe, 0},
 #endif
-#ifdef CONFIG_ES3210
-	{es_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 eisa_probes2[] __initdata = {
+#ifdef CONFIG_ES3210
+	{es_probe, 0},
+#endif
 #ifdef CONFIG_LNE390
 	{lne390_probe, 0},
 #endif
diff -Nru a/drivers/net/es3210.c b/drivers/net/es3210.c
--- a/drivers/net/es3210.c	Tue Nov 11 14:38:12 2003
+++ b/drivers/net/es3210.c	Tue Nov 11 14:38:12 2003
@@ -62,7 +62,6 @@
 
 #include "8390.h"
 
-int es_probe(struct net_device *dev);
 static int es_probe1(struct net_device *dev, int ioaddr);
 
 static int es_open(struct net_device *dev);
@@ -125,9 +124,11 @@
  *	PROM for a match against the Racal-Interlan assigned value.
  */
 
-int __init es_probe(struct net_device *dev)
+static int __init do_es_probe(struct net_device *dev)
 {
 	unsigned short ioaddr = dev->base_addr;
+	int irq = dev->irq;
+	int mem_start = dev->mem_start;
 
 	SET_MODULE_OWNER(dev);
 
@@ -144,13 +145,50 @@
 	}
 
 	/* EISA spec allows for up to 16 slots, but 8 is typical. */
-	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000)
+	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
 		if (es_probe1(dev, ioaddr) == 0)
 			return 0;
+		dev->irq = irq;
+		dev->mem_start = mem_start;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, ES_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init es_probe(int unit)
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
+	err = do_es_probe(dev);
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
 static int __init es_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, retval;
@@ -376,7 +414,7 @@
 #ifdef MODULE
 #define MAX_ES_CARDS	4	/* Max number of ES3210 cards per module */
 #define NAMELEN		8	/* # of chars for storing dev->name */
-static struct net_device dev_es3210[MAX_ES_CARDS];
+static struct net_device *dev_es3210[MAX_ES_CARDS];
 static int io[MAX_ES_CARDS];
 static int irq[MAX_ES_CARDS];
 static int mem[MAX_ES_CARDS];
@@ -393,26 +431,33 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_ES_CARDS; this_dev++) {
-		struct net_device *dev = &dev_es3210[this_dev];
+		if (io[this_dev] == 0 && this_dev != 0)
+			break;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->mem_start = mem[this_dev];		/* Currently ignored by driver */
-		dev->init = es_probe;
-		/* Default is to only install one card. */
-		if (io[this_dev] == 0 && this_dev != 0) break;
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "es3210.c: No es3210 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev->mem_start = mem[this_dev];
+		if (do_es_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_es3210[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "es3210.c: No es3210 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -421,13 +466,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_ES_CARDS; this_dev++) {
-		struct net_device *dev = &dev_es3210[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, ES_IO_EXTENT);
+		struct net_device *dev = dev_es3210[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
