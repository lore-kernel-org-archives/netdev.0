From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (15/16) smsc-ircc2 -- convert to alloc_irdadev
Date: Tue, 30 Sep 2003 15:19:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930151906.2c51fe58.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than two allocations, use alloc_iradev and dev->priv
to hold local data.  Move the setup code for network device and buffer
inline since it cleans up the error unwind.

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:37:56 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:37:56 2003
@@ -141,9 +141,7 @@
 static int smsc_ircc_open(unsigned int firbase, unsigned int sirbase, u8 dma, u8 irq);
 static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base);
 static void smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq);
-static int smsc_ircc_setup_buffers(struct smsc_ircc_cb *self);
 static void smsc_ircc_setup_qos(struct smsc_ircc_cb *self);
-static int smsc_ircc_setup_netdev(struct smsc_ircc_cb *self);
 static void smsc_ircc_init_chip(struct smsc_ircc_cb *self);
 static int __exit smsc_ircc_close(struct smsc_ircc_cb *self);
 static int  smsc_ircc_dma_receive(struct smsc_ircc_cb *self, int iobase); 
@@ -163,7 +161,6 @@
 #endif
 static void smsc_ircc_sir_write_wakeup(struct smsc_ircc_cb *self);
 static int  smsc_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len);
-static int  smsc_ircc_net_init(struct net_device *dev);
 static int  smsc_ircc_net_open(struct net_device *dev);
 static int  smsc_ircc_net_close(struct net_device *dev);
 static int  smsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -366,6 +363,7 @@
 static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
 {
 	struct smsc_ircc_cb *self;
+	struct net_device *dev;
 	int err;
 	
 	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
@@ -383,21 +381,61 @@
 	/*
 	 *  Allocate new instance of the driver
 	 */
-	self = kmalloc(sizeof(struct smsc_ircc_cb), GFP_KERNEL);
-	if (self == NULL) {
-		ERROR("%s, Can't allocate memory for control block!\n",
-                      driver_name);
+	dev = alloc_irdadev(sizeof(struct smsc_ircc_cb));
+	if (!dev) {
+		WARNING("%s() can't allocate net device\n", __FUNCTION__);
 		goto err_out1;
 	}
-	memset(self, 0, sizeof(struct smsc_ircc_cb));
+
+	SET_MODULE_OWNER(dev);
+
+	dev->hard_start_xmit = smsc_ircc_hard_xmit_sir;
+#if SMSC_IRCC2_C_NET_TIMEOUT
+	dev->tx_timeout	     = smsc_ircc_timeout;
+	dev->watchdog_timeo  = HZ*2;  /* Allow enough time for speed change */
+#endif
+	dev->open            = smsc_ircc_net_open;
+	dev->stop            = smsc_ircc_net_close;
+	dev->do_ioctl        = smsc_ircc_net_ioctl;
+	dev->get_stats	     = smsc_ircc_net_get_stats;
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
 
-	err = smsc_ircc_setup_buffers(self);
-	if(err)
-		goto err_out1;
+	self->rx_buff.truesize = SMSC_IRCC2_RX_BUFF_TRUESIZE; 
+	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
+
+	self->rx_buff.head = (u8 *) kmalloc(self->rx_buff.truesize,
+					      GFP_KERNEL|GFP_DMA);
+	if (self->rx_buff.head == NULL) {
+		ERROR("%s, Can't allocate memory for receive buffer!\n",
+                      driver_name);
+		goto err_out2;
+	}
+
+	self->tx_buff.head = (u8 *) kmalloc(self->tx_buff.truesize, 
+					      GFP_KERNEL|GFP_DMA);
+	if (self->tx_buff.head == NULL) {
+		ERROR("%s, Can't allocate memory for transmit buffer!\n",
+                      driver_name);
+		goto err_out3;
+	}
+
+	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
+	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
+
+	self->rx_buff.in_frame = FALSE;
+	self->rx_buff.state = OUTSIDE_FRAME;
+	self->tx_buff.data = self->tx_buff.head;
+	self->rx_buff.data = self->rx_buff.head;
 	   
 	smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq);
 
@@ -413,17 +451,27 @@
 	else
 		smsc_ircc_probe_transceiver(self);
 
-
-	err = smsc_ircc_setup_netdev(self);
-	if(err) 
-		goto err_out1;
+	err = register_netdev(self->netdev);
+	if(err) {
+		ERROR("%s, Network device registration failed!\n",
+		      driver_name);
+		goto err_out4;
+	}
 
 	self->pmdev = pm_register(PM_SYS_DEV, PM_SYS_IRDA, smsc_ircc_pmproc);
 	if (self->pmdev)
 		self->pmdev->data = self;
 
-	return 0;
+	MESSAGE("IrDA: Registered device %s\n", dev->name);
 
+	return 0;
+ err_out4:
+	kfree(self->tx_buff.head);
+ err_out3:
+	kfree(self->rx_buff.head);
+ err_out2:
+	free_netdev(self->netdev);
+	dev_self[--dev_count] = NULL;
  err_out1:
 	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
 	release_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT);
@@ -455,7 +503,6 @@
 		goto out2;
 	}
 
-
 	register_bank(fir_base, 3);
 
 	high    = inb(fir_base+IRCC_ID_HIGH);
@@ -471,7 +518,6 @@
 			__FUNCTION__, fir_base);
 		goto out3;
 	}
-
 	MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
 		"firport 0x%03x, sirport 0x%03x dma=%d, irq=%d\n",
 		chip & 0x0f, version, fir_base, sir_base, dma, irq);
@@ -486,47 +532,6 @@
 }
 
 /*
- * Function smsc_ircc_setup_buffers(self)
- *
- *    Setup RX/TX buffers
- *
- */
-static int smsc_ircc_setup_buffers(struct smsc_ircc_cb *self)
-{
-	self->rx_buff.truesize = SMSC_IRCC2_RX_BUFF_TRUESIZE; 
-	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
-
-	self->rx_buff.head = (u8 *) kmalloc(self->rx_buff.truesize,
-					      GFP_KERNEL|GFP_DMA);
-	if (self->rx_buff.head == NULL) {
-		ERROR("%s, Can't allocate memory for receive buffer!\n",
-                      driver_name);
-		kfree(self);
-		return -ENOMEM;
-	}
-
-	self->tx_buff.head = (u8 *) kmalloc(self->tx_buff.truesize, 
-					      GFP_KERNEL|GFP_DMA);
-	if (self->tx_buff.head == NULL) {
-		ERROR("%s, Can't allocate memory for transmit buffer!\n",
-                      driver_name);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENOMEM;
-	}
-
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
-
-	self->rx_buff.in_frame = FALSE;
-	self->rx_buff.state = OUTSIDE_FRAME;
-	self->tx_buff.data = self->tx_buff.head;
-	self->rx_buff.data = self->rx_buff.head;
-
-	return 0;
-}
-
-/*
  * Function smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq)
  *
  *    Setup I/O
@@ -637,57 +642,6 @@
 }
 
 /*
- * Function smsc_ircc_setup_netdev(self)
- *
- *    Alloc and setup network device
- *
- */
-static int smsc_ircc_setup_netdev(struct smsc_ircc_cb *self)
-{
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
-	dev->init            = smsc_ircc_net_init;
-	dev->hard_start_xmit = smsc_ircc_hard_xmit_sir;
-	#if SMSC_IRCC2_C_NET_TIMEOUT
-	dev->tx_timeout	     = smsc_ircc_timeout;
-	dev->watchdog_timeo  = HZ*2;  /* Allow enough time for speed change */
-	#endif
-	dev->open            = smsc_ircc_net_open;
-	dev->stop            = smsc_ircc_net_close;
-	dev->do_ioctl        = smsc_ircc_net_ioctl;
-	dev->get_stats	     = smsc_ircc_net_get_stats;
-	
-	/* Make ifconfig display some details */
-	dev->base_addr = self->io.fir_base;
-	dev->irq = self->io.irq;
-
-	err = register_netdev(dev);
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
-}
-
-/*
  * Function smsc_ircc_net_ioctl (dev, rq, cmd)
  *
  *    Process IOCTL commands for this device
@@ -1571,18 +1525,6 @@
 }
 #endif /* unused */
 
-static int smsc_ircc_net_init(struct net_device *dev)
-{
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
-
-	/* Set up to be a normal IrDA network device driver */
-	irda_device_setup(dev);
-
-	/* Insert overrides below this line! */
-
-	return 0;
-}
 
 /*
  * Function smsc_ircc_net_open (dev)
@@ -1745,8 +1687,7 @@
 		pm_unregister(self->pmdev);
 
 	/* Remove netdevice */
-	if (self->netdev) 
-		unregister_netdev(self->netdev);
+	unregister_netdev(self->netdev);
 
 	/* Make sure the irq handler is not exectuting */
 	spin_lock_irqsave(&self->lock, flags);
@@ -1781,7 +1722,7 @@
 	if (self->rx_buff.head)
 		kfree(self->rx_buff.head);
 
-	kfree(self);
+	free_netdev(self->netdev);
 
 	return 0;
 }
