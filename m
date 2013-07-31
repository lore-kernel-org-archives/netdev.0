From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 5/5] bonding: initial RCU conversion
Date: Wed, 31 Jul 2013 17:12:33 +0200
Message-ID: <1375283553-32070-6-git-send-email-nikolay@redhat.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760268Ab3GaPRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 11:17:19 -0400
In-Reply-To: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
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

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c   |  2 ++
 drivers/net/bonding/bond_alb.c   |  6 ++++--
 drivers/net/bonding/bond_main.c  | 30 +++++++++++++++---------------
 drivers/net/bonding/bond_sysfs.c |  2 +-
 4 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 80e288c..bb25aa1 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2424,6 +2424,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	struct ad_info ad_info;
 	int res = 1;
 
+	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2473,6 +2474,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 out:
+	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 41889e3..8f52789 100644
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
 
@@ -1665,7 +1667,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	}
 
 	swap_slave = bond->curr_active_slave;
-	bond->curr_active_slave = new_slave;
+	rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
 	if (!new_slave || (bond->slave_cnt == 0)) {
 		return;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 45ed9b1..126cb50 100644
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
@@ -1038,7 +1039,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		if (new_active)
 			bond_set_slave_active_flags(new_active);
 	} else {
-		bond->curr_active_slave = new_active;
+		rcu_assign_pointer(bond->curr_active_slave, new_active);
 	}
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
@@ -1128,7 +1129,7 @@ void bond_select_active_slave(struct bonding *bond)
  */
 static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 {
-	list_add_tail(&new_slave->list, &bond->slave_list);
+	list_add_tail_rcu(&new_slave->list, &bond->slave_list);
 	bond->slave_cnt++;
 }
 
@@ -1144,7 +1145,7 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
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
@@ -1982,6 +1983,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	write_unlock_bh(&bond->lock);
+	synchronize_rcu();
 	unblock_netpoll_tx();
 
 	if (bond->slave_cnt == 0) {
@@ -3817,7 +3819,7 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 	int i = slave_id;
 
 	/* Here we start from the slave with slave_id */
-	list_for_each_entry(slave, &bond->slave_list, list) {
+	list_for_each_entry_rcu(slave, &bond->slave_list, list) {
 		if (--i < 0) {
 			if (slave_can_tx(slave)) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
@@ -3828,7 +3830,7 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 
 	/* Here we start from the first slave up to slave_id */
 	i = slave_id;
-	list_for_each_entry(slave, &bond->slave_list, list) {
+	list_for_each_entry_rcu(slave, &bond->slave_list, list) {
 		if (--i < 0)
 			break;
 		if (slave_can_tx(slave)) {
@@ -3854,7 +3856,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 * will send all of this type of traffic.
 	 */
 	if (iph->protocol == IPPROTO_IGMP && skb->protocol == htons(ETH_P_IP)) {
-		slave = bond->curr_active_slave;
+		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave && slave_can_tx(slave))
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 		else
@@ -3876,7 +3878,7 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 
-	slave = bond->curr_active_slave;
+	slave = rcu_dereference(bond->curr_active_slave);
 	if (slave)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
@@ -3906,7 +3908,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave = NULL;
 
-	list_for_each_entry(slave, &bond->slave_list, list) {
+	list_for_each_entry_rcu(slave, &bond->slave_list, list) {
 		if (slave->list.next == &bond->slave_list)
 			break;
 		if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
@@ -3961,7 +3963,7 @@ static inline int bond_slave_override(struct bonding *bond,
 		return 1;
 
 	/* Find out if any slaves have the same mapping as this skb. */
-	list_for_each_entry(check_slave, &bond->slave_list, list) {
+	list_for_each_entry_rcu(check_slave, &bond->slave_list, list) {
 		if (check_slave->queue_id == skb->queue_mapping) {
 			slave = check_slave;
 			break;
@@ -4046,14 +4048,12 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (is_netpoll_tx_blocked(dev))
 		return NETDEV_TX_BUSY;
 
-	read_lock(&bond->lock);
-
+	rcu_read_lock();
 	if (bond->slave_cnt)
 		ret = __bond_start_xmit(skb, dev);
 	else
 		kfree_skb(skb);
-
-	read_unlock(&bond->lock);
+	rcu_read_unlock();
 
 	return ret;
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a19b163..3102926 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1284,7 +1284,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	if (!strlen(ifname) || buf[0] == '\n') {
 		pr_info("%s: Clearing current active slave.\n",
 			bond->dev->name);
-		bond->curr_active_slave = NULL;
+		rcu_assign_pointer(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 		goto out;
 	}
-- 
1.8.1.4
