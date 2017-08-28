From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v3 08/13] net: mvpp2: dynamic reconfiguration of the comphy/GoP/MAC
Date: Mon, 28 Aug 2017 16:57:20 +0200
Message-ID: <20170828145725.2539-9-antoine.tenart@free-electrons.com>
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

This patch adds logic to reconfigure the comphy/GoP/MAC when the link
state is updated at runtime. This is very useful on boards where many
link speed are supported: depending on what is negotiated the PPv2
driver will automatically reconfigures the link between the PHY and the
MAC.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 2f05a0b0773c..9e64b1ba3d43 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5771,9 +5771,28 @@ static void mvpp2_link_event(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
+	bool link_reconfigured = false;
 	u32 val;
 
 	if (phydev->link) {
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
+
 		if ((port->speed != phydev->speed) ||
 		    (port->duplex != phydev->duplex)) {
 			mvpp2_gmac_set_autoneg(port, phydev);
@@ -5783,7 +5802,7 @@ static void mvpp2_link_event(struct net_device *dev)
 		}
 	}
 
-	if (phydev->link != port->link) {
+	if (phydev->link != port->link || link_reconfigured) {
 		port->link = phydev->link;
 
 		if (phydev->link) {
-- 
2.13.5
