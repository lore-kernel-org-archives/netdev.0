From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5e: Remove redundant field mlx5e_priv->num_tc
Date: Wed, 29 Jul 2015 15:05:41 +0300
Message-ID: <1438171546-17021-4-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53785 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750898AbbG2MGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:25 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

This field already exists under the mlx5e_params struct

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 -
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 25 ++++++++++------------
 3 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b710e9b..7b5a679 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -389,7 +389,6 @@ struct mlx5e_flow_table {
 
 struct mlx5e_priv {
 	/* priv data path fields - start */
-	int                        num_tc;
 	int                        default_vlan_prio;
 	struct mlx5e_sq            **txq_to_sq_map;
 	/* priv data path fields - end */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 14fd82c..f4a7534 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -173,7 +173,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_STATS:
 		return NUM_VPORT_COUNTERS +
 		       priv->params.num_channels * NUM_RQ_STATS +
-		       priv->params.num_channels * priv->num_tc *
+		       priv->params.num_channels * priv->params.num_tc *
 						   NUM_SQ_STATS;
 	/* fallthrough */
 	default:
@@ -207,7 +207,7 @@ static void mlx5e_get_strings(struct net_device *dev,
 					"rx%d_%s", i, rq_stats_strings[j]);
 
 		for (i = 0; i < priv->params.num_channels; i++)
-			for (tc = 0; tc < priv->num_tc; tc++)
+			for (tc = 0; tc < priv->params.num_tc; tc++)
 				for (j = 0; j < NUM_SQ_STATS; j++)
 					sprintf(data +
 						(idx++) * ETH_GSTRING_LEN,
@@ -242,7 +242,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 				       ((u64 *)&priv->channel[i]->rq.stats)[j];
 
 	for (i = 0; i < priv->params.num_channels; i++)
-		for (tc = 0; tc < priv->num_tc; tc++)
+		for (tc = 0; tc < priv->params.num_tc; tc++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				data[idx++] = !test_bit(MLX5E_STATE_OPENED,
 							&priv->state) ? 0 :
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 05b35bd..48dbed9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -117,7 +117,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		s->rx_csum_none	+= rq_stats->csum_none;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 
-		for (j = 0; j < priv->num_tc; j++) {
+		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
 
 			s->tso_packets		+= sq_stats->tso_packets;
@@ -938,7 +938,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->pdev     = &priv->mdev->pdev->dev;
 	c->netdev   = priv->netdev;
 	c->mkey_be  = cpu_to_be32(priv->mr.key);
-	c->num_tc   = priv->num_tc;
+	c->num_tc   = priv->params.num_tc;
 
 	mlx5e_build_tc_to_txq_map(c, priv->params.num_channels);
 
@@ -1069,27 +1069,28 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 static int mlx5e_open_channels(struct mlx5e_priv *priv)
 {
 	struct mlx5e_channel_param cparam;
+	int nch = priv->params.num_channels;
 	int err = -ENOMEM;
 	int i;
 	int j;
 
-	priv->channel = kcalloc(priv->params.num_channels,
-				sizeof(struct mlx5e_channel *), GFP_KERNEL);
+	priv->channel = kcalloc(nch, sizeof(struct mlx5e_channel *),
+				GFP_KERNEL);
 
-	priv->txq_to_sq_map = kcalloc(priv->params.num_channels * priv->num_tc,
+	priv->txq_to_sq_map = kcalloc(nch * priv->params.num_tc,
 				      sizeof(struct mlx5e_sq *), GFP_KERNEL);
 
 	if (!priv->channel || !priv->txq_to_sq_map)
 		goto err_free_txq_to_sq_map;
 
 	mlx5e_build_channel_param(priv, &cparam);
-	for (i = 0; i < priv->params.num_channels; i++) {
+	for (i = 0; i < nch; i++) {
 		err = mlx5e_open_channel(priv, i, &cparam, &priv->channel[i]);
 		if (err)
 			goto err_close_channels;
 	}
 
-	for (j = 0; j < priv->params.num_channels; j++) {
+	for (j = 0; j < nch; j++) {
 		err = mlx5e_wait_for_min_rx_wqes(&priv->channel[j]->rq);
 		if (err)
 			goto err_close_channels;
@@ -1140,11 +1141,10 @@ static void mlx5e_close_tis(struct mlx5e_priv *priv, int tc)
 
 static int mlx5e_open_tises(struct mlx5e_priv *priv)
 {
-	int num_tc = priv->num_tc;
 	int err;
 	int tc;
 
-	for (tc = 0; tc < num_tc; tc++) {
+	for (tc = 0; tc < priv->params.num_tc; tc++) {
 		err = mlx5e_open_tis(priv, tc);
 		if (err)
 			goto err_close_tises;
@@ -1161,10 +1161,9 @@ err_close_tises:
 
 static void mlx5e_close_tises(struct mlx5e_priv *priv)
 {
-	int num_tc = priv->num_tc;
 	int tc;
 
-	for (tc = 0; tc < num_tc; tc++)
+	for (tc = 0; tc < priv->params.num_tc; tc++)
 		mlx5e_close_tis(priv, tc);
 }
 
@@ -1786,7 +1785,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->mdev                         = mdev;
 	priv->netdev                       = netdev;
 	priv->params.num_channels          = num_comp_vectors;
-	priv->num_tc                       = priv->params.num_tc;
 	priv->default_vlan_prio            = priv->params.default_vlan_prio;
 
 	spin_lock_init(&priv->async_events_spinlock);
@@ -1811,9 +1809,8 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (priv->num_tc > 1) {
+	if (priv->params.num_tc > 1)
 		mlx5e_netdev_ops.ndo_select_queue = mlx5e_select_queue;
-	}
 
 	netdev->netdev_ops        = &mlx5e_netdev_ops;
 	netdev->watchdog_timeo    = 15 * HZ;
-- 
2.4.3.413.ga5fe668
