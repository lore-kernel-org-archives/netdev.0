From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bcm63xx_enet: use netdev stats
Date: Tue, 24 Aug 2010 17:53:15 +0200
Message-ID: <1282665195.2477.261.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <ffainelli@freebox.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61499 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487Ab0HXPxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 11:53:21 -0400
Received: by eyg5 with SMTP id 5so3454204eyg.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 08:53:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use integrated net_device stats instead of a private one

Get rid of bcm_enet_get_stats()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bcm63xx_enet.c |   60 +++++++++++++++--------------------
 drivers/net/bcm63xx_enet.h |    1 
 2 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 0d2c5da..e2f70c3 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -293,22 +293,22 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 		/* if the packet does not have start of packet _and_
 		 * end of packet flag set, then just recycle it */
 		if ((len_stat & DMADESC_ESOP_MASK) != DMADESC_ESOP_MASK) {
-			priv->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			continue;
 		}
 
 		/* recycle packet if it's marked as bad */
 		if (unlikely(len_stat & DMADESC_ERR_MASK)) {
-			priv->stats.rx_errors++;
+			dev->stats.rx_errors++;
 
 			if (len_stat & DMADESC_OVSIZE_MASK)
-				priv->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (len_stat & DMADESC_CRC_MASK)
-				priv->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (len_stat & DMADESC_UNDER_MASK)
-				priv->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (len_stat & DMADESC_OV_MASK)
-				priv->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			continue;
 		}
 
@@ -324,7 +324,7 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 			nskb = netdev_alloc_skb_ip_align(dev, len);
 			if (!nskb) {
 				/* forget packet, just rearm desc */
-				priv->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				continue;
 			}
 
@@ -342,8 +342,8 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
-		priv->stats.rx_packets++;
-		priv->stats.rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 		netif_receive_skb(skb);
 
 	} while (--budget > 0);
@@ -403,7 +403,7 @@ static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 		spin_unlock(&priv->tx_lock);
 
 		if (desc->len_stat & DMADESC_UNDER_MASK)
-			priv->stats.tx_errors++;
+			dev->stats.tx_errors++;
 
 		dev_kfree_skb(skb);
 		released++;
@@ -563,8 +563,8 @@ static int bcm_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!priv->tx_desc_count)
 		netif_stop_queue(dev);
 
-	priv->stats.tx_bytes += skb->len;
-	priv->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
 	ret = NETDEV_TX_OK;
 
 out_unlock:
@@ -1141,17 +1141,6 @@ static int bcm_enet_stop(struct net_device *dev)
 }
 
 /*
- * core request to return device rx/tx stats
- */
-static struct net_device_stats *bcm_enet_get_stats(struct net_device *dev)
-{
-	struct bcm_enet_priv *priv;
-
-	priv = netdev_priv(dev);
-	return &priv->stats;
-}
-
-/*
  * ethtool callbacks
  */
 struct bcm_enet_stats {
@@ -1163,16 +1152,18 @@ struct bcm_enet_stats {
 
 #define GEN_STAT(m) sizeof(((struct bcm_enet_priv *)0)->m),		\
 		     offsetof(struct bcm_enet_priv, m)
+#define DEV_STAT(m) sizeof(((struct net_device_stats *)0)->m),		\
+		     offsetof(struct net_device_stats, m)
 
 static const struct bcm_enet_stats bcm_enet_gstrings_stats[] = {
-	{ "rx_packets", GEN_STAT(stats.rx_packets), -1 },
-	{ "tx_packets",	GEN_STAT(stats.tx_packets), -1 },
-	{ "rx_bytes", GEN_STAT(stats.rx_bytes), -1 },
-	{ "tx_bytes", GEN_STAT(stats.tx_bytes), -1 },
-	{ "rx_errors", GEN_STAT(stats.rx_errors), -1 },
-	{ "tx_errors", GEN_STAT(stats.tx_errors), -1 },
-	{ "rx_dropped",	GEN_STAT(stats.rx_dropped), -1 },
-	{ "tx_dropped",	GEN_STAT(stats.tx_dropped), -1 },
+	{ "rx_packets", DEV_STAT(rx_packets), -1 },
+	{ "tx_packets",	DEV_STAT(tx_packets), -1 },
+	{ "rx_bytes", DEV_STAT(rx_bytes), -1 },
+	{ "tx_bytes", DEV_STAT(tx_bytes), -1 },
+	{ "rx_errors", DEV_STAT(rx_errors), -1 },
+	{ "tx_errors", DEV_STAT(tx_errors), -1 },
+	{ "rx_dropped",	DEV_STAT(rx_dropped), -1 },
+	{ "tx_dropped",	DEV_STAT(tx_dropped), -1 },
 
 	{ "rx_good_octets", GEN_STAT(mib.rx_gd_octets), ETH_MIB_RX_GD_OCTETS},
 	{ "rx_good_pkts", GEN_STAT(mib.rx_gd_pkts), ETH_MIB_RX_GD_PKTS },
@@ -1328,7 +1319,11 @@ static void bcm_enet_get_ethtool_stats(struct net_device *netdev,
 		char *p;
 
 		s = &bcm_enet_gstrings_stats[i];
-		p = (char *)priv + s->stat_offset;
+		if (s->mib_reg == -1)
+			p = (char *)&netdev->stats;
+		else
+			p = (char *)priv;
+		p += s->stat_offset;
 		data[i] = (s->sizeof_stat == sizeof(u64)) ?
 			*(u64 *)p : *(u32 *)p;
 	}
@@ -1605,7 +1600,6 @@ static const struct net_device_ops bcm_enet_ops = {
 	.ndo_open		= bcm_enet_open,
 	.ndo_stop		= bcm_enet_stop,
 	.ndo_start_xmit		= bcm_enet_start_xmit,
-	.ndo_get_stats		= bcm_enet_get_stats,
 	.ndo_set_mac_address	= bcm_enet_set_mac_address,
 	.ndo_set_multicast_list = bcm_enet_set_multicast_list,
 	.ndo_do_ioctl		= bcm_enet_ioctl,
diff --git a/drivers/net/bcm63xx_enet.h b/drivers/net/bcm63xx_enet.h
index bd3684d..0e3048b 100644
--- a/drivers/net/bcm63xx_enet.h
+++ b/drivers/net/bcm63xx_enet.h
@@ -274,7 +274,6 @@ struct bcm_enet_priv {
 	int pause_tx;
 
 	/* stats */
-	struct net_device_stats stats;
 	struct bcm_enet_mib_counters mib;
 
 	/* after mib interrupt, mib registers update is done in this


