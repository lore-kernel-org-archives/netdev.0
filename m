From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/18] mlxsw: spectrum_router: Replace vPorts with Port-VLAN
Date: Fri, 26 May 2017 08:37:28 +0200
Message-ID: <20170526063740.8909-7-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35368 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937244AbdEZGhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:52 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so1683936wmc.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:51 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're going to get rid of vPorts completely later in the patchset, but
the router code is self-contained, so it's a good candidate to start the
transition with.

Convert all the functions that expects to operate on a vPort to operate
on a Port-VLAN instead.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   4 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 137 ++++++++++-----------
 2 files changed, 67 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index acc3a1a..e04d2ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1499,6 +1499,10 @@ mlxsw_sp_port_vlan_create(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 static void
 mlxsw_sp_port_vlan_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 {
+	struct mlxsw_sp_fid *fid = mlxsw_sp_port_vlan->fid;
+
+	if (fid && !WARN_ON(!fid->leave))
+		fid->leave(mlxsw_sp_port_vlan);
 	list_del(&mlxsw_sp_port_vlan->list);
 	kfree(mlxsw_sp_port_vlan);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 6a1de24..ef8e8a1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2917,30 +2917,23 @@ static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 	return MLXSW_SP_INVALID_INDEX_RIF;
 }
 
-static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
-					   bool *p_lagged, u16 *p_system_port)
-{
-	u8 local_port = mlxsw_sp_vport->local_port;
-
-	*p_lagged = mlxsw_sp_vport->lagged;
-	*p_system_port = *p_lagged ? mlxsw_sp_vport->lag_id : local_port;
-}
-
-static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
-				    u16 vr_id, struct net_device *l3_dev,
-				    u16 rif_index, bool create)
+static int
+mlxsw_sp_port_vlan_rif_sp_op(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
+			     u16 vr_id, struct net_device *l3_dev,
+			     u16 rif_index, bool create)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	bool lagged = mlxsw_sp_vport->lagged;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	bool lagged = mlxsw_sp_port->lagged;
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 	u16 system_port;
 
+	system_port = lagged ? mlxsw_sp_port->lag_id :
+			       mlxsw_sp_port->local_port;
 	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif_index,
 			    vr_id, l3_dev->mtu, l3_dev->dev_addr);
-
-	mlxsw_sp_vport_rif_sp_attr_get(mlxsw_sp_vport, &lagged, &system_port);
 	mlxsw_reg_ritr_sp_if_pack(ritr_pl, lagged, system_port,
-				  mlxsw_sp_vport_vid_get(mlxsw_sp_vport));
+				  mlxsw_sp_port_vlan->vid);
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 }
@@ -3009,10 +3002,11 @@ int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif)
 }
 
 static struct mlxsw_sp_rif *
-mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
-			     struct net_device *l3_dev)
+mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
+				 struct net_device *l3_dev)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u32 tb_id = l3mdev_fib_table(l3_dev);
 	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fid *f;
@@ -3028,10 +3022,10 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
-	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev,
-				       rif_index, true);
+	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
+					   rif_index, true);
 	if (err)
-		goto err_vport_rif_sp_op;
+		goto err_port_vlan_rif_sp_op;
 
 	fid = mlxsw_sp_rif_sp_to_fid(rif_index);
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
@@ -3055,7 +3049,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 		err = mlxsw_sp_rif_counter_alloc(mlxsw_sp, rif,
 						 MLXSW_SP_RIF_COUNTER_EGRESS);
 		if (err)
-			netdev_dbg(mlxsw_sp_vport->dev,
+			netdev_dbg(mlxsw_sp_port->dev,
 				   "Counter alloc Failed err=%d\n", err);
 	}
 
@@ -3070,17 +3064,19 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 err_rfid_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 err_rif_fdb_op:
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif_index,
-				 false);
-err_vport_rif_sp_op:
+	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
+				     rif_index, false);
+err_port_vlan_rif_sp_op:
 	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
 
-static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
-					  struct mlxsw_sp_rif *rif)
+static void
+mlxsw_sp_port_vlan_rif_sp_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
+				  struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_vr *vr = &mlxsw_sp->router->vrs[rif->vr_id];
 	struct net_device *l3_dev = rif->dev;
 	struct mlxsw_sp_fid *f = rif->f;
@@ -3102,58 +3098,57 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif_index,
-				 false);
+	mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
+				     rif_index, false);
+
 	mlxsw_sp_vr_put(vr);
 }
 
-static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
-				      struct net_device *l3_dev)
+static int
+mlxsw_sp_port_vlan_rif_sp_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
+			       struct net_device *l3_dev)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	u16 vid = mlxsw_sp_port_vlan->vid;
 	struct mlxsw_sp_rif *rif;
 	int err;
 
-	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp_port->mlxsw_sp, l3_dev);
 	if (!rif) {
-		rif = mlxsw_sp_vport_rif_sp_create(mlxsw_sp_vport, l3_dev);
+		rif = mlxsw_sp_port_vlan_rif_sp_create(mlxsw_sp_port_vlan,
+						       l3_dev);
 		if (IS_ERR(rif))
 			return PTR_ERR(rif);
 	}
 
-	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, false);
 	if (err)
 		goto err_port_vid_learning_set;
 
-	err = mlxsw_sp_port_vid_stp_set(mlxsw_sp_vport, vid,
+	err = mlxsw_sp_port_vid_stp_set(mlxsw_sp_port, vid,
 					BR_STATE_FORWARDING);
 	if (err)
 		goto err_port_vid_stp_set;
 
-	mlxsw_sp_port = mlxsw_sp_vport_port(mlxsw_sp_vport);
 	if (mlxsw_sp_port->nr_port_vid_map++ == 0) {
 		err = mlxsw_sp_port_vp_mode_trans(mlxsw_sp_port);
 		if (err)
 			goto err_port_vp_mode_trans;
 	}
 
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, rif->f);
+	mlxsw_sp_port_vlan->fid = rif->f;
 	rif->f->ref_count++;
 
-	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", rif->f->fid);
-
 	return 0;
 
 err_port_vp_mode_trans:
 	mlxsw_sp_port->nr_port_vid_map--;
-	mlxsw_sp_port_vid_stp_set(mlxsw_sp_vport, vid, BR_STATE_BLOCKING);
+	mlxsw_sp_port_vid_stp_set(mlxsw_sp_port, vid, BR_STATE_BLOCKING);
 err_port_vid_stp_set:
-	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
 err_port_vid_learning_set:
 	if (rif->f->ref_count == 0)
-		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, rif);
+		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp_port_vlan, rif);
 	return err;
 }
 
@@ -3161,44 +3156,37 @@ static void
 mlxsw_sp_port_vlan_rif_sp_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
-	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_fid *fid = mlxsw_sp_port_vlan->fid;
 	u16 vid = mlxsw_sp_port_vlan->vid;
-	struct mlxsw_sp_fid *f;
 
-	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-
-	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
-
-	f->ref_count--;
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
+	fid->ref_count--;
+	mlxsw_sp_port_vlan->fid = NULL;
 
 	if (mlxsw_sp_port->nr_port_vid_map == 1)
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 	mlxsw_sp_port->nr_port_vid_map--;
-	mlxsw_sp_port_vid_stp_set(mlxsw_sp_vport, vid, BR_STATE_BLOCKING);
-	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
+	mlxsw_sp_port_vid_stp_set(mlxsw_sp_port, vid, BR_STATE_BLOCKING);
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
 
-	if (f->ref_count == 0)
-		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->rif);
+	if (fid->ref_count == 0)
+		mlxsw_sp_port_vlan_rif_sp_destroy(mlxsw_sp_port_vlan, fid->rif);
 }
 
-static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
-					 struct net_device *port_dev,
-					 unsigned long event, u16 vid)
+static int mlxsw_sp_inetaddr_port_vlan_event(struct net_device *l3_dev,
+					     struct net_device *port_dev,
+					     unsigned long event, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(port_dev);
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
-	struct mlxsw_sp_port *mlxsw_sp_vport;
 
-	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	if (WARN_ON(!mlxsw_sp_vport))
-		return -EINVAL;
 	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
+	if (WARN_ON(!mlxsw_sp_port_vlan))
+		return -EINVAL;
 
 	switch (event) {
 	case NETDEV_UP:
-		return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, l3_dev);
+		return mlxsw_sp_port_vlan_rif_sp_join(mlxsw_sp_port_vlan,
+						      l3_dev);
 	case NETDEV_DOWN:
 		mlxsw_sp_port_vlan_rif_sp_leave(mlxsw_sp_port_vlan);
 		break;
@@ -3215,7 +3203,7 @@ static int mlxsw_sp_inetaddr_port_event(struct net_device *port_dev,
 	    netif_is_ovs_port(port_dev))
 		return 0;
 
-	return mlxsw_sp_inetaddr_vport_event(port_dev, port_dev, event, 1);
+	return mlxsw_sp_inetaddr_port_vlan_event(port_dev, port_dev, event, 1);
 }
 
 static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
@@ -3228,8 +3216,9 @@ static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
 
 	netdev_for_each_lower_dev(lag_dev, port_dev, iter) {
 		if (mlxsw_sp_port_dev_check(port_dev)) {
-			err = mlxsw_sp_inetaddr_vport_event(l3_dev, port_dev,
-							    event, vid);
+			err = mlxsw_sp_inetaddr_port_vlan_event(l3_dev,
+								port_dev,
+								event, vid);
 			if (err)
 				return err;
 		}
@@ -3444,8 +3433,8 @@ static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	if (mlxsw_sp_port_dev_check(real_dev))
-		return mlxsw_sp_inetaddr_vport_event(vlan_dev, real_dev, event,
-						     vid);
+		return mlxsw_sp_inetaddr_port_vlan_event(vlan_dev, real_dev,
+							 event, vid);
 	else if (netif_is_lag_master(real_dev))
 		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
 						     vid);
-- 
2.9.3
