From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] mlxsw: Query maximum number of ports from firmware
Date: Fri, 24 Mar 2017 08:02:48 +0100
Message-ID: <1490338971-2687-3-git-send-email-jiri@resnulli.us>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33240 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1755369AbdCXHDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:03:46 -0400
Received: by mail-wm0-f66.google.com with SMTP id n11so1388617wma.0
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:03:45 -0700 (PDT)
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We currently hard code the maximum number of ports in the driver, but
this may change in future devices, so query it from the firmware
instead.

Fallback to a maximum of 64 ports in case this number can't be queried.
This should only happen in SwitchX-2 for which this number is correct.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c         | 46 +++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  2 +
 drivers/net/ethernet/mellanox/mlxsw/port.h         | 10 +---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 16 +++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 12 ++--
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 67 ++++++++++++++++------
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  8 ++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |  7 ++-
 9 files changed, 125 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index fb8187d..affe84e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -110,11 +110,42 @@ struct mlxsw_core {
 	struct mlxsw_res res;
 	struct mlxsw_hwmon *hwmon;
 	struct mlxsw_thermal *thermal;
-	struct mlxsw_core_port ports[MLXSW_PORT_MAX_PORTS];
+	struct mlxsw_core_port *ports;
+	unsigned int max_ports;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
 };
 
+#define MLXSW_PORT_MAX_PORTS_DEFAULT	0x40
+
+static int mlxsw_ports_init(struct mlxsw_core *mlxsw_core)
+{
+	/* Switch ports are numbered from 1 to queried value */
+	if (MLXSW_CORE_RES_VALID(mlxsw_core, MAX_SYSTEM_PORT))
+		mlxsw_core->max_ports = MLXSW_CORE_RES_GET(mlxsw_core,
+							   MAX_SYSTEM_PORT) + 1;
+	else
+		mlxsw_core->max_ports = MLXSW_PORT_MAX_PORTS_DEFAULT + 1;
+
+	mlxsw_core->ports = kcalloc(mlxsw_core->max_ports,
+				    sizeof(struct mlxsw_core_port), GFP_KERNEL);
+	if (!mlxsw_core->ports)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void mlxsw_ports_fini(struct mlxsw_core *mlxsw_core)
+{
+	kfree(mlxsw_core->ports);
+}
+
+unsigned int mlxsw_core_max_ports(const struct mlxsw_core *mlxsw_core)
+{
+	return mlxsw_core->max_ports;
+}
+EXPORT_SYMBOL(mlxsw_core_max_ports);
+
 void *mlxsw_core_driver_priv(struct mlxsw_core *mlxsw_core)
 {
 	return mlxsw_core->driver_priv;
@@ -733,7 +764,7 @@ static int mlxsw_devlink_port_split(struct devlink *devlink,
 {
 	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
 
-	if (port_index >= MLXSW_PORT_MAX_PORTS)
+	if (port_index >= mlxsw_core->max_ports)
 		return -EINVAL;
 	if (!mlxsw_core->driver->port_split)
 		return -EOPNOTSUPP;
@@ -745,7 +776,7 @@ static int mlxsw_devlink_port_unsplit(struct devlink *devlink,
 {
 	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
 
-	if (port_index >= MLXSW_PORT_MAX_PORTS)
+	if (port_index >= mlxsw_core->max_ports)
 		return -EINVAL;
 	if (!mlxsw_core->driver->port_unsplit)
 		return -EOPNOTSUPP;
@@ -972,6 +1003,10 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_bus_init;
 
+	err = mlxsw_ports_init(mlxsw_core);
+	if (err)
+		goto err_ports_init;
+
 	if (MLXSW_CORE_RES_VALID(mlxsw_core, MAX_LAG) &&
 	    MLXSW_CORE_RES_VALID(mlxsw_core, MAX_LAG_MEMBERS)) {
 		alloc_size = sizeof(u8) *
@@ -1019,6 +1054,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_emad_init:
 	kfree(mlxsw_core->lag.mapping);
 err_alloc_lag_mapping:
+	mlxsw_ports_fini(mlxsw_core);
+err_ports_init:
 	mlxsw_bus->fini(bus_priv);
 err_bus_init:
 	devlink_free(devlink);
@@ -1039,6 +1076,7 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
 	kfree(mlxsw_core->lag.mapping);
+	mlxsw_ports_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
@@ -1508,7 +1546,7 @@ void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 			    __func__, local_port, rx_info->trap_id);
 
 	if ((rx_info->trap_id >= MLXSW_TRAP_ID_MAX) ||
-	    (local_port >= MLXSW_PORT_MAX_PORTS))
+	    (local_port >= mlxsw_core->max_ports))
 		goto drop;
 
 	rcu_read_lock();
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index cf38cf9..7fb3539 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -57,6 +57,8 @@ struct mlxsw_driver;
 struct mlxsw_bus;
 struct mlxsw_bus_info;
 
+unsigned int mlxsw_core_max_ports(const struct mlxsw_core *mlxsw_core);
+
 void *mlxsw_core_driver_priv(struct mlxsw_core *mlxsw_core);
 
 int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index 3d42146..c580abb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -49,20 +49,12 @@
 
 #define MLXSW_PORT_MID			0xd000
 
-#define MLXSW_PORT_MAX_PHY_PORTS	0x40
-#define MLXSW_PORT_MAX_PORTS		(MLXSW_PORT_MAX_PHY_PORTS + 1)
-
 #define MLXSW_PORT_MAX_IB_PHY_PORTS	36
 #define MLXSW_PORT_MAX_IB_PORTS		(MLXSW_PORT_MAX_IB_PHY_PORTS + 1)
 
-#define MLXSW_PORT_DEVID_BITS_OFFSET	10
-#define MLXSW_PORT_PHY_BITS_OFFSET	4
-#define MLXSW_PORT_PHY_BITS_MASK	(MLXSW_PORT_MAX_PHY_PORTS - 1)
-
 #define MLXSW_PORT_CPU_PORT		0x0
-#define MLXSW_PORT_ROUTER_PORT		(MLXSW_PORT_MAX_PHY_PORTS + 2)
 
-#define MLXSW_PORT_DONT_CARE		(MLXSW_PORT_MAX_PORTS)
+#define MLXSW_PORT_DONT_CARE		0xFF
 
 #define MLXSW_PORT_MODULE_MAX_WIDTH	4
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3ed77e1..7d0bd02 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2595,25 +2595,33 @@ static void mlxsw_sp_ports_remove(struct mlxsw_sp *mlxsw_sp)
 {
 	int i;
 
-	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+	for (i = 1; i < mlxsw_core_max_ports(mlxsw_sp->core); i++)
 		if (mlxsw_sp_port_created(mlxsw_sp, i))
 			mlxsw_sp_port_remove(mlxsw_sp, i);
+	kfree(mlxsw_sp->port_to_module);
 	kfree(mlxsw_sp->ports);
 }
 
 static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 {
+	unsigned int max_ports = mlxsw_core_max_ports(mlxsw_sp->core);
 	u8 module, width, lane;
 	size_t alloc_size;
 	int i;
 	int err;
 
-	alloc_size = sizeof(struct mlxsw_sp_port *) * MLXSW_PORT_MAX_PORTS;
+	alloc_size = sizeof(struct mlxsw_sp_port *) * max_ports;
 	mlxsw_sp->ports = kzalloc(alloc_size, GFP_KERNEL);
 	if (!mlxsw_sp->ports)
 		return -ENOMEM;
 
-	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+	mlxsw_sp->port_to_module = kcalloc(max_ports, sizeof(u8), GFP_KERNEL);
+	if (!mlxsw_sp->port_to_module) {
+		err = -ENOMEM;
+		goto err_port_to_module_alloc;
+	}
+
+	for (i = 1; i < max_ports; i++) {
 		err = mlxsw_sp_port_module_info_get(mlxsw_sp, i, &module,
 						    &width, &lane);
 		if (err)
@@ -2633,6 +2641,8 @@ static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
 	for (i--; i >= 1; i--)
 		if (mlxsw_sp_port_created(mlxsw_sp, i))
 			mlxsw_sp_port_remove(mlxsw_sp, i);
+	kfree(mlxsw_sp->port_to_module);
+err_port_to_module_alloc:
 	kfree(mlxsw_sp->ports);
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b1713a4..80a0d7d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -152,12 +152,14 @@ struct mlxsw_sp_sb_pm {
 #define MLXSW_SP_SB_POOL_COUNT	4
 #define MLXSW_SP_SB_TC_COUNT	8
 
+struct mlxsw_sp_sb_port {
+	struct mlxsw_sp_sb_cm cms[2][MLXSW_SP_SB_TC_COUNT];
+	struct mlxsw_sp_sb_pm pms[2][MLXSW_SP_SB_POOL_COUNT];
+};
+
 struct mlxsw_sp_sb {
 	struct mlxsw_sp_sb_pr prs[2][MLXSW_SP_SB_POOL_COUNT];
-	struct {
-		struct mlxsw_sp_sb_cm cms[2][MLXSW_SP_SB_TC_COUNT];
-		struct mlxsw_sp_sb_pm pms[2][MLXSW_SP_SB_POOL_COUNT];
-	} ports[MLXSW_PORT_MAX_PORTS];
+	struct mlxsw_sp_sb_port *ports;
 };
 
 #define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
@@ -273,7 +275,7 @@ struct mlxsw_sp {
 	u32 ageing_time;
 	struct mlxsw_sp_upper master_bridge;
 	struct mlxsw_sp_upper *lags;
-	u8 port_to_module[MLXSW_PORT_MAX_PORTS];
+	u8 *port_to_module;
 	struct mlxsw_sp_sb sb;
 	struct mlxsw_sp_router router;
 	struct mlxsw_sp_acl *acl;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index a746826..3ab853d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -209,11 +209,25 @@ static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port_pb_prio_init(mlxsw_sp_port);
 }
 
-#define MLXSW_SP_SB_PR_INGRESS_SIZE				\
-	(15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS))
+static int mlxsw_sp_sb_ports_init(struct mlxsw_sp *mlxsw_sp)
+{
+	unsigned int max_ports = mlxsw_core_max_ports(mlxsw_sp->core);
+
+	mlxsw_sp->sb.ports = kcalloc(max_ports, sizeof(struct mlxsw_sp_sb_port),
+				     GFP_KERNEL);
+	if (!mlxsw_sp->sb.ports)
+		return -ENOMEM;
+	return 0;
+}
+
+static void mlxsw_sp_sb_ports_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	kfree(mlxsw_sp->sb.ports);
+}
+
+#define MLXSW_SP_SB_PR_INGRESS_SIZE	12440000
 #define MLXSW_SP_SB_PR_INGRESS_MNG_SIZE (200 * 1000)
-#define MLXSW_SP_SB_PR_EGRESS_SIZE				\
-	(14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS))
+#define MLXSW_SP_SB_PR_EGRESS_SIZE	13232000
 
 #define MLXSW_SP_SB_PR(_mode, _size)	\
 	{				\
@@ -528,26 +542,41 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
-	err = mlxsw_sp_sb_prs_init(mlxsw_sp);
+	err = mlxsw_sp_sb_ports_init(mlxsw_sp);
 	if (err)
 		return err;
+	err = mlxsw_sp_sb_prs_init(mlxsw_sp);
+	if (err)
+		goto err_sb_prs_init;
 	err = mlxsw_sp_cpu_port_sb_cms_init(mlxsw_sp);
 	if (err)
-		return err;
+		goto err_sb_cpu_port_sb_cms_init;
 	err = mlxsw_sp_sb_mms_init(mlxsw_sp);
 	if (err)
-		return err;
-	return devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
-				   MLXSW_SP_SB_SIZE,
-				   MLXSW_SP_SB_POOL_COUNT,
-				   MLXSW_SP_SB_POOL_COUNT,
-				   MLXSW_SP_SB_TC_COUNT,
-				   MLXSW_SP_SB_TC_COUNT);
+		goto err_sb_mms_init;
+	err = devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
+				  MLXSW_SP_SB_SIZE,
+				  MLXSW_SP_SB_POOL_COUNT,
+				  MLXSW_SP_SB_POOL_COUNT,
+				  MLXSW_SP_SB_TC_COUNT,
+				  MLXSW_SP_SB_TC_COUNT);
+	if (err)
+		goto err_devlink_sb_register;
+
+	return 0;
+
+err_devlink_sb_register:
+err_sb_mms_init:
+err_sb_cpu_port_sb_cms_init:
+err_sb_prs_init:
+	mlxsw_sp_sb_ports_fini(mlxsw_sp);
+	return err;
 }
 
 void mlxsw_sp_buffers_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	devlink_sb_unregister(priv_to_devlink(mlxsw_sp->core), 0);
+	mlxsw_sp_sb_ports_fini(mlxsw_sp);
 }
 
 int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
@@ -761,7 +790,7 @@ static void mlxsw_sp_sb_sr_occ_query_cb(struct mlxsw_core *mlxsw_core,
 
 	masked_count = 0;
 	for (local_port = cb_ctx.local_port_1;
-	     local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+	     local_port < mlxsw_core_max_ports(mlxsw_core); local_port++) {
 		if (!mlxsw_sp->ports[local_port])
 			continue;
 		for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
@@ -775,7 +804,7 @@ static void mlxsw_sp_sb_sr_occ_query_cb(struct mlxsw_core *mlxsw_core,
 	}
 	masked_count = 0;
 	for (local_port = cb_ctx.local_port_1;
-	     local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+	     local_port < mlxsw_core_max_ports(mlxsw_core); local_port++) {
 		if (!mlxsw_sp->ports[local_port])
 			continue;
 		for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
@@ -817,7 +846,7 @@ int mlxsw_sp_sb_occ_snapshot(struct mlxsw_core *mlxsw_core,
 		mlxsw_reg_sbsr_pg_buff_mask_set(sbsr_pl, i, 1);
 		mlxsw_reg_sbsr_tclass_mask_set(sbsr_pl, i, 1);
 	}
-	for (; local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+	for (; local_port < mlxsw_core_max_ports(mlxsw_core); local_port++) {
 		if (!mlxsw_sp->ports[local_port])
 			continue;
 		mlxsw_reg_sbsr_ingress_port_mask_set(sbsr_pl, local_port, 1);
@@ -847,7 +876,7 @@ int mlxsw_sp_sb_occ_snapshot(struct mlxsw_core *mlxsw_core,
 				    cb_priv);
 	if (err)
 		goto out;
-	if (local_port < MLXSW_PORT_MAX_PORTS)
+	if (local_port < mlxsw_core_max_ports(mlxsw_core))
 		goto next_batch;
 
 out:
@@ -882,7 +911,7 @@ int mlxsw_sp_sb_occ_max_clear(struct mlxsw_core *mlxsw_core,
 		mlxsw_reg_sbsr_pg_buff_mask_set(sbsr_pl, i, 1);
 		mlxsw_reg_sbsr_tclass_mask_set(sbsr_pl, i, 1);
 	}
-	for (; local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+	for (; local_port < mlxsw_core_max_ports(mlxsw_core); local_port++) {
 		if (!mlxsw_sp->ports[local_port])
 			continue;
 		mlxsw_reg_sbsr_ingress_port_mask_set(sbsr_pl, local_port, 1);
@@ -908,7 +937,7 @@ int mlxsw_sp_sb_occ_max_clear(struct mlxsw_core *mlxsw_core,
 				    &bulk_list, NULL, 0);
 	if (err)
 		goto out;
-	if (local_port < MLXSW_PORT_MAX_PORTS)
+	if (local_port < mlxsw_core_max_ports(mlxsw_core))
 		goto next_batch;
 
 out:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2c666f9..8dbed1d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2976,6 +2976,11 @@ static struct mlxsw_sp_fid *mlxsw_sp_bridge_fid_get(struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_sp_fid_find(mlxsw_sp, fid);
 }
 
+static u8 mlxsw_sp_router_port(const struct mlxsw_sp *mlxsw_sp)
+{
+	return mlxsw_core_max_ports(mlxsw_sp->core) + 1;
+}
+
 static enum mlxsw_flood_table_type mlxsw_sp_flood_table_type_get(u16 fid)
 {
 	return mlxsw_sp_fid_is_vfid(fid) ? MLXSW_REG_SFGC_TABLE_TYPE_FID :
@@ -2990,6 +2995,7 @@ static u16 mlxsw_sp_flood_table_index_get(u16 fid)
 static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
 					  bool set)
 {
+	u8 router_port = mlxsw_sp_router_port(mlxsw_sp);
 	enum mlxsw_flood_table_type table_type;
 	char *sftr_pl;
 	u16 index;
@@ -3002,7 +3008,7 @@ static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
 	table_type = mlxsw_sp_flood_table_type_get(fid);
 	index = mlxsw_sp_flood_table_index_get(fid);
 	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BC, index, table_type,
-			    1, MLXSW_PORT_ROUTER_PORT, set);
+			    1, router_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 
 	kfree(sftr_pl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d44d92f..05eaa15 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1012,7 +1012,7 @@ static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
 
 	mlxsw_reg_smid_pack(smid_pl, mid, mlxsw_sp_port->local_port, add);
 	if (clear_all_ports) {
-		for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+		for (i = 1; i < mlxsw_core_max_ports(mlxsw_sp->core); i++)
 			if (mlxsw_sp->ports[i])
 				mlxsw_reg_smid_port_mask_set(smid_pl, i, 1);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index ec1e886..3b0f724 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1321,7 +1321,7 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 {
 	int i;
 
-	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+	for (i = 1; i < mlxsw_core_max_ports(mlxsw_sx->core); i++)
 		if (mlxsw_sx_port_created(mlxsw_sx, i))
 			mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
@@ -1329,17 +1329,18 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 
 static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 {
+	unsigned int max_ports = mlxsw_core_max_ports(mlxsw_sx->core);
 	size_t alloc_size;
 	u8 module, width;
 	int i;
 	int err;
 
-	alloc_size = sizeof(struct mlxsw_sx_port *) * MLXSW_PORT_MAX_PORTS;
+	alloc_size = sizeof(struct mlxsw_sx_port *) * max_ports;
 	mlxsw_sx->ports = kzalloc(alloc_size, GFP_KERNEL);
 	if (!mlxsw_sx->ports)
 		return -ENOMEM;
 
-	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+	for (i = 1; i < max_ports; i++) {
 		err = mlxsw_sx_port_module_info_get(mlxsw_sx, i, &module,
 						    &width);
 		if (err)
-- 
2.7.4
