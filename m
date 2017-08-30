From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: spectrum_dpipe: Add support for IPv6 host table dump
Date: Wed, 30 Aug 2017 14:03:04 +0200
Message-ID: <20170830120306.6128-7-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37473 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdH3MDX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:23 -0400
Received: by mail-wr0-f195.google.com with SMTP id k9so1289466wre.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:22 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for IPv6 host table dump.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 75 ++++++++++++++++++++--
 1 file changed, 70 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 5924e97..75da2ef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -386,8 +386,19 @@ mlxsw_sp_dpipe_table_host_match_action_prepare(struct devlink_dpipe_match *match
 
 	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
 	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
-	match->header = &devlink_dpipe_header_ipv4;
-	match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+	switch (type) {
+	case AF_INET:
+		match->header = &devlink_dpipe_header_ipv4;
+		match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+		break;
+	case AF_INET6:
+		match->header = &devlink_dpipe_header_ipv6;
+		match->field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
+		break;
+	default:
+		WARN_ON(1);
+		return;
+	}
 
 	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
 	action->header = &devlink_dpipe_header_ethernet;
@@ -424,7 +435,18 @@ mlxsw_sp_dpipe_table_host_entry_prepare(struct devlink_dpipe_entry *entry,
 	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
 
 	match_value->match = match;
-	match_value->value_size = sizeof(u32);
+	switch (type) {
+	case AF_INET:
+		match_value->value_size = sizeof(u32);
+		break;
+	case AF_INET6:
+		match_value->value_size = sizeof(struct in6_addr);
+		break;
+	default:
+		WARN_ON(1);
+		return -EINVAL;
+	}
+
 	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
 	if (!match_value->value)
 		return -ENOMEM;
@@ -479,6 +501,20 @@ mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
 }
 
 static void
+mlxsw_sp_dpipe_table_host6_entry_fill(struct devlink_dpipe_entry *entry,
+				      struct mlxsw_sp_neigh_entry *neigh_entry,
+				      struct mlxsw_sp_rif *rif)
+{
+	struct in6_addr *dip;
+	unsigned char *ha;
+
+	ha = mlxsw_sp_neigh_entry_ha(neigh_entry);
+	dip = mlxsw_sp_neigh6_entry_dip(neigh_entry);
+
+	__mlxsw_sp_dpipe_table_host_entry_fill(entry, rif, ha, dip);
+}
+
+static void
 mlxsw_sp_dpipe_table_host_entry_fill(struct mlxsw_sp *mlxsw_sp,
 				     struct devlink_dpipe_entry *entry,
 				     struct mlxsw_sp_neigh_entry *neigh_entry,
@@ -487,7 +523,18 @@ mlxsw_sp_dpipe_table_host_entry_fill(struct mlxsw_sp *mlxsw_sp,
 {
 	int err;
 
-	mlxsw_sp_dpipe_table_host4_entry_fill(entry, neigh_entry, rif);
+	switch (type) {
+	case AF_INET:
+		mlxsw_sp_dpipe_table_host4_entry_fill(entry, neigh_entry, rif);
+		break;
+	case AF_INET6:
+		mlxsw_sp_dpipe_table_host6_entry_fill(entry, neigh_entry, rif);
+		break;
+	default:
+		WARN_ON(1);
+		return;
+	}
+
 	err = mlxsw_sp_neigh_counter_get(mlxsw_sp, neigh_entry,
 					 &entry->counter);
 	if (!err)
@@ -526,7 +573,13 @@ mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
 
 		rif_neigh_count = 0;
 		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
-			if (mlxsw_sp_neigh_entry_type(neigh_entry) != type)
+			int neigh_type = mlxsw_sp_neigh_entry_type(neigh_entry);
+
+			if (neigh_type != type)
+				continue;
+
+			if (neigh_type == AF_INET6 &&
+			    mlxsw_sp_neigh_ipv6_ignore(neigh_entry))
 				continue;
 
 			if (rif_neigh_count < rif_neigh_skip)
@@ -714,6 +767,17 @@ mlxsw_sp_dpipe_table_host6_matches_dump(void *priv, struct sk_buff *skb)
 	return mlxsw_sp_dpipe_table_host_matches_dump(skb, AF_INET6);
 }
 
+static int
+mlxsw_sp_dpipe_table_host6_entries_dump(void *priv, bool counters_enabled,
+					struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	return mlxsw_sp_dpipe_table_host_entries_dump(mlxsw_sp,
+						      counters_enabled,
+						      dump_ctx, AF_INET6);
+}
+
 static u64 mlxsw_sp_dpipe_table_host6_size_get(void *priv)
 {
 	struct mlxsw_sp *mlxsw_sp = priv;
@@ -724,6 +788,7 @@ static u64 mlxsw_sp_dpipe_table_host6_size_get(void *priv)
 static struct devlink_dpipe_table_ops mlxsw_sp_host6_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_host6_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_host_actions_dump,
+	.entries_dump = mlxsw_sp_dpipe_table_host6_entries_dump,
 	.size_get = mlxsw_sp_dpipe_table_host6_size_get,
 };
 
-- 
2.9.3
