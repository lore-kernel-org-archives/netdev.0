From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c515: use module_param and netdev_priv
Date: Mon, 18 Oct 2004 14:51:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018145110.1557c2a2@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

convert corkscrew to use module_param and netdev_priv
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/3c515.c b/drivers/net/3c515.c
--- a/drivers/net/3c515.c	2004-10-18 14:49:08 -07:00
+++ b/drivers/net/3c515.c	2004-10-18 14:49:08 -07:00
@@ -34,7 +34,7 @@
 /* "Knobs" that adjust features and parameters. */
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1512 effectively disables this feature. */
-static const int rx_copybreak = 200;
+static int rx_copybreak = 200;
 
 /* Allow setting MTU to a larger size, bypassing the normal ethernet setup. */
 static const int mtu = 1500;
@@ -59,6 +59,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/isapnp.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -87,15 +88,6 @@
 MODULE_DESCRIPTION("3Com 3c515 Corkscrew driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(debug, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM_DESC(debug, "3c515 debug level (0-6)");
-MODULE_PARM_DESC(options, "3c515: Bits 0-2: media type, bit 3: full duplex, bit 4: bus mastering");
-MODULE_PARM_DESC(rx_copybreak, "3c515 copy breakpoint for copy-only-tiny-frames");
-MODULE_PARM_DESC(max_interrupt_work, "3c515 maximum events handled per interrupt");
-
 /* "Knobs" for adjusting internal parameters. */
 /* Put out somewhat more debugging messages. (0 - no msg, 1 minimal msgs). */
 #define DRIVER_DEBUG 1
@@ -409,11 +401,22 @@
 
 #ifdef MODULE
 static int debug = -1;
+
+static int num_param;
+module_param(debug, int, 0);
+module_param_array(options, int, num_param, 0);
+module_param(rx_copybreak, int, 0);
+module_param(max_interrupt_work, int, 0);
+MODULE_PARM_DESC(debug, "3c515 debug level (0-6)");
+MODULE_PARM_DESC(options, "3c515: Bits 0-2: media type, bit 3: full duplex, bit 4: bus mastering");
+MODULE_PARM_DESC(rx_copybreak, "3c515 copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(max_interrupt_work, "3c515 maximum events handled per interrupt");
+
 /* A list of all installed Vortex devices, for removing the driver module. */
 /* we will need locking (and refcounting) if we ever use it for more */
 static LIST_HEAD(root_corkscrew_dev);
 
-int init_module(void)
+static int __init corkscrew_init_module(void)
 {
 	int found = 0;
 	if (debug >= 0)
@@ -424,6 +427,7 @@
 		found++;
 	return found ? 0 : -ENODEV;
 }
+module_init(corkscrew_init_module);
 
 #else
 struct net_device *tc515_probe(int unit)
@@ -471,7 +475,7 @@
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	list_del_init(&vp->list);
 	if (dev->dma)
 		free_dma(dev->dma);
@@ -569,7 +573,7 @@
 static void corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
 	int i;
 	int irq;
@@ -695,8 +699,7 @@
 static int corkscrew_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	union wn3_config config;
 	int i;
 
@@ -861,7 +864,7 @@
 {
 #ifdef AUTOMEDIA
 	struct net_device *dev = (struct net_device *) data;
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	int ok = 0;
@@ -953,8 +956,7 @@
 static void corkscrew_timeout(struct net_device *dev)
 {
 	int i;
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING
@@ -993,8 +995,7 @@
 static int corkscrew_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Block a timer-based transmit from overlapping. */
@@ -1129,7 +1130,7 @@
 
 	ioaddr = dev->base_addr;
 	latency = inb(ioaddr + Timer);
-	lp = (struct corkscrew_private *) dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock(&lp->lock);
 	
@@ -1261,7 +1262,7 @@
 
 static int corkscrew_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -1328,8 +1329,7 @@
 
 static int boomerang_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	int ioaddr = dev->base_addr;
 	int rx_status;
@@ -1419,8 +1419,7 @@
 
 static int corkscrew_close(struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 
@@ -1475,7 +1474,7 @@
 
 static struct net_device_stats *corkscrew_get_stats(struct net_device *dev)
 {
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (netif_running(dev)) {
@@ -1495,8 +1494,7 @@
 	*/
 static void update_stats(int ioaddr, struct net_device *dev)
 {
-	struct corkscrew_private *vp =
-	    (struct corkscrew_private *) dev->priv;
+	struct corkscrew_private *vp = netdev_priv(dev);
 
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
@@ -1574,7 +1572,7 @@
 
 
 #ifdef MODULE
-void cleanup_module(void)
+static void __exit corkscrew_cleanup_module(void)
 {
 	while (!list_empty(&root_corkscrew_dev)) {
 		struct net_device *dev;
@@ -1588,6 +1586,7 @@
 		free_netdev(dev);
 	}
 }
+module_exit(corkscrew_cleanup_module);
 #endif				/* MODULE */
 
 /*
