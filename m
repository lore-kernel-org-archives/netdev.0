From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: spectrum: Move netdevice NB to struct mlxsw_sp
Date: Mon, 16 Oct 2017 16:26:35 +0200
Message-ID: <20171016142639.2453-2-jiri@resnulli.us>
References: <20171016142639.2453-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:51754 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753199AbdJPO0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:26:43 -0400
Received: by mail-wm0-f68.google.com with SMTP id f4so3958031wme.0
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:26:42 -0700 (PDT)
In-Reply-To: <20171016142639.2453-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

So far, all netdevice notifications that the driver cared about were
related to its own ports, and mlxsw_sp could be retrieved from the
netdevice's private data. For IP-in-IP offloading however, the driver
cares about events on foreign netdevices, and getting at mlxsw_sp or
router data structures from the handler is inconvenient.

Therefore move the netdevice notifier blocks from global scope to struct
mlxsw_sp to allow retrieval from the notifier block pointer itself.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 23 ++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  1 +
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 321988a..83f9c25 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3667,6 +3667,9 @@ static int mlxsw_sp_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 }
 
+static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
+				    unsigned long event, void *ptr);
+
 static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
@@ -3736,6 +3739,16 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_router_init;
 	}
 
+	/* Initialize netdevice notifier after router is initialized, so that
+	 * the event handler can use router structures.
+	 */
+	mlxsw_sp->netdevice_nb.notifier_call = mlxsw_sp_netdevice_event;
+	err = register_netdevice_notifier(&mlxsw_sp->netdevice_nb);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to register netdev notifier\n");
+		goto err_netdev_notifier;
+	}
+
 	err = mlxsw_sp_span_init(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to init span system\n");
@@ -3769,6 +3782,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 err_acl_init:
 	mlxsw_sp_span_fini(mlxsw_sp);
 err_span_init:
+	unregister_netdevice_notifier(&mlxsw_sp->netdevice_nb);
+err_netdev_notifier:
 	mlxsw_sp_router_fini(mlxsw_sp);
 err_router_init:
 	mlxsw_sp_afa_fini(mlxsw_sp);
@@ -3795,6 +3810,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_dpipe_fini(mlxsw_sp);
 	mlxsw_sp_acl_fini(mlxsw_sp);
 	mlxsw_sp_span_fini(mlxsw_sp);
+	unregister_netdevice_notifier(&mlxsw_sp->netdevice_nb);
 	mlxsw_sp_router_fini(mlxsw_sp);
 	mlxsw_sp_afa_fini(mlxsw_sp);
 	mlxsw_sp_counter_pool_fini(mlxsw_sp);
@@ -4501,10 +4517,6 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 	return notifier_from_errno(err);
 }
 
-static struct notifier_block mlxsw_sp_netdevice_nb __read_mostly = {
-	.notifier_call = mlxsw_sp_netdevice_event,
-};
-
 static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_inetaddr_event,
 	.priority = 10,	/* Must be called before FIB notifier block */
@@ -4532,7 +4544,6 @@ static int __init mlxsw_sp_module_init(void)
 {
 	int err;
 
-	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	register_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
@@ -4553,7 +4564,6 @@ static int __init mlxsw_sp_module_init(void)
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
-	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 	return err;
 }
 
@@ -4564,7 +4574,6 @@ static void __exit mlxsw_sp_module_exit(void)
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inet6addr_notifier(&mlxsw_sp_inet6addr_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
-	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 }
 
 module_init(mlxsw_sp_module_init);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 8e45183..e1a0157 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -161,6 +161,7 @@ struct mlxsw_sp {
 	struct {
 		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
 	} kvdl;
+	struct notifier_block netdevice_nb;
 
 	struct mlxsw_sp_counter_pool *counter_pool;
 	struct {
-- 
2.9.5
