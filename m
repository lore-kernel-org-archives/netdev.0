From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH] pcnet32:  remove private net_device_stats structure
Date: Wed, 17 Oct 2007 17:06:19 -0700
Message-ID: <1192665979.13749.7.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:51541 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbXJRANA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:13:00 -0400
Received: from [192.168.1.2] ([71.117.241.192])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JQ200BM8Z9KDYJ4@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 17 Oct 2007 19:12:59 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the statistics from the private structure.
Use the net_device_stats in netn_device structure.

Following Jeff Garzik's massive cleanup Sep 01.
pcnet32 was not "low-hanging fruit".

Tested x86_64.

Signed-off-by:  Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.23-git7/drivers/net/cleaner.pcnet32.c	2007-10-17 16:00:44.000000000 -0700
+++ linux-2.6.23-git7/drivers/net/pcnet32.c	2007-10-17 16:44:50.000000000 -0700
@@ -282,7 +282,6 @@ struct pcnet32_private {
 
 	struct net_device	*dev;
 	struct napi_struct	napi;
-	struct net_device_stats	stats;
 	char			tx_full;
 	char			phycount;	/* number of phys found */
 	int			options;
@@ -1182,15 +1181,15 @@ static void pcnet32_rx_entry(struct net_
 		 * buffers, with only the last correctly noting the error.
 		 */
 		if (status & 0x01)	/* Only count a general error at the */
-			lp->stats.rx_errors++;	/* end of a packet. */
+			dev->stats.rx_errors++;	/* end of a packet. */
 		if (status & 0x20)
-			lp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & 0x10)
-			lp->stats.rx_over_errors++;
+			dev->stats.rx_over_errors++;
 		if (status & 0x08)
-			lp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		if (status & 0x04)
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 		return;
 	}
 
@@ -1201,13 +1200,13 @@ static void pcnet32_rx_entry(struct net_
 		if (netif_msg_drv(lp))
 			printk(KERN_ERR "%s: Impossible packet size %d!\n",
 			       dev->name, pkt_len);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 	if (pkt_len < 60) {
 		if (netif_msg_rx_err(lp))
 			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		return;
 	}
 
@@ -1241,7 +1240,7 @@ static void pcnet32_rx_entry(struct net_
 			printk(KERN_ERR
 			       "%s: Memory squeeze, dropping packet.\n",
 			       dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb->dev = dev;
@@ -1260,7 +1259,7 @@ static void pcnet32_rx_entry(struct net_
 					       pkt_len,
 					       PCI_DMA_FROMDEVICE);
 	}
-	lp->stats.rx_bytes += skb->len;
+	dev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
 #ifdef CONFIG_PCNET32_NAPI
 	netif_receive_skb(skb);
@@ -1268,7 +1267,7 @@ static void pcnet32_rx_entry(struct net_
 	netif_rx(skb);
 #endif
 	dev->last_rx = jiffies;
-	lp->stats.rx_packets++;
+	dev->stats.rx_packets++;
 	return;
 }
 
@@ -1316,21 +1315,21 @@ static int pcnet32_tx(struct net_device 
 		if (status & 0x4000) {
 			/* There was a major error, log it. */
 			int err_status = le32_to_cpu(lp->tx_ring[entry].misc);
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (netif_msg_tx_err(lp))
 				printk(KERN_ERR
 				       "%s: Tx error status=%04x err_status=%08x\n",
 				       dev->name, status,
 				       err_status);
 			if (err_status & 0x04000000)
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (err_status & 0x08000000)
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (err_status & 0x10000000)
-				lp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 #ifndef DO_DXSUFLO
 			if (err_status & 0x40000000) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				/* Ackk!  On FIFO errors the Tx unit is turned off! */
 				/* Remove this verbosity later! */
 				if (netif_msg_tx_err(lp))
@@ -1341,7 +1340,7 @@ static int pcnet32_tx(struct net_device 
 			}
 #else
 			if (err_status & 0x40000000) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
 					/* Ackk!  On FIFO errors the Tx unit is turned off! */
 					/* Remove this verbosity later! */
@@ -1355,8 +1354,8 @@ static int pcnet32_tx(struct net_device 
 #endif
 		} else {
 			if (status & 0x1800)
-				lp->stats.collisions++;
-			lp->stats.tx_packets++;
+				dev->stats.collisions++;
+			dev->stats.tx_packets++;
 		}
 
 		/* We must free the original skb */
@@ -2478,7 +2477,7 @@ static void pcnet32_tx_timeout(struct ne
 		       "%s: transmit timed out, status %4.4x, resetting.\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (netif_msg_tx_err(lp)) {
 		int i;
 		printk(KERN_DEBUG
@@ -2548,7 +2547,7 @@ static int pcnet32_start_xmit(struct sk_
 	lp->tx_ring[entry].status = cpu_to_le16(status);
 
 	lp->cur_tx++;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
@@ -2593,7 +2592,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
-			lp->stats.tx_errors++;	/* Tx babble. */
+			dev->stats.tx_errors++;	/* Tx babble. */
 		if (csr0 & 0x1000) {
 			/*
 			 * This happens when our receive ring is full. This
@@ -2606,7 +2605,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 			 * don't get a rx interrupt, but a missed frame
 			 * interrupt sooner or later.
 			 */
-			lp->stats.rx_errors++;	/* Missed a Rx frame. */
+			dev->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
 			if (netif_msg_drv(lp))
@@ -2668,7 +2667,7 @@ static int pcnet32_close(struct net_devi
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
 
 	if (netif_msg_ifdown(lp))
 		printk(KERN_DEBUG
@@ -2705,10 +2704,10 @@ static struct net_device_stats *pcnet32_
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /* taken from the sunlance driver, which it took from the depca driver */


