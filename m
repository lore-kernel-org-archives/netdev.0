From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/16] mlxsw: Add the unresolved next-hops probes
Date: Tue,  5 Jul 2016 11:27:52 +0200
Message-ID: <1467710872-20056-17-git-send-email-jiri@resnulli.us>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35542 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbcGEJ2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:28:15 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so27233754wme.2
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:28:14 -0700 (PDT)
In-Reply-To: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Now, the driver sends arp probes for all unresolved neighbours that are
currently a nexthop for some route on the system. The job is set
periodically every 5 seconds.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 33 +++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ff5b859..ef4ac89 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -222,6 +222,8 @@ struct mlxsw_sp_router {
 		struct delayed_work dw;
 		unsigned long interval;	/* ms */
 	} neighs_update;
+	struct delayed_work nexthop_probe_dw;
+#define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
 	struct list_head nexthop_group_list;
 	struct list_head nexthop_neighs_list;
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2b20279..e084ea5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -845,6 +845,33 @@ static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
 	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
 }
 
+static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+	struct mlxsw_sp *mlxsw_sp = container_of(work, struct mlxsw_sp,
+						 router.nexthop_probe_dw.work);
+
+	/* Iterate over nexthop neighbours, find those who are unresolved and
+	 * send arp on them. This solves the chicken-egg problem when
+	 * the nexthop wouldn't get offloaded until the neighbor is resolved
+	 * but it wouldn't get resolved ever in case traffic is flowing in HW
+	 * using different nexthop.
+	 *
+	 * Take RTNL mutex here to prevent lists from changes.
+	 */
+	rtnl_lock();
+	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
+			    nexthop_neighs_list_node) {
+		if (!(neigh_entry->n->nud_state & NUD_VALID) &&
+		    !list_empty(&neigh_entry->nexthop_list))
+			neigh_event_send(neigh_entry->n, NULL);
+	}
+	rtnl_unlock();
+
+	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw,
+			       MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL);
+}
+
 static void
 mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_neigh_entry *neigh_entry,
@@ -1004,10 +1031,13 @@ static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_register_netevent_notifier;
 
+	/* Create the delayed works for the activity_update */
 	INIT_DELAYED_WORK(&mlxsw_sp->router.neighs_update.dw,
 			  mlxsw_sp_router_neighs_update_work);
+	INIT_DELAYED_WORK(&mlxsw_sp->router.nexthop_probe_dw,
+			  mlxsw_sp_router_probe_unresolved_nexthops);
 	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw, 0);
-
+	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw, 0);
 	return 0;
 
 err_register_netevent_notifier:
@@ -1018,6 +1048,7 @@ err_register_netevent_notifier:
 static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	cancel_delayed_work_sync(&mlxsw_sp->router.neighs_update.dw);
+	cancel_delayed_work_sync(&mlxsw_sp->router.nexthop_probe_dw);
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
-- 
2.5.5
