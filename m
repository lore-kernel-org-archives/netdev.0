From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: spectrum_router: Populate adjacency entries according to weights
Date: Sun, 22 Oct 2017 23:11:48 +0200
Message-ID: <20171022211150.2567-7-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:45593 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932173AbdJVVL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:57 -0400
Received: by mail-wr0-f194.google.com with SMTP id y9so3280520wrb.2
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:57 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now the driver assumed all the nexthops have an equal weight
and wrote each to a single adjacency entry.

This patch takes the `weight` parameter into account and populates the
adjacency group according to the relative weight of each nexthop.

Specifically, the weights of all the nexthops that should be offloaded
are first normalized and then used to calculate the upper adjacency
index of each nexthop. This is done according to the hash-threshold
algorithm used by the kernel for IPv4 multi-path routing.

Adjacency groups are currently limited to 32 entries which limits the
weights that can be used, but follow-up patches will introduce groups of
512 entries.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 111 ++++++++++++++++++---
 1 file changed, 99 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 68ce549..27b632c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -46,6 +46,7 @@
 #include <linux/if_bridge.h>
 #include <linux/socket.h>
 #include <linux/route.h>
+#include <linux/gcd.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -2204,6 +2205,8 @@ struct mlxsw_sp_nexthop {
 	unsigned char gw_addr[sizeof(struct in6_addr)];
 	int ifindex;
 	int nh_weight;
+	int norm_nh_weight;
+	int num_adj_entries;
 	struct mlxsw_sp_rif *rif;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
@@ -2233,6 +2236,7 @@ struct mlxsw_sp_nexthop_group {
 	u32 adj_index;
 	u16 ecmp_size;
 	u16 count;
+	int sum_norm_weight;
 	struct mlxsw_sp_nexthop nexthops[0];
 #define nh_rif	nexthops[0].rif
 };
@@ -2318,7 +2322,7 @@ int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
 		if (nh_iter == nh)
 			break;
 		if (nh_iter->offloaded)
-			adj_hash_index++;
+			adj_hash_index += nh_iter->num_adj_entries;
 	}
 
 	*p_adj_hash_index = adj_hash_index;
@@ -2601,8 +2605,8 @@ static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
-			    struct mlxsw_sp_nexthop *nh)
+static int __mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+				     struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 	char ratr_pl[MLXSW_REG_RATR_LEN];
@@ -2619,9 +2623,25 @@ int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ratr), ratr_pl);
 }
 
-static int mlxsw_sp_nexthop_ipip_update(struct mlxsw_sp *mlxsw_sp,
-					u32 adj_index,
-					struct mlxsw_sp_nexthop *nh)
+int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+			    struct mlxsw_sp_nexthop *nh)
+{
+	int i;
+
+	for (i = 0; i < nh->num_adj_entries; i++) {
+		int err;
+
+		err = __mlxsw_sp_nexthop_update(mlxsw_sp, adj_index + i, nh);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int __mlxsw_sp_nexthop_ipip_update(struct mlxsw_sp *mlxsw_sp,
+					  u32 adj_index,
+					  struct mlxsw_sp_nexthop *nh)
 {
 	const struct mlxsw_sp_ipip_ops *ipip_ops;
 
@@ -2629,6 +2649,24 @@ static int mlxsw_sp_nexthop_ipip_update(struct mlxsw_sp *mlxsw_sp,
 	return ipip_ops->nexthop_update(mlxsw_sp, adj_index, nh->ipip_entry);
 }
 
+static int mlxsw_sp_nexthop_ipip_update(struct mlxsw_sp *mlxsw_sp,
+					u32 adj_index,
+					struct mlxsw_sp_nexthop *nh)
+{
+	int i;
+
+	for (i = 0; i < nh->num_adj_entries; i++) {
+		int err;
+
+		err = __mlxsw_sp_nexthop_ipip_update(mlxsw_sp, adj_index + i,
+						     nh);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int
 mlxsw_sp_nexthop_group_update(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_nexthop_group *nh_grp,
@@ -2663,7 +2701,7 @@ mlxsw_sp_nexthop_group_update(struct mlxsw_sp *mlxsw_sp,
 			nh->update = 0;
 			nh->offloaded = 1;
 		}
-		adj_index++;
+		adj_index += nh->num_adj_entries;
 	}
 	return 0;
 }
@@ -2762,16 +2800,64 @@ static int mlxsw_sp_fix_adj_grp_size(struct mlxsw_sp *mlxsw_sp,
 }
 
 static void
+mlxsw_sp_nexthop_group_normalize(struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	int i, g = 0, sum_norm_weight = 0;
+	struct mlxsw_sp_nexthop *nh;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+
+		if (!nh->should_offload)
+			continue;
+		if (g > 0)
+			g = gcd(nh->nh_weight, g);
+		else
+			g = nh->nh_weight;
+	}
+
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+
+		if (!nh->should_offload)
+			continue;
+		nh->norm_nh_weight = nh->nh_weight / g;
+		sum_norm_weight += nh->norm_nh_weight;
+	}
+
+	nh_grp->sum_norm_weight = sum_norm_weight;
+}
+
+static void
+mlxsw_sp_nexthop_group_rebalance(struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	int total = nh_grp->sum_norm_weight;
+	u16 ecmp_size = nh_grp->ecmp_size;
+	int i, weight = 0, lower_bound = 0;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh = &nh_grp->nexthops[i];
+		int upper_bound;
+
+		if (!nh->should_offload)
+			continue;
+		weight += nh->norm_nh_weight;
+		upper_bound = DIV_ROUND_CLOSEST(ecmp_size * weight, total);
+		nh->num_adj_entries = upper_bound - lower_bound;
+		lower_bound = upper_bound;
+	}
+}
+
+static void
 mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_nexthop_group *nh_grp)
 {
+	u16 ecmp_size, old_ecmp_size;
 	struct mlxsw_sp_nexthop *nh;
 	bool offload_change = false;
 	u32 adj_index;
-	u16 ecmp_size = 0;
 	bool old_adj_index_valid;
 	u32 old_adj_index;
-	u16 old_ecmp_size;
 	int i;
 	int err;
 
@@ -2788,8 +2874,6 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 			if (nh->should_offload)
 				nh->update = 1;
 		}
-		if (nh->should_offload)
-			ecmp_size++;
 	}
 	if (!offload_change) {
 		/* Nothing was added or removed, so no need to reallocate. Just
@@ -2802,12 +2886,14 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 		}
 		return;
 	}
-	if (!ecmp_size)
+	mlxsw_sp_nexthop_group_normalize(nh_grp);
+	if (!nh_grp->sum_norm_weight)
 		/* No neigh of this group is connected so we just set
 		 * the trap and let everthing flow through kernel.
 		 */
 		goto set_trap;
 
+	ecmp_size = nh_grp->sum_norm_weight;
 	err = mlxsw_sp_fix_adj_grp_size(mlxsw_sp, &ecmp_size);
 	if (err)
 		/* No valid allocation size available. */
@@ -2827,6 +2913,7 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 	nh_grp->adj_index_valid = 1;
 	nh_grp->adj_index = adj_index;
 	nh_grp->ecmp_size = ecmp_size;
+	mlxsw_sp_nexthop_group_rebalance(nh_grp);
 	err = mlxsw_sp_nexthop_group_update(mlxsw_sp, nh_grp, true);
 	if (err) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to update neigh MAC in adjacency table.\n");
-- 
2.9.5
