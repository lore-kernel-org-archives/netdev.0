From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/3] stmmac: fix suspend/resume locking
Date: Mon, 14 May 2012 10:18:43 +0200
Message-ID: <1336983523-4075-3-git-send-email-peppe.cavallaro@st.com>
References: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:40660 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754448Ab2ENITE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 04:19:04 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C7ED6169
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 08:19:00 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6320E21BD
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 08:19:00 +0000 (GMT)
In-Reply-To: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon resume from standby, there is a possible interrupt
unsafe locking scenario raised when configure the Kernel
with CONFIG_PROVE_LOCKING. So this patch fixes that in
PM driver stuff by calling lock/unlock_irqsave/restore.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d1d0840..d07bc6d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1989,6 +1989,7 @@ int stmmac_suspend(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	int dis_ic = 0;
+	unsigned long flags;
 
 	if (!ndev || !netif_running(ndev))
 		return 0;
@@ -1996,7 +1997,7 @@ int stmmac_suspend(struct net_device *ndev)
 	if (priv->phydev)
 		phy_stop(priv->phydev);
 
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	netif_device_detach(ndev);
 	netif_stop_queue(ndev);
@@ -2024,18 +2025,19 @@ int stmmac_suspend(struct net_device *ndev)
 		/* Disable clock in case of PWM is off */
 		stmmac_clk_disable(priv);
 	}
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 	return 0;
 }
 
 int stmmac_resume(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
+	unsigned long flags;
 
 	if (!netif_running(ndev))
 		return 0;
 
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Power Down bit, into the PM register, is cleared
 	 * automatically as soon as a magic packet or a Wake-up frame
@@ -2063,7 +2065,7 @@ int stmmac_resume(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	if (priv->phydev)
 		phy_start(priv->phydev);
-- 
1.7.4.4
