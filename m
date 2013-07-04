From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] net:stmmac: fix memleak in the open method
Date: Thu,  4 Jul 2013 06:18:07 +0200
Message-ID: <1372911487-18472-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:38206 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751015Ab3GDETb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 00:19:31 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C334314E
	for <netdev@vger.kernel.org>; Thu,  4 Jul 2013 04:19:26 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1A4BD227B
	for <netdev@vger.kernel.org>; Thu,  4 Jul 2013 04:19:00 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix a memory leak in the open method, it reviews error
conditions freeing the resources previously allocated and not freed in
cased of DMA failure.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e9eab29..c047f0e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1579,7 +1579,7 @@ static int stmmac_open(struct net_device *dev)
 		if (ret) {
 			pr_err("%s: Cannot attach to PHY (error: %d)\n",
 			       __func__, ret);
-			goto open_error;
+			goto phy_error;
 		}
 	}
 
@@ -1593,7 +1593,7 @@ static int stmmac_open(struct net_device *dev)
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
 		pr_err("%s: DMA initialization failed\n", __func__);
-		goto open_error;
+		goto init_error;
 	}
 
 	/* Copy the MAC addr into the HW  */
@@ -1612,7 +1612,7 @@ static int stmmac_open(struct net_device *dev)
 	if (unlikely(ret < 0)) {
 		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
 		       __func__, dev->irq, ret);
-		goto open_error;
+		goto init_error;
 	}
 
 	/* Request the Wake IRQ in case of another line is used for WoL */
@@ -1622,7 +1622,7 @@ static int stmmac_open(struct net_device *dev)
 		if (unlikely(ret < 0)) {
 			pr_err("%s: ERROR: allocating the WoL IRQ %d (%d)\n",
 			       __func__, priv->wol_irq, ret);
-			goto open_error_wolirq;
+			goto wolirq_error;
 		}
 	}
 
@@ -1633,7 +1633,7 @@ static int stmmac_open(struct net_device *dev)
 		if (unlikely(ret < 0)) {
 			pr_err("%s: ERROR: allocating the LPI IRQ %d (%d)\n",
 			       __func__, priv->lpi_irq, ret);
-			goto open_error_lpiirq;
+			goto lpiirq_error;
 		}
 	}
 
@@ -1691,17 +1691,17 @@ static int stmmac_open(struct net_device *dev)
 
 	return 0;
 
-open_error_lpiirq:
+lpiirq_error:
 	if (priv->wol_irq != dev->irq)
 		free_irq(priv->wol_irq, dev);
-
-open_error_wolirq:
+wolirq_error:
 	free_irq(dev->irq, dev);
 
-open_error:
+init_error:
+	free_dma_desc_resources(priv);
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
-
+phy_error:
 	clk_disable_unprepare(priv->stmmac_clk);
 
 	return ret;
-- 
1.7.4.4
