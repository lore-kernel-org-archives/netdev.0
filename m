From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 11/14] net: tulip: de2104x: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:36 +0200
Message-ID: <20170407081739.5243-12-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34522 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755232AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
de_private, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/dec/tulip/de2104x.c | 42 +++++++++++++++-----------------
 1 file changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 127ce9707378..91b8f6f5a765 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -312,8 +312,6 @@ struct de_private {
 
 	u32			msg_enable;
 
-	struct net_device_stats net_stats;
-
 	struct pci_dev		*pdev;
 
 	u16			setup_frame[DE_SETUP_FRAME_WORDS];
@@ -388,14 +386,14 @@ static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 			netif_warn(de, rx_err, de->dev,
 				   "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
 				   status);
-			de->net_stats.rx_length_errors++;
+			de->dev->stats.rx_length_errors++;
 		}
 	} else if (status & RxError) {
 		/* There was a fatal error. */
-		de->net_stats.rx_errors++; /* end of a packet.*/
-		if (status & 0x0890) de->net_stats.rx_length_errors++;
-		if (status & RxErrCRC) de->net_stats.rx_crc_errors++;
-		if (status & RxErrFIFO) de->net_stats.rx_fifo_errors++;
+		de->dev->stats.rx_errors++; /* end of a packet.*/
+		if (status & 0x0890) de->dev->stats.rx_length_errors++;
+		if (status & RxErrCRC) de->dev->stats.rx_crc_errors++;
+		if (status & RxErrFIFO) de->dev->stats.rx_fifo_errors++;
 	}
 }
 
@@ -423,7 +421,7 @@ static void de_rx (struct de_private *de)
 		mapping = de->rx_skb[rx_tail].mapping;
 
 		if (unlikely(drop)) {
-			de->net_stats.rx_dropped++;
+			de->dev->stats.rx_dropped++;
 			goto rx_next;
 		}
 
@@ -441,7 +439,7 @@ static void de_rx (struct de_private *de)
 		buflen = copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
 		copy_skb = netdev_alloc_skb(de->dev, buflen);
 		if (unlikely(!copy_skb)) {
-			de->net_stats.rx_dropped++;
+			de->dev->stats.rx_dropped++;
 			drop = 1;
 			rx_work = 100;
 			goto rx_next;
@@ -470,8 +468,8 @@ static void de_rx (struct de_private *de)
 
 		skb->protocol = eth_type_trans (skb, de->dev);
 
-		de->net_stats.rx_packets++;
-		de->net_stats.rx_bytes += skb->len;
+		de->dev->stats.rx_packets++;
+		de->dev->stats.rx_bytes += skb->len;
 		rc = netif_rx (skb);
 		if (rc == NET_RX_DROP)
 			drop = 1;
@@ -572,18 +570,18 @@ static void de_tx (struct de_private *de)
 				netif_dbg(de, tx_err, de->dev,
 					  "tx err, status 0x%x\n",
 					  status);
-				de->net_stats.tx_errors++;
+				de->dev->stats.tx_errors++;
 				if (status & TxOWC)
-					de->net_stats.tx_window_errors++;
+					de->dev->stats.tx_window_errors++;
 				if (status & TxMaxCol)
-					de->net_stats.tx_aborted_errors++;
+					de->dev->stats.tx_aborted_errors++;
 				if (status & TxLinkFail)
-					de->net_stats.tx_carrier_errors++;
+					de->dev->stats.tx_carrier_errors++;
 				if (status & TxFIFOUnder)
-					de->net_stats.tx_fifo_errors++;
+					de->dev->stats.tx_fifo_errors++;
 			} else {
-				de->net_stats.tx_packets++;
-				de->net_stats.tx_bytes += skb->len;
+				de->dev->stats.tx_packets++;
+				de->dev->stats.tx_bytes += skb->len;
 				netif_dbg(de, tx_done, de->dev,
 					  "tx done, slot %d\n", tx_tail);
 			}
@@ -814,9 +812,9 @@ static void de_set_rx_mode (struct net_device *dev)
 static inline void de_rx_missed(struct de_private *de, u32 rx_missed)
 {
 	if (unlikely(rx_missed & RxMissedOver))
-		de->net_stats.rx_missed_errors += RxMissedMask;
+		de->dev->stats.rx_missed_errors += RxMissedMask;
 	else
-		de->net_stats.rx_missed_errors += (rx_missed & RxMissedMask);
+		de->dev->stats.rx_missed_errors += (rx_missed & RxMissedMask);
 }
 
 static void __de_get_stats(struct de_private *de)
@@ -836,7 +834,7 @@ static struct net_device_stats *de_get_stats(struct net_device *dev)
  		__de_get_stats(de);
 	spin_unlock_irq(&de->lock);
 
-	return &de->net_stats;
+	return &dev->stats;
 }
 
 static inline int de_is_running (struct de_private *de)
@@ -1348,7 +1346,7 @@ static void de_clean_rings (struct de_private *de)
 		struct sk_buff *skb = de->tx_skb[i].skb;
 		if ((skb) && (skb != DE_DUMMY_SKB)) {
 			if (skb != DE_SETUP_SKB) {
-				de->net_stats.tx_dropped++;
+				de->dev->stats.tx_dropped++;
 				pci_unmap_single(de->pdev,
 					de->tx_skb[i].mapping,
 					skb->len, PCI_DMA_TODEVICE);
-- 
2.12.2
