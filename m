From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 16/17] net: dsa: mv88e6xxx: add port priority override op
Date: Sat, 11 Mar 2017 16:13:02 -0500
Message-ID: <20170311211303.24560-17-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55028 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755568AbdCKVPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:05 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new operation to disable the DA, SA and VTU priority override.

Setting such limit is not likely to be used soon, so provide a
port_disable_pri_override operation directly. This can be changed later
for port_set_pri_override when we'll need it.

Also remove the now obsolete mv88e6xxx_6320_family helper.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 39 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  1 +
 4 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 06fe86309e27..3354f99df378 100644
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
@@ -2407,14 +2402,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
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
@@ -2840,6 +2829,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2890,6 +2880,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2912,6 +2903,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2968,6 +2960,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2988,6 +2981,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3016,6 +3010,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3046,6 +3041,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3074,6 +3070,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3104,6 +3101,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3157,6 +3155,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3186,6 +3185,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3215,6 +3215,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3246,6 +3247,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3275,6 +3277,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3305,6 +3308,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3333,6 +3337,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3359,6 +3364,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3387,6 +3393,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3417,6 +3424,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3447,6 +3455,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3477,6 +3486,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3508,6 +3518,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3539,6 +3550,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3568,6 +3580,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a2a0006d8c98..75be2c339a49 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -872,6 +872,7 @@ struct mv88e6xxx_ops {
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_disable_learn_limit)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_disable_pri_override)(struct mv88e6xxx_chip *chip, int port);
 
 	/* CMODE control what PHY mode the MAC will use, eg. SGMII, RGMII, etc.
 	 * Some chips allow this to be configured on specific ports.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 8152fc96fa67..d4868bb50ed5 100644
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
index e9eccbf277b8..c2425ddab287 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -77,5 +77,6 @@ int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 				     int upstream_port);
 
 int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port);
+int mv88e6xxx_port_disable_pri_override(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.12.0
