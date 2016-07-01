From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/42] mlxsw: reg: Add Router Algorithmic LPM Structure Tree Register definition
Date: Fri,  1 Jul 2016 16:04:46 +0200
Message-ID: <1467381910-3445-19-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33045 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbcGAOWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:22:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so5687064wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:21:54 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Serves to build LPM tree structure.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 77 +++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index a358e1b..4ea608f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3504,6 +3504,81 @@ static inline void mlxsw_reg_ralta_pack(char *payload, bool alloc,
 	mlxsw_reg_ralta_tree_id_set(payload, tree_id);
 }
 
+/* RALST - Router Algorithmic LPM Structure Tree Register
+ * ------------------------------------------------------
+ * RALST is used to set and query the structure of an LPM tree.
+ * The structure of the tree must be sorted as a sorted binary tree, while
+ * each node is a bin that is tagged as the length of the prefixes the lookup
+ * will refer to. Therefore, bin X refers to a set of entries with prefixes
+ * of X bits to match with the destination address. The bin 0 indicates
+ * the default action, when there is no match of any prefix.
+ */
+#define MLXSW_REG_RALST_ID 0x8011
+#define MLXSW_REG_RALST_LEN 0x104
+
+static const struct mlxsw_reg_info mlxsw_reg_ralst = {
+	.id = MLXSW_REG_RALST_ID,
+	.len = MLXSW_REG_RALST_LEN,
+};
+
+/* reg_ralst_root_bin
+ * The bin number of the root bin.
+ * 0<root_bin=<(length of IP address)
+ * For a default-route tree configure 0xff
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralst, root_bin, 0x00, 16, 8);
+
+/* reg_ralst_tree_id
+ * Tree identifier numbered from 1..(cap_shspm_max_trees-1).
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralst, tree_id, 0x00, 0, 8);
+
+#define MLXSW_REG_RALST_BIN_NO_CHILD 0xff
+#define MLXSW_REG_RALST_BIN_OFFSET 0x04
+#define MLXSW_REG_RALST_BIN_COUNT 128
+
+/* reg_ralst_left_child_bin
+ * Holding the children of the bin according to the stored tree's structure.
+ * For trees composed of less than 4 blocks, the bins in excess are reserved.
+ * Note that tree_id 0 is allocated for a default-route tree, bins are 0xff
+ * Access: RW
+ */
+MLXSW_ITEM16_INDEXED(reg, ralst, left_child_bin, 0x04, 8, 8, 0x02, 0x00, false);
+
+/* reg_ralst_right_child_bin
+ * Holding the children of the bin according to the stored tree's structure.
+ * For trees composed of less than 4 blocks, the bins in excess are reserved.
+ * Note that tree_id 0 is allocated for a default-route tree, bins are 0xff
+ * Access: RW
+ */
+MLXSW_ITEM16_INDEXED(reg, ralst, right_child_bin, 0x04, 0, 8, 0x02, 0x00,
+		     false);
+
+static inline void mlxsw_reg_ralst_pack(char *payload, u8 root_bin, u8 tree_id)
+{
+	MLXSW_REG_ZERO(ralst, payload);
+
+	/* Initialize all bins to have no left or right child */
+	memset(payload + MLXSW_REG_RALST_BIN_OFFSET,
+	       MLXSW_REG_RALST_BIN_NO_CHILD, MLXSW_REG_RALST_BIN_COUNT * 2);
+
+	mlxsw_reg_ralst_root_bin_set(payload, root_bin);
+	mlxsw_reg_ralst_tree_id_set(payload, tree_id);
+}
+
+static inline void mlxsw_reg_ralst_bin_pack(char *payload, u8 bin_number,
+					    u8 left_child_bin,
+					    u8 right_child_bin)
+{
+	int bin_index = bin_number - 1;
+
+	mlxsw_reg_ralst_left_child_bin_set(payload, bin_index, left_child_bin);
+	mlxsw_reg_ralst_right_child_bin_set(payload, bin_index,
+					    right_child_bin);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4248,6 +4323,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RITR";
 	case MLXSW_REG_RALTA_ID:
 		return "RALTA";
+	case MLXSW_REG_RALST_ID:
+		return "RALST";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
