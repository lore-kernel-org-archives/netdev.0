From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2 5/8] net: mvmdio: introduce an ops structure
Date: Thu,  8 Jun 2017 11:26:50 +0200
Message-ID: <20170608092653.25221-6-antoine.tenart@free-electrons.com>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48831 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHKAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:00:23 -0400
In-Reply-To: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce an ops structure to add an indirection on functions accessing
the registers. This is needed to add the xMDIO support later.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 71 ++++++++++++++++++++++++++---------
 1 file changed, 53 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 6cbdb221c1ab..f66b474b382a 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -64,6 +64,14 @@ struct orion_mdio_dev {
 	wait_queue_head_t smi_busy_wait;
 };
 
+struct orion_mdio_ops {
+	int (*is_done)(struct orion_mdio_dev *);
+	int (*is_read_valid)(struct orion_mdio_dev *);
+	void (*start_read)(struct orion_mdio_dev *, int, int);
+	u16 (*read)(struct orion_mdio_dev *);
+	void (*write)(struct orion_mdio_dev *, int, int, u16);
+};
+
 static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
 {
 	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
@@ -74,9 +82,42 @@ static int orion_mdio_smi_is_read_valid(struct orion_mdio_dev *dev)
 	return readl(dev->regs) & MVMDIO_SMI_READ_VALID;
 }
 
+static void orion_mdio_smi_start_read_op(struct orion_mdio_dev *dev, int mii_id,
+					 int regnum)
+{
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_READ_OPERATION),
+	       dev->regs);
+}
+
+static u16 orion_mdio_smi_read_op(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs) & GENMASK(15,0);
+}
+
+static void orion_mdio_smi_write_op(struct orion_mdio_dev *dev, int mii_id,
+				    int regnum, u16 value)
+{
+	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
+		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
+		MVMDIO_SMI_WRITE_OPERATION            |
+		(value << MVMDIO_SMI_DATA_SHIFT)),
+	       dev->regs);
+}
+
+static const struct orion_mdio_ops orion_mdio_smi_ops = {
+	.is_done = orion_mdio_smi_is_done,
+	.is_read_valid = orion_mdio_smi_is_read_valid,
+	.start_read = orion_mdio_smi_start_read_op,
+	.read = orion_mdio_smi_read_op,
+	.write = orion_mdio_smi_write_op,
+};
+
 /* Wait for the SMI unit to be ready for another operation
  */
-static int orion_mdio_wait_ready(struct mii_bus *bus)
+static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
+				 struct mii_bus *bus)
 {
 	struct orion_mdio_dev *dev = bus->priv;
 	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
@@ -84,7 +125,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	int timedout = 0;
 
 	while (1) {
-	        if (orion_mdio_smi_is_done(dev))
+	        if (ops->is_done(dev))
 			return 0;
 	        else if (timedout)
 			break;
@@ -103,8 +144,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 			if (timeout < 2)
 				timeout = 2;
 			wait_event_timeout(dev->smi_busy_wait,
-				           orion_mdio_smi_is_done(dev),
-				           timeout);
+				           ops->is_done(dev), timeout);
 
 			++timedout;
 	        }
@@ -118,30 +158,28 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
+	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
 	int ret;
 
 	mutex_lock(&dev->lock);
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(ops, bus);
 	if (ret < 0)
 		goto out;
 
-	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
-		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
-		MVMDIO_SMI_READ_OPERATION),
-	       dev->regs);
+	ops->start_read(dev, mii_id, regnum);
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(ops, bus);
 	if (ret < 0)
 		goto out;
 
-	if (!orion_mdio_smi_is_read_valid(dev)) {
+	if (!ops->is_read_valid(dev)) {
 		dev_err(bus->parent, "SMI bus read not valid\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
-	ret = readl(dev->regs) & GENMASK(15,0);
+	ret = ops->read(dev);
 out:
 	mutex_unlock(&dev->lock);
 	return ret;
@@ -151,19 +189,16 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 			    int regnum, u16 value)
 {
 	struct orion_mdio_dev *dev = bus->priv;
+	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
 	int ret;
 
 	mutex_lock(&dev->lock);
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(ops, bus);
 	if (ret < 0)
 		goto out;
 
-	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
-		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
-		MVMDIO_SMI_WRITE_OPERATION            |
-		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->regs);
+	ops->write(dev, mii_id, regnum, value);
 
 out:
 	mutex_unlock(&dev->lock);
-- 
2.9.4
