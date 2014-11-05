From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: dsa: slave: Fix autoneg for phys on switch MDIO bus
Date: Wed,  5 Nov 2014 19:47:28 +0100
Message-ID: <1415213248-29037-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49036 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046AbaKESss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 13:48:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the ports phys are connected to the switches internal MDIO bus,
we need to connect the phy to the slave netdev, otherwise
auto-negotiation etc, does not work.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

Hi Florian

Is this the right fix?

What i found is that ports on mv88E6171 we coming up as 10/half.  If i
forced a renegotiation with ethtool -r lan0, the phy would then goto
1000/full.

The code for phys on internal switch MDIO buses never connect the phy
to the device, only phys listed in DT get connected via
of_phy_connect(). By connecting the phy, the state machine is active
and does an autoneg when the slave interface is opened.

net/dsa/slave.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6d1817449c36..ab03e00ffe8f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -489,11 +489,14 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	/* We could not connect to a designated PHY, so use the switch internal
 	 * MDIO bus instead
 	 */
-	if (!p->phy)
+	if (!p->phy) {
 		p->phy = ds->slave_mii_bus->phy_map[p->port];
-	else
+		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
+				   p->phy_interface);
+	} else {
 		pr_info("attached PHY at address %d [%s]\n",
 			p->phy->addr, p->phy->drv->name);
+	}
 }
 
 int dsa_slave_suspend(struct net_device *slave_dev)
-- 
2.1.3
