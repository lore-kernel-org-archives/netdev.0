From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/2] bonding: extend round-robin mode with packets_per_slave
Date: Tue,  5 Nov 2013 13:51:41 +0100
Message-ID: <1383655902-18744-2-git-send-email-nikolay@redhat.com>
References: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab3KEMzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 07:55:08 -0500
In-Reply-To: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to extend round-robin mode with a new option called
packets_per_slave which can have the following values and effects:
0 - choose a random slave
1 (default) - standard round-robin, 1 packet per slave
 >1 - round-robin when >1 packets have been transmitted per slave
The allowed values are between 0 and 65535.
This patch also fixes the comment style in bond_xmit_roundrobin().

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c  | 55 ++++++++++++++++++++++++++++++++++++----
 drivers/net/bonding/bond_sysfs.c | 49 +++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h    |  3 ++-
 3 files changed, 101 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a141f40..4dd5ee2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -79,6 +79,7 @@
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
 #include <net/flow_keys.h>
+#include <linux/reciprocal_div.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -111,6 +112,7 @@ static char *fail_over_mac;
 static int all_slaves_active;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+static int packets_per_slave = 1;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -183,6 +185,10 @@ MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
 module_param(resend_igmp, int, 0);
 MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on "
 			      "link failure");
+module_param(packets_per_slave, int, 0);
+MODULE_PARM_DESC(packets_per_slave, "Packets to send per slave in balance-rr "
+				    "mode; 0 for a random slave, 1 packet per "
+				    "slave (default), >1 packets per slave.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -3574,14 +3580,44 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 	kfree_skb(skb);
 }
 
+/**
+ * bond_rr_gen_slave_id - generate slave id based on packets_per_slave
+ * @bond: bonding device to use
+ *
+ * Based on the value of the bonding device's packets_per_slave parameter
+ * this function generates a slave id, which is usually used as the next
+ * slave to transmit through.
+ */
+static u32 bond_rr_gen_slave_id(struct bonding *bond)
+{
+	int packets_per_slave = bond->params.packets_per_slave;
+	u32 slave_id;
+
+	switch (packets_per_slave) {
+	case 0:
+		slave_id = prandom_u32();
+		break;
+	case 1:
+		slave_id = bond->rr_tx_counter;
+		break;
+	default:
+		slave_id = reciprocal_divide(bond->rr_tx_counter,
+					     packets_per_slave);
+		break;
+	}
+	bond->rr_tx_counter++;
+
+	return slave_id;
+}
+
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct iphdr *iph = ip_hdr(skb);
 	struct slave *slave;
+	u32 slave_id;
 
-	/*
-	 * Start with the curr_active_slave that joined the bond as the
+	/* Start with the curr_active_slave that joined the bond as the
 	 * default for sending IGMP traffic.  For failover purposes one
 	 * needs to maintain some consistency for the interface that will
 	 * send the join/membership reports.  The curr_active_slave found
@@ -3594,8 +3630,8 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 		else
 			bond_xmit_slave_id(bond, skb, 0);
 	} else {
-		bond_xmit_slave_id(bond, skb,
-				   bond->rr_tx_counter++ % bond->slave_cnt);
+		slave_id = bond_rr_gen_slave_id(bond);
+		bond_xmit_slave_id(bond, skb, slave_id % bond->slave_cnt);
 	}
 
 	return NETDEV_TX_OK;
@@ -4099,6 +4135,12 @@ static int bond_check_params(struct bond_params *params)
 		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 	}
 
+	if (packets_per_slave < 0 || packets_per_slave > USHRT_MAX) {
+		pr_warn("Warning: packets_per_slave (%d) should be between 0 and %u resetting to 1\n",
+			packets_per_slave, USHRT_MAX);
+		packets_per_slave = 1;
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -4288,7 +4330,10 @@ static int bond_check_params(struct bond_params *params)
 	params->resend_igmp = resend_igmp;
 	params->min_links = min_links;
 	params->lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
-
+	if (packets_per_slave > 1)
+		params->packets_per_slave = reciprocal_value(packets_per_slave);
+	else
+		params->packets_per_slave = packets_per_slave;
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
 		params->primary[IFNAMSIZ - 1] = 0;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..75dc4d0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -40,6 +40,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <linux/nsproxy.h>
+#include <linux/reciprocal_div.h>
 
 #include "bonding.h"
 
@@ -1640,6 +1641,53 @@ out:
 static DEVICE_ATTR(lp_interval, S_IRUGO | S_IWUSR,
 		   bonding_show_lp_interval, bonding_store_lp_interval);
 
+static ssize_t bonding_show_packets_per_slave(struct device *d,
+					      struct device_attribute *attr,
+					      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	int packets_per_slave = bond->params.packets_per_slave;
+
+	if (packets_per_slave > 1)
+		packets_per_slave = reciprocal_value(packets_per_slave);
+
+	return sprintf(buf, "%d\n", packets_per_slave);
+}
+
+static ssize_t bonding_store_packets_per_slave(struct device *d,
+					       struct device_attribute *attr,
+					       const char *buf, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int new_value, ret = count;
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no packets_per_slave value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > USHRT_MAX) {
+		pr_err("%s: packets_per_slave must be between 0 and %u\n",
+		       bond->dev->name, USHRT_MAX);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (bond->params.mode != BOND_MODE_ROUNDROBIN)
+		pr_warn("%s: Warning: packets_per_slave has effect only in balance-rr mode\n",
+			bond->dev->name);
+	if (new_value > 1)
+		bond->params.packets_per_slave = reciprocal_value(new_value);
+	else
+		bond->params.packets_per_slave = new_value;
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(packets_per_slave, S_IRUGO | S_IWUSR,
+		   bonding_show_packets_per_slave,
+		   bonding_store_packets_per_slave);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1671,6 +1719,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_resend_igmp.attr,
 	&dev_attr_min_links.attr,
 	&dev_attr_lp_interval.attr,
+	&dev_attr_packets_per_slave.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 046a605..77a07a1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -156,6 +156,7 @@ struct bond_params {
 	int all_slaves_active;
 	int resend_igmp;
 	int lp_interval;
+	int packets_per_slave;
 };
 
 struct bond_parm_tbl {
@@ -222,7 +223,7 @@ struct bonding {
 	char     proc_file_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
-	u16      rr_tx_counter;
+	u32      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
-- 
1.8.1.4
