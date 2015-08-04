From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/4] net: dsa: mv88e6xxx: refactor FDB routines
Date: Tue,  4 Aug 2015 02:33:38 -0400
Message-ID: <1438670018-30501-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Refactor mv88e6xxx_port_fdb_{add,del,getnext} to respect the new DSA
switch driver FDB access routines.

The Marvell 88E6xxx switches support up to 4094 FIDs (from 1 to 0xfff;
FID 0 means that multiple address databases are not being used). So
change the fid_mask for a fid_bitmap of 4096 bits.

FIDs 1 to num_ports will be reserved for non-bridged ports and bridge
groups (a bridge group gets the FID of its first member). The remaining
bits will then be used for VLANs.

Also do not consider an address (yet) if it is trunk mapped.

This change is a need to welcome the future support for hardware VLANs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |   3 +
 drivers/net/dsa/mv88e6352.c |   3 +
 drivers/net/dsa/mv88e6xxx.c | 205 +++++++++++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx.h |  31 +++++--
 4 files changed, 172 insertions(+), 70 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index cfa21ed..735f04c 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -116,6 +116,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge       = mv88e6xxx_join_bridge,
 	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index eb4630f..191fb25 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -341,6 +341,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 438c73e..f576a39 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -12,6 +12,7 @@
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/if_vlan.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
@@ -964,7 +965,7 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 	if (ret < 0)
 		return ret;
 
@@ -1091,7 +1092,7 @@ int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 	ps->bridge_mask[fid] = br_port_mask;
 
 	if (fid != ps->fid[port]) {
-		ps->fid_mask |= 1 << ps->fid[port];
+		clear_bit(ps->fid[port], ps->fid_bitmap);
 		ps->fid[port] = fid;
 		ret = _mv88e6xxx_update_bridge_config(ds, fid);
 	}
@@ -1125,9 +1126,16 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 
 	mutex_lock(&ps->smi_mutex);
 
-	newfid = __ffs(ps->fid_mask);
+	newfid = find_next_zero_bit(ps->fid_bitmap, VLAN_N_VID, 1);
+	if (unlikely(newfid > ps->num_ports)) {
+		netdev_err(ds->ports[port], "all first %d FIDs are used\n",
+			   ps->num_ports);
+		ret = -ENOSPC;
+		goto unlock;
+	}
+
 	ps->fid[port] = newfid;
-	ps->fid_mask &= ~(1 << newfid);
+	set_bit(newfid, ps->fid_bitmap);
 	ps->bridge_mask[fid] &= ~(1 << port);
 	ps->bridge_mask[newfid] = 1 << port;
 
@@ -1135,6 +1143,7 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 	if (!ret)
 		ret = _mv88e6xxx_update_bridge_config(ds, newfid);
 
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -1174,8 +1183,8 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
-static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
-				  const unsigned char *addr)
+static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
+				    const u8 addr[ETH_ALEN])
 {
 	int i, ret;
 
@@ -1190,7 +1199,7 @@ static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
 	return 0;
 }
 
-static int __mv88e6xxx_read_addr(struct dsa_switch *ds, unsigned char *addr)
+static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, u8 addr[ETH_ALEN])
 {
 	int i, ret;
 
@@ -1206,109 +1215,184 @@ static int __mv88e6xxx_read_addr(struct dsa_switch *ds, unsigned char *addr)
 	return 0;
 }
 
-static int __mv88e6xxx_port_fdb_cmd(struct dsa_switch *ds, int port,
-				    const unsigned char *addr, int state)
+static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
+			       struct mv88e6xxx_atu_entry *entry)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid = ps->fid[port];
+	u16 reg = 0;
 	int ret;
 
 	ret = _mv88e6xxx_atu_wait(ds);
 	if (ret < 0)
 		return ret;
 
-	ret = __mv88e6xxx_write_addr(ds, addr);
+	ret = _mv88e6xxx_atu_mac_write(ds, entry->mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA,
-				   (0x10 << port) | state);
-	if (ret)
-		return ret;
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
+
+		if (entry->trunk) {
+			reg |= GLOBAL_ATU_DATA_TRUNK;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
+
+		reg |= (entry->portv_trunkid << shift) & mask;
+	}
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_LOAD_DB);
+	reg |= entry->state & GLOBAL_ATU_DATA_STATE_MASK;
 
-	return ret;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, reg);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
+static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
 {
-	int state = is_multicast_ether_addr(addr) ?
-		GLOBAL_ATU_DATA_STATE_MC_STATIC :
-		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
 
-	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, state);
-	mutex_unlock(&ps->smi_mutex);
+	if (vid == 0)
+		return ps->fid[port];
 
-	return ret;
+	return -ENOENT;
 }
 
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
+static int mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port, u16 vid,
+				   u8 addr[ETH_ALEN], u8 state)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_atu_entry entry = { 0 };
 	int ret;
 
+	memcpy(entry.mac, addr, ETH_ALEN);
+	entry.state = state;
+	if (state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		entry.trunk = false;
+		entry.portv_trunkid = BIT(port);
+	}
+
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr,
-				       GLOBAL_ATU_DATA_STATE_UNUSED);
+	ret = _mv88e6xxx_port_vid_to_fid(ds, port, vid);
+	if (ret < 0)
+		goto unlock;
+	entry.fid = ret;
+	ret = _mv88e6xxx_atu_load(ds, &entry);
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
 }
 
-static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
-				    unsigned char *addr, bool *is_static)
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port, u16 vid,
+			   u8 addr[ETH_ALEN])
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid = ps->fid[port];
-	int ret, state;
+	u8 state = is_multicast_ether_addr(addr) ?
+		GLOBAL_ATU_DATA_STATE_MC_STATIC :
+		GLOBAL_ATU_DATA_STATE_UC_STATIC;
+
+	return mv88e6xxx_port_fdb_load(ds, port, vid, addr, state);
+}
+
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port, u16 vid,
+			   u8 addr[ETH_ALEN])
+{
+	u8 state = GLOBAL_ATU_DATA_STATE_UNUSED;
+
+	return mv88e6xxx_port_fdb_load(ds, port, vid, addr, state);
+}
+
+static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
+				  const unsigned char *addr,
+				  struct mv88e6xxx_atu_entry *entry)
+{
+	struct mv88e6xxx_atu_entry next = { 0 };
+	int ret;
+
+	next.fid = fid;
 
 	ret = _mv88e6xxx_atu_wait(ds);
 	if (ret < 0)
 		return ret;
 
-	ret = __mv88e6xxx_write_addr(ds, addr);
+	ret = _mv88e6xxx_atu_mac_write(ds, addr);
 	if (ret < 0)
 		return ret;
 
-	do {
-		ret = _mv88e6xxx_atu_cmd(ds, fid,  GLOBAL_ATU_OP_GET_NEXT_DB);
-		if (ret < 0)
-			return ret;
+	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	if (ret < 0)
+		return ret;
 
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
-		if (ret < 0)
-			return ret;
-		state = ret & GLOBAL_ATU_DATA_STATE_MASK;
-		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			return -ENOENT;
-	} while (!(((ret >> 4) & 0xff) & (1 << port)));
+	ret = _mv88e6xxx_atu_mac_read(ds, next.mac);
+	if (ret < 0)
+		return ret;
 
-	ret = __mv88e6xxx_read_addr(ds, addr);
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
 	if (ret < 0)
 		return ret;
 
-	*is_static = state == (is_multicast_ether_addr(addr) ?
-			       GLOBAL_ATU_DATA_STATE_MC_STATIC :
-			       GLOBAL_ATU_DATA_STATE_UC_STATIC);
+	next.state = ret & GLOBAL_ATU_DATA_STATE_MASK;
+	if (next.state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
 
+		if (ret & GLOBAL_ATU_DATA_TRUNK) {
+			next.trunk = true;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			next.trunk = false;
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
+
+		next.portv_trunkid = (ret & mask) >> shift;
+	}
+
+	*entry = next;
 	return 0;
 }
 
 /* get next entry for port */
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static)
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
+			       u8 addr[ETH_ALEN], bool *is_static)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_atu_entry next;
+	u16 fid;
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_getnext(ds, port, addr, is_static);
+
+	ret = _mv88e6xxx_port_vid_to_fid(ds, port, *vid);
+	if (ret < 0)
+		goto unlock;
+	fid = ret;
+
+	do {
+		if (is_broadcast_ether_addr(addr)) {
+			ret = -ENOENT;
+			goto unlock;
+		}
+
+		ret = _mv88e6xxx_atu_getnext(ds, fid, addr, &next);
+		if (ret < 0)
+			goto unlock;
+
+		memcpy(addr, next.mac, ETH_ALEN);
+
+		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
+			continue;
+	} while (next.trunk || (next.portv_trunkid & BIT(port)) == 0);
+
+	*is_static = next.state == (is_multicast_ether_addr(addr) ?
+				    GLOBAL_ATU_DATA_STATE_MC_STATIC :
+				    GLOBAL_ATU_DATA_STATE_UC_STATIC);
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -1554,9 +1638,9 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
 	 */
-	fid = __ffs(ps->fid_mask);
+	fid = port + 1;
 	ps->fid[port] = fid;
-	ps->fid_mask &= ~(1 << fid);
+	set_bit(fid, ps->fid_bitmap);
 
 	if (!dsa_is_cpu_port(ds, port))
 		ps->bridge_mask[fid] = 1 << port;
@@ -1653,7 +1737,7 @@ static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
 	unsigned char addr[6];
 	int ret, data, state;
 
-	ret = __mv88e6xxx_write_addr(ds, bcast);
+	ret = _mv88e6xxx_atu_mac_write(ds, bcast);
 	if (ret < 0)
 		return ret;
 
@@ -1668,7 +1752,7 @@ static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
 		state = data & GLOBAL_ATU_DATA_STATE_MASK;
 		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			break;
-		ret = __mv88e6xxx_read_addr(ds, addr);
+		ret = _mv88e6xxx_atu_mac_read(ds, addr);
 		if (ret < 0)
 			return ret;
 		mv88e6xxx_atu_show_entry(s, dbnum, addr, data);
@@ -1855,7 +1939,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
 
-	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6a66b4b..f9a6bf8 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,6 +11,8 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
+#include <linux/if_vlan.h>
+
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
 #endif
@@ -170,6 +172,7 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
+#define GLOBAL_ATU_FID		0x01	/* 6097 6165 6351 6352 */
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -204,6 +207,8 @@
 #define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_DATA		0x0c
 #define GLOBAL_ATU_DATA_TRUNK			BIT(15)
+#define GLOBAL_ATU_DATA_TRUNK_ID_MASK		0x00f0
+#define GLOBAL_ATU_DATA_TRUNK_ID_SHIFT		4
 #define GLOBAL_ATU_DATA_PORT_VECTOR_MASK	0x3ff0
 #define GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT	4
 #define GLOBAL_ATU_DATA_STATE_MASK		0x0f
@@ -310,6 +315,14 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+struct mv88e6xxx_atu_entry {
+	u16	fid;
+	u8	state;
+	bool	trunk;
+	u16	portv_trunkid;
+	u8	mac[ETH_ALEN];
+};
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -348,9 +361,9 @@ struct mv88e6xxx_priv_state {
 
 	/* hw bridging */
 
-	u32 fid_mask;
-	u8 fid[DSA_MAX_PORTS];
-	u16 bridge_mask[DSA_MAX_PORTS];
+	DECLARE_BITMAP(fid_bitmap, VLAN_N_VID);	/* FIDs 1 to 4095 available */
+	u16 fid[DSA_MAX_PORTS];			/* per (non-bridged) port FID */
+	u16 bridge_mask[DSA_MAX_PORTS];		/* br groups (indexed by FID) */
 
 	unsigned long port_state_update_mask;
 	u8 port_state[DSA_MAX_PORTS];
@@ -410,15 +423,15 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port, u16 vid,
+			   u8 addr[ETH_ALEN]);
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port, u16 vid,
+			   u8 addr[ETH_ALEN]);
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
+			       u8 addr[ETH_ALEN], bool *is_static);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.4.6
