From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output
	slave selection
Date: Mon, 10 May 2010 20:32:45 -0400
Message-ID: <20100511003245.GB7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab0EKAcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 20:32:46 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4B0Wkig026836
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 20:32:46 -0400
Received: from gospo.usersys.redhat.com (gospo.rdu.redhat.com [10.11.228.52])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o4B0WjWF008910
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 20:32:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch give the user the ability to control the output slave for
round-robin and active-backup bonding.  Similar functionality was
discussed in the past, but Jay Vosburgh indicated he would rather see a
feature like this added to existing modes rather than creating a
completely new mode.  Jay's thoughts as well as Neil's input surrounding
some of the issues with the first implementation pushed us toward a
design that relied on the queue_mapping rather than skb marks.
Round-robin and active-backup modes were chosen as the first users of
this slave selection as they seemed like the most logical choices when
considering a multi-switch environment.

Round-robin mode works without any modification, but active-backup does
require inclusion of the first patch in this series and setting
the 'keep_all' flag.  This will allow reception of unicast traffic on
any of the backup interfaces.

This was tested with IPv4-based filters as well as VLAN-based filters
with good results.

More information as well as a configuration example is available in the
patch to Documentation/networking/bonding.txt.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 Documentation/networking/bonding.txt |   76 +++++++++++++++++++++-
 drivers/net/bonding/bond_main.c      |   77 +++++++++++++++++++++-
 drivers/net/bonding/bond_sysfs.c     |  117 +++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bonding.h        |    5 ++
 include/linux/if_bonding.h           |    1 +
 5 files changed, 270 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d64fd2f..fd277c1 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -49,6 +49,7 @@ Table of Contents
 3.3	Configuring Bonding Manually with Ifenslave
 3.3.1		Configuring Multiple Bonds Manually
 3.4	Configuring Bonding Manually via Sysfs
+3.5	Overriding Configuration for Special Cases
 
 4. Querying Bonding Configuration
 4.1	Bonding Configuration
@@ -1333,8 +1334,79 @@ echo 2000 > /sys/class/net/bond1/bonding/arp_interval
 echo +eth2 > /sys/class/net/bond1/bonding/slaves
 echo +eth3 > /sys/class/net/bond1/bonding/slaves
 
-
-4. Querying Bonding Configuration 
+3.5 Overriding Configuration for Special Cases
+----------------------------------------------
+Nominally, when using the bonding driver, the physical port which transmits a
+frame is selected by the bonding driver, and is not relevant to the user or
+system administrator.  The output port is simply selected using the policies of
+the selected bonding mode.  On occasion however, it is helpful to direct certain
+classes of traffic to certain physical interfaces on output to implement
+slightly more complex policies.  For example, to reach a web server over a
+bonded interface in which eth0 connects to a private network, while eth1
+connects via a public network, it may be desirous to bias the bond to send said
+traffic over eth0 first, using eth1 only as a fall back, while all other traffic
+can safely be sent over either interface.  Such configurations may be achieved
+using the traffic control utilities inherent in linux.
+
+By default the bonding driver is multiqueue aware and 16 queues are created
+when the driver initializes (see Documentation/networking/multiqueue.txt
+for details).  If more or less queues are desired the module parameter
+tx_queues can be used to change this value.  There is no sysfs parameter
+available as the allocation is done at module init time.
+
+The output of the file /proc/net/bonding/bondX has changed so the output Queue
+ID is now printed for each slave:
+
+Bonding Mode: fault-tolerance (active-backup)
+Primary Slave: None
+Currently Active Slave: eth0
+MII Status: up
+MII Polling Interval (ms): 0
+Up Delay (ms): 0
+Down Delay (ms): 0
+
+Slave Interface: eth0
+MII Status: up
+Link Failure Count: 0
+Permanent HW addr: 00:1a:a0:12:8f:cb
+Slave queue ID: 0
+
+Slave Interface: eth1
+MII Status: up
+Link Failure Count: 0
+Permanent HW addr: 00:1a:a0:12:8f:cc
+Slave queue ID: 2
+
+The queue_id for a slave can be set using the command:
+
+# echo "eth1:2" > /sys/class/net/bond0/bonding/queue_id
+
+Any interface that needs a queue_id set should set it with multiple calls
+like the one above until proper priorities are set for all interfaces.  On
+distributions that allow configuration via initscripts, multiple 'queue_id'
+arguments can be added to BONDING_OPTS to set all needed slave queues.
+
+These queue id's can be used in conjunction with the tc utility to configure
+a multiqueue qdisc and filters to bias certain traffic to transmit on certain
+slave devices.  For instance, say we wanted, in the above configuration to
+force all traffic bound to 192.168.1.100 to use eth1 in the bond as its output
+device. The following commands would accomplish this:
+
+# tc qdisc add dev bond0 handle 1 root multiq
+
+# tc filter add dev bond0 protocol ip parent 1: prio 1 u32 match ip dst \
+	192.168.1.100 action skbedit queue_mapping 2
+
+These commands tell the kernel to attach a multiqueue queue discipline to the
+bond0 interface and filter traffic enqueued to it, such that packets with a dst
+ip of 192.168.1.100 have their output queue mapping value overwritten to 2.
+This value is then passed into the driver, causing the normal output path
+selection policy to be overridden, selecting instead qid 2, which maps to eth1.
+
+Note that qid values begin at 1.  qid 0 is reserved to initiate to the driver
+that normal output policy selection should take place.
+
+4 Querying Bonding Configuration
 =================================
 
 4.1 Bonding Configuration
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index eb86363..aa6a79a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -90,6 +90,7 @@
 #define BOND_LINK_ARP_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
+static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
 static int num_grat_arp = 1;
 static int num_unsol_na = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
@@ -111,6 +112,8 @@ static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
+module_param(tx_queues, int, 0);
+MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
 module_param(num_grat_arp, int, 0644);
 MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
 module_param(num_unsol_na, int, 0644);
@@ -1532,6 +1535,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
+	/*
+	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
+	 * is set via sysfs or module option if desired.
+	 */
+	new_slave->queue_id = 0;
+
 	/* save slave's original flags before calling
 	 * netdev_set_master and dev_open
 	 */
@@ -1790,6 +1799,7 @@ err_restore_mac:
 	}
 
 err_free:
+	new_slave->queue_id = 0;
 	kfree(new_slave);
 
 err_undo_flags:
@@ -1977,6 +1987,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
 				   IFF_SLAVE_NEEDARP);
 
+	slave->queue_id = 0;
 	kfree(slave);
 
 	return 0;  /* deletion OK */
@@ -3269,6 +3280,7 @@ static void bond_info_show_slave(struct seq_file *seq,
 		else
 			seq_puts(seq, "Aggregator ID: N/A\n");
 	}
+	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
 }
 
 static int bond_info_seq_show(struct seq_file *seq, void *v)
@@ -4405,9 +4417,59 @@ static void bond_set_xmit_hash_policy(struct bonding *bond)
 	}
 }
 
+/*
+ * Lookup the slave that corresponds to a qid
+ */
+static inline int bond_slave_override(struct bonding *bond,
+				      struct sk_buff *skb)
+{
+	int i, res = 1;
+	struct slave *slave = NULL;
+	struct slave *check_slave;
+
+	read_lock(&bond->lock);
+
+	if (!BOND_IS_OK(bond) || !skb->queue_mapping)
+		goto out;
+
+	/* Find out if any slaves have the same mapping as this skb. */
+	bond_for_each_slave(bond, check_slave, i) {
+		if (check_slave->queue_id == skb->queue_mapping) {
+			slave = check_slave;
+			break;
+		}
+	}
+
+	/* If the slave isn't UP, use default transmit policy. */
+	if (slave && slave->queue_id && IS_UP(slave->dev) &&
+	    (slave->link == BOND_LINK_UP)) {
+		res = bond_dev_queue_xmit(bond, skb, slave->dev);
+	}
+
+out:
+	read_unlock(&bond->lock);
+	return res;
+}
+
+static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	/*
+	 * This helper function exists to help dev_pick_tx get the correct
+	 * destination queue.  Using a helper function skips the a call to
+	 * skb_tx_hash and will put the skbs in the queue we expect on their
+	 * way down to the bonding driver.
+	 */
+	return skb->queue_mapping;
+}
+
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	const struct bonding *bond = netdev_priv(dev);
+	struct bonding *bond = netdev_priv(dev);
+
+	if (TX_QUEUE_OVERRIDE(bond->params.mode)) {
+		if (!bond_slave_override(bond, skb))
+			return NETDEV_TX_OK;
+	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_ROUNDROBIN:
@@ -4492,6 +4554,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_open		= bond_open,
 	.ndo_stop		= bond_close,
 	.ndo_start_xmit		= bond_start_xmit,
+	.ndo_select_queue	= bond_select_queue,
 	.ndo_get_stats		= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_set_multicast_list	= bond_set_multicast_list,
@@ -4763,6 +4826,13 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if (tx_queues < 1 || tx_queues > 255) {
+		pr_warning("Warning: tx_queues (%d) should be between "
+			   "1 and 255, resetting to %d\n",
+			   tx_queues, BOND_DEFAULT_TX_QUEUES);
+		tx_queues = BOND_DEFAULT_TX_QUEUES;
+	}
+
 	if ((keep_all != 0) && (keep_all != 1)) {
 		pr_warning("Warning: keep_all module parameter (%d), "
 			   "not of valid value (0/1), so it was set to "
@@ -4940,6 +5010,7 @@ static int bond_check_params(struct bond_params *params)
 	params->primary[0] = 0;
 	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
+	params->tx_queues = tx_queues;
 	params->keep_all = keep_all;
 
 	if (primary) {
@@ -5027,8 +5098,8 @@ int bond_create(struct net *net, const char *name)
 
 	rtnl_lock();
 
-	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
+				bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 44651ce..87bfcf1 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1472,6 +1472,121 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 
 /*
+ * Show the queue_ids of the slaves in the current bond.
+ */
+static ssize_t bonding_show_queue_id(struct device *d,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct slave *slave;
+	int i, res = 0;
+	struct bonding *bond = to_bond(d);
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		if (res > (PAGE_SIZE - 6)) {
+			/* not enough space for another interface name */
+			if ((PAGE_SIZE - res) > 10)
+				res = PAGE_SIZE - 10;
+			res += sprintf(buf + res, "++more++ ");
+			break;
+		}
+		res += sprintf(buf + res, "%s:%d ",
+			       slave->dev->name, slave->queue_id);
+	}
+	read_unlock(&bond->lock);
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
+	rtnl_unlock();
+	return res;
+}
+
+/*
+ * Set the queue_ids of the  slaves in the current bond.  The bond
+ * interface must be enslaved for this to work.
+ */
+static ssize_t bonding_store_queue_id(struct device *d,
+				      struct device_attribute *attr,
+				      const char *buffer, size_t count)
+{
+	struct slave *slave, *update_slave;
+	struct bonding *bond = to_bond(d);
+	u16 qid;
+	int i, ret = count;
+	char *delim;
+	struct net_device *sdev = NULL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	/* delim will point to queue id if successful */
+	delim = strchr(buffer, ':');
+	if (!delim)
+		goto err_no_cmd;
+
+	/*
+	 * Terminate string that points to device name and bump it
+	 * up one, so we can read the queue id there.
+	 */
+	*delim = '\0';
+	if (sscanf(++delim, "%hd\n", &qid) != 1)
+		goto err_no_cmd;
+
+	/* Check buffer length, valid ifname and queue id */
+	if (strlen(buffer) > IFNAMSIZ ||
+	    !dev_valid_name(buffer) ||
+	    qid > bond->params.tx_queues)
+		goto err_no_cmd;
+
+	/* Get the pointer to that interface if it exists */
+	sdev = __dev_get_by_name(dev_net(bond->dev), buffer);
+	if (!sdev)
+		goto err_no_cmd;
+
+	read_lock(&bond->lock);
+
+	/* Search for thes slave and check for duplicate qids */
+	update_slave = NULL;
+	bond_for_each_slave(bond, slave, i) {
+		if (sdev == slave->dev)
+			/*
+			 * We don't need to check the matching
+			 * slave for dups, since we're overwriting it
+			 */
+			update_slave = slave;
+		else if (qid && qid == slave->queue_id) {
+			goto err_no_cmd_unlock;
+		}
+	}
+
+	if (!update_slave)
+		goto err_no_cmd_unlock;
+
+	/* Actually set the qids for the slave */
+	update_slave->queue_id = qid;
+
+	read_unlock(&bond->lock);
+out:
+	rtnl_unlock();
+	return ret;
+
+err_no_cmd_unlock:
+	read_unlock(&bond->lock);
+err_no_cmd:
+	pr_info("invalid input for queue_id set for %s.\n",
+		bond->dev->name);
+	ret = -EPERM;
+	goto out;
+}
+
+static DEVICE_ATTR(queue_id, S_IRUGO | S_IWUSR, bonding_show_queue_id,
+		   bonding_store_queue_id);
+
+
+/*
  * Show and set the keep_all flag.
  */
 static ssize_t bonding_show_keep(struct device *d,
@@ -1513,7 +1628,6 @@ static DEVICE_ATTR(keep_all, S_IRUGO | S_IWUSR,
 		   bonding_show_keep, bonding_store_keep);
 
 
-
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1539,6 +1653,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_actor_key.attr,
 	&dev_attr_ad_partner_key.attr,
 	&dev_attr_ad_partner_mac.attr,
+	&dev_attr_queue_id.attr,
 	&dev_attr_keep_all.attr,
 	NULL,
 };
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 3b7532f..274a3a1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -60,6 +60,9 @@
 		 ((mode) == BOND_MODE_TLB)          ||	\
 		 ((mode) == BOND_MODE_ALB))
 
+#define TX_QUEUE_OVERRIDE(mode)				\
+			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
+			 ((mode) == BOND_MODE_ROUNDROBIN))
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
@@ -131,6 +134,7 @@ struct bond_params {
 	char primary[IFNAMSIZ];
 	int primary_reselect;
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
+	int tx_queues;
 	int keep_all;
 };
 
@@ -166,6 +170,7 @@ struct slave {
 	u8     perm_hwaddr[ETH_ALEN];
 	u16    speed;
 	u8     duplex;
+	u16    queue_id;
 	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
 	struct tlb_slave_info tlb_info;
 };
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index cd525fa..2c79943 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -83,6 +83,7 @@
 
 #define BOND_DEFAULT_MAX_BONDS  1   /* Default maximum number of devices to support */
 
+#define BOND_DEFAULT_TX_QUEUES 16   /* Default number of tx queues per device */
 /* hashing types */
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
-- 
1.6.2.5

