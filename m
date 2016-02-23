From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 5/9] mlxsw: core: Add devlink port splitter callbacks
Date: Tue, 23 Feb 2016 16:51:30 +0100
Message-ID: <1456242694-29463-6-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38210 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbcBWPvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:51:45 -0500
Received: by mail-wm0-f43.google.com with SMTP id a4so215380474wme.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:51:44 -0800 (PST)
In-Reply-To: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add middle layer in mlxsw core code to forward port split/unsplit calls
into specific ASIC drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 34 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h |  2 ++
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 57d9655..e9d3040 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -785,6 +785,38 @@ static void mlxsw_core_debugfs_fini(struct mlxsw_core *mlxsw_core)
 	debugfs_remove_recursive(mlxsw_core->dbg_dir);
 }
 
+static int mlxsw_devlink_port_split(struct devlink *devlink,
+				    unsigned int port_index,
+				    unsigned int count)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+
+	if (port_index >= MLXSW_PORT_MAX_PORTS)
+		return -EINVAL;
+	if (!mlxsw_core->driver->port_split)
+		return -EOPNOTSUPP;
+	return mlxsw_core->driver->port_split(mlxsw_core->driver_priv,
+					      port_index, count);
+}
+
+static int mlxsw_devlink_port_unsplit(struct devlink *devlink,
+				      unsigned int port_index)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+
+	if (port_index >= MLXSW_PORT_MAX_PORTS)
+		return -EINVAL;
+	if (!mlxsw_core->driver->port_unsplit)
+		return -EOPNOTSUPP;
+	return mlxsw_core->driver->port_unsplit(mlxsw_core->driver_priv,
+						port_index);
+}
+
+static const struct devlink_ops mlxsw_devlink_ops = {
+	.port_split	= mlxsw_devlink_port_split,
+	.port_unsplit	= mlxsw_devlink_port_unsplit,
+};
+
 int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 				   const struct mlxsw_bus *mlxsw_bus,
 				   void *bus_priv)
@@ -800,7 +832,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (!mlxsw_driver)
 		return -EINVAL;
 	alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
-	devlink = devlink_alloc(NULL, alloc_size);
+	devlink = devlink_alloc(&mlxsw_devlink_ops, alloc_size);
 	if (!devlink) {
 		err = -ENOMEM;
 		goto err_devlink_alloc;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index a017236..c73d1c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -186,6 +186,8 @@ struct mlxsw_driver {
 	int (*init)(void *driver_priv, struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_bus_info *mlxsw_bus_info);
 	void (*fini)(void *driver_priv);
+	int (*port_split)(void *driver_priv, u8 local_port, unsigned int count);
+	int (*port_unsplit)(void *driver_priv, u8 local_port);
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
 	u8 txhdr_len;
-- 
2.5.0
