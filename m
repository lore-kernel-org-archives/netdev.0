From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] sc92031: use net_device stats
Date: Wed, 2 Apr 2008 10:08:30 -0700
Message-ID: <20080402100830.42f320c1@extreme>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	<20080402091435.39f99428.akpm@linux-foundation.org>
	<20080402094923.185f15dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59832 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162AbYDBRIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 13:08:35 -0400
In-Reply-To: <20080402094923.185f15dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statistics structure is available for use in net_device structure.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Patch against 2.6.25-rc8 with previous SET_NETDEV_DEV patch
applied.

--- a/drivers/net/sc92031.c	2008-04-02 09:47:41.000000000 -0700
+++ b/drivers/net/sc92031.c	2008-04-02 09:49:34.000000000 -0700
@@ -311,7 +311,6 @@ struct sc92031_priv {
 
 	/* for dev->get_stats */
 	long			rx_value;
-	struct net_device_stats	stats;
 };
 
 /* I don't know which registers can be safely read; however, I can guess
@@ -421,7 +420,7 @@ static void _sc92031_tx_clear(struct net
 
 	while (priv->tx_head - priv->tx_tail > 0) {
 		priv->tx_tail++;
-		priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 	}
 	priv->tx_head = priv->tx_tail = 0;
 }
@@ -676,27 +675,27 @@ static void _sc92031_tx_tasklet(struct n
 		priv->tx_tail++;
 
 		if (tx_status & TxStatOK) {
-			priv->stats.tx_bytes += tx_status & 0x1fff;
-			priv->stats.tx_packets++;
+			dev->stats.tx_bytes += tx_status & 0x1fff;
+			dev->stats.tx_packets++;
 			/* Note: TxCarrierLost is always asserted at 100mbps. */
-			priv->stats.collisions += (tx_status >> 22) & 0xf;
+			dev->stats.collisions += (tx_status >> 22) & 0xf;
 		}
 
 		if (tx_status & (TxOutOfWindow | TxAborted)) {
-			priv->stats.tx_errors++;
+			dev->stats.tx_errors++;
 
 			if (tx_status & TxAborted)
-				priv->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 
 			if (tx_status & TxCarrierLost)
-				priv->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 
 			if (tx_status & TxOutOfWindow)
-				priv->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 		}
 
 		if (tx_status & TxUnderrun)
-			priv->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 	}
 
 	if (priv->tx_tail != old_tx_tail)
@@ -704,27 +703,29 @@ static void _sc92031_tx_tasklet(struct n
 			netif_wake_queue(dev);
 }
 
-static void _sc92031_rx_tasklet_error(u32 rx_status,
-		struct sc92031_priv *priv, unsigned rx_size)
+static void _sc92031_rx_tasklet_error(struct net_device *dev,
+				      u32 rx_status, unsigned rx_size)
 {
 	if(rx_size > (MAX_ETH_FRAME_SIZE + 4) || rx_size < 16) {
-		priv->stats.rx_errors++;
-		priv->stats.rx_length_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_length_errors++;
 	}
 
 	if (!(rx_status & RxStatesOK)) {
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 		if (rx_status & (RxHugeFrame | RxSmallFrame))
-			priv->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 
 		if (rx_status & RxBadAlign)
-			priv->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 
 		if (!(rx_status & RxCRCOK))
-			priv->stats.rx_crc_errors++;
-	} else
+			dev->stats.rx_crc_errors++;
+	} else {
+		struct sc92031_priv *priv = netdev_priv(dev);
 		priv->rx_loss++;
+	}
 }
 
 static void _sc92031_rx_tasklet(struct net_device *dev)
@@ -783,7 +784,7 @@ static void _sc92031_rx_tasklet(struct n
 				|| rx_size > (MAX_ETH_FRAME_SIZE + 4)
 				|| rx_size < 16
 				|| !(rx_status & RxStatesOK))) {
-			_sc92031_rx_tasklet_error(rx_status, priv, rx_size);
+			_sc92031_rx_tasklet_error(dev, rx_status, rx_size);
 			break;
 		}
 
@@ -818,11 +819,11 @@ static void _sc92031_rx_tasklet(struct n
 		dev->last_rx = jiffies;
 		netif_rx(skb);
 
-		priv->stats.rx_bytes += pkt_size;
-		priv->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_size;
+		dev->stats.rx_packets++;
 
 		if (rx_status & Rx_Multicast)
-			priv->stats.multicast++;
+			dev->stats.multicast++;
 
 	next:
 		rx_ring_offset = (rx_ring_offset + rx_size_align) % RX_BUF_LEN;
@@ -835,13 +836,11 @@ static void _sc92031_rx_tasklet(struct n
 
 static void _sc92031_link_tasklet(struct net_device *dev)
 {
-	struct sc92031_priv *priv = netdev_priv(dev);
-
 	if (_sc92031_check_media(dev))
 		netif_wake_queue(dev);
 	else {
 		netif_stop_queue(dev);
-		priv->stats.tx_carrier_errors++;
+		dev->stats.tx_carrier_errors++;
 	}
 }
 
@@ -866,11 +865,11 @@ static void sc92031_tasklet(unsigned lon
 		_sc92031_rx_tasklet(dev);
 
 	if (intr_status & RxOverflow)
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (intr_status & TimeOut) {
-		priv->stats.rx_errors++;
-		priv->stats.rx_length_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_length_errors++;
 	}
 
 	if (intr_status & (LinkFail | LinkOK))
@@ -936,15 +935,14 @@ static struct net_device_stats *sc92031_
 
 		if (temp == 0xffff) {
 			priv->rx_value += temp;
-			priv->stats.rx_fifo_errors = priv->rx_value;
-		} else {
-			priv->stats.rx_fifo_errors = temp + priv->rx_value;
-		}
+			dev->stats.rx_fifo_errors = priv->rx_value;
+		} else
+			dev->stats.rx_fifo_errors = temp + priv->rx_value;
 
 		spin_unlock_bh(&priv->lock);
 	}
 
-	return &priv->stats;
+	return &dev->stats;
 }
 
 static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -959,7 +957,7 @@ static int sc92031_start_xmit(struct sk_
 
 	if (unlikely(skb->len > TX_BUF_SIZE)) {
 		err = -EMSGSIZE;
-		priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		goto out;
 	}
 
@@ -967,7 +965,7 @@ static int sc92031_start_xmit(struct sk_
 
 	if (unlikely(!netif_carrier_ok(dev))) {
 		err = -ENOLINK;
-		priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		goto out_unlock;
 	}
 
