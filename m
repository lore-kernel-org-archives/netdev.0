From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/17] mlxsw: reg: Introduce per priority counters
Date: Wed,  6 Apr 2016 17:10:15 +0200
Message-ID: <1459955416-23786-17-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36044 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbcDFPKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id o129so4683934wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:44 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We are going to add support for PFC as part of DCB ops, which requires us
to report the number of PFC frames sent and received per priority.

Add per priority counters in order to report number of PFC frames sent
and received per priority.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 62 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  3 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  3 +-
 3 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bcd38ff..84aacb3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2487,6 +2487,11 @@ MLXSW_ITEM32(reg, ppcnt, local_port, 0x00, 16, 8);
  */
 MLXSW_ITEM32(reg, ppcnt, pnat, 0x00, 14, 2);
 
+enum mlxsw_reg_ppcnt_grp {
+	MLXSW_REG_PPCNT_IEEE_8023_CNT = 0x0,
+	MLXSW_REG_PPCNT_PRIO_CNT = 0x10,
+};
+
 /* reg_ppcnt_grp
  * Performance counter group.
  * Group 63 indicates all groups. Only valid on Set() operation with
@@ -2522,6 +2527,8 @@ MLXSW_ITEM32(reg, ppcnt, clr, 0x04, 31, 1);
  */
 MLXSW_ITEM32(reg, ppcnt, prio_tc, 0x04, 0, 5);
 
+/* Ethernet IEEE 802.3 Counter Group */
+
 /* reg_ppcnt_a_frames_transmitted_ok
  * Access: RO
  */
@@ -2636,15 +2643,64 @@ MLXSW_ITEM64(reg, ppcnt, a_pause_mac_ctrl_frames_received,
 MLXSW_ITEM64(reg, ppcnt, a_pause_mac_ctrl_frames_transmitted,
 	     0x08 + 0x90, 0, 64);
 
-static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port)
+/* Ethernet Per Priority Group Counters */
+
+/* reg_ppcnt_rx_octets
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, rx_octets, 0x08 + 0x00, 0, 64);
+
+/* reg_ppcnt_rx_frames
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, rx_frames, 0x08 + 0x20, 0, 64);
+
+/* reg_ppcnt_tx_octets
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tx_octets, 0x08 + 0x28, 0, 64);
+
+/* reg_ppcnt_tx_frames
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tx_frames, 0x08 + 0x48, 0, 64);
+
+/* reg_ppcnt_rx_pause
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, rx_pause, 0x08 + 0x50, 0, 64);
+
+/* reg_ppcnt_rx_pause_duration
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, rx_pause_duration, 0x08 + 0x58, 0, 64);
+
+/* reg_ppcnt_tx_pause
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tx_pause, 0x08 + 0x60, 0, 64);
+
+/* reg_ppcnt_tx_pause_duration
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tx_pause_duration, 0x08 + 0x68, 0, 64);
+
+/* reg_ppcnt_rx_pause_transition
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tx_pause_transition, 0x08 + 0x70, 0, 64);
+
+static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
+					enum mlxsw_reg_ppcnt_grp grp,
+					u8 prio_tc)
 {
 	MLXSW_REG_ZERO(ppcnt, payload);
 	mlxsw_reg_ppcnt_swid_set(payload, 0);
 	mlxsw_reg_ppcnt_local_port_set(payload, local_port);
 	mlxsw_reg_ppcnt_pnat_set(payload, 0);
-	mlxsw_reg_ppcnt_grp_set(payload, 0);
+	mlxsw_reg_ppcnt_grp_set(payload, grp);
 	mlxsw_reg_ppcnt_clr_set(payload, 0);
-	mlxsw_reg_ppcnt_prio_tc_set(payload, 0);
+	mlxsw_reg_ppcnt_prio_tc_set(payload, prio_tc);
 }
 
 /* PPTB - Port Prio To Buffer Register
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 086682e..36a94a9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1195,7 +1195,8 @@ static void mlxsw_sp_port_get_stats(struct net_device *dev,
 	int i;
 	int err;
 
-	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
+			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
 	for (i = 0; i < MLXSW_SP_PORT_HW_STATS_LEN; i++)
 		data[i] = !err ? mlxsw_sp_port_hw_stats[i].getter(ppcnt_pl) : 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 7a60a26..c49447f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -518,7 +518,8 @@ static void mlxsw_sx_port_get_stats(struct net_device *dev,
 	int i;
 	int err;
 
-	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sx_port->local_port);
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sx_port->local_port,
+			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0);
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ppcnt), ppcnt_pl);
 	for (i = 0; i < MLXSW_SX_PORT_HW_STATS_LEN; i++)
 		data[i] = !err ? mlxsw_sx_port_hw_stats[i].getter(ppcnt_pl) : 0;
-- 
2.5.5
