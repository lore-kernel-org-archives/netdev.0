From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 06/11] net: dsa: mv88e6xxx: add port 802.1Q mode setter
Date: Fri,  4 Nov 2016 03:23:31 +0100
Message-ID: <20161104022336.14273-7-vivien.didelot@savoirfairelinux.com>
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

Add port functions to set the port 802.1Q mode.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 33 ++-------------------------------
 drivers/net/dsa/mv88e6xxx/port.c | 32 ++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h |  3 +++
 3 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9c0a028..181d3b9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1806,48 +1806,19 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static const char * const mv88e6xxx_port_8021q_mode_names[] = {
-	[PORT_CONTROL_2_8021Q_DISABLED] = "Disabled",
-	[PORT_CONTROL_2_8021Q_FALLBACK] = "Fallback",
-	[PORT_CONTROL_2_8021Q_CHECK] = "Check",
-	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
-};
-
 static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 					 bool vlan_filtering)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u16 old, new = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
+	u16 mode = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
 		PORT_CONTROL_2_8021Q_DISABLED;
-	u16 reg;
 	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
-
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
-	if (err)
-		goto unlock;
-
-	old = reg & PORT_CONTROL_2_8021Q_MASK;
-
-	if (new != old) {
-		reg &= ~PORT_CONTROL_2_8021Q_MASK;
-		reg |= new & PORT_CONTROL_2_8021Q_MASK;
-
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
-		if (err)
-			goto unlock;
-
-		netdev_dbg(ds->ports[port].netdev, "802.1Q Mode %s (was %s)\n",
-			   mv88e6xxx_port_8021q_mode_names[new],
-			   mv88e6xxx_port_8021q_mode_names[old]);
-	}
-
-	err = 0;
-unlock:
+	err = mv88e6xxx_port_set_8021q_mode(chip, port, mode);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 104fe2d..53d17e6 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -190,3 +190,35 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
 
 	return 0;
 }
+
+/* Offset 0x08: Port Control 2 Register */
+
+static const char * const mv88e6xxx_port_8021q_mode_names[] = {
+	[PORT_CONTROL_2_8021Q_DISABLED] = "Disabled",
+	[PORT_CONTROL_2_8021Q_FALLBACK] = "Fallback",
+	[PORT_CONTROL_2_8021Q_CHECK] = "Check",
+	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
+};
+
+int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
+				  u16 mode)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_2_8021Q_MASK;
+	reg |= mode & PORT_CONTROL_2_8021Q_MASK;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "802.1QMode set to %s\n",
+		   mv88e6xxx_port_8021q_mode_names[mode]);
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 4489d9e..921eecf 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -31,4 +31,7 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid);
 int mv88e6xxx_port_get_pvid(struct mv88e6xxx_chip *chip, int port, u16 *pvid);
 int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid);
 
+int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
+				  u16 mode);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
