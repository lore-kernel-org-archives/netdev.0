From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum: Don't sleep during ndo_get_phys_port_name()
Date: Thu,  9 Jun 2016 09:51:40 +0200
Message-ID: <1465458700-5744-3-git-send-email-jiri@resnulli.us>
References: <1465458700-5744-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36362 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbcFIHvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:51:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id m124so8393221wme.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 00:51:46 -0700 (PDT)
In-Reply-To: <1465458700-5744-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When rtnl_fill_ifinfo() is called for a certain netdevice it queries its
various parameters such as switch id and physical port name. The
function might get called in an atomic context, which means the
underlying driver must not sleep during the query operation.

Don't query the device and sleep during ndo_get_phys_port_name(), but
instead store the needed parameters in port creation time.

Fixes: 2bf9a58675c5 ("mlxsw: spectrum: Add support for physical port names")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 64 +++++++++-----------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  5 ++
 2 files changed, 26 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cc62d4c..6f9e3dd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -313,9 +313,9 @@ mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sspr), sspr_pl);
 }
 
-static int __mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
-					   u8 local_port, u8 *p_module,
-					   u8 *p_width, u8 *p_lane)
+static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
+					 u8 local_port, u8 *p_module,
+					 u8 *p_width, u8 *p_lane)
 {
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int err;
@@ -330,16 +330,6 @@ static int __mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
-					 u8 local_port, u8 *p_module,
-					 u8 *p_width)
-{
-	u8 lane;
-
-	return __mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, p_module,
-					       p_width, &lane);
-}
-
 static int mlxsw_sp_port_module_map(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				    u8 module, u8 width, u8 lane)
 {
@@ -957,17 +947,11 @@ static int mlxsw_sp_port_get_phys_port_name(struct net_device *dev, char *name,
 					    size_t len)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	u8 module, width, lane;
+	u8 module = mlxsw_sp_port->mapping.module;
+	u8 width = mlxsw_sp_port->mapping.width;
+	u8 lane = mlxsw_sp_port->mapping.lane;
 	int err;
 
-	err = __mlxsw_sp_port_module_info_get(mlxsw_sp_port->mlxsw_sp,
-					      mlxsw_sp_port->local_port,
-					      &module, &width, &lane);
-	if (err) {
-		netdev_err(dev, "Failed to retrieve module information\n");
-		return err;
-	}
-
 	if (!mlxsw_sp_port->split)
 		err = snprintf(name, len, "p%d", module + 1);
 	else
@@ -1690,7 +1674,7 @@ static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
 }
 
 static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				bool split, u8 module, u8 width)
+				bool split, u8 module, u8 width, u8 lane)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct net_device *dev;
@@ -1705,6 +1689,9 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
 	mlxsw_sp_port->local_port = local_port;
 	mlxsw_sp_port->split = split;
+	mlxsw_sp_port->mapping.module = module;
+	mlxsw_sp_port->mapping.width = width;
+	mlxsw_sp_port->mapping.lane = lane;
 	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
 	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
 	if (!mlxsw_sp_port->active_vlans) {
@@ -1895,8 +1882,8 @@ static void mlxsw_sp_ports_remove(struct mlxsw_sp *mlxsw_sp)
 
 static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 {
+	u8 module, width, lane;
 	size_t alloc_size;
-	u8 module, width;
 	int i;
 	int err;
 
@@ -1907,13 +1894,14 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
 		err = mlxsw_sp_port_module_info_get(mlxsw_sp, i, &module,
-						    &width);
+						    &width, &lane);
 		if (err)
 			goto err_port_module_info_get;
 		if (!width)
 			continue;
 		mlxsw_sp->port_to_module[i] = module;
-		err = mlxsw_sp_port_create(mlxsw_sp, i, false, module, width);
+		err = mlxsw_sp_port_create(mlxsw_sp, i, false, module, width,
+					   lane);
 		if (err)
 			goto err_port_create;
 	}
@@ -1955,7 +1943,7 @@ static int mlxsw_sp_port_split_create(struct mlxsw_sp *mlxsw_sp, u8 base_port,
 
 	for (i = 0; i < count; i++) {
 		err = mlxsw_sp_port_create(mlxsw_sp, base_port + i, true,
-					   module, width);
+					   module, width, i * width);
 		if (err)
 			goto err_port_create;
 	}
@@ -2004,7 +1992,7 @@ static void mlxsw_sp_port_unsplit_create(struct mlxsw_sp *mlxsw_sp,
 		module = mlxsw_sp->port_to_module[local_port];
 
 		mlxsw_sp_port_create(mlxsw_sp, local_port, false, module,
-				     width);
+				     width, 0);
 	}
 }
 
@@ -2024,18 +2012,14 @@ static int mlxsw_sp_port_split(struct mlxsw_core *mlxsw_core, u8 local_port,
 		return -EINVAL;
 	}
 
+	module = mlxsw_sp_port->mapping.module;
+	cur_width = mlxsw_sp_port->mapping.width;
+
 	if (count != 2 && count != 4) {
 		netdev_err(mlxsw_sp_port->dev, "Port can only be split into 2 or 4 ports\n");
 		return -EINVAL;
 	}
 
-	err = mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, &module,
-					    &cur_width);
-	if (err) {
-		netdev_err(mlxsw_sp_port->dev, "Failed to get port's width\n");
-		return err;
-	}
-
 	if (cur_width != MLXSW_PORT_MODULE_MAX_WIDTH) {
 		netdev_err(mlxsw_sp_port->dev, "Port cannot be split further\n");
 		return -EINVAL;
@@ -2077,10 +2061,9 @@ static int mlxsw_sp_port_unsplit(struct mlxsw_core *mlxsw_core, u8 local_port)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
-	u8 module, cur_width, base_port;
+	u8 cur_width, base_port;
 	unsigned int count;
 	int i;
-	int err;
 
 	mlxsw_sp_port = mlxsw_sp->ports[local_port];
 	if (!mlxsw_sp_port) {
@@ -2094,12 +2077,7 @@ static int mlxsw_sp_port_unsplit(struct mlxsw_core *mlxsw_core, u8 local_port)
 		return -EINVAL;
 	}
 
-	err = mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, &module,
-					    &cur_width);
-	if (err) {
-		netdev_err(mlxsw_sp_port->dev, "Failed to get port's width\n");
-		return err;
-	}
+	cur_width = mlxsw_sp_port->mapping.width;
 	count = cur_width == 1 ? 4 : 2;
 
 	base_port = mlxsw_sp_cluster_base_port_get(local_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index e2c022d..13b30ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -229,6 +229,11 @@ struct mlxsw_sp_port {
 		struct ieee_maxrate *maxrate;
 		struct ieee_pfc *pfc;
 	} dcb;
+	struct {
+		u8 module;
+		u8 width;
+		u8 lane;
+	} mapping;
 	/* 802.1Q bridge VLANs */
 	unsigned long *active_vlans;
 	unsigned long *untagged_vlans;
-- 
2.5.5
