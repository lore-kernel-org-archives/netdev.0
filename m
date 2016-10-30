From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 13/15] net/mlx5: Add multi dest support
Date: Sun, 30 Oct 2016 23:22:06 +0200
Message-ID: <1477862528-4328-14-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Currently when calling mlx5_add_flow_rule we accept
only one flow destination, this commit allows to pass
multiple destinations.

This change forces us to change the return structure to a more
flexible one. We introduce a flow handle (struct mlx5_flow_handle),
it holds internally the number for rules created and holds an array
where each cell points the to a flow rule.

>From the consumers (of mlx5_add_flow_rule) point of view this
change is only cosmetic and requires only to change the type
of the returned value they store.

>From the core point of view, we now need to use a loop when
allocating and deleting rules (e.g given to us a flow handler).

Signed-off-by: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c                  |  14 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  38 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  49 ++--
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  32 +--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  68 ++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  22 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  42 +--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 289 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   5 +
 include/linux/mlx5/fs.h                            |  28 +-
 14 files changed, 374 insertions(+), 254 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d02341e..8e0dbd5 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1771,13 +1771,13 @@ static int mlx5_ib_destroy_flow(struct ib_flow *flow_id)
 	mutex_lock(&dev->flow_db.lock);
 
 	list_for_each_entry_safe(iter, tmp, &handler->list, list) {
-		mlx5_del_flow_rule(iter->rule);
+		mlx5_del_flow_rules(iter->rule);
 		put_flow_table(dev, iter->prio, true);
 		list_del(&iter->list);
 		kfree(iter);
 	}
 
-	mlx5_del_flow_rule(handler->rule);
+	mlx5_del_flow_rules(handler->rule);
 	put_flow_table(dev, handler->prio, true);
 	mutex_unlock(&dev->flow_db.lock);
 
@@ -1907,10 +1907,10 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	spec->match_criteria_enable = get_match_criteria_enable(spec->match_criteria);
 	action = dst ? MLX5_FLOW_CONTEXT_ACTION_FWD_DEST :
 		MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
-	handler->rule = mlx5_add_flow_rule(ft, spec,
+	handler->rule = mlx5_add_flow_rules(ft, spec,
 					   action,
 					   MLX5_FS_DEFAULT_FLOW_TAG,
-					   dst);
+					   dst, 1);
 
 	if (IS_ERR(handler->rule)) {
 		err = PTR_ERR(handler->rule);
@@ -1941,7 +1941,7 @@ static struct mlx5_ib_flow_handler *create_dont_trap_rule(struct mlx5_ib_dev *de
 		handler_dst = create_flow_rule(dev, ft_prio,
 					       flow_attr, dst);
 		if (IS_ERR(handler_dst)) {
-			mlx5_del_flow_rule(handler->rule);
+			mlx5_del_flow_rules(handler->rule);
 			ft_prio->refcount--;
 			kfree(handler);
 			handler = handler_dst;
@@ -2004,7 +2004,7 @@ static struct mlx5_ib_flow_handler *create_leftovers_rule(struct mlx5_ib_dev *de
 						 &leftovers_specs[LEFTOVERS_UC].flow_attr,
 						 dst);
 		if (IS_ERR(handler_ucast)) {
-			mlx5_del_flow_rule(handler->rule);
+			mlx5_del_flow_rules(handler->rule);
 			ft_prio->refcount--;
 			kfree(handler);
 			handler = handler_ucast;
@@ -2046,7 +2046,7 @@ static struct mlx5_ib_flow_handler *create_sniffer_rule(struct mlx5_ib_dev *dev,
 	return handler_rx;
 
 err_tx:
-	mlx5_del_flow_rule(handler_rx->rule);
+	mlx5_del_flow_rules(handler_rx->rule);
 	ft_rx->refcount--;
 	kfree(handler_rx);
 err:
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index dcdcd19..d5d0077 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -153,7 +153,7 @@ struct mlx5_ib_flow_handler {
 	struct list_head		list;
 	struct ib_flow			ibflow;
 	struct mlx5_ib_flow_prio	*prio;
-	struct mlx5_flow_rule	*rule;
+	struct mlx5_flow_handle		*rule;
 };
 
 struct mlx5_ib_flow_db {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 460363b..47ee8ff 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -520,7 +520,7 @@ struct mlx5e_vxlan_db {
 
 struct mlx5e_l2_rule {
 	u8  addr[ETH_ALEN + 2];
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 };
 
 struct mlx5e_flow_table {
@@ -541,10 +541,10 @@ struct mlx5e_tc_table {
 struct mlx5e_vlan_table {
 	struct mlx5e_flow_table		ft;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-	struct mlx5_flow_rule	*active_vlans_rule[VLAN_N_VID];
-	struct mlx5_flow_rule	*untagged_rule;
-	struct mlx5_flow_rule	*any_vlan_rule;
-	bool          filter_disabled;
+	struct mlx5_flow_handle	*active_vlans_rule[VLAN_N_VID];
+	struct mlx5_flow_handle	*untagged_rule;
+	struct mlx5_flow_handle	*any_vlan_rule;
+	bool		filter_disabled;
 };
 
 struct mlx5e_l2_table {
@@ -562,14 +562,14 @@ struct mlx5e_l2_table {
 /* L3/L4 traffic type classifier */
 struct mlx5e_ttc_table {
 	struct mlx5e_flow_table  ft;
-	struct mlx5_flow_rule	 *rules[MLX5E_NUM_TT];
+	struct mlx5_flow_handle	 *rules[MLX5E_NUM_TT];
 };
 
 #define ARFS_HASH_SHIFT BITS_PER_BYTE
 #define ARFS_HASH_SIZE BIT(BITS_PER_BYTE)
 struct arfs_table {
 	struct mlx5e_flow_table  ft;
-	struct mlx5_flow_rule    *default_rule;
+	struct mlx5_flow_handle	 *default_rule;
 	struct hlist_head	 rules_hash[ARFS_HASH_SIZE];
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index a8cb387..8ff22e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -56,7 +56,7 @@ struct arfs_tuple {
 struct arfs_rule {
 	struct mlx5e_priv	*priv;
 	struct work_struct      arfs_work;
-	struct mlx5_flow_rule   *rule;
+	struct mlx5_flow_handle *rule;
 	struct hlist_node	hlist;
 	int			rxq;
 	/* Flow ID passed to ndo_rx_flow_steer */
@@ -104,7 +104,7 @@ static int arfs_disable(struct mlx5e_priv *priv)
 		tt = arfs_get_tt(i);
 		/* Modify ttc rules destination to bypass the aRFS tables*/
 		err = mlx5_modify_rule_destination(priv->fs.ttc.rules[tt],
-						   &dest);
+						   &dest, NULL);
 		if (err) {
 			netdev_err(priv->netdev,
 				   "%s: modify ttc destination failed\n",
@@ -137,7 +137,7 @@ int mlx5e_arfs_enable(struct mlx5e_priv *priv)
 		tt = arfs_get_tt(i);
 		/* Modify ttc rules destination to point on the aRFS FTs */
 		err = mlx5_modify_rule_destination(priv->fs.ttc.rules[tt],
-						   &dest);
+						   &dest, NULL);
 		if (err) {
 			netdev_err(priv->netdev,
 				   "%s: modify ttc destination failed err=%d\n",
@@ -151,7 +151,7 @@ int mlx5e_arfs_enable(struct mlx5e_priv *priv)
 
 static void arfs_destroy_table(struct arfs_table *arfs_t)
 {
-	mlx5_del_flow_rule(arfs_t->default_rule);
+	mlx5_del_flow_rules(arfs_t->default_rule);
 	mlx5e_destroy_flow_table(&arfs_t->ft);
 }
 
@@ -205,10 +205,10 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 		goto out;
 	}
 
-	arfs_t->default_rule = mlx5_add_flow_rule(arfs_t->ft.t, spec,
-						  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-						  MLX5_FS_DEFAULT_FLOW_TAG,
-						  &dest);
+	arfs_t->default_rule = mlx5_add_flow_rules(arfs_t->ft.t, spec,
+						   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+						   MLX5_FS_DEFAULT_FLOW_TAG,
+						   &dest, 1);
 	if (IS_ERR(arfs_t->default_rule)) {
 		err = PTR_ERR(arfs_t->default_rule);
 		arfs_t->default_rule = NULL;
@@ -396,7 +396,7 @@ static void arfs_may_expire_flow(struct mlx5e_priv *priv)
 	spin_unlock_bh(&priv->fs.arfs.arfs_lock);
 	hlist_for_each_entry_safe(arfs_rule, htmp, &del_list, hlist) {
 		if (arfs_rule->rule)
-			mlx5_del_flow_rule(arfs_rule->rule);
+			mlx5_del_flow_rules(arfs_rule->rule);
 		hlist_del(&arfs_rule->hlist);
 		kfree(arfs_rule);
 	}
@@ -420,7 +420,7 @@ static void arfs_del_rules(struct mlx5e_priv *priv)
 	hlist_for_each_entry_safe(rule, htmp, &del_list, hlist) {
 		cancel_work_sync(&rule->arfs_work);
 		if (rule->rule)
-			mlx5_del_flow_rule(rule->rule);
+			mlx5_del_flow_rules(rule->rule);
 		hlist_del(&rule->hlist);
 		kfree(rule);
 	}
@@ -462,12 +462,12 @@ static struct arfs_table *arfs_get_table(struct mlx5e_arfs_tables *arfs,
 	return NULL;
 }
 
-static struct mlx5_flow_rule *arfs_add_rule(struct mlx5e_priv *priv,
-					    struct arfs_rule *arfs_rule)
+static struct mlx5_flow_handle *arfs_add_rule(struct mlx5e_priv *priv,
+					      struct arfs_rule *arfs_rule)
 {
 	struct mlx5e_arfs_tables *arfs = &priv->fs.arfs;
 	struct arfs_tuple *tuple = &arfs_rule->tuple;
-	struct mlx5_flow_rule *rule = NULL;
+	struct mlx5_flow_handle *rule = NULL;
 	struct mlx5_flow_destination dest;
 	struct arfs_table *arfs_table;
 	struct mlx5_flow_spec *spec;
@@ -544,9 +544,9 @@ static struct mlx5_flow_rule *arfs_add_rule(struct mlx5e_priv *priv,
 	}
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dest.tir_num = priv->direct_tir[arfs_rule->rxq].tirn;
-	rule = mlx5_add_flow_rule(ft, spec, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				  MLX5_FS_DEFAULT_FLOW_TAG,
-				  &dest);
+	rule = mlx5_add_flow_rules(ft, spec, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+				   MLX5_FS_DEFAULT_FLOW_TAG,
+				   &dest, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule(filter id=%d, rq idx=%d) failed, err=%d\n",
@@ -559,14 +559,14 @@ static struct mlx5_flow_rule *arfs_add_rule(struct mlx5e_priv *priv,
 }
 
 static void arfs_modify_rule_rq(struct mlx5e_priv *priv,
-				struct mlx5_flow_rule *rule, u16 rxq)
+				struct mlx5_flow_handle *rule, u16 rxq)
 {
 	struct mlx5_flow_destination dst;
 	int err = 0;
 
 	dst.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dst.tir_num = priv->direct_tir[rxq].tirn;
-	err =  mlx5_modify_rule_destination(rule, &dst);
+	err =  mlx5_modify_rule_destination(rule, &dst, NULL);
 	if (err)
 		netdev_warn(priv->netdev,
 			    "Failed to modfiy aRFS rule destination to rq=%d\n", rxq);
@@ -578,7 +578,7 @@ static void arfs_handle_work(struct work_struct *work)
 						   struct arfs_rule,
 						   arfs_work);
 	struct mlx5e_priv *priv = arfs_rule->priv;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 
 	mutex_lock(&priv->state_lock);
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 36fbc6b..bed544d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -160,7 +160,7 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 {
 	struct mlx5_flow_table *ft = priv->fs.vlan.ft.t;
 	struct mlx5_flow_destination dest;
-	struct mlx5_flow_rule **rule_p;
+	struct mlx5_flow_handle **rule_p;
 	int err = 0;
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
@@ -187,10 +187,10 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	*rule_p = mlx5_add_flow_rule(ft, spec,
-				     MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				     MLX5_FS_DEFAULT_FLOW_TAG,
-				     &dest);
+	*rule_p = mlx5_add_flow_rules(ft, spec,
+				      MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+				      MLX5_FS_DEFAULT_FLOW_TAG,
+				      &dest, 1);
 
 	if (IS_ERR(*rule_p)) {
 		err = PTR_ERR(*rule_p);
@@ -229,20 +229,20 @@ static void mlx5e_del_vlan_rule(struct mlx5e_priv *priv,
 	switch (rule_type) {
 	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
 		if (priv->fs.vlan.untagged_rule) {
-			mlx5_del_flow_rule(priv->fs.vlan.untagged_rule);
+			mlx5_del_flow_rules(priv->fs.vlan.untagged_rule);
 			priv->fs.vlan.untagged_rule = NULL;
 		}
 		break;
 	case MLX5E_VLAN_RULE_TYPE_ANY_VID:
 		if (priv->fs.vlan.any_vlan_rule) {
-			mlx5_del_flow_rule(priv->fs.vlan.any_vlan_rule);
+			mlx5_del_flow_rules(priv->fs.vlan.any_vlan_rule);
 			priv->fs.vlan.any_vlan_rule = NULL;
 		}
 		break;
 	case MLX5E_VLAN_RULE_TYPE_MATCH_VID:
 		mlx5e_vport_context_update_vlans(priv);
 		if (priv->fs.vlan.active_vlans_rule[vid]) {
-			mlx5_del_flow_rule(priv->fs.vlan.active_vlans_rule[vid]);
+			mlx5_del_flow_rules(priv->fs.vlan.active_vlans_rule[vid]);
 			priv->fs.vlan.active_vlans_rule[vid] = NULL;
 		}
 		mlx5e_vport_context_update_vlans(priv);
@@ -560,7 +560,7 @@ static void mlx5e_cleanup_ttc_rules(struct mlx5e_ttc_table *ttc)
 
 	for (i = 0; i < MLX5E_NUM_TT; i++) {
 		if (!IS_ERR_OR_NULL(ttc->rules[i])) {
-			mlx5_del_flow_rule(ttc->rules[i]);
+			mlx5_del_flow_rules(ttc->rules[i]);
 			ttc->rules[i] = NULL;
 		}
 	}
@@ -616,13 +616,14 @@ static struct {
 	},
 };
 
-static struct mlx5_flow_rule *mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
-						      struct mlx5_flow_table *ft,
-						      struct mlx5_flow_destination *dest,
-						      u16 etype,
-						      u8 proto)
+static struct mlx5_flow_handle *
+mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
+			struct mlx5_flow_table *ft,
+			struct mlx5_flow_destination *dest,
+			u16 etype,
+			u8 proto)
 {
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
@@ -643,10 +644,10 @@ static struct mlx5_flow_rule *mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_param, spec->match_value, outer_headers.ethertype, etype);
 	}
 
-	rule = mlx5_add_flow_rule(ft, spec,
-				  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				  MLX5_FS_DEFAULT_FLOW_TAG,
-				  dest);
+	rule = mlx5_add_flow_rules(ft, spec,
+				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+				   MLX5_FS_DEFAULT_FLOW_TAG,
+				   dest, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: add rule failed\n", __func__);
@@ -660,7 +661,7 @@ static int mlx5e_generate_ttc_table_rules(struct mlx5e_priv *priv)
 {
 	struct mlx5_flow_destination dest;
 	struct mlx5e_ttc_table *ttc;
-	struct mlx5_flow_rule **rules;
+	struct mlx5_flow_handle **rules;
 	struct mlx5_flow_table *ft;
 	int tt;
 	int err;
@@ -801,7 +802,7 @@ static void mlx5e_del_l2_flow_rule(struct mlx5e_priv *priv,
 				   struct mlx5e_l2_rule *ai)
 {
 	if (!IS_ERR_OR_NULL(ai->rule)) {
-		mlx5_del_flow_rule(ai->rule);
+		mlx5_del_flow_rules(ai->rule);
 		ai->rule = NULL;
 	}
 }
@@ -847,9 +848,9 @@ static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 		break;
 	}
 
-	ai->rule = mlx5_add_flow_rule(ft, spec,
-				      MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				      MLX5_FS_DEFAULT_FLOW_TAG, &dest);
+	ai->rule = mlx5_add_flow_rules(ft, spec,
+				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+				       MLX5_FS_DEFAULT_FLOW_TAG, &dest, 1);
 	if (IS_ERR(ai->rule)) {
 		netdev_err(priv->netdev, "%s: add l2 rule(mac:%pM) failed\n",
 			   __func__, mv_dmac);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d17c242..cf52c06 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -36,7 +36,7 @@
 struct mlx5e_ethtool_rule {
 	struct list_head             list;
 	struct ethtool_rx_flow_spec  flow_spec;
-	struct mlx5_flow_rule        *rule;
+	struct mlx5_flow_handle	     *rule;
 	struct mlx5e_ethtool_table   *eth_ft;
 };
 
@@ -284,13 +284,14 @@ static bool outer_header_zero(u32 *match_criteria)
 						  size - 1);
 }
 
-static struct mlx5_flow_rule *add_ethtool_flow_rule(struct mlx5e_priv *priv,
-						    struct mlx5_flow_table *ft,
-						    struct ethtool_rx_flow_spec *fs)
+static struct mlx5_flow_handle *
+add_ethtool_flow_rule(struct mlx5e_priv *priv,
+		      struct mlx5_flow_table *ft,
+		      struct ethtool_rx_flow_spec *fs)
 {
 	struct mlx5_flow_destination *dst = NULL;
 	struct mlx5_flow_spec *spec;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 	int err = 0;
 	u32 action;
 
@@ -317,8 +318,8 @@ static struct mlx5_flow_rule *add_ethtool_flow_rule(struct mlx5e_priv *priv,
 	}
 
 	spec->match_criteria_enable = (!outer_header_zero(spec->match_criteria));
-	rule = mlx5_add_flow_rule(ft, spec, action,
-				  MLX5_FS_DEFAULT_FLOW_TAG, dst);
+	rule = mlx5_add_flow_rules(ft, spec, action,
+				   MLX5_FS_DEFAULT_FLOW_TAG, dst, 1);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: failed to add ethtool steering rule: %d\n",
@@ -335,7 +336,7 @@ static void del_ethtool_rule(struct mlx5e_priv *priv,
 			     struct mlx5e_ethtool_rule *eth_rule)
 {
 	if (eth_rule->rule)
-		mlx5_del_flow_rule(eth_rule->rule);
+		mlx5_del_flow_rules(eth_rule->rule);
 	list_del(&eth_rule->list);
 	priv->fs.ethtool.tot_num_rules--;
 	put_flow_table(eth_rule->eth_ft);
@@ -475,7 +476,7 @@ int mlx5e_ethtool_flow_replace(struct mlx5e_priv *priv,
 {
 	struct mlx5e_ethtool_table *eth_ft;
 	struct mlx5e_ethtool_rule *eth_rule;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 	int num_tuples;
 	int err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 3c97da1..88d3fd1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -328,7 +328,7 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5_flow_rule *flow_rule;
+	struct mlx5_flow_handle *flow_rule;
 	int err;
 	int i;
 
@@ -360,7 +360,7 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 	return 0;
 
 err_del_flow_rule:
-	mlx5_del_flow_rule(rep->vport_rx_rule);
+	mlx5_del_flow_rules(rep->vport_rx_rule);
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_direct_rqts:
@@ -375,7 +375,7 @@ static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 	int i;
 
 	mlx5e_tc_cleanup(priv);
-	mlx5_del_flow_rule(rep->vport_rx_rule);
+	mlx5_del_flow_rules(rep->vport_rx_rule);
 	mlx5e_destroy_direct_tirs(priv);
 	for (i = 0; i < priv->params.num_channels; i++)
 		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index ce8c54d..5d9ac0d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -47,21 +47,22 @@
 struct mlx5e_tc_flow {
 	struct rhash_head	node;
 	u64			cookie;
-	struct mlx5_flow_rule	*rule;
+	struct mlx5_flow_handle *rule;
 	struct mlx5_esw_flow_attr *attr;
 };
 
 #define MLX5E_TC_TABLE_NUM_ENTRIES 1024
 #define MLX5E_TC_TABLE_NUM_GROUPS 4
 
-static struct mlx5_flow_rule *mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
-						    struct mlx5_flow_spec *spec,
-						    u32 action, u32 flow_tag)
+static struct mlx5_flow_handle *
+mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
+		      struct mlx5_flow_spec *spec,
+		      u32 action, u32 flow_tag)
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_flow_destination dest = { 0 };
 	struct mlx5_fc *counter = NULL;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 	bool table_created = false;
 
 	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
@@ -94,9 +95,9 @@ static struct mlx5_flow_rule *mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	}
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	rule = mlx5_add_flow_rule(priv->fs.tc.t, spec,
-				  action, flow_tag,
-				  &dest);
+	rule = mlx5_add_flow_rules(priv->fs.tc.t, spec,
+				   action, flow_tag,
+				   &dest, 1);
 
 	if (IS_ERR(rule))
 		goto err_add_rule;
@@ -114,9 +115,10 @@ static struct mlx5_flow_rule *mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	return rule;
 }
 
-static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
-						    struct mlx5_flow_spec *spec,
-						    struct mlx5_esw_flow_attr *attr)
+static struct mlx5_flow_handle *
+mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
+		      struct mlx5_flow_spec *spec,
+		      struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	int err;
@@ -129,7 +131,7 @@ static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
-			      struct mlx5_flow_rule *rule,
+			      struct mlx5_flow_handle *rule,
 			      struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
@@ -140,7 +142,7 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 	if (esw && esw->mode == SRIOV_OFFLOADS)
 		mlx5_eswitch_del_vlan_action(esw, attr);
 
-	mlx5_del_flow_rule(rule);
+	mlx5_del_flow_rules(rule);
 
 	mlx5_fc_destroy(priv->mdev, counter);
 
@@ -450,7 +452,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	u32 flow_tag, action;
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
-	struct mlx5_flow_rule *old = NULL;
+	struct mlx5_flow_handle *old = NULL;
 	struct mlx5_esw_flow_attr *old_attr = NULL;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
@@ -511,7 +513,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	goto out;
 
 err_del_rule:
-	mlx5_del_flow_rule(flow->rule);
+	mlx5_del_flow_rules(flow->rule);
 
 err_free:
 	if (!old)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 9ef01d1..fcd8b15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -56,7 +56,7 @@ struct esw_uc_addr {
 /* E-Switch MC FDB table hash node */
 struct esw_mc_addr { /* SRIOV only */
 	struct l2addr_node     node;
-	struct mlx5_flow_rule *uplink_rule; /* Forward to uplink rule */
+	struct mlx5_flow_handle *uplink_rule; /* Forward to uplink rule */
 	u32                    refcnt;
 };
 
@@ -65,7 +65,7 @@ struct vport_addr {
 	struct l2addr_node     node;
 	u8                     action;
 	u32                    vport;
-	struct mlx5_flow_rule *flow_rule; /* SRIOV only */
+	struct mlx5_flow_handle *flow_rule; /* SRIOV only */
 	/* A flag indicating that mac was added due to mc promiscuous vport */
 	bool mc_promisc;
 };
@@ -237,13 +237,13 @@ static void del_l2_table_entry(struct mlx5_core_dev *dev, u32 index)
 }
 
 /* E-Switch FDB */
-static struct mlx5_flow_rule *
+static struct mlx5_flow_handle *
 __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 			 u8 mac_c[ETH_ALEN], u8 mac_v[ETH_ALEN])
 {
 	int match_header = (is_zero_ether_addr(mac_c) ? 0 :
 			    MLX5_MATCH_OUTER_HEADERS);
-	struct mlx5_flow_rule *flow_rule = NULL;
+	struct mlx5_flow_handle *flow_rule = NULL;
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_spec *spec;
 	void *mv_misc = NULL;
@@ -286,9 +286,9 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 		  dmac_v, dmac_c, vport);
 	spec->match_criteria_enable = match_header;
 	flow_rule =
-		mlx5_add_flow_rule(esw->fdb_table.fdb, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				   0, &dest);
+		mlx5_add_flow_rules(esw->fdb_table.fdb, spec,
+				    MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+				    0, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		esw_warn(esw->dev,
 			 "FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
@@ -300,7 +300,7 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 	return flow_rule;
 }
 
-static struct mlx5_flow_rule *
+static struct mlx5_flow_handle *
 esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
 {
 	u8 mac_c[ETH_ALEN];
@@ -309,7 +309,7 @@ esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
 	return __esw_fdb_set_vport_rule(esw, vport, false, mac_c, mac);
 }
 
-static struct mlx5_flow_rule *
+static struct mlx5_flow_handle *
 esw_fdb_set_vport_allmulti_rule(struct mlx5_eswitch *esw, u32 vport)
 {
 	u8 mac_c[ETH_ALEN];
@@ -322,7 +322,7 @@ esw_fdb_set_vport_allmulti_rule(struct mlx5_eswitch *esw, u32 vport)
 	return __esw_fdb_set_vport_rule(esw, vport, false, mac_c, mac_v);
 }
 
-static struct mlx5_flow_rule *
+static struct mlx5_flow_handle *
 esw_fdb_set_vport_promisc_rule(struct mlx5_eswitch *esw, u32 vport)
 {
 	u8 mac_c[ETH_ALEN];
@@ -515,7 +515,7 @@ static int esw_del_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 	del_l2_table_entry(esw->dev, esw_uc->table_index);
 
 	if (vaddr->flow_rule)
-		mlx5_del_flow_rule(vaddr->flow_rule);
+		mlx5_del_flow_rules(vaddr->flow_rule);
 	vaddr->flow_rule = NULL;
 
 	l2addr_hash_del(esw_uc);
@@ -562,7 +562,7 @@ static void update_allmulti_vports(struct mlx5_eswitch *esw,
 		case MLX5_ACTION_DEL:
 			if (!iter_vaddr)
 				continue;
-			mlx5_del_flow_rule(iter_vaddr->flow_rule);
+			mlx5_del_flow_rules(iter_vaddr->flow_rule);
 			l2addr_hash_del(iter_vaddr);
 			break;
 		}
@@ -632,7 +632,7 @@ static int esw_del_mc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 		  esw_mc->uplink_rule);
 
 	if (vaddr->flow_rule)
-		mlx5_del_flow_rule(vaddr->flow_rule);
+		mlx5_del_flow_rules(vaddr->flow_rule);
 	vaddr->flow_rule = NULL;
 
 	/* If the multicast mac is added as a result of mc promiscuous vport,
@@ -645,7 +645,7 @@ static int esw_del_mc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 	update_allmulti_vports(esw, vaddr, esw_mc);
 
 	if (esw_mc->uplink_rule)
-		mlx5_del_flow_rule(esw_mc->uplink_rule);
+		mlx5_del_flow_rules(esw_mc->uplink_rule);
 
 	l2addr_hash_del(esw_mc);
 	return 0;
@@ -828,14 +828,14 @@ static void esw_apply_vport_rx_mode(struct mlx5_eswitch *esw, u32 vport_num,
 								UPLINK_VPORT);
 		allmulti_addr->refcnt++;
 	} else if (vport->allmulti_rule) {
-		mlx5_del_flow_rule(vport->allmulti_rule);
+		mlx5_del_flow_rules(vport->allmulti_rule);
 		vport->allmulti_rule = NULL;
 
 		if (--allmulti_addr->refcnt > 0)
 			goto promisc;
 
 		if (allmulti_addr->uplink_rule)
-			mlx5_del_flow_rule(allmulti_addr->uplink_rule);
+			mlx5_del_flow_rules(allmulti_addr->uplink_rule);
 		allmulti_addr->uplink_rule = NULL;
 	}
 
@@ -847,7 +847,7 @@ static void esw_apply_vport_rx_mode(struct mlx5_eswitch *esw, u32 vport_num,
 		vport->promisc_rule = esw_fdb_set_vport_promisc_rule(esw,
 								     vport_num);
 	} else if (vport->promisc_rule) {
-		mlx5_del_flow_rule(vport->promisc_rule);
+		mlx5_del_flow_rules(vport->promisc_rule);
 		vport->promisc_rule = NULL;
 	}
 }
@@ -1015,10 +1015,10 @@ static void esw_vport_cleanup_egress_rules(struct mlx5_eswitch *esw,
 					   struct mlx5_vport *vport)
 {
 	if (!IS_ERR_OR_NULL(vport->egress.allowed_vlan))
-		mlx5_del_flow_rule(vport->egress.allowed_vlan);
+		mlx5_del_flow_rules(vport->egress.allowed_vlan);
 
 	if (!IS_ERR_OR_NULL(vport->egress.drop_rule))
-		mlx5_del_flow_rule(vport->egress.drop_rule);
+		mlx5_del_flow_rules(vport->egress.drop_rule);
 
 	vport->egress.allowed_vlan = NULL;
 	vport->egress.drop_rule = NULL;
@@ -1173,10 +1173,10 @@ static void esw_vport_cleanup_ingress_rules(struct mlx5_eswitch *esw,
 					    struct mlx5_vport *vport)
 {
 	if (!IS_ERR_OR_NULL(vport->ingress.drop_rule))
-		mlx5_del_flow_rule(vport->ingress.drop_rule);
+		mlx5_del_flow_rules(vport->ingress.drop_rule);
 
 	if (!IS_ERR_OR_NULL(vport->ingress.allow_rule))
-		mlx5_del_flow_rule(vport->ingress.allow_rule);
+		mlx5_del_flow_rules(vport->ingress.allow_rule);
 
 	vport->ingress.drop_rule = NULL;
 	vport->ingress.allow_rule = NULL;
@@ -1253,9 +1253,9 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 	vport->ingress.allow_rule =
-		mlx5_add_flow_rule(vport->ingress.acl, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				   0, NULL);
+		mlx5_add_flow_rules(vport->ingress.acl, spec,
+				    MLX5_FLOW_CONTEXT_ACTION_ALLOW,
+				    0, NULL, 0);
 	if (IS_ERR(vport->ingress.allow_rule)) {
 		err = PTR_ERR(vport->ingress.allow_rule);
 		esw_warn(esw->dev,
@@ -1267,9 +1267,9 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 
 	memset(spec, 0, sizeof(*spec));
 	vport->ingress.drop_rule =
-		mlx5_add_flow_rule(vport->ingress.acl, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_DROP,
-				   0, NULL);
+		mlx5_add_flow_rules(vport->ingress.acl, spec,
+				    MLX5_FLOW_CONTEXT_ACTION_DROP,
+				    0, NULL, 0);
 	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
 		esw_warn(esw->dev,
@@ -1321,9 +1321,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 	vport->egress.allowed_vlan =
-		mlx5_add_flow_rule(vport->egress.acl, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
-				   0, NULL);
+		mlx5_add_flow_rules(vport->egress.acl, spec,
+				    MLX5_FLOW_CONTEXT_ACTION_ALLOW,
+				    0, NULL, 0);
 	if (IS_ERR(vport->egress.allowed_vlan)) {
 		err = PTR_ERR(vport->egress.allowed_vlan);
 		esw_warn(esw->dev,
@@ -1336,9 +1336,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	/* Drop others rule (star rule) */
 	memset(spec, 0, sizeof(*spec));
 	vport->egress.drop_rule =
-		mlx5_add_flow_rule(vport->egress.acl, spec,
-				   MLX5_FLOW_CONTEXT_ACTION_DROP,
-				   0, NULL);
+		mlx5_add_flow_rules(vport->egress.acl, spec,
+				    MLX5_FLOW_CONTEXT_ACTION_DROP,
+				    0, NULL, 0);
 	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
 		esw_warn(esw->dev,
@@ -1667,7 +1667,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 		esw_disable_vport(esw, i);
 
 	if (mc_promisc && mc_promisc->uplink_rule)
-		mlx5_del_flow_rule(mc_promisc->uplink_rule);
+		mlx5_del_flow_rules(mc_promisc->uplink_rule);
 
 	esw_destroy_tsar(esw);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index ddae90c..6d414cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -97,16 +97,16 @@ struct vport_ingress {
 	struct mlx5_flow_group *allow_spoofchk_only_grp;
 	struct mlx5_flow_group *allow_untagged_only_grp;
 	struct mlx5_flow_group *drop_grp;
-	struct mlx5_flow_rule  *allow_rule;
-	struct mlx5_flow_rule  *drop_rule;
+	struct mlx5_flow_handle  *allow_rule;
+	struct mlx5_flow_handle  *drop_rule;
 };
 
 struct vport_egress {
 	struct mlx5_flow_table *acl;
 	struct mlx5_flow_group *allowed_vlans_grp;
 	struct mlx5_flow_group *drop_grp;
-	struct mlx5_flow_rule  *allowed_vlan;
-	struct mlx5_flow_rule  *drop_rule;
+	struct mlx5_flow_handle  *allowed_vlan;
+	struct mlx5_flow_handle  *drop_rule;
 };
 
 struct mlx5_vport_info {
@@ -125,8 +125,8 @@ struct mlx5_vport {
 	int                     vport;
 	struct hlist_head       uc_list[MLX5_L2_ADDR_HASH_SIZE];
 	struct hlist_head       mc_list[MLX5_L2_ADDR_HASH_SIZE];
-	struct mlx5_flow_rule   *promisc_rule;
-	struct mlx5_flow_rule   *allmulti_rule;
+	struct mlx5_flow_handle *promisc_rule;
+	struct mlx5_flow_handle *allmulti_rule;
 	struct work_struct      vport_change_handler;
 
 	struct vport_ingress    ingress;
@@ -162,7 +162,7 @@ struct mlx5_eswitch_fdb {
 			struct mlx5_flow_table *fdb;
 			struct mlx5_flow_group *send_to_vport_grp;
 			struct mlx5_flow_group *miss_grp;
-			struct mlx5_flow_rule  *miss_rule;
+			struct mlx5_flow_handle *miss_rule;
 			int vlan_push_pop_refcount;
 		} offloads;
 	};
@@ -175,7 +175,7 @@ enum {
 };
 
 struct mlx5_esw_sq {
-	struct mlx5_flow_rule	*send_to_vport_rule;
+	struct mlx5_flow_handle	*send_to_vport_rule;
 	struct list_head	 list;
 };
 
@@ -188,7 +188,7 @@ struct mlx5_eswitch_rep {
 	u8		       hw_id[ETH_ALEN];
 	void		      *priv_data;
 
-	struct mlx5_flow_rule *vport_rx_rule;
+	struct mlx5_flow_handle *vport_rx_rule;
 	struct list_head       vport_sqs_list;
 	u16		       vlan;
 	u32		       vlan_refcount;
@@ -257,11 +257,11 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 struct mlx5_flow_spec;
 struct mlx5_esw_flow_attr;
 
-struct mlx5_flow_rule *
+struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
 				struct mlx5_esw_flow_attr *attr);
-struct mlx5_flow_rule *
+struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c55ad8d..8b2a383 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -43,14 +43,14 @@ enum {
 	FDB_SLOW_PATH
 };
 
-struct mlx5_flow_rule *
+struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
 				struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_flow_destination dest = { 0 };
 	struct mlx5_fc *counter = NULL;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
 	void *misc;
 	int action;
 
@@ -80,8 +80,8 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS |
 				      MLX5_MATCH_MISC_PARAMETERS;
 
-	rule = mlx5_add_flow_rule((struct mlx5_flow_table *)esw->fdb_table.fdb,
-				  spec, action, 0, &dest);
+	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
+				   spec, action, 0, &dest, 1);
 
 	if (IS_ERR(rule))
 		mlx5_fc_destroy(esw->dev, counter);
@@ -269,11 +269,11 @@ int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 	return err;
 }
 
-static struct mlx5_flow_rule *
+static struct mlx5_flow_handle *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
 {
 	struct mlx5_flow_destination dest;
-	struct mlx5_flow_rule *flow_rule;
+	struct mlx5_flow_handle *flow_rule;
 	struct mlx5_flow_spec *spec;
 	void *misc;
 
@@ -296,9 +296,9 @@ mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = vport;
 
-	flow_rule = mlx5_add_flow_rule(esw->fdb_table.offloads.fdb, spec,
-				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				       0, &dest);
+	flow_rule = mlx5_add_flow_rules(esw->fdb_table.offloads.fdb, spec,
+					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+					0, &dest, 1);
 	if (IS_ERR(flow_rule))
 		esw_warn(esw->dev, "FDB: Failed to add send to vport rule err %ld\n", PTR_ERR(flow_rule));
 out:
@@ -315,7 +315,7 @@ void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
 		return;
 
 	list_for_each_entry_safe(esw_sq, tmp, &rep->vport_sqs_list, list) {
-		mlx5_del_flow_rule(esw_sq->send_to_vport_rule);
+		mlx5_del_flow_rules(esw_sq->send_to_vport_rule);
 		list_del(&esw_sq->list);
 		kfree(esw_sq);
 	}
@@ -325,7 +325,7 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 				 struct mlx5_eswitch_rep *rep,
 				 u16 *sqns_array, int sqns_num)
 {
-	struct mlx5_flow_rule *flow_rule;
+	struct mlx5_flow_handle *flow_rule;
 	struct mlx5_esw_sq *esw_sq;
 	int err;
 	int i;
@@ -362,7 +362,7 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 {
 	struct mlx5_flow_destination dest;
-	struct mlx5_flow_rule *flow_rule = NULL;
+	struct mlx5_flow_handle *flow_rule = NULL;
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
@@ -376,9 +376,9 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = 0;
 
-	flow_rule = mlx5_add_flow_rule(esw->fdb_table.offloads.fdb, spec,
-				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				       0, &dest);
+	flow_rule = mlx5_add_flow_rules(esw->fdb_table.offloads.fdb, spec,
+					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+					0, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		err = PTR_ERR(flow_rule);
 		esw_warn(esw->dev,  "FDB: Failed to add miss flow rule err %d\n", err);
@@ -501,7 +501,7 @@ static void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
 		return;
 
 	esw_debug(esw->dev, "Destroy offloads FDB Table\n");
-	mlx5_del_flow_rule(esw->fdb_table.offloads.miss_rule);
+	mlx5_del_flow_rules(esw->fdb_table.offloads.miss_rule);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.send_to_vport_grp);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.miss_grp);
 
@@ -585,11 +585,11 @@ static void esw_destroy_vport_rx_group(struct mlx5_eswitch *esw)
 	mlx5_destroy_flow_group(esw->offloads.vport_rx_group);
 }
 
-struct mlx5_flow_rule *
+struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 {
 	struct mlx5_flow_destination dest;
-	struct mlx5_flow_rule *flow_rule;
+	struct mlx5_flow_handle *flow_rule;
 	struct mlx5_flow_spec *spec;
 	void *misc;
 
@@ -610,9 +610,9 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
 	dest.tir_num = tirn;
 
-	flow_rule = mlx5_add_flow_rule(esw->offloads.ft_offloads, spec,
-				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-				       0, &dest);
+	flow_rule = mlx5_add_flow_rules(esw->offloads.ft_offloads, spec,
+					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+					0, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		esw_warn(esw->dev, "fs offloads: Failed to add vport rx rule err %ld\n", PTR_ERR(flow_rule));
 		goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 43d7052..6732287 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -155,6 +155,9 @@ static void del_flow_group(struct fs_node *node);
 static void del_fte(struct fs_node *node);
 static bool mlx5_flow_dests_cmp(struct mlx5_flow_destination *d1,
 				struct mlx5_flow_destination *d2);
+static struct mlx5_flow_rule *
+find_flow_rule(struct fs_fte *fte,
+	       struct mlx5_flow_destination *dest);
 
 static void tree_init_node(struct fs_node *node,
 			   unsigned int refcount,
@@ -640,8 +643,8 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 	return err;
 }
 
-int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
-				 struct mlx5_flow_destination *dest)
+static int _mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
+					 struct mlx5_flow_destination *dest)
 {
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
@@ -666,6 +669,28 @@ int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 	return err;
 }
 
+int mlx5_modify_rule_destination(struct mlx5_flow_handle *handle,
+				 struct mlx5_flow_destination *new_dest,
+				 struct mlx5_flow_destination *old_dest)
+{
+	int i;
+
+	if (!old_dest) {
+		if (handle->num_rules != 1)
+			return -EINVAL;
+		return _mlx5_modify_rule_destination(handle->rule[0],
+						     new_dest);
+	}
+
+	for (i = 0; i < handle->num_rules; i++) {
+		if (mlx5_flow_dests_cmp(new_dest, &handle->rule[i]->dest_attr))
+			return _mlx5_modify_rule_destination(handle->rule[i],
+							     new_dest);
+	}
+
+	return -EINVAL;
+}
+
 /* Modify/set FWD rules that point on old_next_ft to point on new_next_ft  */
 static int connect_fwd_rules(struct mlx5_core_dev *dev,
 			     struct mlx5_flow_table *new_next_ft,
@@ -688,7 +713,7 @@ static int connect_fwd_rules(struct mlx5_core_dev *dev,
 	list_splice_init(&old_next_ft->fwd_rules, &new_next_ft->fwd_rules);
 	mutex_unlock(&old_next_ft->lock);
 	list_for_each_entry(iter, &new_next_ft->fwd_rules, next_ft) {
-		err = mlx5_modify_rule_destination(iter, &dest);
+		err = _mlx5_modify_rule_destination(iter, &dest);
 		if (err)
 			pr_err("mlx5_core: failed to modify rule to point on flow table %d\n",
 			       new_next_ft->id);
@@ -917,41 +942,117 @@ static struct mlx5_flow_rule *alloc_rule(struct mlx5_flow_destination *dest)
 	return rule;
 }
 
-/* fte should not be deleted while calling this function */
-static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
-					   struct mlx5_flow_group *fg,
-					   struct mlx5_flow_destination *dest,
-					   bool update_action)
+static struct mlx5_flow_handle *alloc_handle(int num_rules)
 {
+	struct mlx5_flow_handle *handle;
+
+	handle = kzalloc(sizeof(*handle) + sizeof(handle->rule[0]) *
+			  num_rules, GFP_KERNEL);
+	if (!handle)
+		return NULL;
+
+	handle->num_rules = num_rules;
+
+	return handle;
+}
+
+static void destroy_flow_handle(struct fs_fte *fte,
+				struct mlx5_flow_handle *handle,
+				struct mlx5_flow_destination *dest,
+				int i)
+{
+	for (; --i >= 0;) {
+		if (atomic_dec_and_test(&handle->rule[i]->node.refcount)) {
+			fte->dests_size--;
+			list_del(&handle->rule[i]->node.list);
+			kfree(handle->rule[i]);
+		}
+	}
+	kfree(handle);
+}
+
+static struct mlx5_flow_handle *
+create_flow_handle(struct fs_fte *fte,
+		   struct mlx5_flow_destination *dest,
+		   int dest_num,
+		   int *modify_mask,
+		   bool *new_rule)
+{
+	struct mlx5_flow_handle *handle;
+	struct mlx5_flow_rule *rule = NULL;
+	static int count = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_FLOW_COUNTERS);
+	static int dst = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST);
+	int type;
+	int i = 0;
+
+	handle = alloc_handle((dest_num) ? dest_num : 1);
+	if (!handle)
+		return ERR_PTR(-ENOMEM);
+
+	do {
+		if (dest) {
+			rule = find_flow_rule(fte, dest + i);
+			if (rule) {
+				atomic_inc(&rule->node.refcount);
+				goto rule_found;
+			}
+		}
+
+		*new_rule = true;
+		rule = alloc_rule(dest + i);
+		if (!rule)
+			goto free_rules;
+
+		/* Add dest to dests list- we need flow tables to be in the
+		 * end of the list for forward to next prio rules.
+		 */
+		tree_init_node(&rule->node, 1, del_rule);
+		if (dest &&
+		    dest[i].type != MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE)
+			list_add(&rule->node.list, &fte->node.children);
+		else
+			list_add_tail(&rule->node.list, &fte->node.children);
+		if (dest) {
+			fte->dests_size++;
+
+			type = dest[i].type ==
+				MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+			*modify_mask |= type ? count : dst;
+		}
+rule_found:
+		handle->rule[i] = rule;
+	} while (++i < dest_num);
+
+	return handle;
+
+free_rules:
+	destroy_flow_handle(fte, handle, dest, i);
+	return ERR_PTR(-ENOMEM);
+}
+
+/* fte should not be deleted while calling this function */
+static struct mlx5_flow_handle *
+add_rule_fte(struct fs_fte *fte,
+	     struct mlx5_flow_group *fg,
+	     struct mlx5_flow_destination *dest,
+	     int dest_num,
+	     bool update_action)
+{
+	struct mlx5_flow_handle *handle;
 	struct mlx5_flow_table *ft;
-	struct mlx5_flow_rule *rule;
 	int modify_mask = 0;
 	int err;
+	bool new_rule = false;
 
-	rule = alloc_rule(dest);
-	if (!rule)
-		return ERR_PTR(-ENOMEM);
+	handle = create_flow_handle(fte, dest, dest_num, &modify_mask,
+				    &new_rule);
+	if (IS_ERR(handle) || !new_rule)
+		goto out;
 
 	if (update_action)
 		modify_mask |= BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_ACTION);
 
 	fs_get_obj(ft, fg->node.parent);
-	/* Add dest to dests list- we need flow tables to be in the
-	 * end of the list for forward to next prio rules.
-	 */
-	tree_init_node(&rule->node, 1, del_rule);
-	if (dest && dest->type != MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE)
-		list_add(&rule->node.list, &fte->node.children);
-	else
-		list_add_tail(&rule->node.list, &fte->node.children);
-	if (dest) {
-		fte->dests_size++;
-
-		modify_mask |= dest->type == MLX5_FLOW_DESTINATION_TYPE_COUNTER ?
-			BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_FLOW_COUNTERS) :
-			BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST);
-	}
-
 	if (!(fte->status & FS_FTE_STATUS_EXISTING))
 		err = mlx5_cmd_create_fte(get_dev(&ft->node),
 					  ft, fg->id, fte);
@@ -959,17 +1060,15 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 		err = mlx5_cmd_update_fte(get_dev(&ft->node),
 					  ft, fg->id, modify_mask, fte);
 	if (err)
-		goto free_rule;
+		goto free_handle;
 
 	fte->status |= FS_FTE_STATUS_EXISTING;
 
-	return rule;
+out:
+	return handle;
 
-free_rule:
-	list_del(&rule->node.list);
-	kfree(rule);
-	if (dest)
-		fte->dests_size--;
+free_handle:
+	destroy_flow_handle(fte, handle, dest, handle->num_rules);
 	return ERR_PTR(err);
 }
 
@@ -1098,16 +1197,18 @@ static struct mlx5_flow_rule *find_flow_rule(struct fs_fte *fte,
 	return NULL;
 }
 
-static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
-					  u32 *match_value,
-					  u8 action,
-					  u32 flow_tag,
-					  struct mlx5_flow_destination *dest)
+static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
+					    u32 *match_value,
+					    u8 action,
+					    u32 flow_tag,
+					    struct mlx5_flow_destination *dest,
+					    int dest_num)
 {
-	struct fs_fte *fte;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *handle;
 	struct mlx5_flow_table *ft;
 	struct list_head *prev;
+	struct fs_fte *fte;
+	int i;
 
 	nested_lock_ref_node(&fg->node, FS_MUTEX_PARENT);
 	fs_for_each_fte(fte, fg) {
@@ -1116,40 +1217,33 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 		    (action & fte->action) && flow_tag == fte->flow_tag) {
 			int old_action = fte->action;
 
-			rule = find_flow_rule(fte, dest);
-			if (rule) {
-				atomic_inc(&rule->node.refcount);
-				unlock_ref_node(&fte->node);
-				unlock_ref_node(&fg->node);
-				return rule;
-			}
 			fte->action |= action;
-			rule = add_rule_fte(fte, fg, dest,
-					    old_action != action);
-			if (IS_ERR(rule)) {
+			handle = add_rule_fte(fte, fg, dest, dest_num,
+					      old_action != action);
+			if (IS_ERR(handle)) {
 				fte->action = old_action;
 				goto unlock_fte;
 			} else {
-				goto add_rule;
+				goto add_rules;
 			}
 		}
 		unlock_ref_node(&fte->node);
 	}
 	fs_get_obj(ft, fg->node.parent);
 	if (fg->num_ftes >= fg->max_ftes) {
-		rule = ERR_PTR(-ENOSPC);
+		handle = ERR_PTR(-ENOSPC);
 		goto unlock_fg;
 	}
 
 	fte = create_fte(fg, match_value, action, flow_tag, &prev);
 	if (IS_ERR(fte)) {
-		rule = (void *)fte;
+		handle = (void *)fte;
 		goto unlock_fg;
 	}
 	tree_init_node(&fte->node, 0, del_fte);
 	nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
-	rule = add_rule_fte(fte, fg, dest, false);
-	if (IS_ERR(rule)) {
+	handle = add_rule_fte(fte, fg, dest, dest_num, false);
+	if (IS_ERR(handle)) {
 		kfree(fte);
 		goto unlock_fg;
 	}
@@ -1158,21 +1252,24 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 
 	tree_add_node(&fte->node, &fg->node);
 	list_add(&fte->node.list, prev);
-add_rule:
-	tree_add_node(&rule->node, &fte->node);
+add_rules:
+	for (i = 0; i < handle->num_rules; i++) {
+		if (atomic_read(&handle->rule[i]->node.refcount) == 1)
+			tree_add_node(&handle->rule[i]->node, &fte->node);
+	}
 unlock_fte:
 	unlock_ref_node(&fte->node);
 unlock_fg:
 	unlock_ref_node(&fg->node);
-	return rule;
+	return handle;
 }
 
-struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_rule *rule)
+struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_handle *handle)
 {
 	struct mlx5_flow_rule *dst;
 	struct fs_fte *fte;
 
-	fs_get_obj(fte, rule->node.parent);
+	fs_get_obj(fte, handle->rule[0]->node.parent);
 
 	fs_for_each_dst(dst, fte) {
 		if (dst->dest_attr.type == MLX5_FLOW_DESTINATION_TYPE_COUNTER)
@@ -1211,18 +1308,22 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 	return true;
 }
 
-static struct mlx5_flow_rule *
-_mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		   struct mlx5_flow_spec *spec,
-		    u32 action,
-		    u32 flow_tag,
-		    struct mlx5_flow_destination *dest)
+static struct mlx5_flow_handle *
+_mlx5_add_flow_rules(struct mlx5_flow_table *ft,
+		     struct mlx5_flow_spec *spec,
+		     u32 action,
+		     u32 flow_tag,
+		     struct mlx5_flow_destination *dest,
+		     int dest_num)
 {
 	struct mlx5_flow_group *g;
-	struct mlx5_flow_rule *rule;
+	struct mlx5_flow_handle *rule;
+	int i;
 
-	if (!dest_is_valid(dest, action, ft))
-		return ERR_PTR(-EINVAL);
+	for (i = 0; i < dest_num; i++) {
+		if (!dest_is_valid(&dest[i], action, ft))
+			return ERR_PTR(-EINVAL);
+	}
 
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
 	fs_for_each_fg(g, ft)
@@ -1231,7 +1332,7 @@ _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 					   g->mask.match_criteria,
 					   spec->match_criteria)) {
 			rule = add_rule_fg(g, spec->match_value,
-					   action, flow_tag, dest);
+					   action, flow_tag, dest, dest_num);
 			if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOSPC)
 				goto unlock;
 		}
@@ -1244,7 +1345,7 @@ _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 	}
 
 	rule = add_rule_fg(g, spec->match_value,
-			   action, flow_tag, dest);
+			   action, flow_tag, dest, dest_num);
 	if (IS_ERR(rule)) {
 		/* Remove assumes refcount > 0 and autogroup creates a group
 		 * with a refcount = 0.
@@ -1265,17 +1366,18 @@ static bool fwd_next_prio_supported(struct mlx5_flow_table *ft)
 		(MLX5_CAP_FLOWTABLE(get_dev(&ft->node), nic_rx_multi_path_tirs)));
 }
 
-struct mlx5_flow_rule *
-mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		   struct mlx5_flow_spec *spec,
-		   u32 action,
-		   u32 flow_tag,
-		   struct mlx5_flow_destination *dest)
+struct mlx5_flow_handle *
+mlx5_add_flow_rules(struct mlx5_flow_table *ft,
+		    struct mlx5_flow_spec *spec,
+		    u32 action,
+		    u32 flow_tag,
+		    struct mlx5_flow_destination *dest,
+		    int dest_num)
 {
 	struct mlx5_flow_root_namespace *root = find_root(&ft->node);
 	struct mlx5_flow_destination gen_dest;
 	struct mlx5_flow_table *next_ft = NULL;
-	struct mlx5_flow_rule *rule = NULL;
+	struct mlx5_flow_handle *handle = NULL;
 	u32 sw_action = action;
 	struct fs_prio *prio;
 
@@ -1291,6 +1393,7 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 			gen_dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
 			gen_dest.ft = next_ft;
 			dest = &gen_dest;
+			dest_num = 1;
 			action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 		} else {
 			mutex_unlock(&root->chain_lock);
@@ -1298,27 +1401,33 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		}
 	}
 
-	rule = _mlx5_add_flow_rule(ft, spec, action, flow_tag, dest);
+	handle = _mlx5_add_flow_rules(ft, spec, action, flow_tag, dest,
+				      dest_num);
 
 	if (sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
-		if (!IS_ERR_OR_NULL(rule) &&
-		    (list_empty(&rule->next_ft))) {
+		if (!IS_ERR_OR_NULL(handle) &&
+		    (list_empty(&handle->rule[0]->next_ft))) {
 			mutex_lock(&next_ft->lock);
-			list_add(&rule->next_ft, &next_ft->fwd_rules);
+			list_add(&handle->rule[0]->next_ft,
+				 &next_ft->fwd_rules);
 			mutex_unlock(&next_ft->lock);
-			rule->sw_action = MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
+			handle->rule[0]->sw_action = MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO;
 		}
 		mutex_unlock(&root->chain_lock);
 	}
-	return rule;
+	return handle;
 }
-EXPORT_SYMBOL(mlx5_add_flow_rule);
+EXPORT_SYMBOL(mlx5_add_flow_rules);
 
-void mlx5_del_flow_rule(struct mlx5_flow_rule *rule)
+void mlx5_del_flow_rules(struct mlx5_flow_handle *handle)
 {
-	tree_remove_node(&rule->node);
+	int i;
+
+	for (i = handle->num_rules - 1; i >= 0; i--)
+		tree_remove_node(&handle->rule[i]->node);
+	kfree(handle);
 }
-EXPORT_SYMBOL(mlx5_del_flow_rule);
+EXPORT_SYMBOL(mlx5_del_flow_rules);
 
 /* Assuming prio->node.children(flow tables) is sorted by level */
 static struct mlx5_flow_table *find_next_ft(struct mlx5_flow_table *ft)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 71ff03b..d515088 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -94,6 +94,11 @@ struct mlx5_flow_rule {
 	u32					sw_action;
 };
 
+struct mlx5_flow_handle {
+	int num_rules;
+	struct mlx5_flow_rule *rule[];
+};
+
 /* Type of children is mlx5_flow_group */
 struct mlx5_flow_table {
 	struct fs_node			node;
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 93ebc5e..0dcd287 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -69,8 +69,8 @@ enum mlx5_flow_namespace_type {
 
 struct mlx5_flow_table;
 struct mlx5_flow_group;
-struct mlx5_flow_rule;
 struct mlx5_flow_namespace;
+struct mlx5_flow_handle;
 
 struct mlx5_flow_spec {
 	u8   match_criteria_enable;
@@ -127,18 +127,20 @@ void mlx5_destroy_flow_group(struct mlx5_flow_group *fg);
 /* Single destination per rule.
  * Group ID is implied by the match criteria.
  */
-struct mlx5_flow_rule *
-mlx5_add_flow_rule(struct mlx5_flow_table *ft,
-		   struct mlx5_flow_spec *spec,
-		   u32 action,
-		   u32 flow_tag,
-		   struct mlx5_flow_destination *dest);
-void mlx5_del_flow_rule(struct mlx5_flow_rule *fr);
-
-int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
-				 struct mlx5_flow_destination *dest);
-
-struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_rule *rule);
+struct mlx5_flow_handle *
+mlx5_add_flow_rules(struct mlx5_flow_table *ft,
+		    struct mlx5_flow_spec *spec,
+		    u32 action,
+		    u32 flow_tag,
+		    struct mlx5_flow_destination *dest,
+		    int dest_num);
+void mlx5_del_flow_rules(struct mlx5_flow_handle *fr);
+
+int mlx5_modify_rule_destination(struct mlx5_flow_handle *handler,
+				 struct mlx5_flow_destination *new_dest,
+				 struct mlx5_flow_destination *old_dest);
+
+struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_handle *handler);
 struct mlx5_fc *mlx5_fc_create(struct mlx5_core_dev *dev, bool aging);
 void mlx5_fc_destroy(struct mlx5_core_dev *dev, struct mlx5_fc *counter);
 void mlx5_fc_query_cached(struct mlx5_fc *counter,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
