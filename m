From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 2/5] net: rfkill: gpio: clean up clock handling
Date: Wed, 16 Oct 2013 13:53:40 +0300
Message-ID: <1381920823-15403-3-git-send-email-heikki.krogerus@linux.intel.com>
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
	id S1760342Ab3JPKx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 06:53:56 -0400
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a simple flag to see the state of the clock, and make
the clock available even without a name. Also, get rid of
HAVE_CLK dependency.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/Kconfig       |  2 +-
 net/rfkill/rfkill-gpio.c | 35 ++++++++---------------------------
 2 files changed, 9 insertions(+), 28 deletions(-)

diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
index 78efe89..4c10e7e 100644
--- a/net/rfkill/Kconfig
+++ b/net/rfkill/Kconfig
@@ -36,7 +36,7 @@ config RFKILL_REGULATOR
 
 config RFKILL_GPIO
 	tristate "GPIO RFKILL driver"
-	depends on RFKILL && GPIOLIB && HAVE_CLK
+	depends on RFKILL && GPIOLIB
 	default n
 	help
 	  If you say yes here you get support of a generic gpio RFKILL
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 0705806..1d104e7 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -27,24 +27,13 @@
 
 #include <linux/rfkill-gpio.h>
 
-enum rfkill_gpio_clk_state {
-	UNSPECIFIED = 0,
-	PWR_ENABLED,
-	PWR_DISABLED
-};
-
-#define PWR_CLK_SET(_RF, _EN) \
-	((_RF)->pwr_clk_enabled = (!(_EN) ? PWR_ENABLED : PWR_DISABLED))
-#define PWR_CLK_ENABLED(_RF) ((_RF)->pwr_clk_enabled == PWR_ENABLED)
-#define PWR_CLK_DISABLED(_RF) ((_RF)->pwr_clk_enabled != PWR_ENABLED)
-
 struct rfkill_gpio_data {
 	struct rfkill_gpio_platform_data	*pdata;
 	struct rfkill				*rfkill_dev;
 	char					*reset_name;
 	char					*shutdown_name;
-	enum rfkill_gpio_clk_state		pwr_clk_enabled;
-	struct clk				*pwr_clk;
+	struct clk				*clk;
+	bool					clk_enabled;
 };
 
 static int rfkill_gpio_set_power(void *data, bool blocked)
@@ -56,19 +45,18 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
 			gpio_direction_output(rfkill->pdata->shutdown_gpio, 0);
 		if (gpio_is_valid(rfkill->pdata->reset_gpio))
 			gpio_direction_output(rfkill->pdata->reset_gpio, 0);
-		if (rfkill->pwr_clk && PWR_CLK_ENABLED(rfkill))
-			clk_disable(rfkill->pwr_clk);
+		if (!IS_ERR(rfkill->clk) && rfkill->clk_enabled)
+			clk_disable(rfkill->clk);
 	} else {
-		if (rfkill->pwr_clk && PWR_CLK_DISABLED(rfkill))
-			clk_enable(rfkill->pwr_clk);
+		if (!IS_ERR(rfkill->clk) && !rfkill->clk_enabled)
+			clk_enable(rfkill->clk);
 		if (gpio_is_valid(rfkill->pdata->reset_gpio))
 			gpio_direction_output(rfkill->pdata->reset_gpio, 1);
 		if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
 			gpio_direction_output(rfkill->pdata->shutdown_gpio, 1);
 	}
 
-	if (rfkill->pwr_clk)
-		PWR_CLK_SET(rfkill, blocked);
+	rfkill->clk_enabled = blocked;
 
 	return 0;
 }
@@ -123,14 +111,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	snprintf(rfkill->reset_name, len + 6 , "%s_reset", pdata->name);
 	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", pdata->name);
 
-	if (pdata->power_clk_name) {
-		rfkill->pwr_clk = devm_clk_get(&pdev->dev,
-						pdata->power_clk_name);
-		if (IS_ERR(rfkill->pwr_clk)) {
-			pr_warn("%s: can't find pwr_clk.\n", __func__);
-			return PTR_ERR(rfkill->pwr_clk);
-		}
-	}
+	rfkill->clk = devm_clk_get(&pdev->dev, pdata->power_clk_name);
 
 	if (gpio_is_valid(pdata->reset_gpio)) {
 		ret = devm_gpio_request(&pdev->dev, pdata->reset_gpio,
-- 
1.8.4.rc3
