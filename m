From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 10/12] mlxsw: spectrum_router: Add multicast routes notification handling functionality
Date: Wed, 27 Sep 2017 08:23:20 +0200
Message-ID: <20170927062322.5476-11-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35507 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751819AbdI0GXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id n64so3581645wrb.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:34 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add functionality for calling the multicast routing offloading logic upon
MFC and VIF add and delete notifications. In addition, call the multicast
routing upon RIF addition and deletion events.

As the multicast routing offload logic may sleep, the actual calls are done
in a deferred work. To ensure the MFC object is not freed in that interval,
a reference is held to it. In case of a failure, the abort mechanism is
used, which ejects all the routes from the hardware and triggers the
traffic to flow through the kernel.

Note: At that stage, the FIB notifications are still ignored, and will be
enabled in a further patch.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 187 ++++++++++++++++++++-
 1 file changed, 185 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 28c0c84..7758442 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -65,6 +65,8 @@
 #include "spectrum_cnt.h"
 #include "spectrum_dpipe.h"
 #include "spectrum_ipip.h"
+#include "spectrum_mr.h"
+#include "spectrum_mr_tcam.h"
 #include "spectrum_router.h"
 
 struct mlxsw_sp_vr;
@@ -459,6 +461,7 @@ struct mlxsw_sp_vr {
 	unsigned int rif_count;
 	struct mlxsw_sp_fib *fib4;
 	struct mlxsw_sp_fib *fib6;
+	struct mlxsw_sp_mr_table *mr4_table;
 };
 
 static const struct rhashtable_params mlxsw_sp_fib_ht_params;
@@ -653,7 +656,7 @@ static void mlxsw_sp_lpm_fini(struct mlxsw_sp *mlxsw_sp)
 
 static bool mlxsw_sp_vr_is_used(const struct mlxsw_sp_vr *vr)
 {
-	return !!vr->fib4 || !!vr->fib6;
+	return !!vr->fib4 || !!vr->fib6 || !!vr->mr4_table;
 }
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
@@ -744,9 +747,18 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
 		err = PTR_ERR(vr->fib6);
 		goto err_fib6_create;
 	}
+	vr->mr4_table = mlxsw_sp_mr_table_create(mlxsw_sp, vr->id,
+						 MLXSW_SP_L3_PROTO_IPV4);
+	if (IS_ERR(vr->mr4_table)) {
+		err = PTR_ERR(vr->mr4_table);
+		goto err_mr_table_create;
+	}
 	vr->tb_id = tb_id;
 	return vr;
 
+err_mr_table_create:
+	mlxsw_sp_fib_destroy(vr->fib6);
+	vr->fib6 = NULL;
 err_fib6_create:
 	mlxsw_sp_fib_destroy(vr->fib4);
 	vr->fib4 = NULL;
@@ -755,6 +767,8 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
 
 static void mlxsw_sp_vr_destroy(struct mlxsw_sp_vr *vr)
 {
+	mlxsw_sp_mr_table_destroy(vr->mr4_table);
+	vr->mr4_table = NULL;
 	mlxsw_sp_fib_destroy(vr->fib6);
 	vr->fib6 = NULL;
 	mlxsw_sp_fib_destroy(vr->fib4);
@@ -775,7 +789,8 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id)
 static void mlxsw_sp_vr_put(struct mlxsw_sp_vr *vr)
 {
 	if (!vr->rif_count && list_empty(&vr->fib4->node_list) &&
-	    list_empty(&vr->fib6->node_list))
+	    list_empty(&vr->fib6->node_list) &&
+	    mlxsw_sp_mr_table_empty(vr->mr4_table))
 		mlxsw_sp_vr_destroy(vr);
 }
 
@@ -4731,6 +4746,75 @@ static int __mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
+static int mlxsw_sp_router_fibmr_add(struct mlxsw_sp *mlxsw_sp,
+				     struct mfc_entry_notifier_info *men_info,
+				     bool replace)
+{
+	struct mlxsw_sp_vr *vr;
+
+	if (mlxsw_sp->router->aborted)
+		return 0;
+
+	vr = mlxsw_sp_vr_get(mlxsw_sp, men_info->tb_id);
+	if (IS_ERR(vr))
+		return PTR_ERR(vr);
+
+	return mlxsw_sp_mr_route4_add(vr->mr4_table, men_info->mfc, replace);
+}
+
+static void mlxsw_sp_router_fibmr_del(struct mlxsw_sp *mlxsw_sp,
+				      struct mfc_entry_notifier_info *men_info)
+{
+	struct mlxsw_sp_vr *vr;
+
+	if (mlxsw_sp->router->aborted)
+		return;
+
+	vr = mlxsw_sp_vr_find(mlxsw_sp, men_info->tb_id);
+	if (WARN_ON(!vr))
+		return;
+
+	mlxsw_sp_mr_route4_del(vr->mr4_table, men_info->mfc);
+	mlxsw_sp_vr_put(vr);
+}
+
+static int
+mlxsw_sp_router_fibmr_vif_add(struct mlxsw_sp *mlxsw_sp,
+			      struct vif_entry_notifier_info *ven_info)
+{
+	struct mlxsw_sp_rif *rif;
+	struct mlxsw_sp_vr *vr;
+
+	if (mlxsw_sp->router->aborted)
+		return 0;
+
+	vr = mlxsw_sp_vr_get(mlxsw_sp, ven_info->tb_id);
+	if (IS_ERR(vr))
+		return PTR_ERR(vr);
+
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, ven_info->dev);
+	return mlxsw_sp_mr_vif_add(vr->mr4_table, ven_info->dev,
+				   ven_info->vif_index,
+				   ven_info->vif_flags, rif);
+}
+
+static void
+mlxsw_sp_router_fibmr_vif_del(struct mlxsw_sp *mlxsw_sp,
+			      struct vif_entry_notifier_info *ven_info)
+{
+	struct mlxsw_sp_vr *vr;
+
+	if (mlxsw_sp->router->aborted)
+		return;
+
+	vr = mlxsw_sp_vr_find(mlxsw_sp, ven_info->tb_id);
+	if (WARN_ON(!vr))
+		return;
+
+	mlxsw_sp_mr_vif_del(vr->mr4_table, ven_info->vif_index);
+	mlxsw_sp_vr_put(vr);
+}
+
 static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 {
 	enum mlxsw_reg_ralxx_protocol proto = MLXSW_REG_RALXX_PROTOCOL_IPV4;
@@ -4741,6 +4825,10 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
+	/* The multicast router code does not need an abort trap as by default,
+	 * packets that don't match any routes are trapped to the CPU.
+	 */
+
 	proto = MLXSW_REG_RALXX_PROTOCOL_IPV6;
 	return __mlxsw_sp_router_set_abort_trap(mlxsw_sp, proto,
 						MLXSW_SP_LPM_TREE_MIN + 1);
@@ -4822,6 +4910,8 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 
 		if (!mlxsw_sp_vr_is_used(vr))
 			continue;
+
+		mlxsw_sp_mr_table_flush(vr->mr4_table);
 		mlxsw_sp_vr_fib_flush(mlxsw_sp, vr, MLXSW_SP_L3_PROTO_IPV4);
 
 		/* If virtual router was only used for IPv4, then it's no
@@ -4854,6 +4944,8 @@ struct mlxsw_sp_fib_event_work {
 		struct fib_entry_notifier_info fen_info;
 		struct fib_rule_notifier_info fr_info;
 		struct fib_nh_notifier_info fnh_info;
+		struct mfc_entry_notifier_info men_info;
+		struct vif_entry_notifier_info ven_info;
 	};
 	struct mlxsw_sp *mlxsw_sp;
 	unsigned long event;
@@ -4940,6 +5032,55 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 	kfree(fib_work);
 }
 
+static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
+{
+	struct mlxsw_sp_fib_event_work *fib_work =
+		container_of(work, struct mlxsw_sp_fib_event_work, work);
+	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
+	struct fib_rule *rule;
+	bool replace;
+	int err;
+
+	rtnl_lock();
+	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
+	case FIB_EVENT_ENTRY_ADD:
+		replace = fib_work->event == FIB_EVENT_ENTRY_REPLACE;
+
+		err = mlxsw_sp_router_fibmr_add(mlxsw_sp, &fib_work->men_info,
+						replace);
+		if (err)
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		ipmr_cache_put(fib_work->men_info.mfc);
+		break;
+	case FIB_EVENT_ENTRY_DEL:
+		mlxsw_sp_router_fibmr_del(mlxsw_sp, &fib_work->men_info);
+		ipmr_cache_put(fib_work->men_info.mfc);
+		break;
+	case FIB_EVENT_VIF_ADD:
+		err = mlxsw_sp_router_fibmr_vif_add(mlxsw_sp,
+						    &fib_work->ven_info);
+		if (err)
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		dev_put(fib_work->ven_info.dev);
+		break;
+	case FIB_EVENT_VIF_DEL:
+		mlxsw_sp_router_fibmr_vif_del(mlxsw_sp,
+					      &fib_work->ven_info);
+		dev_put(fib_work->ven_info.dev);
+		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		rule = fib_work->fr_info.rule;
+		if (!ipmr_rule_default(rule) && !rule->l3mdev)
+			mlxsw_sp_router_fib_abort(mlxsw_sp);
+		fib_rule_put(rule);
+		break;
+	}
+	rtnl_unlock();
+	kfree(fib_work);
+}
+
 static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
@@ -4985,6 +5126,30 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 	}
 }
 
+static void
+mlxsw_sp_router_fibmr_event(struct mlxsw_sp_fib_event_work *fib_work,
+			    struct fib_notifier_info *info)
+{
+	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
+	case FIB_EVENT_ENTRY_ADD: /* fall through */
+	case FIB_EVENT_ENTRY_DEL:
+		memcpy(&fib_work->men_info, info, sizeof(fib_work->men_info));
+		ipmr_cache_hold(fib_work->men_info.mfc);
+		break;
+	case FIB_EVENT_VIF_ADD: /* fall through */
+	case FIB_EVENT_VIF_DEL:
+		memcpy(&fib_work->ven_info, info, sizeof(fib_work->ven_info));
+		dev_hold(fib_work->ven_info.dev);
+		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
+		fib_rule_get(fib_work->fr_info.rule);
+		break;
+	}
+}
+
 /* Called with rcu_read_lock() */
 static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 				     unsigned long event, void *ptr)
@@ -5014,6 +5179,10 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 		INIT_WORK(&fib_work->work, mlxsw_sp_router_fib6_event_work);
 		mlxsw_sp_router_fib6_event(fib_work, info);
 		break;
+	case RTNL_FAMILY_IPMR:
+		INIT_WORK(&fib_work->work, mlxsw_sp_router_fibmr_event_work);
+		mlxsw_sp_router_fibmr_event(fib_work, info);
+		break;
 	}
 
 	mlxsw_core_schedule_work(&fib_work->work);
@@ -5227,12 +5396,18 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_configure;
 
+	err = mlxsw_sp_mr_rif_add(vr->mr4_table, rif);
+	if (err)
+		goto err_mr_rif_add;
+
 	mlxsw_sp_rif_counters_alloc(rif);
 	mlxsw_sp->router->rifs[rif_index] = rif;
 	vr->rif_count++;
 
 	return rif;
 
+err_mr_rif_add:
+	ops->deconfigure(rif);
 err_configure:
 	if (fid)
 		mlxsw_sp_fid_put(fid);
@@ -5257,6 +5432,7 @@ void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif)
 	vr->rif_count--;
 	mlxsw_sp->router->rifs[rif->rif_index] = NULL;
 	mlxsw_sp_rif_counters_free(rif);
+	mlxsw_sp_mr_rif_del(vr->mr4_table, rif);
 	ops->deconfigure(rif);
 	if (fid)
 		/* Loopback RIFs are not associated with a FID. */
@@ -6120,6 +6296,10 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_lpm_init;
 
+	err = mlxsw_sp_mr_init(mlxsw_sp, &mlxsw_sp_mr_tcam_ops);
+	if (err)
+		goto err_mr_init;
+
 	err = mlxsw_sp_vrs_init(mlxsw_sp);
 	if (err)
 		goto err_vrs_init;
@@ -6141,6 +6321,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_neigh_init:
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 err_vrs_init:
+	mlxsw_sp_mr_fini(mlxsw_sp);
+err_mr_init:
 	mlxsw_sp_lpm_fini(mlxsw_sp);
 err_lpm_init:
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
@@ -6162,6 +6344,7 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	unregister_fib_notifier(&mlxsw_sp->router->fib_nb);
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
+	mlxsw_sp_mr_fini(mlxsw_sp);
 	mlxsw_sp_lpm_fini(mlxsw_sp);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
-- 
2.9.5
