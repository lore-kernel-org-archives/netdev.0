From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum: Support decap-only IP-in-IP tunnels
Date: Mon, 16 Oct 2017 16:26:37 +0200
Message-ID: <20171016142639.2453-4-jiri@resnulli.us>
References: <20171016142639.2453-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:45158 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753205AbdJPO0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:26:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id q124so3945060wmb.0
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:26:44 -0700 (PDT)
In-Reply-To: <20171016142639.2453-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Current code for offloading IP-in-IP tunneling assumes that there is no
decap without encap. But that's never true for IPv6 overlays, and is not
true for IPv4 ones either, if net.ipv4.conf.*.rp_filter is unset.

To support decap-only tunnels, an IPIP entry is now created as soon as
an offloadable tunneling device is created. When that netdevice is up'd,
a decap route is looked up and possibly offloaded. Thus decap is not
handled implicitly as part of mlxsw_sp_ipip_entry_get() call anymore,
but needs to be done explicitly after the get, if desired.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   8 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   6 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 105 +++++++++++++++++++--
 3 files changed, 109 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 83f9c25..c3ae650 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4497,13 +4497,17 @@ static bool mlxsw_sp_is_vrf_event(unsigned long event, void *ptr)
 	return netif_is_l3_master(info->upper_dev);
 }
 
-static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
+static int mlxsw_sp_netdevice_event(struct notifier_block *nb,
 				    unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct mlxsw_sp *mlxsw_sp;
 	int err = 0;
 
-	if (event == NETDEV_CHANGEADDR || event == NETDEV_CHANGEMTU)
+	mlxsw_sp = container_of(nb, struct mlxsw_sp, netdevice_nb);
+	if (mlxsw_sp_netdev_is_ipip(mlxsw_sp, dev))
+		err = mlxsw_sp_netdevice_ipip_event(mlxsw_sp, dev, event);
+	else if (event == NETDEV_CHANGEADDR || event == NETDEV_CHANGEMTU)
 		err = mlxsw_sp_netdevice_router_port_event(dev);
 	else if (mlxsw_sp_is_vrf_event(event, ptr))
 		err = mlxsw_sp_netdevice_vrf_event(dev, event, ptr);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index e1a0157..a4f21af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -395,6 +395,12 @@ int mlxsw_sp_inet6addr_event(struct notifier_block *unused,
 			     unsigned long event, void *ptr);
 int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 				 struct netdev_notifier_changeupper_info *info);
+bool mlxsw_sp_netdev_is_ipip(const struct mlxsw_sp *mlxsw_sp,
+			     const struct net_device *dev);
+int
+mlxsw_sp_netdevice_ipip_event(struct mlxsw_sp *mlxsw_sp,
+			      struct net_device *l3_dev,
+			      unsigned long event);
 void
 mlxsw_sp_port_vlan_router_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c5e574b..db83422 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1206,7 +1206,6 @@ mlxsw_sp_ipip_entry_get(struct mlxsw_sp *mlxsw_sp,
 {
 	u32 ul_tb_id = mlxsw_sp_ipip_dev_ul_tb_id(ol_dev);
 	struct mlxsw_sp_router *router = mlxsw_sp->router;
-	struct mlxsw_sp_fib_entry *decap_fib_entry;
 	struct mlxsw_sp_ipip_entry *ipip_entry;
 	enum mlxsw_sp_l3proto ul_proto;
 	union mlxsw_sp_l3addr saddr;
@@ -1231,11 +1230,6 @@ mlxsw_sp_ipip_entry_get(struct mlxsw_sp *mlxsw_sp,
 	if (IS_ERR(ipip_entry))
 		return ipip_entry;
 
-	decap_fib_entry = mlxsw_sp_ipip_entry_find_decap(mlxsw_sp, ipip_entry);
-	if (decap_fib_entry)
-		mlxsw_sp_ipip_entry_promote_decap(mlxsw_sp, ipip_entry,
-						  decap_fib_entry);
-
 	list_add_tail(&ipip_entry->ipip_list_node,
 		      &mlxsw_sp->router->ipip_list);
 
@@ -1250,8 +1244,6 @@ mlxsw_sp_ipip_entry_put(struct mlxsw_sp *mlxsw_sp,
 {
 	if (--ipip_entry->ref_count == 0) {
 		list_del(&ipip_entry->ipip_list_node);
-		if (ipip_entry->decap_fib_entry)
-			mlxsw_sp_ipip_entry_demote_decap(mlxsw_sp, ipip_entry);
 		mlxsw_sp_ipip_entry_destroy(ipip_entry);
 	}
 }
@@ -1314,6 +1306,103 @@ static bool mlxsw_sp_netdev_ipip_type(const struct mlxsw_sp *mlxsw_sp,
 	return false;
 }
 
+bool mlxsw_sp_netdev_is_ipip(const struct mlxsw_sp *mlxsw_sp,
+			     const struct net_device *dev)
+{
+	return mlxsw_sp_netdev_ipip_type(mlxsw_sp, dev, NULL);
+}
+
+static struct mlxsw_sp_ipip_entry *
+mlxsw_sp_ipip_entry_find_by_ol_dev(struct mlxsw_sp *mlxsw_sp,
+				   const struct net_device *ol_dev)
+{
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+
+	list_for_each_entry(ipip_entry, &mlxsw_sp->router->ipip_list,
+			    ipip_list_node)
+		if (ipip_entry->ol_dev == ol_dev)
+			return ipip_entry;
+
+	return NULL;
+}
+
+static int mlxsw_sp_netdevice_ipip_reg_event(struct mlxsw_sp *mlxsw_sp,
+					     struct net_device *ol_dev)
+{
+	struct mlxsw_sp_router *router = mlxsw_sp->router;
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+	enum mlxsw_sp_ipip_type ipipt;
+
+	mlxsw_sp_netdev_ipip_type(mlxsw_sp, ol_dev, &ipipt);
+	if (router->ipip_ops_arr[ipipt]->can_offload(mlxsw_sp, ol_dev,
+						     MLXSW_SP_L3_PROTO_IPV4) ||
+	    router->ipip_ops_arr[ipipt]->can_offload(mlxsw_sp, ol_dev,
+						     MLXSW_SP_L3_PROTO_IPV6)) {
+		ipip_entry = mlxsw_sp_ipip_entry_get(mlxsw_sp, ipipt, ol_dev);
+		if (IS_ERR(ipip_entry))
+			return PTR_ERR(ipip_entry);
+	}
+
+	return 0;
+}
+
+static void mlxsw_sp_netdevice_ipip_unreg_event(struct mlxsw_sp *mlxsw_sp,
+						struct net_device *ol_dev)
+{
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+
+	ipip_entry = mlxsw_sp_ipip_entry_find_by_ol_dev(mlxsw_sp, ol_dev);
+	if (ipip_entry)
+		mlxsw_sp_ipip_entry_put(mlxsw_sp, ipip_entry);
+}
+
+static int mlxsw_sp_netdevice_ipip_up_event(struct mlxsw_sp *mlxsw_sp,
+					    struct net_device *ol_dev)
+{
+	struct mlxsw_sp_fib_entry *decap_fib_entry;
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+
+	ipip_entry = mlxsw_sp_ipip_entry_find_by_ol_dev(mlxsw_sp, ol_dev);
+	if (ipip_entry) {
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
+static void mlxsw_sp_netdevice_ipip_down_event(struct mlxsw_sp *mlxsw_sp,
+					       struct net_device *ol_dev)
+{
+	struct mlxsw_sp_ipip_entry *ipip_entry;
+
+	ipip_entry = mlxsw_sp_ipip_entry_find_by_ol_dev(mlxsw_sp, ol_dev);
+	if (ipip_entry && ipip_entry->decap_fib_entry)
+		mlxsw_sp_ipip_entry_demote_decap(mlxsw_sp, ipip_entry);
+}
+
+int mlxsw_sp_netdevice_ipip_event(struct mlxsw_sp *mlxsw_sp,
+				  struct net_device *ol_dev,
+				  unsigned long event)
+{
+	switch (event) {
+	case NETDEV_REGISTER:
+		return mlxsw_sp_netdevice_ipip_reg_event(mlxsw_sp, ol_dev);
+	case NETDEV_UNREGISTER:
+		mlxsw_sp_netdevice_ipip_unreg_event(mlxsw_sp, ol_dev);
+		return 0;
+	case NETDEV_UP:
+		return mlxsw_sp_netdevice_ipip_up_event(mlxsw_sp, ol_dev);
+	case NETDEV_DOWN:
+		mlxsw_sp_netdevice_ipip_down_event(mlxsw_sp, ol_dev);
+		return 0;
+	}
+	return 0;
+}
+
 struct mlxsw_sp_neigh_key {
 	struct neighbour *n;
 };
-- 
2.9.5
