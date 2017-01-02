From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 1/3] net: stmmac: dwmac-oxnas: fix of-node leak
Date: Mon,  2 Jan 2017 12:56:02 +0100
Message-ID: <20170102115604.32482-2-johan@kernel.org>
References: <20170102115604.32482-1-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        netdev@vger.kernel.org, linux-oxnas@lists.tuxfamily.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35884 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755536AbdABL4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 06:56:32 -0500
In-Reply-To: <20170102115604.32482-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the syscon lookup-by-phandle helper so that the reference taken by
of_parse_phandle() is released when done with the node.

Fixes: 5ed7414062e7 ("net: stmmac: Add OXNAS Glue Driver")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
index c35597586121..fcc237e0aae1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
@@ -109,16 +109,9 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
 	struct stmmac_resources stmmac_res;
-	struct device_node *sysctrl;
 	struct oxnas_dwmac *dwmac;
 	int ret;
 
-	sysctrl = of_parse_phandle(pdev->dev.of_node, "oxsemi,sys-ctrl", 0);
-	if (!sysctrl) {
-		dev_err(&pdev->dev, "failed to get sys-ctrl node\n");
-		return -EINVAL;
-	}
-
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
 		return ret;
@@ -134,7 +127,8 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 	dwmac->dev = &pdev->dev;
 	plat_dat->bsp_priv = dwmac;
 
-	dwmac->regmap = syscon_node_to_regmap(sysctrl);
+	dwmac->regmap = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
+							"oxsemi,sys-ctrl");
 	if (IS_ERR(dwmac->regmap)) {
 		dev_err(&pdev->dev, "failed to have sysctrl regmap\n");
 		return PTR_ERR(dwmac->regmap);
-- 
2.10.2
