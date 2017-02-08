From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/15] mlxsw: spectrum_router: Reflect nexthop status changes
Date: Wed,  8 Feb 2017 11:16:40 +0100
Message-ID: <1486549002-2056-14-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33535 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754180AbdBHKtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:49:32 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so32450836wmv.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:49:31 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a packet hits a multipath route in the device's routing table, a
hash is computed over its headers, which is then used to select the
appropriate nexthop from the device's adjacency table.

There are situations in which the kernel removes a nexthop from a
multipath route (e.g., no carrier) and the device should do the same.

Upon the reception of NH_{ADD,DEL} events, add or remove a nexthop from
the device's adjacency table and refresh all the routes using the
nexthop group. If all the nexthops of a multipath route are invalid,
then any packet hitting the route would be trapped to the CPU for
forwarding.

If all the nexthops are DEAD, then the kernel would remove the route
entirely. On the other hand, if all the nexthops are merely LINKDOWN,
then the kernel would keep the route and forward any incoming packet
using a different route.

While the last case might sound like a problem, it's expected that a
routing daemon running in user space would remove such a route from the
FIB as it's dumped with the DEAD flag set.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 59 +++++++++++++++++++++-
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 136a50c..1c68b40 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1180,6 +1180,14 @@ static void mlxsw_sp_nexthop_remove(struct mlxsw_sp *mlxsw_sp,
 			       mlxsw_sp_nexthop_ht_params);
 }
 
+static struct mlxsw_sp_nexthop *
+mlxsw_sp_nexthop_lookup(struct mlxsw_sp *mlxsw_sp,
+			struct mlxsw_sp_nexthop_key key)
+{
+	return rhashtable_lookup_fast(&mlxsw_sp->router.nexthop_ht, &key,
+				      mlxsw_sp_nexthop_ht_params);
+}
+
 static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
 					     struct mlxsw_sp_vr *vr,
 					     u32 adj_index, u16 ecmp_size,
@@ -1417,7 +1425,7 @@ static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 	u8 nud_state, dead;
 	int err;
 
-	if (!nh->nh_grp->gateway)
+	if (!nh->nh_grp->gateway || nh->neigh_entry)
 		return 0;
 
 	/* Take a reference of neigh here ensuring that neigh would
@@ -1527,6 +1535,39 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
+static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
+				   unsigned long event, struct fib_nh *fib_nh)
+{
+	struct mlxsw_sp_nexthop_key key;
+	struct mlxsw_sp_nexthop *nh;
+	struct mlxsw_sp_rif *r;
+
+	if (mlxsw_sp->router.aborted)
+		return;
+
+	key.fib_nh = fib_nh;
+	nh = mlxsw_sp_nexthop_lookup(mlxsw_sp, key);
+	if (WARN_ON_ONCE(!nh))
+		return;
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fib_nh->nh_dev);
+	if (!r)
+		return;
+
+	switch (event) {
+	case FIB_EVENT_NH_ADD:
+		nh->r = r;
+		mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
+		break;
+	case FIB_EVENT_NH_DEL:
+		mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
+		nh->r = NULL;
+		break;
+	}
+
+	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
+}
+
 static struct mlxsw_sp_nexthop_group *
 mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 {
@@ -2085,7 +2126,10 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 
 struct mlxsw_sp_fib_event_work {
 	struct work_struct work;
-	struct fib_entry_notifier_info fen_info;
+	union {
+		struct fib_entry_notifier_info fen_info;
+		struct fib_nh_notifier_info fnh_info;
+	};
 	struct mlxsw_sp *mlxsw_sp;
 	unsigned long event;
 };
@@ -2114,6 +2158,12 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	case FIB_EVENT_RULE_DEL:
 		mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		break;
+	case FIB_EVENT_NH_ADD: /* fall through */
+	case FIB_EVENT_NH_DEL:
+		mlxsw_sp_nexthop_event(mlxsw_sp, fib_work->event,
+				       fib_work->fnh_info.fib_nh);
+		fib_info_put(fib_work->fnh_info.fib_nh->nh_parent);
+		break;
 	}
 	rtnl_unlock();
 	kfree(fib_work);
@@ -2147,6 +2197,11 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 		 */
 		fib_info_hold(fib_work->fen_info.fi);
 		break;
+	case FIB_EVENT_NH_ADD: /* fall through */
+	case FIB_EVENT_NH_DEL:
+		memcpy(&fib_work->fnh_info, ptr, sizeof(fib_work->fnh_info));
+		fib_info_hold(fib_work->fnh_info.fib_nh->nh_parent);
+		break;
 	}
 
 	mlxsw_core_schedule_work(&fib_work->work);
-- 
2.7.4
