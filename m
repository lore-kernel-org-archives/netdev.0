From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] net/mpc52xx_phy: Various code cleanups
Date: Wed, 19 May 2010 12:21:10 +0200
Message-ID: <1274264470-2905-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Wolfram Sang <w.sang@pengutronix.de>,
	Grant Likely <grant.likely@secretlab.ca>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50317 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554Ab0ESKVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 06:21:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- don't free bus->irq (obsoleted by ca816d98170942371535b3e862813b0aba9b7d90)
- don't dispose irqs (should be done in of_mdiobus_register())
- use fec-pointer consistently in transfer()
- use resource_size()
- cosmetic fixes

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Grant Likely <grant.likely@secretlab.ca>
---

My phyCORE-MPC5200B-tiny still passes its test-suite after the patch
(running via nfsroot).

 drivers/net/fec_mpc52xx_phy.c |   24 +++++-------------------
 1 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 7658a08..35c90e0 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -29,15 +29,14 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 		int reg, u32 value)
 {
 	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
-	struct mpc52xx_fec __iomem *fec;
+	struct mpc52xx_fec __iomem *fec = priv->regs;
 	int tries = 3;
 
 	value |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
 	value |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
 
-	fec = priv->regs;
 	out_be32(&fec->ievent, FEC_IEVENT_MII);
-	out_be32(&priv->regs->mii_data, value);
+	out_be32(&fec->mii_data, value);
 
 	/* wait for it to finish, this takes about 23 us on lite5200b */
 	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
@@ -47,7 +46,7 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 		return -ETIMEDOUT;
 
 	return value & FEC_MII_DATA_OP_RD ?
-		in_be32(&priv->regs->mii_data) & FEC_MII_DATA_DATAMSK : 0;
+		in_be32(&fec->mii_data) & FEC_MII_DATA_DATAMSK : 0;
 }
 
 static int mpc52xx_fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
@@ -69,9 +68,8 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	struct device_node *np = of->node;
 	struct mii_bus *bus;
 	struct mpc52xx_fec_mdio_priv *priv;
-	struct resource res = {};
+	struct resource res;
 	int err;
-	int i;
 
 	bus = mdiobus_alloc();
 	if (bus == NULL)
@@ -93,7 +91,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	err = of_address_to_resource(np, 0, &res);
 	if (err)
 		goto out_free;
-	priv->regs = ioremap(res.start, res.end - res.start + 1);
+	priv->regs = ioremap(res.start, resource_size(&res));
 	if (priv->regs == NULL) {
 		err = -ENOMEM;
 		goto out_free;
@@ -118,10 +116,6 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
  out_unmap:
 	iounmap(priv->regs);
  out_free:
-	for (i=0; i<PHY_MAX_ADDR; i++)
-		if (bus->irq[i] != PHY_POLL)
-			irq_dispose_mapping(bus->irq[i]);
-	kfree(bus->irq);
 	kfree(priv);
 	mdiobus_free(bus);
 
@@ -133,23 +127,16 @@ static int mpc52xx_fec_mdio_remove(struct of_device *of)
 	struct device *dev = &of->dev;
 	struct mii_bus *bus = dev_get_drvdata(dev);
 	struct mpc52xx_fec_mdio_priv *priv = bus->priv;
-	int i;
 
 	mdiobus_unregister(bus);
 	dev_set_drvdata(dev, NULL);
-
 	iounmap(priv->regs);
-	for (i=0; i<PHY_MAX_ADDR; i++)
-		if (bus->irq[i] != PHY_POLL)
-			irq_dispose_mapping(bus->irq[i]);
 	kfree(priv);
-	kfree(bus->irq);
 	mdiobus_free(bus);
 
 	return 0;
 }
 
-
 static struct of_device_id mpc52xx_fec_mdio_match[] = {
 	{ .compatible = "fsl,mpc5200b-mdio", },
 	{ .compatible = "fsl,mpc5200-mdio", },
@@ -168,5 +155,4 @@ struct of_platform_driver mpc52xx_fec_mdio_driver = {
 /* let fec driver call it, since this has to be registered before it */
 EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);
 
-
 MODULE_LICENSE("Dual BSD/GPL");
-- 
1.7.0

