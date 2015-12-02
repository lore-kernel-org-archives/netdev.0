From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 24/28] mlxsw: reg: Add definition of LAG unicast record for SFD register
Date: Wed,  2 Dec 2015 21:07:47 +0100
Message-ID: <1449086871-19911-25-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:32827 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031AbbLBUI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:26 -0500
Received: by wmec201 with SMTP id c201so270765443wme.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:25 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

LAG-related records have specific format in SFD register.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 79 +++++++++++++++++++++++++++----
 1 file changed, 71 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 049abbb..431b28e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -286,6 +286,7 @@ MLXSW_ITEM32_INDEXED(reg, sfd, rec_swid, MLXSW_REG_SFD_BASE_LEN, 24, 8,
 
 enum mlxsw_reg_sfd_rec_type {
 	MLXSW_REG_SFD_REC_TYPE_UNICAST = 0x0,
+	MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG = 0x1,
 };
 
 /* reg_sfd_rec_type
@@ -376,24 +377,34 @@ MLXSW_ITEM32_INDEXED(reg, sfd, uc_fid_vid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
 MLXSW_ITEM32_INDEXED(reg, sfd, uc_system_port, MLXSW_REG_SFD_BASE_LEN, 0, 16,
 		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
 
-static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
-					 enum mlxsw_reg_sfd_rec_policy policy,
-					 const char *mac, u16 vid,
-					 enum mlxsw_reg_sfd_rec_action action,
-					 u8 local_port)
+static inline void mlxsw_reg_sfd_rec_pack(char *payload, int rec_index,
+					  enum mlxsw_reg_sfd_rec_type rec_type,
+					  enum mlxsw_reg_sfd_rec_policy policy,
+					  const char *mac,
+					  enum mlxsw_reg_sfd_rec_action action)
 {
 	u8 num_rec = mlxsw_reg_sfd_num_rec_get(payload);
 
 	if (rec_index >= num_rec)
 		mlxsw_reg_sfd_num_rec_set(payload, rec_index + 1);
 	mlxsw_reg_sfd_rec_swid_set(payload, rec_index, 0);
-	mlxsw_reg_sfd_rec_type_set(payload, rec_index,
-				   MLXSW_REG_SFD_REC_TYPE_UNICAST);
+	mlxsw_reg_sfd_rec_type_set(payload, rec_index, rec_type);
 	mlxsw_reg_sfd_rec_policy_set(payload, rec_index, policy);
 	mlxsw_reg_sfd_rec_mac_memcpy_to(payload, rec_index, mac);
+	mlxsw_reg_sfd_rec_action_set(payload, rec_index, action);
+}
+
+static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
+					 enum mlxsw_reg_sfd_rec_policy policy,
+					 const char *mac, u16 vid,
+					 enum mlxsw_reg_sfd_rec_action action,
+					 u8 local_port)
+{
+	mlxsw_reg_sfd_rec_pack(payload, rec_index,
+			       MLXSW_REG_SFD_REC_TYPE_UNICAST,
+			       policy, mac, action);
 	mlxsw_reg_sfd_uc_sub_port_set(payload, rec_index, 0);
 	mlxsw_reg_sfd_uc_fid_vid_set(payload, rec_index, vid);
-	mlxsw_reg_sfd_rec_action_set(payload, rec_index, action);
 	mlxsw_reg_sfd_uc_system_port_set(payload, rec_index, local_port);
 }
 
@@ -406,6 +417,58 @@ static inline void mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
 	*p_local_port = mlxsw_reg_sfd_uc_system_port_get(payload, rec_index);
 }
 
+/* reg_sfd_uc_lag_sub_port
+ * LAG sub port.
+ * Must be 0 if multichannel VEPA is not enabled.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_sub_port, MLXSW_REG_SFD_BASE_LEN, 16, 8,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_uc_lag_fid_vid
+ * Filtering ID or VLAN ID
+ * For SwitchX and SwitchX-2:
+ * - Dynamic entries (policy 2,3) use FID
+ * - Static entries (policy 0) use VID
+ * - When independent learning is configured, VID=FID
+ * For Spectrum: use FID for both Dynamic and Static entries.
+ * VID should not be used.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_fid_vid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_uc_lag_lag_id
+ * LAG Identifier - pointer into the LAG descriptor table.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_lag_lag_id, MLXSW_REG_SFD_BASE_LEN, 0, 10,
+		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
+
+static inline void
+mlxsw_reg_sfd_uc_lag_pack(char *payload, int rec_index,
+			  enum mlxsw_reg_sfd_rec_policy policy,
+			  const char *mac, u16 vid,
+			  enum mlxsw_reg_sfd_rec_action action,
+			  u16 lag_id)
+{
+	mlxsw_reg_sfd_rec_pack(payload, rec_index,
+			       MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG,
+			       policy, mac, action);
+	mlxsw_reg_sfd_uc_lag_sub_port_set(payload, rec_index, 0);
+	mlxsw_reg_sfd_uc_lag_fid_vid_set(payload, rec_index, vid);
+	mlxsw_reg_sfd_uc_lag_lag_id_set(payload, rec_index, lag_id);
+}
+
+static inline void mlxsw_reg_sfd_uc_lag_unpack(char *payload, int rec_index,
+					       char *mac, u16 *p_vid,
+					       u16 *p_lag_id)
+{
+	mlxsw_reg_sfd_rec_mac_memcpy_from(payload, rec_index, mac);
+	*p_vid = mlxsw_reg_sfd_uc_lag_fid_vid_get(payload, rec_index);
+	*p_lag_id = mlxsw_reg_sfd_uc_lag_lag_id_get(payload, rec_index);
+}
+
 /* SFN - Switch FDB Notification Register
  * -------------------------------------------
  * The switch provides notifications on newly learned FDB entries and
-- 
1.9.3
