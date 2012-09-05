From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 01/10] net/macb: Add support for Gigabit Ethernet mode
Date: Wed, 5 Sep 2012 10:19:08 +0200
Message-ID: <6ba606a2333630154d5c4139d672a09ce4cc44f1.1346775479.git.nicolas.ferre@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <nicolas.ferre@atmel.com>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrice Vilchez <patrice.vilchez@atmel.com>

Add Gigabit Ethernet mode to GEM cadence IP and enable RGMII connection.

Signed-off-by: Patrice Vilchez <patrice.vilchez@atmel.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   15 ++++++++++++---
 drivers/net/ethernet/cadence/macb.h |    4 ++++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 033064b..9a10f69 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -152,13 +152,17 @@ static void macb_handle_link_change(struct net_device *dev)
 
 			reg = macb_readl(bp, NCFGR);
 			reg &= ~(MACB_BIT(SPD) | MACB_BIT(FD));
+			if (macb_is_gem(bp))
+				reg &= ~GEM_BIT(GBE);
 
 			if (phydev->duplex)
 				reg |= MACB_BIT(FD);
 			if (phydev->speed == SPEED_100)
 				reg |= MACB_BIT(SPD);
+			if (phydev->speed == SPEED_1000)
+				reg |= GEM_BIT(GBE);
 
-			macb_writel(bp, NCFGR, reg);
+			macb_or_gem_writel(bp, NCFGR, reg);
 
 			bp->speed = phydev->speed;
 			bp->duplex = phydev->duplex;
@@ -216,7 +220,10 @@ static int macb_mii_probe(struct net_device *dev)
 	}
 
 	/* mask with MAC supported features */
-	phydev->supported &= PHY_BASIC_FEATURES;
+	if (macb_is_gem(bp))
+		phydev->supported &= PHY_GBIT_FEATURES;
+	else
+		phydev->supported &= PHY_BASIC_FEATURES;
 
 	phydev->advertising = phydev->supported;
 
@@ -1384,7 +1391,9 @@ static int __init macb_probe(struct platform_device *pdev)
 		bp->phy_interface = err;
 	}
 
-	if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
+	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
+		macb_or_gem_writel(bp, USRIO, GEM_BIT(RGMII));
+	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
 #if defined(CONFIG_ARCH_AT91)
 		macb_or_gem_writel(bp, USRIO, (MACB_BIT(RMII) |
 					       MACB_BIT(CLKEN)));
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 335e288..f69ceef 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -145,6 +145,8 @@
 #define MACB_IRXFCS_SIZE			1
 
 /* GEM specific NCFGR bitfields. */
+#define GEM_GBE_OFFSET				10
+#define GEM_GBE_SIZE				1
 #define GEM_CLK_OFFSET				18
 #define GEM_CLK_SIZE				3
 #define GEM_DBW_OFFSET				21
@@ -246,6 +248,8 @@
 /* Bitfields in USRIO (AT91) */
 #define MACB_RMII_OFFSET			0
 #define MACB_RMII_SIZE				1
+#define GEM_RGMII_OFFSET			0	/* GEM gigabit mode */
+#define GEM_RGMII_SIZE				1
 #define MACB_CLKEN_OFFSET			1
 #define MACB_CLKEN_SIZE				1
 
-- 
1.7.10
