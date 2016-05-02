From: Marek Vasut <marex@denx.de>
Subject: [PATCH V2] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Mon,  2 May 2016 02:47:31 +0200
Message-ID: <1462150051-6308-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>, Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42773 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbcEBArk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 20:47:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit b74766a0a0fe ("phylib: don't return NULL
from get_phy_device()") in linux-next, phy_get_device() will return
ERR_PTR(-ENODEV) instead of NULL if the PHY device ID is all ones.

This causes problem with stmmac driver and likely some other drivers
which call mdiobus_register(). I triggered this bug on SoCFPGA MCVEVK
board with linux-next 20160427 and 20160428. In case of the stmmac, if
there is no PHY node specified in the DT for the stmmac block, the stmmac
driver ( drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c function
stmmac_mdio_register() ) will call mdiobus_register() , which will
register the MDIO bus and probe for the PHY.

The mdiobus_register() resp. __mdiobus_register() iterates over all of
the addresses on the MDIO bus and calls mdiobus_scan() for each of them,
which invokes get_phy_device(). Before the aforementioned patch, the
mdiobus_scan() would return NULL if no PHY was found on a given address
and mdiobus_register() would continue and try the next PHY address. Now,
mdiobus_scan() returns ERR_PTR(-ENODEV), which is caught by the
'if (IS_ERR(phydev))' condition and the loop exits immediately if the
PHY address does not contain PHY.

Repair this by explicitly checking for the ERR_PTR(-ENODEV) and if this
error comes around, continue with the next PHY address.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
V2: Fixed checkpatch warning in the commit message
    Added Ack from Florian
---
 drivers/net/phy/mdio_bus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 499003ee..388f992 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 			struct phy_device *phydev;
 
 			phydev = mdiobus_scan(bus, i);
-			if (IS_ERR(phydev)) {
+			if (IS_ERR(phydev) && (PTR_ERR(phydev) != -ENODEV)) {
 				err = PTR_ERR(phydev);
 				goto error;
 			}
-- 
2.7.0
