From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v4 2/3] ethernet: arc: mdio changes for future SoC glue layer devtree support
Date: Tue, 26 Aug 2014 13:14:50 +0000
Message-ID: <1409058891-30790-2-git-send-email-romain.perier@gmail.com>
References: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
Cc: heiko@sntech.de, tklauser@distanz.ch, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	f.fainelli@gmail.com, netdev@vger.kernel.org, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:64484 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbaHZNOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 09:14:53 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so14714811wes.36
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 06:14:52 -0700 (PDT)
In-Reply-To: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an api changes for the emac_mdio.c module.
It will be required later when arc_emac_probe/arc_emac_remove
will no longer use 'struct platform_device'.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/arc/emac.h      | 2 +-
 drivers/net/ethernet/arc/emac_main.c | 2 +-
 drivers/net/ethernet/arc/emac_mdio.c | 7 +++----
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 36cc9bd..8011445 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -204,7 +204,7 @@ static inline void arc_reg_clr(struct arc_emac_priv *priv, int reg, int mask)
 	arc_reg_set(priv, reg, value & ~mask);
 }
 
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv);
+int arc_mdio_probe(struct arc_emac_priv *priv);
 int arc_mdio_remove(struct arc_emac_priv *priv);
 
 #endif /* ARC_EMAC_H */
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 761b936..bbc3157 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -799,7 +799,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	dev_dbg(dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
 		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
 
-	err = arc_mdio_probe(pdev, priv);
+	err = arc_mdio_probe(priv);
 	if (err) {
 		dev_err(dev, "failed to probe MII bus\n");
 		goto out_clken;
diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index 26ba242..d5ee986 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -100,7 +100,6 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
 
 /**
  * arc_mdio_probe - MDIO probe function.
- * @pdev:	Pointer to platform device.
  * @priv:	Pointer to ARC EMAC private data structure.
  *
  * returns:	0 on success, -ENOMEM when mdiobus_alloc
@@ -108,7 +107,7 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
  *
  * Sets up and registers the MDIO interface.
  */
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
+int arc_mdio_probe(struct arc_emac_priv *priv)
 {
 	struct mii_bus *bus;
 	int error;
@@ -124,9 +123,9 @@ int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
 	bus->read = &arc_mdio_read;
 	bus->write = &arc_mdio_write;
 
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
 
-	error = of_mdiobus_register(bus, pdev->dev.of_node);
+	error = of_mdiobus_register(bus, priv->dev->of_node);
 	if (error) {
 		dev_err(priv->dev, "cannot register MDIO bus %s\n", bus->name);
 		mdiobus_free(bus);
-- 
1.9.1
