From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V2] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Tue, 15 May 2012 22:15:06 +0200
Message-ID: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33421 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966104Ab2EOUPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 16:15:36 -0400
Received: by eaak11 with SMTP id k11so930339eaa.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 13:15:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the inw/outw functions by the cs89x0 platform driver
results in NULL pointer references on ARM platforms and
platforms that do not provide ISA-style programmed I/O accessors.

Using inw/outw also accesses the wrong address space on platforms
that have a PCI I/O space that is not identity-mapped into the
physical address space.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |  238 +++++++++++++++++++---------------
 1 files changed, 135 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index b9406cb..8081ad5 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -222,6 +222,8 @@ struct net_local {
 	int send_underrun;	/* keep track of how many underruns in a row we get */
 	int force;		/* force various values; see FORCE* above. */
 	spinlock_t lock;
+	void __iomem *virt_addr;/* CS89x0 virtual address. */
+	unsigned long size;	/* Length of CS89x0 memory region. */
 #if ALLOW_DMA
 	int use_dma;		/* Flag: we're using dma */
 	int dma;		/* DMA channel */
@@ -230,16 +232,13 @@ struct net_local {
 	unsigned char *end_dma_buff;	/* points to the end of the buffer */
 	unsigned char *rx_dma_ptr;	/* points to the next packet  */
 #endif
-#ifdef CONFIG_CS89x0_PLATFORM
-	void __iomem *virt_addr;/* Virtual address for accessing the CS89x0. */
-	unsigned long phys_addr;/* Physical address for accessing the CS89x0. */
-	unsigned long size;	/* Length of CS89x0 memory region. */
-#endif
 };
 
 /* Index to functions, as function prototypes. */
 
-static int cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular);
+static int cs89x0_probe1(struct net_device *dev,
+			 void __iomem *ioaddr,
+			 int modular);
 static int net_open(struct net_device *dev);
 static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
@@ -279,6 +278,67 @@ static int __init dma_fn(char *str)
 __setup("cs89x0_dma=", dma_fn);
 #endif	/* !defined(MODULE) && (ALLOW_DMA != 0) */
 
+#ifndef CONFIG_CS89x0_PLATFORM
+/*
+ * This function converts the I/O port addres used by the cs89x0_probe() and
+ * init_module() functions to the I/O memory address used by the
+ * cs89x0_probe1() function.
+ */
+static int __init
+cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+	void __iomem *io_mem;
+
+	if (!lp)
+		return -ENOMEM;
+
+	dev->base_addr = ioport;
+
+	if (!request_region(ioport, NETCARD_IO_EXTENT, DRV_NAME)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	io_mem = ioport_map(ioport & ~3, NETCARD_IO_EXTENT);
+	if (!io_mem) {
+		ret = -ENOMEM;
+		goto release;
+	}
+
+	/* if they give us an odd I/O address, then do ONE write to
+	   the address port, to get it back to address zero, where we
+	   expect to find the EISA signature word. An IO with a base of 0x3
+	   will skip the test for the ADD_PORT. */
+	if (ioport & 1) {
+		if (net_debug > 1)
+			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n",
+			       dev->name,
+			       ioport);
+		if ((ioport & 2) != 2)
+			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
+			    ADD_SIG) {
+				printk(KERN_ERR "%s: bad signature 0x%x\n",
+					dev->name,
+					ioread16(io_mem + ADD_PORT));
+				ret = -ENODEV;
+				goto unmap;
+			}
+	}
+
+	ret = cs89x0_probe1(dev, io_mem, modular);
+	if (!ret)
+		goto out;
+unmap:
+	ioport_unmap(io_mem);
+release:
+	release_region(ioport, NETCARD_IO_EXTENT);
+out:
+	return ret;
+}
+#endif
+
 #ifndef MODULE
 static int g_cs89x0_media__force;
 
@@ -292,7 +352,6 @@ static int __init media_fn(char *str)
 
 __setup("cs89x0_media=", media_fn);
 
-
 #ifndef CONFIG_CS89x0_PLATFORM
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
@@ -322,12 +381,12 @@ struct net_device * __init cs89x0_probe(int unit)
 		printk("cs89x0:cs89x0_probe(0x%x)\n", io);
 
 	if (io > 0x1ff)	{	/* Check a single specified location. */
-		err = cs89x0_probe1(dev, io, 0);
+		err = cs89x0_ioport_probe(dev, io, 0);
 	} else if (io != 0) {	/* Don't probe at all. */
 		err = -ENXIO;
 	} else {
 		for (port = netcard_portlist; *port; port++) {
-			if (cs89x0_probe1(dev, *port, 0) == 0)
+			if (cs89x0_ioport_probe(dev, *port, 0) == 0)
 				break;
 			dev->irq = irq;
 		}
@@ -369,36 +428,24 @@ writeword(unsigned long base_addr, int portno, u16 value)
 {
 	__raw_writel(value, base_addr + (portno << 1));
 }
-#else
-static u16
-readword(unsigned long base_addr, int portno)
-{
-	return inw(base_addr + portno);
-}
-
-static void
-writeword(unsigned long base_addr, int portno, u16 value)
-{
-	outw(value, base_addr + portno);
-}
 #endif
 
 static void
-readwords(unsigned long base_addr, int portno, void *buf, int length)
+readwords(void __iomem *base_addr, int portno, void *buf, int length)
 {
 	u8 *buf8 = (u8 *)buf;
 
 	do {
 		u16 tmp16;
 
-		tmp16 = readword(base_addr, portno);
+		tmp16 = ioread16(base_addr + portno);
 		*buf8++ = (u8)tmp16;
 		*buf8++ = (u8)(tmp16 >> 8);
 	} while (--length);
 }
 
 static void
-writewords(unsigned long base_addr, int portno, void *buf, int length)
+writewords(void __iomem *base_addr, int portno, void *buf, int length)
 {
 	u8 *buf8 = (u8 *)buf;
 
@@ -407,22 +454,26 @@ writewords(unsigned long base_addr, int portno, void *buf, int length)
 
 		tmp16 = *buf8++;
 		tmp16 |= (*buf8++) << 8;
-		writeword(base_addr, portno, tmp16);
+		iowrite16(tmp16, base_addr + portno);
 	} while (--length);
 }
 
 static u16
 readreg(struct net_device *dev, u16 regno)
 {
-	writeword(dev->base_addr, ADD_PORT, regno);
-	return readword(dev->base_addr, DATA_PORT);
+	struct net_local *lp = netdev_priv(dev);
+
+	iowrite16(regno, lp->virt_addr + ADD_PORT);
+	return ioread16(lp->virt_addr + DATA_PORT);
 }
 
 static void
 writereg(struct net_device *dev, u16 regno, u16 value)
 {
-	writeword(dev->base_addr, ADD_PORT, regno);
-	writeword(dev->base_addr, DATA_PORT, value);
+	struct net_local *lp = netdev_priv(dev);
+
+	iowrite16(regno, lp->virt_addr + ADD_PORT);
+	iowrite16(value, lp->virt_addr + DATA_PORT);
 }
 
 static int __init
@@ -505,7 +556,7 @@ static const struct net_device_ops net_ops = {
  */
 
 static int __init
-cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
+cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 {
 	struct net_local *lp = netdev_priv(dev);
 	static unsigned version_printed;
@@ -529,50 +580,22 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 #endif
 		lp->force = g_cs89x0_media__force;
 #endif
-
         }
 
-	/* Grab the region so we can find another board if autoIRQ fails. */
-	/* WTF is going on here? */
-	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
-		printk(KERN_ERR "%s: request_region(0x%lx, 0x%x) failed\n",
-				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
-		retval = -EBUSY;
-		goto out1;
-	}
+	printk(KERN_DEBUG "PP_addr at %p[%x]: 0x%x\n",
+			ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
+	iowrite16(PP_ChipID, ioaddr + ADD_PORT);
 
-	/* if they give us an odd I/O address, then do ONE write to
-           the address port, to get it back to address zero, where we
-           expect to find the EISA signature word. An IO with a base of 0x3
-	   will skip the test for the ADD_PORT. */
-	if (ioaddr & 1) {
-		if (net_debug > 1)
-			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n", dev->name, ioaddr);
-	        if ((ioaddr & 2) != 2)
-	        	if ((readword(ioaddr & ~3, ADD_PORT) & ADD_MASK) != ADD_SIG) {
-				printk(KERN_ERR "%s: bad signature 0x%x\n",
-					dev->name, readword(ioaddr & ~3, ADD_PORT));
-		        	retval = -ENODEV;
-				goto out2;
-			}
-	}
-
-	ioaddr &= ~3;
-	printk(KERN_DEBUG "PP_addr at %lx[%x]: 0x%x\n",
-			ioaddr, ADD_PORT, readword(ioaddr, ADD_PORT));
-	writeword(ioaddr, ADD_PORT, PP_ChipID);
-
-	tmp = readword(ioaddr, DATA_PORT);
+	tmp = ioread16(ioaddr + DATA_PORT);
 	if (tmp != CHIP_EISA_ID_SIG) {
-		printk(KERN_DEBUG "%s: incorrect signature at %lx[%x]: 0x%x!="
+		printk(KERN_DEBUG "%s: incorrect signature at %p[%x]: 0x%x!="
 			CHIP_EISA_ID_SIG_STR "\n",
 			dev->name, ioaddr, DATA_PORT, tmp);
   		retval = -ENODEV;
-  		goto out2;
+		goto out1;
 	}
 
-	/* Fill in the 'dev' fields. */
-	dev->base_addr = ioaddr;
+	lp->virt_addr = ioaddr;
 
 	/* get the chip type */
 	rev_type = readreg(dev, PRODUCT_ID_ADD);
@@ -590,12 +613,12 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 	if (net_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk(KERN_INFO "%s: cs89%c0%s rev %c found at %#3lx ",
+	printk(KERN_INFO "%s: cs89%c0%s rev %c found at %p ",
 	       dev->name,
 	       lp->chip_type==CS8900?'0':'2',
 	       lp->chip_type==CS8920M?"M":"",
 	       lp->chip_revision,
-	       dev->base_addr);
+	       lp->virt_addr);
 
 	reset_chip(dev);
 
@@ -787,12 +810,10 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 
 	retval = register_netdev(dev);
 	if (retval)
-		goto out3;
+		goto out2;
 	return 0;
-out3:
-	writeword(dev->base_addr, ADD_PORT, PP_ChipID);
 out2:
-	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
+	iowrite16(PP_ChipID, lp->virt_addr + ADD_PORT);
 out1:
 	return retval;
 }
@@ -956,7 +977,6 @@ static void __init reset_chip(struct net_device *dev)
 #if !defined(CONFIG_MACH_MX31ADS)
 #if !defined(CS89x0_NONISA_IRQ)
 	struct net_local *lp = netdev_priv(dev);
-	int ioaddr = dev->base_addr;
 #endif /* CS89x0_NONISA_IRQ */
 	int reset_start_time;
 
@@ -968,13 +988,15 @@ static void __init reset_chip(struct net_device *dev)
 #if !defined(CS89x0_NONISA_IRQ)
 	if (lp->chip_type != CS8900) {
 		/* Hardware problem requires PNP registers to be reconfigured after a reset */
-		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAINT);
-		outb(dev->irq, ioaddr + DATA_PORT);
-		outb(0,      ioaddr + DATA_PORT + 1);
-
-		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAMemB);
-		outb((dev->mem_start >> 16) & 0xff, ioaddr + DATA_PORT);
-		outb((dev->mem_start >> 8) & 0xff,   ioaddr + DATA_PORT + 1);
+		iowrite16(PP_CS8920_ISAINT, lp->virt_addr + ADD_PORT);
+		iowrite8(dev->irq, lp->virt_addr + DATA_PORT);
+		iowrite8(0, lp->virt_addr + DATA_PORT + 1);
+
+		iowrite16(PP_CS8920_ISAMemB, lp->virt_addr + ADD_PORT);
+		iowrite8((dev->mem_start >> 16) & 0xff,
+			 lp->virt_addr + DATA_PORT);
+		iowrite8((dev->mem_start >> 8) & 0xff,
+			 lp->virt_addr + DATA_PORT + 1);
 	}
 #endif /* CS89x0_NONISA_IRQ */
 
@@ -1092,6 +1114,7 @@ detect_tp(struct net_device *dev)
 static int
 send_test_pkt(struct net_device *dev)
 {
+	struct net_local *lp = netdev_priv(dev);
 	char test_packet[] = { 0,0,0,0,0,0, 0,0,0,0,0,0,
 				 0, 46, /* A 46 in network order */
 				 0, 0, /* DSAP=0 & SSAP=0 fields */
@@ -1103,8 +1126,8 @@ send_test_pkt(struct net_device *dev)
 	memcpy(test_packet,          dev->dev_addr, ETH_ALEN);
 	memcpy(test_packet+ETH_ALEN, dev->dev_addr, ETH_ALEN);
 
-        writeword(dev->base_addr, TX_CMD_PORT, TX_AFTER_ALL);
-        writeword(dev->base_addr, TX_LEN_PORT, ETH_ZLEN);
+	iowrite16(TX_AFTER_ALL, lp->virt_addr + TX_CMD_PORT);
+	iowrite16(ETH_ZLEN, lp->virt_addr + TX_LEN_PORT);
 
 	/* Test to see if the chip has allocated memory for the packet */
 	while (jiffies - timenow < 5)
@@ -1114,7 +1137,10 @@ send_test_pkt(struct net_device *dev)
 		return 0;	/* this shouldn't happen */
 
 	/* Write the contents of the packet */
-	writewords(dev->base_addr, TX_FRAME_PORT,test_packet,(ETH_ZLEN+1) >>1);
+	writewords(lp->virt_addr,
+		   TX_FRAME_PORT,
+		   test_packet,
+		   (ETH_ZLEN+1) >> 1);
 
 	if (net_debug > 1) printk("Sending test packet ");
 	/* wait a couple of jiffies for packet to be received */
@@ -1458,8 +1484,8 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 	netif_stop_queue(dev);
 
 	/* initiate a transmit sequence */
-	writeword(dev->base_addr, TX_CMD_PORT, lp->send_cmd);
-	writeword(dev->base_addr, TX_LEN_PORT, skb->len);
+	iowrite16(lp->send_cmd, lp->virt_addr + TX_CMD_PORT);
+	iowrite16(skb->len, lp->virt_addr + TX_LEN_PORT);
 
 	/* Test to see if the chip has allocated memory for the packet */
 	if ((readreg(dev, PP_BusST) & READY_FOR_TX_NOW) == 0) {
@@ -1473,7 +1499,7 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 	/* Write the contents of the packet */
-	writewords(dev->base_addr, TX_FRAME_PORT,skb->data,(skb->len+1) >>1);
+	writewords(lp->virt_addr, TX_FRAME_PORT, skb->data, (skb->len+1) >> 1);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	dev->stats.tx_bytes += skb->len;
 	dev_kfree_skb (skb);
@@ -1499,10 +1525,9 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct net_local *lp;
-	int ioaddr, status;
+	int status;
  	int handled = 0;
 
-	ioaddr = dev->base_addr;
 	lp = netdev_priv(dev);
 
 	/* we MUST read all the events out of the ISQ, otherwise we'll never
@@ -1512,7 +1537,7 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
            course, if you're on a slow machine, and packets are arriving
            faster than you can read them off, you're screwed.  Hasta la
            vista, baby!  */
-	while ((status = readword(dev->base_addr, ISQ_PORT))) {
+	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
 		if (net_debug > 4)printk("%s: event=%04x\n", dev->name, status);
 		handled = 1;
 		switch(status & ISQ_EVENT_MASK) {
@@ -1608,12 +1633,12 @@ count_rx_errors(int status, struct net_device *dev)
 static void
 net_rx(struct net_device *dev)
 {
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
-	int ioaddr = dev->base_addr;
-	status = readword(ioaddr, RX_FRAME_PORT);
-	length = readword(ioaddr, RX_FRAME_PORT);
+	status = ioread16(lp->virt_addr + RX_FRAME_PORT);
+	length = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
 	if ((status & RX_OK) == 0) {
 		count_rx_errors(status, dev);
@@ -1631,9 +1656,12 @@ net_rx(struct net_device *dev)
 	}
 	skb_reserve(skb, 2);	/* longword align L3 header */
 
-	readwords(ioaddr, RX_FRAME_PORT, skb_put(skb, length), length >> 1);
+	readwords(lp->virt_addr,
+		  RX_FRAME_PORT,
+		  skb_put(skb, length),
+		  length >> 1);
 	if (length & 1)
-		skb->data[length-1] = readword(ioaddr, RX_FRAME_PORT);
+		skb->data[length-1] = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
 	if (net_debug > 3) {
 		printk(	"%s: received %d byte packet of type %x\n",
@@ -1886,7 +1914,7 @@ int __init init_module(void)
 		goto out;
 	}
 #endif
-	ret = cs89x0_probe1(dev, io, 1);
+	ret = cs89x0_ioport_probe(dev, io, 1);
 	if (ret)
 		goto out;
 
@@ -1900,8 +1928,11 @@ out:
 void __exit
 cleanup_module(void)
 {
+	struct net_local *lp = netdev_priv(dev_cs89x0);
+
 	unregister_netdev(dev_cs89x0);
-	writeword(dev_cs89x0->base_addr, ADD_PORT, PP_ChipID);
+	iowrite16(PP_ChipID, lp->virt_addr + ADD_PORT);
+	ioport_unmap(lp->virt_addr);
 	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
 	free_netdev(dev_cs89x0);
 }
@@ -1913,6 +1944,7 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
 	struct net_local *lp;
 	struct resource *mem_res;
+	void __iomem *virt_addr;
 	int err;
 
 	if (!dev)
@@ -1928,22 +1960,22 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 		goto free;
 	}
 
-	lp->phys_addr = mem_res->start;
+	dev->base_addr = mem_res->start;
 	lp->size = resource_size(mem_res);
-	if (!request_mem_region(lp->phys_addr, lp->size, DRV_NAME)) {
+	if (!request_mem_region(dev->base_addr, lp->size, DRV_NAME)) {
 		dev_warn(&dev->dev, "request_mem_region() failed.\n");
 		err = -EBUSY;
 		goto free;
 	}
 
-	lp->virt_addr = ioremap(lp->phys_addr, lp->size);
-	if (!lp->virt_addr) {
+	virt_addr = ioremap(dev->base_addr, lp->size);
+	if (!virt_addr) {
 		dev_warn(&dev->dev, "ioremap() failed.\n");
 		err = -ENOMEM;
 		goto release;
 	}
 
-	err = cs89x0_probe1(dev, (unsigned long)lp->virt_addr, 0);
+	err = cs89x0_probe1(dev, virt_addr, 0);
 	if (err) {
 		dev_warn(&dev->dev, "no cs8900 or cs8920 detected.\n");
 		goto unmap;
@@ -1953,9 +1985,9 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 	return 0;
 
 unmap:
-	iounmap(lp->virt_addr);
+	iounmap(virt_addr);
 release:
-	release_mem_region(lp->phys_addr, lp->size);
+	release_mem_region(dev->base_addr, lp->size);
 free:
 	free_netdev(dev);
 	return err;
@@ -1968,7 +2000,7 @@ static int cs89x0_platform_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	iounmap(lp->virt_addr);
-	release_mem_region(lp->phys_addr, lp->size);
+	release_mem_region(dev->base_addr, lp->size);
 	free_netdev(dev);
 	return 0;
 }
-- 
1.7.1
