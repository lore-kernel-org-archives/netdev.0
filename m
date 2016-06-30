From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 3/7] net: ethernet: bgmac: move BCMA MDIO Phy code into a separate file
Date: Thu, 30 Jun 2016 18:59:10 -0400
Message-ID: <1467327554-22074-4-git-send-email-jon.mason@broadcom.com>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the BCMA MDIO phy into a separate file, as it is very tightly
coupled with the BCMA bus.  This will help with the upcoming BCMA
removal from the bgmac driver.  Optimally, this should be moved into
phy drivers, but it is too tightly coupled with the bgmac driver to
effectively move it without more changes to the driver.

Note: the phy_reset was intentionally removed, as the mdio phy subsyste=
m
automatically resets the phy if a reset function pointer is present.  I=
n
addition to the moving of the driver, this reset function is added.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/Makefile          |   2 +-
 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 264 ++++++++++++++++=
++++++++
 drivers/net/ethernet/broadcom/bgmac.c           | 246 +++-------------=
------
 drivers/net/ethernet/broadcom/bgmac.h           |   3 +
 4 files changed, 298 insertions(+), 217 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c

diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ether=
net/broadcom/Makefile
index 00584d7..f559794 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -10,6 +10,6 @@ obj-$(CONFIG_CNIC) +=3D cnic.o
 obj-$(CONFIG_BNX2X) +=3D bnx2x/
 obj-$(CONFIG_SB1250_MAC) +=3D sb1250-mac.o
 obj-$(CONFIG_TIGON3) +=3D tg3.o
-obj-$(CONFIG_BGMAC) +=3D bgmac.o
+obj-$(CONFIG_BGMAC) +=3D bgmac.o bgmac-bcma-mdio.o
 obj-$(CONFIG_SYSTEMPORT) +=3D bcmsysport.o
 obj-$(CONFIG_BNXT) +=3D bnxt/
diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c b/drivers/=
net/ethernet/broadcom/bgmac-bcma-mdio.c
new file mode 100644
index 0000000..1e65349
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
@@ -0,0 +1,264 @@
+/*
+ * Driver for (BCM4706)? GBit MAC core on BCMA bus.
+ *
+ * Copyright (C) 2012 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
+
+#include <linux/bcma/bcma.h>
+#include <linux/brcmphy.h>
+#include "bgmac.h"
+
+struct bcma_mdio {
+	struct bcma_device *core;
+	u8 phyaddr;
+};
+
+static bool bcma_mdio_wait_value(struct bcma_device *core, u16 reg, u3=
2 mask,
+				 u32 value, int timeout)
+{
+	u32 val;
+	int i;
+
+	for (i =3D 0; i < timeout / 10; i++) {
+		val =3D bcma_read32(core, reg);
+		if ((val & mask) =3D=3D value)
+			return true;
+		udelay(10);
+	}
+	dev_err(&core->dev, "Timeout waiting for reg 0x%X\n", reg);
+	return false;
+}
+
+/**************************************************
+ * PHY ops
+ **************************************************/
+
+static u16 bcma_mdio_phy_read(struct bcma_mdio *bcma_mdio, u8 phyaddr,=
 u8 reg)
+{
+	struct bcma_device *core;
+	u16 phy_access_addr;
+	u16 phy_ctl_addr;
+	u32 tmp;
+
+	BUILD_BUG_ON(BGMAC_PA_DATA_MASK !=3D BCMA_GMAC_CMN_PA_DATA_MASK);
+	BUILD_BUG_ON(BGMAC_PA_ADDR_MASK !=3D BCMA_GMAC_CMN_PA_ADDR_MASK);
+	BUILD_BUG_ON(BGMAC_PA_ADDR_SHIFT !=3D BCMA_GMAC_CMN_PA_ADDR_SHIFT);
+	BUILD_BUG_ON(BGMAC_PA_REG_MASK !=3D BCMA_GMAC_CMN_PA_REG_MASK);
+	BUILD_BUG_ON(BGMAC_PA_REG_SHIFT !=3D BCMA_GMAC_CMN_PA_REG_SHIFT);
+	BUILD_BUG_ON(BGMAC_PA_WRITE !=3D BCMA_GMAC_CMN_PA_WRITE);
+	BUILD_BUG_ON(BGMAC_PA_START !=3D BCMA_GMAC_CMN_PA_START);
+	BUILD_BUG_ON(BGMAC_PC_EPA_MASK !=3D BCMA_GMAC_CMN_PC_EPA_MASK);
+	BUILD_BUG_ON(BGMAC_PC_MCT_MASK !=3D BCMA_GMAC_CMN_PC_MCT_MASK);
+	BUILD_BUG_ON(BGMAC_PC_MCT_SHIFT !=3D BCMA_GMAC_CMN_PC_MCT_SHIFT);
+	BUILD_BUG_ON(BGMAC_PC_MTE !=3D BCMA_GMAC_CMN_PC_MTE);
+
+	if (bcma_mdio->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
+		core =3D bcma_mdio->core->bus->drv_gmac_cmn.core;
+		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
+		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
+	} else {
+		core =3D bcma_mdio->core;
+		phy_access_addr =3D BGMAC_PHY_ACCESS;
+		phy_ctl_addr =3D BGMAC_PHY_CNTL;
+	}
+
+	tmp =3D bcma_read32(core, phy_ctl_addr);
+	tmp &=3D ~BGMAC_PC_EPA_MASK;
+	tmp |=3D phyaddr;
+	bcma_write32(core, phy_ctl_addr, tmp);
+
+	tmp =3D BGMAC_PA_START;
+	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
+	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
+	bcma_write32(core, phy_access_addr, tmp);
+
+	if (!bcma_mdio_wait_value(core, phy_access_addr, BGMAC_PA_START, 0,
+				  1000)) {
+		dev_err(&core->dev, "Reading PHY %d register 0x%X failed\n",
+			phyaddr, reg);
+		return 0xffff;
+	}
+
+	return bcma_read32(core, phy_access_addr) & BGMAC_PA_DATA_MASK;
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphywr */
+static int bcma_mdio_phy_write(struct bcma_mdio *bcma_mdio, u8 phyaddr=
, u8 reg,
+			       u16 value)
+{
+	struct bcma_device *core;
+	u16 phy_access_addr;
+	u16 phy_ctl_addr;
+	u32 tmp;
+
+	if (bcma_mdio->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
+		core =3D bcma_mdio->core->bus->drv_gmac_cmn.core;
+		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
+		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
+	} else {
+		core =3D bcma_mdio->core;
+		phy_access_addr =3D BGMAC_PHY_ACCESS;
+		phy_ctl_addr =3D BGMAC_PHY_CNTL;
+	}
+
+	tmp =3D bcma_read32(core, phy_ctl_addr);
+	tmp &=3D ~BGMAC_PC_EPA_MASK;
+	tmp |=3D phyaddr;
+	bcma_write32(core, phy_ctl_addr, tmp);
+
+	bcma_write32(bcma_mdio->core, BGMAC_INT_STATUS, BGMAC_IS_MDIO);
+	if (bcma_read32(bcma_mdio->core, BGMAC_INT_STATUS) & BGMAC_IS_MDIO)
+		dev_warn(&core->dev, "Error setting MDIO int\n");
+
+	tmp =3D BGMAC_PA_START;
+	tmp |=3D BGMAC_PA_WRITE;
+	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
+	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
+	tmp |=3D value;
+	bcma_write32(core, phy_access_addr, tmp);
+
+	if (!bcma_mdio_wait_value(core, phy_access_addr, BGMAC_PA_START, 0,
+				  1000)) {
+		dev_err(&core->dev, "Writing to PHY %d register 0x%X failed\n",
+			phyaddr, reg);
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
+static void bcma_mdio_phy_init(struct bcma_mdio *bcma_mdio)
+{
+	struct bcma_chipinfo *ci =3D &bcma_mdio->core->bus->chipinfo;
+	u8 i;
+
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
+		for (i =3D 0; i < 5; i++) {
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x008b);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x15, 0x0100);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x12, 0x2aaa);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
+		}
+	}
+	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg !=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg !=3D 10) ||
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg !=3D 9)) {
+		struct bcma_drv_cc *cc =3D &bcma_mdio->core->bus->drv_cc;
+
+		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
+		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
+		for (i =3D 0; i < 5; i++) {
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5284);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x0010);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5296);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x1073);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9073);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x52b6);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9273);
+			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
+		}
+	}
+}
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
+static int bcma_mdio_phy_reset(struct mii_bus *bus)
+{
+	struct bcma_mdio *bcma_mdio =3D bus->priv;
+	u8 phyaddr =3D bcma_mdio->phyaddr;
+
+	if (bcma_mdio->phyaddr =3D=3D BGMAC_PHY_NOREGS)
+		return 0;
+
+	bcma_mdio_phy_write(bcma_mdio, phyaddr, MII_BMCR, BMCR_RESET);
+	udelay(100);
+	if (bcma_mdio_phy_read(bcma_mdio, phyaddr, MII_BMCR) & BMCR_RESET)
+		dev_err(&bcma_mdio->core->dev, "PHY reset failed\n");
+	bcma_mdio_phy_init(bcma_mdio);
+
+	return 0;
+}
+
+/**************************************************
+ * MII
+ **************************************************/
+
+static int bcma_mdio_mii_read(struct mii_bus *bus, int mii_id, int reg=
num)
+{
+	return bcma_mdio_phy_read(bus->priv, mii_id, regnum);
+}
+
+static int bcma_mdio_mii_write(struct mii_bus *bus, int mii_id, int re=
gnum,
+			       u16 value)
+{
+	return bcma_mdio_phy_write(bus->priv, mii_id, regnum, value);
+}
+
+struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 ph=
yaddr)
+{
+	struct bcma_mdio *bcma_mdio;
+	struct mii_bus *mii_bus;
+	int err;
+
+	bcma_mdio =3D kzalloc(sizeof(*bcma_mdio), GFP_KERNEL);
+	if (!bcma_mdio)
+		return ERR_PTR(-ENOMEM);
+
+	mii_bus =3D mdiobus_alloc();
+	if (!mii_bus) {
+		err =3D -ENOMEM;
+		goto err;
+	}
+
+	mii_bus->name =3D "bcma_mdio mii bus";
+	sprintf(mii_bus->id, "%s-%d-%d", "bcma_mdio", core->bus->num,
+		core->core_unit);
+	mii_bus->priv =3D bcma_mdio;
+	mii_bus->read =3D bcma_mdio_mii_read;
+	mii_bus->write =3D bcma_mdio_mii_write;
+	mii_bus->reset =3D bcma_mdio_phy_reset;
+	mii_bus->parent =3D &core->dev;
+	mii_bus->phy_mask =3D ~(1 << phyaddr);
+
+	bcma_mdio->core =3D core;
+	bcma_mdio->phyaddr =3D phyaddr;
+
+	err =3D mdiobus_register(mii_bus);
+	if (err) {
+		dev_err(&core->dev, "Registration of mii bus failed\n");
+		goto err_free_bus;
+	}
+
+	return mii_bus;
+
+err_free_bus:
+	mdiobus_free(mii_bus);
+err:
+	kfree(bcma_mdio);
+	return ERR_PTR(err);
+}
+
+void bcma_mdio_mii_unregister(struct mii_bus *mii_bus)
+{
+	struct bcma_mdio *bcma_mdio;
+
+	if (!mii_bus)
+		return;
+
+	bcma_mdio =3D mii_bus->priv;
+
+	mdiobus_unregister(mii_bus);
+	mdiobus_free(mii_bus);
+	kfree(bcma_mdio);
+}
+
+MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 3614bd8..6c6bb18 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -755,150 +755,6 @@ error:
 	return err;
 }
=20
-/**************************************************
- * PHY ops
- **************************************************/
-
-static u16 bgmac_phy_read(struct bgmac *bgmac, u8 phyaddr, u8 reg)
-{
-	struct bcma_device *core;
-	u16 phy_access_addr;
-	u16 phy_ctl_addr;
-	u32 tmp;
-
-	BUILD_BUG_ON(BGMAC_PA_DATA_MASK !=3D BCMA_GMAC_CMN_PA_DATA_MASK);
-	BUILD_BUG_ON(BGMAC_PA_ADDR_MASK !=3D BCMA_GMAC_CMN_PA_ADDR_MASK);
-	BUILD_BUG_ON(BGMAC_PA_ADDR_SHIFT !=3D BCMA_GMAC_CMN_PA_ADDR_SHIFT);
-	BUILD_BUG_ON(BGMAC_PA_REG_MASK !=3D BCMA_GMAC_CMN_PA_REG_MASK);
-	BUILD_BUG_ON(BGMAC_PA_REG_SHIFT !=3D BCMA_GMAC_CMN_PA_REG_SHIFT);
-	BUILD_BUG_ON(BGMAC_PA_WRITE !=3D BCMA_GMAC_CMN_PA_WRITE);
-	BUILD_BUG_ON(BGMAC_PA_START !=3D BCMA_GMAC_CMN_PA_START);
-	BUILD_BUG_ON(BGMAC_PC_EPA_MASK !=3D BCMA_GMAC_CMN_PC_EPA_MASK);
-	BUILD_BUG_ON(BGMAC_PC_MCT_MASK !=3D BCMA_GMAC_CMN_PC_MCT_MASK);
-	BUILD_BUG_ON(BGMAC_PC_MCT_SHIFT !=3D BCMA_GMAC_CMN_PC_MCT_SHIFT);
-	BUILD_BUG_ON(BGMAC_PC_MTE !=3D BCMA_GMAC_CMN_PC_MTE);
-
-	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
-		core =3D bgmac->core->bus->drv_gmac_cmn.core;
-		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
-		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
-	} else {
-		core =3D bgmac->core;
-		phy_access_addr =3D BGMAC_PHY_ACCESS;
-		phy_ctl_addr =3D BGMAC_PHY_CNTL;
-	}
-
-	tmp =3D bcma_read32(core, phy_ctl_addr);
-	tmp &=3D ~BGMAC_PC_EPA_MASK;
-	tmp |=3D phyaddr;
-	bcma_write32(core, phy_ctl_addr, tmp);
-
-	tmp =3D BGMAC_PA_START;
-	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
-	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
-	bcma_write32(core, phy_access_addr, tmp);
-
-	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
) {
-		dev_err(bgmac->dev, "Reading PHY %d register 0x%X failed\n",
-			phyaddr, reg);
-		return 0xffff;
-	}
-
-	return bcma_read32(core, phy_access_addr) & BGMAC_PA_DATA_MASK;
-}
-
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphywr */
-static int bgmac_phy_write(struct bgmac *bgmac, u8 phyaddr, u8 reg, u1=
6 value)
-{
-	struct bcma_device *core;
-	u16 phy_access_addr;
-	u16 phy_ctl_addr;
-	u32 tmp;
-
-	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
-		core =3D bgmac->core->bus->drv_gmac_cmn.core;
-		phy_access_addr =3D BCMA_GMAC_CMN_PHY_ACCESS;
-		phy_ctl_addr =3D BCMA_GMAC_CMN_PHY_CTL;
-	} else {
-		core =3D bgmac->core;
-		phy_access_addr =3D BGMAC_PHY_ACCESS;
-		phy_ctl_addr =3D BGMAC_PHY_CNTL;
-	}
-
-	tmp =3D bcma_read32(core, phy_ctl_addr);
-	tmp &=3D ~BGMAC_PC_EPA_MASK;
-	tmp |=3D phyaddr;
-	bcma_write32(core, phy_ctl_addr, tmp);
-
-	bgmac_write(bgmac, BGMAC_INT_STATUS, BGMAC_IS_MDIO);
-	if (bgmac_read(bgmac, BGMAC_INT_STATUS) & BGMAC_IS_MDIO)
-		dev_warn(bgmac->dev, "Error setting MDIO int\n");
-
-	tmp =3D BGMAC_PA_START;
-	tmp |=3D BGMAC_PA_WRITE;
-	tmp |=3D phyaddr << BGMAC_PA_ADDR_SHIFT;
-	tmp |=3D reg << BGMAC_PA_REG_SHIFT;
-	tmp |=3D value;
-	bcma_write32(core, phy_access_addr, tmp);
-
-	if (!bgmac_wait_value(core, phy_access_addr, BGMAC_PA_START, 0, 1000)=
) {
-		dev_err(bgmac->dev, "Writing to PHY %d register 0x%X failed\n",
-			phyaddr, reg);
-		return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
-static void bgmac_phy_init(struct bgmac *bgmac)
-{
-	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
-	struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
-	u8 i;
-
-	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
-		for (i =3D 0; i < 5; i++) {
-			bgmac_phy_write(bgmac, i, 0x1f, 0x008b);
-			bgmac_phy_write(bgmac, i, 0x15, 0x0100);
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
-			bgmac_phy_write(bgmac, i, 0x12, 0x2aaa);
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
-		}
-	}
-	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg !=3D 10) ||
-	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg !=3D 10) ||
-	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg !=3D 9)) {
-		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
-		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
-		for (i =3D 0; i < 5; i++) {
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
-			bgmac_phy_write(bgmac, i, 0x16, 0x5284);
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
-			bgmac_phy_write(bgmac, i, 0x17, 0x0010);
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
-			bgmac_phy_write(bgmac, i, 0x16, 0x5296);
-			bgmac_phy_write(bgmac, i, 0x17, 0x1073);
-			bgmac_phy_write(bgmac, i, 0x17, 0x9073);
-			bgmac_phy_write(bgmac, i, 0x16, 0x52b6);
-			bgmac_phy_write(bgmac, i, 0x17, 0x9273);
-			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
-		}
-	}
-}
-
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
-static void bgmac_phy_reset(struct bgmac *bgmac)
-{
-	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
-		return;
-
-	bgmac_phy_write(bgmac, bgmac->phyaddr, MII_BMCR, BMCR_RESET);
-	udelay(100);
-	if (bgmac_phy_read(bgmac, bgmac->phyaddr, MII_BMCR) & BMCR_RESET)
-		dev_err(bgmac->dev, "PHY reset failed\n");
-	bgmac_phy_init(bgmac);
-}
=20
 /**************************************************
  * Chip ops
@@ -1155,7 +1011,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	else
 		bgmac_set(bgmac, BGMAC_PHY_CNTL, BGMAC_PC_MTE);
 	bgmac_miiconfig(bgmac);
-	bgmac_phy_init(bgmac);
+	if (bgmac->mii_bus)
+		bgmac->mii_bus->reset(bgmac->mii_bus);
=20
 	netdev_reset_queue(bgmac->net_dev);
 }
@@ -1532,17 +1389,6 @@ static const struct ethtool_ops bgmac_ethtool_op=
s =3D {
  * MII
  **************************************************/
=20
-static int bgmac_mii_read(struct mii_bus *bus, int mii_id, int regnum)
-{
-	return bgmac_phy_read(bus->priv, mii_id, regnum);
-}
-
-static int bgmac_mii_write(struct mii_bus *bus, int mii_id, int regnum=
,
-			   u16 value)
-{
-	return bgmac_phy_write(bus->priv, mii_id, regnum, value);
-}
-
 static void bgmac_adjust_link(struct net_device *net_dev)
 {
 	struct bgmac *bgmac =3D netdev_priv(net_dev);
@@ -1567,7 +1413,7 @@ static void bgmac_adjust_link(struct net_device *=
net_dev)
 	}
 }
=20
-static int bgmac_fixed_phy_register(struct bgmac *bgmac)
+static int bgmac_phy_connect_direct(struct bgmac *bgmac)
 {
 	struct fixed_phy_status fphy_status =3D {
 		.link =3D 1,
@@ -1593,70 +1439,24 @@ static int bgmac_fixed_phy_register(struct bgma=
c *bgmac)
 	return err;
 }
=20
-static int bgmac_mii_register(struct bgmac *bgmac)
+static int bgmac_phy_connect(struct bgmac *bgmac)
 {
-	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
 	char bus_id[MII_BUS_ID_SIZE + 3];
-	int err =3D 0;
-
-	if (bgmac_is_bcm4707_family(bgmac))
-		return bgmac_fixed_phy_register(bgmac);
-
-	mii_bus =3D mdiobus_alloc();
-	if (!mii_bus)
-		return -ENOMEM;
-
-	mii_bus->name =3D "bgmac mii bus";
-	sprintf(mii_bus->id, "%s-%d-%d", "bgmac", bgmac->core->bus->num,
-		bgmac->core->core_unit);
-	mii_bus->priv =3D bgmac;
-	mii_bus->read =3D bgmac_mii_read;
-	mii_bus->write =3D bgmac_mii_write;
-	mii_bus->parent =3D &bgmac->core->dev;
-	mii_bus->phy_mask =3D ~(1 << bgmac->phyaddr);
-
-	err =3D mdiobus_register(mii_bus);
-	if (err) {
-		dev_err(bgmac->dev, "Registration of mii bus failed\n");
-		goto err_free_bus;
-	}
-
-	bgmac->mii_bus =3D mii_bus;
=20
 	/* Connect to the PHY */
-	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, mii_bus->id,
+	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, bgmac->mii_bus->id,
 		 bgmac->phyaddr);
 	phy_dev =3D phy_connect(bgmac->net_dev, bus_id, &bgmac_adjust_link,
 			      PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(phy_dev)) {
 		dev_err(bgmac->dev, "PHY connecton failed\n");
-		err =3D PTR_ERR(phy_dev);
-		goto err_unregister_bus;
+		return PTR_ERR(phy_dev);
 	}
=20
-	return err;
-
-err_unregister_bus:
-	mdiobus_unregister(mii_bus);
-err_free_bus:
-	mdiobus_free(mii_bus);
-	return err;
-}
-
-static void bgmac_mii_unregister(struct bgmac *bgmac)
-{
-	struct mii_bus *mii_bus =3D bgmac->mii_bus;
-
-	mdiobus_unregister(mii_bus);
-	mdiobus_free(mii_bus);
+	return 0;
 }
=20
-/**************************************************
- * BCMA bus ops
- **************************************************/
-
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
 static int bgmac_probe(struct bcma_device *core)
 {
 	struct net_device *net_dev;
@@ -1777,9 +1577,6 @@ static int bgmac_probe(struct bcma_device *core)
 	if (bcm47xx_nvram_getenv("et0_no_txint", NULL, 0) =3D=3D 0)
 		bgmac->int_mask &=3D ~BGMAC_IS_TX_MASK;
=20
-	/* TODO: reset the external phy. Specs are needed */
-	bgmac_phy_reset(bgmac);
-
 	bgmac->has_robosw =3D !!(core->bus->sprom.boardflags_lo &
 			       BGMAC_BFL_ENETROBO);
 	if (bgmac->has_robosw)
@@ -1790,10 +1587,25 @@ static int bgmac_probe(struct bcma_device *core=
)
=20
 	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
=20
-	err =3D bgmac_mii_register(bgmac);
+	if (!bgmac_is_bcm4707_family(bgmac)) {
+		struct mii_bus *mii_bus;
+
+		mii_bus =3D bcma_mdio_mii_register(core, bgmac->phyaddr);
+		if (!IS_ERR(mii_bus)) {
+			err =3D PTR_ERR(mii_bus);
+			goto err_dma_free;
+		}
+
+		bgmac->mii_bus =3D mii_bus;
+	}
+
+	if (!bgmac->mii_bus)
+		err =3D bgmac_phy_connect_direct(bgmac);
+	else
+		err =3D bgmac_phy_connect(bgmac);
 	if (err) {
 		dev_err(bgmac->dev, "Cannot connect to phy\n");
-		goto err_dma_free;
+		goto err_mii_unregister;
 	}
=20
 	net_dev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSU=
M;
@@ -1803,18 +1615,19 @@ static int bgmac_probe(struct bcma_device *core=
)
 	err =3D register_netdev(bgmac->net_dev);
 	if (err) {
 		dev_err(bgmac->dev, "Cannot register net device\n");
-		goto err_mii_unregister;
+		goto err_phy_disconnect;
 	}
=20
 	netif_carrier_off(net_dev);
=20
 	return 0;
=20
+err_phy_disconnect:
+	phy_disconnect(net_dev->phydev);
 err_mii_unregister:
-	bgmac_mii_unregister(bgmac);
+	bcma_mdio_mii_unregister(bgmac->mii_bus);
 err_dma_free:
 	bgmac_dma_free(bgmac);
-
 err_netdev_free:
 	bcma_set_drvdata(core, NULL);
 	free_netdev(net_dev);
@@ -1827,7 +1640,8 @@ static void bgmac_remove(struct bcma_device *core=
)
 	struct bgmac *bgmac =3D bcma_get_drvdata(core);
=20
 	unregister_netdev(bgmac->net_dev);
-	bgmac_mii_unregister(bgmac);
+	phy_disconnect(bgmac->net_dev->phydev);
+	bcma_mdio_mii_unregister(bgmac->mii_bus);
 	netif_napi_del(&bgmac->napi);
 	bgmac_dma_free(bgmac);
 	bcma_set_drvdata(core, NULL);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index fd20018..191e64a 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -456,6 +456,9 @@ struct bgmac {
 	bool loopback;
 };
=20
+struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 ph=
yaddr);
+void bcma_mdio_mii_unregister(struct mii_bus *mii_bus);
+
 static inline u32 bgmac_read(struct bgmac *bgmac, u16 offset)
 {
 	return bcma_read32(bgmac->core, offset);
--=20
1.9.1
