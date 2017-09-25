From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/10] mlxsw: spectrum_router: Add helpers for nexthop access
Date: Mon, 25 Sep 2017 10:32:25 +0200
Message-ID: <20170925083230.1193-6-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38604 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbdIYIcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id x17so6466854wmd.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:35 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is done as a preparation before introducing the ability to dump the
adjacency table via dpipe, and to count the table size. The current table
implementation avoids tunnel entries, thus a helper for checking if
the nexthop group contains tunnel entries is also provided. The mlxsw's
nexthop representative struct stays private to the router module.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 71 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  | 12 ++++
 2 files changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8e78a95..78e0420 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2083,6 +2083,77 @@ struct mlxsw_sp_nexthop_group {
 #define nh_rif	nexthops[0].rif
 };
 
+struct mlxsw_sp_nexthop *mlxsw_sp_nexthop_next(struct mlxsw_sp_router *router,
+					       struct mlxsw_sp_nexthop *nh)
+{
+	if (!nh) {
+		if (list_empty(&router->nexthop_list))
+			return NULL;
+		else
+			return list_first_entry(&router->nexthop_list,
+						typeof(*nh), router_list_node);
+	}
+	if (list_is_last(&nh->router_list_node, &router->nexthop_list))
+		return NULL;
+	return list_next_entry(nh, router_list_node);
+}
+
+bool mlxsw_sp_nexthop_offload(struct mlxsw_sp_nexthop *nh)
+{
+	return nh->offloaded;
+}
+
+unsigned char *mlxsw_sp_nexthop_ha(struct mlxsw_sp_nexthop *nh)
+{
+	if (!nh->offloaded)
+		return NULL;
+	return nh->neigh_entry->ha;
+}
+
+int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
+			     u32 *p_adj_hash_index)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp = nh->nh_grp;
+	u32 adj_hash_index = 0;
+	int i;
+
+	if (!nh->offloaded || !nh_grp->adj_index_valid)
+		return -EINVAL;
+
+	*p_adj_index = nh_grp->adj_index;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh_iter = &nh_grp->nexthops[i];
+
+		if (nh_iter == nh)
+			break;
+		if (nh_iter->offloaded)
+			adj_hash_index++;
+	}
+
+	*p_adj_hash_index = adj_hash_index;
+	return 0;
+}
+
+struct mlxsw_sp_rif *mlxsw_sp_nexthop_rif(struct mlxsw_sp_nexthop *nh)
+{
+	return nh->rif;
+}
+
+bool mlxsw_sp_nexthop_group_has_ipip(struct mlxsw_sp_nexthop *nh)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp = nh->nh_grp;
+	int i;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh_iter = &nh_grp->nexthops[i];
+
+		if (nh_iter->type == MLXSW_SP_NEXTHOP_TYPE_IPIP)
+			return true;
+	}
+	return false;
+}
+
 static struct fib_info *
 mlxsw_sp_nexthop4_group_fi(const struct mlxsw_sp_nexthop_group *nh_grp)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index ae4c99b..d6951d5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -62,6 +62,7 @@ enum mlxsw_sp_rif_counter_dir {
 };
 
 struct mlxsw_sp_neigh_entry;
+struct mlxsw_sp_nexthop;
 
 struct mlxsw_sp_rif *mlxsw_sp_rif_by_index(const struct mlxsw_sp *mlxsw_sp,
 					   u16 rif_index);
@@ -108,5 +109,16 @@ union mlxsw_sp_l3addr
 mlxsw_sp_ipip_netdev_daddr(enum mlxsw_sp_l3proto proto,
 			   const struct net_device *ol_dev);
 __be32 mlxsw_sp_ipip_netdev_daddr4(const struct net_device *ol_dev);
+struct mlxsw_sp_nexthop *mlxsw_sp_nexthop_next(struct mlxsw_sp_router *router,
+					       struct mlxsw_sp_nexthop *nh);
+bool mlxsw_sp_nexthop_offload(struct mlxsw_sp_nexthop *nh);
+unsigned char *mlxsw_sp_nexthop_ha(struct mlxsw_sp_nexthop *nh);
+int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
+			     u32 *p_adj_hash_index);
+struct mlxsw_sp_rif *mlxsw_sp_nexthop_rif(struct mlxsw_sp_nexthop *nh);
+bool mlxsw_sp_nexthop_group_has_ipip(struct mlxsw_sp_nexthop *nh);
+#define mlxsw_sp_nexthop_for_each(nh, router)				\
+	for (nh = mlxsw_sp_nexthop_next(router, NULL); nh;		\
+	     nh = mlxsw_sp_nexthop_next(router, nh))
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.5
