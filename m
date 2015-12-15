From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/14] mlxsw: spectrum: Handle VLAN devices linking / unlinking
Date: Tue, 15 Dec 2015 16:03:43 +0100
Message-ID: <1450191827-6679-11-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34558 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933598AbbLOPEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:05 -0500
Received: by mail-wm0-f51.google.com with SMTP id p66so114411886wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:05 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a VLAN interface is configured on top of a physical port we should
associate the VLAN device with the matching vPort. Likewise, when it's
removed, we should revert back to the underlying port netdev.

While not a must, this is consistent with port netdevs and also provides
a more accurate error printing via netdev_err() and friends.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 54 ++++++++++++++++++++++++--
 1 file changed, 51 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7b1ce97..159b18d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2259,6 +2259,40 @@ static int mlxsw_sp_port_lag_changed(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_lag_tx_en_set(mlxsw_sp_port, info->tx_enabled);
 }
 
+static int mlxsw_sp_port_vlan_link(struct mlxsw_sp_port *mlxsw_sp_port,
+				   struct net_device *vlan_dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	u16 vid = vlan_dev_vlan_id(vlan_dev);
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	if (!mlxsw_sp_vport) {
+		WARN_ON(!mlxsw_sp_vport);
+		return -EINVAL;
+	}
+
+	mlxsw_sp_vport->dev = vlan_dev;
+
+	return 0;
+}
+
+static int mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
+				     struct net_device *vlan_dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	u16 vid = vlan_dev_vlan_id(vlan_dev);
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	if (!mlxsw_sp_vport) {
+		WARN_ON(!mlxsw_sp_vport);
+		return -EINVAL;
+	}
+
+	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
+
+	return 0;
+}
+
 static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 					       unsigned long event, void *ptr)
 {
@@ -2288,9 +2322,23 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!info->master)
-			break;
-		if (netif_is_bridge_master(upper_dev)) {
+		if (is_vlan_dev(upper_dev)) {
+			if (info->linking) {
+				err = mlxsw_sp_port_vlan_link(mlxsw_sp_port,
+							      upper_dev);
+				if (err) {
+					netdev_err(dev, "Failed to link VLAN device\n");
+					return NOTIFY_BAD;
+				}
+			} else {
+				err = mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
+								upper_dev);
+				if (err) {
+					netdev_err(dev, "Failed to unlink VLAN device\n");
+					return NOTIFY_BAD;
+				}
+			}
+		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking) {
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
 				if (err)
-- 
1.9.3
