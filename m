From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) Convert YAM driver to dynamic net_device
Date: Wed, 13 Aug 2003 09:39:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813093909.22de1915.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Paul Roubelat <jpr@f6fbb.org>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert hamradio/yam.c to dynamic allocation of net_device instead of allocating
an array of structures containing net_device's.  

This applies to 2.6.0-test3.  Since this driver will come up with out any actual
hardware was able to test load/unload on SMP.

To bad my license is way out of date ;-)

diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	Wed Aug 13 09:31:17 2003
+++ b/drivers/net/hamradio/yam.c	Wed Aug 13 09:31:17 2003
@@ -120,7 +120,7 @@
 	int irq;
 	int dupmode;
 
-	struct net_device dev;
+	struct net_device *dev;
 
 	/* Stats section */
 
@@ -161,7 +161,7 @@
 	struct yam_mcs *next;
 };
 
-static struct yam_port yam_ports[NR_PORTS];
+static struct net_device *yam_devs[NR_PORTS];
 
 static struct yam_mcs *yam_data;
 
@@ -628,8 +628,8 @@
 	int i;
 
 	for (i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = &yam_ports[i].dev;
-		if (netif_running(dev))
+		struct net_device *dev = yam_devs[i];
+		if (dev && netif_running(dev))
 			yam_arbitrate(dev);
 	}
 	yam_timer.expires = jiffies + HZ / 100;
@@ -724,8 +724,8 @@
 	int handled = 0;
 
 	for (i = 0; i < NR_PORTS; i++) {
-		yp = &yam_ports[i];
-		dev = &yp->dev;
+		dev = yam_devs[i];
+		yp = dev->priv;
 
 		if (!netif_running(dev))
 			continue;
@@ -882,8 +882,10 @@
 
 	/* Reset overruns for all ports - FPGA programming makes overruns */
 	for (i = 0; i < NR_PORTS; i++) {
-		inb(LSR(yam_ports[i].dev.base_addr));
-		yam_ports[i].stats.rx_fifo_errors = 0;
+		struct net_device *dev = yam_devs[i];
+		struct yam_port *yp = dev->priv;
+		inb(LSR(dev->base_addr));
+		yp->stats.rx_fifo_errors = 0;
 	}
 
 	printk(KERN_INFO "%s at iobase 0x%lx irq %u uart %s\n", dev->name, dev->base_addr, dev->irq,
@@ -1070,14 +1072,26 @@
 
 /* --------------------------------------------------------------------- */
 
-static int yam_probe(struct net_device *dev)
+static void yam_setup(struct net_device *dev)
 {
-	struct yam_port *yp;
-
-	if (!dev)
-		return -ENXIO;
+	struct yam_port *yp = dev->priv;
 
-	yp = (struct yam_port *) dev->priv;
+	yp->magic = YAM_MAGIC;
+	yp->bitrate = DEFAULT_BITRATE;
+	yp->baudrate = DEFAULT_BITRATE * 2;
+	yp->iobase = 0;
+	yp->irq = 0;
+	yp->dupmode = 0;
+	yp->holdd = DEFAULT_HOLDD;
+	yp->txd = DEFAULT_TXD;
+	yp->txtail = DEFAULT_TXTAIL;
+	yp->slot = DEFAULT_SLOT;
+	yp->pers = DEFAULT_PERS;
+	yp->dev = dev;
+
+	dev->base_addr = yp->iobase;
+	dev->irq = yp->irq;
+	SET_MODULE_OWNER(dev);
 
 	dev->open = yam_open;
 	dev->stop = yam_close;
@@ -1104,50 +1118,35 @@
 	memcpy(dev->broadcast, ax25_bcast, 7);
 	memcpy(dev->dev_addr, ax25_test, 7);
 
-	/* New style flags */
-	dev->flags = 0;
-
-	return 0;
 }
 
-/* --------------------------------------------------------------------- */
-
 static int __init yam_init_driver(void)
 {
 	struct net_device *dev;
-	int i;
+	int i, err;
+	char name[IFNAMSIZ];
 
 	printk(yam_drvinfo);
 
 	for (i = 0; i < NR_PORTS; i++) {
-		sprintf(yam_ports[i].dev.name, "yam%d", i);
-		yam_ports[i].magic = YAM_MAGIC;
-		yam_ports[i].bitrate = DEFAULT_BITRATE;
-		yam_ports[i].baudrate = DEFAULT_BITRATE * 2;
-		yam_ports[i].iobase = 0;
-		yam_ports[i].irq = 0;
-		yam_ports[i].dupmode = 0;
-		yam_ports[i].holdd = DEFAULT_HOLDD;
-		yam_ports[i].txd = DEFAULT_TXD;
-		yam_ports[i].txtail = DEFAULT_TXTAIL;
-		yam_ports[i].slot = DEFAULT_SLOT;
-		yam_ports[i].pers = DEFAULT_PERS;
-
-		dev = &yam_ports[i].dev;
-
-		dev->priv = &yam_ports[i];
-		dev->base_addr = yam_ports[i].iobase;
-		dev->irq = yam_ports[i].irq;
-		dev->init = yam_probe;
-		dev->if_port = 0;
-
-		if (register_netdev(dev)) {
+		sprintf(name, "yam%d", i);
+		
+		dev = alloc_netdev(sizeof(struct yam_port), name,
+				   yam_setup);
+		if (!dev) {
+			printk(KERN_ERR "yam: cannot allocate net device %s\n",
+			       dev->name);
+			err = -ENOMEM;
+			goto error;
+		}
+		
+		err = register_netdev(dev);
+		if (err) {
 			printk(KERN_WARNING "yam: cannot register net device %s\n", dev->name);
-			dev->priv = NULL;
-			return -ENXIO;
+			goto error;
 		}
+		yam_devs[i] = dev;
 
-		SET_MODULE_OWNER(dev);
 	}
 
 	yam_timer.function = yam_dotimer;
@@ -1156,6 +1155,12 @@
 
 	proc_net_create("yam", 0, yam_net_get_info);
 	return 0;
+ error:
+	while (--i >= 0) {
+		unregister_netdev(yam_devs[i]);
+		kfree(yam_devs[i]);
+	}
+	return err;
 }
 
 /* --------------------------------------------------------------------- */
@@ -1167,12 +1172,11 @@
 
 	del_timer(&yam_timer);
 	for (i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = &yam_ports[i].dev;
-		if (!dev->priv)
-			continue;
-		if (netif_running(dev))
-			yam_close(dev);
-		unregister_netdev(dev);
+		struct net_device *dev = yam_devs[i];
+		if (dev) {
+			unregister_netdev(dev);
+			kfree(dev);
+		}
 	}
 
 	while (yam_data) {
