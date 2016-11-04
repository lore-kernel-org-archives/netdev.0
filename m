From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 11/11] net: dsa: mv88e6xxx: setup port's MAC
Date: Fri,  4 Nov 2016 03:23:36 +0100
Message-ID: <20161104022336.14273-12-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have setters to configure the port's MAC, use them to
refactor the port setup and adjust_link code.

Note that port's MAC speed, duplex or RGMII delay must not be changed
unless the port's link is forced down. So wrap all that in a
mv88e6xxx_port_setup_mac function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 140 +++++++++++++++++----------------------
 1 file changed, 60 insertions(+), 80 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 23c05e3..c8f824d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -701,6 +701,47 @@ static bool mv88e6xxx_6352_family(struct mv88e6xxx_chip *chip)
 	return chip->info->family == MV88E6XXX_FAMILY_6352;
 }
 
+static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
+				    int link, int speed, int duplex,
+				    phy_interface_t mode)
+{
+	int err;
+
+	if (!chip->info->ops->port_set_link)
+		return 0;
+
+	/* Port's MAC control must not be changed unless the link is down */
+	err = chip->info->ops->port_set_link(chip, port, 0);
+	if (err)
+		return err;
+
+	if (chip->info->ops->port_set_speed) {
+		err = chip->info->ops->port_set_speed(chip, port, speed);
+		if (err && err != -EOPNOTSUPP)
+			goto restore_link;
+	}
+
+	if (chip->info->ops->port_set_duplex) {
+		err = chip->info->ops->port_set_duplex(chip, port, duplex);
+		if (err && err != -EOPNOTSUPP)
+			goto restore_link;
+	}
+
+	if (chip->info->ops->port_set_rgmii_delay) {
+		err = chip->info->ops->port_set_rgmii_delay(chip, port, mode);
+		if (err && err != -EOPNOTSUPP)
+			goto restore_link;
+	}
+
+	err = 0;
+restore_link:
+	if (chip->info->ops->port_set_link(chip, port, link))
+		netdev_err(chip->ds->ports[port].netdev,
+			   "failed to restore MAC's link\n");
+
+	return err;
+}
+
 /* We expect the switch to perform auto negotiation if there is a real
  * phy. However, in the case of a fixed link phy, we force the port
  * settings from the fixed link settings.
@@ -709,64 +750,18 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 				  struct phy_device *phydev)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 reg;
 	int err;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
 		return;
 
 	mutex_lock(&chip->reg_lock);
-
-	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
-	if (err)
-		goto out;
-
-	reg &= ~(PORT_PCS_CTRL_LINK_UP |
-		 PORT_PCS_CTRL_FORCE_LINK |
-		 PORT_PCS_CTRL_DUPLEX_FULL |
-		 PORT_PCS_CTRL_FORCE_DUPLEX |
-		 PORT_PCS_CTRL_SPEED_UNFORCED);
-
-	reg |= PORT_PCS_CTRL_FORCE_LINK;
-	if (phydev->link)
-		reg |= PORT_PCS_CTRL_LINK_UP;
-
-	if (mv88e6xxx_6065_family(chip) && phydev->speed > SPEED_100)
-		goto out;
-
-	switch (phydev->speed) {
-	case SPEED_1000:
-		reg |= PORT_PCS_CTRL_SPEED_1000;
-		break;
-	case SPEED_100:
-		reg |= PORT_PCS_CTRL_SPEED_100;
-		break;
-	case SPEED_10:
-		reg |= PORT_PCS_CTRL_SPEED_10;
-		break;
-	default:
-		pr_info("Unknown speed");
-		goto out;
-	}
-
-	reg |= PORT_PCS_CTRL_FORCE_DUPLEX;
-	if (phydev->duplex == DUPLEX_FULL)
-		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
-
-	if ((mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip)) &&
-	    (port >= mv88e6xxx_num_ports(chip) - 2)) {
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
-			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
-			reg |= PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
-			reg |= (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
-				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
-	}
-	mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
-
-out:
+	err = mv88e6xxx_port_setup_mac(chip, port, phydev->link, phydev->speed,
+				       phydev->duplex, phydev->interface);
 	mutex_unlock(&chip->reg_lock);
+
+	if (err && err != -EOPNOTSUPP)
+		netdev_err(ds->ports[port].netdev, "failed to configure MAC\n");
 }
 
 static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
@@ -2409,35 +2404,20 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	int err;
 	u16 reg;
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
-	    mv88e6xxx_6065_family(chip) || mv88e6xxx_6320_family(chip)) {
-		/* MAC Forcing register: don't force link, speed,
-		 * duplex or flow control state to any particular
-		 * values on physical ports, but force the CPU port
-		 * and all DSA ports to their maximum bandwidth and
-		 * full duplex.
-		 */
-		err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
-		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
-			reg &= ~PORT_PCS_CTRL_SPEED_UNFORCED;
-			reg |= PORT_PCS_CTRL_FORCE_LINK |
-				PORT_PCS_CTRL_LINK_UP |
-				PORT_PCS_CTRL_DUPLEX_FULL |
-				PORT_PCS_CTRL_FORCE_DUPLEX;
-			if (mv88e6xxx_6065_family(chip))
-				reg |= PORT_PCS_CTRL_SPEED_100;
-			else
-				reg |= PORT_PCS_CTRL_SPEED_1000;
-		} else {
-			reg |= PORT_PCS_CTRL_SPEED_UNFORCED;
-		}
-
-		err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
-		if (err)
-			return err;
-	}
+	/* MAC Forcing register: don't force link, speed, duplex or flow control
+	 * state to any particular values on physical ports, but force the CPU
+	 * port and all DSA ports to their maximum bandwidth and full duplex.
+	 */
+	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+		err = mv88e6xxx_port_setup_mac(chip, port, LINK_FORCED_UP,
+					       SPEED_MAX, DUPLEX_FULL,
+					       PHY_INTERFACE_MODE_NA);
+	else
+		err = mv88e6xxx_port_setup_mac(chip, port, LINK_UNFORCED,
+					       SPEED_UNFORCED, DUPLEX_UNFORCED,
+					       PHY_INTERFACE_MODE_NA);
+	if (err)
+		return err;
 
 	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
 	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
-- 
2.10.2
