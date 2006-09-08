From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2/2] pcnet32:  Magic number cleanup
Date: Fri, 8 Sep 2006 15:40:41 -0700
Message-ID: <20060908224041.GA24369@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36573 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751217AbWIHWj7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 18:39:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k88Mdut5011421
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 18:39:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k88MduIi248220
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 16:39:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k88Mdt9N022142
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 16:39:56 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initial magic number cleanup.  Delete one unnecessary read and write.
Tested ia32 and ppc64.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.napi	Fri Sep  8 13:19:53 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Fri Sep  8 13:57:13 2006
@@ -213,7 +213,7 @@ static int homepna[MAX_UNITS];
 /* The PCNET32 Rx and Tx ring descriptors. */
 struct pcnet32_rx_head {
 	u32	base;
-	s16	buf_length;
+	s16	buf_length;	/* two`s complement of length */
 	s16	status;
 	u32	msg_length;
 	u32	reserved;
@@ -221,7 +221,7 @@ struct pcnet32_rx_head {
 
 struct pcnet32_tx_head {
 	u32	base;
-	s16	length;
+	s16	length;		/* two`s complement of length */
 	s16	status;
 	u32	misc;
 	u32	reserved;
@@ -901,7 +901,7 @@ static int pcnet32_loopback_test(struct 
 
 	/* Reset the PCNET32 */
 	lp->a.reset(ioaddr);
-	lp->a.write_csr(ioaddr, CSR4, 0x0915);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
@@ -1393,7 +1393,7 @@ static int pcnet32_poll(struct net_devic
 	if (pcnet32_tx(dev)) {
 		/* reset the chip to clear the error condition, then restart */
 		lp->a.reset(ioaddr);
-		lp->a.write_csr(ioaddr, CSR4, 0x0915);
+		lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 		pcnet32_restart(dev, CSR0_START);
 		netif_wake_queue(dev);
 	}
@@ -1901,7 +1901,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 		 * boards will work.
 		 */
 		/* Trigger an initialization just for the interrupt. */
-		a->write_csr(ioaddr, 0, 0x41);
+		a->write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_INIT);
 		mdelay(1);
 
 		dev->irq = probe_irq_off(irq_mask);
@@ -2268,9 +2268,9 @@ static int pcnet32_open(struct net_devic
 
 #ifdef DO_DXSUFLO
 	if (lp->dxsuflo) {	/* Disable transmit stop on underflow */
-		val = lp->a.read_csr(ioaddr, 3);
+		val = lp->a.read_csr(ioaddr, CSR3);
 		val |= 0x40;
-		lp->a.write_csr(ioaddr, 3, val);
+		lp->a.write_csr(ioaddr, CSR3, val);
 	}
 #endif
 
@@ -2291,8 +2291,8 @@ static int pcnet32_open(struct net_devic
 			(lp->dma_addr +
 			 offsetof(struct pcnet32_private, init_block)) >> 16);
 
-	lp->a.write_csr(ioaddr, 4, 0x0915);
-	lp->a.write_csr(ioaddr, 0, 0x0001);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
 
 	netif_start_queue(dev);
 
@@ -2304,13 +2304,13 @@ static int pcnet32_open(struct net_devic
 
 	i = 0;
 	while (i++ < 100)
-		if (lp->a.read_csr(ioaddr, 0) & 0x0100)
+		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_IDON)
 			break;
 	/*
 	 * We used to clear the InitDone bit, 0x0100, here but Mark Stockton
 	 * reports that doing so triggers a bug in the '974.
 	 */
-	lp->a.write_csr(ioaddr, 0, 0x0042);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_NORMAL);
 
 	if (netif_msg_ifup(lp))
 		printk(KERN_DEBUG
@@ -2318,7 +2318,7 @@ static int pcnet32_open(struct net_devic
 		       dev->name, i,
 		       (u32) (lp->dma_addr +
 			      offsetof(struct pcnet32_private, init_block)),
-		       lp->a.read_csr(ioaddr, 0));
+		       lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2389,7 +2389,7 @@ static int pcnet32_init_ring(struct net_
 			    (rx_skbuff = lp->rx_skbuff[i] =
 			     dev_alloc_skb(PKT_BUF_SZ))) {
 				/* there is not much, we can do at this point */
-				if (pcnet32_debug & NETIF_MSG_DRV)
+				if (netif_msg_drv(lp))
 					printk(KERN_ERR
 					       "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
 					       dev->name);
@@ -2439,7 +2439,7 @@ static void pcnet32_restart(struct net_d
 
 	/* wait for stop */
 	for (i = 0; i < 100; i++)
-		if (lp->a.read_csr(ioaddr, 0) & 0x0004)
+		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_STOP)
 			break;
 
 	if (i >= 100 && netif_msg_drv(lp))
@@ -2452,13 +2452,13 @@ static void pcnet32_restart(struct net_d
 		return;
 
 	/* ReInit Ring */
-	lp->a.write_csr(ioaddr, 0, 1);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
 	i = 0;
 	while (i++ < 1000)
-		if (lp->a.read_csr(ioaddr, 0) & 0x0100)
+		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_IDON)
 			break;
 
-	lp->a.write_csr(ioaddr, 0, csr0_bits);
+	lp->a.write_csr(ioaddr, CSR0, csr0_bits);
 }
 
 static void pcnet32_tx_timeout(struct net_device *dev)
@@ -2471,8 +2471,8 @@ static void pcnet32_tx_timeout(struct ne
 	if (pcnet32_debug & NETIF_MSG_DRV)
 		printk(KERN_ERR
 		       "%s: transmit timed out, status %4.4x, resetting.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
-	lp->a.write_csr(ioaddr, 0, 0x0004);
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
 	lp->stats.tx_errors++;
 	if (netif_msg_tx_err(lp)) {
 		int i;
@@ -2494,7 +2494,7 @@ static void pcnet32_tx_timeout(struct ne
 			       le16_to_cpu(lp->tx_ring[i].status));
 		printk("\n");
 	}
-	pcnet32_restart(dev, 0x0042);
+	pcnet32_restart(dev, CSR0_NORMAL);
 
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -2515,7 +2515,7 @@ static int pcnet32_start_xmit(struct sk_
 	if (netif_msg_tx_queued(lp)) {
 		printk(KERN_DEBUG
 		       "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	}
 
 	/* Default status -- will not enable Successful-TxDone
@@ -2546,7 +2546,7 @@ static int pcnet32_start_xmit(struct sk_
 	lp->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
-	lp->a.write_csr(ioaddr, 0, 0x0048);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
 
 	dev->trans_start = jiffies;
 
@@ -2633,7 +2633,7 @@ pcnet32_interrupt(int irq, void *dev_id,
 		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, CSR4, 0x0915);
+			lp->a.write_csr(ioaddr, CSR4, 0x0915); /* auto tx pad */
 			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
@@ -2672,10 +2672,10 @@ static int pcnet32_close(struct net_devi
 	if (netif_msg_ifdown(lp))
 		printk(KERN_DEBUG
 		       "%s: Shutting down ethercard, status was %2.2x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 
 	/* We stop the PCNET32 here -- it occasionally polls memory if we don't. */
-	lp->a.write_csr(ioaddr, 0, 0x0004);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
 
 	/*
 	 * Switch back to 16bit mode to avoid problems with dumb
@@ -2701,13 +2701,10 @@ static struct net_device_stats *pcnet32_
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long ioaddr = dev->base_addr;
-	u16 saved_addr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	saved_addr = lp->a.read_rap(ioaddr);
 	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
-	lp->a.write_rap(ioaddr, saved_addr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return &lp->stats;
-- 
Don Fry
brazilnut@us.ibm.com
