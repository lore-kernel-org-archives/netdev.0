From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: [PATCH] ne3210 update
Date: Sat, 27 Sep 2003 18:54:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpeky2gojv.fsf@hina.wild-wind.fr.eu.org>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: p_gortmaker@yahoo.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Paul, Jeff,

The enclosed patch ports the ne3210 driver over the EISA probing API.

It also fixes some ioremap/isa_memcopy_fromio problems (depending on
where the card memory was mapped) by using ioremap unconditionally and
letting memcopy_fromio do the right thing.

Finally, it removes the card from Space.c (warning, potential
interface renumbering !).

The module options are currently disabled, until Rusty's
module_param_array() patch is included. I will re-introduce them ASAP.

Quite heavily tested on x86.

Thanks,

        M.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=ne3210.patch

--- ../vanilla/linux-2.5/drivers/net/Space.c	2003-09-26 21:03:46.000000000 +0200
+++ linux-2.5/drivers/net/Space.c	2003-09-24 10:15:31.000000000 +0200
@@ -67,7 +67,6 @@
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
 extern int lne390_probe(struct net_device *);
-extern int ne3210_probe(struct net_device *);
 extern int e2100_probe(struct net_device *);
 extern int ni5010_probe(struct net_device *);
 extern int ni52_probe(struct net_device *);
@@ -155,9 +154,6 @@
 #ifdef CONFIG_LNE390
 	{lne390_probe, 0},
 #endif
-#ifdef CONFIG_NE3210
-	{ne3210_probe, 0},
-#endif
 	{NULL, 0},
 };
 
--- ../vanilla/linux-2.5/drivers/net/ne3210.c	2003-09-26 21:03:46.000000000 +0200
+++ linux-2.5/drivers/net/ne3210.c	2003-09-27 18:48:36.000000000 +0200
@@ -23,6 +23,7 @@
 	This driver WILL NOT WORK FOR THE NE3200 - it is completely different
 	and does not use an 8390 at all.
 
+	Updated to EISA probing API 5/2003 by Marc Zyngier.
 */
 
 static const char *version =
@@ -44,9 +45,6 @@
 
 #include "8390.h"
 
-int ne3210_probe(struct net_device *dev);
-static int ne3210_probe1(struct net_device *dev, int ioaddr);
-
 static int ne3210_open(struct net_device *dev);
 static int ne3210_close(struct net_device *dev);
 
@@ -59,7 +57,6 @@
 #define NE3210_START_PG		0x00    /* First page of TX buffer	*/
 #define NE3210_STOP_PG		0x80    /* Last page +1 of RX ring	*/
 
-#define NE3210_ID_PORT		0xc80	/* Same for all EISA cards 	*/
 #define NE3210_IO_EXTENT	0x20
 #define NE3210_SA_PROM		0x16	/* Start of e'net addr.		*/
 #define NE3210_RESET_PORT	0xc84
@@ -69,10 +66,9 @@
 #define NE3210_ADDR1		0x00
 #define NE3210_ADDR2		0x1b
 
-#define NE3210_ID	0x0118cc3a	/* 0x3acc = 1110 10110 01100 =  nvl */
-
 #define NE3210_CFG1		0xc84	/* NB: 0xc84 is also "reset" port. */
 #define NE3210_CFG2		0xc90
+#define NE3210_CFG_EXTENT       (NE3210_CFG2 - NE3210_CFG1 + 1)
 
 /*
  *	You can OR any of the following bits together and assign it
@@ -89,152 +85,108 @@
 
 static unsigned char irq_map[] __initdata = {15, 12, 11, 10, 9, 7, 5, 3};
 static unsigned int shmem_map[] __initdata = {0xff0, 0xfe0, 0xfff0, 0xd8, 0xffe0, 0xffc0, 0xd0, 0x0};
+static const char *ifmap[] __initdata = {"UTP", "?", "BNC", "AUI"};
+static int ifmap_val[] __initdata = {
+		IF_PORT_10BASET,
+		IF_PORT_UNKNOWN,
+		IF_PORT_10BASE2,
+		IF_PORT_AUI,
+};
 
-/*
- *	Probe for the card. The best way is to read the EISA ID if it
- *	is known. Then we can check the prefix of the station address
- *	PROM for a match against the value assigned to Novell.
- */
-
-int __init ne3210_probe(struct net_device *dev)
+static int __init ne3210_eisa_probe (struct device *device)
 {
-	unsigned short ioaddr = dev->base_addr;
-
-	SET_MODULE_OWNER(dev);
+	unsigned long ioaddr, phys_mem;
+	int i, retval, port_index;
+	struct eisa_device *edev = to_eisa_device (device);
+	struct net_device *dev;
 
-	if (ioaddr > 0x1ff)		/* Check a single specified location. */
-		return ne3210_probe1(dev, ioaddr);
-	else if (ioaddr > 0)		/* Don't probe at all. */
-		return -ENXIO;
-
-	if (!EISA_bus) {
-#if NE3210_DEBUG & NE3210_D_PROBE
-		printk("ne3210-debug: Not an EISA bus. Not probing high ports.\n");
-#endif
-		return -ENXIO;
+	/* Allocate dev->priv and fill in 8390 specific dev fields. */
+	if (!(dev = alloc_ei_netdev ())) {
+		printk ("ne3210.c: unable to allocate memory for dev!\n");
+		return -ENOMEM;
 	}
 
-	/* EISA spec allows for up to 16 slots, but 8 is typical. */
-	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000)
-		if (ne3210_probe1(dev, ioaddr) == 0)
-			return 0;
-
-	return -ENODEV;
-}
-
-static int __init ne3210_probe1(struct net_device *dev, int ioaddr)
-{
-	int i, retval;
-	unsigned long eisa_id;
-	const char *ifmap[] = {"UTP", "?", "BNC", "AUI"};
-
-	if (!request_region(dev->base_addr, NE3210_IO_EXTENT, dev->name))
-		return -EBUSY;
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, device);
+	device->driver_data = dev;
+	ioaddr = edev->base_addr;
 
-	if (inb_p(ioaddr + NE3210_ID_PORT) == 0xff) {
-		retval = -ENODEV;
+	if (ethdev_init (dev)) {
+		printk ("ne3210.c: unable to allocate memory for dev->priv!\n");
+		retval = -ENOMEM;
 		goto out;
 	}
 
-#if NE3210_DEBUG & NE3210_D_PROBE
-	printk("ne3210-debug: probe at %#x, ID %#8x\n", ioaddr, inl(ioaddr + NE3210_ID_PORT));
-	printk("ne3210-debug: config regs: %#x %#x\n",
-		inb(ioaddr + NE3210_CFG1), inb(ioaddr + NE3210_CFG2));
-#endif
-
-
-/*	Check the EISA ID of the card. */
-	eisa_id = inl(ioaddr + NE3210_ID_PORT);
-	if (eisa_id != NE3210_ID) {
-		retval = -ENODEV;
+	if (!request_region(ioaddr, NE3210_IO_EXTENT, dev->name)) {
+		retval = -EBUSY;
 		goto out;
 	}
 
-	
-#if 0
-/*	Check the vendor ID as well. Not really required. */
-	if (inb(ioaddr + NE3210_SA_PROM + 0) != NE3210_ADDR0
-		|| inb(ioaddr + NE3210_SA_PROM + 1) != NE3210_ADDR1
-		|| inb(ioaddr + NE3210_SA_PROM + 2) != NE3210_ADDR2 ) {
-		printk("ne3210.c: card not found");
-		for(i = 0; i < ETHER_ADDR_LEN; i++)
-			printk(" %02x", inb(ioaddr + NE3210_SA_PROM + i));
-		printk(" (invalid prefix).\n");
-		retval = -ENODEV;
-		goto out;
+	if (!request_region(ioaddr + NE3210_CFG1,
+			    NE3210_CFG_EXTENT, dev->name)) {
+		retval = -EBUSY;
+		goto out1;
 	}
+
+#if NE3210_DEBUG & NE3210_D_PROBE
+	printk("ne3210-debug: probe at %#x, ID %s\n", ioaddr, edev->id.sig);
+	printk("ne3210-debug: config regs: %#x %#x\n",
+		inb(ioaddr + NE3210_CFG1), inb(ioaddr + NE3210_CFG2));
 #endif
 
-	/* Allocate dev->priv and fill in 8390 specific dev fields. */
-	if (ethdev_init(dev)) {
-		printk ("ne3210.c: unable to allocate memory for dev->priv!\n");
-		retval = -ENOMEM;
-		goto out;
-	}
 
+	port_index = inb(ioaddr + NE3210_CFG2) >> 6;
 	printk("ne3210.c: NE3210 in EISA slot %d, media: %s, addr:",
-		ioaddr/0x1000, ifmap[inb(ioaddr + NE3210_CFG2) >> 6]);
+		edev->slot, ifmap[port_index]);
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		printk(" %02x", (dev->dev_addr[i] = inb(ioaddr + NE3210_SA_PROM + i)));
-	printk(".\nne3210.c: ");
+	
 
 	/* Snarf the interrupt now. CFG file has them all listed as `edge' with share=NO */
-	if (dev->irq == 0) {
-		unsigned char irq_reg = inb(ioaddr + NE3210_CFG2) >> 3;
-		dev->irq = irq_map[irq_reg & 0x07];
-		printk("using");
-	} else {
-		/* This is useless unless we reprogram the card here too */
-		if (dev->irq == 2) dev->irq = 9;	/* Doh! */
-		printk("assigning");
-	}
-	printk(" IRQ %d,", dev->irq);
+	dev->irq = irq_map[(inb(ioaddr + NE3210_CFG2) >> 3) & 0x07];
+	printk(".\nne3210.c: using IRQ %d, ", dev->irq);
 
 	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
 	if (retval) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
-		goto out1;
-	}
-
-	if (dev->mem_start == 0) {
-		unsigned char mem_reg = inb(ioaddr + NE3210_CFG2) & 0x07;
-		dev->mem_start = shmem_map[mem_reg] * 0x1000;
-		printk(" using ");
-	} else {
-		/* Should check for value in shmem_map and reprogram the card to use it */
-		dev->mem_start &= 0xfff8000;
-		printk(" assigning ");
+		goto out2;
 	}
 
-	printk("%dkB memory at physical address %#lx\n",
-			NE3210_STOP_PG/4, dev->mem_start);
+	phys_mem = shmem_map[inb(ioaddr + NE3210_CFG2) & 0x07] * 0x1000;
 
 	/*
 	   BEWARE!! Some dain-bramaged EISA SCUs will allow you to put
 	   the card mem within the region covered by `normal' RAM  !!!
 	*/
-	if (dev->mem_start > 1024*1024) {	/* phys addr > 1MB */
-		if (dev->mem_start < virt_to_phys(high_memory)) {
+	if (phys_mem > 1024*1024) {	/* phys addr > 1MB */
+		if (phys_mem < virt_to_phys(high_memory)) {
 			printk(KERN_CRIT "ne3210.c: Card RAM overlaps with normal memory!!!\n");
 			printk(KERN_CRIT "ne3210.c: Use EISA SCU to set card memory below 1MB,\n");
 			printk(KERN_CRIT "ne3210.c: or to an address above 0x%lx.\n", virt_to_phys(high_memory));
 			printk(KERN_CRIT "ne3210.c: Driver NOT installed.\n");
 			retval = -EINVAL;
-			goto out2;
+			goto out3;
 		}
-		dev->mem_start = (unsigned long)ioremap(dev->mem_start, NE3210_STOP_PG*0x100);
-		if (dev->mem_start == 0) {
-			printk(KERN_ERR "ne3210.c: Unable to remap card memory above 1MB !!\n");
-			printk(KERN_ERR "ne3210.c: Try using EISA SCU to set memory below 1MB.\n");
-			printk(KERN_ERR "ne3210.c: Driver NOT installed.\n");
-			retval = -EAGAIN;
-			goto out2;
-		}
-		ei_status.reg0 = 1;	/* Use as remap flag */
-		printk("ne3210.c: remapped %dkB card memory to virtual address %#lx\n",
-				NE3210_STOP_PG/4, dev->mem_start);
 	}
+	
+	if (!request_mem_region (phys_mem, NE3210_STOP_PG*0x100, dev->name)) {
+		printk ("ne3210.c: Unable to request shared memory at physical address %#lx\n",
+			phys_mem);
+		goto out3;
+	}
+	
+	printk("%dkB memory at physical address %#lx\n",
+	       NE3210_STOP_PG/4, phys_mem);
 
+	dev->mem_start = (unsigned long)ioremap(phys_mem, NE3210_STOP_PG*0x100);
+	if (dev->mem_start == 0) {
+		printk(KERN_ERR "ne3210.c: Unable to remap card memory !!\n");
+		printk(KERN_ERR "ne3210.c: Driver NOT installed.\n");
+		retval = -EAGAIN;
+		goto out4;
+	}
+	printk("ne3210.c: remapped %dkB card memory to virtual address %#lx\n",
+	       NE3210_STOP_PG/4, dev->mem_start);
 	dev->mem_end = ei_status.rmem_end = dev->mem_start
 		+ (NE3210_STOP_PG - NE3210_START_PG)*256;
 	ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
@@ -247,6 +199,7 @@
 	ei_status.rx_start_page = NE3210_START_PG + TX_PAGES;
 	ei_status.stop_page = NE3210_STOP_PG;
 	ei_status.word16 = 1;
+	ei_status.priv = phys_mem;
 
 	if (ei_debug > 0)
 		printk(version);
@@ -258,18 +211,46 @@
 
 	dev->open = &ne3210_open;
 	dev->stop = &ne3210_close;
+	dev->if_port = ifmap_val[port_index];
+
+	if ((retval = register_netdev (dev)))
+		goto out5;
+		
 	NS8390_init(dev, 0);
 	return 0;
-out2:
-	free_irq(dev->irq, dev);	
-out1:
-	kfree(dev->priv);
-	dev->priv = NULL;
-out:
-	release_region(ioaddr, NE3210_IO_EXTENT);
+
+ out5:
+	iounmap((void *)dev->mem_start);
+ out4:
+	release_mem_region (phys_mem, NE3210_STOP_PG*0x100);
+ out3:
+	free_irq (dev->irq, dev);
+ out2:
+	release_region (ioaddr + NE3210_CFG1, NE3210_CFG_EXTENT);
+ out1:
+	release_region (ioaddr, NE3210_IO_EXTENT);
+ out:
+	free_netdev (dev);
+	
 	return retval;
 }
 
+static int __devexit ne3210_eisa_remove (struct device *device)
+{
+	struct net_device  *dev    = device->driver_data;
+	unsigned long       ioaddr = to_eisa_device (device)->base_addr;
+
+	unregister_netdev (dev);
+	iounmap((void *)dev->mem_start);
+	release_mem_region (ei_status.priv, NE3210_STOP_PG*0x100);
+	free_irq (dev->irq, dev);
+	release_region (ioaddr + NE3210_CFG1, NE3210_CFG_EXTENT);
+	release_region (ioaddr, NE3210_IO_EXTENT);
+	free_netdev (dev);
+
+	return 0;
+}
+
 /*
  *	Reset by toggling the "Board Enable" bits (bit 2 and 0).
  */
@@ -309,7 +290,7 @@
 ne3210_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
 	unsigned long hdr_start = dev->mem_start + ((ring_page - NE3210_START_PG)<<8);
-	isa_memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
+	memcpy_fromio(hdr, hdr_start, sizeof(struct e8390_pkt_hdr));
 	hdr->count = (hdr->count + 3) & ~3;     /* Round up allocation. */
 }
 
@@ -327,12 +308,12 @@
 	if (xfer_start + count > ei_status.rmem_end) {
 		/* Packet wraps over end of ring buffer. */
 		int semi_count = ei_status.rmem_end - xfer_start;
-		isa_memcpy_fromio(skb->data, xfer_start, semi_count);
+		memcpy_fromio(skb->data, xfer_start, semi_count);
 		count -= semi_count;
-		isa_memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
+		memcpy_fromio(skb->data + semi_count, ei_status.rmem_start, count);
 	} else {
 		/* Packet is in one chunk. */
-		isa_memcpy_fromio(skb->data, xfer_start, count);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 }
 
@@ -342,7 +323,7 @@
 	unsigned long shmem = dev->mem_start + ((start_page - NE3210_START_PG)<<8);
 
 	count = (count + 3) & ~3;     /* Round up to doubleword */
-	isa_memcpy_toio(shmem, buf, count);
+	memcpy_toio(shmem, buf, count);
 }
 
 static int ne3210_open(struct net_device *dev)
@@ -361,7 +342,23 @@
 	return 0;
 }
 
+static struct eisa_device_id ne3210_ids[] = {
+	{ "EGL0101" },
+	{ "NVL1801" },
+	{ "" },
+};
+
+static struct eisa_driver ne3210_eisa_driver = {
+	.id_table = ne3210_ids,
+	.driver   = {
+		.name   = "ne3210",
+		.probe  = ne3210_eisa_probe,
+		.remove = __devexit_p (ne3210_eisa_remove),
+	},
+};
+
 #ifdef MODULE
+#if 0
 #define MAX_NE3210_CARDS	4	/* Max number of NE3210 cards per module */
 static struct net_device dev_ne3210[MAX_NE3210_CARDS];
 static int io[MAX_NE3210_CARDS];
@@ -374,50 +371,22 @@
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s)");
 MODULE_PARM_DESC(mem, "memory base address(es)");
+#endif
+#endif /* MODULE */
+
+
 MODULE_DESCRIPTION("NE3210 EISA Ethernet driver");
 MODULE_LICENSE("GPL");
 
-int init_module(void)
+int ne3210_init(void)
 {
-	int this_dev, found = 0;
-
-	for (this_dev = 0; this_dev < MAX_NE3210_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne3210[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->mem_start = mem[this_dev];
-		dev->init = ne3210_probe;
-		/* Default is to only install one card. */
-		if (io[this_dev] == 0 && this_dev != 0) break;
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "ne3210.c: No NE3210 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
-			}
-			return -ENXIO;
-		}
-		found++;
-	}
-	return 0;
+	return eisa_driver_register (&ne3210_eisa_driver);
 }
 
-void cleanup_module(void)
+void ne3210_cleanup(void)
 {
-	int this_dev;
-
-	for (this_dev = 0; this_dev < MAX_NE3210_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne3210[this_dev];
-		if (dev->priv != NULL) {
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, NE3210_IO_EXTENT);
-			if (ei_status.reg0)
-				iounmap((void *)dev->mem_start);
-			unregister_netdev(dev);
-			kfree(dev->priv);
-			dev->priv = NULL;
-		}
-	}
+	eisa_driver_unregister (&ne3210_eisa_driver);
 }
 
-#endif /* MODULE */
-
+module_init (ne3210_init);
+module_exit (ne3210_cleanup);

--=-=-=


-- 
Places change, faces change. Life is so very strange.

--=-=-=--
