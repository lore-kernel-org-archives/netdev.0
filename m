From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 08/17] stmmac: dwmac-sti: turn setup callback into a probe function
Date: Wed, 29 Jul 2015 00:08:55 +0200
Message-ID: <1438121344-5304-9-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	kernel@stlinux.com
To: peppe.cavallaro@st.com, srinivas.kandagatla@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:36485 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbG1WJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:30 -0400
Received: by lagw2 with SMTP id w2so77107081lag.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:29 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform a proper probe
function can be created from the setup glue callback. This
makes it look more like a standard driver and prepares the
driver for further clean ups.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 31 ++++++++++++++++++-------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index a2e8111c5d14..b17238aac791 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -334,36 +334,49 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	return 0;
 }
 
-static void *sti_dwmac_setup(struct platform_device *pdev)
+static int sti_dwmac_probe(struct platform_device *pdev)
 {
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct sti_dwmac *dwmac;
 	int ret;
 
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
 	if (!dwmac)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	ret = sti_dwmac_parse_data(dwmac, pdev);
 	if (ret) {
 		dev_err(&pdev->dev, "Unable to parse OF data\n");
-		return ERR_PTR(ret);
+		return ret;
 	}
 
-	return dwmac;
+	plat_dat->bsp_priv = dwmac;
+	plat_dat->exit = sti_dwmac_exit;
+
+	ret = plat_dat->init(pdev, plat_dat->bsp_priv);
+	if (ret)
+		return ret;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
 static const struct stmmac_of_data stih4xx_dwmac_data = {
 	.fix_mac_speed = stih4xx_fix_retime_src,
-	.setup = sti_dwmac_setup,
 	.init = stix4xx_init,
-	.exit = sti_dwmac_exit,
 };
 
 static const struct stmmac_of_data stid127_dwmac_data = {
 	.fix_mac_speed = stid127_fix_retime_src,
-	.setup = sti_dwmac_setup,
 	.init = stid127_init,
-	.exit = sti_dwmac_exit,
 };
 
 static const struct of_device_id sti_dwmac_match[] = {
@@ -376,7 +389,7 @@ static const struct of_device_id sti_dwmac_match[] = {
 MODULE_DEVICE_TABLE(of, sti_dwmac_match);
 
 static struct platform_driver sti_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = sti_dwmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "sti-dwmac",
-- 
1.8.0
