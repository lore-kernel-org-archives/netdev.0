From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] irda 2.6.0-test6
Date: Mon, 29 Sep 2003 17:06:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929170606.09a2a767.shemminger@osdl.org>
References: <20030929175938.GA11698@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030929175938.GA11698@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a patch for all the pieces that are missing in 2.6.0-test6,
it contains all the pieces that didn't get picked up from my earlier
patches. 
	
	irport:
		* 'ret' set but only used in test.
		* use alloc_netdev and dev->priv
		* error unwind fixup
	sa1100: 
		* need to call free_netdev (no destructor anymore)
	smsc_ircc:
		* use alloc_netdev and dev->priv

	irda_device:
		* no destructor, let devices use device
		  before freeing.
	
This should fix the rmmod issues for irda in 2.6.0-test6
and matches what Jean tested.

diff -urN -X dontdiff linux-2.5/drivers/net/irda/irport.c linux-2.5-net/drivers/net/irda/irport.c
--- linux-2.5/drivers/net/irda/irport.c	2003-06-05 10:04:37.000000000 -0700
+++ linux-2.5-net/drivers/net/irda/irport.c	2003-09-19 23:09:40.000000000 -0700
@@ -78,7 +78,6 @@
 static inline int  irport_write(int iobase, int fifo_size, __u8 *buf, int len);
 static inline void irport_receive(struct irport_cb *self);
 
-static int  irport_net_init(struct net_device *dev);
 static int  irport_net_ioctl(struct net_device *dev, struct ifreq *rq, 
 			     int cmd);
 static inline int  irport_is_receiving(struct irport_cb *self);
@@ -136,30 +135,29 @@
 {
 	struct net_device *dev;
 	struct irport_cb *self;
-	void *ret;
-	int err;
 
 	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
 
 	/* Lock the port that we need */
-	ret = request_region(iobase, IO_EXTENT, driver_name);
-	if (!ret) {
+	if (!request_region(iobase, IO_EXTENT, driver_name)) {
 		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
 			   __FUNCTION__, iobase);
-		return NULL;
+		goto err_out1;
 	}
 
 	/*
 	 *  Allocate new instance of the driver
 	 */
-	self = kmalloc(sizeof(struct irport_cb), GFP_KERNEL);
-	if (!self) {
+	dev = alloc_netdev(sizeof(struct irport_cb), "irda%d",
+			   irda_device_setup);
+	if (!dev) {
 		ERROR("%s(), can't allocate memory for "
 		      "control block!\n", __FUNCTION__);
-		release_region(iobase, IO_EXTENT);
-		return NULL;
+		goto err_out2;
 	}
-	memset(self, 0, sizeof(struct irport_cb));
+
+	self = dev->priv;
+	self->netdev = dev;
 	spin_lock_init(&self->lock);
 
 	/* Need to store self somewhere */
@@ -189,8 +187,9 @@
 	self->rx_buff.truesize = IRDA_SKB_MAX_MTU;
 	self->rx_buff.skb = __dev_alloc_skb(self->rx_buff.truesize,
 					    GFP_KERNEL);
-	if (self->rx_buff.skb == NULL)
-		return NULL;
+	if (self->rx_buff.skb == NULL) 
+		goto err_out3;
+
 	skb_reserve(self->rx_buff.skb, 1);
 	self->rx_buff.head = self->rx_buff.skb->data;
 	/* No need to memset the buffer, unless you are really pedantic */
@@ -207,31 +206,24 @@
 	if (self->tx_buff.truesize > 0) {
 		self->tx_buff.head = (__u8 *) kmalloc(self->tx_buff.truesize, 
 						      GFP_KERNEL);
-		if (self->tx_buff.head == NULL) {
-			kfree_skb(self->rx_buff.skb);
-			self->rx_buff.skb = NULL;
-			self->rx_buff.head = NULL;
-			return NULL;
-		}
+		if (self->tx_buff.head == NULL) 
+			goto err_out4;
 		memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 	}	
 	self->tx_buff.data = self->tx_buff.head;
 
-	if (!(dev = dev_alloc("irda%d", &err))) {
-		ERROR("%s(), dev_alloc() failed!\n", __FUNCTION__);
-		return NULL;
-	}
-	self->netdev = dev;
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
-
 	/* May be overridden by piggyback drivers */
- 	dev->priv = (void *) self;
 	self->interrupt    = irport_interrupt;
 	self->change_speed = irport_change_speed;
 
+	/* Make ifconfig display some details */
+	dev->base_addr = iobase;
+	dev->irq = irq;
+	
 	/* Override the network functions we need to use */
-	dev->init            = irport_net_init;
+
+	SET_MODULE_OWNER(dev);
+
 	dev->hard_start_xmit = irport_hard_xmit;
 	dev->tx_timeout	     = irport_timeout;
 	dev->watchdog_timeo  = HZ;  /* Allow time enough for speed change */
@@ -240,25 +232,31 @@
 	dev->get_stats	     = irport_net_get_stats;
 	dev->do_ioctl        = irport_net_ioctl;
 
-	/* Make ifconfig display some details */
-	dev->base_addr = iobase;
-	dev->irq = irq;
-
-	rtnl_lock();
-	err = register_netdevice(dev);
-	rtnl_unlock();
-	if (err) {
+	if (register_netdev(dev)) {
 		ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
-		return NULL;
+		goto err_out5;
 	}
 	MESSAGE("IrDA: Registered device %s (irport io=0x%X irq=%d)\n",
 		dev->name, iobase, irq);
 
 	return self;
+ err_out5:
+	kfree(self->tx_buff.head);
+ err_out4:
+	kfree_skb(self->rx_buff.skb);
+ err_out3:
+	free_netdev(dev);
+	dev_self[i] = NULL;
+ err_out2:
+	release_region(iobase, IO_EXTENT);
+ err_out1:
+	return NULL;
 }
 
 int irport_close(struct irport_cb *self)
 {
+	struct net_device *dev = self->netdev;
+
 	ASSERT(self != NULL, return -1;);
 
 	/* We are not using any dongle anymore! */
@@ -267,8 +265,7 @@
 	self->dongle = NULL;
 	
 	/* Remove netdevice */
-	if (self->netdev)
-		unregister_netdev(self->netdev);
+	unregister_netdev(dev);
 
 	/* Release the IO-port that this driver is using */
 	IRDA_DEBUG(0 , "%s(), Releasing Region %03x\n", 
@@ -284,7 +281,7 @@
 	
 	/* Remove ourselves */
 	dev_self[self->index] = NULL;
-	kfree(self);
+	free_netdev(dev);
 	
 	return 0;
 }
@@ -886,15 +883,6 @@
 	return IRQ_RETVAL(handled);
 }
 
-static int irport_net_init(struct net_device *dev)
-{
-	/* Set up to be a normal IrDA network device driver */
-	irda_device_setup(dev);
-
-	/* Insert overrides below this line! */
-
-	return 0;
-}
 
 /*
  * Function irport_net_open (dev)
diff -urN -X dontdiff linux-2.5/drivers/net/irda/sa1100_ir.c linux-2.5-net/drivers/net/irda/sa1100_ir.c
--- linux-2.5/drivers/net/irda/sa1100_ir.c	2003-06-05 10:04:37.000000000 -0700
+++ linux-2.5-net/drivers/net/irda/sa1100_ir.c	2003-09-17 15:49:30.000000000 -0700
@@ -1132,12 +1132,8 @@
 	release_mem_region(__PREG(Ser2HSCR0), 0x1c);
 	release_mem_region(__PREG(Ser2UTCR0), 0x24);
 
-	/*
-	 * We now know that the netdevice is no longer in use, and all
-	 * references to our driver have been removed.  The only structure
-	 * which may still be present is the netdevice, which will get
-	 * cleaned up by net/core/dev.c
-	 */
+	if(dev)
+		free_netdev(dev);
 }
 
 static int __init sa1100ir_setup(char *line)
diff -urN -X dontdiff linux-2.5/drivers/net/irda/smsc-ircc2.c linux-2.5-net/drivers/net/irda/smsc-ircc2.c
--- linux-2.5/drivers/net/irda/smsc-ircc2.c	2003-06-05 10:04:37.000000000 -0700
+++ linux-2.5-net/drivers/net/irda/smsc-ircc2.c	2003-09-18 10:39:48.000000000 -0700
@@ -140,10 +140,10 @@
 
 static int smsc_ircc_open(unsigned int firbase, unsigned int sirbase, u8 dma, u8 irq);
 static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base);
-static int smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq);
+static void smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq);
 static int smsc_ircc_setup_buffers(struct smsc_ircc_cb *self);
 static void smsc_ircc_setup_qos(struct smsc_ircc_cb *self);
-static int smsc_ircc_setup_netdev(struct smsc_ircc_cb *self);
+static void smsc_ircc_netdev_setup(struct net_device *dev);
 static void smsc_ircc_init_chip(struct smsc_ircc_cb *self);
 static int __exit smsc_ircc_close(struct smsc_ircc_cb *self);
 static int  smsc_ircc_dma_receive(struct smsc_ircc_cb *self, int iobase); 
@@ -366,38 +366,48 @@
 static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
 {
 	struct smsc_ircc_cb *self;
+	struct net_device *dev;
 	int err;
 	
 	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
 
-	err= smsc_ircc_present(fir_base, sir_base);
-	if(err) return -ENODEV;
+	err = smsc_ircc_present(fir_base, sir_base);
+	if(err) 
+		goto out;
 		
-	if (dev_count>DIM(dev_self)) {
+	if (dev_count > DIM(dev_self)) {
 	        WARNING("%s(), too many devices!\n", __FUNCTION__);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out1;
 	}
 
 	/*
 	 *  Allocate new instance of the driver
 	 */
-	self = kmalloc(sizeof(struct smsc_ircc_cb), GFP_KERNEL);
-	if (self == NULL) {
-		ERROR("%s, Can't allocate memory for control block!\n",
-                      driver_name);
-		return -ENOMEM;
+	dev = alloc_netdev(sizeof(*self), "irda%d", 
+			   smsc_ircc_netdev_setup);
+	if (!dev) {
+		WARNING("%s() can't allocate net device\n", __FUNCTION__);
+		err = -ENOMEM;
+		goto out1;
 	}
-	memset(self, 0, sizeof(struct smsc_ircc_cb));
+
+	self = dev->priv;
+	self->netdev = dev;
+
+	/* Make ifconfig display some details */
+	dev->base_addr = self->io.fir_base = fir_base;
+	dev->irq = self->io.irq = irq;
 
 	/* Need to store self somewhere */
 	dev_self[dev_count++] = self;
 	spin_lock_init(&self->lock);
 
 	err = smsc_ircc_setup_buffers(self);
-	if(err) return err;
+	if(err)
+		goto out2;
 	   
-	err= smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq);
-	if(err) return err;
+	smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq);
 
 	smsc_ircc_setup_qos(self);
 
@@ -405,17 +415,32 @@
 		
 	smsc_ircc_init_chip(self);
 	
-	if(ircc_transceiver > 0 && ircc_transceiver < SMSC_IRCC2_C_NUMBER_OF_TRANSCEIVERS) self->transceiver = ircc_transceiver;
-	else smsc_ircc_probe_transceiver(self);
+	if(ircc_transceiver > 0  && 
+	   ircc_transceiver < SMSC_IRCC2_C_NUMBER_OF_TRANSCEIVERS)
+		self->transceiver = ircc_transceiver;
+	else
+		smsc_ircc_probe_transceiver(self);
 
-	err = smsc_ircc_setup_netdev(self);
-	if(err) return err;
+	err = register_netdev(self->netdev);
+	if(err)
+		goto out2;
 
 	self->pmdev = pm_register(PM_SYS_DEV, PM_SYS_IRDA, smsc_ircc_pmproc);
 	if (self->pmdev)
 		self->pmdev->data = self;
 
+	MESSAGE("IrDA: Registered device %s\n", dev->name);
+
 	return 0;
+ out2:
+	kfree(self->tx_buff.head);
+	kfree(self->rx_buff.head);
+	free_netdev(self->netdev);
+ out1:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+	release_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT);
+ out:
+	return err;
 }
 
 /*
@@ -428,18 +453,19 @@
 {
 	unsigned char low, high, chip, config, dma, irq, version;
 
-	if (check_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT) < 0) {
+	if (!request_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT,
+			    driver_name)) {
 		WARNING("%s: can't get fir_base of 0x%03x\n",
 			__FUNCTION__, fir_base);
-		return -ENODEV;
+		goto out1;
 	}
-#if POSSIBLE_USED_BY_SERIAL_DRIVER
-	if (check_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT) < 0) {
+
+	if (!request_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT,
+			    driver_name)) {
 		WARNING("%s: can't get sir_base of 0x%03x\n",
 			__FUNCTION__, sir_base);
-		return -ENODEV;
+		goto out2;
 	}
-#endif
 
 	register_bank(fir_base, 3);
 
@@ -454,13 +480,19 @@
 	if (high != 0x10 || low != 0xb8 || (chip != 0xf1 && chip != 0xf2)) { 
 	        WARNING("%s(), addr 0x%04x - no device found!\n",
 			__FUNCTION__, fir_base);
-		return -ENODEV;
+		goto out3;
 	}
 	MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
 		"firport 0x%03x, sirport 0x%03x dma=%d, irq=%d\n",
 		chip & 0x0f, version, fir_base, sir_base, dma, irq);
 
 	return 0;
+ out3:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+ out2:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+ out1:
+	return -ENODEV;
 }
 
 /*
@@ -510,10 +542,11 @@
  *    Setup I/O
  *
  */
-static int smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
+static void smsc_ircc_setup_io(struct smsc_ircc_cb *self, 
+			       unsigned int fir_base, unsigned int sir_base, 
+			       u8 dma, u8 irq)
 {
 	unsigned char config, chip_dma, chip_irq;
-	void *ret;
 
 	register_bank(fir_base, 3);
 	config  = inb(fir_base+IRCC_INTERFACE);
@@ -545,27 +578,6 @@
 	else
 		self->io.dma = chip_dma;
 
-	ret = request_region(self->io.fir_base, self->io.fir_ext, driver_name);
-	if (!ret) { 
-		WARNING("%s(), can't get iobase of 0x%03x\n",
-			__FUNCTION__, self->io.fir_base);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENODEV;
-	}
-	ret = request_region(self->io.sir_base, self->io.sir_ext, driver_name);
-	if (!ret) { 
-		WARNING("%s(), can't get iobase of 0x%03x\n",
-			__FUNCTION__, self->io.sir_base);
-		release_region(self->io.fir_base, self->io.fir_ext);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENODEV;
-	}
-
-	return 0;
 }
 
 /*
@@ -634,57 +646,19 @@
 	outb(0x00, iobase+IRCC_MASTER);
 }
 
-/*
- * Function smsc_ircc_setup_netdev(self)
- *
- *    Alloc and setup network device
- *
- */
-static int smsc_ircc_setup_netdev(struct smsc_ircc_cb *self)
+static void smsc_ircc_netdev_setup(struct net_device *dev)
 {
-	struct net_device *dev;
-	int err;
-	/* Alloc netdev */
-
-	if (!(dev = dev_alloc("irda%d", &err))) {
-		ERROR("%s(), dev_alloc() failed!\n", __FUNCTION__);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENOMEM;
-	}
-
-	dev->priv = (void *) self;
-	self->netdev = dev;
-
 	dev->init            = smsc_ircc_net_init;
 	dev->hard_start_xmit = smsc_ircc_hard_xmit_sir;
-	#if SMSC_IRCC2_C_NET_TIMEOUT
+#if SMSC_IRCC2_C_NET_TIMEOUT
 	dev->tx_timeout	     = smsc_ircc_timeout;
 	dev->watchdog_timeo  = HZ*2;  /* Allow enough time for speed change */
-	#endif
+#endif
 	dev->open            = smsc_ircc_net_open;
 	dev->stop            = smsc_ircc_net_close;
 	dev->do_ioctl        = smsc_ircc_net_ioctl;
 	dev->get_stats	     = smsc_ircc_net_get_stats;
 	
-	/* Make ifconfig display some details */
-	dev->base_addr = self->io.fir_base;
-	dev->irq = self->io.irq;
-
-	rtnl_lock();
-	err = register_netdevice(dev);
-	rtnl_unlock();
-	if (err) {
-		ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENODEV;
-	}
-	MESSAGE("IrDA: Registered device %s\n", dev->name);
-
-	return 0;
 }
 
 /*
@@ -1734,22 +1708,22 @@
 {
 	int iobase;
 	unsigned long flags;
+	struct net_device *dev;
 
 	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
 
 	ASSERT(self != NULL, return -1;);
 
+	dev = self->netdev;
+	ASSERT(dev != NULL, return -1;);
+
 	iobase = self->io.fir_base;
 
 	if (self->pmdev)
 		pm_unregister(self->pmdev);
 
 	/* Remove netdevice */
-	if (self->netdev) {
-		rtnl_lock();
-		unregister_netdevice(self->netdev);
-		rtnl_unlock();
-	}
+	unregister_netdev(dev);
 
 	/* Make sure the irq handler is not exectuting */
 	spin_lock_irqsave(&self->lock, flags);
@@ -1784,7 +1758,7 @@
 	if (self->rx_buff.head)
 		kfree(self->rx_buff.head);
 
-	kfree(self);
+	free_netdev(dev);
 
 	return 0;
 }
diff -urN -X dontdiff linux-2.5/net/irda/irda_device.c linux-2.5-net/net/irda/irda_device.c
--- linux-2.5/net/irda/irda_device.c	2003-09-08 09:17:23.000000000 -0700
+++ linux-2.5-net/net/irda/irda_device.c	2003-09-19 22:29:17.000000000 -0700
@@ -378,8 +378,6 @@
         dev->hard_header_len = 0;
         dev->addr_len        = 0;
 
-	dev->destructor      = free_netdev;
-
         dev->type            = ARPHRD_IRDA;
         dev->tx_queue_len    = 8; /* Window size + 1 s-frame */
 
