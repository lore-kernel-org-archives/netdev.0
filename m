From: Andrew Lunn <andrew@lunn.ch>
Subject: [[PATCH net-next RFC] 3/4] net: dsa: mv88e6xxx: Move the tagging protocol into info
Date: Thu, 24 Nov 2016 00:43:17 +0100
Message-ID: <1479944598-20372-4-git-send-email-andrew@lunn.ch>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53431 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:43:56 -0500
In-Reply-To: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older chips support a single tagging protocol, DSA. New chips support
both DSA and EDSA, an enhanced version. Having both as an option
changes the register layouts. Up until now, it has been assumed that
if EDSA is supported, it will be used. Hence the register layout has
been determined by which protocol should be used. However, mv88e6390
has a different implementation of EDSA, which requires we need to use
the DSA tagging. Hence separate the selection of the protocol from the
register layout.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 33 +++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 17 ++++-------------
 2 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a6fa3f81e11b..15ea1207b21a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2482,7 +2482,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
 	if (dsa_is_cpu_port(ds, port)) {
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
+		if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
 			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		else
@@ -2611,7 +2611,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA)) {
+		if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA) {
 			err = mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE,
 						   ETH_P_EDSA);
 			if (err)
@@ -3592,6 +3592,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
 	},
@@ -3606,6 +3607,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 		.ops = &mv88e6095_ops,
 	},
@@ -3620,6 +3622,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
 	},
@@ -3634,6 +3637,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6131_ops,
 	},
@@ -3648,6 +3652,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
 	},
@@ -3662,6 +3667,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
 	},
@@ -3676,6 +3682,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
 	},
@@ -3690,6 +3697,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
 	},
@@ -3704,6 +3712,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
 	},
@@ -3718,6 +3727,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
 	},
@@ -3732,6 +3742,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6185_ops,
 	},
@@ -3744,6 +3755,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -3760,6 +3772,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
 	},
@@ -3773,6 +3786,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6391_ops,
 	},
@@ -3787,6 +3802,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
 	},
@@ -3801,6 +3817,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
 	},
@@ -3815,6 +3832,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
 	},
@@ -3829,6 +3847,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6321_ops,
 	},
@@ -3843,6 +3862,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
 	},
@@ -3857,6 +3877,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
 	},
@@ -3871,6 +3892,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
 	},
@@ -3884,6 +3906,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
 	},
@@ -3897,6 +3920,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
 	},
@@ -3997,10 +4021,7 @@ static enum dsa_tag_protocol mv88e6xxx_get_tag_protocol(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
-		return DSA_TAG_PROTO_EDSA;
-
-	return DSA_TAG_PROTO_DSA;
+	return chip->info->tag_protocol;
 }
 
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 6698ec1d22b5..a0d0f79a7de8 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -430,12 +430,6 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
-	/* Two different tag protocols can be used by the driver. All
-	 * switches support DSA, but only later generations support
-	 * EDSA.
-	 */
-	MV88E6XXX_CAP_EDSA,
-
 	/* Energy Efficient Ethernet.
 	 */
 	MV88E6XXX_CAP_EEE,
@@ -498,7 +492,6 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_EDSA		BIT_ULL(MV88E6XXX_CAP_EDSA)
 #define MV88E6XXX_FLAG_EEE		BIT_ULL(MV88E6XXX_CAP_EEE)
 
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
@@ -593,8 +586,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -608,8 +600,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_G1_ATU_FID |	\
+	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
@@ -625,8 +616,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -668,6 +658,7 @@ struct mv88e6xxx_info {
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned int g1_irqs;
+	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
 	const struct mv88e6xxx_ops *ops;
 };
-- 
2.10.2
