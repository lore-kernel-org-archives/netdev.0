From: <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Thu, 6 Feb 2014 17:19:54 -0600
Message-ID: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	"Rob Herring" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	"Kumar Gala" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>

Like the STi series SOCs, Altera's SOCFPGA also needs a glue layer on top of the
Synopsys gmac IP.

This patch adds the platform driver for the glue layer which configures the IP
before the generic STMMAC driver takes over.

Signed-off-by: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Cc: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
v2: Use the dwmac-sti as an example for a glue layer and split patch up
to have dts as a separate patch. Also cc dts maintainers since there is
a new binding.
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  184 ++++++++++++++++++++
 2 files changed, 185 insertions(+)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index ecadece..73df8b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
+stmmac-$(CONFIG_ARCH_SOCFPGA) += dwmac-socfpga.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
new file mode 100644
index 0000000..0a6da3e
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -0,0 +1,184 @@
+/*  Copyright (C) 2014 Altera Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * Adopted from dwmac-sti.c
+ */
+
+#include <linux/clk.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/stmmac.h>
+
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII 0x0
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII 0x1
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH 2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK 0x00000003
+
+struct socfpga_dwmac {
+	int	interface;
+	u32	reg_offset;
+	struct	device *dev;
+	struct regmap *sys_mgr_base_addr;
+	struct	device_node *dwmac_np;
+};
+
+static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *dev)
+{
+	struct device_node *np	= dev->of_node;
+	struct device_node *stmmac_np;
+	struct regmap *sys_mgr_base_addr;
+	u32 reg_offset;
+	int ret;
+
+	stmmac_np = of_get_next_available_child(np, NULL);
+	if (!stmmac_np) {
+		dev_info(dev, "No dwmac node found\n");
+		return -EINVAL;
+	}
+
+	if (!of_device_is_compatible(stmmac_np, "snps,dwmac")) {
+		dev_info(dev, "dwmac node isn't compatible with snps,dwmac\n");
+		return -EINVAL;
+	}
+
+	dwmac->interface = of_get_phy_mode(stmmac_np);
+	of_node_put(stmmac_np);
+
+	sys_mgr_base_addr = syscon_regmap_lookup_by_phandle(np, "altr,sysmgr-syscon");
+	if (IS_ERR(sys_mgr_base_addr)) {
+		dev_info(dev, "No sysmgr-syscon node found\n");
+		return PTR_ERR(sys_mgr_base_addr);
+	}
+
+	ret = of_property_read_u32_index(np, "altr,sysmgr-syscon", 1, &reg_offset);
+	if (ret) {
+		dev_info(dev, "Could not reg_offset into sysmgr-syscon!\n");
+		return -EINVAL;
+	}
+
+	dwmac->reg_offset = reg_offset;
+	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
+	dwmac->dwmac_np = stmmac_np;
+	dwmac->dev = dev;
+
+	return 0;
+}
+
+static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
+{
+	struct regmap *sys_mgr_base_addr = dwmac->sys_mgr_base_addr;
+	int phymode = dwmac->interface;
+	u32 reg_offset = dwmac->reg_offset;
+	u32 ctrl, val, shift = 0;
+
+	if (of_machine_is_compatible("altr,socfpga-vt"))
+		return 0;
+
+	switch (phymode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII;
+		break;
+	case PHY_INTERFACE_MODE_MII:
+	case PHY_INTERFACE_MODE_GMII:
+		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
+		break;
+	default:
+		dev_err(dwmac->dev, "bad phy mode %d\n", phymode);
+		return -EINVAL;
+	}
+
+	regmap_read(sys_mgr_base_addr, reg_offset, &ctrl);
+	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << shift);
+	ctrl |= val << shift;
+
+	regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
+	return 0;
+}
+
+static int socfpga_dwmac_probe(struct platform_device *pdev)
+{
+	struct device		*dev = &pdev->dev;
+	struct device_node	*node = dev->of_node;
+	int			ret = -ENOMEM;
+	struct socfpga_dwmac	*dwmac;
+
+	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return -ENOMEM;
+
+	ret = socfpga_dwmac_parse_data(dwmac, dev);
+	if (ret) {
+		dev_err(dev, "Unable to parse OF data\n");
+		return ret;
+	}
+
+	ret = socfpga_dwmac_setup(dwmac);
+	if (ret) {
+		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
+		return ret;
+	}
+
+	if (node) {
+		ret = of_platform_populate(node, NULL, NULL, dev);
+		if (ret) {
+			dev_err(dev, "failed to add dwmac core\n");
+			return ret;
+		}
+	} else {
+		dev_err(dev, "no device node, failed to add dwmac core\n");
+		return -ENODEV;
+	}
+
+	platform_set_drvdata(pdev, dwmac);
+
+	return 0;
+}
+
+static int socfpga_dwmac_remove(struct platform_device *pdev)
+{
+	return 0;
+}
+
+static const struct of_device_id socfpga_dwmac_match[] = {
+	{ .compatible = "altr,socfpga-stmmac" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, socfpga_dwmac_match);
+
+static struct platform_driver socfpga_dwmac_driver = {
+	.probe		= socfpga_dwmac_probe,
+	.remove		= socfpga_dwmac_remove,
+	.driver		= {
+		.name	= "socfpga-dwmac",
+		.of_match_table = of_match_ptr(socfpga_dwmac_match),
+	},
+};
+
+module_platform_driver(socfpga_dwmac_driver);
+
+MODULE_ALIAS("platform:socfpga-dwmac");
+MODULE_AUTHOR("Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("Altera SOCFPGA DWMAC Glue Layer");
+
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
