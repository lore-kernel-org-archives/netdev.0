From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convering bonding driver /proc interface to seq_file
Date: Thu, 21 Aug 2003 16:52:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821165258.45f1ec53.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch converts /proc/net/bondXX/info to the seq_file interface;
patch is against 2.6.0-test3; but seq_file has been backported to latest
2.4 as well.

It also fixes a bug with multiple bond devices.  The original code
mushes all the bond device status information together.  In other words,
/proc/net/bond0/info gives the same output as /proc/net/bond1/info.

I fixed this in this version, by stuffing a link back to the bonding
data structure in the created proc_dir_entry; which is then used
to only pickup the slaves for that pseudo-device.

Don't think anyone ever used more that one device, because they
probably would have noticed this.

The name "/proc/net/bond0/info" is kind of unconventional, but now
changing that in a almost stable release would be bad.  Better choice
would be "/proc/net/bonding/bond0".

--- linux-2.5/drivers/net/bonding/bond_main.c	2003-08-20 11:19:42.000000000 -0700
+++ linux-2.5-net/drivers/net/bonding/bond_main.c	2003-08-21 16:42:57.130509618 -0700
@@ -402,6 +402,8 @@
 #include <linux/inetdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 
@@ -545,14 +547,6 @@
 static int bond_release_all(struct net_device *master);
 static int bond_sethwaddr(struct net_device *master, struct net_device *slave);
 
-/*
- * bond_get_info is the interface into the /proc filesystem.  This is
- * a different interface than the BOND_INFO_QUERY ioctl.  That is done
- * through the generic networking ioctl interface, and bond_info_query
- * is the internal function which provides that information.
- */
-static int bond_get_info(char *buf, char **start, off_t offset, int length);
-
 /* Caller must hold bond->ptrlock for write */
 static inline struct slave*
 bond_assign_current_slave(struct bonding *bond,struct slave *newslave)
@@ -3327,133 +3321,195 @@
 	return stats;
 }
 
-static int bond_get_info(char *buf, char **start, off_t offset, int length)
-{
-	bonding_t *bond;
-	int len = 0;
-	off_t begin = 0;
-	u16 link;
-	slave_t *slave = NULL;
+#ifdef CONFIG_PROC_FS
 
-	len += sprintf(buf + len, "%s\n", version);
+#define BOND_PROC_HEADER ((void *)1)	/* magic pointer for header line */
+
+static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	bonding_t *bond = seq->private;
+	loff_t off = 0;
+	slave_t *slave;
 
 	read_lock(&dev_base_lock);
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
-		/*
-		 * This function locks the mutex, so we can't lock it until 
-		 * afterwards
-		 */
-		link = bond_check_mii_link(bond);
 
-		len += sprintf(buf + len, "Bonding Mode: %s\n",
-			       bond_mode_name());
+	if (*pos == 0)
+		return BOND_PROC_HEADER;
 
-		if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
-		    (bond_mode == BOND_MODE_TLB) ||
-		    (bond_mode == BOND_MODE_ALB)) {
-			read_lock_bh(&bond->lock);
-			read_lock(&bond->ptrlock);
-			if (bond->current_slave != NULL) {
-				len += sprintf(buf + len, 
-					"Currently Active Slave: %s\n", 
-					bond->current_slave->dev->name);
-			}
-			read_unlock(&bond->ptrlock);
-			read_unlock_bh(&bond->lock);
-		}
-
-		len += sprintf(buf + len, "MII Status: ");
-		len += sprintf(buf + len, 
-				link == BMSR_LSTATUS ? "up\n" : "down\n");
-		len += sprintf(buf + len, "MII Polling Interval (ms): %d\n", 
-				miimon);
-		len += sprintf(buf + len, "Up Delay (ms): %d\n", 
-				updelay * miimon);
-		len += sprintf(buf + len, "Down Delay (ms): %d\n", 
-				downdelay * miimon);
-		len += sprintf(buf + len, "Multicast Mode: %s\n",
-			       multicast_mode_name());
+	read_lock_bh(&bond->lock);
+	for (slave = bond->prev; slave != (slave_t *)bond; slave = slave->prev) {
+		if (++off == *pos)
+			return slave;
+	}
+	
+	return NULL;
+}
+
+static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	bonding_t *bond = seq->private;
+	slave_t *slave = v;
 
+	++*pos;
+	if (v == BOND_PROC_HEADER) {
 		read_lock_bh(&bond->lock);
+		slave = bond->prev;
+	} else {
+		slave = slave->prev;
+	}
+	return (slave == (slave_t *) bond) ? NULL : slave;
+}
 
-		if (bond_mode == BOND_MODE_8023AD) {
-			struct ad_info ad_info;
+static void bond_info_seq_stop(struct seq_file *seq, void *v)
+{
+	bonding_t *bond = seq->private;
+
+	if (v != BOND_PROC_HEADER)
+		read_unlock_bh(&bond->lock);
+	read_unlock(&dev_base_lock);
+}
 
-			len += sprintf(buf + len, "\n802.3ad info\n");
+static void bond_info_show_master(struct seq_file *seq, bonding_t *bond)
+{
+	u16 link = bond_check_mii_link(bond);
 
-			if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-				len += sprintf(buf + len, "bond %s has no active aggregator\n", bond->device->name);
-			} else {
-				len += sprintf(buf + len, "Active Aggregator Info:\n");
+	seq_printf(seq, "Bonding Mode: %s\n",
+		   bond_mode_name());
 
-				len += sprintf(buf + len, "\tAggregator ID: %d\n", ad_info.aggregator_id);
-				len += sprintf(buf + len, "\tNumber of ports: %d\n", ad_info.ports);
-				len += sprintf(buf + len, "\tActor Key: %d\n", ad_info.actor_key);
-				len += sprintf(buf + len, "\tPartner Key: %d\n", ad_info.partner_key);
-				len += sprintf(buf + len, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-					       ad_info.partner_system[0],
-					       ad_info.partner_system[1],
-					       ad_info.partner_system[2],
-					       ad_info.partner_system[3],
-					       ad_info.partner_system[4],
-					       ad_info.partner_system[5]);
-			}
+	if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
+	    (bond_mode == BOND_MODE_TLB) ||
+	    (bond_mode == BOND_MODE_ALB)) {
+		read_lock_bh(&bond->lock);
+		read_lock(&bond->ptrlock);
+		if (bond->current_slave != NULL) {
+			seq_printf(seq, 
+				   "Currently Active Slave: %s\n", 
+				   bond->current_slave->dev->name);
 		}
+		read_unlock(&bond->ptrlock);
+		read_unlock_bh(&bond->lock);
+	}
 
-		for (slave = bond->prev; slave != (slave_t *)bond; 
-		     slave = slave->prev) {
-			len += sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->name);
-
-			len += sprintf(buf + len, "MII Status: ");
-
-			len += sprintf(buf + len, 
-				slave->link == BOND_LINK_UP ? 
-				"up\n" : "down\n");
-			len += sprintf(buf + len, "Link Failure Count: %d\n", 
-				slave->link_failure_count);
-
-			if (app_abi_ver >= 1) {
-				len += sprintf(buf + len,
-					       "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
-					       slave->perm_hwaddr[0],
-					       slave->perm_hwaddr[1],
-					       slave->perm_hwaddr[2],
-					       slave->perm_hwaddr[3],
-					       slave->perm_hwaddr[4],
-					       slave->perm_hwaddr[5]);
-			}
+	seq_printf(seq, "MII Status: ");
+	seq_printf(seq, 
+		   link == BMSR_LSTATUS ? "up\n" : "down\n");
+	seq_printf(seq, "MII Polling Interval (ms): %d\n", 
+		   miimon);
+	seq_printf(seq, "Up Delay (ms): %d\n", 
+		   updelay * miimon);
+	seq_printf(seq, "Down Delay (ms): %d\n", 
+		   downdelay * miimon);
+	seq_printf(seq, "Multicast Mode: %s\n",
+		   multicast_mode_name());
 
-			if (bond_mode == BOND_MODE_8023AD) {
-				struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
-				if (agg) {
-					len += sprintf(buf + len, "Aggregator ID: %d\n",
-						       agg->aggregator_identifier);
-				} else {
-					len += sprintf(buf + len, "Aggregator ID: N/A\n");
-				}
-			}
-		}
-		read_unlock_bh(&bond->lock);
+	if (bond_mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
 
-		/*
-		 * Figure out the calcs for the /proc/net interface
-		 */
-		*start = buf + (offset - begin);
-		len -= (offset - begin);
-		if (len > length) {
-			len = length;
-		}
-		if (len < 0) {
-			len = 0;
+		seq_printf(seq, "\n802.3ad info\n");
+
+		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+			seq_printf(seq, "bond %s has no active aggregator\n", bond->device->name);
+		} else {
+			seq_printf(seq, "Active Aggregator Info:\n");
+
+			seq_printf(seq, "\tAggregator ID: %d\n", ad_info.aggregator_id);
+			seq_printf(seq, "\tNumber of ports: %d\n", ad_info.ports);
+			seq_printf(seq, "\tActor Key: %d\n", ad_info.actor_key);
+			seq_printf(seq, "\tPartner Key: %d\n", ad_info.partner_key);
+			seq_printf(seq, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+				   ad_info.partner_system[0],
+				   ad_info.partner_system[1],
+				   ad_info.partner_system[2],
+				   ad_info.partner_system[3],
+				   ad_info.partner_system[4],
+				   ad_info.partner_system[5]);
 		}
+	}
+
+}
+
+static void bond_info_show_slave(struct seq_file *seq, const slave_t *slave)
+{
+
+	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 
+	seq_printf(seq, "MII Status: ");
+
+	seq_printf(seq, 
+		   slave->link == BOND_LINK_UP ? 
+		   "up\n" : "down\n");
+	seq_printf(seq, "Link Failure Count: %d\n", 
+		   slave->link_failure_count);
+
+	if (app_abi_ver >= 1) {
+		seq_printf(seq,
+			   "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
+			   slave->perm_hwaddr[0],
+			   slave->perm_hwaddr[1],
+			   slave->perm_hwaddr[2],
+			   slave->perm_hwaddr[3],
+			   slave->perm_hwaddr[4],
+			   slave->perm_hwaddr[5]);
 	}
-	read_unlock(&dev_base_lock);
 
-	return len;
+	if (bond_mode == BOND_MODE_8023AD) {
+		const struct aggregator *agg
+			= SLAVE_AD_INFO(slave).port.aggregator;
+
+		if (agg) 
+			seq_printf(seq, "Aggregator ID: %d\n",
+				   agg->aggregator_identifier);
+		else
+			seq_printf(seq, "Aggregator ID: N/A\n");
+	}
+}
+
+static int bond_info_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == BOND_PROC_HEADER) {
+		seq_printf(seq, "%s\n", version);
+		bond_info_show_master(seq, seq->private);
+	} else 
+		bond_info_show_slave(seq, v);
+	return 0;
 }
 
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
+
+
+#endif
+
 static int bond_event(struct notifier_block *this, unsigned long event, 
 			void *ptr)
 {
@@ -3560,15 +3616,15 @@
 	bond->bond_proc_dir->owner = THIS_MODULE;
 
 	bond->bond_proc_info_file = 
-		create_proc_info_entry("info", 0, bond->bond_proc_dir, 
-					bond_get_info);
+		create_proc_entry("info", 0, bond->bond_proc_dir);
 	if (bond->bond_proc_info_file == NULL) {
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
 			dev->name, dev->name);
 		remove_proc_entry(dev->name, proc_net);
 		return -ENOMEM;
 	}
-	bond->bond_proc_info_file->owner = THIS_MODULE;
+	bond->bond_proc_info_file->data = bond;
+	bond->bond_proc_info_file->proc_fops = &bond_info_fops;
 #endif /* CONFIG_PROC_FS */
 
 
