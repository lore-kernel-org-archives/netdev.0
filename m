From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 5/5] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Tue, 23 May 2017 23:04:46 +0200
Message-ID: <1495573486-31827-6-git-send-email-andrew@lunn.ch>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42139 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161788AbdEWVGS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 17:06:18 -0400
In-Reply-To: <1495573486-31827-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the port enable/disable callbacks, which enable/disable the
SERDES interfaces, if applicable. This should save a bit of
power/heat.

We also need to enable SERDES on CPU and DSA ports, so keep the
existing call to the op, but make it conditional.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 40 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fc4d93b5c59f..edab7eb306d9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1862,12 +1862,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	/* If this port is connected to a SerDes, make sure the SerDes is
-	 * powered up.
+	/* Enable the SERDES interface for DSA and CPU ports. Normal
+	 * ports SERDES are enabled when the port is enabled, thus
+	 * saving a bit of power.
 	 */
-	err = mv88e6xxx_serdes_power(chip, port, true);
-	if (err)
-		return err;
+	if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))) {
+		err = mv88e6xxx_serdes_power(chip, port, true);
+		if (err)
+			return err;
+	}
 
 	/* Port Control 2: don't force a good FCS, set the maximum frame size to
 	 * 10240 bytes, disable 802.1q tags checking, don't discard tagged or
@@ -1969,6 +1972,31 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
 }
 
+static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
+				 struct phy_device *phydev)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	int err = 0;
+
+	mutex_lock(&chip->reg_lock);
+	if (chip->info->ops->serdes_power)
+		err = chip->info->ops->serdes_power(chip, port, true);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
+static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
+				   struct phy_device *phydev)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+
+	mutex_lock(&chip->reg_lock);
+	if (chip->info->ops->serdes_power)
+		chip->info->ops->serdes_power(chip, port, false);
+	mutex_unlock(&chip->reg_lock);
+}
+
 static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 {
 	int err;
@@ -3821,6 +3849,8 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.port_enable		= mv88e6xxx_port_enable,
+	.port_disable		= mv88e6xxx_port_disable,
 	.set_eee		= mv88e6xxx_set_eee,
 	.get_eee		= mv88e6xxx_get_eee,
 	.get_eeprom_len		= mv88e6xxx_get_eeprom_len,
-- 
2.11.0
