From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] of: mdio: Add a "broken-turn-around" property
Date: Tue, 12 May 2015 10:33:25 -0700
Message-ID: <1431452006-3219-3-git-send-email-f.fainelli@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
 <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jogo@openwrt.org, bert@biot.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32911 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933492AbbELRdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:33:53 -0400
Received: by pacwv17 with SMTP id wv17so20333378pac.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:33:52 -0700 (PDT)
In-Reply-To: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet PHY devices/switches may not properly release the MDIO bus
during turn-around time, and fail to drive it low, which can be seen by
some controllers as a read failure, while the data clocked in is still
correct.

Add a boolean property "broken-turn-around" which is parsed by the
generic MDIO bus probing code and will set the corresponding bit in the
MDIO bus phy_ignore_ta_mask bitmask for MDIO bus drivers to utilize that
information.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 3 +++
 drivers/of/of_mdio.c                          | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 40831fbaff72..525e1658f2da 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -30,6 +30,9 @@ Optional Properties:
 
 - max-speed: Maximum PHY supported speed (10, 100, 1000...)
 
+- broken-turn-around: If set, indicates the PHY device does not correctly
+  release the turn around line low at the end of a MDIO transaction.
+
 Example:
 
 ethernet-phy@0 {
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 0c064485d1c2..fdc60db60829 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -68,6 +68,9 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 			phy->irq = mdio->irq[addr];
 	}
 
+	if (of_property_read_bool(child, "broken-turn-around"))
+		mdio->phy_ignore_ta_mask |= 1 << addr;
+
 	/* Associate the OF node with the device structure so it
 	 * can be looked up later */
 	of_node_get(child);
-- 
2.1.0
