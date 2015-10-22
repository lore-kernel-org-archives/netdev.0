From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: remove debugfs interface
Date: Thu, 22 Oct 2015 16:54:31 -0400
Message-ID: <1445547271-28003-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is preferable to have a common debugfs interface for DSA or switchdev
instead of a driver specific one. Thus remove the mv88e6xxx debug code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 291 --------------------------------------------
 drivers/net/dsa/mv88e6xxx.h |   2 -
 2 files changed, 293 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 39664d8..7af9630 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -11,7 +11,6 @@
  * (at your option) any later version.
  */
 
-#include <linux/debugfs.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -21,7 +20,6 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
-#include <linux/seq_file.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"
@@ -876,13 +874,6 @@ static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 			       GLOBAL_ATU_OP_BUSY);
 }
 
-/* Must be called with SMI lock held */
-static int _mv88e6xxx_scratch_wait(struct dsa_switch *ds)
-{
-	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SCRATCH_MISC,
-			       GLOBAL2_SCRATCH_BUSY);
-}
-
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
 					int regnum)
@@ -2107,273 +2098,9 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6xxx_regs_show(struct seq_file *s, void *p)
-{
-	struct dsa_switch *ds = s->private;
-
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int reg, port;
-
-	seq_puts(s, "    GLOBAL GLOBAL2 ");
-	for (port = 0 ; port < ps->num_ports; port++)
-		seq_printf(s, " %2d  ", port);
-	seq_puts(s, "\n");
-
-	for (reg = 0; reg < 32; reg++) {
-		seq_printf(s, "%2x: ", reg);
-		seq_printf(s, " %4x    %4x  ",
-			   mv88e6xxx_reg_read(ds, REG_GLOBAL, reg),
-			   mv88e6xxx_reg_read(ds, REG_GLOBAL2, reg));
-
-		for (port = 0 ; port < ps->num_ports; port++)
-			seq_printf(s, "%4x ",
-				   mv88e6xxx_reg_read(ds, REG_PORT(port), reg));
-		seq_puts(s, "\n");
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_regs_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, mv88e6xxx_regs_show, inode->i_private);
-}
-
-static const struct file_operations mv88e6xxx_regs_fops = {
-	.open   = mv88e6xxx_regs_open,
-	.read   = seq_read,
-	.llseek = no_llseek,
-	.release = single_release,
-	.owner  = THIS_MODULE,
-};
-
-static void mv88e6xxx_atu_show_header(struct seq_file *s)
-{
-	seq_puts(s, "DB   T/P  Vec State Addr\n");
-}
-
-static void mv88e6xxx_atu_show_entry(struct seq_file *s, int dbnum,
-				     unsigned char *addr, int data)
-{
-	bool trunk = !!(data & GLOBAL_ATU_DATA_TRUNK);
-	int portvec = ((data & GLOBAL_ATU_DATA_PORT_VECTOR_MASK) >>
-		       GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT);
-	int state = data & GLOBAL_ATU_DATA_STATE_MASK;
-
-	seq_printf(s, "%03x %5s %10pb   %x   %pM\n",
-		   dbnum, (trunk ? "Trunk" : "Port"), &portvec, state, addr);
-}
-
-static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
-				 int dbnum)
-{
-	unsigned char bcast[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-	unsigned char addr[6];
-	int ret, data, state;
-
-	ret = _mv88e6xxx_atu_mac_write(ds, bcast);
-	if (ret < 0)
-		return ret;
-
-	do {
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID,
-					   dbnum);
-		if (ret < 0)
-			return ret;
-
-		ret = _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_GET_NEXT_DB);
-		if (ret < 0)
-			return ret;
-
-		data = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
-		if (data < 0)
-			return data;
-
-		state = data & GLOBAL_ATU_DATA_STATE_MASK;
-		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			break;
-		ret = _mv88e6xxx_atu_mac_read(ds, addr);
-		if (ret < 0)
-			return ret;
-		mv88e6xxx_atu_show_entry(s, dbnum, addr, data);
-	} while (state != GLOBAL_ATU_DATA_STATE_UNUSED);
-
-	return 0;
-}
-
-static int mv88e6xxx_atu_show(struct seq_file *s, void *p)
-{
-	struct dsa_switch *ds = s->private;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int dbnum;
-
-	mv88e6xxx_atu_show_header(s);
-
-	for (dbnum = 0; dbnum < 255; dbnum++) {
-		mutex_lock(&ps->smi_mutex);
-		mv88e6xxx_atu_show_db(s, ds, dbnum);
-		mutex_unlock(&ps->smi_mutex);
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_atu_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, mv88e6xxx_atu_show, inode->i_private);
-}
-
-static const struct file_operations mv88e6xxx_atu_fops = {
-	.open   = mv88e6xxx_atu_open,
-	.read   = seq_read,
-	.llseek = no_llseek,
-	.release = single_release,
-	.owner  = THIS_MODULE,
-};
-
-static void mv88e6xxx_stats_show_header(struct seq_file *s,
-					struct mv88e6xxx_priv_state *ps)
-{
-	int port;
-
-	seq_puts(s, "      Statistic       ");
-	for (port = 0 ; port < ps->num_ports; port++)
-		seq_printf(s, "Port %2d  ", port);
-	seq_puts(s, "\n");
-}
-
-static int mv88e6xxx_stats_show(struct seq_file *s, void *p)
-{
-	struct dsa_switch *ds = s->private;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct mv88e6xxx_hw_stat *stats = mv88e6xxx_hw_stats;
-	int port, stat, max_stats;
-	uint64_t value;
-
-	if (have_sw_in_discards(ds))
-		max_stats = ARRAY_SIZE(mv88e6xxx_hw_stats);
-	else
-		max_stats = ARRAY_SIZE(mv88e6xxx_hw_stats) - 3;
-
-	mv88e6xxx_stats_show_header(s, ps);
-
-	mutex_lock(&ps->smi_mutex);
-
-	for (stat = 0; stat < max_stats; stat++) {
-		seq_printf(s, "%19s: ", stats[stat].string);
-		for (port = 0 ; port < ps->num_ports; port++) {
-			_mv88e6xxx_stats_snapshot(ds, port);
-			value = _mv88e6xxx_get_ethtool_stat(ds, stat, stats,
-							    port);
-			seq_printf(s, "%8llu ", value);
-		}
-		seq_puts(s, "\n");
-	}
-	mutex_unlock(&ps->smi_mutex);
-
-	return 0;
-}
-
-static int mv88e6xxx_stats_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, mv88e6xxx_stats_show, inode->i_private);
-}
-
-static const struct file_operations mv88e6xxx_stats_fops = {
-	.open   = mv88e6xxx_stats_open,
-	.read   = seq_read,
-	.llseek = no_llseek,
-	.release = single_release,
-	.owner  = THIS_MODULE,
-};
-
-static int mv88e6xxx_device_map_show(struct seq_file *s, void *p)
-{
-	struct dsa_switch *ds = s->private;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int target, ret;
-
-	seq_puts(s, "Target Port\n");
-
-	mutex_lock(&ps->smi_mutex);
-	for (target = 0; target < 32; target++) {
-		ret = _mv88e6xxx_reg_write(
-			ds, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
-			target << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT);
-		if (ret < 0)
-			goto out;
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL2,
-					  GLOBAL2_DEVICE_MAPPING);
-		seq_printf(s, "  %2d   %2d\n", target,
-			   ret & GLOBAL2_DEVICE_MAPPING_PORT_MASK);
-	}
-out:
-	mutex_unlock(&ps->smi_mutex);
-
-	return 0;
-}
-
-static int mv88e6xxx_device_map_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, mv88e6xxx_device_map_show, inode->i_private);
-}
-
-static const struct file_operations mv88e6xxx_device_map_fops = {
-	.open   = mv88e6xxx_device_map_open,
-	.read   = seq_read,
-	.llseek = no_llseek,
-	.release = single_release,
-	.owner  = THIS_MODULE,
-};
-
-static int mv88e6xxx_scratch_show(struct seq_file *s, void *p)
-{
-	struct dsa_switch *ds = s->private;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int reg, ret;
-
-	seq_puts(s, "Register Value\n");
-
-	mutex_lock(&ps->smi_mutex);
-	for (reg = 0; reg < 0x80; reg++) {
-		ret = _mv88e6xxx_reg_write(
-			ds, REG_GLOBAL2, GLOBAL2_SCRATCH_MISC,
-			reg << GLOBAL2_SCRATCH_REGISTER_SHIFT);
-		if (ret < 0)
-			goto out;
-
-		ret = _mv88e6xxx_scratch_wait(ds);
-		if (ret < 0)
-			goto out;
-
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL2,
-					  GLOBAL2_SCRATCH_MISC);
-		seq_printf(s, "  %2x   %2x\n", reg,
-			   ret & GLOBAL2_SCRATCH_VALUE_MASK);
-	}
-out:
-	mutex_unlock(&ps->smi_mutex);
-
-	return 0;
-}
-
-static int mv88e6xxx_scratch_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, mv88e6xxx_scratch_show, inode->i_private);
-}
-
-static const struct file_operations mv88e6xxx_scratch_fops = {
-	.open   = mv88e6xxx_scratch_open,
-	.read   = seq_read,
-	.llseek = no_llseek,
-	.release = single_release,
-	.owner  = THIS_MODULE,
-};
-
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	char *name;
 
 	mutex_init(&ps->smi_mutex);
 
@@ -2381,24 +2108,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
-	name = kasprintf(GFP_KERNEL, "dsa%d", ds->index);
-	ps->dbgfs = debugfs_create_dir(name, NULL);
-	kfree(name);
-
-	debugfs_create_file("regs", S_IRUGO, ps->dbgfs, ds,
-			    &mv88e6xxx_regs_fops);
-
-	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
-			    &mv88e6xxx_atu_fops);
-
-	debugfs_create_file("stats", S_IRUGO, ps->dbgfs, ds,
-			    &mv88e6xxx_stats_fops);
-
-	debugfs_create_file("device_map", S_IRUGO, ps->dbgfs, ds,
-			    &mv88e6xxx_device_map_fops);
-
-	debugfs_create_file("scratch", S_IRUGO, ps->dbgfs, ds,
-			    &mv88e6xxx_scratch_fops);
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 430de4f..6f9ed5d 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -406,8 +406,6 @@ struct mv88e6xxx_priv_state {
 	u8 port_state[DSA_MAX_PORTS];
 
 	struct work_struct bridge_work;
-
-	struct dentry *dbgfs;
 };
 
 struct mv88e6xxx_hw_stat {
-- 
2.6.1
