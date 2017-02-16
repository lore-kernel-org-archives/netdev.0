From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 8/8] mlxsw: spectrum: Add Support for erif table entries access
Date: Thu, 16 Feb 2017 16:22:44 +0100
Message-ID: <1487258564-3775-9-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32972 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932452AbdBPPW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:56 -0500
Received: by mail-wr0-f195.google.com with SMTP id i10so2454114wrb.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:55 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Implement dpipe's table ops for erif table which provide:
1. Getting the entries in the table with the associate values.
	- match on "mlxsw_meta:erif_index"
	- action on "mlxsw_meta:forwared_out"
2. Synchronize the hardware in case of enabling/disabling counters which
   mean removing erif counters from all interfaces.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 167 ++++++++++++++++++++-
 1 file changed, 166 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 41e8e33..a7eebee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -100,7 +100,172 @@ static struct devlink_dpipe_hfield mlxsw_sp_dpipe_actions_erif[] = {
 	},
 };
 
-static struct devlink_dpipe_table_ops mlxsw_sp_erif_ops = {};
+static void mlxsw_sp_erif_entry_clear(struct devlink_dpipe_entry *entry)
+{
+	struct devlink_dpipe_hfield_val *val;
+	unsigned int val_count, val_index;
+
+	val = entry->actions;
+	val_count = entry->actions_count;
+	for (val_index = 0; val_index < val_count; val_index++) {
+		kfree(val[val_index].value);
+		kfree(val[val_index].mask);
+	}
+
+	val = entry->matches;
+	val_count = entry->matches_count;
+	for (val_index = 0; val_index < val_count; val_index++) {
+		kfree(val[val_index].value);
+		kfree(val[val_index].mask);
+	}
+}
+
+static int mlxsw_sp_erif_entry_get(struct mlxsw_sp *mlxsw_sp,
+				   struct devlink_dpipe_entry *entry,
+				   struct mlxsw_sp_rif *r,
+				   bool counters_enabled)
+{
+	u32 *action_value;
+	u32 *rif_value;
+	u64 cnt;
+	int err;
+
+	/* Set Match RIF index */
+	rif_value = entry->matches->value;
+	*rif_value = r->rif;
+	entry->matches->mapping_value = r->dev->ifindex;
+
+	/* Set Action Forwarding */
+	action_value = entry->actions->value;
+	*action_value = 1;
+
+	entry->counter_valid = false;
+	entry->counter = 0;
+	if (!counters_enabled)
+		return 0;
+
+	entry->index = r->rif;
+	err = mlxsw_sp_rif_counter_value_get(mlxsw_sp, r,
+					     MLXSW_SP_RIF_COUNTER_EGRESS,
+					     &cnt);
+	if (!err) {
+		entry->counter = cnt;
+		entry->counter_valid = true;
+	}
+	return 0;
+}
+
+static int mlxsw_sp_erif_entry_prepare(struct devlink_dpipe_entry *entry,
+				       struct devlink_dpipe_hfield_val *match,
+				       struct devlink_dpipe_hfield_val *action)
+{
+	entry->matches = match;
+	entry->matches_count = 1;
+
+	entry->actions = action;
+	entry->actions_count = 1;
+
+	match->hfield = mlxsw_sp_dpipe_matches_erif;
+	match->value_size = sizeof(u32);
+	match->value = kmalloc(match->value_size, GFP_KERNEL);
+	if (!match->value)
+		return -ENOMEM;
+
+	action->hfield = &mlxsw_sp_dpipe_actions_erif[MLXSW_SP_DPIPE_TABLE_ERIF_ACTION_FOWARD];
+	action->value_size = sizeof(u32);
+	action->value = kmalloc(action->value_size, GFP_KERNEL);
+	if (!action->value)
+		goto err_action_alloc;
+	return 0;
+
+err_action_alloc:
+	kfree(match->value);
+	return -ENOMEM;
+}
+
+static int mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
+					    struct devlink_dpipe_dump_ctx *
+					    dump_ctx)
+{
+	struct devlink_dpipe_hfield_val match = {0}, action = {0};
+	struct devlink_dpipe_entry entry = {0};
+	struct mlxsw_sp *mlxsw_sp = priv;
+	unsigned int rif_count;
+	int i, j;
+	int err;
+
+	err = mlxsw_sp_erif_entry_prepare(&entry, &match, &action);
+	if (err)
+		return err;
+
+	rif_count = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+	rtnl_lock();
+	i = 0;
+start_again:
+	err = devlink_dpipe_entry_prepare_ctx(dump_ctx);
+	if (err)
+		return err;
+	j = 0;
+	for (; i < rif_count; i++) {
+		if (!mlxsw_sp->rifs[i])
+			continue;
+		err = mlxsw_sp_erif_entry_get(mlxsw_sp, &entry,
+					      mlxsw_sp->rifs[i],
+					      counters_enabled);
+		if (err)
+			goto err_entry_get;
+		err = devlink_dpipe_entry_append_ctx(dump_ctx, &entry);
+		if (err) {
+			if (err == -EMSGSIZE) {
+				if (!j)
+					goto err_entry_append;
+				break;
+			}
+			goto err_entry_append;
+		}
+		j++;
+	}
+
+	devlink_dpipe_entry_close_ctx(dump_ctx);
+	if (i != rif_count)
+		goto start_again;
+	rtnl_unlock();
+
+	mlxsw_sp_erif_entry_clear(&entry);
+	return 0;
+err_entry_append:
+err_entry_get:
+	rtnl_unlock();
+	mlxsw_sp_erif_entry_clear(&entry);
+	return err;
+}
+
+static int mlxsw_sp_table_erif_counter_update(void *priv, bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	int i;
+
+	rtnl_lock();
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
+		if (!mlxsw_sp->rifs[i])
+			continue;
+		if (enable)
+			mlxsw_sp_rif_counter_alloc(mlxsw_sp,
+						   mlxsw_sp->rifs[i],
+						   MLXSW_SP_RIF_COUNTER_EGRESS);
+		else
+			mlxsw_sp_rif_counter_free(mlxsw_sp,
+						  mlxsw_sp->rifs[i],
+						  MLXSW_SP_RIF_COUNTER_EGRESS);
+	}
+	rtnl_unlock();
+	return 0;
+}
+
+static struct devlink_dpipe_table_ops mlxsw_sp_erif_ops = {
+	.entries_dump = mlxsw_sp_table_erif_entries_dump,
+	.counter_set_update = mlxsw_sp_table_erif_counter_update,
+};
 
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 {
-- 
2.7.4
