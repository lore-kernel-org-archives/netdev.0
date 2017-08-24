From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for IPv4 host table dump
Date: Thu, 24 Aug 2017 08:40:09 +0200
Message-ID: <20170824064010.1646-12-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33832 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdHXGkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id 69so1710435wmh.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:31 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for IPv4 host table dump.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 247 +++++++++++++++++++++
 1 file changed, 247 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 9c2b25a..94d954b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -353,6 +353,252 @@ mlxsw_sp_dpipe_table_host4_actions_dump(void *priv, struct sk_buff *skb)
 	return devlink_dpipe_action_put(skb, &action);
 }
 
+enum mlxsw_sp_dpipe_table_host_match {
+	MLXSW_SP_DPIPE_TABLE_HOST_MATCH_RIF,
+	MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP,
+	MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT,
+};
+
+static void
+mlxsw_sp_dpipe_table_host_match_action_prepare(struct devlink_dpipe_match *matches,
+					       struct devlink_dpipe_action *action,
+					       int type)
+{
+	struct devlink_dpipe_match *match;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_RIF];
+	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match->header = &mlxsw_sp_dpipe_header_metadata;
+	match->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
+	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match->header = &devlink_dpipe_header_ipv4;
+	match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+
+	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action->header = &devlink_dpipe_header_ethernet;
+	action->field_id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC;
+}
+
+static int
+mlxsw_sp_dpipe_table_host_entry_prepare(struct devlink_dpipe_entry *entry,
+					struct devlink_dpipe_value *match_values,
+					struct devlink_dpipe_match *matches,
+					struct devlink_dpipe_value *action_value,
+					struct devlink_dpipe_action *action,
+					int type)
+{
+	struct devlink_dpipe_value *match_value;
+	struct devlink_dpipe_match *match;
+
+	entry->match_values = match_values;
+	entry->match_values_count = MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT;
+
+	entry->action_values = action_value;
+	entry->action_values_count = 1;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_RIF];
+	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_RIF];
+
+	match_value->match = match;
+	match_value->value_size = sizeof(u32);
+	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
+	if (!match_value->value)
+		return -ENOMEM;
+
+	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
+	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
+
+	match_value->match = match;
+	match_value->value_size = sizeof(u32);
+	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
+	if (!match_value->value)
+		return -ENOMEM;
+
+	action_value->action = action;
+	action_value->value_size = sizeof(u64);
+	action_value->value = kmalloc(action_value->value_size, GFP_KERNEL);
+	if (!action_value->value)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void
+__mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
+					struct mlxsw_sp_rif *rif,
+					unsigned char *ha, u32 dip)
+{
+	struct devlink_dpipe_value *value;
+	u32 *rif_value;
+	u32 *dip_value;
+	u8 *ha_value;
+
+	/* Set Match RIF index */
+	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_RIF];
+
+	rif_value = value->value;
+	*rif_value = mlxsw_sp_rif_index(rif);
+	value->mapping_value = mlxsw_sp_rif_dev_ifindex(rif);
+	value->mapping_valid = true;
+
+	/* Set Match DIP */
+	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
+
+	dip_value = value->value;
+	*dip_value = dip;
+
+	/* Set Action DMAC */
+	value = entry->action_values;
+	ha_value = value->value;
+	ether_addr_copy(ha_value, ha);
+}
+
+static void
+mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
+				      struct mlxsw_sp_neigh_entry *neigh_entry,
+				      struct mlxsw_sp_rif *rif)
+{
+	unsigned char *ha;
+	u32 dip;
+
+	ha = mlxsw_sp_neigh_entry_ha(neigh_entry);
+	dip = mlxsw_sp_neigh4_entry_dip(neigh_entry);
+	__mlxsw_sp_dpipe_table_host4_entry_fill(entry, rif, ha, dip);
+}
+
+static void
+mlxsw_sp_dpipe_table_host_entry_fill(struct mlxsw_sp *mlxsw_sp,
+				     struct devlink_dpipe_entry *entry,
+				     struct mlxsw_sp_neigh_entry *neigh_entry,
+				     struct mlxsw_sp_rif *rif,
+				     int type)
+{
+	int err;
+
+	mlxsw_sp_dpipe_table_host4_entry_fill(entry, neigh_entry, rif);
+	err = mlxsw_sp_neigh_counter_get(mlxsw_sp, neigh_entry,
+					 &entry->counter);
+	if (!err)
+		entry->counter_valid = true;
+}
+
+static int
+mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
+				      struct devlink_dpipe_entry *entry,
+				      bool counters_enabled,
+				      struct devlink_dpipe_dump_ctx *dump_ctx,
+				      int type)
+{
+	int rif_neigh_count = 0;
+	int rif_neigh_skip = 0;
+	int neigh_count = 0;
+	int rif_count;
+	int i, j;
+	int err;
+
+	rtnl_lock();
+	i = 0;
+	rif_count = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+start_again:
+	err = devlink_dpipe_entry_ctx_prepare(dump_ctx);
+	if (err)
+		goto err_ctx_prepare;
+	j = 0;
+	rif_neigh_skip = rif_neigh_count;
+	for (; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
+		struct mlxsw_sp_rif *rif = mlxsw_sp_rif_by_index(mlxsw_sp, i);
+		struct mlxsw_sp_neigh_entry *neigh_entry;
+
+		if (!rif)
+			continue;
+
+		rif_neigh_count = 0;
+		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
+			if (rif_neigh_count < rif_neigh_skip)
+				goto skip;
+
+			mlxsw_sp_dpipe_table_host_entry_fill(mlxsw_sp, entry,
+							     neigh_entry, rif,
+							     type);
+			entry->index = neigh_count;
+			err = devlink_dpipe_entry_ctx_append(dump_ctx, entry);
+			if (err) {
+				if (err == -EMSGSIZE) {
+					if (!j)
+						goto err_entry_append;
+					else
+						goto out;
+				}
+				goto err_entry_append;
+			}
+			neigh_count++;
+			j++;
+skip:
+			rif_neigh_count++;
+		}
+		rif_neigh_skip = 0;
+	}
+out:
+	devlink_dpipe_entry_ctx_close(dump_ctx);
+	if (i != rif_count)
+		goto start_again;
+
+	rtnl_unlock();
+	return 0;
+
+err_ctx_prepare:
+err_entry_append:
+	rtnl_unlock();
+	return err;
+}
+
+static int
+mlxsw_sp_dpipe_table_host_entries_dump(struct mlxsw_sp *mlxsw_sp,
+				       bool counters_enabled,
+				       struct devlink_dpipe_dump_ctx *dump_ctx,
+				       int type)
+{
+	struct devlink_dpipe_value match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT];
+	struct devlink_dpipe_match matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT];
+	struct devlink_dpipe_value action_value;
+	struct devlink_dpipe_action action = {0};
+	struct devlink_dpipe_entry entry = {0};
+	int err;
+
+	memset(matches, 0, MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT *
+			   sizeof(matches[0]));
+	memset(match_values, 0, MLXSW_SP_DPIPE_TABLE_HOST_MATCH_COUNT *
+				sizeof(match_values[0]));
+	memset(&action_value, 0, sizeof(action_value));
+
+	mlxsw_sp_dpipe_table_host_match_action_prepare(matches, &action, type);
+	err = mlxsw_sp_dpipe_table_host_entry_prepare(&entry, match_values,
+						      matches, &action_value,
+						      &action, type);
+	if (err)
+		goto out;
+
+	err = mlxsw_sp_dpipe_table_host_entries_get(mlxsw_sp, &entry,
+						    counters_enabled, dump_ctx,
+						    type);
+out:
+	devlink_dpipe_entry_clear(&entry);
+	return err;
+}
+
+static int
+mlxsw_sp_dpipe_table_host4_entries_dump(void *priv, bool counters_enabled,
+					struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	return mlxsw_sp_dpipe_table_host_entries_dump(mlxsw_sp,
+						      counters_enabled,
+						      dump_ctx, AF_INET);
+}
+
 static u64
 mlxsw_sp_dpipe_table_host_size_get(struct mlxsw_sp *mlxsw_sp, int type)
 {
@@ -387,6 +633,7 @@ static u64 mlxsw_sp_dpipe_table_host4_size_get(void *priv)
 static struct devlink_dpipe_table_ops mlxsw_sp_host4_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_host4_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_host4_actions_dump,
+	.entries_dump = mlxsw_sp_dpipe_table_host4_entries_dump,
 	.size_get = mlxsw_sp_dpipe_table_host4_size_get,
 };
 
-- 
2.9.3
