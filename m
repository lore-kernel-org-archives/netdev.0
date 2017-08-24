From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of the PHY mode
Date: Thu, 24 Aug 2017 10:38:19 +0200
Message-ID: <20170824083823.16826-10-antoine.tenart@free-electrons.com>
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

This patch adds logic to reconfigure the comphy/gop when the link status
change at runtime. This is very useful on boards such as the mcbin which
have SFP and Ethernet ports connected to the same MAC port: depending on
what the user connects the driver will automatically reconfigure the
link mode.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index e9fd4fa81a2e..31903c2a41c5 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5740,6 +5740,7 @@ static void mvpp2_link_event(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
+	bool link_reconfigured = false;
 
 	if (!netif_running(dev))
 		return;
@@ -5750,9 +5751,27 @@ static void mvpp2_link_event(struct net_device *dev)
 			port->duplex = phydev->duplex;
 			port->speed  = phydev->speed;
 		}
+
+		if (port->phy_interface != phydev->interface && port->comphy) {
+	                /* disable current port for reconfiguration */
+	                mvpp2_interrupts_disable(port);
+	                netif_carrier_off(port->dev);
+	                mvpp2_port_disable(port);
+			phy_power_off(port->comphy);
+
+	                /* comphy reconfiguration */
+	                port->phy_interface = phydev->interface;
+	                mvpp22_comphy_init(port);
+
+	                /* gop/mac reconfiguration */
+	                mvpp22_gop_init(port);
+	                mvpp2_port_mii_set(port);
+
+	                link_reconfigured = true;
+		}
 	}
 
-	if (phydev->link != port->link) {
+	if (phydev->link != port->link || link_reconfigured) {
 		port->link = phydev->link;
 
 		if (phydev->link) {
-- 
2.13.5
