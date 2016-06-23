From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Wed, 22 Jun 2016 22:58:59 -0700
Message-ID: <2835.1466661539@famine>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com> <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com> <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com> <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com> <13338.1466523960@famine> <CAKdSkDWo-fwEMkZGQn2gkL+wT2yWEv1k-t+vVanZ-Cxzi=PcXQ@mail.gmail.com> <20835.1466556541@famine> <CAKdSkDVjoS7djSbZhGku=vdkPDq5cbADUxAh4GEzpWhnByjiww@mail.gmail.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50299 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcFWF7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 01:59:05 -0400
In-reply-to: <CAKdSkDVjoS7djSbZhGku=vdkPDq5cbADUxAh4GEzpWhnByjiww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
[...]
>>         I don't see an issue with the above behavior when ad_select is
>> set to the default value of "stable"; bonding does reselect a new
>> aggregator when all links fail, and it appears to follow the standard.
>
>In my testing ad_select=stable does not reselect a new aggregator when
>all links have failed. Reselection seems to occur only when a link
>comes up the failure. Here's an example of two bonds having three
>links each. Aggregator ID 3 is active with three ports and ID 2 has
>also three ports up.

	Yes, I've since observed that as well.

[...]
>Are you able to reproduce this or is reselection working as expected?

	Reselection is not working correctly at all.

	I'm working up a more comprehensive fix; the setting of BEGIN in
the older code masked a number of issues in the reselection logic that
never came up because setting BEGIN would do a full reselection from
scratch at every slave carrier state change (meaning that no aggregator
ever ended up with link down ports as members).

	My test patch at the moment is below (this is against net); any
testing or review would be appreciated.  I have not tested the ad_select
bandwidth behavior of this yet; I've been testing stable and count
first.

	This patch should be conformant to the standard, which requires
link down ports to remain selected, but implementations are free to
choose an active aggregator however they wish.

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b9304a295f86..57be940c4c37 100644
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
@@ -665,38 +679,39 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
 static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 {
 	u32 bandwidth = 0;
+	int nports = __agg_active_ports(aggregator);
 
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


	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
