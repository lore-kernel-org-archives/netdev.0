From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 38/42] mlxsw: reg: Add Router Adjacency Table register
Date: Fri,  1 Jul 2016 16:05:06 +0200
Message-ID: <1467381910-3445-39-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34022 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbcGAOUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:20:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so5675661wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:20:36 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RATR register is used to configure the Router Adjacency (next-hop)
Table.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 133 ++++++++++++++++++++++++++++++
 1 file changed, 133 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fcf379b..a2d7870 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3455,6 +3455,137 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
 
+/* RATR - Router Adjacency Table Register
+ * --------------------------------------
+ * The RATR register is used to configure the Router Adjacency (next-hop)
+ * Table.
+ */
+#define MLXSW_REG_RATR_ID 0x8008
+#define MLXSW_REG_RATR_LEN 0x2C
+
+static const struct mlxsw_reg_info mlxsw_reg_ratr = {
+	.id = MLXSW_REG_RATR_ID,
+	.len = MLXSW_REG_RATR_LEN,
+};
+
+enum mlxsw_reg_ratr_op {
+	/* Read */
+	MLXSW_REG_RATR_OP_QUERY_READ = 0,
+	/* Read and clear activity */
+	MLXSW_REG_RATR_OP_QUERY_READ_CLEAR = 2,
+	/* Write Adjacency entry */
+	MLXSW_REG_RATR_OP_WRITE_WRITE_ENTRY = 1,
+	/* Write Adjacency entry only if the activity is cleared.
+	 * The write may not succeed if the activity is set. There is not
+	 * direct feedback if the write has succeeded or not, however
+	 * the get will reveal the actual entry (SW can compare the get
+	 * response to the set command).
+	 */
+	MLXSW_REG_RATR_OP_WRITE_WRITE_ENTRY_ON_ACTIVITY = 3,
+};
+
+/* reg_ratr_op
+ * Note that Write operation may also be used for updating
+ * counter_set_type and counter_index. In this case all other
+ * fields must not be updated.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, ratr, op, 0x00, 28, 4);
+
+/* reg_ratr_v
+ * Valid bit. Indicates if the adjacency entry is valid.
+ * Note: the device may need some time before reusing an invalidated
+ * entry. During this time the entry can not be reused. It is
+ * recommended to use another entry before reusing an invalidated
+ * entry (e.g. software can put it at the end of the list for
+ * reusing). Trying to access an invalidated entry not yet cleared
+ * by the device results with failure indicating "Try Again" status.
+ * When valid is '0' then egress_router_interface,trap_action,
+ * adjacency_parameters and counters are reserved
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, v, 0x00, 24, 1);
+
+/* reg_ratr_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on
+ * the specific entry. To clear the a bit, use "clear activity".
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ratr, a, 0x00, 16, 1);
+
+/* reg_ratr_adjacency_index_low
+ * Bits 15:0 of index into the adjacency table.
+ * For SwitchX and SwitchX-2, the adjacency table is linear and
+ * used for adjacency entries only.
+ * For Spectrum, the index is to the KVD linear.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ratr, adjacency_index_low, 0x04, 0, 16);
+
+/* reg_ratr_egress_router_interface
+ * Range is 0 .. cap_max_router_interfaces - 1
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, egress_router_interface, 0x08, 0, 16);
+
+enum mlxsw_reg_ratr_trap_action {
+	MLXSW_REG_RATR_TRAP_ACTION_NOP,
+	MLXSW_REG_RATR_TRAP_ACTION_TRAP,
+	MLXSW_REG_RATR_TRAP_ACTION_MIRROR_TO_CPU,
+	MLXSW_REG_RATR_TRAP_ACTION_MIRROR,
+	MLXSW_REG_RATR_TRAP_ACTION_DISCARD_ERRORS,
+};
+
+/* reg_ratr_trap_action
+ * see mlxsw_reg_ratr_trap_action
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, trap_action, 0x0C, 28, 4);
+
+enum mlxsw_reg_ratr_trap_id {
+	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS0 = 0,
+	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS1 = 1,
+};
+
+/* reg_ratr_adjacency_index_high
+ * Bits 23:16 of the adjacency_index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ratr, adjacency_index_high, 0x0C, 16, 8);
+
+/* reg_ratr_trap_id
+ * Trap ID to be reported to CPU.
+ * Trap-ID is RTR_EGRESS0 or RTR_EGRESS1.
+ * For trap_action of NOP, MIRROR and DISCARD_ERROR
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, trap_id, 0x0C, 0, 8);
+
+/* reg_ratr_eth_destination_mac
+ * MAC address of the destination next-hop.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ratr, eth_destination_mac, 0x12, 6);
+
+static inline void
+mlxsw_reg_ratr_pack(char *payload,
+		    enum mlxsw_reg_ratr_op op, bool valid,
+		    u32 adjacency_index, u16 egress_rif)
+{
+	MLXSW_REG_ZERO(ratr, payload);
+	mlxsw_reg_ratr_op_set(payload, op);
+	mlxsw_reg_ratr_v_set(payload, valid);
+	mlxsw_reg_ratr_adjacency_index_low_set(payload, adjacency_index);
+	mlxsw_reg_ratr_adjacency_index_high_set(payload, adjacency_index >> 16);
+	mlxsw_reg_ratr_egress_router_interface_set(payload, egress_rif);
+}
+
+static inline void mlxsw_reg_ratr_eth_entry_pack(char *payload,
+						 const char *dest_mac)
+{
+	mlxsw_reg_ratr_eth_destination_mac_memcpy_to(payload, dest_mac);
+}
+
 /* RALTA - Router Algorithmic LPM Tree Allocation Register
  * -------------------------------------------------------
  * RALTA is used to allocate the LPM trees of the SHSPM method.
@@ -4910,6 +5041,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RGCR";
 	case MLXSW_REG_RITR_ID:
 		return "RITR";
+	case MLXSW_REG_RATR_ID:
+		return "RATR";
 	case MLXSW_REG_RALTA_ID:
 		return "RALTA";
 	case MLXSW_REG_RALST_ID:
-- 
2.5.5
