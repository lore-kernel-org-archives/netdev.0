From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum_dpipe: Add IPv6 host table initial support
Date: Wed, 30 Aug 2017 14:03:01 +0200
Message-ID: <20170830120306.6128-4-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37457 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3MDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:18 -0400
Received: by mail-wr0-f195.google.com with SMTP id k9so1289344wre.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:17 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add IPv6 host table initial support. The action behavior for both IPv4/6
tables is the same, thus the same action dump op is used. Neighbors with
link local address are ignored.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 76 ++++++++++++++++++++--
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |  1 +
 2 files changed, 71 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 3ea1314..93ba6a6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -76,6 +76,7 @@ static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {
 	&mlxsw_sp_dpipe_header_metadata,
 	&devlink_dpipe_header_ethernet,
 	&devlink_dpipe_header_ipv4,
+	&devlink_dpipe_header_ipv6,
 };
 
 static struct devlink_dpipe_headers mlxsw_sp_dpipe_headers = {
@@ -328,9 +329,21 @@ static int mlxsw_sp_dpipe_table_host_matches_dump(struct sk_buff *skb, int type)
 	if (err)
 		return err;
 
-	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
-	match.header = &devlink_dpipe_header_ipv4;
-	match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+	switch (type) {
+	case AF_INET:
+		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+		match.header = &devlink_dpipe_header_ipv4;
+		match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+		break;
+	case AF_INET6:
+		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+		match.header = &devlink_dpipe_header_ipv6;
+		match.field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
+		break;
+	default:
+		WARN_ON(1);
+		return -EINVAL;
+	}
 
 	return devlink_dpipe_match_put(skb, &match);
 }
@@ -342,7 +355,7 @@ mlxsw_sp_dpipe_table_host4_matches_dump(void *priv, struct sk_buff *skb)
 }
 
 static int
-mlxsw_sp_dpipe_table_host4_actions_dump(void *priv, struct sk_buff *skb)
+mlxsw_sp_dpipe_table_host_actions_dump(void *priv, struct sk_buff *skb)
 {
 	struct devlink_dpipe_action action = {0};
 
@@ -648,8 +661,15 @@ mlxsw_sp_dpipe_table_host_size_get(struct mlxsw_sp *mlxsw_sp, int type)
 		if (!rif)
 			continue;
 		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
-			if (mlxsw_sp_neigh_entry_type(neigh_entry) != type)
+			int neigh_type = mlxsw_sp_neigh_entry_type(neigh_entry);
+
+			if (neigh_type != type)
 				continue;
+
+			if (neigh_type == AF_INET6 &&
+			    mlxsw_sp_neigh_ipv6_ignore(neigh_entry))
+				continue;
+
 			size++;
 		}
 	}
@@ -667,7 +687,7 @@ static u64 mlxsw_sp_dpipe_table_host4_size_get(void *priv)
 
 static struct devlink_dpipe_table_ops mlxsw_sp_host4_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_host4_matches_dump,
-	.actions_dump = mlxsw_sp_dpipe_table_host4_actions_dump,
+	.actions_dump = mlxsw_sp_dpipe_table_host_actions_dump,
 	.entries_dump = mlxsw_sp_dpipe_table_host4_entries_dump,
 	.counters_set_update = mlxsw_sp_dpipe_table_host4_counters_update,
 	.size_get = mlxsw_sp_dpipe_table_host4_size_get,
@@ -691,6 +711,43 @@ static void mlxsw_sp_dpipe_host4_table_fini(struct mlxsw_sp *mlxsw_sp)
 				       MLXSW_SP_DPIPE_TABLE_NAME_HOST4);
 }
 
+static int
+mlxsw_sp_dpipe_table_host6_matches_dump(void *priv, struct sk_buff *skb)
+{
+	return mlxsw_sp_dpipe_table_host_matches_dump(skb, AF_INET6);
+}
+
+static u64 mlxsw_sp_dpipe_table_host6_size_get(void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	return mlxsw_sp_dpipe_table_host_size_get(mlxsw_sp, AF_INET6);
+}
+
+static struct devlink_dpipe_table_ops mlxsw_sp_host6_ops = {
+	.matches_dump = mlxsw_sp_dpipe_table_host6_matches_dump,
+	.actions_dump = mlxsw_sp_dpipe_table_host_actions_dump,
+	.size_get = mlxsw_sp_dpipe_table_host6_size_get,
+};
+
+static int mlxsw_sp_dpipe_host6_table_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	return devlink_dpipe_table_register(devlink,
+					    MLXSW_SP_DPIPE_TABLE_NAME_HOST6,
+					    &mlxsw_sp_host6_ops,
+					    mlxsw_sp, false);
+}
+
+static void mlxsw_sp_dpipe_host6_table_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	devlink_dpipe_table_unregister(devlink,
+				       MLXSW_SP_DPIPE_TABLE_NAME_HOST6);
+}
+
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
@@ -707,8 +764,14 @@ int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 	err = mlxsw_sp_dpipe_host4_table_init(mlxsw_sp);
 	if (err)
 		goto err_host4_table_init;
+
+	err = mlxsw_sp_dpipe_host6_table_init(mlxsw_sp);
+	if (err)
+		goto err_host6_table_init;
 	return 0;
 
+err_host6_table_init:
+	mlxsw_sp_dpipe_host4_table_fini(mlxsw_sp);
 err_host4_table_init:
 	mlxsw_sp_dpipe_erif_table_fini(mlxsw_sp);
 err_erif_table_init:
@@ -720,6 +783,7 @@ void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 
+	mlxsw_sp_dpipe_host6_table_fini(mlxsw_sp);
 	mlxsw_sp_dpipe_host4_table_fini(mlxsw_sp);
 	mlxsw_sp_dpipe_erif_table_fini(mlxsw_sp);
 	devlink_dpipe_headers_unregister(devlink);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
index c56a3d9..283fde4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
@@ -55,5 +55,6 @@ static inline void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
 
 #define MLXSW_SP_DPIPE_TABLE_NAME_ERIF "mlxsw_erif"
 #define MLXSW_SP_DPIPE_TABLE_NAME_HOST4 "mlxsw_host4"
+#define MLXSW_SP_DPIPE_TABLE_NAME_HOST6 "mlxsw_host6"
 
 #endif /* _MLXSW_PIPELINE_H_*/
-- 
2.9.3
