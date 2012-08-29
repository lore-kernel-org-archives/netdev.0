From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 3/7] net/fsl_pq_mdio: merge some functions together
Date: Wed, 29 Aug 2012 13:07:59 -0500
Message-ID: <1346263683-3664-3-git-send-email-timur@freescale.com>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:13899
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754402Ab2H2SIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 14:08:19 -0400
In-Reply-To: <1346263683-3664-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few small functions were called only by other functions in the same
file, so merge them together.  One function, for example, was calculating
the device address even though the caller was doing the same thing.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   92 +++++++------------------
 1 files changed, 26 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index edaa25e..d5b7590 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -68,17 +68,19 @@ struct fsl_pq_mdio_priv {
 };
 
 /*
- * Write value to the PHY at mii_id at register regnum,
- * on the bus attached to the local interface, which may be different from the
- * generic mdio bus (tied to a single interface), waiting until the write is
- * done before returning. This is helpful in programming interfaces like
- * the TBI which control interfaces like onchip SERDES and are always tied to
- * the local mdio pins, which may not be the same as system mdio bus, used for
+ * Write value to the PHY at mii_id at register regnum, on the bus attached
+ * to the local interface, which may be different from the generic mdio bus
+ * (tied to a single interface), waiting until the write is done before
+ * returning. This is helpful in programming interfaces like the TBI which
+ * control interfaces like onchip SERDES and are always tied to the local
+ * mdio pins, which may not be the same as system mdio bus, used for
  * controlling the external PHYs, for example.
  */
-static int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
-		int regnum, u16 value)
+static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+		u16 value)
 {
+	struct fsl_pq_mdio_priv *priv = bus->priv;
+	struct fsl_pq_mdio __iomem *regs = priv->regs;
 	u32 status;
 
 	/* Set the PHY address and the register address we want to write */
@@ -95,20 +97,21 @@ static int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
 }
 
 /*
- * Read the bus for PHY at addr mii_id, register regnum, and
- * return the value.  Clears miimcom first.  All PHY operation
- * done on the bus attached to the local interface,
- * which may be different from the generic mdio bus
- * This is helpful in programming interfaces like
- * the TBI which, in turn, control interfaces like onchip SERDES
- * and are always tied to the local mdio pins, which may not be the
+ * Read the bus for PHY at addr mii_id, register regnum, and return the value.
+ * Clears miimcom first.
+ *
+ * All PHY operation done on the bus attached to the local interface, which
+ * may be different from the generic mdio bus.  This is helpful in programming
+ * interfaces like the TBI which, in turn, control interfaces like on-chip
+ * SERDES and are always tied to the local mdio pins, which may not be the
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
-static int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
-		int mii_id, int regnum)
+static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	u16 value;
+	struct fsl_pq_mdio_priv *priv = bus->priv;
+	struct fsl_pq_mdio __iomem *regs = priv->regs;
 	u32 status;
+	u16 value;
 
 	/* Set the PHY address and the register address we want to read */
 	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
@@ -130,42 +133,11 @@ static int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 	return value;
 }
 
-static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
-{
-	struct fsl_pq_mdio_priv *priv = bus->priv;
-
-	return priv->regs;
-}
-
-/*
- * Write value to the PHY at mii_id at register regnum,
- * on the bus, waiting until the write is done before returning.
- */
-static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-		u16 value)
-{
-	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
-
-	/* Write to the local MII regs */
-	return fsl_pq_local_mdio_write(regs, mii_id, regnum, value);
-}
-
-/*
- * Read the bus for PHY at addr mii_id, register regnum, and
- * return the value.  Clears miimcom first.
- */
-static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
-{
-	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
-
-	/* Read the local MII regs */
-	return fsl_pq_local_mdio_read(regs, mii_id, regnum);
-}
-
 /* Reset the MIIM registers, and wait for the bus to free */
 static int fsl_pq_mdio_reset(struct mii_bus *bus)
 {
-	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
+	struct fsl_pq_mdio_priv *priv = bus->priv;
+	struct fsl_pq_mdio __iomem *regs = priv->regs;
 	u32 status;
 
 	mutex_lock(&bus->mdio_lock);
@@ -191,20 +163,6 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
-{
-	const u32 *addr;
-	u64 taddr = OF_BAD_ADDR;
-
-	addr = of_get_address(np, 0, NULL, NULL);
-	if (addr)
-		taddr = of_translate_address(np, addr);
-
-	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
-		(unsigned long long)taddr);
-}
-
-
 static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct device_node *np)
 {
 #if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
@@ -298,7 +256,6 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 	new_bus->write = &fsl_pq_mdio_write,
 	new_bus->reset = &fsl_pq_mdio_reset,
 	new_bus->priv = priv;
-	fsl_pq_mdio_bus_name(new_bus->id, np);
 
 	addrp = of_get_address(np, 0, &size, NULL);
 	if (!addrp) {
@@ -313,6 +270,9 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 		goto err_free_bus;
 	}
 
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s@%llx", np->name,
+		(unsigned long long)addr);
+
 	map = ioremap(addr, size);
 	if (!map) {
 		err = -ENOMEM;
-- 
1.7.3.4
