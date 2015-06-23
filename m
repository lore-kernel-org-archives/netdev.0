From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 03/11] net/mlx5e: Static mapping of netdev priv resources to/from netdev TX queues
Date: Tue, 23 Jun 2015 17:14:14 +0300
Message-ID: <1435068862-26488-4-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41177 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934061AbbFWOO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:14:59 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

To save per-packet calculations, we use the following static mappings:
1) priv {channel, tc} to netdev txq (used @mlx5e_selec_queue())
2) netdev txq to priv sq (used @mlx5e_xmit())

Thanks to these static mappings, no more need for a separate implementation
of ndo_start_xmit when multiple TCs are configured.
We believe the performance improvement of such separation would be negligible, if any.
The previous way of dynamically calculating the above mappings required
allocating more TX queues than actually used (@alloc_etherdev_mqs()),
which is now no longer needed.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 41 +++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 18 ++--------
 3 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e14120e..1706979 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -316,6 +316,7 @@ struct mlx5e_channel {
 	__be32                     mkey_be;
 	u8                         num_tc;
 	unsigned long              flags;
+	int                        tc_to_txq_map[MLX5E_MAX_NUM_TC];
 
 	/* control */
 	struct mlx5e_priv         *priv;
@@ -379,10 +380,9 @@ struct mlx5e_flow_table {
 
 struct mlx5e_priv {
 	/* priv data path fields - start */
-	int                        order_base_2_num_channels;
-	int                        queue_mapping_channel_mask;
 	int                        num_tc;
 	int                        default_vlan_prio;
+	struct mlx5e_sq            **txq_to_sq_map;
 	/* priv data path fields - end */
 
 	unsigned long              state;
@@ -460,7 +460,6 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw);
 u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		       void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev);
-netdev_tx_t mlx5e_xmit_multi_tc(struct sk_buff *skb, struct net_device *dev);
 
 void mlx5e_completion_event(struct mlx5_core_cq *mcq);
 void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9a48d8e..f5f5eb9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -496,6 +496,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	void *sqc = param->sqc;
 	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
+	int txq_ix;
 	int err;
 
 	err = mlx5_alloc_map_uar(mdev, &sq->uar);
@@ -515,14 +516,15 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	sq->txq = netdev_get_tx_queue(priv->netdev,
-				      c->ix + tc * priv->params.num_channels);
+	txq_ix = c->ix + tc * priv->params.num_channels;
+	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
 
 	sq->pdev    = c->pdev;
 	sq->mkey_be = c->mkey_be;
 	sq->channel = c;
 	sq->tc      = tc;
 	sq->edge    = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
+	priv->txq_to_sq_map[txq_ix] = sq;
 
 	return 0;
 
@@ -902,6 +904,15 @@ static void mlx5e_close_sqs(struct mlx5e_channel *c)
 		mlx5e_close_sq(&c->sq[tc]);
 }
 
+static void mlx5e_build_tc_to_txq_map(struct mlx5e_channel *c,
+				      int num_channels)
+{
+	int i;
+
+	for (i = 0; i < MLX5E_MAX_NUM_TC; i++)
+		c->tc_to_txq_map[i] = c->ix + i * num_channels;
+}
+
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
@@ -923,6 +934,8 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->mkey_be  = cpu_to_be32(priv->mr.key);
 	c->num_tc   = priv->num_tc;
 
+	mlx5e_build_tc_to_txq_map(c, priv->params.num_channels);
+
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
 	err = mlx5e_open_tx_cqs(c, cparam);
@@ -1050,14 +1063,18 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 static int mlx5e_open_channels(struct mlx5e_priv *priv)
 {
 	struct mlx5e_channel_param cparam;
-	int err;
+	int err = -ENOMEM;
 	int i;
 	int j;
 
 	priv->channel = kcalloc(priv->params.num_channels,
 				sizeof(struct mlx5e_channel *), GFP_KERNEL);
-	if (!priv->channel)
-		return -ENOMEM;
+
+	priv->txq_to_sq_map = kcalloc(priv->params.num_channels * priv->num_tc,
+				      sizeof(struct mlx5e_sq *), GFP_KERNEL);
+
+	if (!priv->channel || !priv->txq_to_sq_map)
+		goto err_free_txq_to_sq_map;
 
 	mlx5e_build_channel_param(priv, &cparam);
 	for (i = 0; i < priv->params.num_channels; i++) {
@@ -1078,6 +1095,8 @@ err_close_channels:
 	for (i--; i >= 0; i--)
 		mlx5e_close_channel(priv->channel[i]);
 
+err_free_txq_to_sq_map:
+	kfree(priv->txq_to_sq_map);
 	kfree(priv->channel);
 
 	return err;
@@ -1090,6 +1109,7 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 	for (i = 0; i < priv->params.num_channels; i++)
 		mlx5e_close_channel(priv->channel[i]);
 
+	kfree(priv->txq_to_sq_map);
 	kfree(priv->channel);
 }
 
@@ -1384,8 +1404,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	int num_txqs;
 	int err;
 
-	num_txqs = roundup_pow_of_two(priv->params.num_channels) *
-		   priv->params.num_tc;
+	num_txqs = priv->params.num_channels * priv->params.num_tc;
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
 
@@ -1693,9 +1712,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->mdev                         = mdev;
 	priv->netdev                       = netdev;
 	priv->params.num_channels          = num_comp_vectors;
-	priv->order_base_2_num_channels    = order_base_2(num_comp_vectors);
-	priv->queue_mapping_channel_mask   =
-		roundup_pow_of_two(num_comp_vectors) - 1;
 	priv->num_tc                       = priv->params.num_tc;
 	priv->default_vlan_prio            = priv->params.default_vlan_prio;
 
@@ -1723,7 +1739,6 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	if (priv->num_tc > 1) {
 		mlx5e_netdev_ops.ndo_select_queue = mlx5e_select_queue;
-		mlx5e_netdev_ops.ndo_start_xmit   = mlx5e_xmit_multi_tc;
 	}
 
 	netdev->netdev_ops        = &mlx5e_netdev_ops;
@@ -1793,9 +1808,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	if (mlx5e_check_required_hca_cap(mdev))
 		return NULL;
 
-	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv),
-				    roundup_pow_of_two(ncv) * MLX5E_MAX_NUM_TC,
-				    ncv);
+	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv), ncv, ncv);
 	if (!netdev) {
 		mlx5_core_err(mdev, "alloc_etherdev_mqs() failed\n");
 		return NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index bac268a..471babd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -106,7 +106,7 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		 priv->default_vlan_prio;
 	int tc = netdev_get_prio_tc_map(dev, up);
 
-	return (tc << priv->order_base_2_num_channels) | channel_ix;
+	return priv->channel[channel_ix]->tc_to_txq_map[tc];
 }
 
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
@@ -250,21 +250,7 @@ dma_unmap_wqe_err:
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int ix = skb->queue_mapping;
-	int tc = 0;
-	struct mlx5e_channel *c = priv->channel[ix];
-	struct mlx5e_sq *sq = &c->sq[tc];
-
-	return mlx5e_sq_xmit(sq, skb);
-}
-
-netdev_tx_t mlx5e_xmit_multi_tc(struct sk_buff *skb, struct net_device *dev)
-{
-	struct mlx5e_priv *priv = netdev_priv(dev);
-	int ix = skb->queue_mapping & priv->queue_mapping_channel_mask;
-	int tc = skb->queue_mapping >> priv->order_base_2_num_channels;
-	struct mlx5e_channel *c = priv->channel[ix];
-	struct mlx5e_sq *sq = &c->sq[tc];
+	struct mlx5e_sq *sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
 
 	return mlx5e_sq_xmit(sq, skb);
 }
-- 
2.3.7
