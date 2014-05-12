From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] bonding: alloc the structure ad_info dynamically
 in per slave
Date: Mon, 12 May 2014 15:08:43 +0800
Message-ID: <5370737B.5060700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:46280 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbaELHJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 03:09:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct ad_slave_info is very huge, and only be used for 802.3ad mode,
so alloc the structure dynamically could save 356 Bits for every slave in
non 802.3ad mode.

Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c         | 54 +++++++++++++++++-----------------
 drivers/net/bonding/bond_main.c        | 42 ++++++++++++++++++++++----
 drivers/net/bonding/bond_netlink.c     |  2 +-
 drivers/net/bonding/bond_procfs.c      |  2 +-
 drivers/net/bonding/bond_sysfs_slave.c |  2 +-
 drivers/net/bonding/bonding.h          |  2 +-
 6 files changed, 67 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 9a0d61e..24faddd 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -157,7 +157,7 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 
 	rcu_read_lock();
 	first_slave = bond_first_slave_rcu(bond);
-	agg = first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
+	agg = first_slave ? &(SLAVE_AD_INFO(first_slave)->aggregator) : NULL;
 	rcu_read_unlock();
 
 	return agg;
@@ -241,7 +241,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  */
 static inline void __get_state_machine_lock(struct port *port)
 {
-	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
+	spin_lock_bh(&(SLAVE_AD_INFO(port->slave)->state_machine_lock));
 }
 
 /**
@@ -250,7 +250,7 @@ static inline void __get_state_machine_lock(struct port *port)
  */
 static inline void __release_state_machine_lock(struct port *port)
 {
-	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
+	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave)->state_machine_lock));
 }
 
 /**
@@ -350,7 +350,7 @@ static u8 __get_duplex(struct port *port)
 static inline void __initialize_port_locks(struct slave *slave)
 {
 	/* make sure it isn't called twice */
-	spin_lock_init(&(SLAVE_AD_INFO(slave).state_machine_lock));
+	spin_lock_init(&(SLAVE_AD_INFO(slave)->state_machine_lock));
 }
 
 /* Conversions */
@@ -688,8 +688,8 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 	struct slave *slave;
 
 	bond_for_each_slave_rcu(bond, slave, iter)
-		if (SLAVE_AD_INFO(slave).aggregator.is_active)
-			return &(SLAVE_AD_INFO(slave).aggregator);
+		if (SLAVE_AD_INFO(slave)->aggregator.is_active)
+			return &(SLAVE_AD_INFO(slave)->aggregator);
 
 	return NULL;
 }
@@ -1293,7 +1293,7 @@ static void ad_port_selection_logic(struct port *port)
 	}
 	/* search on all aggregators for a suitable aggregator for this port */
 	bond_for_each_slave(bond, slave, iter) {
-		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
+		aggregator = &(SLAVE_AD_INFO(slave)->aggregator);
 
 		/* keep a free aggregator for later use(if needed) */
 		if (!aggregator->lag_ports) {
@@ -1504,7 +1504,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 	best = (active && agg_device_up(active)) ? active : NULL;
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		agg = &(SLAVE_AD_INFO(slave).aggregator);
+		agg = &(SLAVE_AD_INFO(slave)->aggregator);
 
 		agg->is_active = 0;
 
@@ -1549,7 +1549,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->slave ? best->slave->dev->name : "NULL");
 
 		bond_for_each_slave_rcu(bond, slave, iter) {
-			agg = &(SLAVE_AD_INFO(slave).aggregator);
+			agg = &(SLAVE_AD_INFO(slave)->aggregator);
 
 			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 				 agg->aggregator_identifier, agg->num_of_ports,
@@ -1840,16 +1840,16 @@ void bond_3ad_bind_slave(struct slave *slave)
 	struct aggregator *aggregator;
 
 	/* check that the slave has not been initialized yet. */
-	if (SLAVE_AD_INFO(slave).port.slave != slave) {
+	if (SLAVE_AD_INFO(slave)->port.slave != slave) {
 
 		/* port initialization */
-		port = &(SLAVE_AD_INFO(slave).port);
+		port = &(SLAVE_AD_INFO(slave)->port);
 
 		ad_initialize_port(port, bond->params.lacp_fast);
 
 		__initialize_port_locks(slave);
 		port->slave = slave;
-		port->actor_port_number = SLAVE_AD_INFO(slave).id;
+		port->actor_port_number = SLAVE_AD_INFO(slave)->id;
 		/* key is determined according to the link speed, duplex and user key(which
 		 * is yet not supported)
 		 */
@@ -1874,7 +1874,7 @@ void bond_3ad_bind_slave(struct slave *slave)
 		__disable_port(port);
 
 		/* aggregator initialization */
-		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
+		aggregator = &(SLAVE_AD_INFO(slave)->aggregator);
 
 		ad_initialize_agg(aggregator);
 
@@ -1903,8 +1903,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct slave *slave_iter;
 	struct list_head *iter;
 
-	aggregator = &(SLAVE_AD_INFO(slave).aggregator);
-	port = &(SLAVE_AD_INFO(slave).port);
+	aggregator = &(SLAVE_AD_INFO(slave)->aggregator);
+	port = &(SLAVE_AD_INFO(slave)->port);
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
@@ -1932,7 +1932,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 		    (aggregator->lag_ports->next_port_in_aggregator)) {
 			/* find new aggregator for the related port(s) */
 			bond_for_each_slave(bond, slave_iter, iter) {
-				new_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
+				new_aggregator = &(SLAVE_AD_INFO(slave_iter)->aggregator);
 				/* if the new aggregator is empty, or it is
 				 * connected to our port only
 				 */
@@ -2010,7 +2010,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	/* find the aggregator that this port is connected to */
 	bond_for_each_slave(bond, slave_iter, iter) {
-		temp_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
+		temp_aggregator = &(SLAVE_AD_INFO(slave_iter)->aggregator);
 		prev_port = NULL;
 		/* search the port in the aggregator's related ports */
 		for (temp_port = temp_aggregator->lag_ports; temp_port;
@@ -2076,7 +2076,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	if (BOND_AD_INFO(bond).agg_select_timer &&
 	    !(--BOND_AD_INFO(bond).agg_select_timer)) {
 		slave = bond_first_slave_rcu(bond);
-		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
+		port = slave ? &(SLAVE_AD_INFO(slave)->port) : NULL;
 
 		/* select the active aggregator for the bond */
 		if (port) {
@@ -2094,7 +2094,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 	/* for each port run the state machines */
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		port = &(SLAVE_AD_INFO(slave).port);
+		port = &(SLAVE_AD_INFO(slave)->port);
 		if (!port->slave) {
 			pr_warn_ratelimited("%s: Warning: Found an uninitialized port\n",
 					    bond->dev->name);
@@ -2155,7 +2155,7 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 
 	if (length >= sizeof(struct lacpdu)) {
 
-		port = &(SLAVE_AD_INFO(slave).port);
+		port = &(SLAVE_AD_INFO(slave)->port);
 
 		if (!port->slave) {
 			pr_warn_ratelimited("%s: Warning: port of slave %s is uninitialized\n",
@@ -2212,7 +2212,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 {
 	struct port *port;
 
-	port = &(SLAVE_AD_INFO(slave).port);
+	port = &(SLAVE_AD_INFO(slave)->port);
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
@@ -2245,7 +2245,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 {
 	struct port *port;
 
-	port = &(SLAVE_AD_INFO(slave).port);
+	port = &(SLAVE_AD_INFO(slave)->port);
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
@@ -2279,7 +2279,7 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 {
 	struct port *port;
 
-	port = &(SLAVE_AD_INFO(slave).port);
+	port = &(SLAVE_AD_INFO(slave)->port);
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
@@ -2347,7 +2347,7 @@ int bond_3ad_set_carrier(struct bonding *bond)
 		ret = 0;
 		goto out;
 	}
-	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
+	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
 	if (active) {
 		/* are enough slaves available to consider link up? */
 		if (active->num_of_ports < bond->params.min_links) {
@@ -2384,7 +2384,7 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 	struct port *port;
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		port = &(SLAVE_AD_INFO(slave).port);
+		port = &(SLAVE_AD_INFO(slave)->port);
 		if (port->aggregator && port->aggregator->is_active) {
 			aggregator = port->aggregator;
 			break;
@@ -2444,7 +2444,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	first_ok_slave = NULL;
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		agg = SLAVE_AD_INFO(slave).port.aggregator;
+		agg = SLAVE_AD_INFO(slave)->port.aggregator;
 		if (!agg || agg->aggregator_identifier != agg_id)
 			continue;
 
@@ -2522,7 +2522,7 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 
 	lacp_fast = bond->params.lacp_fast;
 	bond_for_each_slave(bond, slave, iter) {
-		port = &(SLAVE_AD_INFO(slave).port);
+		port = &(SLAVE_AD_INFO(slave)->port);
 		__get_state_machine_lock(port);
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9d08e00..7f32a61 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1163,6 +1163,35 @@ static void bond_upper_dev_unlink(struct net_device *bond_dev,
 	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
 }
 
+static struct slave *bond_alloc_slave(struct bonding *bond)
+{
+	struct slave *slave = NULL;
+
+	slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
+	if (!slave)
+		return NULL;
+
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		SLAVE_AD_INFO(slave) = kzalloc(sizeof(struct ad_slave_info),
+					       GFP_KERNEL);
+		if (!SLAVE_AD_INFO(slave)) {
+			kfree(slave);
+			return NULL;
+		}
+	}
+	return slave;
+}
+
+static void bond_free_slave(struct slave *slave)
+{
+	struct bonding *bond = bond_get_bond_by_slave(slave);
+
+	if (bond->params.mode == BOND_MODE_8023AD)
+		kfree(SLAVE_AD_INFO(slave));
+
+	kfree(slave);
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1290,11 +1319,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	    bond->dev->addr_assign_type == NET_ADDR_RANDOM)
 		bond_set_dev_addr(bond->dev, slave_dev);
 
-	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
+	new_slave = bond_alloc_slave(bond);
 	if (!new_slave) {
 		res = -ENOMEM;
 		goto err_undo_flags;
 	}
+
 	/*
 	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
 	 * is set via sysfs or module option if desired.
@@ -1471,14 +1501,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_set_slave_inactive_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
 		/* if this is the first slave */
 		if (!prev_slave) {
-			SLAVE_AD_INFO(new_slave).id = 1;
+			SLAVE_AD_INFO(new_slave)->id = 1;
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
 			 */
 			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL);
 		} else {
-			SLAVE_AD_INFO(new_slave).id =
-				SLAVE_AD_INFO(prev_slave).id + 1;
+			SLAVE_AD_INFO(new_slave)->id =
+				SLAVE_AD_INFO(prev_slave)->id + 1;
 		}
 
 		bond_3ad_bind_slave(new_slave);
@@ -1599,7 +1629,7 @@ err_restore_mtu:
 	dev_set_mtu(slave_dev, new_slave->original_mtu);
 
 err_free:
-	kfree(new_slave);
+	bond_free_slave(new_slave);
 
 err_undo_flags:
 	/* Enslave of first slave has failed and we need to fix master's mac */
@@ -1786,7 +1816,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	slave_dev->priv_flags &= ~IFF_BONDING;
 
-	kfree(slave);
+	bond_free_slave(slave);
 
 	return 0;  /* deletion OK */
 }
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index f847e16..0d06e75 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -59,7 +59,7 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 	if (slave->bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg;
 
-		agg = SLAVE_AD_INFO(slave).port.aggregator;
+		agg = SLAVE_AD_INFO(slave)->port.aggregator;
 		if (agg)
 			if (nla_put_u16(skb, IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
 					agg->aggregator_identifier))
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 013fdd0..6a261c8 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -190,7 +190,7 @@ static void bond_info_show_slave(struct seq_file *seq,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
-			= SLAVE_AD_INFO(slave).port.aggregator;
+			= SLAVE_AD_INFO(slave)->port.aggregator;
 
 		if (agg)
 			seq_printf(seq, "Aggregator ID: %d\n",
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index 2e4eec5..89bc3b3 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -70,7 +70,7 @@ static ssize_t ad_aggregator_id_show(struct slave *slave, char *buf)
 	const struct aggregator *agg;
 
 	if (slave->bond->params.mode == BOND_MODE_8023AD) {
-		agg = SLAVE_AD_INFO(slave).port.aggregator;
+		agg = SLAVE_AD_INFO(slave)->port.aggregator;
 		if (agg)
 			return sprintf(buf, "%d\n",
 				       agg->aggregator_identifier);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c1c7c2f..c3f44eb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -205,7 +205,7 @@ struct slave {
 	u32    speed;
 	u16    queue_id;
 	u8     perm_hwaddr[ETH_ALEN];
-	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
+	struct ad_slave_info *ad_info;
 	struct tlb_slave_info tlb_info;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll *np;
-- 
1.8.0
