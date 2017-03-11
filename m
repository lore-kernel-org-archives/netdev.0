From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 15/17] net: dsa: mv88e6xxx: add port ATU learn limit op
Date: Sat, 11 Mar 2017 16:13:01 -0500
Message-ID: <20170311211303.24560-16-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55182 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755644AbdCKVPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:07 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new operation to disable the limiting of learnt MAC addresses.

Setting such limit is not likely to be used soon, so provide a
port_disable_learn_limit operation directly. This can be changed later
for port_set_learn_limit when we'll need it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 36 +++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      |  7 +++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  3 +++
 4 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0844df1b25e9..06fe86309e27 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2401,15 +2401,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
+	if (chip->info->ops->port_disable_learn_limit) {
+		err = chip->info->ops->port_disable_learn_limit(chip, port);
+		if (err)
+			return err;
+	}
+
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
 	    mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip)) {
-		/* Port ATU control: disable limiting the number of
-		 * address database entries that this port is allowed
-		 * to use.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL,
-					   0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
@@ -2839,6 +2839,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2888,6 +2889,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2909,6 +2911,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2964,6 +2967,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2983,6 +2987,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3010,6 +3015,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3039,6 +3045,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3066,6 +3073,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3095,6 +3103,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3147,6 +3156,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3175,6 +3185,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3203,6 +3214,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3233,6 +3245,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3261,6 +3274,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3290,6 +3304,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3317,6 +3332,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3342,6 +3358,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3369,6 +3386,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3398,6 +3416,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3427,6 +3446,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3456,6 +3476,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3486,6 +3507,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3516,6 +3538,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3544,6 +3567,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index bde7c775d559..a2a0006d8c98 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -871,6 +871,7 @@ struct mv88e6xxx_ops {
 
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_disable_learn_limit)(struct mv88e6xxx_chip *chip, int port);
 
 	/* CMODE control what PHY mode the MAC will use, eg. SGMII, RGMII, etc.
 	 * Some chips allow this to be configured on specific ports.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index c918292217ff..8152fc96fa67 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -805,6 +805,13 @@ int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0001);
 }
 
+/* Offset 0x0C: Port ATU Control */
+
+int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL, 0);
+}
+
 /* Offset 0x0f: Port Ether type */
 
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 35d28d05c009..e9eccbf277b8 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -75,4 +75,7 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode);
 int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 				     int upstream_port);
+
+int mv88e6xxx_port_disable_learn_limit(struct mv88e6xxx_chip *chip, int port);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.12.0
