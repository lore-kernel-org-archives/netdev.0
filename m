From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 25/42] mlxsw: spectrum: Edit RIF properties based on netdev events
Date: Fri,  1 Jul 2016 16:04:53 +0200
Message-ID: <1467381910-3445-26-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34261 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbcGAOWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:22:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so5685489wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:22:20 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We are just about to introduce router interfaces (RIFs), but before that
we need to be able update the device with the correct RIF attributes
whenever they change for the netdev the RIF is backing. Two such
attributes are MTU and MAC.

The MAC is used both to set the source MAC of packets egressing from the
RIF and also to program an FDB rule that will direct packets to the
router block.

Use the existing netdevice notification block and respond to CHANGEADDR
and CHANGEMTU accordingly. Store both attributes in the RIF struct
in case we need to revert to old attributes following a failed update.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 61 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  5 ++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 26 +++++++--
 3 files changed, 86 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f54fd6a..284f6ab 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2627,6 +2627,63 @@ void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port)
 	dev_put(mlxsw_sp_port->dev);
 }
 
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
+static int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
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
 static bool mlxsw_sp_lag_port_fid_member(struct mlxsw_sp_port *lag_port,
 					 u16 fid)
 {
@@ -3487,7 +3544,9 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	int err = 0;
 
-	if (mlxsw_sp_port_dev_check(dev))
+	if (event == NETDEV_CHANGEADDR || event == NETDEV_CHANGEMTU)
+		err = mlxsw_sp_netdevice_router_port_event(dev);
+	else if (mlxsw_sp_port_dev_check(dev))
 		err = mlxsw_sp_netdevice_port_event(dev, event, ptr);
 	else if (netif_is_lag_master(dev))
 		err = mlxsw_sp_netdevice_lag_event(dev, event, ptr);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index fefff25..0d3e0e3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -107,6 +107,9 @@ struct mlxsw_sp_fid {
 
 struct mlxsw_sp_rif {
 	struct net_device *dev;
+	struct mlxsw_sp_fid *f;
+	unsigned char addr[ETH_ALEN];
+	int mtu;
 	u16 rif;
 };
 
@@ -448,6 +451,8 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid);
+int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
+			bool adding);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 4decc30..06f433a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -753,9 +753,10 @@ static enum mlxsw_reg_sfd_op mlxsw_sp_sfd_op(bool adding)
 			MLXSW_REG_SFD_OP_WRITE_REMOVE;
 }
 
-static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				   const char *mac, u16 fid, bool adding,
-				   bool dynamic)
+static int __mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				     const char *mac, u16 fid, bool adding,
+				     enum mlxsw_reg_sfd_rec_action action,
+				     bool dynamic)
 {
 	char *sfd_pl;
 	int err;
@@ -766,14 +767,29 @@ static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
-			      mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
-			      local_port);
+			      mac, fid, action, local_port);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
 
 	return err;
 }
 
+static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				   const char *mac, u16 fid, bool adding,
+				   bool dynamic)
+{
+	return __mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid, adding,
+					 MLXSW_REG_SFD_REC_ACTION_NOP, dynamic);
+}
+
+int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
+			bool adding)
+{
+	return __mlxsw_sp_port_fdb_uc_op(mlxsw_sp, 0, mac, fid, adding,
+					 MLXSW_REG_SFD_REC_ACTION_FORWARD_IP_ROUTER,
+					 false);
+}
+
 static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
 				       const char *mac, u16 fid, u16 lag_vid,
 				       bool adding, bool dynamic)
-- 
2.5.5
