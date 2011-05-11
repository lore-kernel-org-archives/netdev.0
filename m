From: Rafael Aquini <aquini@linux.com>
Subject: [PATCH net-next-2.6] net/bonding: adjust codingstyle for bond_3ad files
Date: Wed, 11 May 2011 19:52:21 -0300
Message-ID: <20110511225208.GA18851@x61.tchesoft.com>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63305 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab1EKW4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 18:56:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy,

While I was studying what bond_3ad has under its hood, I realized its coding
style did not follow all Documentation/CodingStyle recommendations. As a tiny
collaboration I did some mods there, in an attempt to make that code stick as
closely as possible with Kernel's coding style. Also, Nicolas Kaiser has kindly
suggested some conditional simplifications integrated in this patch.
Modifications:
        * switched all comments from C99-style to C89-style;
        * replaced MAC_ADDRESS_COMPARE macro for compare_ether_addr();
	* print info out on unexpected status checkings;
        * simplify conditionals:
		(a || (!a && !b)) => (a || !b)
		(!(!a && b)) => (a || !b)

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
Signed-off-by: Rafael Aquini <aquini@linux.com>
---
 drivers/net/bonding/bond_3ad.c |  907 +++++++++++++++++++++++-----------------
 drivers/net/bonding/bond_3ad.h |  193 +++++----
 2 files changed, 624 insertions(+), 476 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c7537abc..3f6f8ee 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -34,14 +34,14 @@
 #include "bonding.h"
 #include "bond_3ad.h"
 
-// General definitions
+/* General definitions */
 #define AD_SHORT_TIMEOUT           1
 #define AD_LONG_TIMEOUT            0
 #define AD_STANDBY                 0x2
 #define AD_MAX_TX_IN_SECOND        3
 #define AD_COLLECTOR_MAX_DELAY     0
 
-// Timer definitions(43.4.4 in the 802.3ad standard)
+/* Timer definitions (43.4.4 in the 802.3ad standard) */
 #define AD_FAST_PERIODIC_TIME      1
 #define AD_SLOW_PERIODIC_TIME      30
 #define AD_SHORT_TIMEOUT_TIME      (3*AD_FAST_PERIODIC_TIME)
@@ -49,7 +49,7 @@
 #define AD_CHURN_DETECTION_TIME    60
 #define AD_AGGREGATE_WAIT_TIME     2
 
-// Port state definitions(43.4.2.2 in the 802.3ad standard)
+/* Port state definitions (43.4.2.2 in the 802.3ad standard) */
 #define AD_STATE_LACP_ACTIVITY   0x1
 #define AD_STATE_LACP_TIMEOUT    0x2
 #define AD_STATE_AGGREGATION     0x4
@@ -59,7 +59,9 @@
 #define AD_STATE_DEFAULTED       0x40
 #define AD_STATE_EXPIRED         0x80
 
-// Port Variables definitions used by the State Machines(43.4.7 in the 802.3ad standard)
+/* Port Variables definitions used by the State Machines
+ * (43.4.7 in the 802.3ad standard)
+ */
 #define AD_PORT_BEGIN           0x1
 #define AD_PORT_LACP_ENABLED    0x2
 #define AD_PORT_ACTOR_CHURN     0x4
@@ -71,27 +73,23 @@
 #define AD_PORT_SELECTED        0x100
 #define AD_PORT_MOVED           0x200
 
-// Port Key definitions
-// key is determined according to the link speed, duplex and
-// user key(which is yet not supported)
-//              ------------------------------------------------------------
-// Port key :   | User key                       |      Speed       |Duplex|
-//              ------------------------------------------------------------
-//              16                               6               1 0
+/* Port Key definitions:
+ *  key is determined according to the link speed, duplex and
+ *  user key (which is yet not supported)
+ *             ------------------------------------------------------------
+ *  Port key:  | User key                       |      Speed       |Duplex|
+ *             ------------------------------------------------------------
+ *             16                               6                  1      0
+ */
 #define  AD_DUPLEX_KEY_BITS    0x1
 #define  AD_SPEED_KEY_BITS     0x3E
 #define  AD_USER_KEY_BITS      0xFFC0
 
-//dalloun
 #define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
 #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
-//endalloun
-
-// compare MAC addresses
-#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
 
 static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
 static u16 ad_ticks_per_sec;
@@ -99,7 +97,7 @@ static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
 static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
-// ================= main 802.3ad protocol functions ==================
+/* ================= main 802.3ad protocol functions ================== */
 static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);
 static void ad_mux_machine(struct port *port);
@@ -113,14 +111,12 @@ static void ad_initialize_agg(struct aggregator *aggregator);
 static void ad_initialize_port(struct port *port, int lacp_fast);
 static void ad_enable_collecting_distributing(struct port *port);
 static void ad_disable_collecting_distributing(struct port *port);
-static void ad_marker_info_received(struct bond_marker *marker_info, struct port *port);
-static void ad_marker_response_received(struct bond_marker *marker, struct port *port);
-
-
-/////////////////////////////////////////////////////////////////////////////////
-// ================= api to bonding and kernel code ==================
-/////////////////////////////////////////////////////////////////////////////////
+static void ad_marker_info_received(struct bond_marker *marker_info,
+				    struct port *port);
+static void ad_marker_response_received(struct bond_marker *marker,
+					struct port *port);
 
+/* ================= api to bonding and kernel code ================== */
 /**
  * __get_bond_by_port - get the port's bonding struct
  * @port: the port we're looking at
@@ -161,7 +157,7 @@ static inline struct port *__get_next_port(struct port *port)
 	struct bonding *bond = __get_bond_by_port(port);
 	struct slave *slave = port->slave;
 
-	// If there's no bond for this port, or this is the last slave
+	/* If there's no bond for this port, or this is the last slave */
 	if ((bond == NULL) || (slave->next == bond->first_slave))
 		return NULL;
 
@@ -179,7 +175,7 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 
-	// If there's no bond for this port, or bond has no slaves
+	/* If there's no bond for this port, or bond has no slaves */
 	if ((bond == NULL) || (bond->slave_cnt == 0))
 		return NULL;
 
@@ -198,7 +194,7 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
 	struct slave *slave = aggregator->slave;
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 
-	// If there's no bond for this aggregator, or this is the last slave
+	/* If there's no bond for this aggregator, or this is the last slave */
 	if ((bond == NULL) || (slave->next == bond->first_slave))
 		return NULL;
 
@@ -316,10 +312,9 @@ static u16 __get_link_speed(struct port *port)
 	struct slave *slave = port->slave;
 	u16 speed;
 
-	/* this if covers only a special case: when the configuration starts with
-	 * link down, it sets the speed to 0.
-	 * This is done in spite of the fact that the e100 driver reports 0 to be
-	 * compatible with MVT in the future.*/
+	/* handling a special case:
+	 * when the configuration starts with link down, it sets the speed to 0
+	 */
 	if (slave->link != BOND_LINK_UP)
 		speed = 0;
 	else {
@@ -341,7 +336,9 @@ static u16 __get_link_speed(struct port *port)
 			break;
 
 		default:
-			speed = 0; // unknown speed value from ethtool. shouldn't happen
+			/* unknown speed value from ethtool. shouldn't happen */
+			pr_debug("Unexpected slave->speed: %d\n", slave->speed);
+			speed = 0;
 			break;
 		}
 	}
@@ -362,13 +359,13 @@ static u16 __get_link_speed(struct port *port)
 static u8 __get_duplex(struct port *port)
 {
 	struct slave *slave = port->slave;
+	u8 retval = 0x0;
 
-	u8 retval;
-
-	//  handling a special case: when the configuration starts with
-	// link down, it sets the duplex to 0.
+	/* handling a special case:
+	 * when the configuration starts with link down, it sets the duplex to 0
+	 */
 	if (slave->link != BOND_LINK_UP)
-		retval = 0x0;
+		goto out;
 	else {
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
@@ -384,6 +381,7 @@ static u8 __get_duplex(struct port *port)
 			break;
 		}
 	}
+out:
 	return retval;
 }
 
@@ -394,12 +392,9 @@ static u8 __get_duplex(struct port *port)
  */
 static inline void __initialize_port_locks(struct port *port)
 {
-	// make sure it isn't called twice
 	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
 }
 
-//conversions
-
 /**
  * __ad_timer_to_ticks - convert a given timer type to AD module ticks
  * @timer_type:	which timer to operate
@@ -411,36 +406,36 @@ static inline void __initialize_port_locks(struct port *port)
  */
 static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
 {
-	u16 retval = 0; /* to silence the compiler */
+	u16 retval;
 
 	switch (timer_type) {
-	case AD_CURRENT_WHILE_TIMER:   // for rx machine usage
+	case AD_CURRENT_WHILE_TIMER:	/* for rx machine usage */
 		if (par)
-			retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec); // short timeout
+			retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec);
 		else
-			retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec); // long timeout
+			retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec);
 		break;
-	case AD_ACTOR_CHURN_TIMER:	    // for local churn machine
+	case AD_ACTOR_CHURN_TIMER:	/* for local churn machine */
 		retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
 		break;
-	case AD_PERIODIC_TIMER:	    // for periodic machine
-		retval = (par*ad_ticks_per_sec); // long timeout
+	case AD_PERIODIC_TIMER:		/* for periodic machine */
+		retval = (par*ad_ticks_per_sec);
 		break;
-	case AD_PARTNER_CHURN_TIMER:   // for remote churn machine
+	case AD_PARTNER_CHURN_TIMER:	/* for remote churn machine */
 		retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
 		break;
-	case AD_WAIT_WHILE_TIMER:	    // for selection machine
+	case AD_WAIT_WHILE_TIMER:	/* for selection machine */
 		retval = (AD_AGGREGATE_WAIT_TIME*ad_ticks_per_sec);
 		break;
+	default:
+		pr_warn("Unexpected AD timer_type: %d\n", timer_type);
+		retval = 0;
+		break;
 	}
 	return retval;
 }
 
-
-/////////////////////////////////////////////////////////////////////////////////
-// ================= ad_rx_machine helper functions ==================
-/////////////////////////////////////////////////////////////////////////////////
-
+/* ================= ad_rx_machine helper functions ================== */
 /**
  * __choose_matched - update a port's matched variable from a received lacpdu
  * @lacpdu: the lacpdu we've received
@@ -466,17 +461,17 @@ static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
  */
 static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
 {
-	// check if all parameters are alike
+	/* check if all parameters are alike */
 	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
 	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
-	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
+	     !compare_ether_addr((const u8 *)&(lacpdu->partner_system), (const u8 *)&(port->actor_system)) &&
 	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
 	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
 	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
-	    // or this is individual link(aggregation == FALSE)
+	    /* or this is individual link(aggregation == FALSE) */
 	    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
 		) {
-		// update the state machine Matched variable
+		/* update the state machine Matched variable */
 		port->sm_vars |= AD_PORT_MATCHED;
 	} else {
 		port->sm_vars &= ~AD_PORT_MATCHED;
@@ -498,7 +493,7 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		struct port_params *partner = &port->partner_oper;
 
 		__choose_matched(lacpdu, port);
-		// record the new parameter values for the partner operational
+		/* record the new values for the operational partner */
 		partner->port_number = ntohs(lacpdu->actor_port);
 		partner->port_priority = ntohs(lacpdu->actor_port_priority);
 		partner->system = lacpdu->actor_system;
@@ -506,12 +501,14 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		partner->key = ntohs(lacpdu->actor_key);
 		partner->port_state = lacpdu->actor_state;
 
-		// set actor_oper_port_state.defaulted to FALSE
+		/* set actor_oper_port_state.defaulted to FALSE */
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;
 
-		// set the partner sync. to on if the partner is sync. and the port is matched
-		if ((port->sm_vars & AD_PORT_MATCHED)
-		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
+		/* set the partner sync to on if the partner is sync
+		 * and the port is matched.
+		 */
+		if ((port->sm_vars & AD_PORT_MATCHED) &&
+		    (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
 			partner->port_state |= AD_STATE_SYNCHRONIZATION;
 		else
 			partner->port_state &= ~AD_STATE_SYNCHRONIZATION;
@@ -529,11 +526,8 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 static void __record_default(struct port *port)
 {
 	if (port) {
-		// record the partner admin parameters
 		memcpy(&port->partner_oper, &port->partner_admin,
 		       sizeof(struct port_params));
-
-		// set actor_oper_port_state.defaulted to true
 		port->actor_oper_port_state |= AD_STATE_DEFAULTED;
 	}
 }
@@ -556,14 +550,13 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 	if (lacpdu && port) {
 		const struct port_params *partner = &port->partner_oper;
 
-		// check if any parameter is different
 		if (ntohs(lacpdu->actor_port) != partner->port_number ||
 		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
-		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
+		    compare_ether_addr((const u8 *)&lacpdu->actor_system, (const u8 *)&partner->system) ||
 		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
 		    ntohs(lacpdu->actor_key) != partner->key ||
 		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
-			// update the state machine Selected variable
+			/* update the state machine Selected variable */
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}
 	}
@@ -587,15 +580,15 @@ static void __update_default_selected(struct port *port)
 		const struct port_params *admin = &port->partner_admin;
 		const struct port_params *oper = &port->partner_oper;
 
-		// check if any parameter is different
 		if (admin->port_number != oper->port_number ||
 		    admin->port_priority != oper->port_priority ||
-		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
+		    compare_ether_addr((const u8 *)&admin->system,
+					 (const u8 *)&oper->system) ||
 		    admin->system_priority != oper->system_priority ||
 		    admin->key != oper->key ||
 		    (admin->port_state & AD_STATE_AGGREGATION)
 			!= (oper->port_state & AD_STATE_AGGREGATION)) {
-			// update the state machine Selected variable
+			/* update the state machine Selected variable */
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}
 	}
@@ -615,12 +608,10 @@ static void __update_default_selected(struct port *port)
  */
 static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 {
-	// validate lacpdu and port
 	if (lacpdu && port) {
-		// check if any parameter is different
 		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
 		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
+		    compare_ether_addr((const u8 *)&(lacpdu->partner_system), (const u8 *)&(port->actor_system)) ||
 		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
 		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
@@ -628,7 +619,6 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 		    ((lacpdu->partner_state & AD_STATE_SYNCHRONIZATION) != (port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) ||
 		    ((lacpdu->partner_state & AD_STATE_AGGREGATION) != (port->actor_oper_port_state & AD_STATE_AGGREGATION))
 		   ) {
-
 			port->ntt = true;
 		}
 	}
@@ -644,9 +634,7 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
  */
 static void __attach_bond_to_agg(struct port *port)
 {
-	port = NULL; /* just to satisfy the compiler */
-	// This function does nothing since the parser/multiplexer of the receive
-	// and the parser/multiplexer of the aggregator are already combined
+	port = NULL;
 }
 
 /**
@@ -659,9 +647,7 @@ static void __attach_bond_to_agg(struct port *port)
  */
 static void __detach_bond_from_agg(struct port *port)
 {
-	port = NULL; /* just to satisfy the compiler */
-	// This function does nothing sience the parser/multiplexer of the receive
-	// and the parser/multiplexer of the aggregator are already combined
+	port = NULL;
 }
 
 /**
@@ -675,7 +661,9 @@ static int __agg_ports_are_ready(struct aggregator *aggregator)
 	int retval = 1;
 
 	if (aggregator) {
-		// scan all ports in this aggregator to verfy if they are all ready
+		/* scan all ports in this aggregator
+		 * to verify if they are all ready.
+		 */
 		for (port = aggregator->lag_ports;
 		     port;
 		     port = port->next_port_in_aggregator) {
@@ -715,28 +703,32 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
  */
 static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 {
-	u32 bandwidth = 0;
+	u32 bandwidth;
 
-	if (aggregator->num_of_ports) {
-		switch (__get_link_speed(aggregator->lag_ports)) {
-		case AD_LINK_SPEED_BITMASK_1MBPS:
-			bandwidth = aggregator->num_of_ports;
-			break;
-		case AD_LINK_SPEED_BITMASK_10MBPS:
-			bandwidth = aggregator->num_of_ports * 10;
-			break;
-		case AD_LINK_SPEED_BITMASK_100MBPS:
-			bandwidth = aggregator->num_of_ports * 100;
-			break;
-		case AD_LINK_SPEED_BITMASK_1000MBPS:
-			bandwidth = aggregator->num_of_ports * 1000;
-			break;
-		case AD_LINK_SPEED_BITMASK_10000MBPS:
-			bandwidth = aggregator->num_of_ports * 10000;
-			break;
-		default:
-			bandwidth = 0; /*to silence the compiler ....*/
-		}
+	if (!aggregator->num_of_ports)
+		return 0;
+
+	switch (__get_link_speed(aggregator->lag_ports)) {
+	case AD_LINK_SPEED_BITMASK_1MBPS:
+		bandwidth = aggregator->num_of_ports;
+		break;
+	case AD_LINK_SPEED_BITMASK_10MBPS:
+		bandwidth = aggregator->num_of_ports * 10;
+		break;
+	case AD_LINK_SPEED_BITMASK_100MBPS:
+		bandwidth = aggregator->num_of_ports * 100;
+		break;
+	case AD_LINK_SPEED_BITMASK_1000MBPS:
+		bandwidth = aggregator->num_of_ports * 1000;
+		break;
+	case AD_LINK_SPEED_BITMASK_10000MBPS:
+		bandwidth = aggregator->num_of_ports * 10000;
+		break;
+	default:
+		pr_debug("Unexpected aggregator link speed: %d\n",
+			 __get_link_speed(aggregator->lag_ports));
+		bandwidth = 0;
+		break;
 	}
 	return bandwidth;
 }
@@ -807,10 +799,7 @@ static inline void __update_lacpdu_from_port(struct port *port)
 	 */
 }
 
-//////////////////////////////////////////////////////////////////////////////////////
-// ================= main 802.3ad protocol code ======================================
-//////////////////////////////////////////////////////////////////////////////////////
-
+/* ================= main 802.3ad protocol code ================= */
 /**
  * ad_lacpdu_send - send out a lacpdu packet on a given port
  * @port: the port we're looking at
@@ -839,11 +828,12 @@ static int ad_lacpdu_send(struct port *port)
 
 	memcpy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source address is set to be the member's PERMANENT address,
-	   because we use it to identify loopback lacpdus in receive. */
+	 * because we use it to identify loopback lacpdus in receive.
+	 */
 	memcpy(lacpdu_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
 	lacpdu_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	lacpdu_header->lacpdu = port->lacpdu; // struct copy
+	lacpdu_header->lacpdu = port->lacpdu; /* struct copy */
 
 	dev_queue_xmit(skb);
 
@@ -884,7 +874,7 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 	memcpy(marker_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
 	marker_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	marker_header->marker = *marker; // struct copy
+	marker_header->marker = *marker; /* struct copy */
 
 	dev_queue_xmit(skb);
 
@@ -900,80 +890,103 @@ static void ad_mux_machine(struct port *port)
 {
 	mux_states_t last_state;
 
-	// keep current State Machine state to compare later if it was changed
 	last_state = port->sm_mux_state;
 
 	if (port->sm_vars & AD_PORT_BEGIN) {
-		port->sm_mux_state = AD_MUX_DETACHED;		 // next state
+		port->sm_mux_state = AD_MUX_DETACHED;
 	} else {
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
-			if ((port->sm_vars & AD_PORT_SELECTED)
-			    || (port->sm_vars & AD_PORT_STANDBY))
+			if ((port->sm_vars & AD_PORT_SELECTED) ||
+			    (port->sm_vars & AD_PORT_STANDBY))
 				/* if SELECTED or STANDBY */
-				port->sm_mux_state = AD_MUX_WAITING; // next state
+				port->sm_mux_state = AD_MUX_WAITING;
 			break;
 		case AD_MUX_WAITING:
-			// if SELECTED == FALSE return to DETACH state
-			if (!(port->sm_vars & AD_PORT_SELECTED)) { // if UNSELECTED
+			/* if SELECTED == FALSE return to DETACH state */
+			if (!(port->sm_vars & AD_PORT_SELECTED)) {
 				port->sm_vars &= ~AD_PORT_READY_N;
-				// in order to withhold the Selection Logic to check all ports READY_N value
-				// every callback cycle to update ready variable, we check READY_N and update READY here
-				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
-				port->sm_mux_state = AD_MUX_DETACHED;	 // next state
+				/* in order to withhold the Selection Logic
+				 * to check all ports READY_N value at every
+				 * callback cycle to update ready variable,
+				 * we check READY_N and update READY here
+				 */
+				__set_agg_ports_ready(port->aggregator,
+				       __agg_ports_are_ready(port->aggregator));
+				port->sm_mux_state = AD_MUX_DETACHED;
 				break;
 			}
 
-			// check if the wait_while_timer expired
-			if (port->sm_mux_timer_counter
-			    && !(--port->sm_mux_timer_counter))
+			/* check if the wait_while_timer expired */
+			if (port->sm_mux_timer_counter &&
+			    !(--port->sm_mux_timer_counter))
 				port->sm_vars |= AD_PORT_READY_N;
 
-			// in order to withhold the selection logic to check all ports READY_N value
-			// every callback cycle to update ready variable, we check READY_N and update READY here
-			__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
-
-			// if the wait_while_timer expired, and the port is in READY state, move to ATTACHED state
-			if ((port->sm_vars & AD_PORT_READY)
-			    && !port->sm_mux_timer_counter)
-				port->sm_mux_state = AD_MUX_ATTACHED;	 // next state
+			/* in order to withhold the selection logic
+			 * to check all ports READY_N value at every
+			 * callback cycle to update ready variable,
+			 * we check READY_N and update READY here
+			 */
+			__set_agg_ports_ready(port->aggregator,
+				       __agg_ports_are_ready(port->aggregator));
+
+			/* if the wait_while_timer expired,  and the port
+			 * is in READY state, move to ATTACHED state
+			 */
+			if ((port->sm_vars & AD_PORT_READY) &&
+			    !port->sm_mux_timer_counter)
+				port->sm_mux_state = AD_MUX_ATTACHED;
 			break;
 		case AD_MUX_ATTACHED:
-			// check also if agg_select_timer expired(so the edable port will take place only after this timer)
-			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
-				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;// next state
-			} else if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY)) {	  // if UNSELECTED or STANDBY
+			/* check also if agg_select_timer expired
+			 * so the enable port will take place
+			 * only after this timer
+			 */
+			if ((port->sm_vars & AD_PORT_SELECTED) &&
+			    (port->partner_oper.port_state &
+			     AD_STATE_SYNCHRONIZATION) &&
+			    !__check_agg_selection_timer(port)) {
+				port->sm_mux_state =
+					AD_MUX_COLLECTING_DISTRIBUTING;
+			} else if (!(port->sm_vars & AD_PORT_SELECTED) ||
+				   (port->sm_vars & AD_PORT_STANDBY)) {
+				/* if UNSELECTED or STANDBY */
 				port->sm_vars &= ~AD_PORT_READY_N;
-				// in order to withhold the selection logic to check all ports READY_N value
-				// every callback cycle to update ready variable, we check READY_N and update READY here
-				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
-				port->sm_mux_state = AD_MUX_DETACHED;// next state
+				/* in order to withhold the Selection Logic
+				 * to check all ports READY_N value at every
+				 * callback cycle to update ready variable,
+				 * we check READY_N and update READY here
+				 */
+				__set_agg_ports_ready(port->aggregator,
+				       __agg_ports_are_ready(port->aggregator));
+				port->sm_mux_state = AD_MUX_DETACHED;
 			}
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
-			if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY) ||
-			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)
-			   ) {
-				port->sm_mux_state = AD_MUX_ATTACHED;// next state
-
+			if (!(port->sm_vars & AD_PORT_SELECTED) ||
+			    (port->sm_vars & AD_PORT_STANDBY) ||
+			    !(port->partner_oper.port_state &
+			     AD_STATE_SYNCHRONIZATION)) {
+				port->sm_mux_state = AD_MUX_ATTACHED;
 			} else {
-				// if port state hasn't changed make
-				// sure that a collecting distributing
-				// port in an active aggregator is enabled
+				/* if port state hasn't changed make
+				 * sure that a collecting distributing
+				 * port in an active aggregator is enabled
+				 */
 				if (port->aggregator &&
 				    port->aggregator->is_active &&
-				    !__port_is_enabled(port)) {
-
+				    !__port_is_enabled(port))
 					__enable_port(port);
-				}
 			}
 			break;
-		default:    //to silence the compiler
+		default:
+			pr_debug("Unexpected port->sm_mux_state: %d\n",
+				 port->sm_mux_state);
 			break;
 		}
 	}
 
-	// check if the state machine was changed
+	/* check if the state machine was changed */
 	if (port->sm_mux_state != last_state) {
 		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
@@ -981,14 +994,16 @@ static void ad_mux_machine(struct port *port)
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
 			__detach_bond_from_agg(port);
-			port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
+			port->actor_oper_port_state &=
+					~AD_STATE_SYNCHRONIZATION;
 			ad_disable_collecting_distributing(port);
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
 			port->ntt = true;
 			break;
 		case AD_MUX_WAITING:
-			port->sm_mux_timer_counter = __ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
+			port->sm_mux_timer_counter =
+				__ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
 			break;
 		case AD_MUX_ATTACHED:
 			__attach_bond_to_agg(port);
@@ -1004,7 +1019,9 @@ static void ad_mux_machine(struct port *port)
 			ad_enable_collecting_distributing(port);
 			port->ntt = true;
 			break;
-		default:    //to silence the compiler
+		default:
+			pr_debug("Unexpected port->sm_mux_state: %d\n",
+				 port->sm_mux_state);
 			break;
 		}
 	}
@@ -1021,61 +1038,65 @@ static void ad_mux_machine(struct port *port)
  */
 static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 {
-	rx_states_t last_state;
+	rx_states_t last_state = port->sm_rx_state;
 
-	// keep current State Machine state to compare later if it was changed
-	last_state = port->sm_rx_state;
-
-	// check if state machine should change state
-	// first, check if port was reinitialized
+	/* check if state machine should change state
+	 * first, check if port was reinitialized
+	 */
 	if (port->sm_vars & AD_PORT_BEGIN)
 		/* next state */
 		port->sm_rx_state = AD_RX_INITIALIZE;
-	// check if port is not enabled
-	else if (!(port->sm_vars & AD_PORT_BEGIN)
-		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
+	/* check if port is not enabled */
+	else if (!(port->sm_vars & AD_PORT_BEGIN) &&
+		 !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
 		/* next state */
 		port->sm_rx_state = AD_RX_PORT_DISABLED;
-	// check if new lacpdu arrived
-	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) || (port->sm_rx_state == AD_RX_DEFAULTED) || (port->sm_rx_state == AD_RX_CURRENT))) {
-		port->sm_rx_timer_counter = 0; // zero timer
+	/* check if new lacpdu arrived */
+	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) ||
+		 (port->sm_rx_state == AD_RX_DEFAULTED) ||
+		 (port->sm_rx_state == AD_RX_CURRENT))) {
+		port->sm_rx_timer_counter = 0; /* zero timer */
 		port->sm_rx_state = AD_RX_CURRENT;
 	} else {
-		// if timer is on, and if it is expired
-		if (port->sm_rx_timer_counter && !(--port->sm_rx_timer_counter)) {
+		/* if timer is on, and if it is expired */
+		if (port->sm_rx_timer_counter &&
+		    !(--port->sm_rx_timer_counter)) {
 			switch (port->sm_rx_state) {
 			case AD_RX_EXPIRED:
-				port->sm_rx_state = AD_RX_DEFAULTED;		// next state
+				port->sm_rx_state = AD_RX_DEFAULTED;
 				break;
 			case AD_RX_CURRENT:
-				port->sm_rx_state = AD_RX_EXPIRED;	    // next state
+				port->sm_rx_state = AD_RX_EXPIRED;
 				break;
-			default:    //to silence the compiler
+			default:
+				pr_warn("Unexpected port->sm_rx_state: %d\n",
+					 port->sm_rx_state);
 				break;
 			}
 		} else {
-			// if no lacpdu arrived and no timer is on
+			/* if no lacpdu arrived and no timer is on */
 			switch (port->sm_rx_state) {
 			case AD_RX_PORT_DISABLED:
 				if (port->sm_vars & AD_PORT_MOVED)
-					port->sm_rx_state = AD_RX_INITIALIZE;	    // next state
-				else if (port->is_enabled
-					 && (port->sm_vars
-					     & AD_PORT_LACP_ENABLED))
-					port->sm_rx_state = AD_RX_EXPIRED;	// next state
-				else if (port->is_enabled
-					 && ((port->sm_vars
-					      & AD_PORT_LACP_ENABLED) == 0))
-					port->sm_rx_state = AD_RX_LACP_DISABLED;    // next state
+					port->sm_rx_state = AD_RX_INITIALIZE;
+				else if (port->is_enabled &&
+					 (port->sm_vars &
+					     AD_PORT_LACP_ENABLED))
+					port->sm_rx_state = AD_RX_EXPIRED;
+				else if (port->is_enabled &&
+					 ((port->sm_vars &
+					      AD_PORT_LACP_ENABLED) == 0))
+					port->sm_rx_state = AD_RX_LACP_DISABLED;
 				break;
-			default:    //to silence the compiler
+			default:
+				pr_warn("Unexpected port->sm_rx_state: %d\n",
+					 port->sm_rx_state);
 				break;
-
 			}
 		}
 	}
 
-	// check if the State machine was changed or new lacpdu arrived
+	/* check if the State machine was changed or new lacpdu arrived */
 	if ((port->sm_rx_state != last_state) || (lacpdu)) {
 		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
@@ -1090,7 +1111,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			__record_default(port);
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			port->sm_vars &= ~AD_PORT_MOVED;
-			port->sm_rx_state = AD_RX_PORT_DISABLED;	// next state
+			port->sm_rx_state = AD_RX_PORT_DISABLED;
 
 			/*- Fall Through -*/
 
@@ -1105,14 +1126,20 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
 		case AD_RX_EXPIRED:
-			//Reset of the Synchronization flag. (Standard 43.4.12)
-			//This reset cause to disable this port in the COLLECTING_DISTRIBUTING state of the
-			//mux machine in case of EXPIRED even if LINK_DOWN didn't arrive for the port.
-			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
+			/* Reset of the Synchronization flag. (Standard 43.4.12)
+			 * This reset cause to disable this port in the
+			 * COLLECTING_DISTRIBUTING state of the mux machine
+			 * in case of EXPIRED even if LINK_DOWN didn't arrive
+			 * for the port.
+			 */
+			port->partner_oper.port_state &=
+						~AD_STATE_SYNCHRONIZATION;
 			port->sm_vars &= ~AD_PORT_MATCHED;
 			port->partner_oper.port_state |=
 				AD_STATE_LACP_ACTIVITY;
-			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
+			port->sm_rx_timer_counter =
+				__ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER,
+						(u16)(AD_SHORT_TIMEOUT));
 			port->actor_oper_port_state |= AD_STATE_EXPIRED;
 			break;
 		case AD_RX_DEFAULTED:
@@ -1122,12 +1149,13 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
 		case AD_RX_CURRENT:
-			// detect loopback situation
-			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
-				// INFO_RECEIVED_LOOPBACK_FRAMES
+			/* detect loopback situation */
+			if (!compare_ether_addr((const u8 *)&(lacpdu->actor_system), (const u8 *)&(port->actor_system))) {
+				/* INFO_RECEIVED_LOOPBACK_FRAMES */
 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
-				       port->slave->dev->master->name, port->slave->dev->name);
+				       port->slave->dev->master->name,
+				       port->slave->dev->name);
 				return;
 			}
 			__update_selected(lacpdu, port);
@@ -1135,15 +1163,21 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			__record_pdu(lacpdu, port);
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
-			// verify that if the aggregator is enabled, the port is enabled too.
-			//(because if the link goes down for a short time, the 802.3ad will not
-			// catch it, and the port will continue to be disabled)
+
+			/* verify that if the aggregator is enabled,
+			 * so the port is enabled too.
+			 * because if the link goes down for a short time,
+			 * the 802.3ad will not catch it,
+			 * and the port will continue to be disabled
+			 */
 			if (port->aggregator
 			    && port->aggregator->is_active
 			    && !__port_is_enabled(port))
 				__enable_port(port);
 			break;
-		default:    //to silence the compiler
+		default:
+			pr_warn("Unexpected port->sm_rx_state: %d\n",
+				 port->sm_rx_state);
 			break;
 		}
 	}
@@ -1156,9 +1190,11 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
  */
 static void ad_tx_machine(struct port *port)
 {
-	// check if tx timer expired, to verify that we do not send more than 3 packets per second
+	/* check if tx timer has expired,
+	 * to verify that we do not send more than 3 packets per second
+	 */
 	if (port->sm_tx_timer_counter && !(--port->sm_tx_timer_counter)) {
-		// check if there is something to send
+		/* check if there is something to send */
 		if (port->ntt && (port->sm_vars & AD_PORT_LACP_ENABLED)) {
 			__update_lacpdu_from_port(port);
 
@@ -1166,14 +1202,17 @@ static void ad_tx_machine(struct port *port)
 				pr_debug("Sent LACPDU on port %d\n",
 					 port->actor_port_number);
 
-				/* mark ntt as false, so it will not be sent again until
-				   demanded */
+				/* mark ntt as false,
+				 * so it won't be sent again until demanded
+				 */
 				port->ntt = false;
 			}
 		}
-		// restart tx timer(to verify that we will not exceed AD_MAX_TX_IN_SECOND
+		/* restart tx timer
+		 * to verify that we won't exceed AD_MAX_TX_IN_SECOND
+		 */
 		port->sm_tx_timer_counter =
-			ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
+				ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 	}
 }
 
@@ -1187,76 +1226,96 @@ static void ad_periodic_machine(struct port *port)
 {
 	periodic_states_t last_state;
 
-	// keep current state machine state to compare later if it was changed
+	/* keep current state machine state to compare later if it was changed*/
 	last_state = port->sm_periodic_state;
 
-	// check if port was reinitialized
-	if (((port->sm_vars & AD_PORT_BEGIN) || !(port->sm_vars & AD_PORT_LACP_ENABLED) || !port->is_enabled) ||
-	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) && !(port->partner_oper.port_state & AD_STATE_LACP_ACTIVITY))
-	   ) {
-		port->sm_periodic_state = AD_NO_PERIODIC;	     // next state
+	/* check if port was reinitialized */
+	if (((port->sm_vars & AD_PORT_BEGIN) ||
+	    !(port->sm_vars & AD_PORT_LACP_ENABLED) ||
+	    !port->is_enabled) ||
+	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) &&
+	     !(port->partner_oper.port_state & AD_STATE_LACP_ACTIVITY))) {
+		port->sm_periodic_state = AD_NO_PERIODIC; /* next state */
 	}
-	// check if state machine should change state
+	/* check if state machine should change state */
 	else if (port->sm_periodic_timer_counter) {
-		// check if periodic state machine expired
+		/* check if periodic state machine expired */
 		if (!(--port->sm_periodic_timer_counter)) {
-			// if expired then do tx
-			port->sm_periodic_state = AD_PERIODIC_TX;    // next state
+			/* if expired then do tx, next state */
+			port->sm_periodic_state = AD_PERIODIC_TX;
 		} else {
-			// If not expired, check if there is some new timeout parameter from the partner state
+			/* If not expired, check if there is some
+			 * new timeout parameter from the partner state
+			 */
 			switch (port->sm_periodic_state) {
 			case AD_FAST_PERIODIC:
 				if (!(port->partner_oper.port_state
 				      & AD_STATE_LACP_TIMEOUT))
-					port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
+					port->sm_periodic_state = AD_SLOW_PERIODIC;
 				break;
 			case AD_SLOW_PERIODIC:
-				if ((port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
-					// stop current timer
+				if ((port->partner_oper.port_state &
+				     AD_STATE_LACP_TIMEOUT)) {
+					/* stop current timer */
 					port->sm_periodic_timer_counter = 0;
-					port->sm_periodic_state = AD_PERIODIC_TX;	 // next state
+					port->sm_periodic_state = AD_PERIODIC_TX;
 				}
 				break;
-			default:    //to silence the compiler
+			default:
+				/* unexpected port->sm_sm_periodic_state */
+				pr_debug("Unexpected port->sm_periodic_state: %d\n",
+					 port->sm_periodic_state);
 				break;
 			}
 		}
 	} else {
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
-			port->sm_periodic_state = AD_FAST_PERIODIC;	 // next state
+			port->sm_periodic_state = AD_FAST_PERIODIC;
 			break;
 		case AD_PERIODIC_TX:
-			if (!(port->partner_oper.port_state
-			      & AD_STATE_LACP_TIMEOUT))
-				port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
+			if (!(port->partner_oper.port_state &
+			      AD_STATE_LACP_TIMEOUT))
+				port->sm_periodic_state = AD_SLOW_PERIODIC;
 			else
-				port->sm_periodic_state = AD_FAST_PERIODIC;  // next state
+				port->sm_periodic_state = AD_FAST_PERIODIC;
 			break;
-		default:    //to silence the compiler
+		default:
+			/* unexpected port->sm_sm_periodic_state */
+			pr_debug("Unexpected port->sm_periodic_state: %d\n",
+				 port->sm_periodic_state);
 			break;
 		}
 	}
 
-	// check if the state machine was changed
+	/* check if the state machine was changed */
 	if (port->sm_periodic_state != last_state) {
 		pr_debug("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
 			 port->sm_periodic_state);
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
-			port->sm_periodic_timer_counter = 0;	   // zero timer
+			port->sm_periodic_timer_counter = 0;
 			break;
 		case AD_FAST_PERIODIC:
-			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_FAST_PERIODIC_TIME))-1; // decrement 1 tick we lost in the PERIODIC_TX cycle
+			/* decrement 1 tick we lost in PERIODIC_TX cycle */
+			port->sm_periodic_timer_counter =
+					__ad_timer_to_ticks(AD_PERIODIC_TIMER,
+						(u16)(AD_FAST_PERIODIC_TIME))-1;
 			break;
 		case AD_SLOW_PERIODIC:
-			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_SLOW_PERIODIC_TIME))-1; // decrement 1 tick we lost in the PERIODIC_TX cycle
+			/* decrement 1 tick we lost in PERIODIC_TX cycle */
+			port->sm_periodic_timer_counter =
+					__ad_timer_to_ticks(AD_PERIODIC_TIMER,
+						(u16)(AD_SLOW_PERIODIC_TIME))-1;
 			break;
 		case AD_PERIODIC_TX:
 			port->ntt = true;
 			break;
-		default:    //to silence the compiler
+		default:
+			/* unexpected port->sm_sm_periodic_state */
+			pr_debug("Unexpected port->sm_periodic_state: %d\n",
+				 port->sm_periodic_state);
 			break;
 		}
 	}
@@ -1272,46 +1331,58 @@ static void ad_periodic_machine(struct port *port)
  */
 static void ad_port_selection_logic(struct port *port)
 {
-	struct aggregator *aggregator, *free_aggregator = NULL, *temp_aggregator;
+	struct aggregator *aggregator, *temp_aggregator;
+	struct aggregator *free_aggregator = NULL;
 	struct port *last_port = NULL, *curr_port;
 	int found = 0;
 
-	// if the port is already Selected, do nothing
+	/* if the port is already Selected, do nothing */
 	if (port->sm_vars & AD_PORT_SELECTED)
 		return;
 
-	// if the port is connected to other aggregator, detach it
+	/* if the port is connected to other aggregator, detach it */
 	if (port->aggregator) {
-		// detach the port from its former aggregator
+		/* detach the port from its former aggregator */
 		temp_aggregator = port->aggregator;
 		for (curr_port = temp_aggregator->lag_ports; curr_port;
 		     last_port = curr_port,
 			     curr_port = curr_port->next_port_in_aggregator) {
 			if (curr_port == port) {
 				temp_aggregator->num_of_ports--;
-				if (!last_port) {// if it is the first port attached to the aggregator
+				if (!last_port) {
+					/* if it is the first port attached
+					   to the aggregator */
 					temp_aggregator->lag_ports =
 						port->next_port_in_aggregator;
-				} else {// not the first port attached to the aggregator
+				} else {
+					/* not the first port attached
+					   to the aggregator */
 					last_port->next_port_in_aggregator =
 						port->next_port_in_aggregator;
 				}
 
-				// clear the port's relations to this aggregator
+				/* clear the port's relations
+				   to this aggregator */
 				port->aggregator = NULL;
 				port->next_port_in_aggregator = NULL;
 				port->actor_port_aggregator_identifier = 0;
 
 				pr_debug("Port %d left LAG %d\n",
-					 port->actor_port_number,
-					 temp_aggregator->aggregator_identifier);
-				// if the aggregator is empty, clear its parameters, and set it ready to be attached
+					port->actor_port_number,
+					temp_aggregator->aggregator_identifier);
+				/* if the aggregator is empty,
+				 * clear its parameters, and set it ready
+				 * to be attached
+				 */
 				if (!temp_aggregator->lag_ports)
 					ad_clear_agg(temp_aggregator);
 				break;
 			}
 		}
-		if (!curr_port) { // meaning: the port was related to an aggregator but was not on the aggregator port list
+		if (!curr_port) {
+			/* meaning: the port was related to an aggregator
+			 * but was not on the aggregator port list.
+			 */
 			pr_warning("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
 				   port->slave->dev->master->name,
 				   port->actor_port_number,
@@ -1319,27 +1390,34 @@ static void ad_port_selection_logic(struct port *port)
 				   port->aggregator->aggregator_identifier);
 		}
 	}
-	// search on all aggregators for a suitable aggregator for this port
+	/* search on all aggregators for a suitable aggregator for this port */
 	for (aggregator = __get_first_agg(port); aggregator;
 	     aggregator = __get_next_agg(aggregator)) {
 
-		// keep a free aggregator for later use(if needed)
+		/* keep a free aggregator for later use (if needed) */
 		if (!aggregator->lag_ports) {
 			if (!free_aggregator)
 				free_aggregator = aggregator;
 			continue;
 		}
-		// check if current aggregator suits us
-		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
-		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
+
+		/* check if current aggregator suits us
+		 * a suitable aggregator must fit the following requirements,
+		 * tested here:
+		 *   i. match all parameters;
+		 *  ii. has partner answers;
+		 * iii. it is not individual
+		 */
+		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) &&
+		     !compare_ether_addr((const u8 *)&(aggregator->partner_system), (const u8 *)&(port->partner_oper.system)) &&
 		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
 		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
 		    ) &&
-		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
-		      !aggregator->is_individual)  // but is not individual OR
+		    ((compare_ether_addr((const u8 *)&(port->partner_oper.system), (const u8 *)&(null_mac_addr)) &&
+		      !aggregator->is_individual)
 		    )
 		   ) {
-			// attach to the founded aggregator
+			/* attach to the founded aggregator */
 			port->aggregator = aggregator;
 			port->actor_port_aggregator_identifier =
 				port->aggregator->aggregator_identifier;
@@ -1350,42 +1428,45 @@ static void ad_port_selection_logic(struct port *port)
 				 port->actor_port_number,
 				 port->aggregator->aggregator_identifier);
 
-			// mark this port as selected
+			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
 			found = 1;
 			break;
 		}
 	}
 
-	// the port couldn't find an aggregator - attach it to a new aggregator
+	/* the port couldn't find an aggregator, attach it to a new aggregator*/
 	if (!found) {
 		if (free_aggregator) {
-			// assign port a new aggregator
+			/* assign port a new aggregator */
 			port->aggregator = free_aggregator;
 			port->actor_port_aggregator_identifier =
 				port->aggregator->aggregator_identifier;
 
-			// update the new aggregator's parameters
-			// if port was responsed from the end-user
+			/* update the new aggregator's parameters
+			   if port was replied from the end-user */
 			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)
 				/* if port is full duplex */
 				port->aggregator->is_individual = false;
 			else
 				port->aggregator->is_individual = true;
 
-			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
-			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
+			port->aggregator->actor_admin_aggregator_key =
+						port->actor_admin_port_key;
+			port->aggregator->actor_oper_aggregator_key =
+						port->actor_oper_port_key;
 			port->aggregator->partner_system =
-				port->partner_oper.system;
+						port->partner_oper.system;
 			port->aggregator->partner_system_priority =
-				port->partner_oper.system_priority;
-			port->aggregator->partner_oper_aggregator_key = port->partner_oper.key;
+					port->partner_oper.system_priority;
+			port->aggregator->partner_oper_aggregator_key =
+						port->partner_oper.key;
 			port->aggregator->receive_state = 1;
 			port->aggregator->transmit_state = 1;
 			port->aggregator->lag_ports = port;
 			port->aggregator->num_of_ports++;
 
-			// mark this port as selected
+			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
 
 			pr_debug("Port %d joined LAG %d(new LAG)\n",
@@ -1397,16 +1478,18 @@ static void ad_port_selection_logic(struct port *port)
 			       port->actor_port_number, port->slave->dev->name);
 		}
 	}
-	// if all aggregator's ports are READY_N == TRUE, set ready=TRUE in all aggregator's ports
-	// else set ready=FALSE in all aggregator's ports
-	__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
+	/* if all aggregator's ports are READY_N == TRUE,
+	 * set ready=TRUE in all aggregator's ports
+	 * else set ready=FALSE in all aggregator's ports
+	 */
+	__set_agg_ports_ready(port->aggregator,
+				__agg_ports_are_ready(port->aggregator));
 
 	aggregator = __get_first_agg(port);
 	ad_agg_selection_logic(aggregator);
 }
 
-/*
- * Decide if "agg" is a better choice for the new active aggregator that
+/* Decide if "agg" is a better choice for the new active aggregator that
  * the current best, according to the ad_select policy.
  */
 static struct aggregator *ad_agg_selection_test(struct aggregator *best,
@@ -1531,18 +1614,16 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 
 	if (best &&
 	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
-		/*
-		 * For the STABLE policy, don't replace the old active
-		 * aggregator if it's still active (it has an answering
-		 * partner) or if both the best and active don't have an
-		 * answering partner.
+
+		/* For the STABLE policy, don't replace the old active
+		 * aggregator if it's still active (it has an answering partner)
+		 * or if both the best and active don't have answering partners
 		 */
 		if (active && active->lag_ports &&
 		    active->lag_ports->is_enabled &&
-		    (__agg_has_partner(active) ||
-		     (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
-			if (!(!active->actor_oper_aggregator_key &&
-			      best->actor_oper_aggregator_key)) {
+		    (__agg_has_partner(active) || !__agg_has_partner(best))) {
+			if (active->actor_oper_aggregator_key ||
+			    !best->actor_oper_aggregator_key) {
 				best = NULL;
 				active->is_active = 1;
 			}
@@ -1554,7 +1635,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		active->is_active = 1;
 	}
 
-	// if there is new best aggregator, activate it
+	/* if there is new best aggregator, activate it */
 	if (best) {
 		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 			 best->aggregator_identifier, best->num_of_ports,
@@ -1575,7 +1656,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 				 agg->is_individual, agg->is_active);
 		}
 
-		// check if any partner replys
+		/* check if any partner replies */
 		if (best->is_individual) {
 			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
 				   best->slave ? best->slave->dev->master->name : "NULL");
@@ -1590,7 +1671,9 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->partner_oper_aggregator_key,
 			 best->is_individual, best->is_active);
 
-		// disable the ports that were related to the former active_aggregator
+		/* disable the ports that were related to
+		 * the former active_aggregator
+		 */
 		if (active) {
 			for (port = active->lag_ports; port;
 			     port = port->next_port_in_aggregator) {
@@ -1599,8 +1682,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 	}
 
-	/*
-	 * if the selected aggregator is of join individuals
+	/* if the selected aggregator is of join individuals
 	 * (partner_system is NULL), enable their ports
 	 */
 	active = __get_active_agg(origin);
@@ -1699,8 +1781,10 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		port->ntt = false;
 		port->actor_admin_port_key = 1;
 		port->actor_oper_port_key  = 1;
-		port->actor_admin_port_state = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
-		port->actor_oper_port_state  = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
+		port->actor_admin_port_state =
+				AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
+		port->actor_oper_port_state  =
+				AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
 
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
@@ -1709,7 +1793,7 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		memcpy(&port->partner_oper, &tmpl, sizeof(tmpl));
 
 		port->is_enabled = true;
-		// ****** private parameters ******
+		/* ****** private parameters ****** */
 		port->sm_vars = 0x3;
 		port->sm_rx_state = 0;
 		port->sm_rx_timer_counter = 0;
@@ -1751,7 +1835,9 @@ static void ad_enable_collecting_distributing(struct port *port)
  */
 static void ad_disable_collecting_distributing(struct port *port)
 {
-	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
+	if (port->aggregator &&
+	    compare_ether_addr((const u8 *)&(port->aggregator->partner_system),
+	     (const u8 *)&(null_mac_addr))) {
 		pr_debug("Disabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
@@ -1773,27 +1859,28 @@ static void ad_marker_info_send(struct port *port)
 	struct bond_marker marker;
 	u16 index;
 
-	// fill the marker PDU with the appropriate values
+	/* fill the marker PDU with the appropriate values */
 	marker.subtype = 0x02;
 	marker.version_number = 0x01;
 	marker.tlv_type = AD_MARKER_INFORMATION_SUBTYPE;
 	marker.marker_length = 0x16;
-	// convert requester_port to Big Endian
-	marker.requester_port = (((port->actor_port_number & 0xFF) << 8) |((u16)(port->actor_port_number & 0xFF00) >> 8));
+	/* convert requester_port to Big Endian */
+	marker.requester_port = (((port->actor_port_number & 0xFF) << 8) |
+				((u16)(port->actor_port_number & 0xFF00) >> 8));
 	marker.requester_system = port->actor_system;
-	// convert requester_port(u32) to Big Endian
+	/* convert requester_port(u32) to Big Endian */
 	marker.requester_transaction_id =
-		(((++port->transaction_id & 0xFF) << 24)
-		 | ((port->transaction_id & 0xFF00) << 8)
-		 | ((port->transaction_id & 0xFF0000) >> 8)
-		 | ((port->transaction_id & 0xFF000000) >> 24));
+		(((++port->transaction_id & 0xFF) << 24) |
+		  ((port->transaction_id & 0xFF00) << 8) |
+		  ((port->transaction_id & 0xFF0000) >> 8) |
+		  ((port->transaction_id & 0xFF000000) >> 24));
 	marker.pad = 0;
 	marker.tlv_type_terminator = 0x00;
 	marker.terminator_length = 0x00;
 	for (index = 0; index < 90; index++)
 		marker.reserved_90[index] = 0;
 
-	// send the marker information
+	/* send the marker information */
 	if (ad_marker_send(port, &marker) >= 0) {
 		pr_debug("Sent Marker Information on port %d\n",
 			 port->actor_port_number);
@@ -1812,12 +1899,13 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 {
 	struct bond_marker marker;
 
-	// copy the received marker data to the response marker
-	//marker = *marker_info;
+	/* copy the received marker data to the response marker
+	 * marker = *marker_info;
+	 */
 	memcpy(&marker, marker_info, sizeof(struct bond_marker));
-	// change the marker subtype to marker response
+	/* change the marker subtype to marker response */
 	marker.tlv_type = AD_MARKER_RESPONSE_SUBTYPE;
-	// send the marker response
+	/* send the marker response */
 
 	if (ad_marker_send(port, &marker) >= 0) {
 		pr_debug("Sent Marker Response on port %d\n",
@@ -1837,16 +1925,13 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 static void ad_marker_response_received(struct bond_marker *marker,
 	struct port *port)
 {
-	marker = NULL; /* just to satisfy the compiler */
-	port = NULL;  /* just to satisfy the compiler */
-	// DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW
+	marker = NULL;
+	port = NULL;
 }
 
-//////////////////////////////////////////////////////////////////////////////////////
-// ================= AD exported functions to the main bonding code ==================
-//////////////////////////////////////////////////////////////////////////////////////
+/* ============= AD exported functions to the main bonding code ============ */
 
-// Check aggregators status in team every T seconds
+/* Check aggregators status in team every T seconds */
 #define AD_AGGREGATOR_SELECTION_TIMER  8
 
 /*
@@ -1874,17 +1959,20 @@ static u16 aggregator_identifier;
  */
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast)
 {
-	// check that the bond is not initialized yet
-	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
+	/* check that the bond is not initialized yet */
+	if (compare_ether_addr((const u8 *)&(BOND_AD_INFO(bond).system.sys_mac_addr),
 				bond->dev->dev_addr)) {
 
 		aggregator_identifier = 0;
 
 		BOND_AD_INFO(bond).lacp_fast = lacp_fast;
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
-		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
+		BOND_AD_INFO(bond).system.sys_mac_addr =
+				      *((struct mac_addr *)bond->dev->dev_addr);
 
-		// initialize how many times this module is called in one second(should be about every 100ms)
+		/* initialize how many times this module is
+		 * called in one second(should be about every 100ms)
+		 */
 		ad_ticks_per_sec = tick_resolution;
 
 		bond_3ad_initiate_agg_selection(bond,
@@ -1912,31 +2000,37 @@ int bond_3ad_bind_slave(struct slave *slave)
 		return -1;
 	}
 
-	//check that the slave has not been initialized yet.
+	/* check that the slave has not been initialized yet. */
 	if (SLAVE_AD_INFO(slave).port.slave != slave) {
 
-		// port initialization
+		/* port initialization */
 		port = &(SLAVE_AD_INFO(slave).port);
 
 		ad_initialize_port(port, BOND_AD_INFO(bond).lacp_fast);
 
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
-		// key is determined according to the link speed, duplex and user key(which is yet not supported)
-		//              ------------------------------------------------------------
-		// Port key :   | User key                       |      Speed       |Duplex|
-		//              ------------------------------------------------------------
-		//              16                               6               1 0
-		port->actor_admin_port_key = 0;	// initialize this parameter
+		/* key is determined according to the link speed,
+		 * duplex and user key(which is yet not supported)
+		 * Port key:
+		 * ------------------------------------------------------------
+		 * | User key                       |      Speed       |Duplex|
+		 * ------------------------------------------------------------
+		 * 16                               6                  1      0
+		 */
+		port->actor_admin_port_key = 0;	/* initialize this parameter */
 		port->actor_admin_port_key |= __get_duplex(port);
 		port->actor_admin_port_key |= (__get_link_speed(port) << 1);
 		port->actor_oper_port_key = port->actor_admin_port_key;
-		// if the port is not full duplex, then the port should be not lacp Enabled
+		/* if the port is not full duplex,
+		 * then the port should be not lacp Enabled
+		 */
 		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
-		// actor system is the bond's system
+		/* actor system is the bond's system */
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
-		// tx timer(to verify that no more than MAX_TX_IN_SECOND lacpdu's are sent in one second)
+
+		/* certify that no more than MAX_TX_IN_SECOND lacpdu sent/sec */
 		port->sm_tx_timer_counter = ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 		port->aggregator = NULL;
 		port->next_port_in_aggregator = NULL;
@@ -1945,12 +2039,13 @@ int bond_3ad_bind_slave(struct slave *slave)
 		__initialize_port_locks(port);
 
 
-		// aggregator initialization
+		/* aggregator initialization */
 		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
 
 		ad_initialize_agg(aggregator);
 
-		aggregator->aggregator_mac_address = *((struct mac_addr *)bond->dev->dev_addr);
+		aggregator->aggregator_mac_address =
+				      *((struct mac_addr *)bond->dev->dev_addr);
 		aggregator->aggregator_identifier = (++aggregator_identifier);
 		aggregator->slave = slave;
 		aggregator->is_active = 0;
@@ -1974,13 +2069,13 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct aggregator *aggregator, *new_aggregator, *temp_aggregator;
 	int select_new_active_agg = 0;
 
-	// find the aggregator related to this slave
+	/* find the aggregator related to this slave */
 	aggregator = &(SLAVE_AD_INFO(slave).aggregator);
 
-	// find the port related to this slave
+	/* find the port related to this slave */
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: Trying to unbind an uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
@@ -1995,32 +2090,43 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	__update_lacpdu_from_port(port);
 	ad_lacpdu_send(port);
 
-	// check if this aggregator is occupied
+	/* check if this aggregator is occupied */
 	if (aggregator->lag_ports) {
-		// check if there are other ports related to this aggregator except
-		// the port related to this slave(thats ensure us that there is a
-		// reason to search for new aggregator, and that we will find one
-		if ((aggregator->lag_ports != port) || (aggregator->lag_ports->next_port_in_aggregator)) {
-			// find new aggregator for the related port(s)
+		/* check if there are other ports related to this aggregator
+		 * except the port related to this slave
+		 * (it ensures us that there is a reason to search for
+		 *  new aggregator, and that we will find one)
+		 */
+		if ((aggregator->lag_ports != port) ||
+		    (aggregator->lag_ports->next_port_in_aggregator)) {
+			/* find new aggregator for the related port(s) */
 			new_aggregator = __get_first_agg(port);
-			for (; new_aggregator; new_aggregator = __get_next_agg(new_aggregator)) {
-				// if the new aggregator is empty, or it is connected to our port only
-				if (!new_aggregator->lag_ports
-				    || ((new_aggregator->lag_ports == port)
-					&& !new_aggregator->lag_ports->next_port_in_aggregator))
+			for (; new_aggregator;
+			     new_aggregator = __get_next_agg(new_aggregator)) {
+				/* if the new aggregator is empty,
+				   or it is connected to our port only */
+				if (!new_aggregator->lag_ports ||
+				    ((new_aggregator->lag_ports == port) &&
+				     !new_aggregator->lag_ports->next_port_in_aggregator))
 					break;
 			}
-			// if new aggregator found, copy the aggregator's parameters
-			// and connect the related lag_ports to the new aggregator
-			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
-				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n",
+			/* if new aggregator found, copy the aggregator's
+			 * parameters and connect the related lag_ports to the
+			 * new aggregator
+			 */
+			if ((new_aggregator) &&
+			    ((!new_aggregator->lag_ports) ||
+			     ((new_aggregator->lag_ports == port) &&
+			      !new_aggregator->lag_ports->next_port_in_aggregator))) {
+				pr_debug("Some port(s) related to LAG %d - replacing with LAG %d\n",
 					 aggregator->aggregator_identifier,
 					 new_aggregator->aggregator_identifier);
 
-				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
+				if ((new_aggregator->lag_ports == port) &&
+				     new_aggregator->is_active) {
 					pr_info("%s: Removing an active aggregator\n",
 						aggregator->slave->dev->master->name);
-					// select new active aggregator
+					/* select new active aggregator */
 					 select_new_active_agg = 1;
 				}
 
@@ -2036,14 +2142,15 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				new_aggregator->is_active = aggregator->is_active;
 				new_aggregator->num_of_ports = aggregator->num_of_ports;
 
-				// update the information that is written on the ports about the aggregator
-				for (temp_port = aggregator->lag_ports; temp_port;
-				     temp_port = temp_port->next_port_in_aggregator) {
+				/* update the information that is written on
+				 * the ports about the aggregator
+				 */
+				for (temp_port = aggregator->lag_ports; temp_port; temp_port = temp_port->next_port_in_aggregator) {
 					temp_port->aggregator = new_aggregator;
 					temp_port->actor_port_aggregator_identifier = new_aggregator->aggregator_identifier;
 				}
 
-				// clear the aggregator
+				/* clear the aggregator */
 				ad_clear_agg(aggregator);
 
 				if (select_new_active_agg)
@@ -2052,42 +2159,50 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				pr_warning("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
 					   slave->dev->master->name);
 			}
-		} else { // in case that the only port related to this aggregator is the one we want to remove
+		} else {
+			 /* in case that the only port related to this
+			  * aggregator is the one we want to remove
+			  */
 			select_new_active_agg = aggregator->is_active;
-			// clear the aggregator
+			/* clear the aggregator */
 			ad_clear_agg(aggregator);
 			if (select_new_active_agg) {
 				pr_info("%s: Removing an active aggregator\n",
 					slave->dev->master->name);
-				// select new active aggregator
+				/* select new active aggregator */
 				ad_agg_selection_logic(__get_first_agg(port));
 			}
 		}
 	}
 
 	pr_debug("Unbinding port %d\n", port->actor_port_number);
-	// find the aggregator that this port is connected to
+	/* find the aggregator that this port is connected to */
 	temp_aggregator = __get_first_agg(port);
-	for (; temp_aggregator; temp_aggregator = __get_next_agg(temp_aggregator)) {
+	for (; temp_aggregator;
+	     temp_aggregator = __get_next_agg(temp_aggregator)) {
 		prev_port = NULL;
-		// search the port in the aggregator's related ports
+		/* search the port in the aggregator's related ports */
 		for (temp_port = temp_aggregator->lag_ports; temp_port;
 		     prev_port = temp_port,
 			     temp_port = temp_port->next_port_in_aggregator) {
-			if (temp_port == port) { // the aggregator found - detach the port from this aggregator
+			if (temp_port == port) {
+				/* the aggregator found
+				   detach the port from this aggregator */
 				if (prev_port)
-					prev_port->next_port_in_aggregator = temp_port->next_port_in_aggregator;
+					prev_port->next_port_in_aggregator =
+					     temp_port->next_port_in_aggregator;
 				else
-					temp_aggregator->lag_ports = temp_port->next_port_in_aggregator;
+					temp_aggregator->lag_ports =
+					     temp_port->next_port_in_aggregator;
 				temp_aggregator->num_of_ports--;
 				if (temp_aggregator->num_of_ports == 0) {
 					select_new_active_agg = temp_aggregator->is_active;
-					// clear the aggregator
+					/* clear the aggregator */
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
 						pr_info("%s: Removing an active aggregator\n",
 							slave->dev->master->name);
-						// select new active aggregator
+						/* select new active aggreg */
 						ad_agg_selection_logic(__get_first_agg(port));
 					}
 				}
@@ -2123,13 +2238,14 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	if (bond->kill_timers)
 		goto out;
 
-	//check if there are any slaves
+	/* check if there are any slaves */
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
-	// check if agg_select_timer timer after initialize is timed out
-	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
-		// select the active aggregator for the bond
+	/* check if agg_select_timer timer after initialize is timed out */
+	if (BOND_AD_INFO(bond).agg_select_timer &&
+	    !(--BOND_AD_INFO(bond).agg_select_timer)) {
+		/* select the active aggregator for the bond */
 		if ((port = __get_first_port(bond))) {
 			if (!port->slave) {
 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
@@ -2143,17 +2259,18 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		bond_3ad_set_carrier(bond);
 	}
 
-	// for each port run the state machines
-	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
+	/* for each port run the state machines */
+	for (port = __get_first_port(bond); port;
+	     port = __get_next_port(port)) {
 		if (!port->slave) {
 			pr_warning("%s: Warning: Found an uninitialized port\n",
 				   bond->dev->name);
 			goto re_arm;
 		}
 
-		/* Lock around state machines to protect data accessed
-		 * by all (e.g., port->sm_vars).  ad_rx_machine may run
-		 * concurrently due to incoming LACPDU.
+		/* Lock around state machines to protect data accessed by all
+		 * (e.g., port->sm_vars).
+		 * ad_rx_machine may run concurrently due to incoming LACPDU.
 		 */
 		__get_state_machine_lock(port);
 
@@ -2163,7 +2280,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		ad_mux_machine(port);
 		ad_tx_machine(port);
 
-		// turn off the BEGIN bit, since we already handled it
+		/* turn off the BEGIN bit, since we already handled it */
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
 
@@ -2196,7 +2313,8 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 
 		if (!port->slave) {
 			pr_warning("%s: Warning: port of slave %s is uninitialized\n",
-				   slave->dev->name, slave->dev->master->name);
+				   slave->dev->name,
+				   slave->dev->master->name);
 			return;
 		}
 
@@ -2211,7 +2329,9 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 			break;
 
 		case AD_TYPE_MARKER:
-			// No need to convert fields to Little Endian since we don't use the marker's fields.
+			/* No need to convert fields to Little Endian
+			 *  since we don't use the marker's fields.
+			 */
 
 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
 			case AD_MARKER_INFORMATION_SUBTYPE:
@@ -2246,19 +2366,22 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: speed changed for uninitialized port on %s\n",
-			   slave->dev->master->name, slave->dev->name);
+			   slave->dev->master->name,
+			   slave->dev->name);
 		return;
 	}
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		(__get_link_speed(port) << 1);
+
 	pr_debug("Port %d changed speed\n", port->actor_port_number);
-	// there is no need to reselect a new aggregator, just signal the
-	// state machines to reinitialize
+	/* there is no need to reselect a new aggregator,
+	 * just signal the state machines to reinitialize
+	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 }
 
@@ -2274,7 +2397,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("%s: Warning: duplex changed for uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
@@ -2284,9 +2407,11 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		__get_duplex(port);
+
 	pr_debug("Port %d changed duplex\n", port->actor_port_number);
-	// there is no need to reselect a new aggregator, just signal the
-	// state machines to reinitialize
+	/* there is no need to reselect a new aggregator,
+	 * just signal the state machines to reinitialize
+	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 }
 
@@ -2303,15 +2428,18 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: link status changed for uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
-	// on link down we are zeroing duplex and speed since some of the adaptors(ce1000.lan) report full duplex/speed instead of N/A(duplex) / 0(speed)
-	// on link up we are forcing recheck on the duplex and speed since some of he adaptors(ce1000.lan) report
+	/* on link down we are zeroing duplex and speed
+	 * since some of the adapters (ce1000.lan) report full duplex/speed
+	 * instead of N/A (duplex) / 0(speed)
+	 * on link up we are forcing recheck on the duplex and speed
+	 */
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
@@ -2327,9 +2455,15 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
 					     ~AD_SPEED_KEY_BITS);
 	}
-	//BOND_PRINT_DBG(("Port %d changed link status to %s", port->actor_port_number, ((link == BOND_LINK_UP)?"UP":"DOWN")));
-	// there is no need to reselect a new aggregator, just signal the
-	// state machines to reinitialize
+
+	/* BOND_PRINT_DBG(("Port %d changed link status to %s",
+	 *		  port->actor_port_number,
+	 *		  ((link == BOND_LINK_UP)?"UP":"DOWN")));
+	 */
+
+	/* there is no need to reselect a new aggregator,
+	 * just signal the state machines to reinitialize
+	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 }
 
@@ -2385,7 +2519,8 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 		ad_info->ports = aggregator->num_of_ports;
 		ad_info->actor_key = aggregator->actor_oper_aggregator_key;
 		ad_info->partner_key = aggregator->partner_oper_aggregator_key;
-		memcpy(ad_info->partner_system, aggregator->partner_system.mac_addr_value, ETH_ALEN);
+		memcpy(ad_info->partner_system,
+			 aggregator->partner_system.mac_addr_value, ETH_ALEN);
 		return 0;
 	}
 
@@ -2432,7 +2567,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	if (slave_agg_no >= 0) {
 		pr_err("%s: Error: Couldn't find a slave to tx on for aggregator ID %d\n",
-		       dev->name, agg_id);
+			dev->name, agg_id);
 		goto out;
 	}
 
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 291dbd4..bc437c3 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -28,7 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
 
-// General definitions
+/* General definitions */
 #define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
 #define AD_TIMER_INTERVAL       100 /*msec*/
 
@@ -47,54 +47,54 @@ enum {
 	BOND_AD_COUNT = 2,
 };
 
-// rx machine states(43.4.11 in the 802.3ad standard)
+/* rx machine states (43.4.11 in the 802.3ad standard) */
 typedef enum {
 	AD_RX_DUMMY,
-	AD_RX_INITIALIZE,     // rx Machine
-	AD_RX_PORT_DISABLED,  // rx Machine
-	AD_RX_LACP_DISABLED,  // rx Machine
-	AD_RX_EXPIRED,	      // rx Machine
-	AD_RX_DEFAULTED,      // rx Machine
-	AD_RX_CURRENT	      // rx Machine
+	AD_RX_INITIALIZE,
+	AD_RX_PORT_DISABLED,
+	AD_RX_LACP_DISABLED,
+	AD_RX_EXPIRED,
+	AD_RX_DEFAULTED,
+	AD_RX_CURRENT
 } rx_states_t;
 
-// periodic machine states(43.4.12 in the 802.3ad standard)
+/* periodic machine states (43.4.12 in the 802.3ad standard) */
 typedef enum {
 	AD_PERIODIC_DUMMY,
-	AD_NO_PERIODIC,	       // periodic machine
-	AD_FAST_PERIODIC,      // periodic machine
-	AD_SLOW_PERIODIC,      // periodic machine
-	AD_PERIODIC_TX	   // periodic machine
+	AD_NO_PERIODIC,
+	AD_FAST_PERIODIC,
+	AD_SLOW_PERIODIC,
+	AD_PERIODIC_TX
 } periodic_states_t;
 
-// mux machine states(43.4.13 in the 802.3ad standard)
+/* mux machine states (43.4.13 in the 802.3ad standard) */
 typedef enum {
 	AD_MUX_DUMMY,
-	AD_MUX_DETACHED,       // mux machine
-	AD_MUX_WAITING,	       // mux machine
-	AD_MUX_ATTACHED,       // mux machine
-	AD_MUX_COLLECTING_DISTRIBUTING // mux machine
+	AD_MUX_DETACHED,
+	AD_MUX_WAITING,
+	AD_MUX_ATTACHED,
+	AD_MUX_COLLECTING_DISTRIBUTING
 } mux_states_t;
 
-// tx machine states(43.4.15 in the 802.3ad standard)
+/* tx machine states (43.4.15 in the 802.3ad standard) */
 typedef enum {
 	AD_TX_DUMMY,
-	AD_TRANSMIT	   // tx Machine
+	AD_TRANSMIT
 } tx_states_t;
 
-// rx indication types
+/* rx indication types */
 typedef enum {
-	AD_TYPE_LACPDU = 1,    // type lacpdu
-	AD_TYPE_MARKER	   // type marker
+	AD_TYPE_LACPDU = 1,
+	AD_TYPE_MARKER
 } pdu_type_t;
 
-// rx marker indication types
+/* rx marker indication types */
 typedef enum {
-	AD_MARKER_INFORMATION_SUBTYPE = 1, // marker imformation subtype
-	AD_MARKER_RESPONSE_SUBTYPE     // marker response subtype
+	AD_MARKER_INFORMATION_SUBTYPE = 1,
+	AD_MARKER_RESPONSE_SUBTYPE
 } bond_marker_subtype_t;
 
-// timers types(43.4.9 in the 802.3ad standard)
+/* timers types (43.4.9 in the 802.3ad standard) */
 typedef enum {
 	AD_CURRENT_WHILE_TIMER,
 	AD_ACTOR_CHURN_TIMER,
@@ -105,35 +105,37 @@ typedef enum {
 
 #pragma pack(1)
 
-// Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard)
+/* Link Aggregation Control Protocol (LACP) data unit structure
+ * (43.4.2.2 in the 802.3ad standard)
+ */
 typedef struct lacpdu {
-	u8 subtype;		     // = LACP(= 0x01)
+	u8 subtype;		          /* = LACP(= 0x01) */
 	u8 version_number;
-	u8 tlv_type_actor_info;	      // = actor information(type/length/value)
-	u8 actor_information_length; // = 20
+	u8 tlv_type_actor_info;	          /* = actor info(type/length/value)*/
+	u8 actor_information_length;      /* = 20 */
 	__be16 actor_system_priority;
 	struct mac_addr actor_system;
 	__be16 actor_key;
 	__be16 actor_port_priority;
 	__be16 actor_port;
 	u8 actor_state;
-	u8 reserved_3_1[3];	     // = 0
-	u8 tlv_type_partner_info;     // = partner information
-	u8 partner_information_length;	 // = 20
+	u8 reserved_3_1[3];	          /* = 0 */
+	u8 tlv_type_partner_info;         /* = partner information */
+	u8 partner_information_length;	  /* = 20 */
 	__be16 partner_system_priority;
 	struct mac_addr partner_system;
 	__be16 partner_key;
 	__be16 partner_port_priority;
 	__be16 partner_port;
 	u8 partner_state;
-	u8 reserved_3_2[3];	     // = 0
-	u8 tlv_type_collector_info;	  // = collector information
-	u8 collector_information_length; // = 16
+	u8 reserved_3_2[3];	          /* = 0 */
+	u8 tlv_type_collector_info;	  /* = collector information */
+	u8 collector_information_length;  /* = 16 */
 	__be16 collector_max_delay;
 	u8 reserved_12[12];
-	u8 tlv_type_terminator;	     // = terminator
-	u8 terminator_length;	     // = 0
-	u8 reserved_50[50];	     // = 0
+	u8 tlv_type_terminator;	          /* = terminator */
+	u8 terminator_length;	          /* = 0 */
+	u8 reserved_50[50];	          /* = 0 */
 } lacpdu_t;
 
 typedef struct lacpdu_header {
@@ -141,20 +143,22 @@ typedef struct lacpdu_header {
 	struct lacpdu lacpdu;
 } lacpdu_header_t;
 
-// Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard)
+/* Marker Protocol Data Unit(PDU) structure
+ * (43.5.3.2 in the 802.3ad standard)
+ */
 typedef struct bond_marker {
-	u8 subtype;		 //  = 0x02  (marker PDU)
-	u8 version_number;	 //  = 0x01
-	u8 tlv_type;		 //  = 0x01  (marker information)
-	//  = 0x02  (marker response information)
-	u8 marker_length;	 //  = 0x16
-	u16 requester_port;	 //   The number assigned to the port by the requester
-	struct mac_addr requester_system;      //   The requester's system id
-	u32 requester_transaction_id;	//   The transaction id allocated by the requester,
-	u16 pad;		 //  = 0
-	u8 tlv_type_terminator;	     //  = 0x00
-	u8 terminator_length;	     //  = 0x00
-	u8 reserved_90[90];	     //  = 0
+	u8 subtype;			  /* = 0x02 (marker PDU) */
+	u8 version_number;		  /* = 0x01 */
+	u8 tlv_type;			  /* = 0x01 (marker information)
+					   * = 0x02  (marker response info */
+	u8 marker_length;		  /* = 0x16 */
+	u16 requester_port;
+	struct mac_addr requester_system; /* The requester's system id */
+	u32 requester_transaction_id;
+	u16 pad;			  /* = 0 */
+	u8 tlv_type_terminator;		  /* = 0x00 */
+	u8 terminator_length;		  /* = 0x00 */
+	u8 reserved_90[90];		  /* = 0 */
 } bond_marker_t;
 
 typedef struct bond_marker_header {
@@ -173,7 +177,7 @@ struct port;
 #pragma pack(8)
 #endif
 
-// aggregator structure(43.4.5 in the 802.3ad standard)
+/* aggregator structure (43.4.5 in the 802.3ad standard) */
 typedef struct aggregator {
 	struct mac_addr aggregator_mac_address;
 	u16 aggregator_identifier;
@@ -183,12 +187,13 @@ typedef struct aggregator {
 	struct mac_addr partner_system;
 	u16 partner_system_priority;
 	u16 partner_oper_aggregator_key;
-	u16 receive_state;		// BOOLEAN
-	u16 transmit_state;		// BOOLEAN
+	u16 receive_state;		/* BOOLEAN */
+	u16 transmit_state;		/* BOOLEAN */
 	struct port *lag_ports;
-	// ****** PRIVATE PARAMETERS ******
-	struct slave *slave;	    // pointer to the bond slave that this aggregator belongs to
-	u16 is_active;	    // BOOLEAN. Indicates if this aggregator is active
+	/* ****** PRIVATE PARAMETERS ****** */
+	struct slave *slave; /* pointer to the bond slave
+				that this aggregator belongs to */
+	u16 is_active;	     /* BOOLEAN. Indicates if the aggregator is active*/
 	u16 num_of_ports;
 } aggregator_t;
 
@@ -201,12 +206,18 @@ struct port_params {
 	u16 port_state;
 };
 
-// port structure(43.4.6 in the 802.3ad standard)
+/* port structure (43.4.6 in the 802.3ad standard) */
 typedef struct port {
 	u16 actor_port_number;
 	u16 actor_port_priority;
-	struct mac_addr actor_system;	       // This parameter is added here although it is not specified in the standard, just for simplification
-	u16 actor_system_priority;	 // This parameter is added here although it is not specified in the standard, just for simplification
+
+	/* in a attempt to simplify operations the
+	 * following two elements were included here
+	 * despite they are not specified in the standard
+	 */
+	struct mac_addr actor_system;
+	u16 actor_system_priority;
+
 	u16 actor_port_aggregator_identifier;
 	bool ntt;
 	u16 actor_admin_port_key;
@@ -219,21 +230,21 @@ typedef struct port {
 
 	bool is_enabled;
 
-	// ****** PRIVATE PARAMETERS ******
-	u16 sm_vars;	      // all state machines variables for this port
-	rx_states_t sm_rx_state;	// state machine rx state
-	u16 sm_rx_timer_counter;    // state machine rx timer counter
-	periodic_states_t sm_periodic_state;// state machine periodic state
-	u16 sm_periodic_timer_counter;	// state machine periodic timer counter
-	mux_states_t sm_mux_state;	// state machine mux state
-	u16 sm_mux_timer_counter;   // state machine mux timer counter
-	tx_states_t sm_tx_state;	// state machine tx state
-	u16 sm_tx_timer_counter;    // state machine tx timer counter(allways on - enter to transmit state 3 time per second)
-	struct slave *slave;	    // pointer to the bond slave that this port belongs to
-	struct aggregator *aggregator;	   // pointer to an aggregator that this port related to
-	struct port *next_port_in_aggregator; // Next port on the linked list of the parent aggregator
-	u32 transaction_id;	    // continuous number for identification of Marker PDU's;
-	struct lacpdu lacpdu;	       // the lacpdu that will be sent for this port
+	/* ****** PRIVATE PARAMETERS ****** */
+	u16 sm_vars;
+	rx_states_t sm_rx_state;
+	u16 sm_rx_timer_counter;
+	periodic_states_t sm_periodic_state;
+	u16 sm_periodic_timer_counter;
+	mux_states_t sm_mux_state;
+	u16 sm_mux_timer_counter;
+	tx_states_t sm_tx_state;
+	u16 sm_tx_timer_counter;
+	struct slave *slave;
+	struct aggregator *aggregator;
+	struct port *next_port_in_aggregator;
+	u32 transaction_id;
+	struct lacpdu lacpdu;
 } port_t;
 
 // system structure
@@ -246,30 +257,32 @@ struct ad_system {
 #pragma pack()
 #endif
 
-// ================= AD Exported structures to the main bonding code ==================
+/* ============ AD Exported structures to the main bonding code ============ */
 #define BOND_AD_INFO(bond)   ((bond)->ad_info)
 #define SLAVE_AD_INFO(slave) ((slave)->ad_info)
 
 struct ad_bond_info {
-	struct ad_system system;	    /* 802.3ad system structure */
-	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
-	u32 agg_select_mode;	    // Mode of selection of active aggregator(bandwidth/count)
-	int lacp_fast;		/* whether fast periodic tx should be
-				 * requested
-				 */
+	struct ad_system system;	/* 802.3ad system structure */
+	u32 agg_select_timer;		/* Timer to select aggregator after
+					   all adapter's hand shakes */
+	u32 agg_select_mode;		/* Selection mode of active aggregator
+					   (bandwidth/count) */
+	int lacp_fast;			/* whether fast periodic tx should be
+					   requested */
 	struct timer_list ad_timer;
 };
 
 struct ad_slave_info {
-	struct aggregator aggregator;	    // 802.3ad aggregator structure
-	struct port port;		    // 802.3ad port structure
-	spinlock_t state_machine_lock; /* mutex state machines vs.
+	struct aggregator aggregator;	/* 802.3ad aggregator structure */
+	struct port port;		/* 802.3ad port structure */
+	spinlock_t state_machine_lock;	/* mutex state machines vs.
 					  incoming LACPDU */
 	u16 id;
 };
 
-// ================= AD Exported functions to the main bonding code ==================
-void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
+// ============= AD Exported functions to the main bonding code ============ */
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution,
+			 int lacp_fast);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
@@ -277,7 +290,7 @@ void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
-int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
+int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
 void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
 			  struct slave *slave);
-- 
1.7.4.4


-- 
Rafael Aquini <aquini@linux.com>
