From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: bcmgenet: Remove special handling of "internal" phy-mode
Date: Fri, 23 Jun 2017 10:33:15 -0700
Message-ID: <20170623173316.23017-4-f.fainelli@gmail.com>
References: <20170623173316.23017-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel@vger.kernel.org (open list),
        david.wu@rock-chips.com, opendmb@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623173316.23017-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY library now supports an "internal" phy-mode, thus making our
custom parsing code now unnecessary.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 285676f8da6b..071fcbd14e6a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -251,11 +251,8 @@ int bcmgenet_mii_config(struct net_device *dev)
 	priv->ext_phy = !priv->internal_phy &&
 			(priv->phy_interface != PHY_INTERFACE_MODE_MOCA);
 
-	if (priv->internal_phy)
-		priv->phy_interface = PHY_INTERFACE_MODE_NA;
-
 	switch (priv->phy_interface) {
-	case PHY_INTERFACE_MODE_NA:
+	case PHY_INTERFACE_MODE_INTERNAL:
 	case PHY_INTERFACE_MODE_MOCA:
 		/* Irrespective of the actually configured PHY speed (100 or
 		 * 1000) GENETv4 only has an internal GPHY so we will just end
@@ -471,7 +468,6 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 {
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct device *kdev = &priv->pdev->dev;
-	const char *phy_mode_str = NULL;
 	struct phy_device *phydev = NULL;
 	char *compat;
 	int phy_mode;
@@ -510,23 +506,19 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 
 	/* Get the link mode */
 	phy_mode = of_get_phy_mode(dn);
+	if (phy_mode < 0) {
+		dev_err(kdev, "invalid PHY mode property\n");
+		return phy_mode;
+	}
+
 	priv->phy_interface = phy_mode;
 
 	/* We need to specifically look up whether this PHY interface is internal
 	 * or not *before* we even try to probe the PHY driver over MDIO as we
 	 * may have shut down the internal PHY for power saving purposes.
 	 */
-	if (phy_mode < 0) {
-		ret = of_property_read_string(dn, "phy-mode", &phy_mode_str);
-		if (ret < 0) {
-			dev_err(kdev, "invalid PHY mode property\n");
-			return ret;
-		}
-
-		priv->phy_interface = PHY_INTERFACE_MODE_NA;
-		if (!strcasecmp(phy_mode_str, "internal"))
-			priv->internal_phy = true;
-	}
+	if (priv->phy_interface == PHY_INTERFACE_MODE_INTERNAL)
+		priv->internal_phy = true;
 
 	/* Make sure we initialize MoCA PHYs with a link down */
 	if (phy_mode == PHY_INTERFACE_MODE_MOCA) {
-- 
2.9.3
