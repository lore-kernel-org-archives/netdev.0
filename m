From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (39/42) apne
Date: Wed, 12 Nov 2003 16:46:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0kmQ31517@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE64-apne
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -urN B9-bionet/drivers/net/Space.c B9-apne/drivers/net/Space.c
--- B9-bionet/drivers/net/Space.c	Tue Nov 11 15:23:17 2003
+++ B9-apne/drivers/net/Space.c	Tue Nov 11 19:04:30 2003
@@ -77,7 +77,7 @@
 extern int atarilance_probe(struct net_device *);
 extern int sun3lance_probe(struct net_device *);
 extern int sun3_82586_probe(struct net_device *);
-extern int apne_probe(struct net_device *);
+extern struct net_device *apne_probe(int unit);
 extern struct net_device *bionet_probe(int unit);
 extern struct net_device *pamsnet_probe(int unit);
 extern struct net_device *cs89x0_probe(int unit);
@@ -306,13 +306,13 @@
 #ifdef CONFIG_SUN3_82586        /* sun3 onboard Intel 82586 chip */
 	{sun3_82586_probe, 0},
 #endif
-#ifdef CONFIG_APNE		/* A1200 PCMCIA NE2000 */
-	{apne_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_APNE		/* A1200 PCMCIA NE2000 */
+	{apne_probe, 0},
+#endif
 #ifdef CONFIG_ATARI_BIONET	/* Atari Bionet Ethernet board */
 	{bionet_probe, 0},
 #endif
diff -urN B9-bionet/drivers/net/apne.c B9-apne/drivers/net/apne.c
--- B9-bionet/drivers/net/apne.c	Mon May 26 22:21:35 2003
+++ B9-apne/drivers/net/apne.c	Tue Nov 11 19:04:30 2003
@@ -116,28 +116,38 @@
 
 static int apne_owned;	/* signal if card already owned */
 
-int __init apne_probe(struct net_device *dev)
+struct net_device * __init apne_probe(int unit)
 {
+	struct net_device *dev;
 #ifndef MANUAL_CONFIG
 	char tuple[8];
 #endif
+	int err;
 
 	if (apne_owned)
-		return -ENODEV;
-
-	SET_MODULE_OWNER(dev);
+		return ERR_PTR(-ENODEV);
 
 	if ( !(AMIGAHW_PRESENT(PCMCIA)) )
-		return (-ENODEV);
+		return ERR_PTR(-ENODEV);
                                 
 	printk("Looking for PCMCIA ethernet card : ");
                                         
 	/* check if a card is inserted */
 	if (!(PCMCIA_INSERTED)) {
 		printk("NO PCMCIA card inserted\n");
-		return (-ENODEV);
+		return ERR_PTR(-ENODEV);
+	}
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	dev->priv = NULL;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
 	}
-                                                                                                
+	SET_MODULE_OWNER(dev);
+
 	/* disable pcmcia irq for readtuple */
 	pcmcia_disable_irq();
 
@@ -145,17 +155,41 @@
 	if ((pcmcia_copy_tuple(CISTPL_FUNCID, tuple, 8) < 3) ||
 		(tuple[2] != CISTPL_FUNCID_NETWORK)) {
 		printk("not an ethernet card\n");
-		return (-ENODEV);
+		/* XXX: shouldn't we re-enable irq here? */
+		free_netdev(dev);
+		return ERR_PTR(-ENODEV);
 	}
 #endif
 
 	printk("ethernet PCMCIA card inserted\n");
 
-	if (init_pcmcia())
-		return apne_probe1(dev, IOBASE);
-	else
-		return (-ENODEV);
+	if (!init_pcmcia()) {
+		/* XXX: shouldn't we re-enable irq here? */
+		free_netdev(dev);
+		return ERR_PTR(-ENODEV);
+	}
+
+	if (!request_region(IOBASE, 0x20, dev->name)) {
+		free_netdev(dev);
+		return ERR_PTR(-EBUSY);
+	}
+
+	err = apne_probe1(dev, IOBASE);
+	if (err) {
+		release_region(IOBASE, 0x20);
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+	err = register_netdev(dev);
+	if (!err)
+		return dev;
 
+	pcmcia_disable_irq();
+	free_irq(IRQ_AMIGA_PORTS, dev);
+	pcmcia_reset();
+	release_region(IOBASE, 0x20);
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init apne_probe1(struct net_device *dev, int ioaddr)
@@ -534,32 +568,29 @@
 }
 
 #ifdef MODULE
-static struct net_device apne_dev;
+static struct net_device *apne_dev;
 
 int init_module(void)
 {
 	int err;
 
-	apne_dev.init = apne_probe;
-	if ((err = register_netdev(&apne_dev))) {
-		if (err == -EIO)
-			printk("No PCMCIA NEx000 ethernet card found.\n");
-		return (err);
-	}
-	return (0);
+	apne_dev = apne_probe(-1);
+	if (IS_ERR(apne_dev))
+		return PTR_ERR(apne_dev);
+	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&apne_dev);
+	unregister_netdev(apne_dev);
 
 	pcmcia_disable_irq();
 
-	free_irq(IRQ_AMIGA_PORTS, &apne_dev);
+	free_irq(IRQ_AMIGA_PORTS, apne_dev);
 
 	pcmcia_reset();
 
-	apne_owned = 0;
+	free_netdev(apne_dev);
 }
 
 #endif
