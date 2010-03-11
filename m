From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 2/4] AM35xx : Platform specific hookup for EMAC module
Date: Thu, 11 Mar 2010 20:43:40 +0530
Message-ID: <1268320422-32656-3-git-send-email-srk@ti.com>
References: <1268320422-32656-1-git-send-email-srk@ti.com>
 <1268320422-32656-2-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1268320422-32656-2-git-send-email-srk@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modified AM35xx EVM init sequence to handle EMAC
initialization.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 arch/arm/mach-omap2/board-am3517evm.c |   98 +++++++++++++++++++++++++++++++++
 1 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/board-am3517evm.c b/arch/arm/mach-omap2/board-am3517evm.c
index 6ae8805..a454995 100644
--- a/arch/arm/mach-omap2/board-am3517evm.c
+++ b/arch/arm/mach-omap2/board-am3517evm.c
@@ -21,6 +21,7 @@
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
 #include <linux/i2c/pca953x.h>
+#include <linux/davinci_emac.h>
 
 #include <mach/hardware.h>
 #include <mach/am35xx.h>
@@ -30,11 +31,106 @@
 
 #include <plat/board.h>
 #include <plat/common.h>
+#include <plat/control.h>
 #include <plat/usb.h>
 #include <plat/display.h>
 
 #include "mux.h"
 
+#define AM35XX_EVM_PHY_MASK		(0xF)
+#define AM35XX_EVM_MDIO_FREQUENCY	(1000000)
+
+static struct emac_platform_data am3517_evm_emac_pdata = {
+	.phy_mask	= AM35XX_EVM_PHY_MASK,
+	.mdio_max_freq	= AM35XX_EVM_MDIO_FREQUENCY,
+	.rmii_en	= 1,
+};
+
+static struct resource am3517_emac_resources[] = {
+	{
+		.start  = AM35XX_IPSS_EMAC_BASE,
+		.end    = AM35XX_IPSS_EMAC_BASE + 0x3FFFF,
+		.flags  = IORESOURCE_MEM,
+	},
+	{
+		.start  = INT_35XX_EMAC_C0_RXTHRESH_IRQ,
+		.end    = INT_35XX_EMAC_C0_RXTHRESH_IRQ,
+		.flags  = IORESOURCE_IRQ,
+	},
+	{
+		.start  = INT_35XX_EMAC_C0_RX_PULSE_IRQ,
+		.end    = INT_35XX_EMAC_C0_RX_PULSE_IRQ,
+		.flags  = IORESOURCE_IRQ,
+	},
+	{
+		.start  = INT_35XX_EMAC_C0_TX_PULSE_IRQ,
+		.end    = INT_35XX_EMAC_C0_TX_PULSE_IRQ,
+		.flags  = IORESOURCE_IRQ,
+	},
+	{
+		.start  = INT_35XX_EMAC_C0_MISC_PULSE_IRQ,
+		.end    = INT_35XX_EMAC_C0_MISC_PULSE_IRQ,
+		.flags  = IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device am3517_emac_device = {
+	.name		= "davinci_emac",
+	.id		= -1,
+	.num_resources	= ARRAY_SIZE(am3517_emac_resources),
+	.resource	= am3517_emac_resources,
+};
+
+static void am3517_enable_ethernet_int(void)
+{
+	u32 regval;
+
+	regval = omap_ctrl_readl(AM35XX_CONTROL_LVL_INTR_CLEAR);
+	regval = (regval | AM35XX_CPGMAC_C0_RX_PULSE_CLR |
+		AM35XX_CPGMAC_C0_TX_PULSE_CLR |
+		AM35XX_CPGMAC_C0_MISC_PULSE_CLR |
+		AM35XX_CPGMAC_C0_RX_THRESH_CLR);
+	omap_ctrl_writel(regval, AM35XX_CONTROL_LVL_INTR_CLEAR);
+	regval = omap_ctrl_readl(AM35XX_CONTROL_LVL_INTR_CLEAR);
+}
+
+static void am3517_disable_ethernet_int(void)
+{
+	u32 regval;
+
+	regval = omap_ctrl_readl(AM35XX_CONTROL_LVL_INTR_CLEAR);
+	regval = (regval | AM35XX_CPGMAC_C0_RX_PULSE_CLR |
+		AM35XX_CPGMAC_C0_TX_PULSE_CLR);
+	omap_ctrl_writel(regval, AM35XX_CONTROL_LVL_INTR_CLEAR);
+	regval = omap_ctrl_readl(AM35XX_CONTROL_LVL_INTR_CLEAR);
+}
+
+void am3517_evm_ethernet_init(struct emac_platform_data *pdata)
+{
+	unsigned int regval;
+
+	pdata->ctrl_reg_offset		= AM35XX_EMAC_CNTRL_OFFSET;
+	pdata->ctrl_mod_reg_offset	= AM35XX_EMAC_CNTRL_MOD_OFFSET;
+	pdata->ctrl_ram_offset		= AM35XX_EMAC_CNTRL_RAM_OFFSET;
+	pdata->mdio_reg_offset		= AM35XX_EMAC_MDIO_OFFSET;
+	pdata->ctrl_ram_size		= AM35XX_EMAC_CNTRL_RAM_SIZE;
+	pdata->version			= EMAC_VERSION_2;
+	pdata->hw_ram_addr		= AM35XX_EMAC_HW_RAM_ADDR;
+	pdata->interrupt_enable		= am3517_enable_ethernet_int;
+	pdata->interrupt_disable	= am3517_disable_ethernet_int;
+	am3517_emac_device.dev.platform_data	= pdata;
+	platform_device_register(&am3517_emac_device);
+
+	regval = omap_ctrl_readl(AM35XX_CONTROL_IP_SW_RESET);
+	regval = regval & (~(AM35XX_CPGMACSS_SW_RST));
+	omap_ctrl_writel(regval, AM35XX_CONTROL_IP_SW_RESET);
+	regval = omap_ctrl_readl(AM35XX_CONTROL_IP_SW_RESET);
+
+	return ;
+}
+
+
+
 #define LCD_PANEL_PWR		176
 #define LCD_PANEL_BKLIGHT_PWR	182
 #define LCD_PANEL_PWM		181
@@ -313,6 +409,8 @@ static void __init am3517_evm_init(void)
 
 	i2c_register_board_info(1, am3517evm_i2c_boardinfo,
 				ARRAY_SIZE(am3517evm_i2c_boardinfo));
+	/*Ethernet*/
+	am3517_evm_ethernet_init(&am3517_evm_emac_pdata);
 }
 
 static void __init am3517_evm_map_io(void)
-- 
1.6.2.4

