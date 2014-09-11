From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/7] bonding: clean curr_slave_lock use
Date: Thu, 11 Sep 2014 13:38:39 +0200
Message-ID: <1410435523-7520-4-git-send-email-nikolay@redhat.com>
References: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbaIKLi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 07:38:59 -0400
In-Reply-To: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly all users of curr_slave_lock already have RTNL as we've discussed
previously so there's no point in using it, the one case where the lock
must stay is the 3ad code, in fact it's the only one.
It's okay to remove it from bond_do_fail_over_mac() as it's called with
RTNL and drops the curr_slave_lock anyway.
bond_change_active_slave() is one of the main places where
curr_slave_lock was used, it's okay to remove it as all callers use RTNL
these days before calling it, that's why we move the ASSERT_RTNL() in
the beginning to catch any potential offenders to this rule.
The RTNL argument actually applies to all of the places where
curr_slave_lock has been removed from in this patch.
Also remove the unnecessary bond_deref_active_protected() macro and use
rtnl_dereference() instead.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_alb.c     |  4 +--
 drivers/net/bonding/bond_main.c    | 62 ++++++--------------------------------
 drivers/net/bonding/bond_options.c | 10 +-----
 drivers/net/bonding/bonding.h      |  8 +----
 4 files changed, 14 insertions(+), 70 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index cf4ede8594ff..b755659ddfdc 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -451,7 +451,7 @@ static struct slave *__rlb_next_rx_slave(struct bonding *bond)
  */
 static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 {
-	struct slave *curr_active = bond_deref_active_protected(bond);
+	struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
 
 	if (!curr_active)
 		return;
@@ -512,7 +512,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	_unlock_rx_hashtbl_bh(bond);
 
-	if (slave != bond_deref_active_protected(bond))
+	if (slave != rtnl_dereference(bond->curr_active_slave))
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b43b2df9e5d1..3b06685260b8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -637,13 +637,11 @@ static void bond_set_dev_addr(struct net_device *bond_dev,
  *
  * Perform special MAC address swapping for fail_over_mac settings
  *
- * Called with RTNL, curr_slave_lock for write_bh.
+ * Called with RTNL
  */
 static void bond_do_fail_over_mac(struct bonding *bond,
 				  struct slave *new_active,
 				  struct slave *old_active)
-	__releases(&bond->curr_slave_lock)
-	__acquires(&bond->curr_slave_lock)
 {
 	u8 tmp_mac[ETH_ALEN];
 	struct sockaddr saddr;
@@ -651,11 +649,8 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 	switch (bond->params.fail_over_mac) {
 	case BOND_FOM_ACTIVE:
-		if (new_active) {
-			write_unlock_bh(&bond->curr_slave_lock);
+		if (new_active)
 			bond_set_dev_addr(bond->dev, new_active->dev);
-			write_lock_bh(&bond->curr_slave_lock);
-		}
 		break;
 	case BOND_FOM_FOLLOW:
 		/*
@@ -666,8 +661,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 		if (!new_active)
 			return;
 
-		write_unlock_bh(&bond->curr_slave_lock);
-
 		if (old_active) {
 			ether_addr_copy(tmp_mac, new_active->dev->dev_addr);
 			ether_addr_copy(saddr.sa_data,
@@ -696,7 +689,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			netdev_err(bond->dev, "Error %d setting MAC of slave %s\n",
 				   -rv, new_active->dev->name);
 out:
-		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
 		netdev_err(bond->dev, "bond_do_fail_over_mac impossible: bad policy %d\n",
@@ -709,7 +701,7 @@ out:
 static bool bond_should_change_active(struct bonding *bond)
 {
 	struct slave *prim = rtnl_dereference(bond->primary_slave);
-	struct slave *curr = bond_deref_active_protected(bond);
+	struct slave *curr = rtnl_dereference(bond->curr_active_slave);
 
 	if (!prim || !curr || curr->link != BOND_LINK_UP)
 		return true;
@@ -785,15 +777,15 @@ static bool bond_should_notify_peers(struct bonding *bond)
  * because it is apparently the best available slave we have, even though its
  * updelay hasn't timed out yet.
  *
- * If new_active is not NULL, caller must hold curr_slave_lock for write_bh.
+ * Caller must hold RTNL.
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
 	struct slave *old_active;
 
-	old_active = rcu_dereference_protected(bond->curr_active_slave,
-					       !new_active ||
-					       lockdep_is_held(&bond->curr_slave_lock));
+	ASSERT_RTNL();
+
+	old_active = rtnl_dereference(bond->curr_active_slave);
 
 	if (old_active == new_active)
 		return;
@@ -861,14 +853,10 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 					bond_should_notify_peers(bond);
 			}
 
-			write_unlock_bh(&bond->curr_slave_lock);
-
 			call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
 			if (should_notify_peers)
 				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
 							 bond->dev);
-
-			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
 
@@ -893,7 +881,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
  *
- * Caller must hold curr_slave_lock for write_bh.
+ * Caller must hold RTNL.
  */
 void bond_select_active_slave(struct bonding *bond)
 {
@@ -901,7 +889,7 @@ void bond_select_active_slave(struct bonding *bond)
 	int rv;
 
 	best_slave = bond_find_best_slave(bond);
-	if (best_slave != bond_deref_active_protected(bond)) {
+	if (best_slave != rtnl_dereference(bond->curr_active_slave)) {
 		bond_change_active_slave(bond, best_slave);
 		rv = bond_set_carrier(bond);
 		if (!rv)
@@ -1571,9 +1559,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (bond_uses_primary(bond)) {
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 
@@ -1601,10 +1587,8 @@ err_detach:
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 	if (rcu_access_pointer(bond->curr_active_slave) == new_slave) {
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, NULL);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 	/* either primary_slave or curr_active_slave might've changed */
@@ -1720,11 +1704,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (rtnl_dereference(bond->primary_slave) == slave)
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 
-	if (oldcurrent == slave) {
-		write_lock_bh(&bond->curr_slave_lock);
+	if (oldcurrent == slave)
 		bond_change_active_slave(bond, NULL);
-		write_unlock_bh(&bond->curr_slave_lock);
-	}
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after the slave has been
@@ -1743,11 +1724,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		 * is no concern that another slave add/remove event
 		 * will interfere.
 		 */
-		write_lock_bh(&bond->curr_slave_lock);
-
 		bond_select_active_slave(bond);
-
-		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
 	if (!bond_has_slaves(bond)) {
@@ -2058,9 +2035,7 @@ static void bond_miimon_commit(struct bonding *bond)
 do_failover:
 		ASSERT_RTNL();
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 
@@ -2506,15 +2481,8 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 		if (slave_state_changed) {
 			bond_slave_state_change(bond);
 		} else if (do_failover) {
-			/* the bond_select_active_slave must hold RTNL
-			 * and curr_slave_lock for write.
-			 */
 			block_netpoll_tx();
-			write_lock_bh(&bond->curr_slave_lock);
-
 			bond_select_active_slave(bond);
-
-			write_unlock_bh(&bond->curr_slave_lock);
 			unblock_netpoll_tx();
 		}
 		rtnl_unlock();
@@ -2670,9 +2638,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 do_failover:
 		ASSERT_RTNL();
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 
@@ -2939,9 +2905,7 @@ static int bond_slave_netdev_event(unsigned long event,
 			    primary ? slave_dev->name : "none");
 
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 		break;
 	case NETDEV_FEAT_CHANGE:
@@ -3106,7 +3070,6 @@ static int bond_open(struct net_device *bond_dev)
 
 	/* reset slave->backup and slave->inactive */
 	if (bond_has_slaves(bond)) {
-		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
 			if (bond_uses_primary(bond) &&
 			    slave != rcu_access_pointer(bond->curr_active_slave)) {
@@ -3117,7 +3080,6 @@ static int bond_open(struct net_device *bond_dev)
 							    BOND_SLAVE_NOTIFY_NOW);
 			}
 		}
-		read_unlock(&bond->curr_slave_lock);
 	}
 
 	bond_work_init_all(bond);
@@ -3239,14 +3201,10 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		if (!mii)
 			return -EINVAL;
 
-
 		if (mii->reg_num == 1) {
 			mii->val_out = 0;
-			read_lock(&bond->curr_slave_lock);
 			if (netif_carrier_ok(bond->dev))
 				mii->val_out = BMSR_LSTATUS;
-
-			read_unlock(&bond->curr_slave_lock);
 		}
 
 		return 0;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 534c0600484e..b62697f4a3de 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -734,15 +734,13 @@ static int bond_option_active_slave_set(struct bonding *bond,
 	}
 
 	block_netpoll_tx();
-	write_lock_bh(&bond->curr_slave_lock);
-
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
 		netdev_info(bond->dev, "Clearing current active slave\n");
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
-		struct slave *old_active = bond_deref_active_protected(bond);
+		struct slave *old_active = rtnl_dereference(bond->curr_active_slave);
 		struct slave *new_active = bond_slave_get_rtnl(slave_dev);
 
 		BUG_ON(!new_active);
@@ -765,8 +763,6 @@ static int bond_option_active_slave_set(struct bonding *bond,
 			}
 		}
 	}
-
-	write_unlock_bh(&bond->curr_slave_lock);
 	unblock_netpoll_tx();
 
 	return ret;
@@ -1066,7 +1062,6 @@ static int bond_option_primary_set(struct bonding *bond,
 	struct slave *slave;
 
 	block_netpoll_tx();
-	write_lock_bh(&bond->curr_slave_lock);
 
 	p = strchr(primary, '\n');
 	if (p)
@@ -1103,7 +1098,6 @@ static int bond_option_primary_set(struct bonding *bond,
 		    primary, bond->dev->name);
 
 out:
-	write_unlock_bh(&bond->curr_slave_lock);
 	unblock_netpoll_tx();
 
 	return 0;
@@ -1117,9 +1111,7 @@ static int bond_option_primary_reselect_set(struct bonding *bond,
 	bond->params.primary_reselect = newval->value;
 
 	block_netpoll_tx();
-	write_lock_bh(&bond->curr_slave_lock);
 	bond_select_active_slave(bond);
-	write_unlock_bh(&bond->curr_slave_lock);
 	unblock_netpoll_tx();
 
 	return 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 78c461abaa09..02afdeb08765 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -184,9 +184,7 @@ struct slave {
 
 /*
  * Here are the locking policies for the two bonding locks:
- *
- * 1) Get rcu_read_lock when reading or RTNL when writing slave list.
- * 2) Get bond->curr_slave_lock when reading/writing bond->curr_active_slave.
+ * Get rcu_read_lock when reading or RTNL when writing slave list.
  */
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
@@ -227,10 +225,6 @@ struct bonding {
 #define bond_slave_get_rtnl(dev) \
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
-#define bond_deref_active_protected(bond)				   \
-	rcu_dereference_protected(bond->curr_active_slave,		   \
-				  lockdep_is_held(&bond->curr_slave_lock))
-
 struct bond_vlan_tag {
 	__be16		vlan_proto;
 	unsigned short	vlan_id;
-- 
1.9.3
