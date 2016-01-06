From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 08/22] phy: Centralise print about attached phy
Date: Wed,  6 Jan 2016 20:11:13 +0100
Message-ID: <1452107487-475-9-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42298 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:11:41 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many Ethernet drivers contain the same netdev_info() print statement
about the attached phy. Move it into the phy device code. Additionally
add a varargs function which can be used to append additional
information.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Add a function to do the printing, and a varargs variant.
---
 drivers/net/ethernet/adi/bfin_mac.c          |  6 ++----
 drivers/net/ethernet/agere/et131x.c          |  4 +---
 drivers/net/ethernet/amd/au1000_eth.c        |  4 +---
 drivers/net/ethernet/broadcom/b44.c          |  3 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |  3 +--
 drivers/net/ethernet/broadcom/sb1250-mac.c   |  7 +++----
 drivers/net/ethernet/broadcom/tg3.c          | 10 +++-------
 drivers/net/ethernet/cadence/macb.c          |  3 +--
 drivers/net/ethernet/dnet.c                  |  4 +---
 drivers/net/ethernet/freescale/fec_main.c    |  4 +---
 drivers/net/ethernet/lantiq_etop.c           |  4 +---
 drivers/net/ethernet/nxp/lpc_eth.c           |  5 ++---
 drivers/net/ethernet/rdc/r6040.c             |  4 +---
 drivers/net/ethernet/renesas/ravb_main.c     |  3 +--
 drivers/net/ethernet/renesas/sh_eth.c        |  3 +--
 drivers/net/ethernet/smsc/smsc911x.c         |  4 +---
 drivers/net/ethernet/smsc/smsc9420.c         |  9 ++-------
 drivers/net/ethernet/synopsys/dwc_eth_qos.c  | 12 +-----------
 drivers/net/ethernet/ti/cpsw.c               |  4 ++--
 drivers/net/ethernet/ti/davinci_emac.c       |  5 +----
 drivers/net/ethernet/toshiba/tc35815.c       |  6 ++----
 drivers/net/phy/phy_device.c                 | 27 +++++++++++++++++++++++++++
 drivers/staging/netlogic/xlr_net.c           |  3 +--
 include/linux/phy.h                          |  4 ++++
 net/dsa/slave.c                              |  5 ++---
 25 files changed, 64 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 5f8a5182b8dc..ed5c78cb7239 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -444,10 +444,8 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	lp->old_duplex = -1;
 	lp->phydev = phydev;
 
-	pr_info("attached PHY driver [%s] "
-	        "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
-		phydev->drv->name, phydev_name(phydev), phydev->irq,
-	        MDC_CLK, mdc_div, sclk/1000000);
+	phy_attached_print(phydev, "mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
+			   MDC_CLK, mdc_div, sclk / 1000000);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 80b706f0fc97..825da3af806a 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3289,9 +3289,7 @@ static int et131x_mii_probe(struct net_device *netdev)
 	phydev->autoneg = AUTONEG_ENABLE;
 	adapter->phydev = phydev;
 
-	dev_info(&adapter->pdev->dev,
-		 "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-		 phydev->drv->name, phydev_name(phydev));
+	phy_attached_info(phydev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8a8d6f2a0f6f..114618d357d5 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -583,9 +583,7 @@ static int au1000_mii_probe(struct net_device *dev)
 	aup->old_duplex = -1;
 	aup->phy_dev = phydev;
 
-	netdev_info(dev, "attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       phydev->drv->name, phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 928a2210e788..e7d9308d6760 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2315,8 +2315,7 @@ static int b44_register_phy_one(struct b44 *bp)
 	bp->old_link = 0;
 	bp->phy_addr = phydev->addr;
 
-	dev_info(sdev->dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-		 phydev->drv->name, phydev_name(phydev));
+	phy_attached_info(phydev);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a54bafad3538..55f31faa09e6 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -908,8 +908,7 @@ static int bcm_enet_open(struct net_device *dev)
 		else
 			phydev->advertising &= ~SUPPORTED_Pause;
 
-		dev_info(kdev, "attached PHY at address %d [%s]\n",
-			 phydev->addr, phydev->drv->name);
+		phy_attached_info(phydev);
 
 		priv->old_link = 0;
 		priv->old_duplex = -1;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index f557a2aaec23..2470c6084c67 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2388,11 +2388,10 @@ static int sbmac_mii_probe(struct net_device *dev)
 			      SUPPORTED_MII |
 			      SUPPORTED_Pause |
 			      SUPPORTED_Asym_Pause;
-	phy_dev->advertising = phy_dev->supported;
 
-	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		dev->name, phy_dev->drv->name,
-		dev_name(&phy_dev->dev), phy_dev->irq);
+	phy_attached_info(phydev);
+
+	phy_dev->advertising = phy_dev->supported;
 
 	sc->phy_dev = phy_dev;
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 69d84d67f09a..07c067590caa 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2128,6 +2128,8 @@ static int tg3_phy_init(struct tg3 *tp)
 
 	phydev->advertising = phydev->supported;
 
+	phy_attached_info(phydev);
+
 	return 0;
 }
 
@@ -17898,13 +17900,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 		    tg3_bus_string(tp, str),
 		    dev->dev_addr);
 
-	if (tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) {
-		struct phy_device *phydev;
-		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
-		netdev_info(dev,
-			    "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-			    phydev->drv->name, phydev_name(phydev));
-	} else {
+	if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED)) {
 		char *ethtype;
 
 		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 001d60c5521c..98df33b7a395 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2950,8 +2950,7 @@ static int macb_probe(struct platform_device *pdev)
 		    dev->base_addr, dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
-	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 0ec367521354..6557460cf028 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -886,9 +886,7 @@ static int dnet_probe(struct platform_device *pdev)
 	       (bp->capabilities & DNET_HAS_GIGABIT) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_DMA) ? "" : "no ");
 	phydev = bp->phy_dev;
-	dev_info(&pdev->dev, "attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       phydev->drv->name, phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d2328fc5da57..ceabe21b3b2c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1972,9 +1972,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	fep->link = 0;
 	fep->full_duplex = 0;
 
-	netdev_info(ndev, "Freescale FEC PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
-		    fep->phy_dev->irq);
+	phy_attached_info(phy_dev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 274a3cec84c2..86238a5eaddf 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -408,9 +408,7 @@ ltq_etop_mdio_probe(struct net_device *dev)
 
 	phydev->advertising = phydev->supported;
 	priv->phydev = phydev;
-	pr_info("%s: attached PHY [%s] (phy_addr=%s, irq=%d)\n",
-	       dev->name, phydev->drv->name,
-	       phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 5801aa197697..024bc3675573 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -816,9 +816,8 @@ static int lpc_mii_probe(struct net_device *ndev)
 	pldat->duplex = -1;
 	pldat->phy_dev = phydev;
 
-	netdev_info(ndev,
-		"attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		phydev->drv->name, phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 86a0887811c7..174dea787caf 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1061,9 +1061,7 @@ static int r6040_mii_probe(struct net_device *dev)
 	lp->old_link = 0;
 	lp->old_duplex = -1;
 
-	dev_info(&lp->pdev->dev, "attached PHY driver [%s] "
-		"(mii_bus:phy_addr=%s)\n",
-		phydev->drv->name, phydev_name(phydev));
+	phy_attached_info(phydev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 2f6c974e4a6d..9e20f37a3b6f 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -927,8 +927,7 @@ static int ravb_phy_init(struct net_device *ndev)
 	/* 10BASE is not supported */
 	phydev->supported &= ~PHY_10BT_FEATURES;
 
-	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
-		    phydev->addr, phydev->irq, phydev_name(phydev));
+	phy_attached_info(phydev);
 
 	priv->phydev = phydev;
 
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index e14d28474b70..94581be64d65 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1826,8 +1826,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 		return PTR_ERR(phydev);
 	}
 
-	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
-		    phydev->addr, phydev->irq, phydev_name(phydev));
+	phy_attached_info(phydev);
 
 	mdp->phydev = phydev;
 
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 067346d3209d..139b99b04099 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1031,9 +1031,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 		return ret;
 	}
 
-	netdev_info(dev,
-		    "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
+	phy_attached_info(phydev);
 
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a02ed6b63064..fa8893a804f7 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1163,10 +1163,6 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	phydev = pd->mii_bus->phy_map[1];
-	netif_info(pd, probe, pd->dev, "PHY addr %d, phy_id 0x%08X\n",
-		   phydev->addr, phydev->phy_id);
-
 	phydev = phy_connect(dev, phydev_name(phydev),
 			     smsc9420_phy_adjust_link, PHY_INTERFACE_MODE_MII);
 
@@ -1175,14 +1171,13 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		return PTR_ERR(phydev);
 	}
 
-	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
-
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			      SUPPORTED_Asym_Pause);
 	phydev->advertising = phydev->supported;
 
+	phy_attached_info(phydev);
+
 	pd->phy_dev = phydev;
 	pd->last_duplex = -1;
 	pd->last_carrier = -1;
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 9066d7a8483c..b25ee370254a 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -972,9 +972,7 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	}
 
 	if (netif_msg_probe(lp))
-		netdev_dbg(lp->ndev,
-			   "phydev %p, phydev->phy_id 0xa%x, phydev->addr 0x%x\n",
-			   phydev, phydev->phy_id, phydev->addr);
+		phy_attached_info(phydev);
 
 	phydev->supported &= PHY_GBIT_FEATURES;
 
@@ -983,14 +981,6 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	lp->duplex  = DUPLEX_UNKNOWN;
 	lp->phy_dev = phydev;
 
-	if (netif_msg_probe(lp)) {
-		netdev_dbg(lp->ndev, "phy_addr 0x%x, phy_id 0x%08x\n",
-			   lp->phy_dev->addr, lp->phy_dev->phy_id);
-
-		netdev_dbg(lp->ndev, "attach [%s] phy driver\n",
-			   lp->phy_dev->drv->name);
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 34ce7dce8c9d..49544c0fa6a7 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1159,8 +1159,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 			slave->data->phy_id, slave->slave_num);
 		slave->phy = NULL;
 	} else {
-		dev_info(priv->dev, "phy found : id is : 0x%x\n",
-			 slave->phy->phy_id);
+		phy_attached_info(slave->phy);
+
 		phy_start(slave->phy);
 
 		/* Configure GMII_SEL register */
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 5a40b0256327..5d9abedd6b75 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1644,10 +1644,7 @@ static int emac_dev_open(struct net_device *ndev)
 		priv->speed = 0;
 		priv->duplex = ~0;
 
-		dev_info(emac_dev, "attached PHY driver [%s] "
-			"(mii_bus:phy_addr=%s, id=%x)\n",
-			priv->phydev->drv->name, phydev_name(priv->phydev),
-			priv->phydev->phy_id);
+		phy_attached_info(priv->phydev);
 	}
 
 	if (!priv->phydev) {
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 8df6072ac78d..8fd5e0ba718c 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -638,10 +638,8 @@ static int tc_mii_probe(struct net_device *dev)
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
 	}
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
-		"(mii_bus:phy_addr=%s, id=%x)\n",
-		dev->name, phydev->drv->name, phydev_name(phydev),
-		phydev->phy_id);
+
+	phy_attached_info(phydev);
 
 	/* mask with MAC supported features */
 	phydev->supported &= PHY_BASIC_FEATURES;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0f179709a289..68fe5738daef 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -607,6 +607,33 @@ int phy_init_hw(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_init_hw);
 
+void phy_attached_info(struct phy_device *phydev)
+{
+	phy_attached_print(phydev, NULL);
+}
+EXPORT_SYMBOL(phy_attached_info);
+
+#define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)"
+void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
+{
+	if (!fmt) {
+		dev_info(&phydev->dev, ATTACHED_FMT "\n",
+			 phydev->drv->name, phydev_name(phydev),
+			 phydev->irq);
+	} else {
+		va_list ap;
+
+		dev_info(&phydev->dev, ATTACHED_FMT,
+			 phydev->drv->name, phydev_name(phydev),
+			 phydev->irq);
+
+		va_start(ap, fmt);
+		vprintk(fmt, ap);
+		va_end(ap);
+	}
+}
+EXPORT_SYMBOL(phy_attached_print);
+
 /**
  * phy_attach_direct - attach a network device to a given PHY device pointer
  * @dev: network device to attach
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index b939c4b5f229..cbc25b7e70a2 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -854,8 +854,7 @@ static int xlr_mii_probe(struct xlr_net_priv *priv)
 				| ADVERTISED_MII);
 
 	phydev->advertising = phydev->supported;
-	pr_info("attached PHY driver [%s] (mii_bus:phy_addr=%s\n",
-		phydev->drv->name, phydev_name(phydev));
+	phy_attached_info(phydev);
 	return 0;
 }
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 08198ce98773..ecbf6382ba29 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -16,6 +16,7 @@
 #ifndef __PHY_H
 #define __PHY_H
 
+#include <linux/compiler.h>
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/mdio.h>
@@ -785,6 +786,9 @@ static inline const char *phydev_name(const struct phy_device *phydev)
 	return dev_name(&phydev->dev);
 }
 
+void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
+	__printf(2, 3);
+void phy_attached_info(struct phy_device *phydev);
 int genphy_config_init(struct phy_device *phydev);
 int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1e9e9424a33d..5f45e68b52dc 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1080,11 +1080,10 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
 			return ret;
 		}
-	} else {
-		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
-			    p->phy->addr, p->phy->drv->name);
 	}
 
+	phy_attached_info(p->phy);
+
 	return 0;
 }
 
-- 
2.6.4
