From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/14] mlxsw: spectrum: Add support for VLAN devices on top of LAG
Date: Tue, 15 Dec 2015 16:03:47 +0100
Message-ID: <1450191827-6679-15-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37492 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933606AbbLOPEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:12 -0500
Received: by mail-wm0-f50.google.com with SMTP id n186so30052281wmn.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:11 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When creating a VLAN device on top of LAG, we are basically creating a
vPort on top of each of the port netdevs member in the LAG. Therefore,
these vPorts should inherit both the LAG status and LAG ID from the
underlying port netdevs.

In addition, when the VLAN device joins or leaves a bridge each of the
underlying vPorts should know about it and act accordingly. This is
achieved by propagating the VLAN event down to the lower devices.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 32 +++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e5f888f..c588c65 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -626,6 +626,8 @@ mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_vport->mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	mlxsw_sp_vport->local_port = mlxsw_sp_port->local_port;
 	mlxsw_sp_vport->stp_state = BR_STATE_FORWARDING;
+	mlxsw_sp_vport->lagged = mlxsw_sp_port->lagged;
+	mlxsw_sp_vport->lag_id = mlxsw_sp_port->lag_id;
 	mlxsw_sp_vport->vport.vfid = vfid;
 	mlxsw_sp_vport->vport.vid = vfid->vid;
 
@@ -2774,16 +2776,40 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	return NOTIFY_DONE;
 }
 
+static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
+					      unsigned long event, void *ptr,
+					      u16 vid)
+{
+	struct net_device *dev;
+	struct list_head *iter;
+	int ret;
+
+	netdev_for_each_lower_dev(lag_dev, dev, iter) {
+		if (mlxsw_sp_port_dev_check(dev)) {
+			ret = mlxsw_sp_netdevice_vport_event(dev, event, ptr,
+							     vid);
+			if (ret == NOTIFY_BAD)
+				return ret;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
 static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 					 unsigned long event, void *ptr)
 {
 	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
-	if (!mlxsw_sp_port_dev_check(real_dev))
-		return NOTIFY_DONE;
+	if (mlxsw_sp_port_dev_check(real_dev))
+		return mlxsw_sp_netdevice_vport_event(real_dev, event, ptr,
+						      vid);
+	else if (netif_is_lag_master(real_dev))
+		return mlxsw_sp_netdevice_lag_vport_event(real_dev, event, ptr,
+							  vid);
 
-	return mlxsw_sp_netdevice_vport_event(real_dev, event, ptr, vid);
+	return NOTIFY_DONE;
 }
 
 static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
-- 
1.9.3
