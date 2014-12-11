From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: dsa: handle non-existing PHYs on switch internal bus
Date: Thu, 11 Dec 2014 12:49:15 -0800
Message-ID: <1418330956-17151-2-git-send-email-f.fainelli@gmail.com>
References: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, computersforpeace@gmail.com,
	andrey.volkov@nexvision.fr,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54565 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758647AbaLKUtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:49:35 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so3704413pdi.7
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:49:35 -0800 (PST)
In-Reply-To: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case there is no PHY at the designated address on the internal
switch, we would basically de-reference a null pointer here:

dsa_slave_phy_setup(...)
{
	p->phy = ds->slave_mii_bus->phy_map[p->port];
	phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
				      ^------

This can be triggered when the platform configuration (platform_data or
Device Tree) indicates there should be a PHY device at this address, but
the HW is non-responsive, such that we cannot attach a PHY device at
this specific location.

Fix this by checking the return value prior to calling
phy_connect_direct().

CC: Andrew Lunn <andrew@lunn.ch>
Fixes: b31f65fb4383 ("net: dsa: slave: Fix autoneg for phys on switch MDIO bus")
Reported-by: Brian Norris <computersforpeace@gmail.com>
Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ab03e00ffe8f..0efaab1e408b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -491,6 +491,9 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 */
 	if (!p->phy) {
 		p->phy = ds->slave_mii_bus->phy_map[p->port];
+		if (!p->phy)
+			return;
+
 		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 				   p->phy_interface);
 	} else {
-- 
2.1.0
