From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: Refactor remaining port setup
Date: Sat,  4 Feb 2017 20:15:28 +0100
Message-ID: <1486235728-11775-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55744 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750944AbdBDTP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 14:15:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the remaining port configuration code which varies per device
into port.c, using ops were necessary. This makes
mv88e6xxx_6185_family() and mv88e6xxx_6095_family() unused, so remove
them.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 51 +++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  7 +++++
 drivers/net/dsa/mv88e6xxx/port.c      | 48 +++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  6 ++++-
 4 files changed, 78 insertions(+), 34 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e62d1476b63d..7b4e40b286e4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -677,11 +677,6 @@ static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip,
 	return err;
 }
 
-static bool mv88e6xxx_6095_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6095;
-}
-
 static bool mv88e6xxx_6097_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6097;
@@ -692,11 +687,6 @@ static bool mv88e6xxx_6165_family(struct mv88e6xxx_chip *chip)
 	return chip->info->family == MV88E6XXX_FAMILY_6165;
 }
 
-static bool mv88e6xxx_6185_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6185;
-}
-
 static bool mv88e6xxx_6320_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6320;
@@ -2585,31 +2575,23 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	 * received packets as usual, disable ARP mirroring and don't send a
 	 * copy of all transmitted/received frames on this port to the CPU.
 	 */
-	reg = 0;
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6320_family(chip) ||
-	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6341_family(chip))
-		reg = PORT_CONTROL_2_MAP_DA;
-
-	if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
-		/* Set the upstream port this port should use */
-		reg |= dsa_upstream_port(ds);
-		/* enable forwarding of unknown multicast addresses to
-		 * the upstream port
-		 */
-		if (port == dsa_upstream_port(ds))
-			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
-	}
-
-	reg |= PORT_CONTROL_2_8021Q_DISABLED;
+	err = mv88e6xxx_port_set_map_da(chip, port);
+	if (err)
+		return err;
 
-	if (reg) {
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+	reg = 0;
+	if (chip->info->ops->port_set_upstream_port) {
+		err = chip->info->ops->port_set_upstream_port(
+			chip, port, dsa_upstream_port(ds));
 		if (err)
 			return err;
 	}
 
+	err = mv88e6xxx_port_set_8021q_mode(chip, port,
+					    PORT_CONTROL_2_8021Q_DISABLED);
+	if (err)
+		return err;
+
 	if (chip->info->ops->port_jumbo_config) {
 		err = chip->info->ops->port_jumbo_config(chip, port);
 		if (err)
@@ -3144,7 +3126,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
+	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
+	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3210,8 +3193,9 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
@@ -3387,8 +3371,9 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
+	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
+	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index c1d43ee11842..8a21800374f3 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -168,6 +168,7 @@
 #define PORT_CONTROL_2_FORWARD_UNKNOWN	BIT(6)
 #define PORT_CONTROL_2_EGRESS_MONITOR	BIT(5)
 #define PORT_CONTROL_2_INGRESS_MONITOR	BIT(4)
+#define PORT_CONTROL_2_UPSTREAM_MASK	0x0f
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
 #define PORT_ASSOC_VECTOR	0x0b
@@ -854,6 +855,12 @@ struct mv88e6xxx_ops {
 	int (*port_set_cmode)(struct mv88e6xxx_chip *chip, int port,
 			      phy_interface_t mode);
 
+	/* Some devices have a per port register indicating what is
+	 * the upstream port this port should forward to.
+	 */
+	int (*port_set_upstream_port)(struct mv88e6xxx_chip *chip, int port,
+				      int upstream_port);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index d543a6817d61..8875784c4718 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -672,6 +672,40 @@ static const char * const mv88e6xxx_port_8021q_mode_names[] = {
 	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
 };
 
+int mv88e6095_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
+		return err;
+
+	if (on)
+		reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
+	else
+		reg &= ~PORT_CONTROL_2_FORWARD_UNKNOWN;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+}
+
+int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
+				     int upstream_port)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_2_UPSTREAM_MASK;
+	reg |= upstream_port;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+}
+
 int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 				  u16 mode)
 {
@@ -695,6 +729,20 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	return 0;
 }
 
+int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
+		return err;
+
+	reg |= PORT_CONTROL_2_MAP_DA;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+}
+
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port)
 {
 	u16 reg;
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index cb871e306f62..c83cbb3f4491 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -58,6 +58,8 @@ int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 				  enum mv88e6xxx_frame_mode mode);
 int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 				       bool on);
+int mv88e6095_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on);
 int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 				       bool on);
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
@@ -70,5 +72,7 @@ int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390x_port_set_cmode(struct mv88e6xxx_chip *chip, int port,
 			      phy_interface_t mode);
 int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode);
-
+int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port);
+int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
+				     int upstream_port);
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.11.0
