From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv3 2/6] net: Add MDIO bus driver for the Allwinner EMAC
Date: Fri, 24 May 2013 11:23:10 +0200
Message-ID: <1369387394-9453-3-git-send-email-maxime.ripard@free-electrons.com>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a separate driver for the MDIO interface of the
Allwinner ethernet controllers.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 .../bindings/net/allwinner,sun4i-mdio.txt          |  26 +++
 drivers/net/ethernet/allwinner/Kconfig             |   8 +
 drivers/net/ethernet/allwinner/Makefile            |   1 +
 drivers/net/ethernet/allwinner/sun4i-mdio.c        | 191 +++++++++++++++++++++
 4 files changed, 226 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
 create mode 100644 drivers/net/ethernet/allwinner/sun4i-mdio.c

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt b/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
new file mode 100644
index 0000000..00b9f9a
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
@@ -0,0 +1,26 @@
+* Allwinner A10 MDIO Ethernet Controller interface
+
+Required properties:
+- compatible: should be "allwinner,sun4i-mdio".
+- reg: address and length of the register set for the device.
+
+Optional properties:
+- phy-supply: phandle to a regulator if the PHY needs one
+
+Example at the SoC level:
+mdio@01c0b080 {
+	compatible = "allwinner,sun4i-mdio";
+	reg = <0x01c0b080 0x14>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+};
+
+And at the board level:
+
+mdio@01c0b080 {
+	phy-supply = <&reg_emac_3v3>;
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
index 4220c9a..848b27a 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -27,10 +27,18 @@ config SUN4I_EMAC
 	select NET_CORE
 	select MII
 	select REGULATOR_FIXED_VOLTAGE
+	select PHYLIB
         ---help---
           Support for Allwinner A10 EMAC ethernet driver.
 
           To compile this driver as a module, choose M here.  The module
           will be called sun4i-emac.
 
+config SUN4I_MDIO
+	tristate "Allwinner sun4i MDIO interface support"
+	---help---
+	  This driver supports the MDIO interface found in the network
+	  interface units of the Allwinner SoC that have an EMAC (A10,
+	  A12, A10s, etc.)
+
 endif # NET_VENDOR_ALLWINNER
diff --git a/drivers/net/ethernet/allwinner/Makefile b/drivers/net/ethernet/allwinner/Makefile
index 03129f7..95eaa31 100644
--- a/drivers/net/ethernet/allwinner/Makefile
+++ b/drivers/net/ethernet/allwinner/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_SUN4I_EMAC) += sun4i-emac.o
+obj-$(CONFIG_SUN4I_MDIO) += sun4i-mdio.o
\ No newline at end of file
diff --git a/drivers/net/ethernet/allwinner/sun4i-mdio.c b/drivers/net/ethernet/allwinner/sun4i-mdio.c
new file mode 100644
index 0000000..00e432c
--- /dev/null
+++ b/drivers/net/ethernet/allwinner/sun4i-mdio.c
@@ -0,0 +1,191 @@
+/*
+ * Allwinner EMAC MDIO interface driver
+ *
+ * Copyright 2012-2013 Stefan Roese <sr@denx.de>
+ * Copyright 2013 Maxime Ripard <maxime.ripard@free-electrons.com>
+ *
+ * Based on the Linux driver provided by Allwinner:
+ * Copyright (C) 1997  Sten Wang
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/delay.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/regulator/consumer.h>
+
+#define EMAC_MAC_MCMD_REG	(0x00)
+#define EMAC_MAC_MADR_REG	(0x04)
+#define EMAC_MAC_MWTD_REG	(0x08)
+#define EMAC_MAC_MRDD_REG	(0x0c)
+#define EMAC_MAC_MIND_REG	(0x10)
+#define EMAC_MAC_SSRR_REG	(0x14)
+
+#define MDIO_TIMEOUT		(msecs_to_jiffies(100))
+
+struct sun4i_mdio_data {
+	void __iomem		*membase;
+	struct regulator	*regulator;
+};
+
+static int sun4i_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct sun4i_mdio_data *data = bus->priv;
+	unsigned long start_jiffies;
+	int value;
+
+	/* issue the phy address and reg */
+	writel((mii_id << 8) | regnum, data->membase + EMAC_MAC_MADR_REG);
+	/* pull up the phy io line */
+	writel(0x1, data->membase + EMAC_MAC_MCMD_REG);
+
+	/* Wait read complete */
+	start_jiffies = jiffies;
+	while (readl(data->membase + EMAC_MAC_MIND_REG) & 0x1) {
+		if (time_after(start_jiffies,
+			       start_jiffies + MDIO_TIMEOUT))
+			return -ETIMEDOUT;
+		msleep(1);
+	}
+
+	/* push down the phy io line */
+	writel(0x0, data->membase + EMAC_MAC_MCMD_REG);
+	/* and read data */
+	value = readl(data->membase + EMAC_MAC_MRDD_REG);
+
+	return value;
+}
+
+static int sun4i_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+			    u16 value)
+{
+	struct sun4i_mdio_data *data = bus->priv;
+	unsigned long start_jiffies;
+
+	/* issue the phy address and reg */
+	writel((mii_id << 8) | regnum, data->membase + EMAC_MAC_MADR_REG);
+	/* pull up the phy io line */
+	writel(0x1, data->membase + EMAC_MAC_MCMD_REG);
+
+	/* Wait read complete */
+	start_jiffies = jiffies;
+	while (readl(data->membase + EMAC_MAC_MIND_REG) & 0x1) {
+		if (time_after(start_jiffies,
+			       start_jiffies + MDIO_TIMEOUT))
+			return -ETIMEDOUT;
+		msleep(1);
+	}
+
+	/* push down the phy io line */
+	writel(0x0, data->membase + EMAC_MAC_MCMD_REG);
+	/* and write data */
+	writel(value, data->membase + EMAC_MAC_MWTD_REG);
+
+	return 0;
+}
+
+static int sun4i_mdio_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+static int sun4i_mdio_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mii_bus *bus;
+	struct sun4i_mdio_data *data;
+	int ret, i;
+
+	bus = mdiobus_alloc_size(sizeof(*data));
+	if (!bus)
+		return -ENOMEM;
+
+	bus->name = "sun4i_mii_bus";
+	bus->read = &sun4i_mdio_read;
+	bus->write = &sun4i_mdio_write;
+	bus->reset = &sun4i_mdio_reset;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
+	bus->parent = &pdev->dev;
+
+	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bus->irq) {
+		ret = -ENOMEM;
+		goto err_out_free_mdiobus;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	data = bus->priv;
+	data->membase = of_iomap(np, 0);
+	if (!data->membase) {
+		ret = -ENOMEM;
+		goto err_out_free_mdio_irq;
+	}
+
+	data->regulator = devm_regulator_get(&pdev->dev, "phy");
+	if (IS_ERR(data->regulator)) {
+		if (PTR_ERR(data->regulator) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+
+		dev_info(&pdev->dev, "no regulator found\n");
+	} else
+		regulator_enable(data->regulator);
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret < 0)
+		goto err_out_disable_regulator;
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+
+err_out_disable_regulator:
+	regulator_disable(data->regulator);
+err_out_free_mdio_irq:
+	kfree(bus->irq);
+err_out_free_mdiobus:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int sun4i_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+
+	mdiobus_unregister(bus);
+	kfree(bus->irq);
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static const struct of_device_id sun4i_mdio_dt_ids[] = {
+	{ .compatible = "allwinner,sun4i-mdio" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, sun4i_mdio_dt_ids);
+
+static struct platform_driver sun4i_mdio_driver = {
+	.probe = sun4i_mdio_probe,
+	.remove = sun4i_mdio_remove,
+	.driver = {
+		.name = "sun4i-mdio",
+		.of_match_table = sun4i_mdio_dt_ids,
+	},
+};
+
+module_platform_driver(sun4i_mdio_driver);
+
+MODULE_DESCRIPTION("Allwinner EMAC MDIO interface driver");
+MODULE_AUTHOR("Maxime Ripard <maxime.ripard@free-electrons.com>");
+MODULE_LICENSE("GPL");
-- 
1.8.1.2
