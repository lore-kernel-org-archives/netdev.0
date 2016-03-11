From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 08:47:00 -0800
Message-ID: <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Remove the call to force the octeon-mdio driver to be loaded.  Allow
the standard driver loading mechanisms to load the PHY drivers, and
use -EPROBE_DEFER to cause the BGX driver to be probed only after the
PHY drivers are available.

Reorder the setting of MAC addresses and PHY probing to allow BGX
LMACs with no attached PHY to still be assigned a MAC address.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 31 ++++++++++++-----------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index f8abdff..928c02b 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -978,27 +978,31 @@ static int bgx_init_of_phy(struct bgx *bgx)
 	const char *mac;
 
 	device_for_each_child_node(&bgx->pdev->dev, fwn) {
+		struct phy_device *pd;
 		struct device_node *phy_np;
 		struct device_node *node = to_of_node(fwn);
 
-		/* If it is not an OF node we cannot handle it yet, so
-		 * exit the loop.
-		 */
-		if (!node)
-			break;
-
-		phy_np = of_parse_phandle(node, "phy-handle", 0);
-		if (!phy_np)
-			continue;
-
-		bgx->lmac[lmac].phydev = of_phy_find_device(phy_np);
-
 		mac = of_get_mac_address(node);
 		if (mac)
 			ether_addr_copy(bgx->lmac[lmac].mac, mac);
 
 		SET_NETDEV_DEV(&bgx->lmac[lmac].netdev, &bgx->pdev->dev);
 		bgx->lmac[lmac].lmacid = lmac;
+
+		phy_np = of_parse_phandle(node, "phy-handle", 0);
+		/* If there is no phy or defective firmware presents
+		 * this cortina phy, for which there is no driver
+		 * support, ignore it.
+		 */
+		if (phy_np &&
+		    !of_device_is_compatible(phy_np, "cortina,cs4223-slice")) {
+			/* Wait until the phy drivers are available */
+			pd = of_phy_find_device(phy_np);
+			if (!pd)
+				return -EPROBE_DEFER;
+			bgx->lmac[lmac].phydev = pd;
+		}
+
 		lmac++;
 		if (lmac == MAX_LMAC_PER_BGX) {
 			of_node_put(node);
@@ -1032,9 +1036,6 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct bgx *bgx = NULL;
 	u8 lmac;
 
-	/* Load octeon mdio driver */
-	octeon_mdiobus_force_mod_depencency();
-
 	bgx = devm_kzalloc(dev, sizeof(*bgx), GFP_KERNEL);
 	if (!bgx)
 		return -ENOMEM;
-- 
1.7.11.7
