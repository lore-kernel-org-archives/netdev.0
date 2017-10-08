From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next repost 2/2] mlxsw: spectrum: Propagate extack further for bridge enslavements
Date: Sun,  8 Oct 2017 11:57:56 +0200
Message-ID: <20171008095756.2139-3-jiri@resnulli.us>
References: <20171008095756.2139-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:45291 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdJHJ6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 05:58:00 -0400
Received: by mail-wm0-f68.google.com with SMTP id q124so15809611wmb.0
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 02:58:00 -0700 (PDT)
In-Reply-To: <20171008095756.2139-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The code that actually takes care of bridge offload introduces a few
more non-trivial constraints with regards to bridge enslavements.
Propagate extack there to indicate the reason.

$ ip link add link enp1s0np1 name enp1s0np1.10 type vlan id 10
$ ip link add link enp1s0np1 name enp1s0np1.20 type vlan id 20
$ ip link add name br0 type bridge
$ ip link set dev enp1s0np1.10 master br0
$ ip link set dev enp1s0np1.20 master br0
Error: spectrum: Can not bridge VLAN uppers of the same port.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 ++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 25 +++++++++++++++-------
 3 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5ab4fd7..321988a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4299,7 +4299,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
 			if (info->linking)
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
 								lower_dev,
-								upper_dev);
+								upper_dev,
+								extack);
 			else
 				mlxsw_sp_port_bridge_leave(mlxsw_sp_port,
 							   lower_dev,
@@ -4416,7 +4417,8 @@ static int mlxsw_sp_netdevice_port_vlan_event(struct net_device *vlan_dev,
 			if (info->linking)
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
 								vlan_dev,
-								upper_dev);
+								upper_dev,
+								extack);
 			else
 				mlxsw_sp_port_bridge_leave(mlxsw_sp_port,
 							   vlan_dev,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ae67e60..8e45183 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -326,7 +326,8 @@ void
 mlxsw_sp_port_vlan_bridge_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 			      struct net_device *brport_dev,
-			      struct net_device *br_dev);
+			      struct net_device *br_dev,
+			      struct netlink_ext_ack *extack);
 void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				struct net_device *brport_dev,
 				struct net_device *br_dev);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0f9eac5..2cfdf22 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -46,6 +46,7 @@
 #include <linux/workqueue.h>
 #include <linux/jiffies.h>
 #include <linux/rtnetlink.h>
+#include <linux/netlink.h>
 #include <net/switchdev.h>
 
 #include "spectrum.h"
@@ -107,7 +108,8 @@ struct mlxsw_sp_bridge_vlan {
 struct mlxsw_sp_bridge_ops {
 	int (*port_join)(struct mlxsw_sp_bridge_device *bridge_device,
 			 struct mlxsw_sp_bridge_port *bridge_port,
-			 struct mlxsw_sp_port *mlxsw_sp_port);
+			 struct mlxsw_sp_port *mlxsw_sp_port,
+			 struct netlink_ext_ack *extack);
 	void (*port_leave)(struct mlxsw_sp_bridge_device *bridge_device,
 			   struct mlxsw_sp_bridge_port *bridge_port,
 			   struct mlxsw_sp_port *mlxsw_sp_port);
@@ -1735,12 +1737,15 @@ static const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
 static int
 mlxsw_sp_bridge_8021q_port_join(struct mlxsw_sp_bridge_device *bridge_device,
 				struct mlxsw_sp_bridge_port *bridge_port,
-				struct mlxsw_sp_port *mlxsw_sp_port)
+				struct mlxsw_sp_port *mlxsw_sp_port,
+				struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 
-	if (is_vlan_dev(bridge_port->dev))
+	if (is_vlan_dev(bridge_port->dev)) {
+		NL_SET_ERR_MSG(extack, "spectrum: Can not enslave a VLAN device to a VLAN-aware bridge");
 		return -EINVAL;
+	}
 
 	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, 1);
 	if (WARN_ON(!mlxsw_sp_port_vlan))
@@ -1797,13 +1802,16 @@ mlxsw_sp_port_is_br_member(const struct mlxsw_sp_port *mlxsw_sp_port,
 static int
 mlxsw_sp_bridge_8021d_port_join(struct mlxsw_sp_bridge_device *bridge_device,
 				struct mlxsw_sp_bridge_port *bridge_port,
-				struct mlxsw_sp_port *mlxsw_sp_port)
+				struct mlxsw_sp_port *mlxsw_sp_port,
+				struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	u16 vid;
 
-	if (!is_vlan_dev(bridge_port->dev))
+	if (!is_vlan_dev(bridge_port->dev)) {
+		NL_SET_ERR_MSG(extack, "spectrum: Only VLAN devices can be enslaved to a VLAN-unaware bridge");
 		return -EINVAL;
+	}
 	vid = vlan_dev_vlan_id(bridge_port->dev);
 
 	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
@@ -1811,7 +1819,7 @@ mlxsw_sp_bridge_8021d_port_join(struct mlxsw_sp_bridge_device *bridge_device,
 		return -EINVAL;
 
 	if (mlxsw_sp_port_is_br_member(mlxsw_sp_port, bridge_device->dev)) {
-		netdev_err(mlxsw_sp_port->dev, "Can't bridge VLAN uppers of the same port\n");
+		NL_SET_ERR_MSG(extack, "spectrum: Can not bridge VLAN uppers of the same port");
 		return -EINVAL;
 	}
 
@@ -1854,7 +1862,8 @@ static const struct mlxsw_sp_bridge_ops mlxsw_sp_bridge_8021d_ops = {
 
 int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 			      struct net_device *brport_dev,
-			      struct net_device *br_dev)
+			      struct net_device *br_dev,
+			      struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_bridge_device *bridge_device;
@@ -1867,7 +1876,7 @@ int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	bridge_device = bridge_port->bridge_device;
 
 	err = bridge_device->ops->port_join(bridge_device, bridge_port,
-					    mlxsw_sp_port);
+					    mlxsw_sp_port, extack);
 	if (err)
 		goto err_port_join;
 
-- 
2.9.5
