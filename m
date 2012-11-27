From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 3/9] bnx2x: Change MDIO clock settings
Date: Tue, 27 Nov 2012 15:46:30 +0200
Message-ID: <1354023996-3512-4-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4472 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab2K0LrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:25 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When drivers works on top of an old bootcode, it is theoretically subjected to
MDC/MDIO failures since the MDIO clock is set in the beginning of each sequence,
rather than per CL45 command. On rare cases an old bootcodes may change that in
the middle, so to address that, the MDIO clock is set for each CL45 access.
In addition, setting the MDIO clock is now done per EMAC base, and
not per port number, since a specific port can potentially use both EMACs for
different PHY accesses.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   77 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    5 ++
 4 files changed, 66 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 525a9bc..a1a3ff4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1246,6 +1246,7 @@ struct drv_func_mb {
 	#define DRV_MSG_CODE_VRFY_AFEX_SUPPORTED        0xa2000000
 	#define REQ_BC_VER_4_VRFY_AFEX_SUPPORTED        0x00070002
 	#define REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED   0x00070014
+	#define REQ_BC_VER_4_MT_SUPPORTED               0x00070201
 	#define REQ_BC_VER_4_PFC_STATS_SUPPORTED        0x00070201
 	#define REQ_BC_VER_4_FCOE_FEATURES              0x00070209
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index eb44b23..e054921 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1441,30 +1441,47 @@ void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 /******************************************************************/
 /*			MAC/PBF section				  */
 /******************************************************************/
-static void bnx2x_set_mdio_clk(struct bnx2x *bp, u32 chip_id, u8 port)
+static void bnx2x_set_mdio_clk(struct bnx2x *bp, u32 chip_id,
+			       u32 emac_base)
 {
-	u32 mode, emac_base;
+	u32 new_mode, cur_mode;
+	u32 clc_cnt;
 	/* Set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
+	cur_mode = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
 
-	if (CHIP_IS_E2(bp))
-		emac_base = GRCBASE_EMAC0;
-	else
-		emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	mode = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-	mode &= ~(EMAC_MDIO_MODE_AUTO_POLL |
-		  EMAC_MDIO_MODE_CLOCK_CNT);
 	if (USES_WARPCORE(bp))
-		mode |= (74L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
+		clc_cnt = 74L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT;
 	else
-		mode |= (49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
+		clc_cnt = 49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT;
 
-	mode |= (EMAC_MDIO_MODE_CLAUSE_45);
-	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE, mode);
+	if (((cur_mode & EMAC_MDIO_MODE_CLOCK_CNT) == clc_cnt) &&
+	    (cur_mode & (EMAC_MDIO_MODE_CLAUSE_45)))
+		return;
+
+	new_mode = cur_mode &
+		~(EMAC_MDIO_MODE_AUTO_POLL | EMAC_MDIO_MODE_CLOCK_CNT);
+	new_mode |= clc_cnt;
+	new_mode |= (EMAC_MDIO_MODE_CLAUSE_45);
 
+	DP(NETIF_MSG_LINK, "Changing emac_mode from 0x%x to 0x%x\n",
+	   cur_mode, new_mode);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE, new_mode);
 	udelay(40);
 }
+
+static void bnx2x_set_mdio_emac_per_phy(struct bnx2x *bp,
+					struct link_params *params)
+{
+	u8 phy_index;
+	/* Set mdio clock per phy */
+	for (phy_index = INT_PHY; phy_index < params->num_phys;
+	      phy_index++)
+		bnx2x_set_mdio_clk(bp, params->chip_id,
+				   params->phy[phy_index].mdio_ctrl);
+}
+
 static u8 bnx2x_is_4_port_mode(struct bnx2x *bp)
 {
 	u32 port4mode_ovwr_val;
@@ -1509,7 +1526,8 @@ static void bnx2x_emac_init(struct link_params *params,
 		}
 		timeout--;
 	} while (val & EMAC_MODE_RESET);
-	bnx2x_set_mdio_clk(bp, params->chip_id, port);
+
+	bnx2x_set_mdio_emac_per_phy(bp, params);
 	/* Set mac address */
 	val = ((params->mac_addr[0] << 8) |
 		params->mac_addr[1]);
@@ -2683,6 +2701,13 @@ static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 	u32 val;
 	u16 i;
 	int rc = 0;
+	u32 chip_id;
+	if (phy->flags & FLAGS_MDC_MDIO_WA_G) {
+		chip_id = (REG_RD(bp, MISC_REG_CHIP_NUM) << 16) |
+			  ((REG_RD(bp, MISC_REG_CHIP_REV) & 0xf) << 12);
+		bnx2x_set_mdio_clk(bp, chip_id, phy->mdio_ctrl);
+	}
+
 	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
 		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
 			      EMAC_MDIO_STATUS_10MB);
@@ -2751,6 +2776,13 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 	u32 tmp;
 	u8 i;
 	int rc = 0;
+	u32 chip_id;
+	if (phy->flags & FLAGS_MDC_MDIO_WA_G) {
+		chip_id = (REG_RD(bp, MISC_REG_CHIP_NUM) << 16) |
+			  ((REG_RD(bp, MISC_REG_CHIP_REV) & 0xf) << 12);
+		bnx2x_set_mdio_clk(bp, chip_id, phy->mdio_ctrl);
+	}
+
 	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
 		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
 			      EMAC_MDIO_STATUS_10MB);
@@ -4508,7 +4540,7 @@ static void bnx2x_warpcore_link_reset(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 val16, lane;
 	bnx2x_sfp_e3_set_transmitter(params, phy, 0);
-	bnx2x_set_mdio_clk(bp, params->chip_id, params->port);
+	bnx2x_set_mdio_emac_per_phy(bp, params);
 	bnx2x_set_aer_mmd(params, phy);
 	/* Global register */
 	bnx2x_warpcore_reset_lane(bp, phy, 1);
@@ -8600,7 +8632,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 
 	/* Call the handling function in case module is detected */
 	if (gpio_val == 0) {
-		bnx2x_set_mdio_clk(bp, params->chip_id, params->port);
+		bnx2x_set_mdio_emac_per_phy(bp, params);
 		bnx2x_set_aer_mmd(params, phy);
 
 		bnx2x_power_sfp_module(params, phy, 1);
@@ -12100,6 +12132,10 @@ int bnx2x_phy_probe(struct link_params *params)
 		    FEATURE_CONFIG_DISABLE_REMOTE_FAULT_DET)
 			phy->flags &= ~FLAGS_TX_ERROR_CHECK;
 
+		if (!(params->feature_config_flags &
+		      FEATURE_CONFIG_MT_SUPPORT))
+			phy->flags |= FLAGS_MDC_MDIO_WA_G;
+
 		sync_offset = params->shmem_base +
 			offsetof(struct shmem_region,
 			dev_info.port_hw_config[params->port].media_type);
@@ -12542,7 +12578,7 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 * Hold it as vars low
 	 */
 	 /* Clear link led */
-	bnx2x_set_mdio_clk(bp, params->chip_id, port);
+	bnx2x_set_mdio_emac_per_phy(bp, params);
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	if (reset_ext_phy) {
@@ -13019,12 +13055,12 @@ int bnx2x_pre_init_phy(struct bnx2x *bp,
 {
 	int rc = 0;
 	struct bnx2x_phy phy;
-	bnx2x_set_mdio_clk(bp, chip_id, PORT_0);
 	if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base, shmem2_base,
 			       PORT_0, &phy)) {
 		DP(NETIF_MSG_LINK, "populate_phy failed\n");
 		return -EINVAL;
 	}
+	bnx2x_set_mdio_clk(bp, chip_id, phy.mdio_ctrl);
 	switch (phy.type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
 		rc = bnx2x_84833_pre_init_phy(bp, &phy);
@@ -13095,8 +13131,9 @@ int bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
 	u32 phy_ver, val;
 	u8 phy_index = 0;
 	u32 ext_phy_type, ext_phy_config;
-	bnx2x_set_mdio_clk(bp, chip_id, PORT_0);
-	bnx2x_set_mdio_clk(bp, chip_id, PORT_1);
+
+	bnx2x_set_mdio_clk(bp, chip_id, GRCBASE_EMAC0);
+	bnx2x_set_mdio_clk(bp, chip_id, GRCBASE_EMAC1);
 	DP(NETIF_MSG_LINK, "Begin common phy init\n");
 	if (CHIP_IS_E3(bp)) {
 		/* Enable EPIO */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 33940fb..24246b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -156,6 +156,7 @@ struct bnx2x_phy {
 #define FLAGS_MDC_MDIO_WA_B0		(1<<10)
 #define FLAGS_TX_ERROR_CHECK		(1<<12)
 #define FLAGS_EEE			(1<<13)
+#define FLAGS_MDC_MDIO_WA_G	(1<<15)
 
 	/* preemphasis values for the rx side */
 	u16 rx_preemphasis[4];
@@ -267,6 +268,8 @@ struct link_params {
 #define FEATURE_CONFIG_AUTOGREEEN_ENABLED			(1<<9)
 #define FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED		(1<<10)
 #define FEATURE_CONFIG_DISABLE_REMOTE_FAULT_DET		(1<<11)
+#define FEATURE_CONFIG_MT_SUPPORT			(1<<13)
+
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6d125c2..c7303cd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9918,6 +9918,11 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->link_params.feature_config_flags |=
 		(val >= REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED) ?
 		FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED : 0;
+
+	bp->link_params.feature_config_flags |=
+		(val >= REQ_BC_VER_4_MT_SUPPORTED) ?
+		FEATURE_CONFIG_MT_SUPPORT : 0;
+
 	bp->flags |= (val >= REQ_BC_VER_4_PFC_STATS_SUPPORTED) ?
 			BC_SUPPORTS_PFC_STATS : 0;
 
-- 
1.7.1
