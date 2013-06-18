From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix EEE setup
Date: Tue, 18 Jun 2013 07:03:23 +0200
Message-ID: <1371531803-8177-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:33611 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788Ab3FRFZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 01:25:32 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9D988C0
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 05:03:32 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6E309279C
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 05:03:10 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the EEE setup allowing to configure this support
when the link changes.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   66 ++++++++++-----------
 2 files changed, 33 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7788fbe..9517697 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -297,8 +297,8 @@ struct dma_features {
 #define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
 
 /* Default LPI timers */
-#define STMMAC_DEFAULT_LIT_LS_TIMER	0x3E8
-#define STMMAC_DEFAULT_TWT_LS_TIMER	0x0
+#define STMMAC_DEFAULT_LIT_LS	0x3E8
+#define STMMAC_DEFAULT_TWT_LS	0x0
 
 #define STMMAC_CHAIN_MODE	0x1
 #define STMMAC_RING_MODE	0x2
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ee919ca..e9eab29 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -130,7 +130,7 @@ static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 static int eee_timer = STMMAC_DEFAULT_LPI_TIMER;
 module_param(eee_timer, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
-#define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
+#define STMMAC_LPI_T(x) (jiffies + msecs_to_jiffies(x))
 
 /* By default the driver will use the ring mode to manage tx and rx descriptors
  * but passing this value so user can force to use the chain instead of the ring
@@ -288,7 +288,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
 	struct stmmac_priv *priv = (struct stmmac_priv *)arg;
 
 	stmmac_enable_eee_mode(priv);
-	mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+	mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
 }
 
 /**
@@ -304,22 +304,34 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 {
 	bool ret = false;
 
+	/* Using PCS we cannot dial with the phy registers at this stage
+	 * so we do not support extra feature like EEE.
+	 */
+	if ((priv->pcs == STMMAC_PCS_RGMII) || (priv->pcs == STMMAC_PCS_TBI) ||
+	    (priv->pcs == STMMAC_PCS_RTBI))
+		goto out;
+
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
 		/* Check if the PHY supports EEE */
 		if (phy_init_eee(priv->phydev, 1))
 			goto out;
 
-		priv->eee_active = 1;
-		init_timer(&priv->eee_ctrl_timer);
-		priv->eee_ctrl_timer.function = stmmac_eee_ctrl_timer;
-		priv->eee_ctrl_timer.data = (unsigned long)priv;
-		priv->eee_ctrl_timer.expires = STMMAC_LPI_TIMER(eee_timer);
-		add_timer(&priv->eee_ctrl_timer);
-
-		priv->hw->mac->set_eee_timer(priv->ioaddr,
-					     STMMAC_DEFAULT_LIT_LS_TIMER,
-					     priv->tx_lpi_timer);
+		if (!priv->eee_active) {
+			priv->eee_active = 1;
+			init_timer(&priv->eee_ctrl_timer);
+			priv->eee_ctrl_timer.function = stmmac_eee_ctrl_timer;
+			priv->eee_ctrl_timer.data = (unsigned long)priv;
+			priv->eee_ctrl_timer.expires = STMMAC_LPI_T(eee_timer);
+			add_timer(&priv->eee_ctrl_timer);
+
+			priv->hw->mac->set_eee_timer(priv->ioaddr,
+						     STMMAC_DEFAULT_LIT_LS,
+						     priv->tx_lpi_timer);
+		} else
+			/* Set HW EEE according to the speed */
+			priv->hw->mac->set_eee_pls(priv->ioaddr,
+						   priv->phydev->link);
 
 		pr_info("stmmac: Energy-Efficient Ethernet initialized\n");
 
@@ -329,20 +341,6 @@ out:
 	return ret;
 }
 
-/**
- * stmmac_eee_adjust: adjust HW EEE according to the speed
- * @priv: driver private structure
- * Description:
- *	When the EEE has been already initialised we have to
- *	modify the PLS bit in the LPI ctrl & status reg according
- *	to the PHY link status. For this reason.
- */
-static void stmmac_eee_adjust(struct stmmac_priv *priv)
-{
-	if (priv->eee_enabled)
-		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
-}
-
 /* stmmac_get_tx_hwtstamp: get HW TX timestamps
  * @priv: driver private structure
  * @entry : descriptor index to be used.
@@ -769,7 +767,10 @@ static void stmmac_adjust_link(struct net_device *dev)
 	if (new_state && netif_msg_link(priv))
 		phy_print_status(phydev);
 
-	stmmac_eee_adjust(priv);
+	/* At this stage, it could be needed to setup the EEE or adjust some
+	 * MAC related HW registers.
+	 */
+	priv->eee_enabled = stmmac_eee_init(priv);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -1277,7 +1278,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
 		stmmac_enable_eee_mode(priv);
-		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
 	}
 	spin_unlock(&priv->tx_lock);
 }
@@ -1671,14 +1672,9 @@ static int stmmac_open(struct net_device *dev)
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
-	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
+	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
-	/* Using PCS we cannot dial with the phy registers at this stage
-	 * so we do not support extra feature like EEE.
-	 */
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI)
-		priv->eee_enabled = stmmac_eee_init(priv);
+	priv->eee_enabled = stmmac_eee_init(priv);
 
 	stmmac_init_tx_coalesce(priv);
 
-- 
1.7.4.4
