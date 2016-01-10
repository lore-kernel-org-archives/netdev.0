From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: reg: Add definition of multicast record for SFD register
Date: Sun, 10 Jan 2016 14:07:23 +0100
Message-ID: <1452431248-5411-4-git-send-email-jiri@resnulli.us>
References: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38406 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756154AbcAJNHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 08:07:36 -0500
Received: by mail-wm0-f44.google.com with SMTP id b14so231829410wmb.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 05:07:35 -0800 (PST)
In-Reply-To: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Multicast-related records have specific format in SFD register.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 49 +++++++++++++++++++++++++++----
 1 file changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 66d851d..9b79457 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -287,6 +287,7 @@ MLXSW_ITEM32_INDEXED(reg, sfd, rec_swid, MLXSW_REG_SFD_BASE_LEN, 24, 8,
 enum mlxsw_reg_sfd_rec_type {
 	MLXSW_REG_SFD_REC_TYPE_UNICAST = 0x0,
 	MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG = 0x1,
+	MLXSW_REG_SFD_REC_TYPE_MULTICAST = 0x2,
 };
 
 /* reg_sfd_rec_type
@@ -379,7 +380,6 @@ MLXSW_ITEM32_INDEXED(reg, sfd, uc_system_port, MLXSW_REG_SFD_BASE_LEN, 0, 16,
 
 static inline void mlxsw_reg_sfd_rec_pack(char *payload, int rec_index,
 					  enum mlxsw_reg_sfd_rec_type rec_type,
-					  enum mlxsw_reg_sfd_rec_policy policy,
 					  const char *mac,
 					  enum mlxsw_reg_sfd_rec_action action)
 {
@@ -389,7 +389,6 @@ static inline void mlxsw_reg_sfd_rec_pack(char *payload, int rec_index,
 		mlxsw_reg_sfd_num_rec_set(payload, rec_index + 1);
 	mlxsw_reg_sfd_rec_swid_set(payload, rec_index, 0);
 	mlxsw_reg_sfd_rec_type_set(payload, rec_index, rec_type);
-	mlxsw_reg_sfd_rec_policy_set(payload, rec_index, policy);
 	mlxsw_reg_sfd_rec_mac_memcpy_to(payload, rec_index, mac);
 	mlxsw_reg_sfd_rec_action_set(payload, rec_index, action);
 }
@@ -401,8 +400,8 @@ static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
 					 u8 local_port)
 {
 	mlxsw_reg_sfd_rec_pack(payload, rec_index,
-			       MLXSW_REG_SFD_REC_TYPE_UNICAST,
-			       policy, mac, action);
+			       MLXSW_REG_SFD_REC_TYPE_UNICAST, mac, action);
+	mlxsw_reg_sfd_rec_policy_set(payload, rec_index, policy);
 	mlxsw_reg_sfd_uc_sub_port_set(payload, rec_index, 0);
 	mlxsw_reg_sfd_uc_fid_vid_set(payload, rec_index, fid_vid);
 	mlxsw_reg_sfd_uc_system_port_set(payload, rec_index, local_port);
@@ -461,7 +460,8 @@ mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
 {
 	mlxsw_reg_sfd_rec_pack(payload, rec_index,
 			       MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG,
-			       policy, mac, action);
+			       mac, action);
+	mlxsw_reg_sfd_rec_policy_set(payload, rec_index, policy);
 	mlxsw_reg_sfd_uc_lag_sub_port_set(payload, rec_index, 0);
 	mlxsw_reg_sfd_uc_lag_fid_vid_set(payload, rec_index, fid_vid);
 	mlxsw_reg_sfd_uc_lag_lag_vid_set(payload, rec_index, lag_vid);
@@ -477,6 +477,45 @@ static inline void mlxsw_reg_sfd_uc_lag_unpack(char *payload, int rec_index,
 	*p_lag_id = mlxsw_reg_sfd_uc_lag_lag_id_get(payload, rec_index);
 }
 
+/* reg_sfd_mc_pgi
+ *
+ * Multicast port group index - index into the port group table.
+ * Value 0x1FFF indicates the pgi should point to the MID entry.
+ * For Spectrum this value must be set to 0x1FFF
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, mc_pgi, MLXSW_REG_SFD_BASE_LEN, 16, 13,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_mc_fid_vid
+ *
+ * Filtering ID or VLAN ID
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, mc_fid_vid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_mc_mid
+ *
+ * Multicast identifier - global identifier that represents the multicast
+ * group across all devices.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, mc_mid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
+
+static inline void
+mlxsw_reg_sfd_mc_pack(char *payload, int rec_index,
+		      const char *mac, u16 fid_vid,
+		      enum mlxsw_reg_sfd_rec_action action, u16 mid)
+{
+	mlxsw_reg_sfd_rec_pack(payload, rec_index,
+			       MLXSW_REG_SFD_REC_TYPE_MULTICAST, mac, action);
+	mlxsw_reg_sfd_mc_pgi_set(payload, rec_index, 0x1FFF);
+	mlxsw_reg_sfd_mc_fid_vid_set(payload, rec_index, fid_vid);
+	mlxsw_reg_sfd_mc_mid_set(payload, rec_index, mid);
+}
+
 /* SFN - Switch FDB Notification Register
  * -------------------------------------------
  * The switch provides notifications on newly learned FDB entries and
-- 
1.9.3
