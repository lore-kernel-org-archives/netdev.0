From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/42) at1700
Date: Wed, 12 Nov 2003 16:41:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0fIg30099@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE30-at1700
	* switched at1700 to dynamic allocation
	* at1700: embedded ->priv
	* at1700: fixed resource leaks on failure exits
	* at1700: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:37 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:37 2003
@@ -52,7 +52,7 @@
 extern struct net_device *express_probe(int unit);
 extern struct net_device *eepro_probe(int unit);
 extern int at1500_probe(struct net_device *);
-extern int at1700_probe(struct net_device *);
+extern struct net_device *at1700_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
@@ -241,13 +241,13 @@
 #ifdef CONFIG_CS89x0
  	{cs89x0_probe, 0},
 #endif
-#ifdef CONFIG_AT1700
-	{at1700_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_AT1700
+	{at1700_probe, 0},
+#endif
 #ifdef CONFIG_FMV18X		/* Fujitsu FMV-181/182 */
 	{fmv18x_probe, 0},
 #endif
diff -Nru a/drivers/net/at1700.c b/drivers/net/at1700.c
--- a/drivers/net/at1700.c	Tue Nov 11 09:35:37 2003
+++ b/drivers/net/at1700.c	Tue Nov 11 09:35:37 2003
@@ -81,12 +81,12 @@
  */
 
 #ifndef CONFIG_X86_PC9800
-static int at1700_probe_list[] __initdata = {
+static unsigned at1700_probe_list[] __initdata = {
 	0x260, 0x280, 0x2a0, 0x240, 0x340, 0x320, 0x380, 0x300, 0
 };
 
 #else /* CONFIG_X86_PC9800 */
-static int at1700_probe_list[] __initdata = {
+static unsigned at1700_probe_list[] __initdata = {
 	0x1d6, 0x1d8, 0x1da, 0x1d4, 0xd4, 0xd2, 0xd8, 0xd0, 0
 };
 
@@ -196,8 +196,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int at1700_probe(struct net_device *dev);
-
 static int at1700_probe1(struct net_device *dev, int ioaddr);
 static int read_eeprom(long ioaddr, int location);
 static int net_open(struct net_device *dev);
@@ -232,24 +230,78 @@
    (detachable devices only).
    */
 
-int __init at1700_probe(struct net_device *dev)
+#ifndef CONFIG_X86_PC9800
+static int io = 0x260;
+#else
+static int io = 0xd0;
+#endif
+
+static int irq;
+
+static void cleanup_card(struct net_device *dev)
 {
-	int i;
-	int base_addr = dev->base_addr;
+#ifdef CONFIG_MCA	
+	struct net_local *lp = dev->priv;
+	if (lp->mca_slot)
+		mca_mark_as_unused(lp->mca_slot);
+#endif	
+	free_irq(dev->irq, NULL);
+#ifndef CONFIG_X86_PC9800
+	release_region(dev->base_addr, AT1700_IO_EXTENT);
+#else
+	{
+		int i;
+		for (i = 0; i < 0x2000; i += 0x200)
+			release_region(dev->base_addr + i, 2);
+	}
+#endif
+}
+
+struct net_device * __init at1700_probe(int unit)
+{
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
+	} else {
+		dev->base_addr = io;
+		dev->irq = irq;
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return at1700_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; at1700_probe_list[i]; i++) {
-		int ioaddr = at1700_probe_list[i];
-		if (at1700_probe1(dev, ioaddr) == 0)
-			return 0;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = at1700_probe1(dev, io);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = at1700_probe_list; *port; port++) {
+			if (at1700_probe1(dev, *port) == 0)
+				break;
+			dev->irq = irq;
+		}
+		if (!*port)
+			err = -ENODEV;
 	}
-	return -ENODEV;
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
 }
 
 /* The Fujitsu datasheet suggests that the NIC be probed for by checking its
@@ -267,7 +319,7 @@
 	char at1700_irqmap[8] = {3, 4, 5, 9, 10, 11, 14, 15};
 	unsigned int i, irq, is_fmv18x = 0, is_at1700 = 0;
 	int slot, ret = -ENODEV;
-	struct net_local *lp;
+	struct net_local *lp = dev->priv;
 	
 #ifndef CONFIG_X86_PC9800
 	if (!request_region(ioaddr, AT1700_IO_EXTENT, dev->name))
@@ -284,9 +336,10 @@
 	}
 #endif
 
-		/* Resetting the chip doesn't reset the ISA interface, so don't bother.
-	   That means we have to be careful with the register values we probe for.
-	   */
+	/* Resetting the chip doesn't reset the ISA interface, so don't bother.
+	   That means we have to be careful with the register values we probe
+	   for.
+	 */
 #ifdef notdef
 	printk("at1700 probe at %#x, eeprom is %4.4x %4.4x %4.4x ctrl %4.4x.\n",
 		   ioaddr, read_eeprom(ioaddr, 4), read_eeprom(ioaddr, 5),
@@ -331,15 +384,13 @@
 						break;
 
 					/* probing for a card at a particular IO/IRQ */
-				if (dev &&
-					((dev->irq && dev->irq != irq) ||
-					 (dev->base_addr && dev->base_addr != ioaddr))) {
+				if ((dev->irq && dev->irq != irq) ||
+				    (dev->base_addr && dev->base_addr != ioaddr)) {
 				  	slot++;		/* probing next slot */
 				  	continue;
 				}
 
-				if (dev)
-					dev->irq = irq;
+				dev->irq = irq;
 				
 				/* claim the slot */
 				mca_set_adapter_name( slot, at1720_mca_adapters[j].name );
@@ -476,13 +527,7 @@
 	if (net_debug)
 		printk(version);
 
-	/* Initialize the device structure. */
-	dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		ret = -ENOMEM;
-		goto err_out;
-	}
-	memset(dev->priv, 0, sizeof(struct net_local));
+	memset(lp, 0, sizeof(struct net_local));
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
@@ -492,11 +537,7 @@
 	dev->tx_timeout = net_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	lp = (struct net_local *)dev->priv;
-	lp->lock = SPIN_LOCK_UNLOCKED;
-
-	/* Fill in the fields of 'dev' with ethernet-generic values. */
-	ether_setup(dev);
+	spin_lock_init(&lp->lock);
 
 	lp->jumpered = is_fmv18x;
 	lp->mca_slot = slot;
@@ -505,14 +546,11 @@
 	if (ret) {
 		printk ("  AT1700 at %#3x is unusable due to a conflict on"
 				"IRQ %d.\n", ioaddr, irq);
-		goto err_out_priv;
+		goto err_out;
 	}
 
 	return 0;
 
-err_out_priv:
-	kfree(dev->priv);
-	dev->priv = NULL;
 err_out:
 #ifndef CONFIG_X86_PC9800
 	release_region(ioaddr, AT1700_IO_EXTENT);
@@ -940,14 +978,7 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_at1700;
-#ifndef CONFIG_X86_PC9800
-static int io = 0x260;
-#else
-static int io = 0xd0;
-#endif
-
-static int irq;
+static struct net_device *dev_at1700;
 
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -960,41 +991,18 @@
 {
 	if (io == 0)
 		printk("at1700: You should not use auto-probing with insmod!\n");
-	dev_at1700.base_addr = io;
-	dev_at1700.irq       = irq;
-	dev_at1700.init      = at1700_probe;
-	if (register_netdev(&dev_at1700) != 0) {
-		printk("at1700: register_netdev() returned non-zero.\n");
-		return -EIO;
-	}
+	dev_at1700 = at1700_probe(-1);
+	if (IS_ERR(dev_at1700))
+		return PTR_ERR(dev_at1700);
 	return 0;
 }
 
 void
 cleanup_module(void)
 {
-#ifdef CONFIG_MCA	
-	struct net_local *lp = dev_at1700.priv;
-	if(lp->mca_slot)
-	{
-		mca_mark_as_unused(lp->mca_slot);
-	}
-#endif	
-	unregister_netdev(&dev_at1700);
-	kfree(dev_at1700.priv);
-	dev_at1700.priv = NULL;
-
-	/* If we don't do this, we can't re-insmod it later. */
-	free_irq(dev_at1700.irq, NULL);
-#ifndef CONFIG_X86_PC9800
-	release_region(dev_at1700.base_addr, AT1700_IO_EXTENT);
-#else
-	{
-		int i;
-		for (i = 0; i < 0x2000; i += 0x200)
-			release_region(dev_at1700.base_addr + i, 2);
-	}
-#endif
+	unregister_netdev(dev_at1700);
+	cleanup_card(dev_at1700);
+	free_netdev(dev_at1700);
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
