From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: mv88e6xxx: add VLAN Load support
Date: Thu, 13 Aug 2015 12:52:22 -0400
Message-ID: <1439484743-5126-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:61574 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbbHMQwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:52:37 -0400
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement port_pvid_set and port_vlan_add to add new entries in the VLAN
hardware table, and join ports to them.

The patch also implement the STU Get Next and Load Purge operations,
since it is required to have a valid STU entry for at least all VLANs.

Each VLAN has its own forwarding database, with FID num_ports+1 to 4095.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |   2 +
 drivers/net/dsa/mv88e6xxx.c | 169 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |   9 +++
 3 files changed, 180 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cec38bb..14b7177 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -344,6 +344,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
+	.port_pvid_set		= mv88e6xxx_port_pvid_set,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8423924..ca867e4 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1198,6 +1198,12 @@ int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 	return 0;
 }
 
+int mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
+{
+	return mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
+				   pvid & PORT_DEFAULT_VLAN_MASK);
+}
+
 static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
@@ -1374,6 +1380,169 @@ loadpurge:
 	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
 }
 
+static int _mv88e6xxx_stu_getnext(struct dsa_switch *ds, u8 sid,
+				  struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	struct mv88e6xxx_vtu_stu_entry next = { 0 };
+	int ret;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID,
+				   sid & GLOBAL_VTU_SID_MASK);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_GET_NEXT);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
+	if (ret < 0)
+		return ret;
+
+	next.sid = ret & GLOBAL_VTU_SID_MASK;
+
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
+	if (ret < 0)
+		return ret;
+
+	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
+
+	if (next.valid) {
+		ret = _mv88e6xxx_vtu_stu_data_read(ds, &next, 2);
+		if (ret < 0)
+			return ret;
+	}
+
+	*entry = next;
+	return 0;
+}
+
+static int _mv88e6xxx_stu_loadpurge(struct dsa_switch *ds,
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
+	/* Write port states */
+	ret = _mv88e6xxx_vtu_stu_data_write(ds, entry, 2);
+	if (ret < 0)
+		return ret;
+
+	reg = GLOBAL_VTU_VID_VALID;
+loadpurge:
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	if (ret < 0)
+		return ret;
+
+	reg = entry->sid & GLOBAL_VTU_SID_MASK;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+}
+
+static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
+				struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry vlan = {
+		.valid = true,
+		.vid = vid,
+	};
+	int i;
+
+	/* exclude all ports except the CPU */
+	for (i = 0; i < ps->num_ports; ++i)
+		vlan.data[i] = dsa_is_cpu_port(ds, i) ?
+			GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED :
+			GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+
+	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+		struct mv88e6xxx_vtu_stu_entry vstp;
+		int err;
+
+		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
+		 * implemented, only one STU entry is needed to cover all VTU
+		 * entries. Thus, validate the SID 0.
+		 */
+		vlan.sid = 0;
+		err = _mv88e6xxx_stu_getnext(ds, GLOBAL_VTU_SID_MASK, &vstp);
+		if (err)
+			return err;
+
+		if (vstp.sid != vlan.sid || !vstp.valid) {
+			memset(&vstp, 0, sizeof(vstp));
+			vstp.valid = true;
+			vstp.sid = vlan.sid;
+
+			err = _mv88e6xxx_stu_loadpurge(ds, &vstp);
+			if (err)
+				return err;
+		}
+
+		/* Non-bridged ports and bridge groups use FIDs from 1 to
+		 * num_ports; VLANs use FIDs from num_ports+1 to 4095.
+		 */
+		vlan.fid = find_next_zero_bit(ps->fid_bitmap, VLAN_N_VID,
+					      ps->num_ports + 1);
+		if (unlikely(vlan.fid == VLAN_N_VID)) {
+			pr_err("no more FID available for VLAN %d\n", vid);
+			return -ENOSPC;
+		}
+
+		err = _mv88e6xxx_flush_fid(ds, vlan.fid);
+		if (err)
+			return err;
+
+		set_bit(vlan.fid, ps->fid_bitmap);
+	}
+
+	*entry = vlan;
+	return 0;
+}
+
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    bool untagged)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry vlan;
+	int err;
+
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_vtu_getnext(ds, vid - 1, &vlan);
+	if (err)
+		goto unlock;
+
+	if (vlan.vid != vid || !vlan.valid) {
+		err = _mv88e6xxx_vlan_init(ds, vid, &vlan);
+		if (err)
+			goto unlock;
+	}
+
+	vlan.data[port] = untagged ?
+		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
+		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+
+	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
 int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index c70a3c1..ca3268f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -197,6 +197,8 @@
 #define GLOBAL_VTU_OP_FLUSH_ALL		((0x01 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_OP_VTU_LOAD_PURGE	((0x03 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_OP_VTU_GET_NEXT	((0x04 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_STU_LOAD_PURGE	((0x05 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_STU_GET_NEXT	((0x06 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
 #define GLOBAL_VTU_VID_MASK	0xfff
 #define GLOBAL_VTU_VID_VALID	BIT(12)
@@ -208,6 +210,10 @@
 #define GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED	0x01
 #define GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED	0x02
 #define GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER	0x03
+#define GLOBAL_STU_DATA_PORT_STATE_DISABLED	0x00
+#define GLOBAL_STU_DATA_PORT_STATE_BLOCKING	0x01
+#define GLOBAL_STU_DATA_PORT_STATE_LEARNING	0x02
+#define GLOBAL_STU_DATA_PORT_STATE_FORWARDING	0x03
 #define GLOBAL_ATU_CONTROL	0x0a
 #define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
 #define GLOBAL_ATU_OP		0x0b
@@ -454,6 +460,9 @@ int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *vid);
+int mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 vid);
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    bool untagged);
 int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid);
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged);
-- 
2.5.0
