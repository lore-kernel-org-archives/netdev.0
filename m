From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/14] mlxsw: spectrum: Add support for VLAN devices bridging
Date: Tue, 15 Dec 2015 16:03:44 +0100
Message-ID: <1450191827-6679-12-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36421 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933578AbbLOPEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:11 -0500
Received: by mail-wm0-f46.google.com with SMTP id n186so169121608wmn.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:11 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

All the member VLAN devices in a bridge need to share the same vFID.

To achieve that, expand the vFID struct to include the associated bridge
device (or lack of) and allow one to lookup a vFID based on a bridge
device.

When joining a bridge, lookup the relevant vFID or create one if none
exists. Next, make the VLAN device use the vFID.

Leaving a bridge can either occur because a user removed the VLAN device
from a bridge or because the VLAN device was deleted by the user. In the
latter case the bridge's teardown sequence is invoked after the hardware
vPort is already gone. Therefore, when unlinking the VLAN device from
the real device, check if the associated vPort is bridged and act
accordingly. The bridge's notification will be ignored in this case.

Note that bridging a VLAN interface with an ordinary port netdev is
currently not supported, but not forbidden. This will be addressed in a
follow-up patchset.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 358 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  11 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  10 +-
 3 files changed, 378 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 159b18d..e5f888f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1851,6 +1851,7 @@ static int mlxsw_sp_init(void *priv, struct mlxsw_core *mlxsw_core,
 	mlxsw_sp->core = mlxsw_core;
 	mlxsw_sp->bus_info = mlxsw_bus_info;
 	INIT_LIST_HEAD(&mlxsw_sp->port_vfids.list);
+	INIT_LIST_HEAD(&mlxsw_sp->br_vfids.list);
 
 	err = mlxsw_sp_base_mac_get(mlxsw_sp);
 	if (err) {
@@ -2259,6 +2260,9 @@ static int mlxsw_sp_port_lag_changed(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_lag_tx_en_set(mlxsw_sp_port, info->tx_enabled);
 }
 
+static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+				       struct net_device *br_dev);
+
 static int mlxsw_sp_port_vlan_link(struct mlxsw_sp_port *mlxsw_sp_port,
 				   struct net_device *vlan_dev)
 {
@@ -2288,6 +2292,17 @@ static int mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -EINVAL;
 	}
 
+	/* When removing a VLAN device while still bridged we should first
+	 * remove it from the bridge, as we receive the bridge's notification
+	 * when the vPort is already gone.
+	 */
+	if (mlxsw_sp_vport->bridged) {
+		struct net_device *br_dev;
+
+		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, br_dev);
+	}
+
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
 
 	return 0;
@@ -2431,6 +2446,346 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 	return NOTIFY_DONE;
 }
 
+static struct mlxsw_sp_vfid *
+mlxsw_sp_br_vfid_find(const struct mlxsw_sp *mlxsw_sp,
+		      const struct net_device *br_dev)
+{
+	struct mlxsw_sp_vfid *vfid;
+
+	list_for_each_entry(vfid, &mlxsw_sp->br_vfids.list, list) {
+		if (vfid->br_dev == br_dev)
+			return vfid;
+	}
+
+	return NULL;
+}
+
+static u16 mlxsw_sp_vfid_to_br_vfid(u16 vfid)
+{
+	return vfid - MLXSW_SP_VFID_PORT_MAX;
+}
+
+static u16 mlxsw_sp_br_vfid_to_vfid(u16 br_vfid)
+{
+	return MLXSW_SP_VFID_PORT_MAX + br_vfid;
+}
+
+static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
+{
+	return find_first_zero_bit(mlxsw_sp->br_vfids.mapped,
+				   MLXSW_SP_VFID_BR_MAX);
+}
+
+static struct mlxsw_sp_vfid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
+						     struct net_device *br_dev)
+{
+	struct device *dev = mlxsw_sp->bus_info->dev;
+	struct mlxsw_sp_vfid *vfid;
+	u16 n_vfid;
+	int err;
+
+	n_vfid = mlxsw_sp_br_vfid_to_vfid(mlxsw_sp_avail_br_vfid_get(mlxsw_sp));
+	if (n_vfid == MLXSW_SP_VFID_MAX) {
+		dev_err(dev, "No available vFIDs\n");
+		return ERR_PTR(-ERANGE);
+	}
+
+	err = __mlxsw_sp_vfid_create(mlxsw_sp, n_vfid);
+	if (err) {
+		dev_err(dev, "Failed to create vFID=%d\n", n_vfid);
+		return ERR_PTR(err);
+	}
+
+	vfid = kzalloc(sizeof(*vfid), GFP_KERNEL);
+	if (!vfid)
+		goto err_allocate_vfid;
+
+	vfid->vfid = n_vfid;
+	vfid->br_dev = br_dev;
+
+	list_add(&vfid->list, &mlxsw_sp->br_vfids.list);
+	set_bit(mlxsw_sp_vfid_to_br_vfid(n_vfid), mlxsw_sp->br_vfids.mapped);
+
+	return vfid;
+
+err_allocate_vfid:
+	__mlxsw_sp_vfid_destroy(mlxsw_sp, n_vfid);
+	return ERR_PTR(-ENOMEM);
+}
+
+static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_vfid *vfid)
+{
+	u16 br_vfid = mlxsw_sp_vfid_to_br_vfid(vfid->vfid);
+
+	clear_bit(br_vfid, mlxsw_sp->br_vfids.mapped);
+	list_del(&vfid->list);
+
+	__mlxsw_sp_vfid_destroy(mlxsw_sp, vfid->vfid);
+
+	kfree(vfid);
+}
+
+static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+				       struct net_device *br_dev)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	struct net_device *dev = mlxsw_sp_vport->dev;
+	struct mlxsw_sp_vfid *vfid, *new_vfid;
+	int err;
+
+	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
+	if (!vfid) {
+		WARN_ON(!vfid);
+		return -EINVAL;
+	}
+
+	/* We need a vFID to go back to after leaving the bridge's vFID. */
+	new_vfid = mlxsw_sp_vfid_find(mlxsw_sp, vid);
+	if (!new_vfid) {
+		new_vfid = mlxsw_sp_vfid_create(mlxsw_sp, vid);
+		if (IS_ERR(new_vfid)) {
+			netdev_err(dev, "Failed to create vFID for VID=%d\n",
+				   vid);
+			return PTR_ERR(new_vfid);
+		}
+	}
+
+	/* Invalidate existing {Port, VID} to vFID mapping and create a new
+	 * one for the new vFID.
+	 */
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   false,
+					   mlxsw_sp_vfid_to_fid(vfid->vfid),
+					   vid);
+	if (err) {
+		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
+			   vfid->vfid);
+		goto err_port_vid_to_fid_invalidate;
+	}
+
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   true,
+					   mlxsw_sp_vfid_to_fid(new_vfid->vfid),
+					   vid);
+	if (err) {
+		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
+			   new_vfid->vfid);
+		goto err_port_vid_to_fid_validate;
+	}
+
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
+	if (err) {
+		netdev_err(dev, "Failed to disable learning\n");
+		goto err_port_vid_learning_set;
+	}
+
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false,
+				       false);
+	if (err) {
+		netdev_err(dev, "Failed clear to clear flooding\n");
+		goto err_vport_flood_set;
+	}
+
+	/* Switch between the vFIDs and destroy the old one if needed. */
+	new_vfid->nr_vports++;
+	mlxsw_sp_vport->vport.vfid = new_vfid;
+	vfid->nr_vports--;
+	if (!vfid->nr_vports)
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
+
+	mlxsw_sp_vport->learning = 0;
+	mlxsw_sp_vport->learning_sync = 0;
+	mlxsw_sp_vport->uc_flood = 0;
+	mlxsw_sp_vport->bridged = 0;
+
+	return 0;
+
+err_vport_flood_set:
+err_port_vid_learning_set:
+err_port_vid_to_fid_validate:
+err_port_vid_to_fid_invalidate:
+	/* Rollback vFID only if new. */
+	if (!new_vfid->nr_vports)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, new_vfid);
+	return err;
+}
+
+static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
+				      struct net_device *br_dev)
+{
+	struct mlxsw_sp_vfid *old_vfid = mlxsw_sp_vport->vport.vfid;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	struct net_device *dev = mlxsw_sp_vport->dev;
+	struct mlxsw_sp_vfid *vfid;
+	int err;
+
+	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
+	if (!vfid) {
+		vfid = mlxsw_sp_br_vfid_create(mlxsw_sp, br_dev);
+		if (IS_ERR(vfid)) {
+			netdev_err(dev, "Failed to create bridge vFID\n");
+			return PTR_ERR(vfid);
+		}
+	}
+
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, true, false);
+	if (err) {
+		netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
+			   vfid->vfid);
+		goto err_port_flood_set;
+	}
+
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
+	if (err) {
+		netdev_err(dev, "Failed to enable learning\n");
+		goto err_port_vid_learning_set;
+	}
+
+	/* We need to invalidate existing {Port, VID} to vFID mapping and
+	 * create a new one for the bridge's vFID.
+	 */
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   false,
+					   mlxsw_sp_vfid_to_fid(old_vfid->vfid),
+					   vid);
+	if (err) {
+		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
+			   old_vfid->vfid);
+		goto err_port_vid_to_fid_invalidate;
+	}
+
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   true,
+					   mlxsw_sp_vfid_to_fid(vfid->vfid),
+					   vid);
+	if (err) {
+		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
+			   vfid->vfid);
+		goto err_port_vid_to_fid_validate;
+	}
+
+	/* Switch between the vFIDs and destroy the old one if needed. */
+	vfid->nr_vports++;
+	mlxsw_sp_vport->vport.vfid = vfid;
+	old_vfid->nr_vports--;
+	if (!old_vfid->nr_vports)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, old_vfid);
+
+	mlxsw_sp_vport->learning = 1;
+	mlxsw_sp_vport->learning_sync = 1;
+	mlxsw_sp_vport->uc_flood = 1;
+	mlxsw_sp_vport->bridged = 1;
+
+	return 0;
+
+err_port_vid_to_fid_validate:
+	mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
+				     MLXSW_REG_SVFA_MT_PORT_VID_TO_FID, false,
+				     mlxsw_sp_vfid_to_fid(old_vfid->vfid), vid);
+err_port_vid_to_fid_invalidate:
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
+err_port_vid_learning_set:
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false, false);
+err_port_flood_set:
+	if (!vfid->nr_vports)
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
+	return err;
+}
+
+static bool
+mlxsw_sp_port_master_bridge_check(const struct mlxsw_sp_port *mlxsw_sp_port,
+				  const struct net_device *br_dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+
+	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
+			    vport.list) {
+		if (mlxsw_sp_vport_br_get(mlxsw_sp_vport) == br_dev)
+			return false;
+	}
+
+	return true;
+}
+
+static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
+					  unsigned long event, void *ptr,
+					  u16 vid)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct netdev_notifier_changeupper_info *info = ptr;
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct net_device *upper_dev;
+	int err;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (!info->master || !info->linking)
+			break;
+		if (!netif_is_bridge_master(upper_dev))
+			return NOTIFY_BAD;
+		/* We can't have multiple VLAN interfaces configured on
+		 * the same port and being members in the same bridge.
+		 */
+		if (!mlxsw_sp_port_master_bridge_check(mlxsw_sp_port,
+						       upper_dev))
+			return NOTIFY_BAD;
+		break;
+	case NETDEV_CHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (!info->master)
+			break;
+		if (info->linking) {
+			if (!mlxsw_sp_vport) {
+				WARN_ON(!mlxsw_sp_vport);
+				return NOTIFY_BAD;
+			}
+			err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
+							 upper_dev);
+			if (err) {
+				netdev_err(dev, "Failed to join bridge\n");
+				return NOTIFY_BAD;
+			}
+		} else {
+			/* We ignore bridge's unlinking notifications if vPort
+			 * is gone, since we already left the bridge when the
+			 * VLAN device was unlinked from the real device.
+			 */
+			if (!mlxsw_sp_vport)
+				return NOTIFY_DONE;
+			err = mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport,
+							  upper_dev);
+			if (err) {
+				netdev_err(dev, "Failed to leave bridge\n");
+				return NOTIFY_BAD;
+			}
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int mlxsw_sp_netdevice_vlan_event(struct net_device *vlan_dev,
+					 unsigned long event, void *ptr)
+{
+	struct net_device *real_dev = vlan_dev_real_dev(vlan_dev);
+	u16 vid = vlan_dev_vlan_id(vlan_dev);
+
+	if (!mlxsw_sp_port_dev_check(real_dev))
+		return NOTIFY_DONE;
+
+	return mlxsw_sp_netdevice_vport_event(real_dev, event, ptr, vid);
+}
+
 static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 				    unsigned long event, void *ptr)
 {
@@ -2442,6 +2797,9 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 	if (netif_is_lag_master(dev))
 		return mlxsw_sp_netdevice_lag_event(dev, event, ptr);
 
+	if (is_vlan_dev(dev))
+		return mlxsw_sp_netdevice_vlan_event(dev, event, ptr);
+
 	return NOTIFY_DONE;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 33794f2..463ed6d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -65,6 +65,7 @@ struct mlxsw_sp_vfid {
 	struct list_head list;
 	u16 nr_vports;
 	u16 vfid;	/* Starting at 0 */
+	struct net_device *br_dev;
 	u16 vid;
 };
 
@@ -88,6 +89,10 @@ struct mlxsw_sp {
 		struct list_head list;
 		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_VFID_PORT_MAX)];
 	} port_vfids;
+	struct {
+		struct list_head list;
+		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_VFID_BR_MAX)];
+	} br_vfids;
 	unsigned long active_fids[BITS_TO_LONGS(VLAN_N_VID)];
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
@@ -161,6 +166,12 @@ mlxsw_sp_port_is_vport(const struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port->vport.vfid;
 }
 
+static inline struct net_device *
+mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	return mlxsw_sp_vport->vport.vfid->br_dev;
+}
+
 static inline u16
 mlxsw_sp_vport_vid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e6e5b5e..a428dfa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -151,6 +151,11 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
 }
 
+static bool mlxsw_sp_vfid_is_vport_br(u16 vfid)
+{
+	return vfid >= MLXSW_SP_VFID_PORT_MAX;
+}
+
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 idx_begin, u16 idx_end, bool set,
 				     bool only_uc)
@@ -164,7 +169,10 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID;
-		local_port = MLXSW_PORT_CPU_PORT;
+		if (mlxsw_sp_vfid_is_vport_br(idx_begin))
+			local_port = mlxsw_sp_port->local_port;
+		else
+			local_port = MLXSW_PORT_CPU_PORT;
 	} else {
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
 	}
-- 
1.9.3
