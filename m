From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 3/9] net/mlx5e: Add cache for HW modify header IDs
Date: Sun, 11 Jun 2017 17:55:47 +0300
Message-ID: <20170611145553.14180-4-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46635 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751911AbdFKO4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:10 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Packets belonging to flows which are different by matching may still need
to go through the same header re-write. Add a cache for header re-write IDs
keyed by the binary chain of modify header actions.

The caching is supported for both eswitch and NIC use-cases, where the
actual conversion of the code to use caching comes in next patches, one
per use-case.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 134 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |   1 +
 4 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 2fd044b23875..f4b95dbd1c7f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -623,6 +623,8 @@ struct mlx5e_tc_table {
 
 	struct rhashtable_params        ht_params;
 	struct rhashtable               ht;
+
+	DECLARE_HASHTABLE(mod_hdr_tbl, 8);
 };
 
 struct mlx5e_vlan_table {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a9feddc31667..e1217c2279ab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -69,7 +69,8 @@ struct mlx5e_tc_flow {
 	u64			cookie;
 	u8			flags;
 	struct mlx5_flow_handle *rule;
-	struct list_head	encap; /* flows sharing the same encap */
+	struct list_head	encap;   /* flows sharing the same encap ID */
+	struct list_head	mod_hdr; /* flows sharing the same mod hdr ID */
 	union {
 		struct mlx5_esw_flow_attr esw_attr[0];
 		struct mlx5_nic_flow_attr nic_attr[0];
@@ -90,6 +91,135 @@ enum {
 #define MLX5E_TC_TABLE_NUM_ENTRIES 1024
 #define MLX5E_TC_TABLE_NUM_GROUPS 4
 
+struct mod_hdr_key {
+	int num_actions;
+	void *actions;
+};
+
+struct mlx5e_mod_hdr_entry {
+	/* a node of a hash table which keeps all the mod_hdr entries */
+	struct hlist_node mod_hdr_hlist;
+
+	/* flows sharing the same mod_hdr entry */
+	struct list_head flows;
+
+	struct mod_hdr_key key;
+
+	u32 mod_hdr_id;
+};
+
+#define MLX5_MH_ACT_SZ MLX5_UN_SZ_BYTES(set_action_in_add_action_in_auto)
+
+static inline u32 hash_mod_hdr_info(struct mod_hdr_key *key)
+{
+	return jhash(key->actions,
+		     key->num_actions * MLX5_MH_ACT_SZ, 0);
+}
+
+static inline int cmp_mod_hdr_info(struct mod_hdr_key *a,
+				   struct mod_hdr_key *b)
+{
+	if (a->num_actions != b->num_actions)
+		return 1;
+
+	return memcmp(a->actions, b->actions, a->num_actions * MLX5_MH_ACT_SZ);
+}
+
+static int mlx5e_attach_mod_hdr(struct mlx5e_priv *priv,
+				struct mlx5e_tc_flow *flow,
+				struct mlx5e_tc_flow_parse_attr *parse_attr)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	int num_actions, actions_size, namespace, err;
+	struct mlx5e_mod_hdr_entry *mh;
+	struct mod_hdr_key key;
+	bool found = false;
+	u32 hash_key;
+
+	num_actions  = parse_attr->num_mod_hdr_actions;
+	actions_size = MLX5_MH_ACT_SZ * num_actions;
+
+	key.actions = parse_attr->mod_hdr_actions;
+	key.num_actions = num_actions;
+
+	hash_key = hash_mod_hdr_info(&key);
+
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
+		namespace = MLX5_FLOW_NAMESPACE_FDB;
+		hash_for_each_possible(esw->offloads.mod_hdr_tbl, mh,
+				       mod_hdr_hlist, hash_key) {
+			if (!cmp_mod_hdr_info(&mh->key, &key)) {
+				found = true;
+				break;
+			}
+		}
+	} else {
+		namespace = MLX5_FLOW_NAMESPACE_KERNEL;
+		hash_for_each_possible(priv->fs.tc.mod_hdr_tbl, mh,
+				       mod_hdr_hlist, hash_key) {
+			if (!cmp_mod_hdr_info(&mh->key, &key)) {
+				found = true;
+				break;
+			}
+		}
+	}
+
+	if (found)
+		goto attach_flow;
+
+	mh = kzalloc(sizeof(*mh) + actions_size, GFP_KERNEL);
+	if (!mh)
+		return -ENOMEM;
+
+	mh->key.actions = (void *)mh + sizeof(*mh);
+	memcpy(mh->key.actions, key.actions, actions_size);
+	mh->key.num_actions = num_actions;
+	INIT_LIST_HEAD(&mh->flows);
+
+	err = mlx5_modify_header_alloc(priv->mdev, namespace,
+				       mh->key.num_actions,
+				       mh->key.actions,
+				       &mh->mod_hdr_id);
+	if (err)
+		goto out_err;
+
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH)
+		hash_add(esw->offloads.mod_hdr_tbl, &mh->mod_hdr_hlist, hash_key);
+	else
+		hash_add(priv->fs.tc.mod_hdr_tbl, &mh->mod_hdr_hlist, hash_key);
+
+attach_flow:
+	list_add(&flow->mod_hdr, &mh->flows);
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH)
+		flow->esw_attr->mod_hdr_id = mh->mod_hdr_id;
+	else
+		flow->nic_attr->mod_hdr_id = mh->mod_hdr_id;
+
+	return 0;
+
+out_err:
+	kfree(mh);
+	return err;
+}
+
+static void mlx5e_detach_mod_hdr(struct mlx5e_priv *priv,
+				 struct mlx5e_tc_flow *flow)
+{
+	struct list_head *next = flow->mod_hdr.next;
+
+	list_del(&flow->mod_hdr);
+
+	if (list_empty(next)) {
+		struct mlx5e_mod_hdr_entry *mh;
+
+		mh = list_entry(next, struct mlx5e_mod_hdr_entry, flows);
+
+		mlx5_modify_header_dealloc(priv->mdev, mh->mod_hdr_id);
+		hash_del(&mh->mod_hdr_hlist);
+		kfree(mh);
+	}
+}
+
 static struct mlx5_flow_handle *
 mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		      struct mlx5e_tc_flow_parse_attr *parse_attr,
@@ -1939,6 +2069,8 @@ int mlx5e_tc_init(struct mlx5e_priv *priv)
 {
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
 
+	hash_init(tc->mod_hdr_tbl);
+
 	tc->ht_params = mlx5e_tc_flow_ht_params;
 	return rhashtable_init(&tc->ht, &tc->ht_params);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 81dfcd90b1f5..37927156f258 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1769,6 +1769,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	}
 
 	hash_init(esw->offloads.encap_tbl);
+	hash_init(esw->offloads.mod_hdr_tbl);
 	mutex_init(&esw->state_lock);
 
 	for (vport_num = 0; vport_num < total_vports; vport_num++) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b746f62c8c79..834a33050969 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -207,6 +207,7 @@ struct mlx5_esw_offload {
 	struct mlx5_flow_group *vport_rx_group;
 	struct mlx5_eswitch_rep *vport_reps;
 	DECLARE_HASHTABLE(encap_tbl, 8);
+	DECLARE_HASHTABLE(mod_hdr_tbl, 8);
 	u8 inline_mode;
 	u64 num_flows;
 	u8 encap;
-- 
2.11.0
