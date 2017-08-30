From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: spectrum_dpipe: Add support for controlling IPv6 neighbor counters
Date: Wed, 30 Aug 2017 14:03:06 +0200
Message-ID: <20170830120306.6128-9-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38004 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3MD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:26 -0400
Received: by mail-wm0-f68.google.com with SMTP id u26so1536903wma.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:25 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for controlling IPv6 neighbor counters via dpipe.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 75da2ef..51e6846 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -679,8 +679,15 @@ mlxsw_sp_dpipe_table_host_counters_update(struct mlxsw_sp *mlxsw_sp,
 		if (!rif)
 			continue;
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
+
 			mlxsw_sp_neigh_entry_counter_update(mlxsw_sp,
 							    neigh_entry,
 							    enable);
@@ -778,6 +785,14 @@ mlxsw_sp_dpipe_table_host6_entries_dump(void *priv, bool counters_enabled,
 						      dump_ctx, AF_INET6);
 }
 
+static int mlxsw_sp_dpipe_table_host6_counters_update(void *priv, bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	mlxsw_sp_dpipe_table_host_counters_update(mlxsw_sp, enable, AF_INET6);
+	return 0;
+}
+
 static u64 mlxsw_sp_dpipe_table_host6_size_get(void *priv)
 {
 	struct mlxsw_sp *mlxsw_sp = priv;
@@ -789,6 +804,7 @@ static struct devlink_dpipe_table_ops mlxsw_sp_host6_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_host6_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_host_actions_dump,
 	.entries_dump = mlxsw_sp_dpipe_table_host6_entries_dump,
+	.counters_set_update = mlxsw_sp_dpipe_table_host6_counters_update,
 	.size_get = mlxsw_sp_dpipe_table_host6_size_get,
 };
 
-- 
2.9.3
