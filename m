From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/14] mlxsw: reg: Add lag_vid field to SFD register
Date: Tue, 15 Dec 2015 16:03:45 +0100
Message-ID: <1450191827-6679-13-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36461 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933593AbbLOPEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:12 -0500
Received: by mail-wm0-f45.google.com with SMTP id n186so169122774wmn.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:12 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Unicast LAG records in the Switch Filtering Database (SFD) register have
a lag_vid field indicating the VLAN ID in case of vFIDs. This field is
no longer reserved since we are going to add support for VLAN devices on
top of LAG.

Add the lag_vid field to be used by VLAN devies on top of LAG.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h                | 10 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  2 +-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index be529e4..66d851d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -438,6 +438,13 @@ MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_sub_port, MLXSW_REG_SFD_BASE_LEN, 16, 8,
 MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_fid_vid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
 		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
 
+/* reg_sfd_uc_lag_lag_vid
+ * Indicates VID in case of vFIDs. Reserved for FIDs.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_lag_vid, MLXSW_REG_SFD_BASE_LEN, 16, 12,
+		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
+
 /* reg_sfd_uc_lag_lag_id
  * LAG Identifier - pointer into the LAG descriptor table.
  * Access: RW
@@ -449,7 +456,7 @@ static inline void
 mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
 			  enum mlxsw_reg_sfd_rec_policy policy,
 			  const char *mac, u16 fid_vid,
-			  enum mlxsw_reg_sfd_rec_action action,
+			  enum mlxsw_reg_sfd_rec_action action, u16 lag_vid,
 			  u16 lag_id)
 {
 	mlxsw_reg_sfd_rec_pack(payload, rec_index,
@@ -457,6 +464,7 @@ mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
 			       policy, mac, action);
 	mlxsw_reg_sfd_uc_lag_sub_port_set(payload, rec_index, 0);
 	mlxsw_reg_sfd_uc_lag_fid_vid_set(payload, rec_index, fid_vid);
+	mlxsw_reg_sfd_uc_lag_lag_vid_set(payload, rec_index, lag_vid);
 	mlxsw_reg_sfd_uc_lag_lag_id_set(payload, rec_index, lag_id);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index a428dfa..3eed8d7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -600,7 +600,7 @@ static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_lag_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
-				  mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
+				  mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP, 0,
 				  lag_id);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
-- 
1.9.3
