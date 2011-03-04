From: Nils Carlson <nils.carlson@ericsson.com>
Subject: [PATCH 2/2] bonding 802.3ad: Rename rx_machine_lock to state_machine_lock
Date: Fri, 4 Mar 2011 09:09:12 +0100
Message-ID: <1299226152-23578-2-git-send-email-nils.carlson@ericsson.com>
References: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nils Carlson <nils.carlson@ericsson.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:48591 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759108Ab1CDHtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 02:49:32 -0500
In-Reply-To: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the rx_machine_lock to state_machine_lock as this makes more
sense in light of it now protecting all the state machines against
concurrency.

Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>
---
 drivers/net/bonding/bond_3ad.c |   24 ++++++++++++------------
 drivers/net/bonding/bond_3ad.h |    3 ++-
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index de30c8d..a5d5d0b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -281,23 +281,23 @@ static inline int __check_agg_selection_timer(struct port *port)
 }
 
 /**
- * __get_rx_machine_lock - lock the port's RX machine
+ * __get_state_machine_lock - lock the port's state machines
  * @port: the port we're looking at
  *
  */
-static inline void __get_rx_machine_lock(struct port *port)
+static inline void __get_state_machine_lock(struct port *port)
 {
-	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
 }
 
 /**
- * __release_rx_machine_lock - unlock the port's RX machine
+ * __release_state_machine_lock - unlock the port's state machines
  * @port: the port we're looking at
  *
  */
-static inline void __release_rx_machine_lock(struct port *port)
+static inline void __release_state_machine_lock(struct port *port)
 {
-	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
 }
 
 /**
@@ -388,14 +388,14 @@ static u8 __get_duplex(struct port *port)
 }
 
 /**
- * __initialize_port_locks - initialize a port's RX machine spinlock
+ * __initialize_port_locks - initialize a port's STATE machine spinlock
  * @port: the port we're looking at
  *
  */
 static inline void __initialize_port_locks(struct port *port)
 {
 	// make sure it isn't called twice
-	spin_lock_init(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
 }
 
 //conversions
@@ -2154,7 +2154,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		 * by all (e.g., port->sm_vars).  ad_rx_machine may run
 		 * concurrently due to incoming LACPDU.
 		 */
-		__get_rx_machine_lock(port);
+		__get_state_machine_lock(port);
 
 		ad_rx_machine(NULL, port);
 		ad_periodic_machine(port);
@@ -2166,7 +2166,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
 
-		__release_rx_machine_lock(port);
+		__release_state_machine_lock(port);
 	}
 
 re_arm:
@@ -2204,9 +2204,9 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 			pr_debug("Received LACPDU on port %d\n",
 				 port->actor_port_number);
 			/* Protect against concurrent state machines */
-			__get_rx_machine_lock(port);
+			__get_state_machine_lock(port);
 			ad_rx_machine(lacpdu, port);
-			__release_rx_machine_lock(port);
+			__release_state_machine_lock(port);
 			break;
 
 		case AD_TYPE_MARKER:
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 2c46a15..b28baff 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -264,7 +264,8 @@ struct ad_bond_info {
 struct ad_slave_info {
 	struct aggregator aggregator;	    // 802.3ad aggregator structure
 	struct port port;		    // 802.3ad port structure
-	spinlock_t rx_machine_lock; // To avoid race condition between callback and receive interrupt
+	spinlock_t state_machine_lock; /* mutex state machines vs.
+					  incoming LACPDU */
 	u16 id;
 };
 
-- 
1.7.1

