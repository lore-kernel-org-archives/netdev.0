From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 3/5] stmmac: dwmac-socfpga: keep a copy of stmmac_rst in driver priv data
Date: Tue, 26 Apr 2016 23:24:57 +0200
Message-ID: <1461705899-17015-4-git-send-email-manabian@gmail.com>
References: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35942 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbcDZVZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:25:31 -0400
Received: by mail-lf0-f66.google.com with SMTP id y84so4293568lfc.3
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:25:30 -0700 (PDT)
In-Reply-To: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac-socfpga driver needs to control the reset usually managed
by the core driver to set the PHY mode. Take a copy of the reset
handle from core priv data so it can be used by the driver later.

This also allow us to move reset handling into socfpga_dwmac_setup()
where the code that needs it is located.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Marek Vasut <marex@denx.de>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 33 ++++++++++++++--------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 789013a..ba0b793 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -49,6 +49,7 @@ struct socfpga_dwmac {
 	u32	reg_shift;
 	struct	device *dev;
 	struct regmap *sys_mgr_base_addr;
+	struct reset_control *stmmac_rst;
 	void __iomem *splitter_base;
 	bool f2h_ptp_ref_clk;
 };
@@ -164,6 +165,10 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	if (dwmac->splitter_base)
 		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
 
+	/* Assert reset to the enet controller before changing the phy mode */
+	if (dwmac->stmmac_rst)
+		reset_control_assert(dwmac->stmmac_rst);
+
 	regmap_read(sys_mgr_base_addr, reg_offset, &ctrl);
 	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
 	ctrl |= val << reg_shift;
@@ -181,6 +186,12 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 
 	regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
 
+	/* Deassert reset for the phy configuration to be sampled by
+	 * the enet controller, and operation to start in requested mode
+	 */
+	if (dwmac->stmmac_rst)
+		reset_control_deassert(dwmac->stmmac_rst);
+
 	return 0;
 }
 
@@ -198,21 +209,11 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
 	if (!stpriv)
 		return -EINVAL;
 
-	/* Assert reset to the enet controller before changing the phy mode */
-	if (stpriv->stmmac_rst)
-		reset_control_assert(stpriv->stmmac_rst);
-
 	/* Setup the phy mode in the system manager registers according to
 	 * devicetree configuration
 	 */
 	ret = socfpga_dwmac_setup(dwmac);
 
-	/* Deassert reset for the phy configuration to be sampled by
-	 * the enet controller, and operation to start in requested mode
-	 */
-	if (stpriv->stmmac_rst)
-		reset_control_deassert(stpriv->stmmac_rst);
-
 	/* Before the enet controller is suspended, the phy is suspended.
 	 * This causes the phy clock to be gated. The enet controller is
 	 * resumed before the phy, so the clock is still gated "off" when
@@ -264,8 +265,18 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
-	if (!ret)
+	if (!ret) {
+		struct net_device *ndev = platform_get_drvdata(pdev);
+		struct stmmac_priv *stpriv = netdev_priv(ndev);
+
+		/* The socfpga driver needs to control the stmmac reset to
+		 * set the phy mode. Create a copy of the core reset handel
+		 * so it can be used by the driver later.
+		 */
+		dwmac->stmmac_rst = stpriv->stmmac_rst;
+
 		ret = socfpga_dwmac_init(pdev, dwmac);
+	}
 
 	return ret;
 }
-- 
2.8.0
