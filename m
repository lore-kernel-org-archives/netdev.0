From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: spectrum_router: Use ordered workqueue for neigh updates
Date: Mon,  6 Feb 2017 16:20:11 +0100
Message-ID: <1486394417-8011-3-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34536 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752428AbdBFPUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:22 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so22521171wmi.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:22 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We currently associate each neighbour entry with a work item, so it's
not possible to have multiple events queued for the same neighbour
entry. However, this is about to be changed so that the neighbour entry
is only resolved when the work item is scheduled.

The above can result in a mismatch between the kernel's and the device's
neighbour table, unless the associated work items are processed in the
order in which they were submitted.

Do that by migrating the NEIGH_UPDATE work items to be processed in the
ordered workqueue which was recently introduced in mlxsw in commit
a3832b31898f ("mlxsw: core: Create an ordered workqueue for FIB
offload").

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 01e86e7..0d8201e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -614,7 +614,7 @@ struct mlxsw_sp_neigh_entry {
 	struct mlxsw_sp_neigh_key key;
 	u16 rif;
 	bool offloaded;
-	struct delayed_work dw;
+	struct work_struct work;
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	unsigned char ha[ETH_ALEN];
 	struct list_head nexthop_list; /* list of nexthops using
@@ -659,7 +659,7 @@ mlxsw_sp_neigh_entry_create(struct neighbour *n, u16 rif)
 		return NULL;
 	neigh_entry->key.n = n;
 	neigh_entry->rif = rif;
-	INIT_DELAYED_WORK(&neigh_entry->dw, mlxsw_sp_router_neigh_update_hw);
+	INIT_WORK(&neigh_entry->work, mlxsw_sp_router_neigh_update_hw);
 	INIT_LIST_HEAD(&neigh_entry->nexthop_list);
 	return neigh_entry;
 }
@@ -935,7 +935,7 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry =
-		container_of(work, struct mlxsw_sp_neigh_entry, dw.work);
+		container_of(work, struct mlxsw_sp_neigh_entry, work);
 	struct neighbour *n = neigh_entry->key.n;
 	struct mlxsw_sp_port *mlxsw_sp_port = neigh_entry->mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
@@ -1052,7 +1052,7 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 		 * work.
 		 */
 		neigh_clone(n);
-		if (!mlxsw_core_schedule_dw(&neigh_entry->dw, 0)) {
+		if (!mlxsw_core_schedule_work(&neigh_entry->work)) {
 			neigh_release(n);
 			mlxsw_sp_port_dev_put(mlxsw_sp_port);
 		}
-- 
2.7.4
