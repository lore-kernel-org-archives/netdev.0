From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: spectrum: Simplify port split flow
Date: Thu,  8 Jun 2017 08:47:44 +0200
Message-ID: <20170608064745.4900-3-jiri@resnulli.us>
References: <20170608064745.4900-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34887 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdFHGrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:47:51 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so5672365wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:47:51 -0700 (PDT)
In-Reply-To: <20170608064745.4900-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In commit be94535f9531 ("mlxsw: spectrum: Make split flow match firmware
requirements") we had to modify the port split flow to overcome quirks
in the device's firmware. This resulted in asymmetrical code with
regards to port creation and removal.

The problem in the firmware is long gone and since we can now enforce a
minimal firmware version, we can simplify the code and make it symmetric
again.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 103 +++++++------------------
 1 file changed, 28 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 85c6c49..8de9d17 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -860,21 +860,13 @@ static int mlxsw_sp_port_mtu_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mtu)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmtu), pmtu_pl);
 }
 
-static int __mlxsw_sp_port_swid_set(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				    u8 swid)
-{
-	char pspa_pl[MLXSW_REG_PSPA_LEN];
-
-	mlxsw_reg_pspa_pack(pspa_pl, swid, local_port);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pspa), pspa_pl);
-}
-
 static int mlxsw_sp_port_swid_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 swid)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char pspa_pl[MLXSW_REG_PSPA_LEN];
 
-	return __mlxsw_sp_port_swid_set(mlxsw_sp, mlxsw_sp_port->local_port,
-					swid);
+	mlxsw_reg_pspa_pack(pspa_pl, swid, mlxsw_sp_port->local_port);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pspa), pspa_pl);
 }
 
 int mlxsw_sp_port_vp_mode_set(struct mlxsw_sp_port *mlxsw_sp_port, bool enable)
@@ -2651,17 +2643,26 @@ static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
-static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				  bool split, u8 module, u8 width, u8 lane)
+static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				bool split, u8 module, u8 width, u8 lane)
 {
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct net_device *dev;
 	int err;
 
+	err = mlxsw_core_port_init(mlxsw_sp->core, local_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to init core port\n",
+			local_port);
+		return err;
+	}
+
 	dev = alloc_etherdev(sizeof(struct mlxsw_sp_port));
-	if (!dev)
-		return -ENOMEM;
+	if (!dev) {
+		err = -ENOMEM;
+		goto err_alloc_etherdev;
+	}
 	SET_NETDEV_DEV(dev, mlxsw_sp->bus_info->dev);
 	mlxsw_sp_port = netdev_priv(dev);
 	mlxsw_sp_port->dev = dev;
@@ -2703,6 +2704,14 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
 	dev->ethtool_ops = &mlxsw_sp_port_ethtool_ops;
 
+	err = mlxsw_sp_port_module_map(mlxsw_sp, local_port, module, width,
+				       lane);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to map module\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_module_map;
+	}
+
 	err = mlxsw_sp_port_swid_set(mlxsw_sp_port, 0);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set SWID\n",
@@ -2825,6 +2834,8 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_dev_addr_init:
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
+	mlxsw_sp_port_module_unmap(mlxsw_sp, local_port);
+err_port_module_map:
 	kfree(mlxsw_sp_port->hw_stats.cache);
 err_alloc_hw_stats:
 	kfree(mlxsw_sp_port->sample);
@@ -2832,32 +2843,12 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
 	free_netdev(dev);
-	return err;
-}
-
-static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				bool split, u8 module, u8 width, u8 lane)
-{
-	int err;
-
-	err = mlxsw_core_port_init(mlxsw_sp->core, local_port);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to init core port\n",
-			local_port);
-		return err;
-	}
-	err = __mlxsw_sp_port_create(mlxsw_sp, local_port, split,
-				     module, width, lane);
-	if (err)
-		goto err_port_create;
-	return 0;
-
-err_port_create:
+err_alloc_etherdev:
 	mlxsw_core_port_fini(mlxsw_sp->core, local_port);
 	return err;
 }
 
-static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
 
@@ -2876,11 +2867,6 @@ static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vlans_list));
 	free_netdev(mlxsw_sp_port->dev);
-}
-
-static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
-{
-	__mlxsw_sp_port_remove(mlxsw_sp, local_port);
 	mlxsw_core_port_fini(mlxsw_sp->core, local_port);
 }
 
@@ -2959,19 +2945,6 @@ static int mlxsw_sp_port_split_create(struct mlxsw_sp *mlxsw_sp, u8 base_port,
 	int err, i;
 
 	for (i = 0; i < count; i++) {
-		err = mlxsw_sp_port_module_map(mlxsw_sp, base_port + i, module,
-					       width, i * width);
-		if (err)
-			goto err_port_module_map;
-	}
-
-	for (i = 0; i < count; i++) {
-		err = __mlxsw_sp_port_swid_set(mlxsw_sp, base_port + i, 0);
-		if (err)
-			goto err_port_swid_set;
-	}
-
-	for (i = 0; i < count; i++) {
 		err = mlxsw_sp_port_create(mlxsw_sp, base_port + i, true,
 					   module, width, i * width);
 		if (err)
@@ -2984,15 +2957,6 @@ static int mlxsw_sp_port_split_create(struct mlxsw_sp *mlxsw_sp, u8 base_port,
 	for (i--; i >= 0; i--)
 		if (mlxsw_sp_port_created(mlxsw_sp, base_port + i))
 			mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
-	i = count;
-err_port_swid_set:
-	for (i--; i >= 0; i--)
-		__mlxsw_sp_port_swid_set(mlxsw_sp, base_port + i,
-					 MLXSW_PORT_SWID_DISABLED_PORT);
-	i = count;
-err_port_module_map:
-	for (i--; i >= 0; i--)
-		mlxsw_sp_port_module_unmap(mlxsw_sp, base_port + i);
 	return err;
 }
 
@@ -3011,17 +2975,6 @@ static void mlxsw_sp_port_unsplit_create(struct mlxsw_sp *mlxsw_sp,
 		local_port = base_port + i * 2;
 		module = mlxsw_sp->port_to_module[local_port];
 
-		mlxsw_sp_port_module_map(mlxsw_sp, local_port, module, width,
-					 0);
-	}
-
-	for (i = 0; i < count; i++)
-		__mlxsw_sp_port_swid_set(mlxsw_sp, base_port + i * 2, 0);
-
-	for (i = 0; i < count; i++) {
-		local_port = base_port + i * 2;
-		module = mlxsw_sp->port_to_module[local_port];
-
 		mlxsw_sp_port_create(mlxsw_sp, local_port, false, module,
 				     width, 0);
 	}
-- 
2.9.3
