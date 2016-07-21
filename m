From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/9] mlxsw: reg: Add the Monitoring Port Analyzer register
Date: Thu, 21 Jul 2016 12:03:15 +0200
Message-ID: <1469095397-3837-8-git-send-email-jiri@resnulli.us>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33690 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbcGUKDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 06:03:31 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so1964794wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 03:03:31 -0700 (PDT)
In-Reply-To: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MPAR register is used to bind ports to a SPAN entry (which was
created using MPAT register) and thus mirror their traffic (ingress /
egress) to a different port.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - fixed wrapping issue in function pointed out by Jamal
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 67 +++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 341ee245..311b5c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4660,6 +4660,16 @@ MLXSW_ITEM32(reg, mpat, e, 0x04, 31, 1);
  */
 MLXSW_ITEM32(reg, mpat, qos, 0x04, 26, 1);
 
+/* reg_mpat_be
+ * Best effort mode. Indicates mirroring traffic should not cause packet
+ * drop or back pressure, but will discard the mirrored packets. Mirrored
+ * packets will be forwarded on a best effort manner.
+ * 0: Do not discard mirrored packets
+ * 1: Discard mirrored packets if causing congestion
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpat, be, 0x04, 25, 1);
+
 static inline void mlxsw_reg_mpat_pack(char *payload, u8 pa_id,
 				       u16 system_port, bool e)
 {
@@ -4668,6 +4678,61 @@ static inline void mlxsw_reg_mpat_pack(char *payload, u8 pa_id,
 	mlxsw_reg_mpat_system_port_set(payload, system_port);
 	mlxsw_reg_mpat_e_set(payload, e);
 	mlxsw_reg_mpat_qos_set(payload, 1);
+	mlxsw_reg_mpat_be_set(payload, 1);
+}
+
+/* MPAR - Monitoring Port Analyzer Register
+ * ----------------------------------------
+ * MPAR register is used to query and configure the port analyzer port mirroring
+ * properties.
+ */
+#define MLXSW_REG_MPAR_ID 0x901B
+#define MLXSW_REG_MPAR_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_mpar = {
+	.id = MLXSW_REG_MPAR_ID,
+	.len = MLXSW_REG_MPAR_LEN,
+};
+
+/* reg_mpar_local_port
+ * The local port to mirror the packets from.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mpar, local_port, 0x00, 16, 8);
+
+enum mlxsw_reg_mpar_i_e {
+	MLXSW_REG_MPAR_TYPE_EGRESS,
+	MLXSW_REG_MPAR_TYPE_INGRESS,
+};
+
+/* reg_mpar_i_e
+ * Ingress/Egress
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mpar, i_e, 0x00, 0, 4);
+
+/* reg_mpar_enable
+ * Enable mirroring
+ * By default, port mirroring is disabled for all ports.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpar, enable, 0x04, 31, 1);
+
+/* reg_mpar_pa_id
+ * Port Analyzer ID.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpar, pa_id, 0x04, 0, 4);
+
+static inline void mlxsw_reg_mpar_pack(char *payload, u8 local_port,
+				       enum mlxsw_reg_mpar_i_e i_e,
+				       bool enable, u8 pa_id)
+{
+	MLXSW_REG_ZERO(mpar, payload);
+	mlxsw_reg_mpar_local_port_set(payload, local_port);
+	mlxsw_reg_mpar_enable_set(payload, enable);
+	mlxsw_reg_mpar_i_e_set(payload, i_e);
+	mlxsw_reg_mpar_pa_id_set(payload, pa_id);
 }
 
 /* MLCR - Management LED Control Register
@@ -5243,6 +5308,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "MTCAP";
 	case MLXSW_REG_MPAT_ID:
 		return "MPAT";
+	case MLXSW_REG_MPAR_ID:
+		return "MPAR";
 	case MLXSW_REG_MTMP_ID:
 		return "MTMP";
 	case MLXSW_REG_MLCR_ID:
-- 
2.5.5
