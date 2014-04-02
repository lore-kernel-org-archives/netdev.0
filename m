From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v3 5/5] bonding: Add tlb_dynamic_lb module parameter
Date: Wed,  2 Apr 2014 00:00:17 -0700
Message-ID: <1396422017-32099-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:46643 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978AbaDBHAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 03:00:20 -0400
Received: by mail-ob0-f201.google.com with SMTP id gq1so2204023obb.4
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 00:00:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aggresive load balancing causes packet re-ordering as active
flows are moved from a slave to another within the group. Sometime
this aggresive lb is not necessary if the preference is for less
re-ordering. This module parameter if used with value "0" disables
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

 drivers/net/bonding/bond_alb.c     | 19 +++++++++++++++----
 drivers/net/bonding/bond_main.c    | 28 +++++++++++++++++++++++++---
 drivers/net/bonding/bond_options.c | 27 +++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.h |  1 +
 drivers/net/bonding/bond_sysfs.c   | 29 +++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h      |  1 +
 6 files changed, 98 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bf44ab417c54..f29ec54faaf0 100644
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
+
+				int idx = hash_index % bond->slave_cnt;
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
index 1bff382d9291..977f688c2724 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -111,6 +111,7 @@ static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 static int packets_per_slave = 1;
 static int lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
+static int tlb_dynamic_lb = 1;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -191,6 +192,9 @@ module_param(lp_interval, uint, 0);
 MODULE_PARM_DESC(lp_interval, "The number of seconds between instances where "
 			      "the bonding driver sends learning packets to "
 			      "each slaves peer switch. The default is 1.");
+module_param(tlb_dynamic_lb, int, 0644);
+MODULE_PARM_DESC(tlb_dynamic_lb, "Enable periodic flow balancing. "
+				 "The default is 1.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -3046,7 +3050,7 @@ static void bond_work_init_all(struct bonding *bond)
 {
 	INIT_DELAYED_WORK(&bond->mcast_work,
 			  bond_resend_igmp_join_requests_delayed);
-	if (bond_is_lb(bond))
+	if (bond_is_lb(bond) && bond->params.tlb_dynamic_lb)
 		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
@@ -3060,7 +3064,7 @@ static void bond_work_cancel_all(struct bonding *bond)
 {
 	cancel_delayed_work_sync(&bond->mii_work);
 	cancel_delayed_work_sync(&bond->arp_work);
-	if (bond_is_lb(bond))
+	if (bond_is_lb(bond) && bond->params.tlb_dynamic_lb)
 		cancel_delayed_work_sync(&bond->alb_work);
 	cancel_delayed_work_sync(&bond->ad_work);
 	cancel_delayed_work_sync(&bond->mcast_work);
@@ -3098,7 +3102,8 @@ static int bond_open(struct net_device *bond_dev)
 		 */
 		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB)))
 			return -ENOMEM;
-		queue_delayed_work(bond->wq, &bond->alb_work, 0);
+		if (bond->params.tlb_dynamic_lb)
+			queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
 	if (bond->params.miimon)  /* link check interval, in milliseconds. */
@@ -4285,6 +4290,22 @@ static int bond_check_params(struct bond_params *params)
 		lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
 	}
 
+	if (!tlb_dynamic_lb) {
+		if (bond_mode == BOND_MODE_TLB) {
+			pr_notice("Dynamic-lb is disabled.\n");
+		} else {
+			pr_warn("Disabling dynamic-lb is unsupported"
+				" in this mode, force enabling "
+				"dynamic-lb\n");
+			/*
+			 * IMPORTANT: Set it to "1" here so that we
+			 * dont have to worry about validating mode
+			 * before checking value of tlb_dynamic_lb
+			 */
+			tlb_dynamic_lb = 1;
+		}
+	}
+
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
@@ -4306,6 +4327,7 @@ static int bond_check_params(struct bond_params *params)
 	params->min_links = min_links;
 	params->lp_interval = lp_interval;
 	params->packets_per_slave = packets_per_slave;
+	params->tlb_dynamic_lb = tlb_dynamic_lb;
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
