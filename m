From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (34/42) mac_mace
Date: Wed, 12 Nov 2003 16:45:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0jwP31318@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE59-mace
	* switched mace to dynamic allocation
	* mace: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:16:33 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:16:33 2003
@@ -86,7 +86,7 @@
 extern int mvme147lance_probe(struct net_device *dev);
 extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
-extern int mace_probe(struct net_device *dev);
+extern struct net_device *mace_probe(struct net_device *dev);
 extern struct net_device *macsonic_probe(int unit);
 extern struct net_device *mac8390_probe(int unit);
 extern struct net_device *mac89x0_probe(int unit);
@@ -320,13 +320,13 @@
 #ifdef CONFIG_MVME147_NET	/* MVME147 internal Ethernet */
 	{mvme147lance_probe, 0},
 #endif
-#ifdef CONFIG_MACMACE		/* Mac 68k Quadra AV builtin Ethernet */
-	{mace_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_MACMACE		/* Mac 68k Quadra AV builtin Ethernet */
+	{mace_probe, 0},
+#endif
 #ifdef CONFIG_MACSONIC		/* Mac SONIC-based Ethernet of all sorts */ 
 	{macsonic_probe, 0},
 #endif
diff -Nru a/drivers/net/macmace.c b/drivers/net/macmace.c
--- a/drivers/net/macmace.c	Tue Nov 11 14:16:33 2003
+++ b/drivers/net/macmace.c	Tue Nov 11 14:16:33 2003
@@ -180,7 +180,7 @@
  * model of Macintrash has a MACE (AV macintoshes)
  */
  
-int mace_probe(struct net_device *unused)
+struct net_device *mace_probe(int unit)
 {
 	int j;
 	struct mace_data *mp;
@@ -188,13 +188,19 @@
 	struct net_device *dev;
 	unsigned char checksum = 0;
 	static int found = 0;
+	int err;
 	
-	if (found || macintosh_config->ether_type != MAC_ETHER_MACE) return -ENODEV;
+	if (found || macintosh_config->ether_type != MAC_ETHER_MACE)
+		return ERR_PTR(-ENODEV);
 
 	found = 1;	/* prevent 'finding' one on every device probe */
 
-	dev = init_etherdev(0, PRIV_BYTES);
-	if (!dev) return -ENOMEM;
+	dev = alloc_etherdev(PRIV_BYTES);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0)
+		sprintf(dev->name, "eth%d", unit);
 
 	mp = (struct mace_data *) dev->priv;
 	dev->base_addr = (u32)MACE_BASE;
@@ -221,7 +227,10 @@
 		checksum ^= bitrev(addr[j<<4]);
 	}
 	
-	if (checksum != 0xFF) return -ENODEV;
+	if (checksum != 0xFF) {
+		free_netdev(dev);
+		return -ENODEV;
+	}
 
 	memset(&mp->stats, 0, sizeof(mp->stats));
 
@@ -234,13 +243,16 @@
 	dev->set_multicast_list	= mace_set_multicast;
 	dev->set_mac_address	= mace_set_address;
 
-	ether_setup(dev);
-
 	printk(KERN_INFO "%s: 68K MACE, hardware address %.2X", dev->name, dev->dev_addr[0]);
 	for (j = 1 ; j < 6 ; j++) printk(":%.2X", dev->dev_addr[j]);
 	printk("\n");
 
-	return 0;
+	err = register_netdev(dev);
+	if (!err)
+		return dev;
+
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*
