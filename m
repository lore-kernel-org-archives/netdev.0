From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] drivers/net/bonding/bond_3ad: Remove struct
 mac_addr and typedef
Date: Sun, 17 Oct 2010 00:38:17 -0700
Message-ID: <1287301097.20968.19.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2984 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754494Ab0JQHiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Oct 2010 03:38:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more standard u8 name[ETH_ALEN];
Remove MAC_ADDRESS_COMPARE and use compare_ether_addr
Remove null_mac_addr and use is_zero_ether_addr and memset
Use memcpy for copying ether addresses

Size increases ~200 bytes so it's not great,
but it might be better for style consistency.

$ size drivers/net/bonding/*.o.*
   text	   data	    bss	    dec	    hex	filename
  25580	    776	   5800	  32156	   7d9c	drivers/net/bonding/bond_3ad.o.new
  25396	    776	   5808	  31980	   7cec	drivers/net/bonding/bond_3ad.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c |   50 ++++++++++++++++++---------------------
 drivers/net/bonding/bond_3ad.h |   20 ++++++---------
 2 files changed, 31 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 079b9d1..5a38eef 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -90,10 +90,6 @@
 #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
 //endalloun
 
-// compare MAC addresses
-#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
-
-static struct mac_addr null_mac_addr = {{0, 0, 0, 0, 0, 0}};
 static u16 ad_ticks_per_sec;
 static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
@@ -218,7 +214,7 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
  */
 static inline int __agg_has_partner(struct aggregator *agg)
 {
-	return !is_zero_ether_addr(agg->partner_system.mac_addr_value);
+	return !is_zero_ether_addr(agg->partner_system);
 }
 
 /**
@@ -478,7 +474,7 @@ static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
 	// check if all parameters are alike
 	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
 	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
-	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
+	     !compare_ether_addr(lacpdu->partner_system, port->actor_system) &&
 	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
 	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
 	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
@@ -510,7 +506,7 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		// record the new parameter values for the partner operational
 		partner->port_number = ntohs(lacpdu->actor_port);
 		partner->port_priority = ntohs(lacpdu->actor_port_priority);
-		partner->system = lacpdu->actor_system;
+		memcpy(partner->system, lacpdu->actor_system, ETH_ALEN);
 		partner->system_priority = ntohs(lacpdu->actor_system_priority);
 		partner->key = ntohs(lacpdu->actor_key);
 		partner->port_state = lacpdu->actor_state;
@@ -568,7 +564,7 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 		// check if any parameter is different
 		if (ntohs(lacpdu->actor_port) != partner->port_number ||
 		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
-		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
+		    compare_ether_addr(lacpdu->actor_system, partner->system) ||
 		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
 		    ntohs(lacpdu->actor_key) != partner->key ||
 		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
@@ -599,7 +595,7 @@ static void __update_default_selected(struct port *port)
 		// check if any parameter is different
 		if (admin->port_number != oper->port_number ||
 		    admin->port_priority != oper->port_priority ||
-		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
+		    compare_ether_addr(admin->system, oper->system) ||
 		    admin->system_priority != oper->system_priority ||
 		    admin->key != oper->key ||
 		    (admin->port_state & AD_STATE_AGGREGATION)
@@ -629,7 +625,7 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 		// check if any parameter is different
 		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
 		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
+		    compare_ether_addr(lacpdu->partner_system, port->actor_system) ||
 		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
 		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
@@ -787,7 +783,7 @@ static inline void __update_lacpdu_from_port(struct port *port)
 	 */
 
 	lacpdu->actor_system_priority = htons(port->actor_system_priority);
-	lacpdu->actor_system = port->actor_system;
+	memcpy(lacpdu->actor_system, port->actor_system, ETH_ALEN);
 	lacpdu->actor_key = htons(port->actor_oper_port_key);
 	lacpdu->actor_port_priority = htons(port->actor_port_priority);
 	lacpdu->actor_port = htons(port->actor_port_number);
@@ -799,7 +795,7 @@ static inline void __update_lacpdu_from_port(struct port *port)
 	 */
 
 	lacpdu->partner_system_priority = htons(partner->system_priority);
-	lacpdu->partner_system = partner->system;
+	memcpy(lacpdu->partner_system, partner->system, ETH_ALEN);
 	lacpdu->partner_key = htons(partner->key);
 	lacpdu->partner_port_priority = htons(partner->port_priority);
 	lacpdu->partner_port = htons(partner->port_number);
@@ -1133,7 +1129,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			break;
 		case AD_RX_CURRENT:
 			// detect loopback situation
-			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
+			if (!compare_ether_addr(lacpdu->actor_system, port->actor_system)) {
 				// INFO_RECEIVED_LOOPBACK_FRAMES
 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
@@ -1340,11 +1336,11 @@ static void ad_port_selection_logic(struct port *port)
 		}
 		// check if current aggregator suits us
 		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
-		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
+		     !compare_ether_addr(aggregator->partner_system, port->partner_oper.system) &&
 		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
 		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
 		    ) &&
-		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
+		    ((is_zero_ether_addr(port->partner_oper.system) && // partner answers
 		      !aggregator->is_individual)  // but is not individual OR
 		    )
 		   ) {
@@ -1382,7 +1378,7 @@ static void ad_port_selection_logic(struct port *port)
 
 			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
 			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
-			port->aggregator->partner_system=port->partner_oper.system;
+			memcpy(port->aggregator->partner_system, port->partner_oper.system, ETH_ALEN);
 			port->aggregator->partner_system_priority = port->partner_oper.system_priority;
 			port->aggregator->partner_oper_aggregator_key = port->partner_oper.key;
 			port->aggregator->receive_state = 1;
@@ -1636,7 +1632,7 @@ static void ad_clear_agg(struct aggregator *aggregator)
 		aggregator->is_individual = false;
 		aggregator->actor_admin_aggregator_key = 0;
 		aggregator->actor_oper_aggregator_key = 0;
-		aggregator->partner_system = null_mac_addr;
+		memset(aggregator->partner_system, 0, ETH_ALEN);
 		aggregator->partner_system_priority = 0;
 		aggregator->partner_oper_aggregator_key = 0;
 		aggregator->receive_state = 0;
@@ -1659,7 +1655,7 @@ static void ad_initialize_agg(struct aggregator *aggregator)
 	if (aggregator) {
 		ad_clear_agg(aggregator);
 
-		aggregator->aggregator_mac_address = null_mac_addr;
+		memset(aggregator->aggregator_mac_address, 0, ETH_ALEN);
 		aggregator->aggregator_identifier = 0;
 		aggregator->slave = NULL;
 	}
@@ -1695,7 +1691,7 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 	if (port) {
 		port->actor_port_number = 1;
 		port->actor_port_priority = 0xff;
-		port->actor_system = null_mac_addr;
+		memset(port->actor_system, 0, ETH_ALEN);
 		port->actor_system_priority = 0xffff;
 		port->actor_port_aggregator_identifier = 0;
 		port->ntt = false;
@@ -1754,7 +1750,7 @@ static void ad_enable_collecting_distributing(struct port *port)
  */
 static void ad_disable_collecting_distributing(struct port *port)
 {
-	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
+	if (port->aggregator && is_zero_ether_addr(port->aggregator->partner_system)) {
 		pr_debug("Disabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
@@ -1875,14 +1871,14 @@ static u16 aggregator_identifier;
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast)
 {
 	// check that the bond is not initialized yet
-	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
-				bond->dev->dev_addr)) {
+	if (compare_ether_addr(BOND_AD_INFO(bond).system.sys_mac_addr,
+			       bond->dev->dev_addr)) {
 
 		aggregator_identifier = 0;
 
 		BOND_AD_INFO(bond).lacp_fast = lacp_fast;
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
-		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
+		memcpy(BOND_AD_INFO(bond).system.sys_mac_addr, bond->dev->dev_addr, ETH_ALEN);
 
 		// initialize how many times this module is called in one second(should be about every 100ms)
 		ad_ticks_per_sec = tick_resolution;
@@ -1936,7 +1932,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 		}
 		// actor system is the bond's system
-		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
+		memcpy(port->actor_system, BOND_AD_INFO(bond).system.sys_mac_addr, ETH_ALEN);
 		// tx timer(to verify that no more than MAX_TX_IN_SECOND lacpdu's are sent in one second)
 		port->sm_tx_timer_counter = ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 		port->aggregator = NULL;
@@ -1951,7 +1947,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 
 		ad_initialize_agg(aggregator);
 
-		aggregator->aggregator_mac_address = *((struct mac_addr *)bond->dev->dev_addr);
+		memcpy(aggregator->aggregator_mac_address, bond->dev->dev_addr, ETH_ALEN);
 		aggregator->aggregator_identifier = (++aggregator_identifier);
 		aggregator->slave = slave;
 		aggregator->is_active = 0;
@@ -2027,7 +2023,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				new_aggregator->is_individual = aggregator->is_individual;
 				new_aggregator->actor_admin_aggregator_key = aggregator->actor_admin_aggregator_key;
 				new_aggregator->actor_oper_aggregator_key = aggregator->actor_oper_aggregator_key;
-				new_aggregator->partner_system = aggregator->partner_system;
+				memcpy(new_aggregator->partner_system, aggregator->partner_system, ETH_ALEN);
 				new_aggregator->partner_system_priority = aggregator->partner_system_priority;
 				new_aggregator->partner_oper_aggregator_key = aggregator->partner_oper_aggregator_key;
 				new_aggregator->receive_state = aggregator->receive_state;
@@ -2371,7 +2367,7 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 		ad_info->ports = aggregator->num_of_ports;
 		ad_info->actor_key = aggregator->actor_oper_aggregator_key;
 		ad_info->partner_key = aggregator->partner_oper_aggregator_key;
-		memcpy(ad_info->partner_system, aggregator->partner_system.mac_addr_value, ETH_ALEN);
+		memcpy(ad_info->partner_system, aggregator->partner_system, ETH_ALEN);
 		return 0;
 	}
 
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 2c46a154..648792c 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -37,10 +37,6 @@
 #define AD_LACP_SLOW 0
 #define AD_LACP_FAST 1
 
-typedef struct mac_addr {
-	u8 mac_addr_value[ETH_ALEN];
-} mac_addr_t;
-
 enum {
 	BOND_AD_STABLE = 0,
 	BOND_AD_BANDWIDTH = 1,
@@ -112,7 +108,7 @@ typedef struct lacpdu {
 	u8 tlv_type_actor_info;	      // = actor information(type/length/value)
 	u8 actor_information_length; // = 20
 	__be16 actor_system_priority;
-	struct mac_addr actor_system;
+	u8 actor_system[ETH_ALEN];
 	__be16 actor_key;
 	__be16 actor_port_priority;
 	__be16 actor_port;
@@ -121,7 +117,7 @@ typedef struct lacpdu {
 	u8 tlv_type_partner_info;     // = partner information
 	u8 partner_information_length;	 // = 20
 	__be16 partner_system_priority;
-	struct mac_addr partner_system;
+	u8 partner_system[ETH_ALEN];
 	__be16 partner_key;
 	__be16 partner_port_priority;
 	__be16 partner_port;
@@ -149,7 +145,7 @@ typedef struct bond_marker {
 	//  = 0x02  (marker response information)
 	u8 marker_length;	 //  = 0x16
 	u16 requester_port;	 //   The number assigned to the port by the requester
-	struct mac_addr requester_system;      //   The requester's system id
+	u8 requester_system[ETH_ALEN];      //   The requester's system id
 	u32 requester_transaction_id;	//   The transaction id allocated by the requester,
 	u16 pad;		 //  = 0
 	u8 tlv_type_terminator;	     //  = 0x00
@@ -175,12 +171,12 @@ struct port;
 
 // aggregator structure(43.4.5 in the 802.3ad standard)
 typedef struct aggregator {
-	struct mac_addr aggregator_mac_address;
+	u8 aggregator_mac_address[ETH_ALEN];
 	u16 aggregator_identifier;
 	bool is_individual;
 	u16 actor_admin_aggregator_key;
 	u16 actor_oper_aggregator_key;
-	struct mac_addr partner_system;
+	u8 partner_system[ETH_ALEN];
 	u16 partner_system_priority;
 	u16 partner_oper_aggregator_key;
 	u16 receive_state;		// BOOLEAN
@@ -193,7 +189,7 @@ typedef struct aggregator {
 } aggregator_t;
 
 struct port_params {
-	struct mac_addr system;
+	u8 system[ETH_ALEN];
 	u16 system_priority;
 	u16 key;
 	u16 port_number;
@@ -205,7 +201,7 @@ struct port_params {
 typedef struct port {
 	u16 actor_port_number;
 	u16 actor_port_priority;
-	struct mac_addr actor_system;	       // This parameter is added here although it is not specified in the standard, just for simplification
+	u8 actor_system[ETH_ALEN];       // This parameter is added here although it is not specified in the standard, just for simplification
 	u16 actor_system_priority;	 // This parameter is added here although it is not specified in the standard, just for simplification
 	u16 actor_port_aggregator_identifier;
 	bool ntt;
@@ -239,7 +235,7 @@ typedef struct port {
 // system structure
 struct ad_system {
 	u16 sys_priority;
-	struct mac_addr sys_mac_addr;
+	u8 sys_mac_addr[ETH_ALEN];
 };
 
 #ifdef __ia64__


