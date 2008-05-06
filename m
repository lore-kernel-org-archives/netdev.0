From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH 2/3] lib8390: use netstats in net_device structure
Date: Wed, 07 May 2008 02:20:40 +0300
Message-ID: <4820E7C8.6080700@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010300070205060405080203"
Cc: becker@scyld.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42616 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759674AbYEFXZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 19:25:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JtWWs-0000cG-5H
	for netdev@vger.kernel.org; Tue, 06 May 2008 23:25:02 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:25:02 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:25:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010300070205060405080203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------010300070205060405080203
Content-Type: text/x-patch;
 name="lib8390_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lib8390_netstats.patch"

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 0c5447d..72ffbeb 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -265,7 +265,7 @@ static void ei_tx_timeout(struct net_device *dev)
 	int txsr, isr, tickssofar = jiffies - dev->trans_start;
 	unsigned long flags;
 
-	ei_local->stat.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	txsr = ei_inb(e8390_base+EN0_TSR);
@@ -276,7 +276,7 @@ static void ei_tx_timeout(struct net_device *dev)
 		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
 		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
 
-	if (!isr && !ei_local->stat.tx_packets)
+	if (!isr && !dev->stats.tx_packets)
 	{
 		/* The 8390 probably hasn't gotten on the cable yet. */
 		ei_local->interface_num ^= 1;   /* Try a different xcvr.  */
@@ -374,7 +374,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
 		enable_irq_lockdep_irqrestore(dev->irq, &flags);
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		return 1;
 	}
 
@@ -417,7 +417,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
 
 	dev_kfree_skb (skb);
-	ei_local->stat.tx_bytes += send_length;
+	dev->stats.tx_bytes += send_length;
 
 	return 0;
 }
@@ -493,9 +493,9 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 		if (interrupts & ENISR_COUNTERS)
 		{
-			ei_local->stat.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
-			ei_local->stat.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
-			ei_local->stat.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
+			dev->stats.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
+			dev->stats.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
+			dev->stats.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
 			ei_outb_p(ENISR_COUNTERS, e8390_base + EN0_ISR); /* Ack intr. */
 		}
 
@@ -578,10 +578,10 @@ static void ei_tx_err(struct net_device *dev)
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
 
@@ -645,25 +645,25 @@ static void ei_tx_intr(struct net_device *dev)
 
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
@@ -730,7 +730,7 @@ static void ei_receive(struct net_device *dev)
 			&& rx_frame.next != next_frame + 1 - num_rx_pages) {
 			ei_local->current_page = rxing_page;
 			ei_outb(ei_local->current_page-1, e8390_base+EN0_BOUNDARY);
-			ei_local->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			continue;
 		}
 
@@ -740,8 +740,8 @@ static void ei_receive(struct net_device *dev)
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
@@ -753,7 +753,7 @@ static void ei_receive(struct net_device *dev)
 				if (ei_debug > 1)
 					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
 						   dev->name, pkt_len);
-				ei_local->stat.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			else
@@ -764,10 +764,10 @@ static void ei_receive(struct net_device *dev)
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
@@ -776,10 +776,10 @@ static void ei_receive(struct net_device *dev)
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
 
@@ -827,7 +827,7 @@ static void ei_rx_overrun(struct net_device *dev)
 
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
-	ei_local->stat.rx_over_errors++;
+	dev->stats.rx_over_errors++;
 
 	/*
 	 * Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
@@ -889,16 +889,16 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 
 	/* If the card is stopped, just return the present stats. */
 	if (!netif_running(dev))
-		return &ei_local->stat;
+		return &dev->stats;
 
 	spin_lock_irqsave(&ei_local->page_lock,flags);
 	/* Read the counter registers, assuming we are in page 0. */
-	ei_local->stat.rx_frame_errors += ei_inb_p(ioaddr + EN0_COUNTER0);
-	ei_local->stat.rx_crc_errors   += ei_inb_p(ioaddr + EN0_COUNTER1);
-	ei_local->stat.rx_missed_errors+= ei_inb_p(ioaddr + EN0_COUNTER2);
+	dev->stats.rx_frame_errors += ei_inb_p(ioaddr + EN0_COUNTER0);
+	dev->stats.rx_crc_errors   += ei_inb_p(ioaddr + EN0_COUNTER1);
+	dev->stats.rx_missed_errors+= ei_inb_p(ioaddr + EN0_COUNTER2);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
-	return &ei_local->stat;
+	return &dev->stats;
 }
 
 /*

--------------010300070205060405080203--

