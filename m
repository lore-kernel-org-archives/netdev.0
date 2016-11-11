From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 04/11] net: dsa: mv88e6xxx: Abstract stats_snapshot into ops structure
Date: Fri, 11 Nov 2016 03:53:36 +0100
Message-ID: <1478832823-31471-5-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34638 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:54:25 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking a stats snapshot differs between same families. Abstract this
into an ops member.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 +++++++++++++++++++++++++++++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 +++++
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 066d9479c981..65f34f1999e7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -785,9 +785,6 @@ static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
 	int err;
 
-	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
-		port = (port + 1) << 5;
-
 	/* Snapshot the hardware statistics counters for this port. */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
 				 GLOBAL_STATS_OP_CAPTURE_PORT |
@@ -799,6 +796,21 @@ static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	return _mv88e6xxx_stats_wait(chip);
 }
 
+static int mv88e6320_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	port = (port + 1) << 5;
+
+	return _mv88e6xxx_stats_snapshot(chip, port);
+}
+
+static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	if (!chip->info->ops->stats_snapshot)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->stats_snapshot(chip, port);
+}
+
 static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 				  int stat, u32 *val)
 {
@@ -987,7 +999,7 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_stats_snapshot(chip, port);
+	ret = mv88e6xxx_stats_snapshot(chip, port);
 	if (ret < 0) {
 		mutex_unlock(&chip->reg_lock);
 		return;
@@ -3146,6 +3158,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3155,6 +3168,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3164,6 +3178,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3173,6 +3188,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3182,6 +3198,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3191,6 +3208,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3201,6 +3219,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3213,6 +3232,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3223,6 +3243,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3235,6 +3256,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3244,6 +3266,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = _mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3256,6 +3279,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3267,6 +3291,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3278,6 +3303,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3288,6 +3314,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3298,6 +3325,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.stats_snapshot = mv88e6xxx_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3310,6 +3338,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
+	.stats_snapshot = mv88e6320_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 48915e5e3a3d..fd5352bf7625 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -793,6 +793,11 @@ struct mv88e6xxx_ops {
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
