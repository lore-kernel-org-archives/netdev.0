From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net] bnx2x: Fix 5461x LED
Date: Wed, 23 Nov 2011 15:54:08 +0200
Message-ID: <1322056448-22290-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4200 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab1KWLzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 06:55:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix port identify test on 5461x PHY by driving LEDs through MDIO.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   39 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index bce203f..882f48f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10327,6 +10327,43 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
+
+static void bnx2x_5461x_set_link_led(struct bnx2x_phy *phy,
+				       struct link_params *params, u8 mode)
+{
+	struct bnx2x *bp = params->bp;
+	u16 temp;
+
+	bnx2x_cl22_write(bp, phy,
+		MDIO_REG_GPHY_SHADOW,
+		MDIO_REG_GPHY_SHADOW_LED_SEL1);
+	bnx2x_cl22_read(bp, phy,
+		MDIO_REG_GPHY_SHADOW,
+		&temp);
+	temp &= 0xff00;
+
+	DP(NETIF_MSG_LINK, "54618x set link led (mode=%x)\n", mode);
+	switch (mode) {
+	case LED_MODE_FRONT_PANEL_OFF:
+	case LED_MODE_OFF:
+		temp |= 0x00ee;
+		break;
+	case LED_MODE_OPER:
+		temp |= 0x0001;
+		break;
+	case LED_MODE_ON:
+		temp |= 0x00ff;
+		break;
+	default:
+		break;
+	}
+	bnx2x_cl22_write(bp, phy,
+		MDIO_REG_GPHY_SHADOW,
+		MDIO_REG_GPHY_SHADOW_WR_ENA | temp);
+	return;
+}
+
+
 static void bnx2x_54618se_link_reset(struct bnx2x_phy *phy,
 				     struct link_params *params)
 {
@@ -11103,7 +11140,7 @@ static struct bnx2x_phy phy_54618se = {
 	.config_loopback = (config_loopback_t)bnx2x_54618se_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_5461x_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 /*****************************************************************/
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index fc7bd0f..e58073e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6990,6 +6990,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_REG_INTR_MASK				0x1b
 #define MDIO_REG_INTR_MASK_LINK_STATUS			(0x1 << 1)
 #define MDIO_REG_GPHY_SHADOW				0x1c
+#define MDIO_REG_GPHY_SHADOW_LED_SEL1			(0x0d << 10)
 #define MDIO_REG_GPHY_SHADOW_LED_SEL2			(0x0e << 10)
 #define MDIO_REG_GPHY_SHADOW_WR_ENA			(0x1 << 15)
 #define MDIO_REG_GPHY_SHADOW_AUTO_DET_MED		(0x1e << 10)
-- 
1.7.7.1
