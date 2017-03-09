From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 13/14] net: dsa: mv88e6xxx: add port priority override op
Date: Thu,  9 Mar 2017 18:33:23 -0500
Message-ID: <20170309233324.18539-14-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new operation to disable the DA, SA and VTU priority override.

Setting such limit is not likely to be used soon, so provide a
port_disable_pri_override operation directly. This can be changed later
for port_set_pri_override when we'll need it.

Also remove the now obsolete mv88e6xxx_6320_family helper.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 39 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  1 +
 4 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a4fe0576258b..3a350b8a6024 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -687,11 +687,6 @@ static bool mv88e6xxx_6165_family(struct mv88e6xxx_chip *chip)
 	return chip->info->family == MV88E6XXX_FAMILY_6165;
 }
 
-static bool mv88e6xxx_6320_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6320;
-}
-
 static bool mv88e6xxx_6341_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6341;
@@ -2410,14 +2405,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip)) {
-		/* Priority Override: disable DA, SA and VTU priority
-		 * override.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_PRI_OVERRIDE,
-					   0x0000);
+	if (chip->info->ops->port_disable_pri_override) {
+		err = chip->info->ops->port_disable_pri_override(chip, port);
 		if (err)
 			return err;
 	}
@@ -2843,6 +2832,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2893,6 +2883,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2915,6 +2906,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2971,6 +2963,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2991,6 +2984,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3019,6 +3013,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3049,6 +3044,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3077,6 +3073,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3107,6 +3104,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3160,6 +3158,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3189,6 +3188,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3218,6 +3218,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3249,6 +3250,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3278,6 +3280,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3308,6 +3311,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3336,6 +3340,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3362,6 +3367,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3390,6 +3396,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3420,6 +3427,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3450,6 +3458,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3480,6 +3489,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3511,6 +3521,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3542,6 +3553,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3571,6 +3583,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8b341a976366..24cdf461001e 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -877,6 +877,7 @@ struct mv88e6xxx_ops {
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_disable_learn_limit)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_disable_pri_override)(struct mv88e6xxx_chip *chip, int port);
 
 	/* CMODE control what PHY mode the MAC will use, eg. SGMII, RGMII, etc.
 	 * Some chips allow this to be configured on specific ports.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 129f4e67d8af..c8440e56474f 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -812,6 +812,13 @@ int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL, 0);
 }
 
+/* Offset 0x0D: (Priority) Override Register */
+
+int mv88e6xxx_port_disable_pri_override(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_PRI_OVERRIDE, 0);
+}
+
 /* Offset 0x0f: Port Ether type */
 
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index f96ecdbfe8b5..63d9fb172171 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -77,5 +77,6 @@ int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 				     int upstream_port);
 
 int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port);
+int mv88e6xxx_port_disable_pri_override(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.12.0
