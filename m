From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 8139too: use netstats in net_device structure
Date: Mon, 05 May 2008 16:24:21 +0300
Message-ID: <481F0A85.5040204@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000909020408000402080208"
Cc: jeff@garzik.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41629 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbYEENYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 09:24:31 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt0g9-0005P5-EC
	for netdev@vger.kernel.org; Mon, 05 May 2008 13:24:29 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 13:24:29 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 13:24:29 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000909020408000402080208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------000909020408000402080208
Content-Type: text/x-patch;
 name="8139too_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8139too_netstats.patch"

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..b23a00c 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -574,7 +574,6 @@ struct rtl8139_private {
 	u32			msg_enable;
 	struct napi_struct	napi;
 	struct net_device	*dev;
-	struct net_device_stats	stats;
 
 	unsigned char		*rx_ring;
 	unsigned int		cur_rx;	/* RX buf index of next pkt */
@@ -1711,7 +1710,7 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 	} else {
 		dev_kfree_skb(skb);
-		tp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return 0;
 	}
 
@@ -1762,27 +1761,27 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 			if (netif_msg_tx_err(tp))
 				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
 					dev->name, txstatus);
-			tp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
-				tp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 				RTL_W32 (TxConfig, TxClearAbt);
 				RTL_W16 (IntrStatus, TxErr);
 				wmb();
 			}
 			if (txstatus & TxCarrierLost)
-				tp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (txstatus & TxOutOfWindow)
-				tp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 		} else {
 			if (txstatus & TxUnderrun) {
 				/* Add 64 to the Tx FIFO threshold. */
 				if (tp->tx_flag < 0x00300000)
 					tp->tx_flag += 0x00020000;
-				tp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			}
-			tp->stats.collisions += (txstatus >> 24) & 15;
-			tp->stats.tx_bytes += txstatus & 0x7ff;
-			tp->stats.tx_packets++;
+			dev->stats.collisions += (txstatus >> 24) & 15;
+			dev->stats.tx_bytes += txstatus & 0x7ff;
+			dev->stats.tx_packets++;
 		}
 
 		dirty_tx++;
@@ -1818,7 +1817,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	if (netif_msg_rx_err (tp))
 		printk(KERN_DEBUG "%s: Ethernet frame had errors, status %8.8x.\n",
 			dev->name, rx_status);
-	tp->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
 			DPRINTK ("%s: Oversized Ethernet frame, status %4.4x!\n",
@@ -1826,11 +1825,11 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			/* A.C.: The chip hangs here. */
 		}
 		if (rx_status & (RxBadSymbol | RxBadAlign))
-			tp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (rx_status & (RxRunt | RxTooLong))
-			tp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (rx_status & RxCRCErr)
-			tp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		tp->xstats.rx_lost_in_ring++;
 	}
@@ -1913,9 +1912,9 @@ static void rtl8139_isr_ack(struct rtl8139_private *tp)
 	/* Clear out errors and receive interrupts */
 	if (likely(status != 0)) {
 		if (unlikely(status & (RxFIFOOver | RxOverflow))) {
-			tp->stats.rx_errors++;
+			tp->dev->stats.rx_errors++;
 			if (status & RxFIFOOver)
-				tp->stats.rx_fifo_errors++;
+				tp->dev->stats.rx_fifo_errors++;
 		}
 		RTL_W16_F (IntrStatus, RxAckBits);
 	}
@@ -2016,8 +2015,8 @@ no_early_rx:
 			skb->protocol = eth_type_trans (skb, dev);
 
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 
 			netif_receive_skb (skb);
 		} else {
@@ -2025,7 +2024,7 @@ no_early_rx:
 				printk (KERN_WARNING
 					"%s: Memory squeeze, dropping packet.\n",
 					dev->name);
-			tp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 		received++;
 
@@ -2072,7 +2071,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	assert (ioaddr != NULL);
 
 	/* Update the error count. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	if ((status & RxUnderrun) && link_changed &&
@@ -2082,12 +2081,12 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	}
 
 	if (status & (RxUnderrun | RxErr))
-		tp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (status & PCSTimeout)
-		tp->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 	if (status & RxUnderrun)
-		tp->stats.rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
 		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
@@ -2227,7 +2226,7 @@ static int rtl8139_close (struct net_device *dev)
 	RTL_W16 (IntrMask, 0);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
@@ -2472,12 +2471,12 @@ static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave (&tp->lock, flags);
-		tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+		dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 		RTL_W32 (RxMissed, 0);
 		spin_unlock_irqrestore (&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -2561,7 +2560,7 @@ static int rtl8139_suspend (struct pci_dev *pdev, pm_message_t state)
 	RTL_W8 (ChipCmd, 0);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);

--------------000909020408000402080208--

