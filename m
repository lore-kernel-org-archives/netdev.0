From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (18/42) ultra
Date: Wed, 12 Nov 2003 16:43:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0hIp30689@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE42-ultra
	* switched smc-ultra to dynamic allocation
	* smc-ultra: fixed order of freeing bugs
	* smc-ultra: fixed resource leaks on failure exits
	* smc-ultra: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:36:08 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:36:08 2003
@@ -42,7 +42,7 @@
 
 extern int ne2_probe(struct net_device *dev);
 extern int hp100_probe(struct net_device *dev);
-extern int ultra_probe(struct net_device *dev);
+extern struct net_device *ultra_probe(int unit);
 extern int ultra32_probe(struct net_device *dev);
 extern struct net_device *wd_probe(int unit);
 extern struct net_device *el2_probe(int unit);
@@ -204,13 +204,13 @@
 #ifdef CONFIG_3C515
 	{tc515_probe, 0},
 #endif
-#ifdef CONFIG_ULTRA 
-	{ultra_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ULTRA 
+	{ultra_probe, 0},
+#endif
 #ifdef CONFIG_WD80x3 
 	{wd_probe, 0},
 #endif
diff -Nru a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c	Tue Nov 11 09:36:08 2003
+++ b/drivers/net/smc-ultra.c	Tue Nov 11 09:36:08 2003
@@ -76,7 +76,6 @@
 static unsigned int ultra_portlist[] __initdata =
 {0x200, 0x220, 0x240, 0x280, 0x300, 0x340, 0x380, 0};
 
-int ultra_probe(struct net_device *dev);
 static int ultra_probe1(struct net_device *dev, int ioaddr);
 
 #ifdef __ISAPNP__
@@ -127,10 +126,11 @@
 	following.
 */
 
-int __init ultra_probe(struct net_device *dev)
+static int __init do_ultra_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -147,13 +147,54 @@
 	printk(KERN_NOTICE "smc-ultra.c: No ISAPnP cards found, trying standard ones...\n");
 #endif
 
-	for (i = 0; ultra_portlist[i]; i++)
+	for (i = 0; ultra_portlist[i]; i++) {
+		dev->irq = irq;
 		if (ultra_probe1(dev, ultra_portlist[i]) == 0)
 			return 0;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	/* NB: ultra_close_card() does free_irq */
+#ifdef __ISAPNP__
+	struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+	if (idev)
+		pnp_device_detach(idev);
+#endif
+	release_region(dev->base_addr - ULTRA_NIC_OFFSET, ULTRA_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init ultra_probe(int unit)
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
+	err = do_ultra_probe(dev);
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
 static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, retval;
@@ -500,7 +541,7 @@
 
 #ifdef MODULE
 #define MAX_ULTRA_CARDS	4	/* Max number of Ultra cards per module */
-static struct net_device dev_ultra[MAX_ULTRA_CARDS];
+static struct net_device *dev_ultra[MAX_ULTRA_CARDS];
 static int io[MAX_ULTRA_CARDS];
 static int irq[MAX_ULTRA_CARDS];
 
@@ -516,26 +557,34 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_ULTRA_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ultra[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->init = ultra_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "smc-ultra.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "smc-ultra.c: No SMC Ultra card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) return 0;	/* Got at least one. */
-			return -ENXIO;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		if (do_ultra_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_ultra[found++] = dev;
+				continue;
+			}
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "smc-ultra.c: No SMC Ultra card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -544,20 +593,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_ULTRA_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ultra[this_dev];
-		if (dev->priv != NULL) {
-			/* NB: ultra_close_card() does free_irq */
-			int ioaddr = dev->base_addr - ULTRA_NIC_OFFSET;
-
-#ifdef __ISAPNP__
-			struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
-			if (idev)
-				pnp_device_detach(idev);
-#endif
-
+		struct net_device *dev = dev_ultra[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			release_region(ioaddr, ULTRA_IO_EXTENT);
-			kfree(dev->priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
