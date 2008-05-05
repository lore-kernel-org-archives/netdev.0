From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 8139cp: use netstats in net_device structure
Date: Mon, 05 May 2008 16:05:17 +0300
Message-ID: <481F060D.1080906@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050800010509020802090203"
Cc: jeff@garzik.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55369 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646AbYEENFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 09:05:35 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt0Nk-0004Z0-LB
	for netdev@vger.kernel.org; Mon, 05 May 2008 13:05:28 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 13:05:28 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 13:05:28 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050800010509020802090203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------050800010509020802090203
Content-Type: text/x-patch;
 name="8139cp_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8139cp_netstats.patch"

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a453eda..934db35 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -340,7 +340,6 @@ struct cp_private {
 	u32			rx_config;
 	u16			cpcmd;
 
-	struct net_device_stats net_stats;
 	struct cp_extra_stats	cp_stats;
 
 	unsigned		rx_head		____cacheline_aligned;
@@ -457,8 +456,8 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 {
 	skb->protocol = eth_type_trans (skb, cp->dev);
 
-	cp->net_stats.rx_packets++;
-	cp->net_stats.rx_bytes += skb->len;
+	cp->dev->stats.rx_packets++;
+	cp->dev->stats.rx_bytes += skb->len;
 	cp->dev->last_rx = jiffies;
 
 #if CP_VLAN_TAG_USED
@@ -477,17 +476,17 @@ static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
 		printk (KERN_DEBUG
 			"%s: rx err, slot %d status 0x%x len %d\n",
 			cp->dev->name, rx_tail, status, len);
-	cp->net_stats.rx_errors++;
+	cp->dev->stats.rx_errors++;
 	if (status & RxErrFrame)
-		cp->net_stats.rx_frame_errors++;
+		cp->dev->stats.rx_frame_errors++;
 	if (status & RxErrCRC)
-		cp->net_stats.rx_crc_errors++;
+		cp->dev->stats.rx_crc_errors++;
 	if ((status & RxErrRunt) || (status & RxErrLong))
-		cp->net_stats.rx_length_errors++;
+		cp->dev->stats.rx_length_errors++;
 	if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag))
-		cp->net_stats.rx_length_errors++;
+		cp->dev->stats.rx_length_errors++;
 	if (status & RxErrFIFO)
-		cp->net_stats.rx_fifo_errors++;
+		cp->dev->stats.rx_fifo_errors++;
 }
 
 static inline unsigned int cp_rx_csum_ok (u32 status)
@@ -539,7 +538,7 @@ rx_status_loop:
 			 * that RX fragments are never encountered
 			 */
 			cp_rx_err_acct(cp, rx_tail, status, len);
-			cp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			cp->cp_stats.rx_frags++;
 			goto rx_next;
 		}
@@ -556,7 +555,7 @@ rx_status_loop:
 		buflen = cp->rx_buf_sz + RX_OFFSET;
 		new_skb = dev_alloc_skb (buflen);
 		if (!new_skb) {
-			cp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto rx_next;
 		}
 
@@ -710,20 +709,20 @@ static void cp_tx (struct cp_private *cp)
 				if (netif_msg_tx_err(cp))
 					printk(KERN_DEBUG "%s: tx err, status 0x%x\n",
 					       cp->dev->name, status);
-				cp->net_stats.tx_errors++;
+				cp->dev->stats.tx_errors++;
 				if (status & TxOWC)
-					cp->net_stats.tx_window_errors++;
+					cp->dev->stats.tx_window_errors++;
 				if (status & TxMaxCol)
-					cp->net_stats.tx_aborted_errors++;
+					cp->dev->stats.tx_aborted_errors++;
 				if (status & TxLinkFail)
-					cp->net_stats.tx_carrier_errors++;
+					cp->dev->stats.tx_carrier_errors++;
 				if (status & TxFIFOUnder)
-					cp->net_stats.tx_fifo_errors++;
+					cp->dev->stats.tx_fifo_errors++;
 			} else {
-				cp->net_stats.collisions +=
+				cp->dev->stats.collisions +=
 					((status >> TxColCntShift) & TxColCntMask);
-				cp->net_stats.tx_packets++;
-				cp->net_stats.tx_bytes += skb->len;
+				cp->dev->stats.tx_packets++;
+				cp->dev->stats.tx_bytes += skb->len;
 				if (netif_msg_tx_done(cp))
 					printk(KERN_DEBUG "%s: tx done, slot %d\n", cp->dev->name, tx_tail);
 			}
@@ -956,7 +955,7 @@ static void cp_set_rx_mode (struct net_device *dev)
 static void __cp_get_stats(struct cp_private *cp)
 {
 	/* only lower 24 bits valid; write any value to clear */
-	cp->net_stats.rx_missed_errors += (cpr32 (RxMissed) & 0xffffff);
+	cp->dev->stats.rx_missed_errors += (cpr32 (RxMissed) & 0xffffff);
 	cpw32 (RxMissed, 0);
 }
 
@@ -971,7 +970,7 @@ static struct net_device_stats *cp_get_stats(struct net_device *dev)
  		__cp_get_stats(cp);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
-	return &cp->net_stats;
+	return &dev->stats;
 }
 
 static void cp_stop_hw (struct cp_private *cp)
@@ -1142,7 +1141,7 @@ static void cp_clean_rings (struct cp_private *cp)
 					 PCI_DMA_TODEVICE);
 			if (le32_to_cpu(desc->opts1) & LastFrag)
 				dev_kfree_skb(skb);
-			cp->net_stats.tx_dropped++;
+			cp->dev->stats.tx_dropped++;
 		}
 	}
 

--------------050800010509020802090203--

