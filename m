From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: [net 3/3] gianfar: Refactor link flow control update (adjust_link)
Date: Fri, 1 Sep 2017 12:41:03 +0300
Message-ID: <1504258863-2058-4-git-send-email-claudiu.manoil@nxp.com>
References: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0079.outbound.protection.outlook.com ([104.47.32.79]:53471
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751705AbdIAJlM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 05:41:12 -0400
In-Reply-To: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Encapsulate link layer flow control logic. These settings
are touching maccfg1 reg exclusively.

Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 68 ++++++++++++++++----------------
 1 file changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 46880a9..1648173 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3672,6 +3672,36 @@ static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
 	return val;
 }
 
+static void gfar_update_link_flowctrl(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 maccfg1, tx_flow_oldval;
+	int i;
+
+	maccfg1 = gfar_read(&regs->maccfg1);
+	tx_flow_oldval = (maccfg1 & MACCFG1_TX_FLOW);
+
+	maccfg1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
+	maccfg1 |= gfar_get_flowctrl_cfg(priv);
+
+	/* Turn last free buffer recording on */
+	if ((maccfg1 & MACCFG1_TX_FLOW) && !tx_flow_oldval) {
+		for (i = 0; i < priv->num_rx_queues; i++) {
+			u32 bdp_dma;
+
+			bdp_dma = gfar_rxbd_dma_lastfree(priv->rx_queue[i]);
+			gfar_write(priv->rx_queue[i]->rfbptr, bdp_dma);
+		}
+
+		priv->tx_actual_en = 1;
+	}
+
+	if (unlikely(!(maccfg1 & MACCFG1_TX_FLOW) && tx_flow_oldval))
+		priv->tx_actual_en = 0;
+
+	gfar_write(&regs->maccfg1, maccfg1);
+}
+
 static void gfar_update_link_speed(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
@@ -3722,44 +3752,14 @@ static void gfar_update_link_speed(struct gfar_private *priv)
 
 static noinline void gfar_update_link_state(struct gfar_private *priv)
 {
-	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	struct net_device *ndev = priv->ndev;
-	struct phy_device *phydev = ndev->phydev;
-	struct gfar_priv_rx_q *rx_queue = NULL;
-	int i;
-
 	if (unlikely(test_bit(GFAR_RESETTING, &priv->state)))
 		return;
 
-	if (phydev->link) {
-		u32 tempval1 = gfar_read(&regs->maccfg1);
-		u32 tx_flow_oldval = (tempval1 & MACCFG1_TX_FLOW);
-
+	if (priv->ndev->phydev->link) {
+		gfar_update_link_flowctrl(priv);
 		gfar_update_link_speed(priv);
 
-		tempval1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
-		tempval1 |= gfar_get_flowctrl_cfg(priv);
-
-		/* Turn last free buffer recording on */
-		if ((tempval1 & MACCFG1_TX_FLOW) && !tx_flow_oldval) {
-			for (i = 0; i < priv->num_rx_queues; i++) {
-				u32 bdp_dma;
-
-				rx_queue = priv->rx_queue[i];
-				bdp_dma = gfar_rxbd_dma_lastfree(rx_queue);
-				gfar_write(rx_queue->rfbptr, bdp_dma);
-			}
-
-			priv->tx_actual_en = 1;
-		}
-
-		if (unlikely(!(tempval1 & MACCFG1_TX_FLOW) && tx_flow_oldval))
-			priv->tx_actual_en = 0;
-
-		gfar_write(&regs->maccfg1, tempval1);
-
-		if (!priv->oldlink)
-			priv->oldlink = 1;
+		priv->oldlink = 1;
 
 	} else if (priv->oldlink) {
 		priv->oldlink = 0;
@@ -3768,7 +3768,7 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 	}
 
 	if (netif_msg_link(priv))
-		phy_print_status(phydev);
+		phy_print_status(priv->ndev->phydev);
 }
 
 static const struct of_device_id gfar_match[] =
-- 
2.7.4
