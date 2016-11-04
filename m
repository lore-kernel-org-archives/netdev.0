From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 5/7] stmmac: dwmac-sti: move clk_prepare_enable out of init and add error handling
Date: Fri,  4 Nov 2016 18:54:09 +0100
Message-ID: <20161104175411.12943-6-manabian@gmail.com>
References: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33183 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965320AbcKDRz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:29 -0400
Received: by mail-lf0-f67.google.com with SMTP id 98so1681179lfs.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:28 -0700 (PDT)
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add clock error handling to probe and in the process move clock enabling
out of sti_dwmac_init() to make this easier.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 269c7a5..b71888a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -237,8 +237,6 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	u32 reg = dwmac->ctrl_reg;
 	u32 val;
 
-	clk_prepare_enable(dwmac->clk);
-
 	if (dwmac->gmac_en)
 		regmap_update_bits(regmap, reg, EN_MASK, EN);
 
@@ -348,11 +346,23 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	plat_dat->bsp_priv = dwmac;
 	plat_dat->fix_mac_speed = data->fix_retime_src;
 
-	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
+	ret = clk_prepare_enable(dwmac->clk);
 	if (ret)
 		return ret;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
+	if (ret)
+		goto disable_clk;
+
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto disable_clk;
+
+	return 0;
+
+disable_clk:
+	clk_disable_unprepare(dwmac->clk);
+	return ret;
 }
 
 static int sti_dwmac_remove(struct platform_device *pdev)
@@ -381,6 +391,7 @@ static int sti_dwmac_resume(struct device *dev)
 	struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
 	struct platform_device *pdev = to_platform_device(dev);
 
+	clk_prepare_enable(dwmac->clk);
 	sti_dwmac_init(pdev, dwmac);
 
 	return stmmac_resume(dev);
-- 
2.10.2
