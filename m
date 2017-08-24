From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 05/13] net: mvpp2: do not force the link mode
Date: Thu, 24 Aug 2017 10:38:15 +0200
Message-ID: <20170824083823.16826-6-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link mode (speed, duplex) was forced based on what the phylib
returns. This should not be the case, and only forced by ethtool
functions manually. This patch removes the link mode enforcement from
the phylib link_event callback.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 5f188de63caf..49506bdde19a 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5741,30 +5741,10 @@ static void mvpp2_link_event(struct net_device *dev)
 	struct mvpp2_port *port = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 	int status_change = 0;
-	u32 val;
 
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
-
 			port->duplex = phydev->duplex;
 			port->speed  = phydev->speed;
 		}
@@ -5782,10 +5762,6 @@ static void mvpp2_link_event(struct net_device *dev)
 
 	if (status_change) {
 		if (phydev->link) {
-			val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
-			val |= (MVPP2_GMAC_FORCE_LINK_PASS |
-				MVPP2_GMAC_FORCE_LINK_DOWN);
-			writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
 			mvpp2_egress_enable(port);
 			mvpp2_ingress_enable(port);
 		} else {
-- 
2.13.5
