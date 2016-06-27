From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 13/16] net/mlx5e: Mark enabled RQTs instances explicitly
Date: Mon, 27 Jun 2016 19:07:26 +0300
Message-ID: <1467043649-28594-14-git-send-email-saeedm@mellanox.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36560 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751639AbcF0QKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 12:10:19 -0400
In-Reply-To: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

In the current driver implementation two types of receive queue
tables (RQTs) are in use - direct and indirect.

Change the driver to mark each new created RQT (direct or indirect)
as "enabled". This behaviour is needed for introducing new mlx5e
instances which serve to represent SRIOV VFs.

The VF representors will have only one type of RQTs (direct).

An "enabled" flag is added to each RQT to allow better handling
and code sharing between the representors and the nic netdevices.

This patch doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 13 +++++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 45 +++++++++++++---------
 3 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ded3f96..1843a4c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -552,10 +552,15 @@ struct mlx5e_flow_steering {
 	struct mlx5e_arfs_tables        arfs;
 };
 
-struct mlx5e_tir {
-	u32              tirn;
+struct mlx5e_rqt {
 	u32              rqtn;
-	struct list_head list;
+	bool		 enabled;
+};
+
+struct mlx5e_tir {
+	u32		  tirn;
+	struct mlx5e_rqt  rqt;
+	struct list_head  list;
 };
 
 enum {
@@ -576,7 +581,7 @@ struct mlx5e_priv {
 
 	struct mlx5e_channel     **channel;
 	u32                        tisn[MLX5E_MAX_NUM_TC];
-	u32                        indir_rqtn;
+	struct mlx5e_rqt           indir_rqt;
 	struct mlx5e_tir           indir_tir[MLX5E_NUM_INDIR_TIRS];
 	struct mlx5e_tir           direct_tir[MLX5E_MAX_NUM_CHANNELS];
 	u32                        tx_rates[MLX5E_MAX_NUM_SQS];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 877cf68..7c5c477 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -898,7 +898,7 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 	mutex_lock(&priv->state_lock);
 
 	if (indir) {
-		u32 rqtn = priv->indir_rqtn;
+		u32 rqtn = priv->indir_rqt.rqtn;
 
 		memcpy(priv->params.indirection_rqt, indir,
 		       sizeof(priv->params.indirection_rqt));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 808dff4..db890b2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1487,7 +1487,8 @@ static void mlx5e_fill_direct_rqt_rqn(struct mlx5e_priv *priv, void *rqtc,
 	MLX5_SET(rqtc, rqtc, rq_num[0], rqn);
 }
 
-static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz, int ix, u32 *rqtn)
+static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz,
+			    int ix, struct mlx5e_rqt *rqt)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqtc;
@@ -1510,34 +1511,37 @@ static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz, int ix, u32 *rqtn)
 	else
 		mlx5e_fill_direct_rqt_rqn(priv, rqtc, ix);
 
-	err = mlx5_core_create_rqt(mdev, in, inlen, rqtn);
+	err = mlx5_core_create_rqt(mdev, in, inlen, &rqt->rqtn);
+	if (!err)
+		rqt->enabled = true;
 
 	kvfree(in);
 	return err;
 }
 
-static void mlx5e_destroy_rqt(struct mlx5e_priv *priv, u32 rqtn)
+static void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt)
 {
-	mlx5_core_destroy_rqt(priv->mdev, rqtn);
+	rqt->enabled = false;
+	mlx5_core_destroy_rqt(priv->mdev, rqt->rqtn);
 }
 
 static int mlx5e_create_rqts(struct mlx5e_priv *priv)
 {
 	int nch = mlx5e_get_max_num_channels(priv->mdev);
-	u32 *rqtn;
+	struct mlx5e_rqt *rqt;
 	int err;
 	int ix;
 
 	/* Indirect RQT */
-	rqtn = &priv->indir_rqtn;
-	err = mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, 0, rqtn);
+	rqt = &priv->indir_rqt;
+	err = mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, 0, rqt);
 	if (err)
 		return err;
 
 	/* Direct RQTs */
 	for (ix = 0; ix < nch; ix++) {
-		rqtn = &priv->direct_tir[ix].rqtn;
-		err = mlx5e_create_rqt(priv, 1 /*size */, ix, rqtn);
+		rqt = &priv->direct_tir[ix].rqt;
+		err = mlx5e_create_rqt(priv, 1 /*size */, ix, rqt);
 		if (err)
 			goto err_destroy_rqts;
 	}
@@ -1546,9 +1550,9 @@ static int mlx5e_create_rqts(struct mlx5e_priv *priv)
 
 err_destroy_rqts:
 	for (ix--; ix >= 0; ix--)
-		mlx5e_destroy_rqt(priv, priv->direct_tir[ix].rqtn);
+		mlx5e_destroy_rqt(priv, &priv->direct_tir[ix].rqt);
 
-	mlx5e_destroy_rqt(priv, priv->indir_rqtn);
+	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 
 	return err;
 }
@@ -1559,9 +1563,9 @@ static void mlx5e_destroy_rqts(struct mlx5e_priv *priv)
 	int i;
 
 	for (i = 0; i < nch; i++)
-		mlx5e_destroy_rqt(priv, priv->direct_tir[i].rqtn);
+		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
 
-	mlx5e_destroy_rqt(priv, priv->indir_rqtn);
+	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 }
 
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix)
@@ -1599,10 +1603,15 @@ static void mlx5e_redirect_rqts(struct mlx5e_priv *priv)
 	u32 rqtn;
 	int ix;
 
-	rqtn = priv->indir_rqtn;
-	mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, 0);
+	if (priv->indir_rqt.enabled) {
+		rqtn = priv->indir_rqt.rqtn;
+		mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, 0);
+	}
+
 	for (ix = 0; ix < priv->params.num_channels; ix++) {
-		rqtn = priv->direct_tir[ix].rqtn;
+		if (!priv->direct_tir[ix].rqt.enabled)
+			continue;
+		rqtn = priv->direct_tir[ix].rqt.rqtn;
 		mlx5e_redirect_rqt(priv, rqtn, 1, ix);
 	}
 }
@@ -2013,7 +2022,7 @@ static void mlx5e_build_indir_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
 	mlx5e_build_tir_ctx_lro(tirc, priv);
 
 	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
-	MLX5_SET(tirc, tirc, indirect_table, priv->indir_rqtn);
+	MLX5_SET(tirc, tirc, indirect_table, priv->indir_rqt.rqtn);
 	mlx5e_build_tir_ctx_hash(tirc, priv);
 
 	switch (tt) {
@@ -2145,7 +2154,7 @@ static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 		tir = &priv->direct_tir[ix];
 		tirc = MLX5_ADDR_OF(create_tir_in, in, ctx);
 		mlx5e_build_direct_tir_ctx(priv, tirc,
-					   priv->direct_tir[ix].rqtn);
+					   priv->direct_tir[ix].rqt.rqtn);
 		err = mlx5e_create_tir(priv->mdev, tir, in, inlen);
 		if (err)
 			goto err_destroy_ch_tirs;
-- 
2.8.0
