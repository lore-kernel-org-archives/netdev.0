From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: mdio: of_mdio: check for already registered phy before creating new instances
Date: Tue,  6 May 2014 17:21:51 +0200
Message-ID: <1399389711-32716-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	grant.likely@linaro.org, robh+dt@kernel.org,
	Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:54599 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792AbaEFPV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:21:59 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so2985996eei.28
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 08:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In of_mdiobus_register_phy(), check if the phy with the given address is
already registered within the mii bus before calling phy_device_create()
or get_phy_device().

This allows us to augment auto-probed phy devices with extra information
via DT. Without this patch, a second instance of the phydev is created
unnecessarily.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/of/of_mdio.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 9a95831..264ea3f 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -72,10 +72,15 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	is_c45 = of_device_is_compatible(child,
 					 "ethernet-phy-ieee802.3-c45");
 
-	if (!is_c45 && !of_get_phy_id(child, &phy_id))
-		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
-	else
-		phy = get_phy_device(mdio, addr, is_c45);
+	/* Check if the phy we're looking for is already registered */
+	phy = mdio->phy_map[addr];
+	if (!phy) {
+		if (!is_c45 && !of_get_phy_id(child, &phy_id))
+			phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
+		else
+			phy = get_phy_device(mdio, addr, is_c45);
+	}
+
 	if (!phy || IS_ERR(phy))
 		return 1;
 
-- 
1.9.0
