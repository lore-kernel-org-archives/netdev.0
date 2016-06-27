From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/16] net/mlx5e: TIRs management refactoring
Date: Mon, 27 Jun 2016 19:07:25 +0300
Message-ID: <1467043649-28594-13-git-send-email-saeedm@mellanox.com>
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
Received: from [193.47.165.129] ([193.47.165.129]:36471 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751745AbcF0QJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 12:09:18 -0400
In-Reply-To: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The current refresh tirs self loopback mechanism, refreshes all the tirs
belonging to the same mlx5e instance to prevent self loopback by packets
sent over any ring of that instance. This mechanism relies on all the
tirs/tises of an instance to be created with the same transport domain
number (tdn).

Change the driver to refresh all the tirs created under the same tdn
regardless of which mlx5e netdev instance they belong to.

This behaviour is needed for introducing new mlx5e instances which serve
to represent SRIOV VFs. The representors and the PF share vport used for
E-Switch management, and we want to avoid NIC level HW loopback between
them, e.g when sending broadcast packets. To achieve that, both the
representors and the PF NIC will share the tdn.

This patch doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 12 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  | 14 +++---
 .../net/ethernet/mellanox/mlx5/core/en_common.c    | 48 +++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 56 +++++-----------------
 6 files changed, 77 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index da93bf55..ded3f96 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -552,9 +552,10 @@ struct mlx5e_flow_steering {
 	struct mlx5e_arfs_tables        arfs;
 };
 
-struct mlx5e_direct_tir {
+struct mlx5e_tir {
 	u32              tirn;
 	u32              rqtn;
+	struct list_head list;
 };
 
 enum {
@@ -576,8 +577,8 @@ struct mlx5e_priv {
 	struct mlx5e_channel     **channel;
 	u32                        tisn[MLX5E_MAX_NUM_TC];
 	u32                        indir_rqtn;
-	u32                        indir_tirn[MLX5E_NUM_INDIR_TIRS];
-	struct mlx5e_direct_tir    direct_tir[MLX5E_MAX_NUM_CHANNELS];
+	struct mlx5e_tir           indir_tir[MLX5E_NUM_INDIR_TIRS];
+	struct mlx5e_tir           direct_tir[MLX5E_MAX_NUM_CHANNELS];
 	u32                        tx_rates[MLX5E_MAX_NUM_SQS];
 
 	struct mlx5e_flow_steering fs;
@@ -784,7 +785,12 @@ int mlx5e_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 #endif
 
 u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
+int mlx5e_create_tir(struct mlx5_core_dev *mdev,
+		     struct mlx5e_tir *tir, u32 *in, int inlen);
+void mlx5e_destroy_tir(struct mlx5_core_dev *mdev,
+		       struct mlx5e_tir *tir);
 int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev);
 void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev);
+int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev);
 
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 3515e78..10f18d4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -93,14 +93,14 @@ static enum mlx5e_traffic_types arfs_get_tt(enum arfs_type type)
 static int arfs_disable(struct mlx5e_priv *priv)
 {
 	struct mlx5_flow_destination dest;
-	u32 *tirn = priv->indir_tirn;
+	struct mlx5e_tir *tir = priv->indir_tir;
 	int err = 0;
 	int tt;
 	int i;
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	for (i = 0; i < ARFS_NUM_TYPES; i++) {
-		dest.tir_num = tirn[i];
+		dest.tir_num = tir[i].tirn;
 		tt = arfs_get_tt(i);
 		/* Modify ttc rules destination to bypass the aRFS tables*/
 		err = mlx5_modify_rule_destination(priv->fs.ttc.rules[tt],
@@ -176,7 +176,7 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	struct arfs_table *arfs_t = &priv->fs.arfs.arfs_tables[type];
 	struct mlx5_flow_destination dest;
 	u8 match_criteria_enable = 0;
-	u32 *tirn = priv->indir_tirn;
+	struct mlx5e_tir *tir = priv->indir_tir;
 	u32 *match_criteria;
 	u32 *match_value;
 	int err = 0;
@@ -192,16 +192,16 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	switch (type) {
 	case ARFS_IPV4_TCP:
-		dest.tir_num = tirn[MLX5E_TT_IPV4_TCP];
+		dest.tir_num = tir[MLX5E_TT_IPV4_TCP].tirn;
 		break;
 	case ARFS_IPV4_UDP:
-		dest.tir_num = tirn[MLX5E_TT_IPV4_UDP];
+		dest.tir_num = tir[MLX5E_TT_IPV4_UDP].tirn;
 		break;
 	case ARFS_IPV6_TCP:
-		dest.tir_num = tirn[MLX5E_TT_IPV6_TCP];
+		dest.tir_num = tir[MLX5E_TT_IPV6_TCP].tirn;
 		break;
 	case ARFS_IPV6_UDP:
-		dest.tir_num = tirn[MLX5E_TT_IPV6_UDP];
+		dest.tir_num = tir[MLX5E_TT_IPV6_UDP].tirn;
 		break;
 	default:
 		err = -EINVAL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index 33b3732..673043c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -36,6 +36,27 @@
  * Global resources are common to all the netdevices crated on the same nic.
  */
 
+int mlx5e_create_tir(struct mlx5_core_dev *mdev,
+		     struct mlx5e_tir *tir, u32 *in, int inlen)
+{
+	int err;
+
+	err = mlx5_core_create_tir(mdev, in, inlen, &tir->tirn);
+	if (err)
+		return err;
+
+	list_add(&tir->list, &mdev->mlx5e_res.td.tirs_list);
+
+	return 0;
+}
+
+void mlx5e_destroy_tir(struct mlx5_core_dev *mdev,
+		       struct mlx5e_tir *tir)
+{
+	mlx5_core_destroy_tir(mdev, tir->tirn);
+	list_del(&tir->list);
+}
+
 static int mlx5e_create_mkey(struct mlx5_core_dev *mdev, u32 pdn,
 			     struct mlx5_core_mkey *mkey)
 {
@@ -89,6 +110,8 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev)
 		goto err_dealloc_transport_domain;
 	}
 
+	INIT_LIST_HEAD(&mdev->mlx5e_res.td.tirs_list);
+
 	return 0;
 
 err_dealloc_transport_domain:
@@ -110,3 +133,28 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_core_dealloc_pd(mdev, res->pdn);
 	mlx5_unmap_free_uar(mdev, &res->cq_uar);
 }
+
+int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev)
+{
+	struct mlx5e_tir *tir;
+	void *in;
+	int inlen;
+	int err;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	MLX5_SET(modify_tir_in, in, bitmask.self_lb_en, 1);
+
+	list_for_each_entry(tir, &mdev->mlx5e_res.td.tirs_list, list) {
+		err = mlx5_core_modify_tir(mdev, tir->tirn, in, inlen);
+		if (err)
+			return err;
+	}
+
+	kvfree(in);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 39a4d96..877cf68 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -876,7 +876,7 @@ static void mlx5e_modify_tirs_hash(struct mlx5e_priv *priv, void *in, int inlen)
 	mlx5e_build_tir_ctx_hash(tirc, priv);
 
 	for (i = 0; i < MLX5E_NUM_INDIR_TIRS; i++)
-		mlx5_core_modify_tir(mdev, priv->indir_tirn[i], in, inlen);
+		mlx5_core_modify_tir(mdev, priv->indir_tir[i].tirn, in, inlen);
 }
 
 static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index b327400..606e69b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -655,7 +655,7 @@ static int mlx5e_generate_ttc_table_rules(struct mlx5e_priv *priv)
 		if (tt == MLX5E_TT_ANY)
 			dest.tir_num = priv->direct_tir[0].tirn;
 		else
-			dest.tir_num = priv->indir_tirn[tt];
+			dest.tir_num = priv->indir_tir[tt].tirn;
 		rules[tt] = mlx5e_generate_ttc_rule(priv, ft, &dest,
 						    ttc_rules[tt].etype,
 						    ttc_rules[tt].proto);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bd3bd61..808dff4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1662,7 +1662,7 @@ static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 	mlx5e_build_tir_ctx_lro(tirc, priv);
 
 	for (tt = 0; tt < MLX5E_NUM_INDIR_TIRS; tt++) {
-		err = mlx5_core_modify_tir(mdev, priv->indir_tirn[tt], in,
+		err = mlx5_core_modify_tir(mdev, priv->indir_tir[tt].tirn, in,
 					   inlen);
 		if (err)
 			goto free_in;
@@ -1681,40 +1681,6 @@ free_in:
 	return err;
 }
 
-static int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5e_priv *priv)
-{
-	void *in;
-	int inlen;
-	int err;
-	int i;
-
-	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
-	in = mlx5_vzalloc(inlen);
-	if (!in)
-		return -ENOMEM;
-
-	MLX5_SET(modify_tir_in, in, bitmask.self_lb_en, 1);
-
-	for (i = 0; i < MLX5E_NUM_INDIR_TIRS; i++) {
-		err = mlx5_core_modify_tir(priv->mdev, priv->indir_tirn[i], in,
-					   inlen);
-		if (err)
-			return err;
-	}
-
-	for (i = 0; i < priv->params.num_channels; i++) {
-		err = mlx5_core_modify_tir(priv->mdev,
-					   priv->direct_tir[i].tirn, in,
-					   inlen);
-		if (err)
-			return err;
-	}
-
-	kvfree(in);
-
-	return 0;
-}
-
 static int mlx5e_set_mtu(struct mlx5e_priv *priv, u16 mtu)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1805,7 +1771,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_clear_state_opened_flag;
 	}
 
-	err = mlx5e_refresh_tirs_self_loopback_enable(priv);
+	err = mlx5e_refresh_tirs_self_loopback_enable(priv->mdev);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_refresh_tirs_self_loopback_enable failed, %d\n",
 			   __func__, err);
@@ -2149,9 +2115,9 @@ static void mlx5e_build_direct_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
 static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 {
 	int nch = mlx5e_get_max_num_channels(priv->mdev);
+	struct mlx5e_tir *tir;
 	void *tirc;
 	int inlen;
-	u32 *tirn;
 	int err;
 	u32 *in;
 	int ix;
@@ -2165,10 +2131,10 @@ static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 	/* indirect tirs */
 	for (tt = 0; tt < MLX5E_NUM_INDIR_TIRS; tt++) {
 		memset(in, 0, inlen);
-		tirn = &priv->indir_tirn[tt];
+		tir = &priv->indir_tir[tt];
 		tirc = MLX5_ADDR_OF(create_tir_in, in, ctx);
 		mlx5e_build_indir_tir_ctx(priv, tirc, tt);
-		err = mlx5_core_create_tir(priv->mdev, in, inlen, tirn);
+		err = mlx5e_create_tir(priv->mdev, tir, in, inlen);
 		if (err)
 			goto err_destroy_tirs;
 	}
@@ -2176,11 +2142,11 @@ static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 	/* direct tirs */
 	for (ix = 0; ix < nch; ix++) {
 		memset(in, 0, inlen);
-		tirn = &priv->direct_tir[ix].tirn;
+		tir = &priv->direct_tir[ix];
 		tirc = MLX5_ADDR_OF(create_tir_in, in, ctx);
 		mlx5e_build_direct_tir_ctx(priv, tirc,
 					   priv->direct_tir[ix].rqtn);
-		err = mlx5_core_create_tir(priv->mdev, in, inlen, tirn);
+		err = mlx5e_create_tir(priv->mdev, tir, in, inlen);
 		if (err)
 			goto err_destroy_ch_tirs;
 	}
@@ -2191,11 +2157,11 @@ static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 
 err_destroy_ch_tirs:
 	for (ix--; ix >= 0; ix--)
-		mlx5_core_destroy_tir(priv->mdev, priv->direct_tir[ix].tirn);
+		mlx5e_destroy_tir(priv->mdev, &priv->direct_tir[ix]);
 
 err_destroy_tirs:
 	for (tt--; tt >= 0; tt--)
-		mlx5_core_destroy_tir(priv->mdev, priv->indir_tirn[tt]);
+		mlx5e_destroy_tir(priv->mdev, &priv->indir_tir[tt]);
 
 	kvfree(in);
 
@@ -2208,10 +2174,10 @@ static void mlx5e_destroy_tirs(struct mlx5e_priv *priv)
 	int i;
 
 	for (i = 0; i < nch; i++)
-		mlx5_core_destroy_tir(priv->mdev, priv->direct_tir[i].tirn);
+		mlx5e_destroy_tir(priv->mdev, &priv->direct_tir[i]);
 
 	for (i = 0; i < MLX5E_NUM_INDIR_TIRS; i++)
-		mlx5_core_destroy_tir(priv->mdev, priv->indir_tirn[i]);
+		mlx5e_destroy_tir(priv->mdev, &priv->indir_tir[i]);
 }
 
 int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd)
-- 
2.8.0
