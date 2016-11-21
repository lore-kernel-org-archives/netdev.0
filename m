From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 10/11] net: dsa: mv88e6xxx: Implement mv88e6390 get_stats
Date: Mon, 21 Nov 2016 23:27:04 +0100
Message-ID: <1479767225-13789-11-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47710 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753308AbcKUW1g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:27:36 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 uses a different bit to select between bank0 and bank1
of the statistics. So implement an ops function for this, and pass the
selector bit to the generic stats read function. Also, the histogram
selection has moved for the mv88e6390, so abstract its selection as
well.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 39 +++++++++++++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  3 ++-
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ac99e5b0ea75..5f2193949f87 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -815,8 +815,7 @@ static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 	*val = 0;
 
 	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_READ_CAPTURED |
-				 GLOBAL_STATS_OP_HIST_RX_TX | stat);
+				 GLOBAL_STATS_OP_READ_CAPTURED | stat);
 	if (err)
 		return;
 
@@ -901,7 +900,8 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 
 static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 					    struct mv88e6xxx_hw_stat *s,
-					    int port)
+					    int port, u16 bank1_select,
+					    u16 histogram)
 {
 	u32 low;
 	u32 high = 0;
@@ -924,10 +924,10 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 		}
 		break;
 	case STATS_TYPE_BANK1:
-		reg = GLOBAL_STATS_OP_BANK_1;
+		reg = bank1_select;
 		/* fall through */
 	case STATS_TYPE_BANK0:
-		reg |= s->reg;
+		reg |= s->reg | histogram;
 		_mv88e6xxx_stats_read(chip, reg, &low);
 		if (s->sizeof_stat == 8)
 			_mv88e6xxx_stats_read(chip, reg + 1, &high);
@@ -1012,7 +1012,8 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 }
 
 static void mv88e6xxx_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
-				      uint64_t *data, int types)
+				      uint64_t *data, int types,
+				      u16 bank1_select, u16 histogram)
 {
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
@@ -1020,7 +1021,9 @@ static void mv88e6xxx_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
 		if (stat->type & types) {
-			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port);
+			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port,
+							      bank1_select,
+							      histogram);
 			j++;
 		}
 	}
@@ -1030,14 +1033,25 @@ static void mv88e6095_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 				      uint64_t *data)
 {
 	return mv88e6xxx_stats_get_stats(chip, port, data,
-					 STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+					 STATS_TYPE_BANK0 | STATS_TYPE_PORT,
+					 0, GLOBAL_STATS_OP_HIST_RX_TX);
 }
 
 static void mv88e6320_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
 				      uint64_t *data)
 {
 	return mv88e6xxx_stats_get_stats(chip, port, data,
-					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
+					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
+					 GLOBAL_STATS_OP_BANK_1_BIT_9,
+					 GLOBAL_STATS_OP_HIST_RX_TX);
+}
+
+static void mv88e6390_stats_get_stats(struct mv88e6xxx_chip *chip, int port,
+				      uint64_t *data)
+{
+	return mv88e6xxx_stats_get_stats(chip, port, data,
+					 STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
+					 GLOBAL_STATS_OP_BANK_1_BIT_10, 0);
 }
 
 static void mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
@@ -3390,6 +3404,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3405,6 +3420,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3420,6 +3436,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3452,6 +3469,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3546,6 +3564,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3561,6 +3580,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3576,6 +3596,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a6a66eb3169b..9298faa5878b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -296,7 +296,8 @@
 #define GLOBAL_STATS_OP_HIST_RX		((1 << 10) | GLOBAL_STATS_OP_BUSY)
 #define GLOBAL_STATS_OP_HIST_TX		((2 << 10) | GLOBAL_STATS_OP_BUSY)
 #define GLOBAL_STATS_OP_HIST_RX_TX	((3 << 10) | GLOBAL_STATS_OP_BUSY)
-#define GLOBAL_STATS_OP_BANK_1	BIT(9)
+#define GLOBAL_STATS_OP_BANK_1_BIT_9	BIT(9)
+#define GLOBAL_STATS_OP_BANK_1_BIT_10	BIT(10)
 #define GLOBAL_STATS_COUNTER_32	0x1e
 #define GLOBAL_STATS_COUNTER_01	0x1f
 
-- 
2.10.2
