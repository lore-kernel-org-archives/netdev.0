From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: disable at run-time the EEE if not supported
Date: Mon, 19 Aug 2013 08:38:07 +0200
Message-ID: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:35433 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750862Ab3HSGo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 02:44:29 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 58FEC6D
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 06:44:16 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E260B2BCF
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 06:43:46 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to disable the EEE (so HW and timers)
for example when the phy communicates that the EEE
can be supported nomore.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   24 ++++++++++++++++----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0a9bb9d..75cc2d3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -285,10 +285,25 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
+		int tx_lpi_timer = priv->tx_lpi_timer;
+
 		/* Check if the PHY supports EEE */
-		if (phy_init_eee(priv->phydev, 1))
+		if (phy_init_eee(priv->phydev, 1)) {
+			/* To manage at run-time if the EEE cannot be supported
+			 * anymore (for example becasue the lp caps have been
+			 * changed).
+			 * In that case the driver disable own timers.
+			 */
+			if (priv->eee_active) {
+				pr_debug("stmmac: disable EEE\n");
+				del_timer_sync(&priv->eee_ctrl_timer);
+				priv->hw->mac->set_eee_timer(priv->ioaddr, 0,
+							     tx_lpi_timer);
+			}
+			priv->eee_active = 0;
 			goto out;
-
+		}
+		/* Activate the EEE and start timers */
 		if (!priv->eee_active) {
 			priv->eee_active = 1;
 			init_timer(&priv->eee_ctrl_timer);
@@ -299,13 +314,13 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 
 			priv->hw->mac->set_eee_timer(priv->ioaddr,
 						     STMMAC_DEFAULT_LIT_LS,
-						     priv->tx_lpi_timer);
+						     tx_lpi_timer);
 		} else
 			/* Set HW EEE according to the speed */
 			priv->hw->mac->set_eee_pls(priv->ioaddr,
 						   priv->phydev->link);
 
-		pr_info("stmmac: Energy-Efficient Ethernet initialized\n");
+		pr_debug("stmmac: Energy-Efficient Ethernet initialized\n");
 
 		ret = true;
 	}
@@ -2166,7 +2181,6 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 static void stmmac_tx_timeout(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-
 	/* Clear Tx resources and restart transmitting again */
 	stmmac_tx_err(priv);
 }
-- 
1.7.4.4
