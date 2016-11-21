From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 08/11] net: dsa: mv88e6xxx: Add stats_get_sset_count|string to ops structure
Date: Mon, 21 Nov 2016 23:27:02 +0100
Message-ID: <1479767225-13789-9-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47740 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753308AbcKUW3c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:29:32 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different families have different sets of statistics. Abstract this
using a stats_get_sset_count and stats_get_strings op. Each stat has a
bitmap, and the ops implementer uses a bit map mask to count the
statistics which apply for the family, or return the list of strings.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
v2:
  Rename functions to avoid _ prefix.
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 243 +++++++++++++++++++++++-----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  14 +-
 2 files changed, 177 insertions(+), 80 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index dc23d042790b..ef6d3574062d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -838,76 +838,76 @@ static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 }
 
 static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
-	{ "in_good_octets",	8, 0x00, BANK0, },
-	{ "in_bad_octets",	4, 0x02, BANK0, },
-	{ "in_unicast",		4, 0x04, BANK0, },
-	{ "in_broadcasts",	4, 0x06, BANK0, },
-	{ "in_multicasts",	4, 0x07, BANK0, },
-	{ "in_pause",		4, 0x16, BANK0, },
-	{ "in_undersize",	4, 0x18, BANK0, },
-	{ "in_fragments",	4, 0x19, BANK0, },
-	{ "in_oversize",	4, 0x1a, BANK0, },
-	{ "in_jabber",		4, 0x1b, BANK0, },
-	{ "in_rx_error",	4, 0x1c, BANK0, },
-	{ "in_fcs_error",	4, 0x1d, BANK0, },
-	{ "out_octets",		8, 0x0e, BANK0, },
-	{ "out_unicast",	4, 0x10, BANK0, },
-	{ "out_broadcasts",	4, 0x13, BANK0, },
-	{ "out_multicasts",	4, 0x12, BANK0, },
-	{ "out_pause",		4, 0x15, BANK0, },
-	{ "excessive",		4, 0x11, BANK0, },
-	{ "collisions",		4, 0x1e, BANK0, },
-	{ "deferred",		4, 0x05, BANK0, },
-	{ "single",		4, 0x14, BANK0, },
-	{ "multiple",		4, 0x17, BANK0, },
-	{ "out_fcs_error",	4, 0x03, BANK0, },
-	{ "late",		4, 0x1f, BANK0, },
-	{ "hist_64bytes",	4, 0x08, BANK0, },
-	{ "hist_65_127bytes",	4, 0x09, BANK0, },
-	{ "hist_128_255bytes",	4, 0x0a, BANK0, },
-	{ "hist_256_511bytes",	4, 0x0b, BANK0, },
-	{ "hist_512_1023bytes", 4, 0x0c, BANK0, },
-	{ "hist_1024_max_bytes", 4, 0x0d, BANK0, },
-	{ "sw_in_discards",	4, 0x10, PORT, },
-	{ "sw_in_filtered",	2, 0x12, PORT, },
-	{ "sw_out_filtered",	2, 0x13, PORT, },
-	{ "in_discards",	4, 0x00 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_filtered",	4, 0x01 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_accepted",	4, 0x02 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_bad_accepted",	4, 0x03 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_good_avb_class_a", 4, 0x04 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_good_avb_class_b", 4, 0x05 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_bad_avb_class_a", 4, 0x06 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_bad_avb_class_b", 4, 0x07 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "tcam_counter_0",	4, 0x08 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "tcam_counter_1",	4, 0x09 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "tcam_counter_2",	4, 0x0a | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "tcam_counter_3",	4, 0x0b | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_da_unknown",	4, 0x0e | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "in_management",	4, 0x0f | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_0",	4, 0x10 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_1",	4, 0x11 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_2",	4, 0x12 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_3",	4, 0x13 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_4",	4, 0x14 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_5",	4, 0x15 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_6",	4, 0x16 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_queue_7",	4, 0x17 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_cut_through",	4, 0x18 | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_octets_a",	4, 0x1a | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_octets_b",	4, 0x1b | GLOBAL_STATS_OP_BANK_1, BANK1, },
-	{ "out_management",	4, 0x1f | GLOBAL_STATS_OP_BANK_1, BANK1, },
+	{ "in_good_octets",		8, 0x00, STATS_TYPE_BANK0, },
+	{ "in_bad_octets",		4, 0x02, STATS_TYPE_BANK0, },
+	{ "in_unicast",			4, 0x04, STATS_TYPE_BANK0, },
+	{ "in_broadcasts",		4, 0x06, STATS_TYPE_BANK0, },
+	{ "in_multicasts",		4, 0x07, STATS_TYPE_BANK0, },
+	{ "in_pause",			4, 0x16, STATS_TYPE_BANK0, },
+	{ "in_undersize",		4, 0x18, STATS_TYPE_BANK0, },
+	{ "in_fragments",		4, 0x19, STATS_TYPE_BANK0, },
+	{ "in_oversize",		4, 0x1a, STATS_TYPE_BANK0, },
+	{ "in_jabber",			4, 0x1b, STATS_TYPE_BANK0, },
+	{ "in_rx_error",		4, 0x1c, STATS_TYPE_BANK0, },
+	{ "in_fcs_error",		4, 0x1d, STATS_TYPE_BANK0, },
+	{ "out_octets",			8, 0x0e, STATS_TYPE_BANK0, },
+	{ "out_unicast",		4, 0x10, STATS_TYPE_BANK0, },
+	{ "out_broadcasts",		4, 0x13, STATS_TYPE_BANK0, },
+	{ "out_multicasts",		4, 0x12, STATS_TYPE_BANK0, },
+	{ "out_pause",			4, 0x15, STATS_TYPE_BANK0, },
+	{ "excessive",			4, 0x11, STATS_TYPE_BANK0, },
+	{ "collisions",			4, 0x1e, STATS_TYPE_BANK0, },
+	{ "deferred",			4, 0x05, STATS_TYPE_BANK0, },
+	{ "single",			4, 0x14, STATS_TYPE_BANK0, },
+	{ "multiple",			4, 0x17, STATS_TYPE_BANK0, },
+	{ "out_fcs_error",		4, 0x03, STATS_TYPE_BANK0, },
+	{ "late",			4, 0x1f, STATS_TYPE_BANK0, },
+	{ "hist_64bytes",		4, 0x08, STATS_TYPE_BANK0, },
+	{ "hist_65_127bytes",		4, 0x09, STATS_TYPE_BANK0, },
+	{ "hist_128_255bytes",		4, 0x0a, STATS_TYPE_BANK0, },
+	{ "hist_256_511bytes",		4, 0x0b, STATS_TYPE_BANK0, },
+	{ "hist_512_1023bytes",		4, 0x0c, STATS_TYPE_BANK0, },
+	{ "hist_1024_max_bytes",	4, 0x0d, STATS_TYPE_BANK0, },
+	{ "sw_in_discards",		4, 0x10, STATS_TYPE_PORT, },
+	{ "sw_in_filtered",		2, 0x12, STATS_TYPE_PORT, },
+	{ "sw_out_filtered",		2, 0x13, STATS_TYPE_PORT, },
+	{ "in_discards",		4, 0x00, STATS_TYPE_BANK1, },
+	{ "in_filtered",		4, 0x01, STATS_TYPE_BANK1, },
+	{ "in_accepted",		4, 0x02, STATS_TYPE_BANK1, },
+	{ "in_bad_accepted",		4, 0x03, STATS_TYPE_BANK1, },
+	{ "in_good_avb_class_a",	4, 0x04, STATS_TYPE_BANK1, },
+	{ "in_good_avb_class_b",	4, 0x05, STATS_TYPE_BANK1, },
+	{ "in_bad_avb_class_a",		4, 0x06, STATS_TYPE_BANK1, },
+	{ "in_bad_avb_class_b",		4, 0x07, STATS_TYPE_BANK1, },
+	{ "tcam_counter_0",		4, 0x08, STATS_TYPE_BANK1, },
+	{ "tcam_counter_1",		4, 0x09, STATS_TYPE_BANK1, },
+	{ "tcam_counter_2",		4, 0x0a, STATS_TYPE_BANK1, },
+	{ "tcam_counter_3",		4, 0x0b, STATS_TYPE_BANK1, },
+	{ "in_da_unknown",		4, 0x0e, STATS_TYPE_BANK1, },
+	{ "in_management",		4, 0x0f, STATS_TYPE_BANK1, },
+	{ "out_queue_0",		4, 0x10, STATS_TYPE_BANK1, },
+	{ "out_queue_1",		4, 0x11, STATS_TYPE_BANK1, },
+	{ "out_queue_2",		4, 0x12, STATS_TYPE_BANK1, },
+	{ "out_queue_3",		4, 0x13, STATS_TYPE_BANK1, },
+	{ "out_queue_4",		4, 0x14, STATS_TYPE_BANK1, },
+	{ "out_queue_5",		4, 0x15, STATS_TYPE_BANK1, },
+	{ "out_queue_6",		4, 0x16, STATS_TYPE_BANK1, },
+	{ "out_queue_7",		4, 0x17, STATS_TYPE_BANK1, },
+	{ "out_cut_through",		4, 0x18, STATS_TYPE_BANK1, },
+	{ "out_octets_a",		4, 0x1a, STATS_TYPE_BANK1, },
+	{ "out_octets_b",		4, 0x1b, STATS_TYPE_BANK1, },
+	{ "out_management",		4, 0x1f, STATS_TYPE_BANK1, },
 };
 
 static bool mv88e6xxx_has_stat(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_hw_stat *stat)
 {
 	switch (stat->type) {
-	case BANK0:
+	case STATS_TYPE_BANK0:
 		return true;
-	case BANK1:
+	case STATS_TYPE_BANK1:
 		return mv88e6xxx_6320_family(chip);
-	case PORT:
+	case STATS_TYPE_PORT:
 		return mv88e6xxx_6095_family(chip) ||
 			mv88e6xxx_6185_family(chip) ||
 			mv88e6xxx_6097_family(chip) ||
@@ -924,12 +924,12 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 {
 	u32 low;
 	u32 high = 0;
+	u16 reg = 0;
 	int err;
-	u16 reg;
 	u64 value;
 
 	switch (s->type) {
-	case PORT:
+	case STATS_TYPE_PORT:
 		err = mv88e6xxx_port_read(chip, port, s->reg, &reg);
 		if (err)
 			return UINT64_MAX;
@@ -942,26 +942,28 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 			high = reg;
 		}
 		break;
-	case BANK0:
-	case BANK1:
-		_mv88e6xxx_stats_read(chip, s->reg, &low);
+	case STATS_TYPE_BANK1:
+		reg = GLOBAL_STATS_OP_BANK_1;
+		/* fall through */
+	case STATS_TYPE_BANK0:
+		reg |= s->reg;
+		_mv88e6xxx_stats_read(chip, reg, &low);
 		if (s->sizeof_stat == 8)
-			_mv88e6xxx_stats_read(chip, s->reg + 1, &high);
+			_mv88e6xxx_stats_read(chip, reg + 1, &high);
 	}
 	value = (((u64)high) << 16) | low;
 	return value;
 }
 
-static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
-				  uint8_t *data)
+static void mv88e6xxx_stats_get_strings(struct mv88e6xxx_chip *chip,
+					uint8_t *data, int types)
 {
-	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(chip, stat)) {
+		if (stat->type & types) {
 			memcpy(data + j * ETH_GSTRING_LEN, stat->string,
 			       ETH_GSTRING_LEN);
 			j++;
@@ -969,20 +971,65 @@ static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 	}
 }
 
-static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
+static void mv88e6095_stats_get_strings(struct mv88e6xxx_chip *chip,
+					uint8_t *data)
+{
+	mv88e6xxx_stats_get_strings(chip, data,
+				    STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+}
+
+static void mv88e6320_stats_get_strings(struct mv88e6xxx_chip *chip,
+					uint8_t *data)
+{
+	mv88e6xxx_stats_get_strings(chip, data,
+				    STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
+}
+
+static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
+				  uint8_t *data)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
+
+	if (chip->info->ops->stats_get_strings)
+		chip->info->ops->stats_get_strings(chip, data);
+}
+
+static int mv88e6xxx_stats_get_sset_count(struct mv88e6xxx_chip *chip,
+					  int types)
+{
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(chip, stat))
+		if (stat->type & types)
 			j++;
 	}
 	return j;
 }
 
+static int mv88e6095_stats_get_sset_count(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_stats_get_sset_count(chip, STATS_TYPE_BANK0 |
+					      STATS_TYPE_PORT);
+}
+
+static int mv88e6320_stats_get_sset_count(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_stats_get_sset_count(chip, STATS_TYPE_BANK0 |
+					      STATS_TYPE_BANK1);
+}
+
+static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+
+	if (chip->info->ops->stats_get_sset_count)
+		return chip->info->ops->stats_get_sset_count(chip);
+
+	return 0;
+}
+
 static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 					uint64_t *data)
 {
@@ -3167,6 +3214,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3178,6 +3227,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3189,6 +3240,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3200,6 +3253,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3211,6 +3266,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3222,6 +3279,8 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3234,6 +3293,8 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3248,6 +3309,8 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3260,6 +3323,8 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3274,6 +3339,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3285,6 +3352,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3298,6 +3367,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3311,6 +3382,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3324,6 +3397,8 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3338,6 +3413,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3351,6 +3428,8 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3364,6 +3443,8 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3377,6 +3458,8 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3389,6 +3472,8 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3401,6 +3486,8 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3415,6 +3502,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
+	.stats_get_strings = mv88e6095_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3428,6 +3517,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3441,6 +3532,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3454,6 +3547,8 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d947a0c4ace6..09cce4c426b5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -806,19 +806,21 @@ struct mv88e6xxx_ops {
 	 * are separated out of the STATS_OP register.
 	 */
 	int (*stats_set_histogram)(struct mv88e6xxx_chip *chip);
-};
 
-enum stat_type {
-	BANK0,
-	BANK1,
-	PORT,
+	/* Return the number of strings describing statistics */
+	int (*stats_get_sset_count)(struct mv88e6xxx_chip *chip);
+	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
 };
 
+#define STATS_TYPE_PORT		BIT(0)
+#define STATS_TYPE_BANK0	BIT(1)
+#define STATS_TYPE_BANK1	BIT(2)
+
 struct mv88e6xxx_hw_stat {
 	char string[ETH_GSTRING_LEN];
 	int sizeof_stat;
 	int reg;
-	enum stat_type type;
+	int type;
 };
 
 static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
-- 
2.10.2
