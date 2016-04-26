From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 4/5] stmmac: dwmac-socfpga: call phy_resume() only in resume callback
Date: Tue, 26 Apr 2016 23:24:58 +0200
Message-ID: <1461705899-17015-5-git-send-email-manabian@gmail.com>
References: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35948 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbcDZVZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:25:33 -0400
Received: by mail-lf0-f65.google.com with SMTP id y84so4293639lfc.3
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:25:32 -0700 (PDT)
In-Reply-To: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling phy_resume() should only be need during driver resume to
workaround a hardware errata.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Marek Vasut <marex@denx.de>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 50 ++++++++--------------
 1 file changed, 19 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index ba0b793..ba49d8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -198,41 +198,11 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
 {
 	struct socfpga_dwmac *dwmac = priv;
-	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct stmmac_priv *stpriv = NULL;
-	int ret = 0;
-
-	if (!ndev)
-		return -EINVAL;
-
-	stpriv = netdev_priv(ndev);
-	if (!stpriv)
-		return -EINVAL;
 
 	/* Setup the phy mode in the system manager registers according to
 	 * devicetree configuration
 	 */
-	ret = socfpga_dwmac_setup(dwmac);
-
-	/* Before the enet controller is suspended, the phy is suspended.
-	 * This causes the phy clock to be gated. The enet controller is
-	 * resumed before the phy, so the clock is still gated "off" when
-	 * the enet controller is resumed. This code makes sure the phy
-	 * is "resumed" before reinitializing the enet controller since
-	 * the enet controller depends on an active phy clock to complete
-	 * a DMA reset. A DMA reset will "time out" if executed
-	 * with no phy clock input on the Synopsys enet controller.
-	 * Verified through Synopsys Case #8000711656.
-	 *
-	 * Note that the phy clock is also gated when the phy is isolated.
-	 * Phy "suspend" and "isolate" controls are located in phy basic
-	 * control register 0, and can be modified by the phy driver
-	 * framework.
-	 */
-	if (stpriv->phydev)
-		phy_resume(stpriv->phydev);
-
-	return ret;
+	return socfpga_dwmac_setup(dwmac);
 }
 
 static int socfpga_dwmac_probe(struct platform_device *pdev)
@@ -290,6 +260,24 @@ static int socfpga_dwmac_resume(struct device *dev)
 
 	socfpga_dwmac_init(pdev, priv->plat->bsp_priv);
 
+	/* Before the enet controller is suspended, the phy is suspended.
+	 * This causes the phy clock to be gated. The enet controller is
+	 * resumed before the phy, so the clock is still gated "off" when
+	 * the enet controller is resumed. This code makes sure the phy
+	 * is "resumed" before reinitializing the enet controller since
+	 * the enet controller depends on an active phy clock to complete
+	 * a DMA reset. A DMA reset will "time out" if executed
+	 * with no phy clock input on the Synopsys enet controller.
+	 * Verified through Synopsys Case #8000711656.
+	 *
+	 * Note that the phy clock is also gated when the phy is isolated.
+	 * Phy "suspend" and "isolate" controls are located in phy basic
+	 * control register 0, and can be modified by the phy driver
+	 * framework.
+	 */
+	if (priv->phydev)
+		phy_resume(priv->phydev);
+
 	return stmmac_resume(dev);
 }
 #endif /* CONFIG_PM_SLEEP */
-- 
2.8.0
