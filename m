From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/42) seeq8005
Date: Wed, 12 Nov 2003 16:41:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0fmW30188@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE33-seeq8005
	* switched seeq8005 to dynamic allocation
	* seeq8005: embedded ->priv
	* seeq8005: fixed resource leaks on failure exits
	* seeq8005: fixed clobbering on autoprobe
	* seeq8005: fixed jiffies truncation
	* seeq8005: fixed a typo in Kconfig - module is _not_ called ewrk3

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:45 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:45 2003
@@ -72,7 +72,7 @@
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
 extern struct net_device *SK_init(int unit);
-extern int seeq8005_probe(struct net_device *);
+extern struct net_device *seeq8005_probe(int unit);
 extern int smc_init( struct net_device * );
 extern int atarilance_probe(struct net_device *);
 extern int sun3lance_probe(struct net_device *);
@@ -231,13 +231,13 @@
 #ifdef CONFIG_SMC9194
 	{smc_init, 0},
 #endif
-#ifdef CONFIG_SEEQ8005 
-	{seeq8005_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_SEEQ8005 
+	{seeq8005_probe, 0},
+#endif
 #ifdef CONFIG_CS89x0
  	{cs89x0_probe, 0},
 #endif
diff -Nru a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
--- a/drivers/net/seeq8005.c	Tue Nov 11 09:35:45 2003
+++ b/drivers/net/seeq8005.c	Tue Nov 11 09:35:45 2003
@@ -78,8 +78,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int seeq8005_probe(struct net_device *dev);
-
 static int seeq8005_probe1(struct net_device *dev, int ioaddr);
 static int seeq8005_open(struct net_device *dev);
 static void seeq8005_timeout(struct net_device *dev);
@@ -102,22 +100,48 @@
    If dev->base_addr == 1, always return failure.
    */
 
-int __init 
-seeq8005_probe(struct net_device *dev)
-{
-	int i;
-	int base_addr = dev ? dev->base_addr : 0;
-
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return seeq8005_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; seeq8005_portlist[i]; i++)
-		if (seeq8005_probe1(dev, seeq8005_portlist[i]) == 0)
-			return 0;
+static int io = 0x320;
+static int irq = 10;
 
-	return -ENODEV;
+struct net_device * __init seeq8005_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
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
+		irq = dev->irq;
+	}
+
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = seeq8005_probe1(dev, io);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = seeq8005_portlist; *port; port++) {
+			if (seeq8005_probe1(dev, *port) == 0)
+				break;
+		}
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
+	release_region(dev->base_addr, SEEQ8005_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /* This is the real probe routine.  Linux has a history of friendly device
@@ -274,6 +298,7 @@
 
 	/* Fill in the 'dev' fields. */
 	dev->base_addr = ioaddr;
+	dev->irq = irq;
 
 	/* Retrieve and print the ethernet address. */
 	for (i = 0; i < 6; i++)
@@ -307,13 +332,6 @@
 		 }
 	}
 #endif
-
-	/* Initialize the device structure. */
-	dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct net_local));
-
 	dev->open		= seeq8005_open;
 	dev->stop		= seeq8005_close;
 	dev->hard_start_xmit 	= seeq8005_send_packet;
@@ -321,10 +339,6 @@
 	dev->watchdog_timeo	= HZ/20;
 	dev->get_stats		= seeq8005_get_stats;
 	dev->set_multicast_list = set_multicast_list;
-
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-	
 	dev->flags &= ~IFF_MULTICAST;
 
 	return 0;
@@ -721,9 +735,7 @@
 	
 #ifdef MODULE
 
-static struct net_device dev_seeq = { .init = seeq8005_probe };
-static int io = 0x320;
-static int irq = 10;
+static struct net_device *dev_seeq;
 MODULE_LICENSE("GPL");
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -732,28 +744,17 @@
 
 int init_module(void)
 {
-	dev_seeq.irq=irq;
-	dev_seeq.base_addr=io;
-	if (register_netdev(&dev_seeq) != 0)
-		return -EIO;
+	dev_seeq = seeq8005_probe(-1);
+	if (IS_ERR(dev_seeq))
+		return PTR_ERR(dev_seeq);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_seeq);
-
-	/*
-	 *	Free up the private structure, or leak memory :-)
-	 */
-
-	kfree(dev_seeq.priv);
-	dev_seeq.priv = NULL;	/* gets re-allocated by el1_probe1 */
-
-	/*
-	 *	If we don't do this, we can't re-insmod it later.
-	 */
-	release_region(dev_seeq.base_addr, SEEQ8005_IO_EXTENT);
+	unregister_netdev(dev_seeq);
+	release_region(dev_seeq->base_addr, SEEQ8005_IO_EXTENT);
+	free_netdev(dev_seeq);
 }
 
 #endif /* MODULE */
