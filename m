From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: Move devlink port registration into common core code
Date: Fri,  8 Apr 2016 17:45:21 +0200
Message-ID: <1460130325-14931-2-git-send-email-jiri@resnulli.us>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35630 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540AbcDHPpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:45:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id a140so5282661wma.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:45:30 -0700 (PDT)
In-Reply-To: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Remove devlink port reg/unreg from spectrum and switchx2 code and rather
do the common work in core. That also ensures code separation where
devlink is only used in core.c.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 22 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 10 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 31 +++++++++-----------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  3 +--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 30 +++++++++----------------
 5 files changed, 55 insertions(+), 41 deletions(-)

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
index c73d1c0..06631a0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -43,6 +43,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
+#include <net/devlink.h>
 
 #include "trap.h"
 #include "reg.h"
@@ -131,6 +132,15 @@ u8 mlxsw_core_lag_mapping_get(struct mlxsw_core *mlxsw_core,
 void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 				  u16 lag_id, u8 local_port);
 
+struct mlxsw_core_port {
+	struct devlink_port devlink_port;
+};
+
+int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
+			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
+			 struct net_device *dev, bool split, u32 split_group);
+void mlxsw_core_port_fini(struct mlxsw_core_port *mlxsw_core_port);
+
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
 struct mlxsw_swid_config {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 507263a..3216f2b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -50,7 +50,6 @@
 #include <linux/bitops.h>
 #include <linux/list.h>
 #include <linux/dcbnl.h>
-#include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -1685,9 +1684,7 @@ static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
 static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				  bool split, u8 module, u8 width)
 {
-	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
-	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	size_t bytes;
 	int err;
@@ -1740,16 +1737,6 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
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
@@ -1812,7 +1799,14 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
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
@@ -1822,6 +1816,8 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return 0;
 
 err_port_vlan_init:
+	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
+err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
 err_port_dcb_init:
@@ -1832,8 +1828,6 @@ err_port_mtu_set:
 err_port_speed_by_width_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
-	devlink_port_unregister(&mlxsw_sp_port->devlink_port);
-err_devlink_port_register:
 err_dev_addr_init:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
@@ -1887,16 +1881,13 @@ static void mlxsw_sp_port_vports_fini(struct mlxsw_sp_port *mlxsw_sp_port)
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
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
-	devlink_port_unregister(devlink_port);
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 47610a5..361b0c2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -44,7 +44,6 @@
 #include <linux/list.h>
 #include <linux/dcbnl.h>
 #include <net/switchdev.h>
-#include <net/devlink.h>
 
 #include "port.h"
 #include "core.h"
@@ -166,6 +165,7 @@ struct mlxsw_sp_port_pcpu_stats {
 };
 
 struct mlxsw_sp_port {
+	struct mlxsw_core_port core_port; /* must be first */
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sp *mlxsw_sp;
@@ -198,7 +198,6 @@ struct mlxsw_sp_port {
 	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
-	struct devlink_port devlink_port;
 };
 
 static inline bool
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index c49447f..2417f09 100644
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
@@ -956,9 +955,7 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 
 static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
-	struct devlink *devlink = priv_to_devlink(mlxsw_sx->core);
 	struct mlxsw_sx_port *mlxsw_sx_port;
-	struct devlink_port *devlink_port;
 	struct net_device *dev;
 	bool usable;
 	int err;
@@ -1012,14 +1009,6 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
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
@@ -1077,11 +1066,19 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
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
@@ -1090,8 +1087,6 @@ err_port_mtu_set:
 err_port_speed_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
-	devlink_port_unregister(&mlxsw_sx_port->devlink_port);
-err_devlink_port_register:
 port_not_usable:
 err_port_module_check:
 err_dev_addr_get:
@@ -1104,15 +1099,12 @@ err_alloc_stats:
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
2.5.5
