From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 2/3] net: davinci_emac: simplify the OF parser code
Date: Tue, 25 Jun 2013 21:24:52 +0530
Message-ID: <1372175693-20318-3-git-send-email-prabhakar.csengg@gmail.com>
References: <1372175693-20318-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372175693-20318-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

This patch cleans up the OF parser code, removes unnecessary checks
on of_property_read_*() and guards davinci_emac_of_match table with
CONFIG_OF.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   67 +++++++++++---------------------
 1 file changed, 23 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 8baf630..defaea0 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1754,29 +1754,22 @@ static const struct net_device_ops emac_netdev_ops = {
 #endif
 };
 
-#ifdef CONFIG_OF
-static struct emac_platform_data
-	*davinci_emac_of_get_pdata(struct platform_device *pdev,
-	struct emac_priv *priv)
+static struct emac_platform_data *
+davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 {
 	struct device_node *np;
 	struct emac_platform_data *pdata = NULL;
 	const u8 *mac_addr;
-	u32 data;
-	int ret;
 
-	pdata = pdev->dev.platform_data;
-	if (!pdata) {
-		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
-		if (!pdata)
-			goto nodata;
-	}
+	if (!IS_ENABLED(CONFIG_OF) || !pdev->dev.of_node)
+		return pdev->dev.platform_data;
+
+	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return NULL;
 
 	np = pdev->dev.of_node;
-	if (!np)
-		goto nodata;
-	else
-		pdata->version = EMAC_VERSION_2;
+	pdata->version = EMAC_VERSION_2;
 
 	if (!is_valid_ether_addr(pdata->mac_addr)) {
 		mac_addr = of_get_mac_address(np);
@@ -1784,47 +1777,31 @@ static struct emac_platform_data
 			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
 	}
 
-	ret = of_property_read_u32(np, "ti,davinci-ctrl-reg-offset", &data);
-	if (!ret)
-		pdata->ctrl_reg_offset = data;
+	of_property_read_u32(np, "ti,davinci-ctrl-reg-offset",
+			     &pdata->ctrl_reg_offset);
 
-	ret = of_property_read_u32(np, "ti,davinci-ctrl-mod-reg-offset",
-		&data);
-	if (!ret)
-		pdata->ctrl_mod_reg_offset = data;
+	of_property_read_u32(np, "ti,davinci-ctrl-mod-reg-offset",
+			     &pdata->ctrl_mod_reg_offset);
 
-	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-offset", &data);
-	if (!ret)
-		pdata->ctrl_ram_offset = data;
+	of_property_read_u32(np, "ti,davinci-ctrl-ram-offset",
+			     &pdata->ctrl_ram_offset);
 
-	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-size", &data);
-	if (!ret)
-		pdata->ctrl_ram_size = data;
+	of_property_read_u32(np, "ti,davinci-ctrl-ram-size",
+			     &pdata->ctrl_ram_size);
 
-	ret = of_property_read_u32(np, "ti,davinci-rmii-en", &data);
-	if (!ret)
-		pdata->rmii_en = data;
+	of_property_read_u8(np, "ti,davinci-rmii-en", &pdata->rmii_en);
 
-	ret = of_property_read_u32(np, "ti,davinci-no-bd-ram", &data);
-	if (!ret)
-		pdata->no_bd_ram = data;
+	pdata->no_bd_ram = of_property_read_bool(np, "ti,davinci-no-bd-ram");
 
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
 	if (!priv->phy_node)
 		pdata->phy_id = "";
 
 	pdev->dev.platform_data = pdata;
-nodata:
+
 	return  pdata;
 }
-#else
-static struct emac_platform_data
-	*davinci_emac_of_get_pdata(struct platform_device *pdev,
-	struct emac_priv *priv)
-{
-	return  pdev->dev.platform_data;
-}
-#endif
+
 /**
  * davinci_emac_probe - EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
@@ -2047,11 +2024,13 @@ static const struct dev_pm_ops davinci_emac_pm_ops = {
 	.resume		= davinci_emac_resume,
 };
 
+#if IS_ENABLED(CONFIG_OF)
 static const struct of_device_id davinci_emac_of_match[] = {
 	{.compatible = "ti,davinci-dm6467-emac", },
 	{},
 };
 MODULE_DEVICE_TABLE(of, davinci_emac_of_match);
+#endif
 
 /* davinci_emac_driver: EMAC platform driver structure */
 static struct platform_driver davinci_emac_driver = {
-- 
1.7.9.5
