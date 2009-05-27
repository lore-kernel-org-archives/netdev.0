From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6]: Get rid of BUS_ID_SIZE in networking
Date: Wed, 27 May 2009 16:53:18 -0700 (PDT)
Message-ID: <20090527.165318.122791879.davem@davemloft.net>
References: <20090526.213942.196879926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbZE0XxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 19:53:19 -0400
In-Reply-To: <20090526.213942.196879926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 26 May 2009 21:39:42 -0700 (PDT)

> I had this glorious and ambitious patch almost finished that tried to
> tackle the MII_BUS_ID_SIZE thing by similarly implementing dynamic
> string lengths there but I gave up. :-)

For anyone so inclined, here is how far I got with those changes:

diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index 0eb6d7f..8e3e1e7 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -138,7 +138,7 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 
 	bus->name = "ep8248e-mdio-bitbang";
 	bus->parent = &ofdev->dev;
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	dev_set_name(&bus->dev, "%x", res.start);
 
 	return mdiobus_register(bus);
 }
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 75cc165..d34591a 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -241,7 +241,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	new_bus->reset = &gpio_mdio_reset;
 
 	prop = of_get_property(np, "reg", NULL);
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", *prop);
+	dev_set_name(&new_bus->dev, "%x", *prop);
 	new_bus->priv = priv;
 
 	new_bus->phy_mask = 0;
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 5fe17d5..6d45ed2 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -343,7 +343,7 @@ static int ixp4xx_mdio_register(void)
 	mdio_bus->name = "IXP4xx MII Bus";
 	mdio_bus->read = &ixp4xx_mdio_read;
 	mdio_bus->write = &ixp4xx_mdio_write;
-	strcpy(mdio_bus->id, "0");
+	dev_set_name(&mdio_bus->dev, "0");
 
 	if ((err = mdiobus_register(mdio_bus)))
 		mdiobus_free(mdio_bus);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 4274e4a..df4ac9c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1143,7 +1143,7 @@ static struct net_device * au1000_probe(int port_num)
 	aup->mii_bus->write = au1000_mdiobus_write;
 	aup->mii_bus->reset = au1000_mdiobus_reset;
 	aup->mii_bus->name = "au1000_eth_mii";
-	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
+	dev_set_name(&aup->mii_bus->dev, "%x", aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 9afe809..b12ee78 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1066,7 +1066,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	lp->mii_bus->write = bfin_mdiobus_write;
 	lp->mii_bus->reset = bfin_mdiobus_reset;
 	lp->mii_bus->name = "bfin_mac_mdio";
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	dev_set_name(&lp->mii_bus->dev, "0");
 	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		lp->mii_bus->irq[i] = PHY_POLL;
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 3f476c7..c71fe68 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1249,7 +1249,7 @@ int __devinit cpmac_init(void)
 	}
 
 	cpmac_mii->phy_mask = ~(mask | 0x80000000);
-	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "0");
+	dev_set_name(&cpmac_mii->dev, "0");
 
 	res = mdiobus_register(cpmac_mii);
 	if (res)
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index db1e31f..5d041ca 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -325,7 +325,7 @@ static int dnet_mii_init(struct dnet *bp)
 	bp->mii_bus->write = &dnet_mdio_write;
 	bp->mii_bus->reset = &dnet_mdio_reset;
 
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);
+	dev_set_name(&bp->mii_bus->dev, "%x", 0);
 
 	bp->mii_bus->priv = bp;
 
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 91a9b1a..b1a641e 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -979,8 +979,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	priv->mdio->name = "ethoc-mdio";
-	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "%s-%d",
-			priv->mdio->name, pdev->id);
+	dev_set_name(&priv->mdio->dev, "%s-%d", priv->mdio->name, pdev->id);
 	priv->mdio->read = ethoc_mdio_read;
 	priv->mdio->write = ethoc_mdio_write;
 	priv->mdio->reset = ethoc_mdio_reset;
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index dd9bfa4..1d5fc13 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -112,7 +112,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 		goto out_free;
 	}
 
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	dev_set_name(&bus->dev, "%x", res.start);
 	bus->priv = priv;
 
 	bus->parent = dev;
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 49b6645..489bd6a 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -126,7 +126,7 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	 * we get is an int, and the odds of multiple bitbang mdio buses
 	 * is low enough that it's not worth going too crazy.
 	 */
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	dev_set_name(&bus->dev, "%x", res.start);
 
 	data = of_get_property(np, "fsl,mdio-pin", &len);
 	if (!data || len != 4)
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 28077cc..e99de9a 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -146,7 +146,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (ret)
 		goto out_res;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	dev_set_name(&new_bus->dev, "%x", res.start);
 
 	fec->fecp = ioremap(res.start, res.end - res.start + 1);
 	if (!fec->fecp)
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index b3079a5..f89e85f 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -192,7 +192,7 @@ static int *create_irq_map(struct device_node *np)
 	return irqs;
 }
 
-void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
+void fsl_pq_mdio_bus_name(const struct device *dev, struct device_node *np)
 {
 	const u32 *addr;
 	u64 taddr = OF_BAD_ADDR;
@@ -201,8 +201,7 @@ void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 	if (addr)
 		taddr = of_translate_address(np, addr);
 
-	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
-		(unsigned long long)taddr);
+	dev_set_name(dev, "%s@%llx", np->name, (unsigned long long)taddr);
 }
 
 /* Scan the bus in reverse, looking for an empty spot */
@@ -301,7 +300,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	new_bus->read = &fsl_pq_mdio_read,
 	new_bus->write = &fsl_pq_mdio_write,
 	new_bus->reset = &fsl_pq_mdio_reset,
-	fsl_pq_mdio_bus_name(new_bus->id, np);
+	fsl_pq_mdio_bus_name(&new_bus->dev, np);
 
 	/* Set the PHY base address */
 	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f505010..d989980 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -254,7 +254,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus->read = &macb_mdio_read;
 	bp->mii_bus->write = &macb_mdio_write;
 	bp->mii_bus->reset = &macb_mdio_reset;
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
+	dev_set_name(&bp->mii_bus->dev, "%x", bp->pdev->id);
 	bp->mii_bus->priv = bp;
 	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a56d9d2..ac5992c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2645,7 +2645,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		msp->smi_bus->name = "mv643xx_eth smi";
 		msp->smi_bus->read = smi_bus_read;
 		msp->smi_bus->write = smi_bus_write,
-		snprintf(msp->smi_bus->id, MII_BUS_ID_SIZE, "%d", pdev->id);
+		dev_set_name(&msp->smi_bus->dev, "%d", pdev->id);
 		msp->smi_bus->parent = &pdev->dev;
 		msp->smi_bus->phy_mask = 0xffffffff;
 		if (mdiobus_register(msp->smi_bus) < 0)
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index cf24cc3..5e3b200 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -218,7 +218,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_mdiobus_reg;
 	}
 
-	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	dev_set_name(&fmb->mii_bus->dev, "0");
 	fmb->mii_bus->name = "Fixed MDIO Bus";
 	fmb->mii_bus->priv = fmb;
 	fmb->mii_bus->parent = &pdev->dev;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 33984b7..5baa805 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -117,7 +117,7 @@ static int __devinit mdio_gpio_bus_init(struct device *dev,
 		if (!new_bus->irq[i])
 			new_bus->irq[i] = PHY_POLL;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", bus_id);
+	dev_set_name(&new_bus->dev, "%x", bus_id);
 
 	if (gpio_request(bitbang->mdc, "mdc"))
 		goto out_free_bus;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index b754020..4ce4c09 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -99,11 +99,11 @@ int mdiobus_register(struct mii_bus *bus)
 	bus->dev.parent = bus->parent;
 	bus->dev.class = &mdio_bus_class;
 	bus->dev.groups = NULL;
-	dev_set_name(&bus->dev, "%s", bus->id);
 
 	err = device_register(&bus->dev);
 	if (err) {
-		printk(KERN_ERR "mii_bus %s failed to register\n", bus->id);
+		printk(KERN_ERR "mii_bus %s failed to register\n",
+		       dev_name(&bus->dev));
 		return -EINVAL;
 	}
 
@@ -201,7 +201,7 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 
 	phydev->dev.parent = bus->parent;
 	phydev->dev.bus = &mdio_bus_type;
-	dev_set_name(&phydev->dev, PHY_ID_FMT, bus->id, addr);
+	dev_set_name(&phydev->dev, PHY_ID_FMT, dev_name(&bus->dev), addr);
 
 	phydev->bus = bus;
 
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 88dd2e0..3cd7c1d 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2376,7 +2376,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	       dev->name, base, eaddr);
 
 	sc->mii_bus->name = sbmac_mdio_string;
-	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%x", idx);
+	dev_set_name(&sc->mii_bus->dev, "%x", idx);
 	sc->mii_bus->priv = sc;
 	sc->mii_bus->read = sbmac_mii_read;
 	sc->mii_bus->write = sbmac_mii_write;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 7b18827..6855fe0 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -804,11 +804,14 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 static int sh_eth_phy_init(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	char phy_id[BUS_ID_SIZE];
 	struct phy_device *phydev = NULL;
+	char *phy_id;
+	int err;
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-		mdp->mii_bus->id , mdp->phy_id);
+	phy_id = kvasprintf(GFP_KERNEL, PHY_ID_FMT,
+			    dev_name(&mdp->mii_bus->dev), mdp->phy_id);
+	if (!phy_id)
+		return -ENOMEM;
 
 	mdp->link = PHY_DOWN;
 	mdp->speed = 0;
@@ -819,14 +822,18 @@ static int sh_eth_phy_init(struct net_device *ndev)
 				0, PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
-		return PTR_ERR(phydev);
+		err = PTR_ERR(phydev);
+		goto out;
 	}
 	dev_info(&ndev->dev, "attached phy %i to driver %s\n",
 	phydev->addr, phydev->drv->name);
 
 	mdp->phydev = phydev;
+	err = 0;
 
-	return 0;
+out:
+	kfree(phy_id);
+	return err;
 }
 
 /* PHY control start function */
@@ -1154,7 +1161,7 @@ static int sh_mdio_init(struct net_device *ndev, int id)
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = &ndev->dev;
-	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%x", id);
+	dev_set_name(&mdp->mii_bus->dev, "%x", id);
 
 	/* PHY IRQ */
 	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index af8f60c..96d049e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -820,7 +820,7 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	}
 
 	pdata->mii_bus->name = SMSC_MDIONAME;
-	snprintf(pdata->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	dev_set_name(&pdata->mii_bus->dev, "%x", pdev->id);
 	pdata->mii_bus->priv = pdata;
 	pdata->mii_bus->read = smsc911x_mii_read;
 	pdata->mii_bus->write = smsc911x_mii_write;
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 5959ae8..68cec96 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1194,8 +1194,8 @@ static int smsc9420_mii_init(struct net_device *dev)
 		goto err_out_1;
 	}
 	pd->mii_bus->name = DRV_MDIONAME;
-	snprintf(pd->mii_bus->id, MII_BUS_ID_SIZE, "%x",
-		(pd->pdev->bus->number << 8) | pd->pdev->devfn);
+	dev_set_name(&pd->mii_bus->dev, "%x",
+		     (pd->pdev->bus->number << 8) | pd->pdev->devfn);
 	pd->mii_bus->priv = pd;
 	pd->mii_bus->read = smsc9420_mii_read;
 	pd->mii_bus->write = smsc9420_mii_write;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index b52a1c0..b2157fd 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -775,8 +775,8 @@ static int tc_mii_init(struct net_device *dev)
 	lp->mii_bus->name = "tc35815_mii_bus";
 	lp->mii_bus->read = tc_mdio_read;
 	lp->mii_bus->write = tc_mdio_write;
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%x",
-		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
+	dev_set_name(&lp->mii_bus->dev, "%x",
+		     (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
 	lp->mii_bus->priv = dev;
 	lp->mii_bus->parent = &lp->pci_dev->dev;
 	lp->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f7efcec..61374f9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1008,8 +1008,8 @@ static int tg3_mdio_init(struct tg3 *tp)
 		return -ENOMEM;
 
 	tp->mdio_bus->name     = "tg3 mdio bus";
-	snprintf(tp->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
-		 (tp->pdev->bus->number << 8) | tp->pdev->devfn);
+	dev_set_name(&tp->mdio_bus->dev, "%x",
+		     (tp->pdev->bus->number << 8) | tp->pdev->devfn);
 	tp->mdio_bus->priv     = tp;
 	tp->mdio_bus->parent   = &tp->pdev->dev;
 	tp->mdio_bus->read     = &tg3_mdio_read;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 32cf14a..7b464a5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -76,18 +76,11 @@ typedef enum {
 #define PHY_ID_FMT "%s:%02x"
 
 /*
- * Need to be a little smaller than phydev->dev.bus_id to leave room
- * for the ":%02x"
- */
-#define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
-
-/*
  * The Bus class for PHYs.  Devices which provide access to
  * PHYs should register using this structure
  */
 struct mii_bus {
 	const char *name;
-	char id[MII_BUS_ID_SIZE];
 	void *priv;
 	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ed13118..278f98b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -41,8 +41,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->name = "dsa slave smi";
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
-	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x",
-			ds->master_mii_bus->id, ds->pd->sw_addr);
+	dev_set_name(&ds->slave_mii_bus->dev, "%s:%.2x",
+		     ds->master_mii_bus->id, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
 
