From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: [PATCH] atmel: use netstats in net_device structure
Date: Tue, 06 May 2008 23:50:30 +0300
Message-ID: <4820C496.1040204@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070806020003090804060808"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070806020003090804060808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill atmel_get_stats function, because by default it is used
identical internal_stats function from net/core/dev.c
No need to memset stats to 0, because they are allocated by kzalloc.

P.S. Someone should cleanup init_atmel_card function from unneeded
initializations to 0/NULL. Out of scope for this patch.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------070806020003090804060808
Content-Type: text/x-patch;
 name="atmel_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atmel_netstats.patch"

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index ef2da40..f978a9d 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -433,7 +433,6 @@ struct atmel_private {
 	struct net_device *dev;
 	struct device *sys_dev;
 	struct iw_statistics wstats;
-	struct net_device_stats	stats;	// device stats
 	spinlock_t irqlock, timerlock;	// spinlocks
 	enum { BUS_TYPE_PCCARD, BUS_TYPE_PCI } bus_type;
 	enum {
@@ -694,9 +693,9 @@ static void tx_done_irq(struct atmel_private *priv)
 
 		if (type == TX_PACKET_TYPE_DATA) {
 			if (status == TX_STATUS_SUCCESS)
-				priv->stats.tx_packets++;
+				priv->dev->stats.tx_packets++;
 			else
-				priv->stats.tx_errors++;
+				priv->dev->stats.tx_errors++;
 			netif_wake_queue(priv->dev);
 		}
 	}
@@ -792,13 +791,13 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	if (priv->card && priv->present_callback &&
 	    !(*priv->present_callback)(priv->card)) {
-		priv->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		dev_kfree_skb(skb);
 		return 0;
 	}
 
 	if (priv->station_state != STATION_STATE_READY) {
-		priv->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -815,7 +814,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	   initial + 18 (+30-12) */
 
 	if (!(buff = find_tx_buff(priv, len + 18))) {
-		priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		spin_unlock_irqrestore(&priv->irqlock, flags);
 		spin_unlock_bh(&priv->timerlock);
 		netif_stop_queue(dev);
@@ -851,7 +850,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	/* low bit of first byte of destination tells us if broadcast */
 	tx_update_descriptor(priv, *(skb->data) & 0x01, len + 18, buff, TX_PACKET_TYPE_DATA);
 	dev->trans_start = jiffies;
-	priv->stats.tx_bytes += len;
+	dev->stats.tx_bytes += len;
 
 	spin_unlock_irqrestore(&priv->irqlock, flags);
 	spin_unlock_bh(&priv->timerlock);
@@ -895,7 +894,7 @@ static void fast_rx_path(struct atmel_private *priv,
 	}
 
 	if (!(skb = dev_alloc_skb(msdu_size + 14))) {
-		priv->stats.rx_dropped++;
+		priv->dev->stats.rx_dropped++;
 		return;
 	}
 
@@ -908,7 +907,7 @@ static void fast_rx_path(struct atmel_private *priv,
 		crc = crc32_le(crc, skbp + 12, msdu_size);
 		atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + 30 + msdu_size, 4);
 		if ((crc ^ 0xffffffff) != netcrc) {
-			priv->stats.rx_crc_errors++;
+			priv->dev->stats.rx_crc_errors++;
 			dev_kfree_skb(skb);
 			return;
 		}
@@ -924,8 +923,8 @@ static void fast_rx_path(struct atmel_private *priv,
 	skb->protocol = eth_type_trans(skb, priv->dev);
 	skb->ip_summed = CHECKSUM_NONE;
 	netif_rx(skb);
-	priv->stats.rx_bytes += 12 + msdu_size;
-	priv->stats.rx_packets++;
+	priv->dev->stats.rx_bytes += 12 + msdu_size;
+	priv->dev->stats.rx_packets++;
 }
 
 /* Test to see if the packet in card memory at packet_loc has a valid CRC
@@ -991,7 +990,7 @@ static void frag_rx_path(struct atmel_private *priv,
 			crc = crc32_le(crc, &priv->rx_buf[12], msdu_size);
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
-				priv->stats.rx_crc_errors++;
+				priv->dev->stats.rx_crc_errors++;
 				memset(priv->frag_source, 0xff, 6);
 			}
 		}
@@ -1009,7 +1008,7 @@ static void frag_rx_path(struct atmel_private *priv,
 				       msdu_size);
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
-				priv->stats.rx_crc_errors++;
+				priv->dev->stats.rx_crc_errors++;
 				memset(priv->frag_source, 0xff, 6);
 				more_frags = 1; /* don't send broken assembly */
 			}
@@ -1021,7 +1020,7 @@ static void frag_rx_path(struct atmel_private *priv,
 		if (!more_frags) { /* last one */
 			memset(priv->frag_source, 0xff, 6);
 			if (!(skb = dev_alloc_skb(priv->frag_len + 14))) {
-				priv->stats.rx_dropped++;
+				priv->dev->stats.rx_dropped++;
 			} else {
 				skb_reserve(skb, 2);
 				memcpy(skb_put(skb, priv->frag_len + 12),
@@ -1031,8 +1030,8 @@ static void frag_rx_path(struct atmel_private *priv,
 				skb->protocol = eth_type_trans(skb, priv->dev);
 				skb->ip_summed = CHECKSUM_NONE;
 				netif_rx(skb);
-				priv->stats.rx_bytes += priv->frag_len + 12;
-				priv->stats.rx_packets++;
+				priv->dev->stats.rx_bytes += priv->frag_len + 12;
+				priv->dev->stats.rx_packets++;
 			}
 		}
 	} else
@@ -1057,7 +1056,7 @@ static void rx_done_irq(struct atmel_private *priv)
 			if (status == 0xc1) /* determined by experiment */
 				priv->wstats.discard.nwid++;
 			else
-				priv->stats.rx_errors++;
+				priv->dev->stats.rx_errors++;
 			goto next;
 		}
 
@@ -1065,7 +1064,7 @@ static void rx_done_irq(struct atmel_private *priv)
 		rx_packet_loc = atmel_rmem16(priv, atmel_rx(priv, RX_DESC_MSDU_POS_OFFSET, priv->rx_desc_head));
 
 		if (msdu_size < 30) {
-			priv->stats.rx_errors++;
+			priv->dev->stats.rx_errors++;
 			goto next;
 		}
 
@@ -1123,7 +1122,7 @@ static void rx_done_irq(struct atmel_private *priv)
 				msdu_size -= 4;
 				crc = crc32_le(crc, (unsigned char *)&priv->rx_buf, msdu_size);
 				if ((crc ^ 0xffffffff) != (*((u32 *)&priv->rx_buf[msdu_size]))) {
-					priv->stats.rx_crc_errors++;
+					priv->dev->stats.rx_crc_errors++;
 					goto next;
 				}
 			}
@@ -1250,12 +1249,6 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 	}
 }
 
-static struct net_device_stats *atmel_get_stats(struct net_device *dev)
-{
-	struct atmel_private *priv = netdev_priv(dev);
-	return &priv->stats;
-}
--------------070806020003090804060808--
