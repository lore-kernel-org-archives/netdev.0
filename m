From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 03/12] bonding: convert bond_3ad.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:00 +0200
Message-ID: <1405445769-15394-4-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756636AbaGORkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:41 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several functions left out cause we might not have at that time a valid
bond/slave/port.

Also, converted severa pr_ratelimited into net_ratelimited.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_3ad.c | 183 ++++++++++++++++++++---------------------
 1 file changed, 88 insertions(+), 95 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 0dfeaf5..159c451 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -301,8 +301,8 @@ static u16 __get_link_speed(struct port *port)
 		}
 	}
 
-	pr_debug("Port %d Received link speed %d update from adapter\n",
-		 port->actor_port_number, speed);
+	netdev_dbg(slave->bond->dev, "Port %d Received link speed %d update from adapter\n",
+		   port->actor_port_number, speed);
 	return speed;
 }
 
@@ -329,14 +329,14 @@ static u8 __get_duplex(struct port *port)
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval = 0x1;
-			pr_debug("Port %d Received status full duplex update from adapter\n",
-				 port->actor_port_number);
+			netdev_dbg(slave->bond->dev, "Port %d Received status full duplex update from adapter\n",
+				   port->actor_port_number);
 			break;
 		case DUPLEX_HALF:
 		default:
 			retval = 0x0;
-			pr_debug("Port %d Received status NOT full duplex update from adapter\n",
-				 port->actor_port_number);
+			netdev_dbg(slave->bond->dev, "Port %d Received status NOT full duplex update from adapter\n",
+				   port->actor_port_number);
 			break;
 		}
 	}
@@ -1079,9 +1079,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			/* detect loopback situation */
 			if (MAC_ADDRESS_EQUAL(&(lacpdu->actor_system),
 					      &(port->actor_system))) {
-				pr_err("%s: An illegal loopback occurred on adapter (%s)\n"
+				netdev_err(port->slave->bond->dev, "An illegal loopback occurred on adapter (%s)\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
-				       port->slave->bond->dev->name,
 				       port->slave->dev->name);
 				return;
 			}
@@ -1269,9 +1268,9 @@ static void ad_port_selection_logic(struct port *port)
 				port->next_port_in_aggregator = NULL;
 				port->actor_port_aggregator_identifier = 0;
 
-				pr_debug("Port %d left LAG %d\n",
-					 port->actor_port_number,
-					 temp_aggregator->aggregator_identifier);
+				netdev_dbg(bond->dev, "Port %d left LAG %d\n",
+					   port->actor_port_number,
+					   temp_aggregator->aggregator_identifier);
 				/* if the aggregator is empty, clear its
 				 * parameters, and set it ready to be attached
 				 */
@@ -1284,11 +1283,11 @@ static void ad_port_selection_logic(struct port *port)
 			/* meaning: the port was related to an aggregator
 			 * but was not on the aggregator port list
 			 */
-			pr_warn_ratelimited("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
-					    port->slave->bond->dev->name,
-					    port->actor_port_number,
-					    port->slave->dev->name,
-					    port->aggregator->aggregator_identifier);
+			net_warn_ratelimited("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
+					     port->slave->bond->dev->name,
+					     port->actor_port_number,
+					     port->slave->dev->name,
+					     port->aggregator->aggregator_identifier);
 		}
 	}
 	/* search on all aggregators for a suitable aggregator for this port */
@@ -1318,9 +1317,9 @@ static void ad_port_selection_logic(struct port *port)
 			port->next_port_in_aggregator = aggregator->lag_ports;
 			port->aggregator->num_of_ports++;
 			aggregator->lag_ports = port;
-			pr_debug("Port %d joined LAG %d(existing LAG)\n",
-				 port->actor_port_number,
-				 port->aggregator->aggregator_identifier);
+			netdev_dbg(bond->dev, "Port %d joined LAG %d(existing LAG)\n",
+				   port->actor_port_number,
+				   port->aggregator->aggregator_identifier);
 
 			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
@@ -1363,12 +1362,11 @@ static void ad_port_selection_logic(struct port *port)
 			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
 
-			pr_debug("Port %d joined LAG %d(new LAG)\n",
-				 port->actor_port_number,
-				 port->aggregator->aggregator_identifier);
+			netdev_dbg(bond->dev, "Port %d joined LAG %d(new LAG)\n",
+				   port->actor_port_number,
+				   port->aggregator->aggregator_identifier);
 		} else {
-			pr_err("%s: Port %d (on %s) did not find a suitable aggregator\n",
-			       port->slave->bond->dev->name,
+			netdev_err(bond->dev, "Port %d (on %s) did not find a suitable aggregator\n",
 			       port->actor_port_number, port->slave->dev->name);
 		}
 	}
@@ -1445,9 +1443,9 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 		break;
 
 	default:
-		pr_warn_ratelimited("%s: Impossible agg select mode %d\n",
-				    curr->slave->bond->dev->name,
-				    __get_agg_selection_mode(curr->lag_ports));
+		net_warn_ratelimited("%s: Impossible agg select mode %d\n",
+				     curr->slave->bond->dev->name,
+				     __get_agg_selection_mode(curr->lag_ports));
 		break;
 	}
 
@@ -1539,40 +1537,40 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 
 	/* if there is new best aggregator, activate it */
 	if (best) {
-		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-			 best->aggregator_identifier, best->num_of_ports,
-			 best->actor_oper_aggregator_key,
-			 best->partner_oper_aggregator_key,
-			 best->is_individual, best->is_active);
-		pr_debug("best ports %p slave %p %s\n",
-			 best->lag_ports, best->slave,
-			 best->slave ? best->slave->dev->name : "NULL");
+		netdev_dbg(bond->dev, "best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+			   best->aggregator_identifier, best->num_of_ports,
+			   best->actor_oper_aggregator_key,
+			   best->partner_oper_aggregator_key,
+			   best->is_individual, best->is_active);
+		netdev_dbg(bond->dev, "best ports %p slave %p %s\n",
+			   best->lag_ports, best->slave,
+			   best->slave ? best->slave->dev->name : "NULL");
 
 		bond_for_each_slave_rcu(bond, slave, iter) {
 			agg = &(SLAVE_AD_INFO(slave)->aggregator);
 
-			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-				 agg->aggregator_identifier, agg->num_of_ports,
-				 agg->actor_oper_aggregator_key,
-				 agg->partner_oper_aggregator_key,
-				 agg->is_individual, agg->is_active);
+			netdev_dbg(bond->dev, "Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+				   agg->aggregator_identifier, agg->num_of_ports,
+				   agg->actor_oper_aggregator_key,
+				   agg->partner_oper_aggregator_key,
+				   agg->is_individual, agg->is_active);
 		}
 
 		/* check if any partner replys */
 		if (best->is_individual) {
-			pr_warn_ratelimited("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
-					    best->slave ?
-					    best->slave->bond->dev->name : "NULL");
+			net_warn_ratelimited("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
+					     best->slave ?
+					     best->slave->bond->dev->name : "NULL");
 		}
 
 		best->is_active = 1;
-		pr_debug("LAG %d chosen as the active LAG\n",
-			 best->aggregator_identifier);
-		pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-			 best->aggregator_identifier, best->num_of_ports,
-			 best->actor_oper_aggregator_key,
-			 best->partner_oper_aggregator_key,
-			 best->is_individual, best->is_active);
+		netdev_dbg(bond->dev, "LAG %d chosen as the active LAG\n",
+			   best->aggregator_identifier);
+		netdev_dbg(bond->dev, "Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+			   best->aggregator_identifier, best->num_of_ports,
+			   best->actor_oper_aggregator_key,
+			   best->partner_oper_aggregator_key,
+			   best->is_individual, best->is_active);
 
 		/* disable the ports that were related to the former
 		 * active_aggregator
@@ -1908,13 +1906,13 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warn("Warning: %s: Trying to unbind an uninitialized port on %s\n",
-			slave->bond->dev->name, slave->dev->name);
+		netdev_warn(bond->dev, "Trying to unbind an uninitialized port on %s\n",
+			    slave->dev->name);
 		return;
 	}
 
-	pr_debug("Unbinding Link Aggregation Group %d\n",
-		 aggregator->aggregator_identifier);
+	netdev_dbg(bond->dev, "Unbinding Link Aggregation Group %d\n",
+		   aggregator->aggregator_identifier);
 
 	/* Tell the partner that this port is not suitable for aggregation */
 	port->actor_oper_port_state &= ~AD_STATE_AGGREGATION;
@@ -1949,14 +1947,13 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			 * new aggregator
 			 */
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
-				pr_debug("Some port(s) related to LAG %d - replacing with LAG %d\n",
-					 aggregator->aggregator_identifier,
-					 new_aggregator->aggregator_identifier);
+				netdev_dbg(bond->dev, "Some port(s) related to LAG %d - replacing with LAG %d\n",
+					   aggregator->aggregator_identifier,
+					   new_aggregator->aggregator_identifier);
 
 				if ((new_aggregator->lag_ports == port) &&
 				    new_aggregator->is_active) {
-					pr_info("%s: Removing an active aggregator\n",
-						aggregator->slave->bond->dev->name);
+					netdev_info(bond->dev, "Removing an active aggregator\n");
 					 select_new_active_agg = 1;
 				}
 
@@ -1986,8 +1983,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				if (select_new_active_agg)
 					ad_agg_selection_logic(__get_first_agg(port));
 			} else {
-				pr_warn("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
-					slave->bond->dev->name);
+				netdev_warn(bond->dev, "unbinding aggregator, and could not find a new aggregator for its ports\n");
 			}
 		} else {
 			/* in case that the only port related to this
@@ -1996,8 +1992,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			select_new_active_agg = aggregator->is_active;
 			ad_clear_agg(aggregator);
 			if (select_new_active_agg) {
-				pr_info("%s: Removing an active aggregator\n",
-					slave->bond->dev->name);
+				netdev_info(bond->dev, "Removing an active aggregator\n");
 				/* select new active aggregator */
 				temp_aggregator = __get_first_agg(port);
 				if (temp_aggregator)
@@ -2006,7 +2001,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 		}
 	}
 
-	pr_debug("Unbinding port %d\n", port->actor_port_number);
+	netdev_dbg(bond->dev, "Unbinding port %d\n", port->actor_port_number);
 
 	/* find the aggregator that this port is connected to */
 	bond_for_each_slave(bond, slave_iter, iter) {
@@ -2029,8 +2024,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					select_new_active_agg = temp_aggregator->is_active;
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
-						pr_info("%s: Removing an active aggregator\n",
-							slave->bond->dev->name);
+						netdev_info(bond->dev, "Removing an active aggregator\n");
 						/* select new active aggregator */
 						ad_agg_selection_logic(__get_first_agg(port));
 					}
@@ -2081,8 +2075,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		/* select the active aggregator for the bond */
 		if (port) {
 			if (!port->slave) {
-				pr_warn_ratelimited("%s: Warning: bond's first port is uninitialized\n",
-						    bond->dev->name);
+				net_warn_ratelimited("%s: Warning: bond's first port is uninitialized\n",
+						     bond->dev->name);
 				goto re_arm;
 			}
 
@@ -2096,7 +2090,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave)->port);
 		if (!port->slave) {
-			pr_warn_ratelimited("%s: Warning: Found an uninitialized port\n",
+			net_warn_ratelimited("%s: Warning: Found an uninitialized port\n",
 					    bond->dev->name);
 			goto re_arm;
 		}
@@ -2158,16 +2152,16 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 		port = &(SLAVE_AD_INFO(slave)->port);
 
 		if (!port->slave) {
-			pr_warn_ratelimited("%s: Warning: port of slave %s is uninitialized\n",
-					    slave->dev->name, slave->bond->dev->name);
+			net_warn_ratelimited("%s: Warning: port of slave %s is uninitialized\n",
+					     slave->dev->name, slave->bond->dev->name);
 			return ret;
 		}
 
 		switch (lacpdu->subtype) {
 		case AD_TYPE_LACPDU:
 			ret = RX_HANDLER_CONSUMED;
-			pr_debug("Received LACPDU on port %d\n",
-				 port->actor_port_number);
+			netdev_dbg(slave->bond->dev, "Received LACPDU on port %d\n",
+				   port->actor_port_number);
 			/* Protect against concurrent state machines */
 			__get_state_machine_lock(port);
 			ad_rx_machine(lacpdu, port);
@@ -2182,20 +2176,20 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 
 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
 			case AD_MARKER_INFORMATION_SUBTYPE:
-				pr_debug("Received Marker Information on port %d\n",
-					 port->actor_port_number);
+				netdev_dbg(slave->bond->dev, "Received Marker Information on port %d\n",
+					   port->actor_port_number);
 				ad_marker_info_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			case AD_MARKER_RESPONSE_SUBTYPE:
-				pr_debug("Received Marker Response on port %d\n",
-					 port->actor_port_number);
+				netdev_dbg(slave->bond->dev, "Received Marker Response on port %d\n",
+					   port->actor_port_number);
 				ad_marker_response_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			default:
-				pr_debug("Received an unknown Marker subtype on slot %d\n",
-					 port->actor_port_number);
+				netdev_dbg(slave->bond->dev, "Received an unknown Marker subtype on slot %d\n",
+					   port->actor_port_number);
 			}
 		}
 	}
@@ -2216,8 +2210,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warn("Warning: %s: speed changed for uninitialized port on %s\n",
-			slave->bond->dev->name, slave->dev->name);
+		netdev_warn(slave->bond->dev, "speed changed for uninitialized port on %s\n",
+			    slave->dev->name);
 		return;
 	}
 
@@ -2226,7 +2220,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		(__get_link_speed(port) << 1);
-	pr_debug("Port %d changed speed\n", port->actor_port_number);
+	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
 	 */
@@ -2249,8 +2243,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warn("%s: Warning: duplex changed for uninitialized port on %s\n",
-			slave->bond->dev->name, slave->dev->name);
+		netdev_warn(slave->bond->dev, "duplex changed for uninitialized port on %s\n",
+			    slave->dev->name);
 		return;
 	}
 
@@ -2259,7 +2253,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		__get_duplex(port);
-	pr_debug("Port %d changed duplex\n", port->actor_port_number);
+	netdev_dbg(slave->bond->dev, "Port %d changed duplex\n", port->actor_port_number);
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
 	 */
@@ -2283,8 +2277,8 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warn("Warning: %s: link status changed for uninitialized port on %s\n",
-			slave->bond->dev->name, slave->dev->name);
+		netdev_warn(slave->bond->dev, "link status changed for uninitialized port on %s\n",
+			    slave->dev->name);
 		return;
 	}
 
@@ -2311,9 +2305,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
 					     ~AD_SPEED_KEY_BITS);
 	}
-	pr_debug("Port %d changed link status to %s\n",
-		 port->actor_port_number,
-		 link == BOND_LINK_UP ? "UP" : "DOWN");
+	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
+		   port->actor_port_number,
+		   link == BOND_LINK_UP ? "UP" : "DOWN");
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
 	 */
@@ -2427,8 +2421,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	int agg_id;
 
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
-			 dev->name);
+		netdev_dbg(dev, "__bond_3ad_get_active_agg_info failed\n");
 		goto err_free;
 	}
 
@@ -2436,7 +2429,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	agg_id = ad_info.aggregator_id;
 
 	if (slaves_in_agg == 0) {
-		pr_debug("%s: Error: active aggregator is empty\n", dev->name);
+		netdev_dbg(dev, "active aggregator is empty\n");
 		goto err_free;
 	}
 
@@ -2462,8 +2455,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (slave_agg_no >= 0) {
-		pr_err("%s: Error: Couldn't find a slave to tx on for aggregator ID %d\n",
-		       dev->name, agg_id);
+		netdev_err(dev, "Couldn't find a slave to tx on for aggregator ID %d\n",
+			   agg_id);
 		goto err_free;
 	}
 
-- 
1.8.4
