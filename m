From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/14] mlxsw: spectrum: Configure FIDs based on bridge events
Date: Mon,  4 Jul 2016 08:23:16 +0200
Message-ID: <1467613397-17140-14-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35988 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbcGDGXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:38 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so19140615wme.3
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:37 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Before introducing support for L3 interfaces on top of the VLAN-aware
bridge we need to add some missing infrastructure.

Such an interface can either be the bridge device itself or a VLAN
device on top of it. In the first case the router interface (RIF) is
associated with FID 1, which is created whenever the first port netdev
joins the bridge. We currently assume the default PVID is 1 and that
it's already created, as it seems reasonable. This can be extended in
the future.

However, in the second case it's entirely possible we've yet to create a
matching FID. This can happen if the VLAN device was configured before
making any bridge port member in the VLAN.

Prevent such ordering problems by using the VLAN device's CHANGEUPPER
event to configure the FID. Make the VLAN device hold a reference to the
FID and prevent it from being destroyed even if none of the port netdevs
is using it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 86 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 27 +++++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 18 +----
 3 files changed, 107 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e987a8a..e49f80ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2887,6 +2887,17 @@ int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
 		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_port, fid);
 }
 
+static void mlxsw_sp_master_bridge_gone_sync(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_fid *f, *tmp;
+
+	list_for_each_entry_safe(f, tmp, &mlxsw_sp->fids, list)
+		if (--f->ref_count == 0)
+			mlxsw_sp_fid_destroy(mlxsw_sp, f);
+		else
+			WARN_ON_ONCE(1);
+}
+
 static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
 					 struct net_device *br_dev)
 {
@@ -2903,8 +2914,15 @@ static void mlxsw_sp_master_bridge_inc(struct mlxsw_sp *mlxsw_sp,
 
 static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp)
 {
-	if (--mlxsw_sp->master_bridge.ref_count == 0)
+	if (--mlxsw_sp->master_bridge.ref_count == 0) {
 		mlxsw_sp->master_bridge.dev = NULL;
+		/* It's possible upper VLAN devices are still holding
+		 * references to underlying FIDs. Drop the reference
+		 * and release the resources if it was the last one.
+		 * If it wasn't, then something bad happened.
+		 */
+		mlxsw_sp_master_bridge_gone_sync(mlxsw_sp);
+	}
 }
 
 static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -3373,18 +3391,68 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 	return 0;
 }
 
-static struct mlxsw_sp_fid *
-mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp,
-		   const struct net_device *br_dev)
+static int mlxsw_sp_master_bridge_vlan_link(struct mlxsw_sp *mlxsw_sp,
+					    struct net_device *vlan_dev)
 {
+	u16 fid = vlan_dev_vlan_id(vlan_dev);
 	struct mlxsw_sp_fid *f;
 
-	list_for_each_entry(f, &mlxsw_sp->vfids.list, list) {
-		if (f->dev == br_dev)
-			return f;
+	f = mlxsw_sp_fid_find(mlxsw_sp, fid);
+	if (!f) {
+		f = mlxsw_sp_fid_create(mlxsw_sp, fid);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
 	}
 
-	return NULL;
+	f->ref_count++;
+
+	return 0;
+}
+
+static void mlxsw_sp_master_bridge_vlan_unlink(struct mlxsw_sp *mlxsw_sp,
+					       struct net_device *vlan_dev)
+{
+	u16 fid = vlan_dev_vlan_id(vlan_dev);
+	struct mlxsw_sp_fid *f;
+
+	f = mlxsw_sp_fid_find(mlxsw_sp, fid);
+	if (f && --f->ref_count == 0)
+		mlxsw_sp_fid_destroy(mlxsw_sp, f);
+}
+
+static int mlxsw_sp_netdevice_bridge_event(struct net_device *br_dev,
+					   unsigned long event, void *ptr)
+{
+	struct netdev_notifier_changeupper_info *info;
+	struct net_device *upper_dev;
+	struct mlxsw_sp *mlxsw_sp;
+	int err;
+
+	mlxsw_sp = mlxsw_sp_lower_get(br_dev);
+	if (!mlxsw_sp)
+		return 0;
+	if (br_dev != mlxsw_sp->master_bridge.dev)
+		return 0;
+
+	info = ptr;
+
+	switch (event) {
+	case NETDEV_CHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (!is_vlan_dev(upper_dev))
+			break;
+		if (info->linking) {
+			err = mlxsw_sp_master_bridge_vlan_link(mlxsw_sp,
+							       upper_dev);
+			if (err)
+				return err;
+		} else {
+			mlxsw_sp_master_bridge_vlan_unlink(mlxsw_sp, upper_dev);
+		}
+		break;
+	}
+
+	return 0;
 }
 
 static u16 mlxsw_sp_avail_vfid_get(const struct mlxsw_sp *mlxsw_sp)
@@ -3675,6 +3743,8 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 		err = mlxsw_sp_netdevice_port_event(dev, event, ptr);
 	else if (netif_is_lag_master(dev))
 		err = mlxsw_sp_netdevice_lag_event(dev, event, ptr);
+	else if (netif_is_bridge_master(dev))
+		err = mlxsw_sp_netdevice_bridge_event(dev, event, ptr);
 	else if (is_vlan_dev(dev))
 		err = mlxsw_sp_netdevice_vlan_event(dev, event, ptr);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b15b47b..17c5d3b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -387,6 +387,31 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 	return NULL;
 }
 
+static inline struct mlxsw_sp_fid *mlxsw_sp_fid_find(struct mlxsw_sp *mlxsw_sp,
+						     u16 fid)
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
+static inline struct mlxsw_sp_fid *
+mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp,
+		   const struct net_device *br_dev)
+{
+	struct mlxsw_sp_fid *f;
+
+	list_for_each_entry(f, &mlxsw_sp->vfids.list, list)
+		if (f->dev == br_dev)
+			return f;
+
+	return NULL;
+}
+
 static inline struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev)
@@ -459,6 +484,8 @@ int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid);
 int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
 			bool adding);
+struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid);
+void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 941acd7..e446640 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -374,18 +374,6 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 	return err;
 }
 
-static struct mlxsw_sp_fid *mlxsw_sp_fid_find(struct mlxsw_sp *mlxsw_sp,
-					      u16 fid)
-{
-	struct mlxsw_sp_fid *f;
-
-	list_for_each_entry(f, &mlxsw_sp->fids, list)
-		if (f->fid == fid)
-			return f;
-
-	return NULL;
-}
-
 static int mlxsw_sp_fid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 {
 	char sfmr_pl[MLXSW_REG_SFMR_LEN];
@@ -416,8 +404,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_fid_alloc(u16 fid)
 	return f;
 }
 
-static struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp,
-						u16 fid)
+struct mlxsw_sp_fid *mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid)
 {
 	struct mlxsw_sp_fid *f;
 	int err;
@@ -452,8 +439,7 @@ err_fid_map:
 	return ERR_PTR(err);
 }
 
-static void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_fid *f)
+void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f)
 {
 	u16 fid = f->fid;
 
-- 
2.5.5
