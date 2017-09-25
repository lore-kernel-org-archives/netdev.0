From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/10] mlxsw: spectrum: Add support for setting counters on nexthops
Date: Mon, 25 Sep 2017 10:32:28 +0200
Message-ID: <20170925083230.1193-9-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37721 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934140AbdIYIci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:38 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so6471609wmh.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:38 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for setting counters on nexthops based on dpipe's adjacency
table counter status. This patch also adds the ability for getting the
counter value, which will be used by the dpipe adjacency table dump
implementation in the next patches.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 52 ++++++++++++++++++++--
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  2 +
 2 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 78e0420..2400fff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2067,6 +2067,8 @@ struct mlxsw_sp_nexthop {
 		struct mlxsw_sp_neigh_entry *neigh_entry;
 		struct mlxsw_sp_ipip_entry *ipip_entry;
 	};
+	unsigned int counter_index;
+	bool counter_valid;
 };
 
 struct mlxsw_sp_nexthop_group {
@@ -2083,6 +2085,41 @@ struct mlxsw_sp_nexthop_group {
 #define nh_rif	nexthops[0].rif
 };
 
+static void mlxsw_sp_nexthop_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+					   struct mlxsw_sp_nexthop *nh)
+{
+	struct devlink *devlink;
+
+	devlink = priv_to_devlink(mlxsw_sp->core);
+	if (!devlink_dpipe_table_counter_enabled(devlink,
+						 MLXSW_SP_DPIPE_TABLE_NAME_ADJ))
+		return;
+
+	if (mlxsw_sp_flow_counter_alloc(mlxsw_sp, &nh->counter_index))
+		return;
+
+	nh->counter_valid = true;
+}
+
+static void mlxsw_sp_nexthop_counter_free(struct mlxsw_sp *mlxsw_sp,
+					  struct mlxsw_sp_nexthop *nh)
+{
+	if (!nh->counter_valid)
+		return;
+	mlxsw_sp_flow_counter_free(mlxsw_sp, nh->counter_index);
+	nh->counter_valid = false;
+}
+
+int mlxsw_sp_nexthop_counter_get(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_nexthop *nh, u64 *p_counter)
+{
+	if (!nh->counter_valid)
+		return -EINVAL;
+
+	return mlxsw_sp_flow_counter_get(mlxsw_sp, nh->counter_index,
+					 p_counter, NULL);
+}
+
 struct mlxsw_sp_nexthop *mlxsw_sp_nexthop_next(struct mlxsw_sp_router *router,
 					       struct mlxsw_sp_nexthop *nh)
 {
@@ -2411,8 +2448,8 @@ static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static int mlxsw_sp_nexthop_mac_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
-				       struct mlxsw_sp_nexthop *nh)
+static int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+				   struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 	char ratr_pl[MLXSW_REG_RATR_LEN];
@@ -2421,6 +2458,11 @@ static int mlxsw_sp_nexthop_mac_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
 			    true, MLXSW_REG_RATR_TYPE_ETHERNET,
 			    adj_index, neigh_entry->rif);
 	mlxsw_reg_ratr_eth_entry_pack(ratr_pl, neigh_entry->ha);
+	if (nh->counter_valid)
+		mlxsw_reg_ratr_counter_pack(ratr_pl, nh->counter_index, true);
+	else
+		mlxsw_reg_ratr_counter_pack(ratr_pl, 0, false);
+
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ratr), ratr_pl);
 }
 
@@ -2455,7 +2497,7 @@ mlxsw_sp_nexthop_group_update(struct mlxsw_sp *mlxsw_sp,
 		if (nh->update || reallocate) {
 			switch (nh->type) {
 			case MLXSW_SP_NEXTHOP_TYPE_ETH:
-				err = mlxsw_sp_nexthop_mac_update
+				err = mlxsw_sp_nexthop_update
 					    (mlxsw_sp, adj_index, nh);
 				break;
 			case MLXSW_SP_NEXTHOP_TYPE_IPIP:
@@ -2872,6 +2914,7 @@ static int mlxsw_sp_nexthop4_init(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
+	mlxsw_sp_nexthop_counter_alloc(mlxsw_sp, nh);
 	list_add_tail(&nh->router_list_node, &mlxsw_sp->router->nexthop_list);
 
 	if (!dev)
@@ -2898,6 +2941,7 @@ static void mlxsw_sp_nexthop4_fini(struct mlxsw_sp *mlxsw_sp,
 {
 	mlxsw_sp_nexthop4_type_fini(mlxsw_sp, nh);
 	list_del(&nh->router_list_node);
+	mlxsw_sp_nexthop_counter_free(mlxsw_sp, nh);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
@@ -4135,6 +4179,7 @@ static int mlxsw_sp_nexthop6_init(struct mlxsw_sp *mlxsw_sp,
 
 	nh->nh_grp = nh_grp;
 	memcpy(&nh->gw_addr, &rt->rt6i_gateway, sizeof(nh->gw_addr));
+	mlxsw_sp_nexthop_counter_alloc(mlxsw_sp, nh);
 
 	list_add_tail(&nh->router_list_node, &mlxsw_sp->router->nexthop_list);
 
@@ -4150,6 +4195,7 @@ static void mlxsw_sp_nexthop6_fini(struct mlxsw_sp *mlxsw_sp,
 {
 	mlxsw_sp_nexthop6_type_fini(mlxsw_sp, nh);
 	list_del(&nh->router_list_node);
+	mlxsw_sp_nexthop_counter_free(mlxsw_sp, nh);
 }
 
 static bool mlxsw_sp_rt6_is_gateway(const struct mlxsw_sp *mlxsw_sp,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index d6951d5..a6e8659 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -120,5 +120,7 @@ bool mlxsw_sp_nexthop_group_has_ipip(struct mlxsw_sp_nexthop *nh);
 #define mlxsw_sp_nexthop_for_each(nh, router)				\
 	for (nh = mlxsw_sp_nexthop_next(router, NULL); nh;		\
 	     nh = mlxsw_sp_nexthop_next(router, nh))
+int mlxsw_sp_nexthop_counter_get(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_nexthop *nh, u64 *p_counter);
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.5
