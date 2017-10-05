From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] mlxsw: spectrum_switchdev: Support bridge mrouter notifications
Date: Thu,  5 Oct 2017 12:36:42 +0200
Message-ID: <20171005103642.1414-7-jiri@resnulli.us>
References: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:49349 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdJEKgy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:54 -0400
Received: by mail-wm0-f68.google.com with SMTP id b189so1223549wmd.4
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:54 -0700 (PDT)
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Support the SWITCHDEV_ATTR_ID_BRIDGE_MROUTER port attribute switchdev
notification.

To do that, add the mrouter flag to struct mlxsw_sp_bridge_device, which
indicates whether the bridge device was set to be mrouter port. This field
is set when:
 - A new bridge is created, where the value is taken from the kernel
   bridge value.
 - A switchdev SWITCHDEV_ATTR_ID_BRIDGE_MROUTER notification is sent.

In addition, change the bridge MID entries to include the router port when
the bridge device is configured to be mrouter port. The MID entries are
updated in the following cases:
 - When a new MID entry is created, update the router port according to the
   bridge mrouter state.
 - When a SWITCHDEV_ATTR_ID_BRIDGE_MROUTER notification is sent, update all
   the bridge's MID entries.

This is aligned with the case where a bridge slave is configured to be
mrouter port.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 65 +++++++++++++++++++++-
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 092231a..15bb5f9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -79,7 +79,8 @@ struct mlxsw_sp_bridge_device {
 	struct list_head ports_list;
 	struct list_head mids_list;
 	u8 vlan_enabled:1,
-	   multicast_enabled:1;
+	   multicast_enabled:1,
+	   mrouter:1;
 	const struct mlxsw_sp_bridge_ops *ops;
 };
 
@@ -169,6 +170,7 @@ mlxsw_sp_bridge_device_create(struct mlxsw_sp_bridge *bridge,
 	bridge_device->dev = br_dev;
 	bridge_device->vlan_enabled = vlan_enabled;
 	bridge_device->multicast_enabled = br_multicast_enabled(br_dev);
+	bridge_device->mrouter = br_multicast_router(br_dev);
 	INIT_LIST_HEAD(&bridge_device->ports_list);
 	if (vlan_enabled) {
 		bridge->vlan_enabled_exists = true;
@@ -811,6 +813,60 @@ static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static int mlxsw_sp_smid_router_port_set(struct mlxsw_sp *mlxsw_sp,
+					 u16 mid_idx, bool add)
+{
+	char *smid_pl;
+	int err;
+
+	smid_pl = kmalloc(MLXSW_REG_SMID_LEN, GFP_KERNEL);
+	if (!smid_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_smid_pack(smid_pl, mid_idx,
+			    mlxsw_sp_router_port(mlxsw_sp), add);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(smid), smid_pl);
+	kfree(smid_pl);
+	return err;
+}
+
+static void
+mlxsw_sp_bridge_mrouter_update_mdb(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_bridge_device *bridge_device,
+				   bool add)
+{
+	struct mlxsw_sp_mid *mid;
+
+	list_for_each_entry(mid, &bridge_device->mids_list, list)
+		mlxsw_sp_smid_router_port_set(mlxsw_sp, mid->mid, add);
+}
+
+static int
+mlxsw_sp_port_attr_br_mrouter_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				  struct switchdev_trans *trans,
+				  struct net_device *orig_dev,
+				  bool is_mrouter)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_bridge_device *bridge_device;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	/* It's possible we failed to enslave the port, yet this
+	 * operation is executed due to it being deferred.
+	 */
+	bridge_device = mlxsw_sp_bridge_device_find(mlxsw_sp->bridge, orig_dev);
+	if (!bridge_device)
+		return 0;
+
+	if (bridge_device->mrouter != is_mrouter)
+		mlxsw_sp_bridge_mrouter_update_mdb(mlxsw_sp, bridge_device,
+						   is_mrouter);
+	bridge_device->mrouter = is_mrouter;
+	return 0;
+}
+
 static int mlxsw_sp_port_attr_set(struct net_device *dev,
 				  const struct switchdev_attr *attr,
 				  struct switchdev_trans *trans)
@@ -848,6 +904,11 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 						    attr->orig_dev,
 						    attr->u.mc_disabled);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_MROUTER:
+		err = mlxsw_sp_port_attr_br_mrouter_set(mlxsw_sp_port, trans,
+							attr->orig_dev,
+							attr->u.mrouter);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -1371,7 +1432,7 @@ mlxsw_sp_mc_write_mdb_entry(struct mlxsw_sp *mlxsw_sp,
 
 	mid->mid = mid_idx;
 	err = mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid_idx, flood_bitmap,
-					    false);
+					    bridge_device->mrouter);
 	kfree(flood_bitmap);
 	if (err)
 		return false;
-- 
2.9.5
