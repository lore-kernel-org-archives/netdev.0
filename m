From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/6) skisa -- probe2
Date: Wed, 15 Oct 2003 13:48:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152048.h9FKmAs11913@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert the SK-NET TMS380 ISA card to the new probe2 format.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Oct 13 15:10:32 2003
+++ b/drivers/net/Space.c	Mon Oct 13 15:10:32 2003
@@ -410,11 +410,14 @@
 #ifdef CONFIG_TR
 /* Token-ring device probe */
 extern int ibmtr_probe(struct net_device *);
-extern int sk_isa_probe(struct net_device *);
+extern struct net_device *sk_isa_probe(int unit);
 extern struct net_device *proteon_probe(int unit);
 extern struct net_device *smctr_probe(int unit);
 
 static struct devprobe2 tr_probes2[] __initdata = {
+#ifdef CONFIG_SKISA
+	{sk_isa_probe, 0},
+#endif
 #ifdef CONFIG_PROTEON
 	{proteon_probe, 0},
 #endif
@@ -438,9 +441,6 @@
 	if (
 #ifdef CONFIG_IBMTR
 	    ibmtr_probe(dev) == 0  ||
-#endif
-#ifdef CONFIG_SKISA
-	    sk_isa_probe(dev) == 0 || 
 #endif
 	    0 ) 
 		err = register_netdev(dev);
diff -Nru a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
--- a/drivers/net/tokenring/skisa.c	Mon Oct 13 15:10:32 2003
+++ b/drivers/net/tokenring/skisa.c	Mon Oct 13 15:10:32 2003
@@ -56,7 +56,7 @@
 /* A zero-terminated list of IRQs to be probed. 
  * Used again after initial probe for sktr_chipset_init, called from sktr_open.
  */
-static unsigned short irqlist[] = {
+static const unsigned short irqlist[] = {
 	3, 5, 9, 10, 11, 12, 15,
 	0
 };
@@ -69,7 +69,6 @@
 
 static char isa_cardname[] = "SK NET TR 4/16 ISA\0";
 
-int sk_isa_probe(struct net_device *dev);
 static int sk_isa_open(struct net_device *dev);
 static int sk_isa_close(struct net_device *dev);
 static void sk_isa_read_eeprom(struct net_device *dev);
@@ -95,17 +94,14 @@
 	outw(val, dev->base_addr + reg);
 }
 
-struct sk_isa_card {
-	struct net_device *dev;
-	struct sk_isa_card *next;
-};
-
-static struct sk_isa_card *sk_isa_card_list;
 
-static int __init sk_isa_probe1(int ioaddr)
+static int __init sk_isa_probe1(struct net_device *dev, int ioaddr)
 {
 	unsigned char old, chk1, chk2;
 
+	if (!request_region(ioaddr, SK_ISA_IO_EXTENT, isa_cardname))
+		return -ENODEV;
+
 	old = inb(ioaddr + SIFADR);	/* Get the old SIFADR value */
 
 	chk1 = 0;	/* Begin with check value 0 */
@@ -122,8 +118,10 @@
 		chk2 = inb(ioaddr + SIFADD);
 		chk2 ^= 0x0FE;
 
-		if(chk1 != chk2)
-			return (-1);	/* No adapter */
+		if(chk1 != chk2) {
+			release_region(ioaddr, SK_ISA_IO_EXTENT);
+			return -ENODEV;
+		}
 
 		chk1 -= 2;
 	} while(chk1 != 0);	/* Repeat 128 times (all byte values) */
@@ -131,58 +129,45 @@
     	/* Restore the SIFADR value */
 	outb(old, ioaddr + SIFADR);
 
-	return (0);
+	dev->base_addr = ioaddr;
+	return 0;
 }
 
-int __init sk_isa_probe(struct net_device *dev)
+struct net_device * __init sk_isa_probe(int unit)
 {
-        static int versionprinted;
+	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
 	struct net_local *tp;
-	int i,j;
-	struct sk_isa_card *card;
+        static int versionprinted;
+	const unsigned *port;
+	int j, err = 0;
 
-#ifndef MODULE
-	netdev_boot_setup_check(dev);
-	tr_setup(dev);
-#endif
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
-	if (!dev->base_addr)
-	{
-		for(i = 0; portlist[i]; i++)
-		{
-			if (!request_region(portlist[i], SK_ISA_IO_EXTENT, isa_cardname))
-				continue;
-
-			if(sk_isa_probe1(portlist[i]))
-			{
-				release_region(dev->base_addr, SK_ISA_IO_EXTENT); 
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
+		err = sk_isa_probe1(dev, dev->base_addr);
+	else {
+		for (port = portlist; *port; port++) {
+			err = sk_isa_probe1(dev, *port);
+			if (!err)
+				break;
 		}
-		if(!dev->base_addr)
-			return -1;
 	}
-	else
-	{
-		if (!request_region(dev->base_addr, SK_ISA_IO_EXTENT, isa_cardname))
-			return -1;
-
-		if(sk_isa_probe1(dev->base_addr))
-		{
-			release_region(dev->base_addr, SK_ISA_IO_EXTENT); 
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
 
@@ -284,14 +269,11 @@
 	printk(KERN_DEBUG "%s:    IO: %#4lx  IRQ: %d  DMA: %d\n",
 	       dev->name, dev->base_addr, dev->irq, dev->dma);
 		
-	/* Enlist in the card list */
-	card = kmalloc(sizeof(struct sk_isa_card), GFP_KERNEL);
-	if (!card)
+	err = register_netdev(dev);
+	if (err)
 		goto out;
-	card->next = sk_isa_card_list;
-	sk_isa_card_list = card;
-	card->dev = dev;
-	return 0;
+
+	return dev;
 out:
 	free_dma(dev->dma);
 out2:
@@ -300,7 +282,8 @@
 	tmsdev_term(dev);
 out4:
 	release_region(dev->base_addr, SK_ISA_IO_EXTENT); 
-	return -1;
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*
@@ -373,6 +356,8 @@
 
 #define ISATR_MAX_ADAPTERS 3
 
+static struct net_device *sk_isa_dev[ISATR_MAX_ADAPTERS];
+
 static int io[ISATR_MAX_ADAPTERS];
 static int irq[ISATR_MAX_ADAPTERS];
 static int dma[ISATR_MAX_ADAPTERS];
@@ -383,50 +368,54 @@
 MODULE_PARM(irq, "1-" __MODULE_STRING(ISATR_MAX_ADAPTERS) "i");
 MODULE_PARM(dma, "1-" __MODULE_STRING(ISATR_MAX_ADAPTERS) "i");
 
-static int __init setup_card(unsigned long io, unsigned irq, unsigned char dma)
+static struct net_device * __init setup_card(unsigned long io, unsigned irq, unsigned char dma)
 {
-	int res = -ENOMEM;
-	struct sk_isa_card *this_card;
-	struct net_device *dev = alloc_trdev(0);
-
-	if (dev) {
-		dev->base_addr = io;
-		dev->irq       = irq;
-		dev->dma       = dma;
-		res = -ENODEV;
-		if (sk_isa_probe(dev) == 0) {
-			res = register_netdev(dev);
-			if (!res)
-				return 0;
-			release_region(dev->base_addr, SK_ISA_IO_EXTENT);
-			free_irq(dev->irq, dev);
-			free_dma(dev->dma);
-			tmsdev_term(dev);
-			this_card = sk_isa_card_list;
-			sk_isa_card_list = this_card->next;
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
+	dev->base_addr = io;
+	dev->irq       = irq;
+	dev->dma       = dma;
+
+	err = sk_isa_probe1(dev, io);
+	if (err)
+		goto out;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+
+ out1:
+	release_region(dev->base_addr, SK_ISA_IO_EXTENT);
+	free_irq(dev->irq, dev);
+	free_dma(dev->dma);
+	tmsdev_term(dev);
+ out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 int init_module(void)
 {
+	struct net_device *dev;
 	int i, num;
 
 	num = 0;
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
+		if (io[0])  /* Only probe addresses from command line */
+			dev = setup_card(io[i], irq[i], dma[i]);
+		else
+			dev = sk_isa_probe(-1);
+		if (!IS_ERR(dev)) {
+			sk_isa_dev[i] = dev;
+			++num;
 		}
 	}
+
 	printk(KERN_NOTICE "skisa.c: %d cards found.\n", num);
 	/* Probe for cards. */
 	if (num == 0) {
@@ -438,11 +427,13 @@
 
 void cleanup_module(void)
 {
-	struct net_device *dev;
-	struct sk_isa_card *this_card;
+	int i;
+
+	for (i = 0; i < ISATR_MAX_ADAPTERS ; i++) {
+		struct net_device *dev = sk_isa_dev[i];
 
-	while (sk_isa_card_list) {
-		dev = sk_isa_card_list->dev;
+		if (!dev) 
+			continue;
 		
 		unregister_netdev(dev);
 		release_region(dev->base_addr, SK_ISA_IO_EXTENT);
@@ -450,9 +441,6 @@
 		free_dma(dev->dma);
 		tmsdev_term(dev);
 		free_netdev(dev);
-		this_card = sk_isa_card_list;
-		sk_isa_card_list = this_card->next;
-		kfree(this_card);
 	}
 }
 #endif /* MODULE */
