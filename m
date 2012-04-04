From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 06/10] bnx2x: Fix link issue for BCM8727 boards.
Date: Wed, 4 Apr 2012 14:28:59 +0300
Message-ID: <1333538942-9904-7-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2061 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109Ab2DDJ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:39 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a link problem on BCM57712 + BCM8727 designs in which the TX
laser is controller by GPIO, after 1.60.xx drivers were previously loaded.
On these designs the TX_LASER is enabled by logic AND between the PHY
(through MDIO), and the GPIO. When an old driver is used, it disables the
MDIO part, hence the GPIO control had no affect de facto.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 1438da8..732b4c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -8089,7 +8089,9 @@ static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	netdev_err(bp->dev,  "Warning: Unqualified SFP+ module detected,"
 			      " Port %d from %s part number %s\n",
 			 params->port, vendor_name, vendor_pn);
-	phy->flags |= FLAGS_SFP_NOT_APPROVED;
+	if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) !=
+	    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_WARNING_MSG)
+		phy->flags |= FLAGS_SFP_NOT_APPROVED;
 	return -EINVAL;
 }
 
@@ -9149,6 +9151,12 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		tmp2 &= 0xFFEF;
 		bnx2x_cl45_write(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_OPT_CFG_REG, tmp2);
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER,
+				&tmp2);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER,
+				 (tmp2 & 0x7fff));
 	}
 
 	return 0;
@@ -9329,12 +9337,11 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL,
 				 ((1<<5) | (1<<2)));
 	}
-	DP(NETIF_MSG_LINK, "Enabling 8727 TX laser if SFP is approved\n");
-	bnx2x_8727_specific_func(phy, params, ENABLE_TX);
-	/* If transmitter is disabled, ignore false link up indication */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &val1);
-	if (val1 & (1<<15)) {
+
+	if (!(phy->flags & FLAGS_SFP_NOT_APPROVED)) {
+		DP(NETIF_MSG_LINK, "Enabling 8727 TX laser\n");
+		bnx2x_sfp_set_transmitter(params, phy, 1);
+	} else {
 		DP(NETIF_MSG_LINK, "Tx is disabled\n");
 		return 0;
 	}
-- 
1.7.7.1
