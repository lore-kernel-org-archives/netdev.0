From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/7] net/mlx5e: Add rx/tx bytes software counters
Date: Wed, 24 Feb 2016 13:18:52 +0200
Message-ID: <1456312733-22091-7-git-send-email-saeedm@mellanox.com>
References: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44439 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754348AbcBXLUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 06:20:13 -0500
In-Reply-To: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Sum up rx/tx bytes in software as we do for rx/tx packets, to be reported
in upcoming statistics fix.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |    8 ++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c |    9 ++++++---
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d0a57d5..5b17532 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -223,6 +223,7 @@ struct mlx5e_pport_stats {
 
 static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
+	"bytes",
 	"csum_none",
 	"csum_sw",
 	"lro_packets",
@@ -232,16 +233,18 @@ static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 
 struct mlx5e_rq_stats {
 	u64 packets;
+	u64 bytes;
 	u64 csum_none;
 	u64 csum_sw;
 	u64 lro_packets;
 	u64 lro_bytes;
 	u64 wqe_err;
-#define NUM_RQ_STATS 6
+#define NUM_RQ_STATS 7
 };
 
 static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
+	"bytes",
 	"tso_packets",
 	"tso_bytes",
 	"csum_offload_none",
@@ -253,6 +256,7 @@ static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
 
 struct mlx5e_sq_stats {
 	u64 packets;
+	u64 bytes;
 	u64 tso_packets;
 	u64 tso_bytes;
 	u64 csum_offload_none;
@@ -260,7 +264,7 @@ struct mlx5e_sq_stats {
 	u64 wake;
 	u64 dropped;
 	u64 nop;
-#define NUM_SQ_STATS 8
+#define NUM_SQ_STATS 9
 };
 
 struct mlx5e_stats {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 3fd6a58..59658b9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -263,6 +263,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 
 		mlx5e_build_rx_skb(cqe, rq, skb);
 		rq->stats.packets++;
+		rq->stats.bytes += be32_to_cpu(cqe->byte_cnt);
 		napi_gro_receive(cq->napi, skb);
 
 wq_ll_pop:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 2beea8c..bb4eeeb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -179,6 +179,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	unsigned int skb_len = skb->len;
 	u8  opcode = MLX5_OPCODE_SEND;
 	dma_addr_t dma_addr = 0;
+	unsigned int num_bytes;
 	bool bf = false;
 	u16 headlen;
 	u16 ds_cnt;
@@ -204,8 +205,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		opcode       = MLX5_OPCODE_LSO;
 		ihs          = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		payload_len  = skb->len - ihs;
-		wi->num_bytes = skb->len +
-				(skb_shinfo(skb)->gso_segs - 1) * ihs;
+		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
 		sq->stats.tso_packets++;
 		sq->stats.tso_bytes += payload_len;
 	} else {
@@ -213,9 +213,11 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		     !skb->xmit_more &&
 		     !skb_shinfo(skb)->nr_frags;
 		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
-		wi->num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 	}
 
+	wi->num_bytes = num_bytes;
+
 	if (skb_vlan_tag_present(skb)) {
 		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs, &skb_data,
 				  &skb_len);
@@ -307,6 +309,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	sq->bf_budget = bf ? sq->bf_budget - 1 : 0;
 
 	sq->stats.packets++;
+	sq->stats.bytes += num_bytes;
 	return NETDEV_TX_OK;
 
 dma_unmap_wqe_err:
-- 
1.7.1
