From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Tue, 23 Jun 2015 17:46:08 -0400
Message-ID: <1435095970-18576-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:51342 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbbFWVqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 17:46:19 -0400
In-Reply-To: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the Get Next operation for the VLAN Table Unit, and a "vtu"
debugfs file to dump the hardware VLANs.

A populated VTU can look like this:

    # cat /sys/kernel/debug/dsa0/vtu
    VID  FID  SID  P0 P1 P2 P3 P4 P5 P6
    550  562  0    x  x  x  u  x  t  x
    1000 1012 0    x  x  t  x  x  t  x
    1200 1212 0    x  x  t  x  t  t  x

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 138 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  24 ++++++++
 2 files changed, 162 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8c130c0..0dce8e8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1366,6 +1366,81 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
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
 static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1739,6 +1814,66 @@ static const struct file_operations mv88e6xxx_atu_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static int mv88e6xxx_vtu_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int vid = 0xfff; /* find the first or lowest VID */
+	int ret = 0;
+	int port;
+
+	seq_puts(s, "VID  FID  SID  P0 P1 P2 P3 P4 P5 P6\n");
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
+		seq_printf(s, "%-4d %-4d %-2d ", next.vid, next.fid, next.sid);
+		for (port = 0; port < 7; ++port) {
+			u8 tag = next.tags[port];
+
+			if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED)
+				seq_puts(s, "  -");
+			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+				seq_puts(s, "  u");
+			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED)
+				seq_puts(s, "  t");
+			else if (tag == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+				seq_puts(s, "  x");
+			else
+				seq_puts(s, "  ?"); /* unlikely */
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
+static int mv88e6xxx_vtu_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_vtu_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_vtu_fops = {
+	.open		= mv88e6xxx_vtu_open,
+	.read		= seq_read,
+	.llseek		= no_llseek,
+	.release	= single_release,
+	.owner		= THIS_MODULE,
+};
+
 static void mv88e6xxx_stats_show_header(struct seq_file *s,
 					struct mv88e6xxx_priv_state *ps)
 {
@@ -1901,6 +2036,9 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_atu_fops);
 
+	debugfs_create_file("vtu", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_vtu_fops);
+
 	debugfs_create_file("stats", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_stats_fops);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 1bc5a3e..798b6b8 100644
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
+#define GLOBAL_VTU_FID		0x02 /* 6352 only? */
+#define GLOBAL_VTU_FID_MASK	0xfff
+#define GLOBAL_VTU_SID		0x03 /* 6352 only? */
+#define GLOBAL_VTU_SID_MASK	0x3f
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -186,9 +191,20 @@
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
 #define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
@@ -310,6 +326,14 @@
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
2.4.4
