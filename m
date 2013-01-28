From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 6/6] ARM: davinci: da850: configure system configuration chip(CFGCHIP3) for emac
Date: Mon, 28 Jan 2013 19:17:59 +0530
Message-ID: <1359380879-26306-7-git-send-email-prabhakar.lad@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.lad@ti.com>

The system configuration chip CFGCHIP3, controls the emac module.
This patch appropriately configures this register for emac and
sets DA850_MII_MDIO_CLKEN_PIN GPIO pin appropriately.

Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 arch/arm/mach-davinci/da8xx-dt.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
index e533a0a..4a096e3 100644
--- a/arch/arm/mach-davinci/da8xx-dt.c
+++ b/arch/arm/mach-davinci/da8xx-dt.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/io.h>
+#include <linux/gpio.h>
 #include <linux/of_irq.h>
 #include <linux/of_platform.h>
 #include <linux/irqdomain.h>
@@ -39,6 +40,32 @@ static void __init da8xx_init_irq(void)
 
 #ifdef CONFIG_ARCH_DAVINCI_DA850
 
+static void __init da8xx_config_emac(void)
+{
+#define DA850_MII_MDIO_CLKEN_PIN	GPIO_TO_PIN(2, 6)
+#define DA850_EMAC_MODE_SELECT		BIT(8)
+	void __iomem *cfg_chip3_base;
+	int ret;
+	u32 val;
+
+	cfg_chip3_base = DA8XX_SYSCFG0_VIRT(DA8XX_CFGCHIP3_REG);
+
+	val = __raw_readl(cfg_chip3_base);
+	val &= ~DA850_EMAC_MODE_SELECT;
+	/* configure the CFGCHIP3 register for MII */
+	__raw_writel(val, cfg_chip3_base);
+	pr_info("EMAC: MII PHY configured\n");
+
+	ret = gpio_request(DA850_MII_MDIO_CLKEN_PIN, "mdio_clk_en");
+	if (ret) {
+		pr_warn("Cannot open GPIO %d\n",
+					DA850_MII_MDIO_CLKEN_PIN);
+		return;
+	}
+	/* Enable/Disable MII MDIO clock */
+	gpio_direction_output(DA850_MII_MDIO_CLKEN_PIN, 0);
+}
+
 struct of_dev_auxdata da8xx_auxdata[] __initdata = {
 	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
 	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
@@ -52,6 +79,7 @@ static void __init da850_init_machine(void)
 			     da8xx_auxdata, NULL);
 
 	da8xx_uart_clk_enable();
+	da8xx_config_emac();
 }
 
 static const char *da850_boards_compat[] __initdata = {
-- 
1.7.4.1
