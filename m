From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum_router: Add support for setting counters on IPv6 neighbors
Date: Wed, 30 Aug 2017 14:03:05 +0200
Message-ID: <20170830120306.6128-8-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33303 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdH3MDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id m85so1058638wma.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:23 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for setting counters on IPv6 neighbors based on dpipe's host6
table counter status.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index db57c0c..0cf6810 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1008,21 +1008,33 @@ mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
 }
 
 static bool
-mlxsw_sp_neigh4_counter_should_alloc(struct mlxsw_sp *mlxsw_sp)
+mlxsw_sp_neigh_counter_should_alloc(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_neigh_entry *neigh_entry)
 {
 	struct devlink *devlink;
+	const char *table_name;
+
+	switch (mlxsw_sp_neigh_entry_type(neigh_entry)) {
+	case AF_INET:
+		table_name = MLXSW_SP_DPIPE_TABLE_NAME_HOST4;
+		break;
+	case AF_INET6:
+		table_name = MLXSW_SP_DPIPE_TABLE_NAME_HOST6;
+		break;
+	default:
+		WARN_ON(1);
+		return false;
+	}
 
 	devlink = priv_to_devlink(mlxsw_sp->core);
-	return devlink_dpipe_table_counter_enabled(devlink,
-						   MLXSW_SP_DPIPE_TABLE_NAME_HOST4);
+	return devlink_dpipe_table_counter_enabled(devlink, table_name);
 }
 
 static void
 mlxsw_sp_neigh_counter_alloc(struct mlxsw_sp *mlxsw_sp,
 			     struct mlxsw_sp_neigh_entry *neigh_entry)
 {
-	if (mlxsw_sp_neigh_entry_type(neigh_entry) != AF_INET ||
-	    !mlxsw_sp_neigh4_counter_should_alloc(mlxsw_sp))
+	if (!mlxsw_sp_neigh_counter_should_alloc(mlxsw_sp, neigh_entry))
 		return;
 
 	if (mlxsw_sp_flow_counter_alloc(mlxsw_sp, &neigh_entry->counter_index))
-- 
2.9.3
