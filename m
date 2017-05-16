From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/12] mlxsw: spectrum_router: Move FIB notification block to router struct
Date: Tue, 16 May 2017 19:38:28 +0200
Message-ID: <20170516173835.2978-6-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36683 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdEPRiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:51 -0400
Received: by mail-wr0-f193.google.com with SMTP id v42so14918359wrc.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:50 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The FIB notification block logically belongs inside the router specific
struct, so move it there.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h        |  1 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 17 ++++++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index babaf1f..29db77f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -179,7 +179,6 @@ struct mlxsw_sp {
 		struct mlxsw_sp_span_entry *entries;
 		int entries_count;
 	} span;
-	struct notifier_block fib_nb;
 };
 
 static inline struct mlxsw_sp_upper *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7b44389..df4051f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -78,6 +78,7 @@ struct mlxsw_sp_router {
 #define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
 	struct list_head nexthop_neighs_list;
 	bool aborted;
+	struct notifier_block fib_nb;
 };
 
 struct mlxsw_sp_rif {
@@ -2797,9 +2798,9 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 				     unsigned long event, void *ptr)
 {
-	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
 	struct mlxsw_sp_fib_event_work *fib_work;
 	struct fib_notifier_info *info = ptr;
+	struct mlxsw_sp_router *router;
 
 	if (!net_eq(info->net, &init_net))
 		return NOTIFY_DONE;
@@ -2809,7 +2810,8 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 		return NOTIFY_BAD;
 
 	INIT_WORK(&fib_work->work, mlxsw_sp_router_fib_event_work);
-	fib_work->mlxsw_sp = mlxsw_sp;
+	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
+	fib_work->mlxsw_sp = router->mlxsw_sp;
 	fib_work->event = event;
 
 	switch (event) {
@@ -3550,14 +3552,15 @@ int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
-	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
+	struct mlxsw_sp_router *router;
 
 	/* Flush pending FIB notifications and then flush the device's
 	 * table before requesting another dump. The FIB notification
 	 * block is unregistered, so no need to take RTNL.
 	 */
 	mlxsw_core_flush_owq();
-	mlxsw_sp_router_fib_flush(mlxsw_sp);
+	router = container_of(nb, struct mlxsw_sp_router, fib_nb);
+	mlxsw_sp_router_fib_flush(router->mlxsw_sp);
 }
 
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
@@ -3641,8 +3644,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_neigh_init;
 
-	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
-	err = register_fib_notifier(&mlxsw_sp->fib_nb,
+	mlxsw_sp->router->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
+	err = register_fib_notifier(&mlxsw_sp->router->fib_nb,
 				    mlxsw_sp_router_fib_dump_flush);
 	if (err)
 		goto err_register_fib_notifier;
@@ -3668,7 +3671,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	unregister_fib_notifier(&mlxsw_sp->fib_nb);
+	unregister_fib_notifier(&mlxsw_sp->router->fib_nb);
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 	mlxsw_sp_lpm_fini(mlxsw_sp);
-- 
2.9.3
