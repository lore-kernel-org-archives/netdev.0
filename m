From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/7] net: dsa: mv88e6xxx: rework pause limit operation
Date: Thu,  8 Jun 2017 18:34:12 -0400
Message-ID: <20170608223414.594-6-vivien.didelot@savoirfairelinux.com>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50794 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdFHWgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:36:38 -0400
In-Reply-To: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All Marvell chips supporting Pause frames limiting use 1-byte value for
input and output.

Old chips have both bytes adjacent in a 16-bit register. New ones have
an indirect table using 8-bit data.

The mv88e6xxx library functions (such as in port.c) must not contain
driver logic, but only generic helpers. This patch changes the
port_pause_config operation for port_pause_limit taking two u8 arguments
for input and output limits. There is no functional changes.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 48 ++++++++++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  3 ++-
 drivers/net/dsa/mv88e6xxx/port.c | 12 +++++-----
 drivers/net/dsa/mv88e6xxx/port.h |  6 +++--
 4 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f33b83bf3ee8..a0f450cb45fb 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1901,8 +1901,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	if (chip->info->ops->port_pause_config) {
-		err = chip->info->ops->port_pause_config(chip, port);
+	if (chip->info->ops->port_pause_limit) {
+		err = chip->info->ops->port_pause_limit(chip, port, 0, 0);
 		if (err)
 			return err;
 	}
@@ -2362,7 +2362,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
@@ -2417,7 +2417,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
@@ -2473,7 +2473,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
@@ -2506,7 +2506,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -2536,7 +2536,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2590,7 +2590,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2623,7 +2623,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2655,7 +2655,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2688,7 +2688,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2747,7 +2747,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -2780,7 +2780,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -2813,7 +2813,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -2848,7 +2848,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2880,7 +2880,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
@@ -2915,7 +2915,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2946,7 +2946,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -2977,7 +2977,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
@@ -3008,7 +3008,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -3039,7 +3039,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -3072,7 +3072,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
+	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6320_g1_stats_snapshot,
@@ -3106,7 +3106,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
@@ -3142,7 +3142,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6390_port_pause_config,
+	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 07b35cccb0c4..d5f55c28f613 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -425,7 +425,8 @@ struct mv88e6xxx_ops {
 	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
 
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
-	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_pause_limit)(struct mv88e6xxx_chip *chip, int port, u8 in,
+				u8 out);
 	int (*port_disable_learn_limit)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_disable_pri_override)(struct mv88e6xxx_chip *chip, int port);
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 46e73ca0ac4d..ee94d16789a2 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -376,22 +376,24 @@ int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode)
  * the remote end or the period of time that this port can pause the
  * remote end.
  */
-int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port)
+int mv88e6097_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
+			       u8 out)
 {
-	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, 0x0000);
+	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, out << 8 | in);
 }
 
-int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port)
+int mv88e6390_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
+			       u8 out)
 {
 	int err;
 
 	err = mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
-				   PORT_FLOW_CTRL_LIMIT_IN | 0);
+				   PORT_FLOW_CTRL_LIMIT_IN | in);
 	if (err)
 		return err;
 
 	return mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL,
-				    PORT_FLOW_CTRL_LIMIT_OUT | 0);
+				    PORT_FLOW_CTRL_LIMIT_OUT | out);
 }
 
 /* Offset 0x04: Port Control Register */
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 1de200074e21..7be66f5b4c31 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -228,8 +228,10 @@ int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
 int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
-int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port);
-int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6097_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
+			       u8 out);
+int mv88e6390_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
+			       u8 out);
 int mv88e6390x_port_set_cmode(struct mv88e6xxx_chip *chip, int port,
 			      phy_interface_t mode);
 int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode);
-- 
2.13.1
