From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] net/fsl: introduce Freescale 10G MDIO driver
Date: Fri, 17 Aug 2012 15:03:12 -0500
Message-ID: <1345233792-14985-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:49126 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755802Ab2HQUDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 16:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to fsl_pq_mdio.c, this driver is for the 10G MDIO controller on
Freescale Frame Manager Ethernet controllers.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig      |    7 +
 drivers/net/ethernet/freescale/Makefile     |    1 +
 drivers/net/ethernet/freescale/xgmac_mdio.c |  257 +++++++++++++++++++++++++++
 3 files changed, 265 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/xgmac_mdio.c

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 3574e14..feff516 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -62,6 +62,13 @@ config FSL_PQ_MDIO
 	---help---
 	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
 
+config FSL_XGMAC_MDIO
+	tristate "Freescale XGMAC MDIO"
+	depends on FSL_SOC
+	select PHYLIB
+	---help---
+	  This driver supports the MDIO bus on the Fman 10G Ethernet MACs.
+
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
index 1752488..3d1839a 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -9,6 +9,7 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 endif
 obj-$(CONFIG_FS_ENET) += fs_enet/
 obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
+obj-$(CONFIG_FSL_XGMAC_MDIO) += xgmac_mdio.o
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 gianfar_driver-objs := gianfar.o \
diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
new file mode 100644
index 0000000..1894476
--- /dev/null
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -0,0 +1,257 @@
+/*
+ * QorIQ 10G MDIO Controller
+ *
+ * Copyright 2012 Freescale Semiconductor, Inc.
+ *
+ * Authors: Andy Fleming <afleming@freescale.com>
+ *          Timur Tabi <timur@freescale.com>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/mdio.h>
+#include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+
+/* Number of microseconds to wait for a register to respond */
+#define TIMEOUT	1000
+
+struct tgec_mdio_controller {
+	__be32	reserved[12];
+	__be32	mdio_stat;	/* MDIO configuration and status */
+	__be32	mdio_ctl;	/* MDIO control */
+	__be32	mdio_data;	/* MDIO data */
+	__be32	mdio_addr;	/* MDIO address */
+} __packed;
+
+#define MDIO_STAT_CLKDIV(x)	(((x>>1) & 0xff) << 8)
+#define MDIO_STAT_BSY		(1 << 0)
+#define MDIO_STAT_RD_ER		(1 << 1)
+#define MDIO_CTL_DEV_ADDR(x) 	(x & 0x1f)
+#define MDIO_CTL_PORT_ADDR(x)	((x & 0x1f) << 5)
+#define MDIO_CTL_PRE_DIS	(1 << 10)
+#define MDIO_CTL_SCAN_EN	(1 << 11)
+#define MDIO_CTL_POST_INC	(1 << 14)
+#define MDIO_CTL_READ		(1 << 15)
+
+#define MDIO_DATA(x)		(x & 0xffff)
+#define MDIO_DATA_BSY		(1 << 31)
+
+/*
+ * Write value to the PHY for this device to the register at regnum,waiting
+ * until the write is done before it returns.  All PHY configuration has to be
+ * done through the TSEC1 MIIM regs.
+ */
+static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 value)
+{
+	struct tgec_mdio_controller __iomem *regs = bus->priv;
+	uint16_t dev_addr = regnum >> 16;
+	uint32_t status;
+
+	/* Setup the MII Mgmt clock speed */
+	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
+
+	/* Wait till the bus is free */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	/* Set the port and dev addr */
+	out_be32(&regs->mdio_ctl,
+		 MDIO_CTL_PORT_ADDR(phy_id) | MDIO_CTL_DEV_ADDR(dev_addr));
+
+	/* Set the register address */
+	out_be32(&regs->mdio_addr, regnum & 0xffff);
+
+	/* Wait till the bus is free */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	/* Write the value to the register */
+	out_be32(&regs->mdio_data, MDIO_DATA(value));
+
+	/* Wait till the MDIO write is complete */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_data)) & MDIO_DATA_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for data\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+/*
+ * Reads from register regnum in the PHY for device dev, returning the value.
+ * Clears miimcom first.  All PHY configuration has to be done through the
+ * TSEC1 MIIM regs.
+ */
+static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
+{
+	struct tgec_mdio_controller __iomem *regs = bus->priv;
+	uint16_t dev_addr = regnum >> 16;
+	uint32_t mdio_ctl;
+	uint32_t status;
+	int ret;
+
+	/* Setup the MII Mgmt clock speed */
+	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
+
+	/* Wait till the bus is free */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	/* Set the Port and Device Addrs */
+	mdio_ctl = MDIO_CTL_PORT_ADDR(phy_id) | MDIO_CTL_DEV_ADDR(dev_addr);
+	out_be32(&regs->mdio_ctl, mdio_ctl);
+
+	/* Set the register address */
+	out_be32(&regs->mdio_addr, regnum & 0xffff);
+
+	/* Wait till the bus is free */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	/* Initiate the read */
+	out_be32(&regs->mdio_ctl, mdio_ctl | MDIO_CTL_READ);
+
+	/* Wait till the MDIO write is complete */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_data)) & MDIO_DATA_BSY), TIMEOUT, 0);
+	if (!status) {
+		dev_dbg(&bus->dev, "%s: timeout waiting for data\n", __func__);
+		return -ETIMEDOUT;
+	}
+
+	/* Return all Fs if nothing was there */
+	if (in_be32(&regs->mdio_stat) & MDIO_STAT_RD_ER)
+		return 0xffff;
+
+	ret = in_be32(&regs->mdio_data) & 0xffff;
+
+	return ret;
+}
+
+/* Reset the MIIM registers, and wait for the bus to free */
+static int xgmac_mdio_reset(struct mii_bus *bus)
+{
+	struct tgec_mdio_controller __iomem *regs = bus->priv;
+	uint32_t status;
+
+	mutex_lock(&bus->mdio_lock);
+
+	/* Setup the MII Mgmt clock speed */
+	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
+
+	/* Wait till the bus is free */
+	status = spin_event_timeout(
+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
+
+	mutex_unlock(&bus->mdio_lock);
+
+	if (!status) {
+		dev_err(&bus->dev, "timeout waiting for bus reset\n");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int __devinit xgmac_mdio_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mii_bus *bus;
+	int ret;
+
+	bus = mdiobus_alloc_size(PHY_MAX_ADDR * sizeof(int));
+	if (!bus)
+		return -ENOMEM;
+
+	bus->name = "Freescale XGMAC MDIO Bus";
+	bus->read = xgmac_mdio_read;
+	bus->write = xgmac_mdio_write;
+	bus->reset = xgmac_mdio_reset;
+	bus->irq = bus->priv;
+	bus->parent = &pdev->dev;
+	strncpy(bus->id, np->name, MII_BUS_ID_SIZE);
+
+	/* Set the PHY base address */
+	bus->priv = of_iomap(np, 0);
+	if (!bus->priv) {
+		ret = -ENOMEM;
+		goto err_ioremap;
+	}
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret) {
+		dev_err(&pdev->dev, "cannot register MDIO bus\n");
+		goto err_registration;
+	}
+
+	dev_set_drvdata(&pdev->dev, bus);
+
+	return 0;
+
+err_registration:
+	iounmap(bus->priv);
+
+err_ioremap:
+	mdiobus_free(bus);
+
+	return ret;
+}
+
+static int __devexit xgmac_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&pdev->dev);
+
+	mdiobus_unregister(bus);
+	iounmap(bus->priv);
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static struct of_device_id xgmac_mdio_match[] = {
+	{
+		.compatible = "fsl,fman-xmdio",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, xgmac_mdio_match);
+
+static struct platform_driver xgmac_mdio_driver = {
+	.driver = {
+		.name = "fsl-fman_xmdio",
+		.of_match_table = xgmac_mdio_match,
+	},
+	.probe = xgmac_mdio_probe,
+	.remove = xgmac_mdio_remove,
+};
+
+module_platform_driver(xgmac_mdio_driver);
+
+MODULE_DESCRIPTION("Freescale QorIQ 10G MDIO Controller");
+MODULE_LICENSE("GPL v2");
-- 
1.7.3.4
