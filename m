From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv2 2/3] phylib: move to dynamic allocation of struct mii_bus
Date: Thu, 2 Oct 2008 03:41:42 +0200
Message-ID: <20081002014142.GC26575@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42391 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbYJBBlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:41:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces mdiobus_alloc() and mdiobus_free(), and
makes all mdio bus drivers use these functions to allocate their
struct mii_bus'es dynamically.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/au1000_eth.c          |   43 +++++++++++++++---------
 drivers/net/au1000_eth.h          |    2 +-
 drivers/net/bfin_mac.c            |   31 ++++++++++-------
 drivers/net/bfin_mac.h            |    2 +-
 drivers/net/cpmac.c               |   51 +++++++++++++++++------------
 drivers/net/fec_mpc52xx_phy.c     |    6 ++--
 drivers/net/fs_enet/mii-bitbang.c |    7 ++--
 drivers/net/fs_enet/mii-fec.c     |    6 ++--
 drivers/net/gianfar_mii.c         |    7 ++--
 drivers/net/macb.c                |   49 ++++++++++++++++-----------
 drivers/net/macb.h                |    2 +-
 drivers/net/mv643xx_eth.c         |   32 +++++++++++-------
 drivers/net/phy/fixed.c           |   29 ++++++++++-----
 drivers/net/phy/mdio-bitbang.c    |    4 +-
 drivers/net/phy/mdio-ofgpio.c     |    9 ++---
 drivers/net/phy/mdio_bus.c        |   24 +++++++++++++
 drivers/net/sb1250-mac.c          |   36 ++++++++++++--------
 drivers/net/sh_eth.c              |    2 +-
 drivers/net/tc35815.c             |   45 +++++++++++++++----------
 drivers/net/tg3.c                 |   66 +++++++++++++++++++------------------
 drivers/net/tg3.h                 |    2 +-
 drivers/net/ucc_geth_mii.c        |    7 ++--
 include/linux/phy.h               |    2 +
 23 files changed, 279 insertions(+), 185 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 5ee1b05..9061839 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -290,7 +290,7 @@ static int mii_probe (struct net_device *dev)
 
 	if(aup->mac_id == 0) { /* get PHY0 */
 # if defined(AU1XXX_PHY0_ADDR)
-		phydev = au_macs[AU1XXX_PHY0_BUSID]->mii_bus.phy_map[AU1XXX_PHY0_ADDR];
+		phydev = au_macs[AU1XXX_PHY0_BUSID]->mii_bus->phy_map[AU1XXX_PHY0_ADDR];
 # else
 		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
 			dev->name);
@@ -298,7 +298,7 @@ static int mii_probe (struct net_device *dev)
 # endif /* defined(AU1XXX_PHY0_ADDR) */
 	} else if (aup->mac_id == 1) { /* get PHY1 */
 # if defined(AU1XXX_PHY1_ADDR)
-		phydev = au_macs[AU1XXX_PHY1_BUSID]->mii_bus.phy_map[AU1XXX_PHY1_ADDR];
+		phydev = au_macs[AU1XXX_PHY1_BUSID]->mii_bus->phy_map[AU1XXX_PHY1_ADDR];
 # else
 		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
 			dev->name);
@@ -311,8 +311,8 @@ static int mii_probe (struct net_device *dev)
 
 	/* find the first (lowest address) PHY on the current MAC's MII bus */
 	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
-		if (aup->mii_bus.phy_map[phy_addr]) {
-			phydev = aup->mii_bus.phy_map[phy_addr];
+		if (aup->mii_bus->phy_map[phy_addr]) {
+			phydev = aup->mii_bus->phy_map[phy_addr];
 # if !defined(AU1XXX_PHY_SEARCH_HIGHEST_ADDR)
 			break; /* break out with first one found */
 # endif
@@ -331,7 +331,7 @@ static int mii_probe (struct net_device *dev)
 		 * the MAC0 MII bus */
 		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
 			struct phy_device *const tmp_phydev =
-				au_macs[0]->mii_bus.phy_map[phy_addr];
+				au_macs[0]->mii_bus->phy_map[phy_addr];
 
 			if (!tmp_phydev)
 				continue; /* no PHY here... */
@@ -696,28 +696,32 @@ static struct net_device * au1000_probe(int port_num)
 	*aup->enable = 0;
 	aup->mac_enabled = 0;
 
-	aup->mii_bus.priv = dev;
-	aup->mii_bus.read = mdiobus_read;
-	aup->mii_bus.write = mdiobus_write;
-	aup->mii_bus.reset = mdiobus_reset;
-	aup->mii_bus.name = "au1000_eth_mii";
-	snprintf(aup->mii_bus.id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
-	aup->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	aup->mii_bus = mdiobus_alloc();
+	if (aup->mii_bus == NULL)
+		goto err_out;
+
+	aup->mii_bus->priv = dev;
+	aup->mii_bus->read = mdiobus_read;
+	aup->mii_bus->write = mdiobus_write;
+	aup->mii_bus->reset = mdiobus_reset;
+	aup->mii_bus->name = "au1000_eth_mii";
+	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
+	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
-		aup->mii_bus.irq[i] = PHY_POLL;
+		aup->mii_bus->irq[i] = PHY_POLL;
 
 	/* if known, set corresponding PHY IRQs */
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
 # if defined(AU1XXX_PHY0_IRQ)
 	if (AU1XXX_PHY0_BUSID == aup->mac_id)
-		aup->mii_bus.irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
+		aup->mii_bus->irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
 # endif
 # if defined(AU1XXX_PHY1_IRQ)
 	if (AU1XXX_PHY1_BUSID == aup->mac_id)
-		aup->mii_bus.irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
+		aup->mii_bus->irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
 # endif
 #endif
-	mdiobus_register(&aup->mii_bus);
+	mdiobus_register(aup->mii_bus);
 
 	if (mii_probe(dev) != 0) {
 		goto err_out;
@@ -774,6 +778,11 @@ static struct net_device * au1000_probe(int port_num)
 	return dev;
 
 err_out:
+	if (aup->mii_bus != NULL) {
+		mdiobus_unregister(aup->mii_bus);
+		mdiobus_free(aup->mii_bus);
+	}
+
 	/* here we should have a valid dev plus aup-> register addresses
 	 * so we can reset the mac properly.*/
 	reset_mac(dev);
@@ -1004,6 +1013,8 @@ static void __exit au1000_cleanup_module(void)
 		if (dev) {
 			aup = (struct au1000_private *) dev->priv;
 			unregister_netdev(dev);
+			mdiobus_unregister(aup->mii_bus);
+			mdiobus_free(aup->mii_bus);
 			for (j = 0; j < NUM_RX_DMA; j++)
 				if (aup->rx_db_inuse[j])
 					ReleaseDB(aup, aup->rx_db_inuse[j]);
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index f3baeaa..824ecd5 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -106,7 +106,7 @@ struct au1000_private {
 	int old_duplex;
 
 	struct phy_device *phy_dev;
-	struct mii_bus mii_bus;
+	struct mii_bus *mii_bus;
 
 	/* These variables are just for quick access to certain regs addresses. */
 	volatile mac_reg_t *mac;  /* mac registers                      */
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 3db7db1..af5e69e 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -398,7 +398,7 @@ static int mii_probe(struct net_device *dev)
 
 	/* search for connect PHY device */
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		struct phy_device *const tmp_phydev = lp->mii_bus.phy_map[i];
+		struct phy_device *const tmp_phydev = lp->mii_bus->phy_map[i];
 
 		if (!tmp_phydev)
 			continue; /* no PHY here... */
@@ -1058,17 +1058,21 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	setup_mac_addr(ndev->dev_addr);
 
 	/* MDIO bus initial */
-	lp->mii_bus.priv = ndev;
-	lp->mii_bus.read = mdiobus_read;
-	lp->mii_bus.write = mdiobus_write;
-	lp->mii_bus.reset = mdiobus_reset;
-	lp->mii_bus.name = "bfin_mac_mdio";
-	snprintf(lp->mii_bus.id, MII_BUS_ID_SIZE, "0");
-	lp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	lp->mii_bus = mdiobus_alloc();
+	if (lp->mii_bus == NULL)
+		goto out_err_mdiobus_alloc;
+
+	lp->mii_bus->priv = ndev;
+	lp->mii_bus->read = mdiobus_read;
+	lp->mii_bus->write = mdiobus_write;
+	lp->mii_bus->reset = mdiobus_reset;
+	lp->mii_bus->name = "bfin_mac_mdio";
+	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
-		lp->mii_bus.irq[i] = PHY_POLL;
+		lp->mii_bus->irq[i] = PHY_POLL;
 
-	rc = mdiobus_register(&lp->mii_bus);
+	rc = mdiobus_register(lp->mii_bus);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
 		goto out_err_mdiobus_register;
@@ -1121,8 +1125,10 @@ out_err_reg_ndev:
 	free_irq(IRQ_MAC_RX, ndev);
 out_err_request_irq:
 out_err_mii_probe:
-	mdiobus_unregister(&lp->mii_bus);
+	mdiobus_unregister(lp->mii_bus);
 out_err_mdiobus_register:
+	mdiobus_free(lp->mii_bus);
+out_err_mdiobus_alloc:
 	peripheral_free_list(pin_req);
 out_err_setup_pin_mux:
 out_err_probe_mac:
@@ -1139,7 +1145,8 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	mdiobus_unregister(&lp->mii_bus);
+	mdiobus_unregister(lp->mii_bus);
+	mdiobus_free(lp->mii_bus);
 
 	unregister_netdev(ndev);
 
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index beff510..052b5dc 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -66,7 +66,7 @@ struct bfin_mac_local {
 	int old_duplex;
 
 	struct phy_device *phydev;
-	struct mii_bus mii_bus;
+	struct mii_bus *mii_bus;
 };
 
 extern void bfin_get_ether_addr(char *addr);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index ec6b0af..017a536 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -302,13 +302,7 @@ static int cpmac_mdio_reset(struct mii_bus *bus)
 
 static int mii_irqs[PHY_MAX_ADDR] = { PHY_POLL, };
 
-static struct mii_bus cpmac_mii = {
-	.name = "cpmac-mii",
-	.read = cpmac_mdio_read,
-	.write = cpmac_mdio_write,
-	.reset = cpmac_mdio_reset,
-	.irq = mii_irqs,
-};
+static struct mii_bus *cpmac_mii;
 
 static int cpmac_config(struct net_device *dev, struct ifmap *map)
 {
@@ -1116,7 +1110,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
 		if (!(pdata->phy_mask & (1 << phy_id)))
 			continue;
-		if (!cpmac_mii.phy_map[phy_id])
+		if (!cpmac_mii->phy_map[phy_id])
 			continue;
 		break;
 	}
@@ -1168,7 +1162,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
 
-	priv->phy = phy_connect(dev, cpmac_mii.phy_map[phy_id]->dev.bus_id,
+	priv->phy = phy_connect(dev, cpmac_mii->phy_map[phy_id]->dev.bus_id,
 				&cpmac_adjust_link, 0, PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(priv->phy)) {
 		if (netif_msg_drv(priv))
@@ -1216,11 +1210,22 @@ int __devinit cpmac_init(void)
 	u32 mask;
 	int i, res;
 
-	cpmac_mii.priv = ioremap(AR7_REGS_MDIO, 256);
+	cpmac_mii = mdiobus_alloc();
+	if (cpmac_mii == NULL)
+		return -ENOMEM;
+
+	cpmac_mii->name = "cpmac-mii";
+	cpmac_mii->read = cpmac_mdio_read;
+	cpmac_mii->write = cpmac_mdio_write;
+	cpmac_mii->reset = cpmac_mdio_reset;
+	cpmac_mii->irq = mii_irqs;
+
+	cpmac_mii->priv = ioremap(AR7_REGS_MDIO, 256);
 
-	if (!cpmac_mii.priv) {
+	if (!cpmac_mii->priv) {
 		printk(KERN_ERR "Can't ioremap mdio registers\n");
-		return -ENXIO;
+		res = -ENXIO;
+		goto fail_alloc;
 	}
 
 #warning FIXME: unhardcode gpio&reset bits
@@ -1230,10 +1235,10 @@ int __devinit cpmac_init(void)
 	ar7_device_reset(AR7_RESET_BIT_CPMAC_HI);
 	ar7_device_reset(AR7_RESET_BIT_EPHY);
 
-	cpmac_mii.reset(&cpmac_mii);
+	cpmac_mii->reset(cpmac_mii);
 
 	for (i = 0; i < 300000; i++)
-		if ((mask = cpmac_read(cpmac_mii.priv, CPMAC_MDIO_ALIVE)))
+		if ((mask = cpmac_read(cpmac_mii->priv, CPMAC_MDIO_ALIVE)))
 			break;
 		else
 			cpu_relax();
@@ -1244,10 +1249,10 @@ int __devinit cpmac_init(void)
 		mask = 0;
 	}
 
-	cpmac_mii.phy_mask = ~(mask | 0x80000000);
-	snprintf(cpmac_mii.id, MII_BUS_ID_SIZE, "0");
+	cpmac_mii->phy_mask = ~(mask | 0x80000000);
+	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "0");
 
-	res = mdiobus_register(&cpmac_mii);
+	res = mdiobus_register(cpmac_mii);
 	if (res)
 		goto fail_mii;
 
@@ -1258,10 +1263,13 @@ int __devinit cpmac_init(void)
 	return 0;
 
 fail_cpmac:
-	mdiobus_unregister(&cpmac_mii);
+	mdiobus_unregister(cpmac_mii);
 
 fail_mii:
-	iounmap(cpmac_mii.priv);
+	iounmap(cpmac_mii->priv);
+
+fail_alloc:
+	mdiobus_free(cpmac_mii);
 
 	return res;
 }
@@ -1269,8 +1277,9 @@ fail_mii:
 void __devexit cpmac_exit(void)
 {
 	platform_driver_unregister(&cpmac_driver);
-	mdiobus_unregister(&cpmac_mii);
-	iounmap(cpmac_mii.priv);
+	mdiobus_unregister(cpmac_mii);
+	mdiobus_free(cpmac_mii);
+	iounmap(cpmac_mii->priv);
 }
 
 module_init(cpmac_init);
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 2a52330..08e18bc 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -83,7 +83,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct of_device_i
 	int err;
 	int i;
 
-	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
+	bus = mdiobus_alloc();
 	if (bus == NULL)
 		return -ENOMEM;
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
@@ -150,7 +150,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct of_device_i
 			irq_dispose_mapping(bus->irq[i]);
 	kfree(bus->irq);
 	kfree(priv);
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return err;
 }
@@ -171,7 +171,7 @@ static int mpc52xx_fec_mdio_remove(struct of_device *of)
 			irq_dispose_mapping(bus->irq[i]);
 	kfree(priv);
 	kfree(bus->irq);
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return 0;
 }
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 2774252..49b6645 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -218,9 +218,9 @@ out_free_irqs:
 out_unmap_regs:
 	iounmap(bitbang->dir);
 out_free_bus:
-	kfree(new_bus);
-out_free_priv:
 	free_mdio_bitbang(new_bus);
+out_free_priv:
+	kfree(bitbang);
 out:
 	return ret;
 }
@@ -231,12 +231,11 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 	struct bb_info *bitbang = bus->priv;
 
 	mdiobus_unregister(bus);
-	free_mdio_bitbang(bus);
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
+	free_mdio_bitbang(bus);
 	iounmap(bitbang->dir);
 	kfree(bitbang);
-	kfree(bus);
 
 	return 0;
 }
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 4d89a22..28077cc 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -128,7 +128,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	struct fec_info *fec;
 	int ret = -ENOMEM, i;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	new_bus = mdiobus_alloc();
 	if (!new_bus)
 		goto out;
 
@@ -190,7 +190,7 @@ out_res:
 out_fec:
 	kfree(fec);
 out_mii:
-	kfree(new_bus);
+	mdiobus_free(new_bus);
 out:
 	return ret;
 }
@@ -205,7 +205,7 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 	kfree(bus->irq);
 	iounmap(fec->fecp);
 	kfree(fec);
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return 0;
 }
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 574884c..6b0438b 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -164,8 +164,7 @@ static int gfar_mdio_probe(struct device *dev)
 	if (NULL == dev)
 		return -EINVAL;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
-
+	new_bus = mdiobus_alloc();
 	if (NULL == new_bus)
 		return -ENOMEM;
 
@@ -240,7 +239,7 @@ static int gfar_mdio_probe(struct device *dev)
 bus_register_fail:
 	iounmap(regs);
 reg_map_fail:
-	kfree(new_bus);
+	mdiobus_free(new_bus);
 
 	return err;
 }
@@ -256,7 +255,7 @@ static int gfar_mdio_remove(struct device *dev)
 
 	iounmap((void __iomem *)bus->priv);
 	bus->priv = NULL;
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return 0;
 }
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 045361f..01f7a31 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -195,8 +195,8 @@ static int macb_mii_probe(struct net_device *dev)
 
 	/* find the first phy */
 	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (bp->mii_bus.phy_map[phy_addr]) {
-			phydev = bp->mii_bus.phy_map[phy_addr];
+		if (bp->mii_bus->phy_map[phy_addr]) {
+			phydev = bp->mii_bus->phy_map[phy_addr];
 			break;
 		}
 	}
@@ -244,30 +244,36 @@ static int macb_mii_init(struct macb *bp)
 	/* Enable managment port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	bp->mii_bus.name = "MACB_mii_bus";
-	bp->mii_bus.read = &macb_mdio_read;
-	bp->mii_bus.write = &macb_mdio_write;
-	bp->mii_bus.reset = &macb_mdio_reset;
-	snprintf(bp->mii_bus.id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
-	bp->mii_bus.priv = bp;
-	bp->mii_bus.parent = &bp->dev->dev;
+	bp->mii_bus = mdiobus_alloc();
+	if (bp->mii_bus == NULL) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	bp->mii_bus->name = "MACB_mii_bus";
+	bp->mii_bus->read = &macb_mdio_read;
+	bp->mii_bus->write = &macb_mdio_write;
+	bp->mii_bus->reset = &macb_mdio_reset;
+	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
+	bp->mii_bus->priv = bp;
+	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
 	if (pdata)
-		bp->mii_bus.phy_mask = pdata->phy_mask;
+		bp->mii_bus->phy_mask = pdata->phy_mask;
 
-	bp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	if (!bp->mii_bus.irq) {
+	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bp->mii_bus->irq) {
 		err = -ENOMEM;
-		goto err_out;
+		goto err_out_free_mdiobus;
 	}
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-		bp->mii_bus.irq[i] = PHY_POLL;
+		bp->mii_bus->irq[i] = PHY_POLL;
 
-	platform_set_drvdata(bp->dev, &bp->mii_bus);
+	platform_set_drvdata(bp->dev, bp->mii_bus);
 
-	if (mdiobus_register(&bp->mii_bus))
+	if (mdiobus_register(bp->mii_bus))
 		goto err_out_free_mdio_irq;
 
 	if (macb_mii_probe(bp->dev) != 0) {
@@ -277,9 +283,11 @@ static int macb_mii_init(struct macb *bp)
 	return 0;
 
 err_out_unregister_bus:
-	mdiobus_unregister(&bp->mii_bus);
+	mdiobus_unregister(bp->mii_bus);
 err_out_free_mdio_irq:
-	kfree(bp->mii_bus.irq);
+	kfree(bp->mii_bus->irq);
+err_out_free_mdiobus:
+	mdiobus_free(bp->mii_bus);
 err_out:
 	return err;
 }
@@ -1261,8 +1269,9 @@ static int __exit macb_remove(struct platform_device *pdev)
 		bp = netdev_priv(dev);
 		if (bp->phy_dev)
 			phy_disconnect(bp->phy_dev);
-		mdiobus_unregister(&bp->mii_bus);
-		kfree(bp->mii_bus.irq);
+		mdiobus_unregister(bp->mii_bus);
+		kfree(bp->mii_bus->irq);
+		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 57b85ac..d3212f6 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -384,7 +384,7 @@ struct macb {
 
 	unsigned int		rx_pending, tx_pending;
 
-	struct mii_bus		mii_bus;
+	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
 	unsigned int 		link;
 	unsigned int 		speed;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0709c49..fb8f1e9 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -250,7 +250,7 @@ struct mv643xx_eth_shared_private {
 	/*
 	 * Provides access to local SMI interface.
 	 */
-	struct mii_bus smi_bus;
+	struct mii_bus *smi_bus;
 
 	/*
 	 * If we have access to the error interrupt pin (which is
@@ -2339,15 +2339,19 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	 * Set up and register SMI bus.
 	 */
 	if (pd == NULL || pd->shared_smi == NULL) {
-		msp->smi_bus.priv = msp;
-		msp->smi_bus.name = "mv643xx_eth smi";
-		msp->smi_bus.read = smi_bus_read;
-		msp->smi_bus.write = smi_bus_write,
-		snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
-		msp->smi_bus.parent = &pdev->dev;
-		msp->smi_bus.phy_mask = 0xffffffff;
-		if (mdiobus_register(&msp->smi_bus) < 0)
+		msp->smi_bus = mdiobus_alloc();
+		if (msp->smi_bus == NULL)
 			goto out_unmap;
+
+		msp->smi_bus->priv = msp;
+		msp->smi_bus->name = "mv643xx_eth smi";
+		msp->smi_bus->read = smi_bus_read;
+		msp->smi_bus->write = smi_bus_write,
+		snprintf(msp->smi_bus->id, MII_BUS_ID_SIZE, "%d", pdev->id);
+		msp->smi_bus->parent = &pdev->dev;
+		msp->smi_bus->phy_mask = 0xffffffff;
+		if (mdiobus_register(msp->smi_bus) < 0)
+			goto out_free_mii_bus;
 		msp->smi = msp;
 	} else {
 		msp->smi = platform_get_drvdata(pd->shared_smi);
@@ -2387,6 +2391,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_free_mii_bus:
+	mdiobus_free(msp->smi_bus);
 out_unmap:
 	iounmap(msp->base);
 out_free:
@@ -2400,8 +2406,10 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
-	if (pd == NULL || pd->shared_smi == NULL)
-		mdiobus_unregister(&msp->smi_bus);
+	if (pd == NULL || pd->shared_smi == NULL) {
+		mdiobus_free(msp->smi_bus);
+		mdiobus_unregister(msp->smi_bus);
+	}
 	if (msp->err_interrupt != NO_IRQ)
 		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
@@ -2469,7 +2477,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 				   int phy_addr)
 {
-	struct mii_bus *bus = &mp->shared->smi->smi_bus;
+	struct mii_bus *bus = mp->shared->smi->smi_bus;
 	struct phy_device *phydev;
 	int start;
 	int num;
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 1cec896..b5e13f8 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -24,7 +24,7 @@
 
 struct fixed_mdio_bus {
 	int irqs[PHY_MAX_ADDR];
-	struct mii_bus mii_bus;
+	struct mii_bus *mii_bus;
 	struct list_head phys;
 };
 
@@ -213,19 +213,27 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_pdev;
 	}
 
-	snprintf(fmb->mii_bus.id, MII_BUS_ID_SIZE, "0");
-	fmb->mii_bus.name = "Fixed MDIO Bus";
-	fmb->mii_bus.parent = &pdev->dev;
-	fmb->mii_bus.read = &fixed_mdio_read;
-	fmb->mii_bus.write = &fixed_mdio_write;
-	fmb->mii_bus.irq = fmb->irqs;
+	fmb->mii_bus = mdiobus_alloc();
+	if (fmb->mii_bus == NULL) {
+		ret = -ENOMEM;
+		goto err_mdiobus_reg;
+	}
 
-	ret = mdiobus_register(&fmb->mii_bus);
+	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	fmb->mii_bus->name = "Fixed MDIO Bus";
+	fmb->mii_bus->parent = &pdev->dev;
+	fmb->mii_bus->read = &fixed_mdio_read;
+	fmb->mii_bus->write = &fixed_mdio_write;
+	fmb->mii_bus->irq = fmb->irqs;
+
+	ret = mdiobus_register(fmb->mii_bus);
 	if (ret)
-		goto err_mdiobus_reg;
+		goto err_mdiobus_alloc;
 
 	return 0;
 
+err_mdiobus_alloc:
+	mdiobus_free(fmb->mii_bus);
 err_mdiobus_reg:
 	platform_device_unregister(pdev);
 err_pdev:
@@ -238,7 +246,8 @@ static void __exit fixed_mdio_bus_exit(void)
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp, *tmp;
 
-	mdiobus_unregister(&fmb->mii_bus);
+	mdiobus_unregister(fmb->mii_bus);
+	mdiobus_free(fmb->mii_bus);
 	platform_device_unregister(pdev);
 
 	list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index c01b780..2576055 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -165,7 +165,7 @@ struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl)
 {
 	struct mii_bus *bus;
 
-	bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	bus = mdiobus_alloc();
 	if (!bus)
 		return NULL;
 
@@ -184,7 +184,7 @@ void free_mdio_bitbang(struct mii_bus *bus)
 	struct mdiobb_ctrl *ctrl = bus->priv;
 
 	module_put(ctrl->ops->owner);
-	kfree(bus);
+	mdiobus_free(bus);
 }
 EXPORT_SYMBOL(free_mdio_bitbang);
 
diff --git a/drivers/net/phy/mdio-ofgpio.c b/drivers/net/phy/mdio-ofgpio.c
index 27bd453..2ff9775 100644
--- a/drivers/net/phy/mdio-ofgpio.c
+++ b/drivers/net/phy/mdio-ofgpio.c
@@ -122,7 +122,7 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 
 	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!new_bus)
-		goto out_free_priv;
+		goto out_free_bitbang;
 
 	new_bus->name = "GPIO Bitbanged MII",
 
@@ -155,9 +155,9 @@ out_free_irqs:
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(new_bus->irq);
 out_free_bus:
-	kfree(new_bus);
-out_free_priv:
 	free_mdio_bitbang(new_bus);
+out_free_bitbang:
+	kfree(bitbang);
 out:
 	return ret;
 }
@@ -168,11 +168,10 @@ static int mdio_ofgpio_remove(struct of_device *ofdev)
 	struct mdio_gpio_info *bitbang = bus->priv;
 
 	mdiobus_unregister(bus);
+	kfree(bus->irq);
 	free_mdio_bitbang(bus);
 	dev_set_drvdata(&ofdev->dev, NULL);
-	kfree(bus->irq);
 	kfree(bitbang);
-	kfree(bus);
 
 	return 0;
 }
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 73e2696..e889a06 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -36,6 +36,18 @@
 #include <asm/uaccess.h>
 
 /**
+ * mdiobus_alloc - allocate a mii_bus structure
+ *
+ * Description: called by a bus driver to allocate an mii_bus
+ * structure to fill in.
+ */
+struct mii_bus *mdiobus_alloc(void)
+{
+	return kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+}
+EXPORT_SYMBOL(mdiobus_alloc);
+
+/**
  * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
  * @bus: target mii_bus
  *
@@ -87,6 +99,18 @@ void mdiobus_unregister(struct mii_bus *bus)
 }
 EXPORT_SYMBOL(mdiobus_unregister);
 
+/**
+ * mdiobus_free - free a struct mii_bus
+ * @bus: mii_bus to free
+ *
+ * This function frees the mii_bus.
+ */
+void mdiobus_free(struct mii_bus *bus)
+{
+	kfree(bus);
+}
+EXPORT_SYMBOL(mdiobus_free);
+
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 {
 	struct phy_device *phydev;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index d6de19c..b2bc93f 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -256,7 +256,7 @@ struct sbmac_softc {
 	struct net_device	*sbm_dev;	/* pointer to linux device */
 	struct napi_struct	napi;
 	struct phy_device	*phy_dev;	/* the associated PHY device */
-	struct mii_bus		mii_bus;	/* the MII bus */
+	struct mii_bus		*mii_bus;	/* the MII bus */
 	int			phy_irq[PHY_MAX_ADDR];
 	spinlock_t		sbm_lock;	/* spin lock */
 	int			sbm_devflags;	/* current device flags */
@@ -2347,10 +2347,17 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);
 
+	sc->mii_bus = mdiobus_alloc();
+	if (sc->mii_bus == NULL) {
+		sbmac_uninitctx(sc);
+		return -ENOMEM;
+	}
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR "%s.%d: unable to register netdev\n",
 		       sbmac_string, idx);
+		mdiobus_free(sc->mii_bus);
 		sbmac_uninitctx(sc);
 		return err;
 	}
@@ -2368,17 +2375,17 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	pr_info("%s: SiByte Ethernet at 0x%08Lx, address: %s\n",
 	       dev->name, base, print_mac(mac, eaddr));
 
-	sc->mii_bus.name = sbmac_mdio_string;
-	snprintf(sc->mii_bus.id, MII_BUS_ID_SIZE, "%x", idx);
-	sc->mii_bus.priv = sc;
-	sc->mii_bus.read = sbmac_mii_read;
-	sc->mii_bus.write = sbmac_mii_write;
-	sc->mii_bus.irq = sc->phy_irq;
+	sc->mii_bus->name = sbmac_mdio_string;
+	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%x", idx);
+	sc->mii_bus->priv = sc;
+	sc->mii_bus->read = sbmac_mii_read;
+	sc->mii_bus->write = sbmac_mii_write;
+	sc->mii_bus->irq = sc->phy_irq;
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
-		sc->mii_bus.irq[i] = SBMAC_PHY_INT;
+		sc->mii_bus->irq[i] = SBMAC_PHY_INT;
 
-	sc->mii_bus.parent = &pldev->dev;
-	dev_set_drvdata(&pldev->dev, &sc->mii_bus);
+	sc->mii_bus->parent = &pldev->dev;
+	dev_set_drvdata(&pldev->dev, sc->mii_bus);
 
 	return 0;
 }
@@ -2409,7 +2416,7 @@ static int sbmac_open(struct net_device *dev)
 	/*
 	 * Probe PHY address
 	 */
-	err = mdiobus_register(&sc->mii_bus);
+	err = mdiobus_register(sc->mii_bus);
 	if (err) {
 		printk(KERN_ERR "%s: unable to register MDIO bus\n",
 		       dev->name);
@@ -2446,7 +2453,7 @@ static int sbmac_open(struct net_device *dev)
 	return 0;
 
 out_unregister:
-	mdiobus_unregister(&sc->mii_bus);
+	mdiobus_unregister(sc->mii_bus);
 
 out_unirq:
 	free_irq(dev->irq, dev);
@@ -2462,7 +2469,7 @@ static int sbmac_mii_probe(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		phy_dev = sc->mii_bus.phy_map[i];
+		phy_dev = sc->mii_bus->phy_map[i];
 		if (phy_dev)
 			break;
 	}
@@ -2639,7 +2646,7 @@ static int sbmac_close(struct net_device *dev)
 	phy_disconnect(sc->phy_dev);
 	sc->phy_dev = NULL;
 
-	mdiobus_unregister(&sc->mii_bus);
+	mdiobus_unregister(sc->mii_bus);
 
 	free_irq(dev->irq, dev);
 
@@ -2748,6 +2755,7 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 
 	unregister_netdev(dev);
 	sbmac_uninitctx(sc);
+	mdiobus_free(sc->mii_bus);
 	iounmap(sc->sbm_base);
 	free_netdev(dev);
 
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 1b3b7b6..b39d1cc 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1166,7 +1166,7 @@ out_free_irq:
 	kfree(mdp->mii_bus->irq);
 
 out_free_bus:
-	kfree(mdp->mii_bus);
+	free_mdio_bitbang(mdp->mii_bus);
 
 out_free_bitbang:
 	kfree(bitbang);
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 1f2b1f2..4980b12 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -424,7 +424,7 @@ struct tc35815_local {
 	 */
 	spinlock_t lock;
 
-	struct mii_bus mii_bus;
+	struct mii_bus *mii_bus;
 	struct phy_device *phy_dev;
 	int duplex;
 	int speed;
@@ -704,13 +704,13 @@ static int tc_mii_probe(struct net_device *dev)
 
 	/* find the first phy */
 	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (lp->mii_bus.phy_map[phy_addr]) {
+		if (lp->mii_bus->phy_map[phy_addr]) {
 			if (phydev) {
 				printk(KERN_ERR "%s: multiple PHYs found\n",
 				       dev->name);
 				return -EINVAL;
 			}
-			phydev = lp->mii_bus.phy_map[phy_addr];
+			phydev = lp->mii_bus->phy_map[phy_addr];
 			break;
 		}
 	}
@@ -762,23 +762,29 @@ static int tc_mii_init(struct net_device *dev)
 	int err;
 	int i;
 
-	lp->mii_bus.name = "tc35815_mii_bus";
-	lp->mii_bus.read = tc_mdio_read;
-	lp->mii_bus.write = tc_mdio_write;
-	snprintf(lp->mii_bus.id, MII_BUS_ID_SIZE, "%x",
-		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
-	lp->mii_bus.priv = dev;
-	lp->mii_bus.parent = &lp->pci_dev->dev;
-	lp->mii_bus.irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (!lp->mii_bus.irq) {
+	lp->mii_bus = mdiobus_alloc();
+	if (lp->mii_bus == NULL) {
 		err = -ENOMEM;
 		goto err_out;
 	}
 
+	lp->mii_bus->name = "tc35815_mii_bus";
+	lp->mii_bus->read = tc_mdio_read;
+	lp->mii_bus->write = tc_mdio_write;
+	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
+	lp->mii_bus->priv = dev;
+	lp->mii_bus->parent = &lp->pci_dev->dev;
+	lp->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!lp->mii_bus->irq) {
+		err = -ENOMEM;
+		goto err_out_free_mii_bus;
+	}
+
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-		lp->mii_bus.irq[i] = PHY_POLL;
+		lp->mii_bus->irq[i] = PHY_POLL;
 
-	err = mdiobus_register(&lp->mii_bus);
+	err = mdiobus_register(lp->mii_bus);
 	if (err)
 		goto err_out_free_mdio_irq;
 	err = tc_mii_probe(dev);
@@ -787,9 +793,11 @@ static int tc_mii_init(struct net_device *dev)
 	return 0;
 
 err_out_unregister_bus:
-	mdiobus_unregister(&lp->mii_bus);
+	mdiobus_unregister(lp->mii_bus);
 err_out_free_mdio_irq:
-	kfree(lp->mii_bus.irq);
+	kfree(lp->mii_bus->irq);
+err_out_free_mii_bus;
+	mdiobus_free(lp->mii_bus);
 err_out:
 	return err;
 }
@@ -961,8 +969,9 @@ static void __devexit tc35815_remove_one(struct pci_dev *pdev)
 	struct tc35815_local *lp = netdev_priv(dev);
 
 	phy_disconnect(lp->phy_dev);
-	mdiobus_unregister(&lp->mii_bus);
-	kfree(lp->mii_bus.irq);
+	mdiobus_unregister(lp->mii_bus);
+	kfree(lp->mii_bus->irq);
+	mdiobus_free(lp->mii_bus);
 	unregister_netdev(dev);
 	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fc815a3..99c428e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -876,7 +876,7 @@ static void tg3_mdio_config(struct tg3 *tp)
 {
 	u32 val;
 
-	if (tp->mdio_bus.phy_map[PHY_ADDR]->interface !=
+	if (tp->mdio_bus->phy_map[PHY_ADDR]->interface !=
 	    PHY_INTERFACE_MODE_RGMII)
 		return;
 
@@ -920,9 +920,9 @@ static void tg3_mdio_config(struct tg3 *tp)
 static void tg3_mdio_start(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
-		mutex_lock(&tp->mdio_bus.mdio_lock);
+		mutex_lock(&tp->mdio_bus->mdio_lock);
 		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
-		mutex_unlock(&tp->mdio_bus.mdio_lock);
+		mutex_unlock(&tp->mdio_bus->mdio_lock);
 	}
 
 	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
@@ -936,9 +936,9 @@ static void tg3_mdio_start(struct tg3 *tp)
 static void tg3_mdio_stop(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
-		mutex_lock(&tp->mdio_bus.mdio_lock);
+		mutex_lock(&tp->mdio_bus->mdio_lock);
 		tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_PAUSED;
-		mutex_unlock(&tp->mdio_bus.mdio_lock);
+		mutex_unlock(&tp->mdio_bus->mdio_lock);
 	}
 }
 
@@ -947,7 +947,6 @@ static int tg3_mdio_init(struct tg3 *tp)
 	int i;
 	u32 reg;
 	struct phy_device *phydev;
-	struct mii_bus *mdio_bus = &tp->mdio_bus;
 
 	tg3_mdio_start(tp);
 
@@ -955,21 +954,23 @@ static int tg3_mdio_init(struct tg3 *tp)
 	    (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED))
 		return 0;
 
-	memset(mdio_bus, 0, sizeof(*mdio_bus));
+	tp->mdio_bus = mdiobus_alloc();
+	if (tp->mdio_bus == NULL)
+		return -ENOMEM;
 
-	mdio_bus->name     = "tg3 mdio bus";
-	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%x",
+	tp->mdio_bus->name     = "tg3 mdio bus";
+	snprintf(tp->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
 		 (tp->pdev->bus->number << 8) | tp->pdev->devfn);
-	mdio_bus->priv     = tp;
-	mdio_bus->parent   = &tp->pdev->dev;
-	mdio_bus->read     = &tg3_mdio_read;
-	mdio_bus->write    = &tg3_mdio_write;
-	mdio_bus->reset    = &tg3_mdio_reset;
-	mdio_bus->phy_mask = ~(1 << PHY_ADDR);
-	mdio_bus->irq      = &tp->mdio_irq[0];
+	tp->mdio_bus->priv     = tp;
+	tp->mdio_bus->parent   = &tp->pdev->dev;
+	tp->mdio_bus->read     = &tg3_mdio_read;
+	tp->mdio_bus->write    = &tg3_mdio_write;
+	tp->mdio_bus->reset    = &tg3_mdio_reset;
+	tp->mdio_bus->phy_mask = ~(1 << PHY_ADDR);
+	tp->mdio_bus->irq      = &tp->mdio_irq[0];
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-		mdio_bus->irq[i] = PHY_POLL;
+		tp->mdio_bus->irq[i] = PHY_POLL;
 
 	/* The bus registration will look for all the PHYs on the mdio bus.
 	 * Unfortunately, it does not ensure the PHY is powered up before
@@ -979,7 +980,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	if (tg3_readphy(tp, MII_BMCR, &reg) || (reg & BMCR_PDOWN))
 		tg3_bmcr_reset(tp);
 
-	i = mdiobus_register(mdio_bus);
+	i = mdiobus_register(tp->mdio_bus);
 	if (i) {
 		printk(KERN_WARNING "%s: mdiobus_reg failed (0x%x)\n",
 			tp->dev->name, i);
@@ -988,7 +989,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 
 	tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
 
-	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 	switch (phydev->phy_id) {
 	case TG3_PHY_ID_BCM50610:
@@ -1014,7 +1015,8 @@ static void tg3_mdio_fini(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
 		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_INITED;
-		mdiobus_unregister(&tp->mdio_bus);
+		mdiobus_unregister(tp->mdio_bus);
+		mdiobus_free(tp->mdio_bus);
 		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
 	}
 }
@@ -1220,7 +1222,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
-		autoneg = tp->mdio_bus.phy_map[PHY_ADDR]->autoneg;
+		autoneg = tp->mdio_bus->phy_map[PHY_ADDR]->autoneg;
 	else
 		autoneg = tp->link_config.autoneg;
 
@@ -1257,7 +1259,7 @@ static void tg3_adjust_link(struct net_device *dev)
 	u8 oldflowctrl, linkmesg = 0;
 	u32 mac_mode, lcl_adv, rmt_adv;
 	struct tg3 *tp = netdev_priv(dev);
-	struct phy_device *phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+	struct phy_device *phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 	spin_lock(&tp->lock);
 
@@ -1334,7 +1336,7 @@ static int tg3_phy_init(struct tg3 *tp)
 	/* Bring the PHY back to a known state. */
 	tg3_bmcr_reset(tp);
 
-	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 	/* Attach the MAC to the PHY. */
 	phydev = phy_connect(tp->dev, phydev->dev.bus_id, tg3_adjust_link,
@@ -1367,7 +1369,7 @@ static void tg3_phy_start(struct tg3 *tp)
 	if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 		return;
 
-	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 	if (tp->link_config.phy_is_low_power) {
 		tp->link_config.phy_is_low_power = 0;
@@ -1387,13 +1389,13 @@ static void tg3_phy_stop(struct tg3 *tp)
 	if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 		return;
 
-	phy_stop(tp->mdio_bus.phy_map[PHY_ADDR]);
+	phy_stop(tp->mdio_bus->phy_map[PHY_ADDR]);
 }
 
 static void tg3_phy_fini(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
-		phy_disconnect(tp->mdio_bus.phy_map[PHY_ADDR]);
+		phy_disconnect(tp->mdio_bus->phy_map[PHY_ADDR]);
 		tp->tg3_flags3 &= ~TG3_FLG3_PHY_CONNECTED;
 	}
 }
@@ -2049,7 +2051,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			struct phy_device *phydev;
 			u32 advertising;
 
-			phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+			phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 			tp->link_config.phy_is_low_power = 1;
 
@@ -8977,7 +8979,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 			return -EAGAIN;
-		return phy_ethtool_gset(tp->mdio_bus.phy_map[PHY_ADDR], cmd);
+		return phy_ethtool_gset(tp->mdio_bus->phy_map[PHY_ADDR], cmd);
 	}
 
 	cmd->supported = (SUPPORTED_Autoneg);
@@ -9018,7 +9020,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 			return -EAGAIN;
-		return phy_ethtool_sset(tp->mdio_bus.phy_map[PHY_ADDR], cmd);
+		return phy_ethtool_sset(tp->mdio_bus->phy_map[PHY_ADDR], cmd);
 	}
 
 	if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) {
@@ -9166,7 +9168,7 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 			return -EAGAIN;
-		r = phy_start_aneg(tp->mdio_bus.phy_map[PHY_ADDR]);
+		r = phy_start_aneg(tp->mdio_bus->phy_map[PHY_ADDR]);
 	} else {
 		u32 bmcr;
 
@@ -9283,7 +9285,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 			u32 newadv;
 			struct phy_device *phydev;
 
-			phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+			phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 			if (epause->rx_pause) {
 				if (epause->tx_pause)
@@ -10265,7 +10267,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 			return -EAGAIN;
-		return phy_mii_ioctl(tp->mdio_bus.phy_map[PHY_ADDR], data, cmd);
+		return phy_mii_ioctl(tp->mdio_bus->phy_map[PHY_ADDR], data, cmd);
 	}
 
 	switch(cmd) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f5b8cab..3ec9021 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2557,7 +2557,7 @@ struct tg3 {
 	int				msi_cap;
 	int				pcix_cap;
 
-	struct mii_bus			mdio_bus;
+	struct mii_bus			*mdio_bus;
 	int				mdio_irq[PHY_MAX_ADDR];
 
 	/* PHY info */
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 75b72fe..c001d26 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -141,8 +141,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 	struct resource res;
 	int k, err = 0;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
-
+	new_bus = mdiobus_alloc();
 	if (NULL == new_bus)
 		return -ENOMEM;
 
@@ -235,7 +234,7 @@ bus_register_fail:
 ioremap_fail:
 	kfree(new_bus->irq);
 reg_map_fail:
-	kfree(new_bus);
+	mdiobus_free(new_bus);
 
 	return err;
 }
@@ -251,7 +250,7 @@ static int uec_mdio_remove(struct of_device *ofdev)
 
 	iounmap((void __iomem *)bus->priv);
 	bus->priv = NULL;
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return 0;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 3bfda82..e6c46c8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -114,8 +114,10 @@ struct mii_bus {
 	int *irq;
 };
 
+struct mii_bus *mdiobus_alloc(void);
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
+void mdiobus_free(struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
 int mdiobus_read(struct mii_bus *bus, int addr, u16 regnum);
 int mdiobus_write(struct mii_bus *bus, int addr, u16 regnum, u16 val);
-- 
1.5.6.4
