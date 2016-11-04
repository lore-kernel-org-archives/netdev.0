From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 03/11] net: dsa: mv88e6xxx: add port vlan map setter
Date: Fri,  4 Nov 2016 03:23:28 +0100
Message-ID: <20161104022336.14273-4-vivien.didelot@savoirfairelinux.com>
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

Add a port function to access the Port Based VLAN Map register.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 14 ++------------
 drivers/net/dsa/mv88e6xxx/port.c | 25 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h |  2 ++
 3 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 12c1175..0877777 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1218,16 +1218,13 @@ static int _mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid,
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
 	struct net_device *bridge = chip->ports[port].bridge_dev;
-	const u16 mask = (1 << mv88e6xxx_num_ports(chip)) - 1;
 	struct dsa_switch *ds = chip->ds;
 	u16 output_ports = 0;
-	u16 reg;
-	int err;
 	int i;
 
 	/* allow CPU port or DSA link(s) to send frames to every port */
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
-		output_ports = mask;
+		output_ports = ~0;
 	} else {
 		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 			/* allow sending frames to every group member */
@@ -1243,14 +1240,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 	/* prevent frames from going back out of the port they came in on */
 	output_ports &= ~BIT(port);
 
-	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
-	if (err)
-		return err;
-
-	reg &= ~mask;
-	reg |= output_ports & mask;
-
-	return mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+	return mv88e6xxx_port_set_vlan_map(chip, port, output_ports);
 }
 
 static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 8d59fe7..c6a22ae 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -60,3 +60,28 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 
 	return 0;
 }
+
+/* Offset 0x06: Port Based VLAN Map */
+
+int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
+{
+	const u16 mask = GENMASK(mv88e6xxx_num_ports(chip) - 1, 0);
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	if (err)
+		return err;
+
+	reg &= ~mask;
+	reg |= map & mask;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "VLANTable set to %.3x\n",
+		   map);
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index ac13988..037d638 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -23,4 +23,6 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 
 int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
 
+int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
