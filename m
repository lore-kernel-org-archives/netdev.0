From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5e: Make RSS indirection table size a constant
Date: Sun, 16 Aug 2015 16:04:46 +0300
Message-ID: <1439730292-29617-3-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38366 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751266AbbHPNHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:00 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indirection table size was defined by a variable that
was actually assigned a constant value.
Since we do not have any forseen intension to make it configurable
we simply made it a constant.

We also limit the number of channels such that the RSS indirection
table could always populate all RX rings.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 60 ++++++++++-------------
 2 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7b2b743..0b8a2703 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -56,8 +56,10 @@
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC      0x10
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS      0x20
 #define MLX5E_PARAMS_DEFAULT_MIN_RX_WQES                0x80
-#define MLX5E_PARAMS_DEFAULT_RX_HASH_LOG_TBL_SZ         0x7
 
+#define MLX5E_LOG_INDIR_RQT_SIZE       0x7
+#define MLX5E_INDIR_RQT_SIZE           BIT(MLX5E_LOG_INDIR_RQT_SIZE)
+#define MLX5E_MAX_NUM_CHANNELS         (MLX5E_INDIR_RQT_SIZE >> 1)
 #define MLX5E_TX_CQ_POLL_BUDGET        128
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
 #define MLX5E_SQ_BF_BUDGET             16
@@ -268,7 +270,6 @@ struct mlx5e_params {
 	u16 tx_cq_moderation_usec;
 	u16 tx_cq_moderation_pkts;
 	u16 min_rx_wqes;
-	u16 rx_hash_log_tbl_sz;
 	bool lro_en;
 	u32 lro_wqe_sz;
 	u8  rss_hfunc;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 662ca67..bc36f9b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1174,27 +1174,31 @@ static int mlx5e_bits_invert(unsigned long a, int size)
 	return inv;
 }
 
+static void mlx5e_fill_indir_rqt_rqns(struct mlx5e_priv *priv, void *rqtc)
+{
+	int i;
+
+	for (i = 0; i < MLX5E_INDIR_RQT_SIZE; i++) {
+		int ix = i;
+
+		if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
+			ix = mlx5e_bits_invert(i, MLX5E_LOG_INDIR_RQT_SIZE);
+
+		ix = ix % priv->params.num_channels;
+		MLX5_SET(rqtc, rqtc, rq_num[i],
+			 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
+			 priv->channel[ix]->rq.rqn :
+			 priv->drop_rq.rqn);
+	}
+}
+
 static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, void *rqtc,
 				enum mlx5e_rqt_ix rqt_ix)
 {
-	int i;
-	int log_sz;
 
 	switch (rqt_ix) {
 	case MLX5E_INDIRECTION_RQT:
-		log_sz = priv->params.rx_hash_log_tbl_sz;
-		for (i = 0; i < (1 << log_sz); i++) {
-			int ix = i;
-
-			if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
-				ix = mlx5e_bits_invert(i, log_sz);
-
-			ix = ix % priv->params.num_channels;
-			MLX5_SET(rqtc, rqtc, rq_num[i],
-				 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
-				 priv->channel[ix]->rq.rqn :
-				 priv->drop_rq.rqn);
-		}
+		mlx5e_fill_indir_rqt_rqns(priv, rqtc);
 
 		break;
 
@@ -1214,13 +1218,10 @@ static int mlx5e_create_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 	u32 *in;
 	void *rqtc;
 	int inlen;
-	int log_sz;
 	int sz;
 	int err;
 
-	log_sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 0 :
-		  priv->params.rx_hash_log_tbl_sz;
-	sz = 1 << log_sz;
+	sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 1 : MLX5E_INDIR_RQT_SIZE;
 
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
 	in = mlx5_vzalloc(inlen);
@@ -1247,13 +1248,10 @@ static int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 	u32 *in;
 	void *rqtc;
 	int inlen;
-	int log_sz;
 	int sz;
 	int err;
 
-	log_sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 0 :
-		  priv->params.rx_hash_log_tbl_sz;
-	sz = 1 << log_sz;
+	sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 1 : MLX5E_INDIR_RQT_SIZE;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rqt_in) + sizeof(u32) * sz;
 	in = mlx5_vzalloc(inlen);
@@ -1911,7 +1909,7 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
-				    int num_comp_vectors)
+				    int num_channels)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
@@ -1930,11 +1928,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
 	priv->params.min_rx_wqes           =
 		MLX5E_PARAMS_DEFAULT_MIN_RX_WQES;
-	priv->params.rx_hash_log_tbl_sz    =
-		(order_base_2(num_comp_vectors) >
-		 MLX5E_PARAMS_DEFAULT_RX_HASH_LOG_TBL_SZ) ?
-		order_base_2(num_comp_vectors)           :
-		MLX5E_PARAMS_DEFAULT_RX_HASH_LOG_TBL_SZ;
 	priv->params.num_tc                = 1;
 	priv->params.default_vlan_prio     = 0;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
@@ -1948,7 +1941,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 
 	priv->mdev                         = mdev;
 	priv->netdev                       = netdev;
-	priv->params.num_channels          = num_comp_vectors;
+	priv->params.num_channels          = num_channels;
 	priv->default_vlan_prio            = priv->params.default_vlan_prio;
 
 	spin_lock_init(&priv->async_events_spinlock);
@@ -2037,19 +2030,20 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 {
 	struct net_device *netdev;
 	struct mlx5e_priv *priv;
-	int ncv = mdev->priv.eq_table.num_comp_vectors;
+	int nch = min_t(int, mdev->priv.eq_table.num_comp_vectors,
+			MLX5E_MAX_NUM_CHANNELS);
 	int err;
 
 	if (mlx5e_check_required_hca_cap(mdev))
 		return NULL;
 
-	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv), ncv, ncv);
+	netdev = alloc_etherdev_mqs(sizeof(struct mlx5e_priv), nch, nch);
 	if (!netdev) {
 		mlx5_core_err(mdev, "alloc_etherdev_mqs() failed\n");
 		return NULL;
 	}
 
-	mlx5e_build_netdev_priv(mdev, netdev, ncv);
+	mlx5e_build_netdev_priv(mdev, netdev, nch);
 	mlx5e_build_netdev(netdev);
 
 	netif_carrier_off(netdev);
-- 
1.8.3.1
