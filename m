From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 07/13] tile: update dev->stats directly in tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <07b5385c3cb11e0d9550a6afa0a2a8ba57d6ad2e.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 8d1f748..a245858 100644
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
@@ -447,7 +445,6 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 				 gxio_mpipe_idesc_t *idesc, unsigned long len)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	struct tile_net_priv *priv = netdev_priv(dev);
 
 	/* Encode the actual packet length. */
 	skb_put(skb, len);
@@ -464,8 +461,8 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	netif_receive_skb(skb);
 
 	/* Update stats. */
-	tile_net_stats_add(1, &priv->stats.rx_packets);
-	tile_net_stats_add(len, &priv->stats.rx_bytes);
+	tile_net_stats_add(1, &dev->stats.rx_packets);
+	tile_net_stats_add(len, &dev->stats.rx_bytes);
 
 	/* Need a new buffer. */
 	if (idesc->size == buffer_size_enums[0])
@@ -481,7 +478,6 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	struct net_device *dev = tile_net_devs_for_channel[idesc->channel];
-	struct tile_net_priv *priv = netdev_priv(dev);
 	uint8_t l2_offset;
 	void *va;
 	void *buf;
@@ -495,7 +491,7 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 	 */
 	if (idesc->be || idesc->me || idesc->tr || idesc->ce) {
 		if (dev)
-			tile_net_stats_add(1, &priv->stats.rx_errors);
+			tile_net_stats_add(1, &dev->stats.rx_errors);
 		goto drop;
 	}
 
@@ -515,7 +511,7 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 	filter = filter_packet(dev, buf);
 	if (filter) {
 		if (dev)
-			tile_net_stats_add(1, &priv->stats.rx_dropped);
+			tile_net_stats_add(1, &dev->stats.rx_dropped);
 	drop:
 		gxio_mpipe_iqueue_drop(&info->mpipe[instance].iqueue, idesc);
 	} else {
@@ -1549,7 +1545,6 @@ static void tso_headers_prepare(struct sk_buff *skb, unsigned char *headers,
 static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 		       struct sk_buff *skb, unsigned char *headers, s64 slot)
 {
-	struct tile_net_priv *priv = netdev_priv(dev);
 	struct skb_shared_info *sh = skb_shinfo(skb);
 	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	unsigned int data_len = skb->len - sh_len;
@@ -1627,8 +1622,8 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 	}
 
 	/* Update stats. */
-	tile_net_stats_add(tx_packets, &priv->stats.tx_packets);
-	tile_net_stats_add(tx_bytes, &priv->stats.tx_bytes);
+	tile_net_stats_add(tx_packets, &dev->stats.tx_packets);
+	tile_net_stats_add(tx_bytes, &dev->stats.tx_bytes);
 }
 
 /* Do "TSO" handling for egress.
@@ -1774,9 +1769,9 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	add_comp(equeue, comps, slot - 1, skb);
 
 	/* NOTE: Use ETH_ZLEN for short packets (e.g. 42 < 60). */
-	tile_net_stats_add(1, &priv->stats.tx_packets);
+	tile_net_stats_add(1, &dev->stats.tx_packets);
 	tile_net_stats_add(max_t(unsigned int, len, ETH_ZLEN),
-			   &priv->stats.tx_bytes);
+			   &dev->stats.tx_bytes);
 
 	local_irq_restore(irqflags);
 
@@ -1813,13 +1808,6 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -1869,7 +1857,6 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_start_xmit = tile_net_tx,
 	.ndo_select_queue = tile_net_select_queue,
 	.ndo_do_ioctl = tile_net_ioctl,
-	.ndo_get_stats = tile_net_get_stats,
 	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
 	.ndo_set_mac_address = tile_net_set_mac_address,
-- 
1.8.3.1
