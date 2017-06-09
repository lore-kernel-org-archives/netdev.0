From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 04/13] net: dsa: lan9303: Added adjust_link() method
Date: Fri, 9 Jun 2017 15:18:55 +0200
Message-ID: <2a218123dc984b93b1732d851896abb5@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes the driver react to device tree "fixed-link" declaration
on CPU port.

- turn off autonegotiation
- force speed 10 or 100 mb/s
- force duplex mode

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 0806a0684d55..be6d78f45a5f 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -17,6 +17,7 @@
 #include <linux/regmap.h>
 #include <linux/mutex.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "lan9303.h"
 
@@ -746,6 +747,37 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
 	return chip->ops->phy_write(chip, phy, regnum, val);
 }
 
+static void lan9303_adjust_link(struct dsa_switch *ds, int port,
+				struct phy_device *phydev)
+{
+	struct lan9303 *chip = ds->priv;
+
+	int ctl, res;
+
+	ctl = lan9303_phy_read(ds, port, MII_BMCR);
+
+	if (!phy_is_pseudo_fixed_link(phydev))
+		return;
+
+	ctl &= ~BMCR_ANENABLE;
+	if (phydev->speed == SPEED_100)
+		ctl |= BMCR_SPEED100;
+
+	if (phydev->duplex == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+
+	res =  lan9303_phy_write(ds, port, MII_BMCR, ctl);
+
+	if (port == chip->phy_addr_sel_strap) {
+		/* Virtual Phy: Remove Turbo 200Mbit mode */
+		lan9303_read(chip->regmap, LAN9303_VIRT_SPECIAL_CTRL, &ctl);
+
+		ctl &= ~(1 << 10); // TURBO BIT
+		res =  regmap_write(chip->regmap,
+				    LAN9303_VIRT_SPECIAL_CTRL, ctl);
+	}
+}
+
 static int lan9303_port_enable(struct dsa_switch *ds, int port,
 			       struct phy_device *phy)
 {
@@ -789,6 +821,7 @@ static struct dsa_switch_ops lan9303_switch_ops = {
 	.get_strings = lan9303_get_strings,
 	.phy_read = lan9303_phy_read,
 	.phy_write = lan9303_phy_write,
+	.adjust_link = lan9303_adjust_link,
 	.get_ethtool_stats = lan9303_get_ethtool_stats,
 	.get_sset_count = lan9303_get_sset_count,
 	.port_enable = lan9303_port_enable,
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
