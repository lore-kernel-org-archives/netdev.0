From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/42) eexpress
Date: Wed, 12 Nov 2003 16:40:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130040.hAD0em429916@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE27-eexpress
	* switched eexpress to dynamic allocation
	* eexpress: embedded ->priv
	* eexpress: fixed clobbering on autoprobe
	* eexpress: fixed IO without request_region()
	* eexpress: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:27 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:27 2003
@@ -49,7 +49,7 @@
 extern int ne_probe(struct net_device *dev);
 extern int hp_probe(struct net_device *dev);
 extern int hp_plus_probe(struct net_device *dev);
-extern int express_probe(struct net_device *);
+extern struct net_device *express_probe(int unit);
 extern struct net_device *eepro_probe(int unit);
 extern int at1500_probe(struct net_device *);
 extern int at1700_probe(struct net_device *);
@@ -250,13 +250,13 @@
 #ifdef CONFIG_ETH16I
 	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
 #endif
-#ifdef CONFIG_EEXPRESS		/* Intel EtherExpress */
-	{express_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EEXPRESS		/* Intel EtherExpress */
+	{express_probe, 0},
+#endif
 #ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
 	{eepro_probe, 0},
 #endif
diff -Nru a/drivers/net/eexpress.c b/drivers/net/eexpress.c
--- a/drivers/net/eexpress.c	Tue Nov 11 09:35:27 2003
+++ b/drivers/net/eexpress.c	Tue Nov 11 09:35:27 2003
@@ -244,7 +244,6 @@
  * Prototypes for Linux interface
  */
 
-extern int express_probe(struct net_device *dev);
 static int eexp_open(struct net_device *dev);
 static int eexp_close(struct net_device *dev);
 static void eexp_timeout(struct net_device *dev);
@@ -334,11 +333,13 @@
  * checks for presence of EtherExpress card
  */
 
-int __init express_probe(struct net_device *dev)
+static int __init do_express_probe(struct net_device *dev)
 {
 	unsigned short *port;
 	static unsigned short ports[] = { 0x240,0x300,0x310,0x270,0x320,0x340,0 };
 	unsigned short ioaddr = dev->base_addr;
+	int dev_irq = dev->irq;
+	int err;
 
 	SET_MODULE_OWNER(dev);
 
@@ -391,27 +392,58 @@
 		}
 	}
 #endif
-	if (ioaddr&0xfe00)
-		return eexp_hw_probe(dev,ioaddr);
-	else if (ioaddr)
+	if (ioaddr&0xfe00) {
+		if (!request_region(ioaddr, EEXP_IO_EXTENT, "EtherExpress"))
+			return -EBUSY;
+		err = eexp_hw_probe(dev,ioaddr);
+		release_region(ioaddr, EEXP_IO_EXTENT);
+		return err;
+	} else if (ioaddr)
 		return -ENXIO;
 
 	for (port=&ports[0] ; *port ; port++ )
 	{
 		unsigned short sum = 0;
 		int i;
+		if (!request_region(*port, EEXP_IO_EXTENT, "EtherExpress"))
+			continue;
 		for ( i=0 ; i<4 ; i++ )
 		{
 			unsigned short t;
 			t = inb(*port + ID_PORT);
 			sum |= (t>>4) << ((t & 0x03)<<2);
 		}
-		if (sum==0xbaba && !eexp_hw_probe(dev,*port))
+		if (sum==0xbaba && !eexp_hw_probe(dev,*port)) {
+			release_region(*port, EEXP_IO_EXTENT);
 			return 0;
+		}
+		release_region(*port, EEXP_IO_EXTENT);
+		dev->irq = dev_irq;
 	}
 	return -ENODEV;
 }
 
+struct net_device * __init express_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = do_express_probe(dev);
+	if (!err) {
+		err = register_netdev(dev);
+		if (!err)
+			return dev;
+	}
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+
 /*
  * open and initialize the adapter, ready for use
  */
@@ -1058,7 +1090,7 @@
 	unsigned int memory_size;
 	int i;
 	unsigned short xsum = 0;
-	struct net_local *lp;
+	struct net_local *lp = dev->priv;
 
 	printk("%s: EtherExpress 16 at %#x ",dev->name,ioaddr);
 
@@ -1108,17 +1140,18 @@
 		buswidth = !((setupval & 0x400) >> 10);
 	}
 
-	dev->priv = lp = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (!dev->priv)
-		return -ENOMEM;
-
-	memset(dev->priv, 0, sizeof(struct net_local));
+	memset(lp, 0, sizeof(struct net_local));
 	spin_lock_init(&lp->lock);
 
  	printk("(IRQ %d, %s connector, %d-bit bus", dev->irq, 
  	       eexp_ifmap[dev->if_port], buswidth?8:16);
  
+	if (!request_region(dev->base_addr + 0x300e, 1, "EtherExpress"))
+		return -EBUSY;
+
  	eexp_hw_set_interface(dev);
+ 
+	release_region(dev->base_addr + 0x300e, 1);
   
 	/* Find out how much RAM we have on the card */
 	outw(0, dev->base_addr + WRITE_PTR);
@@ -1156,7 +1189,6 @@
 		break;
 	default:
 		printk(") bad memory size (%dk).\n", memory_size);
-		kfree(dev->priv);
 		return -ENODEV;
 		break;
 	}
@@ -1171,7 +1203,6 @@
 	dev->set_multicast_list = &eexp_set_multicast;
 	dev->tx_timeout = eexp_timeout;
 	dev->watchdog_timeo = 2*HZ;
-	ether_setup(dev);
 	return 0;
 }
 
@@ -1654,7 +1685,7 @@
 
 #define EEXP_MAX_CARDS     4    /* max number of cards to support */
 
-static struct net_device dev_eexp[EEXP_MAX_CARDS];
+static struct net_device *dev_eexp[EEXP_MAX_CARDS];
 static int irq[EEXP_MAX_CARDS];
 static int io[EEXP_MAX_CARDS];
 
@@ -1671,25 +1702,30 @@
  */
 int init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < EEXP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_eexp[this_dev];
+		dev = alloc_etherdev(sizeof(struct net_local));
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->init = express_probe;
 		if (io[this_dev] == 0) {
-			if (this_dev) break;
+			if (this_dev)
+				break;
 			printk(KERN_NOTICE "eexpress.c: Module autoprobe not recommended, give io=xx.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "eexpress.c: Failed to register card at 0x%x.\n", io[this_dev]);
-			if (found != 0) return 0;
-			return -ENXIO;
+		if (do_express_probe(dev) == 0 && register_netdev(dev) == 0) {
+			dev_eexp[this_dev] = dev;
+			found++;
+			continue;
 		}
-		found++;
+		printk(KERN_WARNING "eexpress.c: Failed to register card at 0x%x.\n", io[this_dev]);
+		free_netdev(dev);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void cleanup_module(void)
@@ -1697,11 +1733,10 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < EEXP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_eexp[this_dev];
-		if (dev->priv != NULL) {
+		struct net_device *dev = dev_eexp[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
+			free_netdev(dev);
 		}
 	}
 }
