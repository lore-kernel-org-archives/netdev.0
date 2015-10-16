From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/16] mlxsw: reg: Add Switch Filtering Database register definition
Date: Fri, 16 Oct 2015 14:01:28 +0200
Message-ID: <1444996897-2708-8-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37016 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbbJPMBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:51 -0400
Received: by wijq8 with SMTP id q8so7282228wij.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:49 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add the SFD register which is responsible for filtering database
manipulation, including static and dynamic FDB entries.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 216 ++++++++++++++++++++++++++++++
 1 file changed, 216 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4099d4b3..c0cc5f1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -157,6 +157,220 @@ static inline void mlxsw_reg_sspr_pack(char *payload, u8 local_port)
 	mlxsw_reg_sspr_system_port_set(payload, local_port);
 }
 
+/* SFD - Switch Filtering Database
+ * -------------------------------
+ * The following register defines the access to the filtering database.
+ * The register supports querying, adding, removing and modifying the database.
+ * The access is optimized for bulk updates in which case more than one
+ * FDB record is present in the same command.
+ */
+#define MLXSW_REG_SFD_ID 0x200A
+#define MLXSW_REG_SFD_BASE_LEN 0x10 /* base length, without records */
+#define MLXSW_REG_SFD_REC_LEN 0x10 /* record length */
+#define MLXSW_REG_SFD_REC_MAX_COUNT 64
+#define MLXSW_REG_SFD_LEN (MLXSW_REG_SFD_BASE_LEN +	\
+			   MLXSW_REG_SFD_REC_LEN * MLXSW_REG_SFD_REC_MAX_COUNT)
+
+static const struct mlxsw_reg_info mlxsw_reg_sfd = {
+	.id = MLXSW_REG_SFD_ID,
+	.len = MLXSW_REG_SFD_LEN,
+};
+
+/* reg_sfd_swid
+ * Switch partition ID for queries. Reserved on Write.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfd, swid, 0x00, 24, 8);
+
+enum mlxsw_reg_sfd_op {
+	/* Dump entire FDB a (process according to record_locator) */
+	MLXSW_REG_SFD_OP_QUERY_DUMP = 0,
+	/* Query records by {MAC, VID/FID} value */
+	MLXSW_REG_SFD_OP_QUERY_QUERY = 1,
+	/* Query and clear activity. Query records by {MAC, VID/FID} value */
+	MLXSW_REG_SFD_OP_QUERY_QUERY_AND_CLEAR_ACTIVITY = 2,
+	/* Test. Response indicates if each of the records could be
+	 * added to the FDB.
+	 */
+	MLXSW_REG_SFD_OP_WRITE_TEST = 0,
+	/* Add/modify. Aged-out records cannot be added. This command removes
+	 * the learning notification of the {MAC, VID/FID}. Response includes
+	 * the entries that were added to the FDB.
+	 */
+	MLXSW_REG_SFD_OP_WRITE_EDIT = 1,
+	/* Remove record by {MAC, VID/FID}. This command also removes
+	 * the learning notification and aged-out notifications
+	 * of the {MAC, VID/FID}. The response provides current (pre-removal)
+	 * entries as non-aged-out.
+	 */
+	MLXSW_REG_SFD_OP_WRITE_REMOVE = 2,
+	/* Remove learned notification by {MAC, VID/FID}. The response provides
+	 * the removed learning notification.
+	 */
+	MLXSW_REG_SFD_OP_WRITE_REMOVE_NOTIFICATION = 2,
+};
+
+/* reg_sfd_op
+ * Operation.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, sfd, op, 0x04, 30, 2);
+
+/* reg_sfd_record_locator
+ * Used for querying the FDB. Use record_locator=0 to initiate the
+ * query. When a record is returned, a new record_locator is
+ * returned to be used in the subsequent query.
+ * Reserved for database update.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfd, record_locator, 0x04, 0, 30);
+
+/* reg_sfd_num_rec
+ * Request: Number of records to read/add/modify/remove
+ * Response: Number of records read/added/replaced/removed
+ * See above description for more details.
+ * Ranges 0..64
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfd, num_rec, 0x08, 0, 8);
+
+static inline void mlxsw_reg_sfd_pack(char *payload, enum mlxsw_reg_sfd_op op,
+				      u32 record_locator)
+{
+	MLXSW_REG_ZERO(sfd, payload);
+	mlxsw_reg_sfd_op_set(payload, op);
+	mlxsw_reg_sfd_record_locator_set(payload, record_locator);
+}
+
+/* reg_sfd_rec_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, rec_swid, MLXSW_REG_SFD_BASE_LEN, 24, 8,
+		     MLXSW_REG_SFD_REC_LEN, 0x00, false);
+
+enum mlxsw_reg_sfd_rec_type {
+	MLXSW_REG_SFD_REC_TYPE_UNICAST = 0x0,
+};
+
+/* reg_sfd_rec_type
+ * FDB record type.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, rec_type, MLXSW_REG_SFD_BASE_LEN, 20, 4,
+		     MLXSW_REG_SFD_REC_LEN, 0x00, false);
+
+enum mlxsw_reg_sfd_rec_policy {
+	/* Replacement disabled, aging disabled. */
+	MLXSW_REG_SFD_REC_POLICY_STATIC_ENTRY = 0,
+	/* (mlag remote): Replacement enabled, aging disabled,
+	 * learning notification enabled on this port.
+	 */
+	MLXSW_REG_SFD_REC_POLICY_DYNAMIC_ENTRY_MLAG = 1,
+	/* (ingress device): Replacement enabled, aging enabled. */
+	MLXSW_REG_SFD_REC_POLICY_DYNAMIC_ENTRY_INGRESS = 3,
+};
+
+/* reg_sfd_rec_policy
+ * Policy.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, rec_policy, MLXSW_REG_SFD_BASE_LEN, 18, 2,
+		     MLXSW_REG_SFD_REC_LEN, 0x00, false);
+
+/* reg_sfd_rec_a
+ * Activity. Set for new static entries. Set for static entries if a frame SMAC
+ * lookup hits on the entry.
+ * To clear the a bit, use "query and clear activity" op.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, rec_a, MLXSW_REG_SFD_BASE_LEN, 16, 1,
+		     MLXSW_REG_SFD_REC_LEN, 0x00, false);
+
+/* reg_sfd_rec_mac
+ * MAC address.
+ * Access: Index
+ */
+MLXSW_ITEM_BUF_INDEXED(reg, sfd, rec_mac, MLXSW_REG_SFD_BASE_LEN, 6,
+		       MLXSW_REG_SFD_REC_LEN, 0x02);
+
+enum mlxsw_reg_sfd_rec_action {
+	/* forward */
+	MLXSW_REG_SFD_REC_ACTION_NOP = 0,
+	/* forward and trap, trap_id is FDB_TRAP */
+	MLXSW_REG_SFD_REC_ACTION_MIRROR_TO_CPU = 1,
+	/* trap and do not forward, trap_id is FDB_TRAP */
+	MLXSW_REG_SFD_REC_ACTION_TRAP = 3,
+	MLXSW_REG_SFD_REC_ACTION_DISCARD_ERROR = 15,
+};
+
+/* reg_sfd_rec_action
+ * Action to apply on the packet.
+ * Note: Dynamic entries can only be configured with NOP action.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, rec_action, MLXSW_REG_SFD_BASE_LEN, 28, 4,
+		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
+
+/* reg_sfd_uc_sub_port
+ * LAG sub port.
+ * Must be 0 if multichannel VEPA is not enabled.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_sub_port, MLXSW_REG_SFD_BASE_LEN, 16, 8,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_uc_fid_vid
+ * Filtering ID or VLAN ID
+ * For SwitchX and SwitchX-2:
+ * - Dynamic entries (policy 2,3) use FID
+ * - Static entries (policy 0) use VID
+ * - When independent learning is configured, VID=FID
+ * For Spectrum: use FID for both Dynamic and Static entries.
+ * VID should not be used.
+ * Access: Index
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_fid_vid, MLXSW_REG_SFD_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFD_REC_LEN, 0x08, false);
+
+/* reg_sfd_uc_system_port
+ * Unique port identifier for the final destination of the packet.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, sfd, uc_system_port, MLXSW_REG_SFD_BASE_LEN, 0, 16,
+		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
+
+static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
+					 enum mlxsw_reg_sfd_rec_policy policy,
+					 const char *mac, u16 vid,
+					 enum mlxsw_reg_sfd_rec_action action,
+					 u8 local_port)
+{
+	u8 num_rec = mlxsw_reg_sfd_num_rec_get(payload);
+
+	if (rec_index >= num_rec)
+		mlxsw_reg_sfd_num_rec_set(payload, rec_index + 1);
+	mlxsw_reg_sfd_rec_swid_set(payload, rec_index, 0);
+	mlxsw_reg_sfd_rec_type_set(payload, rec_index,
+				   MLXSW_REG_SFD_REC_TYPE_UNICAST);
+	mlxsw_reg_sfd_rec_policy_set(payload, rec_index, policy);
+	mlxsw_reg_sfd_rec_mac_memcpy_to(payload, rec_index, mac);
+	mlxsw_reg_sfd_uc_sub_port_set(payload, rec_index, 0);
+	mlxsw_reg_sfd_uc_fid_vid_set(payload, rec_index, vid);
+	mlxsw_reg_sfd_rec_action_set(payload, rec_index, action);
+	mlxsw_reg_sfd_uc_system_port_set(payload, rec_index, local_port);
+}
+
+static inline void
+mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
+			char *mac, u16 *p_vid,
+			u8 *p_local_port)
+{
+	mlxsw_reg_sfd_rec_mac_memcpy_from(payload, rec_index, mac);
+	*p_vid = mlxsw_reg_sfd_uc_fid_vid_get(payload, rec_index);
+	*p_local_port = mlxsw_reg_sfd_uc_system_port_get(payload, rec_index);
+}
+
 /* SPMS - Switch Port MSTP/RSTP State Register
  * -------------------------------------------
  * Configures the spanning tree state of a physical port.
@@ -1251,6 +1465,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SPAD";
 	case MLXSW_REG_SSPR_ID:
 		return "SSPR";
+	case MLXSW_REG_SFD_ID:
+		return "SFD";
 	case MLXSW_REG_SPMS_ID:
 		return "SPMS";
 	case MLXSW_REG_SFGC_ID:
-- 
1.9.3
