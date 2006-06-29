From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 9/9] pcnet32: Magic number cleanup.
Date: Thu, 29 Jun 2006 13:56:20 -0700
Message-ID: <20060629205620.GA22036@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:55003 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932507AbWF2U4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:56:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKu4HE018189
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:56:04 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKu4RC227222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:56:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKu446007713
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:56:04 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Initial magic number cleanup.  Delete one unnecessary read and write.
Tested ia32 and ppc64.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/napi.pcnet32.c	Thu Jun 29 13:25:50 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Thu Jun 29 13:30:46 2006
@@ -211,7 +211,7 @@ static int homepna[MAX_UNITS];
 /* The PCNET32 Rx and Tx ring descriptors. */
 struct pcnet32_rx_head {
 	u32	base;
-	s16	buf_length;
+	s16	buf_length;	/* two`s complement of length */
 	s16	status;
 	u32	msg_length;
 	u32	reserved;
@@ -219,7 +219,7 @@ struct pcnet32_rx_head {
 
 struct pcnet32_tx_head {
 	u32	base;
-	s16	length;
+	s16	length;		/* two`s complement of length */
 	s16	status;
 	u32	misc;
 	u32	reserved;
@@ -896,7 +896,7 @@ static int pcnet32_loopback_test(struct 
 
 	/* Reset the PCNET32 */
 	lp->a.reset(ioaddr);
-	lp->a.write_csr(ioaddr, CSR4, 0x0915);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
@@ -1384,7 +1384,7 @@ static int pcnet32_poll(struct net_devic
 	if (pcnet32_tx(dev)) {
 		/* reset the chip to clear the error condition, then restart */
 		lp->a.reset(ioaddr);
-		lp->a.write_csr(ioaddr, CSR4, 0x0915);
+		lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 		pcnet32_restart(dev, CSR0_START);
 		netif_wake_queue(dev);
 	}
@@ -1891,7 +1891,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 		 * boards will work.
 		 */
 		/* Trigger an initialization just for the interrupt. */
-		a->write_csr(ioaddr, 0, 0x41);
+		a->write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_INIT);
 		mdelay(1);
 
 		dev->irq = probe_irq_off(irq_mask);
@@ -2261,9 +2261,9 @@ static int pcnet32_open(struct net_devic
 
 #ifdef DO_DXSUFLO
 	if (lp->dxsuflo) {	/* Disable transmit stop on underflow */
-		val = lp->a.read_csr(ioaddr, 3);
+		val = lp->a.read_csr(ioaddr, CSR3);
 		val |= 0x40;
-		lp->a.write_csr(ioaddr, 3, val);
+		lp->a.write_csr(ioaddr, CSR3, val);
 	}
 #endif
 
@@ -2284,8 +2284,8 @@ static int pcnet32_open(struct net_devic
 			(lp->dma_addr +
 			 offsetof(struct pcnet32_private, init_block)) >> 16);
 
-	lp->a.write_csr(ioaddr, 4, 0x0915);
-	lp->a.write_csr(ioaddr, 0, 0x0001);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
 
 	netif_start_queue(dev);
 
@@ -2295,13 +2295,13 @@ static int pcnet32_open(struct net_devic
 
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
@@ -2309,7 +2309,7 @@ static int pcnet32_open(struct net_devic
 		       dev->name, i,
 		       (u32) (lp->dma_addr +
 			      offsetof(struct pcnet32_private, init_block)),
-		       lp->a.read_csr(ioaddr, 0));
+		       lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2380,7 +2380,7 @@ static int pcnet32_init_ring(struct net_
 			    (rx_skbuff = lp->rx_skbuff[i] =
 			     dev_alloc_skb(PKT_BUF_SZ))) {
 				/* there is not much, we can do at this point */
-				if (pcnet32_debug & NETIF_MSG_DRV)
+				if (netif_msg_drv(lp))
 					printk(KERN_ERR
 					       "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
 					       dev->name);
@@ -2430,7 +2430,7 @@ static void pcnet32_restart(struct net_d
 
 	/* wait for stop */
 	for (i = 0; i < 100; i++)
-		if (lp->a.read_csr(ioaddr, 0) & 0x0004)
+		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_STOP)
 			break;
 
 	if (i >= 100 && netif_msg_drv(lp))
@@ -2443,13 +2443,13 @@ static void pcnet32_restart(struct net_d
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
@@ -2462,8 +2462,8 @@ static void pcnet32_tx_timeout(struct ne
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
@@ -2485,7 +2485,7 @@ static void pcnet32_tx_timeout(struct ne
 			       le16_to_cpu(lp->tx_ring[i].status));
 		printk("\n");
 	}
-	pcnet32_restart(dev, 0x0042);
+	pcnet32_restart(dev, CSR0_NORMAL);
 
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -2506,7 +2506,7 @@ static int pcnet32_start_xmit(struct sk_
 	if (netif_msg_tx_queued(lp)) {
 		printk(KERN_DEBUG
 		       "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	}
 
 	/* Default status -- will not enable Successful-TxDone
@@ -2537,7 +2537,7 @@ static int pcnet32_start_xmit(struct sk_
 	lp->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
-	lp->a.write_csr(ioaddr, 0, 0x0048);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
 
 	dev->trans_start = jiffies;
 
@@ -2623,7 +2623,7 @@ pcnet32_interrupt(int irq, void *dev_id,
 		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, CSR4, 0x0915);
+			lp->a.write_csr(ioaddr, CSR4, 0x0915); /* auto tx pad */
 			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
@@ -2662,10 +2662,10 @@ static int pcnet32_close(struct net_devi
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
@@ -2691,13 +2691,10 @@ static struct net_device_stats *pcnet32_
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
