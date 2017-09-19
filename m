From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/13] mlxsw: reg: Add the Router Interface Group Version 2 register
Date: Tue, 19 Sep 2017 10:00:14 +0200
Message-ID: <20170919080020.5870-8-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37588 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbdISIA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:29 -0400
Received: by mail-wm0-f67.google.com with SMTP id f4so3039763wmh.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:29 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RIGR-V2 register is used to add, remove and query egress interface list
of a multicast forwarding entry and it will be used by the multicast
router offloading logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 83 +++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index e9f37ea..1778d7f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5646,6 +5646,88 @@ mlxsw_reg_rtdp_ipip4_pack(char *payload, u16 irif,
 	mlxsw_reg_rtdp_ipip_expected_gre_key_set(payload, expected_gre_key);
 }
 
+/* RIGR-V2 - Router Interface Group Register Version 2
+ * ---------------------------------------------------
+ * The RIGR_V2 register is used to add, remove and query egress interface list
+ * of a multicast forwarding entry.
+ */
+#define MLXSW_REG_RIGR2_ID 0x8023
+#define MLXSW_REG_RIGR2_LEN 0xB0
+
+#define MLXSW_REG_RIGR2_MAX_ERIFS 32
+
+MLXSW_REG_DEFINE(rigr2, MLXSW_REG_RIGR2_ID, MLXSW_REG_RIGR2_LEN);
+
+/* reg_rigr2_rigr_index
+ * KVD Linear index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rigr2, rigr_index, 0x04, 0, 24);
+
+/* reg_rigr2_vnext
+ * Next RIGR Index is valid.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rigr2, vnext, 0x08, 31, 1);
+
+/* reg_rigr2_next_rigr_index
+ * Next RIGR Index. The index is to the KVD linear.
+ * Reserved when vnxet = '0'.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rigr2, next_rigr_index, 0x08, 0, 24);
+
+/* reg_rigr2_vrmid
+ * RMID Index is valid.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rigr2, vrmid, 0x20, 31, 1);
+
+/* reg_rigr2_rmid_index
+ * RMID Index.
+ * Range 0 .. max_mid - 1
+ * Reserved when vrmid = '0'.
+ * The index is to the Port Group Table (PGT)
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rigr2, rmid_index, 0x20, 0, 16);
+
+/* reg_rigr2_erif_entry_v
+ * Egress Router Interface is valid.
+ * Note that low-entries must be set if high-entries are set. For
+ * example: if erif_entry[2].v is set then erif_entry[1].v and
+ * erif_entry[0].v must be set.
+ * Index can be from 0 to cap_mc_erif_list_entries-1
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, rigr2, erif_entry_v, 0x24, 31, 1, 4, 0, false);
+
+/* reg_rigr2_erif_entry_erif
+ * Egress Router Interface.
+ * Valid range is from 0 to cap_max_router_interfaces - 1
+ * Index can be from 0 to MLXSW_REG_RIGR2_MAX_ERIFS - 1
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, rigr2, erif_entry_erif, 0x24, 0, 16, 4, 0, false);
+
+static inline void mlxsw_reg_rigr2_pack(char *payload, u32 rigr_index,
+					bool vnext, u32 next_rigr_index)
+{
+	MLXSW_REG_ZERO(rigr2, payload);
+	mlxsw_reg_rigr2_rigr_index_set(payload, rigr_index);
+	mlxsw_reg_rigr2_vnext_set(payload, vnext);
+	mlxsw_reg_rigr2_next_rigr_index_set(payload, next_rigr_index);
+	mlxsw_reg_rigr2_vrmid_set(payload, 0);
+	mlxsw_reg_rigr2_rmid_index_set(payload, 0);
+}
+
+static inline void mlxsw_reg_rigr2_erif_entry_pack(char *payload, int index,
+						   bool v, u16 erif)
+{
+	mlxsw_reg_rigr2_erif_entry_v_set(payload, index, v);
+	mlxsw_reg_rigr2_erif_entry_erif_set(payload, index, erif);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -6917,6 +6999,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(rauht),
 	MLXSW_REG(raleu),
 	MLXSW_REG(rauhtd),
+	MLXSW_REG(rigr2),
 	MLXSW_REG(mfcr),
 	MLXSW_REG(mfsc),
 	MLXSW_REG(mfsm),
-- 
2.9.5
