From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v1 1/3] net: Add MDIO bus driver for the Hisilicon FEMAC
Date: Fri, 15 Jul 2016 16:26:33 +0800
Message-ID: <1468571195-59763-2-git-send-email-lidongpo@hisilicon.com>
References: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dongpo Li <lidongpo@hisilicon.com>
To: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <frowand.list@gmail.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a separate driver for the MDIO interface of the
Hisilicon Fast Ethernet MAC.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 .../bindings/net/hisilicon-femac-mdio.txt          |  22 +++
 drivers/net/phy/Kconfig                            |   7 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-hisi-femac.c                  | 166 +++++++++++++++++++++
 4 files changed, 196 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
 create mode 100644 drivers/net/phy/mdio-hisi-femac.c

diff --git a/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
new file mode 100644
index 0000000..6f46337
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
@@ -0,0 +1,22 @@
+Hisilicon Fast Ethernet MDIO Controller interface
+
+Required properties:
+- compatible: should be "hisilicon,hisi-femac-mdio".
+- reg: address and length of the register set for the device.
+- clocks: A phandle to the reference clock for this device.
+
+- PHY subnode: inherits from phy binding [1]
+[1] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+mdio: mdio@10091100 {
+	compatible = "hisilicon,hisi-femac-mdio";
+	reg = <0x10091100 0x10>;
+	clocks = <&crg HI3516CV300_MDIO_CLK>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy0: phy@1 {
+		reg = <1>;
+	};
+};
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..3353bde 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -271,6 +271,13 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config MDIO_HISI_FEMAC
+	tristate "Hisilicon FEMAC MDIO bus controller"
+	depends on HAS_IOMEM && OF_MDIO
+	help
+	  This module provides a driver for the MDIO busses found in the
+	  Hisilicon SoC that have an Fast Ethernet MAC.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcdbb92..039c4be 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
diff --git a/drivers/net/phy/mdio-hisi-femac.c b/drivers/net/phy/mdio-hisi-femac.c
new file mode 100644
index 0000000..b03fedd
--- /dev/null
+++ b/drivers/net/phy/mdio-hisi-femac.c
@@ -0,0 +1,166 @@
+/*
+ * Hisilicon Fast Ethernet MDIO Bus Driver
+ *
+ * Copyright (c) 2016 HiSilicon Technologies Co., Ltd.
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
+ * along with this program. If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/clk.h>
+#include <linux/iopoll.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/platform_device.h>
+
+#define MDIO_RWCTRL		0x00
+#define MDIO_RO_DATA		0x04
+#define MDIO_WRITE		BIT(13)
+#define MDIO_RW_FINISH		BIT(15)
+#define BIT_PHY_ADDR_OFFSET	8
+#define BIT_WR_DATA_OFFSET	16
+
+struct hisi_femac_mdio_data {
+	struct clk *clk;
+	void __iomem *membase;
+};
+
+static int hisi_femac_mdio_wait_ready(struct hisi_femac_mdio_data *data)
+{
+	u32 val;
+
+	return readl_poll_timeout(data->membase + MDIO_RWCTRL,
+				  val, val & MDIO_RW_FINISH, 20, 10000);
+}
+
+static int hisi_femac_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct hisi_femac_mdio_data *data = bus->priv;
+	int ret;
+
+	ret = hisi_femac_mdio_wait_ready(data);
+	if (ret)
+		return ret;
+
+	writel((mii_id << BIT_PHY_ADDR_OFFSET) | regnum,
+	       data->membase + MDIO_RWCTRL);
+
+	ret = hisi_femac_mdio_wait_ready(data);
+	if (ret)
+		return ret;
+
+	return readl(data->membase + MDIO_RO_DATA) & 0xFFFF;
+}
+
+static int hisi_femac_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+				 u16 value)
+{
+	struct hisi_femac_mdio_data *data = bus->priv;
+	int ret;
+
+	ret = hisi_femac_mdio_wait_ready(data);
+	if (ret)
+		return ret;
+
+	writel(MDIO_WRITE | (value << BIT_WR_DATA_OFFSET) |
+	       (mii_id << BIT_PHY_ADDR_OFFSET) | regnum,
+	       data->membase + MDIO_RWCTRL);
+
+	return hisi_femac_mdio_wait_ready(data);
+}
+
+static int hisi_femac_mdio_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mii_bus *bus;
+	struct hisi_femac_mdio_data *data;
+	struct resource *res;
+	int ret;
+
+	bus = mdiobus_alloc_size(sizeof(*data));
+	if (!bus)
+		return -ENOMEM;
+
+	bus->name = "hisi_femac_mii_bus";
+	bus->read = &hisi_femac_mdio_read;
+	bus->write = &hisi_femac_mdio_write;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	bus->parent = &pdev->dev;
+
+	data = bus->priv;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	data->membase = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(data->membase)) {
+		ret = PTR_ERR(data->membase);
+		goto err_out_free_mdiobus;
+	}
+
+	data->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(data->clk)) {
+		ret = PTR_ERR(data->clk);
+		goto err_out_free_mdiobus;
+	}
+
+	ret = clk_prepare_enable(data->clk);
+	if (ret)
+		goto err_out_free_mdiobus;
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret)
+		goto err_out_disable_clk;
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+
+err_out_disable_clk:
+	clk_disable_unprepare(data->clk);
+err_out_free_mdiobus:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int hisi_femac_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	struct hisi_femac_mdio_data *data = bus->priv;
+
+	mdiobus_unregister(bus);
+	clk_disable_unprepare(data->clk);
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static const struct of_device_id hisi_femac_mdio_dt_ids[] = {
+	{ .compatible = "hisilicon,hisi-femac-mdio" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, hisi_femac_mdio_dt_ids);
+
+static struct platform_driver hisi_femac_mdio_driver = {
+	.probe = hisi_femac_mdio_probe,
+	.remove = hisi_femac_mdio_remove,
+	.driver = {
+		.name = "hisi-femac-mdio",
+		.of_match_table = hisi_femac_mdio_dt_ids,
+	},
+};
+
+module_platform_driver(hisi_femac_mdio_driver);
+
+MODULE_DESCRIPTION("Hisilicon Fast Ethernet MAC MDIO interface driver");
+MODULE_AUTHOR("Dongpo Li <lidongpo@hisilicon.com>");
+MODULE_LICENSE("GPL v2");
-- 
2.8.2
