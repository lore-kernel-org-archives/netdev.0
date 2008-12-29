From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 9/9 V2] mlx4_en: Multiqueue support
Date: Mon, 29 Dec 2008 11:57:09 +0200
Message-ID: <49589EF5.8070800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40754 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752976AbYL2J6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 04:58:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added a function that performs hashing on the TX traffic.
The hashing is only done for TCP or UDP packets, all other packets
are sent to a default queue.
We use an indirection table with an entry for each hash result.
For each entry in the table, we hold statistics regarding the stream
that corresponds to that entry. Packets are then directed to a TX queue
according to stream's pattern.
A ring is opened for each queue.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   16 +++++++++-
 drivers/net/mlx4/en_params.c |    9 +----
 drivers/net/mlx4/en_tx.c     |   64 ++++++++++++++++++++++++++++++++---------
 drivers/net/mlx4/mlx4_en.h   |   17 ++++++++++-
 4 files changed, 81 insertions(+), 25 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 15bb38d..0c242ac 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -645,6 +645,16 @@ int mlx4_en_start_port(struct net_device *dev)
 		++tx_index;
 	}

+	for (i = 0; i < MLX4_EN_TX_HASH_SIZE; i++) {
+		memset(&priv->tx_hash[i], 0, sizeof(struct mlx4_en_tx_hash_entry));
+		/*
+		 * Initially, all streams are assigned to the rings
+		 * that should handle the small packages streams, (the lower ring
+		 * indixes) then moved according the stream charasteristics.
+		 */
+		priv->tx_hash[i].ring = i & (MLX4_EN_NUM_HASH_RINGS / 2 - 1);
+	}
+
 	/* Configure port */
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
@@ -949,6 +959,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
+	.ndo_select_queue	= mlx4_en_select_queue,
 	.ndo_get_stats		= mlx4_en_get_stats,
 	.ndo_set_multicast_list	= mlx4_en_set_multicast,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
@@ -970,7 +981,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	int i;
 	int err;

-	dev = alloc_etherdev(sizeof(struct mlx4_en_priv));
+	dev = alloc_etherdev_mq(sizeof(struct mlx4_en_priv), prof->tx_ring_num);
 	if (dev == NULL) {
 		mlx4_err(mdev, "Net device allocation failed\n");
 		return -ENOMEM;
@@ -1033,7 +1044,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->allocated = 1;

 	/* Populate Tx priority mappings */
-	mlx4_en_set_prio_map(priv, priv->tx_prio_map, prof->tx_ring_num);
+	mlx4_en_set_prio_map(priv, priv->tx_prio_map,
+			     prof->tx_ring_num - MLX4_EN_NUM_HASH_RINGS);

 	/*
 	 * Initialize netdev entry points
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index cfeef0f..e50e882 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -80,13 +80,8 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
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
+		params->prof[i].tx_ring_num = MLX4_EN_NUM_HASH_RINGS + 1 +
+			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
 	}

 	return 0;
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index ff4d752..2b8cc17 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -297,7 +297,7 @@ void mlx4_en_set_prio_map(struct mlx4_en_priv *priv, u16 *prio_map, u32 ring_num
 	int block = 8 / ring_num;
 	int extra = 8 - (block * ring_num);
 	int num = 0;
-	u16 ring = 1;
+	u16 ring = MLX4_EN_NUM_HASH_RINGS + 1;
 	int prio;

 	if (ring_num == 1) {
@@ -392,7 +392,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 			 *   transmission on that ring would stop the queue.
 			 */
 			ring->blocked = 0;
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(netdev_get_tx_queue(dev, cq->ring));
 			priv->port_stats.wake_queue++;
 		}
 	}
@@ -612,21 +612,55 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }

-static int get_vlan_info(struct mlx4_en_priv *priv, struct sk_buff *skb,
-			 u16 *vlan_tag)
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	int tx_ind;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	u16 vlan_tag = 0;
+	u16 tx_ind = 0;
+	struct tcphdr *th = tcp_hdr(skb);
+	struct iphdr *iph = ip_hdr(skb);
+	struct mlx4_en_tx_hash_entry *entry;
+	u32 hash_index;

 	/* Obtain VLAN information if present */
 	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
-		*vlan_tag = vlan_tx_tag_get(skb);
+		vlan_tag = vlan_tx_tag_get(skb);
 		/* Set the Tx ring to use according to vlan priority */
-		tx_ind = priv->tx_prio_map[*vlan_tag >> 13];
-	} else {
-		*vlan_tag = 0;
-		tx_ind = 0;
+		tx_ind = priv->tx_prio_map[vlan_tag >> 13];
+		if (tx_ind)
+			return tx_ind;
+	}
+
+	/* Hashing is only done for TCP/IP or UDP/IP packets */
+	if (be16_to_cpu(skb->protocol) != ETH_P_IP)
+		return MLX4_EN_NUM_HASH_RINGS;
+
+	hash_index = be32_to_cpu(iph->daddr) & MLX4_EN_TX_HASH_MASK;
+	switch (iph->protocol) {
+	case 17:
+		break;
+	case 6:
+		hash_index = (hash_index ^ be16_to_cpu(th->dest ^ th->source)) &
+				MLX4_EN_TX_HASH_MASK;
+		break;
+	default:
+		return MLX4_EN_NUM_HASH_RINGS;
+	}
+
+	entry = &priv->tx_hash[hash_index];
+	if (skb->len > MLX4_EN_SMALL_PKT_SIZE)
+		entry->big_pkts++;
+	else
+		entry->small_pkts++;
+
+	if (unlikely(!(++entry->cnt))) {
+		tx_ind = hash_index & (MLX4_EN_NUM_HASH_RINGS / 2 - 1);
+		if (2 * entry->big_pkts > entry->small_pkts)
+			tx_ind += MLX4_EN_NUM_HASH_RINGS / 2;
+		entry->small_pkts = entry->big_pkts = 0;
+		entry->ring = tx_ind;
 	}
-	return tx_ind;
+	return entry->ring;
 }

 int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -646,7 +680,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_addr_t dma;
 	u32 index;
 	__be32 op_own;
-	u16 vlan_tag;
+	u16 vlan_tag = 0;
 	int i;
 	int lso_header_size;
 	void *fragptr;
@@ -669,15 +703,17 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
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
 		/* every full Tx ring stops queue.
 		 * TODO: implement multi-queue support (per-queue stop) */
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, tx_ind));
 		ring->blocked = 1;
 		priv->port_stats.queue_stopped++;

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 2e96c7b..45e0ab3 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -119,8 +119,12 @@ enum {
 #define MLX4_EN_MIN_RX_SIZE	(MLX4_EN_ALLOC_SIZE / SMP_CACHE_BYTES)
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)

-#define MLX4_EN_TX_RING_NUM		9
-#define MLX4_EN_DEF_TX_RING_SIZE	1024
+#define MLX4_EN_SMALL_PKT_SIZE		128
+#define MLX4_EN_TX_HASH_SIZE		256
+#define MLX4_EN_TX_HASH_MASK		(MLX4_EN_TX_HASH_SIZE - 1)
+#define MLX4_EN_NUM_HASH_RINGS		8
+#define MLX4_EN_NUM_PPP_RINGS		8
+#define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024

 /* Target number of bytes to coalesce with interrupt moderation */
@@ -416,6 +420,13 @@ struct mlx4_en_frag_info {

 };

+struct mlx4_en_tx_hash_entry {
+	u8 cnt;
+	unsigned int small_pkts;
+	unsigned int big_pkts;
+	u16 ring;
+};
+
 struct mlx4_en_priv {
 	struct mlx4_en_dev *mdev;
 	struct mlx4_en_port_profile *prof;
@@ -471,6 +482,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
 	struct mlx4_en_cq tx_cq[MAX_TX_RINGS];
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
+	struct mlx4_en_tx_hash_entry tx_hash[MLX4_EN_TX_HASH_SIZE];
 	struct work_struct mcast_task;
 	struct work_struct mac_task;
 	struct delayed_work refill_task;
@@ -508,6 +520,7 @@ int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 void mlx4_en_poll_tx_cq(unsigned long data);
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);

 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring,
 			   u32 size, u16 stride);
-- 
1.5.4

