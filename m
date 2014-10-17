From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH] Move rlb table dump to procfs
Date: Fri, 17 Oct 2014 14:41:52 -0400
Message-ID: <1413571313-10137-1-git-send-email-emunson@akamai.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	linux-kernel@vger.kernel.org, Eric B Munson <emunson@akamai.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because debugfs is not net namespace aware, it is currently not
possible to dump the RLB hash table when network namespaces are enabled.
This patch creates a second proc file called IFNAME_rlb_table for
bonding interfaces that use adaptive load balancing which will expose
this table to userspace.  It also removes all the debugfs code from the
bonding module as the RLB hash was the only entry in debugfs.

Signed-off-by: Eric B Munson <emunson@akamai.com>
---
 drivers/net/bonding/Makefile       |    2 +-
 drivers/net/bonding/bond_debugfs.c |  141 ------------------------------------
 drivers/net/bonding/bond_main.c    |   11 ---
 drivers/net/bonding/bond_procfs.c  |   75 ++++++++++++++++++-
 drivers/net/bonding/bonding.h      |   11 +--
 5 files changed, 74 insertions(+), 166 deletions(-)
 delete mode 100644 drivers/net/bonding/bond_debugfs.c

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 6f4e808..409c5e3 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_sysfs_slave.o bond_debugfs.o bond_netlink.o bond_options.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_sysfs_slave.o bond_netlink.o bond_options.o
 
 proc-$(CONFIG_PROC_FS) += bond_procfs.o
 bonding-objs += $(proc-y)
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
deleted file mode 100644
index 8f99082..0000000
--- a/drivers/net/bonding/bond_debugfs.c
+++ /dev/null
@@ -1,141 +0,0 @@
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/device.h>
-#include <linux/netdevice.h>
-
-#include "bonding.h"
-#include "bond_alb.h"
-
-#if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_NET_NS)
-
-#include <linux/debugfs.h>
-#include <linux/seq_file.h>
-
-static struct dentry *bonding_debug_root;
-
-/* Show RLB hash table */
-static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
-{
-	struct bonding *bond = m->private;
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct rlb_client_info *client_info;
-	u32 hash_index;
-
-	if (BOND_MODE(bond) != BOND_MODE_ALB)
-		return 0;
-
-	seq_printf(m, "SourceIP        DestinationIP   "
-			"Destination MAC   DEV\n");
-
-	spin_lock_bh(&bond->mode_lock);
-
-	hash_index = bond_info->rx_hashtbl_used_head;
-	for (; hash_index != RLB_NULL_INDEX;
-	     hash_index = client_info->used_next) {
-		client_info = &(bond_info->rx_hashtbl[hash_index]);
-		seq_printf(m, "%-15pI4 %-15pI4 %-17pM %s\n",
-			&client_info->ip_src,
-			&client_info->ip_dst,
-			&client_info->mac_dst,
-			client_info->slave->dev->name);
-	}
-
-	spin_unlock_bh(&bond->mode_lock);
-
-	return 0;
-}
-
-static int bond_debug_rlb_hash_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, bond_debug_rlb_hash_show, inode->i_private);
-}
-
-static const struct file_operations bond_debug_rlb_hash_fops = {
-	.owner		= THIS_MODULE,
-	.open		= bond_debug_rlb_hash_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
-
-void bond_debug_register(struct bonding *bond)
-{
-	if (!bonding_debug_root)
-		return;
-
-	bond->debug_dir =
-		debugfs_create_dir(bond->dev->name, bonding_debug_root);
-
-	if (!bond->debug_dir) {
-		netdev_warn(bond->dev, "failed to register to debugfs\n");
-		return;
-	}
-
-	debugfs_create_file("rlb_hash_table", 0400, bond->debug_dir,
-				bond, &bond_debug_rlb_hash_fops);
-}
-
-void bond_debug_unregister(struct bonding *bond)
-{
-	if (!bonding_debug_root)
-		return;
-
-	debugfs_remove_recursive(bond->debug_dir);
-}
-
-void bond_debug_reregister(struct bonding *bond)
-{
-	struct dentry *d;
-
-	if (!bonding_debug_root)
-		return;
-
-	d = debugfs_rename(bonding_debug_root, bond->debug_dir,
-			   bonding_debug_root, bond->dev->name);
-	if (d) {
-		bond->debug_dir = d;
-	} else {
-		netdev_warn(bond->dev, "failed to reregister, so just unregister old one\n");
-		bond_debug_unregister(bond);
-	}
-}
-
-void bond_create_debugfs(void)
-{
-	bonding_debug_root = debugfs_create_dir("bonding", NULL);
-
-	if (!bonding_debug_root) {
-		pr_warn("Warning: Cannot create bonding directory in debugfs\n");
-	}
-}
-
-void bond_destroy_debugfs(void)
-{
-	debugfs_remove_recursive(bonding_debug_root);
-	bonding_debug_root = NULL;
-}
-
-
-#else /* !CONFIG_DEBUG_FS */
-
-void bond_debug_register(struct bonding *bond)
-{
-}
-
-void bond_debug_unregister(struct bonding *bond)
-{
-}
-
-void bond_debug_reregister(struct bonding *bond)
-{
-}
-
-void bond_create_debugfs(void)
-{
-}
-
-void bond_destroy_debugfs(void)
-{
-}
-
-#endif /* CONFIG_DEBUG_FS */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c9ac06c..d6aea43 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2778,8 +2778,6 @@ static int bond_event_changename(struct bonding *bond)
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
 
-	bond_debug_reregister(bond);
-
 	return NOTIFY_DONE;
 }
 
@@ -4039,8 +4037,6 @@ static void bond_uninit(struct net_device *bond_dev)
 	}
 
 	list_del(&bond->bond_list);
-
-	bond_debug_unregister(bond);
 }
 
 /*------------------------- Module initialization ---------------------------*/
@@ -4432,8 +4428,6 @@ static int bond_init(struct net_device *bond_dev)
 
 	bond_prepare_sysfs_group(bond);
 
-	bond_debug_register(bond);
-
 	/* Ensure valid dev_addr */
 	if (is_zero_ether_addr(bond_dev->dev_addr) &&
 	    bond_dev->addr_assign_type == NET_ADDR_PERM)
@@ -4538,8 +4532,6 @@ static int __init bonding_init(void)
 	if (res)
 		goto err_link;
 
-	bond_create_debugfs();
-
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(&init_net, NULL);
 		if (res)
@@ -4550,7 +4542,6 @@ static int __init bonding_init(void)
 out:
 	return res;
 err:
-	bond_destroy_debugfs();
 	bond_netlink_fini();
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
@@ -4562,8 +4553,6 @@ static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 
-	bond_destroy_debugfs();
-
 	bond_netlink_fini();
 	unregister_pernet_subsys(&bond_net_ops);
 
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index a3948f8..30693bc 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -231,10 +231,55 @@ static const struct file_operations bond_info_fops = {
 	.release = seq_release,
 };
 
+static int bond_table_seq_show(struct seq_file *seq, void *v)
+{
+	struct bonding *bond = seq->private;
+	struct alb_bond_info *bond_info;
+	struct rlb_client_info *client_info;
+	u32 hash_index;
+
+	/* make sure the bond won't be taken away */
+	rcu_read_lock();
+	bond_info = &(BOND_ALB_INFO(bond));
+
+	seq_printf(seq, "%-15s %-17s %-15s %-17s %s\n", "SourceIP",
+		   "Source MAC", "DestinationIP", "Destination MAC", "DEV");
+
+	spin_lock_bh(&bond->mode_lock);
+
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX;
+	     hash_index = client_info->used_next) {
+		client_info = &bond_info->rx_hashtbl[hash_index];
+		seq_printf(seq, "%-15pI4 %-17pM %-15pI4 %-17pM %s\n",
+			   &client_info->ip_src, client_info->mac_src,
+			   &client_info->ip_dst, client_info->mac_dst,
+			   client_info->slave->dev->name);
+	}
+
+	spin_unlock_bh(&bond->mode_lock);
+	rcu_read_unlock();
+	return 0;
+}
+
+static int bond_table_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bond_table_seq_show, PDE_DATA(inode));
+}
+
+static const struct file_operations bond_table_fops = {
+	.owner   = THIS_MODULE,
+	.open    = bond_table_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 void bond_create_proc_entry(struct bonding *bond)
 {
 	struct net_device *bond_dev = bond->dev;
 	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
+	char table_name[IFNAMSIZ + 10];
 
 	if (bn->proc_dir) {
 		bond->proc_entry = proc_create_data(bond_dev->name,
@@ -245,6 +290,21 @@ void bond_create_proc_entry(struct bonding *bond)
 				    DRV_NAME, bond_dev->name);
 		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
+
+		if (bond->params.mode == BOND_MODE_ALB) {
+			snprintf(table_name, IFNAMSIZ + 10, "%s_rlb_table",
+				 bond_dev->name);
+			bond->proc_table = proc_create_data(table_name, S_IRUGO,
+							    bn->proc_dir,
+							    &bond_table_fops,
+							    bond);
+			if (bond->proc_table == NULL)
+				pr_warn("Warning: Cannot create /proc/net/%s/%s\n",
+					DRV_NAME, table_name);
+			else
+				memcpy(bond->proc_table_name, table_name,
+				       IFNAMSIZ + 10);
+		}
 	}
 }
 
@@ -253,10 +313,17 @@ void bond_remove_proc_entry(struct bonding *bond)
 	struct net_device *bond_dev = bond->dev;
 	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
 
-	if (bn->proc_dir && bond->proc_entry) {
-		remove_proc_entry(bond->proc_file_name, bn->proc_dir);
-		memset(bond->proc_file_name, 0, IFNAMSIZ);
-		bond->proc_entry = NULL;
+	if (bn->proc_dir) {
+		if (bond->proc_entry) {
+			remove_proc_entry(bond->proc_file_name, bn->proc_dir);
+			memset(bond->proc_file_name, 0, IFNAMSIZ);
+			bond->proc_entry = NULL;
+		}
+		if (bond->proc_table) {
+			remove_proc_entry(bond->proc_table_name, bn->proc_dir);
+			memset(bond->proc_table_name, 0, IFNAMSIZ + 10);
+			bond->proc_table = NULL;
+		}
 	}
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 10920f0..714222a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -217,6 +217,8 @@ struct bonding {
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
 	char     proc_file_name[IFNAMSIZ];
+	struct   proc_dir_entry *proc_table;
+	char     proc_table_name[IFNAMSIZ + 10];
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
 	u32      rr_tx_counter;
@@ -230,10 +232,6 @@ struct bonding {
 	struct   delayed_work ad_work;
 	struct   delayed_work mcast_work;
 	struct   delayed_work slave_arr_work;
-#ifdef CONFIG_DEBUG_FS
-	/* debugging support via debugfs */
-	struct	 dentry *debug_dir;
-#endif /* CONFIG_DEBUG_FS */
 	struct rtnl_link_stats64 bond_stats;
 };
 
@@ -527,11 +525,6 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
-void bond_create_debugfs(void);
-void bond_destroy_debugfs(void);
-void bond_debug_register(struct bonding *bond);
-void bond_debug_unregister(struct bonding *bond);
-void bond_debug_reregister(struct bonding *bond);
 const char *bond_mode_name(int mode);
 void bond_setup(struct net_device *bond_dev);
 unsigned int bond_get_num_tx_queues(void);
-- 
1.7.9.5
