From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V3 2/3] net: bgmac: drop struct bcma_mdio we don't need anymore
Date: Tue, 31 Jan 2017 19:37:55 +0100
Message-ID: <20170131183756.20395-3-zajec5@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170131183756.20395-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33240 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdAaSiV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:38:21 -0500
Received: by mail-lf0-f68.google.com with SMTP id x1so34742599lff.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:38:20 -0800 (PST)
In-Reply-To: <20170131183756.20395-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

Adding struct bcma_mdio was a workaround for bcma code not having access
to the struct bgmac used in the core code. Now we don't duplicate this
struct we can just use it internally in bcma code.

This simplifies code & allows access to all bgmac driver details from
all places in bcma code.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 98 ++++++++++---------------
 drivers/net/ethernet/broadcom/bgmac-bcma.c      |  2 +-
 drivers/net/ethernet/broadcom/bgmac.h           |  2 +-
 3 files changed, 42 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
index 7c19c8e2bf91..9d9984999dce 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
@@ -12,11 +12,6 @@
 #include <linux/brcmphy.h>
 #include "bgmac.h"
 
-struct bcma_mdio {
-	struct bcma_device *core;
-	u8 phyaddr;
-};
-
 static bool bcma_mdio_wait_value(struct bcma_device *core, u16 reg, u32 mask,
 				 u32 value, int timeout)
 {
@@ -37,7 +32,7 @@ static bool bcma_mdio_wait_value(struct bcma_device *core, u16 reg, u32 mask,
  * PHY ops
  **************************************************/
 
-static u16 bcma_mdio_phy_read(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg)
+static u16 bcma_mdio_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg)
 {
 	struct bcma_device *core;
 	u16 phy_access_addr;
@@ -56,12 +51,12 @@ static u16 bcma_mdio_phy_read(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg)
 	BUILD_BUG_ON(BGMAC_PC_MCT_SHIFT != BCMA_GMAC_CMN_PC_MCT_SHIFT);
 	BUILD_BUG_ON(BGMAC_PC_MTE != BCMA_GMAC_CMN_PC_MTE);
 
-	if (bcma_mdio->core->id.id == BCMA_CORE_4706_MAC_GBIT) {
-		core = bcma_mdio->core->bus->drv_gmac_cmn.core;
+	if (bgmac->bcma.core->id.id == BCMA_CORE_4706_MAC_GBIT) {
+		core = bgmac->bcma.core->bus->drv_gmac_cmn.core;
 		phy_access_addr = BCMA_GMAC_CMN_PHY_ACCESS;
 		phy_ctl_addr = BCMA_GMAC_CMN_PHY_CTL;
 	} else {
-		core = bcma_mdio->core;
+		core = bgmac->bcma.core;
 		phy_access_addr = BGMAC_PHY_ACCESS;
 		phy_ctl_addr = BGMAC_PHY_CNTL;
 	}
@@ -87,7 +82,7 @@ static u16 bcma_mdio_phy_read(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg)
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphywr */
-static int bcma_mdio_phy_write(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg,
+static int bcma_mdio_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg,
 			       u16 value)
 {
 	struct bcma_device *core;
@@ -95,12 +90,12 @@ static int bcma_mdio_phy_write(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg,
 	u16 phy_ctl_addr;
 	u32 tmp;
 
-	if (bcma_mdio->core->id.id == BCMA_CORE_4706_MAC_GBIT) {
-		core = bcma_mdio->core->bus->drv_gmac_cmn.core;
+	if (bgmac->bcma.core->id.id == BCMA_CORE_4706_MAC_GBIT) {
+		core = bgmac->bcma.core->bus->drv_gmac_cmn.core;
 		phy_access_addr = BCMA_GMAC_CMN_PHY_ACCESS;
 		phy_ctl_addr = BCMA_GMAC_CMN_PHY_CTL;
 	} else {
-		core = bcma_mdio->core;
+		core = bgmac->bcma.core;
 		phy_access_addr = BGMAC_PHY_ACCESS;
 		phy_ctl_addr = BGMAC_PHY_CNTL;
 	}
@@ -110,8 +105,8 @@ static int bcma_mdio_phy_write(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg,
 	tmp |= phyaddr;
 	bcma_write32(core, phy_ctl_addr, tmp);
 
-	bcma_write32(bcma_mdio->core, BGMAC_INT_STATUS, BGMAC_IS_MDIO);
-	if (bcma_read32(bcma_mdio->core, BGMAC_INT_STATUS) & BGMAC_IS_MDIO)
+	bcma_write32(bgmac->bcma.core, BGMAC_INT_STATUS, BGMAC_IS_MDIO);
+	if (bcma_read32(bgmac->bcma.core, BGMAC_INT_STATUS) & BGMAC_IS_MDIO)
 		dev_warn(&core->dev, "Error setting MDIO int\n");
 
 	tmp = BGMAC_PA_START;
@@ -132,39 +127,39 @@ static int bcma_mdio_phy_write(struct bcma_mdio *bcma_mdio, u8 phyaddr, u8 reg,
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
-static void bcma_mdio_phy_init(struct bcma_mdio *bcma_mdio)
+static void bcma_mdio_phy_init(struct bgmac *bgmac)
 {
-	struct bcma_chipinfo *ci = &bcma_mdio->core->bus->chipinfo;
+	struct bcma_chipinfo *ci = &bgmac->bcma.core->bus->chipinfo;
 	u8 i;
 
 	if (ci->id == BCMA_CHIP_ID_BCM5356) {
 		for (i = 0; i < 5; i++) {
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x008b);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x15, 0x0100);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x12, 0x2aaa);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x008b);
+			bcma_mdio_phy_write(bgmac, i, 0x15, 0x0100);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bgmac, i, 0x12, 0x2aaa);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
 		}
 	}
 	if ((ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg != 10) ||
 	    (ci->id == BCMA_CHIP_ID_BCM4749 && ci->pkg != 10) ||
 	    (ci->id == BCMA_CHIP_ID_BCM53572 && ci->pkg != 9)) {
-		struct bcma_drv_cc *cc = &bcma_mdio->core->bus->drv_cc;
+		struct bcma_drv_cc *cc = &bgmac->bcma.core->bus->drv_cc;
 
 		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
 		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
 		for (i = 0; i < 5; i++) {
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5284);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x0010);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5296);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x1073);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9073);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x52b6);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9273);
-			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bgmac, i, 0x16, 0x5284);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
+			bcma_mdio_phy_write(bgmac, i, 0x17, 0x0010);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bgmac, i, 0x16, 0x5296);
+			bcma_mdio_phy_write(bgmac, i, 0x17, 0x1073);
+			bcma_mdio_phy_write(bgmac, i, 0x17, 0x9073);
+			bcma_mdio_phy_write(bgmac, i, 0x16, 0x52b6);
+			bcma_mdio_phy_write(bgmac, i, 0x17, 0x9273);
+			bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
 		}
 	}
 }
@@ -172,17 +167,17 @@ static void bcma_mdio_phy_init(struct bcma_mdio *bcma_mdio)
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
 static int bcma_mdio_phy_reset(struct mii_bus *bus)
 {
-	struct bcma_mdio *bcma_mdio = bus->priv;
-	u8 phyaddr = bcma_mdio->phyaddr;
+	struct bgmac *bgmac = bus->priv;
+	u8 phyaddr = bgmac->phyaddr;
 
-	if (bcma_mdio->phyaddr == BGMAC_PHY_NOREGS)
+	if (phyaddr == BGMAC_PHY_NOREGS)
 		return 0;
 
-	bcma_mdio_phy_write(bcma_mdio, phyaddr, MII_BMCR, BMCR_RESET);
+	bcma_mdio_phy_write(bgmac, phyaddr, MII_BMCR, BMCR_RESET);
 	udelay(100);
-	if (bcma_mdio_phy_read(bcma_mdio, phyaddr, MII_BMCR) & BMCR_RESET)
-		dev_err(&bcma_mdio->core->dev, "PHY reset failed\n");
-	bcma_mdio_phy_init(bcma_mdio);
+	if (bcma_mdio_phy_read(bgmac, phyaddr, MII_BMCR) & BMCR_RESET)
+		dev_err(bgmac->dev, "PHY reset failed\n");
+	bcma_mdio_phy_init(bgmac);
 
 	return 0;
 }
@@ -202,16 +197,12 @@ static int bcma_mdio_mii_write(struct mii_bus *bus, int mii_id, int regnum,
 	return bcma_mdio_phy_write(bus->priv, mii_id, regnum, value);
 }
 
-struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr)
+struct mii_bus *bcma_mdio_mii_register(struct bgmac *bgmac)
 {
-	struct bcma_mdio *bcma_mdio;
+	struct bcma_device *core = bgmac->bcma.core;
 	struct mii_bus *mii_bus;
 	int err;
 
-	bcma_mdio = kzalloc(sizeof(*bcma_mdio), GFP_KERNEL);
-	if (!bcma_mdio)
-		return ERR_PTR(-ENOMEM);
-
 	mii_bus = mdiobus_alloc();
 	if (!mii_bus) {
 		err = -ENOMEM;
@@ -221,15 +212,12 @@ struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr)
 	mii_bus->name = "bcma_mdio mii bus";
 	sprintf(mii_bus->id, "%s-%d-%d", "bcma_mdio", core->bus->num,
 		core->core_unit);
-	mii_bus->priv = bcma_mdio;
+	mii_bus->priv = bgmac;
 	mii_bus->read = bcma_mdio_mii_read;
 	mii_bus->write = bcma_mdio_mii_write;
 	mii_bus->reset = bcma_mdio_phy_reset;
 	mii_bus->parent = &core->dev;
-	mii_bus->phy_mask = ~(1 << phyaddr);
-
-	bcma_mdio->core = core;
-	bcma_mdio->phyaddr = phyaddr;
+	mii_bus->phy_mask = ~(1 << bgmac->phyaddr);
 
 	err = mdiobus_register(mii_bus);
 	if (err) {
@@ -242,23 +230,17 @@ struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr)
 err_free_bus:
 	mdiobus_free(mii_bus);
 err:
-	kfree(bcma_mdio);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(bcma_mdio_mii_register);
 
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus)
 {
-	struct bcma_mdio *bcma_mdio;
-
 	if (!mii_bus)
 		return;
 
-	bcma_mdio = mii_bus->priv;
-
 	mdiobus_unregister(mii_bus);
 	mdiobus_free(mii_bus);
-	kfree(bcma_mdio);
 }
 EXPORT_SYMBOL_GPL(bcma_mdio_mii_unregister);
 
diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 9281abda4026..5ef60d4f12b4 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -177,7 +177,7 @@ static int bgmac_probe(struct bcma_device *core)
 
 	if (!bgmac_is_bcm4707_family(core) &&
 	    !(ci->id == BCMA_CHIP_ID_BCM53573 && core->core_unit == 1)) {
-		mii_bus = bcma_mdio_mii_register(core, bgmac->phyaddr);
+		mii_bus = bcma_mdio_mii_register(bgmac);
 		if (IS_ERR(mii_bus)) {
 			err = PTR_ERR(mii_bus);
 			goto err;
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index dfebaded3b52..ab2db76e4fb8 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -523,7 +523,7 @@ void bgmac_enet_remove(struct bgmac *bgmac);
 void bgmac_adjust_link(struct net_device *net_dev);
 int bgmac_phy_connect_direct(struct bgmac *bgmac);
 
-struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr);
+struct mii_bus *bcma_mdio_mii_register(struct bgmac *bgmac);
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus);
 
 static inline u32 bgmac_read(struct bgmac *bgmac, u16 offset)
-- 
2.11.0
