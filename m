From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/12] mlxsw: spectrum_dpipe: Add support for controlling neighbor counters
Date: Thu, 24 Aug 2017 08:40:10 +0200
Message-ID: <20170824064010.1646-13-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34987 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751759AbdHXGkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id x79so1699798wma.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:32 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for controlling neighbor counters via dpipe.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 33 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 12 ++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  4 +++
 3 files changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 94d954b..3c8599f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -599,6 +599,38 @@ mlxsw_sp_dpipe_table_host4_entries_dump(void *priv, bool counters_enabled,
 						      dump_ctx, AF_INET);
 }
 
+static void
+mlxsw_sp_dpipe_table_host_counters_update(struct mlxsw_sp *mlxsw_sp,
+					  bool enable, int type)
+{
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
+			mlxsw_sp_neigh_entry_counter_update(mlxsw_sp,
+							    neigh_entry,
+							    enable);
+		}
+	}
+	rtnl_unlock();
+}
+
+static int mlxsw_sp_dpipe_table_host4_counters_update(void *priv, bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	mlxsw_sp_dpipe_table_host_counters_update(mlxsw_sp, enable, AF_INET);
+	return 0;
+}
+
 static u64
 mlxsw_sp_dpipe_table_host_size_get(struct mlxsw_sp *mlxsw_sp, int type)
 {
@@ -634,6 +666,7 @@ static struct devlink_dpipe_table_ops mlxsw_sp_host4_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_host4_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_host4_actions_dump,
 	.entries_dump = mlxsw_sp_dpipe_table_host4_entries_dump,
+	.counters_set_update = mlxsw_sp_dpipe_table_host4_counters_update,
 	.size_get = mlxsw_sp_dpipe_table_host4_size_get,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index abccd84..377d85c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1429,6 +1429,18 @@ mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
+void
+mlxsw_sp_neigh_entry_counter_update(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_neigh_entry *neigh_entry,
+				    bool adding)
+{
+	if (adding)
+		mlxsw_sp_neigh_counter_alloc(mlxsw_sp, neigh_entry);
+	else
+		mlxsw_sp_neigh_counter_free(mlxsw_sp, neigh_entry);
+	mlxsw_sp_neigh_entry_update(mlxsw_sp, neigh_entry, true);
+}
+
 struct mlxsw_sp_neigh_event_work {
 	struct work_struct work;
 	struct mlxsw_sp *mlxsw_sp;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index aafae46..fb0f971 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -72,5 +72,9 @@ u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry);
 int mlxsw_sp_neigh_counter_get(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_neigh_entry *neigh_entry,
 			       u64 *p_counter);
+void
+mlxsw_sp_neigh_entry_counter_update(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_neigh_entry *neigh_entry,
+				    bool adding);
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.3
