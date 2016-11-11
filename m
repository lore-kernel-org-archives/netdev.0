From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 10/11] net: dsa: mv88e6xxx: Add stats_get_stats to ops structure
Date: Fri, 11 Nov 2016 03:53:42 +0100
Message-ID: <1478832823-31471-11-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34634 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCyN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:54:13 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different families have different sets of statistics. Abstract this
using a stats_get_stats op. The mv88e6390 needs a different
implementation, which will be added later.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 84 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 +
 2 files changed, 58 insertions(+), 28 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index cfbf0f0ff0dd..ebef214eb1e3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -921,25 +921,6 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
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
@@ -1049,13 +1030,48 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 	return 0;
 }
 
+static void _mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
+				 uint64_t *data, int types)
+{
+	struct mv88e6xxx_hw_stat *stat;
+	int i, j;
+
+	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
+		stat = &mv88e6xxx_hw_stats[i];
+		if (stat->type & types) {
+			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port,
+							      bank1_select);
+			j++;
+		}
+	}
+}
+
+static void mv88e6095_get_stats(struct mv88e6xxx_chip *chip, int port,
+				uint64_t *data)
+{
+	return _mv88e6xxx_get_stats(chip, port, data,
+				    STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+}
+
+static void mv88e6320_get_stats(struct mv88e6xxx_chip *chip, int port,
+				uint64_t *data)
+{
+	return _mv88e6xxx_get_stats(chip, port, data,
+				    STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
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
 
@@ -1064,13 +1080,8 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
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
@@ -3251,6 +3262,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3264,6 +3276,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3277,6 +3290,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3290,6 +3304,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3303,6 +3318,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3316,6 +3332,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3330,6 +3347,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3346,6 +3364,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3360,6 +3379,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3376,6 +3396,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3389,6 +3410,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3405,6 +3427,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3420,6 +3443,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
 	.stats_get_strings = mv88e6320_get_strings,
+	.stats_get_stats = mv88e6320_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3435,6 +3459,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
 	.stats_get_strings = mv88e6320_get_strings,
+	.stats_get_stats = mv88e6320_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3449,6 +3474,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3463,6 +3489,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_snapshot = mv88e6xxx_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3479,6 +3506,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_snapshot = mv88e6320_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_get_sset_count,
 	.stats_get_strings = mv88e6095_get_strings,
+	.stats_get_stats = mv88e6095_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d3b8eed109a6..e0196450e8a2 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -804,6 +804,8 @@ struct mv88e6xxx_ops {
 	int (*stats_snapshot)(struct mv88e6xxx_chip *chip, int port);
 	int (*stats_get_sset_count)(struct mv88e6xxx_chip *chip);
 	void (*stats_get_strings)(struct mv88e6xxx_chip *chip,  uint8_t *data);
+	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
+				uint64_t *data);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
-- 
2.10.2
