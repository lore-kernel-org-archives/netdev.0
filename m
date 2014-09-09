From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 4/7] bonding: convert primary_slave to use RCU
Date: Tue,  9 Sep 2014 23:17:00 +0200
Message-ID: <1410297423-26624-5-git-send-email-nikolay@redhat.com>
References: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Cc: hariprasad@chelsio.com, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbaIIVRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 17:17:22 -0400
In-Reply-To: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is necessary mainly for two bonding call sites: procfs and
sysfs as it was dereferenced without any real protection.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 42 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_netlink.c |  7 ++++---
 drivers/net/bonding/bond_options.c |  8 ++++----
 drivers/net/bonding/bond_procfs.c  |  8 ++++----
 drivers/net/bonding/bond_sysfs.c   | 10 ++++++---
 drivers/net/bonding/bonding.h      |  2 +-
 6 files changed, 43 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dcd331bd0c17..629037f79213 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -708,7 +708,7 @@ out:
 
 static bool bond_should_change_active(struct bonding *bond)
 {
-	struct slave *prim = bond->primary_slave;
+	struct slave *prim = rtnl_dereference(bond->primary_slave);
 	struct slave *curr = bond_deref_active_protected(bond);
 
 	if (!prim || !curr || curr->link != BOND_LINK_UP)
@@ -732,13 +732,14 @@ static bool bond_should_change_active(struct bonding *bond)
  */
 static struct slave *bond_find_best_slave(struct bonding *bond)
 {
-	struct slave *slave, *bestslave = NULL;
+	struct slave *slave, *bestslave = NULL, *primary;
 	struct list_head *iter;
 	int mintime = bond->params.updelay;
 
-	if (bond->primary_slave && bond->primary_slave->link == BOND_LINK_UP &&
+	primary = rtnl_dereference(bond->primary_slave);
+	if (primary && primary->link == BOND_LINK_UP &&
 	    bond_should_change_active(bond))
-		return bond->primary_slave;
+		return primary;
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (slave->link == BOND_LINK_UP)
@@ -1482,7 +1483,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (bond_uses_primary(bond) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
-			bond->primary_slave = new_slave;
+			rcu_assign_pointer(bond->primary_slave, new_slave);
 			bond->force_primary = true;
 		}
 	}
@@ -1596,8 +1597,8 @@ err_detach:
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
-	if (bond->primary_slave == new_slave)
-		bond->primary_slave = NULL;
+	if (rcu_access_pointer(bond->primary_slave) == new_slave)
+		RCU_INIT_POINTER(bond->primary_slave, NULL);
 	if (rcu_access_pointer(bond->curr_active_slave) == new_slave) {
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
@@ -1606,6 +1607,8 @@ err_detach:
 		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
+	/* either primary_slave or curr_active_slave might've changed */
+	synchronize_rcu();
 	slave_disable_netpoll(new_slave);
 
 err_close:
@@ -1714,8 +1717,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 				    bond_dev->name, slave_dev->name);
 	}
 
-	if (bond->primary_slave == slave)
-		bond->primary_slave = NULL;
+	if (rtnl_dereference(bond->primary_slave) == slave)
+		RCU_INIT_POINTER(bond->primary_slave, NULL);
 
 	if (oldcurrent == slave) {
 		write_lock_bh(&bond->curr_slave_lock);
@@ -1976,7 +1979,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 static void bond_miimon_commit(struct bonding *bond)
 {
 	struct list_head *iter;
-	struct slave *slave;
+	struct slave *slave, *primary;
 
 	bond_for_each_slave(bond, slave, iter) {
 		switch (slave->new_link) {
@@ -1987,13 +1990,14 @@ static void bond_miimon_commit(struct bonding *bond)
 			slave->link = BOND_LINK_UP;
 			slave->last_link_up = jiffies;
 
+			primary = rtnl_dereference(bond->primary_slave);
 			if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 				/* prevent it from being the active one */
 				bond_set_backup_slave(slave);
 			} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 				/* make it immediately active */
 				bond_set_active_slave(slave);
-			} else if (slave != bond->primary_slave) {
+			} else if (slave != primary) {
 				/* prevent it from being the active one */
 				bond_set_backup_slave(slave);
 			}
@@ -2011,8 +2015,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
-			if (!bond->curr_active_slave ||
-			    (slave == bond->primary_slave))
+			if (!bond->curr_active_slave || slave == primary)
 				goto do_failover;
 
 			continue;
@@ -2633,7 +2636,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 					    slave->dev->name);
 
 				if (!rtnl_dereference(bond->curr_active_slave) ||
-				    (slave == bond->primary_slave))
+				    slave == rtnl_dereference(bond->primary_slave))
 					goto do_failover;
 
 			}
@@ -2860,7 +2863,7 @@ static int bond_master_netdev_event(unsigned long event,
 static int bond_slave_netdev_event(unsigned long event,
 				   struct net_device *slave_dev)
 {
-	struct slave *slave = bond_slave_get_rtnl(slave_dev);
+	struct slave *slave = bond_slave_get_rtnl(slave_dev), *primary;
 	struct bonding *bond;
 	struct net_device *bond_dev;
 	u32 old_speed;
@@ -2874,6 +2877,7 @@ static int bond_slave_netdev_event(unsigned long event,
 		return NOTIFY_DONE;
 	bond_dev = slave->bond->dev;
 	bond = slave->bond;
+	primary = rtnl_dereference(bond->primary_slave);
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -2921,18 +2925,18 @@ static int bond_slave_netdev_event(unsigned long event,
 		    !bond->params.primary[0])
 			break;
 
-		if (slave == bond->primary_slave) {
+		if (slave == primary) {
 			/* slave's name changed - he's no longer primary */
-			bond->primary_slave = NULL;
+			RCU_INIT_POINTER(bond->primary_slave, NULL);
 		} else if (!strcmp(slave_dev->name, bond->params.primary)) {
 			/* we have a new primary slave */
-			bond->primary_slave = slave;
+			rcu_assign_pointer(bond->primary_slave, slave);
 		} else { /* we didn't change primary - exit */
 			break;
 		}
 
 		netdev_info(bond->dev, "Primary slave changed to %s, reselecting active slave\n",
-			    bond->primary_slave ? slave_dev->name : "none");
+			    primary ? slave_dev->name : "none");
 
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index e1489d9df2a4..c13d83e15ace 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -443,6 +443,7 @@ static int bond_fill_info(struct sk_buff *skb,
 	unsigned int packets_per_slave;
 	int ifindex, i, targets_added;
 	struct nlattr *targets;
+	struct slave *primary;
 
 	if (nla_put_u8(skb, IFLA_BOND_MODE, BOND_MODE(bond)))
 		goto nla_put_failure;
@@ -492,9 +493,9 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->params.arp_all_targets))
 		goto nla_put_failure;
 
-	if (bond->primary_slave &&
-	    nla_put_u32(skb, IFLA_BOND_PRIMARY,
-			bond->primary_slave->dev->ifindex))
+	primary = rtnl_dereference(bond->primary_slave);
+	if (primary &&
+	    nla_put_u32(skb, IFLA_BOND_PRIMARY, primary->dev->ifindex))
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_BOND_PRIMARY_RESELECT,
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index d8dc17faa6b4..7c9e176baecc 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1090,7 +1090,7 @@ static int bond_option_primary_set(struct bonding *bond,
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
 		netdev_info(bond->dev, "Setting primary slave to None\n");
-		bond->primary_slave = NULL;
+		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
 		goto out;
@@ -1100,16 +1100,16 @@ static int bond_option_primary_set(struct bonding *bond,
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
 			netdev_info(bond->dev, "Setting %s as primary slave\n",
 				    slave->dev->name);
-			bond->primary_slave = slave;
+			rcu_assign_pointer(bond->primary_slave, slave);
 			strcpy(bond->params.primary, slave->dev->name);
 			bond_select_active_slave(bond);
 			goto out;
 		}
 	}
 
-	if (bond->primary_slave) {
+	if (rtnl_dereference(bond->primary_slave)) {
 		netdev_info(bond->dev, "Setting primary slave to None\n");
-		bond->primary_slave = NULL;
+		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		bond_select_active_slave(bond);
 	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index de62c0385dfb..1a9fe1ba4c60 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -66,7 +66,7 @@ static void bond_info_show_master(struct seq_file *seq)
 {
 	struct bonding *bond = seq->private;
 	const struct bond_opt_value *optval;
-	struct slave *curr;
+	struct slave *curr, *primary;
 	int i;
 
 	curr = rcu_dereference(bond->curr_active_slave);
@@ -92,10 +92,10 @@ static void bond_info_show_master(struct seq_file *seq)
 	}
 
 	if (bond_uses_primary(bond)) {
+		primary = rcu_dereference(bond->primary_slave);
 		seq_printf(seq, "Primary Slave: %s",
-			   (bond->primary_slave) ?
-			   bond->primary_slave->dev->name : "None");
-		if (bond->primary_slave) {
+			   primary ? primary->dev->name : "None");
+		if (primary) {
 			optval = bond_opt_get_val(BOND_OPT_PRIMARY_RESELECT,
 						  bond->params.primary_reselect);
 			seq_printf(seq, " (primary_reselect %s)",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 98db8edd9c75..5555517284db 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -425,11 +425,15 @@ static ssize_t bonding_show_primary(struct device *d,
 				    struct device_attribute *attr,
 				    char *buf)
 {
-	int count = 0;
 	struct bonding *bond = to_bond(d);
+	struct slave *primary;
+	int count = 0;
 
-	if (bond->primary_slave)
-		count = sprintf(buf, "%s\n", bond->primary_slave->dev->name);
+	rcu_read_lock();
+	primary = rcu_dereference(bond->primary_slave);
+	if (primary)
+		count = sprintf(buf, "%s\n", primary->dev->name);
+	rcu_read_unlock();
 
 	return count;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index aace510d08d1..c798561a6f01 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,7 +195,7 @@ struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
 	struct   slave __rcu *curr_active_slave;
 	struct   slave __rcu *current_arp_slave;
-	struct   slave *primary_slave;
+	struct   slave __rcu *primary_slave;
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
-- 
1.9.3
