From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_router: Flush FIB tables during fini
Date: Mon, 14 Nov 2016 11:26:32 +0100
Message-ID: <1479119192-1545-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34748 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933952AbcKNK0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 05:26:35 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so13983436wme.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 02:26:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since commit b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications
instead of switchdev calls") we reflect to the device the entire FIB
table and not only FIBs that point to netdevs created by the driver.

During module removal, FIBs of the second type are removed following
NETDEV_UNREGISTER events sent. The other FIBs are still present in both
the driver's cache and the device's table.

Fix this by iterating over all the FIB tables in the device and flush
them. There's no need to take locks, as we're the only writer.

Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index cbeeddd..e83072d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -594,8 +594,11 @@ static int mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp);
+
 static void mlxsw_sp_vrs_fini(struct mlxsw_sp *mlxsw_sp)
 {
+	mlxsw_sp_router_fib_flush(mlxsw_sp);
 	kfree(mlxsw_sp->router.vrs);
 }
 
@@ -1867,18 +1870,18 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
-static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
+static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_resources *resources;
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_entry *tmp;
 	struct mlxsw_sp_vr *vr;
 	int i;
-	int err;
 
 	resources = mlxsw_core_resources_get(mlxsw_sp->core);
 	for (i = 0; i < resources->max_virtual_routers; i++) {
 		vr = &mlxsw_sp->router.vrs[i];
+
 		if (!vr->used)
 			continue;
 
@@ -1894,6 +1897,13 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 				break;
 		}
 	}
+}
+
+static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
+{
+	int err;
+
+	mlxsw_sp_router_fib_flush(mlxsw_sp);
 	mlxsw_sp->router.aborted = true;
 	err = mlxsw_sp_router_set_abort_trap(mlxsw_sp);
 	if (err)
-- 
2.7.4
