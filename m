From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net 1/2] of: of_mdio: Add a whitelist of PHY compatibilities.
Date: Wed, 27 Jan 2016 01:11:38 +0100
Message-ID: <1453853499-11248-2-git-send-email-andrew@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43345 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbcA0AL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 19:11:56 -0500
In-Reply-To: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some phy nodes list a compatible value indicating the PHY make/model.
This is never used to match the device to the driver. However it does
confuse the code to separate a PHY from a generic MDIO device like a
switch. Generic MDIO devices must have a compatible value, PHYs can
list clause 22 or 45, but nothing else.

Issue a warning if we find a compatible value known on the whitelist,
and say it is a PHY.

Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
Reported-by: Olof Johansson <olof@lixom.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/of/of_mdio.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b5aa004a24b6..26c245041493 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -143,11 +143,31 @@ int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdio_parse_addr);
 
+/* The following is a list of PHY compatible strings which appear in
+ * some DTBs. The compatible string is never matched against a PHY
+ * driver, so is pointless. We only expect devices which are not PHYs
+ * to have a compatible string, so they can be matched to an MDIO
+ * driver.  Encourage users to upgrade there DT blobs to remove these.
+ */
+static const struct of_device_id whitelist_phys[] = {
+	{ .compatible = "brcm,40nm-ephy" },
+	{ .compatible = "marvell,88E1111", },
+	{ .compatible = "marvell,88e1116", },
+	{ .compatible = "marvell,88e1118", },
+	{ .compatible = "marvell,88e1149r", },
+	{ .compatible = "marvell,88e1310", },
+	{ .compatible = "marvell,88E1510", },
+	{ .compatible = "marvell,88E1514", },
+	{ .compatible = "moxa,moxart-rtl8201cp", },
+	{}
+};
+
 /*
  * Return true if the child node is for a phy. It must either:
  * o Compatible string of "ethernet-phy-idX.X"
  * o Compatible string of "ethernet-phy-ieee802.3-c45"
  * o Compatible string of "ethernet-phy-ieee802.3-c22"
+ * o In the white list above (and issue a warning)
  * o No compatibility string
  *
  * A device which is not a phy is expected to have a compatible string
@@ -166,6 +186,13 @@ static bool of_mdiobus_child_is_phy(struct device_node *child)
 	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c22"))
 		return true;
 
+	if (of_match_node(whitelist_phys, child)) {
+		pr_warn(FW_WARN
+			"%s: Whitelisted compatible string. Please remove\n",
+			child->full_name);
+		return true;
+	}
+
 	if (!of_find_property(child, "compatible", NULL))
 		return true;
 
-- 
2.7.0
