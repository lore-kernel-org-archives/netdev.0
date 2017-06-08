From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum: Pass port argument to module mapping functions
Date: Thu,  8 Jun 2017 08:47:45 +0200
Message-ID: <20170608064745.4900-4-jiri@resnulli.us>
References: <20170608064745.4900-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34898 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751526AbdFHGrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:47:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so5672439wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:47:52 -0700 (PDT)
In-Reply-To: <20170608064745.4900-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previous patch made it unnecessary to map ports to modules before we
allocate their struct. We can now therefore pass the port struct to
these functions, thereby making them consistent with other functions
that operate on ports.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8de9d17..d4666f5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -967,13 +967,14 @@ static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static int mlxsw_sp_port_module_map(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+static int mlxsw_sp_port_module_map(struct mlxsw_sp_port *mlxsw_sp_port,
 				    u8 module, u8 width, u8 lane)
 {
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int i;
 
-	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
+	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sp_port->local_port);
 	mlxsw_reg_pmlp_width_set(pmlp_pl, width);
 	for (i = 0; i < width; i++) {
 		mlxsw_reg_pmlp_module_set(pmlp_pl, i, module);
@@ -983,11 +984,12 @@ static int mlxsw_sp_port_module_map(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
 }
 
-static int mlxsw_sp_port_module_unmap(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+static int mlxsw_sp_port_module_unmap(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 
-	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
+	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sp_port->local_port);
 	mlxsw_reg_pmlp_width_set(pmlp_pl, 0);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
 }
@@ -2704,8 +2706,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
 	dev->ethtool_ops = &mlxsw_sp_port_ethtool_ops;
 
-	err = mlxsw_sp_port_module_map(mlxsw_sp, local_port, module, width,
-				       lane);
+	err = mlxsw_sp_port_module_map(mlxsw_sp_port, module, width, lane);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to map module\n",
 			mlxsw_sp_port->local_port);
@@ -2834,7 +2835,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_dev_addr_init:
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
-	mlxsw_sp_port_module_unmap(mlxsw_sp, local_port);
+	mlxsw_sp_port_module_unmap(mlxsw_sp_port);
 err_port_module_map:
 	kfree(mlxsw_sp_port->hw_stats.cache);
 err_alloc_hw_stats:
@@ -2861,7 +2862,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_fids_fini(mlxsw_sp_port);
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
-	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
+	mlxsw_sp_port_module_unmap(mlxsw_sp_port);
 	kfree(mlxsw_sp_port->hw_stats.cache);
 	kfree(mlxsw_sp_port->sample);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
-- 
2.9.3
