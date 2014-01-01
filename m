From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net 3/5] bnx2x: Fix Duplex setting for 54618se
Date: Wed, 1 Jan 2014 11:06:43 +0200
Message-ID: <1388567205-20210-4-git-send-email-yanivr@broadcom.com>
References: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:37581 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390AbaAAJIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:08:06 -0500
In-Reply-To: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM54618SE is used to advertise half-duplex even if HD was not requested by the
user. This change makes the legacy speed/duplex advertisement for this PHY
exactly according to the requested speed and duplex.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   54 +++++++++++----------
 1 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 000b6ee..68417e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10841,9 +10841,9 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 			   (1<<11));
 
 	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-			(phy->speed_cap_mask &
-			PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
-			(phy->req_line_speed == SPEED_1000)) {
+	     (phy->speed_cap_mask &
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
+	    (phy->req_line_speed == SPEED_1000)) {
 		an_1000_val |= (1<<8);
 		autoneg_val |= (1<<9 | 1<<12);
 		if (phy->req_duplex == DUPLEX_FULL)
@@ -10859,30 +10859,32 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 			0x09,
 			&an_1000_val);
 
-	/* Set 100 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-			(phy->speed_cap_mask &
-			(PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-			PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
-		an_10_100_val |= (1<<7);
-		/* Enable autoneg and restart autoneg for legacy speeds */
-		autoneg_val |= (1<<9 | 1<<12);
-
-		if (phy->req_duplex == DUPLEX_FULL)
-			an_10_100_val |= (1<<8);
-		DP(NETIF_MSG_LINK, "Advertising 100M\n");
-	}
-
-	/* Set 10 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-			(phy->speed_cap_mask &
-			(PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-			PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
-		an_10_100_val |= (1<<5);
-		autoneg_val |= (1<<9 | 1<<12);
-		if (phy->req_duplex == DUPLEX_FULL)
+	/* Advertise 10/100 link speed */
+	if (phy->req_line_speed == SPEED_AUTO_NEG) {
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF) {
+			an_10_100_val |= (1<<5);
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 10M-HD\n");
+		}
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) {
 			an_10_100_val |= (1<<6);
-		DP(NETIF_MSG_LINK, "Advertising 10M\n");
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 10M-FD\n");
+		}
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF) {
+			an_10_100_val |= (1<<7);
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 100M-HD\n");
+		}
+		if (phy->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL) {
+			an_10_100_val |= (1<<8);
+			autoneg_val |= (1<<9 | 1<<12);
+			DP(NETIF_MSG_LINK, "Advertising 100M-FD\n");
+		}
 	}
 
 	/* Only 10/100 are allowed to work in FORCE mode */
-- 
1.7.1
