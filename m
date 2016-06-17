From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/18] net/mlx5: Add support to add/del flow rule notifiers
Date: Fri, 17 Jun 2016 17:43:46 +0300
Message-ID: <1466174639-14576-6-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57444 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752696AbcFQOr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:27 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Use kernel notifier block API in order to notifiy user when new rule
is added/deleted to/from namespace. Once a new listener is registered
we will fire add rule notification on all the existing rules.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 215 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  15 ++
 include/linux/mlx5/fs.h                           |  20 ++
 3 files changed, 247 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 06f94bf..6ef7b99 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -164,10 +164,10 @@ static void tree_get_node(struct fs_node *node)
 }
 
 static void nested_lock_ref_node(struct fs_node *node,
-				 enum fs_i_mutex_lock_class class)
+				 int nesting)
 {
 	if (node) {
-		mutex_lock_nested(&node->lock, class);
+		mutex_lock_nested(&node->lock, nesting);
 		atomic_inc(&node->refcount);
 	}
 }
@@ -363,6 +363,8 @@ static void del_flow_table(struct fs_node *node)
 
 static void del_rule(struct fs_node *node)
 {
+	struct rule_client_data *priv_data;
+	struct rule_client_data *tmp;
 	struct mlx5_flow_rule *rule;
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
@@ -380,6 +382,12 @@ static void del_rule(struct fs_node *node)
 	}
 
 	fs_get_obj(rule, node);
+
+	list_for_each_entry_safe(priv_data, tmp, &rule->clients_data, list) {
+		list_del(&priv_data->list);
+		kfree(priv_data);
+	}
+
 	fs_get_obj(fte, rule->node.parent);
 	fs_get_obj(fg, fte->node.parent);
 	memcpy(match_value, fte->val, sizeof(fte->val));
@@ -896,6 +904,8 @@ static struct mlx5_flow_rule *alloc_rule(struct mlx5_flow_destination *dest)
 	INIT_LIST_HEAD(&rule->next_ft);
 	atomic_set(&rule->refcount, 1);
 	rule->node.type = FS_TYPE_FLOW_DEST;
+	INIT_LIST_HEAD(&rule->clients_data);
+	mutex_init(&rule->clients_lock);
 	if (dest)
 		memcpy(&rule->dest_attr, dest, sizeof(*dest));
 
@@ -1070,6 +1080,52 @@ static struct mlx5_flow_rule *find_flow_rule(struct fs_fte *fte,
 	return NULL;
 }
 
+static struct mlx5_flow_namespace *get_ns(struct fs_node *node)
+{
+	struct mlx5_flow_namespace *ns = NULL;
+
+	while (node  && (node->type != FS_TYPE_NAMESPACE))
+		node = node->parent;
+
+	if (node)
+		fs_get_obj(ns, node);
+
+	return ns;
+}
+
+static void get_event_data(struct mlx5_flow_rule *rule, struct mlx5_event_data
+			   *data)
+{
+	struct mlx5_flow_group *fg;
+	struct mlx5_flow_table *ft;
+	struct fs_fte *fte;
+
+	data->rule = rule;
+
+	fs_get_obj(fte, rule->node.parent);
+	WARN_ON(!fte);
+	fs_get_obj(fg, fte->node.parent);
+	WARN_ON(!fg);
+	fs_get_obj(ft, fg->node.parent);
+	WARN_ON(!ft);
+	data->ft = ft;
+}
+
+static void notify_add_rule(struct mlx5_flow_rule *rule)
+{
+	struct mlx5_event_data evt_data;
+	struct mlx5_flow_namespace *ns;
+	struct fs_fte *fte;
+
+	fs_get_obj(fte, rule->node.parent);
+	ns = get_ns(&fte->node);
+	if (!ns)
+		return;
+
+	get_event_data(rule, &evt_data);
+	raw_notifier_call_chain(&ns->listeners, MLX5_RULE_EVENT_ADD, &evt_data);
+}
+
 static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 					  u32 *match_value,
 					  u8 action,
@@ -1126,6 +1182,7 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 	list_add(&fte->node.list, prev);
 add_rule:
 	tree_add_node(&rule->node, &fte->node);
+	notify_add_rule(rule);
 unlock_fg:
 	unlock_ref_node(&fg->node);
 	return rule;
@@ -1238,6 +1295,7 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 	struct mlx5_flow_rule *rule = NULL;
 	u32 sw_action = attr->action;
 	struct fs_prio *prio;
+	struct mlx5_flow_namespace *ns;
 
 	fs_get_obj(prio, ft->node.parent);
 	if (attr->action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
@@ -1258,8 +1316,10 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		}
 	}
 
+	ns = get_ns(&ft->node);
+	if (ns)
+		down_read(&ns->ns_rw_sem);
 	rule =	_mlx5_add_flow_rule(ft, attr);
-
 	if (sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
 		if (!IS_ERR_OR_NULL(rule) &&
 		    (list_empty(&rule->next_ft))) {
@@ -1270,15 +1330,41 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		}
 		mutex_unlock(&root->chain_lock);
 	}
+	if (ns)
+		up_read(&ns->ns_rw_sem);
+
 	return rule;
 }
 EXPORT_SYMBOL(mlx5_add_flow_rule);
 
+static void notify_del_rule(struct mlx5_flow_rule *rule)
+{
+	struct mlx5_flow_namespace *ns;
+	struct mlx5_event_data evt_data;
+	struct fs_fte *fte;
+
+	fs_get_obj(fte, rule->node.parent);
+	ns = get_ns(&fte->node);
+	if (!ns)
+		return;
+
+	get_event_data(rule, &evt_data);
+	raw_notifier_call_chain(&ns->listeners, MLX5_RULE_EVENT_DEL, &evt_data);
+}
+
 void mlx5_del_flow_rule(struct mlx5_flow_rule *rule)
 {
+	struct mlx5_flow_namespace *ns;
+
 	if (!atomic_dec_and_test(&rule->refcount))
 		return;
+	ns = get_ns(&rule->node);
+	if (ns)
+		down_read(&ns->ns_rw_sem);
+	notify_del_rule(rule);
 	tree_remove_node(&rule->node);
+	if (ns)
+		up_read(&ns->ns_rw_sem);
 }
 EXPORT_SYMBOL(mlx5_del_flow_rule);
 
@@ -1453,6 +1539,8 @@ static struct mlx5_flow_namespace *fs_init_namespace(struct mlx5_flow_namespace
 {
 	ns->node.type = FS_TYPE_NAMESPACE;
 
+	init_rwsem(&ns->ns_rw_sem);
+
 	return ns;
 }
 
@@ -1823,3 +1911,124 @@ void mlx5_put_flow_rule(struct mlx5_flow_rule *rule)
 {
 	tree_put_node(&rule->node);
 }
+
+static void notify_existing_rules_recursive(struct fs_node *root,
+					    struct notifier_block *nb,
+					    int nesting)
+{
+	struct mlx5_event_data data;
+	struct fs_node *iter;
+
+	nested_lock_ref_node(root, nesting++);
+	if (root->type == FS_TYPE_FLOW_ENTRY) {
+		struct mlx5_flow_rule *rule;
+		int err = 0;
+
+		/* Iterate on destinations */
+		list_for_each_entry(iter, &root->children, list) {
+			fs_get_obj(rule, iter);
+			get_event_data(rule, &data);
+			err = nb->notifier_call(nb, MLX5_RULE_EVENT_ADD, &data);
+			if (err)
+				break;
+		}
+	} else {
+		list_for_each_entry(iter, &root->children, list)
+			notify_existing_rules_recursive(iter, nb, nesting);
+	}
+	unlock_ref_node(root);
+}
+
+static void mlx5_flow_notify_existing_rules(struct mlx5_flow_namespace *ns,
+					    struct notifier_block *nb)
+{
+	notify_existing_rules_recursive(&ns->node, nb, 0);
+}
+
+int mlx5_register_rule_notifier(struct mlx5_flow_namespace *ns,
+				struct notifier_block *nb)
+{
+	int err;
+
+	down_write(&ns->ns_rw_sem);
+	mlx5_flow_notify_existing_rules(ns, nb);
+	err = raw_notifier_chain_register(&ns->listeners, nb);
+	up_write(&ns->ns_rw_sem);
+
+	return err;
+}
+
+int mlx5_unregister_rule_notifier(struct mlx5_flow_namespace *ns,
+				  struct notifier_block *nb)
+{
+	int err;
+
+	down_write(&ns->ns_rw_sem);
+	err = raw_notifier_chain_unregister(&ns->listeners, nb);
+	up_write(&ns->ns_rw_sem);
+
+	return err;
+}
+
+void *mlx5_get_rule_private_data(struct mlx5_flow_rule *rule,
+				 struct notifier_block *nb)
+{
+	struct rule_client_data *priv_data;
+	void *data = NULL;
+
+	mutex_lock(&rule->clients_lock);
+	list_for_each_entry(priv_data, &rule->clients_data, list) {
+		if (priv_data->nb == nb) {
+			data = priv_data->client_data;
+			break;
+		}
+	}
+	mutex_unlock(&rule->clients_lock);
+
+	return data;
+}
+
+void mlx5_release_rule_private_data(struct mlx5_flow_rule *rule,
+				    struct notifier_block *nb)
+{
+	struct rule_client_data *priv_data;
+	struct rule_client_data *tmp;
+
+	mutex_lock(&rule->clients_lock);
+	list_for_each_entry_safe(priv_data, tmp, &rule->clients_data, list) {
+		if (priv_data->nb == nb) {
+			list_del(&priv_data->list);
+			break;
+		}
+	}
+	mutex_unlock(&rule->clients_lock);
+}
+
+int mlx5_set_rule_private_data(struct mlx5_flow_rule *rule,
+			       struct notifier_block *nb,
+			       void  *client_data)
+{
+	struct rule_client_data *priv_data;
+
+	mutex_lock(&rule->clients_lock);
+	list_for_each_entry(priv_data, &rule->clients_data, list) {
+		if (priv_data->nb == nb) {
+			priv_data->client_data = client_data;
+			goto unlock;
+		}
+	}
+	priv_data = kzalloc(sizeof(*priv_data), GFP_KERNEL);
+	if (!priv_data) {
+		mutex_unlock(&rule->clients_lock);
+		return -ENOMEM;
+	}
+
+	priv_data->client_data = client_data;
+	priv_data->nb = nb;
+	list_add(&priv_data->list, &rule->clients_data);
+
+unlock:
+	mutex_unlock(&rule->clients_lock);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 29dd9e0..dc08742 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -85,6 +85,9 @@ struct mlx5_flow_rule {
 	struct list_head			next_ft;
 	u32					sw_action;
 	atomic_t				refcount;
+	struct list_head			clients_data;
+	/* Protect clients data list */
+	struct mutex				clients_lock;
 };
 
 /* Type of children is mlx5_flow_group */
@@ -153,6 +156,12 @@ struct fs_prio {
 struct mlx5_flow_namespace {
 	/* parent == NULL => root ns */
 	struct	fs_node			node;
+	/* Listeners list for rule add/del operations */
+	struct raw_notifier_head	listeners;
+	/* We take write lock when we iterate on the
+	 * namespace's rules.
+	 */
+	struct  rw_semaphore		ns_rw_sem;
 };
 
 struct mlx5_flow_group_mask {
@@ -182,6 +191,12 @@ struct mlx5_flow_root_namespace {
 int mlx5_init_fc_stats(struct mlx5_core_dev *dev);
 void mlx5_cleanup_fc_stats(struct mlx5_core_dev *dev);
 
+struct rule_client_data {
+	struct notifier_block *nb;
+	struct list_head list;
+	void   *client_data;
+};
+
 int mlx5_init_fs(struct mlx5_core_dev *dev);
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev);
 
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 37e13a1..5ac0e8f 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -152,4 +152,24 @@ void mlx5_fc_query_cached(struct mlx5_fc *counter,
 void mlx5_get_flow_rule(struct mlx5_flow_rule *rule);
 void mlx5_put_flow_rule(struct mlx5_flow_rule *rule);
 
+enum {
+	MLX5_RULE_EVENT_ADD,
+	MLX5_RULE_EVENT_DEL,
+};
+
+int mlx5_set_rule_private_data(struct mlx5_flow_rule *rule,
+			       struct notifier_block *nb, void *client_data);
+void *mlx5_get_rule_private_data(struct mlx5_flow_rule *rule,
+				 struct notifier_block *nb);
+void mlx5_release_rule_private_data(struct mlx5_flow_rule *rule,
+				    struct notifier_block *nb);
+
+int mlx5_register_rule_notifier(struct mlx5_flow_namespace *ns,
+				struct notifier_block *nb);
+int mlx5_unregister_rule_notifier(struct mlx5_flow_namespace *ns,
+				  struct notifier_block *nb);
+struct mlx5_event_data {
+	struct mlx5_flow_table *ft;
+	struct mlx5_flow_rule *rule;
+};
 #endif
-- 
2.8.0
