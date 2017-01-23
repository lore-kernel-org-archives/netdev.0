From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_router: Correctly reallocate adjacency entries
Date: Mon, 23 Jan 2017 11:11:42 +0100
Message-ID: <1485166302-5629-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34376 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWKLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 05:11:45 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so25157421wmi.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 02:11:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

mlxsw_sp_nexthop_group_mac_update() is called in one of two cases:

1) When the MAC of a nexthop needs to be updated
2) When the size of a nexthop group has changed

In the second case the adjacency entries for the nexthop group need to
be reallocated from the adjacency table. In this case we must write to
the entries the MAC addresses of all the nexthops that should be
offloaded and not only those whose MAC changed. Otherwise, these entries
would be filled with garbage data, resulting in packet loss.

Fixes: a7ff87acd995 ("mlxsw: spectrum_router: Implement next-hop routing")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 01d0efa..9e494a4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1172,7 +1172,8 @@ static int mlxsw_sp_nexthop_mac_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
 
 static int
 mlxsw_sp_nexthop_group_mac_update(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_nexthop_group *nh_grp)
+				  struct mlxsw_sp_nexthop_group *nh_grp,
+				  bool reallocate)
 {
 	u32 adj_index = nh_grp->adj_index; /* base */
 	struct mlxsw_sp_nexthop *nh;
@@ -1187,7 +1188,7 @@ mlxsw_sp_nexthop_group_mac_update(struct mlxsw_sp *mlxsw_sp,
 			continue;
 		}
 
-		if (nh->update) {
+		if (nh->update || reallocate) {
 			err = mlxsw_sp_nexthop_mac_update(mlxsw_sp,
 							  adj_index, nh);
 			if (err)
@@ -1248,7 +1249,8 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 		/* Nothing was added or removed, so no need to reallocate. Just
 		 * update MAC on existing adjacency indexes.
 		 */
-		err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp);
+		err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp,
+							false);
 		if (err) {
 			dev_warn(mlxsw_sp->bus_info->dev, "Failed to update neigh MAC in adjacency table.\n");
 			goto set_trap;
@@ -1276,7 +1278,7 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 	nh_grp->adj_index_valid = 1;
 	nh_grp->adj_index = adj_index;
 	nh_grp->ecmp_size = ecmp_size;
-	err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp);
+	err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp, true);
 	if (err) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to update neigh MAC in adjacency table.\n");
 		goto set_trap;
-- 
2.7.4
