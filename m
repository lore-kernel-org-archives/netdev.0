From: "Jianming.qiao" <jqiaoulk@gmail.com>
Subject: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Fri,  4 Aug 2017 00:07:45 +0100
Message-ID: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35481 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:08:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so3885169wmd.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:08:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using Broadcom Systemport device in 32bit Platform, ifconfig can
only report up to 4G tx,rx status, which will be wrapped to 0 when the
number of incoming or outgoing packets exceeds 4G, only taking
around 2 hours in busy network environment (such as streaming).
Therefore, it makes hard for network diagnostic tool to get reliable
statistical result, so the patch is used to add 64bit support for
Broadcom Systemport device in 32bit Platform.

This patch provides 64bit statistics capability on both ethtool and ifconfig.

Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 78 +++++++++++++++++++++++-------
 drivers/net/ethernet/broadcom/bcmsysport.h | 21 ++++++++
 2 files changed, 82 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5333601..bf9ca3c 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -201,10 +201,10 @@ static int bcm_sysport_set_features(struct net_device *dev,
  */
 static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 	/* general stats */
-	STAT_NETDEV(rx_packets),
-	STAT_NETDEV(tx_packets),
-	STAT_NETDEV(rx_bytes),
-	STAT_NETDEV(tx_bytes),
+	STAT_NETDEV64(rx_packets),
+	STAT_NETDEV64(tx_packets),
+	STAT_NETDEV64(rx_bytes),
+	STAT_NETDEV64(tx_bytes),
 	STAT_NETDEV(rx_errors),
 	STAT_NETDEV(tx_errors),
 	STAT_NETDEV(rx_dropped),
@@ -316,6 +316,7 @@ static inline bool bcm_sysport_lite_stat_valid(enum bcm_sysport_stat_type type)
 {
 	switch (type) {
 	case BCM_SYSPORT_STAT_NETDEV:
+	case BCM_SYSPORT_STAT_NETDEV64:
 	case BCM_SYSPORT_STAT_RXCHK:
 	case BCM_SYSPORT_STAT_RBUF:
 	case BCM_SYSPORT_STAT_SOFT:
@@ -398,6 +399,7 @@ static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
 		s = &bcm_sysport_gstrings_stats[i];
 		switch (s->type) {
 		case BCM_SYSPORT_STAT_NETDEV:
+		case BCM_SYSPORT_STAT_NETDEV64:
 		case BCM_SYSPORT_STAT_SOFT:
 			continue;
 		case BCM_SYSPORT_STAT_MIB_RX:
@@ -434,7 +436,10 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_stats64 *stats64 = &priv->stats64;
+	struct u64_stats_sync *syncp = &priv->syncp;
 	struct bcm_sysport_tx_ring *ring;
+	unsigned int start;
 	int i, j;
 
 	if (netif_running(dev))
@@ -447,10 +452,20 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 		s = &bcm_sysport_gstrings_stats[i];
 		if (s->type == BCM_SYSPORT_STAT_NETDEV)
 			p = (char *)&dev->stats;
+		else if (s->type == BCM_SYSPORT_STAT_NETDEV64)
+			p = (char *)stats64;
 		else
 			p = (char *)priv;
+
 		p += s->stat_offset;
-		data[j] = *(unsigned long *)p;
+
+		if (s->stat_sizeof == sizeof(u64))
+			do {
+				start = u64_stats_fetch_begin_irq(syncp);
+				data[i] = *(u64 *)p;
+			} while (u64_stats_fetch_retry_irq(syncp, start));
+		else
+			data[i] = *(u32 *)p;
 		j++;
 	}
 
@@ -662,6 +677,7 @@ static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
 static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 					unsigned int budget)
 {
+	struct bcm_sysport_stats64 *stats64 = &priv->stats64;
 	struct net_device *ndev = priv->netdev;
 	unsigned int processed = 0, to_process;
 	struct bcm_sysport_cb *cb;
@@ -765,6 +781,10 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		skb->protocol = eth_type_trans(skb, ndev);
 		ndev->stats.rx_packets++;
 		ndev->stats.rx_bytes += len;
+		u64_stats_update_begin(&priv->syncp);
+		stats64->rx_packets++;
+		stats64->rx_bytes += len;
+		u64_stats_update_end(&priv->syncp);
 
 		napi_gro_receive(&priv->napi, skb);
 next:
@@ -787,17 +807,15 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 	struct device *kdev = &priv->pdev->dev;
 
 	if (cb->skb) {
-		ring->bytes += cb->skb->len;
 		*bytes_compl += cb->skb->len;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
 				 dma_unmap_len(cb, dma_len),
 				 DMA_TO_DEVICE);
-		ring->packets++;
 		(*pkts_compl)++;
 		bcm_sysport_free_cb(cb);
 	/* SKB fragment */
 	} else if (dma_unmap_addr(cb, dma_addr)) {
-		ring->bytes += dma_unmap_len(cb, dma_len);
+		*bytes_compl += dma_unmap_len(cb, dma_len);
 		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
 			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
 		dma_unmap_addr_set(cb, dma_addr, 0);
@@ -808,9 +826,9 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 					     struct bcm_sysport_tx_ring *ring)
 {
-	struct net_device *ndev = priv->netdev;
 	unsigned int c_index, last_c_index, last_tx_cn, num_tx_cbs;
 	unsigned int pkts_compl = 0, bytes_compl = 0;
+	struct net_device *ndev = priv->netdev;
 	struct bcm_sysport_cb *cb;
 	u32 hw_ind;
 
@@ -849,6 +867,11 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 		last_c_index &= (num_tx_cbs - 1);
 	}
 
+	u64_stats_update_begin(&priv->syncp);
+	ring->packets += pkts_compl;
+	ring->bytes += bytes_compl;
+	u64_stats_update_end(&priv->syncp);
+
 	ring->c_index = c_index;
 
 	netif_dbg(priv, tx_done, ndev,
@@ -1671,22 +1694,41 @@ static int bcm_sysport_change_mac(struct net_device *dev, void *p)
 	return 0;
 }
 
-static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
+static void bcm_sysport_get_stats64(struct net_device *dev,
+				    struct rtnl_link_stats64 *stats)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
-	unsigned long tx_bytes = 0, tx_packets = 0;
+	struct bcm_sysport_stats64 *stats64 = &priv->stats64;
 	struct bcm_sysport_tx_ring *ring;
+	u64 tx_packets = 0, tx_bytes = 0;
+	unsigned int start;
 	unsigned int q;
 
+	netdev_stats_to_stats64(stats, &dev->stats);
+
 	for (q = 0; q < dev->num_tx_queues; q++) {
 		ring = &priv->tx_rings[q];
-		tx_bytes += ring->bytes;
-		tx_packets += ring->packets;
+		do {
+			start = u64_stats_fetch_begin_irq(&priv->syncp);
+			tx_bytes = ring->bytes;
+			tx_packets = ring->packets;
+		} while (u64_stats_fetch_retry_irq(&priv->syncp, start));
+
+		stats->tx_bytes += tx_bytes;
+		stats->tx_packets += tx_packets;
 	}
 
-	dev->stats.tx_bytes = tx_bytes;
-	dev->stats.tx_packets = tx_packets;
-	return &dev->stats;
+	/* lockless update tx_bytes and tx_packets */
+	u64_stats_update_begin(&priv->syncp);
+	stats64->tx_bytes = stats->tx_bytes;
+	stats64->tx_packets = stats->tx_packets;
+	u64_stats_update_end(&priv->syncp);
+
+	do {
+		start = u64_stats_fetch_begin_irq(&priv->syncp);
+		stats->rx_packets = stats64->rx_packets;
+		stats->rx_bytes = stats64->rx_bytes;
+	} while (u64_stats_fetch_retry_irq(&priv->syncp, start));
 }
 
 static void bcm_sysport_netif_start(struct net_device *dev)
@@ -1950,7 +1992,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
-	.ndo_get_stats		= bcm_sysport_get_nstats,
+	.ndo_get_stats64	= bcm_sysport_get_stats64,
 };
 
 #define REV_FMT	"v%2x.%02x"
@@ -2098,6 +2140,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	/* libphy will adjust the link state accordingly */
 	netif_carrier_off(dev);
 
+	u64_stats_init(&priv->syncp);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register net_device\n");
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 77a51c1..80b4fff 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -603,6 +603,7 @@ struct bcm_sysport_mib {
 /* HW maintains a large list of counters */
 enum bcm_sysport_stat_type {
 	BCM_SYSPORT_STAT_NETDEV = -1,
+	BCM_SYSPORT_STAT_NETDEV64,
 	BCM_SYSPORT_STAT_MIB_RX,
 	BCM_SYSPORT_STAT_MIB_TX,
 	BCM_SYSPORT_STAT_RUNT,
@@ -619,6 +620,13 @@ enum bcm_sysport_stat_type {
 	.type = BCM_SYSPORT_STAT_NETDEV, \
 }
 
+#define STAT_NETDEV64(m) { \
+	.stat_string = __stringify(m), \
+	.stat_sizeof = sizeof(((struct bcm_sysport_stats64 *)0)->m), \
+	.stat_offset = offsetof(struct bcm_sysport_stats64, m), \
+	.type = BCM_SYSPORT_STAT_NETDEV64, \
+}
+
 #define STAT_MIB(str, m, _type) { \
 	.stat_string = str, \
 	.stat_sizeof = sizeof(((struct bcm_sysport_priv *)0)->m), \
@@ -659,6 +667,14 @@ struct bcm_sysport_stats {
 	u16 reg_offset;
 };
 
+struct bcm_sysport_stats64 {
+	/* 64bit stats on 32bit/64bit Machine */
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+};
+
 /* Software house keeping helper structure */
 struct bcm_sysport_cb {
 	struct sk_buff	*skb;		/* SKB for RX packets */
@@ -743,5 +759,10 @@ struct bcm_sysport_priv {
 
 	/* Ethtool */
 	u32			msg_enable;
+
+	struct bcm_sysport_stats64	stats64;
+
+	/* For atomic update generic 64bit value on 32bit Machine */
+	struct u64_stats_sync	syncp;
 };
 #endif /* __BCM_SYSPORT_H */
-- 
1.9.1
