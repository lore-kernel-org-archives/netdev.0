From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
Subject: [PATCH v2 3/5] omap: panda: add fixed regulator device for wlan
Date: Tue, 15 Feb 2011 03:40:34 -0500
Message-ID: <1297759236-25323-4-git-send-email-panduranga_mallireddy@ti.com>
References: <1297759236-25323-1-git-send-email-panduranga_mallireddy@ti.com>
 <1297759236-25323-2-git-send-email-panduranga_mallireddy@ti.com>
 <1297759236-25323-3-git-send-email-panduranga_mallireddy@ti.com>
Cc: ohad@wizery.com, benzyg@ti.com, pradeepgurumath@ti.com,
	vishalm@ti.com, x-boudet@ti.com, naveen_jain@ti.com,
	pavan_savoy@ti.com, manjunatha_halli@ti.com, tony@atomide.com,
	cjb@laptop.org,
	Panduranga Mallireddy <panduranga_mallireddy@ti.com>
To: coelho@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:46654 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690Ab1BOIPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 03:15:06 -0500
In-Reply-To: <1297759236-25323-3-git-send-email-panduranga_mallireddy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a fixed regulator vmmc device to enable power control
of the wl1271 wlan device.

Based on the patch for zoom by Ohad Ben-Cohen <ohad@wizery.com>
Signed-off-by: Panduranga Mallireddy <panduranga_mallireddy@ti.com>
---
 arch/arm/mach-omap2/board-omap4panda.c |   34 ++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/board-omap4panda.c b/arch/arm/mach-omap2/board-omap4panda.c
index cc9df6c..cd25255 100644
--- a/arch/arm/mach-omap2/board-omap4panda.c
+++ b/arch/arm/mach-omap2/board-omap4panda.c
@@ -26,6 +26,7 @@
 #include <linux/usb/otg.h>
 #include <linux/i2c/twl.h>
 #include <linux/regulator/machine.h>
+#include <linux/regulator/fixed.h>
 
 #include <mach/hardware.h>
 #include <mach/omap4-common.h>
@@ -45,6 +46,7 @@
 
 #define GPIO_HUB_POWER		1
 #define GPIO_HUB_NRESET		62
+#define GPIO_WIFI_PMENA		43
 
 static struct gpio_led gpio_leds[] = {
 	{
@@ -172,6 +174,37 @@ static struct regulator_consumer_supply omap4_panda_vmmc_supply[] = {
 	},
 };
 
+static struct regulator_consumer_supply omap4_panda_vmmc5_supply = {
+	.supply = "vmmc",
+	.dev_name = "mmci-omap-hs.4",
+};
+
+static struct regulator_init_data panda_vmmc5 = {
+	.constraints = {
+		.valid_ops_mask = REGULATOR_CHANGE_STATUS,
+	},
+	.num_consumer_supplies = 1,
+	.consumer_supplies = &omap4_panda_vmmc5_supply,
+};
+
+static struct fixed_voltage_config panda_vwlan = {
+	.supply_name = "vwl1271",
+	.microvolts = 1800000, /* 1.8V */
+	.gpio = GPIO_WIFI_PMENA,
+	.startup_delay = 70000, /* 70msec */
+	.enable_high = 1,
+	.enabled_at_boot = 0,
+	.init_data = &panda_vmmc5,
+};
+
+static struct platform_device omap_vwlan_device = {
+	.name		= "reg-fixed-voltage",
+	.id		= 1,
+	.dev = {
+		.platform_data = &panda_vwlan,
+	},
+};
+
 static int omap4_twl6030_hsmmc_late_init(struct device *dev)
 {
 	int ret = 0;
@@ -430,6 +463,7 @@ static void __init omap4_panda_init(void)
 
 	omap4_panda_i2c_init();
 	platform_add_devices(panda_devices, ARRAY_SIZE(panda_devices));
+	platform_device_register(&omap_vwlan_device);
 	omap_serial_init();
 	omap4_twl6030_hsmmc_init(mmc);
 	/* OMAP4 Panda uses internal transceiver so register nop transceiver */
-- 
1.5.6.3

