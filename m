From: Andrew Lunn <andrew@lunn.ch>
Subject: [[PATCH net-next RFC] 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA port setup
Date: Thu, 24 Nov 2016 00:43:18 +0100
Message-ID: <1479944598-20372-5-git-send-email-andrew@lunn.ch>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53428 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXnl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:43:41 -0500
In-Reply-To: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older chips only support DSA tagging. Newer chips have both DSA and
EDSA tagging. Put these two different implementations into functions
which get called from the ops structure.

This results in the helper mv88e6xxx_6065_family() becoming unused, so
remove it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 92 ++++++++++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  6 +++
 drivers/net/dsa/mv88e6xxx/port.c      | 75 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  5 ++
 4 files changed, 133 insertions(+), 45 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 15ea1207b21a..28bd10d95750 100644
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
@@ -2473,41 +2468,20 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
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
+		err = chip->info->ops->cpu_port_config(chip, port);
+		if (err)
+			return err;
 	}
 	if (dsa_is_dsa_port(ds, port)) {
-		if (mv88e6xxx_6095_family(chip) ||
-		    mv88e6xxx_6185_family(chip))
-			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(chip) ||
-		    mv88e6xxx_6351_family(chip) ||
-		    mv88e6xxx_6165_family(chip) ||
-		    mv88e6xxx_6097_family(chip) ||
-		    mv88e6xxx_6320_family(chip)) {
-			reg |= PORT_CONTROL_FRAME_MODE_DSA;
-		}
-
-		if (port == dsa_upstream_port(ds))
-			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
-				PORT_CONTROL_FORWARD_UNKNOWN_MC;
-	}
-	if (reg) {
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+		err = chip->info->ops->dsa_port_config(chip, port);
 		if (err)
 			return err;
 	}
@@ -2607,16 +2581,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
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
 
 	if (chip->info->ops->tag_remap) {
@@ -3181,6 +3145,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -3196,6 +3162,8 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6095_cpu_port_config,
+	.dsa_port_config = mv88e6095_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -3212,6 +3180,8 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -3227,6 +3197,8 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6095_cpu_port_config,
+	.dsa_port_config = mv88e6095_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -3243,6 +3215,8 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -3259,6 +3233,8 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -3276,6 +3252,8 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -3295,6 +3273,8 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3312,6 +3292,8 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3331,6 +3313,8 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3346,6 +3330,8 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6095_cpu_port_config,
+	.dsa_port_config = mv88e6095_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3419,6 +3405,8 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3455,6 +3443,8 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3473,6 +3463,8 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.stats_get_stats = mv88e6320_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3490,6 +3482,8 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3507,6 +3501,8 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3526,6 +3522,8 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.tag_remap = mv88e6095_tag_remap,
 	.monitor_ctrl = mv88e6095_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3544,6 +3542,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
 	.monitor_ctrl = mv88e6390_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3562,6 +3562,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.stats_get_stats = mv88e6390_stats_get_stats,
 	.tag_remap = mv88e6390_tag_remap,
 	.monitor_ctrl = mv88e6390_monitor_ctrl,
+	.cpu_port_config = mv88e6351_cpu_port_config,
+	.dsa_port_config = mv88e6351_dsa_port_config,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a0d0f79a7de8..b846a33c024c 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -123,6 +123,10 @@
 #define PORT_CONTROL_USE_TAG		BIT(4)
 #define PORT_CONTROL_FORWARD_UNKNOWN_MC	BIT(3)
 #define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
+#define PORT_CONTROL_NOT_EGREES_UNKNOWN_DA		(0x0 << 2)
+#define PORT_CONTROL_NOT_EGREES_UNKNOWN_MULTICAST_DA	(0x1 << 2)
+#define PORT_CONTROL_NOT_EGREES_UNKNOWN_UNITCAST_DA	(0x2 << 2)
+#define PORT_CONTROL_EGREES_ALL_UNKNOWN_DA		(0x3 << 2)
 #define PORT_CONTROL_STATE_MASK		0x03
 #define PORT_CONTROL_STATE_DISABLED	0x00
 #define PORT_CONTROL_STATE_BLOCKING	0x01
@@ -821,6 +825,8 @@ struct mv88e6xxx_ops {
 				uint64_t *data);
 	int (*tag_remap)(struct mv88e6xxx_chip *chip, int port);
 	int (*monitor_ctrl)(struct mv88e6xxx_chip *chip, int upstream_port);
+	int (*cpu_port_config)(struct mv88e6xxx_chip *chip, int port);
+	int (*dsa_port_config)(struct mv88e6xxx_chip *chip, int port);
 };
 
 #define STATS_TYPE_PORT		BIT(0)
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index b7fab70f6cd7..a37d7d72df47 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -553,3 +553,78 @@ int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port)
 
 	return 0;
 }
+
+int mv88e6095_cpu_port_config(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg |= PORT_CONTROL_DSA_TAG |
+		PORT_CONTROL_EGRESS_ADD_TAG |
+		PORT_CONTROL_FORWARD_UNKNOWN;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6351_cpu_port_config(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA) {
+		reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
+			PORT_CONTROL_EGRESS_ADD_TAG;
+
+		/* Port Ethertype: use the Ethertype DSA Ethertype
+		 * value.
+		 */
+		err = mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE,
+					   ETH_P_EDSA);
+		if (err)
+			return err;
+	} else {
+		reg |= PORT_CONTROL_FRAME_MODE_DSA;
+	}
+
+	reg |= PORT_CONTROL_EGREES_ALL_UNKNOWN_DA;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6095_dsa_port_config(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg |= PORT_CONTROL_DSA_TAG |
+		PORT_CONTROL_FORWARD_UNKNOWN;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
+
+int mv88e6351_dsa_port_config(struct mv88e6xxx_chip *chip, int port)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
+
+	reg |= PORT_CONTROL_FRAME_MODE_DSA |
+		PORT_CONTROL_EGREES_ALL_UNKNOWN_DA;
+
+	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 99a04cf3d1d6..18070beae35a 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -51,4 +51,9 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 int mv88e6095_tag_remap(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_tag_remap(struct mv88e6xxx_chip *chip, int port);
 
+int mv88e6095_cpu_port_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6351_cpu_port_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6095_dsa_port_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6351_dsa_port_config(struct mv88e6xxx_chip *chip, int port);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
