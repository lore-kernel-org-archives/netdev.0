From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/16] mlxsw: switchx2: Check if port is usable before calling port create
Date: Fri, 28 Oct 2016 21:35:47 +0200
Message-ID: <1477683361-8011-2-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33778 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756618AbcJ1TmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:42:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id m83so8760582wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:41:37 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do it in a same way we do it in spectrum. Check if port is usable first
and only in that case create a port instance.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 32 +++++++++-----------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 8d11e5447..67f1b70 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -256,18 +256,17 @@ mlxsw_sx_port_system_port_mapping_set(struct mlxsw_sx_port *mlxsw_sx_port)
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sspr), sspr_pl);
 }
 
-static int mlxsw_sx_port_module_check(struct mlxsw_sx_port *mlxsw_sx_port,
-				      bool *p_usable)
+static int mlxsw_sx_port_module_info_get(struct mlxsw_sx *mlxsw_sx,
+					 u8 local_port, u8 *p_width)
 {
-	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int err;
 
-	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sx_port->local_port);
+	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(pmlp), pmlp_pl);
 	if (err)
 		return err;
-	*p_usable = mlxsw_reg_pmlp_width_get(pmlp_pl) ? true : false;
+	*p_width = mlxsw_reg_pmlp_width_get(pmlp_pl);
 	return 0;
 }
 
@@ -962,7 +961,6 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	struct net_device *dev;
-	bool usable;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct mlxsw_sx_port));
@@ -1005,19 +1003,6 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	 */
 	dev->needed_headroom = MLXSW_TXHDR_LEN;
 
-	err = mlxsw_sx_port_module_check(mlxsw_sx_port, &usable);
-	if (err) {
-		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to check module\n",
-			mlxsw_sx_port->local_port);
-		goto err_port_module_check;
-	}
-
-	if (!usable) {
-		dev_dbg(mlxsw_sx->bus_info->dev, "Port %d: Not usable, skipping initialization\n",
-			mlxsw_sx_port->local_port);
-		goto port_not_usable;
-	}
-
 	err = mlxsw_sx_port_system_port_mapping_set(mlxsw_sx_port);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set system port mapping\n",
@@ -1097,8 +1082,6 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
 err_port_system_port_mapping_set:
-port_not_usable:
-err_port_module_check:
 err_dev_addr_get:
 	free_percpu(mlxsw_sx_port->pcpu_stats);
 err_alloc_stats:
@@ -1131,6 +1114,7 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 {
 	size_t alloc_size;
+	u8 width;
 	int i;
 	int err;
 
@@ -1140,6 +1124,11 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 		return -ENOMEM;
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+		err = mlxsw_sx_port_module_info_get(mlxsw_sx, i, &width);
+		if (err)
+			goto err_port_module_info_get;
+		if (!width)
+			continue;
 		err = mlxsw_sx_port_create(mlxsw_sx, i);
 		if (err)
 			goto err_port_create;
@@ -1147,6 +1136,7 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 	return 0;
 
 err_port_create:
+err_port_module_info_get:
 	for (i--; i >= 1; i--)
 		mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
-- 
2.5.5
