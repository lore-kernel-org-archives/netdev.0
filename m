From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v3 5/5] bonding: initial RCU conversion
Date: Thu,  1 Aug 2013 16:54:51 +0200
Message-ID: <1375368891-9979-6-git-send-email-nikolay@redhat.com>
References: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab3HAO6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 10:58:35 -0400
In-Reply-To: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does the initial bonding conversion to RCU. After it the
following modes are protected by RCU alone: roundrobin, active-backup,
broadcast and xor. Modes ALB/TLB and 3ad still acquire bond->lock for
reading, and will be dealt with later. curr_active_slave needs to be
dereferenced via rcu in the converted modes because the only thing
protecting the slave after this patch is rcu_read_lock, so we need the
proper barrier for weakly ordered archs and to make sure we don't have
stale pointer. It's not tagged with __rcu yet because there's still work
to be done to remove the curr_slave_lock, so sparse will complain when
rcu_assign_pointer and rcu_dereference are used, but the alternative to use
rcu_dereference_protected would've created much bigger code churn which is
more difficult to test and review. That will be converted in time.

1. Active-backup mode
 1.1 Perf recording while doing iperf -P 4
  - old bonding: iperf spent 0.55% in bonding, system spent 0.29% CPU
                 in bonding
  - new bonding: iperf spent 0.29% in bonding, system spent 0.15% CPU
                 in bonding
 1.2. Bandwidth measurements
  - old bonding: 16.1 gbps consistently
  - new bonding: 17.5 gbps consistently

2. Round-robin mode
 2.1 Perf recording while doing iperf -P 4
  - old bonding: iperf spent 0.51% in bonding, system spent 0.24% CPU
                 in bonding
  - new bonding: iperf spent 0.16% in bonding, system spent 0.11% CPU
                 in bonding
 2.2 Bandwidth measurements
  - old bonding: 8 gbps (variable due to packet reorderings)
  - new bonding: 10 gbps (variable due to packet reorderings)

Of course the latency has improved in all converted modes, and moreover
while
doing enslave/release (since it doesn't affect tx anymore).

Also I've stress tested all modes doing enslave/release in a loop while
transmitting traffic.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v3: no change
v2: include performance notes, convert curr_active_slave use in bond_sysfs
to RCU, fix a potential latency issue in slave release because TX was
unblocked after synchronize_rcu which might take a while, introduce new
primitive bond_for_each_slave_rcu

 drivers/net/bonding/bond_3ad.c   |  2 ++
 drivers/net/bonding/bond_alb.c   |  6 ++++--
 drivers/net/bonding/bond_main.c  | 30 +++++++++++++++---------------
 drivers/net/bonding/bond_sysfs.c | 19 +++++++------------
 drivers/net/bonding/bonding.h    |  4 ++++
 5 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7d46fa8..9010265 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2426,6 +2426,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	struct ad_info ad_info;
 	int res = 1;
 
+	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2475,6 +2476,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 out:
+	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 4d35196..3a5db7b 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1337,6 +1337,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 	/* make sure that the curr_active_slave do not change during tx
 	 */
+	read_lock(&bond->lock);
 	read_lock(&bond->curr_slave_lock);
 
 	switch (ntohs(skb->protocol)) {
@@ -1441,11 +1442,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	}
 
 	read_unlock(&bond->curr_slave_lock);
-
+	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
 	}
+
 	return NETDEV_TX_OK;
 }
 
@@ -1663,7 +1665,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	}
 
 	swap_slave = bond->curr_active_slave;
-	bond->curr_active_slave = new_slave;
+	rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
 	if (!new_slave || list_empty(&bond->slave_list))
 		return;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 196febb..b83618c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -77,6 +77,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/pkt_sched.h>
+#include <linux/rculist.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -1037,7 +1038,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		if (new_active)
 			bond_set_slave_active_flags(new_active);
 	} else {
-		bond->curr_active_slave = new_active;
+		rcu_assign_pointer(bond->curr_active_slave, new_active);
 	}
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
@@ -1127,7 +1128,7 @@ void bond_select_active_slave(struct bonding *bond)
  */
 static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 {
-	list_add_tail(&new_slave->list, &bond->slave_list);
+	list_add_tail_rcu(&new_slave->list, &bond->slave_list);
 	bond->slave_cnt++;
 }
 
@@ -1143,7 +1144,7 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
  */
 static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 {
-	list_del(&slave->list);
+	list_del_rcu(&slave->list);
 	bond->slave_cnt--;
 }
 
@@ -1751,7 +1752,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * so we can change it without calling change_active_interface()
 		 */
 		if (!bond->curr_active_slave && new_slave->link == BOND_LINK_UP)
-			bond->curr_active_slave = new_slave;
+			rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
 		break;
 	} /* switch(bond_mode) */
@@ -1951,7 +1952,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	if (all) {
-		bond->curr_active_slave = NULL;
+		rcu_assign_pointer(bond->curr_active_slave, NULL);
 	} else if (oldcurrent == slave) {
 		/*
 		 * Note that we hold RTNL over this sequence, so there
@@ -1983,6 +1984,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
+	synchronize_rcu();
 
 	if (list_empty(&bond->slave_list)) {
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
@@ -3811,7 +3813,7 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 	int i = slave_id;
 
 	/* Here we start from the slave with slave_id */
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (--i < 0) {
 			if (slave_can_tx(slave)) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
@@ -3822,7 +3824,7 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 
 	/* Here we start from the first slave up to slave_id */
 	i = slave_id;
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (--i < 0)
 			break;
 		if (slave_can_tx(slave)) {
@@ -3848,7 +3850,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 * will send all of this type of traffic.
 	 */
 	if (iph->protocol == IPPROTO_IGMP && skb->protocol == htons(ETH_P_IP)) {
-		slave = bond->curr_active_slave;
+		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave && slave_can_tx(slave))
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 		else
@@ -3870,7 +3872,7 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 
-	slave = bond->curr_active_slave;
+	slave = rcu_dereference(bond->curr_active_slave);
 	if (slave)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
@@ -3900,7 +3902,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave = NULL;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (bond_is_last_slave(bond, slave))
 			break;
 		if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
@@ -3955,7 +3957,7 @@ static inline int bond_slave_override(struct bonding *bond,
 		return 1;
 
 	/* Find out if any slaves have the same mapping as this skb. */
-	bond_for_each_slave(bond, check_slave) {
+	bond_for_each_slave_rcu(bond, check_slave) {
 		if (check_slave->queue_id == skb->queue_mapping) {
 			slave = check_slave;
 			break;
@@ -4040,14 +4042,12 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (is_netpoll_tx_blocked(dev))
 		return NETDEV_TX_BUSY;
 
-	read_lock(&bond->lock);
-
+	rcu_read_lock();
 	if (!list_empty(&bond->slave_list))
 		ret = __bond_start_xmit(skb, dev);
 	else
 		kfree_skb(skb);
-
-	read_unlock(&bond->lock);
+	rcu_read_unlock();
 
 	return ret;
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0702e91..0f539de 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1243,16 +1243,16 @@ static ssize_t bonding_show_active_slave(struct device *d,
 					 struct device_attribute *attr,
 					 char *buf)
 {
-	struct slave *curr;
 	struct bonding *bond = to_bond(d);
+	struct slave *curr;
 	int count = 0;
 
-	read_lock(&bond->curr_slave_lock);
-	curr = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
+	rcu_read_lock();
+	curr = rcu_dereference(bond->curr_active_slave);
 	if (USES_PRIMARY(bond->params.mode) && curr)
 		count = sprintf(buf, "%s\n", curr->dev->name);
+	rcu_read_unlock();
+
 	return count;
 }
 
@@ -1284,7 +1284,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	if (!strlen(ifname) || buf[0] == '\n') {
 		pr_info("%s: Clearing current active slave.\n",
 			bond->dev->name);
-		bond->curr_active_slave = NULL;
+		rcu_assign_pointer(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 		goto out;
 	}
@@ -1347,14 +1347,9 @@ static ssize_t bonding_show_mii_status(struct device *d,
 				       struct device_attribute *attr,
 				       char *buf)
 {
-	struct slave *curr;
 	struct bonding *bond = to_bond(d);
 
-	read_lock(&bond->curr_slave_lock);
-	curr = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
-	return sprintf(buf, "%s\n", curr ? "up" : "down");
+	return sprintf(buf, "%s\n", bond->curr_active_slave ? "up" : "down");
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0995974..4bf52d5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -116,6 +116,10 @@
 #define bond_for_each_slave(bond, pos) \
 	list_for_each_entry(pos, &(bond)->slave_list, list)
 
+/* Caller must have rcu_read_lock */
+#define bond_for_each_slave_rcu(bond, pos) \
+	list_for_each_entry_rcu(pos, &(bond)->slave_list, list)
+
 /**
  * bond_for_each_slave_reverse - iterate in reverse from a given position
  * @bond:	the bond holding this list
-- 
1.8.1.4
