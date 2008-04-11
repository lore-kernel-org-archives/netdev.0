From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Fri, 11 Apr 2008 11:49:17 -0400
Message-ID: <20080411154914.GA19036@windriver.com>
References: <1207870471-3601-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [128.224.252.2] ([128.224.252.2]:49214 "EHLO
	yow-pgortmak-d1.corp.ad.wrs.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759975AbYDKPtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 11:49:08 -0400
Content-Disposition: inline
In-Reply-To: <1207870471-3601-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
on 10/04/2008 Andy Fleming wrote:

> TBIPA needs to be set to a value (on connected MDIO buses) that doesn't
> conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were preventing
> boards with PHYs at 0x1f from working properly.  Instead, scan the bus when
> it comes up, and find an address that doesn't have a PHY on it.  The TBI PHY
> configuration code then trusts that the value in TBIPA is either safe, or
> doesn't matter (ie - it's not an active bus with other PHYs).
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> 
> I think this should go in, but I'd like to see some testing first.  I don't
> have hardware which is affected by this.  I've only confirmed that it doesn't
> break current hardware.

I've tested on a board with the primary PHY at 0x1f, and it seems OK.

I'f I'm understanding this correctly, you are explicitly setting TBIPA
to zero, doing a bus walk but excluding zero, and then assigning the
found free address, which re-opens zero to be used by a real PHY.

I've made some changes to what you'd sent out, those being:
	-changed the "if (i < 0) return -EBUSY to "i == 0"
	-remove the now unused TBIPA_VALUE define
	-remove the prototypes from gianfar.c now that you've
	 added them into gianfar.h
	-factor out the code to read the PHY ID so we don't have
	 it duplicated in two places.

Thanks,
Paul.

------

>From 51389f8ca0ed0f45dcb1038069d07bdd32a55c14 Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 11 Apr 2008 11:21:32 -0400
Subject: [PATCH] phylib: factor out get_phy_id from within get_phy_device

We were already doing what amounts to a get_phy_id from within
get_phy_device, and rather than duplicate this for the TBIPA
probing, we might as well just factor it out and make it available
instead.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/phy/phy_device.c |   38 +++++++++++++++++++++++++++++---------
 include/linux/phy.h          |    1 +
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f4c4fd8..8b1121b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -86,35 +86,55 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 EXPORT_SYMBOL(phy_device_create);
 
 /**
- * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * get_phy_id - reads the specified addr for its ID.
  * @bus: the target MII bus
  * @addr: PHY address on the MII bus
+ * @phy_id: where to store the ID retrieved.
  *
  * Description: Reads the ID registers of the PHY at @addr on the
- *   @bus, then allocates and returns the phy_device to represent it.
+ *   @bus, stores it in @phy_id and returns zero on success.
  */
-struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
+int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 {
 	int phy_reg;
-	u32 phy_id;
-	struct phy_device *dev = NULL;
 
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
 	phy_reg = bus->read(bus, addr, MII_PHYSID1);
 
 	if (phy_reg < 0)
-		return ERR_PTR(phy_reg);
+		return -EIO;
 
-	phy_id = (phy_reg & 0xffff) << 16;
+	*phy_id = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
 	phy_reg = bus->read(bus, addr, MII_PHYSID2);
 
 	if (phy_reg < 0)
-		return ERR_PTR(phy_reg);
+		return -EIO;
+
+	*phy_id |= (phy_reg & 0xffff);
+
+	return 0;
+}
+
+/**
+ * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * @bus: the target MII bus
+ * @addr: PHY address on the MII bus
+ *
+ * Description: Reads the ID registers of the PHY at @addr on the
+ *   @bus, then allocates and returns the phy_device to represent it.
+ */
+struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
+{
+	struct phy_device *dev = NULL;
+	u32 phy_id;
+	int r;
 
-	phy_id |= (phy_reg & 0xffff);
+	r = get_phy_id(bus, addr, &phy_id);
+	if (r)
+		return ERR_PTR(r);
 
 	/* If the phy_id is all Fs, there is no device there */
 	if (0xffffffff == phy_id)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5e43ae7..e794c4d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -361,6 +361,7 @@ struct phy_driver {
 
 int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
-- 
1.5.4.3

>From 87b3a8137049e23b75454a6bf2b37d24622afdfa Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 11 Apr 2008 11:35:37 -0400
Subject: [PATCH] gianfar: Determine TBIPA value dynamically

TBIPA needs to be set to a value (on connected MDIO buses) that doesn't
conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were preventing
boards with PHYs at 0x1f from working properly.  Instead, scan the bus when
it comes up, and find an address that doesn't have a PHY on it.  The TBI PHY
configuration code then trusts that the value in TBIPA is either safe, or
doesn't matter (ie - it's not an active bus with other PHYs).

Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/gianfar.c     |   27 ++++++++++++++-------------
 drivers/net/gianfar.h     |    1 -
 drivers/net/gianfar_mii.c |   38 +++++++++++++++++++++++++++++++++-----
 drivers/net/gianfar_mii.h |    3 +++
 4 files changed, 50 insertions(+), 19 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 718cf77..b30809b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -130,8 +130,6 @@ static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
-extern int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id, int regnum, u16 value);
-extern int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 #ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget);
 #endif
@@ -476,24 +474,30 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
+/*
+ * Initialize TBI PHY interface for communicating with the
+ * SERDES lynx PHY on the chip.  We communicate with this PHY
+ * through the MDIO bus on each controller, treating it as a
+ * "normal" PHY at the address found in the TBIPA register.  We assume
+ * that the TBIPA register is valid.  Either the MDIO bus code will set
+ * it to a value that doesn't conflict with other PHYs on the bus, or the
+ * value doesn't matter, as there are no other PHYs on the bus.
+ */
 static void gfar_configure_serdes(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_mii __iomem *regs =
 			(void __iomem *)&priv->regs->gfar_mii_regs;
+	int tbipa = gfar_read(&priv->regs->tbipa);
 
-	/* Initialise TBI i/f to communicate with serdes (lynx phy) */
+	/* Single clk mode, mii mode off(for serdes communication) */
+	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
 
-	/* Single clk mode, mii mode off(for aerdes communication) */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_TBICON, TBICON_CLK_SELECT);
-
-	/* Supported pause and full-duplex, no half-duplex */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_ADVERTISE,
+	gfar_local_mdio_write(regs, tbipa, MII_ADVERTISE,
 			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
 			ADVERTISE_1000XPSE_ASYM);
 
-	/* ANEG enable, restart ANEG, full duplex mode, speed[1] set */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_BMCR, BMCR_ANENABLE |
+	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 }
 
@@ -540,9 +544,6 @@ static void init_registers(struct net_device *dev)
 
 	/* Initialize the Minimum Frame Length Register */
 	gfar_write(&priv->regs->minflr, MINFLR_INIT_SETTINGS);
-
-	/* Assign the TBI an address which won't conflict with the PHYs */
-	gfar_write(&priv->regs->tbipa, TBIPA_VALUE);
 }
 
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 46cd773..771aa5e 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -130,7 +130,6 @@ extern const char gfar_driver_version[];
 #define DEFAULT_RXCOUNT	16
 #define DEFAULT_RXTIME	4
 
-#define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
 #define MIIMCFG_RESET           0x80000000
 #define MIIMIND_BUSY            0x00000001
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 2432762..4f23e60 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -78,7 +78,6 @@ int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
 int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum)
-
 {
 	u16 value;
 
@@ -122,7 +121,7 @@ int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 }
 
 /* Reset the MIIM registers, and wait for the bus to free */
-int gfar_mdio_reset(struct mii_bus *bus)
+static int gfar_mdio_reset(struct mii_bus *bus)
 {
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
@@ -152,14 +151,15 @@ int gfar_mdio_reset(struct mii_bus *bus)
 }
 
 
-int gfar_mdio_probe(struct device *dev)
+static int gfar_mdio_probe(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
 	struct gianfar_mdio_data *pdata;
 	struct gfar_mii __iomem *regs;
+	struct gfar __iomem *enet_regs;
 	struct mii_bus *new_bus;
 	struct resource *r;
-	int err = 0;
+	int i, err = 0;
 
 	if (NULL == dev)
 		return -EINVAL;
@@ -199,6 +199,34 @@ int gfar_mdio_probe(struct device *dev)
 	new_bus->dev = dev;
 	dev_set_drvdata(dev, new_bus);
 
+	/*
+	 * This is mildly evil, but so is our hardware for doing this.
+	 * Also, we have to cast back to struct gfar_mii because of
+	 * definition weirdness done in gianfar.h.
+	 */
+	enet_regs = (struct gfar __iomem *)
+		((char *)regs - offsetof(struct gfar, gfar_mii_regs));
+
+	/* Scan the bus, looking for an empty spot for TBIPA */
+	gfar_write(&enet_regs->tbipa, 0);
+	for (i = PHY_MAX_ADDR; i > 0; i--) {
+		u32 phy_id;
+		int r;
+
+		r = get_phy_id(new_bus, i, &phy_id);
+		if (r)
+			return r;
+
+		if (phy_id == 0xffffffff)
+			break;
+	}
+
+	/* The bus is full.  We don't support using 31 PHYs, sorry */
+	if (i == 0)
+		return -EBUSY;
+
+	gfar_write(&enet_regs->tbipa, i);
+
 	err = mdiobus_register(new_bus);
 
 	if (0 != err) {
@@ -218,7 +246,7 @@ reg_map_fail:
 }
 
 
-int gfar_mdio_remove(struct device *dev)
+static int gfar_mdio_remove(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index b373091..2af28b1 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -41,6 +41,9 @@ struct gfar_mii {
 
 int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
+			  int regnum, u16 value);
+int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 int __init gfar_mdio_init(void);
 void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
-- 
1.5.4.3
