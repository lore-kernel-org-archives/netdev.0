From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 5/5] dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable
Date: Fri, 26 May 2017 01:03:24 +0200
Message-ID: <1495753404-29943-6-git-send-email-andrew@lunn.ch>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45086 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165913AbdEYXEx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:04:53 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the port enable/disable callbacks, which enable/disable the
SERDES interfaces, if applicable. This should save a bit of
power/heat.

We also need to enable SERDES on CPU and DSA ports, so keep the
existing call to the op, but make it conditional.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 50 +++++++++++++++++++++++++++++++++-------
 1 file changed, 42 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4e58d9a82d9e..c2f38f6770aa 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1806,10 +1806,16 @@ static int mv88e6xxx_setup_egress_floods(struct mv88e6xxx_chip *chip, int port)
 static int mv88e6xxx_serdes_power(struct mv88e6xxx_chip *chip, int port,
 				  bool on)
 {
-	if (chip->info->ops->serdes_power)
-		return chip->info->ops->serdes_power(chip, port, on);
+	int err = 0;
 
-	return 0;
+	if (chip->info->ops->serdes_power) {
+		err = chip->info->ops->serdes_power(chip, port, on);
+		if (err)
+			dev_err(chip->dev,
+				"Failed to change SERDES power: %d\n", err);
+	}
+
+	return err;
 }
 
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
@@ -1862,12 +1868,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
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
@@ -1969,6 +1978,29 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
 }
 
+static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
+				 struct phy_device *phydev)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	int err = 0;
+
+	mutex_lock(&chip->reg_lock);
+	mv88e6xxx_serdes_power(chip, port, true);
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
+	mv88e6xxx_serdes_power(chip, port, false);
+	mutex_unlock(&chip->reg_lock);
+}
+
 static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 {
 	int err;
@@ -3809,6 +3841,8 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
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
