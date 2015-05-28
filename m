From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 2/3] net: dsa: mv88e6xxx: add support for VTU operations
Date: Thu, 28 May 2015 17:37:14 -0400
Message-ID: <1432849035-8499-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net>
 <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:52270 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbE1VhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:37:24 -0400
In-Reply-To: <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements the port_vlan_add, port_vlan_kill, and
port_bridge_setlink dsa_switch_driver functions to access the VTU, and
thus add support for adding, removing VLANs, and joining ports to them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 309 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  28 ++++
 2 files changed, 337 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cf309aa9..2f4c99f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2,6 +2,9 @@
  * net/dsa/mv88e6xxx.c - Marvell 88e6xxx switch chip support
  * Copyright (c) 2008 Marvell Semiconductor
  *
+ * Copyright (c) 2015 CMC Electronics, Inc.
+ *	Added support for 802.1q VTU operations
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -1241,6 +1244,312 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 	}
 }
 
+static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
+{
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
+			       GLOBAL_VTU_OP_BUSY);
+}
+
+static int _mv88e6xxx_vtu_cmd(struct dsa_switch *ds, u16 op)
+{
+	int ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_OP, op);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_wait(ds);
+}
+
+static int _mv88e6xxx_stu_loadpurge(struct dsa_switch *ds, u8 sid, bool valid)
+{
+	int ret, data;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	data = sid & GLOBAL_VTU_SID_MASK;
+	if (valid)
+		data |= GLOBAL_VTU_VID_VALID;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, data);
+	if (ret < 0)
+		return ret;
+
+	/* Unused (yet) data registers */
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3, 0);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7, 0);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11, 0);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+}
+
+static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
+				  struct mv88e6xxx_vtu_entry *entry)
+{
+	int ret, i;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
+				   vid & GLOBAL_VTU_VID_MASK);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
+	if (ret < 0)
+		return ret;
+
+	entry->vid = ret & GLOBAL_VTU_VID_MASK;
+	entry->valid = !!(ret & GLOBAL_VTU_VID_VALID);
+
+	if (entry->valid) {
+		/* Ports 0-3, offsets 0, 4, 8, 12 */
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3);
+		if (ret < 0)
+			return ret;
+
+		for (i = 0; i < 4; ++i)
+			entry->tags[i] = (ret >> (i * 4)) & 3;
+
+		/* Ports 4-6, offsets 0, 4, 8 */
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7);
+		if (ret < 0)
+			return ret;
+
+		for (i = 4; i < 7; ++i)
+			entry->tags[i] = (ret >> ((i - 4) * 4)) & 3;
+
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_FID);
+		if (ret < 0)
+			return ret;
+
+		entry->fid = ret & GLOBAL_VTU_FID_MASK;
+
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
+		if (ret < 0)
+			return ret;
+
+		entry->sid = ret & GLOBAL_VTU_SID_MASK;
+	}
+
+	return 0;
+}
+
+static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
+				    struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 data = 0;
+	int ret, i;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (entry->valid) {
+		/* Set Data Register, ports 0-3, offsets 0, 4, 8, 12 */
+		for (data = i = 0; i < 4; ++i)
+			data |= entry->tags[i] << (i * 4);
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3,
+					   data);
+		if (ret < 0)
+			return ret;
+
+		/* Set Data Register, ports 4-6, offsets 0, 4, 8 */
+		for (data = 0, i = 4; i < 7; ++i)
+			data |= entry->tags[i] << ((i - 4) * 4);
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7,
+					   data);
+		if (ret < 0)
+			return ret;
+
+		/* Unused Data Register */
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11,
+					   0);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID,
+					   entry->sid & GLOBAL_VTU_SID_MASK);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID,
+					   entry->fid & GLOBAL_VTU_FID_MASK);
+		if (ret < 0)
+			return ret;
+
+		/* Valid bit set means load, unset means purge */
+		data = GLOBAL_VTU_VID_VALID;
+	}
+
+	data |= entry->vid & GLOBAL_VTU_VID_MASK;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, data);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vid ? vid - 1 : 4095;
+	int i, ret;
+
+	/* Bringing an interface up adds it to the VLAN 0. Ignore this. */
+	if (!vid)
+		return 0;
+
+	/* The DSA port-based VLAN setup reserves FID 0 to DSA_MAX_PORTS;
+	 * we will use the next FIDs for 802.1q;
+	 * thus, forbid the last DSA_MAX_PORTS VLANs.
+	 */
+	if (vid > 4095 - DSA_MAX_PORTS)
+		return -EINVAL;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	/* If the VLAN does not exist, re-initialize the entry for addition */
+	if (entry.vid != vid || !entry.valid) {
+		memset(&entry, 0, sizeof(entry));
+		entry.valid = true;
+		entry.vid = vid;
+		entry.fid = DSA_MAX_PORTS + vid;
+		entry.sid = 0; /* We don't use 802.1s (yet) */
+
+		/* A VTU entry must have a valid STU entry (undocumented).
+		 * The default STU pointer for a VTU entry is 0. If per VLAN
+		 * spanning tree is not used then only one STU entry is needed
+		 * to cover all VTU entries. Thus, validate the STU entry 0.
+		 */
+		ret = _mv88e6xxx_stu_loadpurge(ds, 0, true);
+		if (ret < 0)
+			goto unlock;
+
+		for (i = 0; i < ps->num_ports; ++i)
+			entry.tags[i] = dsa_is_cpu_port(ds, i) ?
+				GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED :
+				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+	}
+
+	entry.tags[port] = GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED;
+
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_vlan_kill(struct dsa_switch *ds, int port, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int i, ret, prev_vid = vid ? vid - 1 : 4095;
+	bool keep = false;
+
+	/* Bringing an interface up adds it to the VLAN 0. Ignore this. */
+	if (!vid)
+		return 0;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	if (entry.vid != vid || !entry.valid) {
+		ret = -EINVAL;
+		goto unlock;
+	}
+
+	entry.tags[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+
+	/* keep the VLAN unless all ports are excluded */
+	for (i = 0; i < ps->num_ports; ++i) {
+		if (dsa_is_cpu_port(ds, i))
+			continue;
+
+		if (entry.tags[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+			keep = true;
+			break;
+		}
+	}
+
+	entry.valid = keep;
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	if (!keep)
+		ret = _mv88e6xxx_update_bridge_config(ds, entry.fid);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_bridge_setlink(struct dsa_switch *ds, int port,
+				  struct bridge_vlan_info *vinfo)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vinfo->vid > 0 ? vinfo->vid - 1 : 4095;
+	int ret;
+
+	/* Bringing an interface up adds it to the VLAN 0. Ignore this. */
+	if (!vinfo->vid)
+		return 0;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	if (entry.vid != vinfo->vid || !entry.valid) {
+		ret = -EINVAL;
+		goto unlock;
+	}
+
+	/* Set port default VID */
+	if (vinfo->flags & BRIDGE_VLAN_INFO_PVID) {
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_DEFAULT_VLAN,
+					   vinfo->vid & PORT_DEFAULT_VLAN_MASK);
+		if (ret < 0)
+			goto unlock;
+	}
+
+	/* Update VTU entry with the new port membership */
+	entry.tags[port] = vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED ?
+		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
+		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e045154..383b17af 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -73,6 +73,7 @@
 #define PORT_CONTROL_1		0x05
 #define PORT_BASE_VLAN		0x06
 #define PORT_DEFAULT_VLAN	0x07
+#define PORT_DEFAULT_VLAN_MASK	0xfff
 #define PORT_CONTROL_2		0x08
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
@@ -96,6 +97,10 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
+#define GLOBAL_VTU_FID		0x02 /* 6352 only? */
+#define GLOBAL_VTU_FID_MASK	0xfff
+#define GLOBAL_VTU_SID		0x03 /* 6352 only? */
+#define GLOBAL_VTU_SID_MASK	0x3f
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -112,9 +117,20 @@
 #define GLOBAL_CONTROL_TCAM_EN		BIT(1)
 #define GLOBAL_CONTROL_EEPROM_DONE_EN	BIT(0)
 #define GLOBAL_VTU_OP		0x05
+#define GLOBAL_VTU_OP_BUSY	BIT(15)
+#define GLOBAL_VTU_OP_FLUSH_ALL		((1 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_VTU_LOAD_PURGE	((3 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_VTU_GET_NEXT	((4 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_STU_LOAD_PURGE	((5 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
+#define GLOBAL_VTU_VID_MASK	0xfff
+#define GLOBAL_VTU_VID_VALID	BIT(12)
 #define GLOBAL_VTU_DATA_0_3	0x07
 #define GLOBAL_VTU_DATA_4_7	0x08
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED	0
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED	1
+#define GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED	2
+#define GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER	3
 #define GLOBAL_VTU_DATA_8_11	0x09
 #define GLOBAL_ATU_CONTROL	0x0a
 #define GLOBAL_ATU_OP		0x0b
@@ -205,6 +221,14 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+struct mv88e6xxx_vtu_entry {
+	u16	vid;
+	u16	fid;
+	u8	sid;
+	bool	valid;
+	u8	tags[DSA_MAX_PORTS];
+};
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -310,6 +334,10 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid);
+int mv88e6xxx_port_vlan_kill(struct dsa_switch *ds,int port, u16 vid);
+int mv88e6xxx_port_bridge_setlink(struct dsa_switch *ds,int port,
+				  struct bridge_vlan_info *vinfo);
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
-- 
2.4.1
