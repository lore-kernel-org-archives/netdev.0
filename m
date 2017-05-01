From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 14/18] net: dsa: mv88e6xxx: add VTU Load/Purge operation
Date: Mon,  1 May 2017 14:05:23 -0400
Message-ID: <20170501180527.11756-15-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new vtu_loadpurge operation to the chip info structure to differ
the various implementations of the VTU accesses.

Now that the STU handling is abstracted behind VTU operations, kill the
obsolete MV88E6XXX_FLAG_STU flag.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 80 +++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 66 +++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   | 10 +----
 4 files changed, 103 insertions(+), 57 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1e14edebc0c7..51c8b2ff9760 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1255,6 +1255,15 @@ static int mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return chip->info->ops->vtu_getnext(chip, entry);
 }
 
+static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+				   struct mv88e6xxx_vtu_entry *entry)
+{
+	if (!chip->info->ops->vtu_loadpurge)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->vtu_loadpurge(chip, entry);
+}
+
 static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(struct switchdev_obj *obj))
@@ -1308,53 +1317,6 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
-	int err;
-
-	err = mv88e6xxx_g1_vtu_op_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
-	if (err)
-		return err;
-
-	if (!entry->valid)
-		goto loadpurge;
-
-	/* Write port member tags */
-	err = mv88e6185_g1_vtu_data_write(chip, entry);
-	if (err)
-		return err;
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-		err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
-		if (err)
-			return err;
-
-		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
-		if (err)
-			return err;
-	}
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-		err = mv88e6xxx_g1_vtu_fid_write(chip, entry);
-		if (err)
-			return err;
-	} else if (mv88e6xxx_num_databases(chip) == 256) {
-		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
-		 * VTU DBNum[3:0] are located in VTU Operation 3:0
-		 */
-		op |= (entry->fid & 0xf0) << 8;
-		op |= entry->fid & 0xf;
-	}
-loadpurge:
-	return mv88e6xxx_g1_vtu_op(chip, op);
-}
-
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
@@ -1565,7 +1527,7 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
-	return _mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
 }
 
 static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
@@ -1624,7 +1586,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 		}
 	}
 
-	err = _mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
 	if (err)
 		return err;
 
@@ -2669,6 +2631,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -2691,6 +2654,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -2720,6 +2684,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -2744,6 +2709,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -2774,6 +2740,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6141_ops = {
@@ -2806,6 +2773,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -2835,6 +2803,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -2857,6 +2826,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -2887,6 +2857,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -2919,6 +2890,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -2949,6 +2921,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -2981,6 +2954,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3007,6 +2981,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3129,6 +3104,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3190,6 +3166,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3219,6 +3196,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6341_ops = {
@@ -3251,6 +3229,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3281,6 +3260,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3311,6 +3291,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3343,6 +3324,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 780ee8241dbf..60dd7079c756 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -76,8 +76,12 @@ int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *vtu);
 int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 8b07b6b0fc7d..73e08c5c3948 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -302,6 +302,72 @@ int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->valid) {
+		err = mv88e6185_g1_vtu_data_write(chip, entry);
+		if (err)
+			return err;
+
+		/* VTU DBNum[3:0] are located in VTU Operation 3:0
+		 * VTU DBNum[7:4] are located in VTU Operation 11:8
+		 */
+		op |= entry->fid & 0x000f;
+		op |= (entry->fid & 0x00f0) << 8;
+	}
+
+	return mv88e6xxx_g1_vtu_op(chip, op);
+}
+
+int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->valid) {
+		/* Write MemberTag and PortState data */
+		err = mv88e6185_g1_vtu_data_write(chip, entry);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
+		if (err)
+			return err;
+
+		/* Load STU entry */
+		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_fid_write(chip, entry);
+		if (err)
+			return err;
+	}
+
+	/* Load/Purge VTU entry */
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
 {
 	int err;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index b356f2875643..a0d57b10acfe 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -566,8 +566,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_IRL_DATA	BIT_ULL(MV88E6XXX_CAP_G2_IRL_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
-#define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
-
 /* Ingress Rate Limit unit */
 #define MV88E6XXX_FLAGS_IRL		\
 	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
@@ -595,7 +593,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -606,7 +603,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -631,7 +627,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_SERDES)
@@ -643,7 +638,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -655,7 +649,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_SERDES)
@@ -664,7 +657,6 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |        \
-	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -894,6 +886,8 @@ struct mv88e6xxx_ops {
 	/* VLAN Translation Unit operations */
 	int (*vtu_getnext)(struct mv88e6xxx_chip *chip,
 			   struct mv88e6xxx_vtu_entry *entry);
+	int (*vtu_loadpurge)(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
 };
 
 struct mv88e6xxx_irq_ops {
-- 
2.12.2
