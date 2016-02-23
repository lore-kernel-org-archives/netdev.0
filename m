From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v2 1/4] net: ethernet: dwmac: add Ethernet glue logic for
 stm32 chip
Date: Tue, 23 Feb 2016 16:10:41 +0100
Message-ID: <1456240244-10275-2-git-send-email-alexandre.torgue@gmail.com>
References: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

stm324xx family chips support Synopsys MAC 3.510 IP.
This patch adds settings for logical glue logic:
-clocks
-mode selection MII or RMII.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index cec147d..f63bdcf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -114,6 +114,18 @@ config DWMAC_SUNXI
 	  This selects Allwinner SoC glue layer support for the
 	  stmmac device driver. This driver is used for A20/A31
 	  GMAC ethernet controller.
+
+config DWMAC_STM32
+	tristate "STM32 DWMAC support"
+	default ARCH_STM32
+	depends on OF && HAS_IOMEM
+	select MFD_SYSCON
+	---help---
+	  Support for ethernet controller on STM32 SOCs.
+
+	  This selects STM32 SoC glue layer support for the stmmac
+	  device driver. This driver is used on for the STM32 series
+	  SOCs GMAC ethernet controller.
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index b390161..559086d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
 obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
+obj-$(CONFIG_DWMAC_STM32)	+= dwmac-stm32.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
new file mode 100644
index 0000000..0b48ee7
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
@@ -0,0 +1,208 @@
+/*
+ * dwmac-stm32.c - DWMAC Specific Glue layer for STM32 MCU
+ *
+ * Copyright (C) Alexandre Torgue 2015
+ * Author:  Alexandre Torgue <alexandre.torgue@gmail.com>
+ * License terms:  GNU General Public License (GPL), version 2
+ *
+ */
+
+#include <linux/clk.h>
+#include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/slab.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
+
+#define MII_PHY_SEL_MASK	BIT(23)
+
+struct stm32_dwmac {
+	int interface;		/* MII interface */
+	struct clk *clk_tx;
+	struct clk *clk_rx;
+	u32 mode_reg;		/* MAC glue-logic mode register */
+	struct regmap *regmap;
+	u32 speed;
+};
+
+static int stm32_dwmac_init(void *priv)
+{
+	struct stm32_dwmac *dwmac = priv;
+	struct regmap *regmap = dwmac->regmap;
+	int ret, iface = dwmac->interface;
+	u32 reg = dwmac->mode_reg;
+	u32 val;
+
+	ret = clk_prepare_enable(dwmac->clk_tx);
+	if (ret)
+		goto out;
+
+	ret = clk_prepare_enable(dwmac->clk_rx);
+	if (ret)
+		goto out_disable_clk_tx;
+
+	val = (iface == PHY_INTERFACE_MODE_MII) ? 0 : 1;
+	ret = regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK, val);
+	if (ret)
+		goto out_disable_clk_tx_rx;
+
+	return 0;
+
+out_disable_clk_tx_rx:
+	clk_disable_unprepare(dwmac->clk_rx);
+out_disable_clk_tx:
+	clk_disable_unprepare(dwmac->clk_tx);
+out:
+	return ret;
+}
+
+static void stm32_dwmac_exit(void *priv)
+{
+	struct stm32_dwmac *dwmac = priv;
+
+	clk_disable_unprepare(dwmac->clk_tx);
+	clk_disable_unprepare(dwmac->clk_rx);
+}
+
+static int stm32_dwmac_parse_data(struct stm32_dwmac *dwmac,
+				  struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct device_node *np = dev->of_node;
+	struct regmap *regmap;
+	int err;
+
+	/*  Get TX/RX clocks */
+	dwmac->clk_tx = devm_clk_get(dev, "tx-clk");
+	if (IS_ERR(dwmac->clk_tx)) {
+		dev_warn(dev, "No tx clock provided...\n");
+		dwmac->clk_tx = NULL;
+	}
+	dwmac->clk_rx = devm_clk_get(dev, "rx-clk");
+	if (IS_ERR(dwmac->clk_rx)) {
+		dev_warn(dev, "No rx clock provided...\n");
+		dwmac->clk_rx = NULL;
+	}
+
+	/* Get mode register */
+	regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
+	if (IS_ERR(regmap))
+		return PTR_ERR(regmap);
+
+	err = of_property_read_u32_index(np, "st,syscon", 1, &dwmac->mode_reg);
+	if (err) {
+		dev_err(dev, "Can't get sysconfig mode offset (%d)\n", err);
+		return err;
+	}
+
+	dwmac->interface = of_get_phy_mode(np);
+	dwmac->regmap = regmap;
+
+	return 0;
+}
+
+static int stm32_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	struct stm32_dwmac *dwmac;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
+	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return -ENOMEM;
+
+	ret = stm32_dwmac_parse_data(dwmac, pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Unable to parse OF data\n");
+		return ret;
+	}
+
+	plat_dat->bsp_priv = dwmac;
+
+	ret = stm32_dwmac_init(plat_dat->bsp_priv);
+	if (ret)
+		return ret;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
+
+static int stm32_dwmac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret = stmmac_dvr_remove(ndev);
+
+	stm32_dwmac_exit(priv->plat->bsp_priv);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int stm32_dwmac_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = stmmac_suspend(ndev);
+	stm32_dwmac_exit(priv->plat->bsp_priv);
+
+	return ret;
+}
+
+static int stm32_dwmac_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = stm32_dwmac_init(priv->plat->bsp_priv);
+	if (ret)
+		goto out_regmap;
+
+	ret = stmmac_resume(ndev);
+
+out_regmap:
+	return ret;
+}
+#endif /* CONFIG_PM_SLEEP */
+
+SIMPLE_DEV_PM_OPS(stm32_dwmac_pm_ops, stm32_dwmac_suspend, stm32_dwmac_resume);
+
+static const struct of_device_id stm32_dwmac_match[] = {
+	{ .compatible = "st,stm32-dwmac"},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, stm32_dwmac_match);
+
+static struct platform_driver stm32_dwmac_driver = {
+	.probe  = stm32_dwmac_probe,
+	.remove = stm32_dwmac_remove,
+	.driver = {
+		.name           = "stm32-dwmac",
+		.pm		= &stm32_dwmac_pm_ops,
+		.of_match_table = stm32_dwmac_match,
+	},
+};
+module_platform_driver(stm32_dwmac_driver);
+
+MODULE_AUTHOR("Alexandre Torgue <alexandre.torgue@gmail.com>");
+MODULE_DESCRIPTION("STMicroelectronics MCU DWMAC Specific Glue layer");
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
