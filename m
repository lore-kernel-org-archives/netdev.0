From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 11:42:50 +0100
Message-ID: <20170612104250.GB10223@n2100.armlinux.org.uk>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
 <20170612095745.11300-8-antoine.tenart@free-electrons.com>
 <20170612101739.GA4902@n2100.armlinux.org.uk>
 <20170612104126.GB4902@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        f.fainelli@gmail.com, jason@lakedaemon.net, netdev@vger.kernel.org,
        nadavh@marvell.com, gregory.clement@free-electrons.com,
        mw@semihalf.com, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org,
        sebastian.hesselbarth@gmail.com
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37104 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdFLKnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:43:03 -0400
Content-Disposition: inline
In-Reply-To: <20170612104126.GB4902@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/2] net: mvmdio: get rid of fine-grained ops
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset="utf-8"

The fine-grained ops makes the driver less readable, so let's instead
implement two pairs of read/write mii_bus ops, one for SMI and the
other for XSMI.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 268 ++++++++++++++++------------------
 1 file changed, 124 insertions(+), 144 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index d6770217965e..d04022db8619 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -84,123 +84,11 @@ struct orion_mdio_dev {
 
 struct orion_mdio_ops {
 	int (*is_done)(struct orion_mdio_dev *);
-	int (*is_read_valid)(struct orion_mdio_dev *);
-	void (*start_read)(struct orion_mdio_dev *, int, int);
-	u16 (*read)(struct orion_mdio_dev *);
-	void (*write)(struct orion_mdio_dev *, int, int, u16);
 
 	unsigned int poll_interval_min;
 	unsigned int poll_interval_max;
 };
 
-/* mdio smi */
-static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
-{
-	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
-}
-
-static int orion_mdio_smi_is_read_valid(struct orion_mdio_dev *dev)
-{
-	return readl(dev->regs) & MVMDIO_SMI_READ_VALID;
-}
-
-static void orion_mdio_smi_start_read_op(struct orion_mdio_dev *dev, int mii_id,
-					 int regnum)
-{
-	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
-		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
-		MVMDIO_SMI_READ_OPERATION),
-	       dev->regs);
-}
-
-static u16 orion_mdio_smi_read_op(struct orion_mdio_dev *dev)
-{
-	return readl(dev->regs) & GENMASK(15, 0);
-}
-
-static void orion_mdio_smi_write_op(struct orion_mdio_dev *dev, int mii_id,
-				    int regnum, u16 value)
-{
-	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
-		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
-		MVMDIO_SMI_WRITE_OPERATION            |
-		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->regs);
-}
-
-static const struct orion_mdio_ops orion_mdio_smi_ops = {
-	.is_done = orion_mdio_smi_is_done,
-	.is_read_valid = orion_mdio_smi_is_read_valid,
-	.start_read = orion_mdio_smi_start_read_op,
-	.read = orion_mdio_smi_read_op,
-	.write = orion_mdio_smi_write_op,
-
-	.poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN,
-	.poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX,
-};
-
-/* xmdio xsmi */
-static int orion_mdio_xsmi_is_done(struct orion_mdio_dev *dev)
-{
-	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_BUSY);
-}
-
-static int orion_mdio_xsmi_is_read_valid(struct orion_mdio_dev *dev)
-{
-	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_READ_VALID;
-}
-
-static void orion_mdio_xsmi_start_read_op(struct orion_mdio_dev *dev,
-					  int mii_id, int regnum)
-{
-	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
-
-	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
-	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
-	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
-	       MVMDIO_XSMI_READ_OPERATION,
-	       dev->regs + MVMDIO_XSMI_MGNT_REG);
-}
-
-static u16 orion_mdio_xsmi_read_op(struct orion_mdio_dev *dev)
-{
-	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & GENMASK(15, 0);
-}
-
-static void orion_mdio_xsmi_write_op(struct orion_mdio_dev *dev, int mii_id,
-				     int regnum, u16 value)
-{
-	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
-
-	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
-	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
-	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
-	       MVMDIO_XSMI_WRITE_OPERATION | value,
-	       dev->regs + MVMDIO_XSMI_MGNT_REG);
-}
-
-static const struct orion_mdio_ops orion_mdio_xsmi_ops = {
-	.is_done = orion_mdio_xsmi_is_done,
-	.is_read_valid = orion_mdio_xsmi_is_read_valid,
-	.start_read = orion_mdio_xsmi_start_read_op,
-	.read = orion_mdio_xsmi_read_op,
-	.write = orion_mdio_xsmi_write_op,
-
-	.poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN,
-	.poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX,
-};
-
-static const struct orion_mdio_ops *orion_mdio_get_ops(struct orion_mdio_dev *dev,
-						       int regnum)
-{
-	if (dev->bus_type == BUS_TYPE_XSMI && (regnum & MII_ADDR_C45))
-		return &orion_mdio_xsmi_ops;
-	else if (dev->bus_type == BUS_TYPE_SMI)
-		return &orion_mdio_smi_ops;
-
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
@@ -241,57 +129,138 @@ static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
 	return  -ETIMEDOUT;
 }
 
-static int orion_mdio_read(struct mii_bus *bus, int mii_id,
-			   int regnum)
+/* mdio smi */
+static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
+}
+
+static const struct orion_mdio_ops orion_mdio_smi_ops = {
+	.is_done = orion_mdio_smi_is_done,
+
+	.poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN,
+	.poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX,
+};
+
+static int orion_mdio_smi_read(struct mii_bus *bus, int mii_id,
+			       int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops;
 	int ret;
 
-	ops = orion_mdio_get_ops(dev, regnum);
-	if (IS_ERR(ops))
-		return PTR_ERR(ops);
+	if (regnum & MII_ADDR_C45)
+		return -EOPNOTSUPP;
 
-	ret = orion_mdio_wait_ready(ops, bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
 
-	ops->start_read(dev, mii_id, regnum);
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_READ_OPERATION),
+	       dev->regs);
 
-	ret = orion_mdio_wait_ready(ops, bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
 
-	if (!ops->is_read_valid(dev)) {
+	if (!(readl(dev->regs) & MVMDIO_SMI_READ_VALID)) {
 		dev_err(bus->parent, "SMI bus read not valid\n");
-		ret = -ENODEV;
-		goto out;
+		return -ENODEV;
 	}
 
-	ret = ops->read(dev);
-out:
-	return ret;
+	return readl(dev->regs) & GENMASK(15, 0);
 }
 
-static int orion_mdio_write(struct mii_bus *bus, int mii_id,
-			    int regnum, u16 value)
+static int orion_mdio_smi_write(struct mii_bus *bus, int mii_id,
+				int regnum, u16 value)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops;
 	int ret;
 
-	ops = orion_mdio_get_ops(dev, regnum);
-	if (IS_ERR(ops))
-		return PTR_ERR(ops);
+	if (regnum & MII_ADDR_C45)
+		return -EOPNOTSUPP;
 
-	ret = orion_mdio_wait_ready(ops, bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
-		goto out;
+		return ret;
+
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_WRITE_OPERATION            |
+		(value << MVMDIO_SMI_DATA_SHIFT)),
+	       dev->regs);
 
-	ops->write(dev, mii_id, regnum, value);
+	return 0;
+}
 
-out:
-	return ret;
+/* xmdio xsmi */
+static int orion_mdio_xsmi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & MVMDIO_XSMI_BUSY);
+}
+
+static const struct orion_mdio_ops orion_mdio_xsmi_ops = {
+	.is_done = orion_mdio_xsmi_is_done,
+
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
 }
 
 static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
@@ -311,11 +280,14 @@ static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 
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
@@ -328,8 +300,17 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	bus->name = "orion_mdio_bus";
-	bus->read = orion_mdio_read;
-	bus->write = orion_mdio_write;
+
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
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii",
 		 dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
@@ -371,8 +352,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -EPROBE_DEFER;
 	}
 
-	dev->bus_type =
-		(enum orion_mdio_bus_type)of_device_get_match_data(&pdev->dev);
+	dev->bus_type = type;
 
 	if (pdev->dev.of_node)
 		ret = of_mdiobus_register(bus, pdev->dev.of_node);
-- 
2.7.4


-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
