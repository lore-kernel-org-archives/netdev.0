From: Andrew Lunn <andrew@lunn.ch>
Subject: [[PATCH net-next RFC] 1/4] net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
Date: Thu, 24 Nov 2016 00:43:15 +0100
Message-ID: <1479944598-20372-2-git-send-email-andrew@lunn.ch>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53443 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:45:25 -0500
In-Reply-To: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 does not have the two registers to set the frame
priority map. Instead it has an indirection registers for setting a
number of different priority maps. Refactor the old code into an
function, implement the mv88e6390 version, and use an op to call the
right one.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 +++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 10 ++++++
 drivers/net/dsa/mv88e6xxx/port.c      | 57 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 93 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bada6465af59..880e40288038 100644
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
+	if (chip->info->ops->tag_remap) {
+		err = chip->info->ops->tag_remap(chip, port);
 		if (err)
 			return err;
 	}
@@ -3193,6 +3183,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3221,6 +3212,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3249,6 +3241,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3263,6 +3256,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3278,6 +3272,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3295,6 +3290,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3310,6 +3306,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3327,6 +3324,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3357,6 +3355,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3373,6 +3372,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3389,6 +3389,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3406,6 +3407,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3422,6 +3424,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3438,6 +3441,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3454,6 +3458,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3469,6 +3474,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3484,6 +3490,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3501,6 +3508,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.tag_remap = mv88e6095_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3517,6 +3525,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3533,6 +3542,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3549,6 +3559,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
+	.tag_remap = mv88e6390_tag_remap,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9298faa5878b..241025e0aec7 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -171,6 +171,15 @@
 #define PORT_OUT_FILTERED	0x13
 #define PORT_TAG_REGMAP_0123	0x18
 #define PORT_TAG_REGMAP_4567	0x19
+#define PORT_PRIO_MAP_TABLE	0x18    /* 6390 */
+#define PORT_PRIO_MAP_TABLE_UPDATE		BIT(15)
+#define PORT_PRIO_MAP_TABLE_INGRESS_PCP		(0x0 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	(0x1 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	(0x2 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_AVB_PCP	(0x3 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	(0x5 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	(0x6 << 12)
+#define PORT_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	(0x7 << 12)
 
 #define GLOBAL_STATUS		0x00
 #define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
@@ -813,6 +822,7 @@ struct mv88e6xxx_ops {
 	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
 	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
 				uint64_t *data);
+	int (*tag_remap)(struct mv88e6xxx_chip *chip, int port);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index af4772d86086..b7fab70f6cd7 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -496,3 +496,60 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 
 	return 0;
 }
+
+int mv88e6095_tag_remap(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	/* Tag Remap: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123, 0x3210);
+	if (err)
+		return err;
+
+	/* Tag Remap 2: use an identity 802.1p prio -> switch
+	 * prio mapping.
+	 */
+	return mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567, 0x7654);
+}
+
+int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port)
+{
+	int err, reg, i;
+
+	for (i = 0; i <= 7; i++) {
+		reg = i | (i << 4) |
+			PORT_PRIO_MAP_TABLE_INGRESS_PCP |
+			PORT_PRIO_MAP_TABLE_UPDATE;
+		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
+					   reg);
+		if (err)
+			return err;
+
+		reg = i | PORT_PRIO_MAP_TABLE_EGRESS_GREEN_PCP |
+			PORT_PRIO_MAP_TABLE_UPDATE;
+		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
+					   reg);
+		if (err)
+			return err;
+
+		reg = i |
+			PORT_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP |
+			PORT_PRIO_MAP_TABLE_UPDATE;
+		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
+					   reg);
+		if (err)
+			return err;
+
+		reg = i |
+			PORT_PRIO_MAP_TABLE_EGRESS_AVB_PCP |
+			PORT_PRIO_MAP_TABLE_UPDATE;
+		err = mv88e6xxx_port_write(chip, port, PORT_PRIO_MAP_TABLE,
+					   reg);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 499129c1489c..99a04cf3d1d6 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -48,5 +48,7 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid);
 
 int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 				  u16 mode);
+int mv88e6095_tag_remap(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
