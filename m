From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] allow modular mv64340_eth
Date: Tue, 6 Jul 2004 12:36:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706103645.GA14521@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Only tested together with some additional patches to make the driver
work on PPC that need more work, but the changes are obvious.


--- a/drivers/net/Kconfig~	2004-07-06 14:32:32.380761120 +0200
+++ b/drivers/net/Kconfig	2004-07-06 14:32:40.494527640 +0200
@@ -2132,7 +2132,7 @@
 	  will be called tg3.  This is recommended.
 
 config MV64340_ETH
-	bool "MV-64340 Ethernet support"
+	tristate "MV-64340 Ethernet support"
 	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV64340
--- a/drivers/net/mv64340_eth.c~	2004-07-06 14:26:47.163242160 +0200
+++ b/drivers/net/mv64340_eth.c	2004-07-06 14:32:15.198373240 +0200
@@ -1316,7 +1316,7 @@
  * Input : number of port to initialize
  * Output : -ENONMEM if failed , 0 if success
  */
-static int mv64340_eth_init(int port_num)
+static struct net_device *mv64340_eth_init(int port_num)
 {
 	struct mv64340_private *mp;
 	struct net_device *dev;
@@ -1324,7 +1324,7 @@
 
 	dev = alloc_etherdev(sizeof(struct mv64340_private));
 	if (!dev)
-		return -ENOMEM;
+		return NULL;
 
 	mp = netdev_priv(dev);
 
@@ -1395,14 +1395,27 @@
 	printk("RX NAPI Enabled \n");
 #endif
 
-	return 0;
+	return dev;
 
 out_free_dev:
 	free_netdev(dev);
 
-	return err;
+	return NULL;
+}
+
+static void mv64340_eth_remove(struct net_device *dev)
+{
+	struct mv64340_private *mp = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	flush_scheduled_work();
+	free_netdev(dev);
 }
 
+static struct net_device *mv64340_dev0;
+static struct net_device *mv64340_dev1;
+static struct net_device *mv64340_dev2;
+
 /*
  * mv64340_init_module
  *
@@ -1415,20 +1428,24 @@
 static int __init mv64340_init_module(void)
 {
 	printk(KERN_NOTICE "MV-64340 10/100/1000 Ethernet Driver\n");
+
 #ifdef CONFIG_MV64340_ETH_0
-	if (mv64340_eth_init(0)) {
+	mv64340_dev0 = mv64340_eth_init(0);
+	if (!mv64340_dev0) {
 		printk(KERN_ERR
 		       "Error registering MV-64360 ethernet port 0\n");
 	}
 #endif
 #ifdef CONFIG_MV64340_ETH_1
-	if (mv64340_eth_init(1)) {
+	mv64340_dev1 = mv64340_eth_init(1);
+	if (!mv64340_dev1) {
 		printk(KERN_ERR
 		       "Error registering MV-64360 ethernet port 1\n");
 	}
 #endif
 #ifdef CONFIG_MV64340_ETH_2
-	if (mv64340_eth_init(2)) {
+	mv64340_dev2 = mv64340_eth_init(2);
+	if (!mv64340_dev2) {
 		printk(KERN_ERR
 		       "Error registering MV-64360 ethernet port 2\n");
 	}
@@ -1445,9 +1462,14 @@
  *
  * Output : N/A
  */
-static void __init mv64340_cleanup_module(void)
+static void __exit mv64340_cleanup_module(void)
 {
-	/* Nothing to do here ! it's not a removable module */
+	if (mv64340_dev2)
+		mv64340_eth_remove(mv64340_dev2);
+	if (mv64340_dev1)
+		mv64340_eth_remove(mv64340_dev1);
+	if (mv64340_dev0)
+		mv64340_eth_remove(mv64340_dev0);
 }
 
 module_init(mv64340_init_module);
