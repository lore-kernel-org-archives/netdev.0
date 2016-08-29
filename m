From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 6/8] ARM: sa1100/collie: switch collie IrDA to use gpiod APIs
Date: Mon, 29 Aug 2016 12:26:31 +0100
Message-ID: <E1beKhz-0001HH-Di@rmk-PC.armlinux.org.uk>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56862 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757234AbcH2L0t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:26:49 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the IrDA code to use the gpiod APIs rather than platform data
with function callbacks.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/arm/mach-sa1100/collie.c | 40 ++++++++++++----------------------------
 1 file changed, 12 insertions(+), 28 deletions(-)

diff --git a/arch/arm/mach-sa1100/collie.c b/arch/arm/mach-sa1100/collie.c
index 3cc2b71e16f0..8ed0cbfaa0f4 100644
--- a/arch/arm/mach-sa1100/collie.c
+++ b/arch/arm/mach-sa1100/collie.c
@@ -21,6 +21,7 @@
 #include <linux/kernel.h>
 #include <linux/tty.h>
 #include <linux/delay.h>
+#include <linux/gpio/machine.h>
 #include <linux/platform_data/sa11x0-serial.h>
 #include <linux/platform_device.h>
 #include <linux/mfd/ucb1x00.h>
@@ -97,35 +98,16 @@ static struct mcp_plat_data collie_mcp_data = {
 	.codec_pdata	= &collie_ucb1x00_data,
 };
 
-static int collie_ir_startup(struct device *dev)
-{
-	int rc = gpio_request(COLLIE_GPIO_IR_ON, "IrDA");
-	if (rc)
-		return rc;
-	rc = gpio_direction_output(COLLIE_GPIO_IR_ON, 1);
-
-	if (!rc)
-		return 0;
-
-	gpio_free(COLLIE_GPIO_IR_ON);
-	return rc;
-}
-
-static void collie_ir_shutdown(struct device *dev)
-{
-	gpio_free(COLLIE_GPIO_IR_ON);
-}
-
-static int collie_ir_set_power(struct device *dev, unsigned int state)
-{
-	gpio_set_value(COLLIE_GPIO_IR_ON, !state);
-	return 0;
-}
-
 static struct irda_platform_data collie_ir_data = {
-	.startup = collie_ir_startup,
-	.shutdown = collie_ir_shutdown,
-	.set_power = collie_ir_set_power,
+};
+
+/* IrDA GPIO mappings */
+static struct gpiod_lookup_table collie_irda_gpio_table = {
+	.dev_id = "sa11x0-ir",
+	.table = {
+		GPIO_LOOKUP("ucb1x00", 3, "ir-power", GPIO_ACTIVE_LOW),
+		{ },
+	},
 };
 
 /*
@@ -357,6 +339,8 @@ static void __init collie_init(void)
 {
 	int ret = 0;
 
+	gpiod_add_lookup_table(&collie_irda_gpio_table);
+
 	/* cpu initialize */
 	GAFR = GPIO_SSP_TXD | GPIO_SSP_SCLK | GPIO_SSP_SFRM | GPIO_SSP_CLK |
 		GPIO_MCP_CLK | GPIO_32_768kHz;
-- 
2.1.0
