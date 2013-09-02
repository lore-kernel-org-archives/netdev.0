From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 13/21] bonding: make bond_for_each_slave() use lower neighbour's private
Date: Mon,  2 Sep 2013 23:39:17 +0200
Message-ID: <1378157965-17537-14-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326Ab3IBVka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:40:30 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It needs a list_head *iter, so add it wherever needed. Use both non-rcu and
rcu variants.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c    |  8 ++--
 drivers/net/bonding/bond_alb.c    | 18 ++++----
 drivers/net/bonding/bond_main.c   | 88 +++++++++++++++++++++++++--------------
 drivers/net/bonding/bond_procfs.c |  5 ++-
 drivers/net/bonding/bond_sysfs.c  | 23 ++++++----
 drivers/net/bonding/bonding.h     | 12 +++---
 6 files changed, 98 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index f0cca88..7430cbb 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2419,6 +2419,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slave *slave, *start_at;
 	struct bonding *bond = netdev_priv(dev);
+	struct list_head *iter;
 	int slave_agg_no;
 	int slaves_in_agg;
 	int agg_id;
@@ -2444,7 +2445,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
 		if (agg && (agg->aggregator_identifier == agg_id)) {
@@ -2514,14 +2515,15 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
  */
 void bond_3ad_update_lacp_rate(struct bonding *bond)
 {
-	struct slave *slave;
 	struct port *port = NULL;
+	struct list_head *iter;
+	struct slave *slave;
 	int lacp_fast;
 
 	write_lock_bh(&bond->lock);
 	lacp_fast = bond->params.lacp_fast;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (port->slave == NULL)
 			continue;
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bda976f..738eeae 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -223,13 +223,14 @@ static long long compute_gap(struct slave *slave)
 static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 {
 	struct slave *slave, *least_loaded;
+	struct list_head *iter;
 	long long max_gap;
 
 	least_loaded = NULL;
 	max_gap = LLONG_MIN;
 
 	/* Find the slave with the largest gap */
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (SLAVE_IS_OK(slave)) {
 			long long gap = compute_gap(slave);
 
@@ -1174,8 +1175,9 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
  */
 static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slave *slave)
 {
-	struct slave *tmp_slave1, *free_mac_slave = NULL;
 	struct slave *has_bond_addr = bond->curr_active_slave;
+	struct slave *tmp_slave1, *free_mac_slave = NULL;
+	struct list_head *iter;
 
 	if (!bond_has_slaves(bond)) {
 		/* this is the first slave */
@@ -1198,7 +1200,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	/* The slave's address is equal to the address of the bond.
 	 * Search for a spare address in the bond for this slave.
 	 */
-	bond_for_each_slave(bond, tmp_slave1) {
+	bond_for_each_slave(bond, tmp_slave1, iter) {
 		if (!bond_slave_has_mac(bond, tmp_slave1->perm_hwaddr)) {
 			/* no slave has tmp_slave1's perm addr
 			 * as its curr addr
@@ -1249,6 +1251,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 static int alb_set_mac_address(struct bonding *bond, void *addr)
 {
 	struct slave *slave, *rollback_slave;
+	struct list_head *iter;
 	struct sockaddr sa;
 	char tmp_addr[ETH_ALEN];
 	int res;
@@ -1256,7 +1259,7 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 	if (bond->alb_info.rlb_enabled)
 		return 0;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		/* save net_device's current hw address */
 		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
 
@@ -1276,7 +1279,7 @@ unwind:
 	sa.sa_family = bond->dev->type;
 
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave(bond, rollback_slave) {
+	bond_for_each_slave(bond, rollback_slave, iter) {
 		if (rollback_slave == slave)
 			break;
 		memcpy(tmp_addr, rollback_slave->dev->dev_addr, ETH_ALEN);
@@ -1462,6 +1465,7 @@ void bond_alb_monitor(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    alb_work.work);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct list_head *iter;
 	struct slave *slave;
 
 	read_lock(&bond->lock);
@@ -1484,7 +1488,7 @@ void bond_alb_monitor(struct work_struct *work)
 		 */
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave)
+		bond_for_each_slave(bond, slave, iter)
 			alb_send_learning_packets(slave, slave->dev->dev_addr);
 
 		read_unlock(&bond->curr_slave_lock);
@@ -1497,7 +1501,7 @@ void bond_alb_monitor(struct work_struct *work)
 
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			tlb_clear_slave(bond, slave, 1);
 			if (slave == bond->curr_active_slave) {
 				SLAVE_TLB_INFO(slave).load =
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0a4aa0d..297b910 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -333,9 +333,10 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *rollback_slave;
+	struct list_head *iter;
 	int res;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		res = vlan_vid_add(slave->dev, proto, vid);
 		if (res)
 			goto unwind;
@@ -345,7 +346,7 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 
 unwind:
 	/* unwind to the slave that failed */
-	bond_for_each_slave(bond, rollback_slave) {
+	bond_for_each_slave(bond, rollback_slave, iter) {
 		if (rollback_slave == slave)
 			break;
 
@@ -364,9 +365,10 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 				 __be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct list_head *iter;
 	struct slave *slave;
 
-	bond_for_each_slave(bond, slave)
+	bond_for_each_slave(bond, slave, iter)
 		vlan_vid_del(slave->dev, proto, vid);
 
 	if (bond_is_lb(bond))
@@ -386,6 +388,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
  */
 static int bond_set_carrier(struct bonding *bond)
 {
+	struct list_head *iter;
 	struct slave *slave;
 
 	if (!bond_has_slaves(bond))
@@ -394,7 +397,7 @@ static int bond_set_carrier(struct bonding *bond)
 	if (bond->params.mode == BOND_MODE_8023AD)
 		return bond_3ad_set_carrier(bond);
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (slave->link == BOND_LINK_UP) {
 			if (!netif_carrier_ok(bond->dev)) {
 				netif_carrier_on(bond->dev);
@@ -526,7 +529,9 @@ static int bond_check_dev_link(struct bonding *bond,
  */
 static int bond_set_promiscuity(struct bonding *bond, int inc)
 {
+	struct list_head *iter;
 	int err = 0;
+
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
@@ -536,7 +541,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	} else {
 		struct slave *slave;
 
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			err = dev_set_promiscuity(slave->dev, inc);
 			if (err)
 				return err;
@@ -550,7 +555,9 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
  */
 static int bond_set_allmulti(struct bonding *bond, int inc)
 {
+	struct list_head *iter;
 	int err = 0;
+
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
@@ -560,7 +567,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	} else {
 		struct slave *slave;
 
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			err = dev_set_allmulti(slave->dev, inc);
 			if (err)
 				return err;
@@ -1051,9 +1058,10 @@ static void bond_poll_controller(struct net_device *bond_dev)
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct list_head *iter;
 	struct slave *slave;
 
-	bond_for_each_slave(bond, slave)
+	bond_for_each_slave(bond, slave, iter)
 		if (IS_UP(slave->dev))
 			slave_disable_netpoll(slave);
 }
@@ -1061,10 +1069,11 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, gfp_t gfp)
 {
 	struct bonding *bond = netdev_priv(dev);
+	struct list_head *iter;
 	struct slave *slave;
 	int err = 0;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		err = slave_enable_netpoll(slave);
 		if (err) {
 			bond_netpoll_cleanup(dev);
@@ -1091,8 +1100,9 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
-	struct slave *slave;
 	struct bonding *bond = netdev_priv(dev);
+	struct list_head *iter;
+	struct slave *slave;
 	netdev_features_t mask;
 
 	read_lock(&bond->lock);
@@ -1107,7 +1117,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		features = netdev_increment_features(features,
 						     slave->dev->features,
 						     mask);
@@ -1125,9 +1135,10 @@ out:
 
 static void bond_compute_features(struct bonding *bond)
 {
-	struct slave *slave;
-	struct net_device *bond_dev = bond->dev;
 	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
+	struct net_device *bond_dev = bond->dev;
+	struct list_head *iter;
+	struct slave *slave;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	unsigned int gso_max_size = GSO_MAX_SIZE;
 	u16 gso_max_segs = GSO_MAX_SEGS;
@@ -1138,7 +1149,7 @@ static void bond_compute_features(struct bonding *bond)
 	if (!bond_has_slaves(bond))
 		goto done;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		vlan_features = netdev_increment_features(vlan_features,
 			slave->dev->vlan_features, BOND_VLAN_FEATURES);
 
@@ -1993,11 +2004,12 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct list_head *iter;
 	int i = 0, res = -ENODEV;
 	struct slave *slave;
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (i++ == (int)info->slave_id) {
 			res = 0;
 			strcpy(info->slave_name, slave->dev->name);
@@ -2018,12 +2030,13 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 static int bond_miimon_inspect(struct bonding *bond)
 {
 	int link_state, commit = 0;
+	struct list_head *iter;
 	struct slave *slave;
 	bool ignore_updelay;
 
 	ignore_updelay = !bond->curr_active_slave ? true : false;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
@@ -2117,9 +2130,10 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 static void bond_miimon_commit(struct bonding *bond)
 {
+	struct list_head *iter;
 	struct slave *slave;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		switch (slave->new_link) {
 		case BOND_LINK_NOCHANGE:
 			continue;
@@ -2515,6 +2529,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
 	struct slave *slave, *oldcurrent;
+	struct list_head *iter;
 	int do_failover = 0;
 
 	read_lock(&bond->lock);
@@ -2531,7 +2546,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 * TODO: what about up/down delay in arp mode? it wasn't here before
 	 *       so it can wait
 	 */
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		unsigned long trans_start = dev_trans_start(slave->dev);
 
 		if (slave->link != BOND_LINK_UP) {
@@ -2622,10 +2637,11 @@ re_arm:
 static int bond_ab_arp_inspect(struct bonding *bond)
 {
 	unsigned long trans_start, last_rx;
+	struct list_head *iter;
 	struct slave *slave;
 	int commit = 0;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 		last_rx = slave_last_rx(bond, slave);
 
@@ -2692,9 +2708,10 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 static void bond_ab_arp_commit(struct bonding *bond)
 {
 	unsigned long trans_start;
+	struct list_head *iter;
 	struct slave *slave;
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		switch (slave->new_link) {
 		case BOND_LINK_NOCHANGE:
 			continue;
@@ -3158,13 +3175,14 @@ static void bond_work_cancel_all(struct bonding *bond)
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct list_head *iter;
 	struct slave *slave;
 
 	/* reset slave->backup and slave->inactive */
 	read_lock(&bond->lock);
 	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 				&& (slave != bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave);
@@ -3231,12 +3249,13 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct rtnl_link_stats64 temp;
+	struct list_head *iter;
 	struct slave *slave;
 
 	memset(stats, 0, sizeof(*stats));
 
 	read_lock_bh(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		const struct rtnl_link_stats64 *sstats =
 			dev_get_stats(slave->dev, &temp);
 
@@ -3403,6 +3422,7 @@ static void bond_change_rx_flags(struct net_device *bond_dev, int change)
 static void bond_set_rx_mode(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct list_head *iter;
 	struct slave *slave;
 
 	ASSERT_RTNL();
@@ -3414,7 +3434,7 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 			dev_mc_sync(slave->dev, bond_dev);
 		}
 	} else {
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			dev_uc_sync_multiple(slave->dev, bond_dev);
 			dev_mc_sync_multiple(slave->dev, bond_dev);
 		}
@@ -3482,6 +3502,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *rollback_slave;
+	struct list_head *iter;
 	int res = 0;
 
 	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
@@ -3502,7 +3523,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	 * call to the base driver.
 	 */
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		pr_debug("s %p s->p %p c_m %p\n",
 			 slave,
 			 bond_prev_slave(bond, slave),
@@ -3530,7 +3551,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
 unwind:
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave(bond, rollback_slave) {
+	bond_for_each_slave(bond, rollback_slave, iter) {
 		int tmp_res;
 
 		if (rollback_slave == slave);
@@ -3558,6 +3579,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *rollback_slave;
 	struct sockaddr *sa = addr, tmp_sa;
+	struct list_head *iter;
 	int res = 0;
 
 	if (bond->params.mode == BOND_MODE_ALB)
@@ -3591,7 +3613,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	 * call to the base driver.
 	 */
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
 		pr_debug("slave %p %s\n", slave, slave->dev->name);
 
@@ -3623,7 +3645,7 @@ unwind:
 	tmp_sa.sa_family = bond_dev->type;
 
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave(bond, rollback_slave) {
+	bond_for_each_slave(bond, rollback_slave, iter) {
 		int tmp_res;
 
 		if (rollback_slave == slave)
@@ -3651,11 +3673,12 @@ unwind:
  */
 void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 {
+	struct list_head *iter;
 	struct slave *slave;
 	int i = slave_id;
 
 	/* Here we start from the slave with slave_id */
-	bond_for_each_slave_rcu(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (--i < 0) {
 			if (slave_can_tx(slave)) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
@@ -3666,7 +3689,7 @@ void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 
 	/* Here we start from the first slave up to slave_id */
 	i = slave_id;
-	bond_for_each_slave_rcu(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (--i < 0)
 			break;
 		if (slave_can_tx(slave)) {
@@ -3743,8 +3766,9 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave = NULL;
+	struct list_head *iter;
 
-	bond_for_each_slave_rcu(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (bond_is_last_slave(bond, slave))
 			break;
 		if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
@@ -3793,13 +3817,14 @@ static inline int bond_slave_override(struct bonding *bond,
 {
 	struct slave *slave = NULL;
 	struct slave *check_slave;
+	struct list_head *iter;
 	int res = 1;
 
 	if (!skb->queue_mapping)
 		return 1;
 
 	/* Find out if any slaves have the same mapping as this skb. */
-	bond_for_each_slave_rcu(bond, check_slave) {
+	bond_for_each_slave_rcu(bond, check_slave, iter) {
 		if (check_slave->queue_id == skb->queue_mapping) {
 			slave = check_slave;
 			break;
@@ -3931,6 +3956,7 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	unsigned long speed = 0;
+	struct list_head *iter;
 	struct slave *slave;
 
 	ecmd->duplex = DUPLEX_UNKNOWN;
@@ -3942,7 +3968,7 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 	 * this is an accurate maximum.
 	 */
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (SLAVE_IS_OK(slave)) {
 			if (slave->speed != SPEED_UNKNOWN)
 				speed += slave->speed;
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 20a6ee2..7af5646 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -10,8 +10,9 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(&bond->lock)
 {
 	struct bonding *bond = seq->private;
-	loff_t off = 0;
+	struct list_head *iter;
 	struct slave *slave;
+	loff_t off = 0;
 
 	/* make sure the bond won't be taken away */
 	rcu_read_lock();
@@ -20,7 +21,7 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	bond_for_each_slave(bond, slave)
+	bond_for_each_slave(bond, slave, iter)
 		if (++off == *pos)
 			return slave;
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8721dcb..b4ae9f5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -175,11 +175,12 @@ static ssize_t bonding_show_slaves(struct device *d,
 				   struct device_attribute *attr, char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	struct slave *slave;
 	int res = 0;
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
@@ -602,6 +603,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	struct slave *slave;
 	__be32 newtarget, *targets;
 	unsigned long *targets_rx;
@@ -634,7 +636,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			 &newtarget);
 		/* not to race with bond_arp_rcv */
 		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave)
+		bond_for_each_slave(bond, slave, iter)
 			slave->target_last_arp_rx[ind] = jiffies;
 		targets[ind] = newtarget;
 		write_unlock_bh(&bond->lock);
@@ -660,7 +662,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			&newtarget);
 
 		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave) {
+		bond_for_each_slave(bond, slave, iter) {
 			targets_rx = slave->target_last_arp_rx;
 			j = ind;
 			for (; (j < BOND_MAX_ARP_TARGETS-1) && targets[j+1]; j++)
@@ -1052,6 +1054,7 @@ static ssize_t bonding_store_primary(struct device *d,
 				     const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	char ifname[IFNAMSIZ];
 	struct slave *slave;
 
@@ -1079,7 +1082,7 @@ static ssize_t bonding_store_primary(struct device *d,
 		goto out;
 	}
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 			pr_info("%s: Setting %s as primary slave.\n",
 				bond->dev->name, slave->dev->name);
@@ -1227,6 +1230,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 {
 	struct slave *slave, *old_active, *new_active;
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	char ifname[IFNAMSIZ];
 
 	if (!rtnl_trylock())
@@ -1254,7 +1258,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		goto out;
 	}
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 			old_active = bond->curr_active_slave;
 			new_active = slave;
@@ -1434,6 +1438,7 @@ static ssize_t bonding_show_queue_id(struct device *d,
 				     char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	struct slave *slave;
 	int res = 0;
 
@@ -1441,7 +1446,7 @@ static ssize_t bonding_show_queue_id(struct device *d,
 		return restart_syscall();
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
 			/* not enough space for another interface_name:queue_id pair */
 			if ((PAGE_SIZE - res) > 10)
@@ -1470,6 +1475,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 {
 	struct slave *slave, *update_slave;
 	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
 	u16 qid;
 	int ret = count;
 	char *delim;
@@ -1506,7 +1512,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 
 	/* Search for thes slave and check for duplicate qids */
 	update_slave = NULL;
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (sdev == slave->dev)
 			/*
 			 * We don't need to check the matching
@@ -1560,6 +1566,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 	int new_value, ret = count;
+	struct list_head *iter;
 	struct slave *slave;
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
@@ -1582,7 +1589,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 	}
 
 	read_lock(&bond->lock);
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
 				slave->inactive = 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8c11f96..b6dc9db 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -112,15 +112,16 @@
  * bond_for_each_slave - iterate over all slaves
  * @bond:	the bond holding this list
  * @pos:	current slave
+ * @iter:	list_head * iterator
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave(bond, pos) \
-	list_for_each_entry(pos, &(bond)->slave_list, list)
+#define bond_for_each_slave(bond, pos, iter) \
+	netdev_for_each_lower_neigh_private((bond)->dev, pos, iter)
 
 /* Caller must have rcu_read_lock */
-#define bond_for_each_slave_rcu(bond, pos) \
-	list_for_each_entry_rcu(pos, &(bond)->slave_list, list)
+#define bond_for_each_slave_rcu(bond, pos, iter) \
+	netdev_for_each_lower_neigh_private_rcu((bond)->dev, pos, iter)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern atomic_t netpoll_block_tx;
@@ -493,9 +494,10 @@ static inline void bond_destroy_proc_dir(struct bond_net *bn)
 static inline struct slave *bond_slave_has_mac(struct bonding *bond,
 					       const u8 *mac)
 {
+	struct list_head *iter;
 	struct slave *tmp;
 
-	bond_for_each_slave(bond, tmp)
+	bond_for_each_slave(bond, tmp, iter)
 		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
 			return tmp;
 
-- 
1.8.4
