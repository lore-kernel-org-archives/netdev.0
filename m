From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (31/42) mac89x0
Date: Wed, 12 Nov 2003 16:45:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0jS931210@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE56-mac8390
	* switched mac8390 to dynamic allocation
	* mac8390: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:15:51 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:15:51 2003
@@ -89,7 +89,7 @@
 extern int mace_probe(struct net_device *dev);
 extern int macsonic_probe(struct net_device *dev);
 extern int mac8390_probe(struct net_device *dev);
-extern int mac89x0_probe(struct net_device *dev);
+extern struct net_device *mac89x0_probe(int unit);
 extern struct net_device *mc32_probe(int unit);
 extern struct net_device *cops_probe(int unit);
 extern struct net_device *ltpc_probe(void);
@@ -329,6 +329,10 @@
 #ifdef CONFIG_MAC8390           /* NuBus NS8390-based cards */
 	{mac8390_probe, 0},
 #endif
+	{NULL, 0},
+};
+
+static struct devprobe2 m68k_probes2[] __initdata = {
 #ifdef CONFIG_MAC89x0
  	{mac89x0_probe, 0},
 #endif
@@ -391,6 +395,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, m68k_probes2, base_addr == 0) &&
 	probe_list2(unit, mips_probes, base_addr == 0) &&
 	probe_list2(unit, eisa_probes, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
diff -Nru a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
--- a/drivers/net/mac89x0.c	Tue Nov 11 14:15:51 2003
+++ b/drivers/net/mac89x0.c	Tue Nov 11 14:15:51 2003
@@ -123,7 +123,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int mac89x0_probe(struct net_device *dev);
 #if 0
 extern void reset_chip(struct net_device *dev);
 #endif
@@ -170,8 +169,9 @@
 
 /* Probe for the CS8900 card in slot E.  We won't bother looking
    anywhere else until we have a really good reason to do so. */
-int __init mac89x0_probe(struct net_device *dev)
+struct net_device * __init mac89x0_probe(int unit)
 {
+	struct net_device *dev;
 	static int once_is_enough;
 	struct net_local *lp;
 	static unsigned version_printed;
@@ -179,18 +179,28 @@
 	unsigned rev_type = 0;
 	unsigned long ioaddr;
 	unsigned short sig;
+	int err = -ENODEV;
+
+	dev = alloc_etherdev(sizeof(struct net_local));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
 	SET_MODULE_OWNER(dev);
 
 	if (once_is_enough)
-		return -ENODEV;
+		goto out;
 	once_is_enough = 1;
 
 	/* We might have to parameterize this later */
 	slot = 0xE;
 	/* Get out now if there's a real NuBus card in slot E */
 	if (nubus_find_slot(slot, NULL) != NULL)
-		return -ENODEV;	
+		goto out;
 
 	/* The pseudo-ISA bits always live at offset 0x300 (gee,
            wonder why...) */
@@ -206,21 +216,15 @@
 		local_irq_restore(flags);
 
 		if (!card_present)
-			return -ENODEV;
+			goto out;
 	}
 
 	nubus_writew(0, ioaddr + ADD_PORT);
 	sig = nubus_readw(ioaddr + DATA_PORT);
 	if (sig != swab16(CHIP_EISA_ID_SIG))
-		return -ENODEV;
+		goto out;
 
 	/* Initialize the net_device structure. */
-	if (dev->priv == NULL) {
-		dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-		if (!dev->priv)
-			return -ENOMEM;
-                memset(dev->priv, 0, sizeof(struct net_local));
-        }
 	lp = (struct net_local *)dev->priv;
 
 	/* Fill in the 'dev' fields. */
@@ -258,9 +262,7 @@
 	/* Try to read the MAC address */
 	if ((readreg(dev, PP_SelfST) & (EEPROM_PRESENT | EEPROM_OK)) == 0) {
 		printk("\nmac89x0: No EEPROM, giving up now.\n");
-		kfree(dev->priv);
-		dev->priv = NULL;
-		return -ENODEV;
+		goto out1;
         } else {
                 for (i = 0; i < ETH_ALEN; i += 2) {
 			/* Big-endian (why??!) */
@@ -277,6 +279,7 @@
 	for (i = 0; i < ETH_ALEN; i++)
 		printk("%2.2x%s", dev->dev_addr[i],
 		       ((i < ETH_ALEN-1) ? ":" : ""));
+	printk("\n");
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
@@ -285,11 +288,15 @@
 	dev->set_multicast_list = &set_multicast_list;
 	dev->set_mac_address = &set_mac_address;
 
-	/* Fill in the fields of the net_device structure with ethernet values. */
-	ether_setup(dev);
-
-	printk("\n");
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
 	return 0;
+out1:
+	nubus_writew(0, dev->base_addr + ADD_PORT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 #if 0
@@ -619,7 +626,7 @@
 
 #ifdef MODULE
 
-static struct net_device dev_cs89x0;
+static struct net_device *dev_cs89x0;
 static int debug;
 
 MODULE_PARM(debug, "i");
@@ -630,36 +637,20 @@
 init_module(void)
 {
 	net_debug = debug;
-        dev_cs89x0.init = mac89x0_probe;
-        dev_cs89x0.priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (!dev_cs89x0.priv)
-		return -ENOMEM;
-	memset(dev_cs89x0.priv, 0, sizeof(struct net_local));
-
-        if (register_netdev(&dev_cs89x0) != 0) {
+        dev_cs89x0 = mac89x0_probe(-1);
+	if (IS_ERR(dev_cs89x0)) {
                 printk(KERN_WARNING "mac89x0.c: No card found\n");
-		kfree(dev_cs89x0.priv);
-                return -ENXIO;
-        }
+		return PTR_ERR(dev_cs89x0);
+	}
 	return 0;
 }
 
 void
 cleanup_module(void)
 {
-
-#endif
-#ifdef MODULE
-	nubus_writew(0, dev_cs89x0.base_addr + ADD_PORT);
-#endif
-#ifdef MODULE
-
-        if (dev_cs89x0.priv != NULL) {
-                /* Free up the private structure, or leak memory :-)  */
-                unregister_netdev(&dev_cs89x0);
-                kfree(dev_cs89x0.priv);
-                dev_cs89x0.priv = NULL;	/* gets re-allocated by cs89x0_probe1 */
-        }
+	unregister_netdev(dev_cs89x0);
+	nubus_writew(0, dev_cs89x0->base_addr + ADD_PORT);
+	free_netdev(dev_cs89x0);
 }
 #endif /* MODULE */
 
