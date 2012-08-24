From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.6.0-rc3 2/2] of/mdio-gpio: Simplify the way device tree support is implemented.
Date: Fri, 24 Aug 2012 12:59:17 +0100
Message-ID: <1345809557-27727-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, davem@davemloft.net,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca
To: netdev@vger.kernel.org, laurentp@cse-semaphore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:39210 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759356Ab2HXMwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 08:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch cleans up the way device tree support is added in mdio-gpio
driver. I found lot of code duplication which is not necessary.
Also strangely a new platform driver was also introduced for device tree
support. All this forced me to do this cleanup patch.
After this patch, the driver probe checks the of_node pointer to get the
data from device tree.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/mdio-gpio.c |  136 +++++++++++++-----------------------------
 1 files changed, 42 insertions(+), 94 deletions(-)
Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/mdio-gpio.c |  132 +++++++++++++------------------------------
 1 files changed, 40 insertions(+), 92 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 7189adf..899274f 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -28,17 +28,38 @@
 #include <linux/gpio.h>
 #include <linux/mdio-gpio.h>
 
-#ifdef CONFIG_OF_GPIO
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
-#include <linux/of_platform.h>
-#endif
 
 struct mdio_gpio_info {
 	struct mdiobb_ctrl ctrl;
 	int mdc, mdio;
 };
 
+static void *mdio_gpio_of_get_data(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mdio_gpio_platform_data *pdata;
+	int ret;
+
+	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return NULL;
+
+	ret = of_get_gpio(np, 0);
+	if (ret < 0)
+		return NULL;
+
+	pdata->mdc = ret;
+
+	ret = of_get_gpio(np, 1);
+	if (ret < 0)
+		return NULL;
+	pdata->mdio = ret;
+
+	return pdata;
+}
+
 static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 {
 	struct mdio_gpio_info *bitbang =
@@ -162,10 +183,15 @@ static void __devexit mdio_gpio_bus_destroy(struct device *dev)
 
 static int __devinit mdio_gpio_probe(struct platform_device *pdev)
 {
-	struct mdio_gpio_platform_data *pdata = pdev->dev.platform_data;
+	struct mdio_gpio_platform_data *pdata;
 	struct mii_bus *new_bus;
 	int ret;
 
+	if (pdev->dev.of_node)
+		pdata = mdio_gpio_of_get_data(pdev);
+	else
+		pdata = pdev->dev.platform_data;
+
 	if (!pdata)
 		return -ENODEV;
 
@@ -173,7 +199,11 @@ static int __devinit mdio_gpio_probe(struct platform_device *pdev)
 	if (!new_bus)
 		return -ENODEV;
 
-	ret = mdiobus_register(new_bus);
+	if (pdev->dev.of_node)
+		ret = of_mdiobus_register(new_bus, pdev->dev.of_node);
+	else
+		ret = mdiobus_register(new_bus);
+
 	if (ret)
 		mdio_gpio_bus_deinit(&pdev->dev);
 
@@ -187,112 +217,30 @@ static int __devexit mdio_gpio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_OF_GPIO
-
-static int __devinit mdio_ofgpio_probe(struct platform_device *ofdev)
-{
-	struct mdio_gpio_platform_data *pdata;
-	struct mii_bus *new_bus;
-	int ret;
-
-	pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
-	if (!pdata)
-		return -ENOMEM;
-
-	ret = of_get_gpio(ofdev->dev.of_node, 0);
-	if (ret < 0)
-		goto out_free;
-	pdata->mdc = ret;
-
-	ret = of_get_gpio(ofdev->dev.of_node, 1);
-	if (ret < 0)
-		goto out_free;
-	pdata->mdio = ret;
-
-	new_bus = mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
-	if (!new_bus)
-		goto out_free;
-
-	ret = of_mdiobus_register(new_bus, ofdev->dev.of_node);
-	if (ret)
-		mdio_gpio_bus_deinit(&ofdev->dev);
-
-	return ret;
-
-out_free:
-	kfree(pdata);
-	return -ENODEV;
-}
-
-static int __devexit mdio_ofgpio_remove(struct platform_device *ofdev)
-{
-	mdio_gpio_bus_destroy(&ofdev->dev);
-	kfree(ofdev->dev.platform_data);
-
-	return 0;
-}
-
-static struct of_device_id mdio_ofgpio_match[] = {
-	{
-		.compatible = "virtual,mdio-gpio",
-	},
-	{},
-};
-MODULE_DEVICE_TABLE(of, mdio_ofgpio_match);
-
-static struct platform_driver mdio_ofgpio_driver = {
-	.driver = {
-		.name = "mdio-ofgpio",
-		.owner = THIS_MODULE,
-		.of_match_table = mdio_ofgpio_match,
-	},
-	.probe = mdio_ofgpio_probe,
-	.remove = __devexit_p(mdio_ofgpio_remove),
+static struct of_device_id mdio_gpio_of_match[] = {
+	{ .compatible = "virtual,mdio-gpio", },
+	{ /* sentinel */ }
 };
 
-static inline int __init mdio_ofgpio_init(void)
-{
-	return platform_driver_register(&mdio_ofgpio_driver);
-}
-
-static inline void mdio_ofgpio_exit(void)
-{
-	platform_driver_unregister(&mdio_ofgpio_driver);
-}
-#else
-static inline int __init mdio_ofgpio_init(void) { return 0; }
-static inline void mdio_ofgpio_exit(void) { }
-#endif /* CONFIG_OF_GPIO */
-
 static struct platform_driver mdio_gpio_driver = {
 	.probe = mdio_gpio_probe,
 	.remove = __devexit_p(mdio_gpio_remove),
 	.driver		= {
 		.name	= "mdio-gpio",
 		.owner	= THIS_MODULE,
+		.of_match_table = mdio_gpio_of_match,
 	},
 };
 
 static int __init mdio_gpio_init(void)
 {
-	int ret;
-
-	ret = mdio_ofgpio_init();
-	if (ret)
-		return ret;
-
-	ret = platform_driver_register(&mdio_gpio_driver);
-	if (ret)
-		mdio_ofgpio_exit();
-
-	return ret;
+	return platform_driver_register(&mdio_gpio_driver);
 }
 module_init(mdio_gpio_init);
 
 static void __exit mdio_gpio_exit(void)
 {
 	platform_driver_unregister(&mdio_gpio_driver);
-	mdio_ofgpio_exit();
 }
 module_exit(mdio_gpio_exit);
 
-- 
1.7.0.4
