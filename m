From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (35/42) mvme147
Date: Wed, 12 Nov 2003 16:46:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0k8q31383@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE60-mvme147lance
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:16:47 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:16:47 2003
@@ -83,7 +83,7 @@
 extern struct net_device *cs89x0_probe(int unit);
 extern int hplance_probe(struct net_device *dev);
 extern struct net_device *bagetlance_probe(int unit);
-extern int mvme147lance_probe(struct net_device *dev);
+extern struct net_device *mvme147lance_probe(int unit);
 extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
 extern struct net_device *mace_probe(struct net_device *dev);
@@ -317,13 +317,13 @@
 #ifdef CONFIG_HPLANCE		/* HP300 internal Ethernet */
 	{hplance_probe, 0},
 #endif
-#ifdef CONFIG_MVME147_NET	/* MVME147 internal Ethernet */
-	{mvme147lance_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_MVME147_NET	/* MVME147 internal Ethernet */
+	{mvme147lance_probe, 0},
+#endif
 #ifdef CONFIG_MACMACE		/* Mac 68k Quadra AV builtin Ethernet */
 	{mace_probe, 0},
 #endif
diff -Nru a/drivers/net/mvme147.c b/drivers/net/mvme147.c
--- a/drivers/net/mvme147.c	Tue Nov 11 14:16:47 2003
+++ b/drivers/net/mvme147.c	Tue Nov 11 14:16:47 2003
@@ -49,7 +49,6 @@
  * plus board-specific init, open and close actions.
  * Oh, and we need to tell the generic code how to read and write LANCE registers...
  */
-int mvme147lance_probe(struct net_device *dev);
 static int m147lance_open(struct net_device *dev);
 static int m147lance_close(struct net_device *dev);
 static void m147lance_writerap(struct m147lance_private *lp, unsigned short value);
@@ -60,13 +59,10 @@
 typedef void (*writerdp_t)(void *, unsigned short);
 typedef unsigned short (*readrdp_t)(void *);
 
-#ifdef MODULE
-static struct m147lance_private *root_m147lance_dev;
-#endif
-
 /* Initialise the one and only on-board 7990 */
-int __init mvme147lance_probe(struct net_device *dev)
+struct net_device * __init mvme147lance_probe(int unit)
 {
+	struct net_device *dev;
 	static int called;
 	static const char name[] = "MVME147 LANCE";
 	struct m147lance_private *lp;
@@ -74,15 +70,17 @@
 	u_long address;
 
 	if (!MACH_IS_MVME147 || called)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
 	called++;
 
-	SET_MODULE_OWNER(dev);
+	dev = alloc_etherdev(sizeof(struct m147lance_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	dev->priv = kmalloc(sizeof(struct m147lance_private), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct m147lance_private));
+	if (unit >= 0)
+		sprintf(dev->name, "eth%d", unit);
+
+	SET_MODULE_OWNER(dev);
 
 	/* Fill the dev fields */
 	dev->base_addr = (unsigned long)MVME147_LANCE_BASE;
@@ -118,7 +116,8 @@
 	if (!lp->ram)
 	{
 		printk("%s: No memory for LANCE buffers\n", dev->name);
-		return -ENODEV;
+		free_netdev(dev);
+		return ERR_PTR(-ENOMEM);
 	}
 
 	lp->lance.name = (char*)name;                   /* discards const, shut up gcc */
@@ -134,15 +133,15 @@
 	lp->lance.lance_log_tx_bufs = LANCE_LOG_TX_BUFFERS;
 	lp->lance.rx_ring_mod_mask = RX_RING_MOD_MASK;
 	lp->lance.tx_ring_mod_mask = TX_RING_MOD_MASK;
-	ether_setup(dev);
 
-#ifdef MODULE
-	dev->ifindex = dev_new_index();
-	lp->next_module = root_m147lance_dev;
-	root_m147lance_dev = lp;
-#endif /* MODULE */
+	err = register_netdev(dev);
+	if (err) {
+		free_pages(lp->ram, 3);
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
 
-	return 0;
+	return dev;
 }
 
 static void m147lance_writerap(struct m147lance_private *lp, unsigned short value)
@@ -185,23 +184,21 @@
 #ifdef MODULE
 MODULE_LICENSE("GPL");
 
+static struct net_device *dev_mvme147_lance;
 int init_module(void)
 {
-	root_lance_dev = NULL;
-	return mvme147lance_probe(NULL);
+	dev_mvme147_lance = mvme147lance_probe(-1);
+	if (IS_ERR(dev_mvme147_lance))
+		return PTR_ERR(dev_mvme147_lance);
+	return 0;
 }
 
 void cleanup_module(void)
 {
-	/* Walk the chain of devices, unregistering them */
-	struct m147lance_private *lp;
-	while (root_m147lance_dev) {
-		lp = root_m147lance_dev->next_module;
-		unregister_netdev(root_lance_dev->dev);
-		free_pages(lp->ram, 3);
-		free_netdev(root_lance_dev->dev);
-		root_lance_dev = lp;
-	}
+	struct m147lance_private *lp = dev_mvme147_lance->priv;
+	unregister_netdev(dev_mvme147_lance);
+	free_pages(lp->ram, 3);
+	free_netdev(dev_mvme147_lance);
 }
 
 #endif /* MODULE */
