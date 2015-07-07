From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Tue,  7 Jul 2015 17:18:18 -0400
Message-ID: <1436303900-24259-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64541 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933556AbbGGVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 17:18:30 -0400
In-Reply-To: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the Get Next and Load Purge operations for the VLAN Table
Unit, and a "vtu" debugfs file to read and write the hardware VLANs.

A populated VTU look like this:

    # cat /sys/kernel/debug/dsa0/vtu
     VID  FID  SID  0  1  2  3  4  5  6
     550  562    0  x  x  x  u  x  t  x
    1000 1012    0  x  x  t  x  x  t  x
    1200 1212    0  x  x  t  x  t  t  x

Where "t", "u", "x", "-", respectively means that the port is tagged,
untagged, excluded or unmodified, for a given VLAN entry.

VTU entries can be added by echoing the same format:

    echo 1300 1312 0 x x t x t t x > vtu

and can be deleted by echoing only the VID:

    echo 1000 > vtu

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 322 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  31 +++++
 2 files changed, 353 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8c130c0..049553c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2,6 +2,9 @@
  * net/dsa/mv88e6xxx.c - Marvell 88e6xxx switch chip support
  * Copyright (c) 2008 Marvell Semiconductor
  *
+ * Copyright (c) 2015 CMC Electronics, Inc.
+ *	Added support for 802.1Q VLAN Table Unit
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -1366,6 +1369,192 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
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
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry next = { 0 };
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
+		u16 data[3];
+		int port;
+
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3);
+		if (ret < 0)
+			return ret;
+		data[0] = ret;
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7);
+		if (ret < 0)
+			return ret;
+		data[1] = ret;
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11);
+		if (ret < 0)
+			return ret;
+		data[2] = ret;
+
+		for (port = 0; port < ps->num_ports; ++port) {
+			int reg = data[port / 4];
+
+			next.tags[port] =
+				GLOBAL_VTU_DATA_MEMBER_TAG_UNMASK(port, reg);
+		}
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
+static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
+				    struct mv88e6xxx_vtu_entry *entry)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 reg = 0;
+	int ret;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (entry->valid) {
+		u16 data[3] = { 0 };
+		int port;
+
+		for (port = 0; port < ps->num_ports; ++port) {
+			u8 tag = entry->tags[port];
+
+			data[port / 4] |= GLOBAL_VTU_DATA_MEMBER_TAG_MASK(port,
+									  tag);
+		}
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3,
+					   data[0]);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7,
+					   data[1]);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11,
+					   data[2]);
+		if (ret < 0)
+			return ret;
+
+		if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+		    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+			reg = entry->sid & GLOBAL_VTU_SID_MASK;
+			ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL,
+						   GLOBAL_VTU_SID, reg);
+			if (ret < 0)
+				return ret;
+
+			reg = entry->fid & GLOBAL_VTU_FID_MASK;
+			ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL,
+						   GLOBAL_VTU_FID, reg);
+			if (ret < 0)
+				return ret;
+		}
+
+		/* Valid bit set means load, unset means purge */
+		reg = GLOBAL_VTU_VID_VALID;
+	}
+
+	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
 static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1739,6 +1928,136 @@ static const struct file_operations mv88e6xxx_atu_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static int mv88e6xxx_vtu_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int port, ret = 0, vid = 0xfff; /* find the first or lowest VID */
+
+	seq_puts(s, " VID  FID  SID");
+	for (port = 0; port < ps->num_ports; ++port)
+		seq_printf(s, " %2d", port);
+	seq_puts(s, "\n");
+
+	mutex_lock(&ps->smi_mutex);
+
+	do {
+		struct mv88e6xxx_vtu_entry next = { 0 };
+
+		ret = _mv88e6xxx_vtu_getnext(ds, vid, &next);
+		if (ret < 0)
+			goto unlock;
+
+		if (!next.valid)
+			break;
+
+		seq_printf(s, "%4d %4d   %2d", next.vid, next.fid, next.sid);
+		for (port = 0; port < ps->num_ports; ++port) {
+			switch (next.tags[port]) {
+			case GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED:
+				seq_puts(s, "  -");
+				break;
+			case GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED:
+				seq_puts(s, "  u");
+				break;
+			case GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED:
+				seq_puts(s, "  t");
+				break;
+			case GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER:
+				seq_puts(s, "  x");
+				break;
+			default:
+				seq_puts(s, "  ?");
+				break;
+			}
+		}
+		seq_puts(s, "\n");
+
+		vid = next.vid;
+	} while (vid < 0xfff);
+
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+static ssize_t mv88e6xxx_vtu_write(struct file *file, const char __user *buf,
+				   size_t count, loff_t *ppos)
+{
+	struct seq_file *s = file->private_data;
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	bool valid = true;
+	char tags[12]; /* DSA_MAX_PORTS */
+	int vid, fid, sid, port, ret;
+
+	/* scan 12 chars instead of num_ports to avoid dynamic scanning... */
+	ret = sscanf(buf, "%d %d %d %c %c %c %c %c %c %c %c %c %c %c %c", &vid,
+		     &fid, &sid, &tags[0], &tags[1], &tags[2], &tags[3],
+		     &tags[4], &tags[5], &tags[6], &tags[7], &tags[8], &tags[9],
+		     &tags[10], &tags[11]);
+	if (ret == 1)
+		valid = false;
+	else if (ret != 3 + ps->num_ports)
+		return -EINVAL;
+
+	entry.vid = vid;
+	entry.valid = valid;
+
+	if (valid) {
+		entry.fid = fid;
+		entry.sid = sid;
+		/* Note: The VTU entry pointed by VID will be loaded but not
+		 * considered valid until the STU entry pointed by SID is valid.
+		 */
+
+		for (port = 0; port < ps->num_ports; ++port) {
+			u8 tag;
+
+			switch (tags[port]) {
+			case 'u':
+				tag = GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED;
+				break;
+			case 't':
+				tag = GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+				break;
+			case 'x':
+				tag = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+				break;
+			case '-':
+				tag = GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+				break;
+			default:
+				return -EINVAL;
+			}
+
+			entry.tags[port] = tag;
+		}
+	}
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret < 0 ? ret : count;
+}
+
+static int mv88e6xxx_vtu_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_vtu_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_vtu_fops = {
+	.open		= mv88e6xxx_vtu_open,
+	.read		= seq_read,
+	.write		= mv88e6xxx_vtu_write,
+	.llseek		= no_llseek,
+	.release	= single_release,
+	.owner		= THIS_MODULE,
+};
+
 static void mv88e6xxx_stats_show_header(struct seq_file *s,
 					struct mv88e6xxx_priv_state *ps)
 {
@@ -1901,6 +2220,9 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_atu_fops);
 
+	debugfs_create_file("vtu", S_IRUGO | S_IWUSR, ps->dbgfs, ds,
+			    &mv88e6xxx_vtu_fops);
+
 	debugfs_create_file("stats", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_stats_fops);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 1bc5a3e..27d1913 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -124,6 +124,7 @@
 #define PORT_CONTROL_1		0x05
 #define PORT_BASE_VLAN		0x06
 #define PORT_DEFAULT_VLAN	0x07
+#define PORT_DEFAULT_VLAN_MASK	0xfff
 #define PORT_CONTROL_2		0x08
 #define PORT_CONTROL_2_IGNORE_FCS	BIT(15)
 #define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
@@ -170,6 +171,10 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
+#define GLOBAL_VTU_FID		0x02	/* 6097 6165 6351 6352 */
+#define GLOBAL_VTU_FID_MASK	0xfff
+#define GLOBAL_VTU_SID		0x03	/* 6097 6165 6351 6352 */
+#define GLOBAL_VTU_SID_MASK	0x3f
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -186,10 +191,28 @@
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
 #define GLOBAL_VTU_DATA_8_11	0x09
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED	0
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED	1
+#define GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED	2
+#define GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER	3
+/* Port member tags 0-11 are at offsets 0, 4, 8, 12 of VTU Data registers 1-3 */
+#define GLOBAL_VTU_DATA_MEMBER_TAG_SHIFT(_port) \
+	(((_port) % 4) * 4)
+#define GLOBAL_VTU_DATA_MEMBER_TAG_MASK(_port, _tag) \
+	(((_tag) & 0x03) << GLOBAL_VTU_DATA_MEMBER_TAG_SHIFT(_port))
+#define GLOBAL_VTU_DATA_MEMBER_TAG_UNMASK(_port, _reg) \
+	(((_reg) >> GLOBAL_VTU_DATA_MEMBER_TAG_SHIFT(_port)) & 0x03)
 #define GLOBAL_ATU_CONTROL	0x0a
 #define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
 #define GLOBAL_ATU_OP		0x0b
@@ -310,6 +333,14 @@
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
-- 
2.4.5
