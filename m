From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6] bonding: fix 802.3ad standards compliance error
Date: Fri, 13 Nov 2009 15:13:01 -0800
Message-ID: <3048.1258153981@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, martin@gear6.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38812 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199AbZKMXNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 18:13:06 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nADN6AUD015659
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:06:10 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nADNDBRS165446
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:13:11 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nADNDAai013911
	for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:13:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The language of 802.3ad 43.4.9 requires the "recordPDU" function
to, in part, compare the Partner parameter values in a received LACPDU
to the stored Actor values.  If those match, then the Partner's
synchronization state is set to true.

	The current 802.3ad implementation is performing these steps out
of order; first, the synchronization check is done, then the paramters are
checked to see if they match (the synch check being done against a match
check of a prior LACPDU).  This causes delays in establishing aggregators
in some circumstances.

	This patch modifies the 802.3ad code to call __choose_matched,
the function that does the "match" comparisions, as the first step of
__record_pdu, instead of immediately afterwards.  This new behavior is
in compliance with the language of the standard.

	Some additional commentary relating to code vs. standard is also
added.

	Reported by Martin Patterson <martin@gear6.com> who also supplied
the logic of the fix and verified the patch.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_3ad.c |   85 ++++++++++++++++++++--------------------
 1 files changed, 43 insertions(+), 42 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1d05819..88c3fe8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -446,6 +446,48 @@ static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
 /////////////////////////////////////////////////////////////////////////////////
 
 /**
+ * __choose_matched - update a port's matched variable from a received lacpdu
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * Update the value of the matched variable, using parameter values from a
+ * newly received lacpdu. Parameter values for the partner carried in the
+ * received PDU are compared with the corresponding operational parameter
+ * values for the actor. Matched is set to TRUE if all of these parameters
+ * match and the PDU parameter partner_state.aggregation has the same value as
+ * actor_oper_port_state.aggregation and lacp will actively maintain the link
+ * in the aggregation. Matched is also set to TRUE if the value of
+ * actor_state.aggregation in the received PDU is set to FALSE, i.e., indicates
+ * an individual link and lacp will actively maintain the link. Otherwise,
+ * matched is set to FALSE. LACP is considered to be actively maintaining the
+ * link if either the PDU's actor_state.lacp_activity variable is TRUE or both
+ * the actor's actor_oper_port_state.lacp_activity and the PDU's
+ * partner_state.lacp_activity variables are TRUE.
+ *
+ * Note: the AD_PORT_MATCHED "variable" is not specified by 802.3ad; it is
+ * used here to implement the language from 802.3ad 43.4.9 that requires
+ * recordPDU to "match" the LACPDU parameters to the stored values.
+ */
+static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
+{
+	// check if all parameters are alike
+	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
+	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
+	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
+	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
+	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
+	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
+	    // or this is individual link(aggregation == FALSE)
+	    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
+		) {
+		// update the state machine Matched variable
+		port->sm_vars |= AD_PORT_MATCHED;
+	} else {
+		port->sm_vars &= ~AD_PORT_MATCHED;
+	}
+}
+
+/**
  * __record_pdu - record parameters from a received lacpdu
  * @lacpdu: the lacpdu we've received
  * @port: the port we're looking at
@@ -459,6 +501,7 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 	if (lacpdu && port) {
 		struct port_params *partner = &port->partner_oper;
 
+		__choose_matched(lacpdu, port);
 		// record the new parameter values for the partner operational
 		partner->port_number = ntohs(lacpdu->actor_port);
 		partner->port_priority = ntohs(lacpdu->actor_port_priority);
@@ -563,47 +606,6 @@ static void __update_default_selected(struct port *port)
 }
 
 /**
- * __choose_matched - update a port's matched variable from a received lacpdu
- * @lacpdu: the lacpdu we've received
- * @port: the port we're looking at
- *
- * Update the value of the matched variable, using parameter values from a
- * newly received lacpdu. Parameter values for the partner carried in the
- * received PDU are compared with the corresponding operational parameter
- * values for the actor. Matched is set to TRUE if all of these parameters
- * match and the PDU parameter partner_state.aggregation has the same value as
- * actor_oper_port_state.aggregation and lacp will actively maintain the link
- * in the aggregation. Matched is also set to TRUE if the value of
- * actor_state.aggregation in the received PDU is set to FALSE, i.e., indicates
- * an individual link and lacp will actively maintain the link. Otherwise,
- * matched is set to FALSE. LACP is considered to be actively maintaining the
- * link if either the PDU's actor_state.lacp_activity variable is TRUE or both
- * the actor's actor_oper_port_state.lacp_activity and the PDU's
- * partner_state.lacp_activity variables are TRUE.
- */
-static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
-{
-	// validate lacpdu and port
-	if (lacpdu && port) {
-		// check if all parameters are alike
-		if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
-		     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
-		     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
-		     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
-		     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
-		     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
-		    // or this is individual link(aggregation == FALSE)
-		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
-		   ) {
-			// update the state machine Matched variable
-			port->sm_vars |= AD_PORT_MATCHED;
-		} else {
-			port->sm_vars &= ~AD_PORT_MATCHED;
-		}
-	}
-}
-
-/**
  * __update_ntt - update a port's ntt variable from a received lacpdu
  * @lacpdu: the lacpdu we've received
  * @port: the port we're looking at
@@ -1134,7 +1136,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			__update_selected(lacpdu, port);
 			__update_ntt(lacpdu, port);
 			__record_pdu(lacpdu, port);
-			__choose_matched(lacpdu, port);
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			// verify that if the aggregator is enabled, the port is enabled too.
-- 
1.5.4.5

