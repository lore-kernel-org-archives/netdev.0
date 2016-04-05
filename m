From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum: Add support for physical port names
Date: Tue,  5 Apr 2016 10:20:04 +0200
Message-ID: <1459844404-4698-4-git-send-email-jiri@resnulli.us>
References: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36156 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbcDEIUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:20:12 -0400
Received: by mail-wm0-f45.google.com with SMTP id 127so15722480wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 01:20:12 -0700 (PDT)
In-Reply-To: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Export to userspace the front panel name of the port, so that udev can
rename the ports accordingly. The convention suggested by switchdev
documentation is used:

1) Non-split: pX
2) Split: pXsY

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 45 ++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4afbc3e..cb5f36e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -305,9 +305,9 @@ mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sspr), sspr_pl);
 }
 
-static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
-					 u8 local_port, u8 *p_module,
-					 u8 *p_width)
+static int __mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
+					   u8 local_port, u8 *p_module,
+					   u8 *p_width, u8 *p_lane)
 {
 	char pmlp_pl[MLXSW_REG_PMLP_LEN];
 	int err;
@@ -318,9 +318,20 @@ static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
 		return err;
 	*p_module = mlxsw_reg_pmlp_module_get(pmlp_pl, 0);
 	*p_width = mlxsw_reg_pmlp_width_get(pmlp_pl);
+	*p_lane = mlxsw_reg_pmlp_tx_lane_get(pmlp_pl, 0);
 	return 0;
 }
 
+static int mlxsw_sp_port_module_info_get(struct mlxsw_sp *mlxsw_sp,
+					 u8 local_port, u8 *p_module,
+					 u8 *p_width)
+{
+	u8 lane;
+
+	return __mlxsw_sp_port_module_info_get(mlxsw_sp, local_port, p_module,
+					       p_width, &lane);
+}
+
 static int mlxsw_sp_port_module_map(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				    u8 module, u8 width, u8 lane)
 {
@@ -861,6 +872,33 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	return 0;
 }
 
+static int mlxsw_sp_port_get_phys_port_name(struct net_device *dev, char *name,
+					    size_t len)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	u8 module, width, lane;
+	int err;
+
+	err = __mlxsw_sp_port_module_info_get(mlxsw_sp_port->mlxsw_sp,
+					      mlxsw_sp_port->local_port,
+					      &module, &width, &lane);
+	if (err) {
+		netdev_err(dev, "Failed to retrieve module information\n");
+		return err;
+	}
+
+	if (!mlxsw_sp_port->split)
+		err = snprintf(name, len, "p%d", module + 1);
+	else
+		err = snprintf(name, len, "p%ds%d", module + 1,
+			       lane / width);
+
+	if (err >= len)
+		return -EINVAL;
+
+	return 0;
+}
+
 static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_open		= mlxsw_sp_port_open,
 	.ndo_stop		= mlxsw_sp_port_stop,
@@ -877,6 +915,7 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+	.ndo_get_phys_port_name	= mlxsw_sp_port_get_phys_port_name,
 };
 
 static void mlxsw_sp_port_get_drvinfo(struct net_device *dev,
-- 
2.5.5
