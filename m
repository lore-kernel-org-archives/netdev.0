From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/18] mlxsw: core: Add devlink shared buffer callbacks
Date: Thu, 14 Apr 2016 18:19:15 +0200
Message-ID: <1460650770-19382-4-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37868 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906AbcDNQTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:38 -0400
Received: by mail-wm0-f53.google.com with SMTP id n3so133906590wmn.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:37 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add middle layer in mlxsw core code to forward shared buffer calls
into specific ASIC drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 105 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h |  20 ++++++
 2 files changed, 123 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 3958195..1278260 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -816,9 +816,110 @@ static int mlxsw_devlink_port_unsplit(struct devlink *devlink,
 	return mlxsw_core->driver->port_unsplit(mlxsw_core, port_index);
 }
 
+static int
+mlxsw_devlink_sb_pool_get(struct devlink *devlink,
+			  unsigned int sb_index, u16 pool_index,
+			  struct devlink_sb_pool_info *pool_info)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+
+	if (!mlxsw_driver->sb_pool_get)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_pool_get(mlxsw_core, sb_index,
+					 pool_index, pool_info);
+}
+
+static int
+mlxsw_devlink_sb_pool_set(struct devlink *devlink,
+			  unsigned int sb_index, u16 pool_index, u32 size,
+			  enum devlink_sb_threshold_type threshold_type)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+
+	if (!mlxsw_driver->sb_pool_set)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_pool_set(mlxsw_core, sb_index,
+					 pool_index, size, threshold_type);
+}
+
+static void *__dl_port(struct devlink_port *devlink_port)
+{
+	return container_of(devlink_port, struct mlxsw_core_port, devlink_port);
+}
+
+static int mlxsw_devlink_sb_port_pool_get(struct devlink_port *devlink_port,
+					  unsigned int sb_index, u16 pool_index,
+					  u32 *p_threshold)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_port_pool_get)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_port_pool_get(mlxsw_core_port, sb_index,
+					      pool_index, p_threshold);
+}
+
+static int mlxsw_devlink_sb_port_pool_set(struct devlink_port *devlink_port,
+					  unsigned int sb_index, u16 pool_index,
+					  u32 threshold)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_port_pool_set)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_port_pool_set(mlxsw_core_port, sb_index,
+					      pool_index, threshold);
+}
+
+static int
+mlxsw_devlink_sb_tc_pool_bind_get(struct devlink_port *devlink_port,
+				  unsigned int sb_index, u16 tc_index,
+				  enum devlink_sb_pool_type pool_type,
+				  u16 *p_pool_index, u32 *p_threshold)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_tc_pool_bind_get)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_tc_pool_bind_get(mlxsw_core_port, sb_index,
+						 tc_index, pool_type,
+						 p_pool_index, p_threshold);
+}
+
+static int
+mlxsw_devlink_sb_tc_pool_bind_set(struct devlink_port *devlink_port,
+				  unsigned int sb_index, u16 tc_index,
+				  enum devlink_sb_pool_type pool_type,
+				  u16 pool_index, u32 threshold)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_tc_pool_bind_set)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_tc_pool_bind_set(mlxsw_core_port, sb_index,
+						 tc_index, pool_type,
+						 pool_index, threshold);
+}
+
 static const struct devlink_ops mlxsw_devlink_ops = {
-	.port_split	= mlxsw_devlink_port_split,
-	.port_unsplit	= mlxsw_devlink_port_unsplit,
+	.port_split		= mlxsw_devlink_port_split,
+	.port_unsplit		= mlxsw_devlink_port_unsplit,
+	.sb_pool_get		= mlxsw_devlink_sb_pool_get,
+	.sb_pool_set		= mlxsw_devlink_sb_pool_set,
+	.sb_port_pool_get	= mlxsw_devlink_sb_port_pool_get,
+	.sb_port_pool_set	= mlxsw_devlink_sb_port_pool_set,
+	.sb_tc_pool_bind_get	= mlxsw_devlink_sb_tc_pool_bind_get,
+	.sb_tc_pool_bind_set	= mlxsw_devlink_sb_tc_pool_bind_set,
 };
 
 int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index f3cebef..184e985 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -200,6 +200,26 @@ struct mlxsw_driver {
 	int (*port_split)(struct mlxsw_core *mlxsw_core, u8 local_port,
 			  unsigned int count);
 	int (*port_unsplit)(struct mlxsw_core *mlxsw_core, u8 local_port);
+	int (*sb_pool_get)(struct mlxsw_core *mlxsw_core,
+			   unsigned int sb_index, u16 pool_index,
+			   struct devlink_sb_pool_info *pool_info);
+	int (*sb_pool_set)(struct mlxsw_core *mlxsw_core,
+			   unsigned int sb_index, u16 pool_index, u32 size,
+			   enum devlink_sb_threshold_type threshold_type);
+	int (*sb_port_pool_get)(struct mlxsw_core_port *mlxsw_core_port,
+				unsigned int sb_index, u16 pool_index,
+				u32 *p_threshold);
+	int (*sb_port_pool_set)(struct mlxsw_core_port *mlxsw_core_port,
+				unsigned int sb_index, u16 pool_index,
+				u32 threshold);
+	int (*sb_tc_pool_bind_get)(struct mlxsw_core_port *mlxsw_core_port,
+				   unsigned int sb_index, u16 tc_index,
+				   enum devlink_sb_pool_type pool_type,
+				   u16 *p_pool_index, u32 *p_threshold);
+	int (*sb_tc_pool_bind_set)(struct mlxsw_core_port *mlxsw_core_port,
+				   unsigned int sb_index, u16 tc_index,
+				   enum devlink_sb_pool_type pool_type,
+				   u16 pool_index, u32 threshold);
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
 	u8 txhdr_len;
-- 
2.5.5
