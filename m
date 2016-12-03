From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 4/5] net: dsa: mv88e6xxx: Refactor pause configuration
Date: Sat,  3 Dec 2016 04:45:19 +0100
Message-ID: <1480736720-12608-5-git-send-email-andrew@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38563 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753846AbcLCDq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:46:29 -0500
In-Reply-To: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 has a different mechanism for configuring pause.
Refactor the code into an ops function, and for the moment, don't add
any mv88e6390 code yet.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 28 ++++++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 drivers/net/dsa/mv88e6xxx/port.c      | 11 +++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  1 +
 4 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1b0917e44809..3ddb1f79e709 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2625,17 +2625,15 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
-		/* Do not limit the period of time that this port can
-		 * be paused for by the remote end or the period of
-		 * time that this port can pause the remote end.
-		 */
-		err = mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, 0x0000);
+	if (chip->info->ops->port_pause_config) {
+		err = chip->info->ops->port_pause_config(chip, port);
 		if (err)
 			return err;
+	}
 
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Port ATU control: disable limiting the number of
 		 * address database entries that this port is allowed
 		 * to use.
@@ -3220,6 +3218,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3260,6 +3259,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3302,6 +3302,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3325,6 +3326,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3366,6 +3368,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3392,6 +3395,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3416,6 +3420,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3442,6 +3447,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3557,6 +3563,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3605,6 +3612,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3630,6 +3638,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
 	.stats_get_strings = mv88e6320_stats_get_strings,
@@ -3653,6 +3662,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3677,6 +3687,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -3703,6 +3714,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 65aa564daf82..3b1f3ab490b9 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -836,6 +836,7 @@ struct mv88e6xxx_ops {
 	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
 
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
 
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index d22c7b0e0f76..8d14833b2e49 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -304,6 +304,17 @@ int mv88e6390x_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
 	return mv88e6xxx_port_set_speed(chip, port, speed, true, true);
 }
 
+/* Offset 0x02: Pause Control
+ *
+ * Do not limit the period of time that this port can be paused for by
+ * the remote end or the period of time that this port can pause the
+ * remote end.
+ */
+int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, 0x0000);
+}
+
 /* Offset 0x04: Port Control Register */
 
 static const char * const mv88e6xxx_port_state_names[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 9bad597280d6..8c964cfd9032 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -65,5 +65,6 @@ int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
+int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
