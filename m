From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 6/8] mlx4_en: multiqueue support
Date: Tue, 02 Jun 2009 12:24:07 +0300
Message-ID: <4A24EFB7.7030207@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40120 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758854AbZFBIdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:33:25 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default the driver opens 8 TX queues (defined by MLX4_EN_NUM_TX_RINGS).
If the driver is configured to support Per Priority Flow Control, we open
8 additional TX rings.
dev->real_num_tx_queues is always set to be MLX4_EN_NUM_TX_RINGS.
The mlx4_en_select_queue() function uses standard hashing (skb_tx_hash)
in case that PPFC is not supported or the skb contain a vlan tag,
otherwise the queue is selected according to vlan priority.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |    9 +----
 drivers/net/mlx4/en_netdev.c |    7 ++--
 drivers/net/mlx4/en_tx.c     |   74 ++++++++++-------------------------------
 drivers/net/mlx4/mlx4_en.h   |    9 +++--
 4 files changed, 28 insertions(+), 71 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index b510000..9ed4a15 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -93,13 +93,8 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-	}
-	if (pfcrx || pfctx) {
-		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
-		params->prof[2].tx_ring_num = MLX4_EN_TX_RING_NUM;
-	} else {
-		params->prof[1].tx_ring_num = 1;
-		params->prof[2].tx_ring_num = 1;
+		params->prof[i].tx_ring_num = MLX4_EN_NUM_TX_RINGS +
+			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
 	}
 
 	return 0;
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 16a634f..37e4d30 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -934,6 +934,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
+	.ndo_select_queue	= mlx4_en_select_queue,
 	.ndo_get_stats		= mlx4_en_get_stats,
 	.ndo_set_multicast_list	= mlx4_en_set_multicast,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
@@ -956,7 +957,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	int i;
 	int err;
 
-	dev = alloc_etherdev(sizeof(struct mlx4_en_priv));
+	dev = alloc_etherdev_mq(sizeof(struct mlx4_en_priv), prof->tx_ring_num);
 	if (dev == NULL) {
 		mlx4_err(mdev, "Net device allocation failed\n");
 		return -ENOMEM;
@@ -1018,14 +1019,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	priv->allocated = 1;
 
-	/* Populate Tx priority mappings */
-	mlx4_en_set_prio_map(priv, priv->tx_prio_map, prof->tx_ring_num);
-
 	/*
 	 * Initialize netdev entry points
 	 */
 	dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
+	dev->real_num_tx_queues = MLX4_EN_NUM_TX_RINGS;
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index e32e869..5dc7466 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -297,34 +297,6 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
-void mlx4_en_set_prio_map(struct mlx4_en_priv *priv, u16 *prio_map, u32 ring_num)
-{
-	int block = 8 / ring_num;
-	int extra = 8 - (block * ring_num);
-	int num = 0;
-	u16 ring = 1;
-	int prio;
-
-	if (ring_num == 1) {
-		for (prio = 0; prio < 8; prio++)
-			prio_map[prio] = 0;
-		return;
-	}
-
-	for (prio = 0; prio < 8; prio++) {
-		if (extra && (num == block + 1)) {
-			ring++;
-			num = 0;
-			extra--;
-		} else if (!extra && (num == block)) {
-			ring++;
-			num = 0;
-		}
-		prio_map[prio] = ring;
-		en_dbg(DRV, priv, " prio:%d --> ring:%d\n", prio, ring);
-		num++;
-	}
-}
 
 static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 {
@@ -386,18 +358,8 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	if (unlikely(ring->blocked)) {
 		if ((u32) (ring->prod - ring->cons) <=
 		     ring->size - HEADROOM - MAX_DESC_TXBBS) {
-
-			/* TODO: support multiqueue netdevs. Currently, we block
-			 * when *any* ring is full. Note that:
-			 * - 2 Tx rings can unblock at the same time and call
-			 *   netif_wake_queue(), which is OK since this
-			 *   operation is idempotent.
-			 * - We might wake the queue just after another ring
-			 *   stopped it. This is no big deal because the next
-			 *   transmission on that ring would stop the queue.
-			 */
 			ring->blocked = 0;
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(netdev_get_tx_queue(dev, cq->ring));
 			priv->port_stats.wake_queue++;
 		}
 	}
@@ -616,21 +578,20 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }
 
-static int get_vlan_info(struct mlx4_en_priv *priv, struct sk_buff *skb,
-			 u16 *vlan_tag)
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	int tx_ind;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	u16 vlan_tag = 0;
 
-	/* Obtain VLAN information if present */
-	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
-		*vlan_tag = vlan_tx_tag_get(skb);
-		/* Set the Tx ring to use according to vlan priority */
-		tx_ind = priv->tx_prio_map[*vlan_tag >> 13];
-	} else {
-		*vlan_tag = 0;
-		tx_ind = 0;
+	/* If we support per priority flow control and the packet contains
+	 * a vlan tag, send the packet to the TX ring assigned to that priority
+	 */
+	if (priv->prof->rx_ppp && priv->vlgrp && vlan_tx_tag_present(skb)) {
+		vlan_tag = vlan_tx_tag_get(skb);
+		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
 	}
-	return tx_ind;
+
+	return skb_tx_hash(dev, skb);
 }
 
 int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -650,7 +611,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_addr_t dma;
 	u32 index;
 	__be32 op_own;
-	u16 vlan_tag;
+	u16 vlan_tag = 0;
 	int i;
 	int lso_header_size;
 	void *fragptr;
@@ -673,15 +634,16 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	tx_ind = get_vlan_info(priv, skb, &vlan_tag);
+	tx_ind = skb->queue_mapping;
 	ring = &priv->tx_ring[tx_ind];
+	if (priv->vlgrp && vlan_tx_tag_present(skb))
+		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
 	if (unlikely(((int)(ring->prod - ring->cons)) >
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
-		/* every full Tx ring stops queue.
-		 * TODO: implement multi-queue support (per-queue stop) */
-		netif_stop_queue(dev);
+		/* every full Tx ring stops queue */
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, tx_ind));
 		ring->blocked = 1;
 		priv->port_stats.queue_stopped++;
 
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index fcbfcfc..4de8db0 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -139,8 +139,10 @@ enum {
 #define MLX4_EN_MIN_RX_SIZE	(MLX4_EN_ALLOC_SIZE / SMP_CACHE_BYTES)
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
-#define MLX4_EN_TX_RING_NUM		9
-#define MLX4_EN_DEF_TX_RING_SIZE	1024
+#define MLX4_EN_SMALL_PKT_SIZE		64
+#define MLX4_EN_NUM_TX_RINGS		8
+#define MLX4_EN_NUM_PPP_RINGS		8
+#define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 
 /* Target number of packets to coalesce with interrupt moderation */
@@ -478,7 +480,6 @@ struct mlx4_en_priv {
 	int base_qpn;
 
 	struct mlx4_en_rss_map rss_map;
-	u16 tx_prio_map[8];
 	u32 flags;
 #define MLX4_EN_FLAG_PROMISC	0x1
 	u32 tx_ring_num;
@@ -526,6 +527,7 @@ int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 
 void mlx4_en_poll_tx_cq(unsigned long data);
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
 int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring,
@@ -560,7 +562,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev);
 void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
 				 struct mlx4_en_rss_map *rss_map,
 				 int num_entries, int num_rings);
-void mlx4_en_set_prio_map(struct mlx4_en_priv *priv, u16 *prio_map, u32 ring_num);
 int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv);
 void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
-- 
1.6.0


