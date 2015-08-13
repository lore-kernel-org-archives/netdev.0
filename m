From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/7] net: dsa: mv88e6xxx: add VLAN Purge support
Date: Thu, 13 Aug 2015 12:52:21 -0400
Message-ID: <1439484743-5126-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the VTU Load Purge operation and implement the
port_vlan_del driver function to remove a port from a VLAN entry, and
delete the VLAN if the given port was its last member.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 113 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |   2 +
 3 files changed, 116 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e6767ce..cec38bb 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -344,6 +344,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6c86bad..8423924 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1254,6 +1254,32 @@ static int _mv88e6xxx_vtu_stu_data_read(struct dsa_switch *ds,
 	return 0;
 }
 
+static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
+					 struct mv88e6xxx_vtu_stu_entry *entry,
+					 unsigned int nibble_offset)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 regs[3] = { 0 };
+	int i;
+	int ret;
+
+	for (i = 0; i < ps->num_ports; ++i) {
+		unsigned int shift = (i % 4) * 4 + nibble_offset;
+		u8 data = entry->data[i];
+
+		regs[i / 4] |= (data & GLOBAL_VTU_STU_DATA_MASK) << shift;
+	}
+
+	for (i = 0; i < 3; ++i) {
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL,
+					   GLOBAL_VTU_DATA_0_3 + i, regs[i]);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
 static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
@@ -1307,6 +1333,93 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
+static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
+				    struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	u16 reg = 0;
+	int ret;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (!entry->valid)
+		goto loadpurge;
+
+	/* Write port member tags */
+	ret = _mv88e6xxx_vtu_stu_data_write(ds, entry, 0);
+	if (ret < 0)
+		return ret;
+
+	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+		reg = entry->sid & GLOBAL_VTU_SID_MASK;
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+		if (ret < 0)
+			return ret;
+
+		reg = entry->fid & GLOBAL_VTU_FID_MASK;
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID, reg);
+		if (ret < 0)
+			return ret;
+	}
+
+	reg = GLOBAL_VTU_VID_VALID;
+loadpurge:
+	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry vlan;
+	bool keep = false;
+	int i, err;
+
+	mutex_lock(&ps->smi_mutex);
+
+	err = _mv88e6xxx_vtu_getnext(ds, vid - 1, &vlan);
+	if (err)
+		goto unlock;
+
+	if (vlan.vid != vid || !vlan.valid ||
+	    vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+		err = -ENOENT;
+		goto unlock;
+	}
+
+	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+
+	/* keep the VLAN unless all ports are excluded */
+	for (i = 0; i < ps->num_ports; ++i) {
+		if (dsa_is_cpu_port(ds, i))
+			continue;
+
+		if (vlan.data[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+			keep = true;
+			break;
+		}
+	}
+
+	vlan.valid = keep;
+	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+	if (err)
+		goto unlock;
+
+	if (!keep)
+		clear_bit(vlan.fid, ps->fid_bitmap);
+
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
 static int _mv88e6xxx_port_vtu_getnext(struct dsa_switch *ds, int port, u16 vid,
 				       struct mv88e6xxx_vtu_stu_entry *entry)
 {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index bb6fa9a..c70a3c1 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -195,6 +195,7 @@
 #define GLOBAL_VTU_OP		0x05
 #define GLOBAL_VTU_OP_BUSY	BIT(15)
 #define GLOBAL_VTU_OP_FLUSH_ALL		((0x01 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_VTU_LOAD_PURGE	((0x03 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_OP_VTU_GET_NEXT	((0x04 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
 #define GLOBAL_VTU_VID_MASK	0xfff
@@ -453,6 +454,7 @@ int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *vid);
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid);
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged);
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-- 
2.5.0
