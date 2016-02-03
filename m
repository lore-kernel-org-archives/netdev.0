From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/6] mlxsw: Implement devlink interface
Date: Wed,  3 Feb 2016 11:47:58 +0100
Message-ID: <1454496482-13961-3-git-send-email-jiri@resnulli.us>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36824 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbcBCKsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:08 -0500
Received: by mail-wm0-f47.google.com with SMTP id p63so158689851wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:07 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement newly introduced devlink interface. Add devlink port instances
for every port and set the port types accordingly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 24 ++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 20 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 20 ++++++++++++++++++++
 4 files changed, 60 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 22379eb..57d9655 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -56,6 +56,7 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <asm/byteorder.h>
+#include <net/devlink.h>
 
 #include "core.h"
 #include "item.h"
@@ -791,6 +792,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	const char *device_kind = mlxsw_bus_info->device_kind;
 	struct mlxsw_core *mlxsw_core;
 	struct mlxsw_driver *mlxsw_driver;
+	struct devlink *devlink;
 	size_t alloc_size;
 	int err;
 
@@ -798,12 +800,13 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (!mlxsw_driver)
 		return -EINVAL;
 	alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
-	mlxsw_core = kzalloc(alloc_size, GFP_KERNEL);
-	if (!mlxsw_core) {
+	devlink = devlink_alloc(NULL, alloc_size);
+	if (!devlink) {
 		err = -ENOMEM;
-		goto err_core_alloc;
+		goto err_devlink_alloc;
 	}
 
+	mlxsw_core = devlink_priv(devlink);
 	INIT_LIST_HEAD(&mlxsw_core->rx_listener_list);
 	INIT_LIST_HEAD(&mlxsw_core->event_listener_list);
 	mlxsw_core->driver = mlxsw_driver;
@@ -841,6 +844,11 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_hwmon_init;
 
+	set_devlink_dev(devlink, mlxsw_bus_info->dev);
+	err = devlink_register(devlink);
+	if (err)
+		goto err_devlink_register;
+
 	err = mlxsw_driver->init(mlxsw_core->driver_priv, mlxsw_core,
 				 mlxsw_bus_info);
 	if (err)
@@ -855,6 +863,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_debugfs_init:
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
 err_driver_init:
+	devlink_unregister(devlink);
+err_devlink_register:
 err_hwmon_init:
 	mlxsw_emad_fini(mlxsw_core);
 err_emad_init:
@@ -864,8 +874,8 @@ err_bus_init:
 err_alloc_lag_mapping:
 	free_percpu(mlxsw_core->pcpu_stats);
 err_alloc_stats:
-	kfree(mlxsw_core);
-err_core_alloc:
+	devlink_free(devlink);
+err_devlink_alloc:
 	mlxsw_core_driver_put(device_kind);
 	return err;
 }
@@ -874,14 +884,16 @@ EXPORT_SYMBOL(mlxsw_core_bus_device_register);
 void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 {
 	const char *device_kind = mlxsw_core->bus_info->device_kind;
+	struct devlink *devlink = priv_to_devlink(mlxsw_core);
 
 	mlxsw_core_debugfs_fini(mlxsw_core);
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+	devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	kfree(mlxsw_core->lag.mapping);
 	free_percpu(mlxsw_core->pcpu_stats);
-	kfree(mlxsw_core);
+	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
 }
 EXPORT_SYMBOL(mlxsw_core_bus_device_unregister);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 217856b..9d4b06c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -49,6 +49,7 @@
 #include <linux/jiffies.h>
 #include <linux/bitops.h>
 #include <linux/list.h>
+#include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -1351,7 +1352,9 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 
 static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	bool usable;
 	size_t bytes;
@@ -1360,6 +1363,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	dev = alloc_etherdev(sizeof(struct mlxsw_sp_port));
 	if (!dev)
 		return -ENOMEM;
+	SET_NETDEV_DEV(dev, devlink_dev(devlink));
 	mlxsw_sp_port = netdev_priv(dev);
 	mlxsw_sp_port->dev = dev;
 	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
@@ -1417,6 +1421,14 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 		goto port_not_usable;
 	}
 
+	devlink_port = &mlxsw_sp_port->devlink_port;
+	err = devlink_port_register(devlink, devlink_port, local_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to register devlink port\n",
+			mlxsw_sp_port->local_port);
+		goto err_devlink_port_register;
+	}
+
 	err = mlxsw_sp_port_system_port_mapping_set(mlxsw_sp_port);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set system port mapping\n",
@@ -1457,6 +1469,8 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 		goto err_register_netdev;
 	}
 
+	devlink_port_type_eth_set(devlink_port, dev);
+
 	err = mlxsw_sp_port_vlan_init(mlxsw_sp_port);
 	if (err)
 		goto err_port_vlan_init;
@@ -1472,6 +1486,8 @@ err_port_admin_status_set:
 err_port_mtu_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
+	devlink_port_unregister(&mlxsw_sp_port->devlink_port);
+err_devlink_port_register:
 port_not_usable:
 err_port_module_check:
 err_dev_addr_init:
@@ -1505,10 +1521,14 @@ static void mlxsw_sp_port_vports_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	struct devlink_port *devlink_port;
 
 	if (!mlxsw_sp_port)
 		return;
+	devlink_port = &mlxsw_sp_port->devlink_port;
+	devlink_port_type_clear(devlink_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
+	devlink_port_unregister(devlink_port);
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7f42eb1..0df9a19 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -43,6 +43,7 @@
 #include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <net/switchdev.h>
+#include <net/devlink.h>
 
 #include "port.h"
 #include "core.h"
@@ -162,6 +163,7 @@ struct mlxsw_sp_port {
 	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
+	struct devlink_port devlink_port;
 };
 
 static inline struct mlxsw_sp_port *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index d85960c..7a60a26 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -43,6 +43,7 @@
 #include <linux/device.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
+#include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -78,6 +79,7 @@ struct mlxsw_sx_port {
 	struct mlxsw_sx_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sx *mlxsw_sx;
 	u8 local_port;
+	struct devlink_port devlink_port;
 };
 
 /* tx_hdr_version
@@ -953,7 +955,9 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 
 static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
+	struct devlink *devlink = priv_to_devlink(mlxsw_sx->core);
 	struct mlxsw_sx_port *mlxsw_sx_port;
+	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	bool usable;
 	int err;
@@ -1007,6 +1011,14 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 		goto port_not_usable;
 	}
 
+	devlink_port = &mlxsw_sx_port->devlink_port;
+	err = devlink_port_register(devlink, devlink_port, local_port);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to register devlink port\n",
+			mlxsw_sx_port->local_port);
+		goto err_devlink_port_register;
+	}
+
 	err = mlxsw_sx_port_system_port_mapping_set(mlxsw_sx_port);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set system port mapping\n",
@@ -1064,6 +1076,8 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 		goto err_register_netdev;
 	}
 
+	devlink_port_type_eth_set(devlink_port, dev);
+
 	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
 	return 0;
 
@@ -1075,6 +1089,8 @@ err_port_mtu_set:
 err_port_speed_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
+	devlink_port_unregister(&mlxsw_sx_port->devlink_port);
+err_devlink_port_register:
 port_not_usable:
 err_port_module_check:
 err_dev_addr_get:
@@ -1087,11 +1103,15 @@ err_alloc_stats:
 static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
+	struct devlink_port *devlink_port;
 
 	if (!mlxsw_sx_port)
 		return;
+	devlink_port = &mlxsw_sx_port->devlink_port;
+	devlink_port_type_clear(devlink_port);
 	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
+	devlink_port_unregister(devlink_port);
 	free_percpu(mlxsw_sx_port->pcpu_stats);
 	free_netdev(mlxsw_sx_port->dev);
 }
-- 
1.9.3
