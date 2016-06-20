From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH] net: macb: Add gmii2rgmii converter support
Date: Mon, 20 Jun 2016 10:57:17 +0530
Message-ID: <1466400437-21277-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <nicolas.ferre@atmel.com>, <punnaia@xilinx.com>,
	<harinik@xilinx.com>, <anirudh@xilinx.com>, <michals@xilinx.com>,
	<appanad@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for gmii2rgmii converter
in the macb driver.

The GMII to RGMII IP core provides the
Reduced Gigabit Media Independent Interface
(RGMII) between Ethernet physical media devices
And the Gigabit Ethernet controller.
This core can switch dynamically between the
Three different speed modes of operation (10/100/1000 Mb/s).
MDIO interface is used to set operating speed of Ethernet MAC.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
--> Tried to include this Coverter support in the
PHY layer but it won't fit into the PHY framework as the
coverter won't have vaild vendor/Device id registers.
--> The Converter has only one register (16) that need's
to be programmed with the external phy negotiated speed.
--> The converter won't follow the Standard MII(ieee 802.3 clause 22).
--> Will appreciate if someone can help on adding this coverter support

 drivers/net/ethernet/cadence/macb.c |   37 ++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/cadence/macb.h |    7 ++++++
 2 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cb07d95..2b6412a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -305,8 +305,10 @@ static void macb_handle_link_change(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *gmii2rgmii_phydev = bp->gmii2rgmii_phy_dev;
 	unsigned long flags;
 	int status_change = 0;
+	u16 gmii2rgmii_reg = 0;
 
 	spin_lock_irqsave(&bp->lock, flags);
 
@@ -320,15 +322,26 @@ static void macb_handle_link_change(struct net_device *dev)
 			if (macb_is_gem(bp))
 				reg &= ~GEM_BIT(GBE);
 
-			if (phydev->duplex)
+			if (phydev->duplex) {
 				reg |= MACB_BIT(FD);
-			if (phydev->speed == SPEED_100)
+				gmii2rgmii_reg |= MACB_GMII2RGMII_FULLDPLX;
+			}
+			if (phydev->speed == SPEED_100) {
 				reg |= MACB_BIT(SPD);
+				gmii2rgmii_reg |= MACB_GMII2RGMII_SPEED100;
+			}
 			if (phydev->speed == SPEED_1000 &&
-			    bp->caps & MACB_CAPS_GIGABIT_MODE_AVAILABLE)
+			    bp->caps & MACB_CAPS_GIGABIT_MODE_AVAILABLE) {
 				reg |= GEM_BIT(GBE);
+				gmii2rgmii_reg |= MACB_GMII2RGMII_SPEED1000;
+			}
 
 			macb_or_gem_writel(bp, NCFGR, reg);
+			if (!gmii2rgmii_phydev) {
+				phy_write(gmii2rgmii_phydev,
+					  MACB_GMII2RGMII_REG_NUM,
+					  gmii2rgmii_reg);
+			}
 
 			bp->speed = phydev->speed;
 			bp->duplex = phydev->duplex;
@@ -376,6 +389,20 @@ static int macb_mii_probe(struct net_device *dev)
 	int phy_irq;
 	int ret;
 
+	if (bp->gmii2rgmii_phy_node) {
+		phydev = of_phy_attach(bp->dev,
+				       bp->gmii2rgmii_phy_node,
+				       0, 0);
+		if (!phydev) {
+			dev_err(&bp->pdev->dev, "%s: no gmii_to_rgmii found\n",
+				dev->name);
+			return -1;
+		}
+		bp->gmii2rgmii_phy_dev = phydev;
+	} else {
+		bp->gmii2rgmii_phy_dev = NULL;
+	}
+
 	phydev = phy_find_first(bp->mii_bus);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
@@ -3001,6 +3028,8 @@ static int macb_probe(struct platform_device *pdev)
 		bp->phy_interface = err;
 	}
 
+	bp->gmii2rgmii_phy_node = of_parse_phandle(bp->pdev->dev.of_node,
+						   "gmii2rgmii-phy-handle", 0);
 	/* IP specific init */
 	err = init(pdev);
 	if (err)
@@ -3059,6 +3088,8 @@ static int macb_remove(struct platform_device *pdev)
 		bp = netdev_priv(dev);
 		if (bp->phy_dev)
 			phy_disconnect(bp->phy_dev);
+		if (bp->gmii2rgmii_phy_dev)
+			phy_disconnect(bp->gmii2rgmii_phy_dev);
 		mdiobus_unregister(bp->mii_bus);
 		mdiobus_free(bp->mii_bus);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8a13824..625aaf3 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -559,6 +559,11 @@ struct macb_dma_desc {
 /* limit RX checksum offload to TCP and UDP packets */
 #define GEM_RX_CSUM_CHECKED_MASK		2
 
+#define MACB_GMII2RGMII_FULLDPLX		BMCR_FULLDPLX
+#define MACB_GMII2RGMII_SPEED1000		BMCR_SPEED1000
+#define MACB_GMII2RGMII_SPEED100		BMCR_SPEED100
+#define MACB_GMII2RGMII_REG_NUM			0x10
+
 /* struct macb_tx_skb - data about an skb which is being transmitted
  * @skb: skb currently being transmitted, only set for the last buffer
  *       of the frame
@@ -846,6 +851,8 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+	struct device_node *gmii2rgmii_phy_node;
+	struct phy_device *gmii2rgmii_phy_dev;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.1
