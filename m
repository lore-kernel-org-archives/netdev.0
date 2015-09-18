From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 5/7] net: fix phy refcounting in a bunch of drivers
Date: Fri, 18 Sep 2015 10:47:34 +0100
Message-ID: <E1ZcsGU-0000ud-Uf@rmk-PC.arm.linux.org.uk>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>, Robert Richter <rric@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Rob Herring <robh+dt@kernel.org>, Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org, Sören Brinkmann <soren.brinkmann@xilinx.com>, Iyappan Subramanian <isubramanian@apm.com>, Grant Likely <grant.likely@linaro.org>, Li Yang <leoli@freescale.com>, Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

of_phy_find_device() increments the phy struct device refcount,
which we need to properly balance.  Add code to network drivers
using this function to ensure that the struct device refcount is
correctly balanced.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 23 +++++++++++++++--------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 19 +++++++++++++++++++
 drivers/net/ethernet/freescale/gianfar.c          |  3 +++
 drivers/net/ethernet/freescale/ucc_geth.c         |  8 +++++++-
 drivers/net/ethernet/marvell/mvneta.c             |  2 ++
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |  2 ++
 6 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index cfa37041ab71..d2103a3199eb 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -689,16 +689,23 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_dbg(ndev, "No phy-handle found in DT\n");
 			return -ENODEV;
 		}
-		pdata->phy_dev = of_phy_find_device(phy_np);
-	}
 
-	phy_dev = pdata->phy_dev;
+		pdata->phy_dev = of_phy_connect(ndev, phy_np,
+						&xgene_enet_adjust_link,
+						pdata->phy_mode);
+		if (!pdata->phy_dev) {
+			netdev_err(ndev, "Could not connect to PHY\n");
+			return -ENODEV;
+		}
+	} else {
+		phy_dev = pdata->phy_dev;
 
-	if (!phy_dev ||
-	    phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
-			       pdata->phy_mode)) {
-		netdev_err(ndev, "Could not connect to PHY\n");
-		return  -ENODEV;
+		if (!phy_dev ||
+		    phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
+				       pdata->phy_mode)) {
+			netdev_err(ndev, "Could not connect to PHY\n");
+			return  -ENODEV;
+		}
 	}
 
 	pdata->phy_speed = SPEED_UNKNOWN;
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 574c49278900..529d212bd071 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -1000,6 +1000,20 @@ static int bgx_init_phy(struct bgx *bgx)
 	return bgx_init_of_phy(bgx);
 }
 
+/*
+ * This drops the refcount obtained from of_phy_find_device() above.
+ * We do not need to keep the refcount after phy_connect_direct() has
+ * taken its own reference.
+ */
+static void bgx_drop_phy_ref(struct bgx *bgx)
+{
+	unsigned int lmac;
+
+	for (lmac = 0; lmac < bgx->lmac_count; lmac++)
+		if (bgx->lmac[lmac].phydev)
+			put_device(&bgx->lmac[lmac].phydev->dev);
+}
+
 static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err;
@@ -1056,9 +1070,14 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
+	if (np)
+		bgx_drop_phy_ref(bgx);
+
 	return 0;
 
 err_enable:
+	if (np)
+		bgx_drop_phy_ref(bgx);
 	bgx_vnic[bgx->bgx_id] = NULL;
 err_release_regions:
 	pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4b69d061d90f..65a16086faec 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1702,6 +1702,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 	tbiphy = of_phy_find_device(priv->tbi_node);
 	if (!tbiphy) {
 		dev_err(&dev->dev, "error: Could not get TBI device\n");
+		put_device(&tbiphy->dev);
 		return;
 	}
 
@@ -1723,6 +1724,8 @@ static void gfar_configure_serdes(struct net_device *dev)
 	phy_write(tbiphy, MII_BMCR,
 		  BMCR_ANENABLE | BMCR_ANRESTART | BMCR_FULLDPLX |
 		  BMCR_SPEED1000);
+
+	put_device(&tbiphy->dev);
 }
 
 static int __gfar_is_rx_idle(struct gfar_private *priv)
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 4dd40e057f40..650f7888e32b 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -1384,6 +1384,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 		value = phy_read(tbiphy, ENET_TBI_MII_CR);
 		value &= ~0x1000;	/* Turn off autonegotiation */
 		phy_write(tbiphy, ENET_TBI_MII_CR, value);
+
+		put_device(&tbiphy->dev);
 	}
 
 	init_check_frame_length_mode(ug_info->lengthCheckRx, &ug_regs->maccfg2);
@@ -1702,8 +1704,10 @@ static void uec_configure_serdes(struct net_device *dev)
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
 	 */
-	if (phy_read(tbiphy, ENET_TBI_MII_SR) & TBISR_LSTATUS)
+	if (phy_read(tbiphy, ENET_TBI_MII_SR) & TBISR_LSTATUS) {
+		put_device(&tbiphy->dev);
 		return;
+	}
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	phy_write(tbiphy, ENET_TBI_MII_ANA, TBIANA_SETTINGS);
@@ -1711,6 +1715,8 @@ static void uec_configure_serdes(struct net_device *dev)
 	phy_write(tbiphy, ENET_TBI_MII_TBICON, TBICON_CLK_SELECT);
 
 	phy_write(tbiphy, ENET_TBI_MII_CR, TBICR_SETTINGS);
+
+	put_device(&tbiphy->dev);
 }
 
 /* Configure the PHY for dev.
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index fe2299ac4f5c..0dce037a2682 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3173,6 +3173,8 @@ static int mvneta_probe(struct platform_device *pdev)
 		struct phy_device *phy = of_phy_find_device(dn);
 
 		mvneta_fixed_link_update(pp, phy);
+
+		put_device(&phy->dev);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 6008eee01a33..cf468c87ce57 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -828,6 +828,8 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 		if (!phydev)
 			dev_info(dev,
 				 "MDIO of the phy is not registered yet\n");
+		else
+			put_device(&phydev->dev);
 		return 0;
 	}
 
-- 
2.1.0
