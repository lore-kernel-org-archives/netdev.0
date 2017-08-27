From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx5: Add SRIOV VGT+ support
Date: Sun, 27 Aug 2017 14:06:16 +0300
Message-ID: <20170827110618.20599-3-saeedm@mellanox.com>
References: <20170827110618.20599-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37293 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751124AbdH0LVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 07:21:30 -0400
In-Reply-To: <20170827110618.20599-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Implementing the VGT+ feature via acl tables.
The acl tables will hold the actual needed rules which is only the
intersection of the requested vlan-ids list and the allowed vlan-ids
list from the administrator.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  28 ++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 496 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  31 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   |  19 +-
 include/linux/mlx5/vport.h                        |   6 +-
 5 files changed, 458 insertions(+), 122 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index fdc2b92f020b..1a2ebe0e79ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3388,6 +3388,32 @@ static int mlx5e_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos,
 					   vlan, qos);
 }
 
+static int mlx5e_add_vf_vlan_trunk_range(struct net_device *dev, int vf,
+					 u16 start_vid, u16 end_vid,
+					 __be16 vlan_proto) {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
+	return mlx5_eswitch_add_vport_trunk_range(mdev->priv.eswitch, vf + 1,
+						  start_vid, end_vid);
+}
+
+static int mlx5e_del_vf_vlan_trunk_range(struct net_device *dev, int vf,
+					 u16 start_vid, u16 end_vid,
+					 __be16 vlan_proto) {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
+	return mlx5_eswitch_del_vport_trunk_range(mdev->priv.eswitch, vf + 1,
+						  start_vid, end_vid);
+}
+
 static int mlx5e_set_vf_spoofchk(struct net_device *dev, int vf, bool setting)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -3733,6 +3759,8 @@ static const struct net_device_ops mlx5e_netdev_ops = {
 	/* SRIOV E-Switch NDOs */
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
+	.ndo_add_vf_vlan_trunk_range = mlx5e_add_vf_vlan_trunk_range,
+	.ndo_del_vf_vlan_trunk_range = mlx5e_del_vf_vlan_trunk_range,
 	.ndo_set_vf_spoofchk     = mlx5e_set_vf_spoofchk,
 	.ndo_set_vf_trust        = mlx5e_set_vf_trust,
 	.ndo_set_vf_rate         = mlx5e_set_vf_rate,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 6b84c1113301..a8e8670c7c8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -60,12 +60,14 @@ struct vport_addr {
 enum {
 	UC_ADDR_CHANGE = BIT(0),
 	MC_ADDR_CHANGE = BIT(1),
+	VLAN_CHANGE    = BIT(2),
 	PROMISC_CHANGE = BIT(3),
 };
 
 /* Vport context events */
 #define SRIOV_VPORT_EVENTS (UC_ADDR_CHANGE | \
 			    MC_ADDR_CHANGE | \
+			    VLAN_CHANGE | \
 			    PROMISC_CHANGE)
 
 static int arm_vport_context_events_cmd(struct mlx5_core_dev *dev, u16 vport,
@@ -681,6 +683,45 @@ static void esw_update_vport_addr_list(struct mlx5_eswitch *esw,
 	kfree(mac_list);
 }
 
+static void esw_update_acl_trunk_bitmap(struct mlx5_eswitch *esw, u32 vport_num)
+{
+	struct mlx5_vport *vport = &esw->vports[vport_num];
+
+	bitmap_and(vport->acl_vlan_8021q_bitmap, vport->req_vlan_bitmap,
+		   vport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
+}
+
+static int esw_vport_egress_config(struct mlx5_eswitch *esw,
+				   struct mlx5_vport *vport);
+static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
+				    struct mlx5_vport *vport);
+
+/* Sync vport vlan list from vport context */
+static void esw_update_vport_vlan_list(struct mlx5_eswitch *esw, u32 vport_num)
+{
+	struct mlx5_vport *vport = &esw->vports[vport_num];
+	DECLARE_BITMAP(prev_vlans_bitmap, VLAN_N_VID);
+	int err;
+
+	bitmap_copy(prev_vlans_bitmap, vport->req_vlan_bitmap, VLAN_N_VID);
+	bitmap_zero(vport->req_vlan_bitmap, VLAN_N_VID);
+
+	if (!vport->enabled)
+		return;
+
+	err = mlx5_query_nic_vport_vlans(esw->dev, vport_num, vport->req_vlan_bitmap);
+	if (err)
+		return;
+
+	bitmap_xor(prev_vlans_bitmap, prev_vlans_bitmap, vport->req_vlan_bitmap, VLAN_N_VID);
+	if (!bitmap_weight(prev_vlans_bitmap, VLAN_N_VID))
+		return;
+
+	esw_update_acl_trunk_bitmap(esw, vport_num);
+	esw_vport_egress_config(esw, vport);
+	esw_vport_ingress_config(esw, vport);
+}
+
 /* Sync vport UC/MC list from vport context
  * Must be called after esw_update_vport_addr_list
  */
@@ -812,6 +853,9 @@ static void esw_vport_change_handle_locked(struct mlx5_vport *vport)
 					   MLX5_NVPRT_LIST_TYPE_MC);
 	}
 
+	if (vport->enabled_events & VLAN_CHANGE)
+		esw_update_vport_vlan_list(esw, vport->vport);
+
 	if (vport->enabled_events & PROMISC_CHANGE) {
 		esw_update_vport_rx_mode(esw, vport->vport);
 		if (!IS_ERR_OR_NULL(vport->allmulti_rule))
@@ -844,18 +888,20 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 				       struct mlx5_vport *vport)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_group *untagged_grp = NULL;
 	struct mlx5_flow_group *vlan_grp = NULL;
 	struct mlx5_flow_group *drop_grp = NULL;
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *acl;
+	/* The egress acl table contains 3 groups:
+	 * 1)Allow tagged traffic with vlan_tag=vst_vlan_id/vgt+_vlan_id
+	 * 2)Allow untagged traffic
+	 * 2)Drop all other traffic
+	 */
+	int table_size = VLAN_N_VID + 2;
 	void *match_criteria;
 	u32 *flow_group_in;
-	/* The egress acl table contains 2 rules:
-	 * 1)Allow traffic with vlan_tag=vst_vlan_id
-	 * 2)Drop all other traffic.
-	 */
-	int table_size = 2;
 	int err = 0;
 
 	if (!MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support))
@@ -887,11 +933,26 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
+
+	/* Create flow group for allowed untagged flow rule */
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.first_vid);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
 
+	untagged_grp = mlx5_create_flow_group(acl, flow_group_in);
+	if (IS_ERR(untagged_grp)) {
+		err = PTR_ERR(untagged_grp);
+		esw_warn(dev, "Failed to create E-Switch vport[%d] egress untagged flow group, err(%d)\n",
+			 vport->vport, err);
+		goto out;
+	}
+
+	/* Create flow group for allowed tagged flow rules */
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.first_vid);
+	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, VLAN_N_VID);
+
 	vlan_grp = mlx5_create_flow_group(acl, flow_group_in);
 	if (IS_ERR(vlan_grp)) {
 		err = PTR_ERR(vlan_grp);
@@ -900,9 +961,10 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 		goto out;
 	}
 
+	/* Create flow group for drop rule */
 	memset(flow_group_in, 0, inlen);
-	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
-	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
+	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, VLAN_N_VID + 1);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, VLAN_N_VID + 1);
 	drop_grp = mlx5_create_flow_group(acl, flow_group_in);
 	if (IS_ERR(drop_grp)) {
 		err = PTR_ERR(drop_grp);
@@ -914,25 +976,45 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	vport->egress.acl = acl;
 	vport->egress.drop_grp = drop_grp;
 	vport->egress.allowed_vlans_grp = vlan_grp;
+	vport->egress.allow_untagged_grp = untagged_grp;
+
 out:
+	if (err) {
+		if (!IS_ERR_OR_NULL(vlan_grp))
+			mlx5_destroy_flow_group(vlan_grp);
+		if (!IS_ERR_OR_NULL(untagged_grp))
+			mlx5_destroy_flow_group(untagged_grp);
+		if (!IS_ERR_OR_NULL(acl))
+			mlx5_destroy_flow_table(acl);
+	}
+
 	kvfree(flow_group_in);
-	if (err && !IS_ERR_OR_NULL(vlan_grp))
-		mlx5_destroy_flow_group(vlan_grp);
-	if (err && !IS_ERR_OR_NULL(acl))
-		mlx5_destroy_flow_table(acl);
 	return err;
 }
 
 static void esw_vport_cleanup_egress_rules(struct mlx5_eswitch *esw,
 					   struct mlx5_vport *vport)
 {
-	if (!IS_ERR_OR_NULL(vport->egress.allowed_vlan))
-		mlx5_del_flow_rules(vport->egress.allowed_vlan);
+	struct mlx5_acl_vlan *trunk_vlan_rule, *tmp;
+
+	if (!IS_ERR_OR_NULL(vport->egress.allowed_vst_vlan))
+		mlx5_del_flow_rules(vport->egress.allowed_vst_vlan);
+
+	list_for_each_entry_safe(trunk_vlan_rule, tmp,
+				 &vport->egress.allowed_vlans_rules, list) {
+		mlx5_del_flow_rules(trunk_vlan_rule->acl_vlan_rule);
+		list_del(&trunk_vlan_rule->list);
+		kfree(trunk_vlan_rule);
+	}
 
 	if (!IS_ERR_OR_NULL(vport->egress.drop_rule))
 		mlx5_del_flow_rules(vport->egress.drop_rule);
 
-	vport->egress.allowed_vlan = NULL;
+	if (!IS_ERR_OR_NULL(vport->egress.allow_untagged_rule))
+		mlx5_del_flow_rules(vport->egress.allow_untagged_rule);
+
+	vport->egress.allow_untagged_rule = NULL;
+	vport->egress.allowed_vst_vlan = NULL;
 	vport->egress.drop_rule = NULL;
 }
 
@@ -945,9 +1027,12 @@ static void esw_vport_disable_egress_acl(struct mlx5_eswitch *esw,
 	esw_debug(esw->dev, "Destroy vport[%d] E-Switch egress ACL\n", vport->vport);
 
 	esw_vport_cleanup_egress_rules(esw, vport);
+	mlx5_destroy_flow_group(vport->egress.allow_untagged_grp);
 	mlx5_destroy_flow_group(vport->egress.allowed_vlans_grp);
 	mlx5_destroy_flow_group(vport->egress.drop_grp);
 	mlx5_destroy_flow_table(vport->egress.acl);
+
+	vport->egress.allow_untagged_grp = NULL;
 	vport->egress.allowed_vlans_grp = NULL;
 	vport->egress.drop_grp = NULL;
 	vport->egress.acl = NULL;
@@ -956,11 +1041,15 @@ static void esw_vport_disable_egress_acl(struct mlx5_eswitch *esw,
 static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 					struct mlx5_vport *vport)
 {
+	bool need_vlan_filter = !!bitmap_weight(vport->info.vlan_trunk_8021q_bitmap,
+						VLAN_N_VID);
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_group *untagged_spoof_grp = NULL;
+	struct mlx5_flow_group *tagged_spoof_grp = NULL;
+	struct mlx5_flow_group *drop_grp = NULL;
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *acl;
-	struct mlx5_flow_group *g;
 	void *match_criteria;
 	u32 *flow_group_in;
 	/* The ingress acl table contains 4 groups
@@ -969,10 +1058,11 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	 *      1 drop rule from the last group):
 	 * 1)Allow untagged traffic with smac=original mac.
 	 * 2)Allow untagged traffic.
-	 * 3)Allow traffic with smac=original mac.
+	 * 3)Allow tagged traffic with smac=original mac.
 	 * 4)Drop all other traffic.
 	 */
-	int table_size = 4;
+	int table_size = need_vlan_filter ? 8192 : 4;
+	int allow_grp_sz = 1;
 	int err = 0;
 
 	if (!MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support))
@@ -1006,76 +1096,71 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
+
+	if (vport->info.vlan || vport->info.qos || need_vlan_filter)
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
+
+	if (vport->info.spoofchk) {
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
+	}
+
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
 
-	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR(g)) {
-		err = PTR_ERR(g);
+	untagged_spoof_grp = mlx5_create_flow_group(acl, flow_group_in);
+	if (IS_ERR(untagged_spoof_grp)) {
+		err = PTR_ERR(untagged_spoof_grp);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress untagged spoofchk flow group, err(%d)\n",
 			 vport->vport, err);
 		goto out;
 	}
-	vport->ingress.allow_untagged_spoofchk_grp = g;
+
+	if (!need_vlan_filter)
+		goto drop_grp;
 
 	memset(flow_group_in, 0, inlen);
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
+	if (vport->info.spoofchk) {
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
+	}
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.first_vid);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
-	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, VLAN_N_VID);
+	allow_grp_sz = VLAN_N_VID + 1;
 
-	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR(g)) {
-		err = PTR_ERR(g);
-		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress untagged flow group, err(%d)\n",
-			 vport->vport, err);
-		goto out;
-	}
-	vport->ingress.allow_untagged_only_grp = g;
-
-	memset(flow_group_in, 0, inlen);
-	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
-	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 2);
-	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 2);
-
-	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR(g)) {
-		err = PTR_ERR(g);
+	tagged_spoof_grp = mlx5_create_flow_group(acl, flow_group_in);
+	if (IS_ERR(tagged_spoof_grp)) {
+		err = PTR_ERR(tagged_spoof_grp);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress spoofchk flow group, err(%d)\n",
 			 vport->vport, err);
 		goto out;
 	}
-	vport->ingress.allow_spoofchk_only_grp = g;
 
+drop_grp:
 	memset(flow_group_in, 0, inlen);
-	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 3);
-	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 3);
+	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, allow_grp_sz);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, allow_grp_sz);
 
-	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR(g)) {
-		err = PTR_ERR(g);
+	drop_grp = mlx5_create_flow_group(acl, flow_group_in);
+	if (IS_ERR(drop_grp)) {
+		err = PTR_ERR(drop_grp);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress drop flow group, err(%d)\n",
 			 vport->vport, err);
 		goto out;
 	}
-	vport->ingress.drop_grp = g;
+	vport->ingress.allow_untagged_spoofchk_grp = untagged_spoof_grp;
+	vport->ingress.allow_tagged_spoofchk_grp = tagged_spoof_grp;
+	vport->ingress.drop_grp = drop_grp;
 
 out:
 	if (err) {
-		if (!IS_ERR_OR_NULL(vport->ingress.allow_spoofchk_only_grp))
-			mlx5_destroy_flow_group(
-					vport->ingress.allow_spoofchk_only_grp);
-		if (!IS_ERR_OR_NULL(vport->ingress.allow_untagged_only_grp))
-			mlx5_destroy_flow_group(
-					vport->ingress.allow_untagged_only_grp);
-		if (!IS_ERR_OR_NULL(vport->ingress.allow_untagged_spoofchk_grp))
-			mlx5_destroy_flow_group(
-				vport->ingress.allow_untagged_spoofchk_grp);
+		if (!IS_ERR_OR_NULL(tagged_spoof_grp))
+			mlx5_destroy_flow_group(tagged_spoof_grp);
+		if (!IS_ERR_OR_NULL(untagged_spoof_grp))
+			mlx5_destroy_flow_group(untagged_spoof_grp);
 		if (!IS_ERR_OR_NULL(vport->ingress.acl))
 			mlx5_destroy_flow_table(vport->ingress.acl);
 	}
@@ -1087,14 +1172,23 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 static void esw_vport_cleanup_ingress_rules(struct mlx5_eswitch *esw,
 					    struct mlx5_vport *vport)
 {
+	struct mlx5_acl_vlan *trunk_vlan_rule, *tmp;
+
 	if (!IS_ERR_OR_NULL(vport->ingress.drop_rule))
 		mlx5_del_flow_rules(vport->ingress.drop_rule);
 
-	if (!IS_ERR_OR_NULL(vport->ingress.allow_rule))
-		mlx5_del_flow_rules(vport->ingress.allow_rule);
+	list_for_each_entry_safe(trunk_vlan_rule, tmp,
+				 &vport->ingress.allowed_vlans_rules, list) {
+		mlx5_del_flow_rules(trunk_vlan_rule->acl_vlan_rule);
+		list_del(&trunk_vlan_rule->list);
+		kfree(trunk_vlan_rule);
+	}
+
+	if (!IS_ERR_OR_NULL(vport->ingress.allow_untagged_rule))
+		mlx5_del_flow_rules(vport->ingress.allow_untagged_rule);
 
 	vport->ingress.drop_rule = NULL;
-	vport->ingress.allow_rule = NULL;
+	vport->ingress.allow_untagged_rule = NULL;
 }
 
 static void esw_vport_disable_ingress_acl(struct mlx5_eswitch *esw,
@@ -1106,23 +1200,32 @@ static void esw_vport_disable_ingress_acl(struct mlx5_eswitch *esw,
 	esw_debug(esw->dev, "Destroy vport[%d] E-Switch ingress ACL\n", vport->vport);
 
 	esw_vport_cleanup_ingress_rules(esw, vport);
-	mlx5_destroy_flow_group(vport->ingress.allow_spoofchk_only_grp);
-	mlx5_destroy_flow_group(vport->ingress.allow_untagged_only_grp);
-	mlx5_destroy_flow_group(vport->ingress.allow_untagged_spoofchk_grp);
-	mlx5_destroy_flow_group(vport->ingress.drop_grp);
+	if (!IS_ERR_OR_NULL(vport->ingress.allow_tagged_spoofchk_grp))
+		mlx5_destroy_flow_group(vport->ingress.allow_tagged_spoofchk_grp);
+
+	if (!IS_ERR_OR_NULL(vport->ingress.allow_untagged_spoofchk_grp))
+		mlx5_destroy_flow_group(vport->ingress.allow_untagged_spoofchk_grp);
+
+	if (!IS_ERR_OR_NULL(vport->ingress.drop_grp))
+		mlx5_destroy_flow_group(vport->ingress.drop_grp);
+
 	mlx5_destroy_flow_table(vport->ingress.acl);
 	vport->ingress.acl = NULL;
 	vport->ingress.drop_grp = NULL;
-	vport->ingress.allow_spoofchk_only_grp = NULL;
-	vport->ingress.allow_untagged_only_grp = NULL;
+	vport->ingress.allow_tagged_spoofchk_grp = NULL;
 	vport->ingress.allow_untagged_spoofchk_grp = NULL;
 }
 
 static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				    struct mlx5_vport *vport)
 {
+	bool need_vlan_filter = !!bitmap_weight(vport->info.vlan_trunk_8021q_bitmap,
+						VLAN_N_VID);
+	struct mlx5_acl_vlan *trunk_vlan_rule;
 	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
+	bool need_acl_table = true;
+	u16 vlan_id = 0;
 	int err = 0;
 	u8 *smac_v;
 
@@ -1133,9 +1236,19 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		return -EPERM;
 	}
 
+	if ((vport->info.vlan || vport->info.qos) && need_vlan_filter) {
+		mlx5_core_warn(esw->dev,
+			       "vport[%d] configure ingress rules failed, Cannot enable both VGT+ and VST\n",
+			       vport->vport);
+		return -EPERM;
+	}
+
+	need_acl_table = vport->info.vlan || vport->info.qos || vport->info.spoofchk
+			|| need_vlan_filter;
+
 	esw_vport_cleanup_ingress_rules(esw, vport);
 
-	if (!vport->info.vlan && !vport->info.qos && !vport->info.spoofchk) {
+	if (!need_acl_table) {
 		esw_vport_disable_ingress_acl(esw, vport);
 		return 0;
 	}
@@ -1158,7 +1271,10 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		goto out;
 	}
 
-	if (vport->info.vlan || vport->info.qos)
+	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
+
+	if (vport->info.vlan || vport->info.qos || need_vlan_filter)
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
 
 	if (vport->info.spoofchk) {
@@ -1170,20 +1286,53 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		ether_addr_copy(smac_v, vport->info.mac);
 	}
 
-	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
-	vport->ingress.allow_rule =
-		mlx5_add_flow_rules(vport->ingress.acl, spec,
-				    &flow_act, NULL, 0);
-	if (IS_ERR(vport->ingress.allow_rule)) {
-		err = PTR_ERR(vport->ingress.allow_rule);
-		esw_warn(esw->dev,
-			 "vport[%d] configure ingress allow rule, err(%d)\n",
-			 vport->vport, err);
-		vport->ingress.allow_rule = NULL;
-		goto out;
+	/* Allow untagged */
+	if (!need_vlan_filter ||
+	    (need_vlan_filter && test_bit(0, vport->info.vlan_trunk_8021q_bitmap))) {
+		vport->ingress.allow_untagged_rule =
+			mlx5_add_flow_rules(vport->ingress.acl, spec,
+					    &flow_act, NULL, 0);
+		if (IS_ERR(vport->ingress.allow_untagged_rule)) {
+			err = PTR_ERR(vport->ingress.allow_untagged_rule);
+			esw_warn(esw->dev,
+				 "vport[%d] configure ingress allow rule, err(%d)\n",
+				 vport->vport, err);
+			vport->ingress.allow_untagged_rule = NULL;
+			goto out;
+		}
+	}
+
+	if (!need_vlan_filter)
+		goto drop_rule;
+
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.first_vid);
+
+	/* VGT+ rules */
+	for_each_set_bit(vlan_id, vport->acl_vlan_8021q_bitmap, VLAN_N_VID) {
+		trunk_vlan_rule = kzalloc(sizeof(*trunk_vlan_rule), GFP_KERNEL);
+		if (!trunk_vlan_rule) {
+			err = -ENOMEM;
+			goto out;
+		}
+
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid,
+			 vlan_id);
+		trunk_vlan_rule->acl_vlan_rule =
+			mlx5_add_flow_rules(vport->ingress.acl, spec, &flow_act, NULL, 0);
+		if (IS_ERR(trunk_vlan_rule->acl_vlan_rule)) {
+			err = PTR_ERR(trunk_vlan_rule->acl_vlan_rule);
+			esw_warn(esw->dev,
+				 "vport[%d] configure ingress allowed vlan rule failed, err(%d)\n",
+				 vport->vport, err);
+			trunk_vlan_rule->acl_vlan_rule = NULL;
+			goto out;
+		}
+		list_add(&trunk_vlan_rule->list, &vport->ingress.allowed_vlans_rules);
 	}
 
+drop_rule:
 	memset(spec, 0, sizeof(*spec));
 	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
 	vport->ingress.drop_rule =
@@ -1208,13 +1357,19 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   struct mlx5_vport *vport)
 {
+	bool need_vlan_filter = !!bitmap_weight(vport->info.vlan_trunk_8021q_bitmap,
+						VLAN_N_VID);
+	bool need_acl_table = vport->info.vlan || vport->info.qos ||
+			      need_vlan_filter;
+	struct mlx5_acl_vlan *trunk_vlan_rule;
 	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
+	u16 vlan_id = 0;
 	int err = 0;
 
 	esw_vport_cleanup_egress_rules(esw, vport);
 
-	if (!vport->info.vlan && !vport->info.qos) {
+	if (!need_acl_table) {
 		esw_vport_disable_egress_acl(esw, vport);
 		return 0;
 	}
@@ -1237,24 +1392,66 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 		goto out;
 	}
 
-	/* Allowed vlan rule */
 	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
+	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
+
+	/* Allow untagged */
+	if (need_vlan_filter && test_bit(0, vport->info.vlan_trunk_8021q_bitmap)) {
+		vport->egress.allow_untagged_rule =
+			mlx5_add_flow_rules(vport->egress.acl, spec,
+					    &flow_act, NULL, 0);
+		if (IS_ERR(vport->egress.allow_untagged_rule)) {
+			err = PTR_ERR(vport->egress.allow_untagged_rule);
+			esw_warn(esw->dev,
+				 "vport[%d] configure egress allow rule, err(%d)\n",
+				 vport->vport, err);
+			vport->egress.allow_untagged_rule = NULL;
+		}
+	}
+
+	/* Allowed vlan rule */
 	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.first_vid);
-	MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid, vport->info.vlan);
 
-	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_ALLOW;
-	vport->egress.allowed_vlan =
-		mlx5_add_flow_rules(vport->egress.acl, spec,
-				    &flow_act, NULL, 0);
-	if (IS_ERR(vport->egress.allowed_vlan)) {
-		err = PTR_ERR(vport->egress.allowed_vlan);
-		esw_warn(esw->dev,
-			 "vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
-			 vport->vport, err);
-		vport->egress.allowed_vlan = NULL;
-		goto out;
+	/* VST rule */
+	if (vport->info.vlan || vport->info.qos) {
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid, vport->info.vlan);
+
+		vport->egress.allowed_vst_vlan =
+			mlx5_add_flow_rules(vport->egress.acl, spec,
+					    &flow_act, NULL, 0);
+		if (IS_ERR(vport->egress.allowed_vst_vlan)) {
+			err = PTR_ERR(vport->egress.allowed_vst_vlan);
+			esw_warn(esw->dev,
+				 "vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
+				 vport->vport, err);
+			vport->egress.allowed_vst_vlan = NULL;
+			goto out;
+		}
+	}
+
+	/* VGT+ rules */
+	for_each_set_bit(vlan_id, vport->acl_vlan_8021q_bitmap, VLAN_N_VID) {
+		trunk_vlan_rule = kzalloc(sizeof(*trunk_vlan_rule), GFP_KERNEL);
+		if (!trunk_vlan_rule) {
+			err = -ENOMEM;
+			goto out;
+		}
+
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid,
+			 vlan_id);
+		trunk_vlan_rule->acl_vlan_rule =
+			mlx5_add_flow_rules(vport->egress.acl, spec, &flow_act, NULL, 0);
+		if (IS_ERR(trunk_vlan_rule->acl_vlan_rule)) {
+			err = PTR_ERR(trunk_vlan_rule->acl_vlan_rule);
+			esw_warn(esw->dev,
+				 "vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
+				 vport->vport, err);
+			trunk_vlan_rule->acl_vlan_rule = NULL;
+			goto out;
+		}
+		list_add(&trunk_vlan_rule->list, &vport->egress.allowed_vlans_rules);
 	}
 
 	/* Drop others rule (star rule) */
@@ -1271,6 +1468,8 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 		vport->egress.drop_rule = NULL;
 	}
 out:
+	if (err)
+		esw_vport_cleanup_egress_rules(esw, vport);
 	kvfree(spec);
 	return err;
 }
@@ -1465,6 +1664,11 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 
 	esw_debug(esw->dev, "Enabling VPORT(%d)\n", vport_num);
 
+	bitmap_zero(vport->req_vlan_bitmap, VLAN_N_VID);
+	bitmap_zero(vport->acl_vlan_8021q_bitmap, VLAN_N_VID);
+	bitmap_zero(vport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
+	INIT_LIST_HEAD(&vport->egress.allowed_vlans_rules);
+	INIT_LIST_HEAD(&vport->ingress.allowed_vlans_rules);
 	/* Restore old vport configuration */
 	esw_apply_vport_conf(esw, vport);
 
@@ -1824,6 +2028,8 @@ int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 	ivi->trusted = evport->info.trusted;
 	ivi->min_tx_rate = evport->info.min_rate;
 	ivi->max_tx_rate = evport->info.max_rate;
+	bitmap_copy((unsigned long *)ivi->trunk_8021q,
+		    evport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
 	mutex_unlock(&esw->state_lock);
 
 	return 0;
@@ -1843,6 +2049,14 @@ int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 	mutex_lock(&esw->state_lock);
 	evport = &esw->vports[vport];
 
+	if (bitmap_weight(evport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID)) {
+		err = -EPERM;
+		mlx5_core_warn(esw->dev,
+			       "VST is not allowed when operating in VGT+ mode vport(%d)\n",
+			       vport);
+		goto unlock;
+	}
+
 	err = modify_esw_vport_cvlan(esw->dev, vport, vlan, qos, set_flags);
 	if (err)
 		goto unlock;
@@ -2018,6 +2232,90 @@ int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw, int vport,
 	return err;
 }
 
+static int mlx5_eswitch_update_vport_trunk(struct mlx5_eswitch *esw,
+					   struct mlx5_vport *evport,
+					   unsigned long *old_trunk) {
+	DECLARE_BITMAP(diff_vlan_bm, VLAN_N_VID);
+	int err = 0;
+
+	bitmap_xor(diff_vlan_bm, old_trunk,
+		   evport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
+	if (!bitmap_weight(diff_vlan_bm, VLAN_N_VID))
+		return err;
+
+	esw_update_acl_trunk_bitmap(esw, evport->vport);
+	if (evport->enabled && esw->mode == SRIOV_LEGACY) {
+		err = esw_vport_egress_config(esw, evport);
+		if (!err)
+			err = esw_vport_ingress_config(esw, evport);
+	}
+	if (err) {
+		bitmap_copy(evport->info.vlan_trunk_8021q_bitmap, old_trunk, VLAN_N_VID);
+		esw_update_acl_trunk_bitmap(esw, evport->vport);
+		esw_vport_egress_config(esw, evport);
+		esw_vport_ingress_config(esw, evport);
+	}
+
+	return err;
+}
+
+int mlx5_eswitch_add_vport_trunk_range(struct mlx5_eswitch *esw,
+				       int vport, u16 start_vlan, u16 end_vlan)
+{
+	DECLARE_BITMAP(prev_vport_bitmap, VLAN_N_VID);
+	struct mlx5_vport *evport;
+	int err = 0;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport) || end_vlan > VLAN_N_VID || start_vlan > end_vlan)
+		return -EINVAL;
+
+	mutex_lock(&esw->state_lock);
+	evport = &esw->vports[vport];
+
+	if (evport->info.vlan || evport->info.qos) {
+		err = -EPERM;
+		mlx5_core_warn(esw->dev,
+			       "VGT+ is not allowed when operating in VST mode vport(%d)\n",
+			       vport);
+		goto unlock;
+	}
+
+	bitmap_copy(prev_vport_bitmap, evport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
+	bitmap_set(evport->info.vlan_trunk_8021q_bitmap, start_vlan,
+		   end_vlan - start_vlan + 1);
+	err = mlx5_eswitch_update_vport_trunk(esw, evport, prev_vport_bitmap);
+
+unlock:
+	mutex_unlock(&esw->state_lock);
+
+	return err;
+}
+
+int mlx5_eswitch_del_vport_trunk_range(struct mlx5_eswitch *esw,
+				       int vport, u16 start_vlan, u16 end_vlan)
+{
+	DECLARE_BITMAP(prev_vport_bitmap, VLAN_N_VID);
+	struct mlx5_vport *evport;
+	int err = 0;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport) || end_vlan > VLAN_N_VID || start_vlan > end_vlan)
+		return -EINVAL;
+
+	mutex_lock(&esw->state_lock);
+	evport = &esw->vports[vport];
+	bitmap_copy(prev_vport_bitmap, evport->info.vlan_trunk_8021q_bitmap, VLAN_N_VID);
+	bitmap_clear(evport->info.vlan_trunk_8021q_bitmap, start_vlan,
+		     end_vlan - start_vlan + 1);
+	err = mlx5_eswitch_update_vport_trunk(esw, evport, prev_vport_bitmap);
+	mutex_unlock(&esw->state_lock);
+
+	return err;
+}
+
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 565c8b7a399a..39ac2037b666 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -35,6 +35,8 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_link.h>
+#include <linux/if_vlan.h>
+#include <linux/bitmap.h>
 #include <net/devlink.h>
 #include <linux/mlx5/device.h>
 #include "lib/mpfs.h"
@@ -53,6 +55,9 @@ enum {
 #define MLX5_MAX_MC_PER_VPORT(dev) \
 	(1 << MLX5_CAP_GEN(dev, log_max_current_mc_list))
 
+#define MLX5_MAX_VLAN_PER_VPORT(dev) \
+	(1 << MLX5_CAP_GEN(dev, log_max_vlan_list))
+
 #define FDB_UPLINK_VPORT 0xffff
 
 #define MLX5_MIN_BW_SHARE 1
@@ -63,19 +68,22 @@ enum {
 struct vport_ingress {
 	struct mlx5_flow_table *acl;
 	struct mlx5_flow_group *allow_untagged_spoofchk_grp;
-	struct mlx5_flow_group *allow_spoofchk_only_grp;
-	struct mlx5_flow_group *allow_untagged_only_grp;
+	struct mlx5_flow_group *allow_tagged_spoofchk_grp;
 	struct mlx5_flow_group *drop_grp;
-	struct mlx5_flow_handle  *allow_rule;
+	struct mlx5_flow_handle  *allow_untagged_rule;
+	struct list_head         allowed_vlans_rules;
 	struct mlx5_flow_handle  *drop_rule;
 };
 
 struct vport_egress {
 	struct mlx5_flow_table *acl;
+	struct mlx5_flow_group *allow_untagged_grp;
 	struct mlx5_flow_group *allowed_vlans_grp;
 	struct mlx5_flow_group *drop_grp;
-	struct mlx5_flow_handle  *allowed_vlan;
+	struct mlx5_flow_handle  *allowed_vst_vlan;
 	struct mlx5_flow_handle  *drop_rule;
+	struct mlx5_flow_handle  *allow_untagged_rule;
+	struct list_head        allowed_vlans_rules;
 };
 
 struct mlx5_vport_info {
@@ -88,6 +96,8 @@ struct mlx5_vport_info {
 	u32                     max_rate;
 	bool                    spoofchk;
 	bool                    trusted;
+	/* the admin approved vlan list */
+	DECLARE_BITMAP(vlan_trunk_8021q_bitmap, VLAN_N_VID);
 };
 
 struct mlx5_vport {
@@ -95,6 +105,10 @@ struct mlx5_vport {
 	int                     vport;
 	struct hlist_head       uc_list[MLX5_L2_ADDR_HASH_SIZE];
 	struct hlist_head       mc_list[MLX5_L2_ADDR_HASH_SIZE];
+	/* The requested vlan list from the vport side */
+	DECLARE_BITMAP(req_vlan_bitmap, VLAN_N_VID);
+	/* Actual accepted vlans on the acl tables */
+	DECLARE_BITMAP(acl_vlan_8021q_bitmap, VLAN_N_VID);
 	struct mlx5_flow_handle *promisc_rule;
 	struct mlx5_flow_handle *allmulti_rule;
 	struct work_struct      vport_change_handler;
@@ -133,6 +147,11 @@ struct mlx5_eswitch_fdb {
 	};
 };
 
+struct mlx5_acl_vlan {
+	struct mlx5_flow_handle	*acl_vlan_rule;
+	struct list_head	list;
+};
+
 struct mlx5_esw_sq {
 	struct mlx5_flow_handle	*send_to_vport_rule;
 	struct list_head	 list;
@@ -218,6 +237,10 @@ int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw, int vport,
 				u32 max_rate, u32 min_rate);
 int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 				  int vport, struct ifla_vf_info *ivi);
+int mlx5_eswitch_add_vport_trunk_range(struct mlx5_eswitch *esw,
+				       int vport, u16 start_vlan, u16 end_vlan);
+int mlx5_eswitch_del_vport_trunk_range(struct mlx5_eswitch *esw,
+				       int vport, u16 start_vlan, u16 end_vlan);
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 5abfec1c3399..c3afc7af6280 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -381,28 +381,18 @@ int mlx5_modify_nic_vport_mac_list(struct mlx5_core_dev *dev,
 }
 EXPORT_SYMBOL_GPL(mlx5_modify_nic_vport_mac_list);
 
-int mlx5_query_nic_vport_vlans(struct mlx5_core_dev *dev,
-			       u32 vport,
-			       u16 vlans[],
-			       int *size)
+int mlx5_query_nic_vport_vlans(struct mlx5_core_dev *dev, u32 vport,
+			       unsigned long *vlans)
 {
 	u32 in[MLX5_ST_SZ_DW(query_nic_vport_context_in)];
 	void *nic_vport_ctx;
 	int req_list_size;
-	int max_list_size;
 	int out_sz;
 	void *out;
 	int err;
 	int i;
 
-	req_list_size = *size;
-	max_list_size = 1 << MLX5_CAP_GEN(dev, log_max_vlan_list);
-	if (req_list_size > max_list_size) {
-		mlx5_core_warn(dev, "Requested list size (%d) > (%d) max list size\n",
-			       req_list_size, max_list_size);
-		req_list_size = max_list_size;
-	}
-
+	req_list_size = 1 << MLX5_CAP_GEN(dev, log_max_vlan_list);
 	out_sz = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in) +
 			req_list_size * MLX5_ST_SZ_BYTES(vlan_layout);
 
@@ -429,12 +419,11 @@ int mlx5_query_nic_vport_vlans(struct mlx5_core_dev *dev,
 	req_list_size = MLX5_GET(nic_vport_context, nic_vport_ctx,
 				 allowed_list_size);
 
-	*size = req_list_size;
 	for (i = 0; i < req_list_size; i++) {
 		void *vlan_addr = MLX5_ADDR_OF(nic_vport_context,
 					       nic_vport_ctx,
 					       current_uc_mac_address[i]);
-		vlans[i] = MLX5_GET(vlan_layout, vlan_addr, vlan);
+		bitmap_set(vlans, MLX5_GET(vlan_layout, vlan_addr, vlan), 1);
 	}
 out:
 	kfree(out);
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 656c70b65dd2..a285bd04eefb 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -97,10 +97,8 @@ int mlx5_modify_nic_vport_promisc(struct mlx5_core_dev *mdev,
 				  int promisc_uc,
 				  int promisc_mc,
 				  int promisc_all);
-int mlx5_query_nic_vport_vlans(struct mlx5_core_dev *dev,
-			       u32 vport,
-			       u16 vlans[],
-			       int *size);
+int mlx5_query_nic_vport_vlans(struct mlx5_core_dev *dev, u32 vport,
+			       unsigned long *vlans);
 int mlx5_modify_nic_vport_vlans(struct mlx5_core_dev *dev,
 				u16 vlans[],
 				int list_size);
-- 
2.13.0
