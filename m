From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (16/42) 3c503
Date: Wed, 12 Nov 2003 16:42:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0gwO30638@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE40-3c503
	* switched 3c503 to dynamic allocation
	* 3c503: fixed order of freeing bugs
	* 3c503: fixed IO without request_region
	* 3c503: fixed resource leaks on failure exits
	* 3c503: fixed clobbering on autoprobe


diff -Nru a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	Tue Nov 11 09:36:03 2003
+++ b/drivers/net/3c503.c	Tue Nov 11 09:36:03 2003
@@ -60,7 +60,6 @@
 #include "3c503.h"
 #define WRD_COUNT 4
 
-int el2_probe(struct net_device *dev);
 static int el2_pio_probe(struct net_device *dev);
 static int el2_probe1(struct net_device *dev, int ioaddr);
 
@@ -90,11 +89,11 @@
    If the ethercard isn't found there is an optional probe for
    ethercard jumpered to programmed-I/O mode.
    */
-int __init 
-el2_probe(struct net_device *dev)
+static int __init do_el2_probe(struct net_device *dev)
 {
     int *addr, addrs[] = { 0xddffe, 0xd9ffe, 0xcdffe, 0xc9ffe, 0};
     int base_addr = dev->base_addr;
+    int irq = dev->irq;
 
     SET_MODULE_OWNER(dev);
     
@@ -104,16 +103,13 @@
 	return -ENXIO;
 
     for (addr = addrs; *addr; addr++) {
-	int i;
-	unsigned int base_bits = isa_readb(*addr);
-	/* Find first set bit. */
-	for(i = 7; i >= 0; i--, base_bits >>= 1)
-	    if (base_bits & 0x1)
-		break;
-	if (base_bits != 1)
+	unsigned base_bits = isa_readb(*addr);
+	int i = ffs(base_bits) - 1;
+	if (i == -1 || base_bits != (1 << i))
 	    continue;
 	if (el2_probe1(dev, netcard_portlist[i]) == 0)
 	    return 0;
+	dev->irq = irq;
     }
 #if ! defined(no_probe_nonshared_memory)
     return el2_pio_probe(dev);
@@ -128,20 +124,57 @@
 el2_pio_probe(struct net_device *dev)
 {
     int i;
-    int base_addr = dev ? dev->base_addr : 0;
+    int base_addr = dev->base_addr;
+    int irq = dev->irq;
 
     if (base_addr > 0x1ff)	/* Check a single specified location. */
 	return el2_probe1(dev, base_addr);
     else if (base_addr != 0)	/* Don't probe at all. */
 	return -ENXIO;
 
-    for (i = 0; netcard_portlist[i]; i++)
+    for (i = 0; netcard_portlist[i]; i++) {
 	if (el2_probe1(dev, netcard_portlist[i]) == 0)
 	    return 0;
+	dev->irq = irq;
+    }
 
     return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	/* NB: el2_close() handles free_irq */
+	release_region(dev->base_addr, EL2_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init el2_probe(int unit)
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
+	err = do_el2_probe(dev);
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
 /* Probe for the Etherlink II card at I/O port base IOADDR,
    returning non-zero on success.  If found, set the station
    address and memory parameters in DEVICE. */
@@ -152,15 +185,19 @@
     static unsigned version_printed;
     unsigned long vendor_id;
 
-    /* FIXME: code reads ioaddr + 0x400, we request ioaddr + 16 */
     if (!request_region(ioaddr, EL2_IO_EXTENT, dev->name))
 	return -EBUSY;
 
+    if (!request_region(ioaddr + 0x400, 8, dev->name)) {
+	retval = -EBUSY;
+	goto out;
+    }
+
     /* Reset and/or avoid any lurking NE2000 */
     if (inb(ioaddr + 0x408) == 0xff) {
     	mdelay(1);
 	retval = -ENODEV;
-	goto out;
+	goto out1;
     }
 
     /* We verify that it's a 3C503 board by checking the first three octets
@@ -171,7 +208,7 @@
     if (   (iobase_reg  & (iobase_reg - 1))
 	|| (membase_reg & (membase_reg - 1))) {
 	retval = -ENODEV;
-	goto out;
+	goto out1;
     }
     saved_406 = inb_p(ioaddr + 0x406);
     outb_p(ECNTRL_RESET|ECNTRL_THIN, ioaddr + 0x406); /* Reset it... */
@@ -184,7 +221,7 @@
 	/* Restore the register we frobbed. */
 	outb(saved_406, ioaddr + 0x406);
 	retval = -ENODEV;
-	goto out;
+	goto out1;
     }
 
     if (ei_debug  &&  version_printed++ == 0)
@@ -195,7 +232,7 @@
     if (ethdev_init(dev)) {
 	printk ("3c503: unable to allocate memory for dev->priv.\n");
 	retval = -ENOMEM;
-	goto out;
+	goto out1;
     }
 
     printk("%s: 3c503 at i/o base %#3x, node ", dev->name, ioaddr);
@@ -322,7 +359,10 @@
 	printk("\n%s: %s, %dkB RAM, using programmed I/O (REJUMPER for SHARED MEMORY).\n",
 	       dev->name, ei_status.name, (wordlength+1)<<3);
     }
+    release_region(ioaddr + 0x400, 8);
     return 0;
+out1:
+    release_region(ioaddr + 0x400, 8);
 out:
     release_region(ioaddr, EL2_IO_EXTENT);
     return retval;
@@ -633,7 +673,7 @@
 #ifdef MODULE
 #define MAX_EL2_CARDS	4	/* Max number of EL2 cards per module */
 
-static struct net_device dev_el2[MAX_EL2_CARDS];
+static struct net_device *dev_el2[MAX_EL2_CARDS];
 static int io[MAX_EL2_CARDS];
 static int irq[MAX_EL2_CARDS];
 static int xcvr[MAX_EL2_CARDS];	/* choose int. or ext. xcvr */
@@ -651,28 +691,35 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_EL2_CARDS; this_dev++) {
-		struct net_device *dev = &dev_el2[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
-		dev->init = el2_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "3c503.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "3c503.c: No 3c503 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
+		if (do_el2_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_el2[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "3c503.c: No 3c503 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -681,13 +728,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_EL2_CARDS; this_dev++) {
-		struct net_device *dev = &dev_el2[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			/* NB: el2_close() handles free_irq */
-			release_region(dev->base_addr, EL2_IO_EXTENT);
+		struct net_device *dev = dev_el2[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:36:03 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:36:03 2003
@@ -45,7 +45,7 @@
 extern int ultra_probe(struct net_device *dev);
 extern int ultra32_probe(struct net_device *dev);
 extern int wd_probe(struct net_device *dev);
-extern int el2_probe(struct net_device *dev);
+extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
 extern struct net_device *hp_probe(int unit);
 extern struct net_device *hp_plus_probe(int unit);
@@ -210,13 +210,13 @@
 #ifdef CONFIG_WD80x3 
 	{wd_probe, 0},
 #endif
-#ifdef CONFIG_EL2 		/* 3c503 */
-	{el2_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EL2 		/* 3c503 */
+	{el2_probe, 0},
+#endif
 #ifdef CONFIG_HPLAN
 	{hp_probe, 0},
 #endif
