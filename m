From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/23] mlxsw: spectrum: Use per-FID struct for the VLAN-aware bridge
Date: Mon, 20 Jun 2016 23:04:15 +0200
Message-ID: <1466456661-5260-18-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36754 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcFTWP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:15:57 -0400
Received: by mail-lf0-f68.google.com with SMTP id a2so7052815lfe.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:15:56 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In a very similar way to the vFIDs, make the first 4K FIDs - used in the
VLAN-aware bridge - use the new FID struct.

Upon first use of the FID by any of the ports do the following:

1) Create the FID
2) Setup a matching flooding entry
3) Create a mapping for the FID

Unlike vFIDs, upon creation of a FID we always create a global
VID-to-FID mapping, so that ports without upper vPorts can use it
instead of creating an explicit {Port, VID} to FID mapping.

When a port leaves a FID the reverse is performed. Whenever the FID's
reference count reaches zero the FID is deleted along with the global
mapping.

The per-FID struct will later allow us to configure L3 interfaces on top
of the VLAN-aware bridge.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 316 +++++++++++++--------
 3 files changed, 195 insertions(+), 125 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4869392..08f3f51 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2396,6 +2396,7 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 
 	mlxsw_sp->core = mlxsw_core;
 	mlxsw_sp->bus_info = mlxsw_bus_info;
+	INIT_LIST_HEAD(&mlxsw_sp->fids);
 	INIT_LIST_HEAD(&mlxsw_sp->port_vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_mids.list);
@@ -2472,6 +2473,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	WARN_ON(!list_empty(&mlxsw_sp->fids));
 }
 
 static struct mlxsw_config_profile mlxsw_sp_config_profile = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index c973ab5..d6cf6de 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -165,7 +165,7 @@ struct mlxsw_sp {
 		struct list_head list;
 		DECLARE_BITMAP(mapped, MLXSW_SP_MID_MAX);
 	} br_mids;
-	DECLARE_BITMAP(active_fids, VLAN_N_VID);
+	struct list_head fids;	/* VLAN-aware bridge FIDs */
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 3e9ba58..6713769 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -384,6 +384,192 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 	return err;
 }
 
+static struct mlxsw_sp_fid *mlxsw_sp_fid_find(struct mlxsw_sp *mlxsw_sp,
+					      u16 fid)
+{
+	struct mlxsw_sp_fid *f;
+
+	list_for_each_entry(f, &mlxsw_sp->fids, list)
+		if (f->fid == fid)
+			return f;
+
+	return NULL;
+}
+
+static int mlxsw_sp_fid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
+{
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
+
+	mlxsw_reg_sfmr_pack(sfmr_pl, !create, fid, fid);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
+}
+
+static int mlxsw_sp_fid_map(struct mlxsw_sp *mlxsw_sp, u16 fid, bool valid)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_VID_TO_FID;
+	char svfa_pl[MLXSW_REG_SVFA_LEN];
+
+	mlxsw_reg_svfa_pack(svfa_pl, 0, mt, valid, fid, fid);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(svfa), svfa_pl);
+}
+
+static struct mlxsw_sp_fid *mlxsw_sp_fid_alloc(u16 fid)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = kzalloc(sizeof(*f), GFP_KERNEL);
+	if (!f)
+		return NULL;
+
+	f->fid = fid;
+
+	return f;
+}
+
+static struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp,
+						u16 fid)
+{
+	struct mlxsw_sp_fid *f;
+	int err;
+
+	err = mlxsw_sp_fid_op(mlxsw_sp, fid, true);
+	if (err)
+		return ERR_PTR(err);
+
+	/* Although all the ports member in the FID might be using a
+	 * {Port, VID} to FID mapping, we create a global VID-to-FID
+	 * mapping. This allows a port to transition to VLAN mode,
+	 * knowing the global mapping exists.
+	 */
+	err = mlxsw_sp_fid_map(mlxsw_sp, fid, true);
+	if (err)
+		goto err_fid_map;
+
+	f = mlxsw_sp_fid_alloc(fid);
+	if (!f) {
+		err = -ENOMEM;
+		goto err_allocate_fid;
+	}
+
+	list_add(&f->list, &mlxsw_sp->fids);
+
+	return f;
+
+err_allocate_fid:
+	mlxsw_sp_fid_map(mlxsw_sp, fid, false);
+err_fid_map:
+	mlxsw_sp_fid_op(mlxsw_sp, fid, false);
+	return ERR_PTR(err);
+}
+
+static void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_fid *f)
+{
+	u16 fid = f->fid;
+
+	list_del(&f->list);
+
+	kfree(f);
+
+	mlxsw_sp_fid_op(mlxsw_sp, fid, false);
+}
+
+static int __mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u16 fid)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = mlxsw_sp_fid_find(mlxsw_sp_port->mlxsw_sp, fid);
+	if (!f) {
+		f = mlxsw_sp_fid_create(mlxsw_sp_port->mlxsw_sp, fid);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
+	}
+
+	f->ref_count++;
+
+	return 0;
+}
+
+static void __mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
+				      u16 fid)
+{
+	struct mlxsw_sp_fid *f;
+
+	f = mlxsw_sp_fid_find(mlxsw_sp_port->mlxsw_sp, fid);
+	if (WARN_ON(!f))
+		return;
+
+	if (--f->ref_count == 0)
+		mlxsw_sp_fid_destroy(mlxsw_sp_port->mlxsw_sp, f);
+}
+
+static int mlxsw_sp_port_fid_map(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid,
+				 bool valid)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+
+	/* If port doesn't have vPorts, then it can use the global
+	 * VID-to-FID mapping.
+	 */
+	if (list_empty(&mlxsw_sp_port->vports_list))
+		return 0;
+
+	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, valid, fid, fid);
+}
+
+static int mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
+				  u16 fid_begin, u16 fid_end)
+{
+	int fid, err;
+
+	for (fid = fid_begin; fid <= fid_end; fid++) {
+		err = __mlxsw_sp_port_fid_join(mlxsw_sp_port, fid);
+		if (err)
+			goto err_port_fid_join;
+	}
+
+	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end,
+					true, false);
+	if (err)
+		goto err_port_flood_set;
+
+	for (fid = fid_begin; fid <= fid_end; fid++) {
+		err = mlxsw_sp_port_fid_map(mlxsw_sp_port, fid, true);
+		if (err)
+			goto err_port_fid_map;
+	}
+
+	return 0;
+
+err_port_fid_map:
+	for (fid--; fid >= fid_begin; fid--)
+		mlxsw_sp_port_fid_map(mlxsw_sp_port, fid, false);
+	__mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end, false,
+				  false);
+err_port_flood_set:
+	fid = fid_end;
+err_port_fid_join:
+	for (fid--; fid >= fid_begin; fid--)
+		__mlxsw_sp_port_fid_leave(mlxsw_sp_port, fid);
+	return err;
+}
+
+static void mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u16 fid_begin, u16 fid_end)
+{
+	int fid;
+
+	for (fid = fid_begin; fid <= fid_end; fid++)
+		mlxsw_sp_port_fid_map(mlxsw_sp_port, fid, false);
+
+	__mlxsw_sp_port_flood_set(mlxsw_sp_port, fid_begin, fid_end, false,
+				  false);
+
+	for (fid = fid_begin; fid <= fid_end; fid++)
+		__mlxsw_sp_port_fid_leave(mlxsw_sp_port, fid);
+}
+
 static int __mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				    u16 vid)
 {
@@ -441,55 +627,6 @@ err_port_allow_untagged_set:
 	return err;
 }
 
-static int mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid)
-{
-	char sfmr_pl[MLXSW_REG_SFMR_LEN];
-	int err;
-
-	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_CREATE_FID, fid, fid);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
-
-	if (err)
-		return err;
-
-	set_bit(fid, mlxsw_sp->active_fids);
-	return 0;
-}
-
-static void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, u16 fid)
-{
-	char sfmr_pl[MLXSW_REG_SFMR_LEN];
-
-	clear_bit(fid, mlxsw_sp->active_fids);
-
-	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_DESTROY_FID,
-			    fid, fid);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
-}
-
-static int mlxsw_sp_port_fid_map(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
-{
-	enum mlxsw_reg_svfa_mt mt;
-
-	if (!list_empty(&mlxsw_sp_port->vports_list))
-		mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
-	else
-		mt = MLXSW_REG_SVFA_MT_VID_TO_FID;
-
-	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, true, fid, fid);
-}
-
-static int mlxsw_sp_port_fid_unmap(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
-{
-	enum mlxsw_reg_svfa_mt mt;
-
-	if (list_empty(&mlxsw_sp_port->vports_list))
-		return 0;
-
-	mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
-	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, false, fid, fid);
-}
-
 static int mlxsw_sp_port_add_vids(struct net_device *dev, u16 vid_begin,
 				  u16 vid_end)
 {
@@ -534,10 +671,8 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end,
 				     bool flag_untagged, bool flag_pvid)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct net_device *dev = mlxsw_sp_port->dev;
-	u16 vid, last_visited_vid, old_pvid;
-	enum mlxsw_reg_svfa_mt mt;
+	u16 vid, old_pvid;
 	int err;
 
 	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
@@ -547,44 +682,10 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!mlxsw_sp_port->bridged)
 		return mlxsw_sp_port_add_vids(dev, vid_begin, vid_end);
 
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		if (!test_bit(vid, mlxsw_sp->active_fids)) {
-			err = mlxsw_sp_fid_create(mlxsw_sp, vid);
-			if (err) {
-				netdev_err(dev, "Failed to create FID=%d\n",
-					   vid);
-				return err;
-			}
-
-			/* When creating a FID, we set a VID to FID mapping
-			 * regardless of the port's mode.
-			 */
-			mt = MLXSW_REG_SVFA_MT_VID_TO_FID;
-			err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt,
-							   true, vid, vid);
-			if (err) {
-				netdev_err(dev, "Failed to create FID=VID=%d mapping\n",
-					   vid);
-				goto err_port_vid_to_fid_set;
-			}
-		}
-	}
-
-	/* Set FID mapping according to port's mode */
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		err = mlxsw_sp_port_fid_map(mlxsw_sp_port, vid);
-		if (err) {
-			netdev_err(dev, "Failed to map FID=%d", vid);
-			last_visited_vid = --vid;
-			goto err_port_fid_map;
-		}
-	}
-
-	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end,
-					true, false);
+	err = mlxsw_sp_port_fid_join(mlxsw_sp_port, vid_begin, vid_end);
 	if (err) {
-		netdev_err(dev, "Failed to configure flooding\n");
-		goto err_port_flood_set;
+		netdev_err(dev, "Failed to join FIDs\n");
+		return err;
 	}
 
 	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
@@ -629,10 +730,6 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	return 0;
 
-err_port_vid_to_fid_set:
-	mlxsw_sp_fid_destroy(mlxsw_sp, vid);
-	return err;
-
 err_port_stp_state_set:
 	for (vid = vid_begin; vid <= vid_end; vid++)
 		clear_bit(vid, mlxsw_sp_port->active_vlans);
@@ -642,13 +739,7 @@ err_port_pvid_set:
 	__mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end, false,
 				  false);
 err_port_vlans_set:
-	__mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end, false,
-				  false);
-err_port_flood_set:
-	last_visited_vid = vid_end;
-err_port_fid_map:
-	for (vid = last_visited_vid; vid >= vid_begin; vid--)
-		mlxsw_sp_port_fid_unmap(mlxsw_sp_port, vid);
+	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 	return err;
 }
 
@@ -971,21 +1062,7 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		}
 	}
 
-	err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid_begin, vid_end,
-					false, false);
-	if (err) {
-		netdev_err(dev, "Failed to clear flooding\n");
-		return err;
-	}
-
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		/* Remove FID mapping in case of Virtual mode */
-		err = mlxsw_sp_port_fid_unmap(mlxsw_sp_port, vid);
-		if (err) {
-			netdev_err(dev, "Failed to unmap FID=%d", vid);
-			return err;
-		}
-	}
+	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 
 out:
 	/* Changing activity bits only if HW operation succeded */
@@ -1490,14 +1567,6 @@ static void mlxsw_sp_fdb_fini(struct mlxsw_sp *mlxsw_sp)
 	cancel_delayed_work_sync(&mlxsw_sp->fdb_notify.dw);
 }
 
-static void mlxsw_sp_fids_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	u16 fid;
-
-	for_each_set_bit(fid, mlxsw_sp->active_fids, VLAN_N_VID)
-		mlxsw_sp_fid_destroy(mlxsw_sp, fid);
-}
-
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 {
 	return mlxsw_sp_fdb_init(mlxsw_sp);
@@ -1506,7 +1575,6 @@ int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	mlxsw_sp_fdb_fini(mlxsw_sp);
-	mlxsw_sp_fids_fini(mlxsw_sp);
 }
 
 int mlxsw_sp_port_vlan_init(struct mlxsw_sp_port *mlxsw_sp_port)
-- 
2.5.5
