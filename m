From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/6] dsa: mv88e6xxx: Add debugfs interface for ATU
Date: Sat, 20 Jun 2015 18:42:29 +0200
Message-ID: <1434818553-10239-3-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59973 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873AbbFTQtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:49:12 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump the Address Translation Unit via a file in debugfs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 81 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 ++
 2 files changed, 84 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e6dbc4a8110e..6e684f3d377c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1643,6 +1643,84 @@ static const struct file_operations mv88e6xxx_regs_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static void mv88e6xxx_atu_show_header(struct seq_file *s)
+{
+	seq_puts(s, "DB   T/P  Vec State Addr\n");
+}
+
+static void mv88e6xxx_atu_show_entry(struct seq_file *s, int dbnum,
+				     unsigned char *addr, int data)
+{
+	bool trunk = !!(data & GLOBAL_ATU_DATA_TRUNK);
+	int portvec = ((data & GLOBAL_ATU_DATA_PORT_VECTOR_MASK) >>
+		       GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT);
+	int state = data & GLOBAL_ATU_DATA_STATE_MASK;
+
+	seq_printf(s, "%03x %5s %10pb   %x   %pM\n",
+		   dbnum, (trunk ? "Trunk" : "Port"), &portvec, state, addr);
+}
+
+static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
+				 int dbnum)
+{
+	unsigned char bcast[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	unsigned char addr[6];
+	int ret, data, state;
+
+	ret = __mv88e6xxx_write_addr(ds, bcast);
+	if (ret < 0)
+		return ret;
+
+	do {
+		ret = _mv88e6xxx_atu_cmd(ds, dbnum, GLOBAL_ATU_OP_GET_NEXT_DB);
+		if (ret < 0)
+			return ret;
+		data = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
+		if (data < 0)
+			return data;
+
+		state = data & GLOBAL_ATU_DATA_STATE_MASK;
+		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
+			break;
+		ret = __mv88e6xxx_read_addr(ds, addr);
+		if (ret < 0)
+			return ret;
+		mv88e6xxx_atu_show_entry(s, dbnum, addr, data);
+	} while (state != GLOBAL_ATU_DATA_STATE_UNUSED);
+
+	return 0;
+}
+
+static int mv88e6xxx_atu_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int dbnum;
+
+	mv88e6xxx_atu_show_header(s);
+
+	for (dbnum = 0; dbnum < 255; dbnum++) {
+		mutex_lock(&ps->smi_mutex);
+		mv88e6xxx_atu_show_db(s, ds, dbnum);
+		mutex_unlock(&ps->smi_mutex);
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_atu_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_atu_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_atu_fops = {
+	.open   = mv88e6xxx_atu_open,
+	.read   = seq_read,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner  = THIS_MODULE,
+};
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1663,6 +1741,9 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	debugfs_create_file("regs", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_regs_fops);
 
+	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_atu_fops);
+
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 5fc291cbdae0..8b9c76b66ddb 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -193,6 +193,9 @@
 #define GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB ((6 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_DATA		0x0c
+#define GLOBAL_ATU_DATA_TRUNK			BIT(15)
+#define GLOBAL_ATU_DATA_PORT_VECTOR_MASK	0x3ff0
+#define GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT	4
 #define GLOBAL_ATU_DATA_STATE_MASK		0x0f
 #define GLOBAL_ATU_DATA_STATE_UNUSED		0x00
 #define GLOBAL_ATU_DATA_STATE_UC_MGMT		0x0d
-- 
2.1.4
