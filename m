From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v7 net-next 2/2] bonding: Simplify the xmit function for modes that use xmit_hash
Date: Fri,  3 Oct 2014 17:48:40 -0700
Message-ID: <1412383720-1540-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:54622 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954AbaJDAso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 20:48:44 -0400
Received: by mail-pa0-f74.google.com with SMTP id kq14so560267pab.5
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 17:48:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier change to use usable slave array for TLB mode had an additional
performance advantage. So extending the same logic to all other modes
that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
Also consolidating this with the earlier TLB change.

The main idea is to build the usable slaves array in the control path
and use that array for slave selection during xmit operation.

Measured performance in a setup with a bond of 4x1G NICs with 200
instances of netperf for the modes involved (3ad, xor, tlb)
cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5

Mode        TPS-Before   TPS-After

802.3ad   : 468,694      493,101
TLB (lb=0): 392,583      392,965
XOR       : 475,696      484,517

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v1:
  (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
      the slave that need to be removed.
  (b) Freeing of array will assign NULL (to handle bond->down to bond->up
      transition gracefully.
  (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
      failure.
  (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
      will populate the array even if these parameters are not used.
  (e) 3AD: Should handle the ad_agg_selection_logic correctly.
v2:
  (a) Removed rcu_read_{un}lock() calls from array manipulation code.
  (b) Slave link-events now refresh array for all these modes.
  (c) Moved free-array call from bond_close() to bond_uninit().
v3:
  (a) Fixed null pointer dereference.
  (b) Removed bond->lock lockdep dependency.
v4:
  (a) Made to changes to comply with Nikolay's locking changes
  (b) Added a work-queue to refresh slave-array when RTNL is not held
  (c) Array refresh happens ONLY with RTNL now.
  (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
v5:
  (a) Consolidated all delayed slave-array updates at one place in
      3ad_state_machine_handler()
v6:
  (a) Free slave array when there is no active aggregator
v7:
  (a) Couple of trivial changes.

 drivers/net/bonding/bond_3ad.c  | 140 +++++++++++------------------
 drivers/net/bonding/bond_alb.c  |  51 ++---------
 drivers/net/bonding/bond_alb.h  |   8 --
 drivers/net/bonding/bond_main.c | 192 +++++++++++++++++++++++++++++++++++++---
 drivers/net/bonding/bonding.h   |  10 +++
 5 files changed, 249 insertions(+), 152 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7e9e522fd476..2110215f3528 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -102,17 +102,20 @@ static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 /* ================= main 802.3ad protocol functions ================== */
 static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);
-static void ad_mux_machine(struct port *port);
+static void ad_mux_machine(struct port *port, bool *update_slave_arr);
 static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port);
 static void ad_tx_machine(struct port *port);
 static void ad_periodic_machine(struct port *port);
-static void ad_port_selection_logic(struct port *port);
-static void ad_agg_selection_logic(struct aggregator *aggregator);
+static void ad_port_selection_logic(struct port *port, bool *update_slave_arr);
+static void ad_agg_selection_logic(struct aggregator *aggregator,
+				   bool *update_slave_arr);
 static void ad_clear_agg(struct aggregator *aggregator);
 static void ad_initialize_agg(struct aggregator *aggregator);
 static void ad_initialize_port(struct port *port, int lacp_fast);
-static void ad_enable_collecting_distributing(struct port *port);
-static void ad_disable_collecting_distributing(struct port *port);
+static void ad_enable_collecting_distributing(struct port *port,
+					      bool *update_slave_arr);
+static void ad_disable_collecting_distributing(struct port *port,
+					       bool *update_slave_arr);
 static void ad_marker_info_received(struct bond_marker *marker_info,
 				    struct port *port);
 static void ad_marker_response_received(struct bond_marker *marker,
@@ -796,8 +799,9 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 /**
  * ad_mux_machine - handle a port's mux state machine
  * @port: the port we're looking at
+ * @update_slave_arr: Does slave array need update?
  */
-static void ad_mux_machine(struct port *port)
+static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 {
 	mux_states_t last_state;
 
@@ -901,7 +905,8 @@ static void ad_mux_machine(struct port *port)
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
 			port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
-			ad_disable_collecting_distributing(port);
+			ad_disable_collecting_distributing(port,
+							   update_slave_arr);
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
 			port->ntt = true;
@@ -913,13 +918,15 @@ static void ad_mux_machine(struct port *port)
 			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
-			ad_disable_collecting_distributing(port);
+			ad_disable_collecting_distributing(port,
+							   update_slave_arr);
 			port->ntt = true;
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			port->actor_oper_port_state |= AD_STATE_COLLECTING;
 			port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
-			ad_enable_collecting_distributing(port);
+			ad_enable_collecting_distributing(port,
+							  update_slave_arr);
 			port->ntt = true;
 			break;
 		default:
@@ -1187,12 +1194,13 @@ static void ad_periodic_machine(struct port *port)
 /**
  * ad_port_selection_logic - select aggregation groups
  * @port: the port we're looking at
+ * @update_slave_arr: Does slave array need update?
  *
  * Select aggregation groups, and assign each port for it's aggregetor. The
  * selection logic is called in the inititalization (after all the handshkes),
  * and after every lacpdu receive (if selected is off).
  */
-static void ad_port_selection_logic(struct port *port)
+static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
 {
 	struct aggregator *aggregator, *free_aggregator = NULL, *temp_aggregator;
 	struct port *last_port = NULL, *curr_port;
@@ -1347,7 +1355,7 @@ static void ad_port_selection_logic(struct port *port)
 			      __agg_ports_are_ready(port->aggregator));
 
 	aggregator = __get_first_agg(port);
-	ad_agg_selection_logic(aggregator);
+	ad_agg_selection_logic(aggregator, update_slave_arr);
 }
 
 /* Decide if "agg" is a better choice for the new active aggregator that
@@ -1435,6 +1443,7 @@ static int agg_device_up(const struct aggregator *agg)
 /**
  * ad_agg_selection_logic - select an aggregation group for a team
  * @aggregator: the aggregator we're looking at
+ * @update_slave_arr: Does slave array need update?
  *
  * It is assumed that only one aggregator may be selected for a team.
  *
@@ -1457,7 +1466,8 @@ static int agg_device_up(const struct aggregator *agg)
  * __get_active_agg() won't work correctly. This function should be better
  * called with the bond itself, and retrieve the first agg from it.
  */
-static void ad_agg_selection_logic(struct aggregator *agg)
+static void ad_agg_selection_logic(struct aggregator *agg,
+				   bool *update_slave_arr)
 {
 	struct aggregator *best, *active, *origin;
 	struct bonding *bond = agg->slave->bond;
@@ -1550,6 +1560,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 				__disable_port(port);
 			}
 		}
+		/* Slave array needs update. */
+		*update_slave_arr = true;
 	}
 
 	/* if the selected aggregator is of join individuals
@@ -1678,24 +1690,30 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 /**
  * ad_enable_collecting_distributing - enable a port's transmit/receive
  * @port: the port we're looking at
+ * @update_slave_arr: Does slave array need update?
  *
  * Enable @port if it's in an active aggregator
  */
-static void ad_enable_collecting_distributing(struct port *port)
+static void ad_enable_collecting_distributing(struct port *port,
+					      bool *update_slave_arr)
 {
 	if (port->aggregator->is_active) {
 		pr_debug("Enabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
 		__enable_port(port);
+		/* Slave array needs update */
+		*update_slave_arr = true;
 	}
 }
 
 /**
  * ad_disable_collecting_distributing - disable a port's transmit/receive
  * @port: the port we're looking at
+ * @update_slave_arr: Does slave array need update?
  */
-static void ad_disable_collecting_distributing(struct port *port)
+static void ad_disable_collecting_distributing(struct port *port,
+					       bool *update_slave_arr)
 {
 	if (port->aggregator &&
 	    !MAC_ADDRESS_EQUAL(&(port->aggregator->partner_system),
@@ -1704,6 +1722,8 @@ static void ad_disable_collecting_distributing(struct port *port)
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
 		__disable_port(port);
+		/* Slave array needs an update */
+		*update_slave_arr = true;
 	}
 }
 
@@ -1868,6 +1888,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct bonding *bond = slave->bond;
 	struct slave *slave_iter;
 	struct list_head *iter;
+	bool dummy_slave_update; /* Ignore this value as caller updates array */
 
 	/* Sync against bond_3ad_state_machine_handler() */
 	spin_lock_bh(&bond->mode_lock);
@@ -1951,7 +1972,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				ad_clear_agg(aggregator);
 
 				if (select_new_active_agg)
-					ad_agg_selection_logic(__get_first_agg(port));
+					ad_agg_selection_logic(__get_first_agg(port),
+							       &dummy_slave_update);
 			} else {
 				netdev_warn(bond->dev, "unbinding aggregator, and could not find a new aggregator for its ports\n");
 			}
@@ -1966,7 +1988,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				/* select new active aggregator */
 				temp_aggregator = __get_first_agg(port);
 				if (temp_aggregator)
-					ad_agg_selection_logic(temp_aggregator);
+					ad_agg_selection_logic(temp_aggregator,
+							       &dummy_slave_update);
 			}
 		}
 	}
@@ -1996,7 +2019,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					if (select_new_active_agg) {
 						netdev_info(bond->dev, "Removing an active aggregator\n");
 						/* select new active aggregator */
-						ad_agg_selection_logic(__get_first_agg(port));
+						ad_agg_selection_logic(__get_first_agg(port),
+							               &dummy_slave_update);
 					}
 				}
 				break;
@@ -2031,6 +2055,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct slave *slave;
 	struct port *port;
 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
+	bool update_slave_arr = false;
 
 	/* Lock to protect data accessed by all (e.g., port->sm_vars) and
 	 * against running with bond_3ad_unbind_slave. ad_rx_machine may run
@@ -2058,7 +2083,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 			}
 
 			aggregator = __get_first_agg(port);
-			ad_agg_selection_logic(aggregator);
+			ad_agg_selection_logic(aggregator, &update_slave_arr);
 		}
 		bond_3ad_set_carrier(bond);
 	}
@@ -2074,8 +2099,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 		ad_rx_machine(NULL, port);
 		ad_periodic_machine(port);
-		ad_port_selection_logic(port);
-		ad_mux_machine(port);
+		ad_port_selection_logic(port, &update_slave_arr);
+		ad_mux_machine(port, &update_slave_arr);
 		ad_tx_machine(port);
 
 		/* turn off the BEGIN bit, since we already handled it */
@@ -2093,6 +2118,9 @@ re_arm:
 	rcu_read_unlock();
 	spin_unlock_bh(&bond->mode_lock);
 
+	if (update_slave_arr)
+		bond_slave_arr_work_rearm(bond, 0);
+
 	if (should_notify_rtnl && rtnl_trylock()) {
 		bond_slave_state_notify(bond);
 		rtnl_unlock();
@@ -2283,6 +2311,11 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	port->sm_vars |= AD_PORT_BEGIN;
 
 	spin_unlock_bh(&slave->bond->mode_lock);
+
+	/* RTNL is held and mode_lock is released so it's safe
+	 * to update slave_array here.
+	 */
+	bond_update_slave_arr(slave->bond, NULL);
 }
 
 /**
@@ -2377,73 +2410,6 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 	return ret;
 }
 
-int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
-{
-	struct bonding *bond = netdev_priv(dev);
-	struct slave *slave, *first_ok_slave;
-	struct aggregator *agg;
-	struct ad_info ad_info;
-	struct list_head *iter;
-	int slaves_in_agg;
-	int slave_agg_no;
-	int agg_id;
-
-	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		netdev_dbg(dev, "__bond_3ad_get_active_agg_info failed\n");
-		goto err_free;
-	}
-
-	slaves_in_agg = ad_info.ports;
-	agg_id = ad_info.aggregator_id;
-
-	if (slaves_in_agg == 0) {
-		netdev_dbg(dev, "active aggregator is empty\n");
-		goto err_free;
-	}
-
-	slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
-	first_ok_slave = NULL;
-
-	bond_for_each_slave_rcu(bond, slave, iter) {
-		agg = SLAVE_AD_INFO(slave)->port.aggregator;
-		if (!agg || agg->aggregator_identifier != agg_id)
-			continue;
-
-		if (slave_agg_no >= 0) {
-			if (!first_ok_slave && bond_slave_can_tx(slave))
-				first_ok_slave = slave;
-			slave_agg_no--;
-			continue;
-		}
-
-		if (bond_slave_can_tx(slave)) {
-			bond_dev_queue_xmit(bond, skb, slave->dev);
-			goto out;
-		}
-	}
-
-	if (slave_agg_no >= 0) {
-		netdev_err(dev, "Couldn't find a slave to tx on for aggregator ID %d\n",
-			   agg_id);
-		goto err_free;
-	}
-
-	/* we couldn't find any suitable slave after the agg_no, so use the
-	 * first suitable found, if found.
-	 */
-	if (first_ok_slave)
-		bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
-	else
-		goto err_free;
-
-out:
-	return NETDEV_TX_OK;
-err_free:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb_any(skb);
-	goto out;
-}
-
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave)
 {
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 615f3bebd019..d2eadab787c5 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -177,7 +177,6 @@ static int tlb_initialize(struct bonding *bond)
 static void tlb_deinitialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct tlb_up_slave *arr;
 
 	spin_lock_bh(&bond->mode_lock);
 
@@ -185,10 +184,6 @@ static void tlb_deinitialize(struct bonding *bond)
 	bond_info->tx_hashtbl = NULL;
 
 	spin_unlock_bh(&bond->mode_lock);
-
-	arr = rtnl_dereference(bond_info->slave_arr);
-	if (arr)
-		kfree_rcu(arr, rcu);
 }
 
 static long long compute_gap(struct slave *slave)
@@ -1336,39 +1331,9 @@ out:
 	return NETDEV_TX_OK;
 }
 
-static int bond_tlb_update_slave_arr(struct bonding *bond,
-				     struct slave *skipslave)
-{
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *tx_slave;
-	struct list_head *iter;
-	struct tlb_up_slave *new_arr, *old_arr;
-
-	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
-			  GFP_ATOMIC);
-	if (!new_arr)
-		return -ENOMEM;
-
-	bond_for_each_slave(bond, tx_slave, iter) {
-		if (!bond_slave_can_tx(tx_slave))
-			continue;
-		if (skipslave == tx_slave)
-			continue;
-		new_arr->arr[new_arr->count++] = tx_slave;
-	}
-
-	old_arr = rtnl_dereference(bond_info->slave_arr);
-	rcu_assign_pointer(bond_info->slave_arr, new_arr);
-	if (old_arr)
-		kfree_rcu(old_arr, rcu);
-
-	return 0;
-}
-
 int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct ethhdr *eth_data;
 	struct slave *tx_slave = NULL;
 	u32 hash_index;
@@ -1389,12 +1354,14 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 							      hash_index & 0xFF,
 							      skb->len);
 			} else {
-				struct tlb_up_slave *slaves;
+				struct bond_up_slave *slaves;
+				unsigned int count;
 
-				slaves = rcu_dereference(bond_info->slave_arr);
-				if (slaves && slaves->count)
+				slaves = rcu_dereference(bond->slave_arr);
+				count = slaves ? ACCESS_ONCE(slaves->count) : 0;
+				if (likely(count))
 					tx_slave = slaves->arr[hash_index %
-							       slaves->count];
+							       count];
 			}
 			break;
 		}
@@ -1641,10 +1608,6 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 		rlb_clear_slave(bond, slave);
 	}
 
-	if (bond_is_nondyn_tlb(bond))
-		if (bond_tlb_update_slave_arr(bond, slave))
-			pr_err("Failed to build slave-array for TLB mode.\n");
-
 }
 
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link)
@@ -1669,7 +1632,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
 	}
 
 	if (bond_is_nondyn_tlb(bond)) {
-		if (bond_tlb_update_slave_arr(bond, NULL))
+		if (bond_update_slave_arr(bond, NULL))
 			pr_err("Failed to build slave-array for TLB mode.\n");
 	}
 }
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 3c6a7ff974d7..1ad473b4ade5 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -139,19 +139,11 @@ struct tlb_slave_info {
 			 */
 };
 
-struct tlb_up_slave {
-	unsigned int	count;
-	struct rcu_head rcu;
-	struct slave	*arr[0];
-};
-
 struct alb_bond_info {
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
 	u32			unbalanced_load;
 	int			tx_rebalance_counter;
 	int			lp_counter;
-	/* -------- non-dynamic tlb mode only ---------*/
-	struct tlb_up_slave __rcu *slave_arr;	  /* Up slaves */
 	/* -------- rlb parameters -------- */
 	int rlb_enabled;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c2adc2755ff6..692dedf2b73b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -210,6 +210,7 @@ static int bond_init(struct net_device *bond_dev);
 static void bond_uninit(struct net_device *bond_dev);
 static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 						struct rtnl_link_stats64 *stats);
+static void bond_slave_arr_handler(struct work_struct *work);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -1551,6 +1552,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		unblock_netpoll_tx();
 	}
 
+	if (bond_mode_uses_xmit_hash(bond))
+		bond_update_slave_arr(bond, NULL);
+
 	netdev_info(bond_dev, "Enslaving %s as %s interface with %s link\n",
 		    slave_dev->name,
 		    bond_is_active_slave(new_slave) ? "an active" : "a backup",
@@ -1668,6 +1672,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		bond_3ad_unbind_slave(slave);
 
+	if (bond_mode_uses_xmit_hash(bond))
+		bond_update_slave_arr(bond, slave);
+
 	netdev_info(bond_dev, "Releasing %s interface %s\n",
 		    bond_is_active_slave(slave) ? "active" : "backup",
 		    slave_dev->name);
@@ -1970,6 +1977,9 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
+			if (BOND_MODE(bond) == BOND_MODE_XOR)
+				bond_update_slave_arr(bond, NULL);
+
 			if (!bond->curr_active_slave || slave == primary)
 				goto do_failover;
 
@@ -1997,6 +2007,9 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
+			if (BOND_MODE(bond) == BOND_MODE_XOR)
+				bond_update_slave_arr(bond, NULL);
+
 			if (slave == rcu_access_pointer(bond->curr_active_slave))
 				goto do_failover;
 
@@ -2453,6 +2466,8 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 		if (slave_state_changed) {
 			bond_slave_state_change(bond);
+			if (BOND_MODE(bond) == BOND_MODE_XOR)
+				bond_update_slave_arr(bond, NULL);
 		} else if (do_failover) {
 			block_netpoll_tx();
 			bond_select_active_slave(bond);
@@ -2829,8 +2844,20 @@ static int bond_slave_netdev_event(unsigned long event,
 			if (old_duplex != slave->duplex)
 				bond_3ad_adapter_duplex_changed(slave);
 		}
+		/* Refresh slave-array if applicable!
+		 * If the setup does not use miimon or arpmon (mode-specific!),
+		 * then these events will not cause the slave-array to be
+		 * refreshed. This will cause xmit to use a slave that is not
+		 * usable. Avoid such situation by refeshing the array at these
+		 * events. If these (miimon/arpmon) parameters are configured
+		 * then array gets refreshed twice and that should be fine!
+		 */
+		if (bond_mode_uses_xmit_hash(bond))
+			bond_update_slave_arr(bond, NULL);
 		break;
 	case NETDEV_DOWN:
+		if (bond_mode_uses_xmit_hash(bond))
+			bond_update_slave_arr(bond, NULL);
 		break;
 	case NETDEV_CHANGEMTU:
 		/* TODO: Should slaves be allowed to
@@ -3010,6 +3037,7 @@ static void bond_work_init_all(struct bonding *bond)
 	else
 		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
 	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
+	INIT_DELAYED_WORK(&bond->slave_arr_work, bond_slave_arr_handler);
 }
 
 static void bond_work_cancel_all(struct bonding *bond)
@@ -3019,6 +3047,7 @@ static void bond_work_cancel_all(struct bonding *bond)
 	cancel_delayed_work_sync(&bond->alb_work);
 	cancel_delayed_work_sync(&bond->ad_work);
 	cancel_delayed_work_sync(&bond->mcast_work);
+	cancel_delayed_work_sync(&bond->slave_arr_work);
 }
 
 static int bond_open(struct net_device *bond_dev)
@@ -3068,6 +3097,9 @@ static int bond_open(struct net_device *bond_dev)
 		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
+	if (bond_mode_uses_xmit_hash(bond))
+		bond_update_slave_arr(bond, NULL);
+
 	return 0;
 }
 
@@ -3573,20 +3605,148 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	return NETDEV_TX_OK;
 }
 
-/* In bond_xmit_xor() , we determine the output device by using a pre-
- * determined xmit_hash_policy(), If the selected device is not enabled,
- * find the next active slave.
+/* Use this to update slave_array when (a) it's not appropriate to update
+ * slave_array right away (note that update_slave_array() may sleep)
+ * and / or (b) RTNL is not held.
  */
-static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
+void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay)
 {
-	struct bonding *bond = netdev_priv(bond_dev);
-	int slave_cnt = ACCESS_ONCE(bond->slave_cnt);
+	queue_delayed_work(bond->wq, &bond->slave_arr_work, delay);
+}
 
-	if (likely(slave_cnt))
-		bond_xmit_slave_id(bond, skb,
-				   bond_xmit_hash(bond, skb) % slave_cnt);
-	else
+/* Slave array work handler. Holds only RTNL */
+static void bond_slave_arr_handler(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    slave_arr_work.work);
+	int ret;
+
+	if (!rtnl_trylock())
+		goto err;
+
+	ret = bond_update_slave_arr(bond, NULL);
+	rtnl_unlock();
+	if (ret) {
+		pr_warn_ratelimited("Failed to update slave array from WT\n");
+		goto err;
+	}
+	return;
+
+err:
+	bond_slave_arr_work_rearm(bond, 1);
+}
+
+/* Build the usable slaves array in control path for modes that use xmit-hash
+ * to determine the slave interface -
+ * (a) BOND_MODE_8023AD
+ * (b) BOND_MODE_XOR
+ * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
+ *
+ * The caller is expected to hold RTNL only and NO other lock!
+ */
+int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
+{
+	struct slave *slave;
+	struct list_head *iter;
+	struct bond_up_slave *new_arr, *old_arr;
+	int slaves_in_agg;
+	int agg_id = 0;
+	int ret = 0;
+
+#ifdef CONFIG_LOCKDEP
+	lockdep_assert_held(&bond->mode_lock);
+#endif
+
+	new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
+			  GFP_KERNEL);
+	if (!new_arr) {
+		ret = -ENOMEM;
+		pr_err("Failed to build slave-array.\n");
+		goto out;
+	}
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+
+		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+			pr_debug("bond_3ad_get_active_agg_info failed\n");
+			kfree_rcu(new_arr, rcu);
+			/* No active aggragator means it's not safe to use
+			 * the previous array.
+			 */
+			old_arr = rtnl_dereference(bond->slave_arr);
+			if (old_arr) {
+				RCU_INIT_POINTER(bond->slave_arr, NULL);
+				kfree_rcu(old_arr, rcu);
+			}
+			goto out;
+		}
+		slaves_in_agg = ad_info.ports;
+		agg_id = ad_info.aggregator_id;
+	}
+	bond_for_each_slave(bond, slave, iter) {
+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+			struct aggregator *agg;
+
+			agg = SLAVE_AD_INFO(slave)->port.aggregator;
+			if (!agg || agg->aggregator_identifier != agg_id)
+				continue;
+		}
+		if (!bond_slave_can_tx(slave))
+			continue;
+		if (skipslave == slave)
+			continue;
+		new_arr->arr[new_arr->count++] = slave;
+	}
+
+	old_arr = rtnl_dereference(bond->slave_arr);
+	rcu_assign_pointer(bond->slave_arr, new_arr);
+	if (old_arr)
+		kfree_rcu(old_arr, rcu);
+out:
+	if (ret != 0 && skipslave) {
+		int idx;
+
+		/* Rare situation where caller has asked to skip a specific
+		 * slave but allocation failed (most likely!). BTW this is
+		 * only possible when the call is initiated from
+		 * __bond_release_one(). In this situation; overwrite the
+		 * skipslave entry in the array with the last entry from the
+		 * array to avoid a situation where the xmit path may choose
+		 * this to-be-skipped slave to send a packet out.
+		 */
+		old_arr = rtnl_dereference(bond->slave_arr);
+		for (idx = 0; idx < old_arr->count; idx++) {
+			if (skipslave == old_arr->arr[idx]) {
+				old_arr->arr[idx] =
+				    old_arr->arr[old_arr->count-1];
+				old_arr->count--;
+				break;
+			}
+		}
+	}
+	return ret;
+}
+
+/* Use this Xmit function for 3AD as well as XOR modes. The current
+ * usable slave array is formed in the control path. The xmit function
+ * just calculates hash and sends the packet out.
+ */
+int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bonding *bond = netdev_priv(dev);
+	struct slave *slave;
+	struct bond_up_slave *slaves;
+	unsigned int count;
+
+	slaves = rcu_dereference(bond->slave_arr);
+	count = slaves ? ACCESS_ONCE(slaves->count) : 0;
+	if (likely(count)) {
+		slave = slaves->arr[bond_xmit_hash(bond, skb) % count];
+		bond_dev_queue_xmit(bond, skb, slave->dev);
+	} else {
 		dev_kfree_skb_any(skb);
+		atomic_long_inc(&dev->tx_dropped);
+	}
 
 	return NETDEV_TX_OK;
 }
@@ -3682,12 +3842,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 		return bond_xmit_roundrobin(skb, dev);
 	case BOND_MODE_ACTIVEBACKUP:
 		return bond_xmit_activebackup(skb, dev);
+	case BOND_MODE_8023AD:
 	case BOND_MODE_XOR:
-		return bond_xmit_xor(skb, dev);
+		return bond_3ad_xor_xmit(skb, dev);
 	case BOND_MODE_BROADCAST:
 		return bond_xmit_broadcast(skb, dev);
-	case BOND_MODE_8023AD:
-		return bond_3ad_xmit_xor(skb, dev);
 	case BOND_MODE_ALB:
 		return bond_alb_xmit(skb, dev);
 	case BOND_MODE_TLB:
@@ -3861,6 +4020,7 @@ static void bond_uninit(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct list_head *iter;
 	struct slave *slave;
+	struct bond_up_slave *arr;
 
 	bond_netpoll_cleanup(bond_dev);
 
@@ -3869,6 +4029,12 @@ static void bond_uninit(struct net_device *bond_dev)
 		__bond_release_one(bond_dev, slave->dev, true);
 	netdev_info(bond_dev, "Released all slaves\n");
 
+	arr = rtnl_dereference(bond->slave_arr);
+	if (arr) {
+		RCU_INIT_POINTER(bond->slave_arr, NULL);
+		kfree_rcu(arr, rcu);
+	}
+
 	list_del(&bond->bond_list);
 
 	bond_debug_unregister(bond);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5b022da9cad2..10920f0686e2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -179,6 +179,12 @@ struct slave {
 	struct rtnl_link_stats64 slave_stats;
 };
 
+struct bond_up_slave {
+	unsigned int	count;
+	struct rcu_head rcu;
+	struct slave	*arr[0];
+};
+
 /*
  * Link pseudo-state only used internally by monitors
  */
@@ -193,6 +199,7 @@ struct bonding {
 	struct   slave __rcu *curr_active_slave;
 	struct   slave __rcu *current_arp_slave;
 	struct   slave __rcu *primary_slave;
+	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
@@ -222,6 +229,7 @@ struct bonding {
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
 	struct   delayed_work mcast_work;
+	struct   delayed_work slave_arr_work;
 #ifdef CONFIG_DEBUG_FS
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
@@ -534,6 +542,8 @@ const char *bond_slave_link_status(s8 link);
 struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
 					      struct net_device *end_dev,
 					      int level);
+int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
+void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
 
 #ifdef CONFIG_PROC_FS
 void bond_create_proc_entry(struct bonding *bond);
-- 
2.1.0.rc2.206.gedb03e5
