From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/10] mlxsw: spectrum_router: Add support for VRFs
Date: Mon, 13 Mar 2017 08:38:31 +0100
Message-ID: <1489390713-2634-8-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33093 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751733AbdCMHio (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:44 -0400
Received: by mail-wr0-f194.google.com with SMTP id g10so18938777wrg.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:43 -0700 (PDT)
In-Reply-To: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow port netdevs, LAG and VLAN devices stacked on top of these to be
enslaved to a VRF master device.

Upon enslavement, create a router interface (RIF) for the enslaved
netdev and associate it with a virtual router (VR) based on the VRF's
table ID.

If a RIF already exists for the netdev (f.e., due to the existence of an
IP address), then it's deleted and a new one is created with the
appropriate VR binding.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 19 ++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 41 ++++++++++++++++++++++
 3 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 475499b..29d8082 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3951,7 +3951,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 		upper_dev = info->upper_dev;
 		if (!is_vlan_dev(upper_dev) &&
 		    !netif_is_lag_master(upper_dev) &&
-		    !netif_is_bridge_master(upper_dev))
+		    !netif_is_bridge_master(upper_dev) &&
+		    !netif_is_vrf_master(upper_dev))
 			return -EINVAL;
 		if (!info->linking)
 			break;
@@ -3991,6 +3992,11 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 			else
 				mlxsw_sp_port_lag_leave(mlxsw_sp_port,
 							upper_dev);
+		} else if (netif_is_vrf_master(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_port_vrf_join(mlxsw_sp_port);
+			else
+				mlxsw_sp_port_vrf_leave(mlxsw_sp_port);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -4353,14 +4359,16 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!netif_is_bridge_master(upper_dev))
+		if (!netif_is_bridge_master(upper_dev) &&
+		    !netif_is_vrf_master(upper_dev))
 			return -EINVAL;
 		if (!info->linking)
 			break;
 		/* We can't have multiple VLAN interfaces configured on
 		 * the same port and being members in the same bridge.
 		 */
-		if (!mlxsw_sp_port_master_bridge_check(mlxsw_sp_port,
+		if (netif_is_bridge_master(upper_dev) &&
+		    !mlxsw_sp_port_master_bridge_check(mlxsw_sp_port,
 						       upper_dev))
 			return -EINVAL;
 		break;
@@ -4372,6 +4380,11 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 								 upper_dev);
 			else
 				mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
+		} else if (netif_is_vrf_master(upper_dev)) {
+			if (info->linking)
+				err = mlxsw_sp_vport_vrf_join(mlxsw_sp_vport);
+			else
+				mlxsw_sp_vport_vrf_leave(mlxsw_sp_vport);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5502232..60004d9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -578,6 +578,10 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr);
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_rif *r);
+int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport);
+void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port);
+void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 64f0dc7..cbb0362 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3224,6 +3224,47 @@ int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
 	return err;
 }
 
+int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+	struct net_device *dev = mlxsw_sp_vport->dev;
+
+	/* In case vPort already has a RIF, then we need to drop it.
+	 * A new one will be created using the VRF's VR.
+	 */
+	if (f && f->r)
+		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
+
+	return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, dev);
+}
+
+void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
+}
+
+int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
+	if (WARN_ON(!mlxsw_sp_vport))
+		return -EINVAL;
+
+	return mlxsw_sp_vport_vrf_join(mlxsw_sp_vport);
+}
+
+void mlxsw_sp_port_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
+	if (WARN_ON(!mlxsw_sp_vport))
+		return;
+
+	mlxsw_sp_vport_vrf_leave(mlxsw_sp_vport);
+}
+
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
 	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
-- 
2.7.4
