From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/42) ne
Date: Wed, 12 Nov 2003 16:42:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0gI730471@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on NE36-ne
	* switched ne/ne2k_cbus to dynamic allocation
	* ne/ne2k_cbus: fixed order of freeing bugs
	* ne/ne2k_cbus: fixed resource leaks on failure exits
	* ne/ne2k_cbus: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:35:31 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:35:31 2003
@@ -46,7 +46,7 @@
 extern int ultra32_probe(struct net_device *dev);
 extern int wd_probe(struct net_device *dev);
 extern int el2_probe(struct net_device *dev);
-extern int ne_probe(struct net_device *dev);
+extern struct net_device *ne_probe(int unit);
 extern int hp_probe(struct net_device *dev);
 extern int hp_plus_probe(struct net_device *dev);
 extern struct net_device *express_probe(int unit);
@@ -222,13 +222,13 @@
 #ifdef CONFIG_E2100		/* Cabletron E21xx series. */
 	{e2100_probe, 0},
 #endif
-#if defined(CONFIG_NE2000) || defined(CONFIG_NE2K_CBUS)	/* ISA & PC-9800 CBUS (use ne2k-pci for PCI cards) */
-	{ne_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#if defined(CONFIG_NE2000) || defined(CONFIG_NE2K_CBUS)	/* ISA & PC-9800 CBUS (use ne2k-pci for PCI cards) */
+	{ne_probe, 0},
+#endif
 #ifdef CONFIG_LANCE		/* ISA/VLB (use pcnet32 for PCI cards) */
 	{lance_probe, 0},
 #endif
diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c
--- a/drivers/net/ne.c	Tue Nov 11 14:35:31 2003
+++ b/drivers/net/ne.c	Tue Nov 11 14:35:31 2003
@@ -126,7 +126,6 @@
 #define NESM_START_PG	0x40	/* First page of TX buffer */
 #define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
 
-int ne_probe(struct net_device *dev);
 static int ne_probe1(struct net_device *dev, int ioaddr);
 static int ne_probe_isapnp(struct net_device *dev);
 
@@ -163,9 +162,10 @@
 	E2010	 starts at 0x100 and ends at 0x4000.
 	E2010-x starts at 0x100 and ends at 0xffff.  */
 
-int __init ne_probe(struct net_device *dev)
+static int __init do_ne_probe(struct net_device *dev)
 {
 	unsigned int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -183,6 +183,7 @@
 	/* Last resort. The semi-risky ISA auto-probe. */
 	for (base_addr = 0; netcard_portlist[base_addr] != 0; base_addr++) {
 		int ioaddr = netcard_portlist[base_addr];
+		dev->irq = irq;
 		if (ne_probe1(dev, ioaddr) == 0)
 			return 0;
 	}
@@ -191,6 +192,44 @@
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	void *priv = dev->priv;
+	struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+	if (idev)
+		pnp_device_detach(idev);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, NE_IO_EXTENT);
+	kfree(priv);
+}
+
+struct net_device * __init ne_probe(int unit)
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
+	err = do_ne_probe(dev);
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
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
 	int i;
@@ -734,7 +773,7 @@
 
 #ifdef MODULE
 #define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct net_device dev_ne[MAX_NE_CARDS];
+static struct net_device *dev_ne[MAX_NE_CARDS];
 static int io[MAX_NE_CARDS];
 static int irq[MAX_NE_CARDS];
 static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
@@ -758,25 +797,32 @@
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
+		struct net_device *dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->init = ne_probe;
-		if (register_netdev(dev) == 0) {
-			found++;
-			continue;
-		}
-		if (found != 0) { 	/* Got at least one. */
-			return 0;
+		if (do_ne_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_ne[found++] = dev;
+				continue;
+			}
+			cleanup_card(dev);
 		}
+		free_netdev(dev);
+		if (found)
+			break;
 		if (io[this_dev] != 0)
 			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
 		else
 			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
 		return -ENXIO;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENODEV;
 }
 
 void cleanup_module(void)
@@ -784,16 +830,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
-			if (idev)
-				pnp_device_detach(idev);
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, NE_IO_EXTENT);
+		struct net_device *dev = dev_ne[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/ne2k_cbus.c b/drivers/net/ne2k_cbus.c
--- a/drivers/net/ne2k_cbus.c	Tue Nov 11 14:35:31 2003
+++ b/drivers/net/ne2k_cbus.c	Tue Nov 11 14:35:31 2003
@@ -78,7 +78,6 @@
 
 #include "ne2k_cbus.h"
 
-int ne_probe(struct net_device *dev);
 static int ne_probe1(struct net_device *dev, int ioaddr);
 static int ne_open(struct net_device *dev);
 static int ne_close(struct net_device *dev);
@@ -113,9 +112,10 @@
 	E2010	 starts at 0x100 and ends at 0x4000.
 	E2010-x starts at 0x100 and ends at 0xffff.  */
 
-int __init ne_probe(struct net_device *dev)
+static int __init do_ne_probe(struct net_device *dev)
 {
 	unsigned int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -135,7 +135,7 @@
 		if (ei_debug > 2)
 			printk(KERN_DEBUG "ne_probe(): call ne_probe_cbus(base_addr=0x%x)\n", base_addr);
 
-		result = ne_probe_cbus(dev, hw, base_addr);
+		result = ne_probe_cbus(dev, hw, base_addr, irq);
 		if (result != 0)
 			ne2k_cbus_destroy(dev);
 
@@ -156,13 +156,13 @@
 		if (hw && hw->hwtype) {
 			const unsigned short *plist;
 			for (plist = hw->portlist; *plist; plist++)
-				if (ne_probe_cbus(dev, hw, *plist) == 0)
+				if (ne_probe_cbus(dev, hw, *plist, irq) == 0)
 					return 0;
 		} else {
 			for (hw = &ne2k_cbus_hwinfo_list[0]; hw->hwtype; hw++) {
 				const unsigned short *plist;
 				for (plist = hw->portlist; *plist; plist++)
-					if (ne_probe_cbus(dev, hw, *plist) == 0)
+					if (ne_probe_cbus(dev, hw, *plist, irq) == 0)
 						return 0;
 			}
 		}
@@ -174,7 +174,47 @@
 	return -ENODEV;
 }
 
-static int __init ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr)
+static void cleanup_card(struct net_device *dev)
+{
+	const struct ne2k_cbus_region *rlist;
+	const struct ne2k_cbus_hwinfo *hw = ne2k_cbus_get_hwinfo((int)(dev->mem_start & NE2K_CBUS_HARDWARE_TYPE_MASK));
+
+	free_irq(dev->irq, dev);
+	for (rlist = hw->regionlist; rlist->range; rlist++) {
+		release_region(dev->base_addr + rlist->start,
+				rlist->range);
+	}
+	ne2k_cbus_destroy(dev);
+}
+
+struct net_device * __init ne_probe(int unit)
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
+	err = do_ne_probe(dev);
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
+static int __init ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr, int irq)
 {
 	if (ei_debug > 2)
 		printk(KERN_DEBUG "ne_probe_cbus(): entered. (called from %p)\n",
@@ -182,6 +222,7 @@
 
 	if (hw && hw->hwtype) {
 		ne2k_cbus_set_hwtype(dev, hw, ioaddr);
+		dev->irq = irq;
 		return ne_probe1(dev, ioaddr);
 	} else {
 		/* auto detect */
@@ -189,6 +230,7 @@
 		printk(KERN_DEBUG "ne_probe_cbus(): try to determine hardware types.\n");
 		for (hw = &ne2k_cbus_hwinfo_list[0]; hw->hwtype; hw++) {
 			ne2k_cbus_set_hwtype(dev, hw, ioaddr);
+			dev->irq = irq;
 			if (ne_probe1(dev, ioaddr) == 0)
 				return 0;
 		}
@@ -301,11 +343,12 @@
 		if (ei_debug > 2)
 			printk(" [CNET98EL-specific initialize...");
 		outb_p(E8390_NODMA | E8390_STOP, ioaddr + E8390_CMD); /* 0x20|0x1 */
+		ret = -ENODEV;
 		i = inb(ioaddr);
 		if ((i & ~0x2) != (0x20 | 0x01))
-			return -ENODEV;
+			goto err_out;
 		if ((inb(ioaddr + 0x7) & 0x80) != 0x80)
-			return -ENODEV;
+			goto err_out;
 		outb_p(E8390_RXOFF, ioaddr + EN0_RXCR); /* out(ioaddr+0xc, 0x20) */
 		/* outb_p(ENDCFG_WTS|ENDCFG_FT1|ENDCFG_LS, ioaddr+EN0_DCFG); */
 		outb_p(ENDCFG_WTS | 0x48, ioaddr + EN0_DCFG); /* 0x49 */
@@ -330,7 +373,7 @@
 			if (ei_debug > 2)
 				printk("] ");
 			printk("memory failure at %x\n", i);
-			return -ENODEV;
+			goto err_out;
 		}
 		if (ei_debug > 2)
 			printk(" good...");
@@ -338,7 +381,7 @@
 			if (ei_debug > 2)
 				printk("] ");
 			printk("IRQ must be specified for C-NET(98)E/L. probe failed.\n");
-			return -ENODEV;
+			goto err_out;
 		}
 		outb((dev->irq > 5) ? (dev->irq & 4):(dev->irq >> 1), ioaddr + (0x2 | 0x400));
 		outb(0x7e, ioaddr + (0x4 | 0x400));
@@ -779,7 +822,7 @@
 
 #ifdef MODULE
 #define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct net_device dev_ne[MAX_NE_CARDS];
+static struct net_device *dev_ne[MAX_NE_CARDS];
 static int io[MAX_NE_CARDS];
 static int irq[MAX_NE_CARDS];
 static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
@@ -806,26 +849,33 @@
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
+		struct net_device *dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
 		dev->mem_start = hwtype[this_dev];
-		dev->init = ne_probe;
-		if (register_netdev(dev) == 0) {
-			found++;
-			continue;
-		}
-		if (found != 0) { 	/* Got at least one. */
-			return 0;
+		if (do_ne_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_ne[found++] = dev;
+				continue;
+			}
+			cleanup_card(dev);
 		}
+		free_netdev(dev);
+		if (found)
+			break;
 		if (io[this_dev] != 0)
 			printk(KERN_WARNING "ne2k_cbus: No NE*000 card found at i/o = %#x\n", io[this_dev]);
 		else
-			printk(KERN_NOTICE "ne2k_cbus: You must supply \"io=0xNNN\" value(s) for C-Bus cards.\n");
+			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
 		return -ENXIO;
 	}
-	return 0;
+	if (found)
+		return 0;
+ 	return -ENODEV;
 }
 
 void cleanup_module(void)
@@ -833,18 +883,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
-		if (dev->priv != NULL) {
-			const struct ne2k_cbus_region *rlist;
-			const struct ne2k_cbus_hwinfo *hw = ne2k_cbus_get_hwinfo((int)(dev->mem_start & NE2K_CBUS_HARDWARE_TYPE_MASK));
-
-			free_irq(dev->irq, dev);
-			for (rlist = hw->regionlist; rlist->range; rlist++) {
-				release_region(dev->base_addr + rlist->start,
-						rlist->range);
-			}
+		struct net_device *dev = dev_ne[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			ne2k_cbus_destroy(dev);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/ne2k_cbus.h b/drivers/net/ne2k_cbus.h
--- a/drivers/net/ne2k_cbus.h	Tue Nov 11 14:35:31 2003
+++ b/drivers/net/ne2k_cbus.h	Tue Nov 11 14:35:31 2003
@@ -477,5 +477,5 @@
 }
 #endif
 
-static int ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr);
+static int ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr, int irq);
 /* End of ne2k_cbus.h */
