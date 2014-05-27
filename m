From: Chen-Yu Tsai <wens@csie.org>
Subject: [PATCH net-next] net: stmmac: Handle different error codes from platform_get_irq_byname
Date: Tue, 27 May 2014 12:49:54 +0800
Message-ID: <1401166194-19085-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Rob Herring <robh@kernel.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mirror2.csie.ntu.edu.tw ([140.112.30.76]:39935 "EHLO
	mirror2.csie.ntu.edu.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbaE0F1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 01:27:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch moved device tree interrupt resolution into
platform_get_irq_byname:

  ad69674 of/irq: do irq resolution in platform_get_irq_byname()

As a result, the function no longer only return -ENXIO on error.
This breaks DT based probing of stmmac, as seen in test runs of
linux-next next-20140526 cubie2-sunxi_defconfig:

  http://lists.linaro.org/pipermail/kernel-build-reports/2014-May/003659.html

This patch makes the stmmac_platform probe function properly handle
error codes, such as returning for deferred probing, and other codes
returned by of_irq_get_by_name.

Signed-off-by: Chen-Yu Tsai <wens@csie.org>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c    | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 46aef510..9562b18 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -237,10 +237,12 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	/* Get the MAC information */
 	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
-	if (priv->dev->irq == -ENXIO) {
-		pr_err("%s: ERROR: MAC IRQ configuration "
-		       "information not found\n", __func__);
-		return -ENXIO;
+	if (priv->dev->irq < 0) {
+		if (priv->wol_irq != -EPROBE_DEFER) {
+			pr_err("%s: ERROR: MAC IRQ configuration "
+			       "information not found\n", __func__);
+		}
+		return priv->dev->irq;
 	}
 
 	/*
@@ -252,10 +254,18 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	 * so the driver will continue to use the mac irq (ndev->irq)
 	 */
 	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
-	if (priv->wol_irq == -ENXIO)
+	if (priv->wol_irq < 0) {
+		if (priv->wol_irq == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
 		priv->wol_irq = priv->dev->irq;
+	}
 
 	priv->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
+	if (priv->lpi_irq < 0) {
+		if (priv->wol_irq == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		priv->lpi_irq = -ENXIO;
+	}
 
 	platform_set_drvdata(pdev, priv->dev);
 
-- 
2.0.0.rc2
