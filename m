From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 1/2] net: dsa: mv88e6xxx: add write access to debugfs regs file
Date: Wed,  8 Jul 2015 16:36:18 -0400
Message-ID: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow write access to the regs file in the debugfs interface, with the
following parameters:

    echo <name> <reg> <value> > regs

Where "name" is the register name (as shown in the header row), "reg" is
the register address (as shown in the first column) and "value" is the
16-bit value. e.g.:

    echo GLOBAL 1a 5550 > regs

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8c130c0..04e6eb6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1648,6 +1648,35 @@ static int mv88e6xxx_regs_show(struct seq_file *s, void *p)
 	return 0;
 }
 
+static ssize_t mv88e6xxx_regs_write(struct file *file, const char __user *buf,
+				    size_t count, loff_t *ppos)
+{
+	struct seq_file *s = file->private_data;
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	char name[count];
+	unsigned int port, reg, val;
+	int ret;
+
+	ret = sscanf(buf, "%s %x %x", name, &reg, &val);
+	if (ret != 3)
+		return -EINVAL;
+
+	if (reg > 0x1f || val > 0xffff)
+		return -ERANGE;
+
+	if (strcasecmp(name, "GLOBAL") == 0)
+		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, reg, val);
+	else if (strcasecmp(name, "GLOBAL2") == 0)
+		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, reg, val);
+	else if (kstrtouint(name, 10, &port) == 0 && port < ps->num_ports)
+		ret = mv88e6xxx_reg_write(ds, REG_PORT(port), reg, val);
+	else
+		return -EINVAL;
+
+	return ret < 0 ? ret : count;
+}
+
 static int mv88e6xxx_regs_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, mv88e6xxx_regs_show, inode->i_private);
@@ -1656,6 +1685,7 @@ static int mv88e6xxx_regs_open(struct inode *inode, struct file *file)
 static const struct file_operations mv88e6xxx_regs_fops = {
 	.open   = mv88e6xxx_regs_open,
 	.read   = seq_read,
+	.write	= mv88e6xxx_regs_write,
 	.llseek = no_llseek,
 	.release = single_release,
 	.owner  = THIS_MODULE,
@@ -1895,7 +1925,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	ps->dbgfs = debugfs_create_dir(name, NULL);
 	kfree(name);
 
-	debugfs_create_file("regs", S_IRUGO, ps->dbgfs, ds,
+	debugfs_create_file("regs", S_IRUGO | S_IWUSR, ps->dbgfs, ds,
 			    &mv88e6xxx_regs_fops);
 
 	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
-- 
2.4.5
