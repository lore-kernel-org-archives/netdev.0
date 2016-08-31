From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/3] net: dsa: mv88e6xxx: make switchdev DB ops generic
Date: Wed, 31 Aug 2016 11:50:04 -0400
Message-ID: <20160831155005.2569-3-vivien.didelot@savoirfairelinux.com>
References: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MDB support for the mv88e6xxx driver will be very similar to the FDB
support, since it consists of loading/purging/dumping address to/from
the Address Translation Unit (ATU).

Prepare the support for MDB by making the FDB code accessing the ATU
generic. The FDB operations now provide access to the unicast addresses
while the MDB operations will provide access to the multicast addresses.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 100 ++++++++++++++++++++++-----------------
 1 file changed, 57 insertions(+), 43 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4e697ee..acb3167 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2093,9 +2093,9 @@ static int _mv88e6xxx_atu_load(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_atu_cmd(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
-static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_chip *chip, int port,
-				    const unsigned char *addr, u16 vid,
-				    u8 state)
+static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
+					const unsigned char *addr, u16 vid,
+					u8 state)
 {
 	struct mv88e6xxx_atu_entry entry = { 0 };
 	struct mv88e6xxx_vtu_stu_entry vlan;
@@ -2134,15 +2134,12 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_fdb *fdb,
 				   struct switchdev_trans *trans)
 {
-	int state = is_multicast_ether_addr(fdb->addr) ?
-		GLOBAL_ATU_DATA_STATE_MC_STATIC :
-		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
 	mutex_lock(&chip->reg_lock);
-	if (_mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid, state))
-		netdev_err(ds->ports[port].netdev,
-			   "failed to load MAC address\n");
+	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
+					 GLOBAL_ATU_DATA_STATE_UC_STATIC))
+		netdev_err(ds->ports[port].netdev, "failed to load unicast MAC address\n");
 	mutex_unlock(&chip->reg_lock);
 }
 
@@ -2150,14 +2147,14 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 				  const struct switchdev_obj_port_fdb *fdb)
 {
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
+	int err;
 
 	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid,
-				       GLOBAL_ATU_DATA_STATE_UNUSED);
+	err = mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
+					   GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&chip->reg_lock);
 
-	return ret;
+	return err;
 }
 
 static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
@@ -2205,10 +2202,10 @@ static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 	return 0;
 }
 
-static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_chip *chip,
-					u16 fid, u16 vid, int port,
-					struct switchdev_obj_port_fdb *fdb,
-					int (*cb)(struct switchdev_obj *obj))
+static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
+				      u16 fid, u16 vid, int port,
+				      struct switchdev_obj *obj,
+				      int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_atu_entry addr = {
 		.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
@@ -2222,72 +2219,89 @@ static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_chip *chip,
 	do {
 		err = _mv88e6xxx_atu_getnext(chip, fid, &addr);
 		if (err)
-			break;
+			return err;
 
 		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			break;
 
-		if (!addr.trunk && addr.portv_trunkid & BIT(port)) {
-			bool is_static = addr.state ==
-				(is_multicast_ether_addr(addr.mac) ?
-				 GLOBAL_ATU_DATA_STATE_MC_STATIC :
-				 GLOBAL_ATU_DATA_STATE_UC_STATIC);
+		if (addr.trunk || (addr.portv_trunkid & BIT(port)) == 0)
+			continue;
+
+		if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
+			struct switchdev_obj_port_fdb *fdb;
 
+			if (!is_unicast_ether_addr(addr.mac))
+				continue;
+
+			fdb = SWITCHDEV_OBJ_PORT_FDB(obj);
 			fdb->vid = vid;
 			ether_addr_copy(fdb->addr, addr.mac);
-			fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
-
-			err = cb(&fdb->obj);
-			if (err)
-				break;
+			if (addr.state == GLOBAL_ATU_DATA_STATE_UC_STATIC)
+				fdb->ndm_state = NUD_NOARP;
+			else
+				fdb->ndm_state = NUD_REACHABLE;
+		} else {
+			return -EOPNOTSUPP;
 		}
+
+		err = cb(obj);
+		if (err)
+			return err;
 	} while (!is_broadcast_ether_addr(addr.mac));
 
 	return err;
 }
 
-static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
-				   struct switchdev_obj_port_fdb *fdb,
-				   int (*cb)(struct switchdev_obj *obj))
+static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
+				  struct switchdev_obj *obj,
+				  int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan = {
 		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
 	};
 	u16 fid;
 	int err;
 
-	mutex_lock(&chip->reg_lock);
-
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
 	err = _mv88e6xxx_port_fid_get(chip, port, &fid);
 	if (err)
-		goto unlock;
+		return err;
 
-	err = _mv88e6xxx_port_fdb_dump_one(chip, fid, 0, port, fdb, cb);
+	err = mv88e6xxx_port_db_dump_fid(chip, fid, 0, port, obj, cb);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Dump VLANs' Filtering Information Databases */
 	err = _mv88e6xxx_vtu_vid_write(chip, vlan.vid);
 	if (err)
-		goto unlock;
+		return err;
 
 	do {
 		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
-			break;
+			return err;
 
 		if (!vlan.valid)
 			break;
 
-		err = _mv88e6xxx_port_fdb_dump_one(chip, vlan.fid, vlan.vid,
-						   port, fdb, cb);
+		err = mv88e6xxx_port_db_dump_fid(chip, vlan.fid, vlan.vid, port,
+						 obj, cb);
 		if (err)
-			break;
+			return err;
 	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
 
-unlock:
+	return err;
+}
+
+static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
+				   struct switchdev_obj_port_fdb *fdb,
+				   int (*cb)(struct switchdev_obj *obj))
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_port_db_dump(chip, port, &fdb->obj, cb);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
-- 
2.9.3
