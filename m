From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/18] mlxsw: spectrum: Don't lose bridge port device during enslavement
Date: Fri, 26 May 2017 08:37:29 +0200
Message-ID: <20170526063740.8909-8-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35407 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933815AbdEZGhx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so1684004wmc.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:52 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when port netdevs (or their uppers) are enslaved to a bridge,
we simply propagate the CHANGEUPPER event all the way down and lose the
context of the actual netdevice used as the bridge port.

This leads to a lot of information hanging off the ports (and vPorts),
which doesn't logically belong there, such as mrouter indication and
unknown unicast flood state.

Following patches are going to put the mlxsw_sp_port struct on diet and
instead introduce a bridge port struct, where the above mentioned
information belongs. But in order to do that, we need to be able to
determine the bridge port netdevice, so propagate it down.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 67 +++++++++++++++++---------
 1 file changed, 44 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e04d2ed..29d9439 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4026,6 +4026,7 @@ static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp)
 }
 
 static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
+				     struct net_device *brport_dev,
 				     struct net_device *br_dev)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
@@ -4053,7 +4054,9 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
-static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
+				       struct net_device *brport_dev,
+				       struct net_device *br_dev)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 
@@ -4302,7 +4305,7 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
-		mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
+		mlxsw_sp_port_bridge_leave(mlxsw_sp_port, NULL, NULL);
 	}
 
 	if (lag->ref_count == 1)
@@ -4439,7 +4442,8 @@ static void mlxsw_sp_port_ovs_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_sp_port_vp_mode_set(mlxsw_sp_port, false);
 }
 
-static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
+static int mlxsw_sp_netdevice_port_upper_event(struct net_device *lower_dev,
+					       struct net_device *dev,
 					       unsigned long event, void *ptr)
 {
 	struct netdev_notifier_changeupper_info *info;
@@ -4492,9 +4496,12 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
+								lower_dev,
 								upper_dev);
 			else
-				mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
+				mlxsw_sp_port_bridge_leave(mlxsw_sp_port,
+							   lower_dev,
+							   upper_dev);
 		} else if (netif_is_lag_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
@@ -4541,15 +4548,18 @@ static int mlxsw_sp_netdevice_port_lower_event(struct net_device *dev,
 	return 0;
 }
 
-static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
+static int mlxsw_sp_netdevice_port_event(struct net_device *lower_dev,
+					 struct net_device *port_dev,
 					 unsigned long event, void *ptr)
 {
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGEUPPER:
-		return mlxsw_sp_netdevice_port_upper_event(dev, event, ptr);
+		return mlxsw_sp_netdevice_port_upper_event(lower_dev, port_dev,
+							   event, ptr);
 	case NETDEV_CHANGELOWERSTATE:
-		return mlxsw_sp_netdevice_port_lower_event(dev, event, ptr);
+		return mlxsw_sp_netdevice_port_lower_event(port_dev, event,
+							   ptr);
 	}
 
 	return 0;
@@ -4564,7 +4574,8 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 
 	netdev_for_each_lower_dev(lag_dev, dev, iter) {
 		if (mlxsw_sp_port_dev_check(dev)) {
-			ret = mlxsw_sp_netdevice_port_event(dev, event, ptr);
+			ret = mlxsw_sp_netdevice_port_event(lag_dev, dev, event,
+							    ptr);
 			if (ret)
 				return ret;
 		}
@@ -4807,6 +4818,7 @@ mlxsw_sp_port_vlan_vfid_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 }
 
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
+				      struct net_device *brport_dev,
 				      struct net_device *br_dev)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
@@ -4848,7 +4860,9 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return err;
 }
 
-static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+					struct net_device *brport_dev,
+					struct net_device *br_dev)
 {
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
@@ -4885,9 +4899,10 @@ mlxsw_sp_port_master_bridge_check(const struct mlxsw_sp_port *mlxsw_sp_port,
 	return true;
 }
 
-static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
-					  unsigned long event, void *ptr,
-					  u16 vid)
+static int mlxsw_sp_netdevice_port_vlan_event(struct net_device *vlan_dev,
+					      struct net_device *dev,
+					      unsigned long event, void *ptr,
+					      u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct netdev_notifier_changeupper_info *info = ptr;
@@ -4919,9 +4934,12 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 		if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
+								 vlan_dev,
 								 upper_dev);
 			else
-				mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
+				mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport,
+							    vlan_dev,
+							    upper_dev);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -4932,9 +4950,10 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	return err;
 }
 
-static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
-					      unsigned long event, void *ptr,
-					      u16 vid)
+static int mlxsw_sp_netdevice_lag_port_vlan_event(struct net_device *vlan_dev,
+						  struct net_device *lag_dev,
+						  unsigned long event,
+						  void *ptr, u16 vid)
 {
 	struct net_device *dev;
 	struct list_head *iter;
@@ -4942,8 +4961,9 @@ static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
 
 	netdev_for_each_lower_dev(lag_dev, dev, iter) {
 		if (mlxsw_sp_port_dev_check(dev)) {
-			ret = mlxsw_sp_netdevice_vport_event(dev, event, ptr,
-							     vid);
+			ret = mlxsw_sp_netdevice_port_vlan_event(vlan_dev, dev,
+								 event, ptr,
+								 vid);
 			if (ret)
 				return ret;
 		}
@@ -4959,11 +4979,12 @@ static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	if (mlxsw_sp_port_dev_check(real_dev))
-		return mlxsw_sp_netdevice_vport_event(real_dev, event, ptr,
-						      vid);
+		return mlxsw_sp_netdevice_port_vlan_event(vlan_dev, real_dev,
+							  event, ptr, vid);
 	else if (netif_is_lag_master(real_dev))
-		return mlxsw_sp_netdevice_lag_vport_event(real_dev, event, ptr,
-							  vid);
+		return mlxsw_sp_netdevice_lag_port_vlan_event(vlan_dev,
+							      real_dev, event,
+							      ptr, vid);
 
 	return 0;
 }
@@ -4988,7 +5009,7 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 	else if (mlxsw_sp_is_vrf_event(event, ptr))
 		err = mlxsw_sp_netdevice_vrf_event(dev, event, ptr);
 	else if (mlxsw_sp_port_dev_check(dev))
-		err = mlxsw_sp_netdevice_port_event(dev, event, ptr);
+		err = mlxsw_sp_netdevice_port_event(dev, dev, event, ptr);
 	else if (netif_is_lag_master(dev))
 		err = mlxsw_sp_netdevice_lag_event(dev, event, ptr);
 	else if (netif_is_bridge_master(dev))
-- 
2.9.3
