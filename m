From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/14] net: dsa: mv88e6xxx: fix port egress flooding mode
Date: Thu,  9 Mar 2017 18:33:21 -0500
Message-ID: <20170309233324.18539-12-vivien.didelot@savoirfairelinux.com>
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

The Marvell switch ports can be configured to allow or prevent egress of
frames with an unknown unicast or multicast destination address.

Some switch chips such as 88E6095 and 88E6185 have two disjoint bits in
Port Control Register (0x04) bit 2 "Forward Unknown" (for unicast) and
Port Control 2 Register (0x08) bit 6 "Default Forward" (for multicast).

Other chips such as 88E6085, 88E6123, 88E6352, and 88E6390 have a 2-bit
value in Port Control Register (0x04) bits 3:2 "EgressFloods".

The current code does not fully implement the disjoint bits variant and
assigns incorrect ones to some chip models. Fix that with two
implementation references (6185 and 6352 that I currently have) of a
port_set_egress_floods operation (as named in datasheets).

Old chips such as 88E6060 don't have egress flooding mode, so don't
error out if the operation is not provided.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 111 +++++++++++++---------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  15 +++--
 drivers/net/dsa/mv88e6xxx/port.c      |  44 ++++++++++----
 drivers/net/dsa/mv88e6xxx/port.h      |  10 ++-
 4 files changed, 84 insertions(+), 96 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2bbd5649f126..07b08329aa9b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2261,23 +2261,6 @@ static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
 	return -EINVAL;
 }
 
-static int mv88e6xxx_setup_port_dsa(struct mv88e6xxx_chip *chip, int port,
-				    int upstream_port)
-{
-	return chip->info->ops->port_set_egress_unknowns(
-		chip, port, port == upstream_port);
-}
-
-static int mv88e6xxx_setup_port_cpu(struct mv88e6xxx_chip *chip, int port)
-{
-	return chip->info->ops->port_set_egress_unknowns(chip, port, true);
-}
-
-static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
-{
-	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
-}
-
 static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
 {
 	bool message = dsa_is_dsa_port(chip->ds, port);
@@ -2288,6 +2271,18 @@ static int mv88e6xxx_setup_message_port(struct mv88e6xxx_chip *chip, int port)
 	return 0;
 }
 
+static int mv88e6xxx_setup_egress_floods(struct mv88e6xxx_chip *chip, int port)
+{
+	bool flood = port == dsa_upstream_port(chip->ds);
+
+	/* Upstream ports flood frames with unknown unicast or multicast DA */
+	if (chip->info->ops->port_set_egress_floods)
+		return chip->info->ops->port_set_egress_floods(chip, port,
+							       flood, flood);
+
+	return 0;
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -2330,21 +2325,14 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	if (dsa_is_cpu_port(ds, port)) {
-		err = mv88e6xxx_setup_port_cpu(chip, port);
-	} else if (dsa_is_dsa_port(ds, port)) {
-		err = mv88e6xxx_setup_port_dsa(chip, port,
-					       dsa_upstream_port(ds));
-	} else {
-		err = mv88e6xxx_setup_port_normal(chip, port);
-	}
-	if (err)
-		return err;
-
 	err = mv88e6xxx_setup_port_mode(chip, port);
 	if (err)
 		return err;
 
+	err = mv88e6xxx_setup_egress_floods(chip, port);
+	if (err)
+		return err;
+
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
@@ -2850,7 +2838,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6097_port_pause_config,
@@ -2876,7 +2864,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6185_port_set_egress_floods,
 	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
@@ -2898,7 +2886,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
@@ -2923,7 +2911,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2945,7 +2933,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6185_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
@@ -2974,7 +2962,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3020,7 +3008,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3049,7 +3037,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3076,7 +3064,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3105,7 +3093,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3130,7 +3118,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6095_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6185_port_set_egress_floods,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
@@ -3159,7 +3147,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -3187,7 +3175,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -3215,7 +3203,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -3243,7 +3231,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3272,7 +3260,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
@@ -3300,7 +3288,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3327,7 +3315,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3352,7 +3340,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3379,7 +3367,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3408,7 +3396,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3437,7 +3425,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3466,7 +3454,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3495,7 +3483,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3526,7 +3514,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
@@ -3556,7 +3544,7 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -3571,17 +3559,6 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
-static int mv88e6xxx_verify_madatory_ops(struct mv88e6xxx_chip *chip,
-					 const struct mv88e6xxx_ops *ops)
-{
-	if (!ops->port_set_egress_unknowns) {
-		dev_err(chip->dev, "Missing port_set_egress_mode");
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 	[MV88E6085] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
@@ -4272,10 +4249,6 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 
 	chip->info = compat_info;
 
-	err = mv88e6xxx_verify_madatory_ops(chip, chip->info->ops);
-	if (err)
-		return err;
-
 	err = mv88e6xxx_smi_init(chip, mdiodev->bus, mdiodev->addr);
 	if (err)
 		return err;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index c5c54c4608ae..0b8ce86c98ce 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -132,12 +132,12 @@
 #define PORT_CONTROL_TAG_IF_BOTH	BIT(6)
 #define PORT_CONTROL_USE_IP		BIT(5)
 #define PORT_CONTROL_USE_TAG		BIT(4)
-#define PORT_CONTROL_FORWARD_UNKNOWN_MC	BIT(3)
 #define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
-#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_DA		(0x0 << 2)
-#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_MULTICAST_DA	(0x1 << 2)
-#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_UNITCAST_DA	(0x2 << 2)
-#define PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA		(0x3 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_MASK			(0x3 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_DA	(0x0 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MC_DA	(0x1 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UC_DA	(0x2 << 2)
+#define PORT_CONTROL_EGRESS_FLOODS_ALL_UNKNOWN_DA	(0x3 << 2)
 #define PORT_CONTROL_STATE_MASK		0x03
 #define PORT_CONTROL_STATE_DISABLED	0x00
 #define PORT_CONTROL_STATE_BLOCKING	0x01
@@ -167,7 +167,6 @@
 #define PORT_CONTROL_2_DISCARD_UNTAGGED	BIT(8)
 #define PORT_CONTROL_2_MAP_DA		BIT(7)
 #define PORT_CONTROL_2_DEFAULT_FORWARD	BIT(6)
-#define PORT_CONTROL_2_FORWARD_UNKNOWN	BIT(6)
 #define PORT_CONTROL_2_EGRESS_MONITOR	BIT(5)
 #define PORT_CONTROL_2_INGRESS_MONITOR	BIT(4)
 #define PORT_CONTROL_2_UPSTREAM_MASK	0x0f
@@ -869,8 +868,8 @@ struct mv88e6xxx_ops {
 
 	int (*port_set_frame_mode)(struct mv88e6xxx_chip *chip, int port,
 				   enum mv88e6xxx_frame_mode mode);
-	int (*port_set_egress_unknowns)(struct mv88e6xxx_chip *chip, int port,
-					bool on);
+	int (*port_set_egress_floods)(struct mv88e6xxx_chip *chip, int port,
+				      bool unicast, bool multicast);
 	int (*port_set_ether_type)(struct mv88e6xxx_chip *chip, int port,
 				   u16 etype);
 	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 599039dbc384..b028d07134d9 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -497,8 +497,8 @@ int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
 }
 
-int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on)
+static int mv88e6185_port_set_forward_unknown(struct mv88e6xxx_chip *chip,
+					      int port, bool unicast)
 {
 	int err;
 	u16 reg;
@@ -507,7 +507,7 @@ int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	if (on)
+	if (unicast)
 		reg |= PORT_CONTROL_FORWARD_UNKNOWN;
 	else
 		reg &= ~PORT_CONTROL_FORWARD_UNKNOWN;
@@ -515,8 +515,8 @@ int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
 }
 
-int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on)
+int mv88e6352_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
+				     bool unicast, bool multicast)
 {
 	int err;
 	u16 reg;
@@ -525,10 +525,16 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	if (on)
-		reg |= PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA;
+	reg &= ~PORT_CONTROL_EGRESS_FLOODS_MASK;
+
+	if (unicast && multicast)
+		reg |= PORT_CONTROL_EGRESS_FLOODS_ALL_UNKNOWN_DA;
+	else if (unicast)
+		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_MC_DA;
+	else if (multicast)
+		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_UC_DA;
 	else
-		reg &= ~PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA;
+		reg |= PORT_CONTROL_EGRESS_FLOODS_NO_UNKNOWN_DA;
 
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
 }
@@ -690,8 +696,8 @@ static const char * const mv88e6xxx_port_8021q_mode_names[] = {
 	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
 };
 
-int mv88e6095_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on)
+static int mv88e6185_port_set_default_forward(struct mv88e6xxx_chip *chip,
+					      int port, bool multicast)
 {
 	int err;
 	u16 reg;
@@ -700,14 +706,26 @@ int mv88e6095_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	if (on)
-		reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
+	if (multicast)
+		reg |= PORT_CONTROL_2_DEFAULT_FORWARD;
 	else
-		reg &= ~PORT_CONTROL_2_FORWARD_UNKNOWN;
+		reg &= ~PORT_CONTROL_2_DEFAULT_FORWARD;
 
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
 }
 
+int mv88e6185_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
+				     bool unicast, bool multicast)
+{
+	int err;
+
+	err = mv88e6185_port_set_forward_unknown(chip, port, unicast);
+	if (err)
+		return err;
+
+	return mv88e6185_port_set_default_forward(chip, port, multicast);
+}
+
 int mv88e6095_port_set_upstream_port(struct mv88e6xxx_chip *chip, int port,
 				     int upstream_port)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 19217c06e0fb..3e130908a585 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -56,12 +56,10 @@ int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 				  enum mv88e6xxx_frame_mode mode);
 int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 				  enum mv88e6xxx_frame_mode mode);
-int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on);
-int mv88e6095_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on);
-int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
-				       bool on);
+int mv88e6185_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
+				     bool unicast, bool multicast);
+int mv88e6352_port_set_egress_floods(struct mv88e6xxx_chip *chip, int port,
+				     bool unicast, bool multicast);
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
 int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
-- 
2.12.0
