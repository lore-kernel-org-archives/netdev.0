From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/16] mlxsw: Make devlink port instances independent of spectrum/switchx2 port instances
Date: Fri, 28 Oct 2016 21:35:55 +0200
Message-ID: <1477683361-8011-10-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35694 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030240AbcJ1Tog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:44:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id 68so1988629wmz.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:44:35 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, devlink register/unregister is done directly from
spectrum/switchx2 port create/remove functions. With a need to
introduce a port type change, the devlink port instances have to be
persistent across type changes, therefore across port create/remove
function calls. So do a bit of reshuffling to achieve that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 82 +++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 26 +++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 53 +++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  1 -
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 49 ++++++++++-----
 5 files changed, 147 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 02183f6..b50acb1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -90,6 +90,22 @@ struct mlxsw_core_pcpu_stats {
 	u32			port_rx_invalid;
 };
 
+struct mlxsw_core_port {
+	struct devlink_port devlink_port;
+	void *port_driver_priv;
+};
+
+void *mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port)
+{
+	return mlxsw_core_port->port_driver_priv;
+}
+EXPORT_SYMBOL(mlxsw_core_port_driver_priv);
+
+static bool mlxsw_core_port_check(struct mlxsw_core_port *mlxsw_core_port)
+{
+	return mlxsw_core_port->port_driver_priv != NULL;
+}
+
 struct mlxsw_core {
 	struct mlxsw_driver *driver;
 	const struct mlxsw_bus *bus;
@@ -114,6 +130,7 @@ struct mlxsw_core {
 	} lag;
 	struct mlxsw_res res;
 	struct mlxsw_hwmon *hwmon;
+	struct mlxsw_core_port ports[MLXSW_PORT_MAX_PORTS];
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
 };
@@ -928,7 +945,8 @@ static int mlxsw_devlink_sb_port_pool_get(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_port_pool_get)
+	if (!mlxsw_driver->sb_port_pool_get ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_port_pool_get(mlxsw_core_port, sb_index,
 					      pool_index, p_threshold);
@@ -942,7 +960,8 @@ static int mlxsw_devlink_sb_port_pool_set(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_port_pool_set)
+	if (!mlxsw_driver->sb_port_pool_set ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_port_pool_set(mlxsw_core_port, sb_index,
 					      pool_index, threshold);
@@ -958,7 +977,8 @@ mlxsw_devlink_sb_tc_pool_bind_get(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_tc_pool_bind_get)
+	if (!mlxsw_driver->sb_tc_pool_bind_get ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_tc_pool_bind_get(mlxsw_core_port, sb_index,
 						 tc_index, pool_type,
@@ -975,7 +995,8 @@ mlxsw_devlink_sb_tc_pool_bind_set(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_tc_pool_bind_set)
+	if (!mlxsw_driver->sb_tc_pool_bind_set ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_tc_pool_bind_set(mlxsw_core_port, sb_index,
 						 tc_index, pool_type,
@@ -1013,7 +1034,8 @@ mlxsw_devlink_sb_occ_port_pool_get(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_occ_port_pool_get)
+	if (!mlxsw_driver->sb_occ_port_pool_get ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_occ_port_pool_get(mlxsw_core_port, sb_index,
 						  pool_index, p_cur, p_max);
@@ -1029,7 +1051,8 @@ mlxsw_devlink_sb_occ_tc_port_bind_get(struct devlink_port *devlink_port,
 	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
 	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
 
-	if (!mlxsw_driver->sb_occ_tc_port_bind_get)
+	if (!mlxsw_driver->sb_occ_tc_port_bind_get ||
+	    !mlxsw_core_port_check(mlxsw_core_port))
 		return -EOPNOTSUPP;
 	return mlxsw_driver->sb_occ_tc_port_bind_get(mlxsw_core_port,
 						     sb_index, tc_index,
@@ -1656,28 +1679,59 @@ u64 mlxsw_core_res_get(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_res_get);
 
-int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
-			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
-			 struct net_device *dev, bool split, u32 split_group)
+int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core, u8 local_port)
 {
 	struct devlink *devlink = priv_to_devlink(mlxsw_core);
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
 	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+	int err;
 
-	if (split)
-		devlink_port_split_set(devlink_port, split_group);
-	devlink_port_type_eth_set(devlink_port, dev);
-	return devlink_port_register(devlink, devlink_port, local_port);
+	err = devlink_port_register(devlink, devlink_port, local_port);
+	if (err)
+		memset(mlxsw_core_port, 0, sizeof(*mlxsw_core_port));
+	return err;
 }
 EXPORT_SYMBOL(mlxsw_core_port_init);
 
-void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port)
+void mlxsw_core_port_fini(struct mlxsw_core *mlxsw_core, u8 local_port)
 {
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
 	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
 
 	devlink_port_unregister(devlink_port);
+	memset(mlxsw_core_port, 0, sizeof(*mlxsw_core_port));
 }
 EXPORT_SYMBOL(mlxsw_core_port_fini);
 
+void mlxsw_core_port_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			 void *port_driver_priv, struct net_device *dev,
+			 bool split, u32 split_group)
+{
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	mlxsw_core_port->port_driver_priv = port_driver_priv;
+	if (split)
+		devlink_port_split_set(devlink_port, split_group);
+	devlink_port_type_eth_set(devlink_port, dev);
+}
+EXPORT_SYMBOL(mlxsw_core_port_set);
+
+void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
+			   void *port_driver_priv)
+{
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	mlxsw_core_port->port_driver_priv = port_driver_priv;
+	devlink_port_type_clear(devlink_port);
+}
+EXPORT_SYMBOL(mlxsw_core_port_clear);
+
 static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
 				    const char *buf, size_t size)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 0cf721c..f4bbbd4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -52,6 +52,7 @@
 #include "resources.h"
 
 struct mlxsw_core;
+struct mlxsw_core_port;
 struct mlxsw_driver;
 struct mlxsw_bus;
 struct mlxsw_bus_info;
@@ -141,23 +142,14 @@ u8 mlxsw_core_lag_mapping_get(struct mlxsw_core *mlxsw_core,
 void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 				  u16 lag_id, u8 local_port);
 
-struct mlxsw_core_port {
-	struct devlink_port devlink_port;
-};
-
-static inline void *
-mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port)
-{
-	/* mlxsw_core_port is ensured to always be the first field in driver
-	 * port structure.
-	 */
-	return mlxsw_core_port;
-}
-
-int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
-			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
-			 struct net_device *dev, bool split, u32 split_group);
-void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port);
+void *mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port);
+int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core, u8 local_port);
+void mlxsw_core_port_fini(struct mlxsw_core *mlxsw_core, u8 local_port);
+void mlxsw_core_port_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			 void *port_driver_priv, struct net_device *dev,
+			 bool split, u32 split_group);
+void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
+			   void *port_driver_priv);
 
 int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d1c2f9f..ad4ff27 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2212,8 +2212,8 @@ static int mlxsw_sp_port_pvid_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port_kill_vid(mlxsw_sp_port->dev, 0, 1);
 }
 
-static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				bool split, u8 module, u8 width, u8 lane)
+static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				  bool split, u8 module, u8 width, u8 lane)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct net_device *dev;
@@ -2358,20 +2358,11 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_register_netdev;
 	}
 
-	err = mlxsw_core_port_init(mlxsw_sp->core, &mlxsw_sp_port->core_port,
-				   mlxsw_sp_port->local_port, dev,
-				   mlxsw_sp_port->split, module);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to init core port\n",
-			mlxsw_sp_port->local_port);
-		goto err_core_port_init;
-	}
-
+	mlxsw_core_port_set(mlxsw_sp->core, mlxsw_sp_port->local_port,
+			    mlxsw_sp_port, dev, mlxsw_sp_port->split, module);
 	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw, 0);
 	return 0;
 
-err_core_port_init:
-	unregister_netdev(dev);
 err_register_netdev:
 	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
@@ -2400,12 +2391,34 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return err;
 }
 
-static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				bool split, u8 module, u8 width, u8 lane)
+{
+	int err;
+
+	err = mlxsw_core_port_init(mlxsw_sp->core, local_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to init core port\n",
+			local_port);
+		return err;
+	}
+	err = __mlxsw_sp_port_create(mlxsw_sp, local_port, false,
+				     module, width, lane);
+	if (err)
+		goto err_port_create;
+	return 0;
+
+err_port_create:
+	mlxsw_core_port_fini(mlxsw_sp->core, local_port);
+	return err;
+}
+
+static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
 
 	cancel_delayed_work_sync(&mlxsw_sp_port->hw_stats.update_dw);
-	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
+	mlxsw_core_port_clear(mlxsw_sp->core, local_port, mlxsw_sp);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
@@ -2421,6 +2434,12 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	free_netdev(mlxsw_sp_port->dev);
 }
 
+static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+{
+	__mlxsw_sp_port_remove(mlxsw_sp, local_port);
+	mlxsw_core_port_fini(mlxsw_sp->core, local_port);
+}
+
 static bool mlxsw_sp_port_created(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	return mlxsw_sp->ports[local_port] != NULL;
@@ -2456,8 +2475,8 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 		if (!width)
 			continue;
 		mlxsw_sp->port_to_module[i] = module;
-		err = mlxsw_sp_port_create(mlxsw_sp, i, false, module, width,
-					   lane);
+		err = mlxsw_sp_port_create(mlxsw_sp, i, false,
+					   module, width, lane);
 		if (err)
 			goto err_port_create;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 92fc43e..cc1af19 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -316,7 +316,6 @@ struct mlxsw_sp_port_pcpu_stats {
 };
 
 struct mlxsw_sp_port {
-	struct mlxsw_core_port core_port; /* must be first */
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sp *mlxsw_sp;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 7b74dcb..8eac26f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -76,7 +76,6 @@ struct mlxsw_sx_port_pcpu_stats {
 };
 
 struct mlxsw_sx_port {
-	struct mlxsw_core_port core_port; /* must be first */
 	struct net_device *dev;
 	struct mlxsw_sx_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sx *mlxsw_sx;
@@ -995,8 +994,8 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spmlr), spmlr_pl);
 }
 
-static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
-				u8 module, u8 width)
+static int __mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				  u8 module, u8 width)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	struct net_device *dev;
@@ -1099,19 +1098,11 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 		goto err_register_netdev;
 	}
 
-	err = mlxsw_core_port_init(mlxsw_sx->core, &mlxsw_sx_port->core_port,
-				   mlxsw_sx_port->local_port, dev, false, 0);
-	if (err) {
-		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to init core port\n",
-			mlxsw_sx_port->local_port);
-		goto err_core_port_init;
-	}
-
+	mlxsw_core_port_set(mlxsw_sx->core, mlxsw_sx_port->local_port,
+			    mlxsw_sx_port, dev, false, 0);
 	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
 	return 0;
 
-err_core_port_init:
-	unregister_netdev(dev);
 err_register_netdev:
 err_port_mac_learning_mode_set:
 err_port_stp_state_set:
@@ -1128,11 +1119,33 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 	return err;
 }
 
-static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				u8 module, u8 width)
+{
+	int err;
+
+	err = mlxsw_core_port_init(mlxsw_sx->core, local_port);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to init core port\n",
+			local_port);
+		return err;
+	}
+	err = __mlxsw_sx_port_create(mlxsw_sx, local_port, module, width);
+	if (err)
+		goto err_port_create;
+
+	return 0;
+
+err_port_create:
+	mlxsw_core_port_fini(mlxsw_sx->core, local_port);
+	return err;
+}
+
+static void __mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
 
-	mlxsw_core_port_fini(&mlxsw_sx_port->core_port);
+	mlxsw_core_port_clear(mlxsw_sx->core, local_port, mlxsw_sx);
 	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
 	mlxsw_sx->ports[local_port] = NULL;
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
@@ -1140,6 +1153,12 @@ static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	free_netdev(mlxsw_sx_port->dev);
 }
 
+static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	__mlxsw_sx_port_remove(mlxsw_sx, local_port);
+	mlxsw_core_port_fini(mlxsw_sx->core, local_port);
+}
+
 static bool mlxsw_sx_port_created(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	return mlxsw_sx->ports[local_port] != NULL;
-- 
2.5.5
