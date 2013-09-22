From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 5/5] bnx2x: Fix 848xx duplex settings
Date: Sun, 22 Sep 2013 14:59:26 +0300
Message-ID: <1379851166-11959-6-git-send-email-yanivr@broadcom.com>
References: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4017 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753171Ab3IVMAC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 08:00:02 -0400
In-Reply-To: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 848xx PHY (10G-baseT), half-duplex was always advertised regardless of the
actual configuration. Change the 848xx duplex settings to advertise half-duplex
only if configured.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   57 +++++++++++++---------
 1 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index dc67566..5146822 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9765,32 +9765,41 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
 			 an_1000_val);
 
-	/* set 100 speed advertisement */
-	if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	     (phy->speed_cap_mask &
-	      (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-	       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))) {
-		an_10_100_val |= (1<<7);
-		/* Enable autoneg and restart autoneg for legacy speeds */
-		autoneg_val |= (1<<9 | 1<<12);
-
-		if (phy->req_duplex == DUPLEX_FULL)
+	/* Set 10/100 speed advertisement */
+	if (phy->req_line_speed == SPEED_AUTO_NEG) {
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL) {
+			/* Enable autoneg and restart autoneg for legacy speeds
+			 */
+			autoneg_val |= (1<<9 | 1<<12);
 			an_10_100_val |= (1<<8);
-		DP(NETIF_MSG_LINK, "Advertising 100M\n");
-	}
-	/* set 10 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	     (phy->speed_cap_mask &
-	      (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-	       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)) &&
-	     (phy->supported &
-	      (SUPPORTED_10baseT_Half |
-	       SUPPORTED_10baseT_Full)))) {
-		an_10_100_val |= (1<<5);
-		autoneg_val |= (1<<9 | 1<<12);
-		if (phy->req_duplex == DUPLEX_FULL)
+			DP(NETIF_MSG_LINK, "Advertising 100M-FD\n");
+		}
+
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF) {
+			/* Enable autoneg and restart autoneg for legacy speeds
+			 */
+			autoneg_val |= (1<<9 | 1<<12);
+			an_10_100_val |= (1<<7);
+			DP(NETIF_MSG_LINK, "Advertising 100M-HD\n");
+		}
+
+		if ((phy->speed_cap_mask &
+		     PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) &&
+		    (phy->supported & SUPPORTED_10baseT_Full)) {
 			an_10_100_val |= (1<<6);
-		DP(NETIF_MSG_LINK, "Advertising 10M\n");
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 10M-FD\n");
+		}
+
+		if ((phy->speed_cap_mask &
+		     PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF) &&
+		    (phy->supported & SUPPORTED_10baseT_Half)) {
+			an_10_100_val |= (1<<5);
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 10M-HD\n");
+		}
 	}
 
 	/* Only 10/100 are allowed to work in FORCE mode */
-- 
1.7.1
