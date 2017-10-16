From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Support IPIP overlay VRF migration
Date: Mon, 16 Oct 2017 16:26:38 +0200
Message-ID: <20171016142639.2453-5-jiri@resnulli.us>
References: <20171016142639.2453-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:57006 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753208AbdJPO0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:26:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id l68so3893577wmd.5
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:26:45 -0700 (PDT)
In-Reply-To: <20171016142639.2453-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

IPIP entries are created as soon as an offloadable device is created.
That means that when such a device is later moved to a different VRF,
the loopback device that backs the tunnel is wrong.

Thus when an offloadable encapsulating netdevice moves from one VRF to
another, make sure that the loopback is updated as necessary.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 47 +++++++++++++++++++++-
 3 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c3ae650..e1e11c7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4506,7 +4506,7 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *nb,
 
 	mlxsw_sp = container_of(nb, struct mlxsw_sp, netdevice_nb);
 	if (mlxsw_sp_netdev_is_ipip(mlxsw_sp, dev))
-		err = mlxsw_sp_netdevice_ipip_event(mlxsw_sp, dev, event);
+		err = mlxsw_sp_netdevice_ipip_event(mlxsw_sp, dev, event, ptr);
 	else if (event == NETDEV_CHANGEADDR || event == NETDEV_CHANGEMTU)
 		err = mlxsw_sp_netdevice_router_port_event(dev);
 	else if (mlxsw_sp_is_vrf_event(event, ptr))
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index a4f21af..28feb74 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -400,7 +400,8 @@ bool mlxsw_sp_netdev_is_ipip(const struct mlxsw_sp *mlxsw_sp,
 int
 mlxsw_sp_netdevice_ipip_event(struct mlxsw_sp *mlxsw_sp,
 			      struct net_device *l3_dev,
-			      unsigned long event);
+			      unsigned long event,
+			      struct netdev_notifier_changeupper_info *info);
 void
 mlxsw_sp_port_vlan_router_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index db83422..082cf00 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1384,9 +1384,49 @@ static void mlxsw_sp_netdevice_ipip_down_event(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_ipip_entry_demote_decap(mlxsw_sp, ipip_entry);
 }
 
+static int mlxsw_sp_netdevice_ipip_vrf_event(struct mlxsw_sp *mlxsw_sp,
+					     struct net_device *ol_dev)
+{
+	struct mlxsw_sp_fib_entry *decap_fib_entry;
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+	struct mlxsw_sp_rif_ipip_lb *lb_rif;
+
+	ipip_entry = mlxsw_sp_ipip_entry_find_by_ol_dev(mlxsw_sp, ol_dev);
+	if (!ipip_entry)
+		return 0;
+
+	/* When a tunneling device is moved to a different VRF, we need to
+	 * update the backing loopback. Since RIFs can't be edited, we need to
+	 * destroy and recreate it. That might create a window of opportunity
+	 * where RALUE and RATR registers end up referencing a RIF that's
+	 * already gone. RATRs are handled by the RIF destroy, and to take care
+	 * of RALUE, demote the decap route back.
+	 */
+	if (ipip_entry->decap_fib_entry)
+		mlxsw_sp_ipip_entry_demote_decap(mlxsw_sp, ipip_entry);
+
+	lb_rif = mlxsw_sp_ipip_ol_ipip_lb_create(mlxsw_sp, ipip_entry->ipipt,
+						 ol_dev);
+	if (IS_ERR(lb_rif))
+		return PTR_ERR(lb_rif);
+	mlxsw_sp_rif_destroy(&ipip_entry->ol_lb->common);
+	ipip_entry->ol_lb = lb_rif;
+
+	if (ol_dev->flags & IFF_UP) {
+		decap_fib_entry = mlxsw_sp_ipip_entry_find_decap(mlxsw_sp,
+								 ipip_entry);
+		if (decap_fib_entry)
+			mlxsw_sp_ipip_entry_promote_decap(mlxsw_sp, ipip_entry,
+							  decap_fib_entry);
+	}
+
+	return 0;
+}
+
 int mlxsw_sp_netdevice_ipip_event(struct mlxsw_sp *mlxsw_sp,
 				  struct net_device *ol_dev,
-				  unsigned long event)
+				  unsigned long event,
+				  struct netdev_notifier_changeupper_info *info)
 {
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -1399,6 +1439,11 @@ int mlxsw_sp_netdevice_ipip_event(struct mlxsw_sp *mlxsw_sp,
 	case NETDEV_DOWN:
 		mlxsw_sp_netdevice_ipip_down_event(mlxsw_sp, ol_dev);
 		return 0;
+	case NETDEV_CHANGEUPPER:
+		if (netif_is_l3_master(info->upper_dev))
+			return mlxsw_sp_netdevice_ipip_vrf_event(mlxsw_sp,
+								 ol_dev);
+		return 0;
 	}
 	return 0;
 }
-- 
2.9.5
