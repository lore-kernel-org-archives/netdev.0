From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: move VTU code to its own file
Date: Thu, 16 Feb 2017 22:29:29 -0500
Message-ID: <20170217032931.15002-5-vivien.didelot@savoirfairelinux.com>
References: <20170217032931.15002-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217032931.15002-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the Global (1) VTU related code to its own file.

Use this opportunity to provide a cleaner API for the VTU, by renaming a
few underscore prefixed functions, split the data member of the
mv88e6xxx_vtu_entry structure into membership (for 802.1q) and port
state (for 802.1s) members, and add a mv88e6xxx_has_vtu() helper.

Older chips (such as 6185) stored per VLAN port state data alongside
port membership. Newer chips (such as 6352) use the same data register
layout, but added STU operations to store the VLAN port state data.
Brand new chips (such as 6390) have an STU and changed the data layout.

This commit prepares the addition for VTU ops by providing 6185 and 6352
variant of the VTU operations. Support for new chip can be easily added.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 462 +++++++-------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  10 +
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 372 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |   8 +-
 5 files changed, 482 insertions(+), 371 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 31d37a90cec7..6edd869c8d6f 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -2,5 +2,6 @@ obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
 mv88e6xxx-objs += global1.o
 mv88e6xxx-objs += global1_atu.o
+mv88e6xxx-objs += global1_vtu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b16975d996d9..7010c3313e35 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3,9 +3,6 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2015 CMC Electronics, Inc.
- *	Added support for VLAN Table Unit operations
- *
  * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -1220,169 +1217,44 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
-{
-	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
-}
-
-static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
+static int mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
+				 struct mv88e6xxx_vtu_entry *entry)
 {
 	int err;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
-	if (err)
-		return err;
-
-	return _mv88e6xxx_vtu_wait(chip);
-}
-
-static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
-{
-	int ret;
-
-	ret = _mv88e6xxx_vtu_wait(chip);
-	if (ret < 0)
-		return ret;
-
-	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_FLUSH_ALL);
-}
-
-static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
-					struct mv88e6xxx_vtu_entry *entry,
-					unsigned int nibble_offset)
-{
-	u16 regs[3];
-	int i, err;
-
-	for (i = 0; i < 3; ++i) {
-		u16 *reg = &regs[i];
-
-		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
-		if (err)
-			return err;
-	}
-
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		unsigned int shift = (i % 4) * 4 + nibble_offset;
-		u16 reg = regs[i / 4];
-
-		entry->data[i] = (reg >> shift) & GLOBAL_VTU_STU_DATA_MASK;
-	}
+	if (!mv88e6xxx_has_vtu(chip))
+		return -EOPNOTSUPP;
 
-	return 0;
-}
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU))
+		err = mv88e6352_g1_vtu_getnext(chip, entry);
+	else
+		err = mv88e6185_g1_vtu_getnext(chip, entry);
 
-static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_chip *chip,
-				   struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 0);
+	return err;
 }
 
-static int mv88e6xxx_stu_data_read(struct mv88e6xxx_chip *chip,
+static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 				   struct mv88e6xxx_vtu_entry *entry)
 {
-	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 2);
-}
-
-static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
-					 struct mv88e6xxx_vtu_entry *entry,
-					 unsigned int nibble_offset)
-{
-	u16 regs[3] = { 0 };
-	int i, err;
-
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		unsigned int shift = (i % 4) * 4 + nibble_offset;
-		u8 data = entry->data[i];
-
-		regs[i / 4] |= (data & GLOBAL_VTU_STU_DATA_MASK) << shift;
-	}
-
-	for (i = 0; i < 3; ++i) {
-		u16 reg = regs[i];
-
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
+	int err;
 
-static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 0);
-}
+	if (!mv88e6xxx_has_vtu(chip))
+		return -EOPNOTSUPP;
 
-static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 2);
-}
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU))
+		err = mv88e6352_g1_vtu_loadpurge(chip, entry);
+	else
+		err = mv88e6185_g1_vtu_loadpurge(chip, entry);
 
-static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_chip *chip, u16 vid)
-{
-	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID,
-				  vid & GLOBAL_VTU_VID_MASK);
+	return err;
 }
 
-static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
-				  struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_vtu_flush(struct mv88e6xxx_chip *chip)
 {
-	struct mv88e6xxx_vtu_entry next = { 0 };
-	u16 val;
-	int err;
-
-	err = _mv88e6xxx_vtu_wait(chip);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
-	if (err)
-		return err;
-
-	next.vid = val & GLOBAL_VTU_VID_MASK;
-	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
-
-	if (next.valid) {
-		err = mv88e6xxx_vtu_data_read(chip, &next);
-		if (err)
-			return err;
-
-		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
-			if (err)
-				return err;
-
-			next.fid = val & GLOBAL_VTU_FID_MASK;
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
-			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
-			if (err)
-				return err;
-
-			next.sid = val & GLOBAL_VTU_SID_MASK;
-		}
-	}
+	if (!mv88e6xxx_has_vtu(chip))
+		return 0;
 
-	*entry = next;
-	return 0;
+	return mv88e6xxx_g1_vtu_flush(chip);
 }
 
 static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
@@ -1390,11 +1262,13 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_entry next;
+	struct mv88e6xxx_vtu_entry next = {
+		.vid = 0xfff,
+	};
 	u16 pvid;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -1403,19 +1277,15 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
-	if (err)
-		goto unlock;
-
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &next);
+		err = mv88e6xxx_vtu_getnext(chip, &next);
 		if (err)
 			break;
 
 		if (!next.valid)
 			break;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 			continue;
 
 		/* reinit and dump this VLAN obj */
@@ -1423,7 +1293,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (next.vid == pvid)
@@ -1440,133 +1310,12 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
-	u16 reg = 0;
-	int err;
-
-	err = _mv88e6xxx_vtu_wait(chip);
-	if (err)
-		return err;
-
-	if (!entry->valid)
-		goto loadpurge;
-
-	/* Write port member tags */
-	err = mv88e6xxx_vtu_data_write(chip, entry);
-	if (err)
-		return err;
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-		reg = entry->sid & GLOBAL_VTU_SID_MASK;
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
-		if (err)
-			return err;
-	}
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-		reg = entry->fid & GLOBAL_VTU_FID_MASK;
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, reg);
-		if (err)
-			return err;
-	} else if (mv88e6xxx_num_databases(chip) == 256) {
-		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
-		 * VTU DBNum[3:0] are located in VTU Operation 3:0
-		 */
-		op |= (entry->fid & 0xf0) << 8;
-		op |= entry->fid & 0xf;
-	}
-
-	reg = GLOBAL_VTU_VID_VALID;
-loadpurge:
-	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
-	if (err)
-		return err;
-
-	return _mv88e6xxx_vtu_cmd(chip, op);
-}
-
-static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
-				  struct mv88e6xxx_vtu_entry *entry)
-{
-	struct mv88e6xxx_vtu_entry next = { 0 };
-	u16 val;
-	int err;
-
-	err = _mv88e6xxx_vtu_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID,
-				 sid & GLOBAL_VTU_SID_MASK);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
-	if (err)
-		return err;
-
-	next.sid = val & GLOBAL_VTU_SID_MASK;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
-	if (err)
-		return err;
-
-	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
-
-	if (next.valid) {
-		err = mv88e6xxx_stu_data_read(chip, &next);
-		if (err)
-			return err;
-	}
-
-	*entry = next;
-	return 0;
-}
-
-static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	u16 reg = 0;
-	int err;
-
-	err = _mv88e6xxx_vtu_wait(chip);
-	if (err)
-		return err;
-
-	if (!entry->valid)
-		goto loadpurge;
-
-	/* Write port states */
-	err = mv88e6xxx_stu_data_write(chip, entry);
-	if (err)
-		return err;
-
-	reg = GLOBAL_VTU_VID_VALID;
-loadpurge:
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
-	if (err)
-		return err;
-
-	reg = entry->sid & GLOBAL_VTU_SID_MASK;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
-	if (err)
-		return err;
-
-	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
-}
-
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
-	struct mv88e6xxx_vtu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan = {
+		.vid = 0xfff,
+	};
 	int i, err;
 
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
@@ -1581,12 +1330,8 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	}
 
 	/* Set every FID bit used by the VLAN entries */
-	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
-	if (err)
-		return err;
-
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			return err;
 
@@ -1607,89 +1352,75 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	return mv88e6xxx_atu_flush(chip, *fid);
 }
 
-static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_entry *entry)
+static int mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
+			     struct mv88e6xxx_vtu_entry *entry)
+
 {
-	struct dsa_switch *ds = chip->ds;
-	struct mv88e6xxx_vtu_entry vlan = {
-		.valid = true,
-		.vid = vid,
-	};
 	int i, err;
 
-	err = mv88e6xxx_atu_new(chip, &vlan.fid);
+	/* Initialize a fresh VLAN entry */
+	memset(entry, 0, sizeof(*entry));
+	entry->valid = true;
+	entry->vid = vid;
+
+	/* Chips with STU require an SID, but since 802.1s multiple spanning
+	 * trees are not being used (yet), these bits must remain zero.
+	 */
+	entry->sid = 0;
+
+	err = mv88e6xxx_atu_new(chip, &entry->fid);
 	if (err)
 		return err;
 
 	/* exclude all ports except the CPU and DSA ports */
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
-			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
-			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
-
-	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
-	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip) ||
-	    mv88e6xxx_6341_family(chip)) {
-		struct mv88e6xxx_vtu_entry vstp;
-
-		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
-		 * implemented, only one STU entry is needed to cover all VTU
-		 * entries. Thus, validate the SID 0.
-		 */
-		vlan.sid = 0;
-		err = _mv88e6xxx_stu_getnext(chip, GLOBAL_VTU_SID_MASK, &vstp);
-		if (err)
-			return err;
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		struct dsa_switch *ds = chip->ds;
+		u8 tag;
 
-		if (vstp.sid != vlan.sid || !vstp.valid) {
-			memset(&vstp, 0, sizeof(vstp));
-			vstp.valid = true;
-			vstp.sid = vlan.sid;
+		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
+			tag = GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+		else
+			tag = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
-			err = _mv88e6xxx_stu_loadpurge(chip, &vstp);
-			if (err)
-				return err;
-		}
+		entry->member[i] = tag;
 	}
 
-	*entry = vlan;
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_entry *entry, bool creat)
+static int mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
+			     struct mv88e6xxx_vtu_entry *entry, bool creat)
 {
 	int err;
 
 	if (!vid)
 		return -EINVAL;
 
-	err = _mv88e6xxx_vtu_vid_write(chip, vid - 1);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_vtu_getnext(chip, entry);
+	memset(entry, 0, sizeof(*entry));
+	entry->vid = vid - 1;
+	err = mv88e6xxx_vtu_getnext(chip, entry);
 	if (err)
 		return err;
 
-	if (entry->vid != vid || !entry->valid) {
-		if (!creat)
-			return -EOPNOTSUPP;
-		/* -ENOENT would've been more appropriate, but switchdev expects
-		 * -EOPNOTSUPP to inform bridge about an eventual software VLAN.
-		 */
+	if (entry->vid == vid && entry->valid)
+		return 0;
 
-		err = _mv88e6xxx_vtu_new(chip, vid, entry);
-	}
+	if (creat)
+		return mv88e6xxx_vtu_new(chip, vid, entry);
 
-	return err;
+	/* -ENOENT would've been more appropriate to specify invalid VLAN, but
+	 * switchdev expects -EOPNOTSUPP to point out an eventual software VLAN.
+	 */
+	return -EOPNOTSUPP;
 }
 
 static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan = {
+		.vid = vid_begin - 1,
+	};
 	int i, err;
 
 	if (!vid_begin)
@@ -1697,12 +1428,8 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_vtu_vid_write(chip, vid_begin - 1);
-	if (err)
-		goto unlock;
-
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			goto unlock;
 
@@ -1719,7 +1446,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (!ds->ports[port].netdev)
 				continue;
 
-			if (vlan.data[i] ==
+			if (vlan.member[i] ==
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
@@ -1753,7 +1480,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		PORT_CONTROL_2_8021Q_DISABLED;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -1771,7 +1498,7 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
 	/* If the requested port doesn't belong to the same bridge as the VLAN
@@ -1794,15 +1521,15 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 	struct mv88e6xxx_vtu_entry vlan;
 	int err;
 
-	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, true);
+	err = mv88e6xxx_vtu_get(chip, vid, &vlan, true);
 	if (err)
 		return err;
 
-	vlan.data[port] = untagged ?
+	vlan.member[port] = untagged ?
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
-	return _mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
 }
 
 static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
@@ -1814,7 +1541,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has_vtu(chip))
 		return;
 
 	mutex_lock(&chip->reg_lock);
@@ -1839,15 +1566,15 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
-	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
+	err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
 	/* Tell switchdev if this VLAN is handled in software */
-	if (vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+	if (vlan.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 		return -EOPNOTSUPP;
 
-	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+	vlan.member[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
@@ -1855,13 +1582,13 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
-		if (vlan.data[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+		if (vlan.member[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
 			vlan.valid = true;
 			break;
 		}
 	}
 
-	err = _mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
 	if (err)
 		return err;
 
@@ -1875,7 +1602,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	u16 pvid, vid;
 	int err = 0;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
+	if (!mv88e6xxx_has_vtu(chip))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
@@ -1914,7 +1641,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (vid == 0)
 		err = mv88e6xxx_port_get_fid(chip, port, &vlan.fid);
 	else
-		err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
+		err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -2044,7 +1771,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 				  int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_vtu_entry vlan = {
-		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
+		.vid = 0xfff,
 	};
 	u16 fid;
 	int err;
@@ -2059,12 +1786,8 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	/* Dump VLANs' Filtering Information Databases */
-	err = _mv88e6xxx_vtu_vid_write(chip, vlan.vid);
-	if (err)
-		return err;
-
 	do {
-		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
+		err = mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
 			return err;
 
@@ -2542,11 +2265,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(chip);
-	if (err < 0)
-		return err;
-
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
@@ -2639,6 +2357,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 		if (err)
 			goto unlock;
 	}
+	/* Clear all VLAN entries */
+	err = mv88e6xxx_vtu_flush(chip);
+	if (err)
+		goto unlock;
 
 	/* Clear all ATU entries */
 	err = mv88e6xxx_atu_flush(chip, 0);
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 354119d8e628..11213f50df07 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -47,4 +47,14 @@ int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid,
 int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 			    bool static_too);
 
+int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
+
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
new file mode 100644
index 000000000000..e1046a1b3c6d
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -0,0 +1,372 @@
+/*
+ * Marvell 88E6xxx VLAN [Spanning Tree] Translation Unit (VTU [STU]) support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2015 CMC Electronics, Inc.
+ * Copyright (c) 2017 Savoir-faire Linux, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "mv88e6xxx.h"
+#include "global1.h"
+
+/* Offset 0x02: VTU FID Register */
+
+static int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
+	if (err)
+		return err;
+
+	entry->fid = val & GLOBAL_VTU_FID_MASK;
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->fid & GLOBAL_VTU_FID_MASK;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, val);
+}
+
+/* Offset 0x03: VTU SID Register */
+
+static int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+	if (err)
+		return err;
+
+	entry->sid = val & GLOBAL_VTU_SID_MASK;
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->sid & GLOBAL_VTU_SID_MASK;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, val);
+}
+
+/* Offset 0x05: VTU Operation Register */
+
+static int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
+}
+
+static int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
+{
+	int err;
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_op_wait(chip);
+}
+
+/* Offset 0x06: VTU VID Register */
+
+static int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	if (err)
+		return err;
+
+	entry->vid = val & 0xfff;
+	entry->valid = !!(val & GLOBAL_VTU_VID_VALID);
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->vid & 0xfff;
+
+	if (entry->valid)
+		val |= GLOBAL_VTU_VID_VALID;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, val);
+}
+
+/* Offset 0x07: VTU/STU Data Register 1
+ * Offset 0x08: VTU/STU Data Register 2
+ * Offset 0x09: VTU/STU Data Register 3
+ */
+
+static int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 regs[3];
+	int i;
+
+	/* Read all 3 VTU/STU Data registers */
+	for (i = 0; i < 3; ++i) {
+		u16 *reg = &regs[i];
+		int err;
+
+		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
+	}
+
+	/* Extract MemberTag and PortState data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int member_offset = (i % 4) * 4;
+		unsigned int state_offset = member_offset + 2;
+
+		entry->member[i] = (regs[i / 4] >> member_offset) & 0x3;
+		entry->state[i] = (regs[i / 4] >> state_offset) & 0x3;
+	}
+
+	return 0;
+}
+
+static int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
+				       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 regs[3] = { 0 };
+	int i;
+
+	/* Insert MemberTag and PortState data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int member_offset = (i % 4) * 4;
+		unsigned int state_offset = member_offset + 2;
+
+		regs[i / 4] |= (entry->member[i] & 0x3) << member_offset;
+		regs[i / 4] |= (entry->state[i] & 0x3) << state_offset;
+	}
+
+	/* Write all 3 VTU/STU Data registers */
+	for (i = 0; i < 3; ++i) {
+		u16 reg = regs[i];
+		int err;
+
+		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+/* VLAN Translation Unit Operations */
+
+static int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+				    struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	/* Write the VID to iterate from only once */
+	if (!entry->valid) {
+		err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+		if (err)
+			return err;
+	}
+
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
+}
+
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
+	if (!entry->valid)
+		return 0;
+
+	err = mv88e6185_g1_vtu_data_read(chip, entry);
+	if (err)
+		return err;
+
+	/* VTU DBNum[3:0] are located in VTU Operation 3:0
+	 * VTU DBNum[7:4] are located in VTU Operation 11:8
+	 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_OP, &val);
+	if (err)
+		return err;
+
+	entry->fid = val & 0x000f;
+	entry->fid |= (val & 0x0f00) >> 4;
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
+					struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_sid_read(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
+}
+
+static int mv88e6xxx_g1_vtu_fetch_stu(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_vtu_entry *vtu)
+{
+	struct mv88e6xxx_vtu_entry stu;
+	int err;
+
+	err = mv88e6xxx_g1_vtu_sid_read(chip, vtu);
+	if (err)
+		return err;
+
+	stu.sid = vtu->sid - 1;
+
+	err = mv88e6xxx_g1_vtu_stu_getnext(chip, &stu);
+	if (err)
+		return err;
+
+	if (stu.sid != vtu->sid || !stu.valid)
+		return -EINVAL;
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
+	if (!entry->valid)
+		return 0;
+
+	/* Fetch (and mask) VLAN PortState data from the STU */
+	err = mv88e6xxx_g1_vtu_fetch_stu(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6185_g1_vtu_data_read(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_fid_read(chip, entry);
+}
+
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
+int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 4dac9793a539..2f9a79a2e957 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -728,7 +728,8 @@ struct mv88e6xxx_vtu_entry {
 	u16	fid;
 	u8	sid;
 	bool	valid;
-	u8	data[DSA_MAX_PORTS];
+	u8	member[DSA_MAX_PORTS];
+	u8	state[DSA_MAX_PORTS];
 };
 
 struct mv88e6xxx_bus_ops;
@@ -939,6 +940,11 @@ static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
 	return (chip->info->flags & flags) == flags;
 }
 
+static inline bool mv88e6xxx_has_vtu(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU);
+}
+
 static inline unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->num_databases;
-- 
2.11.1
