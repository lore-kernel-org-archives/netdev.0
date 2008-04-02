From: Andy Fleming <afleming@freescale.com>
Subject: [RFC] Change mii_bus id field to a string
Date: Wed,  2 Apr 2008 17:49:52 -0500
Message-ID: <1207176592-4224-1-git-send-email-afleming@freescale.com>
Cc: ncase@xes-inc.com, Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:38916 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755792AbYDBWuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 18:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the id field be an int was making more complex bus topologies
excessively difficult.  For now, just convert it to a string, and
change all "bus->id = val" to snprintf(id, MII_BUS_ID_LEN, "%x", val).
---

At the very least this needs to be tested by the various driver maintainers.

 arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    2 +-
 arch/powerpc/sysdev/fsl_soc.c             |    5 ++-
 drivers/net/au1000_eth.c                  |    6 ++--
 drivers/net/bfin_mac.c                    |    2 +-
 drivers/net/cpmac.c                       |    5 +--
 drivers/net/fec_mpc52xx.c                 |    2 +-
 drivers/net/fec_mpc52xx_phy.c             |    2 +-
 drivers/net/fs_enet/fs_enet-main.c        |    4 +-
 drivers/net/fs_enet/mii-bitbang.c         |    4 +-
 drivers/net/fs_enet/mii-fec.c             |    4 +-
 drivers/net/gianfar_mii.c                 |    2 +-
 drivers/net/macb.c                        |    2 +-
 drivers/net/pasemi_mac.c                  |    2 +-
 drivers/net/phy/fixed.c                   |    2 +-
 drivers/net/sb1250-mac.c                  |    2 +-
 drivers/net/ucc_geth.c                    |    2 +-
 drivers/net/ucc_geth.h                    |    2 +-
 drivers/net/ucc_geth_mii.c                |    2 +-
 include/linux/fsl_devices.h               |    2 +-
 include/linux/phy.h                       |   57 +++++++++++++++++++----------
 21 files changed, 66 insertions(+), 47 deletions(-)

diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index ba93d8a..d5770fd 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -138,7 +138,7 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 
 	bus->name = "ep8248e-mdio-bitbang";
 	bus->dev = &ofdev->dev;
-	bus->id = res.start;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	return mdiobus_register(bus);
 }
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index b465429..ab69554 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -241,7 +241,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	new_bus->reset = &gpio_mdio_reset;
 
 	prop = of_get_property(np, "reg", NULL);
-	new_bus->id = *prop;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", *prop);
 	new_bus->priv = priv;
 
 	new_bus->phy_mask = 0;
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 2c5388c..3581416 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -341,7 +341,7 @@ static int __init gfar_of_init(void)
 				goto unreg;
 			}
 
-			gfar_data.bus_id = 0;
+			snprintf(gfar_data.bus_id, MII_BUS_ID_SIZE, "0");
 			gfar_data.phy_id = fixed_link[0];
 		} else {
 			phy = of_find_node_by_phandle(*ph);
@@ -362,7 +362,8 @@ static int __init gfar_of_init(void)
 			}
 
 			gfar_data.phy_id = *id;
-			gfar_data.bus_id = res.start;
+			snprintf(gfar_data.bus_id, MII_BUS_ID_SIZE, "%x",
+					res.start);
 
 			of_node_put(phy);
 			of_node_put(mdio);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 504b7ce..3634b5f 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -701,7 +701,7 @@ static struct net_device * au1000_probe(int port_num)
 	aup->mii_bus.write = mdiobus_write;
 	aup->mii_bus.reset = mdiobus_reset;
 	aup->mii_bus.name = "au1000_eth_mii";
-	aup->mii_bus.id = aup->mac_id;
+	snprintf(aup->mii_bus.id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
 	aup->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus.irq[i] = PHY_POLL;
@@ -709,11 +709,11 @@ static struct net_device * au1000_probe(int port_num)
 	/* if known, set corresponding PHY IRQs */
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
 # if defined(AU1XXX_PHY0_IRQ)
-	if (AU1XXX_PHY0_BUSID == aup->mii_bus.id)
+	if (AU1XXX_PHY0_BUSID == aup->mac_id)
 		aup->mii_bus.irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
 # endif
 # if defined(AU1XXX_PHY1_IRQ)
-	if (AU1XXX_PHY1_BUSID == aup->mii_bus.id)
+	if (AU1XXX_PHY1_BUSID == aup->mac_id)
 		aup->mii_bus.irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
 # endif
 #endif
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c993a32..da1867c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -971,7 +971,7 @@ static int __init bf537mac_probe(struct net_device *dev)
 	lp->mii_bus.write = mdiobus_write;
 	lp->mii_bus.reset = mdiobus_reset;
 	lp->mii_bus.name = "bfin_mac_mdio";
-	lp->mii_bus.id = 0;
+	snprintf(lp->mii_bus.id, MII_BUS_ID_SIZE, "0");
 	lp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		lp->mii_bus.irq[i] = PHY_POLL;
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index c85194f..9da7ff4 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -987,7 +987,7 @@ static int external_switch;
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id, i;
-	int mdio_bus_id = cpmac_mii.id;
+	char *mdio_bus_id = "0";
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
@@ -1008,8 +1008,6 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 		if (external_switch || dumb_switch) {
 			struct fixed_phy_status status = {};
 
-			mdio_bus_id = 0;
-
 			/*
 			 * FIXME: this should be in the platform code!
 			 * Since there is not platform code at all (that is,
@@ -1143,6 +1141,7 @@ int __devinit cpmac_init(void)
 	}
 
 	cpmac_mii.phy_mask = ~(mask | 0x80000000);
+	snprintf(cpmac_mii.id, MII_BUS_ID_SIZE, "0");
 
 	res = mdiobus_register(&cpmac_mii);
 	if (res)
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 58b71e6..43b5f30 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -198,7 +198,7 @@ static int mpc52xx_fec_init_phy(struct net_device *dev)
 	struct phy_device *phydev;
 	char phy_id[BUS_ID_SIZE];
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+	snprintf(phy_id, BUS_ID_SIZE, "%x:%02x",
 			(unsigned int)dev->base_addr, priv->phy_addr);
 
 	priv->link = PHY_DOWN;
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 1837584..994473b 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -123,7 +123,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct of_device_i
 		goto out_free;
 	}
 
-	bus->id = res.start;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 	bus->priv = priv;
 
 	bus->dev = dev;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index af869cf..44a1f30 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1177,7 +1177,7 @@ static int __devinit find_phy(struct device_node *np,
 
 	data  = of_get_property(np, "fixed-link", NULL);
 	if (data) {
-		snprintf(fpi->bus_id, 16, PHY_ID_FMT, 0, *data);
+		snprintf(fpi->bus_id, 16, "%x:%02x", 0, *data);
 		return 0;
 	}
 
@@ -1201,7 +1201,7 @@ static int __devinit find_phy(struct device_node *np,
 	if (!data || len != 4)
 		goto out_put_mdio;
 
-	snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
+	snprintf(fpi->bus_id, 16, "%x:%02x", res.start, *data);
 
 out_put_mdio:
 	of_node_put(mdionode);
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index b8e4a73..1620030 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -130,7 +130,7 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	 * we get is an int, and the odds of multiple bitbang mdio buses
 	 * is low enough that it's not worth going too crazy.
 	 */
-	bus->id = res.start;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	data = of_get_property(np, "fsl,mdio-pin", &len);
 	if (!data || len != 4)
@@ -307,7 +307,7 @@ static int __devinit fs_enet_mdio_probe(struct device *dev)
 		return -ENOMEM;
 
 	new_bus->name = "BB MII Bus",
-	new_bus->id = pdev->id;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
 
 	new_bus->phy_mask = ~0x9;
 	pdata = (struct fs_mii_bb_platform_info *)pdev->dev.platform_data;
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index a89cf15..ba75efc 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -196,7 +196,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (ret)
 		return ret;
 
-	new_bus->id = res.start;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	fec->fecp = ioremap(res.start, res.end - res.start + 1);
 	if (!fec->fecp)
@@ -309,7 +309,7 @@ static int __devinit fs_enet_fec_mdio_probe(struct device *dev)
 	new_bus->read = &fs_enet_fec_mii_read,
 	new_bus->write = &fs_enet_fec_mii_write,
 	new_bus->reset = &fs_enet_fec_mii_reset,
-	new_bus->id = pdev->id;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
 
 	pdata = (struct fs_mii_fec_platform_info *)pdev->dev.platform_data;
 
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 2432762..b889892 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -173,7 +173,7 @@ int gfar_mdio_probe(struct device *dev)
 	new_bus->read = &gfar_mdio_read,
 	new_bus->write = &gfar_mdio_write,
 	new_bus->reset = &gfar_mdio_reset,
-	new_bus->id = pdev->id;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
 
 	pdata = (struct gianfar_mdio_data *)pdev->dev.platform_data;
 
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d210ed..06e860b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -246,7 +246,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus.read = &macb_mdio_read,
 	bp->mii_bus.write = &macb_mdio_write,
 	bp->mii_bus.reset = &macb_mdio_reset,
-	bp->mii_bus.id = bp->pdev->id,
+	snprintf(bp->mii_bus.id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
 	bp->mii_bus.priv = bp,
 	bp->mii_bus.dev = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 2e39e02..bcd7f98 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1012,7 +1012,7 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 		goto err;
 
 	phy_id = *prop;
-	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, (int)r.start, phy_id);
+	snprintf(mac->phy_id, BUS_ID_SIZE, "%x:%02x", (int)r.start, phy_id);
 
 	of_node_put(phy_dn);
 
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index ca9b040..4e07956 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -213,7 +213,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_pdev;
 	}
 
-	fmb->mii_bus.id = 0;
+	snprintf(fmb->mii_bus.id, MII_BUS_ID_SIZE, "0");
 	fmb->mii_bus.name = "Fixed MDIO Bus";
 	fmb->mii_bus.dev = &pdev->dev;
 	fmb->mii_bus.read = &fixed_mdio_read;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 7b53d65..888b7de 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2374,7 +2374,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	       dev->name, base, print_mac(mac, eaddr));
 
 	sc->mii_bus.name = sbmac_mdio_string;
-	sc->mii_bus.id = idx;
+	snprintf(sc->mii_bus.id, MII_BUS_ID_SIZE, "%x", idx);
 	sc->mii_bus.priv = sc;
 	sc->mii_bus.read = sbmac_mii_read;
 	sc->mii_bus.write = sbmac_mii_write;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8cc3166..0ae3cbd 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3991,7 +3991,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	if (err)
 		return -1;
 
-	ug_info->mdio_bus = res.start;
+	snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "%x", res.start);
 
 	if (netif_msg_probe(&debug))
 		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 4fb95b3..9f8b758 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1156,7 +1156,7 @@ struct ucc_geth_info {
 	u16 pausePeriod;
 	u16 extensionField;
 	u8 phy_address;
-	u32 mdio_bus;
+	char mdio_bus[MII_BUS_ID_SIZE];
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index c69e654..e4d3f33 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -157,7 +157,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 	if (err)
 		goto reg_map_fail;
 
-	new_bus->id = res.start;
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	new_bus->irq = kmalloc(32 * sizeof(int), GFP_KERNEL);
 
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 1831b19..2cad5c6 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -50,7 +50,7 @@ struct gianfar_platform_data {
 	u32	device_flags;
 	/* board specific information */
 	u32	board_flags;
-	u32	bus_id;
+	char	bus_id[MII_BUS_ID_SIZE];
 	u32	phy_id;
 	u8	mac_addr[6];
 	phy_interface_t interface;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5e43ae7..92a4829 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -63,8 +63,6 @@ typedef enum {
 	PHY_INTERFACE_MODE_RTBI
 } phy_interface_t;
 
-#define MII_BUS_MAX 4
-
 
 #define PHY_INIT_TIMEOUT	100000
 #define PHY_STATE_TIME		1
@@ -74,20 +72,30 @@ typedef enum {
 #define PHY_MAX_ADDR	32
 
 /* Used when trying to connect to a specific phy (mii bus id:phy device id) */
-#define PHY_ID_FMT "%x:%02x"
+#define PHY_ID_FMT "%s:%02x"
+
+/*
+ * Need to be a little smaller than phydev->dev.bus_id to leave room
+ * for the ":%02x"
+ */
+#define MII_BUS_ID_SIZE	BUS_ID_SIZE - 3
 
-/* The Bus class for PHYs.  Devices which provide access to
- * PHYs should register using this structure */
+/*
+ * The Bus class for PHYs.  Devices which provide access to
+ * PHYs should register using this structure
+ */ 
 struct mii_bus {
 	const char *name;
-	int id;
+	char id[MII_BUS_ID_SIZE];
 	void *priv;
 	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
 
-	/* A lock to ensure that only one thing can read/write
-	 * the MDIO bus at a time */
+	/*
+	 * A lock to ensure that only one thing can read/write
+	 * the MDIO bus at a time
+	 */
 	struct mutex mdio_lock;
 
 	struct device *dev;
@@ -98,8 +106,10 @@ struct mii_bus {
 	/* Phy addresses to be ignored when probing */
 	u32 phy_mask;
 
-	/* Pointer to an array of interrupts, each PHY's
-	 * interrupt at the index matching its address */
+	/*
+	 * Pointer to an array of interrupts, each PHY's
+	 * interrupt at the index matching its address
+	 */
 	int *irq;
 };
 
@@ -251,7 +261,8 @@ struct phy_device {
 	/* Bus address of the PHY (0-32) */
 	int addr;
 
-	/* forced speed & duplex (no autoneg)
+	/*
+	 * forced speed & duplex (no autoneg)
 	 * partner speed & duplex & pause (autoneg)
 	 */
 	int speed;
@@ -274,8 +285,10 @@ struct phy_device {
 
 	int link_timeout;
 
-	/* Interrupt number for this PHY
-	 * -1 means no interrupt */
+	/*
+	 * Interrupt number for this PHY
+	 * -1 means no interrupt
+	 */
 	int irq;
 
 	/* private data pointer */
@@ -325,22 +338,28 @@ struct phy_driver {
 	u32 features;
 	u32 flags;
 
-	/* Called to initialize the PHY,
-	 * including after a reset */
+	/*
+	 * Called to initialize the PHY,
+	 * including after a reset
+	 */
 	int (*config_init)(struct phy_device *phydev);
 
-	/* Called during discovery.  Used to set
-	 * up device-specific structures, if any */
+	/*
+	 * Called during discovery.  Used to set
+	 * up device-specific structures, if any
+	 */
 	int (*probe)(struct phy_device *phydev);
 
 	/* PHY Power Management */
 	int (*suspend)(struct phy_device *phydev);
 	int (*resume)(struct phy_device *phydev);
 
-	/* Configures the advertisement and resets
+	/*
+	 * Configures the advertisement and resets
 	 * autonegotiation if phydev->autoneg is on,
 	 * forces the speed to the current settings in phydev
-	 * if phydev->autoneg is off */
+	 * if phydev->autoneg is off
+	 */
 	int (*config_aneg)(struct phy_device *phydev);
 
 	/* Determines the negotiated speed and duplex */
-- 
1.5.4.23.gef5b9

