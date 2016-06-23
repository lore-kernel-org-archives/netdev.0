From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Thu, 23 Jun 2016 14:20:51 -0700
Message-ID: <10542.1466716851@famine>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55397 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbcFWVU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Since commit 7bb11dc9f59d ("bonding: unify all places where
actor-oper key needs to be updated."), the logic in bonding to handle
selection between multiple aggregators has not functioned.

	This affects only configurations wherein the bonding slaves
connect to two discrete aggregators (e.g., two independent switches, each
with LACP enabled), thus creating two separate aggregation groups within a
single bond.

	The cause is a change in 7bb11dc9f59d to no longer set
AD_PORT_BEGIN on a port after a link state change, which would cause the
port to be reselected for attachment to an aggregator as if were newly
added to the bond.  We cannot restore the prior behavior, as it
contradicts IEEE 802.1AX 5.4.12, which requires ports that "become
inoperable" (lose carrier, setting port_enabled=false as per 802.1AX
5.4.7) to remain selected (i.e., assigned to the aggregator).  As the port
now remains selected, the aggregator selection logic is not invoked.

	A side effect of this change is that aggregators in bonding will
now contain ports that are link down.  The aggregator selection logic
does not currently handle this situation correctly, causing incorrect
aggregator selection.

	This patch makes two changes to repair the aggregator selection
logic in bonding to function as documented and within the confines of the
standard:

	First, the aggregator selection and related logic now utilizes the
number of active ports per aggregator, not the number of selected ports
(as some selected ports may be down).  The ad_select "bandwidth" and
"count" options only consider ports that are link up.

	Second, on any carrier state change of any slave, the aggregator
selection logic is explicitly called to insure the correct aggregator is
active.

Reported-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Fixes: 7bb11dc9f59d ("bonding: unify all places where actor-oper key needs to be updated.")
Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

---
 drivers/net/bonding/bond_3ad.c | 64 +++++++++++++++++++++++++++++-------------
 1 file changed, 45 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b9304a295f86..ca81f46ea1aa 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -657,6 +657,20 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
 	}
 }
 
+static int __agg_active_ports(struct aggregator *agg)
+{
+	struct port *port;
+	int active = 0;
+
+	for (port = agg->lag_ports; port;
+	     port = port->next_port_in_aggregator) {
+		if (port->is_enabled)
+			active++;
+	}
+
+	return active;
+}
+
 /**
  * __get_agg_bandwidth - get the total bandwidth of an aggregator
  * @aggregator: the aggregator we're looking at
@@ -664,39 +678,40 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
  */
 static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 {
+	int nports = __agg_active_ports(aggregator);
 	u32 bandwidth = 0;
 
-	if (aggregator->num_of_ports) {
+	if (nports) {
 		switch (__get_link_speed(aggregator->lag_ports)) {
 		case AD_LINK_SPEED_1MBPS:
-			bandwidth = aggregator->num_of_ports;
+			bandwidth = nports;
 			break;
 		case AD_LINK_SPEED_10MBPS:
-			bandwidth = aggregator->num_of_ports * 10;
+			bandwidth = nports * 10;
 			break;
 		case AD_LINK_SPEED_100MBPS:
-			bandwidth = aggregator->num_of_ports * 100;
+			bandwidth = nports * 100;
 			break;
 		case AD_LINK_SPEED_1000MBPS:
-			bandwidth = aggregator->num_of_ports * 1000;
+			bandwidth = nports * 1000;
 			break;
 		case AD_LINK_SPEED_2500MBPS:
-			bandwidth = aggregator->num_of_ports * 2500;
+			bandwidth = nports * 2500;
 			break;
 		case AD_LINK_SPEED_10000MBPS:
-			bandwidth = aggregator->num_of_ports * 10000;
+			bandwidth = nports * 10000;
 			break;
 		case AD_LINK_SPEED_20000MBPS:
-			bandwidth = aggregator->num_of_ports * 20000;
+			bandwidth = nports * 20000;
 			break;
 		case AD_LINK_SPEED_40000MBPS:
-			bandwidth = aggregator->num_of_ports * 40000;
+			bandwidth = nports * 40000;
 			break;
 		case AD_LINK_SPEED_56000MBPS:
-			bandwidth = aggregator->num_of_ports * 56000;
+			bandwidth = nports * 56000;
 			break;
 		case AD_LINK_SPEED_100000MBPS:
-			bandwidth = aggregator->num_of_ports * 100000;
+			bandwidth = nports * 100000;
 			break;
 		default:
 			bandwidth = 0; /* to silence the compiler */
@@ -1530,10 +1545,10 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 
 	switch (__get_agg_selection_mode(curr->lag_ports)) {
 	case BOND_AD_COUNT:
-		if (curr->num_of_ports > best->num_of_ports)
+		if (__agg_active_ports(curr) > __agg_active_ports(best))
 			return curr;
 
-		if (curr->num_of_ports < best->num_of_ports)
+		if (__agg_active_ports(curr) < __agg_active_ports(best))
 			return best;
 
 		/*FALLTHROUGH*/
@@ -1561,8 +1576,14 @@ static int agg_device_up(const struct aggregator *agg)
 	if (!port)
 		return 0;
 
-	return netif_running(port->slave->dev) &&
-	       netif_carrier_ok(port->slave->dev);
+	for (port = agg->lag_ports; port;
+	     port = port->next_port_in_aggregator) {
+		if (netif_running(port->slave->dev) &&
+		    netif_carrier_ok(port->slave->dev))
+			return 1;
+	}
+
+	return 0;
 }
 
 /**
@@ -1610,7 +1631,7 @@ static void ad_agg_selection_logic(struct aggregator *agg,
 
 		agg->is_active = 0;
 
-		if (agg->num_of_ports && agg_device_up(agg))
+		if (__agg_active_ports(agg) && agg_device_up(agg))
 			best = ad_agg_selection_test(best, agg);
 	}
 
@@ -1622,7 +1643,7 @@ static void ad_agg_selection_logic(struct aggregator *agg,
 		 * answering partner.
 		 */
 		if (active && active->lag_ports &&
-		    active->lag_ports->is_enabled &&
+		    __agg_active_ports(active) &&
 		    (__agg_has_partner(active) ||
 		     (!__agg_has_partner(active) &&
 		     !__agg_has_partner(best)))) {
@@ -2133,7 +2154,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				else
 					temp_aggregator->lag_ports = temp_port->next_port_in_aggregator;
 				temp_aggregator->num_of_ports--;
-				if (temp_aggregator->num_of_ports == 0) {
+				if (__agg_active_ports(temp_aggregator) == 0) {
 					select_new_active_agg = temp_aggregator->is_active;
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
@@ -2432,7 +2453,9 @@ void bond_3ad_adapter_speed_duplex_changed(struct slave *slave)
  */
 void bond_3ad_handle_link_change(struct slave *slave, char link)
 {
+	struct aggregator *agg;
 	struct port *port;
+	bool dummy;
 
 	port = &(SLAVE_AD_INFO(slave)->port);
 
@@ -2459,6 +2482,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->is_enabled = false;
 		ad_update_actor_keys(port, true);
 	}
+	agg = __get_first_agg(port);
+	ad_agg_selection_logic(agg, &dummy);
+
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
 		   link == BOND_LINK_UP ? "UP" : "DOWN");
@@ -2499,7 +2525,7 @@ int bond_3ad_set_carrier(struct bonding *bond)
 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
 	if (active) {
 		/* are enough slaves available to consider link up? */
-		if (active->num_of_ports < bond->params.min_links) {
+		if (__agg_active_ports(active) < bond->params.min_links) {
 			if (netif_carrier_ok(bond->dev)) {
 				netif_carrier_off(bond->dev);
 				goto out;
-- 
1.9.1
