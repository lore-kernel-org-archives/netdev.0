From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/14] net/mlx5e: Redirect RQT refactoring
Date: Mon, 27 Mar 2017 23:49:00 +0300
Message-ID: <20170327204910.20287-5-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44892 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752428AbdC0UuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:02 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RQ Tables are always created once (on netdev creation) pointing to drop RQ
and at that stage, RQ tables (indirection tables) are always directed to
drop RQ.

We don't need to use mlx5e_fill_{direct,indir}_rqt_rqns to fill the drop
RQ in create RQT procedure.

Instead of having separate flows to redirect direct and indirect RQ Tables
to the current active channels Receive Queues (RQs), we unify the two
flows by introducing mlx5e_redirect_rqt function and redirect_rqt_param
struct. Combined, they provide one generic logic to fill the RQ table RQ
numbers regardless of the RQ table purpose (direct/indirect).

Demonstrated the usage with mlx5e_redirect_rqts_to_channels which will
be called on mlx5e_open and with mlx5e_redirect_rqts_to_drop which will
be called on mlx5e_close.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  14 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  24 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 169 ++++++++++++---------
 3 files changed, 129 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b00c6688ddcf..50dfc4c6c8e4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -843,7 +843,19 @@ void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
 int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd);
 
-int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix);
+struct mlx5e_redirect_rqt_param {
+	bool is_rss;
+	union {
+		u32 rqn; /* Direct RQN (Non-RSS) */
+		struct {
+			u8 hfunc;
+			struct mlx5e_channels *channels;
+		} rss; /* RSS data */
+	};
+};
+
+int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz,
+		       struct mlx5e_redirect_rqt_param rrp);
 void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
 				    enum mlx5e_traffic_types tt);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 2e54a6564d86..faa21848c9dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1027,20 +1027,28 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 
 	mutex_lock(&priv->state_lock);
 
-	if (indir) {
-		u32 rqtn = priv->indir_rqt.rqtn;
-
-		memcpy(priv->params.indirection_rqt, indir,
-		       sizeof(priv->params.indirection_rqt));
-		mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, 0);
-	}
-
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE &&
 	    hfunc != priv->params.rss_hfunc) {
 		priv->params.rss_hfunc = hfunc;
 		hash_changed = true;
 	}
 
+	if (indir) {
+		memcpy(priv->params.indirection_rqt, indir,
+		       sizeof(priv->params.indirection_rqt));
+
+		if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+			u32 rqtn = priv->indir_rqt.rqtn;
+			struct mlx5e_redirect_rqt_param rrp = {
+				.is_rss = true,
+				.rss.hfunc = priv->params.rss_hfunc,
+				.rss.channels  = &priv->channels
+			};
+
+			mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, rrp);
+		}
+	}
+
 	if (key) {
 		memcpy(priv->params.toeplitz_hash_key, key,
 		       sizeof(priv->params.toeplitz_hash_key));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 920e72ae992e..aec77f075714 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2046,61 +2046,15 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 	chs->num = 0;
 }
 
-static int mlx5e_rx_hash_fn(int hfunc)
-{
-	return (hfunc == ETH_RSS_HASH_TOP) ?
-	       MLX5_RX_HASH_FN_TOEPLITZ :
-	       MLX5_RX_HASH_FN_INVERTED_XOR8;
-}
-
-static int mlx5e_bits_invert(unsigned long a, int size)
-{
-	int inv = 0;
-	int i;
-
-	for (i = 0; i < size; i++)
-		inv |= (test_bit(size - i - 1, &a) ? 1 : 0) << i;
-
-	return inv;
-}
-
-static void mlx5e_fill_indir_rqt_rqns(struct mlx5e_priv *priv, void *rqtc)
-{
-	int i;
-
-	for (i = 0; i < MLX5E_INDIR_RQT_SIZE; i++) {
-		int ix = i;
-		u32 rqn;
-
-		if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
-			ix = mlx5e_bits_invert(i, MLX5E_LOG_INDIR_RQT_SIZE);
-
-		ix = priv->params.indirection_rqt[ix];
-		rqn = test_bit(MLX5E_STATE_OPENED, &priv->state) ?
-				priv->channels.c[ix]->rq.rqn :
-				priv->drop_rq.rqn;
-		MLX5_SET(rqtc, rqtc, rq_num[i], rqn);
-	}
-}
-
-static void mlx5e_fill_direct_rqt_rqn(struct mlx5e_priv *priv, void *rqtc,
-				      int ix)
-{
-	u32 rqn = test_bit(MLX5E_STATE_OPENED, &priv->state) ?
-			priv->channels.c[ix]->rq.rqn :
-			priv->drop_rq.rqn;
-
-	MLX5_SET(rqtc, rqtc, rq_num[0], rqn);
-}
-
-static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz,
-			    int ix, struct mlx5e_rqt *rqt)
+static int
+mlx5e_create_rqt(struct mlx5e_priv *priv, int sz, struct mlx5e_rqt *rqt)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqtc;
 	int inlen;
 	int err;
 	u32 *in;
+	int i;
 
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
 	in = mlx5_vzalloc(inlen);
@@ -2112,10 +2066,8 @@ static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz,
 	MLX5_SET(rqtc, rqtc, rqt_actual_size, sz);
 	MLX5_SET(rqtc, rqtc, rqt_max_size, sz);
 
-	if (sz > 1) /* RSS */
-		mlx5e_fill_indir_rqt_rqns(priv, rqtc);
-	else
-		mlx5e_fill_direct_rqt_rqn(priv, rqtc, ix);
+	for (i = 0; i < sz; i++)
+		MLX5_SET(rqtc, rqtc, rq_num[i], priv->drop_rq.rqn);
 
 	err = mlx5_core_create_rqt(mdev, in, inlen, &rqt->rqtn);
 	if (!err)
@@ -2135,7 +2087,7 @@ static int mlx5e_create_indirect_rqts(struct mlx5e_priv *priv)
 {
 	struct mlx5e_rqt *rqt = &priv->indir_rqt;
 
-	return mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, 0, rqt);
+	return mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, rqt);
 }
 
 int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
@@ -2146,7 +2098,7 @@ int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
 
 	for (ix = 0; ix < priv->profile->max_nch(priv->mdev); ix++) {
 		rqt = &priv->direct_tir[ix].rqt;
-		err = mlx5e_create_rqt(priv, 1 /*size */, ix, rqt);
+		err = mlx5e_create_rqt(priv, 1 /*size */, rqt);
 		if (err)
 			goto err_destroy_rqts;
 	}
@@ -2160,7 +2112,49 @@ int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
 	return err;
 }
 
-int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix)
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
+static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, int sz,
+				struct mlx5e_redirect_rqt_param rrp, void *rqtc)
+{
+	int i;
+
+	for (i = 0; i < sz; i++) {
+		u32 rqn;
+
+		if (rrp.is_rss) {
+			int ix = i;
+
+			if (rrp.rss.hfunc == ETH_RSS_HASH_XOR)
+				ix = mlx5e_bits_invert(i, ilog2(sz));
+
+			ix = priv->params.indirection_rqt[ix];
+			rqn = rrp.rss.channels->c[ix]->rq.rqn;
+		} else {
+			rqn = rrp.rqn;
+		}
+		MLX5_SET(rqtc, rqtc, rq_num[i], rqn);
+	}
+}
+
+int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz,
+		       struct mlx5e_redirect_rqt_param rrp)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqtc;
@@ -2176,38 +2170,75 @@ int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix)
 	rqtc = MLX5_ADDR_OF(modify_rqt_in, in, ctx);
 
 	MLX5_SET(rqtc, rqtc, rqt_actual_size, sz);
-	if (sz > 1) /* RSS */
-		mlx5e_fill_indir_rqt_rqns(priv, rqtc);
-	else
-		mlx5e_fill_direct_rqt_rqn(priv, rqtc, ix);
-
 	MLX5_SET(modify_rqt_in, in, bitmask.rqn_list, 1);
-
+	mlx5e_fill_rqt_rqns(priv, sz, rrp, rqtc);
 	err = mlx5_core_modify_rqt(mdev, rqtn, in, inlen);
 
 	kvfree(in);
-
 	return err;
 }
 
-static void mlx5e_redirect_rqts(struct mlx5e_priv *priv)
+static u32 mlx5e_get_direct_rqn(struct mlx5e_priv *priv, int ix,
+				struct mlx5e_redirect_rqt_param rrp)
+{
+	if (!rrp.is_rss)
+		return rrp.rqn;
+
+	if (ix >= rrp.rss.channels->num)
+		return priv->drop_rq.rqn;
+
+	return rrp.rss.channels->c[ix]->rq.rqn;
+}
+
+static void mlx5e_redirect_rqts(struct mlx5e_priv *priv,
+				struct mlx5e_redirect_rqt_param rrp)
 {
 	u32 rqtn;
 	int ix;
 
 	if (priv->indir_rqt.enabled) {
+		/* RSS RQ table */
 		rqtn = priv->indir_rqt.rqtn;
-		mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, 0);
+		mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, rrp);
 	}
 
-	for (ix = 0; ix < priv->params.num_channels; ix++) {
+	for (ix = 0; ix < priv->profile->max_nch(priv->mdev); ix++) {
+		struct mlx5e_redirect_rqt_param direct_rrp = {
+			.is_rss = false,
+			.rqn    = mlx5e_get_direct_rqn(priv, ix, rrp)
+		};
+
+		/* Direct RQ Tables */
 		if (!priv->direct_tir[ix].rqt.enabled)
 			continue;
+
 		rqtn = priv->direct_tir[ix].rqt.rqtn;
-		mlx5e_redirect_rqt(priv, rqtn, 1, ix);
+		mlx5e_redirect_rqt(priv, rqtn, 1, direct_rrp);
 	}
 }
 
+static void mlx5e_redirect_rqts_to_channels(struct mlx5e_priv *priv,
+					    struct mlx5e_channels *chs)
+{
+	struct mlx5e_redirect_rqt_param rrp = {
+		.is_rss        = true,
+		.rss.channels  = chs,
+		.rss.hfunc     = priv->params.rss_hfunc
+	};
+
+	mlx5e_redirect_rqts(priv, rrp);
+}
+
+static void mlx5e_redirect_rqts_to_drop(struct mlx5e_priv *priv)
+{
+	struct mlx5e_redirect_rqt_param drop_rrp = {
+		.is_rss = false,
+		.rqn = priv->drop_rq.rqn
+	};
+
+	mlx5e_redirect_rqts(priv, drop_rrp);
+}
+
 static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 {
 	if (!priv->params.lro_en)
@@ -2474,7 +2505,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_close_channels;
 	}
 
-	mlx5e_redirect_rqts(priv);
+	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 
@@ -2525,7 +2556,7 @@ int mlx5e_close_locked(struct net_device *netdev)
 
 	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
-	mlx5e_redirect_rqts(priv);
+	mlx5e_redirect_rqts_to_drop(priv);
 	mlx5e_close_channels(priv);
 
 	return 0;
-- 
2.11.0
