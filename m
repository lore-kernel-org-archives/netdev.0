From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/5] net: mvmdio: enhance driver to support SMI error/done interrupts
Date: Tue, 29 Jan 2013 16:24:06 +0100
Message-ID: <1359473048-26551-4-git-send-email-florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359473048-26551-1-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enhances the "mvmdio" to support a SMI error/done interrupt
line which can be used along with a wait queue instead of doing
busy-waiting on the registers. This is a feature which is available in
the mv643xx_eth SMI code and thus reduces again the gap between the two.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 .../devicetree/bindings/net/marvell-orion-mdio.txt |    3 +
 drivers/net/ethernet/marvell/mvmdio.c              |   83 +++++++++++++++++---
 2 files changed, 75 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 34e7aaf..052b5f2 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -9,6 +9,9 @@ Required properties:
 - compatible: "marvell,orion-mdio"
 - reg: address and length of the SMI register
 
+Optional properties:
+- interrupts: interrupt line number for the SMI error/done interrupt
+
 The child nodes of the MDIO driver are the individual PHY devices
 connected to this MDIO bus. They must have a "reg" property given the
 PHY address on the MDIO bus.
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 5ecda58..cada794 100644
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
 
 #define MVMDIO_SMI_DATA_SHIFT              0
 #define MVMDIO_SMI_PHY_ADDR_SHIFT          16
@@ -36,12 +40,28 @@
 #define MVMDIO_SMI_WRITE_OPERATION         0
 #define MVMDIO_SMI_READ_VALID              BIT(27)
 #define MVMDIO_SMI_BUSY                    BIT(28)
+#define MVMDIO_ERR_INT_CAUSE		   0x007C
+#define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
+#define MVMDIO_ERR_INT_MASK		   0x0080
 
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
+	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(struct mii_bus *bus)
@@ -50,19 +70,30 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	int count;
 	u32 val;
 
-	count = 0;
-	while (1) {
-		val = readl(dev->regs);
-		if (!(val & MVMDIO_SMI_BUSY))
-			break;
-
-		if (count > 100) {
-			dev_err(bus->parent, "Timeout: SMI busy for too long\n");
-			return -ETIMEDOUT;
+	if (dev->err_interrupt == NO_IRQ) {
+		count = 0;
+		while (1) {
+			val = readl(dev->regs);
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
@@ -141,6 +172,21 @@ static int orion_mdio_reset(struct mii_bus *bus)
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
@@ -181,6 +227,19 @@ static int orion_mdio_probe(struct platform_device *pdev)
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
@@ -202,6 +261,8 @@ static int orion_mdio_remove(struct platform_device *pdev)
 	struct mii_bus *bus = platform_get_drvdata(pdev);
 	struct orion_mdio_dev *dev = bus->priv;
 
+	writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
+	free_irq(dev->err_interrupt, dev);
 	mdiobus_unregister(bus);
 	kfree(bus->irq);
 	mdiobus_free(bus);
-- 
1.7.10.4
