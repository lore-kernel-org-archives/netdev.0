From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed,  7 Jun 2017 10:38:08 +0200
Message-ID: <20170607083810.30922-8-antoine.tenart@free-electrons.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37629 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdFGIjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 04:39:16 -0400
In-Reply-To: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the xMDIO interface support in the mvmdio driver. This
interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
of now). The xSMI interface supported by this driver complies with the
IEEE 802.3 clause 45 (while the SMI interface complies with the clause
22). The xSMI interface is used by 10GbE devices.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig  |   6 +-
 drivers/net/ethernet/marvell/mvmdio.c | 121 ++++++++++++++++++++++++++++------
 2 files changed, 104 insertions(+), 23 deletions(-)

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
index 3cb3dd3331d8..13b198aca5c1 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -41,6 +41,15 @@
 #define  MVMDIO_ERR_INT_SMI_DONE	0x00000010
 #define MVMDIO_ERR_INT_MASK		0x0080
 
+#define MVMDIO_XSMI_MGNT_REG		0x0
+#define  MVMDIO_XSMI_READ_VALID		BIT(29)
+#define  MVMDIO_XSMI_BUSY		BIT(30)
+#define MVMDIO_XSMI_ADDR_REG		0x8
+#define  MVMDIO_XSMI_PHYADDR_SHIFT	16
+#define  MVMDIO_XSMI_DEVADDR_SHIFT	21
+#define  MVMDIO_XSMI_READ_OPERATION	(0x7 << 26)
+#define  MVMDIO_XSMI_WRITE_OPERATION	(0x5 << 27)
+
 /*
  * SMI Timeout measurements:
  * - Kirkwood 88F6281 (Globalscale Dreamplug): 45us to 95us (Interrupt)
@@ -50,6 +59,9 @@
 #define MVMDIO_SMI_POLL_INTERVAL_MIN	45
 #define MVMDIO_SMI_POLL_INTERVAL_MAX	55
 
+#define MVMDIO_XSMI_POLL_INTERVAL_MIN	150
+#define MVMDIO_XSMI_POLL_INTERVAL_MAX	160
+
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
@@ -76,18 +88,19 @@ struct orion_mdio_ops {
 	void (*write)(struct orion_mdio_dev *, int, int, u16);
 };
 
-static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
+/* smi */
+static int smi_is_done(struct orion_mdio_dev *dev)
 {
 	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
 }
 
-static int orion_mdio_smi_is_read_valid(struct orion_mdio_dev *dev)
+static int smi_is_read_valid(struct orion_mdio_dev *dev)
 {
 	return !(readl(dev->regs) & MVMDIO_SMI_READ_VALID);
 }
 
-static void orion_mdio_start_read_op(struct orion_mdio_dev *dev, int mii_id,
-				     int regnum)
+static void smi_start_read_op(struct orion_mdio_dev *dev, int mii_id,
+			      int regnum)
 {
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
@@ -95,13 +108,13 @@ static void orion_mdio_start_read_op(struct orion_mdio_dev *dev, int mii_id,
 	       dev->regs);
 }
 
-static u16 orion_mdio_read_op(struct orion_mdio_dev *dev)
+static u16 smi_read_op(struct orion_mdio_dev *dev)
 {
 	return readl(dev->regs) & GENMASK(15,0);
 }
 
-static void orion_mdio_write_op(struct orion_mdio_dev *dev, int mii_id,
-				int regnum, u16 value)
+static void smi_write_op(struct orion_mdio_dev *dev, int mii_id,
+			 int regnum, u16 value)
 {
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
@@ -110,6 +123,47 @@ static void orion_mdio_write_op(struct orion_mdio_dev *dev, int mii_id,
 	       dev->regs);
 }
 
+/* xsmi */
+static int xsmi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_BUSY);
+}
+
+static int xsmi_is_read_valid(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) &
+		 MVMDIO_XSMI_READ_VALID);
+}
+
+static void xsmi_start_read_op(struct orion_mdio_dev *dev, int mii_id,
+			      int regnum)
+{
+	u16 dev_addr = regnum >> 16;
+
+	writel(regnum & GENMASK(15,0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_READ_OPERATION,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+}
+
+static u16 xsmi_read_op(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & GENMASK(15,0);
+}
+
+static void xsmi_write_op(struct orion_mdio_dev *dev, int mii_id,
+			 int regnum, u16 value)
+{
+	u16 dev_addr = regnum >> 16;
+
+	writel(regnum & GENMASK(15,0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_WRITE_OPERATION | value,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(struct mii_bus *bus)
@@ -213,12 +267,47 @@ static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 	return IRQ_NONE;
 }
 
+static int orion_mdio_populate_ops(struct platform_device *pdev,
+				   struct orion_mdio_dev *dev)
+{
+	struct orion_mdio_ops *ops;
+	struct device_node *np = pdev->dev.of_node;
+
+	ops = devm_kzalloc(&pdev->dev, sizeof(*ops), GFP_KERNEL);
+	if (!ops)
+		return -ENOMEM;
+
+	if (of_device_is_compatible(np, "marvell,orion-mdio")) {
+		ops->is_done = smi_is_done;
+		ops->is_read_valid = smi_is_read_valid;
+		ops->start_read = smi_start_read_op;
+		ops->read = smi_read_op;
+		ops->write = smi_write_op;
+
+		dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
+		dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
+	} else if (of_device_is_compatible(np, "marvell,xmdio")) {
+		ops->is_done = xsmi_is_done;
+		ops->is_read_valid = xsmi_is_read_valid;
+		ops->start_read = xsmi_start_read_op;
+		ops->read = xsmi_read_op;
+		ops->write = xsmi_write_op;
+
+		dev->poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN;
+		dev->poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX;
+	} else {
+		return -EINVAL;
+	}
+
+	dev->ops = ops;
+	return 0;
+}
+
 static int orion_mdio_probe(struct platform_device *pdev)
 {
 	struct resource *r;
 	struct mii_bus *bus;
 	struct orion_mdio_dev *dev;
-	struct orion_mdio_ops *ops;
 	int i, ret;
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -278,18 +367,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
 
 	mutex_init(&dev->lock);
 
-	ops = devm_kzalloc(&pdev->dev, sizeof(*ops), GFP_KERNEL);
-	if (!ops)
-		return -ENOMEM;
-
-	dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
-	dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
-	ops->is_done = orion_mdio_smi_is_done;
-	ops->is_read_valid = orion_mdio_smi_is_read_valid;
-	ops->start_read = orion_mdio_start_read_op;
-	ops->read = orion_mdio_read_op;
-	ops->write = orion_mdio_write_op;
-	dev->ops = ops;
+	ret = orion_mdio_populate_ops(pdev, dev);
+	if (ret)
+		return ret;
 
 	if (pdev->dev.of_node)
 		ret = of_mdiobus_register(bus, pdev->dev.of_node);
@@ -340,6 +420,7 @@ static int orion_mdio_remove(struct platform_device *pdev)
 
 static const struct of_device_id orion_mdio_match[] = {
 	{ .compatible = "marvell,orion-mdio" },
+	{ .compatible = "marvell,xmdio" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, orion_mdio_match);
-- 
2.9.4
