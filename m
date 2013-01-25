From: Florian Fainelli <florian@openwrt.org>
Subject: [RFC PATCH 3/4] net: mvmdio: enhance driver to support SMI error/done interrupts
Date: Fri, 25 Jan 2013 11:06:48 +0100
Message-ID: <1359108409-4378-4-git-send-email-florian@openwrt.org>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Cc: linux-arm-kernel@lists.infradead.org, ian.molton@codethink.co.uk,
	jason@lakedaemon.net, andrew@lunn.ch, arnd@arndb.de,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:40873 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756208Ab3AYKJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 05:09:36 -0500
In-Reply-To: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances the "mvmdio" to support a SMI error/done interrupt
line which can be used along with a wait queue instead of doing
busy-waiting on the registers. This is a feature which is available in
the mv643xx_eth SMI code and thus reduces again the gap between the two.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 .../devicetree/bindings/net/marvell-orion-mdio.txt |    3 +
 drivers/net/ethernet/marvell/mvmdio.c              |   81 +++++++++++++++++---
 2 files changed, 73 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 3320d5c..1abf47a 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -9,6 +9,9 @@ Required properties:
 - compatible: "marvell,orion-mdio"
 - reg: address and length of the SMI register
 
+Optional properties:
+- interrupts: interrupt line number for the SMI error/done
+
 The child nodes of the MDIO driver are the individual PHY devices
 connected to this MDIO bus. They must have a "reg" property given the
 PHY address on the MDIO bus.
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 16be140..bdd9047 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -24,10 +24,14 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/phy.h>
+#include <linux/interrupt.h>
 #include <linux/of_address.h>
 #include <linux/of_mdio.h>
+#include <linux/of_irq.h>
 #include <linux/platform_device.h>
 #include <linux/delay.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
 
 #define MVMDIO_SMI_REG			   0x0004
 #define MVMDIO_SMI_DATA_SHIFT              0
@@ -37,12 +41,28 @@
 #define MVMDIO_SMI_WRITE_OPERATION         0
 #define MVMDIO_SMI_READ_VALID              BIT(27)
 #define MVMDIO_SMI_BUSY                    BIT(28)
+#define MVMDIO_ERR_INT_CAUSE		   0x0080
+#define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
+#define MVMDIO_ERR_INT_MASK		   0x0084
 
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
+	/*
+	 * If we have access to the error interrupt pin (which is
+	 * somewhat misnamed as it not only reflects internal errors
+	 * but also reflects SMI completion), use that to wait for
+	 * SMI access completion instead of polling the SMI busy bit.
+	 */
+	int err_interrupt;
+	wait_queue_head_t smi_busy_wait;
 };
 
+static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs + MVMDIO_SMI_REG) & MVMDIO_SMI_BUSY);
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(struct mii_bus *bus)
@@ -51,19 +71,30 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	int count;
 	u32 val;
 
-	count = 0;
-	while (1) {
-		val = readl(dev->regs + MVMDIO_SMI_REG);
-		if (!(val & MVMDIO_SMI_BUSY))
-			break;
-
-		if (count > 100) {
-			dev_err(bus->parent, "Timeout: SMI busy for too long\n");
-			return -ETIMEDOUT;
+	if (dev->err_interrupt == NO_IRQ) {
+		count = 0;
+		while (1) {
+			val = readl(dev->regs + MVMDIO_SMI_REG);
+			if (!(val & MVMDIO_SMI_BUSY))
+				break;
+
+			if (count > 100) {
+				dev_err(bus->parent,
+					"Timeout: SMI busy for too long\n");
+				return -ETIMEDOUT;
+			}
+
+			udelay(10);
+			count++;
 		}
+	}
 
-		udelay(10);
-		count++;
+	if (!orion_mdio_smi_is_done(dev)) {
+		wait_event_timeout(dev->smi_busy_wait,
+				orion_mdio_smi_is_done(dev),
+				msecs_to_jiffies(100));
+		if (!orion_mdio_smi_is_done(dev))
+			return -ETIMEDOUT;
 	}
 
 	return 0;
@@ -142,6 +173,21 @@ static int orion_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
+static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
+{
+	struct orion_mdio_dev *dev = dev_id;
+
+	if (readl(dev->regs + MVMDIO_ERR_INT_CAUSE) &
+			MVMDIO_ERR_INT_SMI_DONE) {
+		writel(~MVMDIO_ERR_INT_SMI_DONE,
+				dev->regs + MVMDIO_ERR_INT_CAUSE);
+		wake_up(&dev->smi_busy_wait);
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
+}
+
 static int orion_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -182,6 +228,19 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
+	dev->err_interrupt = NO_IRQ;
+	init_waitqueue_head(&dev->smi_busy_wait);
+
+	dev->err_interrupt = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	if (dev->err_interrupt != NO_IRQ) {
+		ret = devm_request_irq(&pdev->dev, dev->err_interrupt,
+					orion_mdio_err_irq,
+					IRQF_SHARED, pdev->name, dev);
+		if (!ret)
+			writel(MVMDIO_ERR_INT_SMI_DONE,
+					dev->regs + MVMDIO_ERR_INT_MASK);
+	}
+
 	mutex_init(&dev->lock);
 
 	ret = of_mdiobus_register(bus, np);
-- 
1.7.10.4
