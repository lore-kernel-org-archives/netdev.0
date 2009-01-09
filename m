From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 36/45] dmascc: convert to internal network device stats
Date: Fri, 09 Jan 2009 15:01:33 -0800
Message-ID: <20090109230139.400592115@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, klaus.kudielka@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42253 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754588AbZAIXSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:06 -0500
Content-Disposition: inline; filename=dmascc-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamradio/dmascc.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/dmascc.c	2009-01-09 11:07:16.000000000 -0800
@@ -195,7 +195,7 @@ struct scc_priv {
 	int chip;
 	struct net_device *dev;
 	struct scc_info *info;
-	struct net_device_stats stats;
+
 	int channel;
 	int card_base, scc_cmd, scc_data;
 	int tmr_cnt, tmr_ctrl, tmr_mode;
@@ -239,7 +239,6 @@ static int scc_open(struct net_device *d
 static int scc_close(struct net_device *dev);
 static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int scc_send_packet(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *scc_get_stats(struct net_device *dev);
 static int scc_set_mac_address(struct net_device *dev, void *sa);
 
 static inline void tx_on(struct scc_priv *priv);
@@ -961,14 +960,6 @@ static int scc_send_packet(struct sk_buf
 }
 
 
-static struct net_device_stats *scc_get_stats(struct net_device *dev)
-{
-	struct scc_priv *priv = dev->ml_priv;
-
-	return &priv->stats;
-}
-
-
 static int scc_set_mac_address(struct net_device *dev, void *sa)
 {
 	memcpy(dev->dev_addr, ((struct sockaddr *) sa)->sa_data,
@@ -1216,17 +1207,17 @@ static void special_condition(struct scc
 		}
 		if (priv->rx_over) {
 			/* We had an overrun */
-			priv->stats.rx_errors++;
+			priv->dev->stats.rx_errors++;
 			if (priv->rx_over == 2)
-				priv->stats.rx_length_errors++;
+				priv->dev->stats.rx_length_errors++;
 			else
-				priv->stats.rx_fifo_errors++;
+				priv->dev->stats.rx_fifo_errors++;
 			priv->rx_over = 0;
 		} else if (rc & CRC_ERR) {
 			/* Count invalid CRC only if packet length >= minimum */
 			if (cb >= 15) {
-				priv->stats.rx_errors++;
-				priv->stats.rx_crc_errors++;
+				priv->dev->stats.rx_errors++;
+				priv->dev->stats.rx_crc_errors++;
 			}
 		} else {
 			if (cb >= 15) {
@@ -1239,8 +1230,8 @@ static void special_condition(struct scc
 					priv->rx_count++;
 					schedule_work(&priv->rx_work);
 				} else {
-					priv->stats.rx_errors++;
-					priv->stats.rx_over_errors++;
+					priv->dev->stats.rx_errors++;
+					priv->dev->stats.rx_over_errors++;
 				}
 			}
 		}
@@ -1275,7 +1266,7 @@ static void rx_bh(struct work_struct *ug
 		skb = dev_alloc_skb(cb + 1);
 		if (skb == NULL) {
 			/* Drop packet */
-			priv->stats.rx_dropped++;
+			priv->dev->stats.rx_dropped++;
 		} else {
 			/* Fill buffer */
 			data = skb_put(skb, cb + 1);
@@ -1283,8 +1274,8 @@ static void rx_bh(struct work_struct *ug
 			memcpy(&data[1], priv->rx_buf[i], cb);
 			skb->protocol = ax25_type_trans(skb, priv->dev);
 			netif_rx(skb);
-			priv->stats.rx_packets++;
-			priv->stats.rx_bytes += cb;
+			priv->dev->stats.rx_packets++;
+			priv->dev->stats.rx_bytes += cb;
 		}
 		spin_lock_irqsave(&priv->ring_lock, flags);
 		/* Move tail */
@@ -1351,15 +1342,15 @@ static void es_isr(struct scc_priv *priv
 			write_scc(priv, R1, EXT_INT_ENAB | WT_FN_RDYFN);
 		if (res) {
 			/* Update packet statistics */
-			priv->stats.tx_errors++;
-			priv->stats.tx_fifo_errors++;
+			priv->dev->stats.tx_errors++;
+			priv->dev->stats.tx_fifo_errors++;
 			/* Other underrun interrupts may already be waiting */
 			write_scc(priv, R0, RES_EXT_INT);
 			write_scc(priv, R0, RES_EXT_INT);
 		} else {
 			/* Update packet statistics */
-			priv->stats.tx_packets++;
-			priv->stats.tx_bytes += priv->tx_len[i];
+			priv->dev->stats.tx_packets++;
+			priv->dev->stats.tx_bytes += priv->tx_len[i];
 			/* Remove frame from FIFO */
 			priv->tx_tail = (i + 1) % NUM_TX_BUF;
 			priv->tx_count--;
@@ -1425,7 +1416,7 @@ static void tm_isr(struct scc_priv *priv
 		write_scc(priv, R15, DCDIE);
 		priv->rr0 = read_scc(priv, R0);
 		if (priv->rr0 & DCD) {
-			priv->stats.collisions++;
+			priv->dev->stats.collisions++;
 			rx_on(priv);
 			priv->state = RX_ON;
 		} else {


