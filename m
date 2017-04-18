From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum: Allow ports to work under OVS master
Date: Tue, 18 Apr 2017 16:55:37 +0200
Message-ID: <1492527338-13298-8-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34853 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755704AbdDROzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:51 -0400
Received: by mail-wr0-f193.google.com with SMTP id l44so25146605wrc.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:50 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

>From now on, a port can become a slave of OVS master. All vlans
are enabled, STP state is set to "forwarding". It is up to the OVS
userspace daemon to setup the flows either in kernel or in HW using TC
flower offload.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 62 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  4 +-
 2 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 77b5bb3..f1c1b01 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4036,6 +4036,56 @@ static void mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
 }
 
+static int mlxsw_sp_port_stp_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				 bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	enum mlxsw_reg_spms_state spms_state;
+	char *spms_pl;
+	u16 vid;
+	int err;
+
+	spms_state = enable ? MLXSW_REG_SPMS_STATE_FORWARDING :
+			      MLXSW_REG_SPMS_STATE_DISCARDING;
+
+	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
+	if (!spms_pl)
+		return -ENOMEM;
+	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
+
+	for (vid = 0; vid < VLAN_N_VID; vid++)
+		mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
+
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
+	kfree(spms_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_ovs_join(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int err;
+
+	err = mlxsw_sp_port_stp_set(mlxsw_sp_port, true);
+	if (err)
+		return err;
+	err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, 2, VLAN_N_VID - 1,
+				     true, false);
+	if (err)
+		goto err_port_vlan_set;
+	return 0;
+
+err_port_vlan_set:
+	mlxsw_sp_port_stp_set(mlxsw_sp_port, false);
+	return err;
+}
+
+static void mlxsw_sp_port_ovs_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port_vlan_set(mlxsw_sp_port, 2, VLAN_N_VID - 1,
+			       false, false);
+	mlxsw_sp_port_stp_set(mlxsw_sp_port, false);
+}
+
 static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 					       unsigned long event, void *ptr)
 {
@@ -4055,7 +4105,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		if (!is_vlan_dev(upper_dev) &&
 		    !netif_is_lag_master(upper_dev) &&
 		    !netif_is_bridge_master(upper_dev) &&
-		    !netif_is_l3_master(upper_dev))
+		    !netif_is_l3_master(upper_dev) &&
+		    !netif_is_ovs_master(upper_dev))
 			return -EINVAL;
 		if (!info->linking)
 			break;
@@ -4072,6 +4123,10 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		if (netif_is_lag_port(dev) && is_vlan_dev(upper_dev) &&
 		    !netif_is_lag_master(vlan_dev_real_dev(upper_dev)))
 			return -EINVAL;
+		if (netif_is_ovs_master(upper_dev) && vlan_uses_dev(dev))
+			return -EINVAL;
+		if (netif_is_ovs_port(dev) && is_vlan_dev(upper_dev))
+			return -EINVAL;
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
@@ -4100,6 +4155,11 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				err = mlxsw_sp_port_vrf_join(mlxsw_sp_port);
 			else
 				mlxsw_sp_port_vrf_leave(mlxsw_sp_port);
+		} else if (netif_is_ovs_master(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_port_ovs_join(mlxsw_sp_port);
+			else
+				mlxsw_sp_port_ovs_leave(mlxsw_sp_port);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c70c591..146f8c7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3098,7 +3098,9 @@ static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
 static int mlxsw_sp_inetaddr_port_event(struct net_device *port_dev,
 					unsigned long event)
 {
-	if (netif_is_bridge_port(port_dev) || netif_is_lag_port(port_dev))
+	if (netif_is_bridge_port(port_dev) ||
+	    netif_is_lag_port(port_dev) ||
+	    netif_is_ovs_port(port_dev))
 		return 0;
 
 	return mlxsw_sp_inetaddr_vport_event(port_dev, port_dev, event, 1);
-- 
2.7.4
