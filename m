From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 12/17] net: dsa: Make mdio bus optional
Date: Sat,  4 Jun 2016 21:17:04 +0200
Message-ID: <1465067829-1875-15-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59587 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbcFDTZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:25:32 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch may want to instantiate its own MDIO bus. Only do it
centrally if the switch has not already created one, and the read op
is implemented.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 221ebde4318d..6c314f300424 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -340,17 +340,18 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret < 0)
 		goto out;
 
-	ds->slave_mii_bus = devm_mdiobus_alloc(parent);
-	if (ds->slave_mii_bus == NULL) {
-		ret = -ENOMEM;
-		goto out;
-	}
-	dsa_slave_mii_bus_init(ds);
-
-	ret = mdiobus_register(ds->slave_mii_bus);
-	if (ret < 0)
-		goto out;
+	if (!ds->slave_mii_bus && drv->phy_read) {
+		ds->slave_mii_bus = devm_mdiobus_alloc(parent);
+		if (!ds->slave_mii_bus) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		dsa_slave_mii_bus_init(ds);
 
+		ret = mdiobus_register(ds->slave_mii_bus);
+		if (ret < 0)
+			goto out;
+	}
 
 	/*
 	 * Create network devices for physical switch ports.
@@ -493,7 +494,8 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		dsa_cpu_dsa_destroy(ds->ports[port].dn);
 	}
 
-	mdiobus_unregister(ds->slave_mii_bus);
+	if (ds->slave_mii_bus && ds->drv->phy_read)
+		mdiobus_unregister(ds->slave_mii_bus);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
2.8.1
