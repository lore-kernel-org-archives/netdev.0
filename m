From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v7 10/10] of: mdio: Prevent of_mdiobus_register from scanning mdio-mux nodes
Date: Wed, 18 Oct 2017 13:44:58 +0200
Message-ID: <20171018114458.17891-11-clabbe.montjoie@gmail.com>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-sunxi@googlegroups.com,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:50581 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932616AbdJRLrZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:47:25 -0400
In-Reply-To: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each child node of an MDIO node is scanned as a PHY when calling
of_mdiobus_register() givint the following result:
[   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
[   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
[   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
[...]
[   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
[   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31

Since mdio-mux nodes are not PHY, this patch a way to to not scan
them.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/of/of_mdio.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index d94dd8b77abd..90f3ac87c98f 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -190,6 +190,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	struct device_node *child;
 	bool scanphys = false;
 	int addr, rc;
+	static const struct of_device_id compatible_muxes[] = {
+		{ .compatible = "mdio-mux" },
+		{}
+	};
 
 	/* Do not continue if the node is disabled */
 	if (!of_device_is_available(np))
@@ -212,6 +216,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
 	/* Loop over the child nodes and register a phy_device for each phy */
 	for_each_available_child_of_node(np, child) {
+		if (of_match_node(compatible_muxes, child))
+			continue;
+
 		addr = of_mdio_parse_addr(&mdio->dev, child);
 		if (addr < 0) {
 			scanphys = true;
@@ -229,6 +236,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 
 	/* auto scan for PHYs with empty reg property */
 	for_each_available_child_of_node(np, child) {
+		if (of_match_node(compatible_muxes, child))
+			continue;
+
 		/* Skip PHYs with reg property set */
 		if (of_find_property(child, "reg", NULL))
 			continue;
-- 
2.13.6
