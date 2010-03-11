From: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 2/2] davinci: introduce EMAC PHY clock usage
Date: Thu, 11 Mar 2010 19:54:51 +0530
Message-ID: <1268317491-3822-3-git-send-email-srk@ti.com>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
	<1268317491-3822-2-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1268317491-3822-2-git-send-email-srk-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>

The patch "TI DaVinci EMAC: Add EMAC PHY clock handling" adds
support for enabling and disabling the EMAC PHY clock.

The PHY clock on all DaVinci boards is derived from a fixed
on board clock. This patch adds the PHY clock definition to
the clock tree for all the DaVinci boards using EMAC. Also,
the existing input to EMAC module is differentiated from the
PHY clock using the clock name "emac_clk".

Without this patch ethernet fails to initialize since it cannot
get the PHY clock and EMAC clock.

Tested on EVM boards for DM365, DM6467, DM644x, DA830 and DA850.

Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
Though i have made changes for Neuros OSD2 and SFFSDR boards, i
do not have the hardware to test. Appreciate if folks having this
hardware ack the patch.

 arch/arm/mach-davinci/board-da830-evm.c   |   19 +++++++++++++++++++
 arch/arm/mach-davinci/board-da850-evm.c   |   21 +++++++++++++++++++++
 arch/arm/mach-davinci/board-dm365-evm.c   |   18 ++++++++++++++++++
 arch/arm/mach-davinci/board-dm644x-evm.c  |   18 ++++++++++++++++++
 arch/arm/mach-davinci/board-dm646x-evm.c  |   15 +++++++++++++++
 arch/arm/mach-davinci/board-neuros-osd2.c |   19 +++++++++++++++++++
 arch/arm/mach-davinci/board-sffsdr.c      |   19 +++++++++++++++++++
 arch/arm/mach-davinci/da830.c             |    2 +-
 arch/arm/mach-davinci/da850.c             |    2 +-
 arch/arm/mach-davinci/dm365.c             |    2 +-
 arch/arm/mach-davinci/dm644x.c            |    2 +-
 arch/arm/mach-davinci/dm646x.c            |    2 +-
 12 files changed, 134 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-davinci/board-da830-evm.c b/arch/arm/mach-davinci/board-da830-evm.c
index dc19870..54e8567 100644
--- a/arch/arm/mach-davinci/board-da830-evm.c
+++ b/arch/arm/mach-davinci/board-da830-evm.c
@@ -20,9 +20,11 @@
 #include <linux/i2c/at24.h>
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
+#include <linux/clk.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
+#include <mach/clock.h>
 
 #include <mach/cp_intc.h>
 #include <mach/mux.h>
@@ -30,6 +32,8 @@
 #include <mach/da8xx.h>
 #include <mach/usb.h>
 
+#include "clock.h"
+
 #define DA830_EVM_PHY_MASK		0x0
 #define DA830_EVM_MDIO_FREQUENCY	2200000	/* PHY bus frequency */
 
@@ -557,9 +561,24 @@ static __init void da830_evm_irq_init(void)
 			soc_info->intc_irq_prios);
 }
 
+#define EMAC_PHY_CLK_RATE	50000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init da830_evm_map_io(void)
 {
 	da830_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 MACHINE_START(DAVINCI_DA830_EVM, "DaVinci DA830/OMAP-L137 EVM")
diff --git a/arch/arm/mach-davinci/board-da850-evm.c b/arch/arm/mach-davinci/board-da850-evm.c
index 411284d..c43ae45 100644
--- a/arch/arm/mach-davinci/board-da850-evm.c
+++ b/arch/arm/mach-davinci/board-da850-evm.c
@@ -24,6 +24,7 @@
 #include <linux/mtd/partitions.h>
 #include <linux/mtd/physmap.h>
 #include <linux/regulator/machine.h>
+#include <linux/clk.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -32,6 +33,9 @@
 #include <mach/da8xx.h>
 #include <mach/nand.h>
 #include <mach/mux.h>
+#include <mach/clock.h>
+
+#include "clock.h"
 
 #define DA850_EVM_PHY_MASK		0x1
 #define DA850_EVM_MDIO_FREQUENCY	2200000 /* PHY bus frequency */
@@ -551,6 +555,18 @@ static const short da850_evm_lcdc_pins[] = {
 	-1
 };
 
+#define EMAC_MII_PHY_CLK_RATE	25000000
+#define EMAC_RMII_PHY_CLK_RATE	50000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static int __init da850_evm_config_emac(void)
 {
 	void __iomem *cfg_chip3_base;
@@ -571,17 +587,22 @@ static int __init da850_evm_config_emac(void)
 		ret = da8xx_pinmux_setup(da850_rmii_pins);
 		pr_info("EMAC: RMII PHY configured, MII PHY will not be"
 							" functional\n");
+		emac_phy.rate = EMAC_RMII_PHY_CLK_RATE;
 	} else {
 		val &= ~BIT(8);
 		ret = da8xx_pinmux_setup(da850_cpgmac_pins);
 		pr_info("EMAC: MII PHY configured, RMII PHY will not be"
 							" functional\n");
+		emac_phy.rate = EMAC_MII_PHY_CLK_RATE;
 	}
 
 	if (ret)
 		pr_warning("da850_evm_init: cpgmac/rmii mux setup failed: %d\n",
 				ret);
 
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
+
 	/* configure the CFGCHIP3 register for RMII or MII */
 	__raw_writel(val, cfg_chip3_base);
 
diff --git a/arch/arm/mach-davinci/board-dm365-evm.c b/arch/arm/mach-davinci/board-dm365-evm.c
index d15bece..c36e034 100644
--- a/arch/arm/mach-davinci/board-dm365-evm.c
+++ b/arch/arm/mach-davinci/board-dm365-evm.c
@@ -38,9 +38,12 @@
 #include <mach/mmc.h>
 #include <mach/nand.h>
 #include <mach/keyscan.h>
+#include <mach/clock.h>
 
 #include <media/tvp514x.h>
 
+#include "clock.h"
+
 static inline int have_imager(void)
 {
 	/* REVISIT when it's supported, trigger via Kconfig */
@@ -566,11 +569,26 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
+#define EMAC_PHY_CLK_RATE	25000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init dm365_evm_map_io(void)
 {
 	/* setup input configuration for VPFE input devices */
 	dm365_set_vpfe_config(&vpfe_cfg);
 	dm365_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 static struct spi_eeprom at25640 = {
diff --git a/arch/arm/mach-davinci/board-dm644x-evm.c b/arch/arm/mach-davinci/board-dm644x-evm.c
index 976e11b..ba90181 100644
--- a/arch/arm/mach-davinci/board-dm644x-evm.c
+++ b/arch/arm/mach-davinci/board-dm644x-evm.c
@@ -37,6 +37,9 @@
 #include <mach/nand.h>
 #include <mach/mmc.h>
 #include <mach/usb.h>
+#include <mach/clock.h>
+
+#include "clock.h"
 
 #define DM644X_EVM_PHY_MASK		(0x2)
 #define DM644X_EVM_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
@@ -649,12 +652,27 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
+#define EMAC_PHY_CLK_RATE	25000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init
 davinci_evm_map_io(void)
 {
 	/* setup input configuration for VPFE input devices */
 	dm644x_set_vpfe_config(&vpfe_cfg);
 	dm644x_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 static int davinci_phy_fixup(struct phy_device *phydev)
diff --git a/arch/arm/mach-davinci/board-dm646x-evm.c b/arch/arm/mach-davinci/board-dm646x-evm.c
index 5ba3cb2..6241893 100644
--- a/arch/arm/mach-davinci/board-dm646x-evm.c
+++ b/arch/arm/mach-davinci/board-dm646x-evm.c
@@ -711,10 +711,25 @@ static void __init cdce_clk_init(void)
 	}
 }
 
+#define EMAC_PHY_CLK_RATE	25000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init davinci_map_io(void)
 {
 	dm646x_init();
 	cdce_clk_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 static struct davinci_uart_config uart_config __initdata = {
diff --git a/arch/arm/mach-davinci/board-neuros-osd2.c b/arch/arm/mach-davinci/board-neuros-osd2.c
index bd9ca07..075962c 100644
--- a/arch/arm/mach-davinci/board-neuros-osd2.c
+++ b/arch/arm/mach-davinci/board-neuros-osd2.c
@@ -26,6 +26,7 @@
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
 #include <linux/mtd/partitions.h>
+#include <linux/clk.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -37,6 +38,9 @@
 #include <mach/nand.h>
 #include <mach/mmc.h>
 #include <mach/usb.h>
+#include <mach/clock.h>
+
+#include "clock.h"
 
 #define NEUROS_OSD2_PHY_MASK		0x2
 #define NEUROS_OSD2_MDIO_FREQUENCY	2200000 /* PHY bus frequency */
@@ -188,9 +192,24 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
+#define EMAC_PHY_CLK_RATE	25000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init davinci_ntosd2_map_io(void)
 {
 	dm644x_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 /*
diff --git a/arch/arm/mach-davinci/board-sffsdr.c b/arch/arm/mach-davinci/board-sffsdr.c
index 08d373b..7faa6cf 100644
--- a/arch/arm/mach-davinci/board-sffsdr.c
+++ b/arch/arm/mach-davinci/board-sffsdr.c
@@ -30,6 +30,7 @@
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/nand.h>
 #include <linux/mtd/partitions.h>
+#include <linux/clk.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -41,6 +42,9 @@
 #include <mach/serial.h>
 #include <mach/mux.h>
 #include <mach/usb.h>
+#include <mach/clock.h>
+
+#include "clock.h"
 
 #define SFFSDR_PHY_MASK		(0x2)
 #define SFFSDR_MDIO_FREQUENCY	(2200000) /* PHY bus frequency */
@@ -133,9 +137,24 @@ static struct davinci_uart_config uart_config __initdata = {
 	.enabled_uarts = (1 << 0),
 };
 
+#define EMAC_PHY_CLK_RATE	25000000
+
+static struct clk emac_phy = {
+	.name	= "emac_phy",
+	.rate	= EMAC_PHY_CLK_RATE,
+};
+
+static struct clk_lookup emac_phy_clks[] = {
+	CLK("davinci_emac.1", "phy_clk", &emac_phy),
+	CLK(NULL, NULL, NULL),
+};
+
 static void __init davinci_sffsdr_map_io(void)
 {
 	dm644x_init();
+
+	clkdev_add(emac_phy_clks);
+	clk_register(&emac_phy);
 }
 
 static __init void davinci_sffsdr_init(void)
diff --git a/arch/arm/mach-davinci/da830.c b/arch/arm/mach-davinci/da830.c
index 122e61a..31903e2 100644
--- a/arch/arm/mach-davinci/da830.c
+++ b/arch/arm/mach-davinci/da830.c
@@ -414,7 +414,7 @@ static struct clk_lookup da830_clks[] = {
 	CLK(NULL,		"aemif",	&aemif_clk),
 	CLK(NULL,		"aintc",	&aintc_clk),
 	CLK(NULL,		"secu_mgr",	&secu_mgr_clk),
-	CLK("davinci_emac.1",	NULL,		&emac_clk),
+	CLK("davinci_emac.1",	"emac_clk",	&emac_clk),
 	CLK(NULL,		"gpio",		&gpio_clk),
 	CLK("i2c_davinci.2",	NULL,		&i2c1_clk),
 	CLK(NULL,		"usb11",	&usb11_clk),
diff --git a/arch/arm/mach-davinci/da850.c b/arch/arm/mach-davinci/da850.c
index d0fd756..4fd92d9 100644
--- a/arch/arm/mach-davinci/da850.c
+++ b/arch/arm/mach-davinci/da850.c
@@ -371,7 +371,7 @@ static struct clk_lookup da850_clks[] = {
 	CLK(NULL,		"emif3",	&emif3_clk),
 	CLK(NULL,		"arm",		&arm_clk),
 	CLK(NULL,		"rmii",		&rmii_clk),
-	CLK("davinci_emac.1",	NULL,		&emac_clk),
+	CLK("davinci_emac.1",	"emac_clk",	&emac_clk),
 	CLK("davinci-mcasp.0",	NULL,		&mcasp_clk),
 	CLK("da8xx_lcdc.0",	NULL,		&lcdc_clk),
 	CLK("davinci_mmc.0",	NULL,		&mmcsd_clk),
diff --git a/arch/arm/mach-davinci/dm365.c b/arch/arm/mach-davinci/dm365.c
index 27772e1..71f773c 100644
--- a/arch/arm/mach-davinci/dm365.c
+++ b/arch/arm/mach-davinci/dm365.c
@@ -457,7 +457,7 @@ static struct clk_lookup dm365_clks[] = {
 	CLK("watchdog", NULL, &timer2_clk),
 	CLK(NULL, "timer3", &timer3_clk),
 	CLK(NULL, "usb", &usb_clk),
-	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_emac.1", "emac_clk", &emac_clk),
 	CLK("davinci_voicecodec", NULL, &voicecodec_clk),
 	CLK("davinci-asp.0", NULL, &asp0_clk),
 	CLK(NULL, "rto", &rto_clk),
diff --git a/arch/arm/mach-davinci/dm644x.c b/arch/arm/mach-davinci/dm644x.c
index 2f2ae8b..70948d4 100644
--- a/arch/arm/mach-davinci/dm644x.c
+++ b/arch/arm/mach-davinci/dm644x.c
@@ -299,7 +299,7 @@ struct clk_lookup dm644x_clks[] = {
 	CLK(NULL, "uart0", &uart0_clk),
 	CLK(NULL, "uart1", &uart1_clk),
 	CLK(NULL, "uart2", &uart2_clk),
-	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_emac.1", "emac_clk", &emac_clk),
 	CLK("i2c_davinci.1", NULL, &i2c_clk),
 	CLK("palm_bk3710", NULL, &ide_clk),
 	CLK("davinci-asp", NULL, &asp_clk),
diff --git a/arch/arm/mach-davinci/dm646x.c b/arch/arm/mach-davinci/dm646x.c
index 893baf4..464cebc 100644
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -342,7 +342,7 @@ struct clk_lookup dm646x_clks[] = {
 	CLK("davinci-mcasp.0", NULL, &mcasp0_clk),
 	CLK("davinci-mcasp.1", NULL, &mcasp1_clk),
 	CLK(NULL, "aemif", &aemif_clk),
-	CLK("davinci_emac.1", NULL, &emac_clk),
+	CLK("davinci_emac.1", "emac_clk", &emac_clk),
 	CLK(NULL, "pwm0", &pwm0_clk),
 	CLK(NULL, "pwm1", &pwm1_clk),
 	CLK(NULL, "timer0", &timer0_clk),
-- 
1.6.2.4
