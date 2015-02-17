From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: dsa: Set valid phy interface type
Date: Mon, 16 Feb 2015 21:23:51 -0800
Message-ID: <1424150631-22396-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:59494 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbBQFX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 00:23:58 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YNada-000usO-1q
	for netdev@vger.kernel.org; Tue, 17 Feb 2015 05:23:58 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the phy interface mode is not found in devicetree, or if devicetree
is not configured, of_get_phy_mode returns -ENODEV. The current code
sets the phy interface mode to the return value from of_get_phy_mode
without checking if it is valid.

This invalid phy interface mode is passed as parameter to of_phy_connect
or to phy_connect_direct. This sets the phy interface mode to the invalid
value, which in turn causes problems for any code using phydev->interface.

Fixes: b31f65fb4383 ("net: dsa: slave: Fix autoneg for phys on switch MDIO bus")
Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/dsa/slave.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d104ae1..f23dead 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -521,10 +521,13 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
-	int ret;
+	int mode, ret;
 
 	port_dn = cd->port_dn[p->port];
-	p->phy_interface = of_get_phy_mode(port_dn);
+	mode = of_get_phy_mode(port_dn);
+	if (mode < 0)
+		mode = PHY_INTERFACE_MODE_NA;
+	p->phy_interface = mode;
 
 	phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
 	if (of_phy_is_fixed_link(port_dn)) {
@@ -559,6 +562,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		if (!p->phy)
 			return -ENODEV;
 
+		/* Use already configured phy mode */
+		p->phy_interface = p->phy->interface;
 		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 				   p->phy_interface);
 	} else {
-- 
2.1.0
