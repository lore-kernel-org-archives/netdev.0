From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/16] mlxsw: spectrum: Move port used check outside port remove function
Date: Fri, 28 Oct 2016 21:35:49 +0200
Message-ID: <1477683361-8011-4-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33448 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756632AbcJ1Tmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:42:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id m83so8763802wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:42:44 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be symmentrical with create and do the check outside the remove function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2573faa..d649064 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2403,8 +2403,6 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
 
-	if (!mlxsw_sp_port)
-		return;
 	cancel_delayed_work_sync(&mlxsw_sp_port->hw_stats.update_dw);
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
@@ -2422,12 +2420,18 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	free_netdev(mlxsw_sp_port->dev);
 }
 
+static bool mlxsw_sp_port_created(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+{
+	return mlxsw_sp->ports[local_port] != NULL;
+}
+
 static void mlxsw_sp_ports_remove(struct mlxsw_sp *mlxsw_sp)
 {
 	int i;
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
-		mlxsw_sp_port_remove(mlxsw_sp, i);
+		if (mlxsw_sp_port_created(mlxsw_sp, i))
+			mlxsw_sp_port_remove(mlxsw_sp, i);
 	kfree(mlxsw_sp->ports);
 }
 
@@ -2461,7 +2465,8 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 err_port_create:
 err_port_module_info_get:
 	for (i--; i >= 1; i--)
-		mlxsw_sp_port_remove(mlxsw_sp, i);
+		if (mlxsw_sp_port_created(mlxsw_sp, i))
+			mlxsw_sp_port_remove(mlxsw_sp, i);
 	kfree(mlxsw_sp->ports);
 	return err;
 }
@@ -2503,7 +2508,8 @@ static int mlxsw_sp_port_split_create(struct mlxsw_sp *mlxsw_sp, u8 base_port,
 
 err_port_create:
 	for (i--; i >= 0; i--)
-		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+		if (mlxsw_sp_port_created(mlxsw_sp, base_port + i))
+			mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
 	i = count;
 err_port_swid_set:
 	for (i--; i >= 0; i--)
@@ -2593,7 +2599,8 @@ static int mlxsw_sp_port_split(struct mlxsw_core *mlxsw_core, u8 local_port,
 	}
 
 	for (i = 0; i < count; i++)
-		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+		if (mlxsw_sp_port_created(mlxsw_sp, base_port + i))
+			mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
 
 	err = mlxsw_sp_port_split_create(mlxsw_sp, base_port, module, count);
 	if (err) {
@@ -2638,7 +2645,8 @@ static int mlxsw_sp_port_unsplit(struct mlxsw_core *mlxsw_core, u8 local_port)
 		base_port = base_port + 2;
 
 	for (i = 0; i < count; i++)
-		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+		if (mlxsw_sp_port_created(mlxsw_sp, base_port + i))
+			mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
 
 	mlxsw_sp_port_unsplit_create(mlxsw_sp, base_port, count);
 
-- 
2.5.5
