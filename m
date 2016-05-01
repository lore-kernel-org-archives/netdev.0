From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH v2 0/5] stmmac: dwmac-socfpga refactor+cleanup
Date: Sun,  1 May 2016 22:58:18 +0200
Message-ID: <1462136303-16825-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33470 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcEAU7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:59:19 -0400
Received: by mail-lf0-f68.google.com with SMTP id p64so25550789lfg.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:59:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to remove the init/exit callbacks from the dwmac-
socfpga driver and instead use standard PM callbacks. Doing this
will also allow us to cleanup the driver.

Eventually the init/exit callbacks will be deprecated and removed
from all drivers dwmac-* except for dwmac-generic. Drivers will be
refactored to use standard PM and remove callbacks.

This patch set should not change the behavior of the driver itself,
it only moves code around. The only exception to this is patch
number 4 which restores the resume callback behavior which was
changed in the "net: stmmac: socfpga: Remove re-registration of
reset controller" patch. I belive calling phy_resume() only
from the resume callback and not probe is the right thing to do.

Changes from v1:
 - Rebase on net-next

One heads-up here:
The first patch changes the prototype of a couple of
functions used in Alexandre's "add Ethernet glue logic for
stm32 chip" patch [1] and will cause build failures for
dwmac-stm32.c if not fixed up!
If Alexandre's patch set is applied first I will gladly
rebase my patch set to account for his driver as well.

[1] https://patchwork.ozlabs.org/patch/614405/

Dave: To avoid the build failure mentioned above you can
      apply the changes below to the stm32 driver or
      Alexandre can use it if he creates a new version
      of his patch set.

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
@@ -133,7 +133,7 @@ static int stm32_dwmac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	int ret = stmmac_dvr_remove(ndev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
 
 	stm32_dwmac_clk_disable(priv->plat->bsp_priv);
 
@@ -147,7 +147,7 @@ static int stm32_dwmac_suspend(struct device *dev)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = stmmac_suspend(ndev);
+	ret = stmmac_suspend(dev);
 	stm32_dwmac_clk_disable(priv->plat->bsp_priv);
 
 	return ret;
@@ -163,7 +163,7 @@ static int stm32_dwmac_resume(struct device *dev)
 	if (ret)
 		return ret;
 
-	ret = stmmac_resume(ndev);
+	ret = stmmac_resume(dev);
 
 	return ret;
 }



Joachim Eastwood (5):
  stmmac: let remove/resume/suspend functions take device pointer
  stmmac: dwmac-socfpga: add PM ops and resume function
  stmmac: dwmac-socfpga: keep a copy of stmmac_rst in driver priv data
  stmmac: dwmac-socfpga: call phy_resume() only in resume callback
  stmmac: dwmac-socfpga: kill init() and rename setup() to set_phy_mode()

 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 106 +++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  15 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  24 +----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   6 +-
 5 files changed, 71 insertions(+), 86 deletions(-)

-- 
2.8.0
