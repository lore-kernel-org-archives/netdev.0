From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] net: davinci_mdio: add DT bindings
Date: Thu,  2 Aug 2012 21:43:36 +0200
Message-ID: <1343936616-29318-2-git-send-email-zonque@gmail.com>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Cc: devicetree-discuss@lists.ozlabs.org, koen@dominion.thruhere.net,
	mugunthanvnm@ti.com, linux-arm-kernel@lists.infradead.org,
	paul@pwsan.com, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:32785 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414Ab2HBToB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 15:44:01 -0400
In-Reply-To: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 .../devicetree/bindings/net/davinci_mdio.txt       | 24 +++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c             | 39 ++++++++++++++++++++++
 2 files changed, 63 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/davinci_mdio.txt

diff --git a/Documentation/devicetree/bindings/net/davinci_mdio.txt b/Documentation/devicetree/bindings/net/davinci_mdio.txt
new file mode 100644
index 0000000..03292a5
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davinci_mdio.txt
@@ -0,0 +1,24 @@
+Davinci MDIO DT bindings
+
+Required properties:
+
+ - compatible : should be "ti,davinci-mdio"
+
+Optional properties:
+
+ - bus-freq : an integer to specify the bus speed
+
+Examples:
+
+	mdio: davinci_mdio@4a101000 {
+		compatible = "ti,davinci-mdio";
+		ti,hwmods = "davinci_mdio";
+	};
+
+ or
+
+	mdio: davinci_mdio@4a101000 {
+		compatible = "ti,davinci-mdio";
+		reg = <0x4a101000 0x100>;
+	};
+
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index b4b6015..2640cae 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -36,6 +36,8 @@
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
 #include <linux/davinci_emac.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
 
 /*
  * This timeout definition is a worst-case ultra defensive measure against
@@ -289,6 +291,37 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id davinci_mdio_dt_ids[] = {
+	{ .compatible = "ti,davinci-mdio" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, davinci_mdio_dt_ids);
+
+static inline int davinci_mdio_probe_dt(struct device *dev,
+					struct mdio_platform_data *pdata)
+{
+	struct device_node *np = dev->of_node;
+	const struct of_device_id *of_id =
+			of_match_device(davinci_mdio_dt_ids, dev);
+	u32 tmp;
+
+	if (!of_id)
+		return 0;
+
+	if (of_property_read_u32(np, "bus-freq", &tmp) == 0)
+		pdata->bus_freq = tmp;
+
+	return 0;
+}
+#else
+static inline int davinci_mdio_probe_dt(struct device *dev,
+					struct mdio_platform_data *pdata)
+{
+	return 0;
+}
+#endif
+
 static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = pdev->dev.platform_data;
@@ -306,6 +339,10 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 
 	data->pdata = pdata ? (*pdata) : default_pdata;
 
+	ret = davinci_mdio_probe_dt(dev, pdata);
+	if (ret < 0)
+		goto free_mem;
+
 	data->bus = mdiobus_alloc();
 	if (!data->bus) {
 		dev_err(dev, "failed to alloc mii bus\n");
@@ -389,6 +426,7 @@ bail_out:
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
+free_mem:
 	kfree(data);
 
 	return ret;
@@ -471,6 +509,7 @@ static struct platform_driver davinci_mdio_driver = {
 		.name	 = "davinci_mdio",
 		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_mdio_pm_ops,
+		.of_match_table = of_match_ptr(davinci_mdio_dt_ids),
 	},
 	.probe = davinci_mdio_probe,
 	.remove = __devexit_p(davinci_mdio_remove),
-- 
1.7.11.2
