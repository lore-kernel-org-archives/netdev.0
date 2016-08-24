From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] mlxsw: spectrum: Configure learning for VLAN-aware bridge port
Date: Wed, 24 Aug 2016 12:00:26 +0200
Message-ID: <1472032829-6322-5-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34575 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932436AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1862102wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:37 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We are going to prevent the device from generating learning
notifications for a port that was configured with learning disabled.

Since learning configuration is done per {Port, VID} we need to apply
the port's learning configuration for any VID that is added to the
bridge port's VLAN filter list.

When a VID is added to the VLAN filter list of a VLAN-aware bridge port,
configure the {Port, VID} learning status according to the port's
configuration. When the VID is removed, disable learning for the {Port,
VID}.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 16 +++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 ++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 35 ++++++++++++++++++++++
 3 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1f81689..3820317 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -555,8 +555,9 @@ int mlxsw_sp_port_vid_to_fid_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(svfa), svfa_pl);
 }
 
-static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
-					  u16 vid, bool learn_enable)
+int __mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 vid_begin, u16 vid_end,
+				     bool learn_enable)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *spvmlr_pl;
@@ -565,13 +566,20 @@ static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	spvmlr_pl = kmalloc(MLXSW_REG_SPVMLR_LEN, GFP_KERNEL);
 	if (!spvmlr_pl)
 		return -ENOMEM;
-	mlxsw_reg_spvmlr_pack(spvmlr_pl, mlxsw_sp_port->local_port, vid, vid,
-			      learn_enable);
+	mlxsw_reg_spvmlr_pack(spvmlr_pl, mlxsw_sp_port->local_port, vid_begin,
+			      vid_end, learn_enable);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvmlr), spvmlr_pl);
 	kfree(spvmlr_pl);
 	return err;
 }
 
+static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  u16 vid, bool learn_enable)
+{
+	return __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
+						learn_enable);
+}
+
 static int
 mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ab3feb8..01537d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -558,6 +558,9 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				  enum mlxsw_reg_qeec_hr hr, u8 index,
 				  u8 next_index, u32 maxrate);
+int __mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 vid_begin, u16 vid_end,
+				     bool learn_enable);
 
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e5cf8a5..d1b2b11 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -635,6 +635,27 @@ static int __mlxsw_sp_port_vlans_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  u16 vid_begin, u16 vid_end,
+					  bool learn_enable)
+{
+	u16 vid, vid_e;
+	int err;
+
+	for (vid = vid_begin; vid <= vid_end;
+	     vid += MLXSW_REG_SPVMLR_REC_MAX_COUNT) {
+		vid_e = min((u16) (vid + MLXSW_REG_SPVMLR_REC_MAX_COUNT - 1),
+			    vid_end);
+
+		err = __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid,
+						       vid_e, learn_enable);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end,
 				     bool flag_untagged, bool flag_pvid)
@@ -675,6 +696,14 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		}
 	}
 
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid_begin, vid_end,
+					     mlxsw_sp_port->learning);
+	if (err) {
+		netdev_err(dev, "Failed to set learning for VIDs %d-%d\n",
+			   vid_begin, vid_end);
+		goto err_port_vid_learning_set;
+	}
+
 	/* Changing activity bits only if HW operation succeded */
 	for (vid = vid_begin; vid <= vid_end; vid++) {
 		set_bit(vid, mlxsw_sp_port->active_vlans);
@@ -697,6 +726,9 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 err_port_stp_state_set:
 	for (vid = vid_begin; vid <= vid_end; vid++)
 		clear_bit(vid, mlxsw_sp_port->active_vlans);
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid_begin, vid_end,
+				       false);
+err_port_vid_learning_set:
 	if (old_pvid != mlxsw_sp_port->pvid)
 		mlxsw_sp_port_pvid_set(mlxsw_sp_port, old_pvid);
 err_port_pvid_set:
@@ -1006,6 +1038,9 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!mlxsw_sp_port->bridged)
 		return -EINVAL;
 
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid_begin, vid_end,
+				       false);
+
 	pvid = mlxsw_sp_port->pvid;
 	if (pvid >= vid_begin && pvid <= vid_end)
 		mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
-- 
2.5.5
