From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 7/9] mlxsw: spectrum: Store local port to module mapping during init
Date: Fri, 26 Feb 2016 17:32:29 +0100
Message-ID: <1456504351-18871-8-git-send-email-jiri@resnulli.us>
References: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33993 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030302AbcBZQcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 11:32:46 -0500
Received: by mail-wm0-f66.google.com with SMTP id b205so9961056wmb.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 08:32:45 -0800 (PST)
In-Reply-To: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The port netdevs are each associated with a different local port number
in the device. These local ports are grouped into groups of 4 (e.g.
(1-4), (5-8)) called clusters. The cluster constitutes the one of two
possible modules they can be mapped to. This mapping is board-specific
and done by the device's firmware during init.

When splitting a port by 4, the device requires us to first unmap all
the ports in the cluster and then map each to a single lane in the module
associated with the port netdev used as the handle for the operation.
This means that two port netdevs will disappear, as only 100Gb/s (4
lanes) ports can be split and we are guaranteed to have two of these
((1, 3), (5, 7) etc.) in a cluster.

When unsplit occurs we need to reinstantiate the two original 100Gb/s
ports and map each to its origianl module. Therefore, during driver init
store the initial local port to module mapping, so it can be used later
during unsplitting.

Note that a by 2 split doesn't require us to store the mapping, as we
only need to reinstantiate one port whose module is known.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 36 +++++++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  1 +
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 0dd72f8..240881c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -305,18 +305,19 @@ mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sspr), sspr_pl);
 }
 
-static int mlxsw_sp_port_module_check(struct mlxsw_sp_port *mlxsw_sp_port,
-				      bool *p_usable)
+static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
+					 u8 local_port, u8 *p_module,
+					 u8 *p_width)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int err;
 
-	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
 	if (err)
 		return err;
-	*p_usable = mlxsw_reg_pmlp_width_get(pmlp_pl) ? true : false;
+	*p_module = mlxsw_reg_pmlp_module_get(pmlp_pl, 0);
+	*p_width = mlxsw_reg_pmlp_width_get(pmlp_pl);
 	return 0;
 }
 
@@ -1365,7 +1366,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct devlink_port *devlink_port;
 	struct net_device *dev;
-	bool usable;
 	size_t bytes;
 	int err;
 
@@ -1416,19 +1416,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	 */
 	dev->hard_header_len += MLXSW_TXHDR_LEN;
 
-	err = mlxsw_sp_port_module_check(mlxsw_sp_port, &usable);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to check module\n",
-			mlxsw_sp_port->local_port);
-		goto err_port_module_check;
-	}
-
-	if (!usable) {
-		dev_dbg(mlxsw_sp->bus_info->dev, "Port %d: Not usable, skipping initialization\n",
-			mlxsw_sp_port->local_port);
-		goto port_not_usable;
-	}
-
 	devlink_port = &mlxsw_sp_port->devlink_port;
 	err = devlink_port_register(devlink, devlink_port, local_port);
 	if (err) {
@@ -1496,8 +1483,6 @@ err_port_swid_set:
 err_port_system_port_mapping_set:
 	devlink_port_unregister(&mlxsw_sp_port->devlink_port);
 err_devlink_port_register:
-port_not_usable:
-err_port_module_check:
 err_dev_addr_init:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
@@ -1559,6 +1544,7 @@ static void mlxsw_sp_ports_remove(struct mlxsw_sp *mlxsw_sp)
 static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 {
 	size_t alloc_size;
+	u8 module, width;
 	int i;
 	int err;
 
@@ -1568,6 +1554,13 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 		return -ENOMEM;
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+		err = mlxsw_sp_port_module_info_get(mlxsw_sp, i, &module,
+						    &width);
+		if (err)
+			goto err_port_module_info_get;
+		if (!width)
+			continue;
+		mlxsw_sp->port_to_module[i] = module;
 		err = mlxsw_sp_port_create(mlxsw_sp, i);
 		if (err)
 			goto err_port_create;
@@ -1575,6 +1568,7 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 
 err_port_create:
+err_port_module_info_get:
 	for (i--; i >= 1; i--)
 		mlxsw_sp_port_remove(mlxsw_sp, i);
 	kfree(mlxsw_sp->ports);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 6bf6dac..a7d86ac 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -123,6 +123,7 @@ struct mlxsw_sp {
 	u32 ageing_time;
 	struct mlxsw_sp_upper master_bridge;
 	struct mlxsw_sp_upper lags[MLXSW_SP_LAG_MAX];
+	u8 port_to_module[MLXSW_PORT_MAX_PORTS];
 };
 
 static inline struct mlxsw_sp_upper *
-- 
2.5.0
