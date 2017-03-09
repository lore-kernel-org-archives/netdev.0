From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/14] net: dsa: mv88e6xxx: setup ATU Learn2All
Date: Thu,  9 Mar 2017 18:33:13 -0500
Message-ID: <20170309233324.18539-4-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell switch chips which can be interconnected have an ATU Learn2All
feature which allows chosen ports to also learn newly added addresses.

Enable this feature and mark the DSA links as so called "Message Ports".

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 32 +++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  1 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 17 +++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  1 +
 drivers/net/dsa/mv88e6xxx/port.c        | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h        |  2 ++
 6 files changed, 58 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0ad8200f3321..132bda7ca9a8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1308,6 +1308,14 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 {
+	int err;
+
+	if (chip->info->tag_protocol != DSA_TAG_PROTO_TRAILER) {
+		err = mv88e6xxx_g1_atu_set_learn2all(chip, true);
+		if (err)
+			return err;
+	}
+
 	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
 }
 
@@ -2504,6 +2512,16 @@ static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
 	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
 }
 
+static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
+{
+	bool message = dsa_is_dsa_port(chip->ds, port);
+
+	if (chip->info->tag_protocol != DSA_TAG_PROTO_TRAILER)
+		return mv88e6xxx_port_set_message_port(chip, port, message);
+
+	return 0;
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -2658,10 +2676,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
-	/* Port Control 1: disable trunking, disable sending
-	 * learning messages to this port.
-	 */
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, 0x0000);
+	err = mv88e6xxx_setup_message_port(chip, port);
 	if (err)
 		return err;
 
@@ -2752,15 +2767,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err < 0)
 		return err;
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL,
-				 GLOBAL_ATU_CONTROL_LEARN2ALL);
-	if (err)
-		return err;
-
 	/* Clear all ATU entries */
 	err = _mv88e6xxx_atu_flush(chip, 0, true);
 	if (err)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index b8d0fb519bab..18322d05225a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -38,6 +38,7 @@ int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
+int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all);
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs);
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 4d0ada9efc6d..843a21e05f7b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -15,6 +15,23 @@
 
 /* Offset 0x0A: ATU Control Register */
 
+int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+	if (err)
+		return err;
+
+	if (learn2all)
+		val |= GLOBAL_ATU_CONTROL_LEARN2ALL;
+	else
+		val &= ~GLOBAL_ATU_CONTROL_LEARN2ALL;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+}
+
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 166b513ff751..45205519b9fe 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -144,6 +144,7 @@
 #define PORT_CONTROL_STATE_LEARNING	0x02
 #define PORT_CONTROL_STATE_FORWARDING	0x03
 #define PORT_CONTROL_1		0x05
+#define PORT_CONTROL_1_MESSAGE_PORT	BIT(15)
 #define PORT_CONTROL_1_FID_11_4_MASK	(0xff << 0)
 #define PORT_BASE_VLAN		0x06
 #define PORT_BASE_VLAN_FID_3_0_MASK	(0xf << 12)
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 9bb0f2134cba..599039dbc384 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -535,6 +535,24 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 
 /* Offset 0x05: Port Control 1 */
 
+int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
+				    bool on)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &val);
+	if (err)
+		return err;
+
+	if (on)
+		val |= PORT_CONTROL_1_MESSAGE_PORT;
+	else
+		val &= ~PORT_CONTROL_1_MESSAGE_PORT;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, val);
+}
+
 /* Offset 0x06: Port Based VLAN Map */
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index c83cbb3f4491..19217c06e0fb 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -64,6 +64,8 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 				       bool on);
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
+int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
+				    bool on);
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
-- 
2.12.0
