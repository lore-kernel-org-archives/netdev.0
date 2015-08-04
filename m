From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx5e: Unify the RX flow
Date: Tue,  4 Aug 2015 14:05:40 +0300
Message-ID: <1438686347-17370-2-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36410 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933136AbbHDLGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:13 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Generally an RX packet flows through the following objects:
Flow table --> TIR --> RQT --> RQ

Where:
- TIR stands for "Transport Interface Receive", defining the RSS and
  LRO paramaters.
- RQT stands for "RQ Table", implementing the RSS indirection table.
- RQ stands for "Receive Queue"

For flows that do not need LRO, nor RSS, the driver made a shortcut to
the above RX flow by pointing to the RQ directly from the TIR, yielding
this flow:
Flow table --> TIR --> RQ

In this commit we remove this shortcut by "inserting" a single-RQ RQT
between the TIR and the RQ, i.e RX packets will reach the same RQ but
will go through an RQT of size 1, pointing to just a single RQ.

This way the RX traffic re-direction to/from the "Drop RQ" will be more
uniform (AKA "one flow"), as it will involve only RQTs re-direction and
no TIRs re-direction.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 10 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 93 ++++++++++++++++-------
 2 files changed, 69 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 45f6dc7..af57912 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -344,10 +344,10 @@ enum mlx5e_traffic_types {
 	MLX5E_NUM_TT,
 };
 
-enum {
-	MLX5E_RQT_SPREADING  = 0,
-	MLX5E_RQT_DEFAULT_RQ = 1,
-	MLX5E_NUM_RQT        = 2,
+enum mlx5e_rqt_ix {
+	MLX5E_INDIRECTION_RQT,
+	MLX5E_SINGLE_RQ_RQT,
+	MLX5E_NUM_RQT,
 };
 
 struct mlx5e_eth_addr_info {
@@ -402,7 +402,7 @@ struct mlx5e_priv {
 
 	struct mlx5e_channel     **channel;
 	u32                        tisn[MLX5E_MAX_NUM_TC];
-	u32                        rqtn;
+	u32                        rqtn[MLX5E_NUM_RQT];
 	u32                        tirn[MLX5E_NUM_TT];
 
 	struct mlx5e_flow_table    ft;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bb81589..333c828 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1184,16 +1184,49 @@ static int mlx5e_bits_invert(unsigned long a, int size)
 	return inv;
 }
 
-static int mlx5e_open_rqt(struct mlx5e_priv *priv)
+static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, void *rqtc,
+				enum mlx5e_rqt_ix rqt_ix)
+{
+	int i;
+	int log_sz;
+
+	switch (rqt_ix) {
+	case MLX5E_INDIRECTION_RQT:
+		log_sz = priv->params.rx_hash_log_tbl_sz;
+		for (i = 0; i < (1 << log_sz); i++) {
+			int ix = i;
+
+			if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
+				ix = mlx5e_bits_invert(i, log_sz);
+
+			ix = ix % priv->params.num_channels;
+			MLX5_SET(rqtc, rqtc, rq_num[i],
+				 priv->channel[ix]->rq.rqn);
+		}
+
+		break;
+
+	default: /* MLX5E_SINGLE_RQ_RQT */
+		MLX5_SET(rqtc, rqtc, rq_num[0],
+			 priv->channel[0]->rq.rqn);
+
+		break;
+	}
+}
+
+static int mlx5e_open_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 *in;
 	void *rqtc;
 	int inlen;
+	int log_sz;
+	int sz;
 	int err;
-	int log_tbl_sz = priv->params.rx_hash_log_tbl_sz;
-	int sz = 1 << log_tbl_sz;
-	int i;
+
+	log_sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 0 :
+		  priv->params.rx_hash_log_tbl_sz;
+	sz = 1 << log_sz;
 
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
 	in = mlx5_vzalloc(inlen);
@@ -1205,26 +1238,18 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 	MLX5_SET(rqtc, rqtc, rqt_actual_size, sz);
 	MLX5_SET(rqtc, rqtc, rqt_max_size, sz);
 
-	for (i = 0; i < sz; i++) {
-		int ix = i;
+	mlx5e_fill_rqt_rqns(priv, rqtc, rqt_ix);
 
-		if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
-			ix = mlx5e_bits_invert(i, log_tbl_sz);
-
-		ix = ix % priv->params.num_channels;
-		MLX5_SET(rqtc, rqtc, rq_num[i], priv->channel[ix]->rq.rqn);
-	}
-
-	err = mlx5_core_create_rqt(mdev, in, inlen, &priv->rqtn);
+	err = mlx5_core_create_rqt(mdev, in, inlen, &priv->rqtn[rqt_ix]);
 
 	kvfree(in);
 
 	return err;
 }
 
-static void mlx5e_close_rqt(struct mlx5e_priv *priv)
+static void mlx5e_close_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
-	mlx5_core_destroy_rqt(priv->mdev, priv->rqtn);
+	mlx5_core_destroy_rqt(priv->mdev, priv->rqtn[rqt_ix]);
 }
 
 static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
@@ -1259,18 +1284,17 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 				      lro_timer_supported_periods[3]));
 	}
 
+	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
+
 	switch (tt) {
 	case MLX5E_TT_ANY:
-		MLX5_SET(tirc, tirc, disp_type,
-			 MLX5_TIRC_DISP_TYPE_DIRECT);
-		MLX5_SET(tirc, tirc, inline_rqn,
-			 priv->channel[0]->rq.rqn);
+		MLX5_SET(tirc, tirc, indirect_table,
+			 priv->rqtn[MLX5E_SINGLE_RQ_RQT]);
+		MLX5_SET(tirc, tirc, rx_hash_fn, MLX5_RX_HASH_FN_INVERTED_XOR8);
 		break;
 	default:
-		MLX5_SET(tirc, tirc, disp_type,
-			 MLX5_TIRC_DISP_TYPE_INDIRECT);
 		MLX5_SET(tirc, tirc, indirect_table,
-			 priv->rqtn);
+			 priv->rqtn[MLX5E_INDIRECTION_RQT]);
 		MLX5_SET(tirc, tirc, rx_hash_fn,
 			 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
 		if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
@@ -1472,18 +1496,25 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_close_tises;
 	}
 
-	err = mlx5e_open_rqt(priv);
+	err = mlx5e_open_rqt(priv, MLX5E_INDIRECTION_RQT);
 	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_rqt failed, %d\n",
+		netdev_err(netdev, "%s: mlx5e_open_rqt(INDIR) failed, %d\n",
 			   __func__, err);
 		goto err_close_channels;
 	}
 
+	err = mlx5e_open_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5e_open_rqt(SINGLE) failed, %d\n",
+			   __func__, err);
+		goto err_close_rqt_indir;
+	}
+
 	err = mlx5e_open_tirs(priv);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_open_tir failed, %d\n",
 			   __func__, err);
-		goto err_close_rqls;
+		goto err_close_rqt_single;
 	}
 
 	err = mlx5e_open_flow_table(priv);
@@ -1516,8 +1547,11 @@ err_close_flow_table:
 err_close_tirs:
 	mlx5e_close_tirs(priv);
 
-err_close_rqls:
-	mlx5e_close_rqt(priv);
+err_close_rqt_single:
+	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+
+err_close_rqt_indir:
+	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
 
 err_close_channels:
 	mlx5e_close_channels(priv);
@@ -1551,7 +1585,8 @@ int mlx5e_close_locked(struct net_device *netdev)
 	netif_carrier_off(priv->netdev);
 	mlx5e_close_flow_table(priv);
 	mlx5e_close_tirs(priv);
-	mlx5e_close_rqt(priv);
+	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
 	mlx5e_close_channels(priv);
 	mlx5e_close_tises(priv);
 
-- 
2.4.3.413.ga5fe668
