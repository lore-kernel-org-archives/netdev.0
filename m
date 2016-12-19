From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net 2/3] net: phy: use boolean dt properties for eee broken modes
Date: Mon, 19 Dec 2016 16:05:37 +0100
Message-ID: <1482159938-13239-3-git-send-email-jbrunet@baylibre.com>
References: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Yegor Yefremov <yegorslists@googlemail.com>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patches regarding eee-broken-modes was merged before all people
involved could find an agreement on the best way to move forward.

While we agreed on having a DT property to mark particular modes as broken,
the value used for eee-broken-modes mapped the phy register in very direct
way. Because of this, the concern is that it could be used to implement
configuration policies instead of describing a broken HW.

In the end, having a boolean property for each mode seems to be preferred
over one bit field value mapping the register (too) directly.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
---
 drivers/net/phy/phy_device.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index ee5ebadb1463..92b08383cafa 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1665,7 +1665,7 @@ static void of_set_phy_supported(struct phy_device *phydev)
 static void of_set_phy_eee_broken(struct phy_device *phydev)
 {
 	struct device_node *node = phydev->mdio.dev.of_node;
-	u32 broken;
+	u32 broken = 0;
 
 	if (!IS_ENABLED(CONFIG_OF_MDIO))
 		return;
@@ -1673,8 +1673,20 @@ static void of_set_phy_eee_broken(struct phy_device *phydev)
 	if (!node)
 		return;
 
-	if (!of_property_read_u32(node, "eee-broken-modes", &broken))
-		phydev->eee_broken_modes = broken;
+	if (of_property_read_bool(node, "eee-broken-100tx"))
+		broken |= MDIO_EEE_100TX;
+	if (of_property_read_bool(node, "eee-broken-1000t"))
+		broken |= MDIO_EEE_1000T;
+	if (of_property_read_bool(node, "eee-broken-10gt"))
+		broken |= MDIO_EEE_10GT;
+	if (of_property_read_bool(node, "eee-broken-1000kx"))
+		broken |= MDIO_EEE_1000KX;
+	if (of_property_read_bool(node, "eee-broken-10gkx4"))
+		broken |= MDIO_EEE_10GKX4;
+	if (of_property_read_bool(node, "eee-broken-10gkr"))
+		broken |= MDIO_EEE_10GKR;
+
+	phydev->eee_broken_modes = broken;
 }
 
 /**
-- 
2.7.4
