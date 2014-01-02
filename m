From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 09:12:54 +0800
Message-ID: <52C4BD16.5010702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal_64bits
to instead of memcmp.

Modify the MAC_ADDR_COMPARE to MAC_ADDR_EQUAL, this looks more
appropriate.

The comments for the bond 3ad is too old, cleanup some errors
and warming.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 62 ++++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 58c2249..5393e1e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -90,8 +90,9 @@
 #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
 //endalloun
 
-// compare MAC addresses
-#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
+/* compare MAC addresses */
+#define MAC_ADDRESS_EQUAL(A, B)	\
+	ether_addr_equal_64bits((const u8 *)A, (const u8 *)B)
 
 static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
 static u16 ad_ticks_per_sec;
@@ -417,17 +418,18 @@ static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
  */
 static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
 {
-	// check if all parameters are alike
+	/* check if all parameters are alike
+	 * or this is individual link(aggregation == FALSE)
+	 * then update the state machine Matched variable.
+	 */
 	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
 	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
-	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
+	     MAC_ADDRESS_EQUAL(&(lacpdu->partner_system), &(port->actor_system)) &&
 	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
 	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
 	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
-	    // or this is individual link(aggregation == FALSE)
 	    ((lacpdu->actor_state & AD_STATE_AGGREGATION) == 0)
 		) {
-		// update the state machine Matched variable
 		port->sm_vars |= AD_PORT_MATCHED;
 	} else {
 		port->sm_vars &= ~AD_PORT_MATCHED;
@@ -507,14 +509,15 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 	if (lacpdu && port) {
 		const struct port_params *partner = &port->partner_oper;
 
-		// check if any parameter is different
+		/* check if any parameter is different then
+		 * update the state machine selected variable.
+		 */
 		if (ntohs(lacpdu->actor_port) != partner->port_number ||
 		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
-		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
+		    !MAC_ADDRESS_EQUAL(&lacpdu->actor_system, &partner->system) ||
 		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
 		    ntohs(lacpdu->actor_key) != partner->key ||
 		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
-			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}
 	}
@@ -538,15 +541,16 @@ static void __update_default_selected(struct port *port)
 		const struct port_params *admin = &port->partner_admin;
 		const struct port_params *oper = &port->partner_oper;
 
-		// check if any parameter is different
+		/* check if any parameter is different then
+		 * update the state machine selected variable.
+		 */
 		if (admin->port_number != oper->port_number ||
 		    admin->port_priority != oper->port_priority ||
-		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
+		    !MAC_ADDRESS_EQUAL(&admin->system, &oper->system) ||
 		    admin->system_priority != oper->system_priority ||
 		    admin->key != oper->key ||
 		    (admin->port_state & AD_STATE_AGGREGATION)
 			!= (oper->port_state & AD_STATE_AGGREGATION)) {
-			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}
 	}
@@ -566,12 +570,14 @@ static void __update_default_selected(struct port *port)
  */
 static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 {
-	// validate lacpdu and port
+	/* validate lacpdu and port */
 	if (lacpdu && port) {
-		// check if any parameter is different
+		/* check if any parameter is different then
+		 * update the port->ntt.
+		 */
 		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
 		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
+		    !MAC_ADDRESS_EQUAL(&(lacpdu->partner_system), &(port->actor_system)) ||
 		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
 		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
@@ -579,7 +585,6 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 		    ((lacpdu->partner_state & AD_STATE_SYNCHRONIZATION) != (port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) ||
 		    ((lacpdu->partner_state & AD_STATE_AGGREGATION) != (port->actor_oper_port_state & AD_STATE_AGGREGATION))
 		   ) {
-
 			port->ntt = true;
 		}
 	}
@@ -1076,9 +1081,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
 		case AD_RX_CURRENT:
-			// detect loopback situation
-			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
-				// INFO_RECEIVED_LOOPBACK_FRAMES
+			/* detect loopback situation */
+			if (MAC_ADDRESS_EQUAL(&(lacpdu->actor_system), &(port->actor_system))) {
 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
 				       port->slave->bond->dev->name, port->slave->dev->name);
@@ -1090,7 +1094,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
-		default:    //to silence the compiler
+		default:    /* to silence the compiler */
 			break;
 		}
 	}
@@ -1281,17 +1285,17 @@ static void ad_port_selection_logic(struct port *port)
 				free_aggregator = aggregator;
 			continue;
 		}
-		// check if current aggregator suits us
-		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
-		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
+		/* check if current aggregator suits us */
+		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && /* if all parameters match AND */
+		     MAC_ADDRESS_EQUAL(&(aggregator->partner_system), &(port->partner_oper.system)) &&
 		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
 		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
 		    ) &&
-		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
-		      !aggregator->is_individual)  // but is not individual OR
+		    ((!MAC_ADDRESS_EQUAL(&(port->partner_oper.system), &(null_mac_addr)) && /* partner answers */
+		      !aggregator->is_individual)  /* but is not individual OR */
 		    )
 		   ) {
-			// attach to the founded aggregator
+			/* attach to the founded aggregator */
 			port->aggregator = aggregator;
 			port->actor_port_aggregator_identifier =
 				port->aggregator->aggregator_identifier;
@@ -1705,7 +1709,7 @@ static void ad_enable_collecting_distributing(struct port *port)
  */
 static void ad_disable_collecting_distributing(struct port *port)
 {
-	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
+	if (port->aggregator && !MAC_ADDRESS_EQUAL(&(port->aggregator->partner_system), &(null_mac_addr))) {
 		pr_debug("Disabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
@@ -1826,8 +1830,8 @@ static u16 aggregator_identifier;
  */
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 {
-	// check that the bond is not initialized yet
-	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
+	/* check that the bond is not initialized yet */
+	if (!MAC_ADDRESS_EQUAL(&(BOND_AD_INFO(bond).system.sys_mac_addr),
 				bond->dev->dev_addr)) {
 
 		aggregator_identifier = 0;
-- 
1.8.0
