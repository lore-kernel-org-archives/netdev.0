From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] bonding: add proper __rcu annotation for curr_active_slave
Date: Tue, 15 Jul 2014 02:46:44 -0700
Message-ID: <1405417604-7828-4-git-send-email-edumazet@google.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:64798 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758463AbaGOJqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:46:52 -0400
Received: by mail-ie0-f201.google.com with SMTP id tr6so785645ieb.2
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 02:46:51 -0700 (PDT)
In-Reply-To: <1405417604-7828-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.

Using __rcu annotation actually helps to spot all accesses to bond->curr_active_slave
are correctly protected, with LOCKDEP support.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_alb.c     | 47 +++++++++++++++++++--------------
 drivers/net/bonding/bond_main.c    | 53 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.c |  2 +-
 drivers/net/bonding/bonding.h      |  6 ++++-
 4 files changed, 63 insertions(+), 45 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 76c0dade233f..de5bd03925b4 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -448,11 +448,13 @@ static struct slave *__rlb_next_rx_slave(struct bonding *bond)
  */
 static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 {
-	if (!bond->curr_active_slave)
+	struct slave *curr_active = bond_deref_active_protected(bond);
+
+	if (!curr_active)
 		return;
 
 	if (!bond->alb_info.primary_is_promisc) {
-		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
+		if (!dev_set_promiscuity(curr_active->dev, 1))
 			bond->alb_info.primary_is_promisc = 1;
 		else
 			bond->alb_info.primary_is_promisc = 0;
@@ -460,7 +462,7 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 
 	bond->alb_info.rlb_promisc_timeout_counter = 0;
 
-	alb_send_learning_packets(bond->curr_active_slave, addr, true);
+	alb_send_learning_packets(curr_active, addr, true);
 }
 
 /* slave being removed should not be active at this point
@@ -509,7 +511,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	write_lock_bh(&bond->curr_slave_lock);
 
-	if (slave != bond->curr_active_slave)
+	if (slave != bond_deref_active_protected(bond))
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 
 	write_unlock_bh(&bond->curr_slave_lock);
@@ -684,7 +686,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			 * move the old client to primary (curr_active_slave) so
 			 * that the new client can be assigned to this entry.
 			 */
-			if (bond->curr_active_slave &&
+			if (curr_active_slave &&
 			    client_info->slave != curr_active_slave) {
 				client_info->slave = curr_active_slave;
 				rlb_update_client(client_info);
@@ -1221,7 +1223,7 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
  */
 static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slave *slave)
 {
-	struct slave *has_bond_addr = bond->curr_active_slave;
+	struct slave *has_bond_addr = rcu_access_pointer(bond->curr_active_slave);
 	struct slave *tmp_slave1, *free_mac_slave = NULL;
 	struct list_head *iter;
 
@@ -1575,7 +1577,7 @@ void bond_alb_monitor(struct work_struct *work)
 			 * use mac of the slave device.
 			 * In RLB mode, we always use strict matches.
 			 */
-			strict_match = (slave != bond->curr_active_slave ||
+			strict_match = (slave != rcu_access_pointer(bond->curr_active_slave) ||
 					bond_info->rlb_enabled);
 			alb_send_learning_packets(slave, slave->dev->dev_addr,
 						  strict_match);
@@ -1593,7 +1595,7 @@ void bond_alb_monitor(struct work_struct *work)
 
 		bond_for_each_slave_rcu(bond, slave, iter) {
 			tlb_clear_slave(bond, slave, 1);
-			if (slave == bond->curr_active_slave) {
+			if (slave == rcu_access_pointer(bond->curr_active_slave)) {
 				SLAVE_TLB_INFO(slave).load =
 					bond_info->unbalanced_load /
 						BOND_TLB_REBALANCE_INTERVAL;
@@ -1625,7 +1627,8 @@ void bond_alb_monitor(struct work_struct *work)
 			 * because a slave was disabled then
 			 * it can now leave promiscuous mode.
 			 */
-			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
+			dev_set_promiscuity(rtnl_dereference(bond->curr_active_slave)->dev,
+					    -1);
 			bond_info->primary_is_promisc = 0;
 
 			rtnl_unlock();
@@ -1742,17 +1745,21 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	__acquires(&bond->curr_slave_lock)
 {
 	struct slave *swap_slave;
+	struct slave *curr_active;
 
-	if (bond->curr_active_slave == new_slave)
+	curr_active = rcu_dereference_protected(bond->curr_active_slave,
+						!new_slave ||
+						lockdep_is_held(&bond->curr_slave_lock));
+	if (curr_active == new_slave)
 		return;
 
-	if (bond->curr_active_slave && bond->alb_info.primary_is_promisc) {
-		dev_set_promiscuity(bond->curr_active_slave->dev, -1);
+	if (curr_active && bond->alb_info.primary_is_promisc) {
+		dev_set_promiscuity(curr_active->dev, -1);
 		bond->alb_info.primary_is_promisc = 0;
 		bond->alb_info.rlb_promisc_timeout_counter = 0;
 	}
 
-	swap_slave = bond->curr_active_slave;
+	swap_slave = curr_active;
 	rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
 	if (!new_slave || !bond_has_slaves(bond))
@@ -1818,6 +1825,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
+	struct slave *curr_active;
 	struct slave *swap_slave;
 	int res;
 
@@ -1834,23 +1842,24 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	 * Otherwise we'll need to pass the new address to it and handle
 	 * duplications.
 	 */
-	if (!bond->curr_active_slave)
+	curr_active = rtnl_dereference(bond->curr_active_slave);
+	if (!curr_active)
 		return 0;
 
 	swap_slave = bond_slave_has_mac(bond, bond_dev->dev_addr);
 
 	if (swap_slave) {
-		alb_swap_mac_addr(swap_slave, bond->curr_active_slave);
-		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
+		alb_swap_mac_addr(swap_slave, curr_active);
+		alb_fasten_mac_swap(bond, swap_slave, curr_active);
 	} else {
-		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr);
+		alb_set_slave_mac_addr(curr_active, bond_dev->dev_addr);
 
 		read_lock(&bond->lock);
-		alb_send_learning_packets(bond->curr_active_slave,
+		alb_send_learning_packets(curr_active,
 					  bond_dev->dev_addr, false);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform clients mac address has changed */
-			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
+			rlb_req_update_slave_clients(bond, curr_active);
 		}
 		read_unlock(&bond->lock);
 	}
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 09dc3ef771a7..6a331bbcf43a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -498,11 +498,11 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	int err = 0;
 
 	if (bond_uses_primary(bond)) {
+		struct slave *curr_active = bond_deref_active_protected(bond);
+
 		/* write lock already acquired */
-		if (bond->curr_active_slave) {
-			err = dev_set_promiscuity(bond->curr_active_slave->dev,
-						  inc);
-		}
+		if (curr_active)
+			err = dev_set_promiscuity(curr_active->dev, inc);
 	} else {
 		struct slave *slave;
 
@@ -524,11 +524,11 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	int err = 0;
 
 	if (bond_uses_primary(bond)) {
+		struct slave *curr_active = bond_deref_active_protected(bond);
+
 		/* write lock already acquired */
-		if (bond->curr_active_slave) {
-			err = dev_set_allmulti(bond->curr_active_slave->dev,
-					       inc);
-		}
+		if (curr_active)
+			err = dev_set_allmulti(curr_active->dev, inc);
 	} else {
 		struct slave *slave;
 
@@ -713,7 +713,7 @@ out:
 static bool bond_should_change_active(struct bonding *bond)
 {
 	struct slave *prim = bond->primary_slave;
-	struct slave *curr = bond->curr_active_slave;
+	struct slave *curr = bond_deref_active_protected(bond);
 
 	if (!prim || !curr || curr->link != BOND_LINK_UP)
 		return true;
@@ -792,7 +792,11 @@ static bool bond_should_notify_peers(struct bonding *bond)
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
-	struct slave *old_active = bond->curr_active_slave;
+	struct slave *old_active;
+
+	old_active = rcu_dereference_protected(bond->curr_active_slave,
+					       !new_active ||
+					       lockdep_is_held(&bond->curr_slave_lock));
 
 	if (old_active == new_active)
 		return;
@@ -900,7 +904,7 @@ void bond_select_active_slave(struct bonding *bond)
 	int rv;
 
 	best_slave = bond_find_best_slave(bond);
-	if (best_slave != bond->curr_active_slave) {
+	if (best_slave != bond_deref_active_protected(bond)) {
 		bond_change_active_slave(bond, best_slave);
 		rv = bond_set_carrier(bond);
 		if (!rv)
@@ -1531,7 +1535,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * anyway (it holds no special properties of the bond device),
 		 * so we can change it without calling change_active_interface()
 		 */
-		if (!bond->curr_active_slave && new_slave->link == BOND_LINK_UP)
+		if (!rcu_access_pointer(bond->curr_active_slave) &&
+		    new_slave->link == BOND_LINK_UP)
 			rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
 		break;
@@ -1602,7 +1607,7 @@ err_detach:
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
 	if (bond->primary_slave == new_slave)
 		bond->primary_slave = NULL;
-	if (bond->curr_active_slave == new_slave) {
+	if (rcu_access_pointer(bond->curr_active_slave) == new_slave) {
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, NULL);
@@ -1704,7 +1709,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		bond_is_active_slave(slave) ? "active" : "backup",
 		slave_dev->name);
 
-	oldcurrent = bond->curr_active_slave;
+	oldcurrent = rcu_access_pointer(bond->curr_active_slave);
 
 	bond->current_arp_slave = NULL;
 
@@ -1878,7 +1883,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 
 /*-------------------------------- Monitoring -------------------------------*/
 
-
+/* called with rcu_read_lock() */
 static int bond_miimon_inspect(struct bonding *bond)
 {
 	int link_state, commit = 0;
@@ -1886,7 +1891,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 	struct slave *slave;
 	bool ignore_updelay;
 
-	ignore_updelay = !bond->curr_active_slave ? true : false;
+	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
@@ -2046,7 +2051,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
-			if (slave == bond->curr_active_slave)
+			if (slave == rcu_access_pointer(bond->curr_active_slave))
 				goto do_failover;
 
 			continue;
@@ -2416,7 +2421,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	rcu_read_lock();
 
-	oldcurrent = ACCESS_ONCE(bond->curr_active_slave);
+	oldcurrent = rcu_dereference(bond->curr_active_slave);
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the curr_active_slave does not come into
 	 * the picture unless it is null. also, slave->last_link_up is not
@@ -2607,8 +2612,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 
 		case BOND_LINK_UP:
 			trans_start = dev_trans_start(slave->dev);
-			if (bond->curr_active_slave != slave ||
-			    (!bond->curr_active_slave &&
+			if (rtnl_dereference(bond->curr_active_slave) != slave ||
+			    (!rtnl_dereference(bond->curr_active_slave) &&
 			     bond_time_in_interval(bond, trans_start, 1))) {
 				slave->link = BOND_LINK_UP;
 				if (bond->current_arp_slave) {
@@ -2621,7 +2626,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				pr_info("%s: link status definitely up for interface %s\n",
 					bond->dev->name, slave->dev->name);
 
-				if (!bond->curr_active_slave ||
+				if (!rtnl_dereference(bond->curr_active_slave) ||
 				    (slave == bond->primary_slave))
 					goto do_failover;
 
@@ -2640,7 +2645,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
 
-			if (slave == bond->curr_active_slave) {
+			if (slave == rtnl_dereference(bond->curr_active_slave)) {
 				bond->current_arp_slave = NULL;
 				goto do_failover;
 			}
@@ -3097,8 +3102,8 @@ static int bond_open(struct net_device *bond_dev)
 	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
-			if (bond_uses_primary(bond)
-				&& (slave != bond->curr_active_slave)) {
+			if (bond_uses_primary(bond) &&
+			    slave != rcu_access_pointer(bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
 			} else {
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index b26271fd7b09..f908e65e86c1 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -743,7 +743,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
-		struct slave *old_active = bond->curr_active_slave;
+		struct slave *old_active = bond_deref_active_protected(bond);
 		struct slave *new_active = bond_slave_get_rtnl(slave_dev);
 
 		BUG_ON(!new_active);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 713e2a99c661..d03d2ae4d3af 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -194,7 +194,7 @@ struct slave {
  */
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
-	struct   slave *curr_active_slave;
+	struct   slave __rcu *curr_active_slave;
 	struct   slave *current_arp_slave;
 	struct   slave *primary_slave;
 	bool     force_primary;
@@ -232,6 +232,10 @@ struct bonding {
 #define bond_slave_get_rtnl(dev) \
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
+#define bond_deref_active_protected(bond)				   \
+	rcu_dereference_protected(bond->curr_active_slave,		   \
+				  lockdep_is_held(&bond->curr_slave_lock))
+
 struct bond_vlan_tag {
 	__be16		vlan_proto;
 	unsigned short	vlan_id;
-- 
2.0.0.526.g5318336
