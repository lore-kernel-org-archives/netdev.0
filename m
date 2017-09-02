From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/21] mlxsw: spectrum_router: Extract mlxsw_sp_rt6_is_gateway()
Date: Sat,  2 Sep 2017 23:49:21 +0200
Message-ID: <20170902214929.2890-14-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33973 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752835AbdIBVtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id l19so3163779wmi.1
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:53 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

IPv6 counterpart of the previous patch: introduce a function to
determine whether a given route is a gateway route.

The new function takes a mlxsw_sp argument which follow-up patches will
use. Thus mlxsw_sp_fib6_entry_type_set() got that argument as well.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 04e1887..563e803 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3526,6 +3526,12 @@ static void mlxsw_sp_nexthop6_fini(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_rif_fini(nh);
 }
 
+static bool mlxsw_sp_rt6_is_gateway(const struct mlxsw_sp *mlxsw_sp,
+				    const struct rt6_info *rt)
+{
+	return rt->rt6i_flags & RTF_GATEWAY;
+}
+
 static struct mlxsw_sp_nexthop_group *
 mlxsw_sp_nexthop6_group_create(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_fib6_entry *fib6_entry)
@@ -3548,7 +3554,7 @@ mlxsw_sp_nexthop6_group_create(struct mlxsw_sp *mlxsw_sp,
 #endif
 	mlxsw_sp_rt6 = list_first_entry(&fib6_entry->rt6_list,
 					struct mlxsw_sp_rt6, list);
-	nh_grp->gateway = !!(mlxsw_sp_rt6->rt->rt6i_flags & RTF_GATEWAY);
+	nh_grp->gateway = mlxsw_sp_rt6_is_gateway(mlxsw_sp, mlxsw_sp_rt6->rt);
 	nh_grp->count = fib6_entry->nrt6;
 	for (i = 0; i < nh_grp->count; i++) {
 		struct rt6_info *rt = mlxsw_sp_rt6->rt;
@@ -3705,7 +3711,8 @@ mlxsw_sp_fib6_entry_nexthop_del(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_rt6_destroy(mlxsw_sp_rt6);
 }
 
-static void mlxsw_sp_fib6_entry_type_set(struct mlxsw_sp_fib_entry *fib_entry,
+static void mlxsw_sp_fib6_entry_type_set(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_fib_entry *fib_entry,
 					 const struct rt6_info *rt)
 {
 	/* Packets hitting RTF_REJECT routes need to be discarded by the
@@ -3718,7 +3725,7 @@ static void mlxsw_sp_fib6_entry_type_set(struct mlxsw_sp_fib_entry *fib_entry,
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
 	else if (rt->rt6i_flags & RTF_REJECT)
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-	else if (rt->rt6i_flags & RTF_GATEWAY)
+	else if (mlxsw_sp_rt6_is_gateway(mlxsw_sp, rt))
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
 	else
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
@@ -3758,7 +3765,7 @@ mlxsw_sp_fib6_entry_create(struct mlxsw_sp *mlxsw_sp,
 		goto err_rt6_create;
 	}
 
-	mlxsw_sp_fib6_entry_type_set(fib_entry, mlxsw_sp_rt6->rt);
+	mlxsw_sp_fib6_entry_type_set(mlxsw_sp, fib_entry, mlxsw_sp_rt6->rt);
 
 	INIT_LIST_HEAD(&fib6_entry->rt6_list);
 	list_add_tail(&mlxsw_sp_rt6->list, &fib6_entry->rt6_list);
-- 
2.9.3
