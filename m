From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 3/4] net: dsa: mv88e6xxx: Move the tagging protocol into info
Date: Fri,  2 Dec 2016 19:02:58 +0100
Message-ID: <1480701779-30633-4-git-send-email-andrew@lunn.ch>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37973 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751939AbcLBSEK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 13:04:10 -0500
In-Reply-To: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
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
index 6e981bedd028..80efee6f5e16 100644
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
@@ -3637,6 +3637,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
 	},
@@ -3651,6 +3652,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 		.ops = &mv88e6095_ops,
 	},
@@ -3679,6 +3681,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
 	},
@@ -3693,6 +3696,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6131_ops,
 	},
@@ -3707,6 +3711,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
 	},
@@ -3721,6 +3726,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
 	},
@@ -3735,6 +3741,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
 	},
@@ -3749,6 +3756,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
 	},
@@ -3763,6 +3771,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
 	},
@@ -3777,6 +3786,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
 	},
@@ -3791,6 +3801,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6185_ops,
 	},
@@ -3803,6 +3814,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -3819,6 +3831,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
 	},
@@ -3832,6 +3845,8 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
+		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6391_ops,
 	},
@@ -3846,6 +3861,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
 	},
@@ -3860,6 +3876,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
 	},
@@ -3874,6 +3891,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
 	},
@@ -3888,6 +3906,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6321_ops,
 	},
@@ -3902,6 +3921,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
 	},
@@ -3916,6 +3936,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
 	},
@@ -3930,6 +3951,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
 	},
@@ -3943,6 +3965,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
 	},
@@ -3956,6 +3979,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
 	},
@@ -4056,10 +4080,7 @@ static enum dsa_tag_protocol mv88e6xxx_get_tag_protocol(struct dsa_switch *ds)
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
index a6dd192652e8..2c51e3a8a890 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -438,12 +438,6 @@ enum mv88e6xxx_family {
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
@@ -506,7 +500,6 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_EDSA		BIT_ULL(MV88E6XXX_CAP_EDSA)
 #define MV88E6XXX_FLAG_EEE		BIT_ULL(MV88E6XXX_CAP_EEE)
 
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
@@ -601,8 +594,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -616,8 +608,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_G1_ATU_FID |	\
+	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
@@ -633,8 +624,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EDSA |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -676,6 +666,7 @@ struct mv88e6xxx_info {
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned int g1_irqs;
+	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
 	const struct mv88e6xxx_ops *ops;
 };
-- 
2.10.2
