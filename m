From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net] phy: micrel: Fix finding PHY properties in MAC node.
Date: Wed,  9 Dec 2015 19:56:31 +0100
Message-ID: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	dinguyen@opensource.altera.com, david.daney@cavium.com,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34246 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753558AbbLIS4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 13:56:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus,
not the bus' parent.")  changed the parenting of PHY devices, making
them a child of the MDIO bus, instead of the MAC device. This broken
the Micrel PHY driver which has a deprecated feature of allowing PHY
properties to be placed into the MAC node.

In order to find the MAC node, we need to walk up the tree of devices
until we find one with an OF node attached.

Reported-by: Dinh Nguyen <dinguyen@opensource.altera.com>
Suggested-by: David Daney <david.daney@cavium.com>
Acked-by: David Daney <david.daney@cavium.com>
Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Remove include of netdev.h
---
 drivers/net/phy/micrel.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index cf6312fafea5..e13ad6cdcc22 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -339,9 +339,18 @@ static int ksz9021_config_init(struct phy_device *phydev)
 {
 	const struct device *dev = &phydev->dev;
 	const struct device_node *of_node = dev->of_node;
+	const struct device *dev_walker;
 
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
+	/* The Micrel driver has a deprecated option to place phy OF
+	 * properties in the MAC node. Walk up the tree of devices to
+	 * find a device with an OF node.
+	 */
+	dev_walker = &phydev->dev;
+	do {
+		of_node = dev_walker->of_node;
+		dev_walker = dev_walker->parent;
+
+	} while (!of_node && dev_walker);
 
 	if (of_node) {
 		ksz9021_load_values_from_of(phydev, of_node,
-- 
2.6.2
