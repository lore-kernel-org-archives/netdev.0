From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] mlxsw: spectrum: Teach mlxsw_sp_port_vlan_set to accept any vlan range
Date: Tue, 18 Apr 2017 16:55:35 +0200
Message-ID: <1492527338-13298-6-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36312 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754853AbdDROzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:48 -0400
Received: by mail-wr0-f194.google.com with SMTP id o21so25213906wrb.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:47 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far, mlxsw_sp_port_vlan_set range is limited by
MLXSW_REG_SPVM_REC_MAX_COUNT. In spectrum_switchdev code this is
wrapped up by a helper function which actually does multiple calls
to FW for bigger ranges. Move the code into mlxsw_sp_port_vlan_set
and use it always. That allows caller not to care about the range.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 25 ++++++++++++++--
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 33 ++++------------------
 2 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6e113c3..77b5bb3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1061,8 +1061,9 @@ mlxsw_sp_port_get_stats64(struct net_device *dev,
 	memcpy(stats, mlxsw_sp_port->hw_stats.cache, sizeof(*stats));
 }
 
-int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
-			   u16 vid_end, bool is_member, bool untagged)
+static int __mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u16 vid_begin, u16 vid_end,
+				    bool is_member, bool untagged)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char *spvm_pl;
@@ -1079,6 +1080,26 @@ int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 	return err;
 }
 
+int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
+			   u16 vid_end, bool is_member, bool untagged)
+{
+	u16 vid, vid_e;
+	int err;
+
+	for (vid = vid_begin; vid <= vid_end;
+	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
+		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
+			    vid_end);
+
+		err = __mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e,
+					       is_member, untagged);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mlxsw_sp_port_vp_mode_trans(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 05eaa15..0d8411f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -745,27 +745,6 @@ int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 	return err;
 }
 
-static int __mlxsw_sp_port_vlans_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 vid_begin, u16 vid_end, bool is_member,
-				     bool untagged)
-{
-	u16 vid, vid_e;
-	int err;
-
-	for (vid = vid_begin; vid <= vid_end;
-	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
-		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
-			    vid_end);
-
-		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e,
-					     is_member, untagged);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
 static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					  u16 vid_begin, u16 vid_end,
 					  bool learn_enable)
@@ -804,8 +783,8 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		return err;
 	}
 
-	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
-					true, flag_untagged);
+	err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid_begin, vid_end,
+				     true, flag_untagged);
 	if (err) {
 		netdev_err(dev, "Unable to add VIDs %d-%d\n", vid_begin,
 			   vid_end);
@@ -863,8 +842,8 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (old_pvid != mlxsw_sp_port->pvid)
 		mlxsw_sp_port_pvid_set(mlxsw_sp_port, old_pvid);
 err_port_pvid_set:
-	__mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end, false,
-				  false);
+	mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid_begin, vid_end,
+			       false, false);
 err_port_vlans_set:
 	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 	return err;
@@ -1171,8 +1150,8 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (pvid >= vid_begin && pvid <= vid_end)
 		mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
 
-	__mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end, false,
-				  false);
+	mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid_begin, vid_end,
+			       false, false);
 
 	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 
-- 
2.7.4
