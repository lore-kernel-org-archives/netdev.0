From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: mv88e6xxx: rework jumbo size operation
Date: Thu,  8 Jun 2017 15:04:44 -0400
Message-ID: <20170608190445.24443-7-vivien.didelot@savoirfairelinux.com>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell chips have a Jumbo Mode to set the maximum frame size (MTU).

The mv88e6xxx_ops structure is meant to contain generic functionalities,
no driver logic. Change port_jumbo_config to port_set_jumbo_size setting
the mode from a given maximum size value.

There is no functional changes since we still use 10240 bytes.

At the same time, correctly clear all Jumbo Mode bits before writing.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 38 +++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  3 ++-
 drivers/net/dsa/mv88e6xxx/port.c | 14 ++++++++++++--
 drivers/net/dsa/mv88e6xxx/port.h |  4 +++-
 4 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b2f0ff100f08..87a260aa9120 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1876,8 +1876,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	if (chip->info->ops->port_jumbo_config) {
-		err = chip->info->ops->port_jumbo_config(chip, port);
+	if (chip->info->ops->port_set_jumbo_size) {
+		err = chip->info->ops->port_set_jumbo_size(chip, port, 10240);
 		if (err)
 			return err;
 	}
@@ -2415,7 +2415,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6095_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2471,7 +2471,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.port_set_egress_floods = mv88e6185_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_set_upstream_port = mv88e6095_port_set_upstream_port,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
@@ -2504,7 +2504,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2534,7 +2534,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2588,7 +2588,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2621,7 +2621,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2653,7 +2653,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2686,7 +2686,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2846,7 +2846,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2913,7 +2913,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2944,7 +2944,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -2975,7 +2975,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -3006,7 +3006,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -3037,7 +3037,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -3070,7 +3070,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6097_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
@@ -3104,7 +3104,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_set_cmode = mv88e6390x_port_set_cmode,
@@ -3140,7 +3140,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6390_port_pause_limit,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 0b44df1480d9..747dc2c887df 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -434,7 +434,8 @@ struct mv88e6xxx_ops {
 				      bool unicast, bool multicast);
 	int (*port_set_ether_type)(struct mv88e6xxx_chip *chip, int port,
 				   u16 etype);
-	int (*port_jumbo_config)(struct mv88e6xxx_chip *chip, int port);
+	int (*port_set_jumbo_size)(struct mv88e6xxx_chip *chip, int port,
+				   size_t size);
 
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_limit)(struct mv88e6xxx_chip *chip, int port, u8 in,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index b883b4b0e64b..423b172db4ff 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -816,7 +816,8 @@ int mv88e6xxx_port_set_map_da(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
 }
 
-int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port)
+int mv88e6165_port_set_jumbo_size(struct mv88e6xxx_chip *chip, int port,
+				  size_t size)
 {
 	u16 reg;
 	int err;
@@ -825,7 +826,16 @@ int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	reg |= PORT_CONTROL_2_JUMBO_10240;
+	reg &= ~PORT_CONTROL_2_JUMBO_MASK;
+
+	if (size <= 1522)
+		reg |= PORT_CONTROL_2_JUMBO_1522;
+	else if (size <= 2048)
+		reg |= PORT_CONTROL_2_JUMBO_2048;
+	else if (size <= 10240)
+		reg |= PORT_CONTROL_2_JUMBO_10240;
+	else
+		return -ERANGE;
 
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 7be66f5b4c31..8a59cabc20fa 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -133,6 +133,7 @@
 #define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
 #define PORT_CONTROL_2_SA_PRIO_OVERRIDE	BIT(13)
 #define PORT_CONTROL_2_DA_PRIO_OVERRIDE	BIT(12)
+#define PORT_CONTROL_2_JUMBO_MASK	(0x03 << 12)
 #define PORT_CONTROL_2_JUMBO_1522	(0x00 << 12)
 #define PORT_CONTROL_2_JUMBO_2048	(0x01 << 12)
 #define PORT_CONTROL_2_JUMBO_10240	(0x02 << 12)
@@ -225,7 +226,8 @@ int mv88e6351_port_set_ether_type(struct mv88e6xxx_chip *chip, int port,
 				  u16 etype);
 int mv88e6xxx_port_set_message_port(struct mv88e6xxx_chip *chip, int port,
 				    bool message_port);
-int mv88e6165_port_jumbo_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6165_port_set_jumbo_size(struct mv88e6xxx_chip *chip, int port,
+				  size_t size);
 int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_pause_limit(struct mv88e6xxx_chip *chip, int port, u8 in,
-- 
2.13.1
