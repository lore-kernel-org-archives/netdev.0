From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] yellowfin: Fix buffer underrun after dev_alloc_skb()
 failure
Date: Fri, 14 Aug 2009 11:59:14 +0200
Message-ID: <4A853572.70209@gmail.com>
References: <4A7C6B08.1040800@gmail.com> <20090812.210845.84504668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:34704 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbZHNJzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 05:55:06 -0400
Received: by ewy10 with SMTP id 10so1383299ewy.37
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 02:55:06 -0700 (PDT)
In-Reply-To: <20090812.210845.84504668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dev_alloc_skb fails in the first iteration, a buffer underrun occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
> I think this is a case where this code is going to need to
> be majorly reworked so that you can pass error status up
> to the caller when this allocation failure happens, and
> the caller can properly act upon it.
> 
> Just silently returning when no RX ring has been allocated,
> and the TX ring hasn't been setup at all, is going to be
> worse than the array overrun you're supposedly fixing.

I think it should be something like this. Should yellowfin_open()
do more than just passing the yellowfin_init_ring() error?

diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index a075801..ee35b11 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -346,7 +346,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int yellowfin_open(struct net_device *dev);
 static void yellowfin_timer(unsigned long data);
 static void yellowfin_tx_timeout(struct net_device *dev);
-static void yellowfin_init_ring(struct net_device *dev);
+static int yellowfin_init_ring(struct net_device *dev);
 static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance);
 static int yellowfin_rx(struct net_device *dev);
@@ -573,19 +573,22 @@ static int yellowfin_open(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
 	void __iomem *ioaddr = yp->base;
-	int i;
+	int i, ret;
 
 	/* Reset the chip. */
 	iowrite32(0x80000000, ioaddr + DMACtrl);
 
-	i = request_irq(dev->irq, &yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
-	if (i) return i;
+	ret = request_irq(dev->irq, &yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
+	if (ret)
+		return ret;
 
 	if (yellowfin_debug > 1)
 		printk(KERN_DEBUG "%s: yellowfin_open() irq %d.\n",
 			   dev->name, dev->irq);
 
-	yellowfin_init_ring(dev);
+	ret = yellowfin_init_ring(dev);
+	if (ret)
+		return ret;
 
 	iowrite32(yp->rx_ring_dma, ioaddr + RxPtr);
 	iowrite32(yp->tx_ring_dma, ioaddr + TxPtr);
@@ -725,10 +728,10 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 }
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
-static void yellowfin_init_ring(struct net_device *dev)
+static int yellowfin_init_ring(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
-	int i;
+	int i, j;
 
 	yp->tx_full = 0;
 	yp->cur_rx = yp->cur_tx = 0;
@@ -753,6 +756,11 @@ static void yellowfin_init_ring(struct net_device *dev)
 		yp->rx_ring[i].addr = cpu_to_le32(pci_map_single(yp->pci_dev,
 			skb->data, yp->rx_buf_sz, PCI_DMA_FROMDEVICE));
 	}
+	if (i != RX_RING_SIZE) {
+		for (j = 0; j < i; j++)
+			dev_kfree_skb(yp->rx_skbuff[j]);
+		return -ENOMEM;
+	}
 	yp->rx_ring[i-1].dbdma_cmd = cpu_to_le32(CMD_STOP);
 	yp->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
 
@@ -769,8 +777,6 @@ static void yellowfin_init_ring(struct net_device *dev)
 	yp->tx_ring[--i].dbdma_cmd = cpu_to_le32(CMD_STOP | BRANCH_ALWAYS);
 #else
 {
-	int j;
-
 	/* Tx ring needs a pair of descriptors, the second for the status. */
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		j = 2*i;
@@ -805,7 +811,7 @@ static void yellowfin_init_ring(struct net_device *dev)
 }
 #endif
 	yp->tx_tail_desc = &yp->tx_status[0];
-	return;
+	return 0;
 }
 
 static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
