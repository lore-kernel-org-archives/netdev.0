From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (38/42) bionet
Date: Wed, 12 Nov 2003 16:46:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0kcx31474@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE63-bionet
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Nov 12 14:59:06 2003
+++ b/drivers/net/Space.c	Wed Nov 12 14:59:06 2003
@@ -78,7 +78,7 @@
 extern int sun3lance_probe(struct net_device *);
 extern int sun3_82586_probe(struct net_device *);
 extern int apne_probe(struct net_device *);
-extern int bionet_probe(struct net_device *);
+extern struct net_device *bionet_probe(int unit);
 extern struct net_device *pamsnet_probe(int unit);
 extern struct net_device *cs89x0_probe(int unit);
 extern struct net_device *hplance_probe(int unit);
@@ -308,13 +308,13 @@
 #ifdef CONFIG_APNE		/* A1200 PCMCIA NE2000 */
 	{apne_probe, 0},
 #endif
-#ifdef CONFIG_ATARI_BIONET	/* Atari Bionet Ethernet board */
-	{bionet_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_ATARI_BIONET	/* Atari Bionet Ethernet board */
+	{bionet_probe, 0},
+#endif
 #ifdef CONFIG_ATARI_PAMSNET	/* Atari PAMsNet Ethernet board */
 	{pamsnet_probe, 0},
 #endif
diff -Nru a/drivers/net/atari_bionet.c b/drivers/net/atari_bionet.c
--- a/drivers/net/atari_bionet.c	Wed Nov 12 14:59:06 2003
+++ b/drivers/net/atari_bionet.c	Wed Nov 12 14:59:06 2003
@@ -148,8 +148,6 @@
 
 /* Index to functions, as function prototypes.
  */
-extern int bionet_probe(struct net_device *dev);
-
 static int bionet_open(struct net_device *dev);
 static int bionet_send_packet(struct sk_buff *skb, struct net_device *dev);
 static void bionet_poll_rx(struct net_device *);
@@ -321,15 +319,26 @@
 
 /* Check for a network adaptor of this type, and return '0' if one exists.
  */
-int __init 
-bionet_probe(struct net_device *dev){
+struct net_device * __init bionet_probe(int unit)
+{
+	struct net_device *dev;
 	unsigned char station_addr[6];
 	static unsigned version_printed;
 	static int no_more_found;	/* avoid "Probing for..." printed 4 times */
 	int i;
+	int err;
 
 	if (!MACH_IS_ATARI || no_more_found)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(sizeof(struct net_local));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+	SET_MODULE_OWNER(dev);
 
 	printk("Probing for BioNet 100 Adapter...\n");
 
@@ -347,11 +356,10 @@
 	||  station_addr[2] != 'O' ) {
 		no_more_found = 1;
 		printk( "No BioNet 100 found.\n" );
-		return -ENODEV;
+		free_netdev(dev);
+		return ERR_PTR(-ENODEV);
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (bionet_debug > 0 && version_printed++ == 0)
 		printk(version);
 
@@ -369,12 +377,6 @@
 			nic_packet, phys_nic_packet );
 	}
 
-	if (dev->priv == NULL)
-		dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (!dev->priv)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct net_local));
-
 	dev->open		= bionet_open;
 	dev->stop		= bionet_close;
 	dev->hard_start_xmit	= bionet_send_packet;
@@ -390,8 +392,11 @@
 #endif
 		dev->dev_addr[i]  = station_addr[i];
 	}
-	ether_setup(dev);
-	return 0;
+	err = register_netdev(dev);
+	if (!err)
+		return dev;
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /* Open/initialize the board.  This is called (in the current kernel)
@@ -640,25 +645,20 @@
 
 #ifdef MODULE
 
-static struct net_device bio_dev;
-
-int
-init_module(void) {
-	int err;
+static struct net_device *bio_dev;
 
-	bio_dev.init = bionet_probe;
-	if ((err = register_netdev(&bio_dev))) {
-		if (err == -EEXIST)  {
-			printk("BIONET: devices already present. Module not loaded.\n");
-		}
-		return err;
-	}
+int init_module(void)
+{
+	bio_dev = bionet_probe(-1);
+	if (IS_ERR(bio_dev))
+		return PTR_ERR(bio_dev);
 	return 0;
 }
 
-void
-cleanup_module(void) {
-	unregister_netdev(&bio_dev);
+void cleanup_module(void)
+{
+	unregister_netdev(bio_dev);
+	free_netdev(bio_dev);
 }
 
 #endif /* MODULE */
