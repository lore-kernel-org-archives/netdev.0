From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 02/18] net: dsa: mv88e6xxx: split VTU entry data member
Date: Mon,  1 May 2017 14:05:11 -0400
Message-ID: <20170501180527.11756-3-vivien.didelot@savoirfairelinux.com>
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

VLAN aware Marvell chips can program 802.1Q VLAN membership as well as
802.1s per VLAN Spanning Tree state using the same 3 VTU Data registers.

Some chips such as 88E6185 use different Data registers offsets for
ports state and membership, and program them in a single operation.

Other chips such as 88E6352 use the same register layout but program
them in distinct operations (an indirect table is used for 802.1s.)

Newer chips such as 88E6390 use the same offsets for both state and
membership in distinct operations, thus require multiple data accesses.

To correctly abstract this, split the "data" structure member of
mv88e6xxx_vtu_entry in two "state" and "member" members, before adding
VTU support for newer chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 21 +++++++++++----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  3 ++-
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e45ddf3e90e8..f025d3c22dba 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1312,7 +1312,7 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u16 reg = regs[i / 4];
 
-		entry->data[i] = (reg >> shift) & GLOBAL_VTU_STU_DATA_MASK;
+		entry->state[i] = (reg >> shift) & GLOBAL_VTU_STU_DATA_MASK;
 	}
 
 	return 0;
@@ -1339,7 +1339,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
-		u8 data = entry->data[i];
+		u8 data = entry->state[i];
 
 		regs[i / 4] |= (data & GLOBAL_VTU_STU_DATA_MASK) << shift;
 	}
@@ -1461,7 +1461,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		if (!next.valid)
 			break;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 			continue;
 
 		/* reinit and dump this VLAN obj */
@@ -1469,7 +1469,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
-		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (next.vid == pvid)
@@ -1669,7 +1669,8 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 
 	/* exclude all ports except the CPU and DSA ports */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
+		vlan.member[i] = dsa_is_cpu_port(ds, i) ||
+			dsa_is_dsa_port(ds, i)
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
@@ -1765,7 +1766,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (!ds->ports[port].netdev)
 				continue;
 
-			if (vlan.data[i] ==
+			if (vlan.member[i] ==
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
@@ -1844,7 +1845,7 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	vlan.data[port] = untagged ?
+	vlan.member[port] = untagged ?
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
@@ -1890,10 +1891,10 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 		return err;
 
 	/* Tell switchdev if this VLAN is handled in software */
-	if (vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+	if (vlan.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 		return -EOPNOTSUPP;
 
-	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+	vlan.member[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
@@ -1901,7 +1902,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
-		if (vlan.data[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+		if (vlan.member[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
 			vlan.valid = true;
 			break;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 5695ca206620..8638892a7e18 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -704,7 +704,8 @@ struct mv88e6xxx_vtu_entry {
 	u16	fid;
 	u8	sid;
 	bool	valid;
-	u8	data[DSA_MAX_PORTS];
+	u8	member[DSA_MAX_PORTS];
+	u8	state[DSA_MAX_PORTS];
 };
 
 struct mv88e6xxx_bus_ops;
-- 
2.12.2
