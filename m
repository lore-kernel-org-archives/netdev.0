From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] device probing changes
Date: Mon, 29 Sep 2003 15:11:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929151150.7331b603.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

This a resend of the earlier patches, but these are against 2.6.0-test6 latest;
the arlan patch assumes the fix that occurred after 2.6.0-test6 went out.

	00 - adds list of devices that allocate own netdev

	01 - de620
	02 - ni65
	03 - ni52
	04 - ni5010
	05 - sk16
	06 - 3c505
	07 - 3c507
	08 - arlan
	09 - wavelan
	10 - 3c501
	11 - 82596

Each patch starts with a description.

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="00-probe.patch"
Content-Disposition: attachment;
 filename="00-probe.patch"
Content-Transfer-Encoding: 7bit

Add second probe list used for devices which allocate
their own network device.

Restore earlier behaviour where we probe for up to eight network
devices, even if some don't exist.  This is for the case where boot
parameters set values for second or third device.


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:38:06 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:38:06 2003
@@ -110,6 +110,11 @@
 	int status;	/* non-zero if autoprobe has failed */
 };
 
+struct devprobe2 {
+	struct net_device *(*probe)(int unit);
+	int status;	/* non-zero if autoprobe has failed */
+};
+
 /*
  * probe_list walks a list of probe functions and calls each so long
  * as a non-zero ioaddr is given, or as long as it hasn't already failed 
@@ -135,6 +140,21 @@
 	return -ENODEV;
 }
 
+static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
+{
+	struct net_device *dev;
+	for (; p->probe; p++) {
+		if (autoprobe && p->status)
+			continue;
+		dev = p->probe(unit);
+		if (!IS_ERR(dev))
+			return 0;
+		if (autoprobe)
+			p->status = PTR_ERR(dev);
+	}
+	return -ENODEV;
+}
+
 /*
  * This is a bit of an artificial separation as there are PCI drivers
  * that also probe for EISA cards (in the PCI group) and there are ISA
@@ -372,6 +392,16 @@
 	return err;
 
 }
+ 
+static void __init ethif_probe2(int unit)
+{
+	unsigned long base_addr = netdev_boot_base("eth", unit);
+
+	if (base_addr == 1)
+		return;
+
+	return;	/* nothing yet */
+}
 
 #ifdef CONFIG_TR
 /* Token-ring device probe */
@@ -433,17 +463,17 @@
 	
 #ifdef CONFIG_SBNI
 	for (num = 0; num < 8; ++num)
-		if (sbni_probe(num))
-			break;
+		sbni_probe(num);
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (trif_probe(num))
-			break;
+		trif_probe(num);
 #endif
-	for (num = 0; num < 8; ++num)
-		if (ethif_probe(num))
-			break;
+	for (num = 0; num < 8; ++num) {
+		if (!ethif_probe(num))
+			ethif_probe2(num);
+	}
+
 #ifdef CONFIG_COPS
 	cops_probe(0);
 	cops_probe(1);
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Mon Sep 29 10:38:06 2003
+++ b/include/linux/netdevice.h	Mon Sep 29 10:38:06 2003
@@ -499,6 +499,7 @@
 extern void		probe_old_netdevs(void);
 extern int			netdev_boot_setup_add(char *name, struct ifmap *map);
 extern int 			netdev_boot_setup_check(struct net_device *dev);
+extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Mon Sep 29 10:38:06 2003
+++ b/net/core/dev.c	Mon Sep 29 10:38:06 2003
@@ -372,6 +372,30 @@
 	return 0;
 }
 
+
+/**
+ *	netdev_boot_base	- get address from boot time settings
+ *	@prefix: prefix for network device
+ *	@unit: id for network device
+ *
+ * 	Check boot time settings for the base address of device.
+ *	The found settings are set for the device to be used
+ *	later in the device probing.
+ *	Returns 0 if no settings found.
+ */
+unsigned long netdev_boot_base(const char *prefix, int unit)
+{
+	const struct netdev_boot_setup *s = dev_boot_setup;
+	char name[IFNAMSIZ];
+	int i;
+
+	sprintf(name, "%s%d", prefix, unit);
+	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
+		if (!strcmp(name, s[i].name))
+			return s[i].map.base_addr;
+	return 0;
+}
+
 /*
  * Saves at boot time configured settings for any netdevice.
  */

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="01-de620.patch"
Content-Disposition: attachment;
 filename="01-de620.patch"
Content-Transfer-Encoding: 7bit

Part of viro NE13-de620:
	* switched de620 to dynamic allocation
	* de620: embedded ->priv
	* de620: fixed IO before request_region()
Additional:
	* use free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:43:23 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:43:23 2003
@@ -96,7 +96,7 @@
 extern struct net_device *ltpc_probe(void);
   
 /* Detachable devices ("pocket adaptors") */
-extern int de620_probe(struct net_device *);
+extern struct net_device *de620_probe(int unit);
 
 /* Fibre Channel adapters */
 extern int iph5526_probe(struct net_device *dev);
@@ -292,7 +292,7 @@
 	{NULL, 0},
 };
 
-static struct devprobe parport_probes[] __initdata = {
+static struct devprobe2 parport_probes[] __initdata = {
 #ifdef CONFIG_DE620		/* D-Link DE-620 adapter */
 	{de620_probe, 0},
 #endif
@@ -383,8 +383,7 @@
 	    probe_list(dev, mips_probes) == 0 ||
 	    probe_list(dev, eisa_probes) == 0 ||
 	    probe_list(dev, mca_probes) == 0 ||
-	    probe_list(dev, isa_probes) == 0 ||
-	    probe_list(dev, parport_probes) == 0) 
+	    probe_list(dev, isa_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
@@ -400,7 +399,7 @@
 	if (base_addr == 1)
 		return;
 
-	return;	/* nothing yet */
+	probe_list2(unit, parport_probes, base_addr == 0);
 }
 
 #ifdef CONFIG_TR
diff -Nru a/drivers/net/de620.c b/drivers/net/de620.c
--- a/drivers/net/de620.c	Mon Sep 29 09:43:23 2003
+++ b/drivers/net/de620.c	Mon Sep 29 09:43:23 2003
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

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="02-ni65.patch"
Content-Disposition: attachment;
 filename="02-ni65.patch"
Content-Transfer-Encoding: 7bit

>From  viro NE14-ni65
	* switched ni65 to dynamic allocation
	* ni65: fixed ->irq and ->dma clobbering on autoprobe
Additional:
	* added free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:43:46 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:43:46 2003
@@ -70,7 +70,7 @@
 extern int e2100_probe(struct net_device *);
 extern int ni5010_probe(struct net_device *);
 extern int ni52_probe(struct net_device *);
-extern int ni65_probe(struct net_device *);
+extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
 extern int SK_init(struct net_device *);
 extern int seeq8005_probe(struct net_device *);
@@ -286,6 +286,10 @@
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
@@ -399,6 +403,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, isa_probes2, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
 }
 
diff -Nru a/drivers/net/ni65.c b/drivers/net/ni65.c
--- a/drivers/net/ni65.c	Mon Sep 29 09:43:46 2003
+++ b/drivers/net/ni65.c	Mon Sep 29 09:43:46 2003
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
 

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="03-ni52.patch"
Content-Disposition: attachment;
 filename="03-ni52.patch"
Content-Transfer-Encoding: 7bit

>From viro NE15-ni52
	* switched ni52 to dynamic allocation
	* ni52: embedded ->priv
	* ni52: fixed clobbering of everything on autoprobe
Additional:
	* add free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:44:07 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:44:07 2003
@@ -69,7 +69,7 @@
 extern int lne390_probe(struct net_device *);
 extern int e2100_probe(struct net_device *);
 extern int ni5010_probe(struct net_device *);
-extern int ni52_probe(struct net_device *);
+extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
 extern int SK_init(struct net_device *);
@@ -283,13 +283,13 @@
 #ifdef CONFIG_NI5010
 	{ni5010_probe, 0},
 #endif
-#ifdef CONFIG_NI52
-	{ni52_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_NI52
+	{ni52_probe, 0},
+#endif
 #ifdef CONFIG_NI65
 	{ni65_probe, 0},
 #endif
diff -Nru a/drivers/net/ni52.c b/drivers/net/ni52.c
--- a/drivers/net/ni52.c	Mon Sep 29 09:44:07 2003
+++ b/drivers/net/ni52.c	Mon Sep 29 09:44:07 2003
@@ -354,50 +354,76 @@
 	memset((char *)p->scb,0,sizeof(struct scb_struct));
 }
 
+/* set: io,irq,memstart,memend or set it when calling insmod */
+static int irq=9;
+static int io=0x300;
+static long memstart;	/* e.g 0xd0000 */
+static long memend;	/* e.g 0xd4000 */
+
 /**********************************************
  * probe the ni5210-card
  */
-int __init ni52_probe(struct net_device *dev)
+struct net_device * __init ni52_probe(int unit)
 {
-#ifndef MODULE
-	int *port;
+	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
 	static int ports[] = {0x300, 0x280, 0x360 , 0x320 , 0x340, 0};
-#endif
-	int base_addr = dev->base_addr;
-
-	SET_MODULE_OWNER(dev);
+	int *port;
+	int err = 0;
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return ni52_probe1(dev, base_addr);
-	else if (base_addr > 0)		/* Don't probe at all. */
-		return -ENXIO;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-#ifdef MODULE
-	printk("%s: no autoprobing allowed for modules.\n",dev->name);
-#else
-	for (port = ports; *port; port++) {
-		int ioaddr = *port;
-		dev->base_addr = ioaddr;
-		if (ni52_probe1(dev, ioaddr) == 0)
-			return 0;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		irq = dev->irq;
+		memstart = dev->mem_start;
+		memend = dev->mem_end;
 	}
 
-#ifdef FULL_IO_PROBE
-	for(dev->base_addr=0x200; dev->base_addr<0x400; dev->base_addr+=8)
-		if (ni52_probe1(dev, dev->base_addr) == 0)
-			return 0;
-#endif
+	SET_MODULE_OWNER(dev);
 
+	if (io > 0x1ff)	{	/* Check a single specified location. */
+		err = ni52_probe1(dev, io);
+	} else if (io > 0) {		/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (port = ports; *port && ni52_probe1(dev, *port) ; port++)
+			;
+		if (*port)
+			goto got_it;
+#ifdef FULL_IO_PROBE
+		for (io = 0x200; io < 0x400 && ni52_probe1(dev, io); io += 8)
+			;
+		if (io < 0x400)
+			goto got_it;
 #endif
-
-	dev->base_addr = base_addr;
-	return -ENODEV;
+		err = -ENODEV;
+	}
+	if (err)
+		goto out;
+got_it:
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, NI52_TOTAL_SIZE);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init ni52_probe1(struct net_device *dev,int ioaddr)
 {
 	int i, size, retval;
 
+	dev->base_addr = ioaddr;
+	dev->irq = irq;
+	dev->mem_start = memstart;
+	dev->mem_end = memend;
+
 	if (!request_region(ioaddr, NI52_TOTAL_SIZE, dev->name))
 		return -EBUSY;
 
@@ -416,7 +442,7 @@
 		goto out;
 	}
 
-	printk("%s: NI5210 found at %#3lx, ",dev->name,dev->base_addr);
+	printk(KERN_INFO "%s: NI5210 found at %#3lx, ",dev->name,dev->base_addr);
 
 	/*
 	 * check (or search) IO-Memory, 8K and 16K
@@ -469,13 +495,6 @@
 	dev->mem_end = dev->mem_start + size; /* set mem_end showed by 'ifconfig' */
 #endif
 
-	dev->priv = (void *) kmalloc(sizeof(struct priv),GFP_KERNEL);
-	if(dev->priv == NULL) {
-		printk("%s: Ooops .. can't allocate private driver memory.\n",dev->name);
-		retval = -ENOMEM;
-		goto out;
-	}
-																	/* warning: we don't free it on errors */
 	memset((char *) dev->priv,0,sizeof(struct priv));
 
 	((struct priv *) (dev->priv))->memtop = isa_bus_to_virt(dev->mem_start) + size;
@@ -503,8 +522,6 @@
 		if(!dev->irq)
 		{
 			printk("?autoirq, Failed to detect IRQ line!\n");
-			kfree(dev->priv);
-			dev->priv = NULL;
 			retval = -EAGAIN;
 			goto out;
 		}
@@ -526,8 +543,6 @@
 
 	dev->if_port 		= 0;
 
-	ether_setup(dev);
-
 	return 0;
 out:
 	release_region(ioaddr, NI52_TOTAL_SIZE);
@@ -1295,13 +1310,7 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_ni52;
-
-/* set: io,irq,memstart,memend or set it when calling insmod */
-static int irq=9;
-static int io=0x300;
-static long memstart;	/* e.g 0xd0000 */
-static long memend;	/* e.g 0xd4000 */
+static struct net_device *dev_ni52;
 
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -1318,22 +1327,17 @@
 		printk("ni52: Autoprobing not allowed for modules.\nni52: Set symbols 'io' 'irq' 'memstart' and 'memend'\n");
 		return -ENODEV;
 	}
-	dev_ni52.init = ni52_probe;
-	dev_ni52.irq = irq;
-	dev_ni52.base_addr = io;
-	dev_ni52.mem_end = memend;
-	dev_ni52.mem_start = memstart;
-	if (register_netdev(&dev_ni52) != 0)
-		return -EIO;
+	dev_ni52 = ni52_probe(-1);
+	if (IS_ERR(dev_ni52))
+		return PTR_ERR(dev_ni52);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	release_region(dev_ni52.base_addr, NI52_TOTAL_SIZE);
-	unregister_netdev(&dev_ni52);
-	kfree(dev_ni52.priv);
-	dev_ni52.priv = NULL;
+	unregister_netdev(dev_ni52);
+	release_region(dev_ni52->base_addr, NI52_TOTAL_SIZE);
+	free_netdev(dev_ni52);
 }
 #endif /* MODULE */
 

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="04-ni5010.patch"
Content-Disposition: attachment;
 filename="04-ni5010.patch"
Content-Transfer-Encoding: 7bit

from viro NE16-ni5010
	* switched ni5010 to dynamic allocation
	* ni5010: embedded ->priv
	* ni5010: fixed clobbering ->irq
	* ni5010: fixed IO before request_region()
Additional:
	* add free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:44:30 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:44:30 2003
@@ -68,7 +68,7 @@
 extern int es_probe(struct net_device *);
 extern int lne390_probe(struct net_device *);
 extern int e2100_probe(struct net_device *);
-extern int ni5010_probe(struct net_device *);
+extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
@@ -280,13 +280,13 @@
 #ifdef CONFIG_SK_G16
 	{SK_init, 0},
 #endif
-#ifdef CONFIG_NI5010
-	{ni5010_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_NI5010
+	{ni5010_probe, 0},
+#endif
 #ifdef CONFIG_NI52
 	{ni52_probe, 0},
 #endif
diff -Nru a/drivers/net/ni5010.c b/drivers/net/ni5010.c
--- a/drivers/net/ni5010.c	Mon Sep 29 09:44:30 2003
+++ b/drivers/net/ni5010.c	Mon Sep 29 09:44:30 2003
@@ -82,7 +82,7 @@
 
 #ifndef FULL_IODETECT
 /* A zero-terminated list of I/O addresses to be probed. */
-static unsigned int ni5010_portlist[] __initdata =
+static unsigned int ports[] __initdata =
 	{ 0x300, 0x320, 0x340, 0x360, 0x380, 0x3a0, 0 };
 #endif
 
@@ -95,13 +95,11 @@
 struct ni5010_local {
 	struct net_device_stats stats;
 	int o_pkt_size;
-	int i_pkt_size;
 	spinlock_t lock;
 };
 
 /* Index to functions, as function prototypes. */
 
-extern int 	ni5010_probe(struct net_device *dev);
 static int	ni5010_probe1(struct net_device *dev, int ioaddr);
 static int	ni5010_open(struct net_device *dev);
 static int	ni5010_send_packet(struct sk_buff *skb, struct net_device *dev);
@@ -120,38 +118,58 @@
 static void	dump_packet(void *buf, int len);
 static void 	ni5010_show_registers(struct net_device *dev);
 
+static int io;
+static int irq;
 
-int __init ni5010_probe(struct net_device *dev)
+struct net_device * __init ni5010_probe(int unit)
 {
+	struct net_device *dev = alloc_etherdev(sizeof(struct ni5010_local));
 	int *port;
-	int base_addr = dev->base_addr;
+	int err = 0;
 
-        PRINTK2((KERN_DEBUG "%s: Entering ni5010_probe\n", dev->name));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		irq = dev->irq;
+	}
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return ni5010_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
+	PRINTK2((KERN_DEBUG "%s: Entering ni5010_probe\n", dev->name));
 
+	SET_MODULE_OWNER(dev);
+
+	if (io > 0x1ff)	{	/* Check a single specified location. */
+		err = ni5010_probe1(dev, io);
+	} else if (io != 0) {	/* Don't probe at all. */
+		err = -ENXIO;
+	} else {
 #ifdef FULL_IODETECT
-		for (int ioaddr=0x200; ioaddr<0x400; ioaddr+=0x20) {
-			if (check_region(ioaddr, NI5010_IO_EXTENT))
-				continue;
-			if (ni5010_probe1(dev, ioaddr) == 0)
-				return 0;
-		}
+		for (io=0x200; io<0x400 && ni5010_probe1(dev, io) ; io+=0x20)
+			;
+		if (io == 0x400)
+			err = -ENODEV;
+
 #else
-		for (port = ni5010_portlist; *port; port++) {
-			int ioaddr = *port;
-			if (check_region(ioaddr, NI5010_IO_EXTENT))
-				continue;
-			if (ni5010_probe1(dev, ioaddr) == 0)
-				return 0;
-		}
+		for (port = ports; *port && ni5010_probe1(dev, *port); port++)
+			;
+		if (!*port)
+			err = -ENODEV;
 #endif	/* FULL_IODETECT */
-	return -ENODEV;
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, NI5010_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static inline int rd_port(int ioaddr)
@@ -188,9 +206,17 @@
 static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
 {
 	static unsigned version_printed;
+	struct ni5010_local *lp;
 	int i;
 	unsigned int data = 0;
 	int boguscount = 40;
+	int err = -ENODEV;
+
+	dev->base_addr = ioaddr;
+	dev->irq = irq;
+
+	if (!request_region(ioaddr, NI5010_IO_EXTENT, boardname))
+		return -EBUSY;
 
 	/*
 	 * This is no "official" probe method, I've rather tested which
@@ -205,36 +231,40 @@
 	 *
 	 *   - Andreas
 	 */
-	
+
  	PRINTK2((KERN_DEBUG "%s: entering ni5010_probe1(%#3x)\n", 
  		dev->name, ioaddr));
 
-	if (inb(ioaddr+0) == 0xff) return -ENODEV;
+	if (inb(ioaddr+0) == 0xff)
+		goto out;
 
 	while ( (rd_port(ioaddr) & rd_port(ioaddr) & rd_port(ioaddr) &
 		 rd_port(ioaddr) & rd_port(ioaddr) & rd_port(ioaddr)) != 0xff)
 	{
-		if (boguscount-- == 0) return -ENODEV;
+		if (boguscount-- == 0)
+			goto out;
 	}
 
 	PRINTK2((KERN_DEBUG "%s: I/O #1 passed!\n", dev->name));
 
 	for (i=0; i<32; i++)
 		if ( (data = rd_port(ioaddr)) != 0xff) break;
-	if (data==0xff) return -ENODEV;
+	if (data==0xff)
+		goto out;
 
 	PRINTK2((KERN_DEBUG "%s: I/O #2 passed!\n", dev->name));
 
-	if (		(data == SA_ADDR0) &&
-	     (rd_port(ioaddr) == SA_ADDR1) &&
-	     (rd_port(ioaddr) == SA_ADDR2) ) {
-		for (i=0; i<4; i++) rd_port(ioaddr);
-		if ( (rd_port(ioaddr) != NI5010_MAGICVAL1) ||
-		     (rd_port(ioaddr) != NI5010_MAGICVAL2) ) {
-		     	return -ENODEV;
-		}
-	} else return -ENODEV;
-	
+	if ((data != SA_ADDR0) || (rd_port(ioaddr) != SA_ADDR1) ||
+	    (rd_port(ioaddr) != SA_ADDR2))
+		goto out;
+
+	for (i=0; i<4; i++)
+		rd_port(ioaddr);
+
+	if ( (rd_port(ioaddr) != NI5010_MAGICVAL1) ||
+	     (rd_port(ioaddr) != NI5010_MAGICVAL2) )
+		goto out;
+
 	PRINTK2((KERN_DEBUG "%s: I/O #3 passed!\n", dev->name));
 
 	if (NI5010_DEBUG && version_printed++ == 0)
@@ -267,8 +297,9 @@
 		PRINTK2((KERN_DEBUG "%s: I/O #6 passed!\n", dev->name));
 
 		if (dev->irq == 0) {
+			err = -EAGAIN;
 			printk(KERN_WARNING "%s: no IRQ found!\n", dev->name);
-			return -EAGAIN;
+			goto out;
 		}
 		PRINTK2((KERN_DEBUG "%s: I/O #7 passed!\n", dev->name));
 	} else if (dev->irq == 2) {
@@ -278,19 +309,9 @@
 	PRINTK2((KERN_DEBUG "%s: I/O #9 passed!\n", dev->name));
 
 	/* DMA is not supported (yet?), so no use detecting it */
+	lp = (struct ni5010_local*)dev->priv;
 
-	if (dev->priv == NULL) {
-		struct ni5010_local* lp;
-
-		dev->priv = kmalloc(sizeof(struct ni5010_local), GFP_KERNEL|GFP_DMA);
-		if (dev->priv == NULL) {
-			printk(KERN_WARNING "%s: Failed to allocate private memory\n", dev->name);
-			return -ENOMEM;
-		}
-
-		lp = (struct ni5010_local*)dev->priv;
-		spin_lock_init(&lp->lock);
-	}
+	spin_lock_init(&lp->lock);
 
 	PRINTK2((KERN_DEBUG "%s: I/O #10 passed!\n", dev->name));
 
@@ -315,9 +336,6 @@
 	}
         printk("// bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
 	memset(dev->priv, 0, sizeof(struct ni5010_local));
-
-	/* Grab the region so we can find another board if autoIRQ fails. */
-	request_region(ioaddr, NI5010_IO_EXTENT, boardname);
 	
 	dev->open		= ni5010_open;
 	dev->stop		= ni5010_close;
@@ -327,9 +345,6 @@
 	dev->tx_timeout		= ni5010_timeout;
 	dev->watchdog_timeo	= HZ/20;
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-	
 	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */
 
 	/* Shut up the ni5010 */
@@ -345,6 +360,9 @@
 	printk(KERN_INFO "Join the NI5010 driver development team!\n");
 	printk(KERN_INFO "Mail to a.mohr@mailto.de or jvbest@wi.leidenuniv.nl\n");
 	return 0;
+out:
+	release_region(dev->base_addr, NI5010_IO_EXTENT);
+	return err;
 }
 
 /* 
@@ -513,6 +531,7 @@
 	int ioaddr = dev->base_addr;
 	unsigned char rcv_stat;
 	struct sk_buff *skb;
+	int i_pkt_size;
 	
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_rx()\n", dev->name)); 
 	
@@ -532,17 +551,17 @@
 	
         outb(0xff, EDLC_RCLR);  /* Clear the interrupt */
 
-	lp->i_pkt_size = inw(IE_RCNT);
-	if (lp->i_pkt_size > ETH_FRAME_LEN || lp->i_pkt_size < 10 ) {
+	i_pkt_size = inw(IE_RCNT);
+	if (i_pkt_size > ETH_FRAME_LEN || i_pkt_size < 10 ) {
 		PRINTK((KERN_DEBUG "%s: Packet size error, packet size = %#4.4x\n", 
-			dev->name, lp->i_pkt_size));
+			dev->name, i_pkt_size));
 		lp->stats.rx_errors++;
 		lp->stats.rx_length_errors++;
 		return;
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(lp->i_pkt_size + 3);
+	skb = dev_alloc_skb(i_pkt_size + 3);
 	if (skb == NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
 		lp->stats.rx_dropped++;
@@ -555,7 +574,7 @@
 	/* Read packet into buffer */
         outb(MM_MUX, IE_MMODE); /* Rcv buffer to system bus */
 	outw(0, IE_GP);	/* Seek to beginning of packet */
-	insb(IE_RBUF, skb_put(skb, lp->i_pkt_size), lp->i_pkt_size); 
+	insb(IE_RBUF, skb_put(skb, i_pkt_size), i_pkt_size); 
 	
 	if (NI5010_DEBUG >= 4) 
 		dump_packet(skb->data, skb->len); 
@@ -564,10 +583,10 @@
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += lp->i_pkt_size;
+	lp->stats.rx_bytes += i_pkt_size;
 
 	PRINTK2((KERN_DEBUG "%s: Received packet, size=%#4.4x\n", 
-		dev->name, lp->i_pkt_size));
+		dev->name, i_pkt_size));
 	
 }
 
@@ -697,10 +716,10 @@
 	
 	if (NI5010_DEBUG > 3) dump_packet(buf, length);
 
-        buf_offs = NI5010_BUFSIZE - length - pad;
-        lp->o_pkt_size = length + pad;
+	buf_offs = NI5010_BUFSIZE - length - pad;
 
 	spin_lock_irqsave(&lp->lock, flags);
+	lp->o_pkt_size = length + pad;
 
 	outb(0, EDLC_RMASK);	/* Mask all receive interrupts */
 	outb(0, IE_MMODE);	/* Put Xmit buffer on system bus */
@@ -745,9 +764,7 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_ni5010;
-static int io;
-static int irq;
+static struct net_device *dev_ni5010;
 
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -756,8 +773,6 @@
 
 int init_module(void)
 {
-	int result;
-	
 	PRINTK2((KERN_DEBUG "%s: entering init_module\n", boardname));
 	/*
 	if(io <= 0 || irq == 0){
@@ -771,29 +786,18 @@
 	}
 
 	PRINTK2((KERN_DEBUG "%s: init_module irq=%#2x, io=%#3x\n", boardname, irq, io));
-        dev_ni5010.irq=irq;
-        dev_ni5010.base_addr=io;
-	dev_ni5010.init=ni5010_probe;
-        if ((result = register_netdev(&dev_ni5010)) != 0) {
-        	PRINTK((KERN_WARNING "%s: register_netdev returned %d.\n", 
-        		boardname, result));
-                return -EIO;
-        }
+	dev_ni5010 = ni5010_probe(-1);
+	if (IS_ERR(dev_ni5010))
+		return PTR_ERR(dev_ni5010);
         return 0;
 }
 
-void
-cleanup_module(void)
+void cleanup_module(void)
 {
 	PRINTK2((KERN_DEBUG "%s: entering cleanup_module\n", boardname));
-
-        unregister_netdev(&dev_ni5010);
-
-	release_region(dev_ni5010.base_addr, NI5010_IO_EXTENT);
-	if (dev_ni5010.priv != NULL){
-	        kfree(dev_ni5010.priv);
-	        dev_ni5010.priv = NULL;
-	}
+	unregister_netdev(dev_ni5010);
+	release_region(dev_ni5010->base_addr, NI5010_IO_EXTENT);
+	free_netdev(dev_ni5010);
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="05-sk16.patch"
Content-Disposition: attachment;
 filename="05-sk16.patch"
Content-Transfer-Encoding: 7bit

from viro NE17-sk16
	* switched sk_g16 to dynamic allocation
	* sk_g16: embedded ->priv
	* sk_g16: fixed buggy check for signature (|| instead of &&, somebody
	  forgot to replace it when inverting the test).
	* sk_g16: fixed use after kfree()
	* sk_g16: fixed init_etherdev() race
Additional:
	* add free_netdev
	

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:44:51 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:44:51 2003
@@ -72,7 +72,7 @@
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
-extern int SK_init(struct net_device *);
+extern struct net_device *SK_init(int unit);
 extern int seeq8005_probe(struct net_device *);
 extern int smc_init( struct net_device * );
 extern int atarilance_probe(struct net_device *);
@@ -277,13 +277,13 @@
 #ifdef CONFIG_ELPLUS		/* 3c505 */
 	{elplus_probe, 0},
 #endif
-#ifdef CONFIG_SK_G16
-	{SK_init, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_SK_G16
+	{SK_init, 0},
+#endif
 #ifdef CONFIG_NI5010
 	{ni5010_probe, 0},
 #endif
diff -Nru a/drivers/net/sk_g16.c b/drivers/net/sk_g16.c
--- a/drivers/net/sk_g16.c	Mon Sep 29 09:44:51 2003
+++ b/drivers/net/sk_g16.c	Mon Sep 29 09:44:51 2003
@@ -457,8 +457,6 @@
 /* static variables */
 
 static SK_RAM *board;  /* pointer to our memory mapped board components */
-static struct net_device *SK_dev;
-unsigned long SK_ioaddr;
 static spinlock_t SK_lock = SPIN_LOCK_UNLOCKED;
 
 /* Macros */
@@ -472,7 +470,6 @@
  * See for short explanation of each function its definitions header.
  */
 
-int          SK_init(struct net_device *dev);
 static int   SK_probe(struct net_device *dev, short ioaddr);
 
 static void  SK_timeout(struct net_device *dev);
@@ -530,84 +527,71 @@
  *     YY/MM/DD  uid  Description
 -*/
 
+static int io;	/* 0 == probe */
+
 /* 
  * Check for a network adaptor of this type, and return '0' if one exists.
  * If dev->base_addr == 0, probe all likely locations.
  * If dev->base_addr == 1, always return failure.
  */
 
-int __init SK_init(struct net_device *dev)
+struct net_device * __init SK_init(int unit)
 {
-	int ioaddr;			   /* I/O port address used for POS regs */
 	int *port, ports[] = SK_IO_PORTS;  /* SK_G16 supported ports */
 	static unsigned version_printed;
+	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
+	int err = -ENODEV;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	/* get preconfigured base_addr from dev which is done in Space.c */
-	int base_addr = dev->base_addr; 
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+	}
 
 	if (version_printed++ == 0)
 	        PRINTK(("%s: %s", SK_NAME, rcsid));
 
-	if (base_addr > 0x0ff)        /* Check a single specified address */
-	{
-	    int rc = -ENODEV;
-
-	    ioaddr = base_addr;
+	if (io > 0xff) {        /* Check a single specified address */
+		err = -EBUSY;
+		/* Check if on specified address is a SK_G16 */
+		if (request_region(io, ETHERCARD_TOTAL_SIZE, "sk_g16")) {
+			err = SK_probe(dev, io);
+			if (!err)
+				goto got_it;
+			release_region(io, ETHERCARD_TOTAL_SIZE);
+		}
+	} else if (io > 0) {       /* Don't probe at all */
+		err = -ENXIO;
+	} else {
+		/* Autoprobe base_addr */
+		for (port = &ports[0]; *port; port++) {
+			io = *port;
+
+			/* Check if I/O Port region is used by another board */
+			if (!request_region(io, ETHERCARD_TOTAL_SIZE, "sk_g16"))
+				continue;       /* Try next Port address */
+
+			/* Check if at ioaddr is a SK_G16 */
+			if (SK_probe(dev, io) == 0)
+				goto got_it;
 
-	    /* Check if on specified address is a SK_G16 */
-	    if (!request_region(ioaddr, ETHERCARD_TOTAL_SIZE, "sk_g16"))
-	    	return -EBUSY;
-
-	    if ( (inb(SK_POS0) == SK_IDLOW) ||
-		 (inb(SK_POS1) == SK_IDHIGH) )  
-	    {
-		rc = SK_probe(dev, ioaddr);
-	    }
-
-	    if (rc)
-	        release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-	    return rc;
+			release_region(io, ETHERCARD_TOTAL_SIZE);
+		}
 	}
-	else if (base_addr > 0)       /* Don't probe at all */
-	{
-		return -ENXIO;
+err_out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+
+got_it:
+	err = register_netdev(dev);
+	if (err) {
+		release_region(dev->base_addr, ETHERCARD_TOTAL_SIZE);
+		goto err_out;
 	}
-
-	/* Autoprobe base_addr */
-
-	for (port = &ports[0]; *port; port++) 
-	{
-	    ioaddr = *port;           /* we need ioaddr for accessing POS regs */
-
-	    /* Check if I/O Port region is used by another board */
-
-	    if (!request_region(ioaddr, ETHERCARD_TOTAL_SIZE, "sk_g16"))
-	    {
-		continue;             /* Try next Port address */
-	    }
-
-	    /* Check if at ioaddr is a SK_G16 */
-
-	    if ( !(inb(SK_POS0) == SK_IDLOW) ||
-		 !(inb(SK_POS1) == SK_IDHIGH) )
-	    {
-	        release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-		continue;             /* Try next Port address */
-	    }
-
-	    dev->base_addr = ioaddr;  /* Set I/O Port Address */
-
-	    if (SK_probe(dev, ioaddr) == 0)  
-	    {
-		return 0; /* Card found and initialized */
-	    }
-
-	    release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-	}
-
-	dev->base_addr = base_addr;   /* Write back original base_addr */
-
-	return -ENODEV;                /* Failed to find or init driver */
+	return dev;
 
 } /* End of SK_init */
 
@@ -620,54 +604,22 @@
 
 
 #ifdef MODULE
-static int io;	/* 0 == probe */
-
 static int __init SK_init_module (void)
 {
-	int rc;
-	
-	SK_dev = init_etherdev (NULL, 0);
-	if (!SK_dev)
-		return -ENOMEM;
-	
-	SK_dev->base_addr = io;
-
-	rc = SK_init (SK_dev);
-	if (rc) {
-		unregister_netdev (SK_dev);
-		kfree (SK_dev);
-		SK_dev = NULL;
-	}
-	
-	return rc;
+ 	SK_dev = SK_init(-1);
+ 	return IS_ERR(SK_dev) ? PTR_ERR(SK_dev) : 0;
 }
-#endif /* MODULE */
-
 
 static void __exit SK_cleanup_module (void)
 {
-	if (SK_dev) {
-		if (SK_dev->priv) {
-			kfree(SK_dev->priv);
-			SK_dev->priv = NULL;
-		}
-		unregister_netdev(SK_dev);
-		free_netdev(SK_dev);
-		SK_dev = NULL;
-	}
-	if (SK_ioaddr) {
-		release_region(SK_ioaddr, ETHERCARD_TOTAL_SIZE);
-		SK_ioaddr = 0;
-	}
-		
+ 	unregister_netdev(SK_dev);
+ 	release_region(SK_dev->base_addr, ETHERCARD_TOTAL_SIZE);
+ 	free_netdev(SK_dev);
 }
 
-
-#ifdef MODULE
 module_init(SK_init_module);
-#endif
 module_exit(SK_cleanup_module);
-
+#endif
 
 
 /*-
@@ -695,7 +647,11 @@
     int sk_addr_flag = 0;   /* SK ADDR correct? 1 - no, 0 - yes */
     unsigned int rom_addr;  /* used to store RAM address used for POS_ADDR */
 
-    struct priv *p;         /* SK_G16 private structure */
+    struct priv *p = dev->priv;         /* SK_G16 private structure */
+
+    if (inb(SK_POS0) != SK_IDLOW || inb(SK_POS1) != SK_IDHIGH)
+	return -ENODEV;
+    dev->base_addr = ioaddr;
 
     if (SK_ADDR & 0x3fff || SK_ADDR < 0xa0000)
     {
@@ -837,12 +793,6 @@
 	    dev->dev_addr[4],
 	    dev->dev_addr[5]);
 
-    /* Allocate memory for private structure */
-    p = dev->priv = (void *) kmalloc(sizeof(struct priv), GFP_KERNEL);
-    if (p == NULL) {
-	   printk("%s: ERROR - no memory for driver data!\n", dev->name);
-	   return -ENOMEM;
-    }
     memset((char *) dev->priv, 0, sizeof(struct priv)); /* clear memory */
 
     /* Assign our Device Driver functions */
@@ -856,10 +806,6 @@
     dev->watchdog_timeo		= HZ/7;
 
 
-    /* Set the generic fields of the device structure */
-
-    ether_setup(dev);
-    
     dev->flags &= ~IFF_MULTICAST;
 
     /* Initialize private structure */
@@ -884,12 +830,7 @@
     SK_print_pos(dev, "End of SK_probe");
     SK_print_ram(dev);
 #endif 
-
-    SK_dev = dev;
-    SK_ioaddr = ioaddr;
-
     return 0;                            /* Initialization done */
-
 } /* End of SK_probe() */
 
 
@@ -1280,7 +1221,7 @@
 
 	memcpy_toio((tmdp->u.buffer & 0x00ffffff), skb->data, skb->len);
 	if (len != skb->len)
-		memcpy_toio((tmdp->u.buffer & 0x00ffffff) + sb->len, pad, len-skb->len);
+		memcpy_toio((tmdp->u.buffer & 0x00ffffff) + skb->len, pad, len-skb->len);
 
 	writew(-len, &tmdp->blen);            /* set length to transmit */
 

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="06-3c505.patch"
Content-Disposition: attachment;
 filename="06-3c505.patch"
Content-Transfer-Encoding: 7bit

from viro NE18-3c505
	* switched 3c505 to dynamic allocation
	* 3c505: embedded ->priv
	* 3c505: fixed use of uninitialized variable
	* 3c505: fixed resource leaks on failure exits
Additional:
	* add free_netdev

diff -Nru a/drivers/net/3c505.c b/drivers/net/3c505.c
--- a/drivers/net/3c505.c	Mon Sep 29 09:45:12 2003
+++ b/drivers/net/3c505.c	Mon Sep 29 09:45:12 2003
@@ -1293,42 +1293,6 @@
 	}
 }
 
-/******************************************************
- *
- * initialise Etherlink Plus board
- *
- ******************************************************/
-
-static inline void elp_init(struct net_device *dev)
-{
-	elp_device *adapter = dev->priv;
-
-	/*
-	 * set ptrs to various functions
-	 */
-	dev->open = elp_open;				/* local */
-	dev->stop = elp_close;				/* local */
-	dev->get_stats = elp_get_stats;			/* local */
-	dev->hard_start_xmit = elp_start_xmit;		/* local */
-	dev->tx_timeout = elp_timeout;			/* local */
-	dev->watchdog_timeo = 10*HZ;
-	dev->set_multicast_list = elp_set_mc_list;	/* local */
-	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
-
-	/* Setup the generic properties */
-	ether_setup(dev);
-
-	/*
-	 * setup ptr to adapter specific information
-	 */
-	memset(&(adapter->stats), 0, sizeof(struct net_device_stats));
-
-	/*
-	 * memory information
-	 */
-	dev->mem_start = dev->mem_end = 0;
-}
-
 /************************************************************
  *
  * A couple of tests to see if there's 3C505 or not
@@ -1442,12 +1406,13 @@
  * work at all if it was in a weird state).
  */
 
-int __init elplus_probe(struct net_device *dev)
+static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter;
+	elp_device *adapter = dev->priv;
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
+	int err = -ENODEV;
 
 	SET_MODULE_OWNER(dev);
 
@@ -1456,17 +1421,8 @@
 	 */
 
 	dev->base_addr = elp_autodetect(dev);
-	if (!(dev->base_addr))
-		return -ENODEV;
-
-	/*
-	 * setup ptr to adapter specific information
-	 */
-	adapter = (elp_device *) (dev->priv = kmalloc(sizeof(elp_device), GFP_KERNEL));
-	if (adapter == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", dev->name);
+	if (!dev->base_addr)
 		return -ENODEV;
-	}
 
 	adapter->send_pcb_semaphore = 0;
 
@@ -1544,8 +1500,7 @@
 		outb_control(adapter->hcr_val & ~(FLSH | ATTN), dev);
 	}
 	printk(KERN_ERR "%s: failed to initialise 3c505\n", dev->name);
-	release_region(dev->base_addr, ELP_IO_EXTENT);
-	return -ENODEV;
+	goto out;
 
       okay:
 	if (dev->irq) {		/* Is there a preset IRQ? */
@@ -1560,14 +1515,14 @@
 	case 0:
 		printk(KERN_ERR "%s: IRQ probe failed: check 3c505 jumpers.\n",
 		       dev->name);
-		return -ENODEV;
+		goto out;
 	case 1:
 	case 6:
 	case 8:
 	case 13:
 		printk(KERN_ERR "%s: Impossible IRQ %d reported by probe_irq_off().\n",
 		       dev->name, dev->irq);
-		return -ENODEV;
+		       goto out;
 	}
 	/*
 	 *  Now we have the IRQ number so we can disable the interrupts from
@@ -1636,16 +1591,48 @@
 		printk(KERN_ERR "%s: adapter configuration failed\n", dev->name);
 	}
 
-	/*
-	 * initialise the device
-	 */
-	elp_init(dev);
+	dev->open = elp_open;				/* local */
+	dev->stop = elp_close;				/* local */
+	dev->get_stats = elp_get_stats;			/* local */
+	dev->hard_start_xmit = elp_start_xmit;		/* local */
+	dev->tx_timeout = elp_timeout;			/* local */
+	dev->watchdog_timeo = 10*HZ;
+	dev->set_multicast_list = elp_set_mc_list;	/* local */
+	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
+
+	memset(&(adapter->stats), 0, sizeof(struct net_device_stats));
+	dev->mem_start = dev->mem_end = 0;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out;
 
 	return 0;
+out:
+	release_region(dev->base_addr, ELP_IO_EXTENT);
+	return err;
+}
+
+struct net_device * __init elplus_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(elp_device));
+	int err;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = elplus_setup(dev);
+	if (err) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+	return dev;
 }
 
 #ifdef MODULE
-static struct net_device dev_3c505[ELP_MAX_CARDS];
+static struct net_device *dev_3c505[ELP_MAX_CARDS];
 static int io[ELP_MAX_CARDS];
 static int irq[ELP_MAX_CARDS];
 static int dma[ELP_MAX_CARDS];
@@ -1661,10 +1648,12 @@
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < ELP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_3c505[this_dev];
+		struct net_device *dev = alloc_etherdev(sizeof(elp_device));
+		if (!dev)
+			break;
+
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->init = elplus_probe;
 		if (dma[this_dev]) {
 			dev->dma = dma[this_dev];
 		} else {
@@ -1672,16 +1661,22 @@
 			printk(KERN_WARNING "3c505.c: warning, using default DMA channel,\n");
 		}
 		if (io[this_dev] == 0) {
-			if (this_dev) break;
+			if (this_dev) {
+				free_netdev(dev);
+				break;
+			}
 			printk(KERN_NOTICE "3c505.c: module autoprobe not recommended, give io=xx.\n");
 		}
-		if (register_netdev(dev) != 0) {
+		if (elplus_setup(dev) != 0) {
 			printk(KERN_WARNING "3c505.c: Failed to register card at 0x%x.\n", io[this_dev]);
-			if (found != 0) return 0;
-			return -ENXIO;
+			free_netdev(dev);
+			break;
 		}
+		dev_3c505[this_dev] = dev;
 		found++;
 	}
+	if (!found)
+		return -ENODEV;
 	return 0;
 }
 
@@ -1690,12 +1685,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < ELP_MAX_CARDS; this_dev++) {
-		struct net_device *dev = &dev_3c505[this_dev];
-		if (dev->priv != NULL) {
+		struct net_device *dev = dev_3c505[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
 			release_region(dev->base_addr, ELP_IO_EXTENT);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:45:12 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:45:12 2003
@@ -63,7 +63,7 @@
 extern int el16_probe(struct net_device *);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
-extern int elplus_probe(struct net_device *);
+extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
 extern int lne390_probe(struct net_device *);
@@ -274,13 +274,13 @@
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
-#ifdef CONFIG_ELPLUS		/* 3c505 */
-	{elplus_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ELPLUS		/* 3c505 */
+	{elplus_probe, 0},
+#endif
 #ifdef CONFIG_SK_G16
 	{SK_init, 0},
 #endif

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="07-3c507.patch"
Content-Disposition: attachment;
 filename="07-3c507.patch"
Content-Transfer-Encoding: 7bit

from viro NE19-3c507
	* switched 3c507 to dynamic allocation
	* 3c507: embedded ->priv
	* 3c507: fixed clobbering on autoprobe
	* NB: 3c507.c buggers port 0x100 without claiming it.  Most likely it
	  should be doing request_region() there.
Additional:
	* fix port probing loop and correct error return on no device
	* add free_netdev

diff -Nru a/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	Mon Sep 29 09:45:32 2003
+++ b/drivers/net/3c507.c	Mon Sep 29 09:45:32 2003
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
@@ -309,23 +306,49 @@
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
+	int err = -ENODEV;
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
+	if (io > 0x1ff) 	/* Check a single specified location. */
+		err = el16_probe1(dev, io);
+	else if (io != 0)
+		err = -ENXIO;		/* Don't probe at all. */
+	else {
+			for (port = ports; *port; port++) {
+					err = el16_probe1(dev, io);
+					if (!err)
+						break;
+			}
+	}
 
-	return -ENODEV;
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
@@ -383,8 +406,8 @@
 		printk(" %02x", dev->dev_addr[i]);
 	}
 
-	if ((dev->mem_start & 0xf) > 0)
-		net_debug = dev->mem_start & 7;
+	if (mem_start)
+		net_debug = mem_start & 7;
 
 #ifdef MEM_BASE
 	dev->mem_start = MEM_BASE;
@@ -416,27 +439,18 @@
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
@@ -899,8 +913,7 @@
 };
 
 #ifdef MODULE
-static struct net_device dev_3c507;
-static int io = 0x300;
+static struct net_device *dev_3c507;
 static int irq;
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
@@ -911,26 +924,18 @@
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
--- a/drivers/net/Space.c	Mon Sep 29 09:45:32 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:45:32 2003
@@ -60,7 +60,7 @@
 extern int el1_probe(struct net_device *);
 extern int wavelan_probe(struct net_device *);
 extern int arlan_probe(struct net_device *);
-extern int el16_probe(struct net_device *);
+extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
 extern struct net_device *elplus_probe(int unit);
@@ -271,13 +271,13 @@
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

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="08-arlan.patch"
Content-Disposition: attachment;
 filename="08-arlan.patch"
Content-Transfer-Encoding: 7bit

Completed work started by NE20-arlan-TODO
    * allocate network device
    * probe only once and do it right
    * handle probes > MAX_ARLAN
    * use request_mem_region
    * proper error unwinds.


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:18:17 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:18:17 2003
@@ -59,7 +59,7 @@
 extern int ewrk3_probe(struct net_device *);
 extern int el1_probe(struct net_device *);
 extern int wavelan_probe(struct net_device *);
-extern int arlan_probe(struct net_device *);
+extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
@@ -268,13 +268,13 @@
 #ifdef CONFIG_WAVELAN		/* WaveLAN */
 	{wavelan_probe, 0},
 #endif
-#ifdef CONFIG_ARLAN		/* Aironet */
-	{arlan_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ARLAN		/* Aironet */
+	{arlan_probe, 0},
+#endif
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Mon Sep 29 10:18:17 2003
+++ b/drivers/net/wireless/arlan-main.c	Mon Sep 29 10:18:17 2003
@@ -20,9 +20,7 @@
 static int SID = SIDUNKNOWN;
 static int radioNodeId = radioNodeIdUNKNOWN;
 static char encryptionKey[12] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
-static int mem = memUNKNOWN;
 int arlan_debug = debugUNKNOWN;
-static int numDevices = numDevicesUNKNOWN;
 static int spreadingCode = spreadingCodeUNKNOWN;
 static int channelNumber = channelNumberUNKNOWN;
 static int channelSet = channelSetUNKNOWN;
@@ -46,9 +44,7 @@
 
 MODULE_PARM(irq, "i");
 MODULE_PARM(mem, "i");
-MODULE_PARM(probe, "i");
 MODULE_PARM(arlan_debug, "i");
-MODULE_PARM(numDevices, "i");
 MODULE_PARM(testMemory, "i");
 MODULE_PARM(spreadingCode, "i");
 MODULE_PARM(channelNumber, "i");
@@ -70,9 +66,7 @@
 MODULE_PARM(arlan_EEPROM_bad, "i");
 MODULE_PARM_DESC(irq, "(unused)");
 MODULE_PARM_DESC(mem, "Arlan memory address for single device probing");
-MODULE_PARM_DESC(probe, "Arlan probe at initialization (0-1)");
 MODULE_PARM_DESC(arlan_debug, "Arlan debug enable (0-1)");
-MODULE_PARM_DESC(numDevices, "Number of Arlan devices; ignored if >1");
 MODULE_PARM_DESC(testMemory, "(unused)");
 MODULE_PARM_DESC(mdebug, "Arlan multicast debugging (0-1)");
 MODULE_PARM_DESC(retries, "Arlan maximum packet retransmisions");
@@ -89,7 +83,6 @@
 struct arlan_conf_stru arlan_conf[MAX_ARLANS];
 static int arlans_found;
 
-static  int 	arlan_probe_here(struct net_device *dev, int ioaddr);
 static  int 	arlan_open(struct net_device *dev);
 static  int 	arlan_tx(struct sk_buff *skb, struct net_device *dev);
 static  irqreturn_t arlan_interrupt(int irq, void *dev_id, struct pt_regs *regs);
@@ -976,24 +969,27 @@
  * probes on the ISA bus. A good device probes avoids doing writes, and
  * verifies that the correct device exists and functions.
  */
-
-static int __init arlan_check_fingerprint(int memaddr)
+#define ARLAN_SHMEM_SIZE	0x2000
+static int __init arlan_check_fingerprint(unsigned long memaddr)
 {
-	static char probeText[] = "TELESYSTEM SLW INC.    ARLAN \0";
-	char tempBuf[49];
+	static const char probeText[] = "TELESYSTEM SLW INC.    ARLAN \0";
 	volatile struct arlan_shmem *arlan = (struct arlan_shmem *) memaddr;
+	unsigned long paddr = virt_to_phys((void *) memaddr);
+	char tempBuf[49];
 
 	ARLAN_DEBUG_ENTRY("arlan_check_fingerprint");
-	if (check_mem_region(virt_to_phys((void *)memaddr),0x2000 )){
-		// printk(KERN_WARNING "arlan: memory region %lx excluded from probing \n",virt_to_phys((void*)memaddr));
+
+	if (!request_mem_region(paddr, ARLAN_SHMEM_SIZE, "arlan")) {
+		// printk(KERN_WARNING "arlan: memory region %lx excluded from probing \n",paddr);
 		return -ENODEV;
 	}
+
 	memcpy_fromio(tempBuf, arlan->textRegion, 29);
 	tempBuf[30] = 0;
 
 	/* check for card at this address */
 	if (0 != strncmp(tempBuf, probeText, 29)){
-// not 		release_mem_region(virt_to_phys((void*)memaddr),0x2000);
+ 		release_mem_region(paddr, ARLAN_SHMEM_SIZE);
 		return -ENODEV;
 	}
 
@@ -1001,51 +997,8 @@
 	ARLAN_DEBUG_EXIT("arlan_check_fingerprint");
 
 	return 0;
-
-
-}
-
-static int __init arlan_probe_everywhere(struct net_device *dev)
-{
-	int m;
-	int probed = 0;
-	int found = 0;
-
-	SET_MODULE_OWNER(dev);
-
-	ARLAN_DEBUG_ENTRY("arlan_probe_everywhere");
-	if (mem != 0 && numDevices == 1)	/* Check a single specified location. */
-	{
-		if (arlan_probe_here(dev, (int) phys_to_virt(  mem) ) == 0)
-			return 0;
-		else
-			return -ENODEV;
-	}
-	for (m = (int)phys_to_virt(lastFoundAt) + 0x2000; m <= (int)phys_to_virt(0xDE000); m += 0x2000)
-	{
-		if (arlan_probe_here(dev, m) == 0)
-		{
-			found++;
-			lastFoundAt = (int)virt_to_phys((void*)m);
-			break;
-		}
-		probed++;
-	}
-	if (found == 0 && probed != 0)
-	{
-		if (lastFoundAt == 0xbe000)
-			printk(KERN_ERR "arlan: No Arlan devices found \n");
-		return -ENODEV;
-	}
-	else
-		return 0;
-
-	ARLAN_DEBUG_EXIT("arlan_probe_everywhere");
-
-	return -ENODEV;
 }
 
-
 static int arlan_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct arlan_private *priv = dev->priv;
@@ -1086,47 +1039,14 @@
 
 
 
-
-static int __init
-	      arlan_allocate_device(int num, struct net_device *devs)
+static void __init arlan_setup_device(struct net_device *dev, int num)
 {
+	struct arlan_private *ap = dev->priv;
 
-	struct net_device *dev;
-	struct arlan_private *ap;
+	ARLAN_DEBUG_ENTRY("arlan_setup_device");
 
-	ARLAN_DEBUG_ENTRY("arlan_allocate_device");
+	ap->conf = (struct arlan_shmem *)(ap+1);
 
-	if (!devs) {
-		dev = init_etherdev(0, sizeof(struct arlan_private) + sizeof(struct arlan_shmem));
-		if (!dev) {
-			printk(KERN_ERR "ARLAN: init_etherdev failed\n");
-			return 0;
-		}
-		ap = dev->priv;
-		ap->conf = dev->priv + sizeof(struct arlan_private);
-		ap->init_etherdev_alloc = 1;
-	} else {
-		dev = devs;
-		dev->priv = kmalloc(sizeof(struct arlan_private) + sizeof(struct arlan_shmem), GFP_KERNEL);
-		if (!dev->priv) {
-			printk(KERN_ERR "ARLAN: kmalloc of dev->priv failed\n");
-			return 0;
-		}
-		ap = dev->priv;
-		ap->conf = dev->priv + sizeof(struct arlan_private);
-		memset(ap, 0, sizeof(*ap));
-	}
-
-	/* Fill in the 'dev' fields. */
-	dev->base_addr = 0;
-	dev->mem_start = 0;
-	dev->mem_end = 0;
-	dev->mtu = 1500;
-	dev->flags = 0;		/* IFF_BROADCAST & IFF_MULTICAST & IFF_PROMISC; */
-	dev->irq = 0;
-	dev->dma = 0;
-	dev->tx_queue_len = tx_queue_len;
-	ether_setup(dev);
 	dev->tx_queue_len = tx_queue_len;
 	dev->open = arlan_open;
 	dev->stop = arlan_close;
@@ -1146,34 +1066,29 @@
 	ap->Conf->rx_tweak1 = 30;
 	ap->Conf->rx_tweak2 = 0;
 
-	ARLAN_DEBUG_EXIT("arlan_allocate_device");
-	return (int) dev;
+	ARLAN_DEBUG_EXIT("arlan_setup_device");
 }
 
-
-static int __init arlan_probe_here(struct net_device *dev, int memaddr)
+static int __init arlan_probe_here(struct net_device *dev, 
+				   unsigned long memaddr)
 {
-	volatile struct arlan_shmem *arlan;
+	struct arlan_private *ap = dev->priv;
 
 	ARLAN_DEBUG_ENTRY("arlan_probe_here");
 
 	if (arlan_check_fingerprint(memaddr))
 		return -ENODEV;
 
-	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, (int) virt_to_phys((void*)memaddr));
-
-	if (!arlan_allocate_device(arlans_found, dev))
-		return -1;
-
-	((struct arlan_private *) dev->priv)->card = (struct arlan_shmem *) memaddr;
-	arlan = (void *) memaddr;
+	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, 
+	       (int) virt_to_phys((void*)memaddr));
 
+	ap->card = (void *) memaddr;
 	dev->mem_start = memaddr;
-	dev->mem_end = memaddr + 0x1FFF;
+	dev->mem_end = memaddr + ARLAN_SHMEM_SIZE-1;
 
 	if (dev->irq < 2)
 	{
-		READSHM(dev->irq, arlan->irqLevel, u_char);
+		READSHM(dev->irq, ap->card->irqLevel, u_char);
 	} else if (dev->irq == 2)
 		dev->irq = 9;
 
@@ -1184,8 +1099,6 @@
 }
 
 
-
-
 static int arlan_open(struct net_device *dev)
 {
 	struct arlan_private *priv = dev->priv;
@@ -1194,12 +1107,6 @@
 
 	ARLAN_DEBUG_ENTRY("arlan_open");
 
-	if (dev->mem_start == 0)
-		ret = arlan_probe_everywhere(dev);
-	if (ret != 0)
-		return ret;
-
-	arlan = priv->card;
 	ret = request_irq(dev->irq, &arlan_interrupt, 0, dev->name, dev);
 	if (ret)
 	{
@@ -1769,14 +1676,9 @@
 {
 	struct arlan_private *priv = dev->priv;
 
-	if (!priv)
-	{
-		printk(KERN_CRIT "arlan: No Device priv \n");
-		return 0;
-	}
 	ARLAN_DEBUG_ENTRY("arlan_close");
 
-	del_timer(&priv->timer);
+	del_timer_sync(&priv->timer);
 
 	arlan_command(dev, ARLAN_COMMAND_POWERDOWN);
 
@@ -1868,39 +1770,68 @@
 }
 
 
-int __init arlan_probe(struct net_device *dev)
+struct net_device * __init arlan_probe(int unit)
 {
-	printk("Arlan driver %s\n", arlan_version);
+	struct net_device *dev;
+	int m;
 
-	if (arlan_probe_everywhere(dev))
-		return -ENODEV;
+	ARLAN_DEBUG_ENTRY("arlan_probe");
 
-	arlans_found++;
-	return 0;
-}
+	if (arlans_found == MAX_ARLANS)
+		return ERR_PTR(-ENODEV);
 
-#ifdef  MODULE
+	/* 
+	 * Reserve space for local data and a copy of the shared memory
+	 * that is used by the /proc interface.
+	 */
+	dev = alloc_etherdev(sizeof(struct arlan_private)
+			     + sizeof(struct arlan_shmem));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-static int probe = probeUNKNOWN;
+	SET_MODULE_OWNER(dev);
 
-static int __init arlan_find_devices(void)
-{
-	int m;
-	int found = 0;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		
+		if (dev->mem_start) {
+			if (arlan_probe_here(dev, dev->mem_start) == 0)
+				goto found;
+			goto not_found;
+		}
+			
+	}
 
-	ARLAN_DEBUG_ENTRY("arlan_find_devices");
-	if (mem != 0 && numDevices == 1)	/* Check a single specified location. */
-		return 1;
-	for (m =(int) phys_to_virt(0xc0000); m <=(int) phys_to_virt(0xDE000); m += 0x2000)
+
+	for (m = (int)phys_to_virt(lastFoundAt) + ARLAN_SHMEM_SIZE; 
+	     m <= (int)phys_to_virt(0xDE000); 
+	     m += ARLAN_SHMEM_SIZE)
 	{
-		if (arlan_check_fingerprint(m) == 0)
-			found++;
+		if (arlan_probe_here(dev, m) == 0)
+		{
+			lastFoundAt = (int)virt_to_phys((void*)m);
+			goto found;
+		}
+	}
+
+	if (lastFoundAt == 0xbe000)
+		printk(KERN_ERR "arlan: No Arlan devices found \n");
+
+ not_found:
+	free_netdev(dev);
+	return ERR_PTR(-ENODEV);
+
+ found:
+	arlan_setup_device(dev, arlans_found++);
+	if (arlans_found == 1) {
+		printk(KERN_INFO "Arlan driver %s\n", arlan_version);
 	}
-	ARLAN_DEBUG_EXIT("arlan_find_devices");
 
-	return found;
+	return dev;
 }
 
+#ifdef  MODULE
 int init_module(void)
 {
 	int i = 0;
@@ -1910,21 +1841,15 @@
 	if (channelSet != channelSetUNKNOWN || channelNumber != channelNumberUNKNOWN || systemId != systemIdUNKNOWN)
 		return -EINVAL;
 
-	numDevices = arlan_find_devices();
-	if (numDevices == 0)
-		return -ENODEV;
-
-	for (i = 0; i < numDevices && i < MAX_ARLANS; i++)
+	for (i = 0; i < MAX_ARLANS; i++)
 	{
-		if (!arlan_allocate_device(i, NULL))
-			return -ENOMEM;
-
-		if (arlan_device[i] == NULL)
-			return -ENOMEM;
+		dev = arlan_probe(i);
 
-		if (probe)
-			arlan_probe_everywhere(arlan_device[i]);
-//		arlan_command(arlan_device[i], ARLAN_COMMAND_POWERDOWN );
+		if (IS_ERR(dev)) {
+			if (arlans_found == 0)
+				break;
+			return PTR_ERR(dev);
+		}
 	}
 	init_arlan_proc();
 	printk(KERN_INFO "Arlan driver %s\n", arlan_version);
@@ -1936,7 +1861,7 @@
 void cleanup_module(void)
 {
 	int i = 0;
-	struct arlan_private *ap;
+	struct net_device *dev;
 
 	ARLAN_DEBUG_ENTRY("cleanup_module");
 
@@ -1947,22 +1872,19 @@
 
 	for (i = 0; i < MAX_ARLANS; i++)
 	{
-		if (arlan_device[i])
+		dev = arlan_device[i];
+		if (dev)
 		{
-			arlan_command(arlan_device[i], ARLAN_COMMAND_POWERDOWN );
+			arlan_command(dev, ARLAN_COMMAND_POWERDOWN );
 
-//			release_mem_region(virt_to_phys(arlan_device[i]->mem_start), 0x2000 );
-			unregister_netdev(arlan_device[i]);
-			ap = arlan_device[i]->priv;
-			if (ap->init_etherdev_alloc) {
-				free_netdev(arlan_device[i]);
-				arlan_device[i] = NULL;
-			} else {
-				kfree(ap);
-				ap = NULL;
-			}
+			unregister_netdev(dev);
+			release_mem_region(virt_to_phys(dev->mem_start), 
+					   ARLAN_MEM_SIZE);
+			free_netdev(dev);
+			arlan_device[i] = NULL;
 		}
 	}
+
 	ARLAN_DEBUG_EXIT("cleanup_module");
 }
 

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="09-wavelan.patch"
Content-Disposition: attachment;
 filename="09-wavelan.patch"
Content-Transfer-Encoding: 7bit

>From viro NE21-wavelan
	* switched wavelan to dynamic allocation
	* wavelan: embedded ->priv
	* wavelan: fixed clobbering on autoprobe
	* wavelan: fixed IO before request_region()
	* wavelan: fixed resource leaks on failure exits
	* wavelan: fixed order of freeing bugs
Additional:
	* use free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:19:07 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:19:07 2003
@@ -58,7 +58,7 @@
 extern int i82596_probe(struct net_device *);
 extern int ewrk3_probe(struct net_device *);
 extern int el1_probe(struct net_device *);
-extern int wavelan_probe(struct net_device *);
+extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
@@ -265,13 +265,13 @@
 #ifdef CONFIG_EL1		/* 3c501 */
 	{el1_probe, 0},
 #endif
-#ifdef CONFIG_WAVELAN		/* WaveLAN */
-	{wavelan_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_WAVELAN		/* WaveLAN */
+	{wavelan_probe, 0},
+#endif
 #ifdef CONFIG_ARLAN		/* Aironet */
 	{arlan_probe, 0},
 #endif
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Mon Sep 29 10:19:07 2003
+++ b/drivers/net/wireless/arlan.h	Mon Sep 29 10:19:07 2003
@@ -57,12 +57,8 @@
  
 #define SIDUNKNOWN -1
 #define radioNodeIdUNKNOWN -1
-#define encryptionKeyUNKNOWN '\0';
 #define irqUNKNOWN 0
-#define memUNKNOWN 0
 #define debugUNKNOWN 0
-#define probeUNKNOWN 1
-#define numDevicesUNKNOWN 1
 #define testMemoryUNKNOWN 1
 #define spreadingCodeUNKNOWN 0
 #define channelNumberUNKNOWN 0
@@ -81,6 +77,8 @@
 #else
 	#define ARLAN_DEBUG(a,b) 
 #endif
+
+#define ARLAN_SHMEM_SIZE	0x2000
 
 struct arlan_shmem
 {
diff -Nru a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
--- a/drivers/net/wireless/wavelan.c	Mon Sep 29 10:19:07 2003
+++ b/drivers/net/wireless/wavelan.c	Mon Sep 29 10:19:07 2003
@@ -4091,12 +4091,24 @@
  * device structure
  * (called by wavelan_probe() and via init_module()).
  */
-static int __init wavelan_config(device * dev)
+static int __init wavelan_config(device *dev, unsigned short ioaddr)
 {
-	unsigned long ioaddr = dev->base_addr;
 	u8 irq_mask;
 	int irq;
 	net_local *lp;
+	mac_addr mac;
+	int err;
+
+	if (!request_region(ioaddr, sizeof(ha_t), "wavelan"))
+		return -EADDRINUSE;
+
+	err = wv_check_ioaddr(ioaddr, mac);
+	if (err)
+		goto out;
+
+	memcpy(dev->dev_addr, mac, 6);
+
+	dev->base_addr = ioaddr;
 
 #ifdef DEBUG_CALLBACK_TRACE
 	printk(KERN_DEBUG "%s: ->wavelan_config(dev=0x%x, ioaddr=0x%lx)\n",
@@ -4136,25 +4148,18 @@
 		       "%s: wavelan_config(): could not wavelan_map_irq(%d).\n",
 		       dev->name, irq_mask);
 #endif
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto out;
 	}
 
 	dev->irq = irq;
 
-	if (!request_region(ioaddr, sizeof(ha_t), "wavelan"))
-		return -EBUSY;
-
 	dev->mem_start = 0x0000;
 	dev->mem_end = 0x0000;
 	dev->if_port = 0;
 
 	/* Initialize device structures */
-	dev->priv = kmalloc(sizeof(net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		release_region(ioaddr, sizeof(ha_t));
-		return -ENOMEM;
-	}
-	memset(dev->priv, 0x00, sizeof(net_local));
+	memset(dev->priv, 0, sizeof(net_local));
 	lp = (net_local *) dev->priv;
 
 	/* Back link to the device structure. */
@@ -4172,12 +4177,6 @@
 	/* Init spinlock */
 	spin_lock_init(&lp->spinlock);
 
-	/*
-	 * Fill in the fields of the device structure
-	 * with generic Ethernet values.
-	 */
-	ether_setup(dev);
-
 	SET_MODULE_OWNER(dev);
 	dev->open = wavelan_open;
 	dev->stop = wavelan_close;
@@ -4204,6 +4203,9 @@
 	printk(KERN_DEBUG "%s: <-wavelan_config()\n", dev->name);
 #endif
 	return 0;
+out:
+	release_region(ioaddr, sizeof(ha_t));
+	return err;
 }
 
 /*------------------------------------------------------------------*/
@@ -4214,19 +4216,13 @@
  * We follow the example in drivers/net/ne.c.
  * (called in "Space.c")
  */
-int __init wavelan_probe(device * dev)
+struct net_device * __init wavelan_probe(int unit)
 {
+	struct net_device *dev;
 	short base_addr;
-	mac_addr mac;		/* MAC address (check existence of WaveLAN) */
+	int def_irq;
 	int i;
-	int r;
-
-#ifdef DEBUG_CALLBACK_TRACE
-	printk(KERN_DEBUG
-	       "%s: ->wavelan_probe(dev=0x%x (base_addr=0x%x))\n",
-	       dev->name, (unsigned int) dev,
-	       (unsigned int) dev->base_addr);
-#endif
+	int r = 0;
 
 #ifdef	STRUCT_CHECK
 	if (wv_struct_check() != (char *) NULL) {
@@ -4237,8 +4233,20 @@
 	}
 #endif				/* STRUCT_CHECK */
 
-	/* Check the value of the command line parameter for base address. */
+	dev = alloc_etherdev(sizeof(net_local));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
 	base_addr = dev->base_addr;
+	def_irq = dev->irq;
+
+#ifdef DEBUG_CALLBACK_TRACE
+	printk(KERN_DEBUG
+	       "%s: ->wavelan_probe(dev=%p (base_addr=0x%x))\n",
+	       dev->name, dev, (unsigned int) dev->base_addr);
+#endif
 
 	/* Don't probe at all. */
 	if (base_addr < 0) {
@@ -4247,16 +4255,9 @@
 		       "%s: wavelan_probe(): invalid base address\n",
 		       dev->name);
 #endif
-		return -ENXIO;
-	}
-
-	/* Check a single specified location. */
-	if (base_addr > 0x100) {
-		/* Check if there is something at this base address */
-		if ((r = wv_check_ioaddr(base_addr, mac)) == 0) {
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-			r = wavelan_config(dev);
-		}
+		r = -ENXIO;
+	} else if (base_addr > 0x100) { /* Check a single specified location. */
+		r = wavelan_config(dev, base_addr);
 #ifdef DEBUG_CONFIG_INFO
 		if (r != 0)
 			printk(KERN_DEBUG
@@ -4267,35 +4268,33 @@
 #ifdef DEBUG_CALLBACK_TRACE
 		printk(KERN_DEBUG "%s: <-wavelan_probe()\n", dev->name);
 #endif
-		return r;
-	}
-
-	/* Scan all possible addresses of the WaveLAN hardware. */
-	for (i = 0; i < NELS(iobase); i++) {
-		/* Check whether there is something at this base address. */
-		if (wv_check_ioaddr(iobase[i], mac) == 0) {
-			dev->base_addr = iobase[i];	/* Copy base address. */
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-			if (wavelan_config(dev) == 0) {
+	} else { /* Scan all possible addresses of the WaveLAN hardware. */
+		for (i = 0; i < NELS(iobase); i++) {
+			dev->irq = def_irq;
+			if (wavelan_config(dev, iobase[i]) == 0) {
 #ifdef DEBUG_CALLBACK_TRACE
 				printk(KERN_DEBUG
 				       "%s: <-wavelan_probe()\n",
 				       dev->name);
 #endif
-				return 0;
+				break;
 			}
 		}
+		if (i == NELS(iobase))
+			r = -ENODEV;
 	}
-
-	/* We may have touched base_addr.  Another driver may not like it. */
-	dev->base_addr = base_addr;
-
-#ifdef DEBUG_CONFIG_INFO
-	printk(KERN_DEBUG "%s: wavelan_probe(): no device found\n",
-	       dev->name);
-#endif
-
-	return -ENODEV;
+	if (r) 
+		goto out;
+	r = register_netdev(dev);
+	if (r)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, sizeof(ha_t));
+	wavelan_list = wavelan_list->next;
+out:
+	kfree(dev);
+	return ERR_PTR(r);
 }
 
 /****************************** MODULE ******************************/
@@ -4311,7 +4310,6 @@
  */
 int init_module(void)
 {
-	mac_addr mac;		/* MAC address (check WaveLAN existence) */
 	int ret = -EIO;		/* Return error if no cards found */
 	int i;
 
@@ -4337,38 +4335,28 @@
 	/* Loop on all possible base addresses. */
 	i = -1;
 	while ((io[++i] != 0) && (i < NELS(io))) {
-		/* Check if there is something at this base address. */
-		if (wv_check_ioaddr(io[i], mac) == 0) {
-			device *dev;
+		struct net_device *dev = alloc_etherdev(sizeof(net_local));
+		if (!dev)
+			break;
+		memcpy(dev->name, name[i], IFNAMSIZ);	/* Copy name */
+		dev->base_addr = io[i];
+		dev->irq = irq[i];
 
-			/* Create device and set basic arguments. */
-			dev =
-			    kmalloc(sizeof(struct net_device), GFP_KERNEL);
-			if (dev == NULL) {
-				ret = -ENOMEM;
-				break;
-			}
-			memset(dev, 0x00, sizeof(struct net_device));
-			memcpy(dev->name, name[i], IFNAMSIZ);	/* Copy name */
-			dev->base_addr = io[i];
-			dev->irq = irq[i];
-			dev->init = &wavelan_config;
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-
-			/* Try to create the device. */
+		/* Check if there is something at this base address. */
+		if (wavelan_config(dev, io[i]) == 0) {
 			if (register_netdev(dev) != 0) {
-				/* Deallocate everything. */
-				/* Note: if dev->priv is mallocated, there is no way to fail. */
-				kfree(dev);
+				release_region(dev->base_addr, sizeof(ha_t));
+				wavelan_list = wavelan_list->next;
 			} else {
-				/* If at least one device OK, we do not fail */
 				ret = 0;
+				continue;
 			}
-		}		/* if there is something at the address */
-	}			/* Loop on all addresses. */
+		}
+		kfree(dev);
+	}
 
 #ifdef DEBUG_CONFIG_ERROR
-	if (wavelan_list == (net_local *) NULL)
+	if (!wavelan_list)
 		printk(KERN_WARNING
 		       "WaveLAN init_module(): no device found\n");
 #endif
@@ -4390,7 +4378,7 @@
 #endif
 
 	/* Loop on all devices and release them. */
-	while (wavelan_list != (net_local *) NULL) {
+	while (wavelan_list) {
 		device *dev = wavelan_list->dev;
 
 #ifdef DEBUG_CONFIG_INFO
@@ -4398,18 +4386,11 @@
 		       "%s: cleanup_module(): removing device at 0x%x\n",
 		       dev->name, (unsigned int) dev);
 #endif
-
-		/* Release the ioport region. */
-		release_region(dev->base_addr, sizeof(ha_t));
-
-		/* Definitely remove the device. */
 		unregister_netdev(dev);
 
-		/* Unlink the device. */
+		release_region(dev->base_addr, sizeof(ha_t));
 		wavelan_list = wavelan_list->next;
 
-		/* Free pieces. */
-		kfree(dev->priv);
 		free_netdev(dev);
 	}
 
diff -Nru a/drivers/net/wireless/wavelan.p.h b/drivers/net/wireless/wavelan.p.h
--- a/drivers/net/wireless/wavelan.p.h	Mon Sep 29 10:19:07 2003
+++ b/drivers/net/wireless/wavelan.p.h	Mon Sep 29 10:19:07 2003
@@ -656,9 +656,8 @@
 static int
 	wavelan_open(device *),		/* Open the device. */
 	wavelan_close(device *),	/* Close the device. */
-	wavelan_config(device *);	/* Configure one device. */
-extern int
-	wavelan_probe(device *);	/* See Space.c. */
+	wavelan_config(device *, unsigned short);/* Configure one device. */
+extern struct net_device *wavelan_probe(int unit);	/* See Space.c. */
 
 /**************************** VARIABLES ****************************/
 

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="10-3c501.patch"
Content-Disposition: attachment;
 filename="10-3c501.patch"
Content-Transfer-Encoding: 7bit

>From viro NE22-3c501
	* switched 3c501 to dynamic allocation
	* 3c501: embedded ->priv
	* 3c501: fixed clobbering on autoprobe
	* 3c501: fixed resource leaks on failure exits
Additional:
	* probe correctly when no device present
	* fix loop forever bug in probing
	* free_netdev

diff -Nru a/drivers/net/3c501.c b/drivers/net/3c501.c
--- a/drivers/net/3c501.c	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/3c501.c	Mon Sep 29 10:27:33 2003
@@ -136,17 +136,14 @@
 
 #include "3c501.h"
 
-/* A zero-terminated list of I/O addresses to be probed.
-   The 3c501 can be at many locations, but here are the popular ones. */
-static unsigned int netcard_portlist[] __initdata = { 
-	0x280, 0x300, 0
-};
-
-
 /*
  *	The boilerplate probe code.
  */
 
+static int io=0x280;
+static int irq=5;
+static int mem_start;
+
 /**
  * el1_probe:		-	probe for a 3c501
  * @dev: The device structure passed in to probe. 
@@ -160,23 +157,47 @@
  * probe and failing to find anything.
  */
  
-int __init el1_probe(struct net_device *dev)
+struct net_device * __init el1_probe(int unit)
 {
-	int i;
-	int base_addr = dev->base_addr;
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	static unsigned ports[] = { 0x280, 0x300, 0};
+	unsigned *port;
+	int err = 0;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+		irq = dev->irq;
+		mem_start = dev->mem_start & 7;
+	}
 
 	SET_MODULE_OWNER(dev);
 
-	if (base_addr > 0x1ff)	/* Check a single specified location. */
-		return el1_probe1(dev, base_addr);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; netcard_portlist[i]; i++)
-		if (el1_probe1(dev, netcard_portlist[i]) == 0)
-			return 0;
-
-	return -ENODEV;
+	if (io > 0x1ff) {	/* Check a single specified location. */
+		err = el1_probe1(dev, io);
+	} else if (io != 0) {
+		err = -ENXIO;		/* Don't probe at all. */
+	} else {
+		for (port = ports; *ports && el1_probe1(dev, *ports); port++)
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
+	release_region(dev->base_addr, EL1_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /**
@@ -240,6 +261,8 @@
 	 *	high.
 	 */
 
+	dev->irq = irq;
+
 	if (dev->irq < 2)
 	{
 		unsigned long irq_mask;
@@ -267,8 +290,8 @@
 	dev->base_addr = ioaddr;
 	memcpy(dev->dev_addr, station_addr, ETH_ALEN);
 
-	if (dev->mem_start & 0xf)
-		el_debug = dev->mem_start & 0x7;
+	if (mem_start & 0xf)
+		el_debug = mem_start & 0x7;
 	if (autoirq)
 		dev->irq = autoirq;
 
@@ -282,17 +305,7 @@
 	if (el_debug)
 		printk(KERN_DEBUG "%s", version);
 
-	/*
-	 *	Initialize the device structure.
-	 */
-
-	dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		release_region(ioaddr, EL1_IO_EXTENT);
-		return -ENOMEM;
-	}
 	memset(dev->priv, 0, sizeof(struct net_local));
-
 	lp=dev->priv;
 	spin_lock_init(&lp->lock);
 	
@@ -308,13 +321,6 @@
 	dev->get_stats = &el1_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-
-	/*
-	 *	Setup the generic properties
-	 */
-
-	ether_setup(dev);
-
 	return 0;
 }
 
@@ -884,14 +890,8 @@
 
 #ifdef MODULE
 
-static struct net_device dev_3c501 = {
-	.init		= el1_probe,
-	.base_addr	= 0x280,
-	.irq		= 5,
-};
+static struct net_device *dev_3c501;
 
-static int io=0x280;
-static int irq=5;
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
 MODULE_PARM_DESC(io, "EtherLink I/O base address");
@@ -911,10 +911,9 @@
  
 int init_module(void)
 {
-	dev_3c501.irq=irq;
-	dev_3c501.base_addr=io;
-	if (register_netdev(&dev_3c501) != 0)
-		return -EIO;
+	dev_3c501 = el1_probe(-1);
+	if (IS_ERR(dev_3c501))
+		return PTR_ERR(dev_3c501);
 	return 0;
 }
 
@@ -927,19 +926,10 @@
  
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_3c501);
-
-	/*
-	 *	Free up the private structure, or leak memory :-)
-	 */
-
-	kfree(dev_3c501.priv);
-	dev_3c501.priv = NULL;	/* gets re-allocated by el1_probe1 */
-
-	/*
-	 *	If we don't do this, we can't re-insmod it later.
-	 */
-	release_region(dev_3c501.base_addr, EL1_IO_EXTENT);
+	struct net_device *dev = dev_3c501;
+	unregister_netdev(dev);
+	release_region(dev->base_addr, EL1_IO_EXTENT);
+	free_netdev(dev);
 }
 
 #endif /* MODULE */
diff -Nru a/drivers/net/3c501.h b/drivers/net/3c501.h
--- a/drivers/net/3c501.h	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/3c501.h	Mon Sep 29 10:27:33 2003
@@ -3,7 +3,6 @@
  *	Index to functions.
  */
 
-int el1_probe(struct net_device *dev);
 static int  el1_probe1(struct net_device *dev, int ioaddr);
 static int  el_open(struct net_device *dev);
 static void el_timeout(struct net_device *dev);
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:27:33 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:27:33 2003
@@ -57,7 +57,7 @@
 extern int eth16i_probe(struct net_device *);
 extern int i82596_probe(struct net_device *);
 extern int ewrk3_probe(struct net_device *);
-extern int el1_probe(struct net_device *);
+extern struct net_device *el1_probe(int unit);
 extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
@@ -262,13 +262,13 @@
 #if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_EL1		/* 3c501 */
-	{el1_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EL1		/* 3c501 */
+	{el1_probe, 0},
+#endif
 #ifdef CONFIG_WAVELAN		/* WaveLAN */
 	{wavelan_probe, 0},
 #endif

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0
Content-Type: text/x-diff;
 name="11-82596.patch"
Content-Disposition: attachment;
 filename="11-82596.patch"
Content-Transfer-Encoding: 7bit

>From viro NE23-82596
	* switched 82596 to dynamic allocation
	* 82596: fixed resource leaks on failure exits
Additional:
	* free_netdev

diff -Nru a/drivers/net/82596.c b/drivers/net/82596.c
--- a/drivers/net/82596.c	Mon Sep 29 10:27:00 2003
+++ b/drivers/net/82596.c	Mon Sep 29 10:27:00 2003
@@ -1129,21 +1129,40 @@
 	printk(" %02X%02X, %s\n", add[12], add[13], str);
 }
 
-int __init i82596_probe(struct net_device *dev)
+static int io = 0x300;
+static int irq = 10;
+
+struct net_device * __init i82596_probe(int unit)
 {
+	struct net_device *dev;
 	int i;
 	struct i596_private *lp;
 	char eth_addr[8];
 	static int probed;
+	int err;
 
 	if (probed)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
 	probed++;
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	} else {
+		dev->base_addr = io;
+		dev->irq = irq;
+	}
+
 #ifdef ENABLE_MVME16x_NET
 	if (MACH_IS_MVME16x) {
 		if (mvme16x_config & MVME16x_CONFIG_NO_ETHERNET) {
 			printk(KERN_NOTICE "Ethernet probe disabled - chip not present\n");
-			return -ENODEV;
+			err = -ENODEV;
+			goto out;
 		}
 		memcpy(eth_addr, (void *) 0xfffc1f2c, 6);	/* YUCK! Get addr from NOVRAM */
 		dev->base_addr = MVME_I596_BASE;
@@ -1174,7 +1193,8 @@
 
 		if (!request_region(ioaddr, I596_TOTAL_SIZE, dev->name)) {
 			printk(KERN_ERR "82596: IO address 0x%04x in use\n", ioaddr);
-			return -EBUSY;
+			err = -EBUSY;
+			goto out;
 		}
 
 		for (i = 0; i < 8; i++) {
@@ -1190,8 +1210,8 @@
 
 		if ((checksum % 0x100) || 
 		    (memcmp(eth_addr, "\x00\x00\x49", 3) != 0)) {
-			release_region(ioaddr, I596_TOTAL_SIZE);
-			return -ENODEV;
+			err = -ENODEV;
+			goto out1;
 		}
 
 		dev->base_addr = ioaddr;
@@ -1200,13 +1220,10 @@
 #endif
 	dev->mem_start = (int)__get_free_pages(GFP_ATOMIC, 0);
 	if (!dev->mem_start) {
-#ifdef ENABLE_APRICOT
-		release_region(dev->base_addr, I596_TOTAL_SIZE);
-#endif
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out1;
 	}
 
-	ether_setup(dev);
 	DEB(DEB_PROBE,printk(KERN_INFO "%s: 82596 at %#3lx,", dev->name, dev->base_addr));
 
 	for (i = 0; i < 6; i++)
@@ -1244,7 +1261,26 @@
 	lp->scb.rfd = I596_NULL;
 	lp->lock = SPIN_LOCK_UNLOCKED;
 
-	return 0;
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	return dev;
+out2:
+#ifdef __mc68000__
+	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
+	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
+	 */
+	kernel_set_cachemode((void *)(dev->mem_start), 4096,
+			IOMAP_FULL_CACHING);
+#endif
+	free_page ((u32)(dev->mem_start));
+out1:
+#ifdef ENABLE_APRICOT
+	release_region(dev->base_addr, I596_TOTAL_SIZE);
+#endif
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static irqreturn_t i596_interrupt(int irq, void *dev_id, struct pt_regs *regs)
@@ -1532,11 +1568,9 @@
 }
 
 #ifdef MODULE
-static struct net_device dev_82596 = { .init = i82596_probe };
+static struct net_device *dev_82596;
 
 #ifdef ENABLE_APRICOT
-static int io = 0x300;
-static int irq = 10;
 MODULE_PARM(irq, "i");
 MODULE_PARM_DESC(irq, "Apricot IRQ number");
 #endif
@@ -1547,34 +1581,31 @@
 
 int init_module(void)
 {
-#ifdef ENABLE_APRICOT
-	dev_82596.base_addr = io;
-	dev_82596.irq = irq;
-#endif
 	if (debug >= 0)
 		i596_debug = debug;
-	if (register_netdev(&dev_82596) != 0)
-		return -EIO;
+	dev_82596 = i82596_probe(-1);
+	if (IS_ERR(dev_82596))
+		return PTR_ERR(dev_82596);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_82596);
+	unregister_netdev(dev_82596);
 #ifdef __mc68000__
 	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
 	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
 	 */
 
-	kernel_set_cachemode((void *)(dev_82596.mem_start), 4096,
+	kernel_set_cachemode((void *)(dev_82596->mem_start), 4096,
 			IOMAP_FULL_CACHING);
 #endif
-	free_page ((u32)(dev_82596.mem_start));
-	dev_82596.priv = NULL;
+	free_page ((u32)(dev_82596->mem_start));
 #ifdef ENABLE_APRICOT
 	/* If we don't do this, we can't re-insmod it later. */
-	release_region(dev_82596.base_addr, I596_TOTAL_SIZE);
+	release_region(dev_82596->base_addr, I596_TOTAL_SIZE);
 #endif
+	free_netdev(dev);
 }
 
 #endif				/* MODULE */
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 10:27:00 2003
+++ b/drivers/net/Space.c	Mon Sep 29 10:27:00 2003
@@ -55,7 +55,7 @@
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
 extern int eth16i_probe(struct net_device *);
-extern int i82596_probe(struct net_device *);
+extern struct net_device *i82596_probe(int unit);
 extern int ewrk3_probe(struct net_device *);
 extern struct net_device *el1_probe(int unit);
 extern struct net_device *wavelan_probe(int unit);
@@ -259,13 +259,13 @@
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
-#if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
-	{i82596_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
+	{i82596_probe, 0},
+#endif
 #ifdef CONFIG_EL1		/* 3c501 */
 	{el1_probe, 0},
 #endif

--Multipart_Mon__29_Sep_2003_15:11:50_-0700_084b9cc0--
