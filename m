From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 1/8] MIPS: BCM63XX: add clkdev lookup support
Date: Wed,  2 Aug 2017 11:34:22 +0200
Message-ID: <20170802093429.12572-2-jonas.gorski@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        Kevin Cernekee <cernekee@gmail.com>,
        Jiri Slaby <jslaby@suse.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-arm-kernel@lists.infradead.org,
        linux-serial@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35122 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752352AbdHBJfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 05:35:09 -0400
In-Reply-To: <20170802093429.12572-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable clkdev lookup support to allow us providing clocks under
different names to devices more easily, so we don't need to care
about clock name clashes anymore.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 arch/mips/Kconfig       |   1 +
 arch/mips/bcm63xx/clk.c | 150 +++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 116 insertions(+), 35 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 8dd20358464f..1bc4c5e1fc8e 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -275,6 +275,7 @@ config BCM63XX
 	select GPIOLIB
 	select HAVE_CLK
 	select MIPS_L1_CACHE_SHIFT_4
+	select CLKDEV_LOOKUP
 	help
 	 Support for BCM63XX based boards
 
diff --git a/arch/mips/bcm63xx/clk.c b/arch/mips/bcm63xx/clk.c
index 73626040e4d6..eb1cb0bf930b 100644
--- a/arch/mips/bcm63xx/clk.c
+++ b/arch/mips/bcm63xx/clk.c
@@ -11,6 +11,7 @@
 #include <linux/mutex.h>
 #include <linux/err.h>
 #include <linux/clk.h>
+#include <linux/clkdev.h>
 #include <linux/delay.h>
 #include <bcm63xx_cpu.h>
 #include <bcm63xx_io.h>
@@ -356,44 +357,103 @@ long clk_round_rate(struct clk *clk, unsigned long rate)
 }
 EXPORT_SYMBOL_GPL(clk_round_rate);
 
-struct clk *clk_get(struct device *dev, const char *id)
-{
-	if (!strcmp(id, "enet0"))
-		return &clk_enet0;
-	if (!strcmp(id, "enet1"))
-		return &clk_enet1;
-	if (!strcmp(id, "enetsw"))
-		return &clk_enetsw;
-	if (!strcmp(id, "ephy"))
-		return &clk_ephy;
-	if (!strcmp(id, "usbh"))
-		return &clk_usbh;
-	if (!strcmp(id, "usbd"))
-		return &clk_usbd;
-	if (!strcmp(id, "spi"))
-		return &clk_spi;
-	if (!strcmp(id, "hsspi"))
-		return &clk_hsspi;
-	if (!strcmp(id, "xtm"))
-		return &clk_xtm;
-	if (!strcmp(id, "periph"))
-		return &clk_periph;
-	if ((BCMCPU_IS_3368() || BCMCPU_IS_6358()) && !strcmp(id, "pcm"))
-		return &clk_pcm;
-	if ((BCMCPU_IS_6362() || BCMCPU_IS_6368()) && !strcmp(id, "ipsec"))
-		return &clk_ipsec;
-	if ((BCMCPU_IS_6328() || BCMCPU_IS_6362()) && !strcmp(id, "pcie"))
-		return &clk_pcie;
-	return ERR_PTR(-ENOENT);
-}
+static struct clk_lookup bcm3368_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
+	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
+	CLKDEV_INIT(NULL, "ephy", &clk_ephy),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT(NULL, "pcm", &clk_pcm),
+};
 
-EXPORT_SYMBOL(clk_get);
+static struct clk_lookup bcm6328_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "hsspi", &clk_hsspi),
+	CLKDEV_INIT(NULL, "pcie", &clk_pcie),
+};
 
-void clk_put(struct clk *clk)
-{
-}
+static struct clk_lookup bcm6338_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
+	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
+	CLKDEV_INIT(NULL, "ephy", &clk_ephy),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+};
+
+static struct clk_lookup bcm6345_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
+	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
+	CLKDEV_INIT(NULL, "ephy", &clk_ephy),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+};
+
+static struct clk_lookup bcm6348_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
+	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
+	CLKDEV_INIT(NULL, "ephy", &clk_ephy),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+};
 
-EXPORT_SYMBOL(clk_put);
+static struct clk_lookup bcm6358_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
+	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
+	CLKDEV_INIT(NULL, "ephy", &clk_ephy),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT(NULL, "pcm", &clk_pcm),
+};
+
+static struct clk_lookup bcm6362_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT(NULL, "hsspi", &clk_hsspi),
+	CLKDEV_INIT(NULL, "pcie", &clk_pcie),
+	CLKDEV_INIT(NULL, "ipsec", &clk_ipsec),
+};
+
+static struct clk_lookup bcm6368_clks[] = {
+	/* fixed rate clocks */
+	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	/* gated clocks */
+	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
+	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
+	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
+	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT(NULL, "xtm", &clk_xtm),
+	CLKDEV_INIT(NULL, "ipsec", &clk_ipsec),
+};
 
 #define HSSPI_PLL_HZ_6328	133333333
 #define HSSPI_PLL_HZ_6362	400000000
@@ -401,11 +461,31 @@ EXPORT_SYMBOL(clk_put);
 static int __init bcm63xx_clk_init(void)
 {
 	switch (bcm63xx_get_cpu_id()) {
+	case BCM3368_CPU_ID:
+		clkdev_add_table(bcm3368_clks, ARRAY_SIZE(bcm3368_clks));
+		break;
 	case BCM6328_CPU_ID:
 		clk_hsspi.rate = HSSPI_PLL_HZ_6328;
+		clkdev_add_table(bcm6328_clks, ARRAY_SIZE(bcm6328_clks));
+		break;
+	case BCM6338_CPU_ID:
+		clkdev_add_table(bcm6338_clks, ARRAY_SIZE(bcm6338_clks));
+		break;
+	case BCM6345_CPU_ID:
+		clkdev_add_table(bcm6345_clks, ARRAY_SIZE(bcm6345_clks));
+		break;
+	case BCM6348_CPU_ID:
+		clkdev_add_table(bcm6348_clks, ARRAY_SIZE(bcm6348_clks));
+		break;
+	case BCM6358_CPU_ID:
+		clkdev_add_table(bcm6358_clks, ARRAY_SIZE(bcm6358_clks));
 		break;
 	case BCM6362_CPU_ID:
 		clk_hsspi.rate = HSSPI_PLL_HZ_6362;
+		clkdev_add_table(bcm6362_clks, ARRAY_SIZE(bcm6362_clks));
+		break;
+	case BCM6368_CPU_ID:
+		clkdev_add_table(bcm6368_clks, ARRAY_SIZE(bcm6368_clks));
 		break;
 	}
 
-- 
2.13.2
