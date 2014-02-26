From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v3 2/2] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for ab arp monitor
Date: Wed, 26 Feb 2014 11:05:23 +0800
Message-ID: <1393383923-40876-3-git-send-email-dingtianhong@huawei.com>
References: <1393383923-40876-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:16020 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbaBZDJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 22:09:13 -0500
In-Reply-To: <1393383923-40876-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav has reported and fix this problem by commit f2ebd477f141bc0
(bonding: restructure locking of bond_ab_arp_probe()). According Jay's
opinion, the current solution is not very well, because the notification
is to indicate that the interface has actually changed state in a meaningful
way, but these calls in the ab ARP monitor are internal settings of the flags
to allow the ARP monitor to search for a slave to become active when there are
no active slaves. The flag setting to active or backup is to permit the ARP
monitor's response logic to do the right thing when deciding if the test
slave (current_arp_slave) is up or not.

So the best way to fix the problem is that we should not send a notification
when the slave is in testing state, and check the state at the end of the
monitor, if the slave's state recover, avoid to send pointless notification
twice. And RTNL is really a big lock, hold it regardless the slave's state
changed or not when the current_active_slave is null will loss performance
(every 100ms), so we should hold it only when the slave's state changed and
need to notify.

I revert the old commit and add new modifications.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c  |  8 +----
 drivers/net/bonding/bond_main.c | 80 +++++++++++++++++++++--------------------
 drivers/net/bonding/bonding.h   | 13 +++++++
 3 files changed, 55 insertions(+), 46 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6826e4f..dcde560 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2130,13 +2130,7 @@ re_arm:
 	read_unlock(&bond->lock);
 
 	if (should_notify_rtnl && rtnl_trylock()) {
-		bond_for_each_slave(bond, slave, iter) {
-			if (slave->should_notify) {
-				rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0,
-					     GFP_KERNEL);
-				slave->should_notify = 0;
-			}
-		}
+		bond_slave_state_notify(bond);
 		rtnl_unlock();
 	}
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e02029b..82b70ff 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2623,17 +2623,17 @@ do_failover:
 
 /*
  * Send ARP probes for active-backup mode ARP monitor.
+ *
+ * Called with rcu_read_lock hold.
  */
 static bool bond_ab_arp_probe(struct bonding *bond)
 {
 	struct slave *slave, *before = NULL, *new_slave = NULL,
-		     *curr_arp_slave, *curr_active_slave;
+		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave),
+		     *curr_active_slave = rcu_dereference(bond->curr_active_slave);
 	struct list_head *iter;
 	bool found = false;
-
-	rcu_read_lock();
-	curr_arp_slave = rcu_dereference(bond->current_arp_slave);
-	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
 
 	if (curr_arp_slave && curr_active_slave)
 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
@@ -2642,32 +2642,23 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 
 	if (curr_active_slave) {
 		bond_arp_send_all(bond, curr_active_slave);
-		rcu_read_unlock();
-		return true;
+		return should_notify_rtnl;
 	}
-	rcu_read_unlock();
 
 	/* if we don't have a curr_active_slave, search for the next available
 	 * backup slave from the current_arp_slave and make it the candidate
 	 * for becoming the curr_active_slave
 	 */
 
-	if (!rtnl_trylock())
-		return false;
-	/* curr_arp_slave might have gone away */
-	curr_arp_slave = ACCESS_ONCE(bond->current_arp_slave);
-
 	if (!curr_arp_slave) {
-		curr_arp_slave = bond_first_slave(bond);
-		if (!curr_arp_slave) {
-			rtnl_unlock();
-			return true;
-		}
+		curr_arp_slave = bond_first_slave_rcu(bond);
+		if (!curr_arp_slave)
+			return should_notify_rtnl;
 	}
 
-	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_NOW);
+	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (!found && !before && IS_UP(slave->dev))
 			before = slave;
 
@@ -2686,7 +2677,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 				slave->link_failure_count++;
 
 			bond_set_slave_inactive_flags(slave,
-						      BOND_SLAVE_NOTIFY_NOW);
+						      BOND_SLAVE_NOTIFY_LATER);
 
 			pr_info("%s: backup interface %s is now down.\n",
 				bond->dev->name, slave->dev->name);
@@ -2698,26 +2689,31 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	if (!new_slave && before)
 		new_slave = before;
 
-	if (!new_slave) {
-		rtnl_unlock();
-		return true;
-	}
+	if (!new_slave)
+		goto check_state;
 
 	new_slave->link = BOND_LINK_BACK;
-	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
+	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_LATER);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->jiffies = jiffies;
 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
-	rtnl_unlock();
 
-	return true;
+check_state:
+	bond_for_each_slave_rcu(bond, slave, iter) {
+		if (slave->should_notify) {
+			should_notify_rtnl = BOND_SLAVE_NOTIFY_NOW;
+			break;
+		}
+	}
+	return should_notify_rtnl;
 }
 
 static void bond_activebackup_arp_mon(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
-	bool should_notify_peers = false, should_commit = false;
+	bool should_notify_peers = false;
+	bool should_notify_rtnl = false;
 	int delta_in_ticks;
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
@@ -2726,11 +2722,12 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 		goto re_arm;
 
 	rcu_read_lock();
+
 	should_notify_peers = bond_should_notify_peers(bond);
-	should_commit = bond_ab_arp_inspect(bond);
-	rcu_read_unlock();
 
-	if (should_commit) {
+	if (bond_ab_arp_inspect(bond)) {
+		rcu_read_unlock();
+
 		/* Race avoidance with bond_close flush of workqueue */
 		if (!rtnl_trylock()) {
 			delta_in_ticks = 1;
@@ -2739,23 +2736,28 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 		}
 
 		bond_ab_arp_commit(bond);
+
 		rtnl_unlock();
+		rcu_read_lock();
 	}
 
-	if (!bond_ab_arp_probe(bond)) {
-		/* rtnl locking failed, re-arm */
-		delta_in_ticks = 1;
-		should_notify_peers = false;
-	}
+	should_notify_rtnl = bond_ab_arp_probe(bond);
+	rcu_read_unlock();
 
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 
-	if (should_notify_peers) {
+	if (should_notify_peers || should_notify_rtnl) {
 		if (!rtnl_trylock())
 			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
+
+		if (should_notify_peers)
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+						 bond->dev);
+		if (should_notify_rtnl)
+			bond_slave_state_notify(bond);
+
 		rtnl_unlock();
 	}
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9b280ac..2b0fdec 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -335,6 +335,19 @@ static inline void bond_slave_state_change(struct bonding *bond)
 	}
 }
 
+static inline void bond_slave_state_notify(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->should_notify) {
+			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_KERNEL);
+			tmp->should_notify = 0;
+		}
+	}
+}
+
 static inline int bond_slave_state(struct slave *slave)
 {
 	return slave->backup;
-- 
1.8.0
