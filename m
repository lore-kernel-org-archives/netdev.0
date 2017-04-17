From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 6/9] ftgmac100: Allow configuration of phy interface via device-tree
Date: Tue, 18 Apr 2017 08:37:03 +1000
Message-ID: <20170417223706.16483-7-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51429 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755367AbdDQWlc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:41:32 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This uses the standard phy-mode property

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 42 +++++++++++++++++++++++++++++---
 1 file changed, 39 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index f76765e..7721c2a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -34,6 +34,7 @@
 #include <linux/property.h>
 #include <linux/crc32.h>
 #include <linux/if_vlan.h>
+#include <linux/of_net.h>
 #include <net/ip.h>
 #include <net/ncsi.h>
 
@@ -1051,7 +1052,7 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 	schedule_work(&priv->reset_task);
 }
 
-static int ftgmac100_mii_probe(struct ftgmac100 *priv)
+static int ftgmac100_mii_probe(struct ftgmac100 *priv, phy_interface_t intf)
 {
 	struct net_device *netdev = priv->netdev;
 	struct phy_device *phydev;
@@ -1063,7 +1064,7 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 	}
 
 	phydev = phy_connect(netdev, phydev_name(phydev),
-			     &ftgmac100_adjust_link, PHY_INTERFACE_MODE_GMII);
+			     &ftgmac100_adjust_link, intf);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(netdev, "%s: Could not attach to PHY\n", netdev->name);
@@ -1618,6 +1619,8 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct platform_device *pdev = to_platform_device(priv->dev);
+	int phy_intf = PHY_INTERFACE_MODE_RGMII;
+	struct device_node *np = pdev->dev.of_node;
 	int i, err = 0;
 	u32 reg;
 
@@ -1633,6 +1636,39 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 		iowrite32(reg, priv->base + FTGMAC100_OFFSET_REVR);
 	};
 
+	/* Get PHY mode from device-tree */
+	if (np) {
+		/* Default to RGMII. It's a gigabit part after all */
+		phy_intf = of_get_phy_mode(np);
+		if (phy_intf < 0)
+			phy_intf = PHY_INTERFACE_MODE_RGMII;
+
+		/* Aspeed only supports these. I don't know about other IP
+		 * block vendors so I'm going to just let them through for
+		 * now. Note that this is only a warning if for some obscure
+		 * reason the DT really means to lie about it or it's a newer
+		 * part we don't know about.
+		 *
+		 * On the Aspeed SoC there are additionally straps and SCU
+		 * control bits that could tell us what the interface is
+		 * (or allow us to configure it while the IP block is held
+		 * in reset). For now I chose to keep this driver away from
+		 * those SoC specific bits and assume the device-tree is
+		 * right and the SCU has been configured properly by pinmux
+		 * or the firmware.
+		 */
+		if (priv->is_aspeed &&
+		    phy_intf != PHY_INTERFACE_MODE_RMII &&
+		    phy_intf != PHY_INTERFACE_MODE_RGMII &&
+		    phy_intf != PHY_INTERFACE_MODE_RGMII_ID &&
+		    phy_intf != PHY_INTERFACE_MODE_RGMII_RXID &&
+		    phy_intf != PHY_INTERFACE_MODE_RGMII_TXID) {
+			netdev_warn(netdev,
+				   "Unsupported PHY mode %s !\n",
+				   phy_modes(phy_intf));
+		}
+	}
+
 	priv->mii_bus->name = "ftgmac100_mdio";
 	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 pdev->name, pdev->id);
@@ -1649,7 +1685,7 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 		goto err_register_mdiobus;
 	}
 
-	err = ftgmac100_mii_probe(priv);
+	err = ftgmac100_mii_probe(priv, phy_intf);
 	if (err) {
 		dev_err(priv->dev, "MII Probe failed!\n");
 		goto err_mii_probe;
-- 
2.9.3
