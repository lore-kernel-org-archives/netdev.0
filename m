From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v4 4/4] bonding: Add tlb_dynamic_lb parameter for tlb mode
Date: Wed,  2 Apr 2014 17:33:24 -0700
Message-ID: <1396485204-4111-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:56488 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933628AbaDCAlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 20:41:24 -0400
Received: by mail-pd0-f201.google.com with SMTP id x10so182529pdj.4
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 17:41:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aggresive load balancing causes packet re-ordering as active
flows are moved from a slave to another within the group. Sometime
this aggresive lb is not necessary if the preference is for less
re-ordering. This parameter if used with value "0" disables
this dynamic flow shuffling minimizing packet re-ordering. Of course
the side effect is that it has to live with the static load balancing
that the hashing distribution provides. This impact is less severe if
the correct xmit-hashing-policy is used for the tlb setup.

The default value of the parameter is set to "1" mimicing the earlier
behavior.

Ran the netperf test with 200 stream for 1 min between two hosts with
4x1G trunk (xmit-lb mode with xmit-policy L3+4) before and after these
changes. Following was the command used for those 200 instances -

    netperf -t TCP_RR -l 60 -s 5 -H <host> -- -r81920,81920

Transactions per second:
    Before change: 1,367.11
    After  change: 1,470.65

Change-Id: Ie3f75c77282cf602e83a6e833c6eb164e72a0990
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v2:
  [Trivial] Commit log update with the proper workload and perf numbers.
v3:
  [Trivial] Styling changes.
  Simplified set() by using built-in BOND_OPTFLAG_IFDOWN flag. 
v4:
  tlb_dynamic_lb is no longer a module parameter
  Removed conditional work-queue initialization/cancellation for lb mode.
  [Trivial] Styling changes.
  [Trivial] Documentation changes.

 Documentation/networking/bonding.txt | 42 ++++++++++++++++++++++++++++++------
 drivers/net/bonding/bond_alb.c       | 19 ++++++++++++----
 drivers/net/bonding/bond_main.c      |  4 +++-
 drivers/net/bonding/bond_options.c   | 27 +++++++++++++++++++++++
 drivers/net/bonding/bond_options.h   |  1 +
 drivers/net/bonding/bond_sysfs.c     | 29 +++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |  1 +
 7 files changed, 111 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a97c567f24e8..9c723ecd0025 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -585,13 +585,19 @@ mode
 	balance-tlb or 5
 
 		Adaptive transmit load balancing: channel bonding that
-		does not require any special switch support.  The
-		outgoing traffic is distributed according to the
-		current load (computed relative to the speed) on each
-		slave.  Incoming traffic is received by the current
-		slave.  If the receiving slave fails, another slave
-		takes over the MAC address of the failed receiving
-		slave.
+		does not require any special switch support.
+
+		In tlb_dynamic_lb=1 mode; the outgoing traffic is
+		distributed according to the current load (computed
+		relative to the speed) on each slave.
+
+		In tlb_dynamic_lb=0 mode; the load balancing based on
+		current load is disabled and the load is distributed
+		only using the hash distribution.
+
+		Incoming traffic is received by the current slave.
+		If the receiving slave fails, another slave takes over
+		the MAC address of the failed receiving slave.
 
 		Prerequisite:
 
@@ -736,6 +742,28 @@ primary_reselect
 
 	This option was added for bonding version 3.6.0.
 
+tlb_dynamic_lb
+
+	Specifies if dynamic shuffling of flows is enabled in tlb
+	mode. The value has no effect on any other modes.
+
+	The default behavior of tlb mode is to shuffle active flows across
+	slaves based on the load in that interval. This gives nice lb
+	characteristics but can cause packet reordering. If re-ordering is
+	a concern use this variable to disable flow shuffling and rely on
+	load balancing provided solely by the hash distribution.
+	xmit-hash-policy can be used to select the appropriate hashing for
+	the setup.
+
+	The sysfs entry can be used to change the setting per bond device
+	and the initial value is derived from the module parameter. The
+	sysfs entry is allowed to be changed only if the bond device is
+	down.
+
+	The default value is "1" that enables flow shuffling while value "0"
+	disables it. This option was added in bonding driver 3.7.1
+
+
 updelay
 
 	Specifies the time, in milliseconds, to wait before enabling a
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 153232ed4b3f..70de039dad2e 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1356,7 +1356,8 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 	if (!tx_slave) {
 		/* unbalanced or unassigned, send through primary */
 		tx_slave = rcu_dereference(bond->curr_active_slave);
-		bond_info->unbalanced_load += skb->len;
+		if (bond->params.tlb_dynamic_lb)
+			bond_info->unbalanced_load += skb->len;
 	}
 
 	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
@@ -1369,7 +1370,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 		goto out;
 	}
 
-	if (tx_slave) {
+	if (tx_slave && bond->params.tlb_dynamic_lb) {
 		_lock_tx_hashtbl(bond);
 		__tlb_clear_slave(bond, tx_slave, 0);
 		_unlock_tx_hashtbl(bond);
@@ -1399,11 +1400,21 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		    /* In case of IPX, it will falback to L2 hash */
 		case htons(ETH_P_IPV6):
 			hash_index = bond_xmit_hash(bond, skb);
-			tx_slave = tlb_choose_channel(bond, hash_index & 0xFF, skb->len);
+			if (bond->params.tlb_dynamic_lb) {
+				tx_slave = tlb_choose_channel(bond,
+							      hash_index & 0xFF,
+							      skb->len);
+			} else {
+				struct list_head *iter;
+				int idx = hash_index % bond->slave_cnt;
+
+				bond_for_each_slave_rcu(bond, tx_slave, iter)
+					if (--idx < 0)
+						break;
+			}
 			break;
 		}
 	}
-
 	return bond_do_alb_xmit(skb, bond, tx_slave);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e2b9d3dd8c3d..eedbfc2d78a2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3096,7 +3096,8 @@ static int bond_open(struct net_device *bond_dev)
 		 */
 		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB)))
 			return -ENOMEM;
-		queue_delayed_work(bond->wq, &bond->alb_work, 0);
+		if (bond->params.tlb_dynamic_lb)
+			queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
 	if (bond->params.miimon)  /* link check interval, in milliseconds. */
@@ -4304,6 +4305,7 @@ static int bond_check_params(struct bond_params *params)
 	params->min_links = min_links;
 	params->lp_interval = lp_interval;
 	params->packets_per_slave = packets_per_slave;
+	params->tlb_dynamic_lb = 1; /* Default value */
 	if (packets_per_slave > 0) {
 		params->reciprocal_packets_per_slave =
 			reciprocal_value(packets_per_slave);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index dc3893841752..9fba7a1e6d51 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -70,6 +70,8 @@ static int bond_option_mode_set(struct bonding *bond,
 				const struct bond_opt_value *newval);
 static int bond_option_slaves_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
+static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
+				  const struct bond_opt_value *newval);
 
 
 static const struct bond_opt_value bond_mode_tbl[] = {
@@ -179,6 +181,12 @@ static const struct bond_opt_value bond_lp_interval_tbl[] = {
 	{ NULL,      -1,      0},
 };
 
+static const struct bond_opt_value bond_tlb_dynamic_lb_tbl[] = {
+	{ "off", 0,  0},
+	{ "on",  1,  BOND_VALFLAG_DEFAULT},
+	{ NULL,  -1, 0}
+};
+
 static const struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -364,6 +372,15 @@ static const struct bond_option bond_opts[] = {
 		.flags = BOND_OPTFLAG_RAWVAL,
 		.set = bond_option_slaves_set
 	},
+	[BOND_OPT_TLB_DYNAMIC_LB] = {
+		.id = BOND_OPT_TLB_DYNAMIC_LB,
+		.name = "dynamic_lb",
+		.desc = "Enable dynamic flow shuffling",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_TLB)),
+		.values = bond_tlb_dynamic_lb_tbl,
+		.flags = BOND_OPTFLAG_IFDOWN,
+		.set = bond_option_tlb_dynamic_lb_set,
+	},
 	{ }
 };
 
@@ -1337,3 +1354,13 @@ err_no_cmd:
 	ret = -EPERM;
 	goto out;
 }
+
+static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
+					  const struct bond_opt_value *newval)
+{
+	pr_info("%s: Setting dynamic-lb to %s (%llu)\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.tlb_dynamic_lb = newval->value;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 12be9e1bfb0c..c1860f06145a 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -62,6 +62,7 @@ enum {
 	BOND_OPT_RESEND_IGMP,
 	BOND_OPT_LP_INTERVAL,
 	BOND_OPT_SLAVES,
+	BOND_OPT_TLB_DYNAMIC_LB,
 	BOND_OPT_LAST
 };
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0e8b268da0a0..431892f1a4ce 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1039,6 +1039,34 @@ static ssize_t bonding_store_lp_interval(struct device *d,
 static DEVICE_ATTR(lp_interval, S_IRUGO | S_IWUSR,
 		   bonding_show_lp_interval, bonding_store_lp_interval);
 
+static ssize_t bonding_show_tlb_dynamic_lb(struct device *d,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	return sprintf(buf, "%d\n", bond->params.tlb_dynamic_lb);
+}
+
+static ssize_t bonding_store_tlb_dynamic_lb(struct device *d,
+					    struct device_attribute *attr,
+					    const char *buf,
+					    size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int ret;
+
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_TLB_DYNAMIC_LB,
+				   (char *)buf);
+	if (!ret)
+		ret = count;
+
+	return ret;
+}
+
+static DEVICE_ATTR(tlb_dynamic_lb, S_IRUGO | S_IWUSR,
+		   bonding_show_tlb_dynamic_lb,
+		   bonding_store_tlb_dynamic_lb);
+
 static ssize_t bonding_show_packets_per_slave(struct device *d,
 					      struct device_attribute *attr,
 					      char *buf)
@@ -1099,6 +1127,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_min_links.attr,
 	&dev_attr_lp_interval.attr,
 	&dev_attr_packets_per_slave.attr,
+	&dev_attr_tlb_dynamic_lb.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c0948ca26389..c1c7c2f12ac4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -174,6 +174,7 @@ struct bond_params {
 	int resend_igmp;
 	int lp_interval;
 	int packets_per_slave;
+	int tlb_dynamic_lb;
 	struct reciprocal_value reciprocal_packets_per_slave;
 };
 
-- 
1.9.1.423.g4596e3a
