From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/42) eth16i
Date: Wed, 12 Nov 2003 16:40:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130040.hAD0ew229935@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE28-eth16i
	* switched eth16i to dynamic allocation
	* eth16i: embedded ->priv
	* eth16i: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:29 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:29 2003
@@ -54,7 +54,7 @@
 extern int at1500_probe(struct net_device *);
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
-extern int eth16i_probe(struct net_device *);
+extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *el1_probe(int unit);
@@ -247,13 +247,13 @@
 #ifdef CONFIG_FMV18X		/* Fujitsu FMV-181/182 */
 	{fmv18x_probe, 0},
 #endif
-#ifdef CONFIG_ETH16I
-	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ETH16I
+	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
+#endif
 #ifdef CONFIG_EEXPRESS		/* Intel EtherExpress */
 	{express_probe, 0},
 #endif
diff -Nru a/drivers/net/eth16i.c b/drivers/net/eth16i.c
--- a/drivers/net/eth16i.c	Tue Nov 11 09:35:29 2003
+++ b/drivers/net/eth16i.c	Tue Nov 11 09:35:29 2003
@@ -369,7 +369,6 @@
 #define NUM_OF_EISA_IRQS   8
 
 static unsigned int eth16i_tx_buf_map[] = { 2048, 2048, 4096, 8192 };
-static unsigned int boot = 1;
 
 /* Use 0 for production, 1 for verification, >2 for debug */
 #ifndef ETH16I_DEBUG
@@ -395,8 +394,6 @@
 
 /* Function prototypes */
 
-extern int     eth16i_probe(struct net_device *dev);
-
 static int     eth16i_probe1(struct net_device *dev, int ioaddr);
 static int     eth16i_check_signature(int ioaddr);
 static int     eth16i_probe_port(int ioaddr);
@@ -418,7 +415,7 @@
 static void    eth16i_skip_packet(struct net_device *dev);
 static void    eth16i_multicast(struct net_device *dev); 
 static void    eth16i_select_regbank(unsigned char regbank, int ioaddr);
-static void    eth16i_initialize(struct net_device *dev);
+static void    eth16i_initialize(struct net_device *dev, int boot);
 
 #if 0
 static int     eth16i_set_irq(struct net_device *dev);
@@ -432,7 +429,7 @@
 
 static char cardname[] __initdata = "ICL EtherTeam 16i/32";
 
-int __init eth16i_probe(struct net_device *dev)
+static int __init do_eth16i_probe(struct net_device *dev)
 {
 	int i;
 	int ioaddr;
@@ -461,14 +458,38 @@
 	return -ENODEV;
 }
 
+struct net_device * __init eth16i_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct eth16i_local));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = do_eth16i_probe(dev);
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, ETH16I_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+
 static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 {
-	struct eth16i_local *lp;
+	struct eth16i_local *lp = dev->priv;
 	static unsigned version_printed;
 	int retval;
 
-	boot = 1;  /* To inform initilization that we are in boot probe */
-
 	/* Let's grab the region */
 	if (!request_region(ioaddr, ETH16I_IO_EXTENT, dev->name))
 		return -EBUSY;
@@ -531,22 +552,13 @@
 	eth16i_select_regbank(TRANSCEIVER_MODE_RB, ioaddr);
 	outb(0x38, ioaddr + TRANSCEIVER_MODE_REG); 
 
-	eth16i_initialize(dev);   /* Initialize rest of the chip's registers */
+	eth16i_initialize(dev, 1); /* Initialize rest of the chip's registers */
 
 	/* Now let's same some energy by shutting down the chip ;) */
 	BITCLR(ioaddr + CONFIG_REG_1, POWERUP);
 
 	/* Initialize the device structure */
-	if(dev->priv == NULL) {
-		dev->priv = kmalloc(sizeof(struct eth16i_local), GFP_KERNEL);
-		if(dev->priv == NULL) {
-			free_irq(dev->irq, dev);
-			retval = -ENOMEM;
-			goto out;
-		}
-	}
-
-	memset(dev->priv, 0, sizeof(struct eth16i_local));
+	memset(lp, 0, sizeof(struct eth16i_local));
 	dev->open               = eth16i_open;
 	dev->stop               = eth16i_close;
 	dev->hard_start_xmit    = eth16i_tx;
@@ -554,15 +566,7 @@
 	dev->set_multicast_list = eth16i_multicast;
 	dev->tx_timeout 	= eth16i_timeout;
 	dev->watchdog_timeo	= TX_TIMEOUT;
-
-	lp = (struct eth16i_local *)dev->priv;
 	spin_lock_init(&lp->lock);
-
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
-	boot = 0;
-
 	return 0;
 out:
 	release_region(ioaddr, ETH16I_IO_EXTENT);
@@ -570,7 +574,7 @@
 }
 
 
-static void eth16i_initialize(struct net_device *dev)
+static void eth16i_initialize(struct net_device *dev, int boot)
 {
 	int ioaddr = dev->base_addr;
 	int i, node_w = 0;
@@ -953,7 +957,7 @@
 	outb(0xc0 | POWERUP, ioaddr + CONFIG_REG_1);
 
 	/* Initialize the chip */
-	eth16i_initialize(dev);  
+	eth16i_initialize(dev, 0);  
 
 	/* Set the transmit buffer size */
 	lp->tx_buf_size = eth16i_tx_buf_map[ETH16I_TX_BUF_SIZE & 0x03];
@@ -1401,7 +1405,7 @@
 
 #define MAX_ETH16I_CARDS 4  /* Max number of Eth16i cards per module */
 
-static struct net_device dev_eth16i[MAX_ETH16I_CARDS];
+static struct net_device *dev_eth16i[MAX_ETH16I_CARDS];
 static int io[MAX_ETH16I_CARDS];
 #if 0
 static int irq[MAX_ETH16I_CARDS];
@@ -1431,14 +1435,14 @@
 int init_module(void)
 {
 	int this_dev, found = 0;
+	struct net_device *dev;
+
+	for (this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++) {
+		dev = alloc_etherdev(sizeof(struct eth16i_local));
+		if (!dev)
+			break;
 
-	for(this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++)
-	{
-		struct net_device *dev = &dev_eth16i[this_dev];
-	
-		dev->irq = 0; /* irq[this_dev]; */
 		dev->base_addr = io[this_dev];
-		dev->init = eth16i_probe;
 
 	        if(debug != -1)
 			eth16i_debug = debug;
@@ -1448,44 +1452,43 @@
 
 		dev->if_port = eth16i_parse_mediatype(mediatype[this_dev]);
 
-		if(io[this_dev] == 0)
-		{
-			if(this_dev != 0) break; /* Only autoprobe 1st one */
+		if(io[this_dev] == 0) {
+			if(this_dev != 0) /* Only autoprobe 1st one */
+				break;
 
 			printk(KERN_NOTICE "eth16i.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
 
-		if(register_netdev(dev) != 0)
-		{
-			printk(KERN_WARNING "eth16i.c No Eth16i card found (i/o = 0x%x).\n",
-			       io[this_dev]);
-	    
-			if(found != 0) return 0;
-			return -ENXIO;
+		if (do_eth16i_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_eth16i[found++] = dev;
+				continue;
+			}
+			free_irq(dev->irq, dev);
+			release_region(dev->base_addr, ETH16I_IO_EXTENT);
 		}
-
-		found++;
+		printk(KERN_WARNING "eth16i.c No Eth16i card found (i/o = 0x%x).\n",
+		       io[this_dev]);
+		free_netdev(dev);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 	
 void cleanup_module(void)
 {
 	int this_dev;
 
-	for(this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++)
-	{
-		struct net_device* dev = &dev_eth16i[this_dev];
+	for(this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++) {
+		struct net_device *dev = dev_eth16i[this_dev];
 		
-		if(dev->priv != NULL)
-		{
+		if(dev->priv) {
 			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
-			
 			free_irq(dev->irq, dev);
 			release_region(dev->base_addr, ETH16I_IO_EXTENT);
-			
+			free_netdev(dev);
 		}
 	}
 }
