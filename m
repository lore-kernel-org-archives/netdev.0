From: Chen-Yu Tsai <wens@csie.org>
Subject: [PATCH net-next v2] net: stmmac: Handle different error codes from platform_get_irq_byname
Date: Thu, 29 May 2014 22:31:40 +0800
Message-ID: <1401373900-30253-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Rob Herring <robh@kernel.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mirror2.csie.ntu.edu.tw ([140.112.30.76]:40122 "EHLO
	mirror2.csie.ntu.edu.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605AbaE2Ob4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 10:31:56 -0400
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

v2 addresses Rob Herring's comments:

  - copy / paste errors
  - use netdev_err instead of pr_err
  - join a split string
  - Fix checking lpi_irq for valid interrupt

---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 17 ++++++++++++-----
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 110ca1c..057a120 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1753,7 +1753,7 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 	/* Request the IRQ lines */
-	if (priv->lpi_irq != -ENXIO) {
+	if (priv->lpi_irq > 0) {
 		ret = request_irq(priv->lpi_irq, stmmac_interrupt, IRQF_SHARED,
 				  dev->name, dev);
 		if (unlikely(ret < 0)) {
@@ -1813,7 +1813,7 @@ static int stmmac_release(struct net_device *dev)
 	free_irq(dev->irq, dev);
 	if (priv->wol_irq != dev->irq)
 		free_irq(priv->wol_irq, dev);
-	if (priv->lpi_irq != -ENXIO)
+	if (priv->lpi_irq > 0)
 		free_irq(priv->lpi_irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 46aef510..ea7a65b 100644
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
+		if (priv->dev->irq != -EPROBE_DEFER) {
+			netdev_err(priv->dev,
+				   "MAC IRQ configuration information not found\n");
+		}
+		return priv->dev->irq;
 	}
 
 	/*
@@ -252,10 +254,15 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
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
+	if (priv->lpi_irq == -EPROBE_DEFER)
+		return -EPROBE_DEFER;
 
 	platform_set_drvdata(pdev, priv->dev);
 
-- 
2.0.0.rc4
