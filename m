From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management frames to CPU
Date: Sat,  3 Dec 2016 04:45:16 +0100
Message-ID: <1480736720-12608-2-git-send-email-andrew@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38572 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752297AbcLCDrh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:47:37 -0500
In-Reply-To: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older devices have a couple of registers in global2. The mv88e6390
family has a single register in global1 behind which hides similar
configuration. Implement and op for this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 35 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.c   | 27 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  1 +
 drivers/net/dsa/mv88e6xxx/global2.c   | 43 ++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global2.h   |  6 +++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  3 +++
 6 files changed, 97 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9c14aaad5103..b2b6fe3ef4bf 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2899,6 +2899,17 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	/* Some generations have the configuration of sending reserved
+	 * management frames to the CPU in global2, others in
+	 * global1. Hence it does not fit the two setup functions
+	 * above.
+	 */
+	if (chip->info->ops->mgmt_rsvd2cpu) {
+		err = chip->info->ops->mgmt_rsvd2cpu(chip);
+		if (err)
+			goto unlock;
+	}
+
 unlock:
 	mutex_unlock(&chip->reg_lock);
 
@@ -3221,6 +3232,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3237,6 +3249,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -3257,6 +3270,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3275,6 +3289,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3295,6 +3310,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3315,6 +3331,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3331,6 +3348,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3352,6 +3370,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3375,6 +3394,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3396,6 +3416,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3419,6 +3440,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3437,6 +3459,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3459,6 +3482,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3481,6 +3505,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3503,6 +3528,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3526,6 +3552,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3548,6 +3575,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3570,6 +3598,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3613,6 +3642,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3634,6 +3664,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3657,6 +3688,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3679,6 +3711,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3701,6 +3734,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3723,6 +3757,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 };
 
 static int mv88e6xxx_verify_madatory_ops(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 688547026e15..44136ee015c3 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -102,6 +102,33 @@ int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
 					  port);
 }
 
+int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	/* 01:c2:80:00:00:00:00-01:c2:80:00:00:00:07 are Management */
+	err = mv88e6390_g1_monitor_write(
+		chip, GLOBAL_MONITOR_CONTROL_0180C280000000XLO, 0xff);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:08-01:c2:80:00:00:00:0f are Management */
+	err = mv88e6390_g1_monitor_write(
+		chip, GLOBAL_MONITOR_CONTROL_0180C280000000XHI, 0xff);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:20-01:c2:80:00:00:00:27 are Management */
+	err = mv88e6390_g1_monitor_write(
+		chip, GLOBAL_MONITOR_CONTROL_0180C280000002XLO, 0xff);
+	if (err)
+		return err;
+
+	/* 01:c2:80:00:00:00:28-01:c2:80:00:00:00:2f are Management */
+	return mv88e6390_g1_monitor_write(
+		chip, GLOBAL_MONITOR_CONTROL_0180C280000002XHI, 0xff);
+}
+
 /* Offset 0x1c: Global Control 2 */
 
 int mv88e6390_g1_stats_set_histogram(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 0c979550052f..cb61378829e6 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -29,5 +29,6 @@ int mv88e6095_g1_set_egress_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_set_egress_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 536a27c9735f..3e77071949ab 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -38,6 +38,31 @@ static int mv88e6xxx_g2_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
 	return mv88e6xxx_wait(chip, ADDR_GLOBAL2, reg, mask);
 }
 
+/* Offset 0x02: Management Enable 2x */
+/* Offset 0x03: Management Enable 0x */
+
+int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	/* Consider the frames with reserved multicast destination
+	 * addresses matching 01:80:c2:00:00:2x as MGMT.
+	 */
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
+		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_2X, 0xffff);
+		if (err)
+			return err;
+	}
+
+	/* Consider the frames with reserved multicast destination
+	 * addresses matching 01:80:c2:00:00:0x as MGMT.
+	 */
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X))
+		return mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_0X, 0xffff);
+
+	return 0;
+}
+
 /* Offset 0x06: Device Mapping Table register */
 
 static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
@@ -567,24 +592,6 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	u16 reg;
 	int err;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
-		/* Consider the frames with reserved multicast destination
-		 * addresses matching 01:80:c2:00:00:2x as MGMT.
-		 */
-		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_2X, 0xffff);
-		if (err)
-			return err;
-	}
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X)) {
-		/* Consider the frames with reserved multicast destination
-		 * addresses matching 01:80:c2:00:00:0x as MGMT.
-		 */
-		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_0X, 0xffff);
-		if (err)
-			return err;
-	}
-
 	/* Ignore removed tag data on doubly tagged packets, disable
 	 * flow control messages, force flow control priority to the
 	 * highest, and send all special multicast frames to the CPU
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 1eb3ddd21551..9aefb7d8b0ad 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -35,6 +35,7 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
+int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
 #else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
@@ -94,6 +95,11 @@ static inline void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 {
 }
 
+static inline int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 #endif /* _MV88E6XXX_GLOBAL2_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9dd94d7f58d6..d9ffa96fe875 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -851,6 +851,9 @@ struct mv88e6xxx_ops {
 				uint64_t *data);
 	int (*g1_set_cpu_port)(struct mv88e6xxx_chip *chip, int port);
 	int (*g1_set_egress_port)(struct mv88e6xxx_chip *chip, int port);
+
+	/* Can be either in g1 or g2, so don't use a prefix */
+	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
-- 
2.10.2
