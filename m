From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Thu, 22 May 2003 08:25:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522082506.A11926@lst.de>
References: <20030522075711.A11759@lst.de> <20030521.230211.15256464.davem@redhat.com> <20030522081002.A11850@lst.de> <20030521.232109.26287528.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030521.232109.26287528.davem@redhat.com>; from davem@redhat.com on Wed, May 21, 2003 at 11:21:09PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2003 at 11:21:09PM -0700, David S. Miller wrote:
>    From: Christoph Hellwig <hch@lst.de>
>    Date: Thu, 22 May 2003 08:10:03 +0200
> 
>    On Wed, May 21, 2003 at 11:02:11PM -0700, David S. Miller wrote:
>    > com90xx init was being done via arcnet init.
>    > Which in turn was being done in Space.c
>    
>    it was done in setup.c
>    
> Yuck, it's in pci_probes[]. :(
> 
> Ok, please resend your patch I'll apply it.


--- 1.11/drivers/net/setup.c	Tue May 20 08:57:38 2003
+++ edited/drivers/net/setup.c	Tue May 20 23:21:48 2003
@@ -11,7 +11,6 @@
 
 extern int dmascc_init(void);
 
-extern int arcnet_init(void); 
 extern int scc_enet_init(void); 
 extern int fec_enet_init(void); 
 extern int sdla_setup(void); 
@@ -41,9 +40,6 @@
 #endif	
 #if defined(CONFIG_SDLA)
 	{sdla_c_setup, 0},
-#endif
-#if defined(CONFIG_ARCNET)
-	{arcnet_init, 0},
 #endif
 #if defined(CONFIG_SCC_ENET)
         {scc_enet_init, 0},
--- 1.3/drivers/net/arcnet/arc-rawmode.c	Thu Apr  4 11:39:23 2002
+++ edited/drivers/net/arcnet/arc-rawmode.c	Wed May 21 00:06:42 2003
@@ -53,10 +53,12 @@
 };
 
 
-void arcnet_raw_init(void)
+static int __init arcnet_raw_init(void)
 {
 	int count;
 
+	printk(VERSION);
+
 	for (count = 0; count < 256; count++)
 		if (arc_proto_map[count] == arc_proto_default)
 			arc_proto_map[count] = &rawmode_proto;
@@ -66,26 +68,18 @@
 		arc_bcast_proto = &rawmode_proto;
 
 	arc_proto_default = &rawmode_proto;
-}
-
-
-#ifdef MODULE
-
-int __init init_module(void)
-{
-	printk(VERSION);
-	arcnet_raw_init();
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit arcnet_raw_exit(void)
 {
 	arcnet_unregister_proto(&rawmode_proto);
 }
 
-MODULE_LICENSE("GPL");
-#endif				/* MODULE */
+module_init(arcnet_raw_init);
+module_exit(arcnet_raw_exit);
 
+MODULE_LICENSE("GPL");
 
 
 /* packet receiver */
--- 1.10/drivers/net/arcnet/arcnet.c	Fri May 16 02:23:26 2003
+++ edited/drivers/net/arcnet/arcnet.c	Wed May 21 00:04:26 2003
@@ -106,13 +106,15 @@
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev);
 static int go_tx(struct net_device *dev);
 
-void __init arcnet_init(void)
+static int debug = ARCNET_DEBUG;
+MODULE_PARM(debug, "i");
+MODULE_LICENSE("GPL");
+
+static int __init arcnet_init(void)
 {
-	static int arcnet_inited;
 	int count;
 
-	if (arcnet_inited++)
-		return;
+	arcnet_debug = debug;
 
 	printk(VERSION);
 
@@ -138,47 +140,15 @@
 		sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
 		   sizeof(struct archdr));
 
-#ifdef CONFIG_ARCNET		/* We're not built as a module */
-	printk("arcnet: Available protocols:");
-#ifdef CONFIG_ARCNET_1201
-	printk(" RFC1201");
-	arcnet_rfc1201_init();
-#endif
-#ifdef CONFIG_ARCNET_1051
-	printk(" RFC1051");
-	arcnet_rfc1051_init();
-#endif
-#ifdef CONFIG_ARCNET_RAW
-	printk(" RAW");
-	arcnet_raw_init();
-#endif
-	printk("\n");
-#ifdef CONFIG_ARCNET_COM90xx
-	com90xx_probe(NULL);
-#endif
-#endif
-}
-
-
-#ifdef MODULE
-
-static int debug = ARCNET_DEBUG;
-MODULE_PARM(debug, "i");
-MODULE_LICENSE("GPL");
-
-int __init init_module(void)
-{
-	arcnet_debug = debug;
-	arcnet_init();
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit arcnet_exit(void)
 {
 }
 
-#endif
-
+module_init(arcnet_init);
+module_exit(arcnet_exit);
 
 /*
  * Dump the contents of an sk_buff
--- 1.4/drivers/net/arcnet/com20020-isa.c	Thu Apr  4 11:39:23 2002
+++ edited/drivers/net/arcnet/com20020-isa.c	Tue May 20 12:13:20 2003
@@ -54,10 +54,6 @@
 	unsigned long airqmask;
 	struct arcnet_local *lp = dev->priv;
 
-#ifndef MODULE
-	arcnet_init();
-#endif
-
 	BUGLVL(D_NORMAL) printk(VERSION);
 
 	ioaddr = dev->base_addr;
--- 1.12/drivers/net/arcnet/com20020-pci.c	Sat Feb 15 00:22:15 2003
+++ edited/drivers/net/arcnet/com20020-pci.c	Tue May 20 12:13:36 2003
@@ -183,9 +183,6 @@
 static int __init com20020pci_init(void)
 {
 	BUGLVL(D_NORMAL) printk(VERSION);
-#ifndef MODULE
-	arcnet_init();
-#endif
 	return pci_module_init(&com20020pci_driver);
 }
 
--- 1.6/drivers/net/arcnet/com90io.c	Thu Apr  4 11:39:23 2002
+++ edited/drivers/net/arcnet/com90io.c	Tue May 20 12:13:01 2003
@@ -151,10 +151,6 @@
 	int ioaddr = dev->base_addr, status;
 	unsigned long airqmask;
 
-#ifndef MODULE
-	arcnet_init();
-#endif
-
 	BUGLVL(D_NORMAL) printk(VERSION);
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test this driver, please!\n");
 
--- 1.6/drivers/net/arcnet/com90xx.c	Thu Apr  4 11:39:23 2002
+++ edited/drivers/net/arcnet/com90xx.c	Wed May 21 00:08:10 2003
@@ -29,7 +29,6 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/bootmem.h>
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
@@ -100,7 +99,7 @@
 
 static int com90xx_skip_probe __initdata = 0;
 
-int __init com90xx_probe(struct net_device *dev)
+static int __init com90xx_probe(struct net_device *dev)
 {
 	int count, status, ioaddr, numprint, airq, retval = -ENODEV,
 	 openparen = 0;
@@ -115,10 +114,6 @@
 	if (!dev && com90xx_skip_probe)
 		return -ENODEV;
 
-#ifndef MODULE
-	arcnet_init();
-#endif
-
 	BUGLVL(D_NORMAL) printk(VERSION);
 
 	/* set up the arrays where we'll store the possible probe addresses */
@@ -603,9 +598,6 @@
 }
 
 
-
-#ifdef MODULE
-
 /* Module parameters */
 
 static int io;			/* use the insmod io= irq= shmem= options */
@@ -619,7 +611,7 @@
 MODULE_PARM(device, "s");
 MODULE_LICENSE("GPL");
 
-int init_module(void)
+static int __init com90xx_init(void)
 {
 	struct net_device *dev;
 	int err;
@@ -642,8 +634,7 @@
 	return 0;
 }
 
-
-void cleanup_module(void)
+static void __exit com90xx_exit(void)
 {
 	struct net_device *dev;
 	struct arcnet_local *lp;
@@ -663,44 +654,38 @@
 	}
 }
 
-#else
+module_init(com90xx_init);
+module_exit(com90xx_exit);
 
+#ifndef MODULE
 static int __init com90xx_setup(char *s)
 {
-	struct net_device *dev;
 	int ints[8];
 
-	com90xx_skip_probe = 1;
-
 	s = get_options(s, 8, ints);
 	if (!ints[0] && !*s) {
 		printk("com90xx: Disabled.\n");
 		return 1;
 	}
-	dev = alloc_bootmem(sizeof(struct net_device));
-	memset(dev, 0, sizeof(struct net_device));
-	dev->init = com90xx_probe;
 
 	switch (ints[0]) {
 	default:		/* ERROR */
 		printk("com90xx: Too many arguments.\n");
 	case 3:		/* Mem address */
-		dev->mem_start = ints[3];
+		shmem = ints[3];
 	case 2:		/* IRQ */
-		dev->irq = ints[2];
+		irq = ints[2];
 	case 1:		/* IO address */
-		dev->base_addr = ints[1];
+		io = ints[1];
 	}
+
 	if (*s)
-		strncpy(dev->name, s, 9);
+		strncpy(device, s, 9);
 	else
-		strcpy(dev->name, "arc%d");
-	if (register_netdev(dev))
-		printk(KERN_ERR "com90xx: Cannot register arcnet device\n");
+		strcpy(device, "arc%d");
 
 	return 1;
 }
 
 __setup("com90xx=", com90xx_setup);
-
-#endif				/* MODULE */
+#endif
--- 1.3/drivers/net/arcnet/rfc1051.c	Thu Apr  4 11:39:23 2002
+++ edited/drivers/net/arcnet/rfc1051.c	Wed May 21 00:05:52 2003
@@ -53,8 +53,10 @@
 };
 
 
-void __init arcnet_rfc1051_init(void)
+static int __init arcnet_rfc1051_init(void)
 {
+	printk(VERSION);
+
 	arc_proto_map[ARC_P_IP_RFC1051]
 	    = arc_proto_map[ARC_P_ARP_RFC1051]
 	    = &rfc1051_proto;
@@ -63,27 +65,18 @@
 	if (arc_bcast_proto == arc_proto_default)
 		arc_bcast_proto = &rfc1051_proto;
 
-}
-
-
-#ifdef MODULE
-
-MODULE_LICENSE("GPL");
-
-int __init init_module(void)
-{
-	printk(VERSION);
-	arcnet_rfc1051_init();
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit arcnet_rfc1051_exit(void)
 {
 	arcnet_unregister_proto(&rfc1051_proto);
 }
 
-#endif				/* MODULE */
+module_init(arcnet_rfc1051_init);
+module_exit(arcnet_rfc1051_exit);
 
+MODULE_LICENSE("GPL");
 
 /*
  * Determine a packet's protocol ID.
--- 1.4/drivers/net/arcnet/rfc1201.c	Fri May 16 02:23:26 2003
+++ edited/drivers/net/arcnet/rfc1201.c	Wed May 21 00:04:43 2003
@@ -53,8 +53,10 @@
 };
 
 
-void __init arcnet_rfc1201_init(void)
+static int __init arcnet_rfc1201_init(void)
 {
+	printk(VERSION);
+
 	arc_proto_map[ARC_P_IP]
 	    = arc_proto_map[ARC_P_IPV6]
 	    = arc_proto_map[ARC_P_ARP]
@@ -66,27 +68,17 @@
 	/* if someone else already owns the broadcast, we won't take it */
 	if (arc_bcast_proto == arc_proto_default)
 		arc_bcast_proto = &rfc1201_proto;
-}
-
-
-#ifdef MODULE
 
-MODULE_LICENSE("GPL");
-
-int __init init_module(void)
-{
-	printk(VERSION);
-	arcnet_rfc1201_init();
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit arcnet_rfc1201_exit(void)
 {
 	arcnet_unregister_proto(&rfc1201_proto);
 }
 
-#endif				/* MODULE */
-
+module_init(arcnet_rfc1201_init);
+module_exit(arcnet_rfc1201_exit);
 
 /*
  * Determine a packet's protocol ID.
--- 1.1/include/linux/arcdevice.h	Tue Feb  5 18:39:40 2002
+++ edited/include/linux/arcdevice.h	Tue May 20 23:55:24 2003
@@ -333,14 +333,5 @@
 void arcdev_setup(struct net_device *dev);
 void arcnet_rx(struct net_device *dev, int bufnum);
 
-void arcnet_init(void);
-
-void arcnet_rfc1201_init(void);
-void arcnet_rfc1051_init(void);
-void arcnet_raw_init(void);
-
-int com90xx_probe(struct net_device *dev);
-
 #endif				/* __KERNEL__ */
-
 #endif				/* _LINUX_ARCDEVICE_H */
