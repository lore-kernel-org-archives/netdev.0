From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2] bgmac: register MII bus
Date: Thu,  7 Mar 2013 12:53:28 +0100
Message-ID: <1362657208-6790-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:40012 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3CGLxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 06:53:35 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so232395eek.32
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 03:53:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: use kmalloc_array
---
 drivers/net/ethernet/broadcom/bgmac.c |   80 +++++++++++++++++++++++++=
+++++++-
 drivers/net/ethernet/broadcom/bgmac.h |    1 +
 2 files changed, 80 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index da5f439..d6cb376 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -13,6 +13,7 @@
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <bcm47xx_nvram.h>
@@ -1313,6 +1314,73 @@ static const struct ethtool_ops bgmac_ethtool_op=
s =3D {
 };
=20
 /**************************************************
+ * MII
+ **************************************************/
+
+static int bgmac_mii_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	return bgmac_phy_read(bus->priv, mii_id, regnum);
+}
+
+static int bgmac_mii_write(struct mii_bus *bus, int mii_id, int regnum=
,
+			   u16 value)
+{
+	return bgmac_phy_write(bus->priv, mii_id, regnum, value);
+}
+
+static int bgmac_mii_register(struct bgmac *bgmac)
+{
+	struct mii_bus *mii_bus;
+	int i, err =3D 0;
+
+	mii_bus =3D mdiobus_alloc();
+	if (!mii_bus)
+		return -ENOMEM;
+
+	mii_bus->name =3D "bgmac mii bus";
+	sprintf(mii_bus->id, "%s-%d-%d", "bgmac", bgmac->core->bus->num,
+		bgmac->core->core_unit);
+	mii_bus->priv =3D bgmac;
+	mii_bus->read =3D bgmac_mii_read;
+	mii_bus->write =3D bgmac_mii_write;
+	mii_bus->parent =3D &bgmac->core->dev;
+	mii_bus->phy_mask =3D ~(1 << bgmac->phyaddr);
+
+	mii_bus->irq =3D kmalloc_array(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL)=
;
+	if (!mii_bus->irq) {
+		err =3D -ENOMEM;
+		goto err_free_bus;
+	}
+	for (i =3D 0; i < PHY_MAX_ADDR; i++)
+		mii_bus->irq[i] =3D PHY_POLL;
+
+	err =3D mdiobus_register(mii_bus);
+	if (err) {
+		bgmac_err(bgmac, "Registration of mii bus failed\n");
+		goto err_free_irq;
+	}
+
+	bgmac->mii_bus =3D mii_bus;
+
+	return err;
+
+err_free_irq:
+	kfree(mii_bus->irq);
+err_free_bus:
+	mdiobus_free(mii_bus);
+	return err;
+}
+
+static void bgmac_mii_unregister(struct bgmac *bgmac)
+{
+	struct mii_bus *mii_bus =3D bgmac->mii_bus;
+
+	mdiobus_unregister(mii_bus);
+	kfree(mii_bus->irq);
+	mdiobus_free(mii_bus);
+}
+
+/**************************************************
  * BCMA bus ops
  **************************************************/
=20
@@ -1404,11 +1472,18 @@ static int bgmac_probe(struct bcma_device *core=
)
 	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
 		bgmac_warn(bgmac, "Support for ADMtek ethernet switch not implemente=
d\n");
=20
+	err =3D bgmac_mii_register(bgmac);
+	if (err) {
+		bgmac_err(bgmac, "Cannot register MDIO\n");
+		err =3D -ENOTSUPP;
+		goto err_dma_free;
+	}
+
 	err =3D register_netdev(bgmac->net_dev);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register net device\n");
 		err =3D -ENOTSUPP;
-		goto err_dma_free;
+		goto err_mii_unregister;
 	}
=20
 	netif_carrier_off(net_dev);
@@ -1417,6 +1492,8 @@ static int bgmac_probe(struct bcma_device *core)
=20
 	return 0;
=20
+err_mii_unregister:
+	bgmac_mii_unregister(bgmac);
 err_dma_free:
 	bgmac_dma_free(bgmac);
=20
@@ -1433,6 +1510,7 @@ static void bgmac_remove(struct bcma_device *core=
)
=20
 	netif_napi_del(&bgmac->napi);
 	unregister_netdev(bgmac->net_dev);
+	bgmac_mii_unregister(bgmac);
 	bgmac_dma_free(bgmac);
 	bcma_set_drvdata(core, NULL);
 	free_netdev(bgmac->net_dev);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 4ede614..98d4b5f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -399,6 +399,7 @@ struct bgmac {
 	struct bcma_device *cmn; /* Reference to CMN core for BCM4706 */
 	struct net_device *net_dev;
 	struct napi_struct napi;
+	struct mii_bus *mii_bus;
=20
 	/* DMA */
 	struct bgmac_dma_ring tx_ring[BGMAC_MAX_TX_RINGS];
--=20
1.7.10.4
