From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/12) Probe2 -- de620
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAK30148@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rework de620 driver to new dynamic allocation
Originally by Al Viro.
	* switched de620 to dynamic allocation
	* de620: embedded ->priv
	* de620: fixed IO before request_region()

Updated to ~jgarzik/net-drivers-2.5-exp

diff -urN 00-probe/drivers/net/de620.c 01-de620/drivers/net/de620.c
--- 00-probe/drivers/net/de620.c	2003-09-27 17:50:20.000000000 -0700
+++ 01-de620/drivers/net/de620.c	2003-09-29 15:48:30.000000000 -0700
@@ -226,7 +226,6 @@
 
 /* Initialization */
 static int	adapter_init(struct net_device *);
-int		de620_probe(struct net_device *);
 static int	read_eeprom(struct net_device *);
 
 
@@ -814,11 +813,16 @@
  *
  * Check if there is a DE-620 connected
  */
-int __init de620_probe(struct net_device *dev)
+struct net_device * __init de620_probe(int unit)
 {
-	static struct net_device_stats de620_netstats;
-	int i;
 	byte checkbyte = 0xa5;
+	struct net_device *dev;
+	int err = -ENOMEM;
+	int i;
+
+	dev = alloc_etherdev(sizeof(struct net_device_stats));
+	if (!dev)
+		goto out;
 
 	SET_MODULE_OWNER(dev);
 
@@ -831,11 +835,23 @@
 	dev->base_addr = io;
 	dev->irq       = irq;
 
+	/* allow overriding parameters on command line */
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+	
 	if (de620_debug)
 		printk(version);
 
 	printk(KERN_INFO "D-Link DE-620 pocket adapter");
 
+	if (!request_region(dev->base_addr, 3, "de620")) {
+		printk(" io 0x%3lX, which is busy.\n", dev->base_addr);
+		err = -EBUSY;
+		goto out1;
+	}
+
 	/* Initially, configure basic nibble mode, so we can read the EEPROM */
 	NIC_Cmd = DEF_NIC_CMD;
 	de620_set_register(dev, W_EIP, EIPRegister);
@@ -846,12 +862,8 @@
 
 	if ((checkbyte != 0xa5) || (read_eeprom(dev) != 0)) {
 		printk(" not identified in the printer port\n");
-		return -ENODEV;
-	}
-
-	if (!request_region(dev->base_addr, 3, "de620")) {
-		printk(KERN_ERR "io 0x%3lX, which is busy.\n", dev->base_addr);
-		return -EBUSY;
+		err = -ENODEV;
+		goto out2;
 	}
 
 	/* else, got it! */
@@ -870,10 +882,6 @@
 	else
 		printk(" UTP)\n");
 
-	/* Initialize the device structure. */
-	dev->priv = &de620_netstats;
-
-	memset(dev->priv, 0, sizeof(struct net_device_stats));
 	dev->get_stats 		= get_stats;
 	dev->open 		= de620_open;
 	dev->stop 		= de620_close;
@@ -884,8 +892,6 @@
 	
 	/* base_addr and irq are already set, see above! */
 
-	ether_setup(dev);
-
 	/* dump eeprom */
 	if (de620_debug) {
 		printk("\nEEPROM contents:\n");
@@ -899,7 +905,17 @@
 		printk("SCR = 0x%02x\n", nic_data.SCR);
 	}
 
-	return 0;
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	return dev;
+
+out2:
+	release_region(dev->base_addr, 3);
+out1:
+	free_netdev(dev);
+out:
+	return ERR_PTR(err);
 }
 
 /**********************************
@@ -994,20 +1010,21 @@
  *
  */
 #ifdef MODULE
-static struct net_device de620_dev;
+static struct net_device *de620_dev;
 
 int init_module(void)
 {
-	de620_dev.init = de620_probe;
-	if (register_netdev(&de620_dev) != 0)
-		return -EIO;
+	de620_dev = de620_probe(-1);
+	if (IS_ERR(de620_dev))
+		return PTR_ERR(de620_dev);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&de620_dev);
-	release_region(de620_dev.base_addr, 3);
+	unregister_netdev(de620_dev);
+	release_region(de620_dev->base_addr, 3);
+	free_netdev(de620_dev);
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
diff -urN 00-probe/drivers/net/Space.c 01-de620/drivers/net/Space.c
--- 00-probe/drivers/net/Space.c	2003-09-29 15:44:32.000000000 -0700
+++ 01-de620/drivers/net/Space.c	2003-09-29 15:48:30.000000000 -0700
@@ -97,7 +97,7 @@
 extern struct net_device *ltpc_probe(void);
   
 /* Detachable devices ("pocket adaptors") */
-extern int de620_probe(struct net_device *);
+extern struct net_device *de620_probe(int unit);
 
 /* Fibre Channel adapters */
 extern int iph5526_probe(struct net_device *dev);
@@ -296,7 +296,7 @@
 	{NULL, 0},
 };
 
-static struct devprobe parport_probes[] __initdata = {
+static struct devprobe2 parport_probes[] __initdata = {
 #ifdef CONFIG_DE620		/* D-Link DE-620 adapter */
 	{de620_probe, 0},
 #endif
@@ -387,8 +387,7 @@
 	    probe_list(dev, mips_probes) == 0 ||
 	    probe_list(dev, eisa_probes) == 0 ||
 	    probe_list(dev, mca_probes) == 0 ||
-	    probe_list(dev, isa_probes) == 0 ||
-	    probe_list(dev, parport_probes) == 0) 
+	    probe_list(dev, isa_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
@@ -404,7 +403,7 @@
 	if (base_addr == 1)
 		return;
 
-	return;	/* nothing yet */
+	probe_list2(unit, parport_probes, base_addr == 0);
 }
 
 #ifdef CONFIG_TR
