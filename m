From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/17] mlxsw: reg: Add Port Flow Control Configuration register
Date: Wed,  6 Apr 2016 17:10:12 +0200
Message-ID: <1459955416-23786-14-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33585 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbcDFPKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id i204so14158232wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:40 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Add the Port Flow Control Configuration (PFCC) register, which
configures both flow control and Priority-based Flow Control (PFC).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 131 ++++++++++++++++++++++++++++++
 1 file changed, 131 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2e58c41..b83514a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2319,6 +2319,135 @@ static inline void mlxsw_reg_paos_pack(char *payload, u8 local_port,
 	mlxsw_reg_paos_e_set(payload, 1);
 }
 
+/* PFCC - Ports Flow Control Configuration Register
+ * ------------------------------------------------
+ * Configures and retrieves the per port flow control configuration.
+ */
+#define MLXSW_REG_PFCC_ID 0x5007
+#define MLXSW_REG_PFCC_LEN 0x20
+
+static const struct mlxsw_reg_info mlxsw_reg_pfcc = {
+	.id = MLXSW_REG_PFCC_ID,
+	.len = MLXSW_REG_PFCC_LEN,
+};
+
+/* reg_pfcc_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pfcc, local_port, 0x00, 16, 8);
+
+/* reg_pfcc_pnat
+ * Port number access type. Determines the way local_port is interpreted:
+ * 0 - Local port number.
+ * 1 - IB / label port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pfcc, pnat, 0x00, 14, 2);
+
+/* reg_pfcc_shl_cap
+ * Send to higher layers capabilities:
+ * 0 - No capability of sending Pause and PFC frames to higher layers.
+ * 1 - Device has capability of sending Pause and PFC frames to higher
+ *     layers.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, pfcc, shl_cap, 0x00, 1, 1);
+
+/* reg_pfcc_shl_opr
+ * Send to higher layers operation:
+ * 0 - Pause and PFC frames are handled by the port (default).
+ * 1 - Pause and PFC frames are handled by the port and also sent to
+ *     higher layers. Only valid if shl_cap = 1.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pfcc, shl_opr, 0x00, 0, 1);
+
+/* reg_pfcc_ppan
+ * Pause policy auto negotiation.
+ * 0 - Disabled. Generate / ignore Pause frames based on pptx / pprtx.
+ * 1 - Enabled. When auto-negotiation is performed, set the Pause policy
+ *     based on the auto-negotiation resolution.
+ * Access: RW
+ *
+ * Note: The auto-negotiation advertisement is set according to pptx and
+ * pprtx. When PFC is set on Tx / Rx, ppan must be set to 0.
+ */
+MLXSW_ITEM32(reg, pfcc, ppan, 0x04, 28, 4);
+
+/* reg_pfcc_prio_mask_tx
+ * Bit per priority indicating if Tx flow control policy should be
+ * updated based on bit pfctx.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, pfcc, prio_mask_tx, 0x04, 16, 8);
+
+/* reg_pfcc_prio_mask_rx
+ * Bit per priority indicating if Rx flow control policy should be
+ * updated based on bit pfcrx.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, pfcc, prio_mask_rx, 0x04, 0, 8);
+
+/* reg_pfcc_pptx
+ * Admin Pause policy on Tx.
+ * 0 - Never generate Pause frames (default).
+ * 1 - Generate Pause frames according to Rx buffer threshold.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pfcc, pptx, 0x08, 31, 1);
+
+/* reg_pfcc_aptx
+ * Active (operational) Pause policy on Tx.
+ * 0 - Never generate Pause frames.
+ * 1 - Generate Pause frames according to Rx buffer threshold.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, pfcc, aptx, 0x08, 30, 1);
+
+/* reg_pfcc_pfctx
+ * Priority based flow control policy on Tx[7:0]. Per-priority bit mask:
+ * 0 - Never generate priority Pause frames on the specified priority
+ *     (default).
+ * 1 - Generate priority Pause frames according to Rx buffer threshold on
+ *     the specified priority.
+ * Access: RW
+ *
+ * Note: pfctx and pptx must be mutually exclusive.
+ */
+MLXSW_ITEM32(reg, pfcc, pfctx, 0x08, 16, 8);
+
+/* reg_pfcc_pprx
+ * Admin Pause policy on Rx.
+ * 0 - Ignore received Pause frames (default).
+ * 1 - Respect received Pause frames.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pfcc, pprx, 0x0C, 31, 1);
+
+/* reg_pfcc_aprx
+ * Active (operational) Pause policy on Rx.
+ * 0 - Ignore received Pause frames.
+ * 1 - Respect received Pause frames.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, pfcc, aprx, 0x0C, 30, 1);
+
+/* reg_pfcc_pfcrx
+ * Priority based flow control policy on Rx[7:0]. Per-priority bit mask:
+ * 0 - Ignore incoming priority Pause frames on the specified priority
+ *     (default).
+ * 1 - Respect incoming priority Pause frames on the specified priority.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pfcc, pfcrx, 0x0C, 16, 8);
+
+static inline void mlxsw_reg_pfcc_pack(char *payload, u8 local_port)
+{
+	MLXSW_REG_ZERO(pfcc, payload);
+	mlxsw_reg_pfcc_local_port_set(payload, local_port);
+}
+
 /* PPCNT - Ports Performance Counters Register
  * -------------------------------------------
  * The PPCNT register retrieves per port performance counters.
@@ -3558,6 +3687,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "PPAD";
 	case MLXSW_REG_PAOS_ID:
 		return "PAOS";
+	case MLXSW_REG_PFCC_ID:
+		return "PFCC";
 	case MLXSW_REG_PPCNT_ID:
 		return "PPCNT";
 	case MLXSW_REG_PPTB_ID:
-- 
2.5.5
