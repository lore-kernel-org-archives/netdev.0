From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 9/10] bonding: Don't mangle LACPDUs
Date: Fri, 22 Sep 2006 21:55:32 -0700
Message-ID: <200609230455.k8N4tWZt029427@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:13532 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751006AbWIWEze
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:55:34 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4tY8Q013712
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:55:34 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4tYmG255848
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:55:34 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4tX5T022756
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:55:34 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Fixed handling of 802.3ad LACPDUs.  Do not byte swap data in
place in the packet.  Updated nomenclature of "__ntohs_lacpdu" to be
"htons"; it was previously used for both ntohs and htons operations, but
only called ntohs functions.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c24b20a..3fb354d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -100,7 +100,7 @@ static u16 __get_link_speed(struct port 
 static u8 __get_duplex(struct port *port);
 static inline void __initialize_port_locks(struct port *port);
 //conversions
-static void __ntohs_lacpdu(struct lacpdu *lacpdu);
+static void __htons_lacpdu(struct lacpdu *lacpdu);
 static u16 __ad_timer_to_ticks(u16 timer_type, u16 Par);
 
 
@@ -420,23 +420,23 @@ static inline void __initialize_port_loc
 
 //conversions
 /**
- * __ntohs_lacpdu - convert the contents of a LACPDU to host byte order
+ * __htons_lacpdu - convert the contents of a LACPDU to network byte order
  * @lacpdu: the speicifed lacpdu
  *
  * For each multi-byte field in the lacpdu, convert its content
  */
-static void __ntohs_lacpdu(struct lacpdu *lacpdu)
+static void __htons_lacpdu(struct lacpdu *lacpdu)
 {
 	if (lacpdu) {
-		lacpdu->actor_system_priority =   ntohs(lacpdu->actor_system_priority);
-		lacpdu->actor_key =               ntohs(lacpdu->actor_key);
-		lacpdu->actor_port_priority =     ntohs(lacpdu->actor_port_priority);
-		lacpdu->actor_port =              ntohs(lacpdu->actor_port);
-		lacpdu->partner_system_priority = ntohs(lacpdu->partner_system_priority);
-		lacpdu->partner_key =             ntohs(lacpdu->partner_key);
-		lacpdu->partner_port_priority =   ntohs(lacpdu->partner_port_priority);
-		lacpdu->partner_port =            ntohs(lacpdu->partner_port);
-		lacpdu->collector_max_delay =     ntohs(lacpdu->collector_max_delay);
+		lacpdu->actor_system_priority =   htons(lacpdu->actor_system_priority);
+		lacpdu->actor_key =               htons(lacpdu->actor_key);
+		lacpdu->actor_port_priority =     htons(lacpdu->actor_port_priority);
+		lacpdu->actor_port =              htons(lacpdu->actor_port);
+		lacpdu->partner_system_priority = htons(lacpdu->partner_system_priority);
+		lacpdu->partner_key =             htons(lacpdu->partner_key);
+		lacpdu->partner_port_priority =   htons(lacpdu->partner_port_priority);
+		lacpdu->partner_port =            htons(lacpdu->partner_port);
+		lacpdu->collector_max_delay =     htons(lacpdu->collector_max_delay);
 	}
 }
 
@@ -496,11 +496,11 @@ static void __record_pdu(struct lacpdu *
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// record the new parameter values for the partner operational
-		port->partner_oper_port_number = lacpdu->actor_port;
-		port->partner_oper_port_priority = lacpdu->actor_port_priority;
+		port->partner_oper_port_number = ntohs(lacpdu->actor_port);
+		port->partner_oper_port_priority = ntohs(lacpdu->actor_port_priority);
 		port->partner_oper_system = lacpdu->actor_system;
-		port->partner_oper_system_priority = lacpdu->actor_system_priority;
-		port->partner_oper_key = lacpdu->actor_key;
+		port->partner_oper_system_priority = ntohs(lacpdu->actor_system_priority);
+		port->partner_oper_key = ntohs(lacpdu->actor_key);
 		// zero partener's lase states
 		port->partner_oper_port_state = 0;
 		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_LACP_ACTIVITY);
@@ -567,11 +567,11 @@ static void __update_selected(struct lac
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// check if any parameter is different
-		if ((lacpdu->actor_port != port->partner_oper_port_number) ||
-		    (lacpdu->actor_port_priority != port->partner_oper_port_priority) ||
+		if ((ntohs(lacpdu->actor_port) != port->partner_oper_port_number) ||
+		    (ntohs(lacpdu->actor_port_priority) != port->partner_oper_port_priority) ||
 		    MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->partner_oper_system)) ||
-		    (lacpdu->actor_system_priority != port->partner_oper_system_priority) ||
-		    (lacpdu->actor_key != port->partner_oper_key) ||
+		    (ntohs(lacpdu->actor_system_priority) != port->partner_oper_system_priority) ||
+		    (ntohs(lacpdu->actor_key) != port->partner_oper_key) ||
 		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) != (port->partner_oper_port_state & AD_STATE_AGGREGATION))
 		   ) {
 			// update the state machine Selected variable
@@ -634,11 +634,11 @@ static void __choose_matched(struct lacp
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// check if all parameters are alike
-		if (((lacpdu->partner_port == port->actor_port_number) &&
-		     (lacpdu->partner_port_priority == port->actor_port_priority) &&
+		if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
+		     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
 		     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
-		     (lacpdu->partner_system_priority == port->actor_system_priority) &&
-		     (lacpdu->partner_key == port->actor_oper_port_key) &&
+		     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
+		     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
 		     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
 		    // or this is individual link(aggregation == FALSE)
 		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
@@ -668,11 +668,11 @@ static void __update_ntt(struct lacpdu *
 	// validate lacpdu and port
 	if (lacpdu && port) {
 		// check if any parameter is different
-		if ((lacpdu->partner_port != port->actor_port_number) ||
-		    (lacpdu->partner_port_priority != port->actor_port_priority) ||
+		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
+		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
 		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
-		    (lacpdu->partner_system_priority != port->actor_system_priority) ||
-		    (lacpdu->partner_key != port->actor_oper_port_key) ||
+		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
+		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_TIMEOUT) != (port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT)) ||
 		    ((lacpdu->partner_state & AD_STATE_SYNCHRONIZATION) != (port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) ||
@@ -856,7 +856,7 @@ static inline void __update_lacpdu_from_
 	 */
 
 	/* Convert all non u8 parameters to Big Endian for transmit */
-	__ntohs_lacpdu(lacpdu);
+	__htons_lacpdu(lacpdu);
 }
 
 //////////////////////////////////////////////////////////////////////////////////////
@@ -2180,7 +2180,6 @@ static void bond_3ad_rx_indication(struc
 
 		switch (lacpdu->subtype) {
 		case AD_TYPE_LACPDU:
-			__ntohs_lacpdu(lacpdu);
 			dprintk("Received LACPDU on port %d\n", port->actor_port_number);
 			ad_rx_machine(lacpdu, port);
 			break;
