From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5e: Support RX CHECKSUM_COMPLETE
Date: Sun, 16 Aug 2015 16:04:52 +0300
Message-ID: <1439730292-29617-9-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38403 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751237AbbHPNHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:05 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only for packets with first ethertype set to IPv4/6 for now.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  8 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  5 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 42 ++++++++++++++++++-----
 3 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 298f0bf..27ca459 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -94,6 +94,7 @@ static const char vport_strings[][ETH_GSTRING_LEN] = {
 	"lro_bytes",
 	"rx_csum_good",
 	"rx_csum_none",
+	"rx_csum_sw",
 	"tx_csum_offload",
 	"tx_queue_stopped",
 	"tx_queue_wake",
@@ -131,13 +132,14 @@ struct mlx5e_vport_stats {
 	u64 lro_bytes;
 	u64 rx_csum_good;
 	u64 rx_csum_none;
+	u64 rx_csum_sw;
 	u64 tx_csum_offload;
 	u64 tx_queue_stopped;
 	u64 tx_queue_wake;
 	u64 tx_queue_dropped;
 	u64 rx_wqe_err;
 
-#define NUM_VPORT_COUNTERS     31
+#define NUM_VPORT_COUNTERS     32
 };
 
 static const char pport_strings[][ETH_GSTRING_LEN] = {
@@ -217,6 +219,7 @@ struct mlx5e_pport_stats {
 static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
 	"csum_none",
+	"csum_sw",
 	"lro_packets",
 	"lro_bytes",
 	"wqe_err"
@@ -225,10 +228,11 @@ static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 csum_none;
+	u64 csum_sw;
 	u64 lro_packets;
 	u64 lro_bytes;
 	u64 wqe_err;
-#define NUM_RQ_STATS 5
+#define NUM_RQ_STATS 6
 };
 
 static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f50a11977..55166dd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -149,6 +149,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	s->lro_packets		= 0;
 	s->lro_bytes		= 0;
 	s->rx_csum_none		= 0;
+	s->rx_csum_sw		= 0;
 	s->rx_wqe_err		= 0;
 	for (i = 0; i < priv->params.num_channels; i++) {
 		rq_stats = &priv->channel[i]->rq.stats;
@@ -156,6 +157,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		s->lro_packets	+= rq_stats->lro_packets;
 		s->lro_bytes	+= rq_stats->lro_bytes;
 		s->rx_csum_none	+= rq_stats->csum_none;
+		s->rx_csum_sw	+= rq_stats->csum_sw;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
@@ -241,7 +243,8 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 
 	/* Update calculated offload counters */
 	s->tx_csum_offload = s->tx_packets - tx_offload_none;
-	s->rx_csum_good    = s->rx_packets - s->rx_csum_none;
+	s->rx_csum_good    = s->rx_packets - s->rx_csum_none -
+			       s->rx_csum_sw;
 
 	mlx5e_update_pport_counters(priv);
 free_out:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 9bb88f6..caea062 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -151,6 +151,38 @@ static inline void mlx5e_skb_set_hash(struct mlx5_cqe64 *cqe,
 	skb_set_hash(skb, be32_to_cpu(cqe->rss_hash_result), ht);
 }
 
+static inline bool is_first_ethertype_ip(struct sk_buff *skb)
+{
+	__be16 ethertype = ((struct ethhdr *)skb->data)->h_proto;
+
+	return (ethertype == htons(ETH_P_IP) || ethertype == htons(ETH_P_IPV6));
+}
+
+static inline void mlx5e_handle_csum(struct net_device *netdev,
+				     struct mlx5_cqe64 *cqe,
+				     struct mlx5e_rq *rq,
+				     struct sk_buff *skb)
+{
+	if (unlikely(!(netdev->features & NETIF_F_RXCSUM)))
+		goto csum_none;
+
+	if (likely(cqe->hds_ip_ext & CQE_L4_OK)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else if (is_first_ethertype_ip(skb)) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum = csum_unfold(cqe->check_sum);
+		rq->stats.csum_sw++;
+	} else {
+		goto csum_none;
+	}
+
+	return;
+
+csum_none:
+	skb->ip_summed = CHECKSUM_NONE;
+	rq->stats.csum_none++;
+}
+
 static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				      struct mlx5e_rq *rq,
 				      struct sk_buff *skb)
@@ -169,15 +201,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 		rq->stats.lro_bytes += cqe_bcnt;
 	}
 
-	if (likely(netdev->features & NETIF_F_RXCSUM) &&
-	    (cqe->hds_ip_ext & CQE_L2_OK) &&
-	    (cqe->hds_ip_ext & CQE_L3_OK) &&
-	    (cqe->hds_ip_ext & CQE_L4_OK)) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else {
-		skb->ip_summed = CHECKSUM_NONE;
-		rq->stats.csum_none++;
-	}
+	mlx5e_handle_csum(netdev, cqe, rq, skb);
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-- 
1.8.3.1
