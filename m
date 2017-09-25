From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/10] mlxsw: spectrum_dpipe: Add support for adjacency table dump
Date: Mon, 25 Sep 2017 10:32:29 +0200
Message-ID: <20170925083230.1193-10-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38840 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934142AbdIYIcj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:39 -0400
Received: by mail-wr0-f196.google.com with SMTP id p37so1436301wrb.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:39 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for adjacency table dump.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 238 +++++++++++++++++++++
 1 file changed, 238 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index ca16f89..e6755a9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -895,6 +895,243 @@ static u64 mlxsw_sp_dpipe_table_adj_size(struct mlxsw_sp *mlxsw_sp)
 	return size;
 }
 
+enum mlxsw_sp_dpipe_table_adj_match {
+	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX,
+	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX,
+	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT,
+};
+
+enum mlxsw_sp_dpipe_table_adj_action {
+	MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_DST_MAC,
+	MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_ERIF_PORT,
+	MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT,
+};
+
+static void
+mlxsw_sp_dpipe_table_adj_match_action_prepare(struct devlink_dpipe_match *matches,
+					      struct devlink_dpipe_action *actions)
+{
+	struct devlink_dpipe_action *action;
+	struct devlink_dpipe_match *match;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX];
+	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match->header = &mlxsw_sp_dpipe_header_metadata;
+	match->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_INDEX;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
+	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match->header = &mlxsw_sp_dpipe_header_metadata;
+	match->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX;
+
+	action = &actions[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_DST_MAC];
+	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action->header = &devlink_dpipe_header_ethernet;
+	action->field_id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC;
+
+	action = &actions[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_ERIF_PORT];
+	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action->header = &mlxsw_sp_dpipe_header_metadata;
+	action->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT;
+}
+
+static int
+mlxsw_sp_dpipe_table_adj_entry_prepare(struct devlink_dpipe_entry *entry,
+				       struct devlink_dpipe_value *match_values,
+				       struct devlink_dpipe_match *matches,
+				       struct devlink_dpipe_value *action_values,
+				       struct devlink_dpipe_action *actions)
+{	struct devlink_dpipe_value *action_value;
+	struct devlink_dpipe_value *match_value;
+	struct devlink_dpipe_action *action;
+	struct devlink_dpipe_match *match;
+
+	entry->match_values = match_values;
+	entry->match_values_count = MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT;
+
+	entry->action_values = action_values;
+	entry->action_values_count = MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX];
+	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX];
+
+	match_value->match = match;
+	match_value->value_size = sizeof(u32);
+	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
+	if (!match_value->value)
+		return -ENOMEM;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
+	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
+
+	match_value->match = match;
+	match_value->value_size = sizeof(u32);
+	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
+	if (!match_value->value)
+		return -ENOMEM;
+
+	action = &actions[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_DST_MAC];
+	action_value = &action_values[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_DST_MAC];
+
+	action_value->action = action;
+	action_value->value_size = sizeof(u64);
+	action_value->value = kmalloc(action_value->value_size, GFP_KERNEL);
+	if (!action_value->value)
+		return -ENOMEM;
+
+	action = &actions[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_ERIF_PORT];
+	action_value = &action_values[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_ERIF_PORT];
+
+	action_value->action = action;
+	action_value->value_size = sizeof(u32);
+	action_value->value = kmalloc(action_value->value_size, GFP_KERNEL);
+	if (!action_value->value)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void
+__mlxsw_sp_dpipe_table_adj_entry_fill(struct devlink_dpipe_entry *entry,
+				      u32 adj_index, u32 adj_hash_index,
+				      unsigned char *ha,
+				      struct mlxsw_sp_rif *rif)
+{
+	struct devlink_dpipe_value *value;
+	u32 *p_rif_value;
+	u32 *p_index;
+
+	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX];
+	p_index = value->value;
+	*p_index = adj_index;
+
+	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
+	p_index = value->value;
+	*p_index = adj_hash_index;
+
+	value = &entry->action_values[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_DST_MAC];
+	ether_addr_copy(value->value, ha);
+
+	value = &entry->action_values[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_ERIF_PORT];
+	p_rif_value = value->value;
+	*p_rif_value = mlxsw_sp_rif_index(rif);
+	value->mapping_value = mlxsw_sp_rif_dev_ifindex(rif);
+	value->mapping_valid = true;
+}
+
+static void mlxsw_sp_dpipe_table_adj_entry_fill(struct mlxsw_sp *mlxsw_sp,
+						struct mlxsw_sp_nexthop *nh,
+						struct devlink_dpipe_entry *entry)
+{
+	struct mlxsw_sp_rif *rif = mlxsw_sp_nexthop_rif(nh);
+	unsigned char *ha = mlxsw_sp_nexthop_ha(nh);
+	u32 adj_hash_index = 0;
+	u32 adj_index = 0;
+	int err;
+
+	mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_hash_index);
+	__mlxsw_sp_dpipe_table_adj_entry_fill(entry, adj_index,
+					      adj_hash_index, ha, rif);
+	err = mlxsw_sp_nexthop_counter_get(mlxsw_sp, nh, &entry->counter);
+	if (!err)
+		entry->counter_valid = true;
+}
+
+static int
+mlxsw_sp_dpipe_table_adj_entries_get(struct mlxsw_sp *mlxsw_sp,
+				     struct devlink_dpipe_entry *entry,
+				     bool counters_enabled,
+				     struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	struct mlxsw_sp_nexthop *nh;
+	int entry_index = 0;
+	int nh_count_max;
+	int nh_count = 0;
+	int nh_skip;
+	int j;
+	int err;
+
+	rtnl_lock();
+	nh_count_max = mlxsw_sp_dpipe_table_adj_size(mlxsw_sp);
+start_again:
+	err = devlink_dpipe_entry_ctx_prepare(dump_ctx);
+	if (err)
+		goto err_ctx_prepare;
+	j = 0;
+	nh_skip = nh_count;
+	mlxsw_sp_nexthop_for_each(nh, mlxsw_sp->router) {
+		if (!mlxsw_sp_nexthop_offload(nh) ||
+		    mlxsw_sp_nexthop_group_has_ipip(nh))
+			continue;
+
+		if (nh_count < nh_skip)
+			goto skip;
+
+		mlxsw_sp_dpipe_table_adj_entry_fill(mlxsw_sp, nh, entry);
+		entry->index = entry_index;
+		err = devlink_dpipe_entry_ctx_append(dump_ctx, entry);
+		if (err) {
+			if (err == -EMSGSIZE) {
+				if (!j)
+					goto err_entry_append;
+				break;
+			}
+			goto err_entry_append;
+		}
+		entry_index++;
+		j++;
+skip:
+		nh_count++;
+	}
+
+	devlink_dpipe_entry_ctx_close(dump_ctx);
+	if (nh_count != nh_count_max)
+		goto start_again;
+	rtnl_unlock();
+
+	return 0;
+
+err_ctx_prepare:
+err_entry_append:
+	rtnl_unlock();
+	return err;
+}
+
+static int
+mlxsw_sp_dpipe_table_adj_entries_dump(void *priv, bool counters_enabled,
+				      struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	struct devlink_dpipe_value action_values[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT];
+	struct devlink_dpipe_value match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT];
+	struct devlink_dpipe_action actions[MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT];
+	struct devlink_dpipe_match matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT];
+	struct devlink_dpipe_entry entry = {0};
+	struct mlxsw_sp *mlxsw_sp = priv;
+	int err;
+
+	memset(matches, 0, MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT *
+			   sizeof(matches[0]));
+	memset(match_values, 0, MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT *
+				sizeof(match_values[0]));
+	memset(actions, 0, MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT *
+			   sizeof(actions[0]));
+	memset(action_values, 0, MLXSW_SP_DPIPE_TABLE_ADJ_ACTION_COUNT *
+				 sizeof(action_values[0]));
+
+	mlxsw_sp_dpipe_table_adj_match_action_prepare(matches, actions);
+	err = mlxsw_sp_dpipe_table_adj_entry_prepare(&entry,
+						     match_values, matches,
+						     action_values, actions);
+	if (err)
+		goto out;
+
+	err = mlxsw_sp_dpipe_table_adj_entries_get(mlxsw_sp, &entry,
+						   counters_enabled, dump_ctx);
+out:
+	devlink_dpipe_entry_clear(&entry);
+	return err;
+}
+
 static u64
 mlxsw_sp_dpipe_table_adj_size_get(void *priv)
 {
@@ -911,6 +1148,7 @@ mlxsw_sp_dpipe_table_adj_size_get(void *priv)
 static struct devlink_dpipe_table_ops mlxsw_sp_dpipe_table_adj_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_adj_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_adj_actions_dump,
+	.entries_dump = mlxsw_sp_dpipe_table_adj_entries_dump,
 	.size_get = mlxsw_sp_dpipe_table_adj_size_get,
 };
 
-- 
2.9.5
