From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/8] mlxsw: Adding layer 2 multicast support
Date: Sun, 10 Jan 2016 21:06:28 +0100
Message-ID: <1452456389-2833-8-git-send-email-jiri@resnulli.us>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36440 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbcAJUGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:06:40 -0500
Received: by mail-wm0-f41.google.com with SMTP id l65so189135333wmf.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:06:40 -0800 (PST)
In-Reply-To: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Add SWITCHDEV_OBJ_ID_PORT_MDB switchdev ops support. On first MDB insertion
creates a new multicast group (MID) and add members port to the MID. Also
add new MDB entry for the flooding-domain (fid-vid) and link the MDB entry
to the newly constructed MC group.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- changed GFP_ATOMIC to GFP_KERNEL in __mlxsw_sp_mc_alloc as suggested by Nik
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  13 ++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 176 +++++++++++++++++++++
 3 files changed, 190 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d0e98b8..ce6845d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1858,6 +1858,7 @@ static int mlxsw_sp_init(void *priv, struct mlxsw_core *mlxsw_core,
 	mlxsw_sp->bus_info = mlxsw_bus_info;
 	INIT_LIST_HEAD(&mlxsw_sp->port_vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_vfids.list);
+	INIT_LIST_HEAD(&mlxsw_sp->br_mids.list);
 
 	err = mlxsw_sp_base_mac_get(mlxsw_sp);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f360618..a23dc61 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -44,6 +44,7 @@
 #include <linux/list.h>
 #include <net/switchdev.h>
 
+#include "port.h"
 #include "core.h"
 
 #define MLXSW_SP_VFID_BASE VLAN_N_VID
@@ -71,6 +72,14 @@ struct mlxsw_sp_vfid {
 	u16 vid;
 };
 
+struct mlxsw_sp_mid {
+	struct list_head list;
+	unsigned char addr[ETH_ALEN];
+	u16 vid;
+	u16 mid;
+	unsigned int ref_count;
+};
+
 static inline u16 mlxsw_sp_vfid_to_fid(u16 vfid)
 {
 	return MLXSW_SP_VFID_BASE + vfid;
@@ -95,6 +104,10 @@ struct mlxsw_sp {
 		struct list_head list;
 		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_VFID_BR_MAX)];
 	} br_vfids;
+	struct {
+		struct list_head list;
+		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_MID_MAX)];
+	} br_mids;
 	unsigned long active_fids[BITS_TO_LONGS(VLAN_N_VID)];
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index aa8e2f5..aad05d4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -679,6 +679,143 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 						   true, false);
 }
 
+static int mlxsw_sp_port_mdb_op(struct mlxsw_sp *mlxsw_sp, const char *addr,
+				u16 fid, u16 mid, bool adding)
+{
+	char *sfd_pl;
+	int err;
+
+	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
+	if (!sfd_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
+	mlxsw_reg_sfd_mc_pack(sfd_pl, 0, addr, fid,
+			      MLXSW_REG_SFD_REC_ACTION_NOP, mid);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
+	kfree(sfd_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
+				  bool add, bool clear_all_ports)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *smid_pl;
+	int err, i;
+
+	smid_pl = kmalloc(MLXSW_REG_SMID_LEN, GFP_KERNEL);
+	if (!smid_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_smid_pack(smid_pl, mid, mlxsw_sp_port->local_port, add);
+	if (clear_all_ports) {
+		for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+			if (mlxsw_sp->ports[i])
+				mlxsw_reg_smid_port_mask_set(smid_pl, i, 1);
+	}
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(smid), smid_pl);
+	kfree(smid_pl);
+	return err;
+}
+
+static struct mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp *mlxsw_sp,
+					      const unsigned char *addr,
+					      u16 vid)
+{
+	struct mlxsw_sp_mid *mid;
+
+	list_for_each_entry(mid, &mlxsw_sp->br_mids.list, list) {
+		if (ether_addr_equal(mid->addr, addr) && mid->vid == vid)
+			return mid;
+	}
+	return NULL;
+}
+
+static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
+						const unsigned char *addr,
+						u16 vid)
+{
+	struct mlxsw_sp_mid *mid;
+	u16 mid_idx;
+
+	mid_idx = find_first_zero_bit(mlxsw_sp->br_mids.mapped,
+				      MLXSW_SP_MID_MAX);
+	if (mid_idx == MLXSW_SP_MID_MAX)
+		return NULL;
+
+	mid = kzalloc(sizeof(*mid), GFP_KERNEL);
+	if (!mid)
+		return NULL;
+
+	set_bit(mid_idx, mlxsw_sp->br_mids.mapped);
+	ether_addr_copy(mid->addr, addr);
+	mid->vid = vid;
+	mid->mid = mid_idx;
+	mid->ref_count = 0;
+	list_add_tail(&mid->list, &mlxsw_sp->br_mids.list);
+
+	return mid;
+}
+
+static int __mlxsw_sp_mc_dec_ref(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_mid *mid)
+{
+	if (--mid->ref_count == 0) {
+		list_del(&mid->list);
+		clear_bit(mid->mid, mlxsw_sp->br_mids.mapped);
+		kfree(mid);
+		return 1;
+	}
+	return 0;
+}
+
+static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
+				 const struct switchdev_obj_port_mdb *mdb,
+				 struct switchdev_trans *trans)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct net_device *dev = mlxsw_sp_port->dev;
+	struct mlxsw_sp_mid *mid;
+	u16 fid = mlxsw_sp_port_vid_to_fid_get(mlxsw_sp_port, mdb->vid);
+	int err = 0;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, mdb->vid);
+	if (!mid) {
+		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, mdb->addr, mdb->vid);
+		if (!mid) {
+			netdev_err(dev, "Unable to allocate MC group\n");
+			return -ENOMEM;
+		}
+	}
+	mid->ref_count++;
+
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true,
+				     mid->ref_count == 1);
+	if (err) {
+		netdev_err(dev, "Unable to set SMID\n");
+		goto err_out;
+	}
+
+	if (mid->ref_count == 1) {
+		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid, mid->mid,
+					   true);
+		if (err) {
+			netdev_err(dev, "Unable to set MC SFD\n");
+			goto err_out;
+		}
+	}
+
+	return 0;
+
+err_out:
+	__mlxsw_sp_mc_dec_ref(mlxsw_sp, mid);
+	return err;
+}
+
 static int mlxsw_sp_port_obj_add(struct net_device *dev,
 				 const struct switchdev_obj *obj,
 				 struct switchdev_trans *trans)
@@ -704,6 +841,11 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 						   SWITCHDEV_OBJ_PORT_FDB(obj),
 						   trans);
 		break;
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		err = mlxsw_sp_port_mdb_add(mlxsw_sp_port,
+					    SWITCHDEV_OBJ_PORT_MDB(obj),
+					    trans);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -817,6 +959,37 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 						   false, false);
 }
 
+static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
+				 const struct switchdev_obj_port_mdb *mdb)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct net_device *dev = mlxsw_sp_port->dev;
+	struct mlxsw_sp_mid *mid;
+	u16 fid = mlxsw_sp_port_vid_to_fid_get(mlxsw_sp_port, mdb->vid);
+	u16 mid_idx;
+	int err = 0;
+
+	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, mdb->vid);
+	if (!mid) {
+		netdev_err(dev, "Unable to remove port from MC DB\n");
+		return -EINVAL;
+	}
+
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false, false);
+	if (err)
+		netdev_err(dev, "Unable to remove port from SMID\n");
+
+	mid_idx = mid->mid;
+	if (__mlxsw_sp_mc_dec_ref(mlxsw_sp, mid)) {
+		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid, mid_idx,
+					   false);
+		if (err)
+			netdev_err(dev, "Unable to remove MC SFD\n");
+	}
+
+	return err;
+}
+
 static int mlxsw_sp_port_obj_del(struct net_device *dev,
 				 const struct switchdev_obj *obj)
 {
@@ -839,6 +1012,9 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 		err = mlxsw_sp_port_fdb_static_del(mlxsw_sp_port,
 						   SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		err = mlxsw_sp_port_mdb_del(mlxsw_sp_port,
+					    SWITCHDEV_OBJ_PORT_MDB(obj));
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.9.3
