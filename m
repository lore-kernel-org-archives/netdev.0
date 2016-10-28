From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/16] mlxsw: switchx2: Move port used check outside port remove function
Date: Fri, 28 Oct 2016 21:35:48 +0200
Message-ID: <1477683361-8011-3-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36699 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756698AbcJ1TmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:42:12 -0400
Received: by mail-wm0-f68.google.com with SMTP id c17so8757644wmc.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:42:11 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be symmentrical with create and do the check outside the remove function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 67f1b70..6882e35 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1093,21 +1093,26 @@ static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
 
-	if (!mlxsw_sx_port)
-		return;
 	mlxsw_core_port_fini(&mlxsw_sx_port->core_port);
 	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
+	mlxsw_sx->ports[local_port] = NULL;
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	free_percpu(mlxsw_sx_port->pcpu_stats);
 	free_netdev(mlxsw_sx_port->dev);
 }
 
+static bool mlxsw_sx_port_created(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	return mlxsw_sx->ports[local_port] != NULL;
+}
+
 static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 {
 	int i;
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
-		mlxsw_sx_port_remove(mlxsw_sx, i);
+		if (mlxsw_sx_port_created(mlxsw_sx, i))
+			mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 }
 
@@ -1138,7 +1143,8 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 err_port_create:
 err_port_module_info_get:
 	for (i--; i >= 1; i--)
-		mlxsw_sx_port_remove(mlxsw_sx, i);
+		if (mlxsw_sx_port_created(mlxsw_sx, i))
+			mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 	return err;
 }
-- 
2.5.5
