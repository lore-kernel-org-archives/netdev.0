From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: [net 2/3] gianfar: Refactor link speed update (adjust_link)
Date: Fri, 1 Sep 2017 12:41:02 +0300
Message-ID: <1504258863-2058-3-git-send-email-claudiu.manoil@nxp.com>
References: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0076.outbound.protection.outlook.com ([104.47.38.76]:57818
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751828AbdIAJlL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 05:41:11 -0400
In-Reply-To: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Encapsulate link speed update logic. These settings affect only
the maccfg2 and ecntrl regs.

Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 92 +++++++++++++++++---------------
 1 file changed, 49 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5be52d8..46880a9 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3672,6 +3672,54 @@ static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
 	return val;
 }
 
+static void gfar_update_link_speed(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	struct phy_device *phydev = priv->ndev->phydev;
+	u32 maccfg2, ecntrl;
+
+	maccfg2 = gfar_read(&regs->maccfg2);
+	ecntrl = gfar_read(&regs->ecntrl);
+
+	if (phydev->duplex != priv->oldduplex) {
+		if (!(phydev->duplex))
+			maccfg2 &= ~(MACCFG2_FULL_DUPLEX);
+		else
+			maccfg2 |= MACCFG2_FULL_DUPLEX;
+
+		priv->oldduplex = phydev->duplex;
+	}
+
+	if (phydev->speed != priv->oldspeed) {
+		switch (phydev->speed) {
+		case 1000:
+			maccfg2 = ((maccfg2 & ~(MACCFG2_IF)) | MACCFG2_GMII);
+
+			ecntrl &= ~(ECNTRL_R100);
+			break;
+		case 100:
+		case 10:
+			maccfg2 = ((maccfg2 & ~(MACCFG2_IF)) | MACCFG2_MII);
+
+			/* Reduced mode distinguishes between 10 and 100 */
+			if (phydev->speed == SPEED_100)
+				ecntrl |= ECNTRL_R100;
+			else
+				ecntrl &= ~(ECNTRL_R100);
+			break;
+		default:
+			netif_warn(priv, link, priv->ndev,
+				   "Invalid link speed!\n");
+			break;
+		}
+
+		priv->oldspeed = phydev->speed;
+	}
+
+	gfar_write(&regs->maccfg2, maccfg2);
+	gfar_write(&regs->ecntrl, ecntrl);
+}
+
 static noinline void gfar_update_link_state(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
@@ -3685,49 +3733,9 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 
 	if (phydev->link) {
 		u32 tempval1 = gfar_read(&regs->maccfg1);
-		u32 tempval = gfar_read(&regs->maccfg2);
-		u32 ecntrl = gfar_read(&regs->ecntrl);
 		u32 tx_flow_oldval = (tempval1 & MACCFG1_TX_FLOW);
 
-		if (phydev->duplex != priv->oldduplex) {
-			if (!(phydev->duplex))
-				tempval &= ~(MACCFG2_FULL_DUPLEX);
-			else
-				tempval |= MACCFG2_FULL_DUPLEX;
-
-			priv->oldduplex = phydev->duplex;
-		}
-
-		if (phydev->speed != priv->oldspeed) {
-			switch (phydev->speed) {
-			case 1000:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
-
-				ecntrl &= ~(ECNTRL_R100);
-				break;
-			case 100:
-			case 10:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
-
-				/* Reduced mode distinguishes
-				 * between 10 and 100
-				 */
-				if (phydev->speed == SPEED_100)
-					ecntrl |= ECNTRL_R100;
-				else
-					ecntrl &= ~(ECNTRL_R100);
-				break;
-			default:
-				netif_warn(priv, link, priv->ndev,
-					   "Ack!  Speed (%d) is not 10/100/1000!\n",
-					   phydev->speed);
-				break;
-			}
-
-			priv->oldspeed = phydev->speed;
-		}
+		gfar_update_link_speed(priv);
 
 		tempval1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
 		tempval1 |= gfar_get_flowctrl_cfg(priv);
@@ -3749,8 +3757,6 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 			priv->tx_actual_en = 0;
 
 		gfar_write(&regs->maccfg1, tempval1);
-		gfar_write(&regs->maccfg2, tempval);
-		gfar_write(&regs->ecntrl, ecntrl);
 
 		if (!priv->oldlink)
 			priv->oldlink = 1;
-- 
2.7.4
