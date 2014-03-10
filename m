From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/4 (v2)] stmmac: disable at run-time the EEE if not supported
Date: Mon, 10 Mar 2014 13:40:31 +0100
Message-ID: <1394455234-32021-2-git-send-email-peppe.cavallaro@st.com>
References: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:55161 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753447AbaCJNOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 09:14:52 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3DBCD230
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:07 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3B2D116530
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:07 +0000 (GMT)
In-Reply-To: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to disable the EEE (so HW and timers)
for example when the phy communicates that the EEE
can be supported anymore.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

v2: remove useless change in stmmac_tx path

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   23 +++++++++++++++++---
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 078ad0e..b418f94 100644
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
-- 
1.7.4.4
