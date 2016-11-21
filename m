From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 09/11] net: dsa: mv88e6xxx: Add stats_get_stats to ops structure
Date: Mon, 21 Nov 2016 23:27:03 +0100
Message-ID: <1479767225-13789-10-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47744 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754431AbcKUW35 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:29:57 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different families have different sets of statistics. Abstract this
using a stats_get_stats op. The mv88e6390 needs a different
implementation, which will be added later.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 83 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 +
 2 files changed, 57 insertions(+), 28 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ef6d3574062d..ac99e5b0ea75 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -899,25 +899,6 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 	{ "out_management",		4, 0x1f, STATS_TYPE_BANK1, },
 };
 
-static bool mv88e6xxx_has_stat(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_hw_stat *stat)
-{
-	switch (stat->type) {
-	case STATS_TYPE_BANK0:
-		return true;
-	case STATS_TYPE_BANK1:
-		return mv88e6xxx_6320_family(chip);
-	case STATS_TYPE_PORT:
-		return mv88e6xxx_6095_family(chip) ||
-			mv88e6xxx_6185_family(chip) ||
-			mv88e6xxx_6097_family(chip) ||
-			mv88e6xxx_6165_family(chip) ||
-			mv88e6xxx_6351_family(chip) ||
-			mv88e6xxx_6352_family(chip);
-	}
-	return false;
-}
-
 static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 					    struct mv88e6xxx_hw_stat *s,
 					    int port)
@@ -1030,13 +1011,47 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 	return 0;
 }
 
+static void mv88e6xxx_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
+				      uint64_t *data, int types)
+{
+	struct mv88e6xxx_hw_stat *stat;
+	int i, j;
+
+	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
+		stat = &mv88e6xxx_hw_stats[i];
+		if (stat->type & types) {
+			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port);
+			j++;
+		}
+	}
+}
+
+static void mv88e6095_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
+				      uint64_t *data)
+{
+	return mv88e6xxx_stats_get_stats(chip, port, data,
+					 STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+}
+
+static void mv88e6320_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
+				      uint64_t *data)
+{
+	return mv88e6xxx_stats_get_stats(chip, port, data,
+					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
+}
+
+static void mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
+				uint64_t *data)
+{
+	if (chip->info->ops->stats_get_stats)
+		chip->info->ops->stats_get_stats(chip, port, data);
+}
+
 static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 					uint64_t *data)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_hw_stat *stat;
 	int ret;
-	int i, j;
 
 	mutex_lock(&chip->reg_lock);
 
@@ -1045,13 +1060,8 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 		mutex_unlock(&chip->reg_lock);
 		return;
 	}
-	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
-		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(chip, stat)) {
-			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port);
-			j++;
-		}
-	}
+
+	mv88e6xxx_get_stats(chip, port, data);
 
 	mutex_unlock(&chip->reg_lock);
 }
@@ -3216,6 +3226,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3229,6 +3240,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3242,6 +3254,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3255,6 +3268,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3268,6 +3282,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3281,6 +3296,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3295,6 +3311,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3311,6 +3328,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3325,6 +3343,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3341,6 +3360,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3354,6 +3374,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3415,6 +3436,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3445,6 +3467,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6320_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3460,6 +3483,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6320_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3474,6 +3498,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3488,6 +3513,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3504,6 +3530,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
+	.stats_get_stats = mv88e6095_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 09cce4c426b5..a6a66eb3169b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -810,6 +810,8 @@ struct mv88e6xxx_ops {
 	/* Return the number of strings describing statistics */
 	int (*stats_get_sset_count)(struct mv88e6xxx_chip *chip);
 	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
+	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
+				uint64_t *data);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
-- 
2.10.2
