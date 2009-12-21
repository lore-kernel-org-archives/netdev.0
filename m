From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 2/2] mx25: pdk: add platform code for FEC support
Date: Mon, 21 Dec 2009 13:44:32 +0200
Message-ID: <e03d8ad82b7f1e889d68cd8b916c3d76bb9ef8ec.1261395135.git.baruch@tkos.co.il>
References: <20091221110807.GE15126@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Baruch Siach <baruch@tkos.co.il>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:53366 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807AbZLULpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 06:45:55 -0500
In-Reply-To: <20091221110807.GE15126@pengutronix.de>
In-Reply-To: <97e6c149bb27754075241fc672985c5a2ecef4b6.1261395135.git.baruch@tkos.co.il>
References: <97e6c149bb27754075241fc672985c5a2ecef4b6.1261395135.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 arch/arm/mach-mx25/mx25pdk.c |   46 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-mx25/mx25pdk.c b/arch/arm/mach-mx25/mx25pdk.c
index d23ae57..921bc99 100644
--- a/arch/arm/mach-mx25/mx25pdk.c
+++ b/arch/arm/mach-mx25/mx25pdk.c
@@ -18,10 +18,11 @@
 
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/delay.h>
 #include <linux/clk.h>
 #include <linux/irq.h>
 #include <linux/gpio.h>
-#include <linux/smsc911x.h>
+#include <linux/fec.h>
 #include <linux/platform_device.h>
 
 #include <mach/hardware.h>
@@ -35,16 +36,57 @@
 #include <mach/mx25.h>
 #include <mach/mxc_nand.h>
 #include "devices.h"
-#include <mach/iomux-v3.h>
+#include <mach/iomux.h>
 
 static struct imxuart_platform_data uart_pdata = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
 
+static struct pad_desc mx25pdk_pads[] = {
+	MX25_PAD_FEC_MDC__FEC_MDC,
+	MX25_PAD_FEC_MDIO__FEC_MDIO,
+	MX25_PAD_FEC_TDATA0__FEC_TDATA0,
+	MX25_PAD_FEC_TDATA1__FEC_TDATA1,
+	MX25_PAD_FEC_TX_EN__FEC_TX_EN,
+	MX25_PAD_FEC_RDATA0__FEC_RDATA0,
+	MX25_PAD_FEC_RDATA1__FEC_RDATA1,
+	MX25_PAD_FEC_RX_DV__FEC_RX_DV,
+	MX25_PAD_FEC_TX_CLK__FEC_TX_CLK,
+	MX25_PAD_A17__GPIO_2_3, /* FEC_EN, GPIO 35 */
+	MX25_PAD_D12__GPIO_4_8, /* FEC_RESET_B, GPIO 104 */
+};
+
+static struct fec_platform_data mx25_fec_pdata = {
+        .phy    = PHY_INTERFACE_MODE_RMII,
+};
+
+#define FEC_ENABLE_GPIO		35
+#define FEC_RESET_B_GPIO	104
+
+static void __init mx25pdk_fec_reset(void)
+{
+	gpio_request(FEC_ENABLE_GPIO, "FEC PHY enable");
+	gpio_request(FEC_RESET_B_GPIO, "FEC PHY reset");
+
+	gpio_direction_output(FEC_ENABLE_GPIO, 0);  /* drop PHY power */
+	gpio_direction_output(FEC_RESET_B_GPIO, 0); /* assert reset */
+	udelay(2);
+
+	/* turn on PHY power and lift reset */
+	gpio_set_value(FEC_ENABLE_GPIO, 1);
+	gpio_set_value(FEC_RESET_B_GPIO, 1);
+}
+
 static void __init mx25pdk_init(void)
 {
+	mxc_iomux_v3_setup_multiple_pads(mx25pdk_pads,
+			ARRAY_SIZE(mx25pdk_pads));
+
 	mxc_register_device(&mxc_uart_device0, &uart_pdata);
 	mxc_register_device(&mxc_usbh2, NULL);
+
+	mx25pdk_fec_reset();
+	mxc_register_device(&mx25_fec_device, &mx25_fec_pdata);
 }
 
 static void __init mx25pdk_timer_init(void)
-- 
1.6.5

