From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/6] dsa: mv88e6xxx: Add debugfs interface for registers
Date: Sat, 20 Jun 2015 18:42:28 +0200
Message-ID: <1434818553-10239-2-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59944 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932459AbbFTQsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:48:40 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the contents of the registers to be shown in debugfs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 50 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 2 files changed, 52 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 39530fa142b0..e6dbc4a8110e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/debugfs.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
@@ -16,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
+#include <linux/seq_file.h>
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
@@ -1601,9 +1603,50 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	return 0;
 }
 
+static int mv88e6xxx_regs_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int reg, port;
+
+	seq_puts(s, "    GLOBAL GLOBAL2 ");
+	for (port = 0 ; port < ps->num_ports; port++)
+		seq_printf(s, " %2d  ", port);
+	seq_puts(s, "\n");
+
+	for (reg = 0; reg < 32; reg++) {
+		seq_printf(s, "%2x: ", reg);
+		seq_printf(s, " %4x    %4x  ",
+			   mv88e6xxx_reg_read(ds, REG_GLOBAL, reg),
+			   mv88e6xxx_reg_read(ds, REG_GLOBAL2, reg));
+
+		for (port = 0 ; port < ps->num_ports; port++)
+			seq_printf(s, "%4x ",
+				   mv88e6xxx_reg_read(ds, REG_PORT(port), reg));
+		seq_puts(s, "\n");
+	}
+
+	return 0;
+}
+
+static int mv88e6xxx_regs_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_regs_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_regs_fops = {
+	.open   = mv88e6xxx_regs_open,
+	.read   = seq_read,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner  = THIS_MODULE,
+};
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	char *name;
 
 	mutex_init(&ps->smi_mutex);
 
@@ -1613,6 +1656,13 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
+	name = kasprintf(GFP_KERNEL, "dsa%d", ds->index);
+	ps->dbgfs = debugfs_create_dir(name, NULL);
+	kfree(name);
+
+	debugfs_create_file("regs", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_regs_fops);
+
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e10ccdb4ffbc..5fc291cbdae0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -339,6 +339,8 @@ struct mv88e6xxx_priv_state {
 	u8 port_state[DSA_MAX_PORTS];
 
 	struct work_struct bridge_work;
+
+	struct dentry *dbgfs;
 };
 
 struct mv88e6xxx_hw_stat {
-- 
2.1.4
