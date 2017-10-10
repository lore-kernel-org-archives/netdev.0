From: David Ahern <dsahern@gmail.com>
Subject: [RFC net-next 4/4] mlxsw: spectrum_router: Add extack message for RIF and VRF overflow
Date: Tue, 10 Oct 2017 09:41:05 -0700
Message-ID: <1507653665-20540-5-git-send-email-dsahern@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35101 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932449AbdJJQlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:41:14 -0400
Received: by mail-pf0-f196.google.com with SMTP id i23so36901962pfi.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:41:14 -0700 (PDT)
In-Reply-To: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack argument down to mlxsw_sp_rif_create and mlxsw_sp_vr_create
to set an error message on RIF or VR overflow. Now an overflow of
either resource the use gets an informative message as opposed to
failing with EBUSY.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 114 +++++++++++++--------
 1 file changed, 69 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7d53fdf2c0a8..ec4d313b9eca 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -731,14 +731,17 @@ static struct mlxsw_sp_fib *mlxsw_sp_vr_fib(const struct mlxsw_sp_vr *vr,
 }
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
-					      u32 tb_id)
+					      u32 tb_id,
+					      struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_vr *vr;
 	int err;
 
 	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
-	if (!vr)
+	if (!vr) {
+		NL_SET_ERR_MSG(extack, "spectrum: Exceeded number of supported VRF");
 		return ERR_PTR(-EBUSY);
+	}
 	vr->fib4 = mlxsw_sp_fib_create(vr, MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(vr->fib4))
 		return ERR_CAST(vr->fib4);
@@ -775,14 +778,15 @@ static void mlxsw_sp_vr_destroy(struct mlxsw_sp_vr *vr)
 	vr->fib4 = NULL;
 }
 
-static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id)
+static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id,
+					   struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_vr *vr;
 
 	tb_id = mlxsw_sp_fix_tb_id(tb_id);
 	vr = mlxsw_sp_vr_find(mlxsw_sp, tb_id);
 	if (!vr)
-		vr = mlxsw_sp_vr_create(mlxsw_sp, tb_id);
+		vr = mlxsw_sp_vr_create(mlxsw_sp, tb_id, extack);
 	return vr;
 }
 
@@ -948,7 +952,8 @@ static u32 mlxsw_sp_ipip_dev_ul_tb_id(const struct net_device *ol_dev)
 
 static struct mlxsw_sp_rif *
 mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
-		    const struct mlxsw_sp_rif_params *params);
+		    const struct mlxsw_sp_rif_params *params,
+		    struct netlink_ext_ack *extack);
 
 static struct mlxsw_sp_rif_ipip_lb *
 mlxsw_sp_ipip_ol_ipip_lb_create(struct mlxsw_sp *mlxsw_sp,
@@ -966,7 +971,7 @@ mlxsw_sp_ipip_ol_ipip_lb_create(struct mlxsw_sp *mlxsw_sp,
 		.lb_config = ipip_ops->ol_loopback_config(mlxsw_sp, ol_dev),
 	};
 
-	rif = mlxsw_sp_rif_create(mlxsw_sp, &lb_params.common);
+	rif = mlxsw_sp_rif_create(mlxsw_sp, &lb_params.common, NULL);
 	if (IS_ERR(rif))
 		return ERR_CAST(rif);
 	return container_of(rif, struct mlxsw_sp_rif_ipip_lb, common);
@@ -3711,7 +3716,7 @@ mlxsw_sp_fib_node_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id, const void *addr,
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id, NULL);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 	fib = mlxsw_sp_vr_fib(vr, proto);
@@ -4750,7 +4755,7 @@ static int mlxsw_sp_router_fibmr_add(struct mlxsw_sp *mlxsw_sp,
 	if (mlxsw_sp->router->aborted)
 		return 0;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, men_info->tb_id);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, men_info->tb_id, NULL);
 	if (IS_ERR(vr))
 		return PTR_ERR(vr);
 
@@ -4783,7 +4788,7 @@ mlxsw_sp_router_fibmr_vif_add(struct mlxsw_sp *mlxsw_sp,
 	if (mlxsw_sp->router->aborted)
 		return 0;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, ven_info->tb_id);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, ven_info->tb_id, NULL);
 	if (IS_ERR(vr))
 		return PTR_ERR(vr);
 
@@ -5346,7 +5351,8 @@ const struct net_device *mlxsw_sp_rif_dev(const struct mlxsw_sp_rif *rif)
 
 static struct mlxsw_sp_rif *
 mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
-		    const struct mlxsw_sp_rif_params *params)
+		    const struct mlxsw_sp_rif_params *params,
+		    struct netlink_ext_ack *extack)
 {
 	u32 tb_id = l3mdev_fib_table(params->dev);
 	const struct mlxsw_sp_rif_ops *ops;
@@ -5360,14 +5366,16 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	type = mlxsw_sp_dev_rif_type(mlxsw_sp, params->dev);
 	ops = mlxsw_sp->router->rif_ops_arr[type];
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN, extack);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 	vr->rif_count++;
 
 	err = mlxsw_sp_rif_index_alloc(mlxsw_sp, &rif_index);
-	if (err)
+	if (err) {
+		NL_SET_ERR_MSG(extack, "spectrum: Exceeded number of supported router interfaces");
 		goto err_rif_index_alloc;
+	}
 
 	rif = mlxsw_sp_rif_alloc(ops->rif_size, rif_index, vr->id, params->dev);
 	if (!rif) {
@@ -5454,7 +5462,8 @@ mlxsw_sp_rif_subport_params_init(struct mlxsw_sp_rif_params *params,
 
 static int
 mlxsw_sp_port_vlan_router_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
-			       struct net_device *l3_dev)
+			       struct net_device *l3_dev,
+			       struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
@@ -5470,7 +5479,7 @@ mlxsw_sp_port_vlan_router_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 		};
 
 		mlxsw_sp_rif_subport_params_init(&params, mlxsw_sp_port_vlan);
-		rif = mlxsw_sp_rif_create(mlxsw_sp, &params);
+		rif = mlxsw_sp_rif_create(mlxsw_sp, &params, extack);
 		if (IS_ERR(rif))
 			return PTR_ERR(rif);
 	}
@@ -5525,7 +5534,8 @@ mlxsw_sp_port_vlan_router_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 
 static int mlxsw_sp_inetaddr_port_vlan_event(struct net_device *l3_dev,
 					     struct net_device *port_dev,
-					     unsigned long event, u16 vid)
+					     unsigned long event, u16 vid,
+					     struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(port_dev);
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
@@ -5537,7 +5547,7 @@ static int mlxsw_sp_inetaddr_port_vlan_event(struct net_device *l3_dev,
 	switch (event) {
 	case NETDEV_UP:
 		return mlxsw_sp_port_vlan_router_join(mlxsw_sp_port_vlan,
-						      l3_dev);
+						      l3_dev, extack);
 	case NETDEV_DOWN:
 		mlxsw_sp_port_vlan_router_leave(mlxsw_sp_port_vlan);
 		break;
@@ -5547,19 +5557,22 @@ static int mlxsw_sp_inetaddr_port_vlan_event(struct net_device *l3_dev,
 }
 
 static int mlxsw_sp_inetaddr_port_event(struct net_device *port_dev,
-					unsigned long event)
+					unsigned long event,
+					struct netlink_ext_ack *extack)
 {
 	if (netif_is_bridge_port(port_dev) ||
 	    netif_is_lag_port(port_dev) ||
 	    netif_is_ovs_port(port_dev))
 		return 0;
 
-	return mlxsw_sp_inetaddr_port_vlan_event(port_dev, port_dev, event, 1);
+	return mlxsw_sp_inetaddr_port_vlan_event(port_dev, port_dev, event, 1,
+						 extack);
 }
 
 static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
 					 struct net_device *lag_dev,
-					 unsigned long event, u16 vid)
+					 unsigned long event, u16 vid,
+					 struct netlink_ext_ack *extack)
 {
 	struct net_device *port_dev;
 	struct list_head *iter;
@@ -5569,7 +5582,8 @@ static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
 		if (mlxsw_sp_port_dev_check(port_dev)) {
 			err = mlxsw_sp_inetaddr_port_vlan_event(l3_dev,
 								port_dev,
-								event, vid);
+								event, vid,
+								extack);
 			if (err)
 				return err;
 		}
@@ -5579,16 +5593,19 @@ static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
 }
 
 static int mlxsw_sp_inetaddr_lag_event(struct net_device *lag_dev,
-				       unsigned long event)
+				       unsigned long event,
+				       struct netlink_ext_ack *extack)
 {
 	if (netif_is_bridge_port(lag_dev))
 		return 0;
 
-	return __mlxsw_sp_inetaddr_lag_event(lag_dev, lag_dev, event, 1);
+	return __mlxsw_sp_inetaddr_lag_event(lag_dev, lag_dev, event, 1,
+					     extack);
 }
 
 static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
-					  unsigned long event)
+					  unsigned long event,
+					  struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(l3_dev);
 	struct mlxsw_sp_rif_params params = {
@@ -5598,7 +5615,7 @@ static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
 
 	switch (event) {
 	case NETDEV_UP:
-		rif = mlxsw_sp_rif_create(mlxsw_sp, &params);
+		rif = mlxsw_sp_rif_create(mlxsw_sp, &params, extack);
 		if (IS_ERR(rif))
 			return PTR_ERR(rif);
 		break;
@@ -5612,7 +5629,8 @@ static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
 }
 
 static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
-					unsigned long event)
+					unsigned long event,
+					struct netlink_ext_ack *extack)
 {
 	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
@@ -5622,27 +5640,28 @@ static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 
 	if (mlxsw_sp_port_dev_check(real_dev))
 		return mlxsw_sp_inetaddr_port_vlan_event(vlan_dev, real_dev,
-							 event, vid);
+							 event, vid, extack);
 	else if (netif_is_lag_master(real_dev))
 		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
-						     vid);
+						     vid, extack);
 	else if (netif_is_bridge_master(real_dev) && br_vlan_enabled(real_dev))
-		return mlxsw_sp_inetaddr_bridge_event(vlan_dev, event);
+		return mlxsw_sp_inetaddr_bridge_event(vlan_dev, event, extack);
 
 	return 0;
 }
 
 static int __mlxsw_sp_inetaddr_event(struct net_device *dev,
-				     unsigned long event)
+				     unsigned long event,
+				     struct netlink_ext_ack *extack)
 {
 	if (mlxsw_sp_port_dev_check(dev))
-		return mlxsw_sp_inetaddr_port_event(dev, event);
+		return mlxsw_sp_inetaddr_port_event(dev, event, extack);
 	else if (netif_is_lag_master(dev))
-		return mlxsw_sp_inetaddr_lag_event(dev, event);
+		return mlxsw_sp_inetaddr_lag_event(dev, event, extack);
 	else if (netif_is_bridge_master(dev))
-		return mlxsw_sp_inetaddr_bridge_event(dev, event);
+		return mlxsw_sp_inetaddr_bridge_event(dev, event, extack);
 	else if (is_vlan_dev(dev))
-		return mlxsw_sp_inetaddr_vlan_event(dev, event);
+		return mlxsw_sp_inetaddr_vlan_event(dev, event, extack);
 	else
 		return 0;
 }
@@ -5668,7 +5687,7 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	if (!mlxsw_sp_rif_should_config(rif, dev, event))
 		goto out;
 
-	err = __mlxsw_sp_inetaddr_event(dev, event);
+	err = __mlxsw_sp_inetaddr_event(dev, event, NULL);
 out:
 	return notifier_from_errno(err);
 }
@@ -5691,7 +5710,7 @@ int mlxsw_sp_inetaddr_valid_event(struct notifier_block *unused,
 	if (!mlxsw_sp_rif_should_config(rif, dev, event))
 		goto out;
 
-	err = __mlxsw_sp_inetaddr_event(dev, event);
+	err = __mlxsw_sp_inetaddr_event(dev, event, ivi->extack);
 out:
 	return notifier_from_errno(err);
 }
@@ -5720,7 +5739,7 @@ static void mlxsw_sp_inet6addr_event_work(struct work_struct *work)
 	if (!mlxsw_sp_rif_should_config(rif, dev, event))
 		goto out;
 
-	__mlxsw_sp_inetaddr_event(dev, event);
+	__mlxsw_sp_inetaddr_event(dev, event, NULL);
 out:
 	rtnl_unlock();
 	dev_put(dev);
@@ -5772,7 +5791,7 @@ int mlxsw_sp_inet6addr_valid_event(struct notifier_block *unused,
 	if (!mlxsw_sp_rif_should_config(rif, dev, event))
 		goto out;
 
-	err = __mlxsw_sp_inetaddr_event(dev, event);
+	err = __mlxsw_sp_inetaddr_event(dev, event, i6vi->extack);
 out:
 	return notifier_from_errno(err);
 }
@@ -5849,7 +5868,8 @@ int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
 }
 
 static int mlxsw_sp_port_vrf_join(struct mlxsw_sp *mlxsw_sp,
-				  struct net_device *l3_dev)
+				  struct net_device *l3_dev,
+				  struct netlink_ext_ack *extack)
 {
 	struct mlxsw_sp_rif *rif;
 
@@ -5858,9 +5878,9 @@ static int mlxsw_sp_port_vrf_join(struct mlxsw_sp *mlxsw_sp,
 	 */
 	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
 	if (rif)
-		__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN);
+		__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN, extack);
 
-	return __mlxsw_sp_inetaddr_event(l3_dev, NETDEV_UP);
+	return __mlxsw_sp_inetaddr_event(l3_dev, NETDEV_UP, extack);
 }
 
 static void mlxsw_sp_port_vrf_leave(struct mlxsw_sp *mlxsw_sp,
@@ -5871,7 +5891,7 @@ static void mlxsw_sp_port_vrf_leave(struct mlxsw_sp *mlxsw_sp,
 	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
 	if (!rif)
 		return;
-	__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN);
+	__mlxsw_sp_inetaddr_event(l3_dev, NETDEV_DOWN, NULL);
 }
 
 int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
@@ -5887,10 +5907,14 @@ int mlxsw_sp_netdevice_vrf_event(struct net_device *l3_dev, unsigned long event,
 	case NETDEV_PRECHANGEUPPER:
 		return 0;
 	case NETDEV_CHANGEUPPER:
-		if (info->linking)
-			err = mlxsw_sp_port_vrf_join(mlxsw_sp, l3_dev);
-		else
+		if (info->linking) {
+			struct netlink_ext_ack *extack;
+
+			extack = netdev_notifier_info_to_extack(&info->info);
+			err = mlxsw_sp_port_vrf_join(mlxsw_sp, l3_dev, extack);
+		} else {
 			mlxsw_sp_port_vrf_leave(mlxsw_sp, l3_dev);
+		}
 		break;
 	}
 
@@ -6197,7 +6221,7 @@ mlxsw_sp_rif_ipip_lb_configure(struct mlxsw_sp_rif *rif)
 	struct mlxsw_sp_vr *ul_vr;
 	int err;
 
-	ul_vr = mlxsw_sp_vr_get(mlxsw_sp, ul_tb_id);
+	ul_vr = mlxsw_sp_vr_get(mlxsw_sp, ul_tb_id, NULL);
 	if (IS_ERR(ul_vr))
 		return PTR_ERR(ul_vr);
 
-- 
2.1.4
