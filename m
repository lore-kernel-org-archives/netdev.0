From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Simplify dsa_slave_phy_setup()
Date: Wed, 25 Oct 2017 17:32:05 -0700
Message-ID: <20171026003205.13673-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, mnhu@prevas.dk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:56601 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932194AbdJZAcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:32:13 -0400
Received: by mail-qk0-f195.google.com with SMTP id l194so2290631qke.13
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 17:32:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the code that tried to identify if a PHY designated by Device
Tree required diversion through the DSA-created MDIO bus. This was
created mainly for the bcm_sf2.c driver back when it did not have its
own MDIO bus driver, which it now has since 461cd1b03e32 ("net: dsa:
bcm_sf2: Register our slave MDIO bus").

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d0ae7010ea45..808e205227c3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1060,28 +1060,10 @@ static int dsa_slave_phy_setup(struct net_device *slave_dev)
 		phy_flags = ds->ops->get_phy_flags(ds, dp->index);
 
 	if (phy_dn) {
-		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
-
-		/* If this PHY address is part of phys_mii_mask, which means
-		 * that we need to divert reads and writes to/from it, then we
-		 * want to bind this device using the slave MII bus created by
-		 * DSA to make that happen.
-		 */
-		if (!phy_is_fixed && phy_id >= 0 &&
-		    (ds->phys_mii_mask & (1 << phy_id))) {
-			ret = dsa_slave_phy_connect(slave_dev, phy_id);
-			if (ret) {
-				netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
-				of_node_put(phy_dn);
-				return ret;
-			}
-		} else {
-			slave_dev->phydev = of_phy_connect(slave_dev, phy_dn,
-							   dsa_slave_adjust_link,
-							   phy_flags,
-							   p->phy_interface);
-		}
-
+		slave_dev->phydev = of_phy_connect(slave_dev, phy_dn,
+						   dsa_slave_adjust_link,
+						   phy_flags,
+						   p->phy_interface);
 		of_node_put(phy_dn);
 	}
 
-- 
2.9.3
