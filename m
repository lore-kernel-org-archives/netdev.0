From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH] [bonding] Convert /proc to seq_file
Date: Mon, 15 Sep 2003 14:11:08 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151411.08451.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch converts /proc/net/bondX/info into /proc/net/bonding/bondX
using the seq_file interface.

This is based on Stephen's recent patch, but slightly modified to work
with the propagation patch set and with some locking changes to make it
simpler.

The patch applies both on 2.4 (after the sync set from earlier today)
and on 2.6 (after the propagation set from 2003/11/9).

Amir



diff -Nuarp a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	2003-09-15 11:39:48.000000000 +0300
+++ b/Documentation/networking/bonding.txt	2003-09-15 11:39:49.000000000 +0300
@@ -527,9 +527,9 @@ Verifying Bond Configuration
 
 1) Bonding information files
 ----------------------------
-The bonding driver information files reside in the /proc/net/bond* directories.
+The bonding driver information files reside in the /proc/net/bonding directory.
 
-Sample contents of /proc/net/bond0/info after the driver is loaded with 
+Sample contents of /proc/net/bonding/bond0 after the driver is loaded with 
 parameters of mode=0 and miimon=1000 is shown below.
  
         Bonding Mode: load balancing (round-robin)
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	2003-09-15 11:39:48.000000000 +0300
+++ b/drivers/net/bonding/bonding.h	2003-09-15 11:39:49.000000000 +0300
@@ -101,8 +101,7 @@ typedef struct bonding {
 	struct timer_list arp_timer;
 	struct net_device_stats stats;
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *bond_proc_dir;
-	struct proc_dir_entry *bond_proc_info_file;
+	struct proc_dir_entry *bond_proc_file;
 	char procdir_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
 	struct list_head bond_list;
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2003-09-15 11:39:48.000000000 +0300
+++ b/drivers/net/bonding/bond_main.c	2003-09-15 11:39:50.000000000 +0300
@@ -420,6 +420,12 @@
  *	  HW address and MTU with proper unwind; Consolidate procfs code,
  *	  add CHANGENAME handler; Enhance netdev notification handling.
  *	  Version to 2.4.0.
+ *
+ * 2003/09/15 - Stephen Hemminger <shemminger at osdl dot org>,
+ *	       Amir Noam <amir.noam at intel dot com>
+ *	- Convert /proc to seq_file interface.
+ *	  Change /proc/net/bondX/info to /proc/net/bonding/bondX.
+ *	  Set version to 2.4.1.
  */
 
 #include <linux/config.h>
@@ -453,6 +459,8 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <linux/if_bonding.h>
 #include <linux/smp.h>
@@ -464,8 +472,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.4.0"
-#define DRV_RELDATE	"August 7, 2003"
+#define DRV_VERSION	"2.4.1"
+#define DRV_RELDATE	"September 15, 2003"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -553,6 +561,9 @@ static struct bond_parm_tbl bond_lacp_tb
 };
 
 static LIST_HEAD(bond_dev_list);
+#ifdef CONFIG_PROC_FS
+static struct proc_dir_entry *bond_proc_dir = NULL;
+#endif
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -3348,172 +3359,218 @@ static struct net_device_stats *bond_get
 }
 
 #ifdef CONFIG_PROC_FS
-static int bond_read_proc(char *buf, char **start, off_t off, int count, int *eof, void *data)
+
+#define SEQ_START_TOKEN ((void *)1)
+
+static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct bonding *bond = (struct bonding *) data;
-	int len = 0;
-	u16 link;
-	slave_t *slave = NULL;
+	struct bonding *bond = seq->private;
+	loff_t off = 0;
+	struct slave *slave;
 
 	/* make sure the bond won't be taken away */
 	read_lock(&dev_base_lock);
+	read_lock_bh(&bond->lock);
 
-	len += sprintf(buf + len, "%s\n", version);
+	if (*pos == 0) {
+		return SEQ_START_TOKEN;
+	}
 
-	/*
-	 * This function locks the mutex, so we can't lock it until
-	 * afterwards
-	 */
-	link = bond_check_mii_link(bond);
+	for (slave = bond->prev; slave != (slave_t *)bond;
+	     slave = slave->prev) {
+
+		if (++off == *pos) {
+			return slave;
+		}
+	}
+
+	return NULL;
+}
+
+static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct bonding *bond = seq->private;
+	struct slave *slave = v;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN) {
+		slave = bond->prev;
+	} else {
+		slave = slave->prev;
+	}
+
+	return (slave == (struct slave *) bond) ? NULL : slave;
+}
+
+static void bond_info_seq_stop(struct seq_file *seq, void *v)
+{
+	struct bonding *bond = seq->private;
 
-	len += sprintf(buf + len, "Bonding Mode: %s\n",
-		       bond_mode_name());
+	read_unlock_bh(&bond->lock);
+	read_unlock(&dev_base_lock);
+}
+
+static void bond_info_show_master(struct seq_file *seq, struct bonding *bond)
+{
+	struct slave *curr;
+
+	read_lock(&bond->ptrlock);
+	curr = bond->current_slave;
+	read_unlock(&bond->ptrlock);
+
+	seq_printf(seq, "Bonding Mode: %s\n", bond_mode_name());
 
 	if (USES_PRIMARY(bond_mode)) {
-		read_lock_bh(&bond->lock);
-		read_lock(&bond->ptrlock);
-		if (bond->current_slave != NULL) {
-			len += sprintf(buf + len,
-				"Currently Active Slave: %s\n",
-				bond->current_slave->dev->name);
+		if (curr) {
+			seq_printf(seq,
+				   "Currently Active Slave: %s\n",
+				   curr->dev->name);
 		}
-		read_unlock(&bond->ptrlock);
-		read_unlock_bh(&bond->lock);
 	}
 
-	len += sprintf(buf + len, "MII Status: ");
-	len += sprintf(buf + len,
-			link == BMSR_LSTATUS ? "up\n" : "down\n");
-	len += sprintf(buf + len, "MII Polling Interval (ms): %d\n",
-			miimon);
-	len += sprintf(buf + len, "Up Delay (ms): %d\n",
-			updelay * miimon);
-	len += sprintf(buf + len, "Down Delay (ms): %d\n",
-			downdelay * miimon);
-	len += sprintf(buf + len, "Multicast Mode: %s\n",
-		       multicast_mode_name());
-
-	read_lock_bh(&bond->lock);
+	seq_printf(seq, "MII Status: %s\n", (curr) ? "up" : "down");
+	seq_printf(seq, "MII Polling Interval (ms): %d\n", miimon);
+	seq_printf(seq, "Up Delay (ms): %d\n", updelay * miimon);
+	seq_printf(seq, "Down Delay (ms): %d\n", downdelay * miimon);
+	seq_printf(seq, "Multicast Mode: %s\n", multicast_mode_name());
 
 	if (bond_mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 
-		len += sprintf(buf + len, "\n802.3ad info\n");
+		seq_puts(seq, "\n802.3ad info\n");
 
 		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-			len += sprintf(buf + len, "bond %s has no active aggregator\n", bond->device->name);
+			seq_printf(seq, "bond %s has no active aggregator\n",
+				   bond->device->name);
 		} else {
-			len += sprintf(buf + len, "Active Aggregator Info:\n");
+			seq_printf(seq, "Active Aggregator Info:\n");
 
-			len += sprintf(buf + len, "\tAggregator ID: %d\n", ad_info.aggregator_id);
-			len += sprintf(buf + len, "\tNumber of ports: %d\n", ad_info.ports);
-			len += sprintf(buf + len, "\tActor Key: %d\n", ad_info.actor_key);
-			len += sprintf(buf + len, "\tPartner Key: %d\n", ad_info.partner_key);
-			len += sprintf(buf + len, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-				       ad_info.partner_system[0],
-				       ad_info.partner_system[1],
-				       ad_info.partner_system[2],
-				       ad_info.partner_system[3],
-				       ad_info.partner_system[4],
-				       ad_info.partner_system[5]);
+			seq_printf(seq, "\tAggregator ID: %d\n",
+				   ad_info.aggregator_id);
+			seq_printf(seq, "\tNumber of ports: %d\n",
+				   ad_info.ports);
+			seq_printf(seq, "\tActor Key: %d\n",
+				   ad_info.actor_key);
+			seq_printf(seq, "\tPartner Key: %d\n",
+				   ad_info.partner_key);
+			seq_printf(seq, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+				   ad_info.partner_system[0],
+				   ad_info.partner_system[1],
+				   ad_info.partner_system[2],
+				   ad_info.partner_system[3],
+				   ad_info.partner_system[4],
+				   ad_info.partner_system[5]);
 		}
 	}
+}
 
-	for (slave = bond->prev; slave != (slave_t *)bond;
-	     slave = slave->prev) {
-		len += sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->name);
-
-		len += sprintf(buf + len, "MII Status: ");
-
-		len += sprintf(buf + len,
-			slave->link == BOND_LINK_UP ?
-			"up\n" : "down\n");
-		len += sprintf(buf + len, "Link Failure Count: %d\n",
-			slave->link_failure_count);
+static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave)
+{
+	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
+	seq_printf(seq, "MII Status: %s\n",
+		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
+	seq_printf(seq, "Link Failure Count: %d\n",
+		   slave->link_failure_count);
 
-		if (app_abi_ver >= 1) {
-			len += sprintf(buf + len,
-				       "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
-				       slave->perm_hwaddr[0],
-				       slave->perm_hwaddr[1],
-				       slave->perm_hwaddr[2],
-				       slave->perm_hwaddr[3],
-				       slave->perm_hwaddr[4],
-				       slave->perm_hwaddr[5]);
-		}
+	if (app_abi_ver >= 1) {
+		seq_printf(seq,
+			   "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
+			   slave->perm_hwaddr[0],
+			   slave->perm_hwaddr[1],
+			   slave->perm_hwaddr[2],
+			   slave->perm_hwaddr[3],
+			   slave->perm_hwaddr[4],
+			   slave->perm_hwaddr[5]);
+	}
 
-		if (bond_mode == BOND_MODE_8023AD) {
-			struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
+	if (bond_mode == BOND_MODE_8023AD) {
+		const struct aggregator *agg
+			= SLAVE_AD_INFO(slave).port.aggregator;
 
-			if (agg) {
-				len += sprintf(buf + len, "Aggregator ID: %d\n",
-					       agg->aggregator_identifier);
-			} else {
-				len += sprintf(buf + len, "Aggregator ID: N/A\n");
-			}
+		if (agg) {
+			seq_printf(seq, "Aggregator ID: %d\n",
+				   agg->aggregator_identifier);
+		} else {
+			seq_puts(seq, "Aggregator ID: N/A\n");
 		}
 	}
-	read_unlock_bh(&bond->lock);
+}
 
-	/*
-	 * Figure out the calcs for the /proc/net interface
-	 */
-	if (len <= off + count) {
-		*eof = 1;
-	}
-	*start = buf + off;
-	len -= off;
-	if (len > count) {
-		len = count;
-	}
-	if (len < 0) {
-		len = 0;
+static int bond_info_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, "%s\n", version);
+		bond_info_show_master(seq, seq->private);
+	} else {
+		bond_info_show_slave(seq, v);
 	}
 
-	read_unlock(&dev_base_lock);
-
-	return len;
+	return 0;
 }
-#endif /* CONFIG_PROC_FS */
+
+static struct seq_operations bond_info_seq_ops = {
+	.start = bond_info_seq_start,
+	.next  = bond_info_seq_next,
+	.stop  = bond_info_seq_stop,
+	.show  = bond_info_seq_show,
+};
+
+static int bond_info_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	struct proc_dir_entry *proc;
+	int rc;
+
+	rc = seq_open(file, &bond_info_seq_ops);
+	if (!rc) {
+		/* recover the pointer buried in proc_dir_entry data */
+		seq = file->private_data;
+		proc = PDE(inode);
+		seq->private = proc->data;
+	}
+	return rc;
+}
+
+static struct file_operations bond_info_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = bond_info_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
 
 static int bond_create_proc_info(struct bonding *bond)
 {
-#ifdef CONFIG_PROC_FS
 	struct net_device *dev = bond->device;
 
-	bond->bond_proc_dir = proc_mkdir(dev->name, proc_net);
-	if (bond->bond_proc_dir == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n",
-			dev->name, dev->name);
-		return -ENOMEM;
-	}
-	bond->bond_proc_dir->owner = THIS_MODULE;
-
-	bond->bond_proc_info_file =
-		create_proc_read_entry("info", 0, bond->bond_proc_dir,
-					bond_read_proc, bond);
-	if (bond->bond_proc_info_file == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n",
-			dev->name, dev->name);
-		remove_proc_entry(dev->name, proc_net);
-		return -ENOMEM;
+	if (bond_proc_dir) {
+		bond->bond_proc_file = create_proc_entry(dev->name,
+							 S_IRUGO, 
+							 bond_proc_dir);
+		if (bond->bond_proc_file == NULL) {
+			printk(KERN_WARNING
+			       "%s: Cannot create /proc/net/bonding/%s\n", 
+			       dev->name, dev->name);
+		} else {
+			bond->bond_proc_file->data = bond;
+			bond->bond_proc_file->proc_fops = &bond_info_fops;
+			bond->bond_proc_file->owner = THIS_MODULE;
+			memcpy(bond->procdir_name, dev->name, IFNAMSIZ);
+		}
 	}
-	bond->bond_proc_info_file->owner = THIS_MODULE;
 
-	memcpy(bond->procdir_name, dev->name, IFNAMSIZ);
-#endif /* CONFIG_PROC_FS */
 	return 0;
 }
 
 static void bond_destroy_proc_info(struct bonding *bond)
 {
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("info", bond->bond_proc_dir);
-	remove_proc_entry(bond->procdir_name, proc_net);
-	memset(bond->procdir_name, 0, IFNAMSIZ);
-	bond->bond_proc_dir = NULL;
-#endif /* CONFIG_PROC_FS */
+	if (bond_proc_dir && bond->bond_proc_file) {
+		remove_proc_entry(bond->procdir_name, bond_proc_dir);
+		memset(bond->procdir_name, 0, IFNAMSIZ);
+		bond->bond_proc_file = NULL;
+	}
 }
+#endif /* CONFIG_PROC_FS */
 
 /*
  * Change HW address
@@ -3645,13 +3702,11 @@ unwind:
  */
 static inline int bond_event_changename(struct bonding *bond)
 {
-	int error;
-
+#ifdef CONFIG_PROC_FS
 	bond_destroy_proc_info(bond);
-	error = bond_create_proc_info(bond);
-	if (error) {
-		return NOTIFY_BAD;
-	}
+	bond_create_proc_info(bond);
+#endif
+
 	return NOTIFY_DONE;
 }
 
@@ -3770,13 +3825,15 @@ static struct notifier_block bond_netdev
 	.notifier_call = bond_netdev_event,
 };
 
-static void bond_deinit(struct net_device *dev)
+static inline void bond_deinit(struct net_device *dev)
 {
 	struct bonding *bond = dev->priv;
 
 	list_del(&bond->bond_list);
 
+#ifdef CONFIG_PROC_FS
 	bond_destroy_proc_info(bond);
+#endif
 }
 
 static void bond_free_all(void)
@@ -3790,6 +3847,13 @@ static void bond_free_all(void)
 		bond_deinit(dev);
 		free_netdev(dev);
 	}
+
+#ifdef CONFIG_PROC_FS
+	if (bond_proc_dir) {
+		remove_proc_entry(DRV_NAME, proc_net);
+		bond_proc_dir = NULL;
+	}
+#endif
 }
 
 /*
@@ -3800,7 +3864,6 @@ static int __init bond_init(struct net_d
 {
 	struct bonding *bond;
 	int count;
-	int err = 0;
 
 #ifdef BONDING_DEBUG
 	printk (KERN_INFO "Begin bond_init for %s\n", dev->name);
@@ -3878,27 +3941,14 @@ static int __init bond_init(struct net_d
 	} else {
 		printk("out ARP monitoring\n");
 	}
-
-	err = bond_create_proc_info(bond);
-	if (err) {
-		printk(KERN_ERR "%s: Failed to create proc entry\n",
-			dev->name);
-		return err;
-	}
-
-	/* Future:
-	 * If anything fails beyond this point
-	 * make sure to destroy the proc entry
-	 */
+ 
+#ifdef CONFIG_PROC_FS
+	bond_create_proc_info(bond);
+#endif
 
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
-/*
-err_out:
-	bond_destroy_proc_info(bond);
-	return err;
-*/
 }
 
 /*
@@ -4180,6 +4230,16 @@ static int __init bonding_init(void)
 		primary = NULL;
 	}
 
+#ifdef CONFIG_PROC_FS
+	bond_proc_dir = proc_mkdir(DRV_NAME, proc_net);
+	if (bond_proc_dir == NULL)  {
+		printk(KERN_WARNING
+		       "bonding_init(): can not create /proc/net/" DRV_NAME);
+	} else {
+		bond_proc_dir->owner = THIS_MODULE;
+	}
+#endif
+
 	rtnl_lock();
 
 	err = 0;
