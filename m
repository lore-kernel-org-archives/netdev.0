From: <idosch@mellanox.com>
Subject: [PATCH net-next] mlxsw: spectrum_router: Simplify VRF enslavement
Date: Sun, 30 Apr 2017 19:47:14 +0300
Message-ID: <20170430164714.7303-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jiri@mellanox.com>, <mlxsw@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00041.outbound.protection.outlook.com ([40.107.0.41]:18452
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1424413AbdD3Qrn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 12:47:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a netdev is enslaved to a VRF master, its router interface (RIF)
needs to be destroyed (if exists) and a new one created using the
corresponding virtual router (VR).

>From the driver's perspective, the above is equivalent to an inetaddr
event sent for this netdev. Therefore, when a port netdev (or its
uppers) are enslaved to a VRF master, call the same function that
would've been called had a NETDEV_UP was sent for this netdev in the
inetaddr notification chain.

This patch also fixes a bug when a LAG netdev with an existing RIF is
enslaved to a VRF. Before this patch, each LAG port would drop the
reference on the RIF, but would re-join the same one (in the wrong VR)
soon after. With this patch, the corresponding RIF is first destroyed
and a new one is created using the correct VR.

Fixes: 7179eb5acd59 ("mlxsw: spectrum_router: Add support for VRFs")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  77 +++------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  10 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 107 +++++++++------------
 3 files changed, 63 insertions(+), 131 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 20c1b6c..88357ce 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4106,7 +4106,6 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		if (!is_vlan_dev(upper_dev) &&
 		    !netif_is_lag_master(upper_dev) &&
 		    !netif_is_bridge_master(upper_dev) &&
-		    !netif_is_l3_master(upper_dev) &&
 		    !netif_is_ovs_master(upper_dev))
 			return -EINVAL;
 		if (!info->linking)
@@ -4151,11 +4150,6 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 			else
 				mlxsw_sp_port_lag_leave(mlxsw_sp_port,
 							upper_dev);
-		} else if (netif_is_l3_master(upper_dev)) {
-			if (info->linking)
-				err = mlxsw_sp_port_vrf_join(mlxsw_sp_port);
-			else
-				mlxsw_sp_port_vrf_leave(mlxsw_sp_port);
 		} else if (netif_is_ovs_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_ovs_join(mlxsw_sp_port);
@@ -4275,7 +4269,7 @@ static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!is_vlan_dev(upper_dev) && !netif_is_l3_master(upper_dev))
+		if (!is_vlan_dev(upper_dev))
 			return -EINVAL;
 		if (is_vlan_dev(upper_dev) &&
 		    br_dev != mlxsw_sp->master_bridge.dev)
@@ -4290,12 +4284,6 @@ static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
 			else
 				mlxsw_sp_master_bridge_vlan_unlink(mlxsw_sp,
 								   upper_dev);
-		} else if (netif_is_l3_master(upper_dev)) {
-			if (info->linking)
-				err = mlxsw_sp_bridge_vrf_join(mlxsw_sp,
-							       br_dev);
-			else
-				mlxsw_sp_bridge_vrf_leave(mlxsw_sp, br_dev);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -4529,8 +4517,7 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!netif_is_bridge_master(upper_dev) &&
-		    !netif_is_l3_master(upper_dev))
+		if (!netif_is_bridge_master(upper_dev))
 			return -EINVAL;
 		if (!info->linking)
 			break;
@@ -4550,11 +4537,6 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 								 upper_dev);
 			else
 				mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
-		} else if (netif_is_l3_master(upper_dev)) {
-			if (info->linking)
-				err = mlxsw_sp_vport_vrf_join(mlxsw_sp_vport);
-			else
-				mlxsw_sp_vport_vrf_leave(mlxsw_sp_vport);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -4585,47 +4567,6 @@ static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
 	return 0;
 }
 
-static int mlxsw_sp_netdevice_bridge_vlan_event(struct net_device *vlan_dev,
-						unsigned long event, void *ptr)
-{
-	struct netdev_notifier_changeupper_info *info;
-	struct mlxsw_sp *mlxsw_sp;
-	int err = 0;
-
-	mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
-	if (!mlxsw_sp)
-		return 0;
-
-	info = ptr;
-
-	switch (event) {
-	case NETDEV_PRECHANGEUPPER:
-		/* VLAN devices are only allowed on top of the
-		 * VLAN-aware bridge.
-		 */
-		if (WARN_ON(vlan_dev_real_dev(vlan_dev) !=
-			    mlxsw_sp->master_bridge.dev))
-			return -EINVAL;
-		if (!netif_is_l3_master(info->upper_dev))
-			return -EINVAL;
-		break;
-	case NETDEV_CHANGEUPPER:
-		if (netif_is_l3_master(info->upper_dev)) {
-			if (info->linking)
-				err = mlxsw_sp_bridge_vrf_join(mlxsw_sp,
-							       vlan_dev);
-			else
-				mlxsw_sp_bridge_vrf_leave(mlxsw_sp, vlan_dev);
-		} else {
-			err = -EINVAL;
-			WARN_ON(1);
-		}
-		break;
-	}
-
-	return err;
-}
-
 static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 					 unsigned long event, void *ptr)
 {
@@ -4638,13 +4579,19 @@ static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 	else if (netif_is_lag_master(real_dev))
 		return mlxsw_sp_netdevice_lag_vport_event(real_dev, event, ptr,
 							  vid);
-	else if (netif_is_bridge_master(real_dev))
-		return mlxsw_sp_netdevice_bridge_vlan_event(vlan_dev, event,
-							    ptr);
 
 	return 0;
 }
 
+static bool mlxsw_sp_is_vrf_event(unsigned long event, void *ptr)
+{
+	struct netdev_notifier_changeupper_info *info = ptr;
+
+	if (event != NETDEV_PRECHANGEUPPER && event != NETDEV_CHANGEUPPER)
+		return false;
+	return netif_is_l3_master(info->upper_dev);
+}
+
 static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 				    unsigned long event, void *ptr)
 {
@@ -4653,6 +4600,8 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 
 	if (event == NETDEV_CHANGEADDR || event == NETDEV_CHANGEMTU)
 		err = mlxsw_sp_netdevice_router_port_event(dev);
+	else if (mlxsw_sp_is_vrf_event(event, ptr))
+		err = mlxsw_sp_netdevice_vrf_event(dev, event, ptr);
 	else if (mlxsw_sp_port_dev_check(dev))
 		err = mlxsw_sp_netdevice_port_event(dev, event, ptr);
 	else if (netif_is_lag_master(dev))
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0af6e1a..0c23bc1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -576,14 +576,8 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr);
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_rif *rif);
-int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport);
-void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
-int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port);
-void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port);
-int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
-			     struct net_device *l3_dev);
-void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
-			       struct net_device *l3_dev);
+int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
+				 struct netdev_notifier_changeupper_info *info);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
 			u32 *p_entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 146f8c7..33cec1c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3345,6 +3345,21 @@ static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 	return 0;
 }
 
+static int __mlxsw_sp_inetaddr_event(struct net_device *dev,
+				     unsigned long event)
+{
+	if (mlxsw_sp_port_dev_check(dev))
+		return mlxsw_sp_inetaddr_port_event(dev, event);
+	else if (netif_is_lag_master(dev))
+		return mlxsw_sp_inetaddr_lag_event(dev, event);
+	else if (netif_is_bridge_master(dev))
+		return mlxsw_sp_inetaddr_bridge_event(dev, dev, event);
+	else if (is_vlan_dev(dev))
+		return mlxsw_sp_inetaddr_vlan_event(dev, event);
+	else
+		return 0;
+}
+
 int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr)
 {
@@ -3362,15 +3377,7 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	if (!mlxsw_sp_rif_should_config(rif, ifa->ifa_dev, event))
 		goto out;
 
-	if (mlxsw_sp_port_dev_check(dev))
-		err = mlxsw_sp_inetaddr_port_event(dev, event);
-	else if (netif_is_lag_master(dev))
-		err = mlxsw_sp_inetaddr_lag_event(dev, event);
-	else if (netif_is_bridge_master(dev))
-		err = mlxsw_sp_inetaddr_bridge_event(dev, dev, event);
-	else if (is_vlan_dev(dev))
-		err = mlxsw_sp_inetaddr_vlan_event(dev, event);
-
+	err = __mlxsw_sp_inetaddr_event(dev, event);
 out:
 	return notifier_from_errno(err);
 }
@@ -3433,71 +3440,53 @@ int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
 	return err;
 }
 
-int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport)
+static int mlxsw_sp_port_vrf_join(struct mlxsw_sp *mlxsw_sp,
+				  struct net_device *l3_dev)
 {
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-	struct net_device *dev = mlxsw_sp_vport->dev;
+	struct mlxsw_sp_rif *rif;
 
-	/* In case vPort already has a RIF, then we need to drop it.
-	 * A new one will be created using the VRF's VR.
+	/* If netdev is already associated with a RIF, then we need to
+	 * destroy it and create a new one with the new virtual router ID.
 	 */
-	if (f && f->rif)
-		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
-
-	return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, dev);
-}
-
-void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
-{
-	mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
-}
-
-int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	struct mlxsw_sp_port *mlxsw_sp_vport;
-
-	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
-	if (WARN_ON(!mlxsw_sp_vport))
-		return -EINVAL;
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
+	if (rif)
+		__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN);
 
-	return mlxsw_sp_vport_vrf_join(mlxsw_sp_vport);
+	return __mlxsw_sp_inetaddr_event(l3_dev, NETDEV_UP);
 }
 
-void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+static void mlxsw_sp_port_vrf_leave(struct mlxsw_sp *mlxsw_sp,
+				    struct net_device *l3_dev)
 {
-	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_rif *rif;
 
-	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
-	if (WARN_ON(!mlxsw_sp_vport))
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
+	if (!rif)
 		return;
-
-	mlxsw_sp_vport_vrf_leave(mlxsw_sp_vport);
+	__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN);
 }
 
-int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
-			     struct net_device *l3_dev)
+int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
+				 struct netdev_notifier_changeupper_info *info)
 {
-	struct mlxsw_sp_fid *f;
-
-	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
-	if (WARN_ON(!f))
-		return -EINVAL;
-
-	if (f->rif)
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(l3_dev);
+	int err = 0;
 
-	return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
-}
+	if (!mlxsw_sp)
+		return 0;
 
-void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
-			       struct net_device *l3_dev)
-{
-	struct mlxsw_sp_fid *f;
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+		return 0;
+	case NETDEV_CHANGEUPPER:
+		if (info->linking)
+			err = mlxsw_sp_port_vrf_join(mlxsw_sp, l3_dev);
+		else
+			mlxsw_sp_port_vrf_leave(mlxsw_sp, l3_dev);
+		break;
+	}
 
-	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
-	if (WARN_ON(!f))
-		return;
-	mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
+	return err;
 }
 
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
-- 
2.9.3
