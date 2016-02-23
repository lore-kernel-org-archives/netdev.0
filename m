From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 9/9] mlxsw: spectrum: Introduce port splitting
Date: Tue, 23 Feb 2016 16:51:34 +0100
Message-ID: <1456242694-29463-10-git-send-email-jiri@resnulli.us>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34856 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752AbcBWPwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:52:00 -0500
Received: by mail-wm0-f42.google.com with SMTP id c200so227345262wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:51:59 -0800 (PST)
In-Reply-To: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow a user to split or unsplit a port using the newly introduced
devlink ops.

Once split, the original netdev is destroyed and 2 or 4 others are
created, according to user configuration. The new ports are like any
other port, with the sole difference of supporting a lower maximum
speed. When unsplit, the reverse process takes place.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/port.h     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 178 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 +-
 3 files changed, 182 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index ae65b99..f33b997 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -59,6 +59,8 @@
 
 #define MLXSW_PORT_DONT_CARE		(MLXSW_PORT_MAX_PORTS)
 
+#define MLXSW_PORT_MODULE_MAX_WIDTH	4
+
 enum mlxsw_port_admin_status {
 	MLXSW_PORT_ADMIN_STATUS_UP = 1,
 	MLXSW_PORT_ADMIN_STATUS_DOWN = 2,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 926019e..1dcd3bc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -321,6 +321,22 @@ static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
+static int mlxsw_sp_port_module_map(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				    u8 module, u8 width, u8 lane)
+{
+	char pmlp_pl[MLXSW_REG_PMLP_LEN];
+	int i;
+
+	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
+	mlxsw_reg_pmlp_width_set(pmlp_pl, width);
+	for (i = 0; i < width; i++) {
+		mlxsw_reg_pmlp_module_set(pmlp_pl, i, module);
+		mlxsw_reg_pmlp_tx_lane_set(pmlp_pl, i, lane + i);  /* Rx & Tx */
+	}
+
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
+}
+
 static int mlxsw_sp_port_module_unmap(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
@@ -1360,7 +1376,8 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.set_settings		= mlxsw_sp_port_set_settings,
 };
 
-static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				  bool split, u8 module)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
@@ -1376,6 +1393,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port->dev = dev;
 	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
 	mlxsw_sp_port->local_port = local_port;
+	mlxsw_sp_port->split = split;
 	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
 	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
 	if (!mlxsw_sp_port->active_vlans) {
@@ -1417,6 +1435,8 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	dev->hard_header_len += MLXSW_TXHDR_LEN;
 
 	devlink_port = &mlxsw_sp_port->devlink_port;
+	if (mlxsw_sp_port->split)
+		devlink_port_split_set(devlink_port, module);
 	err = devlink_port_register(devlink, devlink_port, local_port);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to register devlink port\n",
@@ -1494,6 +1514,27 @@ err_port_active_vlans_alloc:
 	return err;
 }
 
+static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				bool split, u8 module, u8 width, u8 lane)
+{
+	int err;
+
+	err = mlxsw_sp_port_module_map(mlxsw_sp, local_port, module, width,
+				       lane);
+	if (err)
+		return err;
+
+	err = __mlxsw_sp_port_create(mlxsw_sp, local_port, split, module);
+	if (err)
+		goto err_port_create;
+
+	return 0;
+
+err_port_create:
+	mlxsw_sp_port_module_unmap(mlxsw_sp, local_port);
+	return err;
+}
+
 static void mlxsw_sp_port_vports_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
@@ -1562,7 +1603,7 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 		if (!width)
 			continue;
 		mlxsw_sp->port_to_module[i] = module;
-		err = mlxsw_sp_port_create(mlxsw_sp, i);
+		err = __mlxsw_sp_port_create(mlxsw_sp, i, false, module);
 		if (err)
 			goto err_port_create;
 	}
@@ -1576,6 +1617,137 @@ err_port_module_info_get:
 	return err;
 }
 
+static u8 mlxsw_sp_cluster_base_port_get(u8 local_port)
+{
+	u8 offset = (local_port - 1) % MLXSW_SP_PORTS_PER_CLUSTER_MAX;
+
+	return local_port - offset;
+}
+
+static int mlxsw_sp_port_split(void *priv, u8 local_port, unsigned int count)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	u8 width = MLXSW_PORT_MODULE_MAX_WIDTH / count;
+	u8 module, cur_width, base_port;
+	int i;
+	int err;
+
+	mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	if (!mlxsw_sp_port) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port number \"%d\" does not exist\n",
+			local_port);
+		return -EINVAL;
+	}
+
+	if (count != 2 && count != 4) {
+		netdev_err(mlxsw_sp_port->dev, "Port can only be split into 2 or 4 ports\n");
+		return -EINVAL;
+	}
+
+	err = mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, &module,
+					    &cur_width);
+	if (err) {
+		netdev_err(mlxsw_sp_port->dev, "Failed to get port's width\n");
+		return err;
+	}
+
+	if (cur_width != MLXSW_PORT_MODULE_MAX_WIDTH) {
+		netdev_err(mlxsw_sp_port->dev, "Port cannot be split further\n");
+		return -EINVAL;
+	}
+
+	/* Make sure we have enough slave (even) ports for the split. */
+	if (count == 2) {
+		base_port = local_port;
+		if (mlxsw_sp->ports[base_port + 1]) {
+			netdev_err(mlxsw_sp_port->dev, "Invalid split configuration\n");
+			return -EINVAL;
+		}
+	} else {
+		base_port = mlxsw_sp_cluster_base_port_get(local_port);
+		if (mlxsw_sp->ports[base_port + 1] ||
+		    mlxsw_sp->ports[base_port + 3]) {
+			netdev_err(mlxsw_sp_port->dev, "Invalid split configuration\n");
+			return -EINVAL;
+		}
+	}
+
+	for (i = 0; i < count; i++)
+		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+
+	for (i = 0; i < count; i++) {
+		err = mlxsw_sp_port_create(mlxsw_sp, base_port + i, true,
+					   module, width, i * width);
+		if (err) {
+			dev_err(mlxsw_sp->bus_info->dev, "Failed to create split port\n");
+			goto err_port_create;
+		}
+	}
+
+	return 0;
+
+err_port_create:
+	for (i--; i >= 0; i--)
+		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+	for (i = 0; i < count / 2; i++) {
+		module = mlxsw_sp->port_to_module[base_port + i * 2];
+		mlxsw_sp_port_create(mlxsw_sp, base_port + i * 2, false,
+				     module, MLXSW_PORT_MODULE_MAX_WIDTH, 0);
+	}
+	return err;
+}
+
+static int mlxsw_sp_port_unsplit(void *priv, u8 local_port)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	u8 module, cur_width, base_port;
+	unsigned int count;
+	int i;
+	int err;
+
+	mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	if (!mlxsw_sp_port) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port number \"%d\" does not exist\n",
+			local_port);
+		return -EINVAL;
+	}
+
+	if (!mlxsw_sp_port->split) {
+		netdev_err(mlxsw_sp_port->dev, "Port wasn't split\n");
+		return -EINVAL;
+	}
+
+	err = mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, &module,
+					    &cur_width);
+	if (err) {
+		netdev_err(mlxsw_sp_port->dev, "Failed to get port's width\n");
+		return err;
+	}
+	count = cur_width == 1 ? 4 : 2;
+
+	base_port = mlxsw_sp_cluster_base_port_get(local_port);
+
+	/* Determine which ports to remove. */
+	if (count == 2 && local_port >= base_port + 2)
+		base_port = base_port + 2;
+
+	for (i = 0; i < count; i++)
+		mlxsw_sp_port_remove(mlxsw_sp, base_port + i);
+
+	for (i = 0; i < count / 2; i++) {
+		module = mlxsw_sp->port_to_module[base_port + i * 2];
+		err = mlxsw_sp_port_create(mlxsw_sp, base_port + i * 2, false,
+					   module, MLXSW_PORT_MODULE_MAX_WIDTH,
+					   0);
+		if (err)
+			dev_err(mlxsw_sp->bus_info->dev, "Failed to reinstantiate port\n");
+	}
+
+	return 0;
+}
+
 static void mlxsw_sp_pude_event_func(const struct mlxsw_reg_info *reg,
 				     char *pude_pl, void *priv)
 {
@@ -1999,6 +2171,8 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.priv_size		= sizeof(struct mlxsw_sp),
 	.init			= mlxsw_sp_init,
 	.fini			= mlxsw_sp_fini,
+	.port_split		= mlxsw_sp_port_split,
+	.port_unsplit		= mlxsw_sp_port_unsplit,
 	.txhdr_construct	= mlxsw_sp_txhdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sp_config_profile,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index a7d86ac..02cb275 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -58,6 +58,8 @@
 
 #define MLXSW_SP_MID_MAX 7000
 
+#define MLXSW_SP_PORTS_PER_CLUSTER_MAX 4
+
 struct mlxsw_sp_port;
 
 struct mlxsw_sp_upper {
@@ -151,7 +153,8 @@ struct mlxsw_sp_port {
 	   learning_sync:1,
 	   uc_flood:1,
 	   bridged:1,
-	   lagged:1;
+	   lagged:1,
+	   split:1;
 	u16 pvid;
 	u16 lag_id;
 	struct {
-- 
2.5.0
