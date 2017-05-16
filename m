From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/12] mlxsw: spectrum_switchdev: Don't batch learning operations
Date: Tue, 16 May 2017 19:38:33 +0200
Message-ID: <20170516173835.2978-11-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33800 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdEPRix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id d127so39722545wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:52 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We no longer batch VLAN operations, so there's no need to set the
learning state for a range of VLANs.

Use a common function to set the learning state for a Port-VLAN, thereby
making the code saner more receptive for upcoming changes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 16 ++++------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  3 ---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  8 +++-----
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2f0e149..da15819 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -666,9 +666,8 @@ int mlxsw_sp_port_vid_to_fid_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(svfa), svfa_pl);
 }
 
-int __mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 vid_begin, u16 vid_end,
-				     bool learn_enable)
+int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
+				   bool learn_enable)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *spvmlr_pl;
@@ -677,20 +676,13 @@ int __mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	spvmlr_pl = kmalloc(MLXSW_REG_SPVMLR_LEN, GFP_KERNEL);
 	if (!spvmlr_pl)
 		return -ENOMEM;
-	mlxsw_reg_spvmlr_pack(spvmlr_pl, mlxsw_sp_port->local_port, vid_begin,
-			      vid_end, learn_enable);
+	mlxsw_reg_spvmlr_pack(spvmlr_pl, mlxsw_sp_port->local_port, vid, vid,
+			      learn_enable);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvmlr), spvmlr_pl);
 	kfree(spvmlr_pl);
 	return err;
 }
 
-int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
-				   bool learn_enable)
-{
-	return __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
-						learn_enable);
-}
-
 static int
 mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index d96e9126..aea321e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -442,9 +442,6 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				  enum mlxsw_reg_qeec_hr hr, u8 index,
 				  u8 next_index, u32 maxrate);
-int __mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 vid_begin, u16 vid_end,
-				     bool learn_enable);
 int mlxsw_sp_port_vid_stp_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
 			      u8 state);
 int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index ad5eefa..6fdcbcf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -322,13 +322,11 @@ static int mlxsw_sp_port_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
 		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 
-		return __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
-							set);
+		return mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, set);
 	}
 
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
-		err = __mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid,
-						       set);
+		err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, set);
 		if (err)
 			goto err_port_vid_learning_set;
 	}
@@ -337,7 +335,7 @@ static int mlxsw_sp_port_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 err_port_vid_learning_set:
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
-		__mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, vid, !set);
+		mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, !set);
 	return err;
 }
 
-- 
2.9.3
