From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 31/42] dvb: update network device to current API
Date: Tue, 06 Jan 2009 16:33:47 -0800
Message-ID: <20090107003348.828888483@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, v4l-dvb-maintainer@linuxtv.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60734 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755738AbZAGAzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:55:37 -0500
Content-Disposition: inline; filename=dvb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use internal network_device_stats that exist in network device and
net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/media/dvb/dvb-core/dvb_net.c	2009-01-03 21:41:52.667265286 -0800
+++ b/drivers/media/dvb/dvb-core/dvb_net.c	2009-01-03 21:46:40.886764565 -0800
@@ -125,7 +125,6 @@ static void hexdump( const unsigned char
 
 struct dvb_net_priv {
 	int in_use;
-	struct net_device_stats stats;
 	u16 pid;
 	struct net_device *net;
 	struct dvb_net *host;
@@ -384,8 +383,8 @@ static void dvb_net_ule( struct net_devi
 				if (priv->ule_skb) {
 					dev_kfree_skb( priv->ule_skb );
 					/* Prepare for next SNDU. */
-					priv->stats.rx_errors++;
-					priv->stats.rx_frame_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_frame_errors++;
 				}
 				reset_ule(priv);
 				priv->need_pusi = 1;
@@ -438,8 +437,8 @@ static void dvb_net_ule( struct net_devi
 					dev_kfree_skb( priv->ule_skb );
 					/* Prepare for next SNDU. */
 					// reset_ule(priv);  moved to below.
-					priv->stats.rx_errors++;
-					priv->stats.rx_frame_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_frame_errors++;
 				}
 				reset_ule(priv);
 				/* skip to next PUSI. */
@@ -460,8 +459,8 @@ static void dvb_net_ule( struct net_devi
 						/* Drop partly decoded SNDU, reset state, resync on PUSI. */
 						if (priv->ule_skb) {
 							dev_kfree_skb( priv->ule_skb );
-							priv->stats.rx_errors++;
-							priv->stats.rx_frame_errors++;
+							dev->stats.rx_errors++;
+							dev->stats.rx_frame_errors++;
 						}
 						reset_ule(priv);
 						priv->need_pusi = 1;
@@ -477,8 +476,8 @@ static void dvb_net_ule( struct net_devi
 				if (priv->ule_sndu_remain > 183) {
 					/* Current SNDU lacks more data than there could be available in the
 					 * current TS cell. */
-					priv->stats.rx_errors++;
-					priv->stats.rx_length_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_length_errors++;
 					printk(KERN_WARNING "%lu: Expected %d more SNDU bytes, but "
 					       "got PUSI (pf %d, ts_remain %d).  Flushing incomplete payload.\n",
 					       priv->ts_count, priv->ule_sndu_remain, ts[4], ts_remain);
@@ -520,8 +519,8 @@ static void dvb_net_ule( struct net_devi
 				if (priv->ule_sndu_len < 5) {
 					printk(KERN_WARNING "%lu: Invalid ULE SNDU length %u. "
 					       "Resyncing.\n", priv->ts_count, priv->ule_sndu_len);
-					priv->stats.rx_errors++;
-					priv->stats.rx_length_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_length_errors++;
 					priv->ule_sndu_len = 0;
 					priv->need_pusi = 1;
 					new_ts = 1;
@@ -573,7 +572,7 @@ static void dvb_net_ule( struct net_devi
 			if (priv->ule_skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
-				priv->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				return;
 			}
 
@@ -637,8 +636,8 @@ static void dvb_net_ule( struct net_devi
 				ule_dump = 1;
 #endif
 
-				priv->stats.rx_errors++;
-				priv->stats.rx_crc_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_crc_errors++;
 				dev_kfree_skb(priv->ule_skb);
 			} else {
 				/* CRC32 verified OK. */
@@ -744,8 +743,8 @@ static void dvb_net_ule( struct net_devi
 				 * receive the packet anyhow. */
 				/* if (priv->ule_dbit && skb->pkt_type == PACKET_OTHERHOST)
 					priv->ule_skb->pkt_type = PACKET_HOST; */
-				priv->stats.rx_packets++;
-				priv->stats.rx_bytes += priv->ule_skb->len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += priv->ule_skb->len;
 				netif_rx(priv->ule_skb);
 			}
 			sndu_done:
@@ -800,8 +799,7 @@ static void dvb_net_sec(struct net_devic
 {
 	u8 *eth;
 	struct sk_buff *skb;
-	struct net_device_stats *stats =
-		&((struct dvb_net_priv *) netdev_priv(dev))->stats;
+	struct net_device_stats *stats = &dev->stats;
 	int snap = 0;
 
 	/* note: pkt_len includes a 32bit checksum */
@@ -1216,28 +1214,29 @@ static int dvb_net_stop(struct net_devic
 	return dvb_net_feed_stop(dev);
 }
 
-static struct net_device_stats * dvb_net_get_stats(struct net_device *dev)
-{
-	return &((struct dvb_net_priv *) netdev_priv(dev))->stats;
-}
-
 static const struct header_ops dvb_header_ops = {
 	.create		= eth_header,
 	.parse		= eth_header_parse,
 	.rebuild	= eth_rebuild_header,
 };
 
+
+static const struct net_device_ops dvb_netdev_ops = {
+	.ndo_open		= dvb_net_open,
+	.ndo_stop		= dvb_net_stop,
+	.ndo_start_xmit		= dvb_net_tx,
+	.ndo_set_multicast_list = dvb_net_set_multicast_list,
+	.ndo_set_mac_address    = dvb_net_set_mac,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static void dvb_net_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
 	dev->header_ops		= &dvb_header_ops;
-	dev->open		= dvb_net_open;
-	dev->stop		= dvb_net_stop;
-	dev->hard_start_xmit	= dvb_net_tx;
-	dev->get_stats		= dvb_net_get_stats;
-	dev->set_multicast_list = dvb_net_set_multicast_list;
-	dev->set_mac_address    = dvb_net_set_mac;
+	dev->netdev_ops		= &dvb_netdev_ops;
 	dev->mtu		= 4096;
 	dev->mc_count           = 0;
 

-- 

