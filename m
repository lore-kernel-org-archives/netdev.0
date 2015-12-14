From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: phy: mdio-mux: Check return value of mdiobus_alloc()
Date: Mon, 14 Dec 2015 13:51:51 +0100
Message-ID: <1450097511-13010-1-git-send-email-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:60140 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbbLNMvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 07:51:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdiobus_alloc() might return NULL, but its return value is not
checked in mdio_mux_init(). This could potentially lead to a NULL
pointer dereference. Fix it by checking the return value

Fixes: 0ca2997d1452 ("netdev/of/phy: Add MDIO bus multiplexer support.")
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/phy/mdio-mux.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 908e8d486342..7f8e7662e28c 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -149,9 +149,14 @@ int mdio_mux_init(struct device *dev,
 		}
 		cb->bus_number = v;
 		cb->parent = pb;
+
 		cb->mii_bus = mdiobus_alloc();
+		if (!cb->mii_bus) {
+			ret_val = -ENOMEM;
+			of_node_put(child_bus_node);
+			break;
+		}
 		cb->mii_bus->priv = cb;
-
 		cb->mii_bus->irq = cb->phy_irq;
 		cb->mii_bus->name = "mdio_mux";
 		snprintf(cb->mii_bus->id, MII_BUS_ID_SIZE, "%x.%x",
-- 
2.6.3.368.gf34be46.dirty
