From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2/5] pcnet32:  magic number cleanup
Date: Wed, 13 Sep 2006 10:16:07 -0700
Message-ID: <20060913171607.GA12751@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48551 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750795AbWIMRPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 13:15:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHFKja007138
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHFK95292232
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHFJeA003705
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:15:20 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change some magic numbers to clearer names.  A few whitespace changes.

Tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.rap	Tue Sep 12 10:09:12 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Tue Sep 12 10:25:09 2006
@@ -207,7 +207,7 @@ static int homepna[MAX_UNITS];
 /* The PCNET32 Rx and Tx ring descriptors. */
 struct pcnet32_rx_head {
 	u32	base;
-	s16	buf_length;
+	s16	buf_length;	/* two`s complement of length */
 	s16	status;
 	u32	msg_length;
 	u32	reserved;
@@ -215,7 +215,7 @@ struct pcnet32_rx_head {
 
 struct pcnet32_tx_head {
 	u32	base;
-	s16	length;
+	s16	length;		/* two`s complement of length */
 	s16	status;
 	u32	misc;
 	u32	reserved;
@@ -804,7 +804,7 @@ static int pcnet32_set_ringparam(struct 
 	}
 	if ((1 << i) != lp->tx_ring_size)
 		pcnet32_realloc_tx_ring(dev, lp, i);
-	
+
 	size = min(ering->rx_pending, (unsigned int)RX_MAX_RING_SIZE);
 	for (i = 2; i <= PCNET32_LOG_MAX_RX_BUFFERS; i++) {
 		if (size <= (1 << i))
@@ -812,7 +812,7 @@ static int pcnet32_set_ringparam(struct 
 	}
 	if ((1 << i) != lp->rx_ring_size)
 		pcnet32_realloc_rx_ring(dev, lp, i);
-	
+
 	dev->weight = lp->rx_ring_size / 2;
 
 	if (netif_running(dev)) {
@@ -892,7 +892,7 @@ static int pcnet32_loopback_test(struct 
 
 	/* Reset the PCNET32 */
 	lp->a.reset(ioaddr);
-	lp->a.write_csr(ioaddr, CSR4, 0x0915);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 
 	/* switch pcnet32 to 32bit mode */
 	lp->a.write_bcr(ioaddr, 20, 2);
@@ -1602,7 +1602,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 		 * boards will work.
 		 */
 		/* Trigger an initialization just for the interrupt. */
-		a->write_csr(ioaddr, 0, 0x41);
+		a->write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_INIT);
 		mdelay(1);
 
 		dev->irq = probe_irq_off(irq_mask);
@@ -1965,9 +1965,9 @@ static int pcnet32_open(struct net_devic
 
 #ifdef DO_DXSUFLO
 	if (lp->dxsuflo) {	/* Disable transmit stop on underflow */
-		val = lp->a.read_csr(ioaddr, 3);
+		val = lp->a.read_csr(ioaddr, CSR3);
 		val |= 0x40;
-		lp->a.write_csr(ioaddr, 3, val);
+		lp->a.write_csr(ioaddr, CSR3, val);
 	}
 #endif
 
@@ -1988,8 +1988,8 @@ static int pcnet32_open(struct net_devic
 			(lp->dma_addr +
 			 offsetof(struct pcnet32_private, init_block)) >> 16);
 
-	lp->a.write_csr(ioaddr, 4, 0x0915);
-	lp->a.write_csr(ioaddr, 0, 0x0001);
+	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
 
 	netif_start_queue(dev);
 
@@ -2001,13 +2001,13 @@ static int pcnet32_open(struct net_devic
 
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
@@ -2015,7 +2015,7 @@ static int pcnet32_open(struct net_devic
 		       dev->name, i,
 		       (u32) (lp->dma_addr +
 			      offsetof(struct pcnet32_private, init_block)),
-		       lp->a.read_csr(ioaddr, 0));
+		       lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2086,7 +2086,7 @@ static int pcnet32_init_ring(struct net_
 			    (rx_skbuff = lp->rx_skbuff[i] =
 			     dev_alloc_skb(PKT_BUF_SZ))) {
 				/* there is not much, we can do at this point */
-				if (pcnet32_debug & NETIF_MSG_DRV)
+				if (netif_msg_drv(lp))
 					printk(KERN_ERR
 					       "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
 					       dev->name);
@@ -2136,7 +2136,7 @@ static void pcnet32_restart(struct net_d
 
 	/* wait for stop */
 	for (i = 0; i < 100; i++)
-		if (lp->a.read_csr(ioaddr, 0) & 0x0004)
+		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_STOP)
 			break;
 
 	if (i >= 100 && netif_msg_drv(lp))
@@ -2149,13 +2149,13 @@ static void pcnet32_restart(struct net_d
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
@@ -2168,8 +2168,8 @@ static void pcnet32_tx_timeout(struct ne
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
@@ -2191,7 +2191,7 @@ static void pcnet32_tx_timeout(struct ne
 			       le16_to_cpu(lp->tx_ring[i].status));
 		printk("\n");
 	}
-	pcnet32_restart(dev, 0x0042);
+	pcnet32_restart(dev, CSR0_NORMAL);
 
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -2212,7 +2212,7 @@ static int pcnet32_start_xmit(struct sk_
 	if (netif_msg_tx_queued(lp)) {
 		printk(KERN_DEBUG
 		       "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	}
 
 	/* Default status -- will not enable Successful-TxDone
@@ -2243,7 +2243,7 @@ static int pcnet32_start_xmit(struct sk_
 	lp->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
-	lp->a.write_csr(ioaddr, 0, 0x0048);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
 
 	dev->trans_start = jiffies;
 
@@ -2425,18 +2425,18 @@ pcnet32_interrupt(int irq, void *dev_id,
 		if (must_restart) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, 4, 0x0915);
-			pcnet32_restart(dev, 0x0002);
+			lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
 	}
 
 	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, 0, 0x0040);
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
 
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-		       dev->name, lp->a.read_csr(ioaddr, 0));
+		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 
 	spin_unlock(&lp->lock);
 
@@ -2616,10 +2616,10 @@ static int pcnet32_close(struct net_devi
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
@@ -2734,7 +2734,7 @@ static void pcnet32_set_multicast_list(s
 		/* clear SUSPEND (SPND) - CSR5 bit 0 */
 		csr5 = lp->a.read_csr(ioaddr, CSR5);
 		lp->a.write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
-	} else { 
+	} else {
 		lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
 		pcnet32_restart(dev, CSR0_NORMAL);
 		netif_wake_queue(dev);
-- 
Don Fry
brazilnut@us.ibm.com
