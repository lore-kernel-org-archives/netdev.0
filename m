From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: spectrum_router: Remove redundant check
Date: Mon,  6 Feb 2017 16:20:15 +0100
Message-ID: <1486394417-8011-7-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33586 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753191AbdBFPU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:27 -0500
Received: by mail-wj0-f193.google.com with SMTP id le4so3364726wjb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:27 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We only add neighbour entries that are also used for nexthops to
'nexthop_neighs_list', so when iterating over this list there's no need
to check that the entry is indeed used for nexthops.

Remove the redundant check.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c338b08..98a6d03 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -847,13 +847,11 @@ static void mlxsw_sp_router_neighs_update_nh(struct mlxsw_sp *mlxsw_sp)
 	/* Take RTNL mutex here to prevent lists from changes */
 	rtnl_lock();
 	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
-			    nexthop_neighs_list_node) {
+			    nexthop_neighs_list_node)
 		/* If this neigh have nexthops, make the kernel think this neigh
 		 * is active regardless of the traffic.
 		 */
-		if (!list_empty(&neigh_entry->nexthop_list))
-			neigh_event_send(neigh_entry->key.n, NULL);
-	}
+		neigh_event_send(neigh_entry->key.n, NULL);
 	rtnl_unlock();
 }
 
@@ -897,11 +895,9 @@ static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
 	 */
 	rtnl_lock();
 	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
-			    nexthop_neighs_list_node) {
-		if (!(neigh_entry->key.n->nud_state & NUD_VALID) &&
-		    !list_empty(&neigh_entry->nexthop_list))
+			    nexthop_neighs_list_node)
+		if (!(neigh_entry->key.n->nud_state & NUD_VALID))
 			neigh_event_send(neigh_entry->key.n, NULL);
-	}
 	rtnl_unlock();
 
 	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw,
-- 
2.7.4
