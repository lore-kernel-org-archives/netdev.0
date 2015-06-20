From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 5/6] dsa: mv88x6xxx: Add debugfs interface for device map
Date: Sat, 20 Jun 2015 18:42:32 +0200
Message-ID: <1434818553-10239-6-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59957 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667AbbFTQs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:48:56 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device map is used to route packets between cascaded switches.
Add dumping a switches device map via debugfs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 41 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fc5d4fdfcb02..7e12a31e9dae 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1786,6 +1786,45 @@ static const struct file_operations mv88e6xxx_stats_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static int mv88e6xxx_device_map_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int target, ret;
+
+	seq_puts(s, "Target Port\n");
+
+	mutex_lock(&ps->smi_mutex);
+	for (target = 0; target < 32; target++) {
+		ret = _mv88e6xxx_reg_write(
+			ds, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
+			target << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT);
+		if (ret < 0)
+			goto out;
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL2,
+					  GLOBAL2_DEVICE_MAPPING);
+		seq_printf(s, "  %2d   %2d\n", target,
+			   ret & GLOBAL2_DEVICE_MAPPING_PORT_MASK);
+	}
+out:
+	mutex_unlock(&ps->smi_mutex);
+
+	return 0;
+}
+
+static int mv88e6xxx_device_map_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_device_map_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_device_map_fops = {
+	.open   = mv88e6xxx_device_map_open,
+	.read   = seq_read,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner  = THIS_MODULE,
+};
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1812,6 +1851,8 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	debugfs_create_file("stats", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_stats_fops);
 
+	debugfs_create_file("device_map", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_device_map_fops);
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7cccff202586..a2c9ac0c54ab 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -260,6 +260,7 @@
 #define GLOBAL2_DEVICE_MAPPING	0x06
 #define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
 #define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
+#define GLOBAL2_DEVICE_MAPPING_PORT_MASK	0x0f
 #define GLOBAL2_TRUNK_MASK	0x07
 #define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
 #define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
-- 
2.1.4
