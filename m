From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 04/17] net: dsa: mv88e6xxx: setup message ports
Date: Sat, 11 Mar 2017 16:12:50 -0500
Message-ID: <20170311211303.24560-5-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54958 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752691AbdCKVPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:03 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All interconnectable Marvell switch chips have an ATU Learn2All feature
which allows newly learnt addresses to be spanned on ports marked as
"Message Port".

This commit configures the DSA ports as Message Port. Note that this has
no effect until the Learn2All feature is enabled.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 12 ++++++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0ad8200f3321..5c1b5825fe6c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2504,6 +2504,13 @@ static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
 	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
 }
 
+static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
+{
+	bool message = dsa_is_dsa_port(chip->ds, port);
+
+	return mv88e6xxx_port_set_message_port(chip, port, message);
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -2658,10 +2665,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
-	/* Port Control 1: disable trunking, disable sending
-	 * learning messages to this port.
-	 */
-	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, 0x0000);
+	err = mv88e6xxx_setup_message_port(chip, port);
 	if (err)
 		return err;
 
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
index 9bb0f2134cba..40fe48188056 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -535,6 +535,24 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 
 /* Offset 0x05: Port Control 1 */
 
+int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
+				    bool message_port)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &val);
+	if (err)
+		return err;
+
+	if (message_port)
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
index c83cbb3f4491..4328d6f29d4d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -64,6 +64,8 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 				       bool on);
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
+int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
+				    bool message_port);
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
-- 
2.12.0
