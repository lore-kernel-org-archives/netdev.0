From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/21] mlxsw: spectrum_router: Extract mlxsw_sp_fi_is_gateway()
Date: Sat,  2 Sep 2017 17:21:16 +0200
Message-ID: <20170902152126.17286-12-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37533 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752749AbdIBPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id x189so2639465wmg.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:46 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

For IPv4 IP-in-IP offload, routes that direct traffic to IP-in-IP
devices need to be considered gateway routes as well. That involves a
bit more logic, so extract the current test to a separate function,
where the logic can be later added.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 72e386b..04e1887 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2382,6 +2382,12 @@ static void mlxsw_sp_nexthop_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
+static bool mlxsw_sp_fi_is_gateway(const struct mlxsw_sp *mlxsw_sp,
+				   const struct fib_info *fi)
+{
+	return fi->fib_nh->nh_scope == RT_SCOPE_LINK;
+}
+
 static struct mlxsw_sp_nexthop_group *
 mlxsw_sp_nexthop4_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 {
@@ -2401,7 +2407,7 @@ mlxsw_sp_nexthop4_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 	INIT_LIST_HEAD(&nh_grp->fib_list);
 	nh_grp->neigh_tbl = &arp_tbl;
 
-	nh_grp->gateway = fi->fib_nh->nh_scope == RT_SCOPE_LINK;
+	nh_grp->gateway = mlxsw_sp_fi_is_gateway(mlxsw_sp, fi);
 	nh_grp->count = fi->fib_nhs;
 	fib_info_hold(fi);
 	for (i = 0; i < nh_grp->count; i++) {
@@ -2801,10 +2807,10 @@ mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		return 0;
 	case RTN_UNICAST:
-		if (fi->fib_nh->nh_scope != RT_SCOPE_LINK)
-			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-		else
+		if (mlxsw_sp_fi_is_gateway(mlxsw_sp, fi))
 			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
+		else
+			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
