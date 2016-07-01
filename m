From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 29/42] mlxsw: spectrum: Enable L3 interfaces on top of bridge devices
Date: Fri,  1 Jul 2016 16:04:57 +0200
Message-ID: <1467381910-3445-30-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34617 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbcGAOUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:20:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so5672275wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:20:05 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As with the previously introduced L3 interfaces, listen to 'inetaddr'
notifications sent for bridges devices configured on top of the port
netdevs and create / destroy router interfaces (RIFs) accordingly.
This also includes VLAN devices configured on top of the VLAN-aware
bridge.

The RIFs will be destroyed either when the last IP address is removed or
when the underlying FID is is destroyed.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 139 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   3 +
 3 files changed, 143 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e49f80ba..7b2b741b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2706,10 +2706,135 @@ static int mlxsw_sp_inetaddr_lag_event(struct net_device *lag_dev,
 	return __mlxsw_sp_inetaddr_lag_event(lag_dev, lag_dev, event, 1);
 }
 
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
+	if (rif == MLXSW_SP_RIF_MAX)
+		return -ERANGE;
+
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
+	if (err)
+		return err;
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
+	mlxsw_sp->rifs[rif] = NULL;
+	f->r = NULL;
+
+	kfree(r);
+
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
+
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
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
 static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 					unsigned long event)
 {
 	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_lower_get(vlan_dev);
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	if (mlxsw_sp_port_dev_check(real_dev))
@@ -2718,6 +2843,10 @@ static int mlxsw_sp_inetaddr_vlan_event(struct net_device *vlan_dev,
 	else if (netif_is_lag_master(real_dev))
 		return __mlxsw_sp_inetaddr_lag_event(vlan_dev, real_dev, event,
 						     vid);
+	else if (netif_is_bridge_master(real_dev) &&
+		 mlxsw_sp->master_bridge.dev == real_dev)
+		return mlxsw_sp_inetaddr_bridge_event(vlan_dev, real_dev,
+						      event);
 
 	return 0;
 }
@@ -2743,6 +2872,8 @@ static int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 		err = mlxsw_sp_inetaddr_port_event(dev, event);
 	else if (netif_is_lag_master(dev))
 		err = mlxsw_sp_inetaddr_lag_event(dev, event);
+	else if (netif_is_bridge_master(dev))
+		err = mlxsw_sp_inetaddr_bridge_event(dev, dev, event);
 	else if (is_vlan_dev(dev))
 		err = mlxsw_sp_inetaddr_vlan_event(dev, event);
 
@@ -3416,6 +3547,8 @@ static void mlxsw_sp_master_bridge_vlan_unlink(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_fid *f;
 
 	f = mlxsw_sp_fid_find(mlxsw_sp, fid);
+	if (f && f->r)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
 	if (f && --f->ref_count == 0)
 		mlxsw_sp_fid_destroy(mlxsw_sp, f);
 }
@@ -3514,13 +3647,17 @@ static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 				  struct mlxsw_sp_fid *f)
 {
 	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
+	u16 fid = f->fid;
 
 	clear_bit(vfid, mlxsw_sp->vfids.mapped);
 	list_del(&f->list);
 
-	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
+	if (f->r)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
 
 	kfree(f);
+
+	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
 }
 
 static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 17c5d3b..958e821 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -486,6 +486,8 @@ int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
 			bool adding);
 struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid);
 void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f);
+void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_rif *r);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e446640..a1ad5e6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -445,6 +445,9 @@ void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f)
 
 	list_del(&f->list);
 
+	if (f->r)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+
 	kfree(f);
 
 	mlxsw_sp_fid_op(mlxsw_sp, fid, false);
-- 
2.5.5
