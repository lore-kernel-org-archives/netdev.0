From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/42) lance
Date: Wed, 12 Nov 2003 16:42:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0g8I30434@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE35-lance
	* switched lance to dynamic allocation
	* lance: fixed init_etherdev races
	* lance: fixed resource leaks on failure exits
	* NB: probing code is, to put it mildly, odd.  It _always_ does
	  autoprobe, modular or not.  WTF is going on there?

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:50 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:50 2003
@@ -85,7 +85,7 @@
 extern int bagetlance_probe(struct net_device *);
 extern int mvme147lance_probe(struct net_device *dev);
 extern int tc515_probe(struct net_device *dev);
-extern int lance_probe(struct net_device *dev);
+extern struct net_device *lance_probe(int unit);
 extern int mace_probe(struct net_device *dev);
 extern int macsonic_probe(struct net_device *dev);
 extern int mac8390_probe(struct net_device *dev);
@@ -225,13 +225,13 @@
 #if defined(CONFIG_NE2000) || defined(CONFIG_NE2K_CBUS)	/* ISA & PC-9800 CBUS (use ne2k-pci for PCI cards) */
 	{ne_probe, 0},
 #endif
-#ifdef CONFIG_LANCE		/* ISA/VLB (use pcnet32 for PCI cards) */
-	{lance_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_LANCE		/* ISA/VLB (use pcnet32 for PCI cards) */
+	{lance_probe, 0},
+#endif
 #ifdef CONFIG_SMC9194
 	{smc_init, 0},
 #endif
diff -Nru a/drivers/net/lance.c b/drivers/net/lance.c
--- a/drivers/net/lance.c	Tue Nov 11 09:35:50 2003
+++ b/drivers/net/lance.c	Tue Nov 11 09:35:50 2003
@@ -59,8 +59,8 @@
 #include <asm/dma.h>
 
 static unsigned int lance_portlist[] __initdata = { 0x300, 0x320, 0x340, 0x360, 0};
-int lance_probe(struct net_device *dev);
 static int lance_probe1(struct net_device *dev, int ioaddr, int irq, int options);
+static int __init do_lance_probe(struct net_device *dev);
 
 #ifdef LANCE_DEBUG
 static int lance_debug = LANCE_DEBUG;
@@ -274,7 +274,6 @@
 static unsigned char lance_need_isa_bounce_buffers = 1;
 
 static int lance_open(struct net_device *dev);
-static int lance_open_fail(struct net_device *dev);
 static void lance_init_ring(struct net_device *dev, int mode);
 static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lance_rx(struct net_device *dev);
@@ -286,10 +285,21 @@
 
 
 
+static void cleanup_card(struct net_device *dev)
+{
+	struct lance_private *lp = dev->priv;
+	if (dev->dma != 4)
+		free_dma(dev->dma);
+	release_region(dev->base_addr, LANCE_TOTAL_SIZE);
+	kfree(lp->tx_bounce_buffs);
+	kfree((void*)lp->rx_buffs);
+	kfree(lp);
+}
+
 #ifdef MODULE
 #define MAX_CARDS		8	/* Max number of interfaces (cards) per module */
 
-static struct net_device dev_lance[MAX_CARDS];
+static struct net_device *dev_lance[MAX_CARDS];
 static int io[MAX_CARDS];
 static int dma[MAX_CARDS];
 static int irq[MAX_CARDS];
@@ -305,28 +315,35 @@
 
 int init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_lance[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->dma = dma[this_dev];
-		dev->init = lance_probe;
 		if (io[this_dev] == 0)  {
-			if (this_dev != 0) break; /* only complain once */
+			if (this_dev != 0) /* only complain once */
+				break;
 			printk(KERN_NOTICE "lance.c: Module autoprobing not allowed. Append \"io=0xNNN\" value(s).\n");
 			return -EPERM;
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "lance.c: No PCnet/LANCE card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) return 0;	/* Got at least one. */
-			return -ENXIO;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		dev->dma = dma[this_dev];
+		if (do_lance_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_lance[found++] = dev;
+				continue;
+			}
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		break;
 	}
-
-	return 0;
+	if (found != 0)
+		return 0;
+	return -ENXIO;
 }
 
 void cleanup_module(void)
@@ -334,13 +351,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_lance[this_dev];
-		if (dev->priv != NULL) {
+		struct net_device *dev = dev_lance[this_dev];
+		if (dev) {
 			unregister_netdev(dev);	
-			free_dma(dev->dma);
-			release_region(dev->base_addr, LANCE_TOTAL_SIZE);
-			kfree(dev->priv);
-			dev->priv = NULL;
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
@@ -352,7 +367,7 @@
    board probes now that kmalloc() can allocate ISA DMA-able regions.
    This also allows the LANCE driver to be used as a module.
    */
-int __init lance_probe(struct net_device *dev)
+static int __init do_lance_probe(struct net_device *dev)
 {
 	int *port, result;
 
@@ -387,6 +402,31 @@
 	return -ENODEV;
 }
 
+struct net_device * __init lance_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(0);
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = do_lance_probe(dev);
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
 static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int options)
 {
 	struct lance_private *lp;
@@ -398,6 +438,7 @@
 	int hp_builtin = 0;			/* HP on-board ethernet. */
 	static int did_version;			/* Already printed version info. */
 	unsigned long flags;
+	int err = -ENOMEM;
 
 	/* First we look for special cases.
 	   Check for HP's on-board ethernet by looking for 'HP' in the BIOS.
@@ -432,7 +473,7 @@
 	outw(88, ioaddr+LANCE_ADDR);
 	if (inw(ioaddr+LANCE_ADDR) != 88) {
 		lance_version = 0;
-	} else {							/* Good, it's a newer chip. */
+	} else {			/* Good, it's a newer chip. */
 		int chip_version = inw(ioaddr+LANCE_DATA);
 		outw(89, ioaddr+LANCE_ADDR);
 		chip_version |= inw(ioaddr+LANCE_DATA) << 16;
@@ -447,13 +488,9 @@
 		}
 	}
 
-	/* We can't use init_etherdev() to allocate dev->priv because it must
+	/* We can't allocate dev->priv from alloc_etherdev() because it must
 	   a ISA DMA-able region. */
-	dev = init_etherdev(dev, 0);
-	if (!dev)
-		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
-	dev->open = lance_open_fail;
 	chipname = chip_table[lance_version].name;
 	printk("%s: %s at %#3x,", dev->name, chipname, ioaddr);
 
@@ -465,8 +502,7 @@
 	dev->base_addr = ioaddr;
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
 		
-	lp = (struct lance_private *)(((unsigned long)kmalloc(sizeof(*lp)+7,
-					   GFP_DMA | GFP_KERNEL)+7) & ~7);
+	lp = kmalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
 	if(lp==NULL)
 		return -ENODEV;
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
@@ -486,7 +522,7 @@
 		lp->tx_bounce_buffs = NULL;
 
 	lp->chip_version = lance_version;
-	lp->devlock = SPIN_LOCK_UNLOCKED;
+	spin_lock_init(&lp->devlock);
 
 	lp->init_block.mode = 0x0003;		/* Disable Rx and Tx. */
 	for (i = 0; i < 6; i++)
@@ -540,6 +576,7 @@
 		dma_channels = ((inb(DMA1_STAT_REG) >> 4) & 0x0f) |
 			(inb(DMA2_STAT_REG) & 0xf0);
 	}
+	err = -ENODEV;
 	if (dev->irq >= 2)
 		printk(" assigned IRQ %d", dev->irq);
 	else if (lance_version != 0)  {	/* 7990 boards need DMA detection first. */
@@ -559,7 +596,7 @@
 			printk(", probed IRQ %d", dev->irq);
 		else {
 			printk(", failed to detect IRQ line.\n");
-			return -ENODEV;
+			goto out_tx;
 		}
 
 		/* Check for the initialization done bit, 0x0100, which means
@@ -573,7 +610,7 @@
 	} else if (dev->dma) {
 		if (request_dma(dev->dma, chipname)) {
 			printk("DMA %d allocation failed.\n", dev->dma);
-			return -ENODEV;
+			goto out_tx;
 		} else
 			printk(", assigned DMA %d.\n", dev->dma);
 	} else {			/* OK, we have to auto-DMA. */
@@ -613,7 +650,7 @@
 		}
 		if (i == 4) {			/* Failure: bail. */
 			printk("DMA detection failed.\n");
-			return -ENODEV;
+			goto out_tx;
 		}
 	}
 
@@ -629,7 +666,7 @@
 		dev->irq = probe_irq_off(irq_mask);
 		if (dev->irq == 0) {
 			printk("  Failed to detect the 7990 IRQ line.\n");
-			return -ENODEV;
+			goto out_dma;
 		}
 		printk("  Auto-IRQ detected IRQ%d.\n", dev->irq);
 	}
@@ -655,17 +692,17 @@
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return 0;
-out_rx:	kfree((void*)lp->rx_buffs);
-out_lp:	kfree(lp);
-	return -ENOMEM;
+out_dma:
+	if (dev->dma != 4)
+		free_dma(dev->dma);
+out_tx:
+	kfree(lp->tx_bounce_buffs);
+out_rx:
+	kfree((void*)lp->rx_buffs);
+out_lp:
+	kfree(lp);
+	return err;
 }
-
-static int
-lance_open_fail(struct net_device *dev)
-{
-	return -ENODEV;
-}
-
 
 
 static int
