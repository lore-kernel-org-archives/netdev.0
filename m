From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 41/42] mlxsw: spectrum_router: Add the nexthop neigh activity update
Date: Fri,  1 Jul 2016 16:05:09 +0200
Message-ID: <1467381910-3445-42-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34576 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbcGAOSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:18:45 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so5663381wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:18:44 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

For nexthop neighbours we need to make kernel to think there is a traffic
flowing to them preventing it from going to stale state. Otherwise
kernel would stale it and eventually the neigh would be removed from HW
and nexthop as well. That would reduce ECMP group in HW.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 75 +++++++++++++++++-----
 2 files changed, 61 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0fe6051..ff5b859 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -223,6 +223,7 @@ struct mlxsw_sp_router {
 		unsigned long interval;	/* ms */
 	} neighs_update;
 	struct list_head nexthop_group_list;
+	struct list_head nexthop_neighs_list;
 };
 
 struct mlxsw_sp {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index dc13178..2b20279 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -570,6 +570,7 @@ struct mlxsw_sp_neigh_entry {
 	struct list_head nexthop_list; /* list of nexthops using
 					* this neigh entry
 					*/
+	struct list_head nexthop_neighs_list_node;
 };
 
 static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
@@ -770,28 +771,15 @@ static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
-static void
-mlxsw_sp_router_neighs_update_work_schedule(struct mlxsw_sp *mlxsw_sp)
+static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
 {
-	unsigned long interval = mlxsw_sp->router.neighs_update.interval;
-
-	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw,
-			       msecs_to_jiffies(interval));
-}
-
-static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
-{
-	struct mlxsw_sp *mlxsw_sp;
 	char *rauhtd_pl;
 	u8 num_rec;
 	int i, err;
 
 	rauhtd_pl = kmalloc(MLXSW_REG_RAUHTD_LEN, GFP_KERNEL);
 	if (!rauhtd_pl)
-		return;
-
-	mlxsw_sp = container_of(work, struct mlxsw_sp,
-				router.neighs_update.dw.work);
+		return -ENOMEM;
 
 	/* Make sure the neighbour's netdev isn't removed in the
 	 * process.
@@ -813,6 +801,47 @@ static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
 	rtnl_unlock();
 
 	kfree(rauhtd_pl);
+	return err;
+}
+
+static void mlxsw_sp_router_neighs_update_nh(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+
+	/* Take RTNL mutex here to prevent lists from changes */
+	rtnl_lock();
+	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
+			    nexthop_neighs_list_node) {
+		/* If this neigh have nexthops, make the kernel think this neigh
+		 * is active regardless of the traffic.
+		 */
+		if (!list_empty(&neigh_entry->nexthop_list))
+			neigh_event_send(neigh_entry->n, NULL);
+	}
+	rtnl_unlock();
+}
+
+static void
+mlxsw_sp_router_neighs_update_work_schedule(struct mlxsw_sp *mlxsw_sp)
+{
+	unsigned long interval = mlxsw_sp->router.neighs_update.interval;
+
+	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw,
+			       msecs_to_jiffies(interval));
+}
+
+static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
+{
+	struct mlxsw_sp *mlxsw_sp = container_of(work, struct mlxsw_sp,
+						 router.neighs_update.dw.work);
+	int err;
+
+	err = mlxsw_sp_router_neighs_update_rauhtd(mlxsw_sp);
+	if (err)
+		dev_err(mlxsw_sp->bus_info->dev, "Could not update kernel for neigh activity");
+
+	mlxsw_sp_router_neighs_update_nh(mlxsw_sp);
+
 	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
 }
 
@@ -1277,6 +1306,14 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 		n = neigh_entry->n;
 		neigh_clone(n);
 	}
+
+	/* If that is the first nexthop connected to that neigh, add to
+	 * nexthop_neighs_list
+	 */
+	if (list_empty(&neigh_entry->nexthop_list))
+		list_add_tail(&neigh_entry->nexthop_neighs_list_node,
+			      &mlxsw_sp->router.nexthop_neighs_list);
+
 	nh->nh_grp = nh_grp;
 	nh->neigh_entry = neigh_entry;
 	list_add_tail(&nh->neigh_list_node, &neigh_entry->nexthop_list);
@@ -1294,6 +1331,13 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 
 	list_del(&nh->neigh_list_node);
+
+	/* If that is the last nexthop connected to that neigh, remove from
+	 * nexthop_neighs_list
+	 */
+	if (list_empty(&nh->neigh_entry->nexthop_list))
+		list_del(&nh->neigh_entry->nexthop_neighs_list_node);
+
 	neigh_release(neigh_entry->n);
 }
 
@@ -1442,6 +1486,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
+	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
 	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_group_list);
 	err = __mlxsw_sp_router_init(mlxsw_sp);
 	if (err)
-- 
2.5.5
