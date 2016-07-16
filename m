From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 08/10] net: phy: Try looking for a phy-handle property to
 find the OF node
Date: Sat, 16 Jul 2016 15:29:06 +0100
Message-ID: <1468679348-10522-9-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

If PHY is registered via. a DSA switch, the MDIO bus the phy is on does
not exist in devicetree, but there may be a reference to the PHY node
on the physical MDIO bus to use.

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 drivers/net/phy/marvell.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 280e879..c2ca347 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -302,14 +302,24 @@ static int marvell_config_aneg(struct phy_device *phydev)
  */
 static int marvell_of_reg_init(struct phy_device *phydev)
 {
-	const __be32 *paddr;
+	const __be32 *paddr = NULL;
 	int len, i, saved_page, current_page, page_changed, ret;
+	struct device_node *phy_dn;
+
+	if (phydev->mdio.dev.of_node)
+		paddr = of_get_property(phydev->mdio.dev.of_node,
+					"marvell,reg-init", &len);
+	else if (phydev->attached_dev->dev.of_node) {
+		/* A DSA slave-mii-bus has no OF node, but the PHY might */
+		phy_dn = of_parse_phandle(phydev->attached_dev->dev.of_node,
+					  "phy-handle", 0);
+		if (phy_dn) {
+			paddr = of_get_property(phy_dn,
+						"marvell,reg-init", &len);
+			of_node_put(phy_dn);
+		}
+	}
 
-	if (!phydev->mdio.dev.of_node)
-		return 0;
-
-	paddr = of_get_property(phydev->mdio.dev.of_node,
-				"marvell,reg-init", &len);
 	if (!paddr || len < (4 * sizeof(*paddr)))
 		return 0;
 
-- 
2.8.1
