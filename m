From: Amerigo Wang <amwang@redhat.com>
Subject: [V2 Patch] bonding: move procfs code into bond_procfs.c
Date: Mon,  7 Mar 2011 15:58:46 +0800
Message-ID: <1299484726-29905-1-git-send-email-amwang@redhat.com>
Cc: davem@davemloft.net, WANG Cong <amwang@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252Ab1CGHke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 02:40:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2: Move #ifdef CONFIG_PROC_FS into bonding.h, as suggested by David.

bond_main.c is bloating, separate the procfs code out,
move them to bond_procfs.c

Signed-off-by: WANG Cong <amwang@redhat.com>

---
 drivers/net/bonding/Makefile      |    3 +
 drivers/net/bonding/bond_main.c   |  302 +------------------------------------
 drivers/net/bonding/bond_procfs.c |  276 +++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h     |   26 +++
 4 files changed, 307 insertions(+), 300 deletions(-)

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 0e2737e..3c5c014 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -6,6 +6,9 @@ obj-$(CONFIG_BONDING) += bonding.o
 
 bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o
 
+proc-$(CONFIG_PROC_FS) += bond_procfs.o
+bonding-objs += $(proc-y)
+
 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 584f97b..7abed73 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -65,8 +65,6 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/smp.h>
 #include <linux/if_ether.h>
 #include <net/arp.h>
@@ -173,9 +171,6 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
 atomic_t netpoll_block_tx = ATOMIC_INIT(0);
 #endif
 
-static const char * const version =
-	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";
-
 int bond_net_id __read_mostly;
 
 static __be32 arp_target[BOND_MAX_ARP_TARGETS];
@@ -245,7 +240,7 @@ static void bond_uninit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
 
-static const char *bond_mode_name(int mode)
+const char *bond_mode_name(int mode)
 {
 	static const char *names[] = {
 		[BOND_MODE_ROUNDROBIN] = "load balancing (round-robin)",
@@ -3292,299 +3287,6 @@ out:
 	read_unlock(&bond->lock);
 }
 
-/*------------------------------ proc/seq_file-------------------------------*/
-
-#ifdef CONFIG_PROC_FS
-
-static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-	__acquires(&bond->lock)
-{
-	struct bonding *bond = seq->private;
-	loff_t off = 0;
-	struct slave *slave;
-	int i;
-
-	/* make sure the bond won't be taken away */
-	rcu_read_lock();
-	read_lock(&bond->lock);
-
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	bond_for_each_slave(bond, slave, i) {
-		if (++off == *pos)
-			return slave;
-	}
-
-	return NULL;
-}
-
-static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct bonding *bond = seq->private;
-	struct slave *slave = v;
-
-	++*pos;
-	if (v == SEQ_START_TOKEN)
-		return bond->first_slave;
-
-	slave = slave->next;
-
-	return (slave == bond->first_slave) ? NULL : slave;
-}
-
-static void bond_info_seq_stop(struct seq_file *seq, void *v)
-	__releases(&bond->lock)
-	__releases(RCU)
-{
-	struct bonding *bond = seq->private;
-
-	read_unlock(&bond->lock);
-	rcu_read_unlock();
-}
-
-static void bond_info_show_master(struct seq_file *seq)
-{
-	struct bonding *bond = seq->private;
-	struct slave *curr;
-	int i;
-
-	read_lock(&bond->curr_slave_lock);
-	curr = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
-	seq_printf(seq, "Bonding Mode: %s",
-		   bond_mode_name(bond->params.mode));
-
-	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
-	    bond->params.fail_over_mac)
-		seq_printf(seq, " (fail_over_mac %s)",
-		   fail_over_mac_tbl[bond->params.fail_over_mac].modename);
-
-	seq_printf(seq, "\n");
-
-	if (bond->params.mode == BOND_MODE_XOR ||
-		bond->params.mode == BOND_MODE_8023AD) {
-		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
-			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-			bond->params.xmit_policy);
-	}
-
-	if (USES_PRIMARY(bond->params.mode)) {
-		seq_printf(seq, "Primary Slave: %s",
-			   (bond->primary_slave) ?
-			   bond->primary_slave->dev->name : "None");
-		if (bond->primary_slave)
-			seq_printf(seq, " (primary_reselect %s)",
-		   pri_reselect_tbl[bond->params.primary_reselect].modename);
-
-		seq_printf(seq, "\nCurrently Active Slave: %s\n",
-			   (curr) ? curr->dev->name : "None");
-	}
-
-	seq_printf(seq, "MII Status: %s\n", netif_carrier_ok(bond->dev) ?
-		   "up" : "down");
-	seq_printf(seq, "MII Polling Interval (ms): %d\n", bond->params.miimon);
-	seq_printf(seq, "Up Delay (ms): %d\n",
-		   bond->params.updelay * bond->params.miimon);
-	seq_printf(seq, "Down Delay (ms): %d\n",
-		   bond->params.downdelay * bond->params.miimon);
-
-
-	/* ARP information */
-	if (bond->params.arp_interval > 0) {
-		int printed = 0;
-		seq_printf(seq, "ARP Polling Interval (ms): %d\n",
-				bond->params.arp_interval);
-
-		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
-
-		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
-			if (!bond->params.arp_targets[i])
-				break;
-			if (printed)
-				seq_printf(seq, ",");
-			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
-			printed = 1;
-		}
-		seq_printf(seq, "\n");
-	}
-
-	if (bond->params.mode == BOND_MODE_8023AD) {
-		struct ad_info ad_info;
-
-		seq_puts(seq, "\n802.3ad info\n");
-		seq_printf(seq, "LACP rate: %s\n",
-			   (bond->params.lacp_fast) ? "fast" : "slow");
-		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
-			   ad_select_tbl[bond->params.ad_select].modename);
-
-		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-			seq_printf(seq, "bond %s has no active aggregator\n",
-				   bond->dev->name);
-		} else {
-			seq_printf(seq, "Active Aggregator Info:\n");
-
-			seq_printf(seq, "\tAggregator ID: %d\n",
-				   ad_info.aggregator_id);
-			seq_printf(seq, "\tNumber of ports: %d\n",
-				   ad_info.ports);
-			seq_printf(seq, "\tActor Key: %d\n",
-				   ad_info.actor_key);
-			seq_printf(seq, "\tPartner Key: %d\n",
-				   ad_info.partner_key);
-			seq_printf(seq, "\tPartner Mac Address: %pM\n",
-				   ad_info.partner_system);
-		}
-	}
-}
-
-static void bond_info_show_slave(struct seq_file *seq,
-				 const struct slave *slave)
-{
-	struct bonding *bond = seq->private;
-
-	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
-	seq_printf(seq, "MII Status: %s\n",
-		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
-	seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
-	seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
-	seq_printf(seq, "Link Failure Count: %u\n",
-		   slave->link_failure_count);
-
-	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
-
-	if (bond->params.mode == BOND_MODE_8023AD) {
-		const struct aggregator *agg
-			= SLAVE_AD_INFO(slave).port.aggregator;
-
-		if (agg)
-			seq_printf(seq, "Aggregator ID: %d\n",
-				   agg->aggregator_identifier);
-		else
-			seq_puts(seq, "Aggregator ID: N/A\n");
-	}
-	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
-}
-
-static int bond_info_seq_show(struct seq_file *seq, void *v)
-{
-	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%s\n", version);
-		bond_info_show_master(seq);
-	} else
-		bond_info_show_slave(seq, v);
-
-	return 0;
-}
-
-static const struct seq_operations bond_info_seq_ops = {
-	.start = bond_info_seq_start,
-	.next  = bond_info_seq_next,
-	.stop  = bond_info_seq_stop,
-	.show  = bond_info_seq_show,
-};
-
-static int bond_info_open(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq;
-	struct proc_dir_entry *proc;
-	int res;
-
-	res = seq_open(file, &bond_info_seq_ops);
-	if (!res) {
-		/* recover the pointer buried in proc_dir_entry data */
-		seq = file->private_data;
-		proc = PDE(inode);
-		seq->private = proc->data;
-	}
-
-	return res;
-}
-
-static const struct file_operations bond_info_fops = {
-	.owner   = THIS_MODULE,
-	.open    = bond_info_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release,
-};
-
-static void bond_create_proc_entry(struct bonding *bond)
-{
-	struct net_device *bond_dev = bond->dev;
-	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
-
-	if (bn->proc_dir) {
-		bond->proc_entry = proc_create_data(bond_dev->name,
-						    S_IRUGO, bn->proc_dir,
-						    &bond_info_fops, bond);
-		if (bond->proc_entry == NULL)
-			pr_warning("Warning: Cannot create /proc/net/%s/%s\n",
-				   DRV_NAME, bond_dev->name);
-		else
-			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
-	}
-}
-
-static void bond_remove_proc_entry(struct bonding *bond)
-{
-	struct net_device *bond_dev = bond->dev;
-	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
-
-	if (bn->proc_dir && bond->proc_entry) {
-		remove_proc_entry(bond->proc_file_name, bn->proc_dir);
-		memset(bond->proc_file_name, 0, IFNAMSIZ);
-		bond->proc_entry = NULL;
-	}
-}
-
-/* Create the bonding directory under /proc/net, if doesn't exist yet.
- * Caller must hold rtnl_lock.
- */
-static void __net_init bond_create_proc_dir(struct bond_net *bn)
-{
-	if (!bn->proc_dir) {
-		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
-		if (!bn->proc_dir)
-			pr_warning("Warning: cannot create /proc/net/%s\n",
-				   DRV_NAME);
-	}
-}
-
-/* Destroy the bonding directory under /proc/net, if empty.
- * Caller must hold rtnl_lock.
- */
-static void __net_exit bond_destroy_proc_dir(struct bond_net *bn)
-{
-	if (bn->proc_dir) {
-		remove_proc_entry(DRV_NAME, bn->net->proc_net);
-		bn->proc_dir = NULL;
-	}
-}
-
-#else /* !CONFIG_PROC_FS */
-
-static void bond_create_proc_entry(struct bonding *bond)
-{
-}
-
-static void bond_remove_proc_entry(struct bonding *bond)
-{
-}
-
-static inline void bond_create_proc_dir(struct bond_net *bn)
-{
-}
-
-static inline void bond_destroy_proc_dir(struct bond_net *bn)
-{
-}
-
-#endif /* CONFIG_PROC_FS */
-
-
 /*-------------------------- netdev event handling --------------------------*/
 
 /*
@@ -5388,7 +5090,7 @@ static int __init bonding_init(void)
 	int i;
 	int res;
 
-	pr_info("%s", version);
+	pr_info("%s", bond_version);
 
 	res = bond_check_params(&bonding_defaults);
 	if (res)
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
new file mode 100644
index 0000000..c18a7ce
--- /dev/null
+++ b/drivers/net/bonding/bond_procfs.c
@@ -0,0 +1,276 @@
+#include <linux/proc_fs.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include "bonding.h"
+
+
+extern const char *bond_mode_name(int mode);
+
+static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
+	__acquires(&bond->lock)
+{
+	struct bonding *bond = seq->private;
+	loff_t off = 0;
+	struct slave *slave;
+	int i;
+
+	/* make sure the bond won't be taken away */
+	rcu_read_lock();
+	read_lock(&bond->lock);
+
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+
+	bond_for_each_slave(bond, slave, i) {
+		if (++off == *pos)
+			return slave;
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
+	if (v == SEQ_START_TOKEN)
+		return bond->first_slave;
+
+	slave = slave->next;
+
+	return (slave == bond->first_slave) ? NULL : slave;
+}
+
+static void bond_info_seq_stop(struct seq_file *seq, void *v)
+	__releases(&bond->lock)
+	__releases(RCU)
+{
+	struct bonding *bond = seq->private;
+
+	read_unlock(&bond->lock);
+	rcu_read_unlock();
+}
+
+static void bond_info_show_master(struct seq_file *seq)
+{
+	struct bonding *bond = seq->private;
+	struct slave *curr;
+	int i;
+
+	read_lock(&bond->curr_slave_lock);
+	curr = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+
+	seq_printf(seq, "Bonding Mode: %s",
+		   bond_mode_name(bond->params.mode));
+
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
+	    bond->params.fail_over_mac)
+		seq_printf(seq, " (fail_over_mac %s)",
+		   fail_over_mac_tbl[bond->params.fail_over_mac].modename);
+
+	seq_printf(seq, "\n");
+
+	if (bond->params.mode == BOND_MODE_XOR ||
+		bond->params.mode == BOND_MODE_8023AD) {
+		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
+			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
+			bond->params.xmit_policy);
+	}
+
+	if (USES_PRIMARY(bond->params.mode)) {
+		seq_printf(seq, "Primary Slave: %s",
+			   (bond->primary_slave) ?
+			   bond->primary_slave->dev->name : "None");
+		if (bond->primary_slave)
+			seq_printf(seq, " (primary_reselect %s)",
+		   pri_reselect_tbl[bond->params.primary_reselect].modename);
+
+		seq_printf(seq, "\nCurrently Active Slave: %s\n",
+			   (curr) ? curr->dev->name : "None");
+	}
+
+	seq_printf(seq, "MII Status: %s\n", netif_carrier_ok(bond->dev) ?
+		   "up" : "down");
+	seq_printf(seq, "MII Polling Interval (ms): %d\n", bond->params.miimon);
+	seq_printf(seq, "Up Delay (ms): %d\n",
+		   bond->params.updelay * bond->params.miimon);
+	seq_printf(seq, "Down Delay (ms): %d\n",
+		   bond->params.downdelay * bond->params.miimon);
+
+
+	/* ARP information */
+	if (bond->params.arp_interval > 0) {
+		int printed = 0;
+		seq_printf(seq, "ARP Polling Interval (ms): %d\n",
+				bond->params.arp_interval);
+
+		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
+
+		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
+			if (!bond->params.arp_targets[i])
+				break;
+			if (printed)
+				seq_printf(seq, ",");
+			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
+			printed = 1;
+		}
+		seq_printf(seq, "\n");
+	}
+
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+
+		seq_puts(seq, "\n802.3ad info\n");
+		seq_printf(seq, "LACP rate: %s\n",
+			   (bond->params.lacp_fast) ? "fast" : "slow");
+		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
+			   ad_select_tbl[bond->params.ad_select].modename);
+
+		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+			seq_printf(seq, "bond %s has no active aggregator\n",
+				   bond->dev->name);
+		} else {
+			seq_printf(seq, "Active Aggregator Info:\n");
+
+			seq_printf(seq, "\tAggregator ID: %d\n",
+				   ad_info.aggregator_id);
+			seq_printf(seq, "\tNumber of ports: %d\n",
+				   ad_info.ports);
+			seq_printf(seq, "\tActor Key: %d\n",
+				   ad_info.actor_key);
+			seq_printf(seq, "\tPartner Key: %d\n",
+				   ad_info.partner_key);
+			seq_printf(seq, "\tPartner Mac Address: %pM\n",
+				   ad_info.partner_system);
+		}
+	}
+}
+
+static void bond_info_show_slave(struct seq_file *seq,
+				 const struct slave *slave)
+{
+	struct bonding *bond = seq->private;
+
+	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
+	seq_printf(seq, "MII Status: %s\n",
+		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
+	seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
+	seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
+	seq_printf(seq, "Link Failure Count: %u\n",
+		   slave->link_failure_count);
+
+	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
+
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		const struct aggregator *agg
+			= SLAVE_AD_INFO(slave).port.aggregator;
+
+		if (agg)
+			seq_printf(seq, "Aggregator ID: %d\n",
+				   agg->aggregator_identifier);
+		else
+			seq_puts(seq, "Aggregator ID: N/A\n");
+	}
+	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
+}
+
+static int bond_info_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, "%s\n", bond_version);
+		bond_info_show_master(seq);
+	} else
+		bond_info_show_slave(seq, v);
+
+	return 0;
+}
+
+static const struct seq_operations bond_info_seq_ops = {
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
+	int res;
+
+	res = seq_open(file, &bond_info_seq_ops);
+	if (!res) {
+		/* recover the pointer buried in proc_dir_entry data */
+		seq = file->private_data;
+		proc = PDE(inode);
+		seq->private = proc->data;
+	}
+
+	return res;
+}
+
+static const struct file_operations bond_info_fops = {
+	.owner   = THIS_MODULE,
+	.open    = bond_info_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+void bond_create_proc_entry(struct bonding *bond)
+{
+	struct net_device *bond_dev = bond->dev;
+	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
+
+	if (bn->proc_dir) {
+		bond->proc_entry = proc_create_data(bond_dev->name,
+						    S_IRUGO, bn->proc_dir,
+						    &bond_info_fops, bond);
+		if (bond->proc_entry == NULL)
+			pr_warning("Warning: Cannot create /proc/net/%s/%s\n",
+				   DRV_NAME, bond_dev->name);
+		else
+			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
+	}
+}
+
+void bond_remove_proc_entry(struct bonding *bond)
+{
+	struct net_device *bond_dev = bond->dev;
+	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
+
+	if (bn->proc_dir && bond->proc_entry) {
+		remove_proc_entry(bond->proc_file_name, bn->proc_dir);
+		memset(bond->proc_file_name, 0, IFNAMSIZ);
+		bond->proc_entry = NULL;
+	}
+}
+
+/* Create the bonding directory under /proc/net, if doesn't exist yet.
+ * Caller must hold rtnl_lock.
+ */
+void __net_init bond_create_proc_dir(struct bond_net *bn)
+{
+	if (!bn->proc_dir) {
+		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
+		if (!bn->proc_dir)
+			pr_warning("Warning: cannot create /proc/net/%s\n",
+				   DRV_NAME);
+	}
+}
+
+/* Destroy the bonding directory under /proc/net, if empty.
+ * Caller must hold rtnl_lock.
+ */
+void __net_exit bond_destroy_proc_dir(struct bond_net *bn)
+{
+	if (bn->proc_dir) {
+		remove_proc_entry(DRV_NAME, bn->net->proc_net);
+		bn->proc_dir = NULL;
+	}
+}
+
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a401b8d..8e8691a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -29,6 +29,8 @@
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
+#define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
+
 #define BOND_MAX_ARP_TARGETS	16
 
 #define IS_UP(dev)					   \
@@ -413,6 +415,30 @@ struct bond_net {
 #endif
 };
 
+#ifdef CONFIG_PROC_FS
+void bond_create_proc_entry(struct bonding *bond);
+void bond_remove_proc_entry(struct bonding *bond);
+void bond_create_proc_dir(struct bond_net *bn);
+void bond_destroy_proc_dir(struct bond_net *bn);
+#else
+static inline void bond_create_proc_entry(struct bonding *bond)
+{
+}
+
+static inline void bond_remove_proc_entry(struct bonding *bond)
+{
+}
+
+static inline void bond_create_proc_dir(struct bond_net *bn)
+{
+}
+
+static inline void bond_destroy_proc_dir(struct bond_net *bn)
+{
+}
+#endif
+
+
 /* exported from bond_main.c */
 extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
