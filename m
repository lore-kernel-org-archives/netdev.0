From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] mlxsw: Do not pass around driver_priv directly
Date: Fri,  8 Apr 2016 19:11:23 +0200
Message-ID: <1460135485-16095-5-git-send-email-jiri@resnulli.us>
References: <1460135485-16095-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36219 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbcDHRLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:11:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id l6so5799056wml.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 10:11:33 -0700 (PDT)
In-Reply-To: <1460135485-16095-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Instead of that, pass mlxsw_core and use a helper to get driver priv
from driver code. Looks much cleaner that way.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 19 +++++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 11 +++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 17 +++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  8 ++++----
 4 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 39161fb..3958195 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -114,6 +114,12 @@ struct mlxsw_core {
 	/* driver_priv has to be always the last item */
 };
 
+void *mlxsw_core_driver_priv(struct mlxsw_core *mlxsw_core)
+{
+	return mlxsw_core->driver_priv;
+}
+EXPORT_SYMBOL(mlxsw_core_driver_priv);
+
 struct mlxsw_rx_listener_item {
 	struct list_head list;
 	struct mlxsw_rx_listener rxl;
@@ -795,8 +801,7 @@ static int mlxsw_devlink_port_split(struct devlink *devlink,
 		return -EINVAL;
 	if (!mlxsw_core->driver->port_split)
 		return -EOPNOTSUPP;
-	return mlxsw_core->driver->port_split(mlxsw_core->driver_priv,
-					      port_index, count);
+	return mlxsw_core->driver->port_split(mlxsw_core, port_index, count);
 }
 
 static int mlxsw_devlink_port_unsplit(struct devlink *devlink,
@@ -808,8 +813,7 @@ static int mlxsw_devlink_port_unsplit(struct devlink *devlink,
 		return -EINVAL;
 	if (!mlxsw_core->driver->port_unsplit)
 		return -EOPNOTSUPP;
-	return mlxsw_core->driver->port_unsplit(mlxsw_core->driver_priv,
-						port_index);
+	return mlxsw_core->driver->port_unsplit(mlxsw_core, port_index);
 }
 
 static const struct devlink_ops mlxsw_devlink_ops = {
@@ -880,8 +884,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_devlink_register;
 
-	err = mlxsw_driver->init(mlxsw_core->driver_priv, mlxsw_core,
-				 mlxsw_bus_info);
+	err = mlxsw_driver->init(mlxsw_core, mlxsw_bus_info);
 	if (err)
 		goto err_driver_init;
 
@@ -892,7 +895,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	return 0;
 
 err_debugfs_init:
-	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+	mlxsw_core->driver->fini(mlxsw_core);
 err_driver_init:
 	devlink_unregister(devlink);
 err_devlink_register:
@@ -918,7 +921,7 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	struct devlink *devlink = priv_to_devlink(mlxsw_core);
 
 	mlxsw_core_debugfs_fini(mlxsw_core);
-	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+	mlxsw_core->driver->fini(mlxsw_core);
 	devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 0454212..f3cebef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -62,6 +62,8 @@ struct mlxsw_driver;
 struct mlxsw_bus;
 struct mlxsw_bus_info;
 
+void *mlxsw_core_driver_priv(struct mlxsw_core *mlxsw_core);
+
 int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver);
 void mlxsw_core_driver_unregister(struct mlxsw_driver *mlxsw_driver);
 
@@ -192,11 +194,12 @@ struct mlxsw_driver {
 	const char *kind;
 	struct module *owner;
 	size_t priv_size;
-	int (*init)(void *driver_priv, struct mlxsw_core *mlxsw_core,
+	int (*init)(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_bus_info *mlxsw_bus_info);
-	void (*fini)(void *driver_priv);
-	int (*port_split)(void *driver_priv, u8 local_port, unsigned int count);
-	int (*port_unsplit)(void *driver_priv, u8 local_port);
+	void (*fini)(struct mlxsw_core *mlxsw_core);
+	int (*port_split)(struct mlxsw_core *mlxsw_core, u8 local_port,
+			  unsigned int count);
+	int (*port_unsplit)(struct mlxsw_core *mlxsw_core, u8 local_port);
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
 	u8 txhdr_len;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8abe1a6..19b3c14 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1948,9 +1948,10 @@ static u8 mlxsw_sp_cluster_base_port_get(u8 local_port)
 	return local_port - offset;
 }
 
-static int mlxsw_sp_port_split(void *priv, u8 local_port, unsigned int count)
+static int mlxsw_sp_port_split(struct mlxsw_core *mlxsw_core, u8 local_port,
+			       unsigned int count)
 {
-	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	u8 width = MLXSW_PORT_MODULE_MAX_WIDTH / count;
 	u8 module, cur_width, base_port;
@@ -2022,9 +2023,9 @@ err_port_create:
 	return err;
 }
 
-static int mlxsw_sp_port_unsplit(void *priv, u8 local_port)
+static int mlxsw_sp_port_unsplit(struct mlxsw_core *mlxsw_core, u8 local_port)
 {
-	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	u8 module, cur_width, base_port;
 	unsigned int count;
@@ -2369,10 +2370,10 @@ static int mlxsw_sp_lag_init(struct mlxsw_sp *mlxsw_sp)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(slcr), slcr_pl);
 }
 
-static int mlxsw_sp_init(void *priv, struct mlxsw_core *mlxsw_core,
+static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
-	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 	int err;
 
 	mlxsw_sp->core = mlxsw_core;
@@ -2443,9 +2444,9 @@ err_event_register:
 	return err;
 }
 
-static void mlxsw_sp_fini(void *priv)
+static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
-	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 2518c84..3842eab 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1447,10 +1447,10 @@ static int mlxsw_sx_flood_init(struct mlxsw_sx *mlxsw_sx)
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sgcr), sgcr_pl);
 }
 
-static int mlxsw_sx_init(void *priv, struct mlxsw_core *mlxsw_core,
+static int mlxsw_sx_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
-	struct mlxsw_sx *mlxsw_sx = priv;
+	struct mlxsw_sx *mlxsw_sx = mlxsw_core_driver_priv(mlxsw_core);
 	int err;
 
 	mlxsw_sx->core = mlxsw_core;
@@ -1497,9 +1497,9 @@ err_event_register:
 	return err;
 }
 
-static void mlxsw_sx_fini(void *priv)
+static void mlxsw_sx_fini(struct mlxsw_core *mlxsw_core)
 {
-	struct mlxsw_sx *mlxsw_sx = priv;
+	struct mlxsw_sx *mlxsw_sx = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sx_traps_fini(mlxsw_sx);
 	mlxsw_sx_event_unregister(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
-- 
2.5.5
