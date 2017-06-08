From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Thu,  8 Jun 2017 11:26:52 +0200
Message-ID: <20170608092653.25221-8-antoine.tenart@free-electrons.com>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48843 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750937AbdFHKA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:00:28 -0400
In-Reply-To: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the xMDIO interface support in the mvmdio driver. This
interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
of now). The xSMI interface supported by this driver complies with the
IEEE 802.3 clause 45 (while the SMI interface complies with the clause
22). The xSMI interface is used by 10GbE devices.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-orion-mdio.txt |  6 +-
 drivers/net/ethernet/marvell/Kconfig               |  6 +-
 drivers/net/ethernet/marvell/mvmdio.c              | 76 +++++++++++++++++++++-
 3 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index ccdabdcc8618..36be4ca5dab2 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -1,9 +1,9 @@
 * Marvell MDIO Ethernet Controller interface
 
 The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
-MV78xx0, Armada 370 and Armada XP have an identical unit that provides
-an interface with the MDIO bus. This driver handles this MDIO
-interface.
+MV78xx0, Armada 370, Armada XP, Armada 7k and Armada 8k have an
+identical unit that provides an interface with the MDIO bus or to
+the xMDIO bus. This driver handles these interfaces.
 
 Required properties:
 - compatible: "marvell,orion-mdio"
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
index 07b18f60da2a..7b650ef67347 100644
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
@@ -75,6 +87,7 @@ struct orion_mdio_ops {
 	unsigned int poll_interval_max;
 };
 
+/* smi */
 static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
 {
 	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
@@ -120,6 +133,65 @@ static const struct orion_mdio_ops orion_mdio_smi_ops = {
 	.poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX,
 };
 
+/* xsmi */
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
+	u16 dev_addr = regnum >> 16;
+
+	writel(regnum & GENMASK(15,0), dev->regs + MVMDIO_XSMI_ADDR_REG);
+	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
+	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
+	       MVMDIO_XSMI_READ_OPERATION,
+	       dev->regs + MVMDIO_XSMI_MGNT_REG);
+}
+
+static u16 orion_mdio_xsmi_read_op(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs + MVMDIO_XSMI_MGNT_REG) & GENMASK(15,0);
+}
+
+static void orion_mdio_xsmi_write_op(struct orion_mdio_dev *dev, int mii_id,
+				     int regnum, u16 value)
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
+static const struct orion_mdio_ops *orion_mdio_get_ops(int regnum)
+{
+	if (regnum & MII_ADDR_C45)
+		return &orion_mdio_xsmi_ops;
+
+	return &orion_mdio_smi_ops;
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
@@ -164,7 +236,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
+	const struct orion_mdio_ops *ops = orion_mdio_get_ops(regnum);
 	int ret;
 
 	mutex_lock(&dev->lock);
@@ -195,7 +267,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 			    int regnum, u16 value)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	const struct orion_mdio_ops *ops = &orion_mdio_smi_ops;
+	const struct orion_mdio_ops *ops = orion_mdio_get_ops(regnum);
 	int ret;
 
 	mutex_lock(&dev->lock);
-- 
2.9.4
