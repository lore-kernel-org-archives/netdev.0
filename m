From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (33/42) macsonic
Date: Wed, 12 Nov 2003 16:45:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0jmd31264@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE58-macsonic
	* switched macsonic to dynamic allocation
	* macsonic: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:16:20 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:16:20 2003
@@ -87,7 +87,7 @@
 extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
 extern int mace_probe(struct net_device *dev);
-extern int macsonic_probe(struct net_device *dev);
+extern struct net_device *macsonic_probe(int unit);
 extern struct net_device *mac8390_probe(int unit);
 extern struct net_device *mac89x0_probe(int unit);
 extern struct net_device *mc32_probe(int unit);
@@ -323,13 +323,13 @@
 #ifdef CONFIG_MACMACE		/* Mac 68k Quadra AV builtin Ethernet */
 	{mace_probe, 0},
 #endif
-#ifdef CONFIG_MACSONIC		/* Mac SONIC-based Ethernet of all sorts */ 
-	{macsonic_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_MACSONIC		/* Mac SONIC-based Ethernet of all sorts */ 
+	{macsonic_probe, 0},
+#endif
 #ifdef CONFIG_MAC8390           /* NuBus NS8390-based cards */
 	{mac8390_probe, 0},
 #endif
diff -Nru a/drivers/net/macsonic.c b/drivers/net/macsonic.c
--- a/drivers/net/macsonic.c	Tue Nov 11 14:16:20 2003
+++ b/drivers/net/macsonic.c	Tue Nov 11 14:16:20 2003
@@ -74,7 +74,6 @@
 
 static int reg_offset;
 
-extern int macsonic_probe(struct net_device* dev);
 extern int mac_onboard_sonic_probe(struct net_device* dev);
 extern int mac_nubus_sonic_probe(struct net_device* dev);
 
@@ -110,14 +109,38 @@
 
 #define SONIC_READ_PROM(addr) nubus_readb(prom_addr+addr)
 
-int __init macsonic_probe(struct net_device* dev)
+struct net_device * __init macsonic_probe(int unit)
 {
-	int rv;
+	struct net_device *dev = alloc_etherdev(0);
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0)
+		sprintf(dev->name, "eth%d", unit);
+
+ 	SET_MODULE_OWNER(dev);
 
 	/* This will catch fatal stuff like -ENOMEM as well as success */
-	if ((rv = mac_onboard_sonic_probe(dev)) != -ENODEV)
-		return rv;
-	return mac_nubus_sonic_probe(dev);
+	err = mac_onboard_sonic_probe(dev);
+	if (err == 0)
+		goto found;
+	if (err != -ENODEV)
+		goto out;
+	err = mac_nubus_sonic_probe(dev);
+	if (err)
+		goto out;
+found:
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	kfree(dev->priv);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*
@@ -195,6 +218,7 @@
 	if ((lp->rba = (char *)
 	     kmalloc(SONIC_NUM_RRS * SONIC_RBSIZE, GFP_KERNEL | GFP_DMA)) == NULL) {
 		printk(KERN_ERR "%s: couldn't allocate receive buffers\n", dev->name);
+		dev->priv = NULL;
 		kfree(lp);
 		return -ENOMEM;
 	}
@@ -229,8 +253,6 @@
 	sonic_write(dev, SONIC_FAET, 0xffff);
 	sonic_write(dev, SONIC_MPT, 0xffff);
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
 	return 0;
 }
 
@@ -344,30 +366,6 @@
 
 	printk("yes\n");	
 
-	if (dev) {
-		dev = init_etherdev(dev, sizeof(struct sonic_local));
-		if (!dev)
-			return -ENOMEM;
-		/* methinks this will always be true but better safe than sorry */
-		if (dev->priv == NULL) {
-			dev->priv = kmalloc(sizeof(struct sonic_local), GFP_KERNEL);
-			if (!dev->priv)
-				return -ENOMEM;
-		}
-	} else {
-		dev = init_etherdev(NULL, sizeof(struct sonic_local));
-	}
-
-	if (dev == NULL)
-		return -ENOMEM;
-
-	if(dev->priv) {
-		printk("%s: warning! sonic entering with priv already allocated!\n",
-		       dev->name);
-		printk("%s: discarding, will attempt to reallocate\n", dev->name);
-		dev->priv = NULL;
-	}
-
 	/* Danger!  My arms are flailing wildly!  You *must* set this
            before using sonic_read() */
 
@@ -567,25 +565,6 @@
 		return -ENODEV;
 	}
 
-	if (dev) {
-		dev = init_etherdev(dev, sizeof(struct sonic_local));
-		if (!dev)
-			return -ENOMEM;
-		/* methinks this will always be true but better safe than sorry */
-		if (dev->priv == NULL) {
-			dev->priv = kmalloc(sizeof(struct sonic_local), GFP_KERNEL);
-			if (!dev->priv) /* FIXME: kfree dev if necessary */
-				return -ENOMEM;
-		}
-	} else {
-		dev = init_etherdev(NULL, sizeof(struct sonic_local));
-	}
-
-	if (dev == NULL)
-		return -ENOMEM;
-
-	lp = (struct sonic_local*) dev->priv;
-	memset(lp, 0, sizeof(struct sonic_local));
 	/* Danger!  My arms are flailing wildly!  You *must* set this
            before using sonic_read() */
 	dev->base_addr = base_addr;
@@ -631,8 +610,7 @@
 }
 
 #ifdef MODULE
-static char namespace[16] = "";
-static struct net_device dev_macsonic;
+static struct net_device *dev_macsonic;
 
 MODULE_PARM(sonic_debug, "i");
 MODULE_PARM_DESC(sonic_debug, "macsonic debug level (1-4)");
@@ -641,24 +619,20 @@
 int
 init_module(void)
 {
-        dev_macsonic.name = namespace;
-        dev_macsonic.init = macsonic_probe;
-
-        if (register_netdev(&dev_macsonic) != 0) {
+        dev_macsonic = macsonic_probe(-1);
+	if (IS_ERR(dev_macsonic)) {
                 printk(KERN_WARNING "macsonic.c: No card found\n");
-                return -ENXIO;
-        }
+		return PTR_ERR(dev_macsonic);
+	}
 	return 0;
 }
 
 void
 cleanup_module(void)
 {
-        if (dev_macsonic.priv != NULL) {
-                unregister_netdev(&dev_macsonic);
-                kfree(dev_macsonic.priv);
-                dev_macsonic.priv = NULL;
-        }
+	unregister_netdev(dev_macsonic);
+	kfree(dev_macsonic->priv);
+	free_netdev(dev_macsonic);
 }
 #endif /* MODULE */
 
