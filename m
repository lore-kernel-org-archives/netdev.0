From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/6] net: dsa: mv88e6xxx: move ATU code in its own file
Date: Fri, 17 Feb 2017 10:05:27 -0500
Message-ID: <20170217150531.2181-3-vivien.didelot@savoirfairelinux.com>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the Global (1) ATU related code in its own file, and export the
necessary primitives.

Use that opportunity to provide a cleaner API for the ATU, by renaming a
few underscore prefixed functions, and members of the
mv88e6xxx_atu_entry structures.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 331 +++++---------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |   9 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 245 +++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |   2 +-
 5 files changed, 308 insertions(+), 280 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_atu.c

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index c36be318de1a..31d37a90cec7 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
 mv88e6xxx-objs += global1.o
+mv88e6xxx-objs += global1_atu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 03dc886ed3d6..4809eea933da 100644
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
@@ -1130,122 +1125,6 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
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
-static int _mv88e6xxx_atu_flush(struct mv88e6xxx_chip *chip,
-				u16 fid, bool static_too)
-{
-	struct mv88e6xxx_atu_entry entry = {
-		.fid = fid,
-		.state = 0, /* EntryState bits must be 0 */
-	};
-
-	return _mv88e6xxx_atu_flush_move(chip, &entry, static_too);
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
@@ -1306,13 +1185,35 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		netdev_err(ds->ports[port].netdev, "failed to update state\n");
 }
 
+static int mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip,
+				 struct mv88e6xxx_atu_entry *entry)
+{
+	return mv88e6xxx_g1_atu_getnext(chip, entry);
+}
+
+static int mv88e6xxx_atu_loadpurge(struct mv88e6xxx_chip *chip,
+				   struct mv88e6xxx_atu_entry *entry)
+{
+	return mv88e6xxx_g1_atu_loadpurge(chip, entry);
+}
+
+static int mv88e6xxx_atu_flush(struct mv88e6xxx_chip *chip, u16 fid)
+{
+	return mv88e6xxx_g1_atu_flush(chip, fid, true);
+}
+
+static int mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port)
+{
+	return mv88e6xxx_g1_atu_remove(chip, fid, port, false);
+}
+
 static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = _mv88e6xxx_atu_remove(chip, 0, port, false);
+	err = mv88e6xxx_atu_remove(chip, 0, port);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
@@ -1662,7 +1563,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
+static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_entry vlan;
@@ -1703,7 +1604,7 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 		return -ENOSPC;
 
 	/* Clear the database */
-	return _mv88e6xxx_atu_flush(chip, *fid, true);
+	return mv88e6xxx_atu_flush(chip, *fid);
 }
 
 static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
@@ -1716,7 +1617,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 	};
 	int i, err;
 
-	err = _mv88e6xxx_fid_new(chip, &vlan.fid);
+	err = mv88e6xxx_atu_new(chip, &vlan.fid);
 	if (err)
 		return err;
 
@@ -1964,7 +1865,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return _mv88e6xxx_atu_remove(chip, vlan.fid, port, false);
+	return mv88e6xxx_atu_remove(chip, vlan.fid, port);
 }
 
 static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
@@ -2001,102 +1902,12 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_chip *chip,
-				    const unsigned char *addr)
-{
-	int i, err;
-
-	for (i = 0; i < 3; i++) {
-		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_MAC_01 + i,
-					 (addr[i * 2] << 8) | addr[i * 2 + 1]);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
-static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_chip *chip,
-				   unsigned char *addr)
-{
-	u16 val;
-	int i, err;
-
-	for (i = 0; i < 3; i++) {
-		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_MAC_01 + i, &val);
-		if (err)
-			return err;
-
-		addr[i * 2] = val >> 8;
-		addr[i * 2 + 1] = val & 0xff;
-	}
-
-	return 0;
-}
-
-static int _mv88e6xxx_atu_load(struct mv88e6xxx_chip *chip,
-			       struct mv88e6xxx_atu_entry *entry)
-{
-	int ret;
-
-	ret = _mv88e6xxx_atu_wait(chip);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_atu_mac_write(chip, entry->mac);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_atu_data_write(chip, entry);
-	if (ret < 0)
-		return ret;
-
-	return _mv88e6xxx_atu_cmd(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
-}
-
-static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
-				  struct mv88e6xxx_atu_entry *entry);
-
-static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
-			     const u8 *addr, struct mv88e6xxx_atu_entry *entry)
-{
-	struct mv88e6xxx_atu_entry next;
-	int err;
-
-	memcpy(next.mac, addr, ETH_ALEN);
-	eth_addr_dec(next.mac);
-
-	err = _mv88e6xxx_atu_mac_write(chip, next.mac);
-	if (err)
-		return err;
-
-	do {
-		err = _mv88e6xxx_atu_getnext(chip, fid, &next);
-		if (err)
-			return err;
-
-		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			break;
-
-		if (ether_addr_equal(next.mac, addr)) {
-			*entry = next;
-			return 0;
-		}
-	} while (ether_addr_greater(addr, next.mac));
-
-	memset(entry, 0, sizeof(*entry));
-	entry->fid = fid;
-	ether_addr_copy(entry->mac, addr);
-
-	return 0;
-}
-
 static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 					const unsigned char *addr, u16 vid,
 					u8 state)
 {
+	struct mv88e6xxx_atu_entry entry = { 0 };
 	struct mv88e6xxx_vtu_entry vlan;
-	struct mv88e6xxx_atu_entry entry;
 	int err;
 
 	/* Null VLAN ID corresponds to the port private database */
@@ -2107,21 +1918,32 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_atu_get(chip, vlan.fid, addr, &entry);
+	entry.fid = vlan.fid;
+	ether_addr_copy(entry.mac, addr);
+	eth_addr_dec(entry.mac);
+	err = mv88e6xxx_atu_getnext(chip, &entry);
 	if (err)
 		return err;
 
+	/* Initialize a fresh ATU entry if it isn't found */
+	if (entry.state == GLOBAL_ATU_DATA_STATE_UNUSED ||
+	    !ether_addr_equal(entry.mac, addr)) {
+		memset(&entry, 0, sizeof(entry));
+		ether_addr_copy(entry.mac, addr);
+		entry.fid = vlan.fid;
+	}
+
 	/* Purge the ATU entry only if no port is using it anymore */
 	if (state == GLOBAL_ATU_DATA_STATE_UNUSED) {
-		entry.portv_trunkid &= ~BIT(port);
-		if (!entry.portv_trunkid)
+		entry.portvec &= ~BIT(port);
+		if (!entry.portvec)
 			entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
 	} else {
-		entry.portv_trunkid |= BIT(port);
+		entry.portvec |= BIT(port);
 		entry.state = state;
 	}
 
-	return _mv88e6xxx_atu_load(chip, &entry);
+	return mv88e6xxx_atu_loadpurge(chip, &entry);
 }
 
 static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
@@ -2161,52 +1983,6 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
-				  struct mv88e6xxx_atu_entry *entry)
-{
-	struct mv88e6xxx_atu_entry next = { 0 };
-	u16 val;
-	int err;
-
-	next.fid = fid;
-
-	err = _mv88e6xxx_atu_wait(chip);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_atu_cmd(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_atu_mac_read(chip, next.mac);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_DATA, &val);
-	if (err)
-		return err;
-
-	next.state = val & GLOBAL_ATU_DATA_STATE_MASK;
-	if (next.state != GLOBAL_ATU_DATA_STATE_UNUSED) {
-		unsigned int mask, shift;
-
-		if (val & GLOBAL_ATU_DATA_TRUNK) {
-			next.trunk = true;
-			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
-			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
-		} else {
-			next.trunk = false;
-			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
-			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
-		}
-
-		next.portv_trunkid = (val & mask) >> shift;
-	}
-
-	*entry = next;
-	return 0;
-}
-
 static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 				      u16 fid, u16 vid, int port,
 				      struct switchdev_obj *obj,
@@ -2214,22 +1990,19 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 {
 	struct mv88e6xxx_atu_entry addr = {
 		.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
+		.fid = fid,
 	};
 	int err;
 
-	err = _mv88e6xxx_atu_mac_write(chip, addr.mac);
-	if (err)
-		return err;
-
 	do {
-		err = _mv88e6xxx_atu_getnext(chip, fid, &addr);
+		err = mv88e6xxx_atu_getnext(chip, &addr);
 		if (err)
 			return err;
 
 		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			break;
 
-		if (addr.trunk || (addr.portv_trunkid & BIT(port)) == 0)
+		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
 			continue;
 
 		if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
@@ -2787,11 +2560,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Clear all ATU entries */
-	err = _mv88e6xxx_atu_flush(chip, 0, true);
-	if (err)
-		return err;
-
 	/* Configure the IP ToS mapping registers. */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
@@ -2872,6 +2640,11 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	/* Clear all ATU entries */
+	err = mv88e6xxx_atu_flush(chip, 0);
+	if (err)
+		goto unlock;
+
 	/* Some generations have the configuration of sending reserved
 	 * management frames to the CPU in global2, others in
 	 * global1. Hence it does not fit the two setup functions
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 1aec7382c02d..354119d8e628 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -38,4 +38,13 @@ int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
+int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_atu_entry *entry);
+int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_atu_entry *entry);
+int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid,
+			   bool static_too);
+int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
+			    bool static_too);
+
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
new file mode 100644
index 000000000000..4758a68f88ea
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -0,0 +1,245 @@
+/*
+ * Marvell 88E6xxx Address Translation Unit (ATU) support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
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
+/* Offset 0x01: ATU FID Register
+ * Offset 0x0A: ATU Control Register
+ * Offset 0x0B: ATU Operation Register
+ */
+
+static int mv88e6xxx_g1_atu_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_wait(chip, GLOBAL_ATU_OP, GLOBAL_ATU_OP_BUSY);
+}
+
+static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
+{
+	u16 val;
+	int err;
+
+	/* FID bits are dispatched all around gradually as more are supported */
+	if (mv88e6xxx_num_databases(chip) > 256) {
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid);
+		if (err)
+			return err;
+	} else {
+		if (mv88e6xxx_num_databases(chip) > 16) {
+			/* ATU DBNum[7:4] are located in ATU Control 15:12 */
+			err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+			if (err)
+				return err;
+
+			val = (val & 0x0fff) | ((fid << 8) & 0xf000);
+			err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+			if (err)
+				return err;
+		}
+
+		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
+		op |= fid & 0xf;
+	}
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_OP, op);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_atu_wait(chip);
+}
+
+/* Offset 0x0C: ATU Data Register */
+
+static int mv88e6xxx_g1_atu_data_read(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_atu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_DATA, &val);
+	if (err)
+		return err;
+
+	entry->state = val & 0xf;
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		if (val & GLOBAL_ATU_DATA_TRUNK)
+			entry->trunk = true;
+
+		entry->portvec = (val >> 4) & mv88e6xxx_port_mask(chip);
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
+				       struct mv88e6xxx_atu_entry *entry)
+{
+	u16 data = entry->state & 0xf;
+
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		if (entry->trunk)
+			data |= GLOBAL_ATU_DATA_TRUNK;
+
+		data |= (entry->portvec & mv88e6xxx_port_mask(chip)) << 4;
+	}
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
+}
+
+/* Offset 0x0D: ATU MAC Address Register Bytes 0 & 1
+ * Offset 0x0E: ATU MAC Address Register Bytes 2 & 3
+ * Offset 0x0F: ATU MAC Address Register Bytes 4 & 5
+ */
+
+static int mv88e6xxx_g1_atu_mac_read(struct mv88e6xxx_chip *chip,
+				     struct mv88e6xxx_atu_entry *entry)
+{
+	u16 val;
+	int i, err;
+
+	for (i = 0; i < 3; i++) {
+		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_MAC_01 + i, &val);
+		if (err)
+			return err;
+
+		entry->mac[i * 2] = val >> 8;
+		entry->mac[i * 2 + 1] = val & 0xff;
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_g1_atu_mac_write(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_atu_entry *entry)
+{
+	u16 val;
+	int i, err;
+
+	for (i = 0; i < 3; i++) {
+		val = (entry->mac[i * 2] << 8) | entry->mac[i * 2 + 1];
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_MAC_01 + i, val);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+/* Address Translation Unit operations */
+
+int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_atu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_atu_wait(chip);
+	if (err)
+		return err;
+
+	/* Write the MAC address to iterate from only once */
+	if (entry->state == GLOBAL_ATU_DATA_STATE_UNUSED) {
+		err = mv88e6xxx_g1_atu_mac_write(chip, entry);
+		if (err)
+			return err;
+	}
+
+	err = mv88e6xxx_g1_atu_op(chip, entry->fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_data_read(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_atu_mac_read(chip, entry);
+}
+
+int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_atu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_atu_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_mac_write(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_data_write(chip, entry);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_atu_op(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
+}
+
+static int mv88e6xxx_g1_atu_flushmove(struct mv88e6xxx_chip *chip,
+				      struct mv88e6xxx_atu_entry *entry,
+				      bool static_too)
+{
+	int op;
+	int err;
+
+	err = mv88e6xxx_g1_atu_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_data_write(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->fid) {
+		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB :
+			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
+	} else {
+		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL :
+			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
+	}
+
+	return mv88e6xxx_g1_atu_op(chip, entry->fid, op);
+}
+
+int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid,
+			   bool static_too)
+{
+	struct mv88e6xxx_atu_entry entry = {
+		.fid = fid,
+		.state = 0, /* Null EntryState means Flush */
+	};
+
+	return mv88e6xxx_g1_atu_flushmove(chip, &entry, static_too);
+}
+
+static int mv88e6xxx_g1_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
+				 int from_port, int to_port, bool static_too)
+{
+	struct mv88e6xxx_atu_entry entry = { 0 };
+	unsigned long mask = 0xf;
+	int shift = bitmap_weight(&mask, 16);
+
+	entry.fid = fid,
+	entry.state = 0xf, /* Full EntryState means Move */
+	entry.portvec = from_port & mask;
+	entry.portvec |= (to_port & mask) << shift;
+
+	return mv88e6xxx_g1_atu_flushmove(chip, &entry, static_too);
+}
+
+int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
+			    bool static_too)
+{
+	int from_port = port;
+	int to_port = 0xf;
+
+	return mv88e6xxx_g1_atu_move(chip, fid, from_port, to_port, static_too);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 166b513ff751..93a686819d17 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -714,7 +714,7 @@ struct mv88e6xxx_atu_entry {
 	u16	fid;
 	u8	state;
 	bool	trunk;
-	u16	portv_trunkid;
+	u16	portvec;
 	u8	mac[ETH_ALEN];
 };
 
-- 
2.11.1
