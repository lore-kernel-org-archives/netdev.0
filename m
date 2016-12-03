From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 2/5] net: dsa: mv88e6xxx: Refactor setting of jumbo frames
Date: Sat,  3 Dec 2016 04:45:17 +0100
Message-ID: <1480736720-12608-3-git-send-email-andrew@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38568 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754206AbcLCDq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:46:29 -0500
In-Reply-To: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switches support jumbo frames. Refactor this code into operations
in the ops structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 26 ++++++++++++++++++++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      | 14 ++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 +-
 4 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b2b6fe3ef4bf..db1542e05e62 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2582,10 +2582,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	    mv88e6xxx_6185_family(chip))
 		reg = PORT_CONTROL_2_MAP_DA;
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6320_family(chip))
-		reg |= PORT_CONTROL_2_JUMBO_10240;
-
 	if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
 		/* Set the upstream port this port should use */
 		reg |= dsa_upstream_port(ds);
@@ -2604,6 +2600,12 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
+	if (chip->info->ops->port_jumbo_config) {
+		err = chip->info->ops->port_jumbo_config(chip, port);
+		if (err)
+			return err;
+	}
+
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
@@ -2663,6 +2665,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 					   0x0001);
 		if (err)
 			return err;
+
 	} else if (mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip)) {
 		err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL,
 					   0x0000);
@@ -3264,6 +3267,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3304,6 +3308,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3325,6 +3330,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3364,6 +3370,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3388,6 +3395,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3410,6 +3418,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3434,6 +3443,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3546,6 +3556,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3592,6 +3603,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3615,6 +3627,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3636,6 +3649,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3658,6 +3672,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3682,6 +3697,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3704,6 +3720,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3727,6 +3744,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d9ffa96fe875..d4f18b8209ec 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -833,6 +833,7 @@ struct mv88e6xxx_ops {
 					bool on);
 	int (*port_set_ether_type)(struct mv88e6xxx_chip *chip, int port,
 				   u16 etype);
+	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
 
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index cf6674911abf..a739129ce5e5 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -607,6 +607,20 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	return 0;
 }
 
+int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
+		return err;
+
+	reg |= PORT_CONTROL_2_JUMBO_10240;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+}
+
 /* Offset 0x0f: Port Ether type */
 
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 83cb3440e067..9e25735c287e 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -62,6 +62,6 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 				       bool on);
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
-
+int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
