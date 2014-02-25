From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/6] stmmac: disable at run-time the EEE if not supported
Date: Tue, 25 Feb 2014 10:58:24 +0100
Message-ID: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:52602 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752914AbaBYK3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 05:29:15 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 614AE1C4
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:51 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CF2B4B530
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:50 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to disable the EEE (so HW and timers)
for example when the phy communicates that the EEE
can be supported anymore.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   24 ++++++++++++++++----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 078ad0e..dc89dc3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -286,10 +286,25 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
+		int tx_lpi_timer = priv->tx_lpi_timer;
+
 		/* Check if the PHY supports EEE */
-		if (phy_init_eee(priv->phydev, 1))
+		if (phy_init_eee(priv->phydev, 1)) {
+			/* To manage at run-time if the EEE cannot be supported
+			 * anymore (for example because the lp caps have been
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
@@ -300,13 +315,13 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 
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
@@ -2204,7 +2219,6 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 static void stmmac_tx_timeout(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-
 	/* Clear Tx resources and restart transmitting again */
 	stmmac_tx_err(priv);
 }
-- 
1.7.4.4
