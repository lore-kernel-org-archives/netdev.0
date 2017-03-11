From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 09/17] net: dsa: mv88e6xxx: rework ATU Remove
Date: Sat, 11 Mar 2017 16:12:55 -0500
Message-ID: <20170311211303.24560-10-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a fresh documented implementation of the ATU Move operation, and use
it to replace the current ATU Remove operation.

Note that not all Marvell switch chip support the ATU Move operation.
For those supporting it, the number of bits used to mask the destination
port may vary. 6352 and such use 4-bit, while 6390 use 5-bit. Thus add a
new atu_move_port_mask member in the info structure to describe the
presence and variant of ATU Move operation.

Note that the ATU Move operation is not documented in the 6185 datasheet
but the chip does support the operation.

All remaining _mv88e6xxx_atu_* functions are now unused as well as the
MV88E6XXX_FLAG_G1_ATU_FID flag, thus remove them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 140 +++++++-------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |   2 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c |  29 +++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  18 ++--
 4 files changed, 67 insertions(+), 122 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8b8c3cb167c1..a11e5354f14f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1066,11 +1066,6 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
-{
-	return mv88e6xxx_g1_wait(chip, GLOBAL_ATU_OP, GLOBAL_ATU_OP_BUSY);
-}
-
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
@@ -1130,111 +1125,6 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
-{
-	u16 val;
-	int err;
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_ATU_FID)) {
-		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid);
-		if (err)
-			return err;
-	} else if (mv88e6xxx_num_databases(chip) == 256) {
-		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
-		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
-		if (err)
-			return err;
-
-		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL,
-					 (val & 0xfff) | ((fid << 8) & 0xf000));
-		if (err)
-			return err;
-
-		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
-		cmd |= fid & 0xf;
-	}
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_OP, cmd);
-	if (err)
-		return err;
-
-	return _mv88e6xxx_atu_wait(chip);
-}
-
-static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_chip *chip,
-				     struct mv88e6xxx_atu_entry *entry)
-{
-	u16 data = entry->state & GLOBAL_ATU_DATA_STATE_MASK;
-
-	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
-		unsigned int mask, shift;
-
-		if (entry->trunk) {
-			data |= GLOBAL_ATU_DATA_TRUNK;
-			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
-			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
-		} else {
-			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
-			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
-		}
-
-		data |= (entry->portv_trunkid << shift) & mask;
-	}
-
-	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
-}
-
-static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_chip *chip,
-				     struct mv88e6xxx_atu_entry *entry,
-				     bool static_too)
-{
-	int op;
-	int err;
-
-	err = _mv88e6xxx_atu_wait(chip);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_atu_data_write(chip, entry);
-	if (err)
-		return err;
-
-	if (entry->fid) {
-		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB :
-			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
-	} else {
-		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL :
-			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
-	}
-
-	return _mv88e6xxx_atu_cmd(chip, entry->fid, op);
-}
-
-static int _mv88e6xxx_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
-			       int from_port, int to_port, bool static_too)
-{
-	struct mv88e6xxx_atu_entry entry = {
-		.trunk = false,
-		.fid = fid,
-	};
-
-	/* EntryState bits must be 0xF */
-	entry.state = GLOBAL_ATU_DATA_STATE_MASK;
-
-	/* ToPort and FromPort are respectively in PortVec bits 7:4 and 3:0 */
-	entry.portv_trunkid = (to_port & 0x0f) << 4;
-	entry.portv_trunkid |= from_port & 0x0f;
-
-	return _mv88e6xxx_atu_flush_move(chip, &entry, static_too);
-}
-
-static int _mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid,
-				 int port, bool static_too)
-{
-	/* Destination port 0xF means remove the entries */
-	return _mv88e6xxx_atu_move(chip, fid, port, 0x0f, static_too);
-}
-
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -1316,7 +1206,7 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = _mv88e6xxx_atu_remove(chip, 0, port, false);
+	err = mv88e6xxx_g1_atu_remove(chip, 0, port, false);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
@@ -1968,7 +1858,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return _mv88e6xxx_atu_remove(chip, vlan.fid, port, false);
+	return mv88e6xxx_g1_atu_remove(chip, vlan.fid, port, false);
 }
 
 static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
@@ -3688,6 +3578,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6085_ops,
@@ -3703,6 +3594,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 		.ops = &mv88e6095_ops,
@@ -3718,6 +3610,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
@@ -3733,6 +3626,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
@@ -3748,6 +3642,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6131_ops,
@@ -3763,6 +3658,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
@@ -3778,6 +3674,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6165_ops,
@@ -3793,6 +3690,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6171_ops,
@@ -3808,6 +3706,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6172_ops,
@@ -3823,6 +3722,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6175_ops,
@@ -3838,6 +3738,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6176_ops,
@@ -3853,6 +3754,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 		.ops = &mv88e6185_ops,
@@ -3869,6 +3771,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
 	},
@@ -3883,6 +3786,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190x_ops,
@@ -3898,6 +3802,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6391_ops,
@@ -3913,6 +3818,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6240_ops,
@@ -3928,6 +3834,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6290_ops,
@@ -3943,6 +3850,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6320_ops,
@@ -3958,6 +3866,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 		.ops = &mv88e6321_ops,
@@ -3972,6 +3881,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6141_ops,
@@ -3986,6 +3896,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
 		.ops = &mv88e6341_ops,
@@ -4001,6 +3912,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6350_ops,
@@ -4016,6 +3928,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 		.ops = &mv88e6351_ops,
@@ -4031,6 +3944,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0xf,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 		.ops = &mv88e6352_ops,
@@ -4045,6 +3959,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390_ops,
@@ -4059,6 +3974,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
 		.g1_irqs = 9,
+		.atu_move_port_mask = 0x1f,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6390x_ops,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 187acfc8ed37..eece7418e67d 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -46,5 +46,7 @@ int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 			       struct mv88e6xxx_atu_entry *entry);
 int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all);
+int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
+			    bool all);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 7ec9b22feaee..d753e3eb1359 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -269,3 +269,32 @@ int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all)
 
 	return mv88e6xxx_g1_atu_flushmove(chip, fid, &entry, all);
 }
+
+static int mv88e6xxx_g1_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
+				 int from_port, int to_port, bool all)
+{
+	struct mv88e6xxx_atu_entry entry = { 0 };
+	unsigned long mask;
+	int shift;
+
+	if (!chip->info->atu_move_port_mask)
+		return -EOPNOTSUPP;
+
+	mask = chip->info->atu_move_port_mask;
+	shift = bitmap_weight(&mask, 16);
+
+	entry.state = 0xf, /* Full EntryState means Move */
+	entry.portv_trunkid = from_port & mask;
+	entry.portv_trunkid |= (to_port & mask) << shift;
+
+	return mv88e6xxx_g1_atu_flushmove(chip, fid, &entry, all);
+}
+
+int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
+			    bool all)
+{
+	int from_port = port;
+	int to_port = chip->info->atu_move_port_mask;
+
+	return mv88e6xxx_g1_atu_move(chip, fid, from_port, to_port, all);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 45205519b9fe..1fca6fae2f83 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -552,7 +552,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
 
-#define MV88E6XXX_FLAG_G1_ATU_FID	BIT_ULL(MV88E6XXX_CAP_G1_ATU_FID)
 #define MV88E6XXX_FLAG_G1_VTU_FID	BIT_ULL(MV88E6XXX_CAP_G1_VTU_FID)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
@@ -595,8 +594,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_G1_ATU_FID |	\
-	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	(MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
@@ -609,8 +607,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_G1_ATU_FID |	\
-	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	(MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
@@ -642,7 +639,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
@@ -655,8 +651,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_SERDES)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_G1_ATU_FID |	\
-	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	(MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
@@ -670,7 +665,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
@@ -708,11 +702,15 @@ struct mv88e6xxx_info {
 	unsigned int g1_irqs;
 	enum dsa_tag_protocol tag_protocol;
 	unsigned long long flags;
+
+	/* Mask for FromPort and ToPort value of PortVec used in ATU Move
+	 * operation. 0 means that the ATU Move operation is not supported.
+	 */
+	u8 atu_move_port_mask;
 	const struct mv88e6xxx_ops *ops;
 };
 
 struct mv88e6xxx_atu_entry {
-	u16	fid;
 	u8	state;
 	bool	trunk;
 	u16	portv_trunkid;
-- 
2.12.0
