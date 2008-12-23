From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 01/10] 802.3ad: make ntt bool
Date: Tue, 23 Dec 2008 23:01:02 +0100
Message-ID: <20081223220551.162884495@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout-xforward.kundenserver.de ([212.227.17.4]:51466 "EHLO
	mout-xforward.kundenserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628AbYLWWF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:05:58 -0500
Content-Disposition: inline; filename=bonding-3ad-ntt-bool.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn Need-To-Transmit port variable into a bool.  There is no functional
change.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -215,7 +215,7 @@ typedef struct port {
 	struct mac_addr actor_system;	       // This parameter is added here although it is not specified in the standard, just for simplification
 	u16 actor_system_priority;	 // This parameter is added here although it is not specified in the standard, just for simplification
 	u16 actor_port_aggregator_identifier;
-	u16 ntt;			 // BOOLEAN
+	bool ntt;
 	u16 actor_admin_port_key;
 	u16 actor_oper_port_key;
 	u8 actor_admin_port_state;
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -629,8 +629,8 @@ static void __update_ntt(struct lacpdu *
 		    ((lacpdu->partner_state & AD_STATE_SYNCHRONIZATION) != (port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) ||
 		    ((lacpdu->partner_state & AD_STATE_AGGREGATION) != (port->actor_oper_port_state & AD_STATE_AGGREGATION))
 		   ) {
-			// set ntt to be TRUE
-			port->ntt = 1;
+
+			port->ntt = true;
 		}
 	}
 }
@@ -987,7 +987,7 @@ static void ad_mux_machine(struct port *
 			ad_disable_collecting_distributing(port);
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
-			port->ntt = 1;
+			port->ntt = true;
 			break;
 		case AD_MUX_WAITING:
 			port->sm_mux_timer_counter = __ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
@@ -998,13 +998,13 @@ static void ad_mux_machine(struct port *
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
 			ad_disable_collecting_distributing(port);
-			port->ntt = 1;
+			port->ntt = true;
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			port->actor_oper_port_state |= AD_STATE_COLLECTING;
 			port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
 			ad_enable_collecting_distributing(port);
-			port->ntt = 1;
+			port->ntt = true;
 			break;
 		default:    //to silence the compiler
 			break;
@@ -1163,11 +1163,13 @@ static void ad_tx_machine(struct port *p
 		// check if there is something to send
 		if (port->ntt && (port->sm_vars & AD_PORT_LACP_ENABLED)) {
 			__update_lacpdu_from_port(port);
-			// send the lacpdu
+
 			if (ad_lacpdu_send(port) >= 0) {
 				pr_debug("Sent LACPDU on port %d\n", port->actor_port_number);
-				// mark ntt as false, so it will not be sent again until demanded
-				port->ntt = 0;
+
+				/* mark ntt as false, so it will not be sent again until
+				   demanded */
+				port->ntt = false;
 			}
 		}
 		// restart tx timer(to verify that we will not exceed AD_MAX_TX_IN_SECOND
@@ -1250,7 +1252,7 @@ static void ad_periodic_machine(struct p
 			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_SLOW_PERIODIC_TIME))-1; // decrement 1 tick we lost in the PERIODIC_TX cycle
 			break;
 		case AD_PERIODIC_TX:
-			port->ntt = 1;
+			port->ntt = true;
 			break;
 		default:    //to silence the compiler
 			break;
@@ -1664,7 +1666,7 @@ static void ad_initialize_port(struct po
 		port->actor_system = null_mac_addr;
 		port->actor_system_priority = 0xffff;
 		port->actor_port_aggregator_identifier = 0;
-		port->ntt = 0;
+		port->ntt = false;
 		port->actor_admin_port_key = 1;
 		port->actor_oper_port_key  = 1;
 		port->actor_admin_port_state = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;

-- 
