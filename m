From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/7) ni5010 -- dynamic allocation
Date: Tue, 23 Sep 2003 14:58:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923145827.11d29f91.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Originally from viro NE16-ni5010
	* switched ni5010 to dynamic allocation
	* ni5010: embedded ->priv
	* ni5010: fixed clobbering ->irq
	* ni5010: fixed IO before request_region()
	+ make i_pkt_size a stack local only used on rx intr
	+ protect o_pkt_size inside lock window


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 13:23:19 2003
+++ b/drivers/net/Space.c	Tue Sep 23 13:23:19 2003
@@ -69,7 +69,7 @@
 extern int lne390_probe(struct net_device *);
 extern int ne3210_probe(struct net_device *);
 extern int e2100_probe(struct net_device *);
-extern int ni5010_probe(struct net_device *);
+extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
@@ -284,13 +284,13 @@
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
--- a/drivers/net/ni5010.c	Tue Sep 23 13:23:19 2003
+++ b/drivers/net/ni5010.c	Tue Sep 23 13:23:19 2003
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
