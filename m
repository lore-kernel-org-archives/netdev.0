From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/16) irport -- convert to alloc_irdadev
Date: Tue, 30 Sep 2003 15:01:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150144.2cc2e704.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6.0-test6, convert irport to use alloc_irdadev and use dev->priv
cleanup the error unwind code path

diff -Nru a/drivers/net/irda/irport.c b/drivers/net/irda/irport.c
--- a/drivers/net/irda/irport.c	Tue Sep 30 11:56:21 2003
+++ b/drivers/net/irda/irport.c	Tue Sep 30 11:56:21 2003
@@ -78,7 +78,6 @@
 static inline int  irport_write(int iobase, int fifo_size, __u8 *buf, int len);
 static inline void irport_receive(struct irport_cb *self);
 
-static int  irport_net_init(struct net_device *dev);
 static int  irport_net_ioctl(struct net_device *dev, struct ifreq *rq, 
 			     int cmd);
 static inline int  irport_is_receiving(struct irport_cb *self);
@@ -136,30 +135,27 @@
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
+	dev = alloc_irdadev(sizeof(struct irport_cb));
+	if (!dev) {
 		ERROR("%s(), can't allocate memory for "
-		      "control block!\n", __FUNCTION__);
-		release_region(iobase, IO_EXTENT);
-		return NULL;
+		      "irda device!\n", __FUNCTION__);
+		goto err_out2;
 	}
-	memset(self, 0, sizeof(struct irport_cb));
+
+	self = dev->priv;
 	spin_lock_init(&self->lock);
 
 	/* Need to store self somewhere */
@@ -189,8 +185,11 @@
 	self->rx_buff.truesize = IRDA_SKB_MAX_MTU;
 	self->rx_buff.skb = __dev_alloc_skb(self->rx_buff.truesize,
 					    GFP_KERNEL);
-	if (self->rx_buff.skb == NULL)
-		return NULL;
+	if (self->rx_buff.skb == NULL) {
+		ERROR("%s(), can't allocate memory for "
+		      "receive buffer!\n", __FUNCTION__);
+		goto err_out3;
+	}
 	skb_reserve(self->rx_buff.skb, 1);
 	self->rx_buff.head = self->rx_buff.skb->data;
 	/* No need to memset the buffer, unless you are really pedantic */
@@ -208,30 +207,23 @@
 		self->tx_buff.head = (__u8 *) kmalloc(self->tx_buff.truesize, 
 						      GFP_KERNEL);
 		if (self->tx_buff.head == NULL) {
-			kfree_skb(self->rx_buff.skb);
-			self->rx_buff.skb = NULL;
-			self->rx_buff.head = NULL;
-			return NULL;
+			ERROR("%s(), can't allocate memory for "
+			      "transmit buffer!\n", __FUNCTION__);
+			goto err_out4;
 		}
 		memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 	}	
 	self->tx_buff.data = self->tx_buff.head;
 
-	if (!(dev = dev_alloc("irda%d", &err))) {
-		ERROR("%s(), dev_alloc() failed!\n", __FUNCTION__);
-		return NULL;
-	}
 	self->netdev = dev;
 	/* Keep track of module usage */
 	SET_MODULE_OWNER(dev);
 
 	/* May be overridden by piggyback drivers */
- 	dev->priv = (void *) self;
 	self->interrupt    = irport_interrupt;
 	self->change_speed = irport_change_speed;
 
 	/* Override the network functions we need to use */
-	dev->init            = irport_net_init;
 	dev->hard_start_xmit = irport_hard_xmit;
 	dev->tx_timeout	     = irport_timeout;
 	dev->watchdog_timeo  = HZ;  /* Allow time enough for speed change */
@@ -244,17 +236,25 @@
 	dev->base_addr = iobase;
 	dev->irq = irq;
 
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
@@ -267,8 +267,7 @@
 	self->dongle = NULL;
 	
 	/* Remove netdevice */
-	if (self->netdev)
-		unregister_netdev(self->netdev);
+	unregister_netdev(self->netdev);
 
 	/* Release the IO-port that this driver is using */
 	IRDA_DEBUG(0 , "%s(), Releasing Region %03x\n", 
@@ -284,7 +283,7 @@
 	
 	/* Remove ourselves */
 	dev_self[self->index] = NULL;
-	kfree(self);
+	free_netdev(self->netdev);
 	
 	return 0;
 }
@@ -884,16 +883,6 @@
 
 	spin_unlock(&self->lock);
 	return IRQ_RETVAL(handled);
-}
-
-static int irport_net_init(struct net_device *dev)
-{
-	/* Set up to be a normal IrDA network device driver */
-	irda_device_setup(dev);
-
-	/* Insert overrides below this line! */
-
-	return 0;
 }
 
 /*
