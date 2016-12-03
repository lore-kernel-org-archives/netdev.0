From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 3/5] net: dsa: mv88e6xxx: Refactor egress rate limiting
Date: Sat,  3 Dec 2016 04:45:18 +0100
Message-ID: <1480736720-12608-4-git-send-email-andrew@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38559 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753128AbcLCDpy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:45:54 -0500
In-Reply-To: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two different rate limiting configurations, depending on the
switch generation. Refactor this into ops.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 31 +++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 drivers/net/dsa/mv88e6xxx/port.c      | 12 ++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  2 ++
 4 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index db1542e05e62..1b0917e44809 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2657,18 +2657,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return err;
 	}
 
-	/* Rate Control: disable ingress rate limiting. */
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
-		err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL,
-					   0x0001);
-		if (err)
-			return err;
-
-	} else if (mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip)) {
-		err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL,
-					   0x0000);
+	if (chip->info->ops->port_egress_rate_limiting) {
+		err = chip->info->ops->port_egress_rate_limiting(chip, port);
 		if (err)
 			return err;
 	}
@@ -3229,6 +3219,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3268,6 +3259,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3309,6 +3301,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3331,6 +3324,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3371,6 +3365,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3396,6 +3391,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3419,6 +3415,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3444,6 +3441,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3463,6 +3461,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.port_set_speed = mv88e6185_port_set_speed,
 	.port_set_frame_mode = mv88e6085_port_set_frame_mode,
 	.port_set_egress_unknowns = mv88e6085_port_set_egress_unknowns,
+	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3557,6 +3556,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3604,6 +3604,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3628,6 +3629,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3650,6 +3652,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3673,6 +3676,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3698,6 +3702,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3721,6 +3726,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3745,6 +3751,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d4f18b8209ec..65aa564daf82 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -835,6 +835,8 @@ struct mv88e6xxx_ops {
 				   u16 etype);
 	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
 
+	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index a739129ce5e5..d22c7b0e0f76 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -621,6 +621,18 @@ int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
 }
 
+/* Offset 0x09: Port Rate Control */
+
+int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0000);
+}
+
+int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL, 0x0001);
+}
+
 /* Offset 0x0f: Port Ether type */
 
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 9e25735c287e..9bad597280d6 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -63,5 +63,7 @@ int mv88e6351_port_set_egress_unknowns(struct mv88e6xxx_chip *chip, int port,
 int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
+int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
