From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 5/9] bnx2x: Add DCB/PFC support - link layer
Date: Mon, 13 Dec 2010 17:44:25 +0200
Message-ID: <1292255065.631.53.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4162 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458Ab0LMPoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 10:44:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add appropriate HW DCB/PFC configuration

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |  665 +++++++++++++++++++++++++++++++++++++---
 drivers/net/bnx2x/bnx2x_link.h |   16 +
 drivers/net/bnx2x/bnx2x_reg.h  |   47 +++
 3 files changed, 689 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 38aeffe..97cbee2 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -164,7 +164,8 @@
 #define EDC_MODE_PASSIVE_DAC 			0x0055
 
 
-
+#define ETS_BW_LIMIT_CREDIT_UPPER_BOUND		(0x5000)
+#define ETS_BW_LIMIT_CREDIT_WEIGHT		(0x5000)
 /**********************************************************/
 /*                     INTERFACE                          */
 /**********************************************************/
@@ -205,6 +206,273 @@ static u32 bnx2x_bits_dis(struct bnx2x *bp, u32 reg, u32 bits)
 	return val;
 }
 
+/******************************************************************/
+/*				ETS section			  */
+/******************************************************************/
+void bnx2x_ets_disabled(struct link_params *params)
+{
+	/* ETS disabled configuration*/
+	struct bnx2x *bp = params->bp;
+
+	DP(NETIF_MSG_LINK, "ETS disabled configuration\n");
+
+	/**
+	 * mapping between entry  priority to client number (0,1,2 -debug and
+	 * management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
+	 * 3bits client num.
+	 *   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
+	 * cos1-100     cos0-011     dbg1-010     dbg0-001     MCP-000
+	 */
+
+	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, 0x4688);
+	/**
+	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	 * as strict.  Bits 0,1,2 - debug and management entries, 3 -
+	 * COS0 entry, 4 - COS1 entry.
+	 * COS1 | COS0 | DEBUG1 | DEBUG0 | MGMT
+	 * bit4   bit3	  bit2   bit1	  bit0
+	 * MCP and debug are strict
+	 */
+
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x7);
+	/* defines which entries (clients) are subjected to WFQ arbitration */
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0);
+	/**
+	* For strict priority entries defines the number of consecutive
+	* slots for the highest priority.
+	*/
+	REG_WR(bp, NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
+	/**
+	 * mapping between the CREDIT_WEIGHT registers and actual client
+	 * numbers
+	 */
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP, 0);
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_0, 0);
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_1, 0);
+
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_0, 0);
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_1, 0);
+	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, 0);
+	/* ETS mode disable */
+	REG_WR(bp, PBF_REG_ETS_ENABLED, 0);
+	/**
+	 * If ETS mode is enabled (there is no strict priority) defines a WFQ
+	 * weight for COS0/COS1.
+	 */
+	REG_WR(bp, PBF_REG_COS0_WEIGHT, 0x2710);
+	REG_WR(bp, PBF_REG_COS1_WEIGHT, 0x2710);
+	/* Upper bound that COS0_WEIGHT can reach in the WFQ arbiter */
+	REG_WR(bp, PBF_REG_COS0_UPPER_BOUND, 0x989680);
+	REG_WR(bp, PBF_REG_COS1_UPPER_BOUND, 0x989680);
+	/* Defines the number of consecutive slots for the strict priority */
+	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0);
+}
+
+void bnx2x_ets_bw_limit_common(const struct link_params *params)
+{
+	/* ETS disabled configuration */
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "ETS enabled BW limit configuration\n");
+	/**
+	* defines which entries (clients) are subjected to WFQ arbitration
+	* COS0 0x8
+	* COS1 0x10
+	*/
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0x18);
+	/**
+	* mapping between the ARB_CREDIT_WEIGHT registers and actual
+	* client numbers (WEIGHT_0 does not actually have to represent
+	* client 0)
+	*    PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
+	*  cos1-001     cos0-000     dbg1-100     dbg0-011     MCP-010
+	*/
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP, 0x111A);
+
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_0,
+	       ETS_BW_LIMIT_CREDIT_UPPER_BOUND);
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_1,
+	       ETS_BW_LIMIT_CREDIT_UPPER_BOUND);
+
+	/* ETS mode enabled*/
+	REG_WR(bp, PBF_REG_ETS_ENABLED, 1);
+
+	/* Defines the number of consecutive slots for the strict priority */
+	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0);
+	/**
+	* Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	* as strict.  Bits 0,1,2 - debug and management entries, 3 - COS0
+	* entry, 4 - COS1 entry.
+	* COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
+	* bit4   bit3	  bit2     bit1	   bit0
+	* MCP and debug are strict
+	*/
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x7);
+
+	/* Upper bound that COS0_WEIGHT can reach in the WFQ arbiter.*/
+	REG_WR(bp, PBF_REG_COS0_UPPER_BOUND,
+	       ETS_BW_LIMIT_CREDIT_UPPER_BOUND);
+	REG_WR(bp, PBF_REG_COS1_UPPER_BOUND,
+	       ETS_BW_LIMIT_CREDIT_UPPER_BOUND);
+}
+
+void bnx2x_ets_bw_limit(const struct link_params *params, const u32 cos0_bw,
+			const u32 cos1_bw)
+{
+	/* ETS disabled configuration*/
+	struct bnx2x *bp = params->bp;
+	const u32 total_bw = cos0_bw + cos1_bw;
+	u32 cos0_credit_weight = 0;
+	u32 cos1_credit_weight = 0;
+
+	DP(NETIF_MSG_LINK, "ETS enabled BW limit configuration\n");
+
+	if ((0 == total_bw) ||
+	    (0 == cos0_bw) ||
+	    (0 == cos1_bw)) {
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_bw_limit: Total BW can't be zero\n");
+		return;
+	}
+
+	cos0_credit_weight = (cos0_bw * ETS_BW_LIMIT_CREDIT_WEIGHT)/
+		total_bw;
+	cos1_credit_weight = (cos1_bw * ETS_BW_LIMIT_CREDIT_WEIGHT)/
+		total_bw;
+
+	bnx2x_ets_bw_limit_common(params);
+
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_0, cos0_credit_weight);
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_1, cos1_credit_weight);
+
+	REG_WR(bp, PBF_REG_COS0_WEIGHT, cos0_credit_weight);
+	REG_WR(bp, PBF_REG_COS1_WEIGHT, cos1_credit_weight);
+}
+
+u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
+{
+	/* ETS disabled configuration*/
+	struct bnx2x *bp = params->bp;
+	u32 val	= 0;
+
+	if ((1 < strict_cos) && (NULL == params))
+		return -EINVAL;
+
+	DP(NETIF_MSG_LINK, "ETS enabled strict configuration\n");
+	/**
+	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	 * as strict.  Bits 0,1,2 - debug and management entries,
+	 * 3 - COS0 entry, 4 - COS1 entry.
+	 *  COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
+	 *  bit4   bit3	  bit2      bit1     bit0
+	 * MCP and debug are strict
+	 */
+	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x1F);
+	/**
+	 * For strict priority entries defines the number of consecutive slots
+	 * for the highest priority.
+	 */
+	REG_WR(bp, NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
+	/* ETS mode disable */
+	REG_WR(bp, PBF_REG_ETS_ENABLED, 0);
+	/* Defines the number of consecutive slots for the strict priority */
+	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0x100);
+
+	/* Defines the number of consecutive slots for the strict priority */
+	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, strict_cos);
+
+	/**
+	* mapping between entry  priority to client number (0,1,2 -debug and
+	* management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
+	* 3bits client num.
+	*   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
+	* dbg0-010     dbg1-001     cos1-100     cos0-011     MCP-000
+	* dbg0-010     dbg1-001     cos0-011     cos1-100     MCP-000
+	*/
+	val = (0 == strict_cos) ? 0x2318 : 0x22E0;
+	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, val);
+
+	return 0;
+}
+/******************************************************************/
+/*			ETS section				  */
+/******************************************************************/
+
+static void bnx2x_bmac2_get_pfc_stat(struct link_params *params,
+				     u32 pfc_frames_sent[2],
+				     u32 pfc_frames_received[2])
+{
+	/* Read pfc statistic */
+	struct bnx2x *bp = params->bp;
+	u32 bmac_addr = params->port ? NIG_REG_INGRESS_BMAC1_MEM :
+		NIG_REG_INGRESS_BMAC0_MEM;
+
+	DP(NETIF_MSG_LINK, "pfc statistic read from BMAC\n");
+
+	REG_RD_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_STAT_GTPP,
+					pfc_frames_sent, 2);
+
+	REG_RD_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_STAT_GRPP,
+					pfc_frames_received, 2);
+
+}
+static void bnx2x_emac_get_pfc_stat(struct link_params *params,
+				    u32 pfc_frames_sent[2],
+				    u32 pfc_frames_received[2])
+{
+	/* Read pfc statistic */
+	struct bnx2x *bp = params->bp;
+	u32 emac_base = params->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	u32 val_xon = 0;
+	u32 val_xoff = 0;
+
+	DP(NETIF_MSG_LINK, "pfc statistic read from EMAC\n");
+
+	/* PFC received frames */
+	val_xoff = REG_RD(bp, emac_base +
+				EMAC_REG_RX_PFC_STATS_XOFF_RCVD);
+	val_xoff &= EMAC_REG_RX_PFC_STATS_XOFF_RCVD_COUNT;
+	val_xon = REG_RD(bp, emac_base + EMAC_REG_RX_PFC_STATS_XON_RCVD);
+	val_xon &= EMAC_REG_RX_PFC_STATS_XON_RCVD_COUNT;
+
+	pfc_frames_received[0] = val_xon + val_xoff;
+
+	/* PFC received sent */
+	val_xoff = REG_RD(bp, emac_base +
+				EMAC_REG_RX_PFC_STATS_XOFF_SENT);
+	val_xoff &= EMAC_REG_RX_PFC_STATS_XOFF_SENT_COUNT;
+	val_xon = REG_RD(bp, emac_base + EMAC_REG_RX_PFC_STATS_XON_SENT);
+	val_xon &= EMAC_REG_RX_PFC_STATS_XON_SENT_COUNT;
+
+	pfc_frames_sent[0] = val_xon + val_xoff;
+}
+
+void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
+			 u32 pfc_frames_sent[2],
+			 u32 pfc_frames_received[2])
+{
+	/* Read pfc statistic */
+	struct bnx2x *bp = params->bp;
+	u32 val	= 0;
+	DP(NETIF_MSG_LINK, "pfc statistic\n");
+
+	if (!vars->link_up)
+		return;
+
+	val = REG_RD(bp, MISC_REG_RESET_REG_2);
+	if ((val & (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port))
+	    == 0) {
+		DP(NETIF_MSG_LINK, "About to read stats from EMAC\n");
+		bnx2x_emac_get_pfc_stat(params, pfc_frames_sent,
+					pfc_frames_received);
+	} else {
+		DP(NETIF_MSG_LINK, "About to read stats from BMAC\n");
+		bnx2x_bmac2_get_pfc_stat(params, pfc_frames_sent,
+					 pfc_frames_received);
+	}
+}
+/******************************************************************/
+/*			MAC/PBF section				  */
+/******************************************************************/
 static void bnx2x_emac_init(struct link_params *params,
 			   struct link_vars *vars)
 {
@@ -315,24 +583,55 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 		/* pause enable/disable */
 		bnx2x_bits_dis(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
 			       EMAC_RX_MODE_FLOW_EN);
-		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
-			bnx2x_bits_en(bp, emac_base +
-				    EMAC_REG_EMAC_RX_MODE,
-				    EMAC_RX_MODE_FLOW_EN);
 
 		bnx2x_bits_dis(bp,  emac_base + EMAC_REG_EMAC_TX_MODE,
-			     (EMAC_TX_MODE_EXT_PAUSE_EN |
-			      EMAC_TX_MODE_FLOW_EN));
-		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
-			bnx2x_bits_en(bp, emac_base +
-				    EMAC_REG_EMAC_TX_MODE,
-				   (EMAC_TX_MODE_EXT_PAUSE_EN |
-				    EMAC_TX_MODE_FLOW_EN));
+			       (EMAC_TX_MODE_EXT_PAUSE_EN |
+				EMAC_TX_MODE_FLOW_EN));
+		if (!(params->feature_config_flags &
+		      FEATURE_CONFIG_PFC_ENABLED)) {
+			if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
+				bnx2x_bits_en(bp, emac_base +
+					      EMAC_REG_EMAC_RX_MODE,
+					      EMAC_RX_MODE_FLOW_EN);
+
+			if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+				bnx2x_bits_en(bp, emac_base +
+					      EMAC_REG_EMAC_TX_MODE,
+					      (EMAC_TX_MODE_EXT_PAUSE_EN |
+					       EMAC_TX_MODE_FLOW_EN));
+		} else
+			bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
+				      EMAC_TX_MODE_FLOW_EN);
 	}
 
 	/* KEEP_VLAN_TAG, promiscuous */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
+
+	/**
+	* Setting this bit causes MAC control frames (except for pause
+	* frames) to be passed on for processing. This setting has no
+	* affect on the operation of the pause frames. This bit effects
+	* all packets regardless of RX Parser packet sorting logic.
+	* Turn the PFC off to make sure we are in Xon state before
+	* enabling it.
+	*/
+	EMAC_WR(bp, EMAC_REG_RX_PFC_MODE, 0);
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED) {
+		DP(NETIF_MSG_LINK, "PFC is enabled\n");
+		/* Enable PFC again */
+		EMAC_WR(bp, EMAC_REG_RX_PFC_MODE,
+			EMAC_REG_RX_PFC_MODE_RX_EN |
+			EMAC_REG_RX_PFC_MODE_TX_EN |
+			EMAC_REG_RX_PFC_MODE_PRIORITIES);
+
+		EMAC_WR(bp, EMAC_REG_RX_PFC_PARAM,
+			((0x0101 <<
+			  EMAC_REG_RX_PFC_PARAM_OPCODE_BITSHIFT) |
+			 (0x00ff <<
+			  EMAC_REG_RX_PFC_PARAM_PRIORITY_EN_BITSHIFT)));
+		val |= EMAC_RX_MODE_KEEP_MAC_CONTROL;
+	}
 	EMAC_WR(bp, EMAC_REG_EMAC_RX_MODE, val);
 
 	/* Set Loopback */
@@ -362,7 +661,9 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	/* enable the NIG in/out to the emac */
 	REG_WR(bp, NIG_REG_EMAC0_IN_EN + port*4, 0x1);
 	val = 0;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+	if ((params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED) ||
+	    (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
 		val = 1;
 
 	REG_WR(bp, NIG_REG_EMAC0_PAUSE_OUT_EN + port*4, val);
@@ -383,9 +684,38 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	return 0;
 }
 
-static void bnx2x_update_bmac2(struct link_params *params,
-			       struct link_vars *vars,
-			       u8 is_lb)
+static void bnx2x_update_pfc_bmac1(struct link_params *params,
+				   struct link_vars *vars)
+{
+	u32 wb_data[2];
+	struct bnx2x *bp = params->bp;
+	u32 bmac_addr =  params->port ? NIG_REG_INGRESS_BMAC1_MEM :
+		NIG_REG_INGRESS_BMAC0_MEM;
+
+	u32 val = 0x14;
+	if ((!(params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED)) &&
+		(vars->flow_ctrl & BNX2X_FLOW_CTRL_RX))
+		/* Enable BigMAC to react on received Pause packets */
+		val |= (1<<5);
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_CONTROL, wb_data, 2);
+
+	/* tx control */
+	val = 0xc0;
+	if (!(params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED) &&
+		(vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
+		val |= 0x800000;
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_CONTROL, wb_data, 2);
+}
+
+static void bnx2x_update_pfc_bmac2(struct link_params *params,
+				   struct link_vars *vars,
+				   u8 is_lb)
 {
 	/*
 	 * Set rx control: Strip CRC and enable BigMAC to relay
@@ -397,7 +727,9 @@ static void bnx2x_update_bmac2(struct link_params *params,
 		NIG_REG_INGRESS_BMAC0_MEM;
 	u32 val = 0x14;
 
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
+	if ((!(params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED)) &&
+		(vars->flow_ctrl & BNX2X_FLOW_CTRL_RX))
 		/* Enable BigMAC to react on received Pause packets */
 		val |= (1<<5);
 	wb_data[0] = val;
@@ -408,14 +740,47 @@ static void bnx2x_update_bmac2(struct link_params *params,
 
 	/* Tx control */
 	val = 0xc0;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+	if (!(params->feature_config_flags &
+				FEATURE_CONFIG_PFC_ENABLED) &&
+	    (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
 		val |= 0x800000;
 	wb_data[0] = val;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_CONTROL,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_CONTROL, wb_data, 2);
+
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED) {
+		DP(NETIF_MSG_LINK, "PFC is enabled\n");
+		/* Enable PFC RX & TX & STATS and set 8 COS  */
+		wb_data[0] = 0x0;
+		wb_data[0] |= (1<<0);  /* RX */
+		wb_data[0] |= (1<<1);  /* TX */
+		wb_data[0] |= (1<<2);  /* Force initial Xon */
+		wb_data[0] |= (1<<3);  /* 8 cos */
+		wb_data[0] |= (1<<5);  /* STATS */
+		wb_data[1] = 0;
+		REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_PFC_CONTROL,
+			    wb_data, 2);
+		/* Clear the force Xon */
+		wb_data[0] &= ~(1<<2);
+	} else {
+		DP(NETIF_MSG_LINK, "PFC is disabled\n");
+		/* disable PFC RX & TX & STATS and set 8 COS */
+		wb_data[0] = 0x8;
+		wb_data[1] = 0;
+	}
+
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_PFC_CONTROL, wb_data, 2);
 
+	/**
+	* Set Time (based unit is 512 bit time) between automatic
+	* re-sending of PP packets amd enable automatic re-send of
+	* Per-Priroity Packet as long as pp_gen is asserted and
+	* pp_disable is low.
+	*/
 	val = 0x8000;
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
+		val |= (1<<16); /* enable automatic re-send */
+
 	wb_data[0] = val;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_PAUSE_CONTROL,
@@ -427,6 +792,9 @@ static void bnx2x_update_bmac2(struct link_params *params,
 		val |= 0x4; /* Local loopback */
 		DP(NETIF_MSG_LINK, "enable bmac loopback\n");
 	}
+	/* When PFC enabled, Pass pause frames towards the NIG. */
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
+		val |= ((1<<6)|(1<<5));
 
 	wb_data[0] = val;
 	wb_data[1] = 0;
@@ -434,6 +802,239 @@ static void bnx2x_update_bmac2(struct link_params *params,
 			wb_data, 2);
 }
 
+static void bnx2x_update_pfc_brb(struct link_params *params,
+		struct link_vars *vars,
+		struct bnx2x_nig_brb_pfc_port_params *pfc_params)
+{
+	struct bnx2x *bp = params->bp;
+	int set_pfc = params->feature_config_flags &
+		FEATURE_CONFIG_PFC_ENABLED;
+
+	/* default - pause configuration */
+	u32 pause_xoff_th = PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_PAUSEABLE;
+	u32 pause_xon_th = PFC_BRB_MAC_PAUSE_XON_THRESHOLD_PAUSEABLE;
+	u32 full_xoff_th = PFC_BRB_MAC_FULL_XOFF_THRESHOLD_PAUSEABLE;
+	u32 full_xon_th = PFC_BRB_MAC_FULL_XON_THRESHOLD_PAUSEABLE;
+
+	if (set_pfc && pfc_params)
+		/* First COS */
+		if (!pfc_params->cos0_pauseable) {
+			pause_xoff_th =
+			  PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_NON_PAUSEABLE;
+			pause_xon_th =
+			  PFC_BRB_MAC_PAUSE_XON_THRESHOLD_NON_PAUSEABLE;
+			full_xoff_th =
+			  PFC_BRB_MAC_FULL_XOFF_THRESHOLD_NON_PAUSEABLE;
+			full_xon_th =
+			  PFC_BRB_MAC_FULL_XON_THRESHOLD_NON_PAUSEABLE;
+		}
+	/* The number of free blocks below which the pause signal to class 0
+	   of MAC #n is asserted. n=0,1 */
+	REG_WR(bp, BRB1_REG_PAUSE_0_XOFF_THRESHOLD_0 , pause_xoff_th);
+	/* The number of free blocks above which the pause signal to class 0
+	   of MAC #n is de-asserted. n=0,1 */
+	REG_WR(bp, BRB1_REG_PAUSE_0_XON_THRESHOLD_0 , pause_xon_th);
+	/* The number of free blocks below which the full signal to class 0
+	   of MAC #n is asserted. n=0,1 */
+	REG_WR(bp, BRB1_REG_FULL_0_XOFF_THRESHOLD_0 , full_xoff_th);
+	/* The number of free blocks above which the full signal to class 0
+	   of MAC #n is de-asserted. n=0,1 */
+	REG_WR(bp, BRB1_REG_FULL_0_XON_THRESHOLD_0 , full_xon_th);
+
+	if (set_pfc && pfc_params) {
+		/* Second COS */
+		if (pfc_params->cos1_pauseable) {
+			pause_xoff_th =
+			  PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_PAUSEABLE;
+			pause_xon_th =
+			  PFC_BRB_MAC_PAUSE_XON_THRESHOLD_PAUSEABLE;
+			full_xoff_th =
+			  PFC_BRB_MAC_FULL_XOFF_THRESHOLD_PAUSEABLE;
+			full_xon_th =
+			  PFC_BRB_MAC_FULL_XON_THRESHOLD_PAUSEABLE;
+		} else {
+			pause_xoff_th =
+			  PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_NON_PAUSEABLE;
+			pause_xon_th =
+			  PFC_BRB_MAC_PAUSE_XON_THRESHOLD_NON_PAUSEABLE;
+			full_xoff_th =
+			  PFC_BRB_MAC_FULL_XOFF_THRESHOLD_NON_PAUSEABLE;
+			full_xon_th =
+			  PFC_BRB_MAC_FULL_XON_THRESHOLD_NON_PAUSEABLE;
+		}
+		/**
+		 * The number of free blocks below which the pause signal to
+		 * class 1 of MAC #n is asserted. n=0,1
+		 **/
+		REG_WR(bp, BRB1_REG_PAUSE_1_XOFF_THRESHOLD_0, pause_xoff_th);
+		/**
+		 * The number of free blocks above which the pause signal to
+		 * class 1 of MAC #n is de-asserted. n=0,1
+		 **/
+		REG_WR(bp, BRB1_REG_PAUSE_1_XON_THRESHOLD_0, pause_xon_th);
+		/**
+		 * The number of free blocks below which the full signal to
+		 * class 1 of MAC #n is asserted. n=0,1
+		 **/
+		REG_WR(bp, BRB1_REG_FULL_1_XOFF_THRESHOLD_0, full_xoff_th);
+		/**
+		 * The number of free blocks above which the full signal to
+		 * class 1 of MAC #n is de-asserted. n=0,1
+		 **/
+		REG_WR(bp, BRB1_REG_FULL_1_XON_THRESHOLD_0, full_xon_th);
+	}
+}
+
+static void bnx2x_update_pfc_nig(struct link_params *params,
+		struct link_vars *vars,
+		struct bnx2x_nig_brb_pfc_port_params *nig_params)
+{
+	u32 xcm_mask = 0, ppp_enable = 0, pause_enable = 0, llfc_out_en = 0;
+	u32 llfc_enable = 0, xcm0_out_en = 0, p0_hwpfc_enable = 0;
+	u32 pkt_priority_to_cos = 0;
+	u32 val;
+	struct bnx2x *bp = params->bp;
+	int port = params->port;
+	int set_pfc = params->feature_config_flags &
+		FEATURE_CONFIG_PFC_ENABLED;
+	DP(NETIF_MSG_LINK, "updating pfc nig parameters\n");
+
+	/**
+	 * When NIG_LLH0_XCM_MASK_REG_LLHX_XCM_MASK_BCN bit is set
+	 * MAC control frames (that are not pause packets)
+	 * will be forwarded to the XCM.
+	 */
+	xcm_mask = REG_RD(bp,
+				port ? NIG_REG_LLH1_XCM_MASK :
+				NIG_REG_LLH0_XCM_MASK);
+	/**
+	 * nig params will override non PFC params, since it's possible to
+	 * do transition from PFC to SAFC
+	 */
+	if (set_pfc) {
+		pause_enable = 0;
+		llfc_out_en = 0;
+		llfc_enable = 0;
+		ppp_enable = 1;
+		xcm_mask &= ~(port ? NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN :
+				     NIG_LLH0_XCM_MASK_REG_LLH0_XCM_MASK_BCN);
+		xcm0_out_en = 0;
+		p0_hwpfc_enable = 1;
+	} else  {
+		if (nig_params) {
+			llfc_out_en = nig_params->llfc_out_en;
+			llfc_enable = nig_params->llfc_enable;
+			pause_enable = nig_params->pause_enable;
+		} else  /*defaul non PFC mode - PAUSE */
+			pause_enable = 1;
+
+		xcm_mask |= (port ? NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN :
+			NIG_LLH0_XCM_MASK_REG_LLH0_XCM_MASK_BCN);
+		xcm0_out_en = 1;
+	}
+
+	REG_WR(bp, port ? NIG_REG_LLFC_OUT_EN_1 :
+	       NIG_REG_LLFC_OUT_EN_0, llfc_out_en);
+	REG_WR(bp, port ? NIG_REG_LLFC_ENABLE_1 :
+	       NIG_REG_LLFC_ENABLE_0, llfc_enable);
+	REG_WR(bp, port ? NIG_REG_PAUSE_ENABLE_1 :
+	       NIG_REG_PAUSE_ENABLE_0, pause_enable);
+
+	REG_WR(bp, port ? NIG_REG_PPP_ENABLE_1 :
+	       NIG_REG_PPP_ENABLE_0, ppp_enable);
+
+	REG_WR(bp, port ? NIG_REG_LLH1_XCM_MASK :
+	       NIG_REG_LLH0_XCM_MASK, xcm_mask);
+
+	REG_WR(bp,  NIG_REG_LLFC_EGRESS_SRC_ENABLE_0, 0x7);
+
+	/* output enable for RX_XCM # IF */
+	REG_WR(bp, NIG_REG_XCM0_OUT_EN, xcm0_out_en);
+
+	/* HW PFC TX enable */
+	REG_WR(bp, NIG_REG_P0_HWPFC_ENABLE, p0_hwpfc_enable);
+
+	/* 0x2 = BMAC, 0x1= EMAC */
+	switch (vars->mac_type) {
+	case MAC_TYPE_EMAC:
+		val = 1;
+		break;
+	case MAC_TYPE_BMAC:
+		val = 0;
+		break;
+	default:
+		val = 0;
+		break;
+	}
+	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT, val);
+
+	if (nig_params) {
+		pkt_priority_to_cos = nig_params->pkt_priority_to_cos;
+
+		REG_WR(bp, port ? NIG_REG_P1_RX_COS0_PRIORITY_MASK :
+		       NIG_REG_P0_RX_COS0_PRIORITY_MASK,
+		       nig_params->rx_cos0_priority_mask);
+
+		REG_WR(bp, port ? NIG_REG_P1_RX_COS1_PRIORITY_MASK :
+		       NIG_REG_P0_RX_COS1_PRIORITY_MASK,
+		       nig_params->rx_cos1_priority_mask);
+
+		REG_WR(bp, port ? NIG_REG_LLFC_HIGH_PRIORITY_CLASSES_1 :
+		       NIG_REG_LLFC_HIGH_PRIORITY_CLASSES_0,
+		       nig_params->llfc_high_priority_classes);
+
+		REG_WR(bp, port ? NIG_REG_LLFC_LOW_PRIORITY_CLASSES_1 :
+		       NIG_REG_LLFC_LOW_PRIORITY_CLASSES_0,
+		       nig_params->llfc_low_priority_classes);
+	}
+	REG_WR(bp, port ? NIG_REG_P1_PKT_PRIORITY_TO_COS :
+	       NIG_REG_P0_PKT_PRIORITY_TO_COS,
+	       pkt_priority_to_cos);
+}
+
+
+void bnx2x_update_pfc(struct link_params *params,
+		      struct link_vars *vars,
+		      struct bnx2x_nig_brb_pfc_port_params *pfc_params)
+{
+	/**
+	 * The PFC and pause are orthogonal to one another, meaning when
+	 * PFC is enabled, the pause are disabled, and when PFC is
+	 * disabled, pause are set according to the pause result.
+	 */
+	u32 val;
+	struct bnx2x *bp = params->bp;
+
+	/* update NIG params */
+	bnx2x_update_pfc_nig(params, vars, pfc_params);
+
+	/* update BRB params */
+	bnx2x_update_pfc_brb(params, vars, pfc_params);
+
+	if (!vars->link_up)
+		return;
+
+	val = REG_RD(bp, MISC_REG_RESET_REG_2);
+	if ((val & (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port))
+	    == 0) {
+		DP(NETIF_MSG_LINK, "About to update PFC in EMAC\n");
+		bnx2x_emac_enable(params, vars, 0);
+		return;
+	}
+
+	DP(NETIF_MSG_LINK, "About to update PFC in BMAC\n");
+	if (CHIP_IS_E2(bp))
+		bnx2x_update_pfc_bmac2(params, vars, 0);
+	else
+		bnx2x_update_pfc_bmac1(params, vars);
+
+	val = 0;
+	if ((params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED) ||
+	    (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
+		val = 1;
+	REG_WR(bp, NIG_REG_BMAC0_PAUSE_OUT_EN + params->port*4, val);
+}
 
 static u8 bnx2x_bmac1_enable(struct link_params *params,
 			     struct link_vars *vars,
@@ -465,15 +1066,6 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_SOURCE_ADDR,
 		    wb_data, 2);
 
-	/* tx control */
-	val = 0xc0;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
-		val |= 0x800000;
-	wb_data[0] = val;
-	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_CONTROL,
-			wb_data, 2);
-
 	/* mac control */
 	val = 0x3;
 	if (is_lb) {
@@ -491,14 +1083,7 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE,
 			wb_data, 2);
 
-	/* rx control set to don't strip crc */
-	val = 0x14;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
-		val |= 0x20;
-	wb_data[0] = val;
-	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_CONTROL,
-			wb_data, 2);
+	bnx2x_update_pfc_bmac1(params, vars);
 
 	/* set tx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
@@ -595,7 +1180,7 @@ static u8 bnx2x_bmac2_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE,
 			wb_data, 2);
 	udelay(30);
-	bnx2x_update_bmac2(params, vars, is_lb);
+	bnx2x_update_pfc_bmac2(params, vars, is_lb);
 
 	return 0;
 }
@@ -627,7 +1212,9 @@ static u8 bnx2x_bmac_enable(struct link_params *params,
 	REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 0x0);
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + port*4, 0x0);
 	val = 0;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+	if ((params->feature_config_flags &
+	      FEATURE_CONFIG_PFC_ENABLED) ||
+	    (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
 		val = 1;
 	REG_WR(bp, NIG_REG_BMAC0_PAUSE_OUT_EN + port*4, val);
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0x0);
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 149f842..bedab1a 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -65,6 +65,22 @@
 #define FW_PARAM_MDIO_CTRL_OFFSET 16
 #define FW_PARAM_SET(phy_addr, phy_type, mdio_access) \
 	(phy_addr | phy_type | mdio_access << FW_PARAM_MDIO_CTRL_OFFSET)
+
+#define PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_PAUSEABLE		170
+#define PFC_BRB_MAC_PAUSE_XOFF_THRESHOLD_NON_PAUSEABLE		0
+
+#define PFC_BRB_MAC_PAUSE_XON_THRESHOLD_PAUSEABLE			250
+#define PFC_BRB_MAC_PAUSE_XON_THRESHOLD_NON_PAUSEABLE		0
+
+#define PFC_BRB_MAC_FULL_XOFF_THRESHOLD_PAUSEABLE			10
+#define PFC_BRB_MAC_FULL_XOFF_THRESHOLD_NON_PAUSEABLE		90
+
+#define PFC_BRB_MAC_FULL_XON_THRESHOLD_PAUSEABLE			50
+#define PFC_BRB_MAC_FULL_XON_THRESHOLD_NON_PAUSEABLE		250
+
+#define PFC_BRB_FULL_LB_XOFF_THRESHOLD				170
+#define PFC_BRB_FULL_LB_XON_THRESHOLD				250
+
 /***********************************************************/
 /*                         Structs                         */
 /***********************************************************/
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 64bdda1..bfd875b 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -1615,6 +1615,8 @@
 #define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_NO_VLAN	 (0x1<<4)
 #define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST	 (0x1<<2)
 #define NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_VLAN	 (0x1<<3)
+#define NIG_LLH0_XCM_MASK_REG_LLH0_XCM_MASK_BCN			 (0x1<<0)
+#define NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN			 (0x1<<0)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_EMAC0_MISC_MI_INT	 (0x1<<0)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_SERDES0_LINK_STATUS	 (0x1<<9)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_XGXS0_LINK10G 	 (0x1<<15)
@@ -1744,12 +1746,16 @@
    ~ppp_enable.ppp_enable = 0 and pause_enable.pause_enable =0 for the same
    port */
 #define NIG_REG_LLFC_ENABLE_0					 0x16208
+#define NIG_REG_LLFC_ENABLE_1					 0x1620c
 /* [RW 16] classes are high-priority for port0 */
 #define NIG_REG_LLFC_HIGH_PRIORITY_CLASSES_0			 0x16058
+#define NIG_REG_LLFC_HIGH_PRIORITY_CLASSES_1			 0x1605c
 /* [RW 16] classes are low-priority for port0 */
 #define NIG_REG_LLFC_LOW_PRIORITY_CLASSES_0			 0x16060
+#define NIG_REG_LLFC_LOW_PRIORITY_CLASSES_1			 0x16064
 /* [RW 1] Output enable of message to LLFC BMAC IF for port0 */
 #define NIG_REG_LLFC_OUT_EN_0					 0x160c8
+#define NIG_REG_LLFC_OUT_EN_1					 0x160cc
 #define NIG_REG_LLH0_ACPI_PAT_0_CRC				 0x1015c
 #define NIG_REG_LLH0_ACPI_PAT_6_LEN				 0x10154
 #define NIG_REG_LLH0_BRB1_DRV_MASK				 0x10244
@@ -1912,11 +1918,17 @@
    ~safc_enable.safc_enable = 0 and ppp_enable.ppp_enable =0 for the same
    port */
 #define NIG_REG_PAUSE_ENABLE_0					 0x160c0
+#define NIG_REG_PAUSE_ENABLE_1					 0x160c4
 /* [RW 1] Input enable for RX PBF LP IF */
 #define NIG_REG_PBF_LB_IN_EN					 0x100b4
 /* [RW 1] Value of this register will be transmitted to port swap when
    ~nig_registers_strap_override.strap_override =1 */
 #define NIG_REG_PORT_SWAP					 0x10394
+/* [RW 1] PPP enable for port0. This register may get 1 only when
+ * ~safc_enable.safc_enable = 0 and pause_enable.pause_enable =0 for the
+ * same port */
+#define NIG_REG_PPP_ENABLE_0					 0x160b0
+#define NIG_REG_PPP_ENABLE_1					 0x160b4
 /* [RW 1] output enable for RX parser descriptor IF */
 #define NIG_REG_PRS_EOP_OUT_EN					 0x10104
 /* [RW 1] Input enable for RX parser request IF */
@@ -1983,6 +1995,14 @@
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK10G	 (0x1<<15)
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS  (0xf<<18)
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS_SIZE 18
+/* [RW 31] The upper bound of the weight of COS0 in the ETS command arbiter. */
+#define PBF_REG_COS0_UPPER_BOUND				 0x15c05c
+/* [RW 31] The weight of COS0 in the ETS command arbiter. */
+#define PBF_REG_COS0_WEIGHT					 0x15c054
+/* [RW 31] The upper bound of the weight of COS1 in the ETS command arbiter. */
+#define PBF_REG_COS1_UPPER_BOUND				 0x15c060
+/* [RW 31] The weight of COS1 in the ETS command arbiter. */
+#define PBF_REG_COS1_WEIGHT					 0x15c058
 /* [RW 1] Disable processing further tasks from port 0 (after ending the
    current task in process). */
 #define PBF_REG_DISABLE_NEW_TASK_PROC_P0			 0x14005c
@@ -1993,9 +2013,16 @@
    current task in process). */
 #define PBF_REG_DISABLE_NEW_TASK_PROC_P4			 0x14006c
 #define PBF_REG_DISABLE_PF					 0x1402e8
+/* [RW 1] Indicates that ETS is performed between the COSes in the command
+ * arbiter. If reset strict priority w/ anti-starvation will be performed
+ * w/o WFQ. */
+#define PBF_REG_ETS_ENABLED					 0x15c050
 /* [RW 6] Bit-map indicating which L2 hdrs may appear after the basic
  * Ethernet header. */
 #define PBF_REG_HDRS_AFTER_BASIC				 0x15c0a8
+/* [RW 1] Indicates which COS is conncted to the highest priority in the
+ * command arbiter. */
+#define PBF_REG_HIGH_PRIORITY_COS_NUM				 0x15c04c
 #define PBF_REG_IF_ENABLE_REG					 0x140044
 /* [RW 1] Init bit. When set the initial credits are copied to the credit
    registers (except the port credits). Should be set and then reset after
@@ -2021,6 +2048,10 @@
 #define PBF_REG_MAC_LB_ENABLE					 0x140040
 /* [RW 6] Bit-map indicating which headers must appear in the packet */
 #define PBF_REG_MUST_HAVE_HDRS					 0x15c0c4
+/* [RW 16] The number of strict priority arbitration slots between 2 RR
+ * arbitration slots. A value of 0 means no strict priority cycles; i.e. the
+ * strict-priority w/ anti-starvation arbiter is a RR arbiter. */
+#define PBF_REG_NUM_STRICT_ARB_SLOTS				 0x15c064
 /* [RW 10] Port 0 threshold used by arbiter in 16 byte lines used when pause
    not suppoterd. */
 #define PBF_REG_P0_ARB_THRSH					 0x1400e4
@@ -4975,7 +5006,23 @@
 #define EMAC_REG_EMAC_TX_MODE					 0xbc
 #define EMAC_REG_EMAC_TX_STAT_AC				 0x280
 #define EMAC_REG_EMAC_TX_STAT_AC_COUNT				 22
+#define EMAC_REG_RX_PFC_MODE					 0x320
+#define EMAC_REG_RX_PFC_MODE_PRIORITIES				 (1L<<2)
+#define EMAC_REG_RX_PFC_MODE_RX_EN				 (1L<<1)
+#define EMAC_REG_RX_PFC_MODE_TX_EN				 (1L<<0)
+#define EMAC_REG_RX_PFC_PARAM					 0x324
+#define EMAC_REG_RX_PFC_PARAM_OPCODE_BITSHIFT			 0
+#define EMAC_REG_RX_PFC_PARAM_PRIORITY_EN_BITSHIFT		 16
+#define EMAC_REG_RX_PFC_STATS_XOFF_RCVD				 0x328
+#define EMAC_REG_RX_PFC_STATS_XOFF_RCVD_COUNT			 (0xffff<<0)
+#define EMAC_REG_RX_PFC_STATS_XOFF_SENT				 0x330
+#define EMAC_REG_RX_PFC_STATS_XOFF_SENT_COUNT			 (0xffff<<0)
+#define EMAC_REG_RX_PFC_STATS_XON_RCVD				 0x32c
+#define EMAC_REG_RX_PFC_STATS_XON_RCVD_COUNT			 (0xffff<<0)
+#define EMAC_REG_RX_PFC_STATS_XON_SENT				 0x334
+#define EMAC_REG_RX_PFC_STATS_XON_SENT_COUNT			 (0xffff<<0)
 #define EMAC_RX_MODE_FLOW_EN					 (1L<<2)
+#define EMAC_RX_MODE_KEEP_MAC_CONTROL				 (1L<<3)
 #define EMAC_RX_MODE_KEEP_VLAN_TAG				 (1L<<10)
 #define EMAC_RX_MODE_PROMISCUOUS				 (1L<<8)
 #define EMAC_RX_MODE_RESET					 (1L<<0)
-- 
1.7.0.4




