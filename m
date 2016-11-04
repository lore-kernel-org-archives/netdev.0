From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 02/11] net: dsa: mv88e6xxx: add port state setter
Date: Fri,  4 Nov 2016 03:23:27 +0100
Message-ID: <20161104022336.14273-3-vivien.didelot@savoirfairelinux.com>
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

Add the port STP state setter to the port files.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 49 ++++------------------------------------
 drivers/net/dsa/mv88e6xxx/port.c | 31 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h |  2 ++
 3 files changed, 37 insertions(+), 45 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b32b242..12c1175 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1215,41 +1215,6 @@ static int _mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid,
 	return _mv88e6xxx_atu_move(chip, fid, port, 0x0f, static_too);
 }
 
-static const char * const mv88e6xxx_port_state_names[] = {
-	[PORT_CONTROL_STATE_DISABLED] = "Disabled",
-	[PORT_CONTROL_STATE_BLOCKING] = "Blocking/Listening",
-	[PORT_CONTROL_STATE_LEARNING] = "Learning",
-	[PORT_CONTROL_STATE_FORWARDING] = "Forwarding",
-};
-
-static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
-				 u8 state)
-{
-	struct dsa_switch *ds = chip->ds;
-	u16 reg;
-	int err;
-	u8 oldstate;
-
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
-	if (err)
-		return err;
-
-	oldstate = reg & PORT_CONTROL_STATE_MASK;
-
-	reg &= ~PORT_CONTROL_STATE_MASK;
-	reg |= state;
-
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
-	if (err)
-		return err;
-
-	netdev_dbg(ds->ports[port].netdev, "PortState %s (was %s)\n",
-		   mv88e6xxx_port_state_names[state],
-		   mv88e6xxx_port_state_names[oldstate]);
-
-	return 0;
-}
-
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
 	struct net_device *bridge = chip->ports[port].bridge_dev;
@@ -1313,13 +1278,11 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 	}
 
 	mutex_lock(&chip->reg_lock);
-	err = _mv88e6xxx_port_state(chip, port, stp_state);
+	err = mv88e6xxx_port_set_state(chip, port, stp_state);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
-		netdev_err(ds->ports[port].netdev,
-			   "failed to update state to %s\n",
-			   mv88e6xxx_port_state_names[stp_state]);
+		netdev_err(ds->ports[port].netdev, "failed to update state\n");
 }
 
 static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
@@ -2526,12 +2489,8 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
-		err = mv88e6xxx_port_read(chip, i, PORT_CONTROL, &reg);
-		if (err)
-			return err;
-
-		err = mv88e6xxx_port_write(chip, i, PORT_CONTROL,
-					   reg & 0xfffc);
+		err = mv88e6xxx_port_set_state(chip, i,
+					       PORT_CONTROL_STATE_DISABLED);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 3b36c92..8d59fe7 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -29,3 +29,34 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
+
+/* Offset 0x04: Port Control Register */
+
+static const char * const mv88e6xxx_port_state_names[] = {
+	[PORT_CONTROL_STATE_DISABLED] = "Disabled",
+	[PORT_CONTROL_STATE_BLOCKING] = "Blocking/Listening",
+	[PORT_CONTROL_STATE_LEARNING] = "Learning",
+	[PORT_CONTROL_STATE_FORWARDING] = "Forwarding",
+};
+
+int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_STATE_MASK;
+	reg |= state;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "PortState set to %s\n",
+		   mv88e6xxx_port_state_names[state]);
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index ae1ae2b..ac13988 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -21,4 +21,6 @@ int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 			 u16 val);
 
+int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
