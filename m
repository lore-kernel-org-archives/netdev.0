From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next] net: dsa: lan9303: Add adjust_link() method
Date: Tue, 19 Sep 2017 10:09:24 +0200
Message-ID: <20170919080924.11144-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the driver react to device tree "fixed-link" declaration on CPU port.

- turn off autonegotiation
- force speed 10 or 100 mb/s
- force duplex mode

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index b471413d3df9..07355db2ad81 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -17,6 +17,7 @@
 #include <linux/regmap.h>
 #include <linux/mutex.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "lan9303.h"
 
@@ -57,6 +58,7 @@
 #define LAN9303_SWITCH_CSR_CMD_LANES (BIT(19) | BIT(18) | BIT(17) | BIT(16))
 #define LAN9303_VIRT_PHY_BASE 0x70
 #define LAN9303_VIRT_SPECIAL_CTRL 0x77
+#define  LAN9303_VIRT_SPECIAL_TURBO BIT(10) /*Turbo MII Enable*/
 
 /*13.4 Switch Fabric Control and Status Registers
  * Accessed indirectly via SWITCH_CSR_CMD, SWITCH_CSR_DATA.
@@ -760,6 +762,43 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
 	return chip->ops->phy_write(chip, phy, regnum, val);
 }
 
+static void lan9303_adjust_link(struct dsa_switch *ds, int port,
+				struct phy_device *phydev)
+{
+	struct lan9303 *chip = ds->priv;
+	int ctl, res;
+
+	if (!phy_is_pseudo_fixed_link(phydev))
+		return;
+
+	ctl = lan9303_phy_read(ds, port, MII_BMCR);
+
+	ctl &= ~BMCR_ANENABLE;
+
+	if (phydev->speed == SPEED_100)
+		ctl |= BMCR_SPEED100;
+	else if (phydev->speed == SPEED_10)
+		ctl &= ~BMCR_SPEED100;
+	else
+		dev_err(ds->dev, "unsupported speed: %d\n", phydev->speed);
+
+	if (phydev->duplex == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+	else
+		ctl &= ~BMCR_FULLDPLX;
+
+	res =  lan9303_phy_write(ds, port, MII_BMCR, ctl);
+
+	if (port == chip->phy_addr_sel_strap) {
+		/* Virtual Phy: Remove Turbo 200Mbit mode */
+		lan9303_read(chip->regmap, LAN9303_VIRT_SPECIAL_CTRL, &ctl);
+
+		ctl &= ~LAN9303_VIRT_SPECIAL_TURBO;
+		res =  regmap_write(chip->regmap,
+				    LAN9303_VIRT_SPECIAL_CTRL, ctl);
+	}
+}
+
 static int lan9303_port_enable(struct dsa_switch *ds, int port,
 			       struct phy_device *phy)
 {
@@ -803,6 +842,7 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_strings = lan9303_get_strings,
 	.phy_read = lan9303_phy_read,
 	.phy_write = lan9303_phy_write,
+	.adjust_link = lan9303_adjust_link,
 	.get_ethtool_stats = lan9303_get_ethtool_stats,
 	.get_sset_count = lan9303_get_sset_count,
 	.port_enable = lan9303_port_enable,
-- 
2.11.0
