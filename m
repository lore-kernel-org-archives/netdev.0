From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 11/11] net: dsa: mv88e6xxx: Implement mv88e6390 get_stats
Date: Fri, 11 Nov 2016 03:53:43 +0100
Message-ID: <1478832823-31471-12-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34642 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCyg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:54:36 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 uses a different bit to select between bank0 and bank1
of the statistics. So implement an ops function for this, and pass the
selector bit to the generic stats read function. Also, the histogram
selection has moved for the mv88e6390, so abstract its selection as
well.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 33 ++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  3 ++-
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ebef214eb1e3..9e3cdc356ae2 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -837,8 +837,7 @@ static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 	*val = 0;
 
 	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_READ_CAPTURED |
-				 GLOBAL_STATS_OP_HIST_RX_TX | stat);
+				 GLOBAL_STATS_OP_READ_CAPTURED | stat);
 	if (err)
 		return;
 
@@ -923,7 +922,8 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 
 static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 					    struct mv88e6xxx_hw_stat *s,
-					    int port)
+					    int port, u16 bank1_select,
+					    u16 histogram)
 {
 	u32 low;
 	u32 high = 0;
@@ -946,10 +946,10 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
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
@@ -1031,7 +1031,8 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 }
 
 static void _mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
-				 uint64_t *data, int types)
+				 uint64_t *data, int types, u16 bank1_select,
+				 u16 histogram)
 {
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
@@ -1040,7 +1041,8 @@ static void _mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
 		stat = &mv88e6xxx_hw_stats[i];
 		if (stat->type & types) {
 			data[j] = _mv88e6xxx_get_ethtool_stat(chip, stat, port,
-							      bank1_select);
+							      bank1_select,
+							      histogram);
 			j++;
 		}
 	}
@@ -1050,14 +1052,25 @@ static void mv88e6095_get_stats(struct mv88e6xxx_chip *chip, int port,
 				uint64_t *data)
 {
 	return _mv88e6xxx_get_stats(chip, port, data,
-				    STATS_TYPE_BANK0 | STATS_TYPE_PORT);
+				    STATS_TYPE_BANK0 | STATS_TYPE_PORT,
+				    0, GLOBAL_STATS_OP_HIST_RX_TX);
 }
 
 static void mv88e6320_get_stats(struct mv88e6xxx_chip *chip, int port,
 				uint64_t *data)
 {
 	return _mv88e6xxx_get_stats(chip, port, data,
-				    STATS_TYPE_BANK0 | STATS_TYPE_BANK1);
+				    STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
+				    GLOBAL_STATS_OP_BANK_1_BIT_9,
+				    GLOBAL_STATS_OP_HIST_RX_TX);
+}
+
+static void mv88e6390_get_stats(struct mv88e6xxx_chip *chip, int port,
+				uint64_t *data)
+{
+	return _mv88e6xxx_get_stats(chip, port, data,
+				    STATS_TYPE_BANK0 | STATS_TYPE_BANK1,
+				    GLOBAL_STATS_OP_BANK_1_BIT_10, 0);
 }
 
 static void mv88e6xxx_get_stats(struct mv88e6xxx_chip *chip, int port,
@@ -3522,6 +3535,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_snapshot = mv88e6390_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
 	.stats_get_strings = mv88e6320_get_strings,
+	.stats_get_stats = mv88e6390_get_stats,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3537,6 +3551,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_snapshot = mv88e6390_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_get_sset_count,
 	.stats_get_strings = mv88e6320_get_strings,
+	.stats_get_stats = mv88e6390_get_stats,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index e0196450e8a2..9ec1fbd94a3a 100644
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
