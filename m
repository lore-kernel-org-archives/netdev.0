From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 6/6] net:phy: Add Ethernet Master for iProc Shared MDIO
 Controller
Date: Thu, 21 Apr 2016 14:48:43 +0530
Message-ID: <1461230323-27891-7-git-send-email-pramod.kumar@broadcom.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Suzuki K Poulose <suzuki.poulose@arm.com>, netdev@vger.kernel.org,
 Punit Agrawal <punit.agrawal@arm.com>, linux-kernel@vger.kernel.org,
 Pramod Kumar <pramod.kumar@broadcom.com>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh+dt@kernel.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
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

Add Ethernet master driver which registers the ethernet phy
to standard legacy mdio framework.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
---
 drivers/net/phy/Kconfig                 |  11 +++
 drivers/net/phy/Makefile                |   1 +
 drivers/net/phy/mdio-bcm-iproc-shared.c | 116 ++++++++++++++++++++++++++++++++
 3 files changed, 128 insertions(+)
 create mode 100644 drivers/net/phy/mdio-bcm-iproc-shared.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..35a7d59 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -271,6 +271,17 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config MDIO_BCM_IPROC_SHARED
+	tristate "Ethernet Master for Broadcom iProc Shared MDIO Controller"
+	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
+	default ARCH_BCM_IPROC
+	help
+	  This module provides a driver for the ethernet master found in
+	  shared MDIO controller in the Broadcom iProc SoC's.
+
+	  Enable this to support the Shared MDIO controller.
+	  if unsure, say N.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcdbb92..e1c0bc5 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_MDIO_BCM_IPROC_SHARED)	+= mdio-bcm-iproc-shared.o
diff --git a/drivers/net/phy/mdio-bcm-iproc-shared.c b/drivers/net/phy/mdio-bcm-iproc-shared.c
new file mode 100644
index 0000000..6844107
--- /dev/null
+++ b/drivers/net/phy/mdio-bcm-iproc-shared.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/shared_mdio.h>
+#include <linux/io.h>
+#include <linux/phy.h>
+#include <linux/of_mdio.h>
+
+struct iproc_mdio_priv {
+	struct shared_mdio_master *master;
+	struct mii_bus *mii_bus;
+};
+
+static int iproc_mdio_mii_read(struct mii_bus *bus, int phyadr, int reg)
+{
+	struct iproc_mdio_priv *priv = (struct iproc_mdio_priv *)bus->priv;
+
+	return shared_mdio_read(priv->master, phyadr, reg);
+}
+
+static int iproc_mdio_mii_write(struct mii_bus *bus, int phyadr, int reg,
+				u16 val)
+{
+	struct iproc_mdio_priv *priv = bus->priv;
+
+	return shared_mdio_write(priv->master, phyadr, reg, val);
+}
+
+static int iproc_mdio_probe(struct shared_mdio_master *master)
+{
+	struct device *dev = &master->dev;
+	struct iproc_mdio_priv *priv;
+	struct mii_bus *bus;
+	struct device_node *dn = dev->of_node;
+	int rc = 0;
+
+	if (of_get_child_count(dn) == 0)
+		return -ENODEV;
+
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+	priv->master = master;
+
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus) {
+		dev_err(dev, "mdio bus alloc failed\n");
+		return -ENOMEM;
+	}
+
+	bus = priv->mii_bus;
+	bus->priv = priv;
+	bus->name = "iProc MDIO bus";
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d", dev_name(&master->dev),
+							master->dev_num);
+	bus->parent = &master->dev;
+	bus->read = iproc_mdio_mii_read;
+	bus->write = iproc_mdio_mii_write;
+
+	rc = of_mdiobus_register(bus, master->dev.of_node);
+	if (rc) {
+		dev_err(dev, "mdio bus registration failed\n");
+		goto mdiobus_err;
+	}
+
+	shared_mdio_set_drvdata(master, priv);
+	dev_info(dev, "iProc MDIO bus registered\n");
+	return 0;
+
+mdiobus_err:
+	mdiobus_free(bus);
+	return rc;
+}
+
+int iproc_mdio_remove(struct shared_mdio_master *master)
+{
+	struct iproc_mdio_priv *priv = shared_mdio_get_drvdata(master);
+
+	mdiobus_unregister(priv->mii_bus);
+	mdiobus_free(priv->mii_bus);
+
+	return 0;
+}
+
+static const struct of_device_id iproc_mdio_of_match[] = {
+	{ .compatible = "brcm,iproc-mdio-master-eth" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, iproc_mdio_of_match);
+
+static struct shared_mdio_driver iproc_mdio_driver = {
+	.driver = {
+		.name = "iproc-mdio-master-eth",
+		.of_match_table = iproc_mdio_of_match,
+	},
+	.probe = iproc_mdio_probe,
+	.remove = iproc_mdio_remove,
+};
+module_shared_mdio_driver(iproc_mdio_driver);
+
+MODULE_DESCRIPTION("Broadcom iProc shared mdio master driver");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Pramod Kumar <pramod.kumar@broadcom.com>");
-- 
1.9.1
