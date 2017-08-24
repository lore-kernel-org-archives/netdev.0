From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/12] mlxsw: spectrum_dpipe: Add IPv4 host table initial support
Date: Thu, 24 Aug 2017 08:40:06 +0200
Message-ID: <20170824064010.1646-9-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38472 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdHXGk1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id a70so1685084wmd.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:26 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add IPv4 host table initial support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 102 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |   1 +
 2 files changed, 103 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 6310c2c..9c2b25a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -74,6 +74,8 @@ static struct devlink_dpipe_header mlxsw_sp_dpipe_header_metadata = {
 
 static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {
 	&mlxsw_sp_dpipe_header_metadata,
+	&devlink_dpipe_header_ethernet,
+	&devlink_dpipe_header_ipv4,
 };
 
 static struct devlink_dpipe_headers mlxsw_sp_dpipe_headers = {
@@ -313,6 +315,99 @@ static void mlxsw_sp_dpipe_erif_table_fini(struct mlxsw_sp *mlxsw_sp)
 	devlink_dpipe_table_unregister(devlink, MLXSW_SP_DPIPE_TABLE_NAME_ERIF);
 }
 
+static int mlxsw_sp_dpipe_table_host_matches_dump(struct sk_buff *skb, int type)
+{
+	struct devlink_dpipe_match match = {0};
+	int err;
+
+	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match.header = &mlxsw_sp_dpipe_header_metadata;
+	match.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT;
+
+	err = devlink_dpipe_match_put(skb, &match);
+	if (err)
+		return err;
+
+	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match.header = &devlink_dpipe_header_ipv4;
+	match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
+
+	return devlink_dpipe_match_put(skb, &match);
+}
+
+static int
+mlxsw_sp_dpipe_table_host4_matches_dump(void *priv, struct sk_buff *skb)
+{
+	return mlxsw_sp_dpipe_table_host_matches_dump(skb, AF_INET);
+}
+
+static int
+mlxsw_sp_dpipe_table_host4_actions_dump(void *priv, struct sk_buff *skb)
+{
+	struct devlink_dpipe_action action = {0};
+
+	action.type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action.header = &devlink_dpipe_header_ethernet;
+	action.field_id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC;
+
+	return devlink_dpipe_action_put(skb, &action);
+}
+
+static u64
+mlxsw_sp_dpipe_table_host_size_get(struct mlxsw_sp *mlxsw_sp, int type)
+{
+	u64 size = 0;
+	int i;
+
+	rtnl_lock();
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
+		struct mlxsw_sp_rif *rif = mlxsw_sp_rif_by_index(mlxsw_sp, i);
+		struct mlxsw_sp_neigh_entry *neigh_entry;
+
+		if (!rif)
+			continue;
+		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
+			if (mlxsw_sp_neigh_entry_type(neigh_entry) != type)
+				continue;
+			size++;
+		}
+	}
+	rtnl_unlock();
+
+	return size;
+}
+
+static u64 mlxsw_sp_dpipe_table_host4_size_get(void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	return mlxsw_sp_dpipe_table_host_size_get(mlxsw_sp, AF_INET);
+}
+
+static struct devlink_dpipe_table_ops mlxsw_sp_host4_ops = {
+	.matches_dump = mlxsw_sp_dpipe_table_host4_matches_dump,
+	.actions_dump = mlxsw_sp_dpipe_table_host4_actions_dump,
+	.size_get = mlxsw_sp_dpipe_table_host4_size_get,
+};
+
+static int mlxsw_sp_dpipe_host4_table_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	return devlink_dpipe_table_register(devlink,
+					    MLXSW_SP_DPIPE_TABLE_NAME_HOST4,
+					    &mlxsw_sp_host4_ops,
+					    mlxsw_sp, false);
+}
+
+static void mlxsw_sp_dpipe_host4_table_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	devlink_dpipe_table_unregister(devlink,
+				       MLXSW_SP_DPIPE_TABLE_NAME_HOST4);
+}
+
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
@@ -325,8 +420,14 @@ int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 	err = mlxsw_sp_dpipe_erif_table_init(mlxsw_sp);
 	if (err)
 		goto err_erif_table_init;
+
+	err = mlxsw_sp_dpipe_host4_table_init(mlxsw_sp);
+	if (err)
+		goto err_host4_table_init;
 	return 0;
 
+err_host4_table_init:
+	mlxsw_sp_dpipe_erif_table_fini(mlxsw_sp);
 err_erif_table_init:
 	devlink_dpipe_headers_unregister(priv_to_devlink(mlxsw_sp->core));
 	return err;
@@ -336,6 +437,7 @@ void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 
+	mlxsw_sp_dpipe_host4_table_fini(mlxsw_sp);
 	mlxsw_sp_dpipe_erif_table_fini(mlxsw_sp);
 	devlink_dpipe_headers_unregister(devlink);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
index d208929..7785f9e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
@@ -39,5 +39,6 @@ int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp);
 
 #define MLXSW_SP_DPIPE_TABLE_NAME_ERIF "mlxsw_erif"
+#define MLXSW_SP_DPIPE_TABLE_NAME_HOST4 "mlxsw_host4"
 
 #endif /* _MLXSW_PIPELINE_H_*/
-- 
2.9.3
