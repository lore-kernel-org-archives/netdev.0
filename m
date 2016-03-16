From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 12/13] net/mlx5e: Add ethtool counter for RX buffer allocation failures
Date: Wed, 16 Mar 2016 08:41:20 +0200
Message-ID: <1458110481-18080-13-git-send-email-saeedm@mellanox.com>
References: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38320 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934804AbcCPGmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 02:42:17 -0400
In-Reply-To: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Counts the number of RX buffer allocation failures and shows it
in ethtool statistics.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    8 ++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   11 +++++++++--
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 44e062a..532c70c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -189,6 +189,7 @@ static const char vport_strings[][ETH_GSTRING_LEN] = {
 	"rx_wqe_err",
 	"rx_mpwqe_filler",
 	"rx_mpwqe_frag",
+	"rx_buff_alloc_err",
 };
 
 struct mlx5e_vport_stats {
@@ -232,8 +233,9 @@ struct mlx5e_vport_stats {
 	u64 rx_wqe_err;
 	u64 rx_mpwqe_filler;
 	u64 rx_mpwqe_frag;
+	u64 rx_buff_alloc_err;
 
-#define NUM_VPORT_COUNTERS     37
+#define NUM_VPORT_COUNTERS     38
 };
 
 static const char pport_strings[][ETH_GSTRING_LEN] = {
@@ -329,6 +331,7 @@ static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"wqe_err",
 	"mpwqe_filler",
 	"mpwqe_frag",
+	"buff_alloc_err",
 };
 
 struct mlx5e_rq_stats {
@@ -341,7 +344,8 @@ struct mlx5e_rq_stats {
 	u64 wqe_err;
 	u64 mpwqe_filler;
 	u64 mpwqe_frag;
-#define NUM_RQ_STATS 8
+	u64 buff_alloc_err;
+#define NUM_RQ_STATS 9
 };
 
 static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c202c7f..aa312e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -181,6 +181,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	s->rx_wqe_err		= 0;
 	s->rx_mpwqe_filler	= 0;
 	s->rx_mpwqe_frag	= 0;
+	s->rx_buff_alloc_err	= 0;
 	for (i = 0; i < priv->params.num_channels; i++) {
 		rq_stats = &priv->channel[i]->rq.stats;
 
@@ -193,6 +194,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		s->rx_wqe_err   += rq_stats->wqe_err;
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
 		s->rx_mpwqe_frag   += rq_stats->mpwqe_frag;
+		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index de5b8cd..291815c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -327,9 +327,14 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 
 	while (!mlx5_wq_ll_is_full(wq)) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
+		int err;
 
-		if (unlikely(rq->alloc_wqe(rq, wqe, wq->head)))
+		err = rq->alloc_wqe(rq, wqe, wq->head);
+		if (unlikely(err)) {
+			if (err != -EBUSY)
+				rq->stats.buff_alloc_err++;
 			break;
+		}
 
 		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
 	}
@@ -645,8 +650,10 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	skb = napi_alloc_skb(rq->cq.napi,
 			     ALIGN(MLX5_MPWRQ_SMALL_PACKET_THRESHOLD,
 				   sizeof(long)));
-	if (unlikely(!skb))
+	if (unlikely(!skb)) {
+		rq->stats.buff_alloc_err++;
 		goto mpwrq_cqe_out;
+	}
 
 	prefetch(skb->data);
 	cqe_bcnt = mpwrq_get_cqe_byte_cnt(cqe);
-- 
1.7.1
