From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 5/6] gianfar: add support for SGMII
Date: Tue, 8 May 2007 17:50:33 -0500
Message-ID: <20070508175033.4441f6e1.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33811 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968861AbXEHWuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 18:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kapil Juneja <Kapil.Juneja@freescale.com>

Add code for initialising and configuring TBI interface and
programming it for connecting to on-chip SERDES (Lynx PHY)
in case of SGMII mode selected through HRCW at reset.

also add defines for TBI register configuration. TBI
interface is programmed towards the SERDES.

refactored mdio read/write functions to differentiate
programming local interface MII regs (e.g., for TBI) from
always programming the mdio master (TSEC1, for programming
the PHYs).

Signed-off-by: Kapil Juneja <Kapil.Juneja@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/gianfar.c     |   27 ++++++++++++++++++++++
 drivers/net/gianfar.h     |    6 +++++
 drivers/net/gianfar_mii.c |   55 ++++++++++++++++++++++++++++++++++++---------
 3 files changed, 77 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b666a0c..8e266bb 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -130,6 +130,9 @@ static int gfar_remove(struct platform_device *pdev);
 static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
+static void gfar_configure_serdes(struct net_device *dev);
+extern int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id, int regnum, u16 value);
+extern int gfar_local_mdio_read(struct gfar_mii *regs, int mii_id, int regnum);
 #ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct net_device *dev, int *budget);
 #endif
@@ -453,6 +456,9 @@ static int init_phy(struct net_device *dev)
 
 	phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
 
+	if (interface == PHY_INTERFACE_MODE_SGMII)
+		gfar_configure_serdes(dev);
+
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
@@ -467,6 +473,27 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
+static void gfar_configure_serdes(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_mii __iomem *regs =
+			(void __iomem *)&priv->regs->gfar_mii_regs;
+
+	/* Initialise TBI i/f to communicate with serdes (lynx phy) */
+
+	/* Single clk mode, mii mode off(for aerdes communication) */
+	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_TBICON, TBICON_CLK_SELECT);
+
+	/* Supported pause and full-duplex, no half-duplex */
+	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_ADVERTISE,
+			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
+			ADVERTISE_1000XPSE_ASYM);
+
+	/* ANEG enable, restart ANEG, full duplex mode, speed[1] set */
+	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_BMCR, BMCR_ANENABLE |
+			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+}
+
 static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 39e9e32..d8e779c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -136,6 +136,12 @@ extern const char gfar_driver_version[];
 #define MIIMCFG_RESET           0x80000000
 #define MIIMIND_BUSY            0x00000001
 
+/* TBI register addresses */
+#define MII_TBICON		0x11
+
+/* TBICON register bit fields */
+#define TBICON_CLK_SELECT	0x0020
+
 /* MAC register bits */
 #define MACCFG1_SOFT_RESET	0x80000000
 #define MACCFG1_RESET_RX_MC	0x00080000
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index bcc6b82..5dd34a1 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -43,13 +43,18 @@
 #include "gianfar.h"
 #include "gianfar_mii.h"
 
-/* Write value to the PHY at mii_id at register regnum,
- * on the bus, waiting until the write is done before returning.
- * All PHY configuration is done through the TSEC1 MIIM regs */
-int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+/*
+ * Write value to the PHY at mii_id at register regnum,
+ * on the bus attached to the local interface, which may be different from the
+ * generic mdio bus (tied to a single interface), waiting until the write is
+ * done before returning. This is helpful in programming interfaces like
+ * the TBI which control interfaces like onchip SERDES and are always tied to
+ * the local mdio pins, which may not be the same as system mdio bus, used for
+ * controlling the external PHYs, for example.
+ */
+int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id,
+			  int regnum, u16 value)
 {
-	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
-
 	/* Set the PHY address and the register address we want to write */
 	gfar_write(&regs->miimadd, (mii_id << 8) | regnum);
 
@@ -63,12 +68,19 @@ int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 	return 0;
 }
 
-/* Read the bus for PHY at addr mii_id, register regnum, and
- * return the value.  Clears miimcom first.  All PHY
- * configuration has to be done through the TSEC1 MIIM regs */
-int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+/*
+ * Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.  All PHY operation
+ * done on the bus attached to the local interface,
+ * which may be different from the generic mdio bus
+ * This is helpful in programming interfaces like
+ * the TBI which, inturn, control interfaces like onchip SERDES
+ * and are always tied to the local mdio pins, which may not be the
+ * same as system mdio bus, used for controlling the external PHYs, for eg.
+ */
+int gfar_local_mdio_read(struct gfar_mii *regs, int mii_id, int regnum)
+
 {
-	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 	u16 value;
 
 	/* Set the PHY address and the register address we want to read */
@@ -88,6 +100,27 @@ int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return value;
 }
 
+/* Write value to the PHY at mii_id at register regnum,
+ * on the bus, waiting until the write is done before returning.
+ * All PHY configuration is done through the TSEC1 MIIM regs */
+int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
+
+	/* Write to the local MII regs */
+	return(gfar_local_mdio_write(regs, mii_id, regnum, value));
+}
+
+/* Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.  All PHY
+ * configuration has to be done through the TSEC1 MIIM regs */
+int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
+
+	/* Read the local MII regs */
+	return(gfar_local_mdio_read(regs, mii_id, regnum));
+}
 
 /* Reset the MIIM registers, and wait for the bus to free */
 int gfar_mdio_reset(struct mii_bus *bus)
-- 
1.5.0.3

