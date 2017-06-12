From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 11:57:43 +0200
Message-ID: <20170612095745.11300-8-antoine.tenart@free-electrons.com>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:43253 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752540AbdFLKAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:00:20 -0400
In-Reply-To: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the xmdio xsmi interface support in the mvmdio driver.
This interface is used in Ethernet controllers on Marvell 370, 7k and 8k
(as of now). The xsmi interface supported by this driver complies with
the IEEE 802.3 clause 45. The xSMI interface is used by 10GbE devices.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig  |   6 +-
 drivers/net/ethernet/marvell/mvmdio.c | 101 +++++++++++++++++++++++++++++++++-
 2 files changed, 101 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index da6fb825afea..205bb7e683b7 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -35,9 +35,9 @@ config MVMDIO
 	depends on HAS_IOMEM
 	select PHYLIB
 	---help---
-	  This driver supports the MDIO interface found in the network
-	  interface units of the Marvell EBU SoCs (Kirkwood, Orion5x,
-	  Dove, Armada 370 and Armada XP).
+	  This driver supports the MDIO and xMDIO interfaces found in
+	  the network interface units of the Marvell EBU SoCs (Kirkwood,
+	  Orion5x, Dove, Armada 370, Armada XP, Armada 7k and Armada 8k).
 
 	  This driver is used by the MV643XX_ETH and MVNETA drivers.
 
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 41c75d7b84fb..c43747f0be0b 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -24,6 +24,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
@@ -41,6 +42,15 @@
 #define  MVMDIO_ERR_INT_SMI_DONE	0x00000010
 #define MVMDIO_ERR_INT_MASK		0x0080
 
+#define MVMDIO_XSMI_MGNT_REG		0x0
+#define  MVMDIO_XSMI_PHYADDR_SHIFT	16
+#define  MVMDIO_XSMI_DEVADDR_SHIFT	21
+#define  MVMDIO_XSMI_WRITE_OPERATION	(0x5 << 26)
+#define  MVMDIO_XSMI_READ_OPERATION	(0x7 << 26)
+#define  MVMDIO_XSMI_READ_VALID		BIT(29)
+#define  MVMDIO_XSMI_BUSY		BIT(30)
+#define MVMDIO_XSMI_ADDR_REG		0x8
+
 /*
  * SMI Timeout measurements:
  * - Kirkwood 88F6281 (Globalscale Dreamplug): 45us to 95us (Interrupt)
@@ -50,6 +60,14 @@
 #define MVMDIO_SMI_POLL_INTERVAL_MIN	45
 #define MVMDIO_SMI_POLL_INTERVAL_MAX	55
 
+#define MVMDIO_XSMI_POLL_INTERVAL_MIN	150
+#define MVMDIO_XSMI_POLL_INTERVAL_MAX	160
+
+enum orion_mdio_bus_type {
+	BUS_TYPE_SMI,
+	BUS_TYPE_XSMI
+};
+
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
@@ -62,6 +80,8 @@ struct orion_mdio_dev {
 	 */
 	int err_interrupt;
 	wait_queue_head_t smi_busy_wait;
+
+	enum orion_mdio_bus_type bus_type;
 };
 
 struct orion_mdio_ops {
@@ -75,6 +95,7 @@ struct orion_mdio_ops {
 	unsigned int poll_interval_max;
 };
 
+/* mdio smi */
 static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
 {
 	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
@@ -120,6 +141,68 @@ static const struct orion_mdio_ops orion_mdio_smi_ops = {
 	.poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX,
 };
 
+/* xmdio xsmi */
+static int orion_mdio_xsmi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_BUSY);
+}
+
+static int orion_mdio_xsmi_is_read_valid(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_READ_VALID;
+}
+
+static void orion_mdio_xsmi_start_read_op(struct orion_mdio_dev *dev,
+					  int mii_id, int regnum)
+{
+	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
+
+	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_READ_OPERATION,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+}
+
+static u16 orion_mdio_xsmi_read_op(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & GENMASK(15, 0);
+}
+
+static void orion_mdio_xsmi_write_op(struct orion_mdio_dev *dev, int mii_id,
+				     int regnum, u16 value)
+{
+	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
+
+	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_WRITE_OPERATION | value,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+}
+
+static const struct orion_mdio_ops orion_mdio_xsmi_ops = {
+	.is_done = orion_mdio_xsmi_is_done,
+	.is_read_valid = orion_mdio_xsmi_is_read_valid,
+	.start_read = orion_mdio_xsmi_start_read_op,
+	.read = orion_mdio_xsmi_read_op,
+	.write = orion_mdio_xsmi_write_op,
+
+	.poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN,
+	.poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX,
+};
+
+static const struct orion_mdio_ops *orion_mdio_get_ops(struct orion_mdio_dev *dev,
+						       int regnum)
+{
+	if (dev->bus_type == BUS_TYPE_XSMI && (regnum & MII_ADDR_C45))
+		return &orion_mdio_xsmi_ops;
+	else if (dev->bus_type == BUS_TYPE_SMI)
+		return &orion_mdio_smi_ops;
+
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
@@ -164,9 +247,13 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
+	const struct orion_mdio_ops *ops;
 	int ret;
 
+	ops = orion_mdio_get_ops(dev, regnum);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+
 	mutex_lock(&dev->lock);
 
 	ret = orion_mdio_wait_ready(ops, bus);
@@ -195,9 +282,13 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 			    int regnum, u16 value)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
+	const struct orion_mdio_ops *ops;
 	int ret;
 
+	ops = orion_mdio_get_ops(dev, regnum);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+
 	mutex_lock(&dev->lock);
 
 	ret = orion_mdio_wait_ready(ops, bus);
@@ -288,6 +379,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -EPROBE_DEFER;
 	}
 
+	dev->bus_type =
+		(enum orion_mdio_bus_type)of_device_get_match_data(&pdev->dev);
+
 	mutex_init(&dev->lock);
 
 	if (pdev->dev.of_node)
@@ -338,7 +432,8 @@ static int orion_mdio_remove(struct platform_device *pdev)
 }
 
 static const struct of_device_id orion_mdio_match[] = {
-	{ .compatible = "marvell,orion-mdio" },
+	{ .compatible = "marvell,orion-mdio", .data = (void *)BUS_TYPE_SMI },
+	{ .compatible = "marvell,xmdio", .data = (void *)BUS_TYPE_XSMI },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, orion_mdio_match);
-- 
2.9.4
