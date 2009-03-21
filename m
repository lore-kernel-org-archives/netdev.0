From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 21/77] usbnet: convert catc to internal net_device_stats
Date: Fri, 20 Mar 2009 22:35:48 -0700
Message-ID: <20090321053714.119627877@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36577 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760907AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-catc-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/catc.c	2009-03-20 12:09:50.229089806 -0700
+++ b/drivers/net/usb/catc.c	2009-03-20 12:10:10.851651580 -0700
@@ -163,7 +163,6 @@ struct catc {
 	struct net_device *netdev;
 	struct usb_device *usbdev;
 
-	struct net_device_stats stats;
 	unsigned long flags;
 
 	unsigned int tx_ptr, tx_idx;
@@ -245,8 +244,8 @@ static void catc_rx_done(struct urb *urb
 		if(!catc->is_f5u011) {
 			pkt_len = le16_to_cpup((__le16*)pkt_start);
 			if (pkt_len > urb->actual_length) {
-				catc->stats.rx_length_errors++;
-				catc->stats.rx_errors++;
+				catc->netdev->stats.rx_length_errors++;
+				catc->netdev->stats.rx_errors++;
 				break;
 			}
 		} else {
@@ -262,8 +261,8 @@ static void catc_rx_done(struct urb *urb
 		skb->protocol = eth_type_trans(skb, catc->netdev);
 		netif_rx(skb);
 
-		catc->stats.rx_packets++;
-		catc->stats.rx_bytes += pkt_len;
+		catc->netdev->stats.rx_packets++;
+		catc->netdev->stats.rx_bytes += pkt_len;
 
 		/* F5U011 only does one packet per RX */
 		if (catc->is_f5u011)
@@ -386,7 +385,7 @@ static void catc_tx_done(struct urb *urb
 		dbg("Tx Reset.");
 		urb->status = 0;
 		catc->netdev->trans_start = jiffies;
-		catc->stats.tx_errors++;
+		catc->netdev->stats.tx_errors++;
 		clear_bit(TX_RUNNING, &catc->flags);
 		netif_wake_queue(catc->netdev);
 		return;
@@ -412,7 +411,7 @@ static void catc_tx_done(struct urb *urb
 	spin_unlock_irqrestore(&catc->tx_lock, flags);
 }
 
-static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int catc_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
 	unsigned long flags;
@@ -443,8 +442,8 @@ static int catc_hard_start_xmit(struct s
 	spin_unlock_irqrestore(&catc->tx_lock, flags);
 
 	if (r >= 0) {
-		catc->stats.tx_bytes += skb->len;
-		catc->stats.tx_packets++;
+		catc->netdev->stats.tx_bytes += skb->len;
+		catc->netdev->stats.tx_packets++;
 	}
 
 	dev_kfree_skb(skb);
@@ -588,15 +587,15 @@ static void catc_stats_done(struct catc 
 	switch (index) {
 		case TxSingleColl:
 		case TxMultiColl:
-			catc->stats.collisions += data - last;
+			catc->netdev->stats.collisions += data - last;
 			break;
 		case TxExcessColl:
-			catc->stats.tx_aborted_errors += data - last;
-			catc->stats.tx_errors += data - last;
+			catc->netdev->stats.tx_aborted_errors += data - last;
+			catc->netdev->stats.tx_errors += data - last;
 			break;
 		case RxFramErr:
-			catc->stats.rx_frame_errors += data - last;
-			catc->stats.rx_errors += data - last;
+			catc->netdev->stats.rx_frame_errors += data - last;
+			catc->netdev->stats.rx_errors += data - last;
 			break;
 	}
 
@@ -614,12 +613,6 @@ static void catc_stats_timer(unsigned lo
 	mod_timer(&catc->timer, jiffies + STATS_UPDATE);
 }
 
-static struct net_device_stats *catc_get_stats(struct net_device *netdev)
-{
-	struct catc *catc = netdev_priv(netdev);
-	return &catc->stats;
-}
-
 /*
  * Receive modes. Broadcast, Multicast, Promisc.
  */
@@ -777,7 +770,6 @@ static int catc_probe(struct usb_interfa
 	netdev->open = catc_open;
 	netdev->hard_start_xmit = catc_hard_start_xmit;
 	netdev->stop = catc_stop;
-	netdev->get_stats = catc_get_stats;
 	netdev->tx_timeout = catc_tx_timeout;
 	netdev->watchdog_timeo = TX_TIMEOUT;
 	netdev->set_multicast_list = catc_set_multicast_list;

-- 

