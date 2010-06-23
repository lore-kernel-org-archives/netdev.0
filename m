From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6] cnic: Disable statistics initialization for eth
 clients that do not support statistics
Date: Wed, 23 Jun 2010 22:09:39 +0300
Message-ID: <1277320179.5984.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2493 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470Ab0FWTJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jun 2010 15:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable statistics initialization for eth clients that do not support
 statistics. This prevents memory corruption on bnx2x hw.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/cnic.c |   55 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index fe92566..b314407 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3919,8 +3919,9 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 		HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS;
 	context->cstorm_st_context.status_block_id = BNX2X_DEF_SB_ID;
 
-	context->xstorm_st_context.statistics_data = (cli |
-				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
+	if (cli < MAX_X_STAT_COUNTER_ID)
+		context->xstorm_st_context.statistics_data = cli |
+				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE;
 
 	context->xstorm_ag_context.cdu_reserved =
 		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(BNX2X_ISCSI_L2_CID, func),
@@ -3928,10 +3929,12 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 					ETH_CONNECTION_TYPE);
 
 	/* reset xstorm per client statistics */
-	val = BAR_XSTRORM_INTMEM +
-	      XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
-	for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++)
-		CNIC_WR(dev, val + i * 4, 0);
+	if (cli < MAX_X_STAT_COUNTER_ID) {
+		val = BAR_XSTRORM_INTMEM +
+		      XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+		for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++)
+			CNIC_WR(dev, val + i * 4, 0);
+	}
 
 	cp->tx_cons_ptr =
 		&cp->bnx2x_def_status_blk->c_def_status_block.index_values[
@@ -3978,9 +3981,11 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 						BNX2X_ISCSI_RX_SB_INDEX_NUM;
 	context->ustorm_st_context.common.clientId = cli;
 	context->ustorm_st_context.common.status_block_id = BNX2X_DEF_SB_ID;
-	context->ustorm_st_context.common.flags =
-		USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS;
-	context->ustorm_st_context.common.statistics_counter_id = cli;
+	if (cli < MAX_U_STAT_COUNTER_ID) {
+		context->ustorm_st_context.common.flags =
+			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS;
+		context->ustorm_st_context.common.statistics_counter_id = cli;
+	}
 	context->ustorm_st_context.common.mc_alignment_log_size = 0;
 	context->ustorm_st_context.common.bd_buff_size =
 						cp->l2_single_buf_size;
@@ -4011,10 +4016,13 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 
 	/* client tstorm info */
 	tstorm_client.mtu = cp->l2_single_buf_size - 14;
-	tstorm_client.config_flags =
-			(TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE |
-			TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE);
-	tstorm_client.statistics_counter_id = cli;
+	tstorm_client.config_flags = TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE;
+
+	if (cli < MAX_T_STAT_COUNTER_ID) {
+		tstorm_client.config_flags |=
+				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
+		tstorm_client.statistics_counter_id = cli;
+	}
 
 	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
 		   TSTORM_CLIENT_CONFIG_OFFSET(port, cli),
@@ -4024,16 +4032,21 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 		   ((u32 *)&tstorm_client)[1]);
 
 	/* reset tstorm per client statistics */
-	val = BAR_TSTRORM_INTMEM +
-	      TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
-	for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++)
-		CNIC_WR(dev, val + i * 4, 0);
+	if (cli < MAX_T_STAT_COUNTER_ID) {
+
+		val = BAR_TSTRORM_INTMEM +
+		      TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+		for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++)
+			CNIC_WR(dev, val + i * 4, 0);
+	}
 
 	/* reset ustorm per client statistics */
-	val = BAR_USTRORM_INTMEM +
-	      USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
-	for (i = 0; i < sizeof(struct ustorm_per_client_stats) / 4; i++)
-		CNIC_WR(dev, val + i * 4, 0);
+	if (cli < MAX_U_STAT_COUNTER_ID) {
+		val = BAR_USTRORM_INTMEM +
+		      USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+		for (i = 0; i < sizeof(struct ustorm_per_client_stats) / 4; i++)
+			CNIC_WR(dev, val + i * 4, 0);
+	}
 
 	cp->rx_cons_ptr =
 		&cp->bnx2x_def_status_blk->u_def_status_block.index_values[
-- 
1.7.1




