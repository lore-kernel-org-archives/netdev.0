From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/12] mlxsw: spectrum_router: Reduce scope of router struct
Date: Tue, 16 May 2017 19:38:25 +0200
Message-ID: <20170516173835.2978-3-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35498 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdEPRil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:41 -0400
Received: by mail-wr0-f194.google.com with SMTP id g12so14946065wrg.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:41 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In a similar fashion to previous patch, the router structure
('mlxsw_sp_router') doesn't need to be accessible to anyone, but the
router code located at spectrum_router.c

Make this apparent and reduce its scope by defining it there.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  49 +-----
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 195 ++++++++++++++-------
 2 files changed, 130 insertions(+), 114 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 976f5b6..2eb2230 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -110,33 +110,6 @@ static inline bool mlxsw_sp_fid_is_vfid(u16 fid)
 	return fid >= MLXSW_SP_VFID_BASE && fid < MLXSW_SP_DUMMY_FID;
 }
 
-#define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
-
-struct mlxsw_sp_prefix_usage {
-	DECLARE_BITMAP(b, MLXSW_SP_PREFIX_COUNT);
-};
-
-enum mlxsw_sp_l3proto {
-	MLXSW_SP_L3_PROTO_IPV4,
-	MLXSW_SP_L3_PROTO_IPV6,
-};
-
-struct mlxsw_sp_lpm_tree {
-	u8 id; /* tree ID */
-	unsigned int ref_count;
-	enum mlxsw_sp_l3proto proto;
-	struct mlxsw_sp_prefix_usage prefix_usage;
-};
-
-struct mlxsw_sp_fib;
-
-struct mlxsw_sp_vr {
-	u16 id; /* virtual router ID */
-	u32 tb_id; /* kernel fib table id */
-	unsigned int rif_count;
-	struct mlxsw_sp_fib *fib4;
-};
-
 enum mlxsw_sp_span_type {
 	MLXSW_SP_SPAN_EGRESS,
 	MLXSW_SP_SPAN_INGRESS
@@ -175,26 +148,8 @@ struct mlxsw_sp_port_mall_tc_entry {
 	};
 };
 
-struct mlxsw_sp_router {
-	struct mlxsw_sp_vr *vrs;
-	struct rhashtable neigh_ht;
-	struct rhashtable nexthop_group_ht;
-	struct rhashtable nexthop_ht;
-	struct {
-		struct mlxsw_sp_lpm_tree *trees;
-		unsigned int tree_count;
-	} lpm;
-	struct {
-		struct delayed_work dw;
-		unsigned long interval;	/* ms */
-	} neighs_update;
-	struct delayed_work nexthop_probe_dw;
-#define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
-	struct list_head nexthop_neighs_list;
-	bool aborted;
-};
-
 struct mlxsw_sp_sb;
+struct mlxsw_sp_router;
 struct mlxsw_sp_acl;
 struct mlxsw_sp_counter_pool;
 
@@ -226,7 +181,7 @@ struct mlxsw_sp {
 	struct mlxsw_sp_upper *lags;
 	u8 *port_to_module;
 	struct mlxsw_sp_sb *sb;
-	struct mlxsw_sp_router router;
+	struct mlxsw_sp_router *router;
 	struct mlxsw_sp_acl *acl;
 	struct {
 		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 33cec1c..28f7f54 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -56,6 +56,29 @@
 #include "spectrum_dpipe.h"
 #include "spectrum_router.h"
 
+struct mlxsw_sp_vr;
+struct mlxsw_sp_lpm_tree;
+
+struct mlxsw_sp_router {
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_vr *vrs;
+	struct rhashtable neigh_ht;
+	struct rhashtable nexthop_group_ht;
+	struct rhashtable nexthop_ht;
+	struct {
+		struct mlxsw_sp_lpm_tree *trees;
+		unsigned int tree_count;
+	} lpm;
+	struct {
+		struct delayed_work dw;
+		unsigned long interval;	/* ms */
+	} neighs_update;
+	struct delayed_work nexthop_probe_dw;
+#define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
+	struct list_head nexthop_neighs_list;
+	bool aborted;
+};
+
 struct mlxsw_sp_rif {
 	struct list_head nexthop_list;
 	struct list_head neigh_list;
@@ -220,6 +243,12 @@ static struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev);
 
+#define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
+
+struct mlxsw_sp_prefix_usage {
+	DECLARE_BITMAP(b, MLXSW_SP_PREFIX_COUNT);
+};
+
 #define mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage) \
 	for_each_set_bit(prefix, (prefix_usage)->b, MLXSW_SP_PREFIX_COUNT)
 
@@ -284,6 +313,7 @@ enum mlxsw_sp_fib_entry_type {
 };
 
 struct mlxsw_sp_nexthop_group;
+struct mlxsw_sp_fib;
 
 struct mlxsw_sp_fib_node {
 	struct list_head entry_list;
@@ -310,6 +340,18 @@ struct mlxsw_sp_fib_entry {
 	bool offloaded;
 };
 
+enum mlxsw_sp_l3proto {
+	MLXSW_SP_L3_PROTO_IPV4,
+	MLXSW_SP_L3_PROTO_IPV6,
+};
+
+struct mlxsw_sp_lpm_tree {
+	u8 id; /* tree ID */
+	unsigned int ref_count;
+	enum mlxsw_sp_l3proto proto;
+	struct mlxsw_sp_prefix_usage prefix_usage;
+};
+
 struct mlxsw_sp_fib {
 	struct rhashtable ht;
 	struct list_head node_list;
@@ -320,6 +362,13 @@ struct mlxsw_sp_fib {
 	enum mlxsw_sp_l3proto proto;
 };
 
+struct mlxsw_sp_vr {
+	u16 id; /* virtual router ID */
+	u32 tb_id; /* kernel fib table id */
+	unsigned int rif_count;
+	struct mlxsw_sp_fib *fib4;
+};
+
 static const struct rhashtable_params mlxsw_sp_fib_ht_params;
 
 static struct mlxsw_sp_fib *mlxsw_sp_fib_create(struct mlxsw_sp_vr *vr,
@@ -358,8 +407,8 @@ mlxsw_sp_lpm_tree_find_unused(struct mlxsw_sp *mlxsw_sp)
 	static struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
 
-	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
+	for (i = 0; i < mlxsw_sp->router->lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router->lpm.trees[i];
 		if (lpm_tree->ref_count == 0)
 			return lpm_tree;
 	}
@@ -455,8 +504,8 @@ mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
 
-	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
+	for (i = 0; i < mlxsw_sp->router->lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router->lpm.trees[i];
 		if (lpm_tree->ref_count != 0 &&
 		    lpm_tree->proto == proto &&
 		    mlxsw_sp_prefix_usage_eq(&lpm_tree->prefix_usage,
@@ -493,15 +542,15 @@ static int mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 		return -EIO;
 
 	max_trees = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_LPM_TREES);
-	mlxsw_sp->router.lpm.tree_count = max_trees - MLXSW_SP_LPM_TREE_MIN;
-	mlxsw_sp->router.lpm.trees = kcalloc(mlxsw_sp->router.lpm.tree_count,
+	mlxsw_sp->router->lpm.tree_count = max_trees - MLXSW_SP_LPM_TREE_MIN;
+	mlxsw_sp->router->lpm.trees = kcalloc(mlxsw_sp->router->lpm.tree_count,
 					     sizeof(struct mlxsw_sp_lpm_tree),
 					     GFP_KERNEL);
-	if (!mlxsw_sp->router.lpm.trees)
+	if (!mlxsw_sp->router->lpm.trees)
 		return -ENOMEM;
 
-	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
+	for (i = 0; i < mlxsw_sp->router->lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router->lpm.trees[i];
 		lpm_tree->id = i + MLXSW_SP_LPM_TREE_MIN;
 	}
 
@@ -510,7 +559,7 @@ static int mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 
 static void mlxsw_sp_lpm_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	kfree(mlxsw_sp->router.lpm.trees);
+	kfree(mlxsw_sp->router->lpm.trees);
 }
 
 static bool mlxsw_sp_vr_is_used(const struct mlxsw_sp_vr *vr)
@@ -524,7 +573,7 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 	int i;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
-		vr = &mlxsw_sp->router.vrs[i];
+		vr = &mlxsw_sp->router->vrs[i];
 		if (!mlxsw_sp_vr_is_used(vr))
 			return vr;
 	}
@@ -570,7 +619,7 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
 	tb_id = mlxsw_sp_fix_tb_id(tb_id);
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
-		vr = &mlxsw_sp->router.vrs[i];
+		vr = &mlxsw_sp->router->vrs[i];
 		if (mlxsw_sp_vr_is_used(vr) && vr->tb_id == tb_id)
 			return vr;
 	}
@@ -677,13 +726,13 @@ static int mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
 		return -EIO;
 
 	max_vrs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS);
-	mlxsw_sp->router.vrs = kcalloc(max_vrs, sizeof(struct mlxsw_sp_vr),
-				       GFP_KERNEL);
-	if (!mlxsw_sp->router.vrs)
+	mlxsw_sp->router->vrs = kcalloc(max_vrs, sizeof(struct mlxsw_sp_vr),
+					GFP_KERNEL);
+	if (!mlxsw_sp->router->vrs)
 		return -ENOMEM;
 
 	for (i = 0; i < max_vrs; i++) {
-		vr = &mlxsw_sp->router.vrs[i];
+		vr = &mlxsw_sp->router->vrs[i];
 		vr->id = i;
 	}
 
@@ -703,7 +752,7 @@ static void mlxsw_sp_vrs_fini(struct mlxsw_sp *mlxsw_sp)
 	 */
 	mlxsw_core_flush_owq();
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
-	kfree(mlxsw_sp->router.vrs);
+	kfree(mlxsw_sp->router->vrs);
 }
 
 struct mlxsw_sp_neigh_key {
@@ -755,7 +804,7 @@ static int
 mlxsw_sp_neigh_entry_insert(struct mlxsw_sp *mlxsw_sp,
 			    struct mlxsw_sp_neigh_entry *neigh_entry)
 {
-	return rhashtable_insert_fast(&mlxsw_sp->router.neigh_ht,
+	return rhashtable_insert_fast(&mlxsw_sp->router->neigh_ht,
 				      &neigh_entry->ht_node,
 				      mlxsw_sp_neigh_ht_params);
 }
@@ -764,7 +813,7 @@ static void
 mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
 			    struct mlxsw_sp_neigh_entry *neigh_entry)
 {
-	rhashtable_remove_fast(&mlxsw_sp->router.neigh_ht,
+	rhashtable_remove_fast(&mlxsw_sp->router->neigh_ht,
 			       &neigh_entry->ht_node,
 			       mlxsw_sp_neigh_ht_params);
 }
@@ -812,7 +861,7 @@ mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 	struct mlxsw_sp_neigh_key key;
 
 	key.n = n;
-	return rhashtable_lookup_fast(&mlxsw_sp->router.neigh_ht,
+	return rhashtable_lookup_fast(&mlxsw_sp->router->neigh_ht,
 				      &key, mlxsw_sp_neigh_ht_params);
 }
 
@@ -821,7 +870,7 @@ mlxsw_sp_router_neighs_update_interval_init(struct mlxsw_sp *mlxsw_sp)
 {
 	unsigned long interval = NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME);
 
-	mlxsw_sp->router.neighs_update.interval = jiffies_to_msecs(interval);
+	mlxsw_sp->router->neighs_update.interval = jiffies_to_msecs(interval);
 }
 
 static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
@@ -951,7 +1000,7 @@ static void mlxsw_sp_router_neighs_update_nh(struct mlxsw_sp *mlxsw_sp)
 
 	/* Take RTNL mutex here to prevent lists from changes */
 	rtnl_lock();
-	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
+	list_for_each_entry(neigh_entry, &mlxsw_sp->router->nexthop_neighs_list,
 			    nexthop_neighs_list_node)
 		/* If this neigh have nexthops, make the kernel think this neigh
 		 * is active regardless of the traffic.
@@ -963,33 +1012,35 @@ static void mlxsw_sp_router_neighs_update_nh(struct mlxsw_sp *mlxsw_sp)
 static void
 mlxsw_sp_router_neighs_update_work_schedule(struct mlxsw_sp *mlxsw_sp)
 {
-	unsigned long interval = mlxsw_sp->router.neighs_update.interval;
+	unsigned long interval = mlxsw_sp->router->neighs_update.interval;
 
-	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw,
+	mlxsw_core_schedule_dw(&mlxsw_sp->router->neighs_update.dw,
 			       msecs_to_jiffies(interval));
 }
 
 static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
 {
-	struct mlxsw_sp *mlxsw_sp = container_of(work, struct mlxsw_sp,
-						 router.neighs_update.dw.work);
+	struct mlxsw_sp_router *router;
 	int err;
 
-	err = mlxsw_sp_router_neighs_update_rauhtd(mlxsw_sp);
+	router = container_of(work, struct mlxsw_sp_router,
+			      neighs_update.dw.work);
+	err = mlxsw_sp_router_neighs_update_rauhtd(router->mlxsw_sp);
 	if (err)
-		dev_err(mlxsw_sp->bus_info->dev, "Could not update kernel for neigh activity");
+		dev_err(router->mlxsw_sp->bus_info->dev, "Could not update kernel for neigh activity");
 
-	mlxsw_sp_router_neighs_update_nh(mlxsw_sp);
+	mlxsw_sp_router_neighs_update_nh(router->mlxsw_sp);
 
-	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
+	mlxsw_sp_router_neighs_update_work_schedule(router->mlxsw_sp);
 }
 
 static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	struct mlxsw_sp *mlxsw_sp = container_of(work, struct mlxsw_sp,
-						 router.nexthop_probe_dw.work);
+	struct mlxsw_sp_router *router;
 
+	router = container_of(work, struct mlxsw_sp_router,
+			      nexthop_probe_dw.work);
 	/* Iterate over nexthop neighbours, find those who are unresolved and
 	 * send arp on them. This solves the chicken-egg problem when
 	 * the nexthop wouldn't get offloaded until the neighbor is resolved
@@ -999,13 +1050,13 @@ static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
 	 * Take RTNL mutex here to prevent lists from changes.
 	 */
 	rtnl_lock();
-	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
+	list_for_each_entry(neigh_entry, &router->nexthop_neighs_list,
 			    nexthop_neighs_list_node)
 		if (!neigh_entry->connected)
 			neigh_event_send(neigh_entry->key.n, NULL);
 	rtnl_unlock();
 
-	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw,
+	mlxsw_core_schedule_dw(&router->nexthop_probe_dw,
 			       MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL);
 }
 
@@ -1127,7 +1178,7 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 
 		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 		interval = jiffies_to_msecs(NEIGH_VAR(p, DELAY_PROBE_TIME));
-		mlxsw_sp->router.neighs_update.interval = interval;
+		mlxsw_sp->router->neighs_update.interval = interval;
 
 		mlxsw_sp_port_dev_put(mlxsw_sp_port);
 		break;
@@ -1168,7 +1219,7 @@ static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
-	err = rhashtable_init(&mlxsw_sp->router.neigh_ht,
+	err = rhashtable_init(&mlxsw_sp->router->neigh_ht,
 			      &mlxsw_sp_neigh_ht_params);
 	if (err)
 		return err;
@@ -1179,20 +1230,20 @@ static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_router_neighs_update_interval_init(mlxsw_sp);
 
 	/* Create the delayed works for the activity_update */
-	INIT_DELAYED_WORK(&mlxsw_sp->router.neighs_update.dw,
+	INIT_DELAYED_WORK(&mlxsw_sp->router->neighs_update.dw,
 			  mlxsw_sp_router_neighs_update_work);
-	INIT_DELAYED_WORK(&mlxsw_sp->router.nexthop_probe_dw,
+	INIT_DELAYED_WORK(&mlxsw_sp->router->nexthop_probe_dw,
 			  mlxsw_sp_router_probe_unresolved_nexthops);
-	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw, 0);
-	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw, 0);
+	mlxsw_core_schedule_dw(&mlxsw_sp->router->neighs_update.dw, 0);
+	mlxsw_core_schedule_dw(&mlxsw_sp->router->nexthop_probe_dw, 0);
 	return 0;
 }
 
 static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	cancel_delayed_work_sync(&mlxsw_sp->router.neighs_update.dw);
-	cancel_delayed_work_sync(&mlxsw_sp->router.nexthop_probe_dw);
-	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
+	cancel_delayed_work_sync(&mlxsw_sp->router->neighs_update.dw);
+	cancel_delayed_work_sync(&mlxsw_sp->router->nexthop_probe_dw);
+	rhashtable_destroy(&mlxsw_sp->router->neigh_ht);
 }
 
 static int mlxsw_sp_neigh_rif_flush(struct mlxsw_sp *mlxsw_sp,
@@ -1267,7 +1318,7 @@ static const struct rhashtable_params mlxsw_sp_nexthop_group_ht_params = {
 static int mlxsw_sp_nexthop_group_insert(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_nexthop_group *nh_grp)
 {
-	return rhashtable_insert_fast(&mlxsw_sp->router.nexthop_group_ht,
+	return rhashtable_insert_fast(&mlxsw_sp->router->nexthop_group_ht,
 				      &nh_grp->ht_node,
 				      mlxsw_sp_nexthop_group_ht_params);
 }
@@ -1275,7 +1326,7 @@ static int mlxsw_sp_nexthop_group_insert(struct mlxsw_sp *mlxsw_sp,
 static void mlxsw_sp_nexthop_group_remove(struct mlxsw_sp *mlxsw_sp,
 					  struct mlxsw_sp_nexthop_group *nh_grp)
 {
-	rhashtable_remove_fast(&mlxsw_sp->router.nexthop_group_ht,
+	rhashtable_remove_fast(&mlxsw_sp->router->nexthop_group_ht,
 			       &nh_grp->ht_node,
 			       mlxsw_sp_nexthop_group_ht_params);
 }
@@ -1284,7 +1335,7 @@ static struct mlxsw_sp_nexthop_group *
 mlxsw_sp_nexthop_group_lookup(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_nexthop_group_key key)
 {
-	return rhashtable_lookup_fast(&mlxsw_sp->router.nexthop_group_ht, &key,
+	return rhashtable_lookup_fast(&mlxsw_sp->router->nexthop_group_ht, &key,
 				      mlxsw_sp_nexthop_group_ht_params);
 }
 
@@ -1297,14 +1348,14 @@ static const struct rhashtable_params mlxsw_sp_nexthop_ht_params = {
 static int mlxsw_sp_nexthop_insert(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_nexthop *nh)
 {
-	return rhashtable_insert_fast(&mlxsw_sp->router.nexthop_ht,
+	return rhashtable_insert_fast(&mlxsw_sp->router->nexthop_ht,
 				      &nh->ht_node, mlxsw_sp_nexthop_ht_params);
 }
 
 static void mlxsw_sp_nexthop_remove(struct mlxsw_sp *mlxsw_sp,
 				    struct mlxsw_sp_nexthop *nh)
 {
-	rhashtable_remove_fast(&mlxsw_sp->router.nexthop_ht, &nh->ht_node,
+	rhashtable_remove_fast(&mlxsw_sp->router->nexthop_ht, &nh->ht_node,
 			       mlxsw_sp_nexthop_ht_params);
 }
 
@@ -1312,7 +1363,7 @@ static struct mlxsw_sp_nexthop *
 mlxsw_sp_nexthop_lookup(struct mlxsw_sp *mlxsw_sp,
 			struct mlxsw_sp_nexthop_key key)
 {
-	return rhashtable_lookup_fast(&mlxsw_sp->router.nexthop_ht, &key,
+	return rhashtable_lookup_fast(&mlxsw_sp->router->nexthop_ht, &key,
 				      mlxsw_sp_nexthop_ht_params);
 }
 
@@ -1599,7 +1650,7 @@ static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 	 */
 	if (list_empty(&neigh_entry->nexthop_list))
 		list_add_tail(&neigh_entry->nexthop_neighs_list_node,
-			      &mlxsw_sp->router.nexthop_neighs_list);
+			      &mlxsw_sp->router->nexthop_neighs_list);
 
 	nh->neigh_entry = neigh_entry;
 	list_add_tail(&nh->neigh_list_node, &neigh_entry->nexthop_list);
@@ -1697,7 +1748,7 @@ static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_nexthop *nh;
 	struct mlxsw_sp_rif *rif;
 
-	if (mlxsw_sp->router.aborted)
+	if (mlxsw_sp->router->aborted)
 		return;
 
 	key.fib_nh = fib_nh;
@@ -2510,7 +2561,7 @@ mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_fib_node *fib_node;
 	int err;
 
-	if (mlxsw_sp->router.aborted)
+	if (mlxsw_sp->router->aborted)
 		return 0;
 
 	fib_node = mlxsw_sp_fib4_node_get(mlxsw_sp, fen_info);
@@ -2550,7 +2601,7 @@ static void mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_node *fib_node;
 
-	if (mlxsw_sp->router.aborted)
+	if (mlxsw_sp->router->aborted)
 		return;
 
 	fib_entry = mlxsw_sp_fib4_entry_lookup(mlxsw_sp, fen_info);
@@ -2581,7 +2632,7 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 		return err;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
-		struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[i];
+		struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[i];
 		char raltb_pl[MLXSW_REG_RALTB_LEN];
 		char ralue_pl[MLXSW_REG_RALUE_LEN];
 
@@ -2663,7 +2714,7 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 	int i;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
-		struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[i];
+		struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[i];
 
 		if (!mlxsw_sp_vr_is_used(vr))
 			continue;
@@ -2675,11 +2726,11 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
-	if (mlxsw_sp->router.aborted)
+	if (mlxsw_sp->router->aborted)
 		return;
 	dev_warn(mlxsw_sp->bus_info->dev, "FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.\n");
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
-	mlxsw_sp->router.aborted = true;
+	mlxsw_sp->router->aborted = true;
 	err = mlxsw_sp_router_set_abort_trap(mlxsw_sp);
 	if (err)
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
@@ -3015,7 +3066,7 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 					  struct mlxsw_sp_rif *rif)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[rif->vr_id];
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[rif->vr_id];
 	struct net_device *l3_dev = rif->dev;
 	struct mlxsw_sp_fid *f = rif->f;
 	u16 rif_index = rif->rif_index;
@@ -3273,7 +3324,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[rif->vr_id];
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[rif->vr_id];
 	struct net_device *l3_dev = rif->dev;
 	struct mlxsw_sp_fid *f = rif->f;
 	u16 rif_index = rif->rif_index;
@@ -3545,19 +3596,26 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_sp_router *router;
 	int err;
 
-	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
+	router = kzalloc(sizeof(*mlxsw_sp->router), GFP_KERNEL);
+	if (!router)
+		return -ENOMEM;
+	mlxsw_sp->router = router;
+	router->mlxsw_sp = mlxsw_sp;
+
+	INIT_LIST_HEAD(&mlxsw_sp->router->nexthop_neighs_list);
 	err = __mlxsw_sp_router_init(mlxsw_sp);
 	if (err)
-		return err;
+		goto err_router_init;
 
-	err = rhashtable_init(&mlxsw_sp->router.nexthop_ht,
+	err = rhashtable_init(&mlxsw_sp->router->nexthop_ht,
 			      &mlxsw_sp_nexthop_ht_params);
 	if (err)
 		goto err_nexthop_ht_init;
 
-	err = rhashtable_init(&mlxsw_sp->router.nexthop_group_ht,
+	err = rhashtable_init(&mlxsw_sp->router->nexthop_group_ht,
 			      &mlxsw_sp_nexthop_group_ht_params);
 	if (err)
 		goto err_nexthop_group_ht_init;
@@ -3589,11 +3647,13 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_vrs_init:
 	mlxsw_sp_lpm_fini(mlxsw_sp);
 err_lpm_init:
-	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
+	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
 err_nexthop_group_ht_init:
-	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
+	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
 err_nexthop_ht_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
+err_router_init:
+	kfree(mlxsw_sp->router);
 	return err;
 }
 
@@ -3603,7 +3663,8 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 	mlxsw_sp_lpm_fini(mlxsw_sp);
-	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
-	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
+	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
+	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
 	__mlxsw_sp_router_fini(mlxsw_sp);
+	kfree(mlxsw_sp->router);
 }
-- 
2.9.3
