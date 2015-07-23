From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/6] net/mlx5e: Support ETH_RSS_HASH_XOR
Date: Thu, 23 Jul 2015 23:35:56 +0300
Message-ID: <1437683761-28052-2-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39700 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754105AbbGWUhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:37:00 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

The ConnectX-4 HW implements inverted XOR8.
To make it act as XOR we re-order the HW RSS indirection table.

Set XOR to be the default RSS hash function and add ethtool API to
control it.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 39 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 46 +++++++++++++++++-----
 include/linux/mlx5/mlx5_ifc.h                      |  6 +--
 4 files changed, 79 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 3d23bd6..61d8433 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -195,6 +195,7 @@ struct mlx5e_params {
 	u16 rx_hash_log_tbl_sz;
 	bool lro_en;
 	u32 lro_wqe_sz;
+	u8  rss_hfunc;
 };
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 3889384..cb28535 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -662,6 +662,43 @@ out:
 	return err;
 }
 
+static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			  u8 *hfunc)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (hfunc)
+		*hfunc = priv->params.rss_hfunc;
+
+	return 0;
+}
+
+static int mlx5e_set_rxfh(struct net_device *netdev, const u32 *indir,
+			  const u8 *key, const u8 hfunc)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err = 0;
+
+	if (hfunc == ETH_RSS_HASH_NO_CHANGE)
+		return 0;
+
+	if ((hfunc != ETH_RSS_HASH_XOR) &&
+	    (hfunc != ETH_RSS_HASH_TOP))
+		return -EINVAL;
+
+	mutex_lock(&priv->state_lock);
+
+	priv->params.rss_hfunc = hfunc;
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		mlx5e_close_locked(priv->netdev);
+		err = mlx5e_open_locked(priv->netdev);
+	}
+
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -676,4 +713,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_coalesce      = mlx5e_set_coalesce,
 	.get_settings      = mlx5e_get_settings,
 	.set_settings      = mlx5e_set_settings,
+	.get_rxfh          = mlx5e_get_rxfh,
+	.set_rxfh          = mlx5e_set_rxfh,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 40206da..07d3627 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1158,6 +1158,24 @@ static void mlx5e_close_tises(struct mlx5e_priv *priv)
 		mlx5e_close_tis(priv, tc);
 }
 
+static int mlx5e_rx_hash_fn(int hfunc)
+{
+	return (hfunc == ETH_RSS_HASH_TOP) ?
+	       MLX5_RX_HASH_FN_TOEPLITZ :
+	       MLX5_RX_HASH_FN_INVERTED_XOR8;
+}
+
+static int mlx5e_bits_invert(unsigned long a, int size)
+{
+	int inv = 0;
+	int i;
+
+	for (i = 0; i < size; i++)
+		inv |= (test_bit(size - i - 1, &a) ? 1 : 0) << i;
+
+	return inv;
+}
+
 static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1166,11 +1184,10 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 	void *rqtc;
 	int inlen;
 	int err;
-	int sz;
+	int log_tbl_sz = priv->params.rx_hash_log_tbl_sz;
+	int sz = 1 << log_tbl_sz;
 	int i;
 
-	sz = 1 << priv->params.rx_hash_log_tbl_sz;
-
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
 	in = mlx5_vzalloc(inlen);
 	if (!in)
@@ -1182,8 +1199,12 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 	MLX5_SET(rqtc, rqtc, rqt_max_size, sz);
 
 	for (i = 0; i < sz; i++) {
-		int ix = i % priv->params.num_channels;
+		int ix = i;
+
+		if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
+			ix = mlx5e_bits_invert(i, log_tbl_sz);
 
+		ix = ix % priv->params.num_channels;
 		MLX5_SET(rqtc, rqtc, rq_num[i], priv->channel[ix]->rq.rqn);
 	}
 
@@ -1254,12 +1275,16 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 		MLX5_SET(tirc, tirc, indirect_table,
 			 priv->rqtn);
 		MLX5_SET(tirc, tirc, rx_hash_fn,
-			 MLX5_TIRC_RX_HASH_FN_HASH_TOEPLITZ);
-		MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
-		netdev_rss_key_fill(MLX5_ADDR_OF(tirc, tirc,
-						 rx_hash_toeplitz_key),
-				    MLX5_FLD_SZ_BYTES(tirc,
-						      rx_hash_toeplitz_key));
+			 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
+		if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
+			void *rss_key = MLX5_ADDR_OF(tirc, tirc,
+						     rx_hash_toeplitz_key);
+			size_t len = MLX5_FLD_SZ_BYTES(tirc,
+						       rx_hash_toeplitz_key);
+
+			MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
+			netdev_rss_key_fill(rss_key, len);
+		}
 		break;
 	}
 
@@ -1700,6 +1725,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 		MLX5E_PARAMS_DEFAULT_RX_HASH_LOG_TBL_SZ;
 	priv->params.num_tc                = 1;
 	priv->params.default_vlan_prio     = 0;
+	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
 	priv->params.lro_en = false && !!MLX5_CAP_ETH(priv->mdev, lro_cap);
 	priv->params.lro_wqe_sz            =
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 6d2f6fe..c60a62b 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1936,9 +1936,9 @@ enum {
 };
 
 enum {
-	MLX5_TIRC_RX_HASH_FN_HASH_NONE           = 0x0,
-	MLX5_TIRC_RX_HASH_FN_HASH_INVERTED_XOR8  = 0x1,
-	MLX5_TIRC_RX_HASH_FN_HASH_TOEPLITZ       = 0x2,
+	MLX5_RX_HASH_FN_NONE           = 0x0,
+	MLX5_RX_HASH_FN_INVERTED_XOR8  = 0x1,
+	MLX5_RX_HASH_FN_TOEPLITZ       = 0x2,
 };
 
 enum {
-- 
2.4.3.413.ga5fe668
