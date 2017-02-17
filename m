From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/6] net: dsa: mv88e6xxx: add VTU ops
Date: Fri, 17 Feb 2017 10:05:30 -0500
Message-ID: <20170217150531.2181-6-vivien.didelot@savoirfairelinux.com>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47606 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934457AbdBQPGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:06:23 -0500
In-Reply-To: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because there are several variant of the VTU operations and because
checking for the presence of an STU is not enough, add new ops to the
info structure to describe the VTU operations that a chip supports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 58 +++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  8 ++++-
 2 files changed, 49 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7010c3313e35..256a209eef9b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1220,33 +1220,19 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 static int mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				 struct mv88e6xxx_vtu_entry *entry)
 {
-	int err;
-
 	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU))
-		err = mv88e6352_g1_vtu_getnext(chip, entry);
-	else
-		err = mv88e6185_g1_vtu_getnext(chip, entry);
-
-	return err;
+	return chip->info->ops->vtu_getnext(chip, entry);
 }
 
 static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 				   struct mv88e6xxx_vtu_entry *entry)
 {
-	int err;
-
 	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU))
-		err = mv88e6352_g1_vtu_loadpurge(chip, entry);
-	else
-		err = mv88e6185_g1_vtu_loadpurge(chip, entry);
-
-	return err;
+	return chip->info->ops->vtu_loadpurge(chip, entry);
 }
 
 static int mv88e6xxx_vtu_flush(struct mv88e6xxx_chip *chip)
@@ -2611,6 +2597,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -2632,6 +2620,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -2658,6 +2648,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -2679,6 +2671,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -2708,6 +2702,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -2734,6 +2730,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -2753,6 +2751,8 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -2780,6 +2780,8 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -2809,6 +2811,8 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -2836,6 +2840,8 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -2865,6 +2871,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -2890,6 +2898,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3003,6 +3013,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3059,6 +3071,8 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3085,6 +3099,8 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3112,6 +3128,8 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3139,6 +3157,8 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3168,6 +3188,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6141_ops = {
@@ -3197,6 +3219,8 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6341_ops = {
@@ -3226,6 +3250,8 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 2f9a79a2e957..3770a50a2d85 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -912,6 +912,12 @@ struct mv88e6xxx_ops {
 
 	/* Can be either in g1 or g2, so don't use a prefix */
 	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
+
+	/* VLAN Translation Unit operations */
+	int (*vtu_getnext)(struct mv88e6xxx_chip *chip,
+			   struct mv88e6xxx_vtu_entry *entry);
+	int (*vtu_loadpurge)(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
 };
 
 struct mv88e6xxx_irq_ops {
@@ -942,7 +948,7 @@ static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
 
 static inline bool mv88e6xxx_has_vtu(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU);
+	return chip->info->ops->vtu_getnext && chip->info->ops->vtu_loadpurge;
 }
 
 static inline unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
-- 
2.11.1
