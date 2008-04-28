From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] lance: use netstats in net_device structure
Date: Mon, 28 Apr 2008 18:57:57 +0300
Message-ID: <4815F405.8010000@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040404000204070204000207"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59356 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933996AbYD1P6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 11:58:30 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqVkK-0000M8-Tm
	for netdev@vger.kernel.org; Mon, 28 Apr 2008 15:58:29 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 15:58:28 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 15:58:28 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040404000204070204000207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------040404000204070204000207
Content-Type: text/x-patch;
 name="lance_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lance_netstats.patch"

diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 977ed34..00ac33a 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -248,7 +248,6 @@ struct lance_private {
 	int cur_rx, cur_tx;			/* The next free ring entry */
 	int dirty_rx, dirty_tx;		/* The ring entries to be free()ed. */
 	int dma;
-	struct net_device_stats stats;
 	unsigned char chip_version;	/* See lance_chip_type. */
 	spinlock_t devlock;
 };
@@ -917,7 +916,7 @@ static void lance_tx_timeout (struct net_device *dev)
 	printk ("%s: transmit timed out, status %4.4x, resetting.\n",
 		dev->name, inw (ioaddr + LANCE_DATA));
 	outw (0x0004, ioaddr + LANCE_DATA);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 #ifndef final_version
 	if (lance_debug > 3) {
 		int i;
@@ -980,7 +979,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	lp->tx_ring[entry].misc = 0x0000;
 
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* If any part of this buffer is >16M we must copy it to a low-memory
 	   buffer. */
@@ -1055,13 +1054,13 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 				if (status & 0x40000000) {
 					/* There was an major error, log it. */
 					int err_status = lp->tx_ring[entry].misc;
-					lp->stats.tx_errors++;
-					if (err_status & 0x0400) lp->stats.tx_aborted_errors++;
-					if (err_status & 0x0800) lp->stats.tx_carrier_errors++;
-					if (err_status & 0x1000) lp->stats.tx_window_errors++;
+					dev->stats.tx_errors++;
+					if (err_status & 0x0400) dev->stats.tx_aborted_errors++;
+					if (err_status & 0x0800) dev->stats.tx_carrier_errors++;
+					if (err_status & 0x1000) dev->stats.tx_window_errors++;
 					if (err_status & 0x4000) {
 						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						lp->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 						/* Remove this verbosity later! */
 						printk("%s: Tx FIFO error! Status %4.4x.\n",
 							   dev->name, csr0);
@@ -1070,8 +1069,8 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 					}
 				} else {
 					if (status & 0x18000000)
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
+						dev->stats.collisions++;
+					dev->stats.tx_packets++;
 				}
 
 				/* We must free the original skb if it's not a data-only copy
@@ -1101,8 +1100,8 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 		}
 
 		/* Log misc errors. */
-		if (csr0 & 0x4000) lp->stats.tx_errors++; /* Tx babble. */
-		if (csr0 & 0x1000) lp->stats.rx_errors++; /* Missed a Rx frame. */
+		if (csr0 & 0x4000) dev->stats.tx_errors++; /* Tx babble. */
+		if (csr0 & 0x1000) dev->stats.rx_errors++; /* Missed a Rx frame. */
 		if (csr0 & 0x0800) {
 			printk("%s: Bus master arbitration failure, status %4.4x.\n",
 				   dev->name, csr0);
@@ -1148,11 +1147,11 @@ lance_rx(struct net_device *dev)
 			   buffers it's possible for a jabber packet to use two
 			   buffers, with only the last correctly noting the error. */
 			if (status & 0x01)	/* Only count a general error at the */
-				lp->stats.rx_errors++; /* end of a packet.*/
-			if (status & 0x20) lp->stats.rx_frame_errors++;
-			if (status & 0x10) lp->stats.rx_over_errors++;
-			if (status & 0x08) lp->stats.rx_crc_errors++;
-			if (status & 0x04) lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++; /* end of a packet.*/
+			if (status & 0x20) dev->stats.rx_frame_errors++;
+			if (status & 0x10) dev->stats.rx_over_errors++;
+			if (status & 0x08) dev->stats.rx_crc_errors++;
+			if (status & 0x04) dev->stats.rx_fifo_errors++;
 			lp->rx_ring[entry].base &= 0x03ffffff;
 		}
 		else
@@ -1164,7 +1163,7 @@ lance_rx(struct net_device *dev)
 			if(pkt_len<60)
 			{
 				printk("%s: Runt packet!\n",dev->name);
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 			}
 			else
 			{
@@ -1178,7 +1177,7 @@ lance_rx(struct net_device *dev)
 
 					if (i > RX_RING_SIZE -2)
 					{
-						lp->stats.rx_dropped++;
+						dev->stats.rx_dropped++;
 						lp->rx_ring[entry].base |= 0x80000000;
 						lp->cur_rx++;
 					}
@@ -1192,8 +1191,8 @@ lance_rx(struct net_device *dev)
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes+=pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes+=pkt_len;
 			}
 		}
 		/* The docs say that the buffer length isn't touched, but Andrew Boyd
@@ -1219,7 +1218,7 @@ lance_close(struct net_device *dev)
 
 	if (chip_table[lp->chip_version].flags & LANCE_HAS_MISSED_FRAME) {
 		outw(112, ioaddr+LANCE_ADDR);
-		lp->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
+		dev->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
 	}
 	outw(0, ioaddr+LANCE_ADDR);
 
@@ -1256,12 +1255,12 @@ static struct net_device_stats *lance_get_stats(struct net_device *dev)
 		spin_lock_irqsave(&lp->devlock, flags);
 		saved_addr = inw(ioaddr+LANCE_ADDR);
 		outw(112, ioaddr+LANCE_ADDR);
-		lp->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
+		dev->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
 		outw(saved_addr, ioaddr+LANCE_ADDR);
 		spin_unlock_irqrestore(&lp->devlock, flags);
 	}
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.

--------------040404000204070204000207--

