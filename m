From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 1/4] net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
Date: Sat,  3 Dec 2016 04:35:16 +0100
Message-ID: <1480736119-12195-2-git-send-email-andrew@lunn.ch>
References: <1480736119-12195-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38545 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752362AbcLCDhS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:37:18 -0500
In-Reply-To: <1480736119-12195-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 does not have the two registers to set the frame
priority map. Instead it has an indirection registers for setting a
number of different priority maps. Refactor the old code into an
function, implement the mv88e6390 version, and use an op to call the
right one.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
v2:
Add port prefix
Add helper function for 6390
Add _IEEE_ into #defines
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 ++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 12 +++++++
 drivers/net/dsa/mv88e6xxx/port.c      | 63 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 101 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ce2f7ff8066e..ff4bd2f74357 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2617,20 +2617,10 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			if (err)
 				return err;
 		}
+	}
 
-		/* Tag Remap: use an identity 802.1p prio -> switch
-		 * prio mapping.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123,
-					   0x3210);
-		if (err)
-			return err;
-
-		/* Tag Remap 2: use an identity 802.1p prio -> switch
-		 * prio mapping.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567,
-					   0x7654);
+	if (chip->info->ops->port_tag_remap) {
+		err = chip->info->ops->port_tag_remap(chip, port);
 		if (err)
 			return err;
 	}
@@ -3189,6 +3179,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3217,6 +3208,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3245,6 +3237,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3259,6 +3252,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3288,6 +3282,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3305,6 +3300,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3320,6 +3316,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3337,6 +3334,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3366,6 +3364,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3382,6 +3381,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3398,6 +3398,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3416,6 +3417,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3431,6 +3433,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3448,6 +3451,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3464,6 +3468,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3479,6 +3484,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3494,6 +3500,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3511,6 +3518,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3526,6 +3534,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3542,6 +3551,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3558,6 +3568,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6390_port_tag_remap,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ab52c3772c78..a6e9dba665c1 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -172,6 +172,16 @@
 #define PORT_OUT_FILTERED	0x13
 #define PORT_TAG_REGMAP_0123	0x18
 #define PORT_TAG_REGMAP_4567	0x19
+#define PORT_IEEE_PRIO_MAP_TABLE	0x18    /* 6390 */
+#define PORT_IEEE_PRIO_MAP_TABLE_UPDATE		BIT(15)
+#define PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP		(0x0 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	(0x1 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	(0x2 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP		(0x3 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	(0x5 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	(0x6 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	(0x7 << 12)
+#define PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT		9
 
 #define GLOBAL_STATUS		0x00
 #define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
@@ -800,6 +810,8 @@ struct mv88e6xxx_ops {
 	 */
 	int (*port_set_speed)(struct mv88e6xxx_chip *chip, int port, int speed);
 
+	int (*port_tag_remap)(struct mv88e6xxx_chip *chip, int port);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index af4772d86086..3d03ea3a2c0d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -496,3 +496,66 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 
 	return 0;
 }
+
+/* Offset 0x18: Port IEEE Priority Remapping Registers [0-3]
+ * Offset 0x19: Port IEEE Priority Remapping Registers [4-7]
+ */
+
+int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	/* Use a direct priority mapping for all IEEE tagged frames */
+	err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123, 0x3210);
+	if (err)
+		return err;
+
+	return mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567, 0x7654);
+}
+
+static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
+					int port, u16 table,
+					u8 pointer, u16 data)
+{
+	u16 reg;
+
+	reg = PORT_IEEE_PRIO_MAP_TABLE_UPDATE |
+		table |
+		(pointer << PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT) |
+		data;
+
+	return mv88e6xxx_port_write(chip, port, PORT_IEEE_PRIO_MAP_TABLE, reg);
+}
+
+int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
+{
+	int err, i;
+
+	for (i = 0; i <= 7; i++) {
+		err = mv88e6xxx_port_ieeepmt_write(
+			chip, port, PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP,
+			i, (i | i << 4));
+		if (err)
+			return err;
+
+		err = mv88e6xxx_port_ieeepmt_write(
+			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP,
+			i, i);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_port_ieeepmt_write(
+			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP,
+			i, i);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_port_ieeepmt_write(
+			chip, port, PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_PCP,
+			i, i);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 499129c1489c..5fab4606662b 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -48,5 +48,7 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid);
 
 int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 				  u16 mode);
+int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
