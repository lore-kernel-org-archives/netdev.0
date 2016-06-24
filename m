From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 14/15] drivers: net: davinci_mdio: enable pm runtime auto for ti cpsw-mdio
Date: Fri, 24 Jun 2016 21:23:54 +0300
Message-ID: <20160624182355.23515-15-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use "ti,cpsw-mdio" to enable PM runtime auto-suspend on supported
platforms, where MDIO is implemented as part of TI CPSW.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 45 +++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index ce3ec42..33df340 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -53,6 +53,10 @@
 
 #define DEF_OUT_FREQ		2200000		/* 2.2 MHz */
 
+struct davinci_mdio_of_param {
+	int autosuspend_delay_ms;
+};
+
 struct davinci_mdio_regs {
 	u32	version;
 	u32	control;
@@ -332,6 +336,19 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 }
 #endif
 
+#if IS_ENABLED(CONFIG_OF)
+static const struct davinci_mdio_of_param of_cpsw_mdio_data = {
+	.autosuspend_delay_ms = 100,
+};
+
+static const struct of_device_id davinci_mdio_of_mtable[] = {
+	{ .compatible = "ti,davinci_mdio", },
+	{ .compatible = "ti,cpsw-mdio", .data = &of_cpsw_mdio_data},
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
+#endif
+
 static int davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = dev_get_platdata(&pdev->dev);
@@ -340,6 +357,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct phy_device *phy;
 	int ret, addr;
+	int autosuspend_delay_ms = -1;
 
 	data = devm_kzalloc(dev, sizeof(*data), GFP_KERNEL);
 	if (!data)
@@ -352,9 +370,22 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	}
 
 	if (dev->of_node) {
-		if (davinci_mdio_probe_dt(&data->pdata, pdev))
-			data->pdata = default_pdata;
+		const struct of_device_id	*of_id;
+
+		ret = davinci_mdio_probe_dt(&data->pdata, pdev);
+		if (ret)
+			return ret;
 		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+
+		of_id = of_match_device(davinci_mdio_of_mtable, &pdev->dev);
+		if (of_id) {
+			const struct davinci_mdio_of_param *of_mdio_data;
+
+			of_mdio_data = of_id->data;
+			if (of_mdio_data)
+				autosuspend_delay_ms =
+					of_mdio_data->autosuspend_delay_ms;
+		}
 	} else {
 		data->pdata = pdata ? (*pdata) : default_pdata;
 		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",
@@ -384,7 +415,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 
 	davinci_mdio_init_clk(data);
 
-	pm_runtime_set_autosuspend_delay(&pdev->dev, -1);
+	pm_runtime_set_autosuspend_delay(&pdev->dev, autosuspend_delay_ms);
 	pm_runtime_use_autosuspend(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
 
@@ -495,14 +526,6 @@ static const struct dev_pm_ops davinci_mdio_pm_ops = {
 	SET_LATE_SYSTEM_SLEEP_PM_OPS(davinci_mdio_suspend, davinci_mdio_resume)
 };
 
-#if IS_ENABLED(CONFIG_OF)
-static const struct of_device_id davinci_mdio_of_mtable[] = {
-	{ .compatible = "ti,davinci_mdio", },
-	{ /* sentinel */ },
-};
-MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
-#endif
-
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
 		.name	 = "davinci_mdio",
-- 
2.9.0
