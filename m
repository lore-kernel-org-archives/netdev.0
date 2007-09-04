From: Mandeep Singh Baines <mandeep.baines@gmail.com>
Subject: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Mon, 3 Sep 2007 20:20:36 -0700
Message-ID: <20070904032036.GA11153@ludhiana>
References: <1188643644-77674666b52f8e4df330ca0982689109@brownhat.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Cc: hadi@cyberus.ca, Mandeep Baines <mandeep.baines@gmail.com>,
	davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, jeff@garzik.org, nhorman@tuxdriver.com
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:37657 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbXIDDVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 23:21:45 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2078737wah
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2007 20:21:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1188643644-77674666b52f8e4df330ca0982689109@brownhat.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Daniele,

Attached is a patch for converting the sis900 driver to NAPI. Please take a
look at let me know what you think. I'm not 100% sure if I'm handling the 
rotting packet issue correctly or that I have the locking right in tx_timeout.
These might be areas to look at closely.

I didn't see much saving in interrupts on my machine (too fast, I guess). But
I still think its beneficial: pushing work out of the interrupt handler into
a bottom half is a good thing and we no longer need to disable interrupts 
in start_xmit. 

I did see a significant boost to tx performance by optimizing start_xmit: more
than double pps in pktgen.

I'm also attaching some test results for various iterations of development.

Regards,
Mandeep

Daniele Venzano (venza@brownhat.org) wrote:
> ----- Message d'origine -----
> De: jamal <hadi@cyberus.ca>
> Date: Fri, 31 Aug 2007 09:50:03 -0400
> Sujet: Re: Re: pktgen terminating condition
> 
> >I dont know if you followed the discussion - by defering the freeing of
> >skbs, you will be slowing down socket apps sending from the local
> >machine. It may be ok if the socket buffers were huge, but that comes at
> >the cost of system memory (which may not be a big deal)
> >Do you by any chance recall why you used the idle interupt instead of
> >txok to kick the prunning of tx descriptors?
> 
> That should be asked to the original author of the driver, that I wasn't able to contact when I took over the maintainership several years ago.
> I think that since this chip is usually used on cheap/low performance (relatively speaking) devices it was felt that generating an interrupt for each transmitted packet was going to affect the performance of the system too much. At the start, if I remember correctly, this was a chip thought for consumer use, where transmissions won't happen continuously for long periods of time. Then the sis900 started to get used everywhere, from embedded systems to (cheap) server motherboards and the usage scenario changed.
> 
> 
> --
> Daniele Venzano
> venza@brownhat.org

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_testing.txt"

Tested using pktgen.

cpuinfo:
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 8
model name      : AMD Geode NX
stepping        : 1
cpu MHz         : 1397.641
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse syscall mp mmxext 3dnowext 3dnow ts fid vid
bogomips        : 2796.00
clflush size    : 32

meminfo:
MemTotal:       907092 kB


Results in pps. Sending 400000 60-byte packets.
Other than Iteration 5 and 6, there is 1 interrupt per packet.

Iteration 0 (replace TxIDLE with TxOK):
62222, 62052, 62335

Iteration 1 (optimize sis900_start_xmit):
148815, 148815, 148829

Iteration 2 (convert Rx to NAPI):
148669, 148635, 148677

Iteration 3 (remove tx_full dev state variable):
148677, 148528, 148532

Iteration 4 (optimize finish_xmit):
148677, 148676, 148689

Iteration 5 (move tx completion code into NAPI poll):
147751, 147658, 147809
Interrupts:
359270, 360747, 358010

Iteration 6 (cleanup + rotting packet handling + rx optimization):
148652, 148680, 148681
Interrupts:
399927, 399841, 399835


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_napi.patch"

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 7c6e480..862e15a 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -185,7 +185,6 @@ struct sis900_private {
 	dma_addr_t tx_ring_dma;
 	dma_addr_t rx_ring_dma;
 
-	unsigned int tx_full; /* The Tx queue is full. */
 	u8 host_bridge_rev;
 	u8 chipset_rev;
 };
@@ -202,8 +201,10 @@ MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per in
 MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void sis900_poll(struct net_device *dev);
+static void sis900_poll_controller(struct net_device *dev);
 #endif
+
+static int sis900_poll(struct net_device *dev, int *budget);
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
@@ -216,8 +217,8 @@ static void sis900_tx_timeout(struct net_device *net_dev);
 static void sis900_init_tx_ring(struct net_device *net_dev);
 static void sis900_init_rx_ring(struct net_device *net_dev);
 static int sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
-static int sis900_rx(struct net_device *net_dev);
-static void sis900_finish_xmit (struct net_device *net_dev);
+static int sis900_rx(struct net_device *net_dev, int limit);
+static int sis900_finish_xmit (struct net_device *net_dev);
 static irqreturn_t sis900_interrupt(int irq, void *dev_instance);
 static int sis900_close(struct net_device *net_dev);
 static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd);
@@ -474,9 +475,11 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	net_dev->tx_timeout = sis900_tx_timeout;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
+	net_dev->poll = &sis900_poll;
+	net_dev->weight = 64;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-        net_dev->poll_controller = &sis900_poll;
+        net_dev->poll_controller = &sis900_poll_controller;
 #endif
 
 	if (sis900_debug > 0)
@@ -979,13 +982,44 @@ static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr)
 	return status;
 }
 
+static int sis900_poll(struct net_device *dev, int *budget)
+{
+	struct sis900_private *sis_priv = dev->priv;
+	long ioaddr = dev->base_addr;
+	int limit = min_t(int, dev->quota, *budget);
+	int rx_work_done;
+	int tx_work_done;
+
+	/* run TX completion thread */
+	spin_lock(sis_priv->lock);
+	tx_work_done = sis900_finish_xmit(dev);
+	spin_unlock(sis_priv->lock);
+
+	/* run RX thread */
+	rx_work_done = sis900_rx(dev, limit);
+	*budget -= rx_work_done;
+	dev->quota -= rx_work_done;
+
+	/* re-enable interrupts if no work done */
+	if (rx_work_done + tx_work_done == 0) {
+		netif_rx_complete(dev);
+		/* Enable all known interrupts. */
+		outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxOK), ioaddr + imr);
+		/* Handle rotting packet */
+		sis900_rx(dev, NUM_RX_DESC);
+		return 0;
+	}
+
+	return 1;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
  * without having to re-enable interrupts. It's not called while
  * the interrupt routine is executing.
 */
-static void sis900_poll(struct net_device *dev)
+static void sis900_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
 	sis900_interrupt(dev->irq, dev);
@@ -1032,7 +1066,7 @@ sis900_open(struct net_device *net_dev)
 	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
+	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxOK), ioaddr + imr);
 	outl(RxENA | inl(ioaddr + cr), ioaddr + cr);
 	outl(IE, ioaddr + ier);
 
@@ -1102,7 +1136,6 @@ sis900_init_tx_ring(struct net_device *net_dev)
 	long ioaddr = net_dev->base_addr;
 	int i;
 
-	sis_priv->tx_full = 0;
 	sis_priv->dirty_tx = sis_priv->cur_tx = 0;
 
 	for (i = 0; i < NUM_TX_DESC; i++) {
@@ -1517,7 +1550,6 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
-	unsigned long flags;
 	int i;
 
 	if(netif_msg_tx_err(sis_priv))
@@ -1527,8 +1559,8 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 	/* Disable interrupts by clearing the interrupt mask. */
 	outl(0x0000, ioaddr + imr);
 
-	/* use spinlock to prevent interrupt handler accessing buffer ring */
-	spin_lock_irqsave(&sis_priv->lock, flags);
+	/* use spinlock to prevent bh from accessing buffer ring */
+	spin_lock_bh(&sis_priv->lock);
 
 	/* discard unsent packets */
 	sis_priv->dirty_tx = sis_priv->cur_tx = 0;
@@ -1546,10 +1578,9 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 			sis_priv->stats.tx_dropped++;
 		}
 	}
-	sis_priv->tx_full = 0;
 	netif_wake_queue(net_dev);
 
-	spin_unlock_irqrestore(&sis_priv->lock, flags);
+	spin_unlock_bh(&sis_priv->lock);
 
 	net_dev->trans_start = jiffies;
 
@@ -1557,7 +1588,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
+	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxOK), ioaddr + imr);
 	return;
 }
 
@@ -1574,52 +1605,27 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 static int
 sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
-	unsigned int  entry;
-	unsigned long flags;
-	unsigned int  index_cur_tx, index_dirty_tx;
-	unsigned int  count_dirty_tx;
+	struct sis900_private *sis_priv = net_dev->priv;
+        unsigned int entry;
 
-	/* Don't transmit data before the complete of auto-negotiation */
-	if(!sis_priv->autong_complete){
+	/* Don't transmit data before auto-negotiation is complete */
+	if(unlikely(!sis_priv->autong_complete)){
 		netif_stop_queue(net_dev);
 		return 1;
 	}
 
-	spin_lock_irqsave(&sis_priv->lock, flags);
-
-	/* Calculate the next Tx descriptor entry. */
-	entry = sis_priv->cur_tx % NUM_TX_DESC;
+	/* Set the Tx descriptor and enable Transmit State Machine */
+        entry = sis_priv->cur_tx++ % NUM_TX_DESC;
 	sis_priv->tx_skbuff[entry] = skb;
-
-	/* set the transmit buffer descriptor and enable Transmit State Machine */
 	sis_priv->tx_ring[entry].bufptr = pci_map_single(sis_priv->pci_dev,
 		skb->data, skb->len, PCI_DMA_TODEVICE);
 	sis_priv->tx_ring[entry].cmdsts = (OWN | skb->len);
 	outl(TxENA | inl(ioaddr + cr), ioaddr + cr);
 
-	sis_priv->cur_tx ++;
-	index_cur_tx = sis_priv->cur_tx;
-	index_dirty_tx = sis_priv->dirty_tx;
-
-	for (count_dirty_tx = 0; index_cur_tx != index_dirty_tx; index_dirty_tx++)
-		count_dirty_tx ++;
-
-	if (index_cur_tx == index_dirty_tx) {
-		/* dirty_tx is met in the cycle of cur_tx, buffer full */
-		sis_priv->tx_full = 1;
-		netif_stop_queue(net_dev);
-	} else if (count_dirty_tx < NUM_TX_DESC) {
-		/* Typical path, tell upper layer that more transmission is possible */
-		netif_start_queue(net_dev);
-	} else {
-		/* buffer full, tell upper layer no more transmission */
-		sis_priv->tx_full = 1;
+        /* If Tx ring is full, tell upper layer no more transmission */
+	if (unlikely(sis_priv->cur_tx - sis_priv->dirty_tx >= NUM_TX_DESC))
 		netif_stop_queue(net_dev);
-	}
-
-	spin_unlock_irqrestore(&sis_priv->lock, flags);
 
 	net_dev->trans_start = jiffies;
 
@@ -1650,32 +1656,27 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 	u32 status;
 	unsigned int handled = 0;
 
-	spin_lock (&sis_priv->lock);
-
-	do {
-		status = inl(ioaddr + isr);
-
-		if ((status & (HIBERR|TxURN|TxERR|TxIDLE|RxORN|RxERR|RxOK)) == 0)
-			/* nothing intresting happened */
-			break;
+	while ((status = inl(ioaddr + isr))) {
 		handled = 1;
 
-		/* why dow't we break after Tx/Rx case ?? keyword: full-duplex */
-		if (status & (RxORN | RxERR | RxOK))
-			/* Rx interrupt */
-			sis900_rx(net_dev);
+		/* why don't we break after Tx/Rx case ?? 
+		 * keyword: full-duplex 
+		 */
 
-		if (status & (TxURN | TxERR | TxIDLE))
-			/* Tx interrupt */
-			sis900_finish_xmit(net_dev);
+		/* Rx interrupt */
+                if (status & (TxURN|TxERR|TxOK|RxORN|RxERR|RxOK)) {
+			/* Disable all interrupts. */
+			outl(0, ioaddr + imr);
+			netif_rx_schedule(net_dev);
+		}
 
 		/* something strange happened !!! */
-		if (status & HIBERR) {
+		if (status & HIBERR)
 			if(netif_msg_intr(sis_priv))
 				printk(KERN_INFO "%s: Abnormal interrupt,"
-					"status %#8.8x.\n", net_dev->name, status);
-			break;
-		}
+					"status %#8.8x.\n", 
+					net_dev->name, status);
+
 		if (--boguscnt < 0) {
 			if(netif_msg_intr(sis_priv))
 				printk(KERN_INFO "%s: Too much work at interrupt, "
@@ -1683,14 +1684,13 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 					net_dev->name, status);
 			break;
 		}
-	} while (1);
+	}
 
 	if(netif_msg_intr(sis_priv))
 		printk(KERN_DEBUG "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
 
-	spin_unlock (&sis_priv->lock);
 	return IRQ_RETVAL(handled);
 }
 
@@ -1704,25 +1704,29 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
  *	don't do "too much" work here
  */
 
-static int sis900_rx(struct net_device *net_dev)
+static int sis900_rx(struct net_device *net_dev, int limit)
 {
 	struct sis900_private *sis_priv = net_dev->priv;
+	struct net_device_stats *stats = &sis_priv->stats;
 	long ioaddr = net_dev->base_addr;
-	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
-	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
-	int rx_work_limit;
+	int cur_rx = sis_priv->cur_rx;
+	int dirty_rx, orig_dirty_rx = sis_priv->dirty_rx;
+	int count;
 
 	if (netif_msg_rx_status(sis_priv))
-		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
-		       "status:0x%8.8x\n",
-		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
-	rx_work_limit = sis_priv->dirty_rx + NUM_RX_DESC - sis_priv->cur_rx;
+		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d\n",
+		       cur_rx, orig_dirty_rx);
 
-	while (rx_status & OWN) {
+	for (count = 0; count < limit; cur_rx++, count++) {
+		unsigned int entry;
+		u32 rx_status;
 		unsigned int rx_size;
 		unsigned int data_size;
 
-		if (--rx_work_limit < 0)
+		entry = cur_rx % NUM_RX_DESC;
+		rx_status = sis_priv->rx_ring[entry].cmdsts;
+
+		if ((rx_status & OWN) == 0)
 			break;
 
 		data_size = rx_status & DSIZE;
@@ -1735,113 +1739,71 @@ static int sis900_rx(struct net_device *net_dev)
 #endif
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
-			/* corrupted packet received */
-			if (netif_msg_rx_err(sis_priv))
-				printk(KERN_DEBUG "%s: Corrupted packet "
-				       "received, buffer status = 0x%8.8x/%d.\n",
-				       net_dev->name, rx_status, data_size);
-			sis_priv->stats.rx_errors++;
+			pci_unmap_single(sis_priv->pci_dev,
+				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
+				PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(sis_priv->rx_skbuff[entry]);
+
+			stats->rx_errors++;
 			if (rx_status & OVERRUN)
-				sis_priv->stats.rx_over_errors++;
+				stats->rx_over_errors++;
 			if (rx_status & (TOOLONG|RUNT))
-				sis_priv->stats.rx_length_errors++;
+				stats->rx_length_errors++;
 			if (rx_status & (RXISERR | FAERR))
-				sis_priv->stats.rx_frame_errors++;
+				stats->rx_frame_errors++;
 			if (rx_status & CRCERR)
-				sis_priv->stats.rx_crc_errors++;
-			/* reset buffer descriptor state */
-			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
+				stats->rx_crc_errors++;
 		} else {
 			struct sk_buff * skb;
-			struct sk_buff * rx_skb;
 
 			pci_unmap_single(sis_priv->pci_dev,
 				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
 				PCI_DMA_FROMDEVICE);
 
-			/* refill the Rx buffer, what if there is not enought
-			 * memory for new socket buffer ?? */
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
-				/*
-				 * Not enough memory to refill the buffer
-				 * so we need to recycle the old one so
-				 * as to avoid creating a memory hole
-				 * in the rx ring
-				 */
-				skb = sis_priv->rx_skbuff[entry];
-				sis_priv->stats.rx_dropped++;
-				goto refill_rx_ring;
-			}	
-
-			/* This situation should never happen, but due to
-			   some unknow bugs, it is possible that
-			   we are working on NULL sk_buff :-( */
-			if (sis_priv->rx_skbuff[entry] == NULL) {
-				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_WARNING "%s: NULL pointer "
-					      "encountered in Rx ring\n"
-					      "cur_rx:%4.4d, dirty_rx:%4.4d\n",
-					      net_dev->name, sis_priv->cur_rx,
-					      sis_priv->dirty_rx);
-				break;
-			}
-
 			/* give the socket buffer to upper layers */
-			rx_skb = sis_priv->rx_skbuff[entry];
-			skb_put(rx_skb, rx_size);
-			rx_skb->protocol = eth_type_trans(rx_skb, net_dev);
-			netif_rx(rx_skb);
+			skb = sis_priv->rx_skbuff[entry];
+			skb_put(skb, rx_size);
+			skb->protocol = eth_type_trans(skb, net_dev);
+			netif_receive_skb(skb);
 
 			/* some network statistics */
 			if ((rx_status & BCAST) == MCAST)
-				sis_priv->stats.multicast++;
+				stats->multicast++;
 			net_dev->last_rx = jiffies;
-			sis_priv->stats.rx_bytes += rx_size;
-			sis_priv->stats.rx_packets++;
-			sis_priv->dirty_rx++;
-refill_rx_ring:
-			sis_priv->rx_skbuff[entry] = skb;
-			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
-                	sis_priv->rx_ring[entry].bufptr =
-				pci_map_single(sis_priv->pci_dev, skb->data,
-					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			stats->rx_bytes += rx_size;
+			stats->rx_packets++;
 		}
-		sis_priv->cur_rx++;
-		entry = sis_priv->cur_rx % NUM_RX_DESC;
-		rx_status = sis_priv->rx_ring[entry].cmdsts;
-	} // while
+	}
 
-	/* refill the Rx buffer, what if the rate of refilling is slower
-	 * than consuming ?? */
-	for (; sis_priv->cur_rx != sis_priv->dirty_rx; sis_priv->dirty_rx++) {
+	/* refill the Rx ring. */
+	for (dirty_rx = orig_dirty_rx; dirty_rx < cur_rx; dirty_rx++) {
 		struct sk_buff *skb;
+		unsigned int entry;
 
-		entry = sis_priv->dirty_rx % NUM_RX_DESC;
-
-		if (sis_priv->rx_skbuff[entry] == NULL) {
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
-				/* not enough memory for skbuff, this makes a
-				 * "hole" on the buffer ring, it is not clear
-				 * how the hardware will react to this kind
-				 * of degenerated buffer */
-				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze,"
-						"deferring packet.\n",
-						net_dev->name);
-				sis_priv->stats.rx_dropped++;
-				break;
-			}
-			sis_priv->rx_skbuff[entry] = skb;
-			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
-                	sis_priv->rx_ring[entry].bufptr =
-				pci_map_single(sis_priv->pci_dev, skb->data,
-					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+			if (netif_msg_rx_err(sis_priv))
+				printk(KERN_INFO "%s: Memory squeeze,"
+					"deferring packet.\n",
+					net_dev->name);
+			break;
 		}
+
+		entry = dirty_rx % NUM_RX_DESC;
+		sis_priv->rx_skbuff[entry] = skb;
+		sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
+               	sis_priv->rx_ring[entry].bufptr =
+			pci_map_single(sis_priv->pci_dev, skb->data,
+				RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 	}
+
 	/* re-enable the potentially idle receive state matchine */
-	outl(RxENA | inl(ioaddr + cr), ioaddr + cr );
+	if (dirty_rx != orig_dirty_rx)
+		outl(RxENA | inl(ioaddr + cr), ioaddr + cr );
 
-	return 0;
+	sis_priv->dirty_rx = dirty_rx;
+	sis_priv->cur_rx = cur_rx;
+
+	return count;
 }
 
 /**
@@ -1854,24 +1816,28 @@ refill_rx_ring:
  *	don't do "too much" work here
  */
 
-static void sis900_finish_xmit (struct net_device *net_dev)
+static int sis900_finish_xmit (struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = net_dev->priv;
+	struct net_device_stats *stats = &sis_priv->stats;
+	int cur_tx = sis_priv->cur_tx;
+	int orig_dirty_tx = sis_priv->dirty_tx;
+	int dirty_tx;
 
-	for (; sis_priv->dirty_tx != sis_priv->cur_tx; sis_priv->dirty_tx++) {
+	for (dirty_tx = orig_dirty_tx; dirty_tx < cur_tx; dirty_tx++) {
 		struct sk_buff *skb;
 		unsigned int entry;
 		u32 tx_status;
 
-		entry = sis_priv->dirty_tx % NUM_TX_DESC;
+		entry = dirty_tx % NUM_TX_DESC;
 		tx_status = sis_priv->tx_ring[entry].cmdsts;
 
-		if (tx_status & OWN) {
-			/* The packet is not transmitted yet (owned by hardware) !
-			 * Note: the interrupt is generated only when Tx Machine
-			 * is idle, so this is an almost impossible case */
+		/* The packet is not transmitted yet (owned by hardware) !
+		 * Note: the interrupt is generated only when Tx Machine
+		 * is idle, so this is an almost impossible case 
+		 */
+		if (tx_status & OWN)
 			break;
-		}
 
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
@@ -1879,20 +1845,20 @@ static void sis900_finish_xmit (struct net_device *net_dev)
 				printk(KERN_DEBUG "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
-			sis_priv->stats.tx_errors++;
+			stats->tx_errors++;
 			if (tx_status & UNDERRUN)
-				sis_priv->stats.tx_fifo_errors++;
+				stats->tx_fifo_errors++;
 			if (tx_status & ABORT)
-				sis_priv->stats.tx_aborted_errors++;
+				stats->tx_aborted_errors++;
 			if (tx_status & NOCARRIER)
-				sis_priv->stats.tx_carrier_errors++;
+				stats->tx_carrier_errors++;
 			if (tx_status & OWCOLL)
-				sis_priv->stats.tx_window_errors++;
+				stats->tx_window_errors++;
 		} else {
 			/* packet successfully transmitted */
-			sis_priv->stats.collisions += (tx_status & COLCNT) >> 16;
-			sis_priv->stats.tx_bytes += tx_status & DSIZE;
-			sis_priv->stats.tx_packets++;
+			stats->collisions += (tx_status & COLCNT) >> 16;
+			stats->tx_bytes += tx_status & DSIZE;
+			stats->tx_packets++;
 		}
 		/* Free the original skb. */
 		skb = sis_priv->tx_skbuff[entry];
@@ -1905,13 +1871,15 @@ static void sis900_finish_xmit (struct net_device *net_dev)
 		sis_priv->tx_ring[entry].cmdsts = 0;
 	}
 
-	if (sis_priv->tx_full && netif_queue_stopped(net_dev) &&
-	    sis_priv->cur_tx - sis_priv->dirty_tx < NUM_TX_DESC - 4) {
-		/* The ring is no longer full, clear tx_full and schedule
-		 * more transmission by netif_wake_queue(net_dev) */
-		sis_priv->tx_full = 0;
+	/* The ring is no longer full, schedule
+	 * more transmission by netif_wake_queue(net_dev) 
+	 */
+	if (netif_queue_stopped(net_dev) && (cur_tx - dirty_tx < NUM_TX_DESC))
 		netif_wake_queue (net_dev);
-	}
+
+	sis_priv->dirty_tx = dirty_tx;
+
+	return dirty_tx - orig_dirty_tx;
 }
 
 /**
@@ -2462,7 +2430,7 @@ static int sis900_resume(struct pci_dev *pci_dev)
 	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
+	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxOK), ioaddr + imr);
 	outl(RxENA | inl(ioaddr + cr), ioaddr + cr);
 	outl(IE, ioaddr + ier);
 
diff --git a/drivers/net/sis900.h b/drivers/net/sis900.h
index 150511a..671af28 100644
--- a/drivers/net/sis900.h
+++ b/drivers/net/sis900.h
@@ -319,8 +319,8 @@ enum sis630_revision_id {
 #define TX_BUF_SIZE     (MAX_FRAME_SIZE+18)
 #define RX_BUF_SIZE     (MAX_FRAME_SIZE+18)
 
-#define NUM_TX_DESC     16      	/* Number of Tx descriptor registers. */
-#define NUM_RX_DESC     16       	/* Number of Rx descriptor registers. */
+#define NUM_TX_DESC     64    	/* Number of Tx descriptor registers. */
+#define NUM_RX_DESC     64    	/* Number of Rx descriptor registers. */
 #define TX_TOTAL_SIZE	NUM_TX_DESC*sizeof(BufferDesc)
 #define RX_TOTAL_SIZE	NUM_RX_DESC*sizeof(BufferDesc)
 

--OXfL5xGRrasGEqWY--
