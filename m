From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (37/42) pamsnet
Date: Wed, 12 Nov 2003 16:46:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0kSJ31429@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE62-pamsnet
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -urN B9-hplance/drivers/net/Space.c B9-pamsnet/drivers/net/Space.c
--- B9-hplance/drivers/net/Space.c	Tue Nov 11 15:10:51 2003
+++ B9-pamsnet/drivers/net/Space.c	Tue Nov 11 15:18:06 2003
@@ -79,7 +79,7 @@
 extern int sun3_82586_probe(struct net_device *);
 extern int apne_probe(struct net_device *);
 extern int bionet_probe(struct net_device *);
-extern int pamsnet_probe(struct net_device *);
+extern struct net_device *pamsnet_probe(int unit);
 extern struct net_device *cs89x0_probe(int unit);
 extern struct net_device *hplance_probe(int unit);
 extern struct net_device *bagetlance_probe(int unit);
@@ -312,13 +312,13 @@
 #ifdef CONFIG_ATARI_BIONET	/* Atari Bionet Ethernet board */
 	{bionet_probe, 0},
 #endif
-#ifdef CONFIG_ATARI_PAMSNET	/* Atari PAMsNet Ethernet board */
-	{pamsnet_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_ATARI_PAMSNET	/* Atari PAMsNet Ethernet board */
+	{pamsnet_probe, 0},
+#endif
 #ifdef CONFIG_HPLANCE		/* HP300 internal Ethernet */
 	{hplance_probe, 0},
 #endif
diff -urN B9-hplance/drivers/net/atari_pamsnet.c B9-pamsnet/drivers/net/atari_pamsnet.c
--- B9-hplance/drivers/net/atari_pamsnet.c	Mon Jul 28 11:13:06 2003
+++ B9-pamsnet/drivers/net/atari_pamsnet.c	Tue Nov 11 15:18:06 2003
@@ -158,8 +158,6 @@
 static int	get_status (void);
 static int	calc_received (void *start_address);
 
-extern int pamsnet_probe(struct net_device *dev);
-
 static int pamsnet_open(struct net_device *dev);
 static int pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev);
 static void pamsnet_poll_rx(struct net_device *);
@@ -562,12 +560,12 @@
 /* Check for a network adaptor of this type, and return '0' if one exists.
  */
 
-int __init 
-pamsnet_probe (dev)
-	struct net_device *dev;
+struct net_device * __init pamsnet_probe (int unit)
 {
+	struct net_device *dev;
 	int i;
 	HADDR *hwaddr;
+	int err;
 
 	unsigned char station_addr[6];
 	static unsigned version_printed;
@@ -575,12 +573,18 @@
 	static int no_more_found;
 
 	if (no_more_found)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
+	no_more_found = 1;
 
+	dev = alloc_etherdev(sizeof(struct net_local));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 	SET_MODULE_OWNER(dev);
 
-	no_more_found = 1;
-
 	printk("Probing for PAM's Net/GK Adapter...\n");
 
 	/* Allocate the DMA buffer here since we need it for probing! */
@@ -618,11 +622,12 @@
 	ENABLE_IRQ();
 	stdma_release();
 
-	if (lance_target < 0)
+	if (lance_target < 0) {
 		printk("No PAM's Net/GK found.\n");
+		free_netdev(dev);
+		return ERR_PTR(-ENODEV);
+	}
 
-	if ((dev == NULL) || (lance_target < 0))
-		return -ENODEV;
 	if (pamsnet_debug > 0 && version_printed++ == 0)
 		printk(version);
 
@@ -632,12 +637,6 @@
 		station_addr[3], station_addr[4], station_addr[5]);
 
 	/* Initialize the device structure. */
-	if (dev->priv == NULL)
-		dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (!dev->priv)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct net_local));
-
 	dev->open		= pamsnet_open;
 	dev->stop		= pamsnet_close;
 	dev->hard_start_xmit	= pamsnet_send_packet;
@@ -653,9 +652,12 @@
 #endif
 		dev->dev_addr[i]  = station_addr[i];
 	}
-	ether_setup(dev);
+	err = register_netdev(dev);
+	if (!err)
+		return dev;
 
-	return(0);
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /* Open/initialize the board.  This is called (in the current kernel)
@@ -866,25 +868,20 @@
 
 #ifdef MODULE
 
-static struct net_device pam_dev;
-
-int
-init_module(void) {
-	int err;
+static struct net_device *pam_dev;
 
-	pam_dev.init = pamsnet_probe;
-	if ((err = register_netdev(&pam_dev))) {
-		if (err == -EEXIST)  {
-			printk("PAM's Net/GK: devices already present. Module not loaded.\n");
-		}
-		return err;
-	}
+int init_module(void)
+{
+	pam_dev = pamsnet_probe(-1);
+	if (IS_ERR(pam_dev))
+		return PTR_ERR(pam_dev);
 	return 0;
 }
 
-void
-cleanup_module(void) {
-	unregister_netdev(&pam_dev);
+void cleanup_module(void)
+{
+	unregister_netdev(pam_dev);
+	free_netdev(pam_dev);
 }
 
 #endif /* MODULE */
