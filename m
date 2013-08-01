From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 06/13] tile: update dev->stats directly in tilegx network driver
Date: Thu, 1 Aug 2013 11:36:42 -0400
Message-ID: <a63f134c0e2ea083f8dba93294012cf588fecf78.1375385120.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
	<cover.1375385119.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:21418 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab3HATff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 15:35:35 -0400
In-Reply-To: <cover.1375385119.git.cmetcalf@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 39c1e9e..e9eba2b 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -178,8 +178,6 @@ struct tile_net_priv {
 	int loopify_channel;
 	/* The egress channel (channel or loopify_channel). */
 	int echannel;
-	/* Total stats. */
-	struct net_device_stats stats;
 };
 
 /* Egress info, indexed by "priv->echannel" (lazily created as needed). */
@@ -414,7 +412,6 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 				 gxio_mpipe_idesc_t *idesc, unsigned long len)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	struct tile_net_priv *priv = netdev_priv(dev);
 
 	/* Encode the actual packet length. */
 	skb_put(skb, len);
@@ -428,8 +425,8 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	netif_receive_skb(skb);
 
 	/* Update stats. */
-	tile_net_stats_add(1, &priv->stats.rx_packets);
-	tile_net_stats_add(len, &priv->stats.rx_bytes);
+	tile_net_stats_add(1, &dev->stats.rx_packets);
+	tile_net_stats_add(len, &dev->stats.rx_bytes);
 
 	/* Need a new buffer. */
 	if (idesc->size == buffer_size_enums[0])
@@ -445,7 +442,6 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	struct net_device *dev = tile_net_devs_for_channel[idesc->channel];
-	struct tile_net_priv *priv = netdev_priv(dev);
 	uint8_t l2_offset;
 	void *va;
 	void *buf;
@@ -459,7 +455,7 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 	 */
 	if (idesc->be || idesc->me || idesc->tr || idesc->ce) {
 		if (dev)
-			tile_net_stats_add(1, &priv->stats.rx_errors);
+			tile_net_stats_add(1, &dev->stats.rx_errors);
 		goto drop;
 	}
 
@@ -479,7 +475,7 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 	filter = filter_packet(dev, buf);
 	if (filter) {
 		if (dev)
-			tile_net_stats_add(1, &priv->stats.rx_dropped);
+			tile_net_stats_add(1, &dev->stats.rx_dropped);
 drop:
 		gxio_mpipe_iqueue_drop(&info->iqueue, idesc);
 	} else {
@@ -1502,7 +1498,6 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 		       struct sk_buff *skb, unsigned char *headers, s64 slot)
 {
-	struct tile_net_priv *priv = netdev_priv(dev);
 	struct skb_shared_info *sh = skb_shinfo(skb);
 	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	unsigned int data_len = skb->len - sh_len;
@@ -1580,8 +1575,8 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 	}
 
 	/* Update stats. */
-	tile_net_stats_add(tx_packets, &priv->stats.tx_packets);
-	tile_net_stats_add(tx_bytes, &priv->stats.tx_bytes);
+	tile_net_stats_add(tx_packets, &dev->stats.tx_packets);
+	tile_net_stats_add(tx_bytes, &dev->stats.tx_bytes);
 }
 
 /* Do "TSO" handling for egress.
@@ -1724,9 +1719,9 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	add_comp(equeue, comps, slot - 1, skb);
 
 	/* NOTE: Use ETH_ZLEN for short packets (e.g. 42 < 60). */
-	tile_net_stats_add(1, &priv->stats.tx_packets);
+	tile_net_stats_add(1, &dev->stats.tx_packets);
 	tile_net_stats_add(max_t(unsigned int, len, ETH_ZLEN),
-			   &priv->stats.tx_bytes);
+			   &dev->stats.tx_bytes);
 
 	local_irq_restore(irqflags);
 
@@ -1757,13 +1752,6 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return -EOPNOTSUPP;
 }
 
-/* Get system network statistics for device. */
-static struct net_device_stats *tile_net_get_stats(struct net_device *dev)
-{
-	struct tile_net_priv *priv = netdev_priv(dev);
-	return &priv->stats;
-}
-
 /* Change the MTU. */
 static int tile_net_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1813,7 +1801,6 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_start_xmit = tile_net_tx,
 	.ndo_select_queue = tile_net_select_queue,
 	.ndo_do_ioctl = tile_net_ioctl,
-	.ndo_get_stats = tile_net_get_stats,
 	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
 	.ndo_set_mac_address = tile_net_set_mac_address,
-- 
1.8.3.1
