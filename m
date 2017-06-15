From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 08/11] net: mvmdio: add xmdio xsmi support
Date: Thu, 15 Jun 2017 16:43:23 +0200
Message-ID: <20170615144326.24463-9-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34846 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752510AbdFOOoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:05 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the xmdio xsmi interface support in the mvmdio driver.
This interface is used in Ethernet controllers on Marvell 370, 7k and 8k
(as of now). The xsmi interface supported by this driver complies with
the IEEE 802.3 clause 45. The xSMI interface is used by 10GbE devices.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 112 +++++++++++++++++++++++++++++++---
 1 file changed, 105 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index fe6072aae0a6..0888e50f6b17 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -23,6 +23,7 @@
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
@@ -40,6 +41,15 @@
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
@@ -49,6 +59,9 @@
 #define MVMDIO_SMI_POLL_INTERVAL_MIN	45
 #define MVMDIO_SMI_POLL_INTERVAL_MAX	55
 
+#define MVMDIO_XSMI_POLL_INTERVAL_MIN	150
+#define MVMDIO_XSMI_POLL_INTERVAL_MAX	160
+
 struct orion_mdio_dev {
 	void __iomem *regs;
 	struct clk *clk[3];
@@ -62,6 +75,11 @@ struct orion_mdio_dev {
 	wait_queue_head_t smi_busy_wait;
 };
 
+enum orion_mdio_bus_type {
+	BUS_TYPE_SMI,
+	BUS_TYPE_XSMI
+};
+
 struct orion_mdio_ops {
 	int (*is_done)(struct orion_mdio_dev *);
 	unsigned int poll_interval_min;
@@ -119,8 +137,8 @@ static const struct orion_mdio_ops orion_mdio_smi_ops = {
 	.poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX,
 };
 
-static int orion_mdio_read(struct mii_bus *bus, int mii_id,
-			   int regnum)
+static int orion_mdio_smi_read(struct mii_bus *bus, int mii_id,
+			       int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
 	u32 val;
@@ -154,8 +172,8 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	return ret;
 }
 
-static int orion_mdio_write(struct mii_bus *bus, int mii_id,
-			    int regnum, u16 value)
+static int orion_mdio_smi_write(struct mii_bus *bus, int mii_id,
+				int regnum, u16 value)
 {
 	struct orion_mdio_dev *dev = bus->priv;
 	int ret;
@@ -177,6 +195,73 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	return ret;
 }
 
+static int orion_mdio_xsmi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_BUSY);
+}
+
+static const struct orion_mdio_ops orion_mdio_xsmi_ops = {
+	.is_done = orion_mdio_xsmi_is_done,
+	.poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN,
+	.poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX,
+};
+
+static int orion_mdio_xsmi_read(struct mii_bus *bus, int mii_id,
+				int regnum)
+{
+	struct orion_mdio_dev *dev = bus->priv;
+	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
+	int ret;
+
+	if (!(regnum & MII_ADDR_C45))
+		return -EOPNOTSUPP;
+
+	ret = orion_mdio_wait_ready(&orion_mdio_xsmi_ops, bus);
+	if (ret < 0)
+		return ret;
+
+	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_READ_OPERATION,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+
+	ret = orion_mdio_wait_ready(&orion_mdio_xsmi_ops, bus);
+	if (ret < 0)
+		return ret;
+
+	if (!(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) &
+	      MVMDIO_XSMI_READ_VALID)) {
+		dev_err(bus->parent, "XSMI bus read not valid\n");
+		return -ENODEV;
+	}
+
+	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & GENMASK(15, 0);
+}
+
+static int orion_mdio_xsmi_write(struct mii_bus *bus, int mii_id,
+				int regnum, u16 value)
+{
+	struct orion_mdio_dev *dev = bus->priv;
+	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
+	int ret;
+
+	if (!(regnum & MII_ADDR_C45))
+		return -EOPNOTSUPP;
+
+	ret = orion_mdio_wait_ready(&orion_mdio_xsmi_ops, bus);
+	if (ret < 0)
+		return ret;
+
+	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_WRITE_OPERATION | value,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+
+	return 0;
+}
+
 static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 {
 	struct orion_mdio_dev *dev = dev_id;
@@ -194,11 +279,14 @@ static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 
 static int orion_mdio_probe(struct platform_device *pdev)
 {
+	enum orion_mdio_bus_type type;
 	struct resource *r;
 	struct mii_bus *bus;
 	struct orion_mdio_dev *dev;
 	int i, ret;
 
+	type = (enum orion_mdio_bus_type)of_device_get_match_data(&pdev->dev);
+
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!r) {
 		dev_err(&pdev->dev, "No SMI register address given\n");
@@ -210,9 +298,18 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	if (!bus)
 		return -ENOMEM;
 
+	switch (type) {
+	case BUS_TYPE_SMI:
+		bus->read = orion_mdio_smi_read;
+		bus->write = orion_mdio_smi_write;
+		break;
+	case BUS_TYPE_XSMI:
+		bus->read = orion_mdio_xsmi_read;
+		bus->write = orion_mdio_xsmi_write;
+		break;
+	}
+
 	bus->name = "orion_mdio_bus";
-	bus->read = orion_mdio_read;
-	bus->write = orion_mdio_write;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii",
 		 dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
@@ -302,7 +399,8 @@ static int orion_mdio_remove(struct platform_device *pdev)
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
