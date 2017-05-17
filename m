From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/3] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Wed, 17 May 2017 22:05:12 +0200
Message-ID: <1495051512-13554-4-git-send-email-andrew@lunn.ch>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34773 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753501AbdEQUGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 16:06:09 -0400
In-Reply-To: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the port enable/disable callbacks, which enable/disable the
SERDES interfaces, if applicable. This should save a bit of
power/heat.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 44 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 067f64dcf1b6..c002869acaab 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1996,9 +1996,6 @@ static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
 	if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
 		return mv88e6xxx_set_port_mode_edsa(chip, port);
 
-	if (chip->info->ops->serdes_power)
-		return chip->info->ops->serdes_power(chip, port, true);
-
 	return 0;
 }
 
@@ -2168,7 +2165,44 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
+	err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
+	if (err)
+		return err;
+
+	/* Enable the SERDES interface for DSA and CPU ports. Normal
+	 * ports SERDES are enabled when the port is enabled, thus
+	 * saving a bit of power.
+	 */
+	if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) &&
+	    chip->info->ops->serdes_power)
+		err = chip->info->ops->serdes_power(chip, port, true);
+
+	return err;
+}
+
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
 }
 
 static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
@@ -4023,6 +4057,8 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
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
