From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6 2/2][v2] bonding: allow user-controlled output
	slave selection
Date: Wed, 2 Jun 2010 14:40:18 -0400
Message-ID: <20100602184018.GL7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab0FBSk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 14:40:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


v2: changed bonding module version, modified to apply on top of changes
from previous patch in series, and updated documentation to elaborate on
multiqueue awareness that now exists in bonding driver.

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
the 'all_slaves_active' flag.  This will allow reception of unicast traffic on
any of the backup interfaces.

This was tested with IPv4-based filters as well as VLAN-based filters
with good results.

More information as well as a configuration example is available in the
patch to Documentation/networking/bonding.txt.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 Documentation/networking/bonding.txt |   84 ++++++++++++++++++++++++-
 drivers/net/bonding/bond_main.c      |   75 +++++++++++++++++++++-
 drivers/net/bonding/bond_sysfs.c     |  116 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |    9 ++-
 include/linux/if_bonding.h           |    1 +
 5 files changed, 278 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 61f516b..d091478 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -49,6 +49,7 @@ Table of Contents
 3.3	Configuring Bonding Manually with Ifenslave
 3.3.1		Configuring Multiple Bonds Manually
 3.4	Configuring Bonding Manually via Sysfs
+3.5	Overriding Configuration for Special Cases
 
 4. Querying Bonding Configuration
 4.1	Bonding Configuration
@@ -1318,8 +1319,87 @@ echo 2000 > /sys/class/net/bond1/bonding/arp_interval
 echo +eth2 > /sys/class/net/bond1/bonding/slaves
 echo +eth3 > /sys/class/net/bond1/bonding/slaves
 
-
-4. Querying Bonding Configuration 
+3.5 Overriding Configuration for Special Cases
+----------------------------------------------
+When using the bonding driver, the physical port which transmits a frame is
+typically selected by the bonding driver, and is not relevant to the user or
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
+Note that qid values begin at 1.  Qid 0 is reserved to initiate to the driver
+that normal output policy selection should take place.  One benefit to simply
+leaving the qid for a slave to 0 is the multiqueue awareness in the bonding
+driver that is now present.  This awareness allows tc filters to be placed on
+slave devices as well as bond devices and the bonding driver will simply act as
+a pass-through for selecting output queues on the slave device rather than 
+output port selection.
+
+This feature first appeared in bonding driver version 3.7.0 and support for
+output slave selection was limited to round-robin and active-backup modes.
+
+4 Querying Bonding Configuration
 =================================
 
 4.1 Bonding Configuration
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f22f6bf..1b19276 100644
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
@@ -1540,6 +1543,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
+	/*
+	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
+	 * is set via sysfs or module option if desired.
+	 */
+	new_slave->queue_id = 0;
+
 	/* Save slave's original mtu and then set it to match the bond */
 	new_slave->original_mtu = slave_dev->mtu;
 	res = dev_set_mtu(slave_dev, bond->dev->mtu);
@@ -3285,6 +3294,7 @@ static void bond_info_show_slave(struct seq_file *seq,
 		else
 			seq_puts(seq, "Aggregator ID: N/A\n");
 	}
+	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
 }
 
 static int bond_info_seq_show(struct seq_file *seq, void *v)
@@ -4421,9 +4431,59 @@ static void bond_set_xmit_hash_policy(struct bonding *bond)
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
@@ -4508,6 +4568,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_open		= bond_open,
 	.ndo_stop		= bond_close,
 	.ndo_start_xmit		= bond_start_xmit,
+	.ndo_select_queue	= bond_select_queue,
 	.ndo_get_stats		= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_set_multicast_list	= bond_set_multicast_list,
@@ -4776,6 +4837,13 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if (tx_queues < 1 || tx_queues > 255) {
+		pr_warning("Warning: tx_queues (%d) should be between "
+			   "1 and 255, resetting to %d\n",
+			   tx_queues, BOND_DEFAULT_TX_QUEUES);
+		tx_queues = BOND_DEFAULT_TX_QUEUES;
+	}
+
 	if ((all_slaves_active != 0) && (all_slaves_active != 1)) {
 		pr_warning("Warning: all_slaves_active module parameter (%d), "
 			   "not of valid value (0/1), so it was set to "
@@ -4953,6 +5021,7 @@ static int bond_check_params(struct bond_params *params)
 	params->primary[0] = 0;
 	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
+	params->tx_queues = tx_queues;
 	params->all_slaves_active = all_slaves_active;
 
 	if (primary) {
@@ -5040,8 +5109,8 @@ int bond_create(struct net *net, const char *name)
 
 	rtnl_lock();
 
-	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
+				bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 066311a..f9a0343 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1412,6 +1412,121 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
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
  * Show and set the all_slaves_active flag.
  */
 static ssize_t bonding_show_slaves_active(struct device *d,
@@ -1489,6 +1604,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_actor_key.attr,
 	&dev_attr_ad_partner_key.attr,
 	&dev_attr_ad_partner_mac.attr,
+	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	NULL,
 };
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index cecdea2..c6fdd85 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,8 +23,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.6.0"
-#define DRV_RELDATE	"September 26, 2009"
+#define DRV_VERSION	"3.7.0"
+#define DRV_RELDATE	"June 2, 2010"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
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
 	int all_slaves_active;
 };
 
@@ -165,6 +169,7 @@ struct slave {
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
1.7.0.1

