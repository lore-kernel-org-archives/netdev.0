From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 04/12] net/mlx5: Support for attaching multiple underlay QPs to root flow table
Date: Sat, 14 Oct 2017 11:48:19 -0700
Message-ID: <20171014184827.18491-5-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43244 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751619AbdJNSsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:47 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Previous support allowed connecting only a single QPN to the FT.
Now using a linked list multiple QPNs can be attached to the same FT.

Supporting attaching multiple underlay QPs is required for PKEY
support in which child and parent share the same FT.

The actual attaching/detaching FW commands will be called inside the
function symmetrically.

This change requires a change in IPoIB open and close functions, the
attaching/detaching to/from the FT is done each time we open/close.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  13 ++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 123 ++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   7 +-
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  |  78 +++++++------
 5 files changed, 171 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 36ecc2b2e187..881e2e55840c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -40,7 +40,8 @@
 #include "eswitch.h"
 
 int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
-			    struct mlx5_flow_table *ft, u32 underlay_qpn)
+			    struct mlx5_flow_table *ft, u32 underlay_qpn,
+			    bool disconnect)
 {
 	u32 in[MLX5_ST_SZ_DW(set_flow_table_root_in)]   = {0};
 	u32 out[MLX5_ST_SZ_DW(set_flow_table_root_out)] = {0};
@@ -52,7 +53,15 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 	MLX5_SET(set_flow_table_root_in, in, opcode,
 		 MLX5_CMD_OP_SET_FLOW_TABLE_ROOT);
 	MLX5_SET(set_flow_table_root_in, in, table_type, ft->type);
-	MLX5_SET(set_flow_table_root_in, in, table_id, ft->id);
+
+	if (disconnect) {
+		MLX5_SET(set_flow_table_root_in, in, op_mod, 1);
+		MLX5_SET(set_flow_table_root_in, in, table_id, 0);
+	} else {
+		MLX5_SET(set_flow_table_root_in, in, op_mod, 0);
+		MLX5_SET(set_flow_table_root_in, in, table_id, ft->id);
+	}
+
 	MLX5_SET(set_flow_table_root_in, in, underlay_qpn, underlay_qpn);
 	if (ft->vport) {
 		MLX5_SET(set_flow_table_root_in, in, vport_number, ft->vport);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index c6d7bdf255b6..71e2d0f37ad9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -71,8 +71,8 @@ int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
 			unsigned int index);
 
 int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
-			    struct mlx5_flow_table *ft,
-			    u32 underlay_qpn);
+			    struct mlx5_flow_table *ft, u32 underlay_qpn,
+			    bool disconnect);
 
 int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u32 *id);
 int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u32 id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 5a7bea688ec8..8a1a7ba9fe53 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -693,8 +693,10 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 				 *prio)
 {
 	struct mlx5_flow_root_namespace *root = find_root(&prio->node);
+	struct mlx5_ft_underlay_qp *uqp;
 	int min_level = INT_MAX;
 	int err;
+	u32 qpn;
 
 	if (root->root_ft)
 		min_level = root->root_ft->level;
@@ -702,10 +704,24 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 	if (ft->level >= min_level)
 		return 0;
 
-	err = mlx5_cmd_update_root_ft(root->dev, ft, root->underlay_qpn);
+	if (list_empty(&root->underlay_qpns)) {
+		/* Don't set any QPN (zero) in case QPN list is empty */
+		qpn = 0;
+		err = mlx5_cmd_update_root_ft(root->dev, ft, qpn, false);
+	} else {
+		list_for_each_entry(uqp, &root->underlay_qpns, list) {
+			qpn = uqp->qpn;
+			err = mlx5_cmd_update_root_ft(root->dev, ft, qpn,
+						      false);
+			if (err)
+				break;
+		}
+	}
+
 	if (err)
-		mlx5_core_warn(root->dev, "Update root flow table of id=%u failed\n",
-			       ft->id);
+		mlx5_core_warn(root->dev,
+			       "Update root flow table of id(%u) qpn(%d) failed\n",
+			       ft->id, qpn);
 	else
 		root->root_ft = ft;
 
@@ -1661,23 +1677,43 @@ static struct mlx5_flow_table *find_next_ft(struct mlx5_flow_table *ft)
 static int update_root_ft_destroy(struct mlx5_flow_table *ft)
 {
 	struct mlx5_flow_root_namespace *root = find_root(&ft->node);
+	struct mlx5_ft_underlay_qp *uqp;
 	struct mlx5_flow_table *new_root_ft = NULL;
+	int err = 0;
+	u32 qpn;
 
 	if (root->root_ft != ft)
 		return 0;
 
 	new_root_ft = find_next_ft(ft);
-	if (new_root_ft) {
-		int err = mlx5_cmd_update_root_ft(root->dev, new_root_ft,
-						  root->underlay_qpn);
 
-		if (err) {
-			mlx5_core_warn(root->dev, "Update root flow table of id=%u failed\n",
-				       ft->id);
-			return err;
+	if (!new_root_ft) {
+		root->root_ft = NULL;
+		return 0;
+	}
+
+	if (list_empty(&root->underlay_qpns)) {
+		/* Don't set any QPN (zero) in case QPN list is empty */
+		qpn = 0;
+		err = mlx5_cmd_update_root_ft(root->dev, new_root_ft, qpn,
+					      false);
+	} else {
+		list_for_each_entry(uqp, &root->underlay_qpns, list) {
+			qpn = uqp->qpn;
+			err = mlx5_cmd_update_root_ft(root->dev, new_root_ft,
+						      qpn, false);
+			if (err)
+				break;
 		}
 	}
-	root->root_ft = new_root_ft;
+
+	if (err)
+		mlx5_core_warn(root->dev,
+			       "Update root flow table of id(%u) qpn(%d) failed\n",
+			       ft->id, qpn);
+	else
+		root->root_ft = new_root_ft;
+
 	return 0;
 }
 
@@ -1965,6 +2001,8 @@ static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_flow_steering
 	root_ns->dev = steering->dev;
 	root_ns->table_type = table_type;
 
+	INIT_LIST_HEAD(&root_ns->underlay_qpns);
+
 	ns = &root_ns->ns;
 	fs_init_namespace(ns);
 	mutex_init(&root_ns->chain_lock);
@@ -2245,17 +2283,76 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 int mlx5_fs_add_rx_underlay_qpn(struct mlx5_core_dev *dev, u32 underlay_qpn)
 {
 	struct mlx5_flow_root_namespace *root = dev->priv.steering->root_ns;
+	struct mlx5_ft_underlay_qp *new_uqp;
+	int err = 0;
+
+	new_uqp = kzalloc(sizeof(*new_uqp), GFP_KERNEL);
+	if (!new_uqp)
+		return -ENOMEM;
+
+	mutex_lock(&root->chain_lock);
+
+	if (!root->root_ft) {
+		err = -EINVAL;
+		goto update_ft_fail;
+	}
+
+	err = mlx5_cmd_update_root_ft(dev, root->root_ft, underlay_qpn, false);
+	if (err) {
+		mlx5_core_warn(dev, "Failed adding underlay QPN (%u) to root FT err(%d)\n",
+			       underlay_qpn, err);
+		goto update_ft_fail;
+	}
+
+	new_uqp->qpn = underlay_qpn;
+	list_add_tail(&new_uqp->list, &root->underlay_qpns);
+
+	mutex_unlock(&root->chain_lock);
 
-	root->underlay_qpn = underlay_qpn;
 	return 0;
+
+update_ft_fail:
+	mutex_unlock(&root->chain_lock);
+	kfree(new_uqp);
+	return err;
 }
 EXPORT_SYMBOL(mlx5_fs_add_rx_underlay_qpn);
 
 int mlx5_fs_remove_rx_underlay_qpn(struct mlx5_core_dev *dev, u32 underlay_qpn)
 {
 	struct mlx5_flow_root_namespace *root = dev->priv.steering->root_ns;
+	struct mlx5_ft_underlay_qp *uqp;
+	bool found = false;
+	int err = 0;
+
+	mutex_lock(&root->chain_lock);
+	list_for_each_entry(uqp, &root->underlay_qpns, list) {
+		if (uqp->qpn == underlay_qpn) {
+			found = true;
+			break;
+		}
+	}
+
+	if (!found) {
+		mlx5_core_warn(dev, "Failed finding underlay qp (%u) in qpn list\n",
+			       underlay_qpn);
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = mlx5_cmd_update_root_ft(dev, root->root_ft, underlay_qpn, true);
+	if (err)
+		mlx5_core_warn(dev, "Failed removing underlay QPN (%u) from root FT err(%d)\n",
+			       underlay_qpn, err);
+
+	list_del(&uqp->list);
+	mutex_unlock(&root->chain_lock);
+	kfree(uqp);
 
-	root->underlay_qpn = 0;
 	return 0;
+
+out:
+	mutex_unlock(&root->chain_lock);
+	return err;
 }
 EXPORT_SYMBOL(mlx5_fs_remove_rx_underlay_qpn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 48dd78975062..9bc048a89bc0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -147,6 +147,11 @@ struct mlx5_fc {
 	struct mlx5_fc_cache cache ____cacheline_aligned_in_smp;
 };
 
+struct mlx5_ft_underlay_qp {
+	struct list_head list;
+	u32 qpn;
+};
+
 #define MLX5_FTE_MATCH_PARAM_RESERVED	reserved_at_600
 /* Calculate the fte_match_param length and without the reserved length.
  * Make sure the reserved field is the last.
@@ -212,7 +217,7 @@ struct mlx5_flow_root_namespace {
 	struct mlx5_flow_table		*root_ft;
 	/* Should be held when chaining flow tables */
 	struct mutex			chain_lock;
-	u32				underlay_qpn;
+	struct list_head		underlay_qpns;
 };
 
 int mlx5_init_fc_stats(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index feb94db6b921..00f0e6a038bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -218,12 +218,6 @@ static int mlx5i_init_tx(struct mlx5e_priv *priv)
 		return err;
 	}
 
-	err = mlx5i_init_underlay_qp(priv);
-	if (err) {
-		mlx5_core_warn(priv->mdev, "intilize underlay QP failed, %d\n", err);
-		goto err_destroy_underlay_qp;
-	}
-
 	err = mlx5e_create_tis(priv->mdev, 0 /* tc */, ipriv->qp.qpn, &priv->tisn[0]);
 	if (err) {
 		mlx5_core_warn(priv->mdev, "create tis failed, %d\n", err);
@@ -285,7 +279,6 @@ static void mlx5i_destroy_flow_steering(struct mlx5e_priv *priv)
 
 static int mlx5i_init_rx(struct mlx5e_priv *priv)
 {
-	struct mlx5i_priv *ipriv  = priv->ppriv;
 	int err;
 
 	err = mlx5e_create_indirect_rqt(priv);
@@ -304,18 +297,12 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 	if (err)
 		goto err_destroy_indirect_tirs;
 
-	err = mlx5_fs_add_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
-	if (err)
-		goto err_destroy_direct_tirs;
-
 	err = mlx5i_create_flow_steering(priv);
 	if (err)
-		goto err_remove_rx_underlay_qpn;
+		goto err_destroy_direct_tirs;
 
 	return 0;
 
-err_remove_rx_underlay_qpn:
-	mlx5_fs_remove_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_indirect_tirs:
@@ -329,9 +316,6 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 
 static void mlx5i_cleanup_rx(struct mlx5e_priv *priv)
 {
-	struct mlx5i_priv *ipriv  = priv->ppriv;
-
-	mlx5_fs_remove_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
 	mlx5i_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
@@ -423,49 +407,71 @@ static void mlx5i_dev_cleanup(struct net_device *dev)
 
 static int mlx5i_open(struct net_device *netdev)
 {
-	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+	struct mlx5e_priv *epriv = mlx5i_epriv(netdev);
+	struct mlx5i_priv *ipriv = epriv->ppriv;
+	struct mlx5_core_dev *mdev = epriv->mdev;
 	int err;
 
-	mutex_lock(&priv->state_lock);
+	mutex_lock(&epriv->state_lock);
 
-	set_bit(MLX5E_STATE_OPENED, &priv->state);
+	set_bit(MLX5E_STATE_OPENED, &epriv->state);
 
-	err = mlx5e_open_channels(priv, &priv->channels);
-	if (err)
+	err = mlx5i_init_underlay_qp(epriv);
+	if (err) {
+		mlx5_core_warn(mdev, "prepare underlay qp state failed, %d\n", err);
 		goto err_clear_state_opened_flag;
+	}
 
-	mlx5e_refresh_tirs(priv, false);
-	mlx5e_activate_priv_channels(priv);
-	mlx5e_timestamp_set(priv);
+	err = mlx5_fs_add_rx_underlay_qpn(mdev, ipriv->qp.qpn);
+	if (err) {
+		mlx5_core_warn(mdev, "attach underlay qp to ft failed, %d\n", err);
+		goto err_reset_qp;
+	}
 
-	mutex_unlock(&priv->state_lock);
+	err = mlx5e_open_channels(epriv, &epriv->channels);
+	if (err)
+		goto err_remove_fs_underlay_qp;
+
+	mlx5e_refresh_tirs(epriv, false);
+	mlx5e_activate_priv_channels(epriv);
+	mlx5e_timestamp_set(epriv);
+
+	mutex_unlock(&epriv->state_lock);
 	return 0;
 
+err_remove_fs_underlay_qp:
+	mlx5_fs_remove_rx_underlay_qpn(mdev, ipriv->qp.qpn);
+err_reset_qp:
+	mlx5i_uninit_underlay_qp(epriv);
 err_clear_state_opened_flag:
-	clear_bit(MLX5E_STATE_OPENED, &priv->state);
-	mutex_unlock(&priv->state_lock);
+	clear_bit(MLX5E_STATE_OPENED, &epriv->state);
+	mutex_unlock(&epriv->state_lock);
 	return err;
 }
 
 static int mlx5i_close(struct net_device *netdev)
 {
-	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+	struct mlx5e_priv *epriv = mlx5i_epriv(netdev);
+	struct mlx5i_priv *ipriv = epriv->ppriv;
+	struct mlx5_core_dev *mdev = epriv->mdev;
 
 	/* May already be CLOSED in case a previous configuration operation
 	 * (e.g RX/TX queue size change) that involves close&open failed.
 	 */
-	mutex_lock(&priv->state_lock);
+	mutex_lock(&epriv->state_lock);
 
-	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+	if (!test_bit(MLX5E_STATE_OPENED, &epriv->state))
 		goto unlock;
 
-	clear_bit(MLX5E_STATE_OPENED, &priv->state);
+	clear_bit(MLX5E_STATE_OPENED, &epriv->state);
 
-	netif_carrier_off(priv->netdev);
-	mlx5e_deactivate_priv_channels(priv);
-	mlx5e_close_channels(&priv->channels);
+	netif_carrier_off(epriv->netdev);
+	mlx5_fs_remove_rx_underlay_qpn(mdev, ipriv->qp.qpn);
+	mlx5i_uninit_underlay_qp(epriv);
+	mlx5e_deactivate_priv_channels(epriv);
+	mlx5e_close_channels(&epriv->channels);;
 unlock:
-	mutex_unlock(&priv->state_lock);
+	mutex_unlock(&epriv->state_lock);
 	return 0;
 }
 
-- 
2.14.2
