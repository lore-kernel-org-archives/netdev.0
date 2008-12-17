From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 2/9] bonding: introduce and use port_params structure
Date: Wed, 17 Dec 2008 22:28:29 +0100
Message-ID: <20081217213008.598744326@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52320 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbYLQVaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:16 -0500
Content-Disposition: inline; filename=bonding-3ad-add-port_params.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It generally helps to handle those values in various places, using it
might make the code more readable and gives room for other improvements.

The IEEE standard talks about them as "parameter values".

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -199,6 +199,15 @@ typedef struct aggregator {
 	u16 num_of_ports;
 } aggregator_t;
 
+struct port_params {
+	struct mac_addr system;
+	u16 system_priority;
+	u16 key;
+	u16 port_number;
+	u16 port_priority;
+	u16 port_state;
+};
+
 // port structure(43.4.6 in the 802.3ad standard)
 typedef struct port {
 	u16 actor_port_number;
@@ -211,18 +220,10 @@ typedef struct port {
 	u16 actor_oper_port_key;
 	u8 actor_admin_port_state;
 	u8 actor_oper_port_state;
-	struct mac_addr partner_admin_system;
-	struct mac_addr partner_oper_system;
-	u16 partner_admin_system_priority;
-	u16 partner_oper_system_priority;
-	u16 partner_admin_key;
-	u16 partner_oper_key;
-	u16 partner_admin_port_number;
-	u16 partner_oper_port_number;
-	u16 partner_admin_port_priority;
-	u16 partner_oper_port_priority;
-	u8 partner_admin_port_state;
-	u8 partner_oper_port_state;
+
+	struct port_params partner_admin;
+	struct port_params partner_oper;
+
 	u16 is_enabled;	      // BOOLEAN
 	// ****** PRIVATE PARAMETERS ******
 	u16 sm_vars;	      // all state machines variables for this port
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -486,21 +486,21 @@ static void __record_pdu(struct lacpdu *
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// record the new parameter values for the partner operational
-		port->partner_oper_port_number = ntohs(lacpdu->actor_port);
-		port->partner_oper_port_priority = ntohs(lacpdu->actor_port_priority);
-		port->partner_oper_system = lacpdu->actor_system;
-		port->partner_oper_system_priority = ntohs(lacpdu->actor_system_priority);
-		port->partner_oper_key = ntohs(lacpdu->actor_key);
-		port->partner_oper_port_state = lacpdu->actor_state;
+		port->partner_oper.port_number = ntohs(lacpdu->actor_port);
+		port->partner_oper.port_priority = ntohs(lacpdu->actor_port_priority);
+		port->partner_oper.system = lacpdu->actor_system;
+		port->partner_oper.system_priority = ntohs(lacpdu->actor_system_priority);
+		port->partner_oper.key = ntohs(lacpdu->actor_key);
+		port->partner_oper.port_state = lacpdu->actor_state;
 
 		// set actor_oper_port_state.defaulted to FALSE
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;
 
 		// set the partner sync. to on if the partner is sync. and the port is matched
 		if ((port->sm_vars & AD_PORT_MATCHED) && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
-			port->partner_oper_port_state |= AD_STATE_SYNCHRONIZATION;
+			port->partner_oper.port_state |= AD_STATE_SYNCHRONIZATION;
 		} else {
-			port->partner_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
+			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
 		}
 	}
 }
@@ -518,12 +518,12 @@ static void __record_default(struct port
 	// validate the port
 	if (port) {
 		// record the partner admin parameters
-		port->partner_oper_port_number = port->partner_admin_port_number;
-		port->partner_oper_port_priority = port->partner_admin_port_priority;
-		port->partner_oper_system = port->partner_admin_system;
-		port->partner_oper_system_priority = port->partner_admin_system_priority;
-		port->partner_oper_key = port->partner_admin_key;
-		port->partner_oper_port_state = port->partner_admin_port_state;
+		port->partner_oper.port_number = port->partner_admin.port_number;
+		port->partner_oper.port_priority = port->partner_admin.port_priority;
+		port->partner_oper.system = port->partner_admin.system;
+		port->partner_oper.system_priority = port->partner_admin.system_priority;
+		port->partner_oper.key = port->partner_admin.key;
+		port->partner_oper.port_state = port->partner_admin.port_state;
 
 		// set actor_oper_port_state.defaulted to true
 		port->actor_oper_port_state |= AD_STATE_DEFAULTED;
@@ -548,12 +548,12 @@ static void __update_selected(struct lac
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// check if any parameter is different
-		if ((ntohs(lacpdu->actor_port) != port->partner_oper_port_number) ||
-		    (ntohs(lacpdu->actor_port_priority) != port->partner_oper_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->partner_oper_system)) ||
-		    (ntohs(lacpdu->actor_system_priority) != port->partner_oper_system_priority) ||
-		    (ntohs(lacpdu->actor_key) != port->partner_oper_key) ||
-		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) != (port->partner_oper_port_state & AD_STATE_AGGREGATION))
+		if ((ntohs(lacpdu->actor_port) != port->partner_oper.port_number) ||
+		    (ntohs(lacpdu->actor_port_priority) != port->partner_oper.port_priority) ||
+		    MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->partner_oper.system)) ||
+		    (ntohs(lacpdu->actor_system_priority) != port->partner_oper.system_priority) ||
+		    (ntohs(lacpdu->actor_key) != port->partner_oper.key) ||
+		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) != (port->partner_oper.port_state & AD_STATE_AGGREGATION))
 		   ) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
@@ -578,12 +578,12 @@ static void __update_default_selected(st
 	// validate the port
 	if (port) {
 		// check if any parameter is different
-		if ((port->partner_admin_port_number != port->partner_oper_port_number) ||
-		    (port->partner_admin_port_priority != port->partner_oper_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(port->partner_admin_system), &(port->partner_oper_system)) ||
-		    (port->partner_admin_system_priority != port->partner_oper_system_priority) ||
-		    (port->partner_admin_key != port->partner_oper_key) ||
-		    ((port->partner_admin_port_state & AD_STATE_AGGREGATION) != (port->partner_oper_port_state & AD_STATE_AGGREGATION))
+		if ((port->partner_admin.port_number != port->partner_oper.port_number) ||
+		    (port->partner_admin.port_priority != port->partner_oper.port_priority) ||
+		    MAC_ADDRESS_COMPARE(&(port->partner_admin.system), &(port->partner_oper.system)) ||
+		    (port->partner_admin.system_priority != port->partner_oper.system_priority) ||
+		    (port->partner_admin.key != port->partner_oper.key) ||
+		    ((port->partner_admin.port_state & AD_STATE_AGGREGATION) != (port->partner_oper.port_state & AD_STATE_AGGREGATION))
 		   ) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
@@ -819,12 +819,12 @@ static inline void __update_lacpdu_from_
 	 * lacpdu->partner_information_length initialized
 	 */
 
-	lacpdu->partner_system_priority = htons(port->partner_oper_system_priority);
-	lacpdu->partner_system = port->partner_oper_system;
-	lacpdu->partner_key = htons(port->partner_oper_key);
-	lacpdu->partner_port_priority = htons(port->partner_oper_port_priority);
-	lacpdu->partner_port = htons(port->partner_oper_port_number);
-	lacpdu->partner_state = port->partner_oper_port_state;
+	lacpdu->partner_system_priority = htons(port->partner_oper.system_priority);
+	lacpdu->partner_system = port->partner_oper.system;
+	lacpdu->partner_key = htons(port->partner_oper.key);
+	lacpdu->partner_port_priority = htons(port->partner_oper.port_priority);
+	lacpdu->partner_port = htons(port->partner_oper.port_number);
+	lacpdu->partner_state = port->partner_oper.port_state;
 
 	/* lacpdu->reserved_3_2              initialized
 	 * lacpdu->tlv_type_collector_info   initialized
@@ -973,7 +973,7 @@ static void ad_mux_machine(struct port *
 			break;
 		case AD_MUX_ATTACHED:
 			// check also if agg_select_timer expired(so the edable port will take place only after this timer)
-			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper_port_state & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
+			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
 				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;// next state
 			} else if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY)) {	  // if UNSELECTED or STANDBY
 				port->sm_vars &= ~AD_PORT_READY_N;
@@ -985,7 +985,7 @@ static void ad_mux_machine(struct port *
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY) ||
-			    !(port->partner_oper_port_state & AD_STATE_SYNCHRONIZATION)
+			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)
 			   ) {
 				port->sm_mux_state = AD_MUX_ATTACHED;// next state
 
@@ -1129,7 +1129,7 @@ static void ad_rx_machine(struct lacpdu 
 		case AD_RX_LACP_DISABLED:
 			port->sm_vars &= ~AD_PORT_SELECTED;
 			__record_default(port);
-			port->partner_oper_port_state &= ~AD_STATE_AGGREGATION;
+			port->partner_oper.port_state &= ~AD_STATE_AGGREGATION;
 			port->sm_vars |= AD_PORT_MATCHED;
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
@@ -1137,9 +1137,9 @@ static void ad_rx_machine(struct lacpdu 
 			//Reset of the Synchronization flag. (Standard 43.4.12)
 			//This reset cause to disable this port in the COLLECTING_DISTRIBUTING state of the
 			//mux machine in case of EXPIRED even if LINK_DOWN didn't arrive for the port.
-			port->partner_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
+			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
 			port->sm_vars &= ~AD_PORT_MATCHED;
-			port->partner_oper_port_state |= AD_SHORT_TIMEOUT;
+			port->partner_oper.port_state |= AD_SHORT_TIMEOUT;
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
 			port->actor_oper_port_state |= AD_STATE_EXPIRED;
 			break;
@@ -1219,7 +1219,7 @@ static void ad_periodic_machine(struct p
 
 	// check if port was reinitialized
 	if (((port->sm_vars & AD_PORT_BEGIN) || !(port->sm_vars & AD_PORT_LACP_ENABLED) || !port->is_enabled) ||
-	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) && !(port->partner_oper_port_state & AD_STATE_LACP_ACTIVITY))
+	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) && !(port->partner_oper.port_state & AD_STATE_LACP_ACTIVITY))
 	   ) {
 		port->sm_periodic_state = AD_NO_PERIODIC;	     // next state
 	}
@@ -1233,12 +1233,12 @@ static void ad_periodic_machine(struct p
 			// If not expired, check if there is some new timeout parameter from the partner state
 			switch (port->sm_periodic_state) {
 			case AD_FAST_PERIODIC:
-				if (!(port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+				if (!(port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
 					port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
 				}
 				break;
 			case AD_SLOW_PERIODIC:
-				if ((port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+				if ((port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
 					// stop current timer
 					port->sm_periodic_timer_counter = 0;
 					port->sm_periodic_state = AD_PERIODIC_TX;	 // next state
@@ -1254,7 +1254,7 @@ static void ad_periodic_machine(struct p
 			port->sm_periodic_state = AD_FAST_PERIODIC;	 // next state
 			break;
 		case AD_PERIODIC_TX:
-			if (!(port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+			if (!(port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
 				port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
 			} else {
 				port->sm_periodic_state = AD_FAST_PERIODIC;  // next state
@@ -1353,11 +1353,11 @@ static void ad_port_selection_logic(stru
 		}
 		// check if current aggregator suits us
 		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
-		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper_system)) &&
-		     (aggregator->partner_system_priority == port->partner_oper_system_priority) &&
-		     (aggregator->partner_oper_aggregator_key == port->partner_oper_key)
+		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
+		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
+		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
 		    ) &&
-		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper_system), &(null_mac_addr)) && // partner answers
+		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
 		      !aggregator->is_individual)  // but is not individual OR
 		    )
 		   ) {
@@ -1393,9 +1393,9 @@ static void ad_port_selection_logic(stru
 
 			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
 			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
-			port->aggregator->partner_system=port->partner_oper_system;
-			port->aggregator->partner_system_priority = port->partner_oper_system_priority;
-			port->aggregator->partner_oper_aggregator_key = port->partner_oper_key;
+			port->aggregator->partner_system=port->partner_oper.system;
+			port->aggregator->partner_system_priority = port->partner_oper.system_priority;
+			port->aggregator->partner_oper_aggregator_key = port->partner_oper.key;
 			port->aggregator->receive_state = 1;
 			port->aggregator->transmit_state = 1;
 			port->aggregator->lag_ports = port;
@@ -1695,18 +1695,18 @@ static void ad_initialize_port(struct po
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
 		}
 
-		port->partner_admin_system = null_mac_addr;
-		port->partner_oper_system  = null_mac_addr;
-		port->partner_admin_system_priority = 0xffff;
-		port->partner_oper_system_priority  = 0xffff;
-		port->partner_admin_key = 1;
-		port->partner_oper_key  = 1;
-		port->partner_admin_port_number = 1;
-		port->partner_oper_port_number  = 1;
-		port->partner_admin_port_priority = 0xff;
-		port->partner_oper_port_priority  = 0xff;
-		port->partner_admin_port_state = 1;
-		port->partner_oper_port_state  = 1;
+		port->partner_admin.system = null_mac_addr;
+		port->partner_oper.system  = null_mac_addr;
+		port->partner_admin.system_priority = 0xffff;
+		port->partner_oper.system_priority  = 0xffff;
+		port->partner_admin.key = 1;
+		port->partner_oper.key  = 1;
+		port->partner_admin.port_number = 1;
+		port->partner_oper.port_number  = 1;
+		port->partner_admin.port_priority = 0xff;
+		port->partner_oper.port_priority  = 0xff;
+		port->partner_admin.port_state = 1;
+		port->partner_oper.port_state  = 1;
 		port->is_enabled = 1;
 		// ****** private parameters ******
 		port->sm_vars = 0x3;

-- 
