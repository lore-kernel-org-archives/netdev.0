From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (36/42) hplance
Date: Wed, 12 Nov 2003 16:46:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0kIt31400@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE61-hplance
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -urN B9-mvme147/drivers/net/Space.c B9-hplance/drivers/net/Space.c
--- B9-mvme147/drivers/net/Space.c	Tue Nov 11 13:57:43 2003
+++ B9-hplance/drivers/net/Space.c	Tue Nov 11 15:10:51 2003
@@ -81,7 +81,7 @@
 extern int bionet_probe(struct net_device *);
 extern int pamsnet_probe(struct net_device *);
 extern struct net_device *cs89x0_probe(int unit);
-extern int hplance_probe(struct net_device *dev);
+extern struct net_device *hplance_probe(int unit);
 extern struct net_device *bagetlance_probe(int unit);
 extern struct net_device *mvme147lance_probe(int unit);
 extern struct net_device *tc515_probe(int unit);
@@ -315,13 +315,13 @@
 #ifdef CONFIG_ATARI_PAMSNET	/* Atari PAMsNet Ethernet board */
 	{pamsnet_probe, 0},
 #endif
-#ifdef CONFIG_HPLANCE		/* HP300 internal Ethernet */
-	{hplance_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_HPLANCE		/* HP300 internal Ethernet */
+	{hplance_probe, 0},
+#endif
 #ifdef CONFIG_MVME147_NET	/* MVME147 internal Ethernet */
 	{mvme147lance_probe, 0},
 #endif
diff -urN B9-mvme147/drivers/net/hplance.c B9-hplance/drivers/net/hplance.c
--- B9-mvme147/drivers/net/hplance.c	Fri Aug 22 23:10:48 2003
+++ B9-hplance/drivers/net/hplance.c	Tue Nov 11 15:10:51 2003
@@ -50,8 +50,7 @@
  * plus board-specific init, open and close actions. 
  * Oh, and we need to tell the generic code how to read and write LANCE registers...
  */
-int hplance_probe(struct net_device *dev);
-static int hplance_init(struct net_device *dev, int scode);
+static void hplance_init(struct net_device *dev, int scode);
 static int hplance_open(struct net_device *dev);
 static int hplance_close(struct net_device *dev);
 static void hplance_writerap(void *priv, unsigned short value);
@@ -62,57 +61,61 @@
 static struct hplance_private *root_hplance_dev;
 #endif
 
+static void cleanup_card(struct net_device *dev)
+{
+        struct hplance_private *lp = dev->priv;
+	dio_unconfig_board(lp->scode);
+}
+
 /* Find all the HP Lance boards and initialise them... */
-int __init hplance_probe(struct net_device *dev)
+struct net_device * __init hplance_probe(int unit)
 {
-        int cards = 0, called = 0;
+	struct net_device *dev;
+
+        if (!MACH_IS_HP300)
+                return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(sizeof(struct hplance_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
-        if (!MACH_IS_HP300 || called)
-                return(ENODEV);
-        called++;
+	SET_MODULE_OWNER(dev);
         
         /* Isn't DIO nice? */
         for(;;)
         {
-                int v, scode = dio_find(DIO_ID_LAN);
+                int scode = dio_find(DIO_ID_LAN);
                                 
                 if (!scode)
                         break;
                 
-                if(cards)
-                        dev = NULL;      /* don't trash previous device, make a new one */
-                cards++;
-                
-                v = hplance_init(dev, scode);
-                if (v)                            /* error, abort immediately */
-                        return v;
+		dio_config_board(scode);
+                hplance_init(dev, scode);
+		if (!register_netdev(dev)) {
+			struct hplance_private *lp = dev->priv;
+			lp->next_module = root_hplance_dev;
+			root_hplance_dev = lp;
+			return dev;
+		}
+		cleanup_card(dev);
         }
-        /* OK, return success, or ENODEV if we didn't find any cards */
-        if (!cards)
-                return -ENODEV;
-        return 0;
+	free_netdev(dev);
+	return ERR_PTR(-ENODEV);
 }
 
 /* Initialise a single lance board at the given select code */
-static int __init hplance_init(struct net_device *dev, int scode)
+static void __init hplance_init(struct net_device *dev, int scode)
 {
         const char *name = dio_scodetoname(scode);
         void *va = dio_scodetoviraddr(scode);
         struct hplance_private *lp;
         int i;
         
-#ifdef MODULE
-	dev = init_etherdev(0, sizeof(struct hplance_private));
-	if (!dev)
-		return -ENOMEM;
-#else
-	dev->priv = kmalloc(sizeof(struct hplance_private), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct hplance_private));
-#endif
-	SET_MODULE_OWNER(dev);
-
         printk("%s: %s; select code %d, addr", dev->name, name, scode);
 
         /* reset the board */
@@ -154,17 +157,7 @@
         lp->lance.tx_ring_mod_mask = TX_RING_MOD_MASK;
         lp->scode = scode;
 	lp->base = va;
-        ether_setup(dev);
 	printk(", irq %d\n", lp->lance.irq);
-
-#ifdef MODULE
-        dev->ifindex = dev_new_index();
-        lp->next_module = root_hplance_dev;
-        root_hplance_dev = lp;
-#endif /* MODULE */
-
-        dio_config_board(scode);                  /* tell bus scanning code this one's taken */
-        return 0;
 }
 
 /* This is disgusting. We have to check the DIO status register for ack every
@@ -227,8 +220,10 @@
 MODULE_LICENSE("GPL");
 int init_module(void)
 {
-        root_lance_dev = NULL;
-        return hplance_probe(NULL);
+	int found = 0;
+	while (!IS_ERR(hplance_probe(-1)))
+		found++;
+	return found ? 0 : -ENODEV;
 }
 
 void cleanup_module(void)
@@ -237,8 +232,8 @@
         struct hplance_private *lp;
         while (root_hplance_dev) {
                 lp = root_hplance_dev->next_module;
-                dio_unconfig_board(lp->scode);
                 unregister_netdev(root_lance_dev->dev);
+                cleanup_card(root_lance_dev->dev);
                 free_netdev(root_lance_dev->dev);
                 root_lance_dev = lp;
         }
