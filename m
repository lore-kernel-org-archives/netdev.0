From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (28/42) ultra32
Date: Wed, 12 Nov 2003 16:44:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0iw231036@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE52-ultra32
	* switched smc-ultra32 to dynamic allocation
	* smc-ultra32: fixed order of freeing bugs
	* smc-ultra32: fixed clobbering on autoprobe
	* smc-ultra32: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:23:43 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:23:43 2003
@@ -43,7 +43,7 @@
 extern struct net_device *ne2_probe(int unit);
 extern struct net_device *hp100_probe(int unit);
 extern struct net_device *ultra_probe(int unit);
-extern int ultra32_probe(struct net_device *dev);
+extern struct net_device *ultra32_probe(int unit);
 extern struct net_device *wd_probe(int unit);
 extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
@@ -160,14 +160,11 @@
  * drivers that probe for EISA cards (in the ISA group).  These are the
  * legacy EISA only driver probes, and also the legacy PCI probes
  */
-static struct devprobe eisa_probes[] __initdata = {
+
+static struct devprobe2 eisa_probes[] __initdata = {
 #ifdef CONFIG_ULTRA32 
 	{ultra32_probe, 0},	
 #endif
-	{NULL, 0},
-};
-
-static struct devprobe2 eisa_probes2[] __initdata = {
 #ifdef CONFIG_AC3200	
 	{ac3200_probe, 0},
 #endif
@@ -379,8 +376,7 @@
 	 * will be probed before other ISA/EISA/MCA/PCI bus cards.
 	 */
 	if (probe_list(dev, m68k_probes) == 0 ||
-	    probe_list(dev, mips_probes) == 0 ||
-	    probe_list(dev, eisa_probes) == 0)
+	    probe_list(dev, mips_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
@@ -396,7 +392,7 @@
 	if (base_addr == 1)
 		return;
 
-	probe_list2(unit, eisa_probes2, base_addr == 0) &&
+	probe_list2(unit, eisa_probes, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
 	probe_list2(unit, isa_probes, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
diff -Nru a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
--- a/drivers/net/smc-ultra32.c	Tue Nov 11 14:23:43 2003
+++ b/drivers/net/smc-ultra32.c	Tue Nov 11 14:23:43 2003
@@ -61,7 +61,6 @@
 
 #include "8390.h"
 
-int ultra32_probe(struct net_device *dev);
 static int ultra32_probe1(struct net_device *dev, int ioaddr);
 static int ultra32_open(struct net_device *dev);
 static void ultra32_reset_8390(struct net_device *dev);
@@ -98,26 +97,60 @@
 #define ULTRA32_CFG6	(-0x15)	/* 0xc8b */
 #define ULTRA32_CFG7	0x0d	/* 0xcad */
 
+static void cleanup_card(struct net_device *dev)
+{
+	int ioaddr = dev->base_addr - ULTRA32_NIC_OFFSET;
+	/* NB: ultra32_close_card() does free_irq */
+	release_region(ioaddr, ULTRA32_IO_EXTENT);
+	kfree(dev->priv);
+}
 
 /*	Probe for the Ultra32.  This looks like a 8013 with the station
 	address PROM at I/O ports <base>+8 to <base>+13, with a checksum
 	following.
 */
 
-int __init ultra32_probe(struct net_device *dev)
+struct net_device * __init ultra32_probe(int unit)
 {
-	int ioaddr;
-
-	if (!EISA_bus) return -ENODEV;
+	struct net_device *dev;
+	int base;
+	int irq;
+	int err = -ENODEV;
+
+	if (!EISA_bus)
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(0);
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	/* EISA spec allows for up to 16 slots, but 8 is typical. */
-	for (ioaddr = 0x1000 + ULTRA32_BASE; ioaddr < 0x9000; ioaddr += 0x1000)
-		if (ultra32_probe1(dev, ioaddr) == 0)
-			return 0;
+	irq = dev->irq;
 
-	return -ENODEV;
+	/* EISA spec allows for up to 16 slots, but 8 is typical. */
+	for (base = 0x1000 + ULTRA32_BASE; base < 0x9000; base += 0x1000) {
+		if (ultra32_probe1(dev, base) == 0)
+			break;
+		dev->irq = irq;
+	}
+	if (base >= 0x9000)
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
 }
 
 static int __init ultra32_probe1(struct net_device *dev, int ioaddr)
@@ -380,7 +413,7 @@
 
 #ifdef MODULE
 #define MAX_ULTRA32_CARDS   4	/* Max number of Ultra cards per module */
-static struct net_device dev_ultra[MAX_ULTRA32_CARDS];
+static struct net_device *dev_ultra[MAX_ULTRA32_CARDS];
 
 MODULE_DESCRIPTION("SMC Ultra32 EISA ethernet driver");
 MODULE_LICENSE("GPL");
@@ -390,18 +423,15 @@
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_ULTRA32_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ultra[this_dev];
-		dev->init = ultra32_probe;
-		if (register_netdev(dev) != 0) {
-			if (found > 0) { /* Got at least one. */
-				return 0;
-			}
-			printk(KERN_WARNING "smc-ultra32.c: No SMC Ultra32 found.\n");
-			return -ENXIO;
-		}
-		found++;
+		struct net_device *dev = ultra32_probe(-1);
+		if (IS_ERR(dev))
+			break;
+		dev_ultra[found++] = dev;
 	}
-	return 0;
+	if (found)
+		return 0;
+	printk(KERN_WARNING "smc-ultra32.c: No SMC Ultra32 found.\n");
+	return -ENXIO;
 }
 
 void cleanup_module(void)
@@ -409,14 +439,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_ULTRA32_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ultra[this_dev];
-		if (dev->priv != NULL) {
-			int ioaddr = dev->base_addr - ULTRA32_NIC_OFFSET;
-			void *priv = dev->priv;
-			/* NB: ultra32_close_card() does free_irq */
-			release_region(ioaddr, ULTRA32_IO_EXTENT);
+		struct net_device *dev = dev_ultra[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
