From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/18] mlxsw: core: Add devlink shared buffer occupancy callbacks
Date: Thu, 14 Apr 2016 18:19:25 +0200
Message-ID: <1460650770-19382-14-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36627 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964835AbcDNQTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:52 -0400
Received: by mail-wm0-f44.google.com with SMTP id v188so227625448wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:51 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add middle layer in mlxsw core code to forward shared buffer occupancy
calls into specific ASIC drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 74 ++++++++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlxsw/core.h | 11 +++++
 2 files changed, 77 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 1278260..63a9777 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -911,15 +911,73 @@ mlxsw_devlink_sb_tc_pool_bind_set(struct devlink_port *devlink_port,
 						 pool_index, threshold);
 }
 
+static int mlxsw_devlink_sb_occ_snapshot(struct devlink *devlink,
+					 unsigned int sb_index)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+
+	if (!mlxsw_driver->sb_occ_snapshot)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_occ_snapshot(mlxsw_core, sb_index);
+}
+
+static int mlxsw_devlink_sb_occ_max_clear(struct devlink *devlink,
+					  unsigned int sb_index)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+
+	if (!mlxsw_driver->sb_occ_max_clear)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_occ_max_clear(mlxsw_core, sb_index);
+}
+
+static int
+mlxsw_devlink_sb_occ_port_pool_get(struct devlink_port *devlink_port,
+				   unsigned int sb_index, u16 pool_index,
+				   u32 *p_cur, u32 *p_max)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_occ_port_pool_get)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_occ_port_pool_get(mlxsw_core_port, sb_index,
+						  pool_index, p_cur, p_max);
+}
+
+static int
+mlxsw_devlink_sb_occ_tc_port_bind_get(struct devlink_port *devlink_port,
+				      unsigned int sb_index, u16 tc_index,
+				      enum devlink_sb_pool_type pool_type,
+				      u32 *p_cur, u32 *p_max)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink_port->devlink);
+	struct mlxsw_driver *mlxsw_driver = mlxsw_core->driver;
+	struct mlxsw_core_port *mlxsw_core_port = __dl_port(devlink_port);
+
+	if (!mlxsw_driver->sb_occ_tc_port_bind_get)
+		return -EOPNOTSUPP;
+	return mlxsw_driver->sb_occ_tc_port_bind_get(mlxsw_core_port,
+						     sb_index, tc_index,
+						     pool_type, p_cur, p_max);
+}
+
 static const struct devlink_ops mlxsw_devlink_ops = {
-	.port_split		= mlxsw_devlink_port_split,
-	.port_unsplit		= mlxsw_devlink_port_unsplit,
-	.sb_pool_get		= mlxsw_devlink_sb_pool_get,
-	.sb_pool_set		= mlxsw_devlink_sb_pool_set,
-	.sb_port_pool_get	= mlxsw_devlink_sb_port_pool_get,
-	.sb_port_pool_set	= mlxsw_devlink_sb_port_pool_set,
-	.sb_tc_pool_bind_get	= mlxsw_devlink_sb_tc_pool_bind_get,
-	.sb_tc_pool_bind_set	= mlxsw_devlink_sb_tc_pool_bind_set,
+	.port_split			= mlxsw_devlink_port_split,
+	.port_unsplit			= mlxsw_devlink_port_unsplit,
+	.sb_pool_get			= mlxsw_devlink_sb_pool_get,
+	.sb_pool_set			= mlxsw_devlink_sb_pool_set,
+	.sb_port_pool_get		= mlxsw_devlink_sb_port_pool_get,
+	.sb_port_pool_set		= mlxsw_devlink_sb_port_pool_set,
+	.sb_tc_pool_bind_get		= mlxsw_devlink_sb_tc_pool_bind_get,
+	.sb_tc_pool_bind_set		= mlxsw_devlink_sb_tc_pool_bind_set,
+	.sb_occ_snapshot		= mlxsw_devlink_sb_occ_snapshot,
+	.sb_occ_max_clear		= mlxsw_devlink_sb_occ_max_clear,
+	.sb_occ_port_pool_get		= mlxsw_devlink_sb_occ_port_pool_get,
+	.sb_occ_tc_port_bind_get	= mlxsw_devlink_sb_occ_tc_port_bind_get,
 };
 
 int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index d0c471f..377dacc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -229,6 +229,17 @@ struct mlxsw_driver {
 				   unsigned int sb_index, u16 tc_index,
 				   enum devlink_sb_pool_type pool_type,
 				   u16 pool_index, u32 threshold);
+	int (*sb_occ_snapshot)(struct mlxsw_core *mlxsw_core,
+			       unsigned int sb_index);
+	int (*sb_occ_max_clear)(struct mlxsw_core *mlxsw_core,
+				unsigned int sb_index);
+	int (*sb_occ_port_pool_get)(struct mlxsw_core_port *mlxsw_core_port,
+				    unsigned int sb_index, u16 pool_index,
+				    u32 *p_cur, u32 *p_max);
+	int (*sb_occ_tc_port_bind_get)(struct mlxsw_core_port *mlxsw_core_port,
+				       unsigned int sb_index, u16 tc_index,
+				       enum devlink_sb_pool_type pool_type,
+				       u32 *p_cur, u32 *p_max);
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
 	u8 txhdr_len;
-- 
2.5.5
