From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/42) fmv18
Date: Wed, 12 Nov 2003 16:41:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0f8a29995@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro, NE29-fmv18
	* switched fmv18x to dynamic allocation
	* fmv18x: embedded ->priv
	* fmv18x: fixed resource leaks on failure exits
	* fmv18x: fixed clobbering on autoprobe
	* fmv18x: compile fix - comment is _not_ an empty statement.  The thing
	  had been b0rken since 2.4.3-pre2, BTW...

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 10:19:59 2003
+++ b/drivers/net/Space.c	Tue Nov 11 10:19:59 2003
@@ -53,7 +53,7 @@
 extern struct net_device *eepro_probe(int unit);
 extern int at1500_probe(struct net_device *);
 extern int at1700_probe(struct net_device *);
-extern int fmv18x_probe(struct net_device *);
+extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
@@ -244,13 +244,13 @@
 #ifdef CONFIG_AT1700
 	{at1700_probe, 0},
 #endif
-#ifdef CONFIG_FMV18X		/* Fujitsu FMV-181/182 */
-	{fmv18x_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_FMV18X		/* Fujitsu FMV-181/182 */
+	{fmv18x_probe, 0},
+#endif
 #ifdef CONFIG_ETH16I
 	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
 #endif
diff -Nru a/drivers/net/fmv18x.c b/drivers/net/fmv18x.c
--- a/drivers/net/fmv18x.c	Tue Nov 11 10:19:59 2003
+++ b/drivers/net/fmv18x.c	Tue Nov 11 10:19:59 2003
@@ -57,7 +57,7 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 
-static int fmv18x_probe_list[] __initdata = {
+static unsigned fmv18x_probe_list[] __initdata = {
 	0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x300, 0x340, 0
 };
 
@@ -109,8 +109,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int fmv18x_probe(struct net_device *dev);
-
 static int fmv18x_probe1(struct net_device *dev, short ioaddr);
 static int net_open(struct net_device *dev);
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev);
@@ -129,23 +127,50 @@
    (detachable devices only).
    */
 
-int __init fmv18x_probe(struct net_device *dev)
+static int io = 0x220;
+static int irq;
+
+struct net_device * __init fmv18x_probe(int unit)
 {
-	int i;
-	int base_addr = dev->base_addr;
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	unsigned *port;
+	int err = 0;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		irq = dev->irq;
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return fmv18x_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; fmv18x_probe_list[i]; i++)
-		if (fmv18x_probe1(dev, fmv18x_probe_list[i]) == 0)
-			return 0;
-
-	return -ENODEV;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = fmv18x_probe1(dev, io);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = fmv18x_probe_list; *port; port++)
+			if (fmv18x_probe1(dev, *port) == 0)
+				break;
+		if (!*port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, FMV18X_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /* The Fujitsu datasheet suggests that the NIC be probed for by checking its
@@ -160,7 +185,7 @@
 {
 	char irqmap[4] = {3, 7, 10, 15};
 	char irqmap_pnp[8] = {3, 4, 5, 7, 9, 10, 11, 15};
-	unsigned int i, irq, retval;
+	unsigned int i, retval;
 	struct net_local *lp;
 
 	/* Resetting the chip doesn't reset the ISA interface, so don't bother.
@@ -170,6 +195,9 @@
 	if (!request_region(ioaddr, FMV18X_IO_EXTENT, dev->name))
 		return -EBUSY;
 
+	dev->irq = irq;
+	dev->base_addr = ioaddr;
+
 	/* Check I/O address configuration and Fujitsu vendor code */
 	if (inb(ioaddr+FJ_MACADDR  ) != 0x00
 	||  inb(ioaddr+FJ_MACADDR+1) != 0x00
@@ -181,9 +209,8 @@
 	/* Check PnP mode for FMV-183/184/183A/184A. */
 	/* This PnP routine is very poor. IO and IRQ should be known. */
 	if (inb(ioaddr + FJ_STATUS1) & 0x20) {
-		irq = dev->irq;
 		for (i = 0; i < 8; i++) {
-			if (irq == irqmap_pnp[i])
+			if (dev->irq == irqmap_pnp[i])
 				break;
 		}
 		if (i == 8) {
@@ -193,22 +220,19 @@
 	} else {
 		if (fmv18x_probe_list[inb(ioaddr + FJ_CONFIG0) & 0x07] != ioaddr)
 			return -ENODEV;
-		irq = irqmap[(inb(ioaddr + FJ_CONFIG0)>>6) & 0x03];
+		dev->irq = irqmap[(inb(ioaddr + FJ_CONFIG0)>>6) & 0x03];
 	}
 
 	/* Snarf the interrupt vector now. */
-	retval = request_irq(irq, &net_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, &net_interrupt, 0, dev->name, dev);
 	if (retval) {
 		printk ("FMV-18x found at %#3x, but it's unusable due to a conflict on"
-				"IRQ %d.\n", ioaddr, irq);
+				"IRQ %d.\n", ioaddr, dev->irq);
 		goto out;
 	}
 
 	printk("%s: FMV-18x found at %#3x, IRQ %d, address ", dev->name,
-		   ioaddr, irq);
-
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
+		   ioaddr, dev->irq);
 
 	for(i = 0; i < 6; i++) {
 		unsigned char val = inb(ioaddr + FJ_MACADDR + i);
@@ -279,14 +303,10 @@
 	dev->watchdog_timeo	= HZ/10;
 	dev->get_stats		= net_get_stats;
 	dev->set_multicast_list = set_multicast_list;
-
-	/* Fill in the fields of 'dev' with ethernet-generic values. */
-
-	ether_setup(dev);
 	return 0;
 
 out_irq:
-	free_irq(irq, dev);
+	free_irq(dev->irq, dev);
 out:
 	release_region(ioaddr, FMV18X_IO_EXTENT);
 	return retval;
@@ -413,9 +433,7 @@
 		lp->tx_queue_len = 0;
 		dev->trans_start = jiffies;
 		lp->tx_started = 1;
-	} else if (lp->tx_queue_len < 4096 - 1502)
-		/* Yes, there is room for one more packet. */
-	else
+	} else if (lp->tx_queue_len >= 4096 - 1502) /* No room for a packet */
 		netif_stop_queue(dev);
 
 	dev_kfree_skb(skb);
@@ -628,9 +646,7 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_fmv18x;
-static int io = 0x220;
-static int irq;
+static struct net_device *dev_fmv18x;
 
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -644,26 +660,19 @@
 {
 	if (io == 0)
 		printk("fmv18x: You should not use auto-probing with insmod!\n");
-	dev_fmv18x.base_addr	= io;
-	dev_fmv18x.irq		= irq;
-	dev_fmv18x.init		= fmv18x_probe;
-	if (register_netdev(&dev_fmv18x) != 0) {
-		printk("fmv18x: register_netdev() returned non-zero.\n");
-		return -EIO;
-	}
+	dev_fmv18x = fmv18x_probe(-1);
+	if (IS_ERR(dev_fmv18x))
+		return PTR_ERR(dev_fmv18x);
 	return 0;
 }
 
 void
 cleanup_module(void)
 {
-	unregister_netdev(&dev_fmv18x);
-	kfree(dev_fmv18x.priv);
-	dev_fmv18x.priv = NULL;
-
-	/* If we don't do this, we can't re-insmod it later. */
-	free_irq(dev_fmv18x.irq, &dev_fmv18x);
-	release_region(dev_fmv18x.base_addr, FMV18X_IO_EXTENT);
+	unregister_netdev(dev_fmv18x);
+	free_irq(dev_fmv18x->irq, dev_fmv18x);
+	release_region(dev_fmv18x->base_addr, FMV18X_IO_EXTENT);
+	free_netdev(dev_fmv18x);
 }
 #endif /* MODULE */
 
