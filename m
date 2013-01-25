From: Florian Fainelli <florian@openwrt.org>
Subject: [RFC PATCH 2/4] net: mvmdio: do not assume SMI reg is at offset 0 of the resource
Date: Fri, 25 Jan 2013 11:06:47 +0100
Message-ID: <1359108409-4378-3-git-send-email-florian@openwrt.org>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Cc: linux-arm-kernel@lists.infradead.org, ian.molton@codethink.co.uk,
	jason@lakedaemon.net, andrew@lunn.ch, arnd@arndb.de,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:40868 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab3AYKJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 05:09:36 -0500
In-Reply-To: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the mvmdio driver not to assume that the
MVMDIO_SMI_REG is at offset 0 of the resource we are being passed via
Device Tree. This is actually required to reduce the differences between
the mv643xx_eth SMI driver and mvmdio. The only user of the "orion-mdio"
binding is updated accordingly.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt |    2 +-
 arch/arm/boot/dts/armada-370-xp.dtsi                         |    2 +-
 drivers/net/ethernet/marvell/mvmdio.c                        |    9 +++++----
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 34e7aaf..3320d5c 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -19,7 +19,7 @@ mdio {
 	#address-cells = <1>;
 	#size-cells = <0>;
 	compatible = "marvell,orion-mdio";
-	reg = <0xd0072004 0x4>;
+	reg = <0xd0072000 0x8>;
 };
 
 And at the board level:
diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
index 4c0abe8..0e7d880 100644
--- a/arch/arm/boot/dts/armada-370-xp.dtsi
+++ b/arch/arm/boot/dts/armada-370-xp.dtsi
@@ -91,7 +91,7 @@
 			#address-cells = <1>;
 			#size-cells = <0>;
 			compatible = "marvell,orion-mdio";
-			reg = <0xd0072004 0x4>;
+			reg = <0xd0072000 0x8>;
 		};
 
 		ethernet@d0070000 {
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index e4a89b2..16be140 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -29,6 +29,7 @@
 #include <linux/platform_device.h>
 #include <linux/delay.h>
 
+#define MVMDIO_SMI_REG			   0x0004
 #define MVMDIO_SMI_DATA_SHIFT              0
 #define MVMDIO_SMI_PHY_ADDR_SHIFT          16
 #define MVMDIO_SMI_PHY_REG_SHIFT           21
@@ -52,7 +53,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 
 	count = 0;
 	while (1) {
-		val = readl(dev->regs);
+		val = readl(dev->regs + MVMDIO_SMI_REG);
 		if (!(val & MVMDIO_SMI_BUSY))
 			break;
 
@@ -87,12 +88,12 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_READ_OPERATION),
-	       dev->regs);
+	       dev->regs + MVMDIO_SMI_REG);
 
 	/* Wait for the value to become available */
 	count = 0;
 	while (1) {
-		val = readl(dev->regs);
+		val = readl(dev->regs + MVMDIO_SMI_REG);
 		if (val & MVMDIO_SMI_READ_VALID)
 			break;
 
@@ -129,7 +130,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_WRITE_OPERATION            |
 		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->regs);
+	       dev->regs + MVMDIO_SMI_REG);
 
 	mutex_unlock(&dev->lock);
 
-- 
1.7.10.4
