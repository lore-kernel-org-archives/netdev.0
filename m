From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 3/5] net: rfkill: gpio: get the name and type from device property
Date: Wed,  5 Aug 2015 16:39:05 +0300
Message-ID: <1438781947-7952-4-git-send-email-heikki.krogerus@linux.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This prepares the driver for removal of platform data.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index d5d58d9..07323c3 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -81,7 +81,6 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
 	if (!id)
 		return -ENODEV;
 
-	rfkill->name = dev_name(dev);
 	rfkill->type = (unsigned)id->driver_data;
 
 	return acpi_dev_add_driver_gpios(ACPI_COMPANION(dev),
@@ -93,12 +92,21 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
 	struct rfkill_gpio_data *rfkill;
 	struct gpio_desc *gpio;
+	const char *type_name;
 	int ret;
 
 	rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
 	if (!rfkill)
 		return -ENOMEM;
 
+	device_property_read_string(&pdev->dev, "name", &rfkill->name);
+	device_property_read_string(&pdev->dev, "type", &type_name);
+
+	if (!rfkill->name)
+		rfkill->name = dev_name(&pdev->dev);
+
+	rfkill->type = rfkill_find_type(type_name);
+
 	if (ACPI_HANDLE(&pdev->dev)) {
 		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
 		if (ret)
@@ -124,10 +132,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 
 	rfkill->shutdown_gpio = gpio;
 
-	/* Make sure at-least one of the GPIO is defined and that
-	 * a name is specified for this instance
-	 */
-	if ((!rfkill->reset_gpio && !rfkill->shutdown_gpio) || !rfkill->name) {
+	/* Make sure at-least one GPIO is defined for this instance */
+	if (!rfkill->reset_gpio && !rfkill->shutdown_gpio) {
 		dev_err(&pdev->dev, "invalid platform data\n");
 		return -EINVAL;
 	}
-- 
2.4.6
