From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 2/5] netdev/phy/of: Handle IEEE802.3 clause 45 Ethernet PHYs in of_mdiobus_register()
Date: Tue, 22 May 2012 10:59:49 -0700
Message-ID: <1337709592-23347-3-git-send-email-ddaney.cavm@gmail.com>
References: <1337709592-23347-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	Andy Fleming <afleming@freescale.com>,
	David Daney <david.daney@cavium.com>
To: devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337709592-23347-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Define two new "compatible" values for Ethernet
PHYs. "ethernet-phy-ieee802.3-c22" and "ethernet-phy-ieee802.3-c45"
are used to indicate a PHY uses the corresponding protocol.

If a PHY is "compatible" with "ethernet-phy-ieee802.3-c45", we
indicate this so that get_phy_device() can properly probe the device.

If get_phy_device() fails, it was probably due to failing the probe of
the PHY identifier registers.  Since we have the device tree telling
us the PHY exists, go ahead and add it anyhow with a phy_id of zero.
There may be a driver match based on the "compatible" property.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 Documentation/devicetree/bindings/net/phy.txt |   12 +++++++++++-
 drivers/of/of_mdio.c                          |   14 +++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index bb8c742..7cd18fb 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -14,10 +14,20 @@ Required properties:
  - linux,phandle :  phandle for this node; likely referenced by an
    ethernet controller node.
 
+Optional Properties:
+
+- compatible: Compatible list, may contain
+  "ethernet-phy-ieee802.3-c22" or "ethernet-phy-ieee802.3-c45" for
+  PHYs that implement IEEE802.3 clause 22 or IEEE802.3 clause 45
+  specifications. If neither of these are specified, the default is to
+  assume clause 22. The compatible list may also contain other
+  elements.
+
 Example:
 
 ethernet-phy@0 {
-	linux,phandle = <2452000>
+	compatible = "ethernet-phy-ieee802.3-c22";
+	linux,phandle = <2452000>;
 	interrupt-parent = <40000>;
 	interrupts = <35 1>;
 	reg = <0>;
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 2574abd..0f08aaf 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -79,11 +79,19 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 				mdio->irq[addr] = PHY_POLL;
 		}
 
+		if (of_device_is_compatible(child,
+					    "ethernet-phy-ieee802.3-c45"))
+			addr |= MII_ADDR_C45;
+
 		phy = get_phy_device(mdio, addr);
 		if (!phy || IS_ERR(phy)) {
-			dev_err(&mdio->dev, "error probing PHY at address %i\n",
-				addr);
-			continue;
+			phy = phy_device_create(mdio, addr, 0, NULL);
+			if (!phy || IS_ERR(phy)) {
+				dev_err(&mdio->dev,
+					"error creating PHY at address %i\n",
+					addr);
+				continue;
+			}
 		}
 
 		/* Associate the OF node with the device structure so it
-- 
1.7.2.3
