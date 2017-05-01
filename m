From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 01/18] net: dsa: mv88e6xxx: add max VID to info
Date: Mon,  1 May 2017 14:05:10 -0400
Message-ID: <20170501180527.11756-2-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48240 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdEASHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:07:42 -0400
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some chips don't have a VLAN Table Unit, most of them do have a 4K
table, some others as the 88E6390 family has a 13th bit for the VID.

Add a new max_vid member to the info structure, used to check the
presence of a VTU as well as the value used to iterate from in VTU
GetNext operations.

This makes the MV88E6XXX_FLAG_VTU obsolete, thus remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 38 ++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 13 ++----------
 2 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 44ba8cff5631..e45ddf3e90e8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1440,7 +1440,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	u16 pvid;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!chip->info->max_vid)
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -1478,7 +1478,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		err = cb(&vlan->obj);
 		if (err)
 			break;
-	} while (next.vid < GLOBAL_VTU_VID_MASK);
+	} while (next.vid < chip->info->max_vid);
 
 unlock:
 	mutex_unlock(&chip->reg_lock);
@@ -1640,7 +1640,7 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 			break;
 
 		set_bit(vlan.fid, fid_bitmap);
-	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
+	} while (vlan.vid < chip->info->max_vid);
 
 	/* The reset value 0x000 is used to indicate that multiple address
 	 * databases are not needed. Return the next positive available.
@@ -1799,7 +1799,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		PORT_CONTROL_2_8021Q_DISABLED;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!chip->info->max_vid)
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -1817,7 +1817,7 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!chip->info->max_vid)
 		return -EOPNOTSUPP;
 
 	/* If the requested port doesn't belong to the same bridge as the VLAN
@@ -1860,7 +1860,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!chip->info->max_vid)
 		return;
 
 	mutex_lock(&chip->reg_lock);
@@ -1921,7 +1921,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	u16 pvid, vid;
 	int err = 0;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!chip->info->max_vid)
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -2090,7 +2090,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 				  int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_vtu_entry vlan = {
-		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
+		.vid = chip->info->max_vid,
 	};
 	u16 fid;
 	int err;
@@ -2121,7 +2121,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 						 obj, cb);
 		if (err)
 			return err;
-	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
+	} while (vlan.vid < chip->info->max_vid);
 
 	return err;
 }
@@ -3685,6 +3685,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3702,6 +3703,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3718,6 +3720,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6097/88E6097F",
 		.num_databases = 4096,
 		.num_ports = 11,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3735,6 +3738,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3752,6 +3756,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3768,6 +3773,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -3784,6 +3790,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3801,6 +3808,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3818,6 +3826,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3835,6 +3844,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3852,6 +3862,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3869,6 +3880,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3886,6 +3898,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3953,6 +3966,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -3987,6 +4001,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -4004,6 +4019,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -4020,6 +4036,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6341",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -4036,6 +4053,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -4053,6 +4071,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
@@ -4070,6 +4089,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.max_vid = 4095,
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index c8f54986996b..5695ca206620 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -567,7 +567,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
 #define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
-#define MV88E6XXX_FLAG_VTU		BIT_ULL(MV88E6XXX_CAP_VTU)
 
 /* Ingress Rate Limit unit */
 #define MV88E6XXX_FLAGS_IRL		\
@@ -587,7 +586,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
@@ -598,7 +596,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -610,7 +607,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -618,8 +614,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -627,7 +622,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -638,7 +632,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_SERDES)
@@ -651,7 +644,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -664,7 +656,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_SERDES)
@@ -674,7 +665,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
@@ -686,6 +676,7 @@ struct mv88e6xxx_info {
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned int max_vid;
 	unsigned int port_base_addr;
 	unsigned int global1_addr;
 	unsigned int age_time_coeff;
-- 
2.12.2
