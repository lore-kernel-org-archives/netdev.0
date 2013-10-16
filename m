From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 4/5] net: rfkill: gpio: prepare for DT and ACPI support
Date: Wed, 16 Oct 2013 13:53:42 +0300
Message-ID: <1381920823-15403-5-git-send-email-heikki.krogerus@linux.intel.com>
References: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Rhyland Klein <rklein@nvidia.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	linux-acpi@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35004 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760680Ab3JPKx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 06:53:59 -0400
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will add the relevant values like the gpios and the
type in rfkill_gpio_platform_data to the rfkill_gpio_data
structure. It will allow those values to be easily picked
from DT and ACPI tables later.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 92 +++++++++++++++++++++++++++---------------------
 1 file changed, 51 insertions(+), 41 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index aa4ac10..2dd78c6 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -28,12 +28,17 @@
 #include <linux/rfkill-gpio.h>
 
 struct rfkill_gpio_data {
-	struct rfkill_gpio_platform_data	*pdata;
-	struct rfkill				*rfkill_dev;
-	char					*reset_name;
-	char					*shutdown_name;
-	struct clk				*clk;
-	bool					clk_enabled;
+	const char		*name;
+	enum rfkill_type	type;
+	int			reset_gpio;
+	int			shutdown_gpio;
+
+	struct rfkill		*rfkill_dev;
+	char			*reset_name;
+	char			*shutdown_name;
+	struct clk		*clk;
+
+	bool			clk_enabled;
 };
 
 static int rfkill_gpio_set_power(void *data, bool blocked)
@@ -41,19 +46,19 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
 	struct rfkill_gpio_data *rfkill = data;
 
 	if (blocked) {
-		if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
-			gpio_set_value(rfkill->pdata->shutdown_gpio, 0);
-		if (gpio_is_valid(rfkill->pdata->reset_gpio))
-			gpio_set_value(rfkill->pdata->reset_gpio, 0);
+		if (gpio_is_valid(rfkill->shutdown_gpio))
+			gpio_set_value(rfkill->shutdown_gpio, 0);
+		if (gpio_is_valid(rfkill->reset_gpio))
+			gpio_set_value(rfkill->reset_gpio, 0);
 		if (!IS_ERR(rfkill->clk) && rfkill->clk_enabled)
 			clk_disable(rfkill->clk);
 	} else {
 		if (!IS_ERR(rfkill->clk) && !rfkill->clk_enabled)
 			clk_enable(rfkill->clk);
-		if (gpio_is_valid(rfkill->pdata->reset_gpio))
-			gpio_set_value(rfkill->pdata->reset_gpio, 1);
-		if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
-			gpio_set_value(rfkill->pdata->shutdown_gpio, 1);
+		if (gpio_is_valid(rfkill->reset_gpio))
+			gpio_set_value(rfkill->reset_gpio, 1);
+		if (gpio_is_valid(rfkill->shutdown_gpio))
+			gpio_set_value(rfkill->shutdown_gpio, 1);
 	}
 
 	rfkill->clk_enabled = blocked;
@@ -67,29 +72,35 @@ static const struct rfkill_ops rfkill_gpio_ops = {
 
 static int rfkill_gpio_probe(struct platform_device *pdev)
 {
-	struct rfkill_gpio_data *rfkill;
 	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
+	struct rfkill_gpio_data *rfkill;
+	const char *clk_name = NULL;
 	int ret = 0;
 	int len = 0;
 
-	if (!pdata) {
-		pr_warn("%s: No platform data specified\n", __func__);
-		return -EINVAL;
+	rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
+	if (!rfkill)
+		return -ENOMEM;
+
+	if (pdata) {
+		clk_name = pdata->power_clk_name;
+		rfkill->name = pdata->name;
+		rfkill->type = pdata->type;
+		rfkill->reset_gpio = pdata->reset_gpio;
+		rfkill->shutdown_gpio = pdata->shutdown_gpio;
+	} else {
+		return -ENODEV;
 	}
 
 	/* make sure at-least one of the GPIO is defined and that
 	 * a name is specified for this instance */
-	if (!pdata->name || (!gpio_is_valid(pdata->reset_gpio) &&
-		!gpio_is_valid(pdata->shutdown_gpio))) {
+	if ((!gpio_is_valid(rfkill->reset_gpio) &&
+	     !gpio_is_valid(rfkill->shutdown_gpio)) || !rfkill->name) {
 		pr_warn("%s: invalid platform data\n", __func__);
 		return -EINVAL;
 	}
 
-	rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
-	if (!rfkill)
-		return -ENOMEM;
-
-	if (pdata->gpio_runtime_setup) {
+	if (pdata && pdata->gpio_runtime_setup) {
 		ret = pdata->gpio_runtime_setup(pdev);
 		if (ret) {
 			pr_warn("%s: can't set up gpio\n", __func__);
@@ -97,9 +108,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		}
 	}
 
-	rfkill->pdata = pdata;
-
-	len = strlen(pdata->name);
+	len = strlen(rfkill->name);
 	rfkill->reset_name = devm_kzalloc(&pdev->dev, len + 7, GFP_KERNEL);
 	if (!rfkill->reset_name)
 		return -ENOMEM;
@@ -108,13 +117,13 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	if (!rfkill->shutdown_name)
 		return -ENOMEM;
 
-	snprintf(rfkill->reset_name, len + 6 , "%s_reset", pdata->name);
-	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", pdata->name);
+	snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
+	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
 
-	rfkill->clk = devm_clk_get(&pdev->dev, pdata->power_clk_name);
+	rfkill->clk = devm_clk_get(&pdev->dev, clk_name);
 
-	if (gpio_is_valid(pdata->reset_gpio)) {
-		ret = devm_gpio_request_one(&pdev->dev, pdata->reset_gpio,
+	if (gpio_is_valid(rfkill->reset_gpio)) {
+		ret = devm_gpio_request_one(&pdev->dev, rfkill->reset_gpio,
 					    0, rfkill->reset_name);
 		if (ret) {
 			pr_warn("%s: failed to get reset gpio.\n", __func__);
@@ -122,8 +131,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		}
 	}
 
-	if (gpio_is_valid(pdata->shutdown_gpio)) {
-		ret = devm_gpio_request_one(&pdev->dev, pdata->shutdown_gpio,
+	if (gpio_is_valid(rfkill->shutdown_gpio)) {
+		ret = devm_gpio_request_one(&pdev->dev, rfkill->shutdown_gpio,
 					    0, rfkill->shutdown_name);
 		if (ret) {
 			pr_warn("%s: failed to get shutdown gpio.\n", __func__);
@@ -131,8 +140,9 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		}
 	}
 
-	rfkill->rfkill_dev = rfkill_alloc(pdata->name, &pdev->dev, pdata->type,
-					  &rfkill_gpio_ops, rfkill);
+	rfkill->rfkill_dev = rfkill_alloc(rfkill->name, &pdev->dev,
+					  rfkill->type, &rfkill_gpio_ops,
+					  rfkill);
 	if (!rfkill->rfkill_dev)
 		return -ENOMEM;
 
@@ -142,7 +152,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, rfkill);
 
-	dev_info(&pdev->dev, "%s device registered.\n", pdata->name);
+	dev_info(&pdev->dev, "%s device registered.\n", rfkill->name);
 
 	return 0;
 }
@@ -152,7 +162,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 	struct rfkill_gpio_data *rfkill = platform_get_drvdata(pdev);
 	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
 
-	if (pdata->gpio_runtime_close)
+	if (pdata && pdata->gpio_runtime_close)
 		pdata->gpio_runtime_close(pdev);
 	rfkill_unregister(rfkill->rfkill_dev);
 	rfkill_destroy(rfkill->rfkill_dev);
@@ -164,8 +174,8 @@ static struct platform_driver rfkill_gpio_driver = {
 	.probe = rfkill_gpio_probe,
 	.remove = rfkill_gpio_remove,
 	.driver = {
-		   .name = "rfkill_gpio",
-		   .owner = THIS_MODULE,
+		.name = "rfkill_gpio",
+		.owner = THIS_MODULE,
 	},
 };
 
-- 
1.8.4.rc3
