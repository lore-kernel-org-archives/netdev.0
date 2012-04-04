From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 03/10] bnx2x: Fix BCM57810-KR AN speed transition
Date: Wed, 4 Apr 2012 14:28:56 +0300
Message-ID: <1333538942-9904-4-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2757 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047Ab2DDJ3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:32 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM57810-KR link may not come up in 1G after running loopback test, so set
the relevant registers to their default values before starting KR autoneg.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 8c00bbc..ce0b0c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3732,7 +3732,23 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	u16 val16 = 0, lane, bam37 = 0;
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "Enable Auto Negotiation for KR\n");
-
+	/* Set to default registers that may be overriden by 10G force */
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+			 MDIO_WC_REG_PAR_DET_10G_CTRL, 0);
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			 MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, 0);
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0xff);
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0x5555);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
+			 MDIO_WC_REG_IEEE0BLK_AUTONEGNP, 0x0);
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			 MDIO_WC_REG_RX66_CONTROL, 0x7415);
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			 MDIO_WC_REG_SERDESDIGITAL_MISC2, 0x6190);
 	/* Disable Autoneg: re-enable it after adv is done. */
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0);
@@ -4402,7 +4418,7 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 		switch (serdes_net_if) {
 		case PORT_HW_CFG_NET_SERDES_IF_KR:
 			/* Enable KR Auto Neg */
-			if (params->loopback_mode == LOOPBACK_NONE)
+			if (params->loopback_mode != LOOPBACK_EXT)
 				bnx2x_warpcore_enable_AN_KR(phy, params, vars);
 			else {
 				DP(NETIF_MSG_LINK, "Setting KR 10G-Force\n");
-- 
1.7.7.1
