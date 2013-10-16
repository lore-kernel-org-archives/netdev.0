From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 1/5] net: rfkill: gpio: convert to resource managed allocation
Date: Wed, 16 Oct 2013 13:53:39 +0300
Message-ID: <1381920823-15403-2-git-send-email-heikki.krogerus@linux.intel.com>
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
	id S1760596Ab3JPKxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 06:53:54 -0400
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And remove now unneeded resource freeing.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 75 +++++++++++++-----------------------------------
 1 file changed, 20 insertions(+), 55 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index fb076cd..0705806 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -97,7 +97,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		return -EINVAL;
 	}
 
-	rfkill = kzalloc(sizeof(*rfkill), GFP_KERNEL);
+	rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
 	if (!rfkill)
 		return -ENOMEM;
 
@@ -105,89 +105,65 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		ret = pdata->gpio_runtime_setup(pdev);
 		if (ret) {
 			pr_warn("%s: can't set up gpio\n", __func__);
-			goto fail_alloc;
+			return ret;
 		}
 	}
 
 	rfkill->pdata = pdata;
 
 	len = strlen(pdata->name);
-	rfkill->reset_name = kzalloc(len + 7, GFP_KERNEL);
-	if (!rfkill->reset_name) {
-		ret = -ENOMEM;
-		goto fail_alloc;
-	}
+	rfkill->reset_name = devm_kzalloc(&pdev->dev, len + 7, GFP_KERNEL);
+	if (!rfkill->reset_name)
+		return -ENOMEM;
 
-	rfkill->shutdown_name = kzalloc(len + 10, GFP_KERNEL);
-	if (!rfkill->shutdown_name) {
-		ret = -ENOMEM;
-		goto fail_reset_name;
-	}
+	rfkill->shutdown_name = devm_kzalloc(&pdev->dev, len + 10, GFP_KERNEL);
+	if (!rfkill->shutdown_name)
+		return -ENOMEM;
 
 	snprintf(rfkill->reset_name, len + 6 , "%s_reset", pdata->name);
 	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", pdata->name);
 
 	if (pdata->power_clk_name) {
-		rfkill->pwr_clk = clk_get(&pdev->dev, pdata->power_clk_name);
+		rfkill->pwr_clk = devm_clk_get(&pdev->dev,
+						pdata->power_clk_name);
 		if (IS_ERR(rfkill->pwr_clk)) {
 			pr_warn("%s: can't find pwr_clk.\n", __func__);
-			ret = PTR_ERR(rfkill->pwr_clk);
-			goto fail_shutdown_name;
+			return PTR_ERR(rfkill->pwr_clk);
 		}
 	}
 
 	if (gpio_is_valid(pdata->reset_gpio)) {
-		ret = gpio_request(pdata->reset_gpio, rfkill->reset_name);
+		ret = devm_gpio_request(&pdev->dev, pdata->reset_gpio,
+					rfkill->reset_name);
 		if (ret) {
 			pr_warn("%s: failed to get reset gpio.\n", __func__);
-			goto fail_clock;
+			return ret;
 		}
 	}
 
 	if (gpio_is_valid(pdata->shutdown_gpio)) {
-		ret = gpio_request(pdata->shutdown_gpio, rfkill->shutdown_name);
+		ret = devm_gpio_request(&pdev->dev, pdata->shutdown_gpio,
+					rfkill->shutdown_name);
 		if (ret) {
 			pr_warn("%s: failed to get shutdown gpio.\n", __func__);
-			goto fail_reset;
+			return ret;
 		}
 	}
 
 	rfkill->rfkill_dev = rfkill_alloc(pdata->name, &pdev->dev, pdata->type,
 					  &rfkill_gpio_ops, rfkill);
-	if (!rfkill->rfkill_dev) {
-		ret = -ENOMEM;
-		goto fail_shutdown;
-	}
+	if (!rfkill->rfkill_dev)
+		return -ENOMEM;
 
 	ret = rfkill_register(rfkill->rfkill_dev);
 	if (ret < 0)
-		goto fail_rfkill;
+		return ret;
 
 	platform_set_drvdata(pdev, rfkill);
 
 	dev_info(&pdev->dev, "%s device registered.\n", pdata->name);
 
 	return 0;
-
-fail_rfkill:
-	rfkill_destroy(rfkill->rfkill_dev);
-fail_shutdown:
-	if (gpio_is_valid(pdata->shutdown_gpio))
-		gpio_free(pdata->shutdown_gpio);
-fail_reset:
-	if (gpio_is_valid(pdata->reset_gpio))
-		gpio_free(pdata->reset_gpio);
-fail_clock:
-	if (rfkill->pwr_clk)
-		clk_put(rfkill->pwr_clk);
-fail_shutdown_name:
-	kfree(rfkill->shutdown_name);
-fail_reset_name:
-	kfree(rfkill->reset_name);
-fail_alloc:
-	kfree(rfkill);
-
-	return ret;
 }
 
 static int rfkill_gpio_remove(struct platform_device *pdev)
@@ -199,17 +175,6 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 		pdata->gpio_runtime_close(pdev);
 	rfkill_unregister(rfkill->rfkill_dev);
 	rfkill_destroy(rfkill->rfkill_dev);
-	if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
-		gpio_free(rfkill->pdata->shutdown_gpio);
-	if (gpio_is_valid(rfkill->pdata->reset_gpio))
-		gpio_free(rfkill->pdata->reset_gpio);
-	if (rfkill->pwr_clk && PWR_CLK_ENABLED(rfkill))
-		clk_disable(rfkill->pwr_clk);
-	if (rfkill->pwr_clk)
-		clk_put(rfkill->pwr_clk);
-	kfree(rfkill->shutdown_name);
-	kfree(rfkill->reset_name);
-	kfree(rfkill);
 
 	return 0;
 }
-- 
1.8.4.rc3
