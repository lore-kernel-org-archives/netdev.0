From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/13] net: dsa: mv88e6xxx: prefix Port Jamming macros
Date: Mon, 12 Jun 2017 12:37:35 -0400
Message-ID: <20170612163745.16868-4-vivien.didelot@savoirfairelinux.com>
References: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60154 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754917AbdFLQkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 12:40:10 -0400
In-Reply-To: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For implicit namespacing and clarity, prefix the common Port Jamming
Control Register macros with MV88E6XXX_PORT_JAM_CTL and the ones which
differ between implementations with a chosen reference model
(e.g. MV88E6097_PORT_JAM_CTL.)

The 88E6390 family renamed the register to Flow Control and turned it
into an indirect table. Document that as well.

Document the register and prefer ordered hex masks values for all
Marvell 16-bit registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 15 +++++++++------
 drivers/net/dsa/mv88e6xxx/port.h | 16 +++++++++++++---
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 60c31b6c2f47..615b8843ad8e 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -376,7 +376,7 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode)
 	return 0;
 }
 
-/* Offset 0x02: Pause Control
+/* Offset 0x02: Jamming Control
  *
  * Do not limit the period of time that this port can be paused for by
  * the remote end or the period of time that this port can pause the
@@ -385,7 +385,8 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode)
 int mv88e6097_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
 			       u8 out)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, out << 8 | in);
+	return mv88e6xxx_port_write(chip, port, MV88E6097_PORT_JAM_CTL,
+				    out << 8 | in);
 }
 
 int mv88e6390_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
@@ -393,13 +394,15 @@ int mv88e6390_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
 {
 	int err;
 
-	err = mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
-				   PORT_FLOW_CTRL_LIMIT_IN | in);
+	err = mv88e6xxx_port_write(chip, port, MV88E6390_PORT_FLOW_CTL,
+				   MV88E6390_PORT_FLOW_CTL_UPDATE |
+				   MV88E6390_PORT_FLOW_CTL_LIMIT_IN | in);
 	if (err)
 		return err;
 
-	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
-				    PORT_FLOW_CTRL_LIMIT_OUT | out);
+	return mv88e6xxx_port_write(chip, port, MV88E6390_PORT_FLOW_CTL,
+				    MV88E6390_PORT_FLOW_CTL_UPDATE |
+				    MV88E6390_PORT_FLOW_CTL_LIMIT_OUT | out);
 }
 
 /* Offset 0x04: Port Control Register */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 260096b34d2b..5226a0651d8e 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -63,9 +63,19 @@
 #define MV88E6390_PORT_MAC_CTL_SPEED_10000		0x0003
 #define MV88E6XXX_PORT_MAC_CTL_SPEED_UNFORCED		0x0003
 
-#define PORT_PAUSE_CTRL		0x02
-#define PORT_FLOW_CTRL_LIMIT_IN		((0x00 << 8) | BIT(15))
-#define PORT_FLOW_CTRL_LIMIT_OUT	((0x01 << 8) | BIT(15))
+/* Offset 0x02: Jamming Control Register */
+#define MV88E6097_PORT_JAM_CTL			0x02
+#define MV88E6097_PORT_JAM_CTL_LIMIT_OUT_MASK	0xff00
+#define MV88E6097_PORT_JAM_CTL_LIMIT_IN_MASK	0x00ff
+
+/* Offset 0x02: Flow Control Register */
+#define MV88E6390_PORT_FLOW_CTL			0x02
+#define MV88E6390_PORT_FLOW_CTL_UPDATE		0x8000
+#define MV88E6390_PORT_FLOW_CTL_PTR_MASK	0x7f00
+#define MV88E6390_PORT_FLOW_CTL_LIMIT_IN	0x0000
+#define MV88E6390_PORT_FLOW_CTL_LIMIT_OUT	0x0100
+#define MV88E6390_PORT_FLOW_CTL_DATA_MASK	0x00ff
+
 #define PORT_SWITCH_ID		0x03
 #define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
 #define PORT_SWITCH_ID_PROD_NUM_6095	0x095
-- 
2.13.1
