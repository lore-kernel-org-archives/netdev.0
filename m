From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/3] net: of_mdio: factor out code to parse a phy's 'reg' property
Date: Sat, 10 May 2014 18:37:53 +0200
Message-ID: <1399739875-16434-2-git-send-email-zonque@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:60826 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbaEJQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 12:38:04 -0400
Received: by mail-ee0-f52.google.com with SMTP id e53so3443471eek.11
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 09:38:03 -0700 (PDT)
In-Reply-To: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out some logic into of_mdio_parse_addr() so it can be reused
later.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/of/of_mdio.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 9a95831..171f9d5 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -114,6 +114,29 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	return 0;
 }
 
+static int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
+{
+	const __be32 *paddr;
+	u32 addr;
+	int len;
+
+	/* A PHY must have a reg property in the range [0-31] */
+	paddr = of_get_property(np, "reg", &len);
+	if (!paddr || len < sizeof(*paddr)) {
+		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
+		return -EINVAL;
+	}
+
+	addr = be32_to_cpup(paddr);
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
@@ -148,19 +171,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
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
