From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 1/8] bnx2x: PFC fixes
Date: Tue, 5 Jul 2011 14:06:27 +0300
Message-ID: <1309863987.4050.80.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3865 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755879Ab1GELGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the source MAC address for PFC packets and update its status during PMF migration.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    2 +
 drivers/net/bnx2x/bnx2x_link.c |   87 +++++++++++++++++++++++-----------------
 drivers/net/bnx2x/bnx2x_reg.h  |   12 +++++
 3 files changed, 64 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index df53558..d6a7aa9 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -1196,6 +1196,8 @@ struct drv_port_mb {
 	#define LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE		0x00800000
 	#define LINK_STATUS_LINK_PARTNER_20GXFD_CAPABLE		0x10000000
 
+	#define LINK_STATUS_PFC_ENABLED				0x20000000
+
 	u32 port_stx;
 
 	u32 stat_nig_timer;
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 8363636..57ba811 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1344,28 +1344,21 @@ static void bnx2x_update_pfc_xmac(struct link_params *params,
 	REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL, pfc0_val);
 	REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL_HI, pfc1_val);
 
-	udelay(30);
-}
 
+	/* Set MAC address for source TX Pause/PFC frames */
+	REG_WR(bp, xmac_base + XMAC_REG_CTRL_SA_LO,
+	       ((params->mac_addr[2] << 24) |
+		(params->mac_addr[3] << 16) |
+		(params->mac_addr[4] << 8) |
+		(params->mac_addr[5])));
+	REG_WR(bp, xmac_base + XMAC_REG_CTRL_SA_HI,
+	       ((params->mac_addr[0] << 8) |
+		(params->mac_addr[1])));
 
-static void bnx2x_bmac2_get_pfc_stat(struct link_params *params,
-				     u32 pfc_frames_sent[2],
-				     u32 pfc_frames_received[2])
-{
-	/* Read pfc statistic */
-	struct bnx2x *bp = params->bp;
-	u32 bmac_addr = params->port ? NIG_REG_INGRESS_BMAC1_MEM :
-		NIG_REG_INGRESS_BMAC0_MEM;
-
-	DP(NETIF_MSG_LINK, "pfc statistic read from BMAC\n");
-
-	REG_RD_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_STAT_GTPP,
-					pfc_frames_sent, 2);
+	udelay(30);
+}
 
-	REG_RD_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_STAT_GRPP,
-					pfc_frames_received, 2);
 
-}
 static void bnx2x_emac_get_pfc_stat(struct link_params *params,
 				    u32 pfc_frames_sent[2],
 				    u32 pfc_frames_received[2])
@@ -1397,28 +1390,23 @@ static void bnx2x_emac_get_pfc_stat(struct link_params *params,
 	pfc_frames_sent[0] = val_xon + val_xoff;
 }
 
+/* Read pfc statistic*/
 void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 			 u32 pfc_frames_sent[2],
 			 u32 pfc_frames_received[2])
 {
 	/* Read pfc statistic */
 	struct bnx2x *bp = params->bp;
-	u32 val	= 0;
+
 	DP(NETIF_MSG_LINK, "pfc statistic\n");
 
 	if (!vars->link_up)
 		return;
 
-	val = REG_RD(bp, MISC_REG_RESET_REG_2);
-	if ((val & (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port))
-	    == 0) {
-		DP(NETIF_MSG_LINK, "About to read stats from EMAC\n");
+	if (MAC_TYPE_EMAC == vars->mac_type) {
+		DP(NETIF_MSG_LINK, "About to read PFC stats from EMAC\n");
 		bnx2x_emac_get_pfc_stat(params, pfc_frames_sent,
 					pfc_frames_received);
-	} else {
-		DP(NETIF_MSG_LINK, "About to read stats from BMAC\n");
-		bnx2x_bmac2_get_pfc_stat(params, pfc_frames_sent,
-					 pfc_frames_received);
 	}
 }
 /******************************************************************/
@@ -1561,6 +1549,16 @@ static void bnx2x_umac_enable(struct link_params *params,
 	REG_WR(bp, umac_base + UMAC_REG_COMMAND_CONFIG, val);
 	udelay(50);
 
+	/* Set MAC address for source TX Pause/PFC frames (under SW reset) */
+	REG_WR(bp, umac_base + UMAC_REG_MAC_ADDR0,
+	       ((params->mac_addr[2] << 24) |
+		(params->mac_addr[3] << 16) |
+		(params->mac_addr[4] << 8) |
+		(params->mac_addr[5])));
+	REG_WR(bp, umac_base + UMAC_REG_MAC_ADDR1,
+	       ((params->mac_addr[0] << 8) |
+		(params->mac_addr[1])));
+
 	/* Enable RX and TX */
 	val &= ~UMAC_COMMAND_CONFIG_REG_PAD_EN;
 	val |= UMAC_COMMAND_CONFIG_REG_TX_ENA |
@@ -2358,6 +2356,15 @@ int bnx2x_pfc_nig_rx_priority_mask(struct bnx2x *bp,
 
 	return 0;
 }
+static void bnx2x_update_mng(struct link_params *params, u32 link_status)
+{
+	struct bnx2x *bp = params->bp;
+
+	REG_WR(bp, params->shmem_base +
+	       offsetof(struct shmem_region,
+			port_mb[params->port].link_status), link_status);
+}
+
 static void bnx2x_update_pfc_nig(struct link_params *params,
 		struct link_vars *vars,
 		struct bnx2x_nig_brb_pfc_port_params *nig_params)
@@ -2467,6 +2474,14 @@ int bnx2x_update_pfc(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	int bnx2x_status = 0;
 	u8 bmac_loopback = (params->loopback_mode == LOOPBACK_BMAC);
+
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
+		vars->link_status |= LINK_STATUS_PFC_ENABLED;
+	else
+		vars->link_status &= ~LINK_STATUS_PFC_ENABLED;
+
+	bnx2x_update_mng(params, vars->link_status);
+
 	/* update NIG params */
 	bnx2x_update_pfc_nig(params, vars, pfc_params);
 
@@ -2695,16 +2710,6 @@ static int bnx2x_bmac_enable(struct link_params *params,
 	return rc;
 }
 
-
-static void bnx2x_update_mng(struct link_params *params, u32 link_status)
-{
-	struct bnx2x *bp = params->bp;
-
-	REG_WR(bp, params->shmem_base +
-	       offsetof(struct shmem_region,
-			port_mb[params->port].link_status), link_status);
-}
-
 static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 {
 	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
@@ -4453,6 +4458,14 @@ void bnx2x_link_status_update(struct link_params *params,
 
 	vars->aeu_int_mask = REG_RD(bp, sync_offset);
 
+	/* Sync PFC status */
+	if (vars->link_status & LINK_STATUS_PFC_ENABLED)
+		params->feature_config_flags |=
+					FEATURE_CONFIG_PFC_ENABLED;
+	else
+		params->feature_config_flags &=
+					~FEATURE_CONFIG_PFC_ENABLED;
+
 	DP(NETIF_MSG_LINK, "link_status 0x%x  phy_link_up %x int_mask 0x%x\n",
 		 vars->link_status, vars->phy_link_up, vars->aeu_int_mask);
 	DP(NETIF_MSG_LINK, "line_speed %x  duplex %x  flow_ctrl 0x%x\n",
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 53da4ef..064b445 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -4771,6 +4771,12 @@
 #define UMAC_COMMAND_CONFIG_REG_SW_RESET			 (0x1<<13)
 #define UMAC_COMMAND_CONFIG_REG_TX_ENA				 (0x1<<0)
 #define UMAC_REG_COMMAND_CONFIG					 0x8
+/* [RW 32] Register Bit 0 refers to Bit 16 of the MAC address; Bit 1 refers
+ * to bit 17 of the MAC address etc. */
+#define UMAC_REG_MAC_ADDR0					 0xc
+/* [RW 16] Register Bit 0 refers to Bit 0 of the MAC address; Register Bit 1
+ * refers to Bit 1 of the MAC address etc. Bits 16 to 31 are reserved. */
+#define UMAC_REG_MAC_ADDR1					 0x10
 /* [RW 14] Defines a 14-Bit maximum frame length used by the MAC receive
  * logic to check frames. */
 #define UMAC_REG_MAXFR						 0x14
@@ -5300,6 +5306,12 @@
 #define XMAC_PFC_CTRL_HI_REG_TX_PFC_EN				 (0x1<<5)
 #define XMAC_REG_CLEAR_RX_LSS_STATUS				 0x60
 #define XMAC_REG_CTRL						 0
+/* [RW 16] Upper 48 bits of ctrl_sa register. Used as the SA in PAUSE/PFC
+ * packets transmitted by the MAC */
+#define XMAC_REG_CTRL_SA_HI					 0x2c
+/* [RW 32] Lower 48 bits of ctrl_sa register. Used as the SA in PAUSE/PFC
+ * packets transmitted by the MAC */
+#define XMAC_REG_CTRL_SA_LO					 0x28
 #define XMAC_REG_PAUSE_CTRL					 0x68
 #define XMAC_REG_PFC_CTRL					 0x70
 #define XMAC_REG_PFC_CTRL_HI					 0x74
-- 
1.7.1








