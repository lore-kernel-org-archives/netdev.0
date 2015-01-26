From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/5] bonding: fix incorrect lacp mux state when agg not active
Date: Mon, 26 Jan 2015 01:16:59 -0500
Message-ID: <1422253021-3798-4-git-send-email-jtoppins@cumulusnetworks.com>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Wilson Kok <wkok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34566 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbAZGUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:20:17 -0500
Received: by mail-qg0-f51.google.com with SMTP id z107so5568593qgd.10
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:20:17 -0800 (PST)
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

This patch attempts to fix the following problems when an actor or
partner's aggregator is not active:
    1. a slave's lacp port state is marked as AD_STATE_SYNCHRONIZATION
       even if it is attached to an inactive aggregator. LACP advertises
       this state to the partner, making the partner think he can move
       into COLLECTING_DISTRIBUTING state even though this link will not
       pass traffic on the local side

    2. a slave goes into COLLECTING_DISTRIBUTING state without checking
       if the aggregator is actually active

    3. when in COLLECTING_DISTRIBUTING state, the partner parameters may
       change, e.g. the partner_oper_port_state.SYNCHRONIZATION. The
       local mux machine is not reacting to the change and continue to
       keep the slave and bond up

    4. When bond slave leaves an inactive aggregator and joins an active
       aggregator, the actor oper port state need to update to SYNC state.

v2:
 * fix style issues in bond_3ad.c

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_3ad.c |   44 +++++++++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 8baa87d..e3c96b2 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -467,11 +467,14 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		/* set the partner sync. to on if the partner is sync,
 		 * and the port is matched
 		 */
-		if ((port->sm_vars & AD_PORT_MATCHED)
-		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
+		if ((port->sm_vars & AD_PORT_MATCHED) &&
+		    (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
 			partner->port_state |= AD_STATE_SYNCHRONIZATION;
-		else
+			pr_debug("%s partner sync=1\n", port->slave->dev->name);
+		} else {
 			partner->port_state &= ~AD_STATE_SYNCHRONIZATION;
+			pr_debug("%s partner sync=0\n", port->slave->dev->name);
+		}
 	}
 }
 
@@ -726,6 +729,8 @@ static inline void __update_lacpdu_from_port(struct port *port)
 	lacpdu->actor_port_priority = htons(port->actor_port_priority);
 	lacpdu->actor_port = htons(port->actor_port_number);
 	lacpdu->actor_state = port->actor_oper_port_state;
+	pr_debug("update lacpdu: %s, actor port state %x\n",
+		 port->slave->dev->name, port->actor_oper_port_state);
 
 	/* lacpdu->reserved_3_1              initialized
 	 * lacpdu->tlv_type_partner_info     initialized
@@ -898,7 +903,9 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 			if ((port->sm_vars & AD_PORT_SELECTED) &&
 			    (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) &&
 			    !__check_agg_selection_timer(port)) {
-				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;
+				if (port->aggregator->is_active)
+					port->sm_mux_state =
+					    AD_MUX_COLLECTING_DISTRIBUTING;
 			} else if (!(port->sm_vars & AD_PORT_SELECTED) ||
 				   (port->sm_vars & AD_PORT_STANDBY)) {
 				/* if UNSELECTED or STANDBY */
@@ -910,12 +917,16 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 				 */
 				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 				port->sm_mux_state = AD_MUX_DETACHED;
+			} else if (port->aggregator->is_active) {
+				port->actor_oper_port_state |=
+				    AD_STATE_SYNCHRONIZATION;
 			}
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			if (!(port->sm_vars & AD_PORT_SELECTED) ||
 			    (port->sm_vars & AD_PORT_STANDBY) ||
-			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)) {
+			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) ||
+			    !(port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) {
 				port->sm_mux_state = AD_MUX_ATTACHED;
 			} else {
 				/* if port state hasn't changed make
@@ -937,8 +948,10 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 
 	/* check if the state machine was changed */
 	if (port->sm_mux_state != last_state) {
-		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n",
-			 port->actor_port_number, last_state,
+		pr_debug("Mux Machine: Port=%d (%s), Last State=%d, Curr State=%d\n",
+			 port->actor_port_number,
+			 port->slave->dev->name,
+			 last_state,
 			 port->sm_mux_state);
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
@@ -953,7 +966,12 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 			port->sm_mux_timer_counter = __ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
 			break;
 		case AD_MUX_ATTACHED:
-			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
+			if (port->aggregator->is_active)
+				port->actor_oper_port_state |=
+				    AD_STATE_SYNCHRONIZATION;
+			else
+				port->actor_oper_port_state &=
+				    ~AD_STATE_SYNCHRONIZATION;
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
 			ad_disable_collecting_distributing(port,
@@ -963,6 +981,7 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			port->actor_oper_port_state |= AD_STATE_COLLECTING;
 			port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
+			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
 			ad_enable_collecting_distributing(port,
 							  update_slave_arr);
 			port->ntt = true;
@@ -1044,8 +1063,10 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 
 	/* check if the State machine was changed or new lacpdu arrived */
 	if ((port->sm_rx_state != last_state) || (lacpdu)) {
-		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n",
-			 port->actor_port_number, last_state,
+		pr_debug("Rx Machine: Port=%d (%s), Last State=%d, Curr State=%d\n",
+			 port->actor_port_number,
+			 port->slave->dev->name,
+			 last_state,
 			 port->sm_rx_state);
 		switch (port->sm_rx_state) {
 		case AD_RX_INITIALIZE:
@@ -1394,6 +1415,9 @@ static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
 
 	aggregator = __get_first_agg(port);
 	ad_agg_selection_logic(aggregator, update_slave_arr);
+
+	if (!port->aggregator->is_active)
+		port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
 }
 
 /* Decide if "agg" is a better choice for the new active aggregator that
-- 
1.7.10.4
