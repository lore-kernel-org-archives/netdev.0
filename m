From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/6) ni65 -- revised probing
Date: Thu, 25 Sep 2003 17:13:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925171331.4ac63e55.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From Al Viro's NE14-ni65 patch
	* switched ni65 to dynamic allocation
	* ni65: fixed ->irq and ->dma clobbering on autoprob

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Thu Sep 25 16:29:14 2003
+++ b/drivers/net/Space.c	Thu Sep 25 16:29:14 2003
@@ -71,7 +71,7 @@
 extern int e2100_probe(struct net_device *);
 extern int ni5010_probe(struct net_device *);
 extern int ni52_probe(struct net_device *);
-extern int ni65_probe(struct net_device *);
+extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
 extern int SK_init(struct net_device *);
 extern int seeq8005_probe(struct net_device *);
@@ -290,6 +290,10 @@
 #ifdef CONFIG_NI52
 	{ni52_probe, 0},
 #endif
+	{NULL, 0},
+};
+
+static struct devprobe2 isa_probes2[] __initdata = {
 #ifdef CONFIG_NI65
 	{ni65_probe, 0},
 #endif
@@ -403,6 +407,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, isa_probes2, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
 }
 
diff -Nru a/drivers/net/ni65.c b/drivers/net/ni65.c
--- a/drivers/net/ni65.c	Thu Sep 25 16:29:14 2003
+++ b/drivers/net/ni65.c	Thu Sep 25 16:29:14 2003
@@ -343,29 +343,64 @@
 	return 0;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	struct priv *p = (struct priv *) dev->priv;
+	disable_dma(dev->dma);
+	free_dma(dev->dma);
+	release_region(dev->base_addr, cards[p->cardno].total_size);
+	ni65_free_buffer(p);
+}
+
+/* set: io,irq,dma or set it when calling insmod */
+static int irq;
+static int io;
+static int dma;
+
 /*
  * Probe The Card (not the lance-chip)
  */
-#ifdef MODULE
-static
-#endif
-int __init ni65_probe(struct net_device *dev)
+struct net_device * __init ni65_probe(int unit)
 {
-	int *port;
+	struct net_device *dev = alloc_etherdev(0);
 	static int ports[] = {0x360,0x300,0x320,0x340, 0};
+	int *port;
+	int err = 0;
 
-	if (dev->base_addr > 0x1ff)          /* Check a single specified location. */
-		 return ni65_probe1(dev, dev->base_addr);
-	else if (dev->base_addr > 0)         /* Don't probe at all. */
-		 return -ENXIO;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	for (port = ports; *port; port++)
-	{
-		if (ni65_probe1(dev, *port) == 0)
-			 return 0;
-	}
-
-	return -ENODEV;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		irq = dev->irq;
+		dma = dev->dma;
+	} else {
+		dev->base_addr = io;
+	}
+
+	if (dev->base_addr > 0x1ff) { /* Check a single specified location. */
+		err = ni65_probe1(dev, dev->base_addr);
+	} else if (dev->base_addr > 0) { /* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = ports; *port && ni65_probe1(dev, *port); port++)
+			;
+		if (!*port)
+			err = -ENODEV;
+	}
+	if (err)
+		goto out;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	cleanup_card(dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*
@@ -377,6 +412,9 @@
 	struct priv *p;
 	unsigned long flags;
 
+	dev->irq = irq;
+	dev->dma = dma;
+
 	for(i=0;i<NUM_CARDS;i++) {
 		if(!request_region(ioaddr, cards[i].total_size, cards[i].cardname))
 			continue;
@@ -521,9 +559,6 @@
 	dev->watchdog_timeo	= HZ/2;
 	dev->get_stats		= ni65_get_stats;
 	dev->set_multicast_list = set_multicast_list;
-
-	ether_setup(dev);
-
 	return 0; /* everything is OK */
 }
 
@@ -1213,12 +1248,7 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_ni65 = { .base_addr = 0x360, .irq = 9, .init = ni65_probe };
-
-/* set: io,irq,dma or set it when calling insmod */
-static int irq;
-static int io;
-static int dma;
+static struct net_device *dev_ni65;
 
 MODULE_PARM(irq, "i");
 MODULE_PARM(io, "i");
@@ -1229,26 +1259,15 @@
 
 int init_module(void)
 {
-	dev_ni65.irq = irq;
-	dev_ni65.dma = dma;
-	dev_ni65.base_addr = io;
-	if (register_netdev(&dev_ni65) != 0)
-		return -EIO;
-	return 0;
+ 	dev_ni65 = ni65_probe(-1);
+	return IS_ERR(dev_ni65) ? PTR_ERR(dev_ni65) : 0;
 }
 
 void cleanup_module(void)
 {
-	struct priv *p;
-	p = (struct priv *) dev_ni65.priv;
-	if(!p)
-		BUG();
-	disable_dma(dev_ni65.dma);
-	free_dma(dev_ni65.dma);
-	unregister_netdev(&dev_ni65);
-	release_region(dev_ni65.base_addr,cards[p->cardno].total_size);
-	ni65_free_buffer(p);
-	dev_ni65.priv = NULL;
+ 	unregister_netdev(dev_ni65);
+ 	cleanup_card(dev_ni65);
+ 	free_netdev(dev_ni65);
 }
 #endif /* MODULE */
 
