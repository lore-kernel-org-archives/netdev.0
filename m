From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/42) smc
Date: Wed, 12 Nov 2003 16:41:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0fwn30285@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE34-smc
	* switched smc to dynamic allocation
	* smc: embedded ->priv
	* smc: fixed resource leaks on failure exits
	* smc: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 11:03:51 2003
+++ b/drivers/net/Space.c	Tue Nov 11 11:03:51 2003
@@ -73,7 +73,7 @@
 extern int sonic_probe(struct net_device *);
 extern struct net_device *SK_init(int unit);
 extern struct net_device *seeq8005_probe(int unit);
-extern int smc_init( struct net_device * );
+extern struct net_device *smc_init(int unit);
 extern int atarilance_probe(struct net_device *);
 extern int sun3lance_probe(struct net_device *);
 extern int sun3_82586_probe(struct net_device *);
@@ -228,13 +228,13 @@
 #ifdef CONFIG_LANCE		/* ISA/VLB (use pcnet32 for PCI cards) */
 	{lance_probe, 0},
 #endif
-#ifdef CONFIG_SMC9194
-	{smc_init, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_SMC9194
+	{smc_init, 0},
+#endif
 #ifdef CONFIG_SEEQ8005 
 	{seeq8005_probe, 0},
 #endif
diff -Nru a/drivers/net/smc9194.c b/drivers/net/smc9194.c
--- a/drivers/net/smc9194.c	Tue Nov 11 11:03:51 2003
+++ b/drivers/net/smc9194.c	Tue Nov 11 11:03:51 2003
@@ -191,7 +191,7 @@
  .
  . NB:This shouldn't be static since it is referred to externally.
 */
-int smc_init(struct net_device *dev);
+struct net_device *smc_init(int unit);
 
 /*
  . The kernel calls this function when someone wants to use the device,
@@ -672,7 +672,7 @@
 
 /*-------------------------------------------------------------------------
  |
- | smc_init( struct net_device * dev )
+ | smc_init(int unit)
  |   Input parameters:
  |	dev->base_addr == 0, try to find all possible locations
  |	dev->base_addr == 1, return failure code
@@ -680,31 +680,56 @@
  |	dev->base_addr == <anything else>   this is the address to check
  |
  |   Output:
- |	0 --> there is a device
- |	anything else, error
+ |	pointer to net_device or ERR_PTR(error)
  |
  ---------------------------------------------------------------------------
 */
-int __init smc_init(struct net_device *dev)
+static int io;
+static int irq;
+static int ifport;
+
+struct net_device * __init smc_init(int unit)
 {
-	int i;
-	int base_addr = dev->base_addr;
+	struct net_device *dev = alloc_etherdev(sizeof(struct smc_local));
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
 
 	SET_MODULE_OWNER(dev);
 
-	/*  try a specific location */
-	if (base_addr > 0x1ff)
-		return smc_probe(dev, base_addr);
-	else if (base_addr != 0)
-		return -ENXIO;
-
-	/* check every ethernet address */
-	for (i = 0; smc_portlist[i]; i++)
-		if (smc_probe(dev, smc_portlist[i]) == 0)
-			return 0;
-
-	/* couldn't find anything */
-	return -ENODEV;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = smc_probe(dev, io);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = smc_portlist; *port; port++) {
+			if (smc_probe(dev, *port) == 0)
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
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, SMC_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*----------------------------------------------------------------------
@@ -821,6 +846,9 @@
 	if (!request_region(ioaddr, SMC_IO_EXTENT, dev->name))
 		return -EBUSY;
 
+	dev->irq = irq;
+	dev->if_port = ifport;
+
 	/* First, see if the high byte is 0x33 */
 	bank = inw( ioaddr + BANK_SELECT );
 	if ( (bank & 0xFF00) != 0x3300 ) {
@@ -969,28 +997,14 @@
 		printk("%2.2x:", dev->dev_addr[i] );
 	printk("%2.2x \n", dev->dev_addr[5] );
 
-
-	/* Initialize the private structure. */
-	if (dev->priv == NULL) {
-		dev->priv = kmalloc(sizeof(struct smc_local), GFP_KERNEL);
-		if (dev->priv == NULL) {
-			retval = -ENOMEM;
-			goto err_out;
-		}
-	}
 	/* set the private data to zero by default */
 	memset(dev->priv, 0, sizeof(struct smc_local));
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
 	/* Grab the IRQ */
       	retval = request_irq(dev->irq, &smc_interrupt, 0, dev->name, dev);
       	if (retval) {
 		printk("%s: unable to get IRQ %d (irqval=%d).\n", dev->name,
 			dev->irq, retval);
-		kfree(dev->priv);
-		dev->priv = NULL;
   	  	goto err_out;
       	}
 
@@ -1524,10 +1538,7 @@
 
 #ifdef MODULE
 
-static struct net_device devSMC9194;
-static int io;
-static int irq;
-static int ifport;
+static struct net_device *devSMC9194;
 MODULE_LICENSE("GPL");
 
 MODULE_PARM(io, "i");
@@ -1539,32 +1550,23 @@
 
 int init_module(void)
 {
-	int result;
-
 	if (io == 0)
 		printk(KERN_WARNING
 		CARDNAME": You shouldn't use auto-probing with insmod!\n" );
 
 	/* copy the parameters from insmod into the device structure */
-	devSMC9194.base_addr = io;
-	devSMC9194.irq       = irq;
-	devSMC9194.if_port	= ifport;
-	devSMC9194.init   	= smc_init;
-	if ((result = register_netdev(&devSMC9194)) != 0)
-		return result;
-
+	devSMC9194 = smc_init(-1);
+	if (IS_ERR(devSMC9194))
+		return PTR_ERR(devSMC9194);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&devSMC9194);
-
-	free_irq(devSMC9194.irq, &devSMC9194);
-	release_region(devSMC9194.base_addr, SMC_IO_EXTENT);
-
-	if (devSMC9194.priv)
-		kfree(devSMC9194.priv);
+	unregister_netdev(devSMC9194);
+	free_irq(devSMC9194->irq, devSMC9194);
+	release_region(devSMC9194->base_addr, SMC_IO_EXTENT);
+	free_netdev(devSMC9194);
 }
 
 #endif /* MODULE */
