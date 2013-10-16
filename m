From: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH 3/5] net: rfkill: gpio: spinlock-safe GPIO access
Date: Wed, 16 Oct 2013 13:53:41 +0300
Message-ID: <1381920823-15403-4-git-send-email-heikki.krogerus@linux.intel.com>
References: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This sets the direction of the gpio once when it's requested,
and uses the spinlock-safe gpio_set_state() to change the
state.

Signed-off-by: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 net/rfkill/rfkill-gpio.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 1d104e7..aa4ac10 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -42,18 +42,18 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
 
 	if (blocked) {
 		if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
-			gpio_direction_output(rfkill->pdata->shutdown_gpio, 0);
+			gpio_set_value(rfkill->pdata->shutdown_gpio, 0);
 		if (gpio_is_valid(rfkill->pdata->reset_gpio))
-			gpio_direction_output(rfkill->pdata->reset_gpio, 0);
+			gpio_set_value(rfkill->pdata->reset_gpio, 0);
 		if (!IS_ERR(rfkill->clk) && rfkill->clk_enabled)
 			clk_disable(rfkill->clk);
 	} else {
 		if (!IS_ERR(rfkill->clk) && !rfkill->clk_enabled)
 			clk_enable(rfkill->clk);
 		if (gpio_is_valid(rfkill->pdata->reset_gpio))
-			gpio_direction_output(rfkill->pdata->reset_gpio, 1);
+			gpio_set_value(rfkill->pdata->reset_gpio, 1);
 		if (gpio_is_valid(rfkill->pdata->shutdown_gpio))
-			gpio_direction_output(rfkill->pdata->shutdown_gpio, 1);
+			gpio_set_value(rfkill->pdata->shutdown_gpio, 1);
 	}
 
 	rfkill->clk_enabled = blocked;
@@ -114,8 +114,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	rfkill->clk = devm_clk_get(&pdev->dev, pdata->power_clk_name);
 
 	if (gpio_is_valid(pdata->reset_gpio)) {
-		ret = devm_gpio_request(&pdev->dev, pdata->reset_gpio,
-					rfkill->reset_name);
+		ret = devm_gpio_request_one(&pdev->dev, pdata->reset_gpio,
+					    0, rfkill->reset_name);
 		if (ret) {
 			pr_warn("%s: failed to get reset gpio.\n", __func__);
 			return ret;
@@ -123,8 +123,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	}
 
 	if (gpio_is_valid(pdata->shutdown_gpio)) {
-		ret = devm_gpio_request(&pdev->dev, pdata->shutdown_gpio,
-					rfkill->shutdown_name);
+		ret = devm_gpio_request_one(&pdev->dev, pdata->shutdown_gpio,
+					    0, rfkill->shutdown_name);
 		if (ret) {
 			pr_warn("%s: failed to get shutdown gpio.\n", __func__);
 			return ret;
-- 
1.8.4.rc3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
