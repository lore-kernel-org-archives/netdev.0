From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next v2 3/9] bnx2x: Warpcore HW reset following fan
 failure
Date: Mon, 28 Nov 2011 12:49:47 +0200
Message-ID: <1322477393-22904-4-git-send-email-yanivr@broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4085 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435Ab1K1Ium (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 03:50:42 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put Warpcore in low power mode in case of fan failure to reduce heat.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    9 +++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index de03730..7eabcee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -8216,7 +8216,15 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 static void bnx2x_warpcore_hw_reset(struct bnx2x_phy *phy,
 				    struct link_params *params)
 {
+	struct bnx2x *bp = params->bp;
 	bnx2x_warpcore_power_module(params, phy, 0);
+	/* Put Warpcore in low power mode */
+	REG_WR(bp, MISC_REG_WC0_RESET, 0x0c0e);
+
+	/* Put LCPLL in low power mode */
+	REG_WR(bp, MISC_REG_LCPLL_E40_PWRDWN, 1);
+	REG_WR(bp, MISC_REG_LCPLL_E40_RESETB_ANA, 0);
+	REG_WR(bp, MISC_REG_LCPLL_E40_RESETB_DIG, 0);
 }
 
 static void bnx2x_power_sfp_module(struct link_params *params,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 92584d3..d5a0dde 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1622,6 +1622,14 @@
    register bits. */
 #define MISC_REG_LCPLL_CTRL_1					 0xa2a4
 #define MISC_REG_LCPLL_CTRL_REG_2				 0xa2a8
+/* [RW 1] LCPLL power down. Global register. Active High. Reset on POR
+ * reset. */
+#define MISC_REG_LCPLL_E40_PWRDWN				 0xaa74
+/* [RW 1] LCPLL VCO reset. Global register. Active Low Reset on POR reset. */
+#define MISC_REG_LCPLL_E40_RESETB_ANA				 0xaa78
+/* [RW 1] LCPLL post-divider reset. Global register. Active Low Reset on POR
+ * reset. */
+#define MISC_REG_LCPLL_E40_RESETB_DIG				 0xaa7c
 /* [RW 4] Interrupt mask register #0 read/write */
 #define MISC_REG_MISC_INT_MASK					 0xa388
 /* [RW 1] Parity mask register #0 read/write */
@@ -1757,6 +1765,7 @@
  * is compared to the value on ctrl_md_devad. Drives output
  * misc_xgxs0_phy_addr. Global register. */
 #define MISC_REG_WC0_CTRL_PHY_ADDR				 0xa9cc
+#define MISC_REG_WC0_RESET					 0xac30
 /* [RW 2] XMAC Core port mode. Indicates the number of ports on the system
    side. This should be less than or equal to phy_port_mode; if some of the
    ports are not used. This enables reduction of frequency on the core side.
-- 
1.7.7.1
