From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/16] mlxsw: reg: Add Infiniband support to PTYS
Date: Fri, 28 Oct 2016 21:35:53 +0200
Message-ID: <1477683361-8011-8-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35843 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756567AbcJ1ToS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:44:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id c17so8763880wmc.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:44:17 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

In order to support Infiniband fabric, we need to introduce IB speeds and
capabilities to PTYS emads.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 71 +++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 3ecf348..2f31af0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2054,6 +2054,7 @@ MLXSW_REG_DEFINE(ptys, MLXSW_REG_PTYS_ID, MLXSW_REG_PTYS_LEN);
  */
 MLXSW_ITEM32(reg, ptys, local_port, 0x00, 16, 8);
 
+#define MLXSW_REG_PTYS_PROTO_MASK_IB	BIT(0)
 #define MLXSW_REG_PTYS_PROTO_MASK_ETH	BIT(2)
 
 /* reg_ptys_proto_mask
@@ -2112,18 +2113,61 @@ MLXSW_ITEM32(reg, ptys, an_status, 0x04, 28, 4);
  */
 MLXSW_ITEM32(reg, ptys, eth_proto_cap, 0x0C, 0, 32);
 
+/* reg_ptys_ib_link_width_cap
+ * IB port supported widths.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, ib_link_width_cap, 0x10, 16, 16);
+
+#define MLXSW_REG_PTYS_IB_SPEED_SDR	BIT(0)
+#define MLXSW_REG_PTYS_IB_SPEED_DDR	BIT(1)
+#define MLXSW_REG_PTYS_IB_SPEED_QDR	BIT(2)
+#define MLXSW_REG_PTYS_IB_SPEED_FDR10	BIT(3)
+#define MLXSW_REG_PTYS_IB_SPEED_FDR	BIT(4)
+#define MLXSW_REG_PTYS_IB_SPEED_EDR	BIT(5)
+
+/* reg_ptys_ib_proto_cap
+ * IB port supported speeds and protocols.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, ib_proto_cap, 0x10, 0, 16);
+
 /* reg_ptys_eth_proto_admin
  * Speed and protocol to set port to.
  * Access: RW
  */
 MLXSW_ITEM32(reg, ptys, eth_proto_admin, 0x18, 0, 32);
 
+/* reg_ptys_ib_link_width_admin
+ * IB width to set port to.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ptys, ib_link_width_admin, 0x1C, 16, 16);
+
+/* reg_ptys_ib_proto_admin
+ * IB speeds and protocols to set port to.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ptys, ib_proto_admin, 0x1C, 0, 16);
+
 /* reg_ptys_eth_proto_oper
  * The current speed and protocol configured for the port.
  * Access: RO
  */
 MLXSW_ITEM32(reg, ptys, eth_proto_oper, 0x24, 0, 32);
 
+/* reg_ptys_ib_link_width_oper
+ * The current IB width to set port to.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, ib_link_width_oper, 0x28, 16, 16);
+
+/* reg_ptys_ib_proto_oper
+ * The current IB speed and protocol.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, ib_proto_oper, 0x28, 0, 16);
+
 /* reg_ptys_eth_proto_lp_advertise
  * The protocols that were advertised by the link partner during
  * autonegotiation.
@@ -2153,6 +2197,33 @@ static inline void mlxsw_reg_ptys_eth_unpack(char *payload,
 		*p_eth_proto_oper = mlxsw_reg_ptys_eth_proto_oper_get(payload);
 }
 
+static inline void mlxsw_reg_ptys_ib_pack(char *payload, u8 local_port,
+					  u16 proto_admin, u16 link_width)
+{
+	MLXSW_REG_ZERO(ptys, payload);
+	mlxsw_reg_ptys_local_port_set(payload, local_port);
+	mlxsw_reg_ptys_proto_mask_set(payload, MLXSW_REG_PTYS_PROTO_MASK_IB);
+	mlxsw_reg_ptys_ib_proto_admin_set(payload, proto_admin);
+	mlxsw_reg_ptys_ib_link_width_admin_set(payload, link_width);
+}
+
+static inline void mlxsw_reg_ptys_ib_unpack(char *payload, u16 *p_ib_proto_cap,
+					    u16 *p_ib_link_width_cap,
+					    u16 *p_ib_proto_oper,
+					    u16 *p_ib_link_width_oper)
+{
+	if (p_ib_proto_cap)
+		*p_ib_proto_cap = mlxsw_reg_ptys_ib_proto_cap_get(payload);
+	if (p_ib_link_width_cap)
+		*p_ib_link_width_cap =
+			mlxsw_reg_ptys_ib_link_width_cap_get(payload);
+	if (p_ib_proto_oper)
+		*p_ib_proto_oper = mlxsw_reg_ptys_ib_proto_oper_get(payload);
+	if (p_ib_link_width_oper)
+		*p_ib_link_width_oper =
+			mlxsw_reg_ptys_ib_link_width_oper_get(payload);
+}
+
 /* PPAD - Port Physical Address Register
  * -------------------------------------
  * The PPAD register configures the per port physical MAC address.
-- 
2.5.5
