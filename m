From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 24/32] net: dsa: Add some debug prints for error cases
Date: Sun, 28 Feb 2016 17:41:32 +0100
Message-ID: <1456677700-23027-25-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44926 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758779AbcB1QmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:16 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the complexity it can be hard to know why DSA fails to probe.
Add some debug prints for the common error cases.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0be85a14a835..9acfbe7c34f7 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -679,6 +679,7 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 
 	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
 	if (!ethernet) {
+		dev_dbg(dev, "Missing mandatory dsa,ethernet property\n");
 		ret = -EINVAL;
 		goto out_put_mdio;
 	}
@@ -710,8 +711,10 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 		if (chip) {
 			cd->of_chip = chip;
 		} else {
-			if (!mdio)
+			if (!mdio) {
+				dev_dbg(dev, "Missing required dsa,mii-bus property\n");
 				return -EINVAL;
+			}
 
 			mdio_bus = of_mdio_find_bus(mdio);
 			if (!mdio_bus)
@@ -1018,14 +1021,18 @@ int dsa_switch_register(struct dsa_switch_tree *dst, struct dsa_switch *ds,
 	struct dsa_platform_data *pd = dst->pd;
 	int index = dsa_find_chip_index(dst, np);
 
-	if (index < 0)
+	if (index < 0) {
+		netdev_dbg(dst->master_netdev, "Registration for unknown switch\n");
 		return index;
+	}
 
 	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
 		    index, name);
 
-	if (dst->ds[index])
+	if (dst->ds[index]) {
+		netdev_dbg(dst->master_netdev, "Device already registered\n");
 		return -EINVAL;
+	}
 
 	ds->index = index;
 	ds->pd = &pd->chip[index];
-- 
2.7.0
