From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (32/42) mac8390
Date: Wed, 12 Nov 2003 16:45:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0jcJ31234@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE57-mac8390
	* switched mac8390 to dynamic allocation
	* mac8390: fixed resource leaks on failure exits
	* get rid of MOD_INC/DEC

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:16:07 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:16:07 2003
@@ -88,7 +88,7 @@
 extern struct net_device *lance_probe(int unit);
 extern int mace_probe(struct net_device *dev);
 extern int macsonic_probe(struct net_device *dev);
-extern int mac8390_probe(struct net_device *dev);
+extern struct net_device *mac8390_probe(int unit);
 extern struct net_device *mac89x0_probe(int unit);
 extern struct net_device *mc32_probe(int unit);
 extern struct net_device *cops_probe(int unit);
@@ -326,13 +326,13 @@
 #ifdef CONFIG_MACSONIC		/* Mac SONIC-based Ethernet of all sorts */ 
 	{macsonic_probe, 0},
 #endif
-#ifdef CONFIG_MAC8390           /* NuBus NS8390-based cards */
-	{mac8390_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_MAC8390           /* NuBus NS8390-based cards */
+	{mac8390_probe, 0},
+#endif
 #ifdef CONFIG_MAC89x0
  	{mac89x0_probe, 0},
 #endif
diff -Nru a/drivers/net/mac8390.c b/drivers/net/mac8390.c
--- a/drivers/net/mac8390.c	Tue Nov 11 14:16:07 2003
+++ b/drivers/net/mac8390.c	Tue Nov 11 14:16:07 2003
@@ -124,11 +124,10 @@
 static char version[] __initdata =
 	"mac8390.c: v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
 		
-extern int mac8390_probe(struct net_device * dev);
 extern enum mac8390_type mac8390_ident(struct nubus_dev * dev);
 extern int mac8390_memsize(unsigned long membase);
 extern int mac8390_memtest(struct net_device * dev);
-extern int mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
+static int mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			   enum mac8390_type type);
 
 static int mac8390_open(struct net_device * dev);
@@ -223,14 +222,14 @@
  	return i * 0x1000;
 }
 
-static int probed __initdata = 0;
-
-int __init mac8390_probe(struct net_device * dev)
+struct net_device * __init mac8390_probe(int unit)
 {
+	struct net_device *dev;
 	volatile unsigned short *i;
-	int boards_found = 0;
 	int version_disp = 0;
 	struct nubus_dev * ndev = NULL;
+	static int probed;
+	int err = -ENDOEV;
 	
 	struct nubus_dir dir;
 	struct nubus_dirent ent;
@@ -238,28 +237,29 @@
 
 	enum mac8390_type cardtype;
 
-	if (probed)
-		return -ENODEV;
-	probed++;
-
 	/* probably should check for Nubus instead */
 
 	if (!MACH_IS_MAC)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	dev->priv = NULL;
+
+	if (unit >= 0)
+		sprintf(dev->name, "eth%d", unit);
+
+ 	SET_MODULE_OWNER(dev);
 
 	while ((ndev = nubus_find_type(NUBUS_CAT_NETWORK, NUBUS_TYPE_ETHERNET, ndev))) {
-		
-		dev = NULL;
-		
-		if ((cardtype = mac8390_ident(ndev)) == MAC8390_NONE)
+		/* Have we seen it already? */
+		if (slots & (1<<ndev->board->slot))
 			continue;
+		slots |= 1<<ndev->board->slot;
 
-		dev = init_etherdev(dev, 0);
-		if (dev == NULL) {
-			printk(KERN_ERR "Unable to allocate etherdev"
-					"structure!\n");
-			return -ENOMEM;
-		}
+		if ((cardtype = mac8390_ident(ndev)) == MAC8390_NONE)
+			continue;
 
 		if (version_disp == 0) {
 			version_disp = 1;
@@ -358,21 +358,28 @@
 					printk(KERN_ERR "Card type %s is"
 							" unsupported, sorry\n",
 					       cardname[cardtype]);
-					return -ENODEV;
+					continue;
 			}
 		}
 
 		/* Do the nasty 8390 stuff */
-		if (mac8390_initdev(dev, ndev, cardtype))
-			continue;
-		boards_found++;
+		if (!mac8390_initdev(dev, ndev, cardtype))
+			break;
 	}
 
-	/* We're outta here */
-	if (boards_found > 0)
-		return 0;
-	else
-		return -ENODEV;
+	if (!ndev)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+
+out1:
+	kfree(dev->priv);
+	dev->priv = NULL;
+out:
+	free_netdev(dev);
+	return ERR_PTE(err);
 }
 
 #ifdef MODULE
@@ -380,26 +387,40 @@
 MODULE_DESCRIPTION("Macintosh NS8390-based Nubus Ethernet driver");
 MODULE_LICENSE("GPL");
 
+/* overkill, of course */
+static struct net_device *dev_mac8390[15];
 int init_module(void)
 {
-	if (mac8390_probe(NULL)) {
+	int i;
+	for (i = 0; i < 15; i++) {
+		struct net_device *dev = mac8390_probe(-1);
+		if (IS_ERR(dev))
+			break;
+		dev_mac890[i] = dev;
+	}
+	if (!i) {
 		printk(KERN_NOTICE "mac8390.c: No useable cards found, driver NOT installed.\n");
 		return -ENODEV;
 	}
-	lock_8390_module();
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	/* FIXME: should probably keep track of net_device structs
-           somewhere and unregister them here? */
-	unlock_8390_module();
+	int i;
+	for (i = 0; i < 15; i++) {
+		struct net_device *dev = dev_mac890[i];
+		if (dev) {
+			unregister_netdev(dev);
+			kfree(dev->priv);
+			free_netdev(dev);
+		}
+	}
 }
 
 #endif /* MODULE */
 
-int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
+static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			    enum mac8390_type type)
 {
 	static u32 fwrd4_offsets[16]={
@@ -499,6 +520,8 @@
 		break;
 	default:
 		printk(KERN_ERR "Card type %s is unsupported, sorry\n", cardname[type]);
+		kfree(dev->priv);
+		dev->priv = NULL;
 		return -ENODEV;
 	}
 		
@@ -529,7 +552,6 @@
 		printk ("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}	
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -537,7 +559,6 @@
 {
 	free_irq(dev->irq, dev);
 	ei_close(dev);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
