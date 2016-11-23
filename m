From: Andrew Lunn <andrew@lunn.ch>
Subject: [[PATCH net-next RFC] 2/4] net: dsa: mv88e6xxx: Monitor and Management tables
Date: Thu, 24 Nov 2016 00:43:16 +0100
Message-ID: <1479944598-20372-3-git-send-email-andrew@lunn.ch>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53440 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:45:09 -0500
In-Reply-To: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 changes the monitor control register into the Monitor
and Management control, which is an indirection register to various
registers. Move the existing code into global1.c, and add new code for
the mv88e6390.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 +++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/global1.c   | 55 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  3 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  7 +++++
 4 files changed, 93 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 880e40288038..a6fa3f81e11b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2747,15 +2747,11 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Configure the upstream port, and configure it as the port to which
-	 * ingress and egress and ARP monitor frames are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
-	if (err)
-		return err;
+	if (chip->info->ops->monitor_ctrl) {
+		err = chip->info->ops->monitor_ctrl(chip, upstream_port);
+		if (err)
+			return err;
+	}
 
 	/* Disable remote management, and set the switch's DSA device number. */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2,
@@ -3184,6 +3180,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3198,6 +3195,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3213,6 +3211,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3227,6 +3226,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3242,6 +3242,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3257,6 +3258,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3273,6 +3275,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3291,6 +3294,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3307,6 +3311,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3325,6 +3330,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3339,6 +3345,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3356,6 +3363,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3373,6 +3381,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3390,6 +3399,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3408,6 +3418,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3425,6 +3436,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3442,6 +3454,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3459,6 +3472,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3475,6 +3489,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3491,6 +3506,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3509,6 +3525,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
+	.monitor_ctrl = mv88e6095_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3526,6 +3543,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3543,6 +3561,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_strings = mv88e6320_stats_get_strings,
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
+	.monitor_ctrl = mv88e6390_monitor_ctrl,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 5fcf23dbf04b..ea4421e1d15c 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -33,6 +33,60 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
 }
 
+/* Offset 0x1a: Monitor Control */
+
+int mv88e6095_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port)
+{
+	u16 reg;
+
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+}
+
+int mv88e6390_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port)
+{
+	u16 reg;
+	int err;
+
+	/* Trap destination */
+	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
+		GLOBAL_MONITOR_CONTROL_CPU_DEST |
+		upstream_port;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:00-01:c2:80:00:00:00:07 are Management */
+	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
+		GLOBAL_MONITOR_CONTROL_0180C280000000XLO | 0xff;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:08-01:c2:80:00:00:00:0f are Management */
+	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
+		GLOBAL_MONITOR_CONTROL_0180C280000000XHI | 0xff;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:20-01:c2:80:00:00:00:27 are Management */
+	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
+		GLOBAL_MONITOR_CONTROL_0180C280000002XLO | 0xff;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:28-01:c2:80:00:00:00:2f are Management */
+	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
+		GLOBAL_MONITOR_CONTROL_0180C280000002XHI | 0xff;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+}
+
 /* Offset 0x1c: Global Control 2 */
 
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
@@ -125,3 +179,4 @@ void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val)
 
 	*val = value | reg;
 }
+
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index df3794cdbfb9..4d8e5ddd8d8c 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -25,5 +25,8 @@ int mv88e6320_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_stats_snapshot(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g1_stats_read(struct mv88e6xxx_chip *chip, int stat, u32 *val);
+int mv88e6095_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port);
+int mv88e6390_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port);
+
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 241025e0aec7..6698ec1d22b5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -289,6 +289,12 @@
 #define GLOBAL_MONITOR_CONTROL_ARP_SHIFT	4
 #define GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT	0
 #define GLOBAL_MONITOR_CONTROL_ARP_DISABLED	(0xf0)
+#define GLOBAL_MONITOR_CONTROL_UPDATE                  BIT(15)
+#define GLOBAL_MONITOR_CONTROL_0180C280000000XLO       (0x00 << 8)
+#define GLOBAL_MONITOR_CONTROL_0180C280000000XHI       (0x01 << 8)
+#define GLOBAL_MONITOR_CONTROL_0180C280000002XLO       (0x02 << 8)
+#define GLOBAL_MONITOR_CONTROL_0180C280000002XHI       (0x03 << 8)
+#define GLOBAL_MONITOR_CONTROL_CPU_DEST		       (0x30 << 8)
 #define GLOBAL_CONTROL_2	0x1c
 #define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
 #define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
@@ -823,6 +829,7 @@ struct mv88e6xxx_ops {
 	void (*stats_get_stats)(struct mv88e6xxx_chip *chip,  int port,
 				uint64_t *data);
 	int (*tag_remap)(struct mv88e6xxx_chip *chip, int port);
+	int (*monitor_ctrl)(struct mv88e6xxx_chip *chip, int upstream_port);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
-- 
2.10.2
