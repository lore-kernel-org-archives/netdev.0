From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v6 1/7] net: mvmdio: new Marvell MDIO driver
Date: Tue, 13 Nov 2012 16:00:37 +0100
Message-ID: <1352818843-4457-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:49756 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab2KMPCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 10:02:30 -0500
In-Reply-To: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a separate driver for the MDIO interface of the
Marvell Ethernet controllers. There are two reasons to have a separate
driver rather than including it inside the MAC driver itself:

 *) The MDIO interface is shared by all Ethernet ports, so a driver
    must guarantee non-concurrent accesses to this MDIO interface. The
    most logical way is to have a separate driver that handles this
    single MDIO interface, used by all Ethernet ports.

 *) The MDIO interface is the same between the existing mv643xx_eth
    driver and the new mvneta driver. Even though it is for now only
    used by the mvneta driver, it will in the future be used by the
    mv643xx_eth driver as well.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-orion-mdio.txt |   35 +++
 drivers/net/ethernet/marvell/Kconfig               |   11 +
 drivers/net/ethernet/marvell/Makefile              |    1 +
 drivers/net/ethernet/marvell/mvmdio.c              |  230 ++++++++++++++++++++
 4 files changed, 277 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
 create mode 100644 drivers/net/ethernet/marvell/mvmdio.c

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
new file mode 100644
index 0000000..34e7aaf
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -0,0 +1,35 @@
+* Marvell MDIO Ethernet Controller interface
+
+The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
+MV78xx0, Armada 370 and Armada XP have an identical unit that provides
+an interface with the MDIO bus. This driver handles this MDIO
+interface.
+
+Required properties:
+- compatible: "marvell,orion-mdio"
+- reg: address and length of the SMI register
+
+The child nodes of the MDIO driver are the individual PHY devices
+connected to this MDIO bus. They must have a "reg" property given the
+PHY address on the MDIO bus.
+
+Example at the SoC level:
+
+mdio {
+	#address-cells = <1>;
+	#size-cells = <0>;
+	compatible = "marvell,orion-mdio";
+	reg = <0xd0072004 0x4>;
+};
+
+And at the board level:
+
+mdio {
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+}
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 0029934..232ccb3 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -31,6 +31,17 @@ config MV643XX_ETH
 	  Some boards that use the Discovery chipset are the Momenco
 	  Ocelot C and Jaguar ATX and Pegasos II.
 
+config MVMDIO
+	tristate "Marvell MDIO interface support"
+	---help---
+	  This driver supports the MDIO interface found in the network
+	  interface units of the Marvell EBU SoCs (Kirkwood, Orion5x,
+	  Dove, Armada 370 and Armada XP).
+
+	  For now, this driver is only needed for the MVNETA driver
+	  (used on Armada 370 and XP), but it could be used in the
+	  future by the MV643XX_ETH driver.
+
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
 	depends on CPU_PXA168
diff --git a/drivers/net/ethernet/marvell/Makefile b/drivers/net/ethernet/marvell/Makefile
index 57e3234..0438599 100644
--- a/drivers/net/ethernet/marvell/Makefile
+++ b/drivers/net/ethernet/marvell/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
+obj-$(CONFIG_MVMDIO) += mvmdio.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_SKGE) += skge.o
 obj-$(CONFIG_SKY2) += sky2.o
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
new file mode 100644
index 0000000..82fbd23
--- /dev/null
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -0,0 +1,230 @@
+/*
+ * Driver for the MDIO interface of Marvell network interfaces.
+ *
+ * Since the MDIO interface of Marvell network interfaces is shared
+ * between all network interfaces, having a single driver allows to
+ * handle concurrent accesses properly (you may have four Ethernet
+ * ports, but they in fact share the same SMI interface to access the
+ * MDIO bus). Moreover, this MDIO interface code is similar between
+ * the mv643xx_eth driver and the mvneta driver. For now, it is only
+ * used by the mvneta driver, but it could later be used by the
+ * mv643xx_eth driver as well.
+ *
+ * Copyright (C) 2012 Marvell
+ *
+ * Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/phy.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/platform_device.h>
+
+#include <asm/delay.h>
+
+#define MVMDIO_SMI_DATA_SHIFT              0
+#define MVMDIO_SMI_PHY_ADDR_SHIFT          16
+#define MVMDIO_SMI_PHY_REG_SHIFT           21
+#define MVMDIO_SMI_READ_OPERATION          BIT(26)
+#define MVMDIO_SMI_WRITE_OPERATION         0
+#define MVMDIO_SMI_READ_VALID              BIT(27)
+#define MVMDIO_SMI_BUSY                    BIT(28)
+
+struct orion_mdio_dev {
+	struct mutex lock;
+	void __iomem *smireg;
+};
+
+/*
+ * Wait for the SMI unit to be ready for another operation
+ */
+static int orion_mdio_wait_ready(struct mii_bus *bus)
+{
+	struct orion_mdio_dev *dev = bus->priv;
+	int count;
+	u32 val;
+
+	count = 0;
+	while (1) {
+		val = readl(dev->smireg);
+		if (!(val & MVMDIO_SMI_BUSY))
+			break;
+
+		if (count > 100) {
+			dev_err(bus->parent, "Timeout: SMI busy for too long\n");
+			return -ETIMEDOUT;
+		}
+
+		udelay(10);
+		count++;
+	}
+
+	return 0;
+}
+
+static int orion_mdio_read(struct mii_bus *bus, int mii_id,
+			   int regnum)
+{
+	struct orion_mdio_dev *dev = bus->priv;
+	int count;
+	u32 val;
+	int ret;
+
+	mutex_lock(&dev->lock);
+
+	ret = orion_mdio_wait_ready(bus);
+	if (ret < 0) {
+		mutex_unlock(&dev->lock);
+		return ret;
+	}
+
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_READ_OPERATION),
+	       dev->smireg);
+
+	/* Wait for the value to become available */
+	count = 0;
+	while (1) {
+		val = readl(dev->smireg);
+		if (val & MVMDIO_SMI_READ_VALID)
+			break;
+
+		if (count > 100) {
+			dev_err(bus->parent, "Timeout when reading PHY\n");
+			mutex_unlock(&dev->lock);
+			return -ETIMEDOUT;
+		}
+
+		udelay(10);
+		count++;
+	}
+
+	mutex_unlock(&dev->lock);
+
+	return val & 0xFFFF;
+}
+
+static int orion_mdio_write(struct mii_bus *bus, int mii_id,
+			    int regnum, u16 value)
+{
+	struct orion_mdio_dev *dev = bus->priv;
+	int ret;
+
+	mutex_lock(&dev->lock);
+
+	ret = orion_mdio_wait_ready(bus);
+	if (ret < 0) {
+		mutex_unlock(&dev->lock);
+		return ret;
+	}
+
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_WRITE_OPERATION            |
+		(value << MVMDIO_SMI_DATA_SHIFT)),
+	       dev->smireg);
+
+	mutex_unlock(&dev->lock);
+
+	return 0;
+}
+
+static int orion_mdio_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+static int __devinit orion_mdio_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mii_bus *bus;
+	struct orion_mdio_dev *dev;
+	int i, ret;
+
+	bus = mdiobus_alloc_size(sizeof(struct orion_mdio_dev));
+	if (!bus) {
+		dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
+		return -ENOMEM;
+	}
+
+	bus->name = "orion_mdio_bus";
+	bus->read = orion_mdio_read;
+	bus->write = orion_mdio_write;
+	bus->reset = orion_mdio_reset;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii",
+		 dev_name(&pdev->dev));
+	bus->parent = &pdev->dev;
+
+	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bus->irq) {
+		dev_err(&pdev->dev, "Cannot allocate PHY IRQ array\n");
+		mdiobus_free(bus);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	dev = bus->priv;
+	dev->smireg = of_iomap(pdev->dev.of_node, 0);
+	if (!dev->smireg) {
+		dev_err(&pdev->dev, "No SMI register address given in DT\n");
+		kfree(bus->irq);
+		mdiobus_free(bus);
+		return -ENODEV;
+	}
+
+	mutex_init(&dev->lock);
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
+		iounmap(dev->smireg);
+		kfree(bus->irq);
+		mdiobus_free(bus);
+		return ret;
+	}
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+}
+
+static int __devexit orion_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	mdiobus_unregister(bus);
+	kfree(bus->irq);
+	mdiobus_free(bus);
+	return 0;
+}
+
+static const struct of_device_id orion_mdio_match[] = {
+	{ .compatible = "marvell,orion-mdio" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, orion_mdio_match);
+
+static struct platform_driver orion_mdio_driver = {
+	.probe = orion_mdio_probe,
+	.remove = __devexit_p(orion_mdio_remove),
+	.driver = {
+		.name = "orion-mdio",
+		.of_match_table = orion_mdio_match,
+	},
+};
+
+module_platform_driver(orion_mdio_driver);
+
+MODULE_DESCRIPTION("Marvell MDIO interface driver");
+MODULE_AUTHOR("Thomas Petazzoni <thomas.petazzoni@free-electrons.com>");
+MODULE_LICENSE("GPL");
-- 
1.7.9.5
