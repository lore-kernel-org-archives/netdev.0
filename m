From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 09/11] net: dsa: mv88e6xxx: Add stats_get_strings to ops structure
Date: Fri, 11 Nov 2016 03:53:41 +0100
Message-ID: <1478832823-31471-10-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34648 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCzN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:55:13 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different families have different sets of statistics. Abstract this
using a stats_get_strings op. Each stat has a bitmap, and the ops
implementer uses a bit map mask to return a list of strings for the
statistics which apply for the family.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 47 ++++++++++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 2 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5d2c135b9175..cfbf0f0ff0dd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -977,16 +977,15 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 	return value;
 }
 
-static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
-				  uint8_t *data)
+static void _mv88e6xxx_get_strings(struct mv88e6xxx_chip *chip,
+				   uint8_t *data, int types)
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
@@ -994,6 +993,27 @@ static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 	}
 }
 
+static void mv88e6095_get_strings(struct mv88e6xxx_chip *chip, uint8_t *data)
+{
+	_mv88e6xxx_get_strings(chip, data,
+			       STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+}
+
+static void mv88e6320_get_strings(struct mv88e6xxx_chip *chip, uint8_t *data)
+{
+	_mv88e6xxx_get_strings(chip, data,
+			       STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
+}
+
+static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
+				  uint8_t *data)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+
+	if (chip->info->ops->stats_get_strings)
+		chip->info->ops->stats_get_strings(chip, data);
+}
+
 static int _mv88e6xxx_get_sset_count(struct mv88e6xxx_chip *chip, int types)
 {
 	struct mv88e6xxx_hw_stat *stat;
@@ -3230,6 +3250,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3242,6 +3263,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3254,6 +3276,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3266,6 +3289,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3278,6 +3302,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3290,6 +3315,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3303,6 +3329,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3318,6 +3345,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3331,6 +3359,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3346,6 +3375,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3358,6 +3388,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3373,6 +3404,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3387,6 +3419,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
+	.stats_get_strings = mv88e6320_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3401,6 +3434,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
+	.stats_get_strings = mv88e6320_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3414,6 +3448,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3427,6 +3462,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3442,6 +3478,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
+	.stats_get_strings = mv88e6095_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3456,6 +3493,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_init = mv88e6390_stats_init,
 	.stats_snapshot = mv88e6390_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
+	.stats_get_strings = mv88e6320_get_strings,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3470,6 +3508,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_init = mv88e6390_stats_init,
 	.stats_snapshot = mv88e6390_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
+	.stats_get_strings = mv88e6320_get_strings,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 4ff674d0e248..d3b8eed109a6 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -803,6 +803,7 @@ struct mv88e6xxx_ops {
 	 */
 	int (*stats_snapshot)(struct mv88e6xxx_chip *chip, int port);
 	int (*stats_get_sset_count)(struct mv88e6xxx_chip *chip);
+	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
-- 
2.10.2
