From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 3/8] stmmac: introduce stmmac_get_platform_resources()
Date: Fri, 17 Jul 2015 00:26:07 +0200
Message-ID: <1437085572-11371-4-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34513 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbbGPW0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:37 -0400
Received: by lagx9 with SMTP id x9so51590179lag.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:36 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor all code that deals with platform resources into it's
own get function. This function will later be used in the probe
function in dwmac-* drivers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 64 +++++++++++++---------
 1 file changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6e6ef859f58a..94962d75b99a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -262,33 +262,23 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 }
 #endif /* CONFIG_OF */
 
-/**
- * stmmac_pltfr_probe - platform driver probe.
- * @pdev: platform device pointer
- * Description: platform_device probe function. It is to allocate
- * the necessary platform resources, invoke custom helper (if required) and
- * invoke the main probe function.
- */
-int stmmac_pltfr_probe(struct platform_device *pdev)
+static int stmmac_get_platform_resources(struct platform_device *pdev,
+					 struct stmmac_resources *stmmac_res)
 {
-	struct stmmac_resources stmmac_res;
-	int ret = 0;
 	struct resource *res;
-	struct device *dev = &pdev->dev;
-	struct plat_stmmacenet_data *plat_dat = NULL;
 
-	memset(&stmmac_res, 0, sizeof(stmmac_res));
+	memset(stmmac_res, 0, sizeof(*stmmac_res));
 
 	/* Get IRQ information early to have an ability to ask for deferred
 	 * probe if needed before we went too far with resource allocation.
 	 */
-	stmmac_res.irq = platform_get_irq_byname(pdev, "macirq");
-	if (stmmac_res.irq < 0) {
-		if (stmmac_res.irq != -EPROBE_DEFER) {
-			dev_err(dev,
+	stmmac_res->irq = platform_get_irq_byname(pdev, "macirq");
+	if (stmmac_res->irq < 0) {
+		if (stmmac_res->irq != -EPROBE_DEFER) {
+			dev_err(&pdev->dev,
 				"MAC IRQ configuration information not found\n");
 		}
-		return stmmac_res.irq;
+		return stmmac_res->irq;
 	}
 
 	/* On some platforms e.g. SPEAr the wake up irq differs from the mac irq
@@ -298,21 +288,41 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	 * In case the wake up interrupt is not passed from the platform
 	 * so the driver will continue to use the mac irq (ndev->irq)
 	 */
-	stmmac_res.wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
-	if (stmmac_res.wol_irq < 0) {
-		if (stmmac_res.wol_irq == -EPROBE_DEFER)
+	stmmac_res->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
+	if (stmmac_res->wol_irq < 0) {
+		if (stmmac_res->wol_irq == -EPROBE_DEFER)
 			return -EPROBE_DEFER;
-		stmmac_res.wol_irq = stmmac_res.irq;
+		stmmac_res->wol_irq = stmmac_res->irq;
 	}
 
-	stmmac_res.lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
-	if (stmmac_res.lpi_irq == -EPROBE_DEFER)
+	stmmac_res->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
+	if (stmmac_res->lpi_irq == -EPROBE_DEFER)
 		return -EPROBE_DEFER;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	stmmac_res.addr = devm_ioremap_resource(dev, res);
-	if (IS_ERR(stmmac_res.addr))
-		return PTR_ERR(stmmac_res.addr);
+	stmmac_res->addr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(stmmac_res->addr))
+		return PTR_ERR(stmmac_res->addr);
+
+	return 0;
+}
+
+/**
+ * stmmac_pltfr_probe - platform driver probe.
+ * @pdev: platform device pointer
+ * Description: platform_device probe function. It is to allocate
+ * the necessary platform resources, invoke custom helper (if required) and
+ * invoke the main probe function.
+ */
+int stmmac_pltfr_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
 
 	if (pdev->dev.of_node) {
 		ret = stmmac_probe_config_dt(pdev, &plat_dat, &stmmac_res.mac);
-- 
1.8.0
