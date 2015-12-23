From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 21/28] net: dsa: Add some debug prints for error cases
Date: Wed, 23 Dec 2015 13:56:35 +0100
Message-ID: <1450875402-20740-22-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48740 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbbLWM6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:05 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the complexity it can be hard to know why DSA fails to probe.
Add some debug prints for the common error cases.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0658077f4e63..2c1f50561343 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -672,6 +672,7 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 
 	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
 	if (!ethernet) {
+		dev_dbg(dev, "Missing mandatory dsa,ethernet property\n");
 		ret = -EINVAL;
 		goto out_put_mdio;
 	}
@@ -703,8 +704,10 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
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
@@ -1002,13 +1005,17 @@ int dsa_switch_register(struct dsa_switch_tree *dst, struct dsa_switch *ds,
 	struct dsa_platform_data *pd = dst->pd;
 	int index = dsa_find_chip_index(dst, np);
 
-	if (index < 0)
+	if (index < 0) {
+		netdev_dbg(dst->master_netdev, "Registration for unknown switch\n");
 		return index;
+	}
 
 	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n", index, name);
 
-	if (dst->ds[index])
+	if (dst->ds[index]) {
+		netdev_dbg(dst->master_netdev, "Device already registered\n");
 		return -EINVAL;
+	}
 
 	ds->index = index;
 	ds->pd = &pd->chip[index];
-- 
2.6.3
