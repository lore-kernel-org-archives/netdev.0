From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 8/9] mlxsw: spectrum_router: Add support for VRFs on top of bridges
Date: Thu, 16 Mar 2017 09:08:19 +0100
Message-ID: <1489651700-3586-9-git-send-email-jiri@resnulli.us>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36780 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdCPIIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:08:47 -0400
Received: by mail-wr0-f196.google.com with SMTP id l37so4805267wrc.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 01:08:32 -0700 (PDT)
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In a similar fashion to the previous patch, allow bridges and VLAN
devices on top of bridges to be enslaved to a VRF master device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 52 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 26 +++++++++++
 3 files changed, 81 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 659df32..28019f8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4111,7 +4111,7 @@ static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!is_vlan_dev(upper_dev))
+		if (!is_vlan_dev(upper_dev) && !netif_is_l3_master(upper_dev))
 			return -EINVAL;
 		if (is_vlan_dev(upper_dev) &&
 		    br_dev != mlxsw_sp->master_bridge.dev)
@@ -4126,6 +4126,12 @@ static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
 			else
 				mlxsw_sp_master_bridge_vlan_unlink(mlxsw_sp,
 								   upper_dev);
+		} else if (netif_is_l3_master(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_bridge_vrf_join(mlxsw_sp,
+							       br_dev);
+			else
+				mlxsw_sp_bridge_vrf_leave(mlxsw_sp, br_dev);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -4415,6 +4421,47 @@ static int mlxsw_sp_netdevice_lag_vport_event(struct net_device *lag_dev,
 	return 0;
 }
 
+static int mlxsw_sp_netdevice_bridge_vlan_event(struct net_device *vlan_dev,
+						unsigned long event, void *ptr)
+{
+	struct netdev_notifier_changeupper_info *info;
+	struct mlxsw_sp *mlxsw_sp;
+	int err = 0;
+
+	mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
+	if (!mlxsw_sp)
+		return 0;
+
+	info = ptr;
+
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+		/* VLAN devices are only allowed on top of the
+		 * VLAN-aware bridge.
+		 */
+		if (WARN_ON(vlan_dev_real_dev(vlan_dev) !=
+			    mlxsw_sp->master_bridge.dev))
+			return -EINVAL;
+		if (!netif_is_l3_master(info->upper_dev))
+			return -EINVAL;
+		break;
+	case NETDEV_CHANGEUPPER:
+		if (netif_is_l3_master(info->upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_bridge_vrf_join(mlxsw_sp,
+							       vlan_dev);
+			else
+				mlxsw_sp_bridge_vrf_leave(mlxsw_sp, vlan_dev);
+		} else {
+			err = -EINVAL;
+			WARN_ON(1);
+		}
+		break;
+	}
+
+	return err;
+}
+
 static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 					 unsigned long event, void *ptr)
 {
@@ -4427,6 +4474,9 @@ static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
 	else if (netif_is_lag_master(real_dev))
 		return mlxsw_sp_netdevice_lag_vport_event(real_dev, event, ptr,
 							  vid);
+	else if (netif_is_bridge_master(real_dev))
+		return mlxsw_sp_netdevice_bridge_vlan_event(vlan_dev, event,
+							    ptr);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 60004d9..0e223f6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -582,6 +582,10 @@ int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport);
 void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
 int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port);
 void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port);
+int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
+			     struct net_device *l3_dev);
+void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
+			       struct net_device *l3_dev);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e262688..c89f4b4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3267,6 +3267,32 @@ void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_sp_vport_vrf_leave(mlxsw_sp_vport);
 }
 
+int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
+			     struct net_device *l3_dev)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
+	if (WARN_ON(!f))
+		return -EINVAL;
+
+	if (f->r)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+
+	return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
+}
+
+void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
+			       struct net_device *l3_dev)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
+	if (WARN_ON(!f))
+		return;
+	mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+}
+
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
 	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
-- 
2.7.4
