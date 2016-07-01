From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 26/42] mlxsw: spectrum: Introduce support for router interfaces
Date: Fri,  1 Jul 2016 16:04:54 +0200
Message-ID: <1467381910-3445-27-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33890 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108AbcGAOR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:17:57 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so5657755wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:17:56 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we only supported bridged interfaces. Packets ingressing
through the switch ports were either classified to FIDs (in the case of
the VLAN-aware bridge) or vFIDs (in the case of VLAN-unaware bridges).
The packets were then forwarded according to the FDB. Routing was done
entirely in slowpath, by splitting the vFID range in two and using the
lower 0.5K vFIDs as dummy bridges that simply flooded all incoming
traffic to the CPU.

Instead, allow packets to be routed in the device by creating router
interfaces (RIFs) that will direct them to the router block.
Specifically, the RIFs introduced here are Sub-port RIFs used for VLAN
devices and port netdevs. Packets ingressing from the {Port / LAG ID, VID}
with which the RIF was programmed with will be assigned to a special
kind of FIDs called rFIDs and from there directed to the router.

Create a RIF whenever the first IPv4 address was programmed on a VLAN /
LAG / port netdev. Destroy it upon removal of the last IPv4 address.
Receive these notifications by registering for the 'inetaddr'
notification chain. A non-zero (10) priority is used for the
notification block, so that RIFs will be created before routes are
offloaded via FIB code.

Note that another trigger for RIF destruction are CHANGEUPPER
notifications causing the underlying FID's reference count to go down to
zero. This can happen, for example, when a VLAN netdev with an IP address
is put under bridge. While this configuration doesn't make sense it does
cause the device and the kernel to get out of sync when the netdev is
unbridged. We intend to address this in the future, hopefully in current
cycle.

Finally, Remove the lower 0.5K vFIDs, as they are deprecated by the RIFs,
which will trap packets according to their DIP.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 543 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  30 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  14 +-
 3 files changed, 357 insertions(+), 230 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 284f6ab..bd8448a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -51,6 +51,7 @@
 #include <linux/list.h>
 #include <linux/notifier.h>
 #include <linux/dcbnl.h>
+#include <linux/inetdevice.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
@@ -210,23 +211,6 @@ static int mlxsw_sp_port_dev_addr_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port_dev_addr_set(mlxsw_sp_port, addr);
 }
 
-static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				       u16 vid, enum mlxsw_reg_spms_state state)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char *spms_pl;
-	int err;
-
-	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
-	if (!spms_pl)
-		return -ENOMEM;
-	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
-	mlxsw_reg_spms_vid_pack(spms_pl, vid, state);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
-	kfree(spms_pl);
-	return err;
-}
-
 static int mlxsw_sp_port_mtu_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mtu)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
@@ -637,87 +621,6 @@ static int mlxsw_sp_port_vlan_mode_trans(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
-static struct mlxsw_sp_fid *
-mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp, u16 vid)
-{
-	struct mlxsw_sp_fid *f;
-
-	list_for_each_entry(f, &mlxsw_sp->port_vfids.list, list) {
-		if (f->vid == vid)
-			return f;
-	}
-
-	return NULL;
-}
-
-static u16 mlxsw_sp_avail_vfid_get(const struct mlxsw_sp *mlxsw_sp)
-{
-	return find_first_zero_bit(mlxsw_sp->port_vfids.mapped,
-				   MLXSW_SP_VFID_PORT_MAX);
-}
-
-static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
-{
-	char sfmr_pl[MLXSW_REG_SFMR_LEN];
-
-	mlxsw_reg_sfmr_pack(sfmr_pl, !create, fid, 0);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
-}
-
-static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
-
-static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
-						 u16 vid)
-{
-	struct device *dev = mlxsw_sp->bus_info->dev;
-	struct mlxsw_sp_fid *f;
-	u16 vfid, fid;
-	int err;
-
-	vfid = mlxsw_sp_avail_vfid_get(mlxsw_sp);
-	if (vfid == MLXSW_SP_VFID_PORT_MAX) {
-		dev_err(dev, "No available vFIDs\n");
-		return ERR_PTR(-ERANGE);
-	}
-
-	fid = mlxsw_sp_vfid_to_fid(vfid);
-	err = mlxsw_sp_vfid_op(mlxsw_sp, fid, true);
-	if (err) {
-		dev_err(dev, "Failed to create FID=%d\n", fid);
-		return ERR_PTR(err);
-	}
-
-	f = kzalloc(sizeof(*f), GFP_KERNEL);
-	if (!f)
-		goto err_allocate_vfid;
-
-	f->leave = mlxsw_sp_vport_vfid_leave;
-	f->fid = fid;
-	f->vid = vid;
-
-	list_add(&f->list, &mlxsw_sp->port_vfids.list);
-	set_bit(vfid, mlxsw_sp->port_vfids.mapped);
-
-	return f;
-
-err_allocate_vfid:
-	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
-	return ERR_PTR(-ENOMEM);
-}
-
-static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_fid *f)
-{
-	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
-
-	clear_bit(vfid, mlxsw_sp->port_vfids.mapped);
-	list_del(&f->list);
-
-	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
-
-	kfree(f);
-}
-
 static struct mlxsw_sp_port *
 mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 {
@@ -750,67 +653,6 @@ static void mlxsw_sp_port_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_vport)
 	kfree(mlxsw_sp_vport);
 }
 
-static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
-				  bool valid)
-{
-	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
-	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-
-	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport, mt, valid, fid,
-					    vid);
-}
-
-static int mlxsw_sp_vport_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport)
-{
-	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-	struct mlxsw_sp_fid *f;
-	int err;
-
-	f = mlxsw_sp_vfid_find(mlxsw_sp_vport->mlxsw_sp, vid);
-	if (!f) {
-		f = mlxsw_sp_vfid_create(mlxsw_sp_vport->mlxsw_sp, vid);
-		if (IS_ERR(f))
-			return PTR_ERR(f);
-	}
-
-	if (!f->ref_count) {
-		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
-		if (err)
-			goto err_vport_flood_set;
-	}
-
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
-	if (err)
-		goto err_vport_fid_map;
-
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, f);
-	f->ref_count++;
-
-	return 0;
-
-err_vport_fid_map:
-	if (!f->ref_count)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
-err_vport_flood_set:
-	if (!f->ref_count)
-		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
-	return err;
-}
-
-static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
-{
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
-
-	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
-
-	if (--f->ref_count == 0) {
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
-		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
-	}
-}
-
 int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 			  u16 vid)
 {
@@ -848,12 +690,6 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		}
 	}
 
-	err = mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
-	if (err) {
-		netdev_err(dev, "Failed to join vFID\n");
-		goto err_vport_vfid_join;
-	}
-
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 	if (err) {
 		netdev_err(dev, "Failed to disable learning for VID=%d\n", vid);
@@ -867,22 +703,11 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		goto err_port_add_vid;
 	}
 
-	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
-					  MLXSW_REG_SPMS_STATE_FORWARDING);
-	if (err) {
-		netdev_err(dev, "Failed to set STP state for VID=%d\n", vid);
-		goto err_port_stp_state_set;
-	}
-
 	return 0;
 
-err_port_stp_state_set:
-	mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, false, false);
 err_port_add_vid:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
-err_vport_vfid_join:
 	if (list_is_singular(&mlxsw_sp_port->vports_list))
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
@@ -910,13 +735,6 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return 0;
 	}
 
-	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
-					  MLXSW_REG_SPMS_STATE_DISCARDING);
-	if (err) {
-		netdev_err(dev, "Failed to set STP state for VID=%d\n", vid);
-		return err;
-	}
-
 	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, false, false);
 	if (err) {
 		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
@@ -2417,7 +2235,6 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	mlxsw_sp->core = mlxsw_core;
 	mlxsw_sp->bus_info = mlxsw_bus_info;
 	INIT_LIST_HEAD(&mlxsw_sp->fids);
-	INIT_LIST_HEAD(&mlxsw_sp->port_vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_mids.list);
 
@@ -2627,6 +2444,311 @@ void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port)
 	dev_put(mlxsw_sp_port->dev);
 }
 
+static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
+				       unsigned long event)
+{
+	switch (event) {
+	case NETDEV_UP:
+		if (!r)
+			return true;
+		r->ref_count++;
+		return false;
+	case NETDEV_DOWN:
+		if (r && --r->ref_count == 0)
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
+static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
+		if (!mlxsw_sp->rifs[i])
+			return i;
+
+	return MLXSW_SP_RIF_MAX;
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
+	ether_addr_copy(r->addr, l3_dev->dev_addr);
+	r->mtu = l3_dev->mtu;
+	r->ref_count = 1;
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
+	if (rif == MLXSW_SP_RIF_MAX)
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
+static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
+					unsigned long event)
+{
+	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
+	u16 vid = vlan_dev_vlan_id(vlan_dev);
+
+	if (mlxsw_sp_port_dev_check(real_dev))
+		return mlxsw_sp_inetaddr_vport_event(vlan_dev, real_dev, event,
+						     vid);
+	else if (netif_is_lag_master(real_dev))
+		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
+						     vid);
+
+	return 0;
+}
+
+static int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
+				   unsigned long event, void *ptr)
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
+	if (!mlxsw_sp_rif_should_config(r, event))
+		goto out;
+
+	if (mlxsw_sp_port_dev_check(dev))
+		err = mlxsw_sp_inetaddr_port_event(dev, event);
+	else if (netif_is_lag_master(dev))
+		err = mlxsw_sp_inetaddr_lag_event(dev, event);
+	else if (is_vlan_dev(dev))
+		err = mlxsw_sp_inetaddr_vlan_event(dev, event);
+
+out:
+	return notifier_from_errno(err);
+}
+
 static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
 			     const char *mac, int mtu)
 {
@@ -3264,20 +3386,18 @@ mlxsw_sp_br_vfid_find(const struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
-static u16 mlxsw_sp_vfid_to_br_vfid(u16 vfid)
+static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
 {
-	return vfid - MLXSW_SP_VFID_PORT_MAX;
+	return find_first_zero_bit(mlxsw_sp->br_vfids.mapped,
+				   MLXSW_SP_VFID_MAX);
 }
 
-static u16 mlxsw_sp_br_vfid_to_vfid(u16 br_vfid)
+static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 {
-	return MLXSW_SP_VFID_PORT_MAX + br_vfid;
-}
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
 
-static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
-{
-	return find_first_zero_bit(mlxsw_sp->br_vfids.mapped,
-				   MLXSW_SP_VFID_BR_MAX);
+	mlxsw_reg_sfmr_pack(sfmr_pl, !create, fid, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
 static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
@@ -3290,7 +3410,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	u16 vfid, fid;
 	int err;
 
-	vfid = mlxsw_sp_br_vfid_to_vfid(mlxsw_sp_avail_br_vfid_get(mlxsw_sp));
+	vfid = mlxsw_sp_avail_br_vfid_get(mlxsw_sp);
 	if (vfid == MLXSW_SP_VFID_MAX) {
 		dev_err(dev, "No available vFIDs\n");
 		return ERR_PTR(-ERANGE);
@@ -3312,7 +3432,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	f->dev = br_dev;
 
 	list_add(&f->list, &mlxsw_sp->br_vfids.list);
-	set_bit(mlxsw_sp_vfid_to_br_vfid(vfid), mlxsw_sp->br_vfids.mapped);
+	set_bit(vfid, mlxsw_sp->br_vfids.mapped);
 
 	return f;
 
@@ -3325,9 +3445,8 @@ static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 				     struct mlxsw_sp_fid *f)
 {
 	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
-	u16 br_vfid = mlxsw_sp_vfid_to_br_vfid(vfid);
 
-	clear_bit(br_vfid, mlxsw_sp->br_vfids.mapped);
+	clear_bit(vfid, mlxsw_sp->br_vfids.mapped);
 	list_del(&f->list);
 
 	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
@@ -3335,6 +3454,16 @@ static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 	kfree(f);
 }
 
+static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
+				  bool valid)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+
+	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport, mt, valid, fid,
+					    vid);
+}
+
 static int mlxsw_sp_vport_br_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				       struct net_device *br_dev)
 {
@@ -3391,16 +3520,18 @@ static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				      struct net_device *br_dev)
 {
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
 	int err;
 
-	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
+	if (f && !WARN_ON(!f->leave))
+		f->leave(mlxsw_sp_vport);
 
 	err = mlxsw_sp_vport_br_vfid_join(mlxsw_sp_vport, br_dev);
 	if (err) {
 		netdev_err(dev, "Failed to join vFID\n");
-		goto err_vport_br_vfid_join;
+		return err;
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
@@ -3418,8 +3549,6 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 err_port_vid_learning_set:
 	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
-err_vport_br_vfid_join:
-	mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
 	return err;
 }
 
@@ -3431,11 +3560,6 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 
 	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
 
-	mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
-
-	mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
-				    MLXSW_REG_SPMS_STATE_FORWARDING);
-
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
 	mlxsw_sp_vport->uc_flood = 0;
@@ -3560,11 +3684,17 @@ static struct notifier_block mlxsw_sp_netdevice_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_netdevice_event,
 };
 
+static struct notifier_block mlxsw_sp_inetaddr_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_inetaddr_event,
+	.priority = 10,	/* Must be called before FIB notifier block */
+};
+
 static int __init mlxsw_sp_module_init(void)
 {
 	int err;
 
 	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
+	register_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	err = mlxsw_core_driver_register(&mlxsw_sp_driver);
 	if (err)
 		goto err_core_driver_register;
@@ -3578,6 +3708,7 @@ err_core_driver_register:
 static void __exit mlxsw_sp_module_exit(void)
 {
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
+	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
 	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0d3e0e3..b6eeab7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -50,9 +50,10 @@
 #include "core.h"
 
 #define MLXSW_SP_VFID_BASE VLAN_N_VID
-#define MLXSW_SP_VFID_PORT_MAX 512	/* Non-bridged VLAN interfaces */
-#define MLXSW_SP_VFID_BR_MAX 6144	/* Bridged VLAN interfaces */
-#define MLXSW_SP_VFID_MAX (MLXSW_SP_VFID_PORT_MAX + MLXSW_SP_VFID_BR_MAX)
+#define MLXSW_SP_VFID_MAX 6656	/* Bridged VLAN interfaces */
+
+#define MLXSW_SP_RFID_BASE 15360
+#define MLXSW_SP_RIF_MAX 800
 
 #define MLXSW_SP_LAG_MAX 64
 #define MLXSW_SP_PORT_PER_LAG_MAX 16
@@ -81,8 +82,6 @@
 
 #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
 
-#define MLXSW_SP_RIF_MAX 800
-
 static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
 {
 	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
@@ -101,12 +100,13 @@ struct mlxsw_sp_fid {
 	struct list_head list;
 	unsigned int ref_count;
 	struct net_device *dev;
+	struct mlxsw_sp_rif *r;
 	u16 fid;
-	u16 vid;
 };
 
 struct mlxsw_sp_rif {
 	struct net_device *dev;
+	unsigned int ref_count;
 	struct mlxsw_sp_fid *f;
 	unsigned char addr[ETH_ALEN];
 	int mtu;
@@ -133,7 +133,17 @@ static inline u16 mlxsw_sp_fid_to_vfid(u16 fid)
 
 static inline bool mlxsw_sp_fid_is_vfid(u16 fid)
 {
-	return fid >= MLXSW_SP_VFID_BASE;
+	return fid >= MLXSW_SP_VFID_BASE && fid < MLXSW_SP_RFID_BASE;
+}
+
+static inline bool mlxsw_sp_fid_is_rfid(u16 fid)
+{
+	return fid >= MLXSW_SP_RFID_BASE;
+}
+
+static inline u16 mlxsw_sp_rif_sp_to_fid(u16 rif)
+{
+	return MLXSW_SP_RFID_BASE + rif;
 }
 
 struct mlxsw_sp_sb_pr {
@@ -207,11 +217,7 @@ struct mlxsw_sp_router {
 struct mlxsw_sp {
 	struct {
 		struct list_head list;
-		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_PORT_MAX);
-	} port_vfids;
-	struct {
-		struct list_head list;
-		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_BR_MAX);
+		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_MAX);
 	} br_vfids;
 	struct {
 		struct list_head list;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 06f433a..941acd7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -166,11 +166,6 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
 }
 
-static bool mlxsw_sp_vfid_is_vport_br(u16 vfid)
-{
-	return vfid >= MLXSW_SP_VFID_PORT_MAX;
-}
-
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 idx_begin, u16 idx_end, bool set,
 				     bool only_uc)
@@ -182,15 +177,10 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	char *sftr_pl;
 	int err;
 
-	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID;
-		if (mlxsw_sp_vfid_is_vport_br(idx_begin))
-			local_port = mlxsw_sp_port->local_port;
-		else
-			local_port = MLXSW_PORT_CPU_PORT;
-	} else {
+	else
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
-	}
 
 	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
 	if (!sftr_pl)
-- 
2.5.5
