From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/7] net: dsa: mv88e6xxx: add VLAN Get Next support
Date: Thu, 13 Aug 2015 12:52:19 -0400
Message-ID: <1439484743-5126-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Received: from mail.savoirfairelinux.com ([209.172.62.77]:59369 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbHMQwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:52:39 -0400
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the port_pvid_get and vlan_getnext driver functions required
to dump VLAN entries from the hardware, with the VTU Get Next operation.

Some functions and structure will be shared with STU operations, since
their table format are similar (e.g. STU data entries are accessible
with the same registers as VTU entries, except with an offset of 2).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |   2 +
 drivers/net/dsa/mv88e6xxx.c | 138 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  27 +++++++++
 3 files changed, 167 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index a18f7c8..e6767ce 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -343,6 +343,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.port_pvid_get		= mv88e6xxx_port_pvid_get,
+	.vlan_getnext		= mv88e6xxx_vlan_getnext,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 175353a..ecdd9da 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2,6 +2,9 @@
  * net/dsa/mv88e6xxx.c - Marvell 88e6xxx switch chip support
  * Copyright (c) 2008 Marvell Semiconductor
  *
+ * Copyright (c) 2015 CMC Electronics, Inc.
+ *	Added support for VLAN Table Unit operations
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -1182,6 +1185,19 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
+int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
+{
+	int ret;
+
+	ret = mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
+	if (ret < 0)
+		return ret;
+
+	*pvid = ret & PORT_DEFAULT_VLAN_MASK;
+
+	return 0;
+}
+
 static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
@@ -1210,6 +1226,128 @@ static int _mv88e6xxx_vtu_stu_flush(struct dsa_switch *ds)
 	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_FLUSH_ALL);
 }
 
+static int _mv88e6xxx_vtu_stu_data_read(struct dsa_switch *ds,
+					struct mv88e6xxx_vtu_stu_entry *entry,
+					unsigned int nibble_offset)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 regs[3];
+	int i;
+	int ret;
+
+	for (i = 0; i < 3; ++i) {
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+					  GLOBAL_VTU_DATA_0_3 + i);
+		if (ret < 0)
+			return ret;
+
+		regs[i] = ret;
+	}
+
+	for (i = 0; i < ps->num_ports; ++i) {
+		unsigned int shift = (i % 4) * 4 + nibble_offset;
+		u16 reg = regs[i / 4];
+
+		entry->data[i] = (reg >> shift) & GLOBAL_VTU_STU_DATA_MASK;
+	}
+
+	return 0;
+}
+
+static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
+				  struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	struct mv88e6xxx_vtu_stu_entry next = { 0 };
+	int ret;
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
+	next.vid = ret & GLOBAL_VTU_VID_MASK;
+	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
+
+	if (next.valid) {
+		ret = _mv88e6xxx_vtu_stu_data_read(ds, &next, 0);
+		if (ret < 0)
+			return ret;
+
+		if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+		    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+						  GLOBAL_VTU_FID);
+			if (ret < 0)
+				return ret;
+
+			next.fid = ret & GLOBAL_VTU_FID_MASK;
+
+			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+						  GLOBAL_VTU_SID);
+			if (ret < 0)
+				return ret;
+
+			next.sid = ret & GLOBAL_VTU_SID_MASK;
+		}
+	}
+
+	*entry = next;
+	return 0;
+}
+
+int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
+			   unsigned long *ports, unsigned long *untagged)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry next;
+	int port;
+	int err;
+
+	if (*vid == 4095)
+		return -ENOENT;
+
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_vtu_getnext(ds, *vid, &next);
+	mutex_unlock(&ps->smi_mutex);
+
+	if (err)
+		return err;
+
+	if (!next.valid)
+		return -ENOENT;
+
+	*vid = next.vid;
+
+	for (port = 0; port < ps->num_ports; ++port) {
+		clear_bit(port, ports);
+		clear_bit(port, untagged);
+
+		if (dsa_is_cpu_port(ds, port))
+			continue;
+
+		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED ||
+		    next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+			set_bit(port, ports);
+
+		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+			set_bit(port, untagged);
+	}
+
+	return 0;
+}
+
 static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 				    const unsigned char *addr)
 {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 76139ea..bb6fa9a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -131,6 +131,7 @@
 #define PORT_CONTROL_1		0x05
 #define PORT_BASE_VLAN		0x06
 #define PORT_DEFAULT_VLAN	0x07
+#define PORT_DEFAULT_VLAN_MASK	0xfff
 #define PORT_CONTROL_2		0x08
 #define PORT_CONTROL_2_IGNORE_FCS	BIT(15)
 #define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
@@ -172,6 +173,10 @@
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
 #define GLOBAL_ATU_FID		0x01	/* 6097 6165 6351 6352 */
+#define GLOBAL_VTU_FID		0x02	/* 6097 6165 6351 6352 */
+#define GLOBAL_VTU_FID_MASK	0xfff
+#define GLOBAL_VTU_SID		0x03	/* 6097 6165 6351 6352 */
+#define GLOBAL_VTU_SID_MASK	0x3f
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -190,10 +195,18 @@
 #define GLOBAL_VTU_OP		0x05
 #define GLOBAL_VTU_OP_BUSY	BIT(15)
 #define GLOBAL_VTU_OP_FLUSH_ALL		((0x01 << 12) | GLOBAL_VTU_OP_BUSY)
+#define GLOBAL_VTU_OP_VTU_GET_NEXT	((0x04 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
+#define GLOBAL_VTU_VID_MASK	0xfff
+#define GLOBAL_VTU_VID_VALID	BIT(12)
 #define GLOBAL_VTU_DATA_0_3	0x07
 #define GLOBAL_VTU_DATA_4_7	0x08
 #define GLOBAL_VTU_DATA_8_11	0x09
+#define GLOBAL_VTU_STU_DATA_MASK		0x03
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED	0x00
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED	0x01
+#define GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED	0x02
+#define GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER	0x03
 #define GLOBAL_ATU_CONTROL	0x0a
 #define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
 #define GLOBAL_ATU_OP		0x0b
@@ -328,6 +341,17 @@ struct mv88e6xxx_atu_entry {
 	u8	mac[ETH_ALEN];
 };
 
+struct mv88e6xxx_vtu_stu_entry {
+	/* VTU only */
+	u16	vid;
+	u16	fid;
+
+	/* VTU and STU */
+	u8	sid;
+	bool	valid;
+	u8	data[DSA_MAX_PORTS];
+};
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -428,6 +452,9 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
+int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *vid);
+int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
+			   unsigned long *ports, unsigned long *untagged);
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-- 
2.5.0
