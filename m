From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/16] mlxsw: switchx2: Add support for physical port names
Date: Fri, 28 Oct 2016 21:35:50 +0200
Message-ID: <1477683361-8011-5-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33654 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761702AbcJ1TnC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:43:02 -0400
Received: by mail-wm0-f67.google.com with SMTP id m83so8764715wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:43:02 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Export to userspace the front panel name of the port, so that udev can
rename the ports accordingly. The convention suggested by switchdev
documentation is used: pX

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 32 ++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 6882e35..941393b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -81,6 +81,9 @@ struct mlxsw_sx_port {
 	struct mlxsw_sx_port_pcpu_stats __percpu *pcpu_stats;
 	struct mlxsw_sx *mlxsw_sx;
 	u8 local_port;
+	struct {
+		u8 module;
+	} mapping;
 };
 
 /* tx_hdr_version
@@ -257,7 +260,8 @@ mlxsw_sx_port_system_port_mapping_set(struct mlxsw_sx_port *mlxsw_sx_port)
 }
 
 static int mlxsw_sx_port_module_info_get(struct mlxsw_sx *mlxsw_sx,
-					 u8 local_port, u8 *p_width)
+					 u8 local_port, u8 *p_module,
+					 u8 *p_width)
 {
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int err;
@@ -266,6 +270,7 @@ static int mlxsw_sx_port_module_info_get(struct mlxsw_sx *mlxsw_sx,
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(pmlp), pmlp_pl);
 	if (err)
 		return err;
+	*p_module = mlxsw_reg_pmlp_module_get(pmlp_pl, 0);
 	*p_width = mlxsw_reg_pmlp_width_get(pmlp_pl);
 	return 0;
 }
@@ -383,12 +388,26 @@ mlxsw_sx_port_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev, char *name,
+					    size_t len)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	int err;
+
+	err = snprintf(name, len, "p%d", mlxsw_sx_port->mapping.module + 1);
+	if (err >= len)
+		return -EINVAL;
+
+	return 0;
+}
+
 static const struct net_device_ops mlxsw_sx_port_netdev_ops = {
 	.ndo_open		= mlxsw_sx_port_open,
 	.ndo_stop		= mlxsw_sx_port_stop,
 	.ndo_start_xmit		= mlxsw_sx_port_xmit,
 	.ndo_change_mtu		= mlxsw_sx_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sx_port_get_stats64,
+	.ndo_get_phys_port_name = mlxsw_sx_port_get_phys_port_name,
 };
 
 static void mlxsw_sx_port_get_drvinfo(struct net_device *dev,
@@ -957,7 +976,8 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spmlr), spmlr_pl);
 }
 
-static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				u8 module)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	struct net_device *dev;
@@ -971,6 +991,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	mlxsw_sx_port->dev = dev;
 	mlxsw_sx_port->mlxsw_sx = mlxsw_sx;
 	mlxsw_sx_port->local_port = local_port;
+	mlxsw_sx_port->mapping.module = module;
 
 	mlxsw_sx_port->pcpu_stats =
 		netdev_alloc_pcpu_stats(struct mlxsw_sx_port_pcpu_stats);
@@ -1119,7 +1140,7 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 {
 	size_t alloc_size;
-	u8 width;
+	u8 module, width;
 	int i;
 	int err;
 
@@ -1129,12 +1150,13 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 		return -ENOMEM;
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
-		err = mlxsw_sx_port_module_info_get(mlxsw_sx, i, &width);
+		err = mlxsw_sx_port_module_info_get(mlxsw_sx, i, &module,
+						    &width);
 		if (err)
 			goto err_port_module_info_get;
 		if (!width)
 			continue;
-		err = mlxsw_sx_port_create(mlxsw_sx, i);
+		err = mlxsw_sx_port_create(mlxsw_sx, i, module);
 		if (err)
 			goto err_port_create;
 	}
-- 
2.5.5
