From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/7) 3c507 dynamic allocation
Date: Tue, 23 Sep 2003 15:01:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923150123.146ad4fc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Originally from viro NE19-3c507
	* switched 3c507 to dynamic allocation
	* 3c507: embedded ->priv
	* 3c507: fixed clobbering on autoprobe
	* NB: 3c507.c buggers port 0x100 without claiming it.  Most likely it
	  should be doing request_region() there.

diff -Nru a/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	Tue Sep 23 13:40:53 2003
+++ b/drivers/net/3c507.c	Tue Sep 23 13:40:53 2003
@@ -74,10 +74,6 @@
 #define debug net_debug
 
 
-/* A zero-terminated list of common I/O addresses to be probed. */
-static unsigned int netcard_portlist[] __initdata =
-	{ 0x300, 0x320, 0x340, 0x280, 0};
-
 /*
   			Details of the i82586.
 
@@ -286,8 +282,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int el16_probe(struct net_device *dev);	/* Called from Space.c */
-
 static int	el16_probe1(struct net_device *dev, int ioaddr);
 static int	el16_open(struct net_device *dev);
 static int	el16_send_packet(struct sk_buff *skb, struct net_device *dev);
@@ -301,6 +295,9 @@
 static void init_82586_mem(struct net_device *dev);
 static struct ethtool_ops netdev_ethtool_ops;
 
+static int io = 0x300;
+static int mem_start;
+
 
 /* Check for a network adaptor of this type, and return '0' iff one exists.
 	If dev->base_addr == 0, probe all likely locations.
@@ -309,23 +306,47 @@
 	device and return success.
 	*/
 
-int __init el16_probe(struct net_device *dev)
+struct net_device * __init el16_probe(int unit)
 {
-	int base_addr = dev->base_addr;
-	int i;
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	static unsigned ports[] = { 0x300, 0x320, 0x340, 0x280, 0};
+	unsigned *port;
+	int err = 0;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		mem_start = dev->mem_start & 15;
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	if (base_addr > 0x1ff)	/* Check a single specified location. */
-		return el16_probe1(dev, base_addr);
-	else if (base_addr != 0)
-		return -ENXIO;		/* Don't probe at all. */
-
-	for (i = 0; netcard_portlist[i]; i++)
-		if (el16_probe1(dev, netcard_portlist[i]) == 0)
-			return 0;
-
-	return -ENODEV;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = el16_probe1(dev, io);
+	} else if (io != 0) {
+		err = -ENXIO;		/* Don't probe at all. */
+	} else {
+		for (port = ports; *port && el16_probe1(dev, *port); port++)
+			;
+		if (!*port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, EL16_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init el16_probe1(struct net_device *dev, int ioaddr)
@@ -383,8 +404,8 @@
 		printk(" %02x", dev->dev_addr[i]);
 	}
 
-	if ((dev->mem_start & 0xf) > 0)
-		net_debug = dev->mem_start & 7;
+	if (mem_start)
+		net_debug = mem_start & 7;
 
 #ifdef MEM_BASE
 	dev->mem_start = MEM_BASE;
@@ -416,27 +437,18 @@
 	if (net_debug)
 		printk(version);
 
-	/* Initialize the device structure. */
-	lp = dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		retval = -ENOMEM;
-		goto out;
-	}
-	memset(dev->priv, 0, sizeof(struct net_local));
+	lp = dev->priv;
+ 	memset(lp, 0, sizeof(*lp));
 	spin_lock_init(&lp->lock);
 
-	dev->open		= el16_open;
-	dev->stop		= el16_close;
+ 	dev->open = el16_open;
+ 	dev->stop = el16_close;
 	dev->hard_start_xmit = el16_send_packet;
 	dev->get_stats	= el16_get_stats;
 	dev->tx_timeout = el16_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-
-	ether_setup(dev);	/* Generic ethernet behaviour */
-
-	dev->flags&=~IFF_MULTICAST;	/* Multicast doesn't work */
-
+ 	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */
 	return 0;
 out:
 	release_region(ioaddr, EL16_IO_EXTENT);
@@ -899,8 +911,7 @@
 };
 
 #ifdef MODULE
-static struct net_device dev_3c507;
-static int io = 0x300;
+static struct net_device *dev_3c507;
 static int irq;
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -911,26 +922,18 @@
 {
 	if (io == 0)
 		printk("3c507: You should not use auto-probing with insmod!\n");
-	dev_3c507.base_addr = io;
-	dev_3c507.irq       = irq;
-	dev_3c507.init	    = el16_probe;
-	if (register_netdev(&dev_3c507) != 0) {
-		printk("3c507: register_netdev() returned non-zero.\n");
-		return -EIO;
-	}
-	return 0;
+	dev_3c507 = el16_probe(-1);
+	return IS_ERR(dev_3c507) ? PTR_ERR(dev_3c507) : 0;
 }
 
 void
 cleanup_module(void)
 {
-	unregister_netdev(&dev_3c507);
-	kfree(dev_3c507.priv);
-	dev_3c507.priv = NULL;
-
-	/* If we don't do this, we can't re-insmod it later. */
-	free_irq(dev_3c507.irq, &dev_3c507);
-	release_region(dev_3c507.base_addr, EL16_IO_EXTENT);
+	struct net_device *dev = dev_3c507;
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, EL16_IO_EXTENT);
+	free_netdev(dev);
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 13:40:53 2003
+++ b/drivers/net/Space.c	Tue Sep 23 13:40:53 2003
@@ -60,7 +60,7 @@
 extern int el1_probe(struct net_device *);
 extern int wavelan_probe(struct net_device *);
 extern int arlan_probe(struct net_device *);
-extern int el16_probe(struct net_device *);
+extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
 extern struct net_device *elplus_probe(int unit);
@@ -275,13 +275,13 @@
 #ifdef CONFIG_ARLAN		/* Aironet */
 	{arlan_probe, 0},
 #endif
-#ifdef CONFIG_EL16		/* 3c507 */
-	{el16_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EL16		/* 3c507 */
+	{el16_probe, 0},
+#endif
 #ifdef CONFIG_ELPLUS		/* 3c505 */
 	{elplus_probe, 0},
 #endif
