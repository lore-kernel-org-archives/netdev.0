From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: ethernet: use platform_{get,set}_drvdata()
Date: Thu, 23 May 2013 19:52:31 +0900
Message-ID: <003a01ce57a3$a028d780$e07a8680$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Kristoffer Glembo' <kristoffer@gaisler.com>,
	'Pantelis Antoniou' <pantelis.antoniou@gmail.com>,
	'Vitaly Bordug' <vbordug@ru.mvista.com>,
	Richard Cochran <richardcochran@gmail.com>,
	'Li Yang' <leoli@freescale.com>,
	'Thadeu Lima de Souza Cascardo'
	<cascardo@linux.vnet.ibm.com>,
	'Anirudha Sarangi' <anirudh@xilinx.com>,
	'John Linn' <John.Linn@xilinx.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:59685 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757825Ab3EWKwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 06:52:36 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MN800G6JZJM7EZ0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 23 May 2013 19:52:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/aeroflex/greth.c                |    4 +---
 drivers/net/ethernet/amd/sunlance.c                  |    6 ++----
 drivers/net/ethernet/broadcom/sb1250-mac.c           |    9 ++++-----
 drivers/net/ethernet/freescale/fec_mpc52xx.c         |    9 ++++-----
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c    |    5 ++---
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c |    6 ++----
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c     |    6 ++----
 drivers/net/ethernet/freescale/gianfar.c             |    6 ++----
 drivers/net/ethernet/freescale/gianfar_ptp.c         |    4 ++--
 drivers/net/ethernet/freescale/ucc_geth.c            |    4 ++--
 drivers/net/ethernet/freescale/xgmac_mdio.c          |    4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_main.c            |    4 ++--
 drivers/net/ethernet/ibm/emac/mal.c                  |    6 ++----
 drivers/net/ethernet/ibm/emac/rgmii.c                |   18 ++++++++----------
 drivers/net/ethernet/ibm/emac/tah.c                  |   14 ++++++--------
 drivers/net/ethernet/ibm/emac/zmii.c                 |   18 ++++++++----------
 drivers/net/ethernet/netx-eth.c                      |    4 +---
 drivers/net/ethernet/octeon/octeon_mgmt.c            |    4 ++--
 drivers/net/ethernet/sun/niu.c                       |    5 ++---
 drivers/net/ethernet/sun/sunhme.c                    |    4 ++--
 drivers/net/ethernet/sun/sunqe.c                     |   10 ++++------
 drivers/net/ethernet/xilinx/ll_temac_main.c          |    5 ++---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c    |    6 ++----
 23 files changed, 66 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 2692954..7ff4b30 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1565,7 +1565,7 @@ error1:
 
 static int greth_of_remove(struct platform_device *of_dev)
 {
-	struct net_device *ndev = dev_get_drvdata(&of_dev->dev);
+	struct net_device *ndev = platform_get_drvdata(of_dev);
 	struct greth_private *greth = netdev_priv(ndev);
 
 	/* Free descriptor areas */
@@ -1573,8 +1573,6 @@ static int greth_of_remove(struct platform_device *of_dev)
 
 	dma_free_coherent(&of_dev->dev, 1024, greth->tx_bd_base, greth->tx_bd_base_phys);
 
-	dev_set_drvdata(&of_dev->dev, NULL);
-
 	if (greth->phy)
 		phy_stop(greth->phy);
 	mdiobus_unregister(greth->mdio);
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index f47b780..ece5683 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1470,7 +1470,7 @@ no_link_test:
 		goto fail;
 	}
 
-	dev_set_drvdata(&op->dev, lp);
+	platform_set_drvdata(op, lp);
 
 	printk(KERN_INFO "%s: LANCE %pM\n",
 	       dev->name, dev->dev_addr);
@@ -1501,7 +1501,7 @@ static int sunlance_sbus_probe(struct platform_device *op)
 
 static int sunlance_sbus_remove(struct platform_device *op)
 {
-	struct lance_private *lp = dev_get_drvdata(&op->dev);
+	struct lance_private *lp = platform_get_drvdata(op);
 	struct net_device *net_dev = lp->dev;
 
 	unregister_netdev(net_dev);
@@ -1510,8 +1510,6 @@ static int sunlance_sbus_remove(struct platform_device *op)
 
 	free_netdev(net_dev);
 
-	dev_set_drvdata(&op->dev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index e80bfb6..c277771 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2197,7 +2197,7 @@ static const struct net_device_ops sbmac_netdev_ops = {
 
 static int sbmac_init(struct platform_device *pldev, long long base)
 {
-	struct net_device *dev = dev_get_drvdata(&pldev->dev);
+	struct net_device *dev = platform_get_drvdata(pldev);
 	int idx = pldev->id;
 	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned char *eaddr;
@@ -2275,7 +2275,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 		       dev->name);
 		goto free_mdio;
 	}
-	dev_set_drvdata(&pldev->dev, sc->mii_bus);
+	platform_set_drvdata(pldev, sc->mii_bus);
 
 	err = register_netdev(dev);
 	if (err) {
@@ -2300,7 +2300,6 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	return 0;
 unreg_mdio:
 	mdiobus_unregister(sc->mii_bus);
-	dev_set_drvdata(&pldev->dev, NULL);
 free_mdio:
 	mdiobus_free(sc->mii_bus);
 uninit_ctx:
@@ -2624,7 +2623,7 @@ static int sbmac_probe(struct platform_device *pldev)
 		goto out_unmap;
 	}
 
-	dev_set_drvdata(&pldev->dev, dev);
+	platform_set_drvdata(pldev, dev);
 	SET_NETDEV_DEV(dev, &pldev->dev);
 
 	sc = netdev_priv(dev);
@@ -2649,7 +2648,7 @@ out_out:
 
 static int __exit sbmac_remove(struct platform_device *pldev)
 {
-	struct net_device *dev = dev_get_drvdata(&pldev->dev);
+	struct net_device *dev = platform_get_drvdata(pldev);
 	struct sbmac_softc *sc = netdev_priv(dev);
 
 	unregister_netdev(dev);
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 9bc15e2..9947765 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -981,7 +981,7 @@ static int mpc52xx_fec_probe(struct platform_device *op)
 		goto err_node;
 
 	/* We're done ! */
-	dev_set_drvdata(&op->dev, ndev);
+	platform_set_drvdata(op, ndev);
 	netdev_info(ndev, "%s MAC %pM\n",
 		    op->dev.of_node->full_name, ndev->dev_addr);
 
@@ -1010,7 +1010,7 @@ mpc52xx_fec_remove(struct platform_device *op)
 	struct net_device *ndev;
 	struct mpc52xx_fec_priv *priv;
 
-	ndev = dev_get_drvdata(&op->dev);
+	ndev = platform_get_drvdata(op);
 	priv = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
@@ -1030,14 +1030,13 @@ mpc52xx_fec_remove(struct platform_device *op)
 
 	free_netdev(ndev);
 
-	dev_set_drvdata(&op->dev, NULL);
 	return 0;
 }
 
 #ifdef CONFIG_PM
 static int mpc52xx_fec_of_suspend(struct platform_device *op, pm_message_t state)
 {
-	struct net_device *dev = dev_get_drvdata(&op->dev);
+	struct net_device *dev = platform_get_drvdata(op);
 
 	if (netif_running(dev))
 		mpc52xx_fec_close(dev);
@@ -1047,7 +1046,7 @@ static int mpc52xx_fec_of_suspend(struct platform_device *op, pm_message_t state
 
 static int mpc52xx_fec_of_resume(struct platform_device *op)
 {
-	struct net_device *dev = dev_get_drvdata(&op->dev);
+	struct net_device *dev = platform_get_drvdata(op);
 
 	mpc52xx_fec_hw_init(dev);
 	mpc52xx_fec_reset_stats(dev);
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index edc1200..8de53a1 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1048,7 +1048,7 @@ static int fs_enet_probe(struct platform_device *ofdev)
 	}
 
 	SET_NETDEV_DEV(ndev, &ofdev->dev);
-	dev_set_drvdata(&ofdev->dev, ndev);
+	platform_set_drvdata(ofdev, ndev);
 
 	fep = netdev_priv(ndev);
 	fep->dev = &ofdev->dev;
@@ -1106,7 +1106,6 @@ out_cleanup_data:
 	fep->ops->cleanup_data(ndev);
 out_free_dev:
 	free_netdev(ndev);
-	dev_set_drvdata(&ofdev->dev, NULL);
 out_put:
 	of_node_put(fpi->phy_node);
 out_free_fpi:
@@ -1116,7 +1115,7 @@ out_free_fpi:
 
 static int fs_enet_remove(struct platform_device *ofdev)
 {
-	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *ndev = platform_get_drvdata(ofdev);
 	struct fs_enet_private *fep = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 2bafbd3..844ecfa 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -179,7 +179,7 @@ static int fs_enet_mdio_probe(struct platform_device *ofdev)
 	}
 
 	new_bus->parent = &ofdev->dev;
-	dev_set_drvdata(&ofdev->dev, new_bus);
+	platform_set_drvdata(ofdev, new_bus);
 
 	ret = of_mdiobus_register(new_bus, ofdev->dev.of_node);
 	if (ret)
@@ -188,7 +188,6 @@ static int fs_enet_mdio_probe(struct platform_device *ofdev)
 	return 0;
 
 out_free_irqs:
-	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(new_bus->irq);
 out_unmap_regs:
 	iounmap(bitbang->dir);
@@ -202,11 +201,10 @@ out:
 
 static int fs_enet_mdio_remove(struct platform_device *ofdev)
 {
-	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct mii_bus *bus = platform_get_drvdata(ofdev);
 	struct bb_info *bitbang = bus->priv;
 
 	mdiobus_unregister(bus);
-	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
 	free_mdio_bitbang(bus);
 	iounmap(bitbang->dir);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 18e8ef2..2f1c46a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -180,7 +180,7 @@ static int fs_enet_mdio_probe(struct platform_device *ofdev)
 	}
 
 	new_bus->parent = &ofdev->dev;
-	dev_set_drvdata(&ofdev->dev, new_bus);
+	platform_set_drvdata(ofdev, new_bus);
 
 	ret = of_mdiobus_register(new_bus, ofdev->dev.of_node);
 	if (ret)
@@ -189,7 +189,6 @@ static int fs_enet_mdio_probe(struct platform_device *ofdev)
 	return 0;
 
 out_free_irqs:
-	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(new_bus->irq);
 out_unmap_regs:
 	iounmap(fec->fecp);
@@ -204,11 +203,10 @@ out:
 
 static int fs_enet_mdio_remove(struct platform_device *ofdev)
 {
-	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct mii_bus *bus = platform_get_drvdata(ofdev);
 	struct fec_info *fec = bus->priv;
 
 	mdiobus_unregister(bus);
-	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
 	iounmap(fec->fecp);
 	kfree(fec);
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2375a01..14f0694 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1000,7 +1000,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	spin_lock_init(&priv->bflock);
 	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
-	dev_set_drvdata(&ofdev->dev, priv);
+	platform_set_drvdata(ofdev, priv);
 	regs = priv->gfargrp[0].regs;
 
 	gfar_detect_errata(priv);
@@ -1240,15 +1240,13 @@ register_fail:
 
 static int gfar_remove(struct platform_device *ofdev)
 {
-	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
+	struct gfar_private *priv = platform_get_drvdata(ofdev);
 
 	if (priv->phy_node)
 		of_node_put(priv->phy_node);
 	if (priv->tbi_node)
 		of_node_put(priv->tbi_node);
 
-	dev_set_drvdata(&ofdev->dev, NULL);
-
 	unregister_netdev(priv->ndev);
 	unmap_group_regs(priv);
 	free_gfar_dev(priv);
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 083ea2b..098f133 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -519,7 +519,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	}
 	gfar_phc_index = ptp_clock_index(etsects->clock);
 
-	dev_set_drvdata(&dev->dev, etsects);
+	platform_set_drvdata(dev, etsects);
 
 	return 0;
 
@@ -537,7 +537,7 @@ no_memory:
 
 static int gianfar_ptp_remove(struct platform_device *dev)
 {
-	struct etsects *etsects = dev_get_drvdata(&dev->dev);
+	struct etsects *etsects = platform_get_drvdata(dev);
 
 	gfar_write(&etsects->regs->tmr_temask, 0);
 	gfar_write(&etsects->regs->tmr_ctrl,   0);
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index e04c598..3c43dac 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3564,7 +3564,7 @@ static void ucc_geth_timeout(struct net_device *dev)
 
 static int ucc_geth_suspend(struct platform_device *ofdev, pm_message_t state)
 {
-	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *ndev = platform_get_drvdata(ofdev);
 	struct ucc_geth_private *ugeth = netdev_priv(ndev);
 
 	if (!netif_running(ndev))
@@ -3592,7 +3592,7 @@ static int ucc_geth_suspend(struct platform_device *ofdev, pm_message_t state)
 
 static int ucc_geth_resume(struct platform_device *ofdev)
 {
-	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *ndev = platform_get_drvdata(ofdev);
 	struct ucc_geth_private *ugeth = netdev_priv(ndev);
 	int err;
 
diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 418068b..c1b6e7e 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -227,7 +227,7 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
 		goto err_registration;
 	}
 
-	dev_set_drvdata(&pdev->dev, bus);
+	platform_set_drvdata(pdev, bus);
 
 	return 0;
 
@@ -242,7 +242,7 @@ err_ioremap:
 
 static int xgmac_mdio_remove(struct platform_device *pdev)
 {
-	struct mii_bus *bus = dev_get_drvdata(&pdev->dev);
+	struct mii_bus *bus = platform_get_drvdata(pdev);
 
 	mdiobus_unregister(bus);
 	iounmap(bus->priv);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 90ea0b1..0605e76 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3289,7 +3289,7 @@ static int ehea_probe_adapter(struct platform_device *dev,
 
 	adapter->pd = EHEA_PD_ID;
 
-	dev_set_drvdata(&dev->dev, adapter);
+	platform_set_drvdata(dev, adapter);
 
 
 	/* initialize adapter and ports */
@@ -3360,7 +3360,7 @@ out:
 
 static int ehea_remove(struct platform_device *dev)
 {
-	struct ehea_adapter *adapter = dev_get_drvdata(&dev->dev);
+	struct ehea_adapter *adapter = platform_get_drvdata(dev);
 	int i;
 
 	for (i = 0; i < EHEA_MAX_PORTS; i++)
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 610ed223..856ea66 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -696,7 +696,7 @@ static int mal_probe(struct platform_device *ofdev)
 
 	/* Advertise this instance to the rest of the world */
 	wmb();
-	dev_set_drvdata(&ofdev->dev, mal);
+	platform_set_drvdata(ofdev, mal);
 
 	mal_dbg_register(mal);
 
@@ -722,7 +722,7 @@ static int mal_probe(struct platform_device *ofdev)
 
 static int mal_remove(struct platform_device *ofdev)
 {
-	struct mal_instance *mal = dev_get_drvdata(&ofdev->dev);
+	struct mal_instance *mal = platform_get_drvdata(ofdev);
 
 	MAL_DBG(mal, "remove" NL);
 
@@ -735,8 +735,6 @@ static int mal_remove(struct platform_device *ofdev)
 		       "mal%d: commac list is not empty on remove!\n",
 		       mal->index);
 
-	dev_set_drvdata(&ofdev->dev, NULL);
-
 	free_irq(mal->serr_irq, mal);
 	free_irq(mal->txde_irq, mal);
 	free_irq(mal->txeob_irq, mal);
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 3925176..c47e23d 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -95,7 +95,7 @@ static inline u32 rgmii_mode_mask(int mode, int input)
 
 int rgmii_attach(struct platform_device *ofdev, int input, int mode)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct rgmii_regs __iomem *p = dev->base;
 
 	RGMII_DBG(dev, "attach(%d)" NL, input);
@@ -124,7 +124,7 @@ int rgmii_attach(struct platform_device *ofdev, int input, int mode)
 
 void rgmii_set_speed(struct platform_device *ofdev, int input, int speed)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct rgmii_regs __iomem *p = dev->base;
 	u32 ssr;
 
@@ -146,7 +146,7 @@ void rgmii_set_speed(struct platform_device *ofdev, int input, int speed)
 
 void rgmii_get_mdio(struct platform_device *ofdev, int input)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct rgmii_regs __iomem *p = dev->base;
 	u32 fer;
 
@@ -167,7 +167,7 @@ void rgmii_get_mdio(struct platform_device *ofdev, int input)
 
 void rgmii_put_mdio(struct platform_device *ofdev, int input)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct rgmii_regs __iomem *p = dev->base;
 	u32 fer;
 
@@ -188,7 +188,7 @@ void rgmii_put_mdio(struct platform_device *ofdev, int input)
 
 void rgmii_detach(struct platform_device *ofdev, int input)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct rgmii_regs __iomem *p;
 
 	BUG_ON(!dev || dev->users == 0);
@@ -214,7 +214,7 @@ int rgmii_get_regs_len(struct platform_device *ofdev)
 
 void *rgmii_dump_regs(struct platform_device *ofdev, void *buf)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 	struct emac_ethtool_regs_subhdr *hdr = buf;
 	struct rgmii_regs *regs = (struct rgmii_regs *)(hdr + 1);
 
@@ -279,7 +279,7 @@ static int rgmii_probe(struct platform_device *ofdev)
 	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");
 
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	return 0;
 
@@ -291,9 +291,7 @@ static int rgmii_probe(struct platform_device *ofdev)
 
 static int rgmii_remove(struct platform_device *ofdev)
 {
-	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
-
-	dev_set_drvdata(&ofdev->dev, NULL);
+	struct rgmii_instance *dev = platform_get_drvdata(ofdev);
 
 	WARN_ON(dev->users != 0);
 
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index 795f139..c231a4a 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -25,7 +25,7 @@
 
 int tah_attach(struct platform_device *ofdev, int channel)
 {
-	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct tah_instance *dev = platform_get_drvdata(ofdev);
 
 	mutex_lock(&dev->lock);
 	/* Reset has been done at probe() time... nothing else to do for now */
@@ -37,7 +37,7 @@ int tah_attach(struct platform_device *ofdev, int channel)
 
 void tah_detach(struct platform_device *ofdev, int channel)
 {
-	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct tah_instance *dev = platform_get_drvdata(ofdev);
 
 	mutex_lock(&dev->lock);
 	--dev->users;
@@ -46,7 +46,7 @@ void tah_detach(struct platform_device *ofdev, int channel)
 
 void tah_reset(struct platform_device *ofdev)
 {
-	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct tah_instance *dev = platform_get_drvdata(ofdev);
 	struct tah_regs __iomem *p = dev->base;
 	int n;
 
@@ -74,7 +74,7 @@ int tah_get_regs_len(struct platform_device *ofdev)
 
 void *tah_dump_regs(struct platform_device *ofdev, void *buf)
 {
-	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct tah_instance *dev = platform_get_drvdata(ofdev);
 	struct emac_ethtool_regs_subhdr *hdr = buf;
 	struct tah_regs *regs = (struct tah_regs *)(hdr + 1);
 
@@ -118,7 +118,7 @@ static int tah_probe(struct platform_device *ofdev)
 		goto err_free;
 	}
 
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
 	tah_reset(ofdev);
@@ -137,9 +137,7 @@ static int tah_probe(struct platform_device *ofdev)
 
 static int tah_remove(struct platform_device *ofdev)
 {
-	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
-
-	dev_set_drvdata(&ofdev->dev, NULL);
+	struct tah_instance *dev = platform_get_drvdata(ofdev);
 
 	WARN_ON(dev->users != 0);
 
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index f91202f..4cdf286 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -84,7 +84,7 @@ static inline u32 zmii_mode_mask(int mode, int input)
 
 int zmii_attach(struct platform_device *ofdev, int input, int *mode)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 	struct zmii_regs __iomem *p = dev->base;
 
 	ZMII_DBG(dev, "init(%d, %d)" NL, input, *mode);
@@ -150,7 +150,7 @@ int zmii_attach(struct platform_device *ofdev, int input, int *mode)
 
 void zmii_get_mdio(struct platform_device *ofdev, int input)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 	u32 fer;
 
 	ZMII_DBG2(dev, "get_mdio(%d)" NL, input);
@@ -163,7 +163,7 @@ void zmii_get_mdio(struct platform_device *ofdev, int input)
 
 void zmii_put_mdio(struct platform_device *ofdev, int input)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 
 	ZMII_DBG2(dev, "put_mdio(%d)" NL, input);
 	mutex_unlock(&dev->lock);
@@ -172,7 +172,7 @@ void zmii_put_mdio(struct platform_device *ofdev, int input)
 
 void zmii_set_speed(struct platform_device *ofdev, int input, int speed)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 	u32 ssr;
 
 	mutex_lock(&dev->lock);
@@ -193,7 +193,7 @@ void zmii_set_speed(struct platform_device *ofdev, int input, int speed)
 
 void zmii_detach(struct platform_device *ofdev, int input)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 
 	BUG_ON(!dev || dev->users == 0);
 
@@ -218,7 +218,7 @@ int zmii_get_regs_len(struct platform_device *ofdev)
 
 void *zmii_dump_regs(struct platform_device *ofdev, void *buf)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 	struct emac_ethtool_regs_subhdr *hdr = buf;
 	struct zmii_regs *regs = (struct zmii_regs *)(hdr + 1);
 
@@ -272,7 +272,7 @@ static int zmii_probe(struct platform_device *ofdev)
 	printk(KERN_INFO
 	       "ZMII %s initialized\n", ofdev->dev.of_node->full_name);
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	return 0;
 
@@ -284,9 +284,7 @@ static int zmii_probe(struct platform_device *ofdev)
 
 static int zmii_remove(struct platform_device *ofdev)
 {
-	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
-
-	dev_set_drvdata(&ofdev->dev, NULL);
+	struct zmii_instance *dev = platform_get_drvdata(ofdev);
 
 	WARN_ON(dev->users != 0);
 
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index cb9e638..5da3ffb 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -430,11 +430,9 @@ exit:
 
 static int netx_eth_drv_remove(struct platform_device *pdev)
 {
-	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct netx_eth_priv *priv = netdev_priv(ndev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 	xc_stop(priv->xc);
 	free_xc(priv->xc);
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 921729f..e6e0292 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1437,7 +1437,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	dev_set_drvdata(&pdev->dev, netdev);
+	platform_set_drvdata(pdev, netdev);
 	p = netdev_priv(netdev);
 	netif_napi_add(netdev, &p->napi, octeon_mgmt_napi_poll,
 		       OCTEON_MGMT_NAPI_WEIGHT);
@@ -1559,7 +1559,7 @@ err:
 
 static int octeon_mgmt_remove(struct platform_device *pdev)
 {
-	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct net_device *netdev = platform_get_drvdata(pdev);
 
 	unregister_netdev(netdev);
 	free_netdev(netdev);
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 95cff98..fa32240 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -10108,7 +10108,7 @@ static int niu_of_probe(struct platform_device *op)
 		goto err_out_iounmap;
 	}
 
-	dev_set_drvdata(&op->dev, dev);
+	platform_set_drvdata(op, dev);
 
 	niu_device_announce(np);
 
@@ -10145,7 +10145,7 @@ err_out:
 
 static int niu_of_remove(struct platform_device *op)
 {
-	struct net_device *dev = dev_get_drvdata(&op->dev);
+	struct net_device *dev = platform_get_drvdata(op);
 
 	if (dev) {
 		struct niu *np = netdev_priv(dev);
@@ -10175,7 +10175,6 @@ static int niu_of_remove(struct platform_device *op)
 		niu_put_parent(np);
 
 		free_netdev(dev);
-		dev_set_drvdata(&op->dev, NULL);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 436fa9d..171f5b0 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2506,7 +2506,7 @@ static struct quattro *quattro_sbus_find(struct platform_device *child)
 	struct quattro *qp;
 
 	op = to_platform_device(parent);
-	qp = dev_get_drvdata(&op->dev);
+	qp = platform_get_drvdata(op);
 	if (qp)
 		return qp;
 
@@ -2521,7 +2521,7 @@ static struct quattro *quattro_sbus_find(struct platform_device *child)
 		qp->next = qfe_sbus_list;
 		qfe_sbus_list = qp;
 
-		dev_set_drvdata(&op->dev, qp);
+		platform_set_drvdata(op, qp);
 	}
 	return qp;
 }
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 8182591b..b072f4d 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -767,7 +767,7 @@ static struct sunqec *get_qec(struct platform_device *child)
 	struct platform_device *op = to_platform_device(child->dev.parent);
 	struct sunqec *qecp;
 
-	qecp = dev_get_drvdata(&op->dev);
+	qecp = platform_get_drvdata(op);
 	if (!qecp) {
 		qecp = kzalloc(sizeof(struct sunqec), GFP_KERNEL);
 		if (qecp) {
@@ -801,7 +801,7 @@ static struct sunqec *get_qec(struct platform_device *child)
 				goto fail;
 			}
 
-			dev_set_drvdata(&op->dev, qecp);
+			platform_set_drvdata(op, qecp);
 
 			qecp->next_module = root_qec_dev;
 			root_qec_dev = qecp;
@@ -902,7 +902,7 @@ static int qec_ether_init(struct platform_device *op)
 	if (res)
 		goto fail;
 
-	dev_set_drvdata(&op->dev, qe);
+	platform_set_drvdata(op, qe);
 
 	printk(KERN_INFO "%s: qe channel[%d] %pM\n", dev->name, qe->channel,
 	       dev->dev_addr);
@@ -934,7 +934,7 @@ static int qec_sbus_probe(struct platform_device *op)
 
 static int qec_sbus_remove(struct platform_device *op)
 {
-	struct sunqe *qp = dev_get_drvdata(&op->dev);
+	struct sunqe *qp = platform_get_drvdata(op);
 	struct net_device *net_dev = qp->dev;
 
 	unregister_netdev(net_dev);
@@ -948,8 +948,6 @@ static int qec_sbus_remove(struct platform_device *op)
 
 	free_netdev(net_dev);
 
-	dev_set_drvdata(&op->dev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 57c2e5e..58eb448 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1007,7 +1007,7 @@ static int temac_of_probe(struct platform_device *op)
 		return -ENOMEM;
 
 	ether_setup(ndev);
-	dev_set_drvdata(&op->dev, ndev);
+	platform_set_drvdata(op, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
@@ -1136,7 +1136,7 @@ static int temac_of_probe(struct platform_device *op)
 
 static int temac_of_remove(struct platform_device *op)
 {
-	struct net_device *ndev = dev_get_drvdata(&op->dev);
+	struct net_device *ndev = platform_get_drvdata(op);
 	struct temac_local *lp = netdev_priv(ndev);
 
 	temac_mdio_teardown(lp);
@@ -1145,7 +1145,6 @@ static int temac_of_remove(struct platform_device *op)
 	if (lp->phy_node)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
-	dev_set_drvdata(&op->dev, NULL);
 	iounmap(lp->regs);
 	if (lp->sdma_regs)
 		iounmap(lp->sdma_regs);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 24748e8..fb7d1c2 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1484,7 +1484,7 @@ static int axienet_of_probe(struct platform_device *op)
 		return -ENOMEM;
 
 	ether_setup(ndev);
-	dev_set_drvdata(&op->dev, ndev);
+	platform_set_drvdata(op, ndev);
 
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
@@ -1622,7 +1622,7 @@ nodev:
 
 static int axienet_of_remove(struct platform_device *op)
 {
-	struct net_device *ndev = dev_get_drvdata(&op->dev);
+	struct net_device *ndev = platform_get_drvdata(op);
 	struct axienet_local *lp = netdev_priv(ndev);
 
 	axienet_mdio_teardown(lp);
@@ -1632,8 +1632,6 @@ static int axienet_of_remove(struct platform_device *op)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
 
-	dev_set_drvdata(&op->dev, NULL);
-
 	iounmap(lp->regs);
 	if (lp->dma_regs)
 		iounmap(lp->dma_regs);
-- 
1.7.10.4
