From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 04/11] net: dsa: mv88e6xxx: Abstract stats_snapshot into ops structure
Date: Mon, 21 Nov 2016 23:26:58 +0100
Message-ID: <1479767225-13789-5-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47714 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754434AbcKUW1r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:27:47 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking a stats snapshot differs between same families. Abstract this
into an ops member. At the same time, move the code into global1.[ch],
since the registers are in the global1 range.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2:
  Move code into global1.c
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 +++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 27 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  2 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 +++++
 4 files changed, 56 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 02d1b3529ee4..6e72877f125a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -797,22 +797,12 @@ static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 	return -ETIMEDOUT;
 }
 
-static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
-	int err;
-
-	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
-		port = (port + 1) << 5;
-
-	/* Snapshot the hardware statistics counters for this port. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
-				 GLOBAL_STATS_OP_CAPTURE_PORT |
-				 GLOBAL_STATS_OP_HIST_RX_TX | port);
-	if (err)
-		return err;
+	if (!chip->info->ops->stats_snapshot)
+		return -EOPNOTSUPP;
 
-	/* Wait for the snapshotting to complete. */
-	return _mv88e6xxx_stats_wait(chip);
+	return chip->info->ops->stats_snapshot(chip, port);
 }
 
 static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
@@ -1003,7 +993,7 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_stats_snapshot(chip, port);
+	ret = mv88e6xxx_stats_snapshot(chip, port);
 	if (ret < 0) {
 		mutex_unlock(&chip->reg_lock);
 		return;
@@ -3162,6 +3152,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3171,6 +3162,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3180,6 +3172,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3189,6 +3182,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3198,6 +3192,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3207,6 +3202,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3217,6 +3213,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3229,6 +3226,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3239,6 +3237,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3251,6 +3250,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3260,6 +3260,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3302,6 +3303,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3323,6 +3325,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3334,6 +3337,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3344,6 +3348,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3354,6 +3359,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3366,6 +3372,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index d358720b6c2d..47b507d4d163 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -32,3 +32,30 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 {
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
+
+static int mv88e6xxx_g1_stats_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_wait(chip, GLOBAL_STATS_OP, GLOBAL_STATS_OP_BUSY);
+}
+
+int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	/* Snapshot the hardware statistics counters for this port. */
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_CAPTURE_PORT |
+				 GLOBAL_STATS_OP_HIST_RX_TX | port);
+	if (err)
+		return err;
+
+	/* Wait for the snapshotting to complete. */
+	return mv88e6xxx_g1_stats_wait(chip);
+}
+
+int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	port = (port + 1) << 5;
+
+	return mv88e6xxx_g1_stats_snapshot(chip, port);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 62291e6fe3a3..0080a30733e8 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -19,5 +19,7 @@
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
 int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
+int mv88e6xxx_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
+int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index de179c59f5cf..7c61cf626e56 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -794,6 +794,11 @@ struct mv88e6xxx_ops {
 	 * Use SPEED_UNFORCED for normal detection, SPEED_MAX for max value.
 	 */
 	int (*port_set_speed)(struct mv88e6xxx_chip *chip, int port, int speed);
+
+	/* Snapshot the statistics for a port. The statistics can then
+	 * be read back a leisure but still with a consistent view.
+	 */
+	int (*stats_snapshot)(struct mv88e6xxx_chip *chip, int port);
 };
 
 enum stat_type {
-- 
2.10.2
