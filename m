From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 1/1] net: phylib: remove the length limitation of mii bus id
Date: Tue, 20 Mar 2012 12:23:06 +0800
Message-ID: <1332217386-3586-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <dong.aisheng@linaro.org>

When convert to dt, the length of old mii bus id (17 bytes) is not
sufficent to use.
For example, the bus id could be 800f0000.ethernet-1:00 in DT.

This patch removes the bus id length limitation by changing the
bus id to a const char pionter and user could dynamically set the
bus id via kasprintf function call.

Since then no users use MII_BUS_ID_SIZE any more, just remove it.

Signed-off-by: Dong Aisheng <dong.aisheng@linaro.org>
---
The simplest way may just change MII_BUS_ID_SIZE to a more bigger size,
but i'm not sure that's gonna be accepted.
So changed to remove the bus id length limitation, a lot of handwork.

Since this patch changes a lot of other ethernet drivers and i did
not have condition to test it, need each corresponding driver owners
to help review.

I just greped the macro MII_BUS_ID_SIZE in the latest kernel tree and
did the replacement.
In case any one missed(may not use MII_BUS_ID_SIZE), that driver owner
should help change it.

Only tested the fec driver on i.MX28 EVK board.
---
 arch/powerpc/platforms/82xx/ep8248e.c              |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c          |    2 +-
 drivers/net/ethernet/8390/ax88796.c                |    4 +---
 drivers/net/ethernet/adi/bfin_mac.c                |    3 +--
 drivers/net/ethernet/aeroflex/greth.c              |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    3 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |   10 +++++-----
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    4 ++--
 drivers/net/ethernet/cadence/macb.c                |    2 +-
 drivers/net/ethernet/dnet.c                        |    2 +-
 drivers/net/ethernet/ethoc.c                       |    2 +-
 drivers/net/ethernet/faraday/ftgmac100.c           |    2 +-
 drivers/net/ethernet/freescale/fec.c               |   16 +++++++++-------
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c   |    2 +-
 .../net/ethernet/freescale/fs_enet/mii-bitbang.c   |    2 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c   |    2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |    6 +++---
 drivers/net/ethernet/freescale/fsl_pq_mdio.h       |    2 +-
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/rdc/r6040.c                   |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.c              |    7 ++++---
 drivers/net/ethernet/s6gmac.c                      |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |    4 ++--
 drivers/net/ethernet/smsc/smsc9420.c               |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   10 ++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    4 ++--
 drivers/net/ethernet/ti/cpmac.c                    |   16 ++++++++--------
 drivers/net/ethernet/ti/davinci_mdio.c             |    4 ++--
 drivers/net/ethernet/toshiba/tc35815.c             |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_mdio.c        |    2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    7 ++++---
 drivers/net/phy/fixed.c                            |    2 +-
 drivers/net/phy/mdio-gpio.c                        |    2 +-
 drivers/net/phy/mdio-octeon.c                      |    2 +-
 drivers/net/phy/phy_device.c                       |    2 +-
 drivers/of/of_mdio.c                               |    5 +++--
 drivers/staging/et131x/et131x.c                    |    2 +-
 include/linux/phy.h                                |   10 ++--------
 net/dsa/slave.c                                    |    2 +-
 43 files changed, 83 insertions(+), 86 deletions(-)

diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index 10ff526..21658de 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -139,7 +139,7 @@ static int __devinit ep8248e_mdio_probe(struct platform_device *ofdev)
 
 	bus->name = "ep8248e-mdio-bitbang";
 	bus->parent = &ofdev->dev;
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	bus->id = kasprintf(GFP_KERNEL, "%x", res.start);
 
 	ret = of_mdiobus_register(bus, ofdev->dev.of_node);
 	if (ret)
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 9886296..3b55962 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -241,7 +241,7 @@ static int __devinit gpio_mdio_probe(struct platform_device *ofdev)
 	new_bus->reset = &gpio_mdio_reset;
 
 	prop = of_get_property(np, "reg", NULL);
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", *prop);
+	new_bus->id = kasprintf(GFP_KERNEL, "%x", *prop);
 	new_bus->priv = priv;
 
 	new_bus->irq = priv->mdio_irqs;
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 0f92e35..c70067c 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -623,9 +623,7 @@ static int ax_mii_init(struct net_device *dev)
 
 	ax->mii_bus->name = "ax88796_mii_bus";
 	ax->mii_bus->parent = dev->dev.parent;
-	snprintf(ax->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, pdev->id);
-
+	ax->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x", pdev->name, pdev->id);
 	ax->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!ax->mii_bus->irq) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index d812a10..77d473a 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1670,8 +1670,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	miibus->name = "bfin_mii_bus";
 	miibus->phy_mask = mii_bus_pd->phy_mask;
 
-	snprintf(miibus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, pdev->id);
+	miibus->id = kasprintf(GFP_KERNEL, "%s-%x", pdev->name, pdev->id);
 	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!miibus->irq)
 		goto out_err_irq_alloc;
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index c885aa9..df635f2 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1332,7 +1332,7 @@ static int greth_mdio_init(struct greth_private *greth)
 	}
 
 	greth->mdio->name = "greth-mdio";
-	snprintf(greth->mdio->id, MII_BUS_ID_SIZE, "%s-%d", greth->mdio->name, greth->irq);
+	greth->mdio->id = kasprintf(GFP_KERNEL, "%s-%d", greth->mdio->name, greth->irq);
 	greth->mdio->read = greth_mdio_read;
 	greth->mdio->write = greth_mdio_write;
 	greth->mdio->reset = greth_mdio_reset;
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8b95dd3..99e0ebb 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1171,8 +1171,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup->mii_bus->write = au1000_mdiobus_write;
 	aup->mii_bus->reset = au1000_mdiobus_reset;
 	aup->mii_bus->name = "au1000_eth_mii";
-	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, aup->mac_id);
+	aup->mii_bus->id =  kasprintf(GFP_KERNEL, "%s-%x", pdev->name, aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (aup->mii_bus->irq == NULL)
 		goto err_out;
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 986019b..8118878 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -787,7 +787,7 @@ static int bcm_enet_open(struct net_device *dev)
 	struct phy_device *phydev;
 	int i, ret;
 	unsigned int size;
-	char phy_id[MII_BUS_ID_SIZE + 3];
+	const char *phy_id;
 	void *p;
 	u32 val;
 
@@ -796,12 +796,12 @@ static int bcm_enet_open(struct net_device *dev)
 
 	if (priv->has_phy) {
 		/* connect to PHY */
-		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-			 priv->mac_id ? "1" : "0", priv->phy_id);
+		phy_id = kasprintf(GFP_KERNEL, PHY_ID_FMT,
+				priv->mac_id ? "1" : "0", priv->phy_id);
 
 		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
 				     PHY_INTERFACE_MODE_MII);
-
+		kfree(phy_id);
 		if (IS_ERR(phydev)) {
 			dev_err(kdev, "could not attach to PHY\n");
 			return PTR_ERR(phydev);
@@ -1727,7 +1727,7 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 		bus->priv = priv;
 		bus->read = bcm_enet_mdio_read_phylib;
 		bus->write = bcm_enet_mdio_write_phylib;
-		sprintf(bus->id, "%s-%d", pdev->name, priv->mac_id);
+		bus->id = kasprintf(GFP_KERNEL, "%s-%d", pdev->name, priv->mac_id);
 
 		/* only probe bus where we think the PHY is, because
 		 * the mdio read operation return 0 instead of 0xffff
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 084904c..7fd5654 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2259,7 +2259,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	}
 
 	sc->mii_bus->name = sbmac_mdio_string;
-	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	sc->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		pldev->name, idx);
 	sc->mii_bus->priv = sc;
 	sc->mii_bus->read = sbmac_mii_read;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d529af9..2750e49 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1328,8 +1328,8 @@ static int tg3_mdio_init(struct tg3 *tp)
 		return -ENOMEM;
 
 	tp->mdio_bus->name     = "tg3 mdio bus";
-	snprintf(tp->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
-		 (tp->pdev->bus->number << 8) | tp->pdev->devfn);
+	tp->mdio_bus->id = kasprintf(GFP_KERNEL, "%x",
+		(tp->pdev->bus->number << 8) | tp->pdev->devfn);
 	tp->mdio_bus->priv     = tp;
 	tp->mdio_bus->parent   = &tp->pdev->dev;
 	tp->mdio_bus->read     = &tg3_mdio_read;
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..62e4465 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -243,7 +243,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus->read = &macb_mdio_read;
 	bp->mii_bus->write = &macb_mdio_write;
 	bp->mii_bus->reset = &macb_mdio_reset;
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	bp->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		bp->pdev->name, bp->pdev->id);
 	bp->mii_bus->priv = bp;
 	bp->mii_bus->parent = &bp->dev->dev;
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..18c3c92 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -325,7 +325,7 @@ static int dnet_mii_init(struct dnet *bp)
 	bp->mii_bus->write = &dnet_mdio_write;
 	bp->mii_bus->reset = &dnet_mdio_reset;
 
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	bp->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		bp->pdev->name, bp->pdev->id);
 
 	bp->mii_bus->priv = bp;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 60f0e78..e9195a5 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1063,7 +1063,7 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	}
 
 	priv->mdio->name = "ethoc-mdio";
-	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "%s-%d",
+	priv->mdio->id = kasprintf(GFP_KERNEL, "%s-%d",
 			priv->mdio->name, pdev->id);
 	priv->mdio->read = ethoc_mdio_read;
 	priv->mdio->write = ethoc_mdio_write;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index fb5579a..af418cd 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1255,7 +1255,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	}
 
 	priv->mii_bus->name = "ftgmac100_mdio";
-	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "ftgmac100_mii");
+	priv->mii_bus->id = kstrdup("ftgmac100_mii", GFP_KERNEL);
 
 	priv->mii_bus->priv = netdev;
 	priv->mii_bus->read = ftgmac100_mdiobus_read;
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..6e82c2d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -961,8 +961,8 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	struct phy_device *phy_dev = NULL;
-	char mdio_bus_id[MII_BUS_ID_SIZE];
-	char phy_name[MII_BUS_ID_SIZE + 3];
+	const char *mdio_bus_id;
+	const char *phy_name;
 	int phy_id;
 	int dev_id = fep->dev_id;
 
@@ -978,7 +978,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 			continue;
 		if (dev_id--)
 			continue;
-		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
+		mdio_bus_id = kstrdup(fep->mii_bus->id, GFP_KERNEL);
 		break;
 	}
 
@@ -986,13 +986,15 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 		printk(KERN_INFO
 			"%s: no PHY, assuming direct connection to switch\n",
 			ndev->name);
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE);
+		mdio_bus_id = kstrdup("0", GFP_KERNEL);
 		phy_id = 0;
 	}
 
-	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+	phy_name= kasprintf(GFP_KERNEL, PHY_ID_FMT, mdio_bus_id, phy_id);
 	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
 			      fep->phy_interface);
+	kfree(mdio_bus_id);
+	kfree(phy_name);
 	if (IS_ERR(phy_dev)) {
 		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phy_dev);
@@ -1080,8 +1082,8 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->mii_bus->read = fec_enet_mdio_read;
 	fep->mii_bus->write = fec_enet_mdio_write;
 	fep->mii_bus->reset = fec_enet_mdio_reset;
-	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, fep->dev_id + 1);
+	fep->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
+					pdev->name, fep->dev_id +1);
 	fep->mii_bus->priv = fep;
 	fep->mii_bus->parent = &pdev->dev;
 
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
index 360a578..7724be7 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
@@ -96,7 +96,7 @@ static int mpc52xx_fec_mdio_probe(struct platform_device *of)
 		goto out_free;
 	}
 
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	bus->id = kasprintf(GFP_KERNEL, "%x", res.start);
 	bus->priv = priv;
 
 	bus->parent = dev;
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 0f2d1a7..9e6eac9 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -127,7 +127,7 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	 * we get is an int, and the odds of multiple bitbang mdio buses
 	 * is low enough that it's not worth going too crazy.
 	 */
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	bus->id = kasprintf(GFP_KERNEL, "%x", res.start);
 
 	data = of_get_property(np, "fsl,mdio-pin", &len);
 	if (!data || len != 4)
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 55bb867..5242f4d 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -134,7 +134,7 @@ static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
 	if (ret)
 		goto out_res;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	new_bus->id = kasprintf(GFP_KERNEL, "%x", res.start);
 
 	fec->fecp = ioremap(res.start, resource_size(&res));
 	if (!fec->fecp)
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9eb8159..773acd5 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -169,7 +169,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
+void fsl_pq_mdio_bus_name(char **name, struct device_node *np)
 {
 	const u32 *addr;
 	u64 taddr = OF_BAD_ADDR;
@@ -178,7 +178,7 @@ void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 	if (addr)
 		taddr = of_translate_address(np, addr);
 
-	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
+	*name = kasprintf(GFP_KERNEL, "%s@%llx", np->name,
 		(unsigned long long)taddr);
 }
 EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name);
@@ -277,7 +277,7 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 	new_bus->write = &fsl_pq_mdio_write,
 	new_bus->reset = &fsl_pq_mdio_reset,
 	new_bus->priv = priv;
-	fsl_pq_mdio_bus_name(new_bus->id, np);
+	fsl_pq_mdio_bus_name(&new_bus->id, np);
 
 	addrp = of_get_address(np, 0, &size, NULL);
 	if (!addrp) {
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.h b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
index bd17a2a..b563ef7 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.h
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
@@ -48,5 +48,5 @@ int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
 int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id, int regnum);
 int __init fsl_pq_mdio_init(void);
 void fsl_pq_mdio_exit(void);
-void fsl_pq_mdio_bus_name(char *name, struct device_node *np);
+void fsl_pq_mdio_bus_name(char **name, struct device_node *np);
 #endif /* FSL_PQ_MDIO_H */
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 85e2c6c..742e7dd 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -437,7 +437,7 @@ ltq_etop_mdio_init(struct net_device *dev)
 	priv->mii_bus->read = ltq_etop_mdio_rd;
 	priv->mii_bus->write = ltq_etop_mdio_wr;
 	priv->mii_bus->name = "ltq_mii";
-	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	priv->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		priv->pdev->name, priv->pdev->id);
 	priv->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!priv->mii_bus->irq) {
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c049d2..e18707f 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2613,7 +2613,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		msp->smi_bus->name = "mv643xx_eth smi";
 		msp->smi_bus->read = smi_bus_read;
 		msp->smi_bus->write = smi_bus_write,
-		snprintf(msp->smi_bus->id, MII_BUS_ID_SIZE, "%s-%d",
+		msp->smi_bus->id = kasprintf(GFP_KERNEL, "%s-%d",
 			pdev->name, pdev->id);
 		msp->smi_bus->parent = &pdev->dev;
 		msp->smi_bus->phy_mask = 0xffffffff;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..bf19af7 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1552,7 +1552,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	pep->smi_bus->name = "pxa168_eth smi";
 	pep->smi_bus->read = pxa168_smi_read;
 	pep->smi_bus->write = pxa168_smi_write;
-	snprintf(pep->smi_bus->id, MII_BUS_ID_SIZE, "%s-%d",
+	pep->smi_bus->id = kasprintf(GFP_KERNEL, "%s-%d",
 		pdev->name, pdev->id);
 	pep->smi_bus->parent = &pdev->dev;
 	pep->smi_bus->phy_mask = 0xffffffff;
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb0eca8..9d890b2 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1181,8 +1181,8 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->mii_bus->write = r6040_mdiobus_write;
 	lp->mii_bus->reset = r6040_mdiobus_reset;
 	lp->mii_bus->name = "r6040_eth_mii";
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		dev_name(&pdev->dev), card_idx);
+	lp->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
+			dev_name(&pdev->dev), card_idx);
 	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!lp->mii_bus->irq) {
 		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 813d41c..3210fd9 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1213,10 +1213,10 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 static int sh_eth_phy_init(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	char phy_id[MII_BUS_ID_SIZE + 3];
+	const char *phy_id;
 	struct phy_device *phydev = NULL;
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+	phy_id = kasprintf(GFP_KERNEL, PHY_ID_FMT,
 		mdp->mii_bus->id , mdp->phy_id);
 
 	mdp->link = PHY_DOWN;
@@ -1226,6 +1226,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 	/* Try connect to PHY */
 	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
 				0, mdp->phy_interface);
+	kfree(phy_id);
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
@@ -1702,7 +1703,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = &ndev->dev;
-	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	mdp->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		mdp->pdev->name, id);
 
 	/* PHY IRQ */
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 22e9c01..dd5f29b 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1004,7 +1004,7 @@ static int __devinit s6gmac_probe(struct platform_device *pdev)
 	mb->write = s6mii_write;
 	mb->reset = s6mii_reset;
 	mb->priv = pd;
-	snprintf(mb->id, MII_BUS_ID_SIZE, "%s-%x", pdev->name, pdev->id);
+	mb->id = kasprintf(GFP_KERNEL, "%s-%x", pdev->name, pdev->id);
 	mb->phy_mask = ~(1 << 0);
 	mb->irq = &pd->mii.irq[0];
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 24d2df0..4aab696 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1044,8 +1044,8 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	}
 
 	pdata->mii_bus->name = SMSC_MDIONAME;
-	snprintf(pdata->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, pdev->id);
+	pdata->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
+			pdev->name, pdev->id);
 	pdata->mii_bus->priv = pdata;
 	pdata->mii_bus->read = smsc911x_mii_read;
 	pdata->mii_bus->write = smsc911x_mii_write;
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..bffd175 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1211,7 +1211,7 @@ static int smsc9420_mii_init(struct net_device *dev)
 		goto err_out_1;
 	}
 	pd->mii_bus->name = DRV_MDIONAME;
-	snprintf(pd->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+	pd->mii_bus->id = kasprintf(GFP_KERNEL, "%x",
 		(pd->pdev->bus->number << 8) | pd->pdev->devfn);
 	pd->mii_bus->priv = pd;
 	pd->mii_bus->read = smsc9420_mii_read;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..c72a50e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -300,19 +300,21 @@ static int stmmac_init_phy(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev;
-	char phy_id[MII_BUS_ID_SIZE + 3];
-	char bus_id[MII_BUS_ID_SIZE];
+	const char *phy_id;
+	const char *bus_id;
 	int interface = priv->plat->interface;
 	priv->oldlink = 0;
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x", priv->plat->bus_id);
-	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+	bus_id = kasprintf(GFP_KERNEL, "stmmac-%x", priv->plat->bus_id);
+	phy_id = kasprintf(GFP_KERNEL, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
 	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0, interface);
+	kfree(phy_id);
+	kfree(bus_id);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index da4a104..6a72265 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -158,8 +158,8 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->read = &stmmac_mdio_read;
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		new_bus->name, mdio_bus_data->bus_id);
+	new_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
+			new_bus->name, mdio_bus_data->bus_id);
 	new_bus->priv = ndev;
 	new_bus->irq = irqlist;
 	new_bus->phy_mask = mdio_bus_data->phy_mask;
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 4d9a28f..b448cca 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -205,7 +205,7 @@ struct cpmac_priv {
 	void __iomem *regs;
 	struct mii_bus *mii_bus;
 	struct phy_device *phy;
-	char phy_name[MII_BUS_ID_SIZE + 3];
+	const char *phy_name;
 	int oldlink, oldspeed, oldduplex;
 	u32 msg_enable;
 	struct net_device *dev;
@@ -1113,7 +1113,7 @@ static int external_switch;
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id;
-	char mdio_bus_id[MII_BUS_ID_SIZE];
+	const char *mdio_bus_id;
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
@@ -1122,7 +1122,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	pdata = pdev->dev.platform_data;
 
 	if (external_switch || dumb_switch) {
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
+		mdio_bus_id = kstrdup("0", GFP_KERNEL); /* fixed phys bus */
 		phy_id = pdev->id;
 	} else {
 		for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
@@ -1130,7 +1130,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 				continue;
 			if (!cpmac_mii->phy_map[phy_id])
 				continue;
-			strncpy(mdio_bus_id, cpmac_mii->id, MII_BUS_ID_SIZE);
+			mdio_bus_id = kstrdup(cpmac_mii->id, GFP_KERNEL);
 			break;
 		}
 	}
@@ -1138,7 +1138,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	if (phy_id == PHY_MAX_ADDR) {
 		dev_err(&pdev->dev, "no PHY present, falling back "
 					"to switch on MDIO bus 0\n");
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
+		mdio_bus_id = kstrdup("0", GFP_KERNEL); /* fixed phys bus */
 		phy_id = pdev->id;
 	}
 
@@ -1173,8 +1173,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(pdata->dev_addr));
 
-	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT,
-						mdio_bus_id, phy_id);
+	priv->phy_name= kasprintf(GFP_KERNEL, PHY_ID_FMT, mdio_bus_id, phy_id);
+	kfree(mdio_bus_id);
 
 	priv->phy = phy_connect(dev, priv->phy_name, cpmac_adjust_link, 0,
 						PHY_INTERFACE_MODE_MII);
@@ -1269,7 +1269,7 @@ int __devinit cpmac_init(void)
 	}
 
 	cpmac_mii->phy_mask = ~(mask | 0x80000000);
-	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "cpmac-1");
+	cpmac_mii->id = kstrdup("cpmac-1", GFP_KERNEL);
 
 	res = mdiobus_register(cpmac_mii);
 	if (res)
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index ef7c9c1..67ddf87 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -313,8 +313,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->reset	= davinci_mdio_reset,
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
-	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		pdev->name, pdev->id);
+	data->bus->id = kasprintf(GFP_KERNEL, "%s-%x",
+			pdev->name, pdev->id);
 
 	data->clk = clk_get(dev, NULL);
 	if (IS_ERR(data->clk)) {
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..8ffacd6 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -682,7 +682,7 @@ static int tc_mii_init(struct net_device *dev)
 	lp->mii_bus->name = "tc35815_mii_bus";
 	lp->mii_bus->read = tc_mdio_read;
 	lp->mii_bus->write = tc_mdio_write;
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+	lp->mii_bus->id = kasprintf(GFP_KERNEL, "%x",
 		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
 	lp->mii_bus->priv = dev;
 	lp->mii_bus->parent = &lp->pci_dev->dev;
diff --git a/drivers/net/ethernet/xilinx/ll_temac_mdio.c b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
index 8cf9d4f..aa9d0d5 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_mdio.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
@@ -86,7 +86,7 @@ int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 		return -ENOMEM;
 
 	of_address_to_resource(np, 0, &res);
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
+	bus->id = kasprintf(GFP_KERNEL, "%.8llx",
 		 (unsigned long long)res.start);
 	bus->priv = lp;
 	bus->name = "Xilinx TEMAC MDIO";
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 79013e5..c476861 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -866,7 +866,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 		return -ENOMEM;
 
 	of_address_to_resource(np, 0, &res);
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
+	bus->id = kasprintf(GFP_KERNEL, "%.8llx",
 		 (unsigned long long)res.start);
 	bus->priv = lp;
 	bus->name = "Xilinx Emaclite MDIO";
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 72a854f..3794959 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -529,7 +529,7 @@ static int ixp4xx_mdio_register(void)
 	mdio_bus->name = "IXP4xx MII Bus";
 	mdio_bus->read = &ixp4xx_mdio_read;
 	mdio_bus->write = &ixp4xx_mdio_write;
-	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "ixp4xx-eth-0");
+	mdio_bus->id = kstrdup("ixp4xx-eth-0", GFP_KERNEL);
 
 	if ((err = mdiobus_register(mdio_bus)))
 		mdiobus_free(mdio_bus);
@@ -1353,7 +1353,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	struct net_device *dev;
 	struct eth_plat_info *plat = pdev->dev.platform_data;
 	u32 regs_phys;
-	char phy_id[MII_BUS_ID_SIZE + 3];
+	const char *phy_id;
 	int err;
 
 	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
@@ -1416,9 +1416,10 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	__raw_writel(DEFAULT_CORE_CNTRL, &port->regs->core_control);
 	udelay(50);
 
-	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
+	phy_id = kasprintf(GFP_KERNEL, PHY_ID_FMT, "0", plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
+	kfree(phy_id);
 	if (IS_ERR(port->phydev)) {
 		err = PTR_ERR(port->phydev);
 		goto err_free_mem;
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 633680d..947c7e1 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -220,7 +220,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_mdiobus_reg;
 	}
 
-	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "fixed-0");
+	fmb->mii_bus->id = kstrdup("fixed-0", GFP_KERNEL);
 	fmb->mii_bus->name = "Fixed MDIO Bus";
 	fmb->mii_bus->priv = fmb;
 	fmb->mii_bus->parent = &pdev->dev;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 50e8e5e..0a89f0b 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -116,7 +116,7 @@ static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
 		if (!new_bus->irq[i])
 			new_bus->irq[i] = PHY_POLL;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
+	new_bus->id = kasprintf(GFP_KERNEL, "gpio-%x", bus_id);
 
 	if (gpio_request(bitbang->mdc, "mdc"))
 		goto out_free_bus;
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 826d961..1158353 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -118,7 +118,7 @@ static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 	bus->mii_bus->priv = bus;
 	bus->mii_bus->irq = bus->phy_irq;
 	bus->mii_bus->name = "mdio-octeon";
-	snprintf(bus->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+	bus->mii_bus->id = kasprintf(GFP_KERNEL, "%s-%x",
 		bus->mii_bus->name, bus->unit);
 	bus->mii_bus->parent = &pdev->dev;
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f320f46..6879e86 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -78,7 +78,7 @@ int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 	if (!fixup)
 		return -ENOMEM;
 
-	strlcpy(fixup->bus_id, bus_id, sizeof(fixup->bus_id));
+	fixup->bus_id = kstrdup(bus_id, GFP_KERNEL);
 	fixup->phy_uid = phy_uid;
 	fixup->phy_uid_mask = phy_uid_mask;
 	fixup->run = run;
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 980c079..4150655 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -166,7 +166,7 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 					     phy_interface_t iface)
 {
 	struct device_node *net_np;
-	char bus_id[MII_BUS_ID_SIZE + 3];
+	const char *bus_id;
 	struct phy_device *phy;
 	const __be32 *phy_id;
 	int sz;
@@ -182,9 +182,10 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 	if (!phy_id || sz < sizeof(*phy_id))
 		return NULL;
 
-	sprintf(bus_id, PHY_ID_FMT, "0", be32_to_cpu(phy_id[0]));
+	bus_id = kasprintf(GFP_KERNEL, PHY_ID_FMT, "0", be32_to_cpu(phy_id[0]));
 
 	phy = phy_connect(dev, bus_id, hndlr, 0, iface);
+	kfree(bus_id);
 	return IS_ERR(phy) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect_fixed_link);
diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 2c4069f..5199386 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -5358,7 +5358,7 @@ static int __devinit et131x_pci_setup(struct pci_dev *pdev,
 	}
 
 	adapter->mii_bus->name = "et131x_eth_mii";
-	snprintf(adapter->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+	adapter->mii_bus->id = kasprintf(GFP_KERNEL, "%x",
 		(adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
 	adapter->mii_bus->priv = netdev;
 	adapter->mii_bus->read = et131x_mdio_read;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c599f7e..bf051a7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -78,12 +78,6 @@ typedef enum {
 /* Used when trying to connect to a specific phy (mii bus id:phy device id) */
 #define PHY_ID_FMT "%s:%02x"
 
-/*
- * Need to be a little smaller than phydev->dev.bus_id to leave room
- * for the ":%02x"
- */
-#define MII_BUS_ID_SIZE	(20 - 3)
-
 /* Or MII_ADDR_C45 into regnum for read/write on mii_bus to enable the 21 bit
    IEEE 802.3ae clause 45 addressing mode used by 10GIGE phy chips. */
 #define MII_ADDR_C45 (1<<30)
@@ -94,7 +88,7 @@ typedef enum {
  */
 struct mii_bus {
 	const char *name;
-	char id[MII_BUS_ID_SIZE];
+	const char *id;
 	void *priv;
 	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
@@ -441,7 +435,7 @@ struct phy_driver {
 /* A Structure for boards to register fixups with the PHY Lib */
 struct phy_fixup {
 	struct list_head list;
-	char bus_id[20];
+	const char *bus_id;
 	u32 phy_uid;
 	u32 phy_uid_mask;
 	int (*run)(struct phy_device *phydev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 56cf9b8..ae0e3ea 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -41,7 +41,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->name = "dsa slave smi";
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
-	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x",
+	ds->slave_mii_bus->id = kasprintf(GFP_KERNEL, "%s:%.2x",
 			ds->master_mii_bus->id, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
-- 
1.7.0.4
