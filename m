From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (27/42) ac3200
Date: Wed, 12 Nov 2003 16:44:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0imB30995@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE51-ac3200
	* switched ac3200 to dynamic allocation
	* ac3200: fixed order of freeing bugs
	* ac3200: fixed clobbering on autoprobe
	* ac3200: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:23:23 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:23:23 2003
@@ -63,7 +63,7 @@
 extern struct net_device *elmc_probe(int unit);
 extern struct net_device *skmca_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
-extern int ac3200_probe(struct net_device *);
+extern struct net_device *ac3200_probe(int unit);
 extern struct net_device *es_probe(int unit);
 extern struct net_device *lne390_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
@@ -164,13 +164,13 @@
 #ifdef CONFIG_ULTRA32 
 	{ultra32_probe, 0},	
 #endif
-#ifdef CONFIG_AC3200	
-	{ac3200_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 eisa_probes2[] __initdata = {
+#ifdef CONFIG_AC3200	
+	{ac3200_probe, 0},
+#endif
 #ifdef CONFIG_ES3210
 	{es_probe, 0},
 #endif
diff -Nru a/drivers/net/ac3200.c b/drivers/net/ac3200.c
--- a/drivers/net/ac3200.c	Tue Nov 11 14:23:23 2003
+++ b/drivers/net/ac3200.c	Tue Nov 11 14:23:23 2003
@@ -75,7 +75,6 @@
 #define AC_START_PG		0x00	/* First page of 8390 TX buffer */
 #define AC_STOP_PG		0x80	/* Last page +1 of the 8390 RX ring */
 
-int ac3200_probe(struct net_device *dev);
 static int ac_probe1(int ioaddr, struct net_device *dev);
 
 static int ac_open(struct net_device *dev);
@@ -96,9 +95,11 @@
 	or the unique value in the station address PROM.
 	*/
 
-int __init ac3200_probe(struct net_device *dev)
+static int __init do_ac3200_probe(struct net_device *dev)
 {
 	unsigned short ioaddr = dev->base_addr;
+	int irq = dev->irq;
+	int mem_start = dev->mem_start;
 
 	SET_MODULE_OWNER(dev);
 
@@ -110,13 +111,53 @@
 	if ( ! EISA_bus)
 		return -ENXIO;
 
-	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000)
+	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
 		if (ac_probe1(ioaddr, dev) == 0)
 			return 0;
+		dev->irq = irq;
+		dev->mem_start = mem_start;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	/* Someday free_irq may be in ac_close_card() */
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, AC_IO_EXTENT);
+	if (ei_status.reg0)
+		iounmap((void *)dev->mem_start);
+	kfree(dev->priv);
+}
+
+struct net_device * __init ac3200_probe(int unit)
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
+	err = do_ac3200_probe(dev);
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
 static int __init ac_probe1(int ioaddr, struct net_device *dev)
 {
 	int i, retval;
@@ -338,7 +379,7 @@
 
 #ifdef MODULE
 #define MAX_AC32_CARDS	4	/* Max number of AC32 cards per module */
-static struct net_device dev_ac32[MAX_AC32_CARDS];
+static struct net_device *dev_ac32[MAX_AC32_CARDS];
 static int io[MAX_AC32_CARDS];
 static int irq[MAX_AC32_CARDS];
 static int mem[MAX_AC32_CARDS];
@@ -354,26 +395,33 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_AC32_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ac32[this_dev];
+		if (io[this_dev] == 0 && this_dev != 0)
+			break;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];		/* Currently ignored by driver */
-		dev->init = ac3200_probe;
-		/* Default is to only install one card. */
-		if (io[this_dev] == 0 && this_dev != 0) break;
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "ac3200.c: No ac3200 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		if (do_ac3200_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_ac32[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "ac3200.c: No ac3200 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -382,16 +430,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_AC32_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ac32[this_dev];
-		if (dev->priv != NULL) {
-			/* Someday free_irq may be in ac_close_card() */
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, AC_IO_EXTENT);
-			if (ei_status.reg0)
-				iounmap((void *)dev->mem_start);
+		struct net_device *dev = dev_ac32[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
