From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (04/12) Probe2 -- ni52
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAT30154@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
 
