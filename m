From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 1/3] net: of_mdio: factor out code to parse a phy's 'reg' property
Date: Sat, 24 May 2014 09:34:25 +0200
Message-ID: <1400916867-24573-2-git-send-email-zonque@gmail.com>
References: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:58138 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaEXHem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 03:34:42 -0400
Received: by mail-we0-f181.google.com with SMTP id w61so5887244wes.12
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 00:34:41 -0700 (PDT)
In-Reply-To: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out some logic into of_mdio_parse_addr() so it can be reused
later. While at it, use of_property_read_u32() rather than open-coding
the same logic again.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 9a95831..4eb335e 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -114,6 +114,27 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	return 0;
 }
 
+static int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
+{
+	u32 addr;
+	int ret;
+
+	ret = of_property_read_u32(np, "reg", &addr);
+	if (ret < 0) {
+		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
+		return ret;
+	}
+
+	/* A PHY must have a reg property in the range [0-31] */
+	if (addr >= PHY_MAX_ADDR) {
+		dev_err(dev, "%s PHY address %i is too large\n",
+			np->full_name, addr);
+		return -EINVAL;
+	}
+
+	return addr;
+}
+
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
  * @mdio: pointer to mii_bus structure
@@ -148,19 +169,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
 	/* Loop over the child nodes and register a phy_device for each one */
 	for_each_available_child_of_node(np, child) {
-		/* A PHY must have a reg property in the range [0-31] */
-		paddr = of_get_property(child, "reg", &len);
-		if (!paddr || len < sizeof(*paddr)) {
+		addr = of_mdio_parse_addr(&mdio->dev, child);
+		if (addr < 0) {
 			scanphys = true;
-			dev_err(&mdio->dev, "%s has invalid PHY address\n",
-				child->full_name);
-			continue;
-		}
-
-		addr = be32_to_cpup(paddr);
-		if (addr >= PHY_MAX_ADDR) {
-			dev_err(&mdio->dev, "%s PHY address %i is too large\n",
-				child->full_name, addr);
 			continue;
 		}
 
-- 
1.9.0
