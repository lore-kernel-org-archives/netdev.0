From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (14/42) hpplus
Date: Wed, 12 Nov 2003 16:42:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0gci30563@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on NE38-hpplus
	* switched hp-plus to dynamic allocation
	* hp-plus: fixed order of freeing bugs
	* hp-plus: fixed resource leaks on failure exits
	* hp-plus: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:58 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:58 2003
@@ -48,7 +48,7 @@
 extern int el2_probe(struct net_device *dev);
 extern struct net_device *ne_probe(int unit);
 extern int hp_probe(struct net_device *dev);
-extern int hp_plus_probe(struct net_device *dev);
+extern struct net_device *hp_plus_probe(int unit);
 extern struct net_device *express_probe(int unit);
 extern struct net_device *eepro_probe(int unit);
 extern struct net_device *at1700_probe(int unit);
@@ -216,13 +216,13 @@
 #ifdef CONFIG_HPLAN
 	{hp_probe, 0},
 #endif
-#ifdef CONFIG_HPLAN_PLUS
-	{hp_plus_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_HPLAN_PLUS
+	{hp_plus_probe, 0},
+#endif
 #ifdef CONFIG_E2100		/* Cabletron E21xx series. */
 	{e2100_probe, 0},
 #endif
diff -Nru a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
--- a/drivers/net/hp-plus.c	Tue Nov 11 09:35:58 2003
+++ b/drivers/net/hp-plus.c	Tue Nov 11 09:35:58 2003
@@ -92,7 +92,6 @@
 	EnableIRQ = 4, FakeIntr = 8, BootROMEnb = 0x10, IOEnb = 0x20,
 	MemEnable = 0x40, ZeroWait = 0x80, MemDisable = 0x1000, };
 
-int hp_plus_probe(struct net_device *dev);
 static int hpp_probe1(struct net_device *dev, int ioaddr);
 
 static void hpp_reset_8390(struct net_device *dev);
@@ -115,10 +114,11 @@
 /*	Probe a list of addresses for an HP LAN+ adaptor.
 	This routine is almost boilerplate. */
 
-int __init hp_plus_probe(struct net_device *dev)
+static int __init do_hpp_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -127,13 +127,49 @@
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
-	for (i = 0; hpplus_portlist[i]; i++)
+	for (i = 0; hpplus_portlist[i]; i++) {
 		if (hpp_probe1(dev, hpplus_portlist[i]) == 0)
 			return 0;
+		dev->irq = irq;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	/* NB: hpp_close() handles free_irq */
+	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init hp_plus_probe(int unit)
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
+	err = do_hpp_probe(dev);
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
 /* Do the interesting part of the probe at a single address. */
 static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 {
@@ -400,7 +436,7 @@
 
 #ifdef MODULE
 #define MAX_HPP_CARDS	4	/* Max number of HPP cards per module */
-static struct net_device dev_hpp[MAX_HPP_CARDS];
+static struct net_device *dev_hpp[MAX_HPP_CARDS];
 static int io[MAX_HPP_CARDS];
 static int irq[MAX_HPP_CARDS];
 
@@ -416,27 +452,34 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_HPP_CARDS; this_dev++) {
-		struct net_device *dev = &dev_hpp[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->init = hp_plus_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "hp-plus.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "hp-plus.c: No HP-Plus card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		if (do_hpp_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_hpp[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "hp-plus.c: No HP-Plus card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -445,14 +488,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_HPP_CARDS; this_dev++) {
-		struct net_device *dev = &dev_hpp[this_dev];
-		if (dev->priv != NULL) {
-			int ioaddr = dev->base_addr - NIC_OFFSET;
-			void *priv = dev->priv;
-			/* NB: hpp_close() handles free_irq */
-			release_region(ioaddr, HP_IO_EXTENT);
+		struct net_device *dev = dev_hpp[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
