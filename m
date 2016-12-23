From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/3] mlxsw: spectrum_router: Correctly remove nexthop groups
Date: Fri, 23 Dec 2016 09:32:50 +0100
Message-ID: <1482481970-2327-4-git-send-email-jiri@resnulli.us>
References: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33007 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755008AbcLWIdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 03:33:01 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so40227534wmu.0
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 00:33:00 -0800 (PST)
In-Reply-To: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

At the end of the nexthop initialization process we determine whether
the nexthop should be offloaded or not based on the NUD state of the
neighbour representing it. After all the nexthops were initialized we
refresh the nexthop group and potentially offload it to the device, in
case some of the nexthops were resolved.

Make the destruction of a nexthop group symmetric with its creation by
marking all nexthops as invalid and then refresh the nexthop group to
make sure it was removed from the device's tables.

Fixes: b2157149b0b0 ("mlxsw: spectrum_router: Add the nexthop neigh activity update")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a0f9742..01d0efa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1396,6 +1396,7 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 
+	__mlxsw_sp_nexthop_neigh_update(nh, true);
 	list_del(&nh->neigh_list_node);
 
 	/* If that is the last nexthop connected to that neigh, remove from
@@ -1454,6 +1455,8 @@ mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
 		nh = &nh_grp->nexthops[i];
 		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
 	}
+	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh_grp);
+	WARN_ON_ONCE(nh_grp->adj_index_valid);
 	kfree(nh_grp);
 }
 
-- 
2.7.4
