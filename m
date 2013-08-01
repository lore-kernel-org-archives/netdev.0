From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v3 1/5] bonding: convert to list API and replace bond's custom list
Date: Thu,  1 Aug 2013 16:54:47 +0200
Message-ID: <1375368891-9979-2-git-send-email-nikolay@redhat.com>
References: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477Ab3HAO63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 10:58:29 -0400
In-Reply-To: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to remove struct bonding's first_slave and struct
slave's next and prev pointers, and replace them with the standard Linux
list API. The old macros are converted to list API as well and some new
primitives are available now. The checks if there're slaves that used
slave_cnt have been replaced by the list_empty macro.
Also a few small style fixes, changing longest -> shortest line in local
variable declarations, leaving an empty line before return and removing
unnecessary brackets.
This is the first step to gradual RCU conversion.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v3: fix 3ad next_slave bug (no end of list check), it was introduced while
making v2

v2: introduce new primitives, keep using bond_for_each_slave, make
bond_first/last_slave return NULL on empty list, eliminate the use
of slave_cnt for checking if there're slaves in the bond and use
list_empty for that, make bond_for_each_slave_from check for NULL pos
Because of these changes one macro goes to 82 chars, but I think it would
look ugly if I break it, also I think we fix an ALB bug in
bond_alb_deinit_slave because we have to check if any slaves have the
released slave's MAC address, and in case we have 2 slaves > 1 would fail
since this one has been already detached

 drivers/net/bonding/bond_3ad.c    |  42 +++++---
 drivers/net/bonding/bond_alb.c    |  51 ++++-----
 drivers/net/bonding/bond_main.c   | 220 ++++++++++++++++----------------------
 drivers/net/bonding/bond_procfs.c |  12 +--
 drivers/net/bonding/bond_sysfs.c  |  43 ++++----
 drivers/net/bonding/bonding.h     |  71 ++++++------
 6 files changed, 203 insertions(+), 236 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 390061d..7d46fa8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -143,10 +143,9 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
  */
 static inline struct port *__get_first_port(struct bonding *bond)
 {
-	if (bond->slave_cnt == 0)
-		return NULL;
+	struct slave *first_slave = bond_first_slave(bond);
 
-	return &(SLAVE_AD_INFO(bond->first_slave).port);
+	return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
 }
 
 /**
@@ -159,13 +158,16 @@ static inline struct port *__get_first_port(struct bonding *bond)
 static inline struct port *__get_next_port(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
-	struct slave *slave = port->slave;
+	struct slave *slave = port->slave, *slave_next;
 
 	// If there's no bond for this port, or this is the last slave
-	if ((bond == NULL) || (slave->next == bond->first_slave))
+	if (bond == NULL)
+		return NULL;
+	slave_next = bond_next_slave(bond, slave);
+	if (!slave_next || bond_is_first_slave(bond, slave_next))
 		return NULL;
 
-	return &(SLAVE_AD_INFO(slave->next).port);
+	return &(SLAVE_AD_INFO(slave_next).port);
 }
 
 /**
@@ -178,12 +180,14 @@ static inline struct port *__get_next_port(struct port *port)
 static inline struct aggregator *__get_first_agg(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
+	struct slave *first_slave;
 
 	// If there's no bond for this port, or bond has no slaves
-	if ((bond == NULL) || (bond->slave_cnt == 0))
+	if (bond == NULL)
 		return NULL;
+	first_slave = bond_first_slave(bond);
 
-	return &(SLAVE_AD_INFO(bond->first_slave).aggregator);
+	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 }
 
 /**
@@ -195,14 +199,17 @@ static inline struct aggregator *__get_first_agg(struct port *port)
  */
 static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
 {
-	struct slave *slave = aggregator->slave;
+	struct slave *slave = aggregator->slave, *slave_next;
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 
 	// If there's no bond for this aggregator, or this is the last slave
-	if ((bond == NULL) || (slave->next == bond->first_slave))
+	if (bond == NULL)
+		return NULL;
+	slave_next = bond_next_slave(bond, slave);
+	if (!slave_next || bond_is_first_slave(bond, slave_next))
 		return NULL;
 
-	return &(SLAVE_AD_INFO(slave->next).aggregator);
+	return &(SLAVE_AD_INFO(slave_next).aggregator);
 }
 
 /*
@@ -2110,7 +2117,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	read_lock(&bond->lock);
 
 	//check if there are any slaves
-	if (bond->slave_cnt == 0)
+	if (list_empty(&bond->slave_list))
 		goto re_arm;
 
 	// check if agg_select_timer timer after initialize is timed out
@@ -2336,8 +2343,12 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 int bond_3ad_set_carrier(struct bonding *bond)
 {
 	struct aggregator *active;
+	struct slave *first_slave;
 
-	active = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
+	first_slave = bond_first_slave(bond);
+	if (!first_slave)
+		return 0;
+	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
 	if (active) {
 		/* are enough slaves available to consider link up? */
 		if (active->num_of_ports < bond->params.min_links) {
@@ -2432,7 +2443,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
 		if (agg && (agg->aggregator_identifier == agg_id)) {
@@ -2501,7 +2512,6 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
  */
 void bond_3ad_update_lacp_rate(struct bonding *bond)
 {
-	int i;
 	struct slave *slave;
 	struct port *port = NULL;
 	int lacp_fast;
@@ -2509,7 +2519,7 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 	write_lock_bh(&bond->lock);
 	lacp_fast = bond->params.lacp_fast;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (port->slave == NULL)
 			continue;
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 4ea8ed1..4d35196 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -224,13 +224,12 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 {
 	struct slave *slave, *least_loaded;
 	long long max_gap;
-	int i;
 
 	least_loaded = NULL;
 	max_gap = LLONG_MIN;
 
 	/* Find the slave with the largest gap */
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (SLAVE_IS_OK(slave)) {
 			long long gap = compute_gap(slave);
 
@@ -386,11 +385,10 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	struct slave *rx_slave, *slave, *start_at;
 	int i = 0;
 
-	if (bond_info->next_rx_slave) {
+	if (bond_info->next_rx_slave)
 		start_at = bond_info->next_rx_slave;
-	} else {
-		start_at = bond->first_slave;
-	}
+	else
+		start_at = bond_first_slave(bond);
 
 	rx_slave = NULL;
 
@@ -405,7 +403,8 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	}
 
 	if (rx_slave) {
-		bond_info->next_rx_slave = rx_slave->next;
+		slave = bond_next_slave(bond, rx_slave);
+		bond_info->next_rx_slave = slave;
 	}
 
 	return rx_slave;
@@ -1173,9 +1172,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 {
 	struct slave *tmp_slave1, *free_mac_slave = NULL;
 	struct slave *has_bond_addr = bond->curr_active_slave;
-	int i;
 
-	if (bond->slave_cnt == 0) {
+	if (list_empty(&bond->slave_list)) {
 		/* this is the first slave */
 		return 0;
 	}
@@ -1196,7 +1194,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	/* The slave's address is equal to the address of the bond.
 	 * Search for a spare address in the bond for this slave.
 	 */
-	bond_for_each_slave(bond, tmp_slave1, i) {
+	bond_for_each_slave(bond, tmp_slave1) {
 		if (!bond_slave_has_mac(bond, tmp_slave1->perm_hwaddr)) {
 			/* no slave has tmp_slave1's perm addr
 			 * as its curr addr
@@ -1246,17 +1244,15 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
  */
 static int alb_set_mac_address(struct bonding *bond, void *addr)
 {
-	struct sockaddr sa;
-	struct slave *slave, *stop_at;
 	char tmp_addr[ETH_ALEN];
+	struct slave *slave;
+	struct sockaddr sa;
 	int res;
-	int i;
 
-	if (bond->alb_info.rlb_enabled) {
+	if (bond->alb_info.rlb_enabled)
 		return 0;
-	}
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
@@ -1276,8 +1272,7 @@ unwind:
 	sa.sa_family = bond->dev->type;
 
 	/* unwind from head to the slave that failed */
-	stop_at = slave;
-	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
+	bond_for_each_slave_continue_reverse(bond, slave) {
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 		dev_set_mac_address(slave->dev, &sa);
 		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
@@ -1460,11 +1455,10 @@ void bond_alb_monitor(struct work_struct *work)
 					    alb_work.work);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *slave;
-	int i;
 
 	read_lock(&bond->lock);
 
-	if (bond->slave_cnt == 0) {
+	if (list_empty(&bond->slave_list)) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
 		goto re_arm;
@@ -1482,9 +1476,8 @@ void bond_alb_monitor(struct work_struct *work)
 		 */
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave)
 			alb_send_learning_packets(slave, slave->dev->dev_addr);
-		}
 
 		read_unlock(&bond->curr_slave_lock);
 
@@ -1496,7 +1489,7 @@ void bond_alb_monitor(struct work_struct *work)
 
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave) {
 			tlb_clear_slave(bond, slave, 1);
 			if (slave == bond->curr_active_slave) {
 				SLAVE_TLB_INFO(slave).load =
@@ -1602,9 +1595,8 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
  */
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 {
-	if (bond->slave_cnt > 1) {
+	if (!list_empty(&bond->slave_list))
 		alb_change_hw_addr_on_detach(bond, slave);
-	}
 
 	tlb_clear_slave(bond, slave, 0);
 
@@ -1661,9 +1653,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 {
 	struct slave *swap_slave;
 
-	if (bond->curr_active_slave == new_slave) {
+	if (bond->curr_active_slave == new_slave)
 		return;
-	}
 
 	if (bond->curr_active_slave && bond->alb_info.primary_is_promisc) {
 		dev_set_promiscuity(bond->curr_active_slave->dev, -1);
@@ -1674,9 +1665,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	swap_slave = bond->curr_active_slave;
 	bond->curr_active_slave = new_slave;
 
-	if (!new_slave || (bond->slave_cnt == 0)) {
+	if (!new_slave || list_empty(&bond->slave_list))
 		return;
-	}
 
 	/* set the new curr_active_slave to the bonds mac address
 	 * i.e. swap mac addresses of old curr_active_slave and new curr_active_slave
@@ -1689,9 +1679,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	 * ignored so we can mess with their MAC addresses without
 	 * fear of interference from transmit activity.
 	 */
-	if (swap_slave) {
+	if (swap_slave)
 		tlb_clear_slave(bond, swap_slave, 1);
-	}
 	tlb_clear_slave(bond, new_slave, 1);
 
 	write_unlock_bh(&bond->curr_slave_lock);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index da3af63..3636a04 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -441,10 +441,10 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 				__be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *stop_at;
-	int i, res;
+	struct slave *slave;
+	int res;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		res = vlan_vid_add(slave->dev, proto, vid);
 		if (res)
 			goto unwind;
@@ -461,8 +461,7 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 
 unwind:
 	/* unwind from head to the slave that failed */
-	stop_at = slave;
-	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at)
+	bond_for_each_slave_continue_reverse(bond, slave)
 		vlan_vid_del(slave->dev, proto, vid);
 
 	return res;
@@ -478,9 +477,9 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int i, res;
+	int res;
 
-	bond_for_each_slave(bond, slave, i)
+	bond_for_each_slave(bond, slave)
 		vlan_vid_del(slave->dev, proto, vid);
 
 	res = bond_del_vlan(bond, vid);
@@ -532,15 +531,14 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 static int bond_set_carrier(struct bonding *bond)
 {
 	struct slave *slave;
-	int i;
 
-	if (bond->slave_cnt == 0)
+	if (list_empty(&bond->slave_list))
 		goto down;
 
 	if (bond->params.mode == BOND_MODE_8023AD)
 		return bond_3ad_set_carrier(bond);
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (slave->link == BOND_LINK_UP) {
 			if (!netif_carrier_ok(bond->dev)) {
 				netif_carrier_on(bond->dev);
@@ -681,8 +679,8 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 		}
 	} else {
 		struct slave *slave;
-		int i;
-		bond_for_each_slave(bond, slave, i) {
+
+		bond_for_each_slave(bond, slave) {
 			err = dev_set_promiscuity(slave->dev, inc);
 			if (err)
 				return err;
@@ -705,8 +703,8 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 		}
 	} else {
 		struct slave *slave;
-		int i;
-		bond_for_each_slave(bond, slave, i) {
+
+		bond_for_each_slave(bond, slave) {
 			err = dev_set_allmulti(slave->dev, inc);
 			if (err)
 				return err;
@@ -935,9 +933,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	new_active = bond->curr_active_slave;
 
 	if (!new_active) { /* there were no active slaves left */
-		if (bond->slave_cnt > 0)   /* found one slave */
-			new_active = bond->first_slave;
-		else
+		new_active = bond_first_slave(bond);
+		if (!new_active)
 			return NULL; /* still no slave, return NULL */
 	}
 
@@ -1130,17 +1127,7 @@ void bond_select_active_slave(struct bonding *bond)
  */
 static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 {
-	if (bond->first_slave == NULL) { /* attaching the first slave */
-		new_slave->next = new_slave;
-		new_slave->prev = new_slave;
-		bond->first_slave = new_slave;
-	} else {
-		new_slave->next = bond->first_slave;
-		new_slave->prev = bond->first_slave->prev;
-		new_slave->next->prev = new_slave;
-		new_slave->prev->next = new_slave;
-	}
-
+	list_add_tail(&new_slave->list, &bond->slave_list);
 	bond->slave_cnt++;
 }
 
@@ -1156,22 +1143,7 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
  */
 static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 {
-	if (slave->next)
-		slave->next->prev = slave->prev;
-
-	if (slave->prev)
-		slave->prev->next = slave->next;
-
-	if (bond->first_slave == slave) { /* slave is the first slave */
-		if (bond->slave_cnt > 1) { /* there are more slave */
-			bond->first_slave = slave->next;
-		} else {
-			bond->first_slave = NULL; /* slave was the last one */
-		}
-	}
-
-	slave->next = NULL;
-	slave->prev = NULL;
+	list_del(&slave->list);
 	bond->slave_cnt--;
 }
 
@@ -1222,9 +1194,8 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int i;
 
-	bond_for_each_slave(bond, slave, i)
+	bond_for_each_slave(bond, slave)
 		if (IS_UP(slave->dev))
 			slave_disable_netpoll(slave);
 }
@@ -1233,9 +1204,9 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
 {
 	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave;
-	int i, err = 0;
+	int err = 0;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		err = slave_enable_netpoll(slave);
 		if (err) {
 			bond_netpoll_cleanup(dev);
@@ -1265,11 +1236,10 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	struct slave *slave;
 	struct bonding *bond = netdev_priv(dev);
 	netdev_features_t mask;
-	int i;
 
 	read_lock(&bond->lock);
 
-	if (!bond->first_slave) {
+	if (list_empty(&bond->slave_list)) {
 		/* Disable adding VLANs to empty bond. But why? --mq */
 		features |= NETIF_F_VLAN_CHALLENGED;
 		goto out;
@@ -1279,7 +1249,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		features = netdev_increment_features(features,
 						     slave->dev->features,
 						     mask);
@@ -1303,15 +1273,14 @@ static void bond_compute_features(struct bonding *bond)
 	unsigned short max_hard_header_len = ETH_HLEN;
 	unsigned int gso_max_size = GSO_MAX_SIZE;
 	u16 gso_max_segs = GSO_MAX_SEGS;
-	int i;
 	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 
 	read_lock(&bond->lock);
 
-	if (!bond->first_slave)
+	if (list_empty(&bond->slave_list))
 		goto done;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		vlan_features = netdev_increment_features(vlan_features,
 			slave->dev->vlan_features, BOND_VLAN_FEATURES);
 
@@ -1499,7 +1468,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * bond ether type mutual exclusion - don't allow slaves of dissimilar
 	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
 	 */
-	if (bond->slave_cnt == 0) {
+	if (list_empty(&bond->slave_list)) {
 		if (bond_dev->type != slave_dev->type) {
 			pr_debug("%s: change device type from %d to %d\n",
 				 bond_dev->name,
@@ -1538,7 +1507,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
-		if (bond->slave_cnt == 0) {
+		if (list_empty(&bond->slave_list)) {
 			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
 				   bond_dev->name);
 			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
@@ -1554,7 +1523,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (!bond->slave_cnt && bond->dev->addr_assign_type == NET_ADDR_RANDOM)
+	if (list_empty(&bond->slave_list) &&
+	    bond->dev->addr_assign_type == NET_ADDR_RANDOM)
 		bond_set_dev_addr(bond->dev, slave_dev);
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
@@ -1562,7 +1532,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		res = -ENOMEM;
 		goto err_undo_flags;
 	}
-
+	INIT_LIST_HEAD(&new_slave->list);
 	/*
 	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
 	 * is set via sysfs or module option if desired.
@@ -1748,15 +1718,18 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		bond_set_slave_inactive_flags(new_slave);
 		/* if this is the first slave */
-		if (bond->slave_cnt == 1) {
+		if (bond_first_slave(bond) == new_slave) {
 			SLAVE_AD_INFO(new_slave).id = 1;
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
 			 */
 			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL);
 		} else {
+			struct slave *prev_slave;
+
+			prev_slave = bond_prev_slave(bond, new_slave);
 			SLAVE_AD_INFO(new_slave).id =
-				SLAVE_AD_INFO(new_slave->prev).id + 1;
+				SLAVE_AD_INFO(prev_slave).id + 1;
 		}
 
 		bond_3ad_bind_slave(new_slave);
@@ -1875,7 +1848,7 @@ err_free:
 err_undo_flags:
 	bond_compute_features(bond);
 	/* Enslave of first slave has failed and we need to fix master's mac */
-	if (bond->slave_cnt == 0 &&
+	if (list_empty(&bond->slave_list) &&
 	    ether_addr_equal(bond_dev->dev_addr, slave_dev->dev_addr))
 		eth_hw_addr_random(bond_dev);
 
@@ -1931,15 +1904,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 	netdev_rx_handler_unregister(slave_dev);
 	write_lock_bh(&bond->lock);
 
-	if (!all && !bond->params.fail_over_mac) {
-		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
-		    bond->slave_cnt > 1)
-			pr_warning("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
-				   bond_dev->name, slave_dev->name,
-				   slave->perm_hwaddr,
-				   bond_dev->name, slave_dev->name);
-	}
-
 	/* Inform AD package of unbinding of slave. */
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* must be called before the slave is
@@ -1960,6 +1924,15 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* release the slave from its bond */
 	bond_detach_slave(bond, slave);
 
+	if (!all && !bond->params.fail_over_mac) {
+		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
+		    !list_empty(&bond->slave_list))
+			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
+				   bond_dev->name, slave_dev->name,
+				   slave->perm_hwaddr,
+				   bond_dev->name, slave_dev->name);
+	}
+
 	if (bond->primary_slave == slave)
 		bond->primary_slave = NULL;
 
@@ -1996,7 +1969,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		write_lock_bh(&bond->lock);
 	}
 
-	if (bond->slave_cnt == 0) {
+	if (list_empty(&bond->slave_list)) {
 		bond_set_carrier(bond);
 		eth_hw_addr_random(bond_dev);
 
@@ -2011,7 +1984,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
 
-	if (bond->slave_cnt == 0) {
+	if (list_empty(&bond->slave_list)) {
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
 		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
 	}
@@ -2082,7 +2055,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	int ret;
 
 	ret = bond_release(bond_dev, slave_dev);
-	if ((ret == 0) && (bond->slave_cnt == 0)) {
+	if (ret == 0 && list_empty(&bond->slave_list)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
 		pr_info("%s: destroying bond %s.\n",
 			bond_dev->name, bond_dev->name);
@@ -2167,13 +2140,12 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	int i = 0, res = -ENODEV;
 	struct slave *slave;
-	int i, res = -ENODEV;
 
 	read_lock(&bond->lock);
-
-	bond_for_each_slave(bond, slave, i) {
-		if (i == (int)info->slave_id) {
+	bond_for_each_slave(bond, slave) {
+		if (i++ == (int)info->slave_id) {
 			res = 0;
 			strcpy(info->slave_name, slave->dev->name);
 			info->link = slave->link;
@@ -2182,7 +2154,6 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 			break;
 		}
 	}
-
 	read_unlock(&bond->lock);
 
 	return res;
@@ -2193,13 +2164,13 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 
 static int bond_miimon_inspect(struct bonding *bond)
 {
+	int link_state, commit = 0;
 	struct slave *slave;
-	int i, link_state, commit = 0;
 	bool ignore_updelay;
 
 	ignore_updelay = !bond->curr_active_slave ? true : false;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
@@ -2294,9 +2265,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 static void bond_miimon_commit(struct bonding *bond)
 {
 	struct slave *slave;
-	int i;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		switch (slave->new_link) {
 		case BOND_LINK_NOCHANGE:
 			continue;
@@ -2401,7 +2371,7 @@ void bond_mii_monitor(struct work_struct *work)
 
 	delay = msecs_to_jiffies(bond->params.miimon);
 
-	if (bond->slave_cnt == 0)
+	if (list_empty(&bond->slave_list))
 		goto re_arm;
 
 	should_notify_peers = bond_should_notify_peers(bond);
@@ -2681,14 +2651,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks, extra_ticks;
-	int i;
 
 	read_lock(&bond->lock);
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 	extra_ticks = delta_in_ticks / 2;
 
-	if (bond->slave_cnt == 0)
+	if (list_empty(&bond->slave_list))
 		goto re_arm;
 
 	read_lock(&bond->curr_slave_lock);
@@ -2703,7 +2672,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 * TODO: what about up/down delay in arp mode? it wasn't here before
 	 *       so it can wait
 	 */
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		unsigned long trans_start = dev_trans_start(slave->dev);
 
 		if (slave->link != BOND_LINK_UP) {
@@ -2800,10 +2769,10 @@ re_arm:
  */
 static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 {
-	struct slave *slave;
-	int i, commit = 0;
 	unsigned long trans_start;
+	struct slave *slave;
 	int extra_ticks;
+	int commit = 0;
 
 	/* All the time comparisons below need some extra time. Otherwise, on
 	 * fast networks the ARP probe/reply may arrive within the same jiffy
@@ -2812,7 +2781,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 	 */
 	extra_ticks = delta_in_ticks / 2;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		if (slave->link != BOND_LINK_UP) {
@@ -2891,11 +2860,10 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
  */
 static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 {
-	struct slave *slave;
-	int i;
 	unsigned long trans_start;
+	struct slave *slave;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		switch (slave->new_link) {
 		case BOND_LINK_NOCHANGE:
 			continue;
@@ -2968,7 +2936,7 @@ do_failover:
  */
 static void bond_ab_arp_probe(struct bonding *bond)
 {
-	struct slave *slave;
+	struct slave *slave, *next_slave;
 	int i;
 
 	read_lock(&bond->curr_slave_lock);
@@ -2992,7 +2960,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	 */
 
 	if (!bond->current_arp_slave) {
-		bond->current_arp_slave = bond->first_slave;
+		bond->current_arp_slave = bond_first_slave(bond);
 		if (!bond->current_arp_slave)
 			return;
 	}
@@ -3000,7 +2968,8 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	bond_set_slave_inactive_flags(bond->current_arp_slave);
 
 	/* search for next candidate */
-	bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
+	next_slave = bond_next_slave(bond, bond->current_arp_slave);
+	bond_for_each_slave_from(bond, slave, i, next_slave) {
 		if (IS_UP(slave->dev)) {
 			slave->link = BOND_LINK_BACK;
 			bond_set_slave_active_flags(slave);
@@ -3041,7 +3010,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (bond->slave_cnt == 0)
+	if (list_empty(&bond->slave_list))
 		goto re_arm;
 
 	should_notify_peers = bond_should_notify_peers(bond);
@@ -3361,13 +3330,12 @@ static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int i;
 
 	/* reset slave->backup and slave->inactive */
 	read_lock(&bond->lock);
-	if (bond->slave_cnt > 0) {
+	if (!list_empty(&bond->slave_list)) {
 		read_lock(&bond->curr_slave_lock);
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave) {
 			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 				&& (slave != bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave);
@@ -3435,13 +3403,11 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct rtnl_link_stats64 temp;
 	struct slave *slave;
-	int i;
 
 	memset(stats, 0, sizeof(*stats));
 
 	read_lock_bh(&bond->lock);
-
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		const struct rtnl_link_stats64 *sstats =
 			dev_get_stats(slave->dev, &temp);
 
@@ -3471,7 +3437,6 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
 		stats->tx_window_errors += sstats->tx_window_errors;
 	}
-
 	read_unlock_bh(&bond->lock);
 
 	return stats;
@@ -3610,7 +3575,6 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int i;
 
 	read_lock(&bond->lock);
 
@@ -3623,7 +3587,7 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 		}
 		read_unlock(&bond->curr_slave_lock);
 	} else {
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave) {
 			dev_uc_sync_multiple(slave->dev, bond_dev);
 			dev_mc_sync_multiple(slave->dev, bond_dev);
 		}
@@ -3635,16 +3599,15 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 static int bond_neigh_init(struct neighbour *n)
 {
 	struct bonding *bond = netdev_priv(n->dev);
-	struct slave *slave = bond->first_slave;
 	const struct net_device_ops *slave_ops;
 	struct neigh_parms parms;
+	struct slave *slave;
 	int ret;
 
+	slave = bond_first_slave(bond);
 	if (!slave)
 		return 0;
-
 	slave_ops = slave->dev->netdev_ops;
-
 	if (!slave_ops->ndo_neigh_setup)
 		return 0;
 
@@ -3687,9 +3650,8 @@ static int bond_neigh_setup(struct net_device *dev,
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *stop_at;
+	struct slave *slave;
 	int res = 0;
-	int i;
 
 	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
 		 (bond_dev ? bond_dev->name : "None"), new_mtu);
@@ -3709,10 +3671,10 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	 * call to the base driver.
 	 */
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		pr_debug("s %p s->p %p c_m %p\n",
 			 slave,
-			 slave->prev,
+			 bond_prev_slave(bond, slave),
 			 slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
@@ -3737,8 +3699,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
 unwind:
 	/* unwind from head to the slave that failed */
-	stop_at = slave;
-	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
+	bond_for_each_slave_continue_reverse(bond, slave) {
 		int tmp_res;
 
 		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
@@ -3762,9 +3723,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr, tmp_sa;
-	struct slave *slave, *stop_at;
+	struct slave *slave;
 	int res = 0;
-	int i;
 
 	if (bond->params.mode == BOND_MODE_ALB)
 		return bond_alb_set_mac_address(bond_dev, addr);
@@ -3797,7 +3757,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	 * call to the base driver.
 	 */
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
 		pr_debug("slave %p %s\n", slave, slave->dev->name);
 
@@ -3829,8 +3789,7 @@ unwind:
 	tmp_sa.sa_family = bond_dev->type;
 
 	/* unwind from head to the slave that failed */
-	stop_at = slave;
-	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {
+	bond_for_each_slave_continue_reverse(bond, slave) {
 		int tmp_res;
 
 		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
@@ -3874,7 +3833,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 		 */
 		slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
 
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave) {
 			slave_no--;
 			if (slave_no < 0)
 				break;
@@ -3940,7 +3899,7 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 
 	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt);
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		slave_no--;
 		if (slave_no < 0)
 			break;
@@ -4041,15 +4000,15 @@ static void bond_set_xmit_hash_policy(struct bonding *bond)
 static inline int bond_slave_override(struct bonding *bond,
 				      struct sk_buff *skb)
 {
-	int i, res = 1;
 	struct slave *slave = NULL;
 	struct slave *check_slave;
+	int res = 1;
 
 	if (!skb->queue_mapping)
 		return 1;
 
 	/* Find out if any slaves have the same mapping as this skb. */
-	bond_for_each_slave(bond, check_slave, i) {
+	bond_for_each_slave(bond, check_slave) {
 		if (check_slave->queue_id == skb->queue_mapping) {
 			slave = check_slave;
 			break;
@@ -4136,7 +4095,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	read_lock(&bond->lock);
 
-	if (bond->slave_cnt)
+	if (!list_empty(&bond->slave_list))
 		ret = __bond_start_xmit(skb, dev);
 	else
 		kfree_skb(skb);
@@ -4182,9 +4141,8 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 				     struct ethtool_cmd *ecmd)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
-	int i;
 	unsigned long speed = 0;
+	struct slave *slave;
 
 	ecmd->duplex = DUPLEX_UNKNOWN;
 	ecmd->port = PORT_OTHER;
@@ -4195,7 +4153,7 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 	 * this is an accurate maximum.
 	 */
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (SLAVE_IS_OK(slave)) {
 			if (slave->speed != SPEED_UNKNOWN)
 				speed += slave->speed;
@@ -4206,6 +4164,7 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 	}
 	ethtool_cmd_speed_set(ecmd, speed ? : SPEED_UNKNOWN);
 	read_unlock(&bond->lock);
+
 	return 0;
 }
 
@@ -4269,7 +4228,7 @@ static void bond_setup(struct net_device *bond_dev)
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
-
+	INIT_LIST_HEAD(&bond->slave_list);
 	bond->params = bonding_defaults;
 
 	/* Initialize pointers */
@@ -4326,13 +4285,14 @@ static void bond_setup(struct net_device *bond_dev)
 static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave, *tmp_slave;
 	struct vlan_entry *vlan, *tmp;
 
 	bond_netpoll_cleanup(bond_dev);
 
 	/* Release the bonded slaves */
-	while (bond->first_slave != NULL)
-		__bond_release_one(bond_dev, bond->first_slave->dev, true);
+	list_for_each_entry_safe(slave, tmp_slave, &bond->slave_list, list)
+		__bond_release_one(bond_dev, slave->dev, true);
 	pr_info("%s: released all slaves\n", bond_dev->name);
 
 	list_del(&bond->bond_list);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 4060d41..20a6ee2 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -12,7 +12,6 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	struct bonding *bond = seq->private;
 	loff_t off = 0;
 	struct slave *slave;
-	int i;
 
 	/* make sure the bond won't be taken away */
 	rcu_read_lock();
@@ -21,10 +20,9 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave)
 		if (++off == *pos)
 			return slave;
-	}
 
 	return NULL;
 }
@@ -36,11 +34,13 @@ static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return bond->first_slave;
+		return bond_first_slave(bond);
 
-	slave = slave->next;
+	if (bond_is_last_slave(bond, slave))
+		return NULL;
+	slave = bond_next_slave(bond, slave);
 
-	return (slave == bond->first_slave) ? NULL : slave;
+	return slave;
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ae02c19..0702e91 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -209,12 +209,12 @@ void bond_destroy_slave_symlinks(struct net_device *master,
 static ssize_t bonding_show_slaves(struct device *d,
 				   struct device_attribute *attr, char *buf)
 {
-	struct slave *slave;
-	int i, res = 0;
 	struct bonding *bond = to_bond(d);
+	struct slave *slave;
+	int res = 0;
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
@@ -227,6 +227,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 	read_unlock(&bond->lock);
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
+
 	return res;
 }
 
@@ -325,7 +326,7 @@ static ssize_t bonding_store_mode(struct device *d,
 		goto out;
 	}
 
-	if (bond->slave_cnt > 0) {
+	if (!list_empty(&bond->slave_list)) {
 		pr_err("unable to update mode of %s because it has slaves.\n",
 			bond->dev->name);
 		ret = -EPERM;
@@ -507,7 +508,7 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	if (bond->slave_cnt != 0) {
+	if (!list_empty(&bond->slave_list)) {
 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -668,7 +669,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			 &newtarget);
 		/* not to race with bond_arp_rcv */
 		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave, i)
+		bond_for_each_slave(bond, slave)
 			slave->target_last_arp_rx[ind] = jiffies;
 		targets[ind] = newtarget;
 		write_unlock_bh(&bond->lock);
@@ -694,7 +695,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			&newtarget);
 
 		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave, i) {
+		bond_for_each_slave(bond, slave) {
 			targets_rx = slave->target_last_arp_rx;
 			j = ind;
 			for (; (j < BOND_MAX_ARP_TARGETS-1) && targets[j+1]; j++)
@@ -1085,10 +1086,9 @@ static ssize_t bonding_store_primary(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t count)
 {
-	int i;
-	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 	char ifname[IFNAMSIZ];
+	struct slave *slave;
 
 	if (!rtnl_trylock())
 		return restart_syscall();
@@ -1114,7 +1114,7 @@ static ssize_t bonding_store_primary(struct device *d,
 		goto out;
 	}
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 			pr_info("%s: Setting %s as primary slave.\n",
 				bond->dev->name, slave->dev->name);
@@ -1260,16 +1260,14 @@ static ssize_t bonding_store_active_slave(struct device *d,
 					  struct device_attribute *attr,
 					  const char *buf, size_t count)
 {
-	int i;
-	struct slave *slave;
-	struct slave *old_active = NULL;
-	struct slave *new_active = NULL;
+	struct slave *slave, *old_active, *new_active;
 	struct bonding *bond = to_bond(d);
 	char ifname[IFNAMSIZ];
 
 	if (!rtnl_trylock())
 		return restart_syscall();
 
+	old_active = new_active = NULL;
 	block_netpoll_tx();
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
@@ -1291,7 +1289,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		goto out;
 	}
 
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 			old_active = bond->curr_active_slave;
 			new_active = slave;
@@ -1475,15 +1473,15 @@ static ssize_t bonding_show_queue_id(struct device *d,
 				     struct device_attribute *attr,
 				     char *buf)
 {
-	struct slave *slave;
-	int i, res = 0;
 	struct bonding *bond = to_bond(d);
+	struct slave *slave;
+	int res = 0;
 
 	if (!rtnl_trylock())
 		return restart_syscall();
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
 			/* not enough space for another interface_name:queue_id pair */
 			if ((PAGE_SIZE - res) > 10)
@@ -1498,6 +1496,7 @@ static ssize_t bonding_show_queue_id(struct device *d,
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
 	rtnl_unlock();
+
 	return res;
 }
 
@@ -1512,7 +1511,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 	struct slave *slave, *update_slave;
 	struct bonding *bond = to_bond(d);
 	u16 qid;
-	int i, ret = count;
+	int ret = count;
 	char *delim;
 	struct net_device *sdev = NULL;
 
@@ -1547,7 +1546,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 
 	/* Search for thes slave and check for duplicate qids */
 	update_slave = NULL;
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (sdev == slave->dev)
 			/*
 			 * We don't need to check the matching
@@ -1599,8 +1598,8 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
-	int i, new_value, ret = count;
 	struct bonding *bond = to_bond(d);
+	int new_value, ret = count;
 	struct slave *slave;
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
@@ -1623,7 +1622,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 	}
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave(bond, slave) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
 				slave->inactive = 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 42d1c65..cfd9b49 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -71,6 +71,28 @@
 	set_fs(fs);			\
 	res; })
 
+/* slave list primitives */
+#define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
+
+/* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
+#define bond_first_slave(bond) \
+	list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
+#define bond_last_slave(bond) \
+	(list_empty(&(bond)->slave_list) ? NULL : \
+					   bond_to_slave((bond)->slave_list.prev))
+
+#define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
+#define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
+
+/* Since bond_first/last_slave can return NULL, these can return NULL too */
+#define bond_next_slave(bond, pos) \
+	(bond_is_last_slave(bond, pos) ? bond_first_slave(bond) : \
+					 bond_to_slave((pos)->list.next))
+
+#define bond_prev_slave(bond, pos) \
+	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
+					  bond_to_slave((pos)->list.prev))
+
 /**
  * bond_for_each_slave_from - iterate the slaves list from a starting point
  * @bond:	the bond holding this list.
@@ -80,37 +102,29 @@
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave_from(bond, pos, cnt, start)	\
-	for (cnt = 0, pos = start;				\
-	     cnt < (bond)->slave_cnt;				\
-             cnt++, pos = (pos)->next)
+#define bond_for_each_slave_from(bond, pos, cnt, start) \
+	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
+	     cnt++, pos = bond_next_slave(bond, pos))
 
 /**
- * bond_for_each_slave_from_to - iterate the slaves list from start point to stop point
- * @bond:	the bond holding this list.
- * @pos:	current slave.
- * @cnt:	counter for number max of moves
- * @start:	start point.
- * @stop:	stop point.
+ * bond_for_each_slave - iterate over all slaves
+ * @bond:	the bond holding this list
+ * @pos:	current slave
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave_from_to(bond, pos, cnt, start, stop)	\
-	for (cnt = 0, pos = start;					\
-	     ((cnt < (bond)->slave_cnt) && (pos != (stop)->next));	\
-             cnt++, pos = (pos)->next)
+#define bond_for_each_slave(bond, pos) \
+	list_for_each_entry(pos, &(bond)->slave_list, list)
 
 /**
- * bond_for_each_slave - iterate the slaves list from head
- * @bond:	the bond holding this list.
- * @pos:	current slave.
- * @cnt:	counter for max number of moves
+ * bond_for_each_slave_reverse - iterate in reverse from a given position
+ * @bond:	the bond holding this list
+ * @pos:	slave to continue from
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave(bond, pos, cnt)	\
-		bond_for_each_slave_from(bond, pos, cnt, (bond)->first_slave)
-
+#define bond_for_each_slave_continue_reverse(bond, pos) \
+	list_for_each_entry_continue_reverse(pos, &(bond)->slave_list, list)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern atomic_t netpoll_block_tx;
@@ -174,8 +188,7 @@ struct vlan_entry {
 
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
-	struct slave *next;
-	struct slave *prev;
+	struct list_head list;
 	struct bonding *bond; /* our master */
 	int    delay;
 	unsigned long jiffies;
@@ -215,7 +228,7 @@ struct slave {
  */
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
-	struct   slave *first_slave;
+	struct   list_head slave_list;
 	struct   slave *curr_active_slave;
 	struct   slave *current_arp_slave;
 	struct   slave *primary_slave;
@@ -270,13 +283,10 @@ static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
 						  struct net_device *slave_dev)
 {
 	struct slave *slave = NULL;
-	int i;
 
-	bond_for_each_slave(bond, slave, i) {
-		if (slave->dev == slave_dev) {
+	bond_for_each_slave(bond, slave)
+		if (slave->dev == slave_dev)
 			return slave;
-		}
-	}
 
 	return NULL;
 }
@@ -477,10 +487,9 @@ static inline void bond_destroy_proc_dir(struct bond_net *bn)
 static inline struct slave *bond_slave_has_mac(struct bonding *bond,
 					       const u8 *mac)
 {
-	int i = 0;
 	struct slave *tmp;
 
-	bond_for_each_slave(bond, tmp, i)
+	bond_for_each_slave(bond, tmp)
 		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
 			return tmp;
 
-- 
1.8.1.4
