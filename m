From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 11/11] net: dsa: mv88e6xxx: Move g1 stats code in global1.[ch]
Date: Mon, 21 Nov 2016 23:27:05 +0100
Message-ID: <1479767225-13789-12-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47718 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754434AbcKUW16 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:27:58 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the stats functions which access global 1 registers into
global1.c.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 54 +++----------------------------------
 drivers/net/dsa/mv88e6xxx/global1.c | 33 ++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global1.h |  2 ++
 3 files changed, 37 insertions(+), 52 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5f2193949f87..bada6465af59 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -780,23 +780,6 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 		netdev_err(ds->ports[port].netdev, "failed to configure MAC\n");
 }
 
-static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
-{
-	u16 val;
-	int i, err;
-
-	for (i = 0; i < 10; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_OP, &val);
-		if (err)
-			return err;
-
-		if ((val & GLOBAL_STATS_OP_BUSY) == 0)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
-}
-
 static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
 	if (!chip->info->ops->stats_snapshot)
@@ -805,37 +788,6 @@ static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	return chip->info->ops->stats_snapshot(chip, port);
 }
 
-static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
-				  int stat, u32 *val)
-{
-	u32 value;
-	u16 reg;
-	int err;
-
-	*val = 0;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_READ_CAPTURED | stat);
-	if (err)
-		return;
-
-	err = _mv88e6xxx_stats_wait(chip);
-	if (err)
-		return;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_32, &reg);
-	if (err)
-		return;
-
-	value = reg << 16;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_01, &reg);
-	if (err)
-		return;
-
-	*val = value | reg;
-}
-
 static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 	{ "in_good_octets",		8, 0x00, STATS_TYPE_BANK0, },
 	{ "in_bad_octets",		4, 0x02, STATS_TYPE_BANK0, },
@@ -928,9 +880,9 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 		/* fall through */
 	case STATS_TYPE_BANK0:
 		reg |= s->reg | histogram;
-		_mv88e6xxx_stats_read(chip, reg, &low);
+		mv88e6xxx_g1_stats_read(chip, reg, &low);
 		if (s->sizeof_stat == 8)
-			_mv88e6xxx_stats_read(chip, reg + 1, &high);
+			mv88e6xxx_g1_stats_read(chip, reg + 1, &high);
 	}
 	value = (((u64)high) << 16) | low;
 	return value;
@@ -2888,7 +2840,7 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 		return err;
 
 	/* Wait for the flush to complete. */
-	err = _mv88e6xxx_stats_wait(chip);
+	err = mv88e6xxx_g1_stats_wait(chip);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index fda8b3c7adad..af860d26b091 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -53,7 +53,7 @@ int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
 
 /* Offset 0x1d: Statistics Operation 2 */
 
-static int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip)
+int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_g1_wait(chip, GLOBAL_STATS_OP, GLOBAL_STATS_OP_BUSY);
 }
@@ -95,3 +95,34 @@ int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	/* Wait for the snapshotting to complete. */
 	return mv88e6xxx_g1_stats_wait(chip);
 }
+
+void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val)
+{
+	u32 value;
+	u16 reg;
+	int err;
+
+	*val = 0;
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_READ_CAPTURED | stat);
+	if (err)
+		return;
+
+	err = mv88e6xxx_g1_stats_wait(chip);
+	if (err)
+		return;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_32, &reg);
+	if (err)
+		return;
+
+	value = reg << 16;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_01, &reg);
+	if (err)
+		return;
+
+	*val = value | reg;
+}
+
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index ffc9f45baad9..df3794cdbfb9 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -19,9 +19,11 @@
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
+int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip);
+void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
-- 
2.10.2
