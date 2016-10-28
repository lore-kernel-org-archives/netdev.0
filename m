From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/16] mlxsw: core: Add port type (Eth/IB) set API
Date: Fri, 28 Oct 2016 21:35:58 +0200
Message-ID: <1477683361-8011-13-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34531 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761459AbcJ1Ttb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:49:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id p190so2514189wmp.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:49:31 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Add "port_type_set" API to mlxsw core. The core layer send the change type
callback to the port along with it's private information.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 41 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h |  6 +++++
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index dcd7202..6004817 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -93,6 +93,7 @@ struct mlxsw_core_pcpu_stats {
 struct mlxsw_core_port {
 	struct devlink_port devlink_port;
 	void *port_driver_priv;
+	u8 local_port;
 };
 
 void *mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port)
@@ -937,6 +938,21 @@ static void *__dl_port(struct devlink_port *devlink_port)
 	return container_of(devlink_port, struct mlxsw_core_port, devlink_port);
 }
 
+static int mlxsw_devlink_port_type_set(struct devlink_port *devlink_port,
+				       enum devlink_port_type port_type)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->port_type_set)
+		return -EOPNOTSUPP;
+
+	return mlxsw_driver->port_type_set(mlxsw_core,
+					   mlxsw_core_port->local_port,
+					   port_type);
+}
+
 static int mlxsw_devlink_sb_port_pool_get(struct devlink_port *devlink_port,
 					  unsigned int sb_index, u16 pool_index,
 					  u32 *p_threshold)
@@ -1060,6 +1076,7 @@ mlxsw_devlink_sb_occ_tc_port_bind_get(struct devlink_port *devlink_port,
 }
 
 static const struct devlink_ops mlxsw_devlink_ops = {
+	.port_type_set			= mlxsw_devlink_port_type_set,
 	.port_split			= mlxsw_devlink_port_split,
 	.port_unsplit			= mlxsw_devlink_port_unsplit,
 	.sb_pool_get			= mlxsw_devlink_sb_pool_get,
@@ -1687,6 +1704,7 @@ int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core, u8 local_port)
 	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
 	int err;
 
+	mlxsw_core_port->local_port = local_port;
 	err = devlink_port_register(devlink, devlink_port, local_port);
 	if (err)
 		memset(mlxsw_core_port, 0, sizeof(*mlxsw_core_port));
@@ -1720,6 +1738,18 @@ void mlxsw_core_port_eth_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 }
 EXPORT_SYMBOL(mlxsw_core_port_eth_set);
 
+void mlxsw_core_port_ib_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			    void *port_driver_priv)
+{
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	mlxsw_core_port->port_driver_priv = port_driver_priv;
+	devlink_port_type_ib_set(devlink_port, NULL);
+}
+EXPORT_SYMBOL(mlxsw_core_port_ib_set);
+
 void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
 			   void *port_driver_priv)
 {
@@ -1732,6 +1762,17 @@ void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
 }
 EXPORT_SYMBOL(mlxsw_core_port_clear);
 
+enum devlink_port_type mlxsw_core_port_type_get(struct mlxsw_core *mlxsw_core,
+						u8 local_port)
+{
+	struct mlxsw_core_port *mlxsw_core_port =
+					&mlxsw_core->ports[local_port];
+	struct devlink_port *devlink_port = &mlxsw_core_port->devlink_port;
+
+	return devlink_port->type;
+}
+EXPORT_SYMBOL(mlxsw_core_port_type_get);
+
 static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
 				    const char *buf, size_t size)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 82866d5..c0acc1b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -148,8 +148,12 @@ void mlxsw_core_port_fini(struct mlxsw_core *mlxsw_core, u8 local_port);
 void mlxsw_core_port_eth_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 			     void *port_driver_priv, struct net_device *dev,
 			     bool split, u32 split_group);
+void mlxsw_core_port_ib_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			    void *port_driver_priv);
 void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
 			   void *port_driver_priv);
+enum devlink_port_type mlxsw_core_port_type_get(struct mlxsw_core *mlxsw_core,
+						u8 local_port);
 
 int mlxsw_core_schedule_dw(struct delayed_work *dwork, unsigned long delay);
 
@@ -210,6 +214,8 @@ struct mlxsw_driver {
 	int (*init)(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_bus_info *mlxsw_bus_info);
 	void (*fini)(struct mlxsw_core *mlxsw_core);
+	int (*port_type_set)(struct mlxsw_core *mlxsw_core, u8 local_port,
+			     enum devlink_port_type new_type);
 	int (*port_split)(struct mlxsw_core *mlxsw_core, u8 local_port,
 			  unsigned int count);
 	int (*port_unsplit)(struct mlxsw_core *mlxsw_core, u8 local_port);
-- 
2.5.5
