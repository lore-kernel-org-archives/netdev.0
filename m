From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2 (v2)] stmmac: disable at run-time the EEE if not supported
Date: Wed, 21 Aug 2013 07:28:27 +0200
Message-ID: <1377062908-16543-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:37230 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751872Ab3HUFeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 01:34:14 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 26223A4
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 05:34:00 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CF37646F3
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 05:33:29 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to disable the EEE (so HW and timers)
for example when the phy communicates that the EEE
can be supported nomore.

v2: clean the patch removing an useless change

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   23 +++++++++++++++++---
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0a9bb9d..45ca081 100644
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
-- 
1.7.4.4
