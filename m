From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 5/5] stmmac: fix pm functions avoiding sleep on spinlock
Date: Thu, 17 Nov 2011 08:58:02 +0100
Message-ID: <1321516682-32208-5-git-send-email-peppe.cavallaro@st.com>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Cc: francesco.virlinzi@st.com, srinivas.kandagatla@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:37772 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1KQH6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:58:30 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CC8242BA
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:28 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 95DD81914
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:28 +0000 (GMT)
In-Reply-To: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

This patch fixes the pm functions to avoid the system
sleeps while a spinlock is taken.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 29dd87c..8ea770a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2011,12 +2011,13 @@ static int stmmac_suspend(struct device *dev)
 	if (!ndev || !netif_running(ndev))
 		return 0;
 
+	if (priv->phydev)
+		phy_stop(priv->phydev);
+
 	spin_lock(&priv->lock);
 
 	netif_device_detach(ndev);
 	netif_stop_queue(ndev);
-	if (priv->phydev)
-		phy_stop(priv->phydev);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_stop();
@@ -2074,12 +2075,13 @@ static int stmmac_resume(struct device *dev)
 #endif
 	napi_enable(&priv->napi);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
-
 	netif_start_queue(ndev);
 
 	spin_unlock(&priv->lock);
+
+	if (priv->phydev)
+		phy_start(priv->phydev);
+
 	return 0;
 }
 
-- 
1.7.4.4
