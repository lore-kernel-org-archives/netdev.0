From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v6 8/11] bonding: add RCU for bond_3ad_state_machine_handler()
Date: Fri, 13 Dec 2013 10:20:12 +0800
Message-ID: <52AA6EDC.2030103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:29868 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab3LMCYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 21:24:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_3ad_state_machine_handler() use the bond lock to protect
the bond slave list and slave port together, but it is not enough,
the bond slave list was link and unlink in RTNL, not bond lock,
so I add RCU to protect the slave list from leaving.

The bond lock is still used here, because when the slave has been
removed from the list by the time the state machine runs, it appears
to be possible for both function to manupulate the same aggregator->lag_ports
by finding the aggregator via two different ports that are both members of
that aggregator (i.e., port A of the agg is being unbound, and port B
of the agg is runing its state machine).

If I remove the bond lock, there are nothing to mutex changes
to aggregator->lag_ports between bond_3ad_state_machine_handler and
bond_3ad_unbind_slave, So the bond lock is the simplest way to protect
aggregator->lag_ports.

There was a lot of function need RCU protect, I have two choice
to make the function in RCU-safe, (1) create new similar functions
and make the bond slave list in RCU. (2) modify the existed functions
and make them in read-side critical section, because the RCU
read-side critical sections may be nested.

I choose (2) because it is no need to create more similar functions.

The nots in the function is still too old, clean up the nots.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c  | 54 +++++++++++++++++++++++++----------------
 drivers/net/bonding/bond_main.c |  7 ++----
 2 files changed, 35 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..58c2249 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -147,11 +147,12 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 	struct bonding *bond = __get_bond_by_port(port);
 	struct slave *first_slave;
 
-	// If there's no bond for this port, or bond has no slaves
+	/* If there's no bond for this port, or bond has no slaves */
 	if (bond == NULL)
 		return NULL;
-	first_slave = bond_first_slave(bond);
-
+	rcu_read_lock();
+	first_slave = bond_first_slave_rcu(bond);
+	rcu_read_unlock();
 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 }
 
@@ -702,9 +703,13 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 	struct list_head *iter;
 	struct slave *slave;
 
-	bond_for_each_slave(bond, slave, iter)
-		if (SLAVE_AD_INFO(slave).aggregator.is_active)
+	rcu_read_lock();
+	bond_for_each_slave_rcu(bond, slave, iter)
+		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
+			rcu_read_unlock();
 			return &(SLAVE_AD_INFO(slave).aggregator);
+		}
+	rcu_read_unlock();
 
 	return NULL;
 }
@@ -1471,7 +1476,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 	active = __get_active_agg(agg);
 	best = (active && agg_device_up(active)) ? active : NULL;
 
-	bond_for_each_slave(bond, slave, iter) {
+	rcu_read_lock();
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		agg = &(SLAVE_AD_INFO(slave).aggregator);
 
 		agg->is_active = 0;
@@ -1505,7 +1511,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		active->is_active = 1;
 	}
 
-	// if there is new best aggregator, activate it
+	/* if there is new best aggregator, activate it */
 	if (best) {
 		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 			 best->aggregator_identifier, best->num_of_ports,
@@ -1516,7 +1522,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->lag_ports, best->slave,
 			 best->slave ? best->slave->dev->name : "NULL");
 
-		bond_for_each_slave(bond, slave, iter) {
+		bond_for_each_slave_rcu(bond, slave, iter) {
 			agg = &(SLAVE_AD_INFO(slave).aggregator);
 
 			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
@@ -1526,10 +1532,11 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 				 agg->is_individual, agg->is_active);
 		}
 
-		// check if any partner replys
+		/* check if any partner replys */
 		if (best->is_individual) {
 			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
-				   best->slave ? best->slave->bond->dev->name : "NULL");
+				best->slave ?
+				best->slave->bond->dev->name : "NULL");
 		}
 
 		best->is_active = 1;
@@ -1541,7 +1548,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->partner_oper_aggregator_key,
 			 best->is_individual, best->is_active);
 
-		// disable the ports that were related to the former active_aggregator
+		/* disable the ports that were related to the former active_aggregator */
 		if (active) {
 			for (port = active->lag_ports; port;
 			     port = port->next_port_in_aggregator) {
@@ -1565,6 +1572,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 	}
 
+	rcu_read_unlock();
+
 	bond_3ad_set_carrier(bond);
 }
 
@@ -2069,17 +2078,18 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct port *port;
 
 	read_lock(&bond->lock);
+	rcu_read_lock();
 
-	//check if there are any slaves
+	/* check if there are any slaves */
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	// check if agg_select_timer timer after initialize is timed out
+	/* check if agg_select_timer timer after initialize is timed out */
 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
-		slave = bond_first_slave(bond);
+		slave = bond_first_slave_rcu(bond);
 		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
 
-		// select the active aggregator for the bond
+		/* select the active aggregator for the bond */
 		if (port) {
 			if (!port->slave) {
 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
@@ -2093,8 +2103,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		bond_3ad_set_carrier(bond);
 	}
 
-	// for each port run the state machines
-	bond_for_each_slave(bond, slave, iter) {
+	/* for each port run the state machines */
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (!port->slave) {
 			pr_warning("%s: Warning: Found an uninitialized port\n",
@@ -2114,7 +2124,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		ad_mux_machine(port);
 		ad_tx_machine(port);
 
-		// turn off the BEGIN bit, since we already handled it
+		/* turn off the BEGIN bit, since we already handled it */
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
 
@@ -2122,9 +2132,9 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
-	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-
+	rcu_read_unlock();
 	read_unlock(&bond->lock);
+	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 }
 
 /**
@@ -2303,7 +2313,9 @@ int bond_3ad_set_carrier(struct bonding *bond)
 	struct aggregator *active;
 	struct slave *first_slave;
 
-	first_slave = bond_first_slave(bond);
+	rcu_read_lock();
+	first_slave = bond_first_slave_rcu(bond);
+	rcu_read_unlock();
 	if (!first_slave)
 		return 0;
 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1b1dd01..720a826 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1703,12 +1703,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 	write_lock_bh(&bond->lock);
 
 	/* Inform AD package of unbinding of slave. */
-	if (bond->params.mode == BOND_MODE_8023AD) {
-		/* must be called before the slave is
-		 * detached from the list
-		 */
+	if (bond->params.mode == BOND_MODE_8023AD)
 		bond_3ad_unbind_slave(slave);
-	}
+
 	write_unlock_bh(&bond->lock);
 
 	pr_info("%s: releasing %s interface %s\n",
-- 
1.8.0
