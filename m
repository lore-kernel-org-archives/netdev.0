From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/14] net: dsa: mv88e6xxx: rework ATU GetNext
Date: Thu,  9 Mar 2017 18:33:15 -0500
Message-ID: <20170309233324.18539-6-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add and use a fresh documented implementation of the ATU GetNext.

Since it is not necessary to write the MAC address to iterate from, only
do it once directly in the ATU GetNext operation, if the provided ATU
entry structure is not valid. This makes the user code simpler.

Also, there is no need to loop when getting a single ATU entry. So
remove the mv88e6xxx_atu_get helper and add a simpler snippet in
mv88e6xxx_port_db_load_purge to lookup a given MAC address.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 140 ++++----------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |   2 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c |  66 +++++++++++++++
 3 files changed, 84 insertions(+), 124 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index eceb9b61679e..d055ab94066b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2014,76 +2014,6 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
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
@@ -2100,10 +2030,21 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_atu_get(chip, vlan.fid, addr, &entry);
+	entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+	ether_addr_copy(entry.mac, addr);
+	eth_addr_dec(entry.mac);
+
+	err = mv88e6xxx_g1_atu_getnext(chip, vlan.fid, &entry);
 	if (err)
 		return err;
 
+	/* Initialize a fresh ATU entry if it isn't found */
+	if (entry.state == GLOBAL_ATU_DATA_STATE_UNUSED ||
+	    !ether_addr_equal(entry.mac, addr)) {
+		memset(&entry, 0, sizeof(entry));
+		ether_addr_copy(entry.mac, addr);
+	}
+
 	/* Purge the ATU entry only if no port is using it anymore */
 	if (state == GLOBAL_ATU_DATA_STATE_UNUSED) {
 		entry.portv_trunkid &= ~BIT(port);
@@ -2154,68 +2095,19 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
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
 				      int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_atu_entry addr = {
-		.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
-	};
+	struct mv88e6xxx_atu_entry addr;
 	int err;
 
-	err = _mv88e6xxx_atu_mac_write(chip, addr.mac);
-	if (err)
-		return err;
+	addr.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+	eth_broadcast_addr(addr.mac);
 
 	do {
-		err = _mv88e6xxx_atu_getnext(chip, fid, &addr);
+		err = mv88e6xxx_g1_atu_getnext(chip, fid, &addr);
 		if (err)
 			return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 2c03f2e04639..8dd8ecc9f064 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -41,6 +41,8 @@ int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all);
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs);
+int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
+			     struct mv88e6xxx_atu_entry *entry);
 int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 			       struct mv88e6xxx_atu_entry *entry);
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 09190559178b..94e940522849 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -109,6 +109,27 @@ static int mv88e6xxx_g1_atu_op(struct mv88e6xxx_chip *chip, u16 fid, u16 op)
 
 /* Offset 0x0C: ATU Data Register */
 
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
+		entry->portv_trunkid = (val >> 4) & mv88e6xxx_port_mask(chip);
+	}
+
+	return 0;
+}
+
 static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
 				       struct mv88e6xxx_atu_entry *entry)
 {
@@ -129,6 +150,24 @@ static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
  * Offset 0x0F: ATU MAC Address Register Bytes 4 & 5
  */
 
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
 static int mv88e6xxx_g1_atu_mac_write(struct mv88e6xxx_chip *chip,
 				      struct mv88e6xxx_atu_entry *entry)
 {
@@ -147,6 +186,33 @@ static int mv88e6xxx_g1_atu_mac_write(struct mv88e6xxx_chip *chip,
 
 /* Address Translation Unit operations */
 
+int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
+			     struct mv88e6xxx_atu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_atu_op_wait(chip);
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
+	err = mv88e6xxx_g1_atu_op(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
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
 int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 			       struct mv88e6xxx_atu_entry *entry)
 {
-- 
2.12.0
