From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/11] forcedeth: Separate vendor specific initializations into functions
Date: Mon, 29 Nov 2010 09:41:59 -0800
Message-ID: <32f58a17265c32d6e5decb25d25e29da33c6dfb5.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neaten the phy_init function by adding and calling vendor
specific functions.

object size is reduced by ~1kb:

$ size drivers/net/forcedeth.o.*
   text	   data	    bss	    dec	    hex	filename
  83475	   1848	  19304	 104627	  198b3	drivers/net/forcedeth.o.new
  84459	   1848	  19544	 105851	  19d7b	drivers/net/forcedeth.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  367 ++++++++++++++++++++++++-----------------------
 1 files changed, 188 insertions(+), 179 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 300748c..0b1d562 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1198,21 +1198,179 @@ static int init_realtek_8211b(struct net_device *dev, struct fe_priv *np)
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(ri); i++) {
-		if (mii_rw(dev, np->phyaddr, ri[i].reg, ri[i].init)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
+		if (mii_rw(dev, np->phyaddr, ri[i].reg, ri[i].init))
+			return PHY_ERROR;
+	}
+
+	return 0;
+}
+
+static int init_realtek_8211c(struct net_device *dev, struct fe_priv *np)
+{
+	u32 reg;
+	u8 __iomem *base = get_hwbase(dev);
+	u32 powerstate = readl(base + NvRegPowerState2);
+
+	/* need to perform hw phy reset */
+	powerstate |= NVREG_POWERSTATE2_PHY_RESET;
+	writel(powerstate, base + NvRegPowerState2);
+	msleep(25);
+
+	powerstate &= ~NVREG_POWERSTATE2_PHY_RESET;
+	writel(powerstate, base + NvRegPowerState2);
+	msleep(25);
+
+	reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
+	reg |= PHY_REALTEK_INIT9;
+	if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10))
+		return PHY_ERROR;
+	reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
+	if (!(reg & PHY_REALTEK_INIT11)) {
+		reg |= PHY_REALTEK_INIT11;
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg))
+			return PHY_ERROR;
+	}
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1))
+		return PHY_ERROR;
+
+	return 0;
+}
+
+static int init_realtek_8201(struct net_device *dev, struct fe_priv *np)
+{
+	u32 phy_reserved;
+
+	if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
+		phy_reserved = mii_rw(dev, np->phyaddr,
+				      PHY_REALTEK_INIT_REG6, MII_READ);
+		phy_reserved |= PHY_REALTEK_INIT7;
+		if (mii_rw(dev, np->phyaddr,
+			   PHY_REALTEK_INIT_REG6, phy_reserved))
 			return PHY_ERROR;
-		}
 	}
 
 	return 0;
 }
 
+static int init_realtek_8201_cross(struct net_device *dev, struct fe_priv *np)
+{
+	u32 phy_reserved;
+
+	if (phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
+		if (mii_rw(dev, np->phyaddr,
+			   PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3))
+			return PHY_ERROR;
+		phy_reserved = mii_rw(dev, np->phyaddr,
+				      PHY_REALTEK_INIT_REG2, MII_READ);
+		phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
+		phy_reserved |= PHY_REALTEK_INIT3;
+		if (mii_rw(dev, np->phyaddr,
+			   PHY_REALTEK_INIT_REG2, phy_reserved))
+			return PHY_ERROR;
+		if (mii_rw(dev, np->phyaddr,
+			   PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1))
+			return PHY_ERROR;
+	}
+
+	return 0;
+}
+
+static int init_cicada(struct net_device *dev, struct fe_priv *np,
+		       u32 phyinterface)
+{
+	u32 phy_reserved;
+
+	if (phyinterface & PHY_RGMII) {
+		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
+		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
+		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
+		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved))
+			return PHY_ERROR;
+		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
+		phy_reserved |= PHY_CICADA_INIT5;
+		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved))
+			return PHY_ERROR;
+	}
+	phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
+	phy_reserved |= PHY_CICADA_INIT6;
+	if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved))
+		return PHY_ERROR;
+
+	return 0;
+}
+
+static int init_vitesse(struct net_device *dev, struct fe_priv *np)
+{
+	u32 phy_reserved;
+
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG4, MII_READ);
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG3, MII_READ);
+	phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+	phy_reserved |= PHY_VITESSE_INIT3;
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG4, MII_READ);
+	phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+	phy_reserved |= PHY_VITESSE_INIT3;
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG3, MII_READ);
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG4, MII_READ);
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved))
+		return PHY_ERROR;
+	phy_reserved = mii_rw(dev, np->phyaddr,
+			      PHY_VITESSE_INIT_REG3, MII_READ);
+	phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
+	phy_reserved |= PHY_VITESSE_INIT8;
+	if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9))
+		return PHY_ERROR;
+	if (mii_rw(dev, np->phyaddr,
+		   PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10))
+		return PHY_ERROR;
+
+	return 0;
+}
+
 static int phy_init(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 phyinterface, phy_reserved, mii_status, mii_control, mii_control_1000, reg;
+	u32 phyinterface;
+	u32 mii_status, mii_control, mii_control_1000, reg;
 
 	/* phy errata for E3016 phy */
 	if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
@@ -1227,64 +1385,32 @@ static int phy_init(struct net_device *dev)
 	if (np->phy_oui == PHY_OUI_REALTEK) {
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
-			if (init_realtek_8211b(dev, np))
-				return PHY_ERROR;
-		} else if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
-			   np->phy_rev == PHY_REV_REALTEK_8211C) {
-			u32 powerstate = readl(base + NvRegPowerState2);
-
-			/* need to perform hw phy reset */
-			powerstate |= NVREG_POWERSTATE2_PHY_RESET;
-			writel(powerstate, base + NvRegPowerState2);
-			msleep(25);
-
-			powerstate &= ~NVREG_POWERSTATE2_PHY_RESET;
-			writel(powerstate, base + NvRegPowerState2);
-			msleep(25);
-
-			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
-			reg |= PHY_REALTEK_INIT9;
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg)) {
+			if (init_realtek_8211b(dev, np)) {
 				netdev_info(dev, "%s: phy init failed\n",
 					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10)) {
+		} else if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+			   np->phy_rev == PHY_REV_REALTEK_8211C) {
+			if (init_realtek_8211c(dev, np)) {
 				netdev_info(dev, "%s: phy init failed\n",
 					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
-			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
-			if (!(reg & PHY_REALTEK_INIT11)) {
-				reg |= PHY_REALTEK_INIT11;
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+		} else if (np->phy_model == PHY_MODEL_REALTEK_8201) {
+			if (init_realtek_8201(dev, np)) {
 				netdev_info(dev, "%s: phy init failed\n",
 					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
-		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
-			if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
-				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
-				phy_reserved |= PHY_REALTEK_INIT7;
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
-			}
-		}
 	}
 
 	/* set advertise register */
 	reg = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
-	reg |= (ADVERTISE_10HALF|ADVERTISE_10FULL|ADVERTISE_100HALF|ADVERTISE_100FULL|ADVERTISE_PAUSE_ASYM|ADVERTISE_PAUSE_CAP);
+	reg |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
+		ADVERTISE_100HALF | ADVERTISE_100FULL |
+		ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP);
 	if (mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg)) {
 		netdev_info(dev, "%s: phy write to advertise failed\n",
 			    pci_name(np->pci_dev));
@@ -1298,7 +1424,8 @@ static int phy_init(struct net_device *dev)
 	mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
 	if (mii_status & PHY_GIGABIT) {
 		np->gigabit = PHY_GIGABIT;
-		mii_control_1000 = mii_rw(dev, np->phyaddr, MII_CTRL1000, MII_READ);
+		mii_control_1000 = mii_rw(dev, np->phyaddr,
+					  MII_CTRL1000, MII_READ);
 		mii_control_1000 &= ~ADVERTISE_1000HALF;
 		if (phyinterface & PHY_RGMII)
 			mii_control_1000 |= ADVERTISE_1000FULL;
@@ -1338,151 +1465,33 @@ static int phy_init(struct net_device *dev)
 	}
 
 	/* phy vendor specific configuration */
-	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII)) {
-		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
-		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
-		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
-		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
-		phy_reserved |= PHY_CICADA_INIT5;
-		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-	}
-	if (np->phy_oui == PHY_OUI_CICADA) {
-		phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
-		phy_reserved |= PHY_CICADA_INIT6;
-		if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-	}
-	if (np->phy_oui == PHY_OUI_VITESSE) {
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
-		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
-		phy_reserved |= PHY_VITESSE_INIT3;
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5)) {
+	if ((np->phy_oui == PHY_OUI_CICADA)) {
+		if (init_cicada(dev, np, phyinterface)) {
 			netdev_info(dev, "%s: phy init failed\n",
 				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
-		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
-		phy_reserved |= PHY_VITESSE_INIT3;
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+	} else if (np->phy_oui == PHY_OUI_VITESSE) {
+		if (init_vitesse(dev, np)) {
 			netdev_info(dev, "%s: phy init failed\n",
 				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
-		phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
-		phy_reserved |= PHY_VITESSE_INIT8;
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10)) {
-			netdev_info(dev, "%s: phy init failed\n",
-				    pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-	}
-	if (np->phy_oui == PHY_OUI_REALTEK) {
+	} else if (np->phy_oui == PHY_OUI_REALTEK) {
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			/* reset could have cleared these out, set them back */
-			if (init_realtek_8211b(dev, np))
+			if (init_realtek_8211b(dev, np)) {
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
-		} else if (np->phy_model == PHY_MODEL_REALTEK_8201) {
-			if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
-				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
-				phy_reserved |= PHY_REALTEK_INIT7;
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
 			}
-			if (phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
-				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII_READ);
-				phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
-				phy_reserved |= PHY_REALTEK_INIT3;
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
-				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-					netdev_info(dev, "%s: phy init failed\n",
-						    pci_name(np->pci_dev));
-					return PHY_ERROR;
-				}
+		} else if (np->phy_model == PHY_MODEL_REALTEK_8201) {
+			if (init_realtek_8201(dev, np) ||
+			    init_realtek_8201_cross(dev, np)) {
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
+				return PHY_ERROR;
 			}
 		}
 	}
-- 
1.7.3.2.245.g03276.dirty
