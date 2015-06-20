From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 6/6] dsa: mv88x6xxx: Add debugfs interface for scratch registers
Date: Sat, 20 Jun 2015 18:42:33 +0200
Message-ID: <1434818553-10239-7-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59938 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932295AbbFTQsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:48:33 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the contents of the scratch registers to be shown in debugfs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 54 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 2 files changed, 57 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7e12a31e9dae..c938d7ce5215 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -901,6 +901,13 @@ static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 			       GLOBAL_ATU_OP_BUSY);
 }
 
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_scratch_wait(struct dsa_switch *ds)
+{
+	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SCRATCH_MISC,
+			       GLOBAL2_SCRATCH_BUSY);
+}
+
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
 					int regnum)
@@ -1825,6 +1832,50 @@ static const struct file_operations mv88e6xxx_device_map_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static int mv88e6xxx_scratch_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int reg, ret;
+
+	seq_puts(s, "Register Value\n");
+
+	mutex_lock(&ps->smi_mutex);
+	for (reg = 0; reg < 0x80; reg++) {
+		ret = _mv88e6xxx_reg_write(
+			ds, REG_GLOBAL2, GLOBAL2_SCRATCH_MISC,
+			reg << GLOBAL2_SCRATCH_REGISTER_SHIFT);
+		if (ret < 0)
+			goto out;
+
+		ret = _mv88e6xxx_scratch_wait(ds);
+		if (ret < 0)
+			goto out;
+
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL2,
+					  GLOBAL2_SCRATCH_MISC);
+		seq_printf(s, "  %2x   %2x\n", reg,
+			   ret & GLOBAL2_SCRATCH_VALUE_MASK);
+	}
+out:
+	mutex_unlock(&ps->smi_mutex);
+
+	return 0;
+}
+
+static int mv88e6xxx_scratch_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_scratch_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_scratch_fops = {
+	.open   = mv88e6xxx_scratch_open,
+	.read   = seq_read,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner  = THIS_MODULE,
+};
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1853,6 +1904,9 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	debugfs_create_file("device_map", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_device_map_fops);
+
+	debugfs_create_file("scratch", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_scratch_fops);
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a2c9ac0c54ab..a650b2656de9 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -297,6 +297,9 @@
 #define GLOBAL2_SMI_OP_45_READ_DATA	((2 << 10) | GLOBAL2_SMI_OP_BUSY)
 #define GLOBAL2_SMI_DATA	0x19
 #define GLOBAL2_SCRATCH_MISC	0x1a
+#define GLOBAL2_SCRATCH_BUSY		BIT(15)
+#define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
+#define GLOBAL2_SCRATCH_VALUE_MASK	0xff
 #define GLOBAL2_WDOG_CONTROL	0x1b
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
-- 
2.1.4
