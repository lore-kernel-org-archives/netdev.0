From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 4/6] mlxsw: spectrum_router: Fix netevent notifier registration
Date: Thu,  1 Sep 2016 10:37:43 +0200
Message-ID: <1472719065-3247-5-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36245 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753154AbcIAIhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:55 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so11481729wmf.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:55 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently the notifier is registered for every asic instance, however the
same block. Fix this by moving the registration to module init.

Fixes: c723c735fa6b ("mlxsw: spectrum_router: Periodically update the kernel's neigh table")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c        |  9 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h        |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 17 ++---------------
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ec1f7d8..e16b347 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -56,6 +56,7 @@
 #include <generated/utsrelease.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/netevent.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -4541,18 +4542,25 @@ static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
 	.priority = 10,	/* Must be called before FIB notifier block */
 };
 
+static struct notifier_block mlxsw_sp_router_netevent_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_router_netevent_event,
+};
+
 static int __init mlxsw_sp_module_init(void)
 {
 	int err;
 
 	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
+	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
+
 	err = mlxsw_core_driver_register(&mlxsw_sp_driver);
 	if (err)
 		goto err_core_driver_register;
 	return 0;
 
 err_core_driver_register:
+	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	return err;
@@ -4561,6 +4569,7 @@ err_core_driver_register:
 static void __exit mlxsw_sp_module_exit(void)
 {
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
+	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ab3feb8..ac48abe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -587,6 +587,8 @@ int mlxsw_sp_router_neigh_construct(struct net_device *dev,
 				    struct neighbour *n);
 void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
 				   struct neighbour *n);
+int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 49f4e06..352259b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -944,8 +944,8 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 	mlxsw_sp_port_dev_put(mlxsw_sp_port);
 }
 
-static int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
-					  unsigned long event, void *ptr)
+int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct mlxsw_sp_port *mlxsw_sp_port;
@@ -1015,10 +1015,6 @@ static int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
-static struct notifier_block mlxsw_sp_router_netevent_nb __read_mostly = {
-	.notifier_call = mlxsw_sp_router_netevent_event,
-};
-
 static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
@@ -1033,10 +1029,6 @@ static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 	 */
 	mlxsw_sp_router_neighs_update_interval_init(mlxsw_sp);
 
-	err = register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
-	if (err)
-		goto err_register_netevent_notifier;
-
 	/* Create the delayed works for the activity_update */
 	INIT_DELAYED_WORK(&mlxsw_sp->router.neighs_update.dw,
 			  mlxsw_sp_router_neighs_update_work);
@@ -1045,17 +1037,12 @@ static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw, 0);
 	mlxsw_core_schedule_dw(&mlxsw_sp->router.nexthop_probe_dw, 0);
 	return 0;
-
-err_register_netevent_notifier:
-	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
-	return err;
 }
 
 static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	cancel_delayed_work_sync(&mlxsw_sp->router.neighs_update.dw);
 	cancel_delayed_work_sync(&mlxsw_sp->router.nexthop_probe_dw);
-	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
 
-- 
2.5.5
