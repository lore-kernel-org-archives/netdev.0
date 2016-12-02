From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA port setup
Date: Fri,  2 Dec 2016 19:02:59 +0100
Message-ID: <1480701779-30633-5-git-send-email-andrew@lunn.ch>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37969 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751294AbcLBSEK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 13:04:10 -0500
In-Reply-To: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older chips only support DSA tagging. Newer chips have both DSA and
EDSA tagging. Refactor the code by adding port functions for setting the
frame mode, egress mode, and if to forward unknown frames.

This results in the helper mv88e6xxx_6065_family() becoming unused, so
remove it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 205 ++++++++++++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  20 ++++
 drivers/net/dsa/mv88e6xxx/port.c      | 118 +++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  13 +++
 4 files changed, 308 insertions(+), 48 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 80efee6f5e16..d1e6a0760a75 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -677,11 +677,6 @@ static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, int addr,
 	return err;
 }
 
-static bool mv88e6xxx_6065_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6065;
-}
-
 static bool mv88e6xxx_6095_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6095;
@@ -2438,6 +2433,80 @@ static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+static int mv88e6xxx_setup_port_dsa(struct mv88e6xxx_chip *chip, int port,
+				    int upstream_port)
+{
+	int err;
+
+	err = chip->info->ops->port_set_frame_mode(
+		chip, port, MV88E6XXX_FRAME_MODE_DSA);
+	if (err)
+		return err;
+
+	err = chip->info->ops->port_set_egress_unknowns(
+		chip, port, port == upstream_port);
+	if (err)
+		return err;
+
+	if (chip->info->ops->port_set_ether_type)
+		return chip->info->ops->port_set_ether_type(
+			chip, port, ETH_P_EDSA);
+
+	return 0;
+}
+
+static int mv88e6xxx_setup_port_cpu(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	switch (chip->info->tag_protocol) {
+	case DSA_TAG_PROTO_EDSA:
+		err = chip->info->ops->port_set_frame_mode(
+			chip, port, MV88E6XXX_FRAME_MODE_ETHERTYPE);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_port_set_egress_mode(
+			chip, port, PORT_CONTROL_EGRESS_ADD_TAG);
+		if (err)
+			return err;
+
+		if (chip->info->ops->port_set_ether_type)
+			err = chip->info->ops->port_set_ether_type(
+				chip, port, ETH_P_EDSA);
+		break;
+
+	case DSA_TAG_PROTO_DSA:
+		err = chip->info->ops->port_set_frame_mode(
+			chip, port, MV88E6XXX_FRAME_MODE_DSA);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_port_set_egress_mode(
+			chip, port, PORT_CONTROL_EGRESS_UNMODIFIED);
+		break;
+	default:
+		err = -EINVAL;
+	}
+
+	if (err)
+		return err;
+
+	return chip->info->ops->port_set_egress_unknowns(chip, port, true);
+}
+
+static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	err = chip->info->ops->port_set_frame_mode(
+		chip, port, MV88E6XXX_FRAME_MODE_NORMAL);
+	if (err)
+		return err;
+
+	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -2473,44 +2542,25 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	 * If this is the upstream port for this switch, enable
 	 * forwarding of unknown unicasts and multicasts.
 	 */
-	reg = 0;
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6065_family(chip) ||
-	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6320_family(chip))
-		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
+	reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
+	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	if (err)
+		return err;
+
 	if (dsa_is_cpu_port(ds, port)) {
-		if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
-			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
-				PORT_CONTROL_FORWARD_UNKNOWN_MC;
-		else
-			reg |= PORT_CONTROL_DSA_TAG;
-		reg |= PORT_CONTROL_EGRESS_ADD_TAG |
-			PORT_CONTROL_FORWARD_UNKNOWN;
-	}
-	if (dsa_is_dsa_port(ds, port)) {
-		if (mv88e6xxx_6095_family(chip) ||
-		    mv88e6xxx_6185_family(chip))
-			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(chip) ||
-		    mv88e6xxx_6351_family(chip) ||
-		    mv88e6xxx_6165_family(chip) ||
-		    mv88e6xxx_6097_family(chip) ||
-		    mv88e6xxx_6320_family(chip)) {
-			reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		err = mv88e6xxx_setup_port_cpu(chip, port);
+	} else {
+		if (dsa_is_dsa_port(ds, port)) {
+			err = mv88e6xxx_setup_port_dsa(chip, port,
+						       dsa_upstream_port(ds));
+		} else {
+			err = mv88e6xxx_setup_port_normal(chip, port);
 		}
-
-		if (port == dsa_upstream_port(ds))
-			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
-				PORT_CONTROL_FORWARD_UNKNOWN_MC;
-	}
-	if (reg) {
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
-		if (err)
-			return err;
 	}
+	if (err)
+		return err;
 
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
@@ -2607,16 +2657,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 					   0x0000);
 		if (err)
 			return err;
-
-		/* Port Ethertype: use the Ethertype DSA Ethertype
-		 * value.
-		 */
-		if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA) {
-			err = mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE,
-						   ETH_P_EDSA);
-			if (err)
-				return err;
-		}
 	}
 
 	if (chip->info->ops->port_tag_remap) {
@@ -3182,6 +3222,9 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3198,6 +3241,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3213,6 +3258,9 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3229,6 +3277,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3246,6 +3296,9 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3263,6 +3316,9 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3297,6 +3353,9 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3317,6 +3376,9 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3335,6 +3397,9 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3355,6 +3420,9 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3371,6 +3439,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
+	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3389,6 +3459,9 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3408,6 +3481,9 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3427,6 +3503,9 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3448,6 +3527,9 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3466,6 +3548,9 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3486,6 +3571,9 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3505,6 +3593,9 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3523,6 +3614,9 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3541,6 +3635,9 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3561,6 +3658,9 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6352_port_set_speed,
 	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3579,6 +3679,9 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3598,6 +3701,9 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3617,6 +3723,9 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
 	.port_tag_remap = mv88e6390_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 2c51e3a8a890..9dd94d7f58d6 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -110,6 +110,7 @@
 #define PORT_CONTROL_EGRESS_UNTAGGED	(0x1 << 12)
 #define PORT_CONTROL_EGRESS_TAGGED	(0x2 << 12)
 #define PORT_CONTROL_EGRESS_ADD_TAG	(0x3 << 12)
+#define PORT_CONTROL_EGRESS_MASK	(0x3 << 12)
 #define PORT_CONTROL_HEADER		BIT(11)
 #define PORT_CONTROL_IGMP_MLD_SNOOP	BIT(10)
 #define PORT_CONTROL_DOUBLE_TAG		BIT(9)
@@ -117,6 +118,7 @@
 #define PORT_CONTROL_FRAME_MODE_DSA		(0x1 << 8)
 #define PORT_CONTROL_FRAME_MODE_PROVIDER	(0x2 << 8)
 #define PORT_CONTROL_FRAME_ETHER_TYPE_DSA	(0x3 << 8)
+#define PORT_CONTROL_FRAME_MASK			(0x3 << 8)
 #define PORT_CONTROL_DSA_TAG		BIT(8)
 #define PORT_CONTROL_VLAN_TUNNEL	BIT(7)
 #define PORT_CONTROL_TAG_IF_BOTH	BIT(6)
@@ -124,6 +126,10 @@
 #define PORT_CONTROL_USE_TAG		BIT(4)
 #define PORT_CONTROL_FORWARD_UNKNOWN_MC	BIT(3)
 #define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
+#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_DA		(0x0 << 2)
+#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_MULTICAST_DA	(0x1 << 2)
+#define PORT_CONTROL_NOT_EGRESS_UNKNOWN_UNITCAST_DA	(0x2 << 2)
+#define PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA		(0x3 << 2)
 #define PORT_CONTROL_STATE_MASK		0x03
 #define PORT_CONTROL_STATE_DISABLED	0x00
 #define PORT_CONTROL_STATE_BLOCKING	0x01
@@ -396,6 +402,13 @@
 
 #define MV88E6XXX_N_FID		4096
 
+enum mv88e6xxx_frame_mode {
+	MV88E6XXX_FRAME_MODE_NORMAL,
+	MV88E6XXX_FRAME_MODE_DSA,
+	MV88E6XXX_FRAME_MODE_PROVIDER,
+	MV88E6XXX_FRAME_MODE_ETHERTYPE,
+};
+
 /* List of supported models */
 enum mv88e6xxx_model {
 	MV88E6085,
@@ -814,6 +827,13 @@ struct mv88e6xxx_ops {
 
 	int (*port_tag_remap)(struct mv88e6xxx_chip *chip, int port);
 
+	int (*port_set_frame_mode)(struct mv88e6xxx_chip *chip, int port,
+				   enum mv88e6xxx_frame_mode mode);
+	int (*port_set_egress_unknowns)(struct mv88e6xxx_chip *chip, int port,
+					bool on);
+	int (*port_set_ether_type)(struct mv88e6xxx_chip *chip, int port,
+				   u16 etype);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 3d03ea3a2c0d..cf6674911abf 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -335,6 +335,116 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 	return 0;
 }
 
+int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
+				   u16 mode)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_EGRESS_MASK;
+	reg |= mode;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
+				  enum mv88e6xxx_frame_mode mode)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_FRAME_MODE_DSA;
+
+	switch (mode) {
+	case MV88E6XXX_FRAME_MODE_NORMAL:
+		reg |= PORT_CONTROL_FRAME_MODE_NORMAL;
+		break;
+	case MV88E6XXX_FRAME_MODE_DSA:
+		reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
+				  enum mv88e6xxx_frame_mode mode)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_CONTROL_FRAME_MASK;
+
+	switch (mode) {
+	case MV88E6XXX_FRAME_MODE_NORMAL:
+		reg |= PORT_CONTROL_FRAME_MODE_NORMAL;
+		break;
+	case MV88E6XXX_FRAME_MODE_DSA:
+		reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		break;
+	case MV88E6XXX_FRAME_MODE_PROVIDER:
+		reg |= PORT_CONTROL_FRAME_MODE_PROVIDER;
+		break;
+	case MV88E6XXX_FRAME_MODE_ETHERTYPE:
+		reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	if (on)
+		reg |= PORT_CONTROL_FORWARD_UNKNOWN;
+	else
+		reg &= ~PORT_CONTROL_FORWARD_UNKNOWN;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	if (on)
+		reg |= PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA;
+	else
+		reg &= ~PORT_CONTROL_EGRESS_ALL_UNKNOWN_DA;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
 /* Offset 0x05: Port Control 1 */
 
 /* Offset 0x06: Port Based VLAN Map */
@@ -497,6 +607,14 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	return 0;
 }
 
+/* Offset 0x0f: Port Ether type */
+
+int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
+				  u16 etype)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE, etype);
+}
+
 /* Offset 0x18: Port IEEE Priority Remapping Registers [0-3]
  * Offset 0x19: Port IEEE Priority Remapping Registers [4-7]
  */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 5fab4606662b..83cb3440e067 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -50,5 +50,18 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 				  u16 mode);
 int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
+int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
+				   u16 mode);
+int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
+				  enum mv88e6xxx_frame_mode mode);
+int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
+				  enum mv88e6xxx_frame_mode mode);
+int mv88e6085_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on);
+int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
+				       bool on);
+int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
+				  u16 etype);
+
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
