From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH 1/3] axnet_cs: use netstats in net_device structure
Date: Wed, 07 May 2008 02:20:36 +0300
Message-ID: <4820E7C4.4040404@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040702090200090806000207"
Cc: dahinds@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:39641 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754526AbYEFXUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 19:20:47 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JtWSj-0000SM-2F
	for netdev@vger.kernel.org; Tue, 06 May 2008 23:20:45 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:20:45 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:20:45 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040702090200090806000207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------040702090200090806000207
Content-Type: text/x-patch;
 name="axnet_cs_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="axnet_cs_netstats.patch"

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index ce95c5d..d7018ff 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1021,7 +1021,7 @@ static void ei_tx_timeout(struct net_device *dev)
 	int txsr, isr, tickssofar = jiffies - dev->trans_start;
 	unsigned long flags;
 
-	ei_local->stat.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	txsr = inb(e8390_base+EN0_TSR);
@@ -1032,7 +1032,7 @@ static void ei_tx_timeout(struct net_device *dev)
 		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
 		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
 
-	if (!isr && !ei_local->stat.tx_packets) 
+	if (!isr && !dev->stats.tx_packets) 
 	{
 		/* The 8390 probably hasn't gotten on the cable yet. */
 		ei_local->interface_num ^= 1;   /* Try a different xcvr.  */
@@ -1122,7 +1122,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock_irqrestore(&ei_local->page_lock, flags);
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		return 1;
 	}
 
@@ -1170,7 +1170,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	dev_kfree_skb (skb);
-	ei_local->stat.tx_bytes += send_length;
+	dev->stats.tx_bytes += send_length;
     
 	return 0;
 }
@@ -1262,9 +1262,9 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 
 		if (interrupts & ENISR_COUNTERS) 
 		{
-			ei_local->stat.rx_frame_errors += inb_p(e8390_base + EN0_COUNTER0);
-			ei_local->stat.rx_crc_errors   += inb_p(e8390_base + EN0_COUNTER1);
-			ei_local->stat.rx_missed_errors+= inb_p(e8390_base + EN0_COUNTER2);
+			dev->stats.rx_frame_errors += inb_p(e8390_base + EN0_COUNTER0);
+			dev->stats.rx_crc_errors   += inb_p(e8390_base + EN0_COUNTER1);
+			dev->stats.rx_missed_errors+= inb_p(e8390_base + EN0_COUNTER2);
 		}
 	}
     
@@ -1309,7 +1309,6 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 static void ei_tx_err(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	unsigned char txsr = inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -1332,10 +1331,10 @@ static void ei_tx_err(struct net_device *dev)
 		ei_tx_intr(dev);
 	else 
 	{
-		ei_local->stat.tx_errors++;
-		if (txsr & ENTSR_CRS) ei_local->stat.tx_carrier_errors++;
-		if (txsr & ENTSR_CDH) ei_local->stat.tx_heartbeat_errors++;
-		if (txsr & ENTSR_OWC) ei_local->stat.tx_window_errors++;
+		dev->stats.tx_errors++;
+		if (txsr & ENTSR_CRS) dev->stats.tx_carrier_errors++;
+		if (txsr & ENTSR_CDH) dev->stats.tx_heartbeat_errors++;
+		if (txsr & ENTSR_OWC) dev->stats.tx_window_errors++;
 	}
 }
 
@@ -1397,25 +1396,25 @@ static void ei_tx_intr(struct net_device *dev)
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
-		ei_local->stat.collisions++;
+		dev->stats.collisions++;
 	if (status & ENTSR_PTX)
-		ei_local->stat.tx_packets++;
+		dev->stats.tx_packets++;
 	else 
 	{
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		if (status & ENTSR_ABT) 
 		{
-			ei_local->stat.tx_aborted_errors++;
-			ei_local->stat.collisions += 16;
+			dev->stats.tx_aborted_errors++;
+			dev->stats.collisions += 16;
 		}
 		if (status & ENTSR_CRS) 
-			ei_local->stat.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 		if (status & ENTSR_FU) 
-			ei_local->stat.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		if (status & ENTSR_CDH)
-			ei_local->stat.tx_heartbeat_errors++;
+			dev->stats.tx_heartbeat_errors++;
 		if (status & ENTSR_OWC)
-			ei_local->stat.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 	}
 	netif_wake_queue(dev);
 }
@@ -1476,8 +1475,8 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2x nxpg=%#2x.\n",
 					   dev->name, rx_frame.count, rx_frame.status,
 					   rx_frame.next);
-			ei_local->stat.rx_errors++;
-			ei_local->stat.rx_length_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_length_errors++;
 		}
 		 else if ((pkt_stat & 0x0F) == ENRSR_RXOK) 
 		{
@@ -1489,7 +1488,7 @@ static void ei_receive(struct net_device *dev)
 				if (ei_debug > 1)
 					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
 						   dev->name, pkt_len);
-				ei_local->stat.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			else
@@ -1500,10 +1499,10 @@ static void ei_receive(struct net_device *dev)
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				ei_local->stat.rx_packets++;
-				ei_local->stat.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
-					ei_local->stat.multicast++;
+					dev->stats.multicast++;
 			}
 		} 
 		else 
@@ -1512,10 +1511,10 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet: status=%#2x nxpg=%#2x size=%d\n",
 					   dev->name, rx_frame.status, rx_frame.next,
 					   rx_frame.count);
-			ei_local->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
 			if (pkt_stat & ENRSR_FO)
-				ei_local->stat.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 		}
 		next_frame = rx_frame.next;
 		
@@ -1550,7 +1549,6 @@ static void ei_rx_overrun(struct net_device *dev)
 	axnet_dev_t *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
     
 	/*
 	 * Record whether a Tx was in progress and then issue the
@@ -1561,7 +1559,7 @@ static void ei_rx_overrun(struct net_device *dev)
     
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
-	ei_local->stat.rx_over_errors++;
+	dev->stats.rx_over_errors++;
     
 	/* 
 	 * Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
@@ -1622,16 +1620,16 @@ static struct net_device_stats *get_stats(struct net_device *dev)
     
 	/* If the card is stopped, just return the present stats. */
 	if (!netif_running(dev))
-		return &ei_local->stat;
+		return &dev->stats;
 
 	spin_lock_irqsave(&ei_local->page_lock,flags);
 	/* Read the counter registers, assuming we are in page 0. */
-	ei_local->stat.rx_frame_errors += inb_p(ioaddr + EN0_COUNTER0);
-	ei_local->stat.rx_crc_errors   += inb_p(ioaddr + EN0_COUNTER1);
-	ei_local->stat.rx_missed_errors+= inb_p(ioaddr + EN0_COUNTER2);
+	dev->stats.rx_frame_errors += inb_p(ioaddr + EN0_COUNTER0);
+	dev->stats.rx_crc_errors   += inb_p(ioaddr + EN0_COUNTER1);
+	dev->stats.rx_missed_errors+= inb_p(ioaddr + EN0_COUNTER2);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
     
-	return &ei_local->stat;
+	return &dev->stats;
 }
 
 /*

--------------040702090200090806000207--

