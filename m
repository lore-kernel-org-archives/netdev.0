From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/6) proteon -- probe2
Date: Wed, 15 Oct 2003 13:48:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152048.h9FKm5511905@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert proteon token ring driver to new probing.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Oct 13 14:10:06 2003
+++ b/drivers/net/Space.c	Mon Oct 13 14:10:06 2003
@@ -411,10 +411,13 @@
 /* Token-ring device probe */
 extern int ibmtr_probe(struct net_device *);
 extern int sk_isa_probe(struct net_device *);
-extern int proteon_probe(struct net_device *);
+extern struct net_device *proteon_probe(int unit);
 extern struct net_device *smctr_probe(int unit);
 
 static struct devprobe2 tr_probes2[] __initdata = {
+#ifdef CONFIG_PROTEON
+	{proteon_probe, 0},
+#endif
 #ifdef CONFIG_SMCTR
 	{smctr_probe, 0},
 #endif
@@ -438,9 +441,6 @@
 #endif
 #ifdef CONFIG_SKISA
 	    sk_isa_probe(dev) == 0 || 
-#endif
-#ifdef CONFIG_PROTEON
-	    proteon_probe(dev) == 0 ||
 #endif
 	    0 ) 
 		err = register_netdev(dev);
diff -Nru a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
--- a/drivers/net/tokenring/proteon.c	Mon Oct 13 14:10:06 2003
+++ b/drivers/net/tokenring/proteon.c	Mon Oct 13 14:10:06 2003
@@ -63,7 +63,7 @@
 
 static char cardname[] = "Proteon 1392\0";
 
-int proteon_probe(struct net_device *dev);
+struct net_device *proteon_probe(int unit);
 static int proteon_open(struct net_device *dev);
 static int proteon_close(struct net_device *dev);
 static void proteon_read_eeprom(struct net_device *dev);
@@ -89,80 +89,69 @@
 	outw(val, dev->base_addr + reg);
 }
 
-struct proteon_card {
-	struct net_device *dev;
-	struct proteon_card *next;
-};
-
-static struct proteon_card *proteon_card_list;
-
-static int __init proteon_probe1(int ioaddr)
+static int __init proteon_probe1(struct net_device *dev, int ioaddr)
 {
 	unsigned char chk1, chk2;
 	int i;
 
+	if (!request_region(ioaddr, PROTEON_IO_EXTENT, cardname))
+		return -ENODEV;
+		
+
 	chk1 = inb(ioaddr + 0x1f);      /* Get Proteon ID reg 1 */
-	if (chk1 != 0x1f)
-		return (-1);
+	if (chk1 != 0x1f) 
+		goto nodev;
+
 	chk1 = inb(ioaddr + 0x1e) & 0x07;       /* Get Proteon ID reg 0 */
 	for (i=0; i<16; i++) {
 		chk2 = inb(ioaddr + 0x1e) & 0x07;
 		if (((chk1 + 1) & 0x07) != chk2)
-			return (-1);
+			goto nodev;
 		chk1 = chk2;
 	}
+
+	dev->base_addr = ioaddr;
 	return (0);
+nodev:
+	release_region(ioaddr, PROTEON_IO_EXTENT); 
+	return -ENODEV;
 }
 
-int __init proteon_probe(struct net_device *dev)
+struct net_device * __init proteon_probe(int unit)
 {
-        static int versionprinted;
+	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
 	struct net_local *tp;
-	int i,j;
-	struct proteon_card *card;
-
-#ifndef MODULE
-	netdev_boot_setup_check(dev);
-	tr_setup(dev);
-#endif
+        static int versionprinted;
+	const unsigned *port;
+	int j,err = 0;
 
-	SET_MODULE_OWNER(dev);
-	if (!dev->base_addr)
-	{
-		for(i = 0; portlist[i]; i++)
-		{
-			if (!request_region(portlist[i], PROTEON_IO_EXTENT, cardname))
-				continue;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-			if(proteon_probe1(portlist[i]))
-			{
-				release_region(dev->base_addr, PROTEON_IO_EXTENT); 
-				continue;
-			}
+	if (unit >= 0) {
+		sprintf(dev->name, "tr%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
-			dev->base_addr = portlist[i];
-			break;
+	SET_MODULE_OWNER(dev);
+	if (dev->base_addr)	/* probe specific location */
+		err = proteon_probe1(dev, dev->base_addr);
+	else {
+		for (port = portlist; *port; port++) {
+			err = proteon_probe1(dev, *port);
+			if (!err)
+				break;
 		}
-		if(!dev->base_addr)
-			return -1;
 	}
-	else
-	{
-		if (!request_region(dev->base_addr, PROTEON_IO_EXTENT, cardname))
-			return -1;
-
-		if(proteon_probe1(dev->base_addr))
-		{
-			release_region(dev->base_addr, PROTEON_IO_EXTENT); 
-			return -1;
-  		}
-	} 
+	if (err)
+		goto out4;
 
 	/* At this point we have found a valid card. */
 
 	if (versionprinted++ == 0)
 		printk(KERN_DEBUG "%s", version);
 
+	err = -EIO;
 	if (tmsdev_init(dev, ISA_MAX_ADDRESS, NULL))
 		goto out4;
 
@@ -264,14 +253,11 @@
 	printk(KERN_DEBUG "%s:    IO: %#4lx  IRQ: %d  DMA: %d\n",
 	       dev->name, dev->base_addr, dev->irq, dev->dma);
 		
-	/* Enlist in the card list */
-	card = kmalloc(sizeof(struct proteon_card), GFP_KERNEL);
-	if (!card)
+	err = register_netdev(dev);
+	if (err)
 		goto out;
-	card->next = proteon_card_list;
-	proteon_card_list = card;
-	card->dev = dev;
-	return 0;
+
+	return dev;
 out:
 	free_dma(dev->dma);
 out2:
@@ -280,7 +266,8 @@
 	tmsdev_term(dev);
 out4:
 	release_region(dev->base_addr, PROTEON_IO_EXTENT); 
-	return -1;
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*
@@ -370,50 +357,50 @@
 MODULE_PARM(irq, "1-" __MODULE_STRING(ISATR_MAX_ADAPTERS) "i");
 MODULE_PARM(dma, "1-" __MODULE_STRING(ISATR_MAX_ADAPTERS) "i");
 
-static int __init setup_card(unsigned long io, unsigned irq, unsigned char dma)
+static struct net_device *proteon_dev[ISATR_MAX_ADAPTERS];
+
+static struct net_device * __init setup_card(unsigned long io, unsigned irq, unsigned char dma)
 {
-	int res = -ENOMEM;
-	struct proteon_card *this_card;
-	struct net_device *dev = alloc_trdev(0);
-
-	if (dev) {
-		dev->base_addr = io;
-		dev->irq       = irq;
-		dev->dma       = dma;
-		res = -ENODEV;
-		if (proteon_probe(dev) == 0) {
-			res = register_netdev(dev);
-			if (!res)
-				return 0;
-			release_region(dev->base_addr, PROTEON_IO_EXTENT);
-			free_irq(dev->irq, dev);
-			free_dma(dev->dma);
-			tmsdev_term(dev);
-			this_card = proteon_card_list;
-			proteon_card_list = this_card->next;
-			kfree(this_card);
-		}
-		kfree(dev);
-	}
-	return res;
+	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	dev->irq = irq;
+	dev->dma = dma;
+	err = proteon_probe1(dev, io);
+	if (err) 
+		goto out;
+		
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+ out1:
+	release_region(dev->base_addr, PROTEON_IO_EXTENT);
+	free_irq(dev->irq, dev);
+	free_dma(dev->dma);
+	tmsdev_term(dev);
+ out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 int init_module(void)
 {
-	int i, num;
+	struct net_device *dev;
+	int i, num = 0;
 
-	num = 0;
-	if (io[0]) { /* Only probe addresses from command line */
-		for (i = 0; i < ISATR_MAX_ADAPTERS ; i++) {
-			if (io[i] && setup_card(io[i], irq[i], dma[i]) == 0)
-				num++;
-		}
-	} else {
-		for(i = 0; num < ISATR_MAX_ADAPTERS && portlist[i]; i++) {
-			if (setup_card(portlist[i], irq[num], dma[num]) == 0)
-				num++;
+	for (i = 0; i < ISATR_MAX_ADAPTERS ; i++) {
+		dev = io[0] ? setup_card(io[i], irq[i], dma[i])
+			: proteon_probe(-1);
+		if (!IS_ERR(dev)) {
+			proteon_dev[i] = dev;
+			++num;
 		}
 	}
+
 	printk(KERN_NOTICE "proteon.c: %d cards found.\n", num);
 	/* Probe for cards. */
 	if (num == 0) {
@@ -425,11 +412,13 @@
 
 void cleanup_module(void)
 {
-	struct net_device *dev;
-	struct proteon_card *this_card;
+	int i;
 
-	while (proteon_card_list) {
-		dev = proteon_card_list->dev;
+	for (i = 0; i < ISATR_MAX_ADAPTERS ; i++) {
+		struct net_device *dev = proteon_dev[i];
+		
+		if (!dev) 
+			continue;
 		
 		unregister_netdev(dev);
 		release_region(dev->base_addr, PROTEON_IO_EXTENT);
@@ -437,9 +426,6 @@
 		free_dma(dev->dma);
 		tmsdev_term(dev);
 		free_netdev(dev);
-		this_card = proteon_card_list;
-		proteon_card_list = this_card->next;
-		kfree(this_card);
 	}
 }
 #endif /* MODULE */
