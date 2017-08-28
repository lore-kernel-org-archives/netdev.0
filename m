From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v3 07/13] net: mvpp2: do not set GMAC autoneg when using XLG MAC
Date: Mon, 28 Aug 2017 16:57:19 +0200
Message-ID: <20170828145725.2539-8-antoine.tenart@free-electrons.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using the XLG MAC, it does not make sense to force the GMAC autoneg
parameters. This patch adds checks to only set the GMAC autoneg
parameters when needed (i.e. when not using the XLG MAC).

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 64 +++++++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 09cad32734f3..2f05a0b0773c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5735,6 +5735,37 @@ static irqreturn_t mvpp2_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static void mvpp2_gmac_set_autoneg(struct mvpp2_port *port,
+				   struct phy_device *phydev)
+{
+	u32 val;
+
+	if (port->phy_interface != PHY_INTERFACE_MODE_RGMII &&
+	    port->phy_interface != PHY_INTERFACE_MODE_RGMII_ID &&
+	    port->phy_interface != PHY_INTERFACE_MODE_RGMII_RXID &&
+	    port->phy_interface != PHY_INTERFACE_MODE_RGMII_TXID &&
+	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
+		return;
+
+	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+	val &= ~(MVPP2_GMAC_CONFIG_MII_SPEED |
+		 MVPP2_GMAC_CONFIG_GMII_SPEED |
+		 MVPP2_GMAC_CONFIG_FULL_DUPLEX |
+		 MVPP2_GMAC_AN_SPEED_EN |
+		 MVPP2_GMAC_AN_DUPLEX_EN);
+
+	if (phydev->duplex)
+		val |= MVPP2_GMAC_CONFIG_FULL_DUPLEX;
+
+	if (phydev->speed == SPEED_1000)
+		val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
+	else if (phydev->speed == SPEED_100)
+		val |= MVPP2_GMAC_CONFIG_MII_SPEED;
+
+	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+
+}
+
 /* Adjust link */
 static void mvpp2_link_event(struct net_device *dev)
 {
@@ -5745,24 +5776,7 @@ static void mvpp2_link_event(struct net_device *dev)
 	if (phydev->link) {
 		if ((port->speed != phydev->speed) ||
 		    (port->duplex != phydev->duplex)) {
-			u32 val;
-
-			val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
-			val &= ~(MVPP2_GMAC_CONFIG_MII_SPEED |
-				 MVPP2_GMAC_CONFIG_GMII_SPEED |
-				 MVPP2_GMAC_CONFIG_FULL_DUPLEX |
-				 MVPP2_GMAC_AN_SPEED_EN |
-				 MVPP2_GMAC_AN_DUPLEX_EN);
-
-			if (phydev->duplex)
-				val |= MVPP2_GMAC_CONFIG_FULL_DUPLEX;
-
-			if (phydev->speed == SPEED_1000)
-				val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
-			else if (phydev->speed == SPEED_100)
-				val |= MVPP2_GMAC_CONFIG_MII_SPEED;
-
-			writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+			mvpp2_gmac_set_autoneg(port, phydev);
 
 			port->duplex = phydev->duplex;
 			port->speed  = phydev->speed;
@@ -5773,10 +5787,16 @@ static void mvpp2_link_event(struct net_device *dev)
 		port->link = phydev->link;
 
 		if (phydev->link) {
-			val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
-			val |= (MVPP2_GMAC_FORCE_LINK_PASS |
-				MVPP2_GMAC_FORCE_LINK_DOWN);
-			writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+			if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
+			    port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
+			    port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+			    port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID ||
+			    port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
+				val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+				val |= (MVPP2_GMAC_FORCE_LINK_PASS |
+					MVPP2_GMAC_FORCE_LINK_DOWN);
+				writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+			}
 
 			mvpp2_interrupts_enable(port);
 			mvpp2_port_enable(port);
-- 
2.13.5
