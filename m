From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 13/18] net: dsa: mv88e6xxx: add VTU GetNext operation
Date: Mon,  1 May 2017 14:05:22 -0400
Message-ID: <20170501180527.11756-14-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48406 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751031AbdEASHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:07:47 -0400
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new vtu_getnext operation to the chip info structure to differ the
various implementations of the VTU accesses.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 82 ++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 57 +++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  4 ++
 4 files changed, 99 insertions(+), 48 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fc30a3e3df47..1e14edebc0c7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1238,49 +1238,6 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
-				  struct mv88e6xxx_vtu_entry *entry)
-{
-	struct mv88e6xxx_vtu_entry next = *entry;
-	u16 val;
-	int err;
-
-	err = mv88e6xxx_g1_vtu_getnext(chip, &next);
-	if (err)
-		return err;
-
-	if (next.valid) {
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-			err = mv88e6xxx_g1_vtu_fid_read(chip, &next);
-			if (err)
-				return err;
-		} else if (mv88e6xxx_num_databases(chip) == 256) {
-			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
-			 * VTU DBNum[3:0] are located in VTU Operation 3:0
-			 */
-			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_OP, &val);
-			if (err)
-				return err;
-
-			next.fid = (val & 0xf00) >> 4;
-			next.fid |= val & 0xf;
-		}
-
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-			err = mv88e6xxx_g1_vtu_stu_get(chip, &next);
-			if (err)
-				return err;
-		}
-
-		err = mv88e6185_g1_vtu_data_read(chip, &next);
-		if (err)
-			return err;
-	}
-
-	*entry = next;
-	return 0;
-}
-
 static int mv88e6xxx_vtu_setup(struct mv88e6xxx_chip *chip)
 {
 	if (!chip->info->max_vid)
@@ -1289,6 +1246,15 @@ static int mv88e6xxx_vtu_setup(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_g1_vtu_flush(chip);
 }
 
+static int mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
+				 struct mv88e6xxx_vtu_entry *entry)
+{
+	if (!chip->info->ops->vtu_getnext)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->vtu_getnext(chip, entry);
+}
+
 static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(struct switchdev_obj *obj))
@@ -1310,7 +1276,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &next);
+		err = mv88e6xxx_vtu_getnext(chip, &next);
 		if (err)
 			break;
 
@@ -1410,7 +1376,7 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 
 	/* Set every FID bit used by the VLAN entries */
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			return err;
 
@@ -1467,7 +1433,7 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 	entry->vid = vid - 1;
 	entry->valid = false;
 
-	err = _mv88e6xxx_vtu_getnext(chip, entry);
+	err = mv88e6xxx_vtu_getnext(chip, entry);
 	if (err)
 		return err;
 
@@ -1499,7 +1465,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			goto unlock;
 
@@ -1857,7 +1823,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 
 	/* Dump VLANs' Filtering Information Databases */
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			return err;
 
@@ -2702,6 +2668,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
@@ -2723,6 +2690,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
@@ -2751,6 +2719,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
@@ -2774,6 +2743,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
@@ -2803,6 +2773,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6141_ops = {
@@ -2834,6 +2805,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
@@ -2862,6 +2834,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
@@ -2883,6 +2856,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
@@ -2912,6 +2886,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
@@ -2943,6 +2918,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -2972,6 +2948,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
@@ -3003,6 +2980,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3028,6 +3006,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
 	.reset = mv88e6185_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
@@ -3149,6 +3128,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3209,6 +3189,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -3237,6 +3218,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6341_ops = {
@@ -3268,6 +3250,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -3297,6 +3280,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
@@ -3326,6 +3310,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3357,6 +3342,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 76b49a3a4701..780ee8241dbf 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -74,6 +74,10 @@ int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
 				 struct mv88e6xxx_vtu_entry *vtu);
 int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *vtu);
+int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 710f86fa3b4e..8b07b6b0fc7d 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -245,6 +245,63 @@ int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
 }
 
+int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_vtu_getnext(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->valid) {
+		err = mv88e6185_g1_vtu_data_read(chip, entry);
+		if (err)
+			return err;
+
+		/* VTU DBNum[3:0] are located in VTU Operation 3:0
+		 * VTU DBNum[7:4] are located in VTU Operation 11:8
+		 */
+		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_OP, &val);
+		if (err)
+			return err;
+
+		entry->fid = val & 0x000f;
+		entry->fid |= (val & 0x0f00) >> 4;
+	}
+
+	return 0;
+}
+
+int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	/* Fetch VLAN MemberTag data from the VTU */
+	err = mv88e6xxx_g1_vtu_getnext(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->valid) {
+		/* Fetch (and mask) VLAN PortState data from the STU */
+		err = mv88e6xxx_g1_vtu_stu_get(chip, entry);
+		if (err)
+			return err;
+
+		err = mv88e6185_g1_vtu_data_read(chip, entry);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_fid_read(chip, entry);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
 {
 	int err;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8638892a7e18..b356f2875643 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -890,6 +890,10 @@ struct mv88e6xxx_ops {
 
 	/* Can be either in g1 or g2, so don't use a prefix */
 	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
+
+	/* VLAN Translation Unit operations */
+	int (*vtu_getnext)(struct mv88e6xxx_chip *chip,
+			   struct mv88e6xxx_vtu_entry *entry);
 };
 
 struct mv88e6xxx_irq_ops {
-- 
2.12.2
