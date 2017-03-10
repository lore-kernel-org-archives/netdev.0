From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/10] mlxsw: spectrum_router: Place RIF related code with router code
Date: Fri, 10 Mar 2017 08:53:39 +0100
Message-ID: <1489132423-12575-7-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36251 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754896AbdCJHx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:57 -0500
Received: by mail-wr0-f196.google.com with SMTP id l37so10522523wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:55 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The inetaddr notification block is currently implemented in the main
driver file, but this isn't really appropriate, as it mainly creates and
destroys router interfaces (RIFs) which belong with the rest of the
router code.

This will become even more apparent later on when we'll need to bind
these RIFs to virtual routers according to the VRF's table.

Structure the driver better and prevent unnecessary function exports by
moving the RIF related code with the rest of the router code.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 541 +---------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  45 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 700 +++++++++++++++++++--
 3 files changed, 644 insertions(+), 642 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cb0e77a..2104ee4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3352,7 +3352,7 @@ static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev
 	return mlxsw_sp_port;
 }
 
-static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
+struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
 
@@ -3391,545 +3391,6 @@ void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port)
 	dev_put(mlxsw_sp_port->dev);
 }
 
-static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
-				       const struct in_device *in_dev,
-				       unsigned long event)
-{
-	switch (event) {
-	case NETDEV_UP:
-		if (!r)
-			return true;
-		return false;
-	case NETDEV_DOWN:
-		if (r && !in_dev->ifa_list)
-			return true;
-		/* It is possible we already removed the RIF ourselves
-		 * if it was assigned to a netdev that is now a bridge
-		 * or LAG slave.
-		 */
-		return false;
-	}
-
-	return false;
-}
-
-static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
-{
-	int i;
-
-	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		if (!mlxsw_sp->rifs[i])
-			return i;
-
-	return MLXSW_SP_INVALID_RIF;
-}
-
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
-				    struct net_device *l3_dev, u16 rif,
-				    bool create)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	bool lagged = mlxsw_sp_vport->lagged;
-	char ritr_pl[MLXSW_REG_RITR_LEN];
-	u16 system_port;
-
-	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif,
-			    l3_dev->mtu, l3_dev->dev_addr);
-
-	mlxsw_sp_vport_rif_sp_attr_get(mlxsw_sp_vport, &lagged, &system_port);
-	mlxsw_reg_ritr_sp_if_pack(ritr_pl, lagged, system_port,
-				  mlxsw_sp_vport_vid_get(mlxsw_sp_vport));
-
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-}
-
-static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
-
-static struct mlxsw_sp_fid *
-mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
-{
-	struct mlxsw_sp_fid *f;
-
-	f = kzalloc(sizeof(*f), GFP_KERNEL);
-	if (!f)
-		return NULL;
-
-	f->leave = mlxsw_sp_vport_rif_sp_leave;
-	f->ref_count = 0;
-	f->dev = l3_dev;
-	f->fid = fid;
-
-	return f;
-}
-
-static struct mlxsw_sp_rif *
-mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
-{
-	struct mlxsw_sp_rif *r;
-
-	r = kzalloc(sizeof(*r), GFP_KERNEL);
-	if (!r)
-		return NULL;
-
-	INIT_LIST_HEAD(&r->nexthop_list);
-	INIT_LIST_HEAD(&r->neigh_list);
-	ether_addr_copy(r->addr, l3_dev->dev_addr);
-	r->mtu = l3_dev->mtu;
-	r->dev = l3_dev;
-	r->rif = rif;
-	r->f = f;
-
-	return r;
-}
-
-static struct mlxsw_sp_rif *
-mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
-			     struct net_device *l3_dev)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct mlxsw_sp_fid *f;
-	struct mlxsw_sp_rif *r;
-	u16 fid, rif;
-	int err;
-
-	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_INVALID_RIF)
-		return ERR_PTR(-ERANGE);
-
-	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, true);
-	if (err)
-		return ERR_PTR(err);
-
-	fid = mlxsw_sp_rif_sp_to_fid(rif);
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
-	if (err)
-		goto err_rif_fdb_op;
-
-	f = mlxsw_sp_rfid_alloc(fid, l3_dev);
-	if (!f) {
-		err = -ENOMEM;
-		goto err_rfid_alloc;
-	}
-
-	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
-	if (!r) {
-		err = -ENOMEM;
-		goto err_rif_alloc;
-	}
-
-	f->r = r;
-	mlxsw_sp->rifs[rif] = r;
-
-	return r;
-
-err_rif_alloc:
-	kfree(f);
-err_rfid_alloc:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
-err_rif_fdb_op:
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
-	return ERR_PTR(err);
-}
-
-static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
-					  struct mlxsw_sp_rif *r)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct net_device *l3_dev = r->dev;
-	struct mlxsw_sp_fid *f = r->f;
-	u16 fid = f->fid;
-	u16 rif = r->rif;
-
-	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
-
-	mlxsw_sp->rifs[rif] = NULL;
-	f->r = NULL;
-
-	kfree(r);
-
-	kfree(f);
-
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
-
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
-}
-
-static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
-				      struct net_device *l3_dev)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct mlxsw_sp_rif *r;
-
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
-	if (!r) {
-		r = mlxsw_sp_vport_rif_sp_create(mlxsw_sp_vport, l3_dev);
-		if (IS_ERR(r))
-			return PTR_ERR(r);
-	}
-
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, r->f);
-	r->f->ref_count++;
-
-	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", r->f->fid);
-
-	return 0;
-}
-
-static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
-{
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-
-	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
-
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
-	if (--f->ref_count == 0)
-		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->r);
-}
-
-static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
-					 struct net_device *port_dev,
-					 unsigned long event, u16 vid)
-{
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(port_dev);
-	struct mlxsw_sp_port *mlxsw_sp_vport;
-
-	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	if (WARN_ON(!mlxsw_sp_vport))
-		return -EINVAL;
-
-	switch (event) {
-	case NETDEV_UP:
-		return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, l3_dev);
-	case NETDEV_DOWN:
-		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
-		break;
-	}
-
-	return 0;
-}
-
-static int mlxsw_sp_inetaddr_port_event(struct net_device *port_dev,
-					unsigned long event)
-{
-	if (netif_is_bridge_port(port_dev) || netif_is_lag_port(port_dev))
-		return 0;
-
-	return mlxsw_sp_inetaddr_vport_event(port_dev, port_dev, event, 1);
-}
-
-static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
-					 struct net_device *lag_dev,
-					 unsigned long event, u16 vid)
-{
-	struct net_device *port_dev;
-	struct list_head *iter;
-	int err;
-
-	netdev_for_each_lower_dev(lag_dev, port_dev, iter) {
-		if (mlxsw_sp_port_dev_check(port_dev)) {
-			err = mlxsw_sp_inetaddr_vport_event(l3_dev, port_dev,
-							    event, vid);
-			if (err)
-				return err;
-		}
-	}
-
-	return 0;
-}
-
-static int mlxsw_sp_inetaddr_lag_event(struct net_device *lag_dev,
-				       unsigned long event)
-{
-	if (netif_is_bridge_port(lag_dev))
-		return 0;
-
-	return __mlxsw_sp_inetaddr_lag_event(lag_dev, lag_dev, event, 1);
-}
-
-static struct mlxsw_sp_fid *mlxsw_sp_bridge_fid_get(struct mlxsw_sp *mlxsw_sp,
-						    struct net_device *l3_dev)
-{
-	u16 fid;
-
-	if (is_vlan_dev(l3_dev))
-		fid = vlan_dev_vlan_id(l3_dev);
-	else if (mlxsw_sp->master_bridge.dev == l3_dev)
-		fid = 1;
-	else
-		return mlxsw_sp_vfid_find(mlxsw_sp, l3_dev);
-
-	return mlxsw_sp_fid_find(mlxsw_sp, fid);
-}
-
-static enum mlxsw_flood_table_type mlxsw_sp_flood_table_type_get(u16 fid)
-{
-	return mlxsw_sp_fid_is_vfid(fid) ? MLXSW_REG_SFGC_TABLE_TYPE_FID :
-	       MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
-}
-
-static u16 mlxsw_sp_flood_table_index_get(u16 fid)
-{
-	return mlxsw_sp_fid_is_vfid(fid) ? mlxsw_sp_fid_to_vfid(fid) : fid;
-}
-
-static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
-					  bool set)
-{
-	enum mlxsw_flood_table_type table_type;
-	char *sftr_pl;
-	u16 index;
-	int err;
-
-	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
-	if (!sftr_pl)
-		return -ENOMEM;
-
-	table_type = mlxsw_sp_flood_table_type_get(fid);
-	index = mlxsw_sp_flood_table_index_get(fid);
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BC, index, table_type,
-			    1, MLXSW_PORT_ROUTER_PORT, set);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
-
-	kfree(sftr_pl);
-	return err;
-}
-
-static enum mlxsw_reg_ritr_if_type mlxsw_sp_rif_type_get(u16 fid)
-{
-	if (mlxsw_sp_fid_is_vfid(fid))
-		return MLXSW_REG_RITR_FID_IF;
-	else
-		return MLXSW_REG_RITR_VLAN_IF;
-}
-
-static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp,
-				  struct net_device *l3_dev,
-				  u16 fid, u16 rif,
-				  bool create)
-{
-	enum mlxsw_reg_ritr_if_type rif_type;
-	char ritr_pl[MLXSW_REG_RITR_LEN];
-
-	rif_type = mlxsw_sp_rif_type_get(fid);
-	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif, l3_dev->mtu,
-			    l3_dev->dev_addr);
-	mlxsw_reg_ritr_fid_set(ritr_pl, rif_type, fid);
-
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-}
-
-static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
-				      struct net_device *l3_dev,
-				      struct mlxsw_sp_fid *f)
-{
-	struct mlxsw_sp_rif *r;
-	u16 rif;
-	int err;
-
-	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_INVALID_RIF)
-		return -ERANGE;
-
-	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
-	if (err)
-		return err;
-
-	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
-	if (err)
-		goto err_rif_bridge_op;
-
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, true);
-	if (err)
-		goto err_rif_fdb_op;
-
-	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
-	if (!r) {
-		err = -ENOMEM;
-		goto err_rif_alloc;
-	}
-
-	f->r = r;
-	mlxsw_sp->rifs[rif] = r;
-
-	netdev_dbg(l3_dev, "RIF=%d created\n", rif);
-
-	return 0;
-
-err_rif_alloc:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
-err_rif_fdb_op:
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
-err_rif_bridge_op:
-	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
-	return err;
-}
-
-void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_rif *r)
-{
-	struct net_device *l3_dev = r->dev;
-	struct mlxsw_sp_fid *f = r->f;
-	u16 rif = r->rif;
-
-	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
-
-	mlxsw_sp->rifs[rif] = NULL;
-	f->r = NULL;
-
-	kfree(r);
-
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
-
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
-
-	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
-
-	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif);
-}
-
-static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
-					  struct net_device *br_dev,
-					  unsigned long event)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(l3_dev);
-	struct mlxsw_sp_fid *f;
-
-	/* FID can either be an actual FID if the L3 device is the
-	 * VLAN-aware bridge or a VLAN device on top. Otherwise, the
-	 * L3 device is a VLAN-unaware bridge and we get a vFID.
-	 */
-	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
-	if (WARN_ON(!f))
-		return -EINVAL;
-
-	switch (event) {
-	case NETDEV_UP:
-		return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
-	case NETDEV_DOWN:
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
-		break;
-	}
-
-	return 0;
-}
-
-static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
-					unsigned long event)
-{
-	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
-	u16 vid = vlan_dev_vlan_id(vlan_dev);
-
-	if (mlxsw_sp_port_dev_check(real_dev))
-		return mlxsw_sp_inetaddr_vport_event(vlan_dev, real_dev, event,
-						     vid);
-	else if (netif_is_lag_master(real_dev))
-		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
-						     vid);
-	else if (netif_is_bridge_master(real_dev) &&
-		 mlxsw_sp->master_bridge.dev == real_dev)
-		return mlxsw_sp_inetaddr_bridge_event(vlan_dev, real_dev,
-						      event);
-
-	return 0;
-}
-
-static int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
-				   unsigned long event, void *ptr)
-{
-	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
-	struct net_device *dev = ifa->ifa_dev->dev;
-	struct mlxsw_sp *mlxsw_sp;
-	struct mlxsw_sp_rif *r;
-	int err = 0;
-
-	mlxsw_sp = mlxsw_sp_lower_get(dev);
-	if (!mlxsw_sp)
-		goto out;
-
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!mlxsw_sp_rif_should_config(r, ifa->ifa_dev, event))
-		goto out;
-
-	if (mlxsw_sp_port_dev_check(dev))
-		err = mlxsw_sp_inetaddr_port_event(dev, event);
-	else if (netif_is_lag_master(dev))
-		err = mlxsw_sp_inetaddr_lag_event(dev, event);
-	else if (netif_is_bridge_master(dev))
-		err = mlxsw_sp_inetaddr_bridge_event(dev, dev, event);
-	else if (is_vlan_dev(dev))
-		err = mlxsw_sp_inetaddr_vlan_event(dev, event);
-
-out:
-	return notifier_from_errno(err);
-}
-
-static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
-			     const char *mac, int mtu)
-{
-	char ritr_pl[MLXSW_REG_RITR_LEN];
-	int err;
-
-	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-	if (err)
-		return err;
-
-	mlxsw_reg_ritr_mtu_set(ritr_pl, mtu);
-	mlxsw_reg_ritr_if_mac_memcpy_to(ritr_pl, mac);
-	mlxsw_reg_ritr_op_set(ritr_pl, MLXSW_REG_RITR_RIF_CREATE);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-}
-
-static int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
-{
-	struct mlxsw_sp *mlxsw_sp;
-	struct mlxsw_sp_rif *r;
-	int err;
-
-	mlxsw_sp = mlxsw_sp_lower_get(dev);
-	if (!mlxsw_sp)
-		return 0;
-
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!r)
-		return 0;
-
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, false);
-	if (err)
-		return err;
-
-	err = mlxsw_sp_rif_edit(mlxsw_sp, r->rif, dev->dev_addr, dev->mtu);
-	if (err)
-		goto err_rif_edit;
-
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, dev->dev_addr, r->f->fid, true);
-	if (err)
-		goto err_rif_fdb_op;
-
-	ether_addr_copy(r->addr, dev->dev_addr);
-	r->mtu = dev->mtu;
-
-	netdev_dbg(dev, "Updated RIF=%d\n", r->rif);
-
-	return 0;
-
-err_rif_fdb_op:
-	mlxsw_sp_rif_edit(mlxsw_sp, r->rif, r->addr, r->mtu);
-err_rif_edit:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, true);
-	return err;
-}
-
 static bool mlxsw_sp_lag_port_fid_member(struct mlxsw_sp_port *lag_port,
 					 u16 fid)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7805430..5bc6042 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -58,7 +58,6 @@
 #define MLXSW_SP_VFID_MAX 1024	/* Bridged VLAN interfaces */
 
 #define MLXSW_SP_RFID_BASE 15360
-#define MLXSW_SP_INVALID_RIF 0xffff
 
 #define MLXSW_SP_MID_MAX 7000
 
@@ -92,6 +91,7 @@ static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
 }
 
 struct mlxsw_sp_port;
+struct mlxsw_sp_rif;
 
 struct mlxsw_sp_upper {
 	struct net_device *dev;
@@ -107,16 +107,6 @@ struct mlxsw_sp_fid {
 	u16 fid;
 };
 
-struct mlxsw_sp_rif {
-	struct list_head nexthop_list;
-	struct list_head neigh_list;
-	struct net_device *dev;
-	struct mlxsw_sp_fid *f;
-	unsigned char addr[ETH_ALEN];
-	int mtu;
-	u16 rif;
-};
-
 struct mlxsw_sp_mid {
 	struct list_head list;
 	unsigned char addr[ETH_ALEN];
@@ -140,16 +130,6 @@ static inline bool mlxsw_sp_fid_is_vfid(u16 fid)
 	return fid >= MLXSW_SP_VFID_BASE && fid < MLXSW_SP_RFID_BASE;
 }
 
-static inline bool mlxsw_sp_fid_is_rfid(u16 fid)
-{
-	return fid >= MLXSW_SP_RFID_BASE;
-}
-
-static inline u16 mlxsw_sp_rif_sp_to_fid(u16 rif)
-{
-	return MLXSW_SP_RFID_BASE + rif;
-}
-
 struct mlxsw_sp_sb_pr {
 	enum mlxsw_reg_sbpr_mode mode;
 	u32 size;
@@ -385,6 +365,7 @@ struct mlxsw_sp_port {
 };
 
 bool mlxsw_sp_port_dev_check(const struct net_device *dev);
+struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev);
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
 void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port);
 
@@ -496,19 +477,6 @@ mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
-static inline struct mlxsw_sp_rif *
-mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
-			 const struct net_device *dev)
-{
-	int i;
-
-	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
-			return mlxsw_sp->rifs[i];
-
-	return NULL;
-}
-
 enum mlxsw_sp_flood_table {
 	MLXSW_SP_FLOOD_TABLE_UC,
 	MLXSW_SP_FLOOD_TABLE_BC,
@@ -569,8 +537,6 @@ int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
 			bool adding);
 struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid);
 void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f);
-void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_rif *r);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
@@ -607,8 +573,11 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 				   unsigned long event, void *ptr);
-void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
-				   struct mlxsw_sp_rif *r);
+int mlxsw_sp_netdevice_router_port_event(struct net_device *dev);
+int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
+			    unsigned long event, void *ptr);
+void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_rif *r);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2fc4a97..1839ba0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -50,6 +50,20 @@
 #include "core.h"
 #include "reg.h"
 
+struct mlxsw_sp_rif {
+	struct list_head nexthop_list;
+	struct list_head neigh_list;
+	struct net_device *dev;
+	struct mlxsw_sp_fid *f;
+	unsigned char addr[ETH_ALEN];
+	int mtu;
+	u16 rif;
+};
+
+static struct mlxsw_sp_rif *
+mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
+			 const struct net_device *dev);
+
 #define mlxsw_sp_prefix_usage_for_each(prefix, prefix_usage) \
 	for_each_set_bit(prefix, (prefix_usage)->b, MLXSW_SP_PREFIX_COUNT)
 
@@ -2452,70 +2466,6 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
 }
 
-static int mlxsw_sp_router_rif_disable(struct mlxsw_sp *mlxsw_sp, u16 rif)
-{
-	char ritr_pl[MLXSW_REG_RITR_LEN];
-	int err;
-
-	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-	if (WARN_ON_ONCE(err))
-		return err;
-
-	mlxsw_reg_ritr_enable_set(ritr_pl, false);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
-}
-
-void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
-				   struct mlxsw_sp_rif *r)
-{
-	mlxsw_sp_router_rif_disable(mlxsw_sp, r->rif);
-	mlxsw_sp_nexthop_rif_gone_sync(mlxsw_sp, r);
-	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, r);
-}
-
-static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
-{
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-	u64 max_rifs;
-	int err;
-
-	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_RIFS))
-		return -EIO;
-
-	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
-	mlxsw_sp->rifs = kcalloc(max_rifs, sizeof(struct mlxsw_sp_rif *),
-				 GFP_KERNEL);
-	if (!mlxsw_sp->rifs)
-		return -ENOMEM;
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, true);
-	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, max_rifs);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-	if (err)
-		goto err_rgcr_fail;
-
-	return 0;
-
-err_rgcr_fail:
-	kfree(mlxsw_sp->rifs);
-	return err;
-}
-
-static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-	int i;
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, false);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-
-	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
-
-	kfree(mlxsw_sp->rifs);
-}
-
 struct mlxsw_sp_fib_event_work {
 	struct work_struct work;
 	union {
@@ -2609,6 +2559,586 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	return NOTIFY_DONE;
 }
 
+static struct mlxsw_sp_rif *
+mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
+			 const struct net_device *dev)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
+		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
+			return mlxsw_sp->rifs[i];
+
+	return NULL;
+}
+
+static int mlxsw_sp_router_rif_disable(struct mlxsw_sp *mlxsw_sp, u16 rif)
+{
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	int err;
+
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+	if (WARN_ON_ONCE(err))
+		return err;
+
+	mlxsw_reg_ritr_enable_set(ritr_pl, false);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+static void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
+					  struct mlxsw_sp_rif *r)
+{
+	mlxsw_sp_router_rif_disable(mlxsw_sp, r->rif);
+	mlxsw_sp_nexthop_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, r);
+}
+
+static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
+				       const struct in_device *in_dev,
+				       unsigned long event)
+{
+	switch (event) {
+	case NETDEV_UP:
+		if (!r)
+			return true;
+		return false;
+	case NETDEV_DOWN:
+		if (r && !in_dev->ifa_list)
+			return true;
+		/* It is possible we already removed the RIF ourselves
+		 * if it was assigned to a netdev that is now a bridge
+		 * or LAG slave.
+		 */
+		return false;
+	}
+
+	return false;
+}
+
+#define MLXSW_SP_INVALID_RIF 0xffff
+static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
+		if (!mlxsw_sp->rifs[i])
+			return i;
+
+	return MLXSW_SP_INVALID_RIF;
+}
+
+static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
+					   bool *p_lagged, u16 *p_system_port)
+{
+	u8 local_port = mlxsw_sp_vport->local_port;
+
+	*p_lagged = mlxsw_sp_vport->lagged;
+	*p_system_port = *p_lagged ? mlxsw_sp_vport->lag_id : local_port;
+}
+
+static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
+				    struct net_device *l3_dev, u16 rif,
+				    bool create)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	bool lagged = mlxsw_sp_vport->lagged;
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	u16 system_port;
+
+	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif,
+			    l3_dev->mtu, l3_dev->dev_addr);
+
+	mlxsw_sp_vport_rif_sp_attr_get(mlxsw_sp_vport, &lagged, &system_port);
+	mlxsw_reg_ritr_sp_if_pack(ritr_pl, lagged, system_port,
+				  mlxsw_sp_vport_vid_get(mlxsw_sp_vport));
+
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+
+static u16 mlxsw_sp_rif_sp_to_fid(u16 rif)
+{
+	return MLXSW_SP_RFID_BASE + rif;
+}
+
+static struct mlxsw_sp_fid *
+mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = kzalloc(sizeof(*f), GFP_KERNEL);
+	if (!f)
+		return NULL;
+
+	f->leave = mlxsw_sp_vport_rif_sp_leave;
+	f->ref_count = 0;
+	f->dev = l3_dev;
+	f->fid = fid;
+
+	return f;
+}
+
+static struct mlxsw_sp_rif *
+mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
+{
+	struct mlxsw_sp_rif *r;
+
+	r = kzalloc(sizeof(*r), GFP_KERNEL);
+	if (!r)
+		return NULL;
+
+	INIT_LIST_HEAD(&r->nexthop_list);
+	INIT_LIST_HEAD(&r->neigh_list);
+	ether_addr_copy(r->addr, l3_dev->dev_addr);
+	r->mtu = l3_dev->mtu;
+	r->dev = l3_dev;
+	r->rif = rif;
+	r->f = f;
+
+	return r;
+}
+
+static struct mlxsw_sp_rif *
+mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
+			     struct net_device *l3_dev)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_fid *f;
+	struct mlxsw_sp_rif *r;
+	u16 fid, rif;
+	int err;
+
+	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
+	if (rif == MLXSW_SP_INVALID_RIF)
+		return ERR_PTR(-ERANGE);
+
+	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, true);
+	if (err)
+		return ERR_PTR(err);
+
+	fid = mlxsw_sp_rif_sp_to_fid(rif);
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	f = mlxsw_sp_rfid_alloc(fid, l3_dev);
+	if (!f) {
+		err = -ENOMEM;
+		goto err_rfid_alloc;
+	}
+
+	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
+	if (!r) {
+		err = -ENOMEM;
+		goto err_rif_alloc;
+	}
+
+	f->r = r;
+	mlxsw_sp->rifs[rif] = r;
+
+	return r;
+
+err_rif_alloc:
+	kfree(f);
+err_rfid_alloc:
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
+err_rif_fdb_op:
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
+	return ERR_PTR(err);
+}
+
+static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
+					  struct mlxsw_sp_rif *r)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct net_device *l3_dev = r->dev;
+	struct mlxsw_sp_fid *f = r->f;
+	u16 fid = f->fid;
+	u16 rif = r->rif;
+
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+
+	mlxsw_sp->rifs[rif] = NULL;
+	f->r = NULL;
+
+	kfree(r);
+
+	kfree(f);
+
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
+
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
+}
+
+static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
+				      struct net_device *l3_dev)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_rif *r;
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
+	if (!r) {
+		r = mlxsw_sp_vport_rif_sp_create(mlxsw_sp_vport, l3_dev);
+		if (IS_ERR(r))
+			return PTR_ERR(r);
+	}
+
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, r->f);
+	r->f->ref_count++;
+
+	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", r->f->fid);
+
+	return 0;
+}
+
+static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+
+	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
+
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
+	if (--f->ref_count == 0)
+		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->r);
+}
+
+static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
+					 struct net_device *port_dev,
+					 unsigned long event, u16 vid)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(port_dev);
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	if (WARN_ON(!mlxsw_sp_vport))
+		return -EINVAL;
+
+	switch (event) {
+	case NETDEV_UP:
+		return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, l3_dev);
+	case NETDEV_DOWN:
+		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
+		break;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_inetaddr_port_event(struct net_device *port_dev,
+					unsigned long event)
+{
+	if (netif_is_bridge_port(port_dev) || netif_is_lag_port(port_dev))
+		return 0;
+
+	return mlxsw_sp_inetaddr_vport_event(port_dev, port_dev, event, 1);
+}
+
+static int __mlxsw_sp_inetaddr_lag_event(struct net_device *l3_dev,
+					 struct net_device *lag_dev,
+					 unsigned long event, u16 vid)
+{
+	struct net_device *port_dev;
+	struct list_head *iter;
+	int err;
+
+	netdev_for_each_lower_dev(lag_dev, port_dev, iter) {
+		if (mlxsw_sp_port_dev_check(port_dev)) {
+			err = mlxsw_sp_inetaddr_vport_event(l3_dev, port_dev,
+							    event, vid);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_inetaddr_lag_event(struct net_device *lag_dev,
+				       unsigned long event)
+{
+	if (netif_is_bridge_port(lag_dev))
+		return 0;
+
+	return __mlxsw_sp_inetaddr_lag_event(lag_dev, lag_dev, event, 1);
+}
+
+static struct mlxsw_sp_fid *mlxsw_sp_bridge_fid_get(struct mlxsw_sp *mlxsw_sp,
+						    struct net_device *l3_dev)
+{
+	u16 fid;
+
+	if (is_vlan_dev(l3_dev))
+		fid = vlan_dev_vlan_id(l3_dev);
+	else if (mlxsw_sp->master_bridge.dev == l3_dev)
+		fid = 1;
+	else
+		return mlxsw_sp_vfid_find(mlxsw_sp, l3_dev);
+
+	return mlxsw_sp_fid_find(mlxsw_sp, fid);
+}
+
+static enum mlxsw_flood_table_type mlxsw_sp_flood_table_type_get(u16 fid)
+{
+	return mlxsw_sp_fid_is_vfid(fid) ? MLXSW_REG_SFGC_TABLE_TYPE_FID :
+	       MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
+}
+
+static u16 mlxsw_sp_flood_table_index_get(u16 fid)
+{
+	return mlxsw_sp_fid_is_vfid(fid) ? mlxsw_sp_fid_to_vfid(fid) : fid;
+}
+
+static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
+					  bool set)
+{
+	enum mlxsw_flood_table_type table_type;
+	char *sftr_pl;
+	u16 index;
+	int err;
+
+	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+	if (!sftr_pl)
+		return -ENOMEM;
+
+	table_type = mlxsw_sp_flood_table_type_get(fid);
+	index = mlxsw_sp_flood_table_index_get(fid);
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BC, index, table_type,
+			    1, MLXSW_PORT_ROUTER_PORT, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+
+	kfree(sftr_pl);
+	return err;
+}
+
+static enum mlxsw_reg_ritr_if_type mlxsw_sp_rif_type_get(u16 fid)
+{
+	if (mlxsw_sp_fid_is_vfid(fid))
+		return MLXSW_REG_RITR_FID_IF;
+	else
+		return MLXSW_REG_RITR_VLAN_IF;
+}
+
+static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp,
+				  struct net_device *l3_dev,
+				  u16 fid, u16 rif,
+				  bool create)
+{
+	enum mlxsw_reg_ritr_if_type rif_type;
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+
+	rif_type = mlxsw_sp_rif_type_get(fid);
+	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif, l3_dev->mtu,
+			    l3_dev->dev_addr);
+	mlxsw_reg_ritr_fid_set(ritr_pl, rif_type, fid);
+
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
+				      struct net_device *l3_dev,
+				      struct mlxsw_sp_fid *f)
+{
+	struct mlxsw_sp_rif *r;
+	u16 rif;
+	int err;
+
+	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
+	if (rif == MLXSW_SP_INVALID_RIF)
+		return -ERANGE;
+
+	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
+	if (err)
+		return err;
+
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
+	if (err)
+		goto err_rif_bridge_op;
+
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
+	if (!r) {
+		err = -ENOMEM;
+		goto err_rif_alloc;
+	}
+
+	f->r = r;
+	mlxsw_sp->rifs[rif] = r;
+
+	netdev_dbg(l3_dev, "RIF=%d created\n", rif);
+
+	return 0;
+
+err_rif_alloc:
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
+err_rif_fdb_op:
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
+err_rif_bridge_op:
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+	return err;
+}
+
+void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_rif *r)
+{
+	struct net_device *l3_dev = r->dev;
+	struct mlxsw_sp_fid *f = r->f;
+	u16 rif = r->rif;
+
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+
+	mlxsw_sp->rifs[rif] = NULL;
+	f->r = NULL;
+
+	kfree(r);
+
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
+
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
+
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+
+	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif);
+}
+
+static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
+					  struct net_device *br_dev,
+					  unsigned long event)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(l3_dev);
+	struct mlxsw_sp_fid *f;
+
+	/* FID can either be an actual FID if the L3 device is the
+	 * VLAN-aware bridge or a VLAN device on top. Otherwise, the
+	 * L3 device is a VLAN-unaware bridge and we get a vFID.
+	 */
+	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
+	if (WARN_ON(!f))
+		return -EINVAL;
+
+	switch (event) {
+	case NETDEV_UP:
+		return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
+	case NETDEV_DOWN:
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+		break;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
+					unsigned long event)
+{
+	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
+	u16 vid = vlan_dev_vlan_id(vlan_dev);
+
+	if (mlxsw_sp_port_dev_check(real_dev))
+		return mlxsw_sp_inetaddr_vport_event(vlan_dev, real_dev, event,
+						     vid);
+	else if (netif_is_lag_master(real_dev))
+		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
+						     vid);
+	else if (netif_is_bridge_master(real_dev) &&
+		 mlxsw_sp->master_bridge.dev == real_dev)
+		return mlxsw_sp_inetaddr_bridge_event(vlan_dev, real_dev,
+						      event);
+
+	return 0;
+}
+
+int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
+			    unsigned long event, void *ptr)
+{
+	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *r;
+	int err = 0;
+
+	mlxsw_sp = mlxsw_sp_lower_get(dev);
+	if (!mlxsw_sp)
+		goto out;
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!mlxsw_sp_rif_should_config(r, ifa->ifa_dev, event))
+		goto out;
+
+	if (mlxsw_sp_port_dev_check(dev))
+		err = mlxsw_sp_inetaddr_port_event(dev, event);
+	else if (netif_is_lag_master(dev))
+		err = mlxsw_sp_inetaddr_lag_event(dev, event);
+	else if (netif_is_bridge_master(dev))
+		err = mlxsw_sp_inetaddr_bridge_event(dev, dev, event);
+	else if (is_vlan_dev(dev))
+		err = mlxsw_sp_inetaddr_vlan_event(dev, event);
+
+out:
+	return notifier_from_errno(err);
+}
+
+static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
+			     const char *mac, int mtu)
+{
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	int err;
+
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_ritr_mtu_set(ritr_pl, mtu);
+	mlxsw_reg_ritr_if_mac_memcpy_to(ritr_pl, mac);
+	mlxsw_reg_ritr_op_set(ritr_pl, MLXSW_REG_RITR_RIF_CREATE);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
+{
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif *r;
+	int err;
+
+	mlxsw_sp = mlxsw_sp_lower_get(dev);
+	if (!mlxsw_sp)
+		return 0;
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!r)
+		return 0;
+
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, false);
+	if (err)
+		return err;
+
+	err = mlxsw_sp_rif_edit(mlxsw_sp, r->rif, dev->dev_addr, dev->mtu);
+	if (err)
+		goto err_rif_edit;
+
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, dev->dev_addr, r->f->fid, true);
+	if (err)
+		goto err_rif_fdb_op;
+
+	ether_addr_copy(r->addr, dev->dev_addr);
+	r->mtu = dev->mtu;
+
+	netdev_dbg(dev, "Updated RIF=%d\n", r->rif);
+
+	return 0;
+
+err_rif_fdb_op:
+	mlxsw_sp_rif_edit(mlxsw_sp, r->rif, r->addr, r->mtu);
+err_rif_edit:
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, true);
+	return err;
+}
+
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
 	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
@@ -2621,6 +3151,48 @@ static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
 }
 
+static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	u64 max_rifs;
+	int err;
+
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_RIFS))
+		return -EIO;
+
+	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+	mlxsw_sp->rifs = kcalloc(max_rifs, sizeof(struct mlxsw_sp_rif *),
+				 GFP_KERNEL);
+	if (!mlxsw_sp->rifs)
+		return -ENOMEM;
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, true);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, max_rifs);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+	if (err)
+		goto err_rgcr_fail;
+
+	return 0;
+
+err_rgcr_fail:
+	kfree(mlxsw_sp->rifs);
+	return err;
+}
+
+static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	int i;
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, false);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
+		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
+
+	kfree(mlxsw_sp->rifs);
+}
+
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
-- 
2.7.4
