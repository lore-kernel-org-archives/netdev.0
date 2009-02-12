From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 19/41]bnx2x: Using the HW 5th lane
Date: Thu, 12 Feb 2009 20:37:07 +0200
Message-ID: <1234463827.1863.151.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1670 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759081AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 19/41]bnx2x: Using the HW 5th lane
This 1G interface (on top of the 4 lanes 10G interface) requires additional
setting to work in CL45

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   35 +++++++++++++++++++++++++++++------
 drivers/net/bnx2x_reg.h  |    4 ++++
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index f4c699e..2463de8 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -174,13 +174,34 @@
 		(_bank + (_addr & 0xf)), \
 		_val)
 
-static void bnx2x_set_phy_mdio(struct link_params *params)
+static void bnx2x_set_serdes_access(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
-		   params->port*0x18, 0);
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + params->port*0x18,
-		   DEFAULT_PHY_DEV_ADDR);
+	u32 emac_base = (params->port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	/* Set Clause 22 */
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + params->port*0x10, 1);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245f8000);
+	udelay(500);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245d000f);
+	udelay(500);
+	 /* Set Clause 45 */
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + params->port*0x10, 0);
+}
+static void bnx2x_set_phy_mdio(struct link_params *params, u8 phy_flags)
+{
+	struct bnx2x *bp = params->bp;
+	if (phy_flags & PHY_XGXS_FLAG) {
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
+			   params->port*0x18, 0);
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + params->port*0x18,
+			   DEFAULT_PHY_DEV_ADDR);
+	} else {
+		bnx2x_set_serdes_access(params);
+
+		REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
+			   params->port*0x10,
+			   DEFAULT_PHY_DEV_ADDR);
+	}
 }
 
 static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
@@ -520,7 +541,7 @@ static void bnx2x_phy_deassert(struct link_params *params, u8 phy_flags)
 	udelay(500);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET,
 		    val);
-	bnx2x_set_phy_mdio(params);
+	bnx2x_set_phy_mdio(params, phy_flags);
 }
 
 void bnx2x_link_status_update(struct link_params *params,
@@ -996,6 +1017,8 @@ static u8 bnx2x_reset_unicore(struct link_params *params)
 			      (mii_control |
 			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
 
+	bnx2x_set_serdes_access(params);
+
 	/* wait for the reset to self clear */
 	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
 		udelay(5);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index b6c9249..d3086e9 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1815,6 +1815,10 @@
 #define NIG_REG_PRS_EOP_OUT_EN					 0x10104
 /* [RW 1] Input enable for RX parser request IF */
 #define NIG_REG_PRS_REQ_IN_EN					 0x100b8
+/* [RW 5] control to serdes - CL45 DEVAD */
+#define NIG_REG_SERDES0_CTRL_MD_DEVAD				 0x10370
+/* [RW 1] control to serdes; 0 - clause 45; 1 - clause 22 */
+#define NIG_REG_SERDES0_CTRL_MD_ST				 0x1036c
 /* [RW 5] control to serdes - CL22 PHY_ADD and CL45 PRTAD */
 #define NIG_REG_SERDES0_CTRL_PHY_ADDR				 0x10374
 /* [R 1] status from serdes0 that inputs to interrupt logic of link status */
-- 
1.5.4.3




