From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 03/13] mlxsw: Move devlink port registration into common core code
Date: Thu, 17 Mar 2016 18:13:43 +0100
Message-ID: <1458234833-25836-4-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34876 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031747AbcCQROA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:00 -0400
Received: by mail-wm0-f49.google.com with SMTP id l68so2765546wml.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:00 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Remove devlink port reg/unreg from spectrum and switchx2 code and rather
do the common work in core. That also ensures code separation where
devlink is only used in core.c.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 22 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 19 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 31 +++++++++-----------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  3 +--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 30 +++++++++----------------
 5 files changed, 64 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index f69f628..004fb8b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1358,6 +1358,28 @@ void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_lag_mapping_clear);
 
+int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
+			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
+			 struct net_device *dev, bool split, u32 split_group)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_core);
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	if (split)
+		devlink_port_split_set(devlink_port, split_group);
+	devlink_port_type_eth_set(devlink_port, dev);
+	return devlink_port_register(devlink, devlink_port, local_port);
+}
+EXPORT_SYMBOL(mlxsw_core_port_init);
+
+void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port)
+{
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	devlink_port_unregister(devlink_port);
+}
+EXPORT_SYMBOL(mlxsw_core_port_fini);
+
 int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
 		   u32 in_mod, bool out_mbox_direct,
 		   char *in_mbox, size_t in_mbox_size,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index c73d1c0..cc8fceb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -43,6 +43,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
+#include <net/devlink.h>
 
 #include "trap.h"
 #include "reg.h"
@@ -131,6 +132,24 @@ u8 mlxsw_core_lag_mapping_get(struct mlxsw_core *mlxsw_core,
 void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 				  u16 lag_id, u8 local_port);
 
+struct mlxsw_core_port {
+	struct devlink_port devlink_port;
+};
+
+static inline void *
+mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port)
+{
+	/* mlxsw_core_port is ensured to be always the first field in driver
+	 * port structure
+	 */
+	return mlxsw_core_port;
+}
+
+int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
+			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
+			 struct net_device *dev, bool split, u32 split_group);
+void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port);
+
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
 struct mlxsw_swid_config {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4afbc3e..22bba32 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -49,7 +49,6 @@
 #include <linux/jiffies.h>
 #include <linux/bitops.h>
 #include <linux/list.h>
-#include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -1405,9 +1404,7 @@ mlxsw_sp_port_speed_by_width_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 width)
 static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				  bool split, u8 module, u8 width)
 {
-	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
-	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	size_t bytes;
 	int err;
@@ -1460,16 +1457,6 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	 */
 	dev->hard_header_len += MLXSW_TXHDR_LEN;
 
-	devlink_port = &mlxsw_sp_port->devlink_port;
-	if (mlxsw_sp_port->split)
-		devlink_port_split_set(devlink_port, module);
-	err = devlink_port_register(devlink, devlink_port, local_port);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to register devlink port\n",
-			mlxsw_sp_port->local_port);
-		goto err_devlink_port_register;
-	}
-
 	err = mlxsw_sp_port_system_port_mapping_set(mlxsw_sp_port);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set system port mapping\n",
@@ -1517,7 +1504,14 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_register_netdev;
 	}
 
-	devlink_port_type_eth_set(devlink_port, dev);
+	err = mlxsw_core_port_init(mlxsw_sp->core, &mlxsw_sp_port->core_port,
+				   mlxsw_sp_port->local_port, dev,
+				   mlxsw_sp_port->split, module);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to init core port\n",
+			mlxsw_sp_port->local_port);
+		goto err_core_port_init;
+	}
 
 	err = mlxsw_sp_port_vlan_init(mlxsw_sp_port);
 	if (err)
@@ -1527,6 +1521,8 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return 0;
 
 err_port_vlan_init:
+	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
+err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
 err_port_buffers_init:
@@ -1535,8 +1531,6 @@ err_port_mtu_set:
 err_port_speed_by_width_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
-	devlink_port_unregister(&mlxsw_sp_port->devlink_port);
-err_devlink_port_register:
 err_dev_addr_init:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
@@ -1590,15 +1584,12 @@ static void mlxsw_sp_port_vports_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
-	struct devlink_port *devlink_port;
 
 	if (!mlxsw_sp_port)
 		return;
 	mlxsw_sp->ports[local_port] = NULL;
-	devlink_port = &mlxsw_sp_port->devlink_port;
-	devlink_port_type_clear(devlink_port);
+	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
-	devlink_port_unregister(devlink_port);
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 4b8abaf..22a5a94 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -43,7 +43,6 @@
 #include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <net/switchdev.h>
-#include <net/devlink.h>
 
 #include "port.h"
 #include "core.h"
@@ -148,6 +147,7 @@ struct mlxsw_sp_port_pcpu_stats {
 };
 
 struct mlxsw_sp_port {
+	struct mlxsw_core_port core_port; /* must be first */
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sp *mlxsw_sp;
@@ -171,7 +171,6 @@ struct mlxsw_sp_port {
 	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
-	struct devlink_port devlink_port;
 };
 
 static inline struct mlxsw_sp_port *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 7a60a26..f4f2a9d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -43,7 +43,6 @@
 #include <linux/device.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
-#include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -75,11 +74,11 @@ struct mlxsw_sx_port_pcpu_stats {
 };
 
 struct mlxsw_sx_port {
+	struct mlxsw_core_port core_port; /* must be first */
 	struct net_device *dev;
 	struct mlxsw_sx_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sx *mlxsw_sx;
 	u8 local_port;
-	struct devlink_port devlink_port;
 };
 
 /* tx_hdr_version
@@ -955,9 +954,7 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 
 static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
-	struct devlink *devlink = priv_to_devlink(mlxsw_sx->core);
 	struct mlxsw_sx_port *mlxsw_sx_port;
-	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	bool usable;
 	int err;
@@ -1011,14 +1008,6 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 		goto port_not_usable;
 	}
 
-	devlink_port = &mlxsw_sx_port->devlink_port;
-	err = devlink_port_register(devlink, devlink_port, local_port);
-	if (err) {
-		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to register devlink port\n",
-			mlxsw_sx_port->local_port);
-		goto err_devlink_port_register;
-	}
-
 	err = mlxsw_sx_port_system_port_mapping_set(mlxsw_sx_port);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set system port mapping\n",
@@ -1076,11 +1065,19 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 		goto err_register_netdev;
 	}
 
-	devlink_port_type_eth_set(devlink_port, dev);
+	err = mlxsw_core_port_init(mlxsw_sx->core, &mlxsw_sx_port->core_port,
+				   mlxsw_sx_port->local_port, dev, false, 0);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to init core port\n",
+			mlxsw_sx_port->local_port);
+		goto err_core_port_init;
+	}
 
 	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
 	return 0;
 
+err_core_port_init:
+	unregister_netdev(dev);
 err_register_netdev:
 err_port_mac_learning_mode_set:
 err_port_stp_state_set:
@@ -1089,8 +1086,6 @@ err_port_mtu_set:
 err_port_speed_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
-	devlink_port_unregister(&mlxsw_sx_port->devlink_port);
-err_devlink_port_register:
 port_not_usable:
 err_port_module_check:
 err_dev_addr_get:
@@ -1103,15 +1098,12 @@ err_alloc_stats:
 static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
-	struct devlink_port *devlink_port;
 
 	if (!mlxsw_sx_port)
 		return;
-	devlink_port = &mlxsw_sx_port->devlink_port;
-	devlink_port_type_clear(devlink_port);
+	mlxsw_core_port_fini(&mlxsw_sx_port->core_port);
 	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
-	devlink_port_unregister(devlink_port);
 	free_percpu(mlxsw_sx_port->pcpu_stats);
 	free_netdev(mlxsw_sx_port->dev);
 }
-- 
2.5.0
