From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next V2 4/6] net/mlx5e: Tx, no inline copy on ConnectX-5
Date: Tue,  7 Feb 2017 01:38:27 +0200
Message-ID: <20170206233829.29716-5-saeedm@mellanox.com>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52048 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751395AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ConnectX-5 and later HW generations will report min inline mode ==
MLX5_INLINE_MODE_NONE, which means driver is not required to copy packet
headers to inline fields of TX WQE.

When inline is not required, vlan insertion will be handled in the
TX descriptor rather than copy to inline.

For LSO case driver is still required to copy headers, for the HW to
duplicate on wire.

This will improve CPU utilization and boost TX performance.

Tested with pktgen burst single flow:
CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
HCA: Mellanox Technologies MT28800 Family [ConnectX-5 Ex]

Before: 15.1Mpps
After:  17.2Mpps
Improvement: 14%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 13 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 30 +++++++++++++----------
 2 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1b7fe43ab22b..9cd38401fdc9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1029,9 +1029,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
-	sq->min_inline_mode =
-		MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5_CAP_INLINE_MODE_VPORT_CONTEXT ?
-		param->min_inline_mode : 0;
+	sq->min_inline_mode = param->min_inline_mode;
 
 	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
 	if (err)
@@ -1095,7 +1093,10 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	MLX5_SET(sqc,  sqc, tis_num_0, param->type == MLX5E_SQ_ICO ?
 				       0 : priv->tisn[sq->tc]);
 	MLX5_SET(sqc,  sqc, cqn,		sq->cq.mcq.cqn);
-	MLX5_SET(sqc,  sqc, min_wqe_inline_mode, sq->min_inline_mode);
+
+	if (MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
+		MLX5_SET(sqc,  sqc, min_wqe_inline_mode, sq->min_inline_mode);
+
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
 	MLX5_SET(sqc,  sqc, tis_lst_sz, param->type == MLX5E_SQ_ICO ? 0 : 1);
 
@@ -3533,6 +3534,10 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
 	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
 	mlx5_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
+	if (priv->params.tx_min_inline_mode == MLX5_INLINE_MODE_NONE &&
+	    !MLX5_CAP_ETH(mdev, wqe_vlan_insert))
+		priv->params.tx_min_inline_mode = MLX5_INLINE_MODE_L2;
+
 	priv->params.num_tc                = 1;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 678c07c8fbb0..f193128bac4b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -154,6 +154,8 @@ static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
 	int hlen;
 
 	switch (mode) {
+	case MLX5_INLINE_MODE_NONE:
+		return 0;
 	case MLX5_INLINE_MODE_TCP_UDP:
 		hlen = eth_get_headlen(skb->data, skb_headlen(skb));
 		if (hlen == ETH_HLEN && !skb_vlan_tag_present(skb))
@@ -283,21 +285,23 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	wi->num_bytes = num_bytes;
 
-	if (skb_vlan_tag_present(skb)) {
-		mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data,
-				  &skb_len);
-		ihs += VLAN_HLEN;
-	} else {
-		memcpy(eseg->inline_hdr.start, skb_data, ihs);
-		mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
+	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
+	if (ihs) {
+		if (skb_vlan_tag_present(skb)) {
+			mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data, &skb_len);
+			ihs += VLAN_HLEN;
+		} else {
+			memcpy(eseg->inline_hdr.start, skb_data, ihs);
+			mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
+		}
+		eseg->inline_hdr.sz = cpu_to_be16(ihs);
+		ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start), MLX5_SEND_WQE_DS);
+	} else if (skb_vlan_tag_present(skb)) {
+		eseg->insert.type = cpu_to_be16(MLX5_ETH_WQE_INSERT_VLAN);
+		eseg->insert.vlan_tci = cpu_to_be16(skb_vlan_tag_get(skb));
 	}
 
-	eseg->inline_hdr.sz = cpu_to_be16(ihs);
-
-	ds_cnt  = sizeof(*wqe) / MLX5_SEND_WQE_DS;
-	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start),
-			       MLX5_SEND_WQE_DS);
-	dseg    = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
+	dseg = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
 
 	wi->num_dma = 0;
 
-- 
2.11.0
