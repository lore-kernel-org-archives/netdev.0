From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/3] bonding: alternate agg selection policies for 802.3ad
Date: Tue,  4 Nov 2008 17:51:16 -0800
Message-ID: <1225849876-8930-4-git-send-email-fubar@us.ibm.com>
References: <1225849876-8930-1-git-send-email-fubar@us.ibm.com>
 <1225849876-8930-2-git-send-email-fubar@us.ibm.com>
 <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42252 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbYKEBvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 20:51:23 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mA51pM2T029827
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:22 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA51pMeU090716
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:22 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA51pMHQ019928
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:22 -0500
In-Reply-To: <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patch implements alternative aggregator selection policies
for 802.3ad.  The existing policy, now termed "stable," selects the active
aggregator by greatest bandwidth, and only reselects a new aggregator
if the active aggregator is entirely disabled (no more ports or all ports
down).

	This patch adds two new policies: bandwidth and count, selecting
the active aggregator by total bandwidth (like the stable policy) or by
the number of ports in the aggregator, respectively.  These two policies
also differ from the stable policy in that they will reselect the active
aggregator when availability-related changes occur in the bond (e.g.,
link state change).

	This permits "gang failover" within 802.3ad, allowing redundant
aggregators along parallel paths to always maintain the "best" aggregator
as the active aggregator (rather than having to wait for the active to
entirely fail).

	This patch also updates the driver version to 3.5.0.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   42 +++++
 drivers/net/bonding/bond_3ad.c       |  326 +++++++++++++++++++++-------------
 drivers/net/bonding/bond_3ad.h       |   10 +-
 drivers/net/bonding/bond_main.c      |   30 +++
 drivers/net/bonding/bond_sysfs.c     |   49 +++++
 drivers/net/bonding/bonding.h        |    5 +-
 6 files changed, 333 insertions(+), 129 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 3f4d0fa..5ede747 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -194,6 +194,48 @@ or, for backwards compatibility, the option value.  E.g.,
 
 	The parameters are as follows:
 
+ad_select
+
+	Specifies the 802.3ad aggregation selection logic to use.  The
+	possible values and their effects are:
+
+	stable or 0
+
+		The active aggregator is chosen by largest aggregate
+		bandwidth.
+
+		Reselection of the active aggregator occurs only when all
+		slaves of the active aggregator are down or the active
+		aggregator has no slaves.
+
+		This is the default value.
+
+	bandwidth or 1
+
+		The active aggregator is chosen by largest aggregate
+		bandwidth.  Reselection occurs if:
+
+		- A slave is added to or removed from the bond
+
+		- Any slave's link state changes
+
+		- Any slave's 802.3ad association state changes
+
+		- The bond's adminstrative state changes to up
+
+	count or 2
+
+		The active aggregator is chosen by the largest number of
+		ports (slaves).  Reselection occurs as described under the
+		"bandwidth" setting, above.
+
+	The bandwidth and count selection policies permit failover of
+	802.3ad aggregations when partial failure of the active aggregator
+	occurs.  This keeps the aggregator with the highest availability
+	(either in bandwidth or in number of ports) active at all times.
+
+	This option was added in bonding version 3.4.0.
+
 arp_interval
 
 	Specifies the ARP link monitoring frequency in milliseconds.
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6106660..ba1372f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -27,6 +27,7 @@
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bonding.h>
 #include <linux/pkt_sched.h>
 #include <net/net_namespace.h>
@@ -236,6 +237,17 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
 	return &(SLAVE_AD_INFO(slave->next).aggregator);
 }
 
+/*
+ * __agg_has_partner
+ *
+ * Return nonzero if aggregator has a partner (denoted by a non-zero ether
+ * address for the partner).  Return 0 if not.
+ */
+static inline int __agg_has_partner(struct aggregator *agg)
+{
+	return !is_zero_ether_addr(agg->partner_system.mac_addr_value);
+}
+
 /**
  * __disable_port - disable the port's slave
  * @port: the port we're looking at
@@ -274,14 +286,14 @@ static inline int __port_is_enabled(struct port *port)
  * __get_agg_selection_mode - get the aggregator selection mode
  * @port: the port we're looking at
  *
- * Get the aggregator selection mode. Can be %BANDWIDTH or %COUNT.
+ * Get the aggregator selection mode. Can be %STABLE, %BANDWIDTH or %COUNT.
  */
 static inline u32 __get_agg_selection_mode(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 
 	if (bond == NULL) {
-		return AD_BANDWIDTH;
+		return BOND_AD_STABLE;
 	}
 
 	return BOND_AD_INFO(bond).agg_select_mode;
@@ -1414,9 +1426,82 @@ static void ad_port_selection_logic(struct port *port)
 	// else set ready=FALSE in all aggregator's ports
 	__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 
-	if (!__check_agg_selection_timer(port) && (aggregator = __get_first_agg(port))) {
-		ad_agg_selection_logic(aggregator);
+	aggregator = __get_first_agg(port);
+	ad_agg_selection_logic(aggregator);
+}
+
+/*
+ * Decide if "agg" is a better choice for the new active aggregator that
+ * the current best, according to the ad_select policy.
+ */
+static struct aggregator *ad_agg_selection_test(struct aggregator *best,
+						struct aggregator *curr)
+{
+	/*
+	 * 0. If no best, select current.
+	 *
+	 * 1. If the current agg is not individual, and the best is
+	 *    individual, select current.
+	 *
+	 * 2. If current agg is individual and the best is not, keep best.
+	 *
+	 * 3. Therefore, current and best are both individual or both not
+	 *    individual, so:
+	 *
+	 * 3a. If current agg partner replied, and best agg partner did not,
+	 *     select current.
+	 *
+	 * 3b. If current agg partner did not reply and best agg partner
+	 *     did reply, keep best.
+	 *
+	 * 4.  Therefore, current and best both have partner replies or
+	 *     both do not, so perform selection policy:
+	 *
+	 * BOND_AD_COUNT: Select by count of ports.  If count is equal,
+	 *     select by bandwidth.
+	 *
+	 * BOND_AD_STABLE, BOND_AD_BANDWIDTH: Select by bandwidth.
+	 */
+	if (!best)
+		return curr;
+
+	if (!curr->is_individual && best->is_individual)
+		return curr;
+
+	if (curr->is_individual && !best->is_individual)
+		return best;
+
+	if (__agg_has_partner(curr) && !__agg_has_partner(best))
+		return curr;
+
+	if (!__agg_has_partner(curr) && __agg_has_partner(best))
+		return best;
+
+	switch (__get_agg_selection_mode(curr->lag_ports)) {
+	case BOND_AD_COUNT:
+		if (curr->num_of_ports > best->num_of_ports)
+			return curr;
+
+		if (curr->num_of_ports < best->num_of_ports)
+			return best;
+
+		/*FALLTHROUGH*/
+	case BOND_AD_STABLE:
+	case BOND_AD_BANDWIDTH:
+		if (__get_agg_bandwidth(curr) > __get_agg_bandwidth(best))
+			return curr;
+
+		break;
+
+	default:
+		printk(KERN_WARNING DRV_NAME
+		       ": %s: Impossible agg select mode %d\n",
+		       curr->slave->dev->master->name,
+		       __get_agg_selection_mode(curr->lag_ports));
+		break;
 	}
+
+	return best;
 }
 
 /**
@@ -1424,156 +1509,138 @@ static void ad_port_selection_logic(struct port *port)
  * @aggregator: the aggregator we're looking at
  *
  * It is assumed that only one aggregator may be selected for a team.
- * The logic of this function is to select (at first time) the aggregator with
- * the most ports attached to it, and to reselect the active aggregator only if
- * the previous aggregator has no more ports related to it.
+ *
+ * The logic of this function is to select the aggregator according to
+ * the ad_select policy:
+ *
+ * BOND_AD_STABLE: select the aggregator with the most ports attached to
+ * it, and to reselect the active aggregator only if the previous
+ * aggregator has no more ports related to it.
+ *
+ * BOND_AD_BANDWIDTH: select the aggregator with the highest total
+ * bandwidth, and reselect whenever a link state change takes place or the
+ * set of slaves in the bond changes.
+ *
+ * BOND_AD_COUNT: select the aggregator with largest number of ports
+ * (slaves), and reselect whenever a link state change takes place or the
+ * set of slaves in the bond changes.
  *
  * FIXME: this function MUST be called with the first agg in the bond, or
  * __get_active_agg() won't work correctly. This function should be better
  * called with the bond itself, and retrieve the first agg from it.
  */
-static void ad_agg_selection_logic(struct aggregator *aggregator)
+static void ad_agg_selection_logic(struct aggregator *agg)
 {
-	struct aggregator *best_aggregator = NULL, *active_aggregator = NULL;
-	struct aggregator *last_active_aggregator = NULL, *origin_aggregator;
+	struct aggregator *best, *active, *origin;
 	struct port *port;
-	u16 num_of_aggs=0;
 
-	origin_aggregator = aggregator;
+	origin = agg;
 
-	//get current active aggregator
-	last_active_aggregator = __get_active_agg(aggregator);
+	active = __get_active_agg(agg);
+	best = active;
 
-	// search for the aggregator with the most ports attached to it.
 	do {
-		// count how many candidate lag's we have
-		if (aggregator->lag_ports) {
-			num_of_aggs++;
-		}
-		if (aggregator->is_active && !aggregator->is_individual &&   // if current aggregator is the active aggregator
-		    MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr))) {   // and partner answers to 802.3ad PDUs
-			if (aggregator->num_of_ports) {	// if any ports attached to the current aggregator
-				best_aggregator=NULL;	 // disregard the best aggregator that was chosen by now
-				break;		 // stop the selection of other aggregator if there are any ports attached to this active aggregator
-			} else { // no ports attached to this active aggregator
-				aggregator->is_active = 0; // mark this aggregator as not active anymore
+		agg->is_active = 0;
+
+		if (agg->num_of_ports)
+			best = ad_agg_selection_test(best, agg);
+
+	} while ((agg = __get_next_agg(agg)));
+
+	if (best &&
+	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
+		/*
+		 * For the STABLE policy, don't replace the old active
+		 * aggregator if it's still active (it has an answering
+		 * partner) or if both the best and active don't have an
+		 * answering partner.
+		 */
+		if (active && active->lag_ports &&
+		    active->lag_ports->is_enabled &&
+		    (__agg_has_partner(active) ||
+		     (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
+			if (!(!active->actor_oper_aggregator_key &&
+			      best->actor_oper_aggregator_key)) {
+				best = NULL;
+				active->is_active = 1;
 			}
 		}
-		if (aggregator->num_of_ports) {	// if any ports attached
-			if (best_aggregator) {	// if there is a candidte aggregator
-				//The reasons for choosing new best aggregator:
-				// 1. if current agg is NOT individual and the best agg chosen so far is individual OR
-				// current and best aggs are both individual or both not individual, AND
-				// 2a.  current agg partner reply but best agg partner do not reply OR
-				// 2b.  current agg partner reply OR current agg partner do not reply AND best agg partner also do not reply AND
-				//      current has more ports/bandwidth, or same amount of ports but current has faster ports, THEN
-				//      current agg become best agg so far
-
-				//if current agg is NOT individual and the best agg chosen so far is individual change best_aggregator
-				if (!aggregator->is_individual && best_aggregator->is_individual) {
-					best_aggregator=aggregator;
-				}
-				// current and best aggs are both individual or both not individual
-				else if ((aggregator->is_individual && best_aggregator->is_individual) ||
-					 (!aggregator->is_individual && !best_aggregator->is_individual)) {
-					//  current and best aggs are both individual or both not individual AND
-					//  current agg partner reply but best agg partner do not reply
-					if ((MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr)) &&
-					     !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr)))) {
-						best_aggregator=aggregator;
-					}
-					//  current agg partner reply OR current agg partner do not reply AND best agg partner also do not reply
-					else if (! (!MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr)) &&
-						    MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr)))) {
-						if ((__get_agg_selection_mode(aggregator->lag_ports) == AD_BANDWIDTH)&&
-						    (__get_agg_bandwidth(aggregator) > __get_agg_bandwidth(best_aggregator))) {
-							best_aggregator=aggregator;
-						} else if (__get_agg_selection_mode(aggregator->lag_ports) == AD_COUNT) {
-							if (((aggregator->num_of_ports > best_aggregator->num_of_ports) &&
-							     (aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS))||
-							    ((aggregator->num_of_ports == best_aggregator->num_of_ports) &&
-							     ((u16)(aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS) >
-							      (u16)(best_aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS)))) {
-								best_aggregator=aggregator;
-							}
-						}
-					}
-				}
-			} else {
-				best_aggregator=aggregator;
-			}
-		}
-		aggregator->is_active = 0; // mark all aggregators as not active anymore
-	} while ((aggregator = __get_next_agg(aggregator)));
-
-	// if we have new aggregator selected, don't replace the old aggregator if it has an answering partner,
-	// or if both old aggregator and new aggregator don't have answering partner
-	if (best_aggregator) {
-		if (last_active_aggregator && last_active_aggregator->lag_ports && last_active_aggregator->lag_ports->is_enabled &&
-		    (MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), &(null_mac_addr)) ||   // partner answers OR
-		     (!MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), &(null_mac_addr)) &&	// both old and new
-		      !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr))))     // partner do not answer
-		   ) {
-			// if new aggregator has link, and old aggregator does not, replace old aggregator.(do nothing)
-			// -> don't replace otherwise.
-			if (!(!last_active_aggregator->actor_oper_aggregator_key && best_aggregator->actor_oper_aggregator_key)) {
-				best_aggregator=NULL;
-				last_active_aggregator->is_active = 1; // don't replace good old aggregator
+	}
 
-			}
-		}
+	if (best && (best == active)) {
+		best = NULL;
+		active->is_active = 1;
 	}
 
 	// if there is new best aggregator, activate it
-	if (best_aggregator) {
-		for (aggregator = __get_first_agg(best_aggregator->lag_ports);
-		    aggregator;
-		    aggregator = __get_next_agg(aggregator)) {
-
-			dprintk("Agg=%d; Ports=%d; a key=%d; p key=%d; Indiv=%d; Active=%d\n",
-					aggregator->aggregator_identifier, aggregator->num_of_ports,
-					aggregator->actor_oper_aggregator_key, aggregator->partner_oper_aggregator_key,
-					aggregator->is_individual, aggregator->is_active);
+	if (best) {
+		dprintk("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+		       best->aggregator_identifier, best->num_of_ports,
+		       best->actor_oper_aggregator_key,
+		       best->partner_oper_aggregator_key,
+		       best->is_individual, best->is_active);
+		dprintk("best ports %p slave %p %s\n",
+		       best->lag_ports, best->slave,
+		       best->slave ? best->slave->dev->name : "NULL");
+
+		for (agg = __get_first_agg(best->lag_ports); agg;
+		     agg = __get_next_agg(agg)) {
+
+			dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+				agg->aggregator_identifier, agg->num_of_ports,
+				agg->actor_oper_aggregator_key,
+				agg->partner_oper_aggregator_key,
+				agg->is_individual, agg->is_active);
 		}
 
 		// check if any partner replys
-		if (best_aggregator->is_individual) {
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad response from "
-			       "the link partner for any adapters in the bond\n",
-			       best_aggregator->slave->dev->master->name);
-		}
-
-		// check if there are more than one aggregator
-		if (num_of_aggs > 1) {
-			dprintk("Warning: More than one Link Aggregation Group was "
-				"found in the bond. Only one group will function in the bond\n");
+		if (best->is_individual) {
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad"
+			       " response from the link partner for any"
+			       " adapters in the bond\n",
+			       best->slave->dev->master->name);
 		}
 
-		best_aggregator->is_active = 1;
-		dprintk("LAG %d choosed as the active LAG\n", best_aggregator->aggregator_identifier);
-		dprintk("Agg=%d; Ports=%d; a key=%d; p key=%d; Indiv=%d; Active=%d\n",
-				best_aggregator->aggregator_identifier, best_aggregator->num_of_ports,
-				best_aggregator->actor_oper_aggregator_key, best_aggregator->partner_oper_aggregator_key,
-				best_aggregator->is_individual, best_aggregator->is_active);
+		best->is_active = 1;
+		dprintk("LAG %d chosen as the active LAG\n",
+			best->aggregator_identifier);
+		dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+			best->aggregator_identifier, best->num_of_ports,
+			best->actor_oper_aggregator_key,
+			best->partner_oper_aggregator_key,
+			best->is_individual, best->is_active);
 
 		// disable the ports that were related to the former active_aggregator
-		if (last_active_aggregator) {
-			for (port=last_active_aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+		if (active) {
+			for (port = active->lag_ports; port;
+			     port = port->next_port_in_aggregator) {
 				__disable_port(port);
 			}
 		}
 	}
 
-	// if the selected aggregator is of join individuals(partner_system is NULL), enable their ports
-	active_aggregator = __get_active_agg(origin_aggregator);
+	/*
+	 * if the selected aggregator is of join individuals
+	 * (partner_system is NULL), enable their ports
+	 */
+	active = __get_active_agg(origin);
 
-	if (active_aggregator) {
-		if (!MAC_ADDRESS_COMPARE(&(active_aggregator->partner_system), &(null_mac_addr))) {
-			for (port=active_aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+	if (active) {
+		if (!__agg_has_partner(active)) {
+			for (port = active->lag_ports; port;
+			     port = port->next_port_in_aggregator) {
 				__enable_port(port);
 			}
 		}
 	}
+
+	if (origin->slave) {
+		struct bonding *bond;
+
+		bond = bond_get_bond_by_slave(origin->slave);
+		if (bond)
+			bond_3ad_set_carrier(bond);
+	}
 }
 
 /**
@@ -1830,6 +1897,19 @@ static void ad_initialize_lacpdu(struct lacpdu *lacpdu)
 // Check aggregators status in team every T seconds
 #define AD_AGGREGATOR_SELECTION_TIMER  8
 
+/*
+ * bond_3ad_initiate_agg_selection(struct bonding *bond)
+ *
+ * Set the aggregation selection timer, to initiate an agg selection in
+ * the very near future.  Called during first initialization, and during
+ * any down to up transitions of the bond.
+ */
+void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout)
+{
+	BOND_AD_INFO(bond).agg_select_timer = timeout;
+	BOND_AD_INFO(bond).agg_select_mode = bond->params.ad_select;
+}
+
 static u16 aggregator_identifier;
 
 /**
@@ -1854,9 +1934,9 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 		// initialize how many times this module is called in one second(should be about every 100ms)
 		ad_ticks_per_sec = tick_resolution;
 
-		// initialize the aggregator selection timer(to activate an aggregation selection after initialize)
-		BOND_AD_INFO(bond).agg_select_timer = (AD_AGGREGATOR_SELECTION_TIMER * ad_ticks_per_sec);
-		BOND_AD_INFO(bond).agg_select_mode = AD_BANDWIDTH;
+		bond_3ad_initiate_agg_selection(bond,
+						AD_AGGREGATOR_SELECTION_TIMER *
+						ad_ticks_per_sec);
 	}
 }
 
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index b5ee45f..a803fe0 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -42,10 +42,11 @@ typedef struct mac_addr {
 	u8 mac_addr_value[ETH_ALEN];
 } mac_addr_t;
 
-typedef enum {
-	AD_BANDWIDTH = 0,
-	AD_COUNT
-} agg_selection_t;
+enum {
+	BOND_AD_STABLE = 0,
+	BOND_AD_BANDWIDTH = 1,
+	BOND_AD_COUNT = 2,
+};
 
 // rx machine states(43.4.11 in the 802.3ad standard)
 typedef enum {
@@ -277,6 +278,7 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
+void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 798d98c..02de3e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -97,6 +97,7 @@ static int use_carrier	= 1;
 static char *mode	= NULL;
 static char *primary	= NULL;
 static char *lacp_rate	= NULL;
+static char *ad_select  = NULL;
 static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
@@ -130,6 +131,8 @@ MODULE_PARM_DESC(primary, "Primary network device to use");
 module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
 			    "(slow/fast)");
+module_param(ad_select, charp, 0);
+MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
 module_param(xmit_hash_policy, charp, 0);
 MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
 				   ", 1 for layer 3+4");
@@ -200,6 +203,13 @@ struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	NULL,			-1},
 };
 
+struct bond_parm_tbl ad_select_tbl[] = {
+{	"stable",	BOND_AD_STABLE},
+{	"bandwidth",	BOND_AD_BANDWIDTH},
+{	"count",	BOND_AD_COUNT},
+{	NULL,		-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -3318,6 +3328,8 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_puts(seq, "\n802.3ad info\n");
 		seq_printf(seq, "LACP rate: %s\n",
 			   (bond->params.lacp_fast) ? "fast" : "slow");
+		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
+			   ad_select_tbl[bond->params.ad_select].modename);
 
 		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -3824,6 +3836,7 @@ static int bond_open(struct net_device *bond_dev)
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
+		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
 	return 0;
@@ -4763,6 +4776,23 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if (ad_select) {
+		params->ad_select = bond_parse_parm(ad_select, ad_select_tbl);
+		if (params->ad_select == -1) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: Invalid ad_select \"%s\"\n",
+			       ad_select == NULL ? "NULL" : ad_select);
+			return -EINVAL;
+		}
+
+		if (bond_mode != BOND_MODE_8023AD) {
+			printk(KERN_WARNING DRV_NAME
+			       ": ad_select param only affects 802.3ad mode\n");
+		}
+	} else {
+		params->ad_select = BOND_AD_STABLE;
+	}
+
 	if (max_bonds < 0 || max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8788e3e..aaf2927 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -48,6 +48,7 @@ extern struct list_head bond_dev_list;
 extern struct bond_params bonding_defaults;
 extern struct bond_parm_tbl bond_mode_tbl[];
 extern struct bond_parm_tbl bond_lacp_tbl[];
+extern struct bond_parm_tbl ad_select_tbl[];
 extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
@@ -944,6 +945,53 @@ out:
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
 
+static ssize_t bonding_show_ad_select(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%s %d\n",
+		ad_select_tbl[bond->params.ad_select].modename,
+		bond->params.ad_select);
+}
+
+
+static ssize_t bonding_store_ad_select(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (bond->dev->flags & IFF_UP) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to update ad_select because interface "
+		       "is up.\n", bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	new_value = bond_parse_parm(buf, ad_select_tbl);
+
+	if (new_value != -1) {
+		bond->params.ad_select = new_value;
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Setting ad_select to %s (%d).\n",
+		       bond->dev->name, ad_select_tbl[new_value].modename,
+		       new_value);
+	} else {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid ad_select value %.*s.\n",
+		       bond->dev->name, (int)strlen(buf) - 1, buf);
+		ret = -EINVAL;
+	}
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR, bonding_show_ad_select, bonding_store_ad_select);
+
 /*
  * Show and set the number of grat ARP to send after a failover event.
  */
@@ -1459,6 +1507,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_downdelay.attr,
 	&dev_attr_updelay.attr,
 	&dev_attr_lacp_rate.attr,
+	&dev_attr_ad_select.attr,
 	&dev_attr_xmit_hash_policy.attr,
 	&dev_attr_num_grat_arp.attr,
 	&dev_attr_num_unsol_na.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0491c7c..b5eb8e6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,8 +23,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.4.0"
-#define DRV_RELDATE	"October 7, 2008"
+#define DRV_VERSION	"3.5.0"
+#define DRV_RELDATE	"November 4, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -137,6 +137,7 @@ struct bond_params {
 	int updelay;
 	int downdelay;
 	int lacp_fast;
+	int ad_select;
 	char primary[IFNAMSIZ];
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
 };
-- 
1.6.0.2

