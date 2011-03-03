From: Nils Carlson <nils.carlson@ericsson.com>
Subject: [PATCH] bonding 802.3ad: Fix the state machine locking
Date: Thu, 3 Mar 2011 10:05:59 +0100
Message-ID: <1299143159-9754-1-git-send-email-nils.carlson@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nils Carlson <nils.carlson@ericsson.com>
To: <bonding-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:51184 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab1CCIqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:46:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation only locked around the rx state machine,
but the rx state machine reads data touched by other state machines
as well, so in a very ugly scenario we would see the rx state machine
reading bad values as data was being overwritten by other state
machines. This patch moves the bond_3ad locking to protect all the
state machines from concurrency issues.

Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>
---
 drivers/net/bonding/bond_3ad.c |   32 +++++++++++++++++++-------------
 drivers/net/bonding/bond_3ad.h |    2 +-
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1024ae1..bbc473b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -281,23 +281,23 @@ static inline int __check_agg_selection_timer(struct port *port)
 }
 
 /**
- * __get_rx_machine_lock - lock the port's RX machine
+ * __get_state_machine_lock - lock the port's state machine
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
+ * __release_state_machine_lock - unlock the port's state machine
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
+ * __initialize_port_locks - initialize a port's state machine spinlock
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
@@ -1025,9 +1025,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 {
 	rx_states_t last_state;
 
-	// Lock to prevent 2 instances of this function to run simultaneously(rx interrupt and periodic machine callback)
-	__get_rx_machine_lock(port);
-
 	// keep current State Machine state to compare later if it was changed
 	last_state = port->sm_rx_state;
 
@@ -1133,7 +1130,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
 				       port->slave->dev->master->name, port->slave->dev->name);
-				__release_rx_machine_lock(port);
 				return;
 			}
 			__update_selected(lacpdu, port);
@@ -1153,7 +1149,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			break;
 		}
 	}
-	__release_rx_machine_lock(port);
 }
 
 /**
@@ -2155,6 +2150,12 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 			goto re_arm;
 		}
 
+		/* Lock around all the state machines to protect data that may
+		 * be accessed also from the ad_rx_machine running in the
+		 * interrupt handler.
+		 */
+		__get_state_machine_lock(port);
+
 		ad_rx_machine(NULL, port);
 		ad_periodic_machine(port);
 		ad_port_selection_logic(port);
@@ -2164,6 +2165,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		// turn off the BEGIN bit, since we already handled it
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
+
+		__release_state_machine_lock(port);
 	}
 
 re_arm:
@@ -2200,7 +2203,10 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 		case AD_TYPE_LACPDU:
 			pr_debug("Received LACPDU on port %d\n",
 				 port->actor_port_number);
+			/* Protect against concurrent state machines */
+			__get_state_machine_lock(port);
 			ad_rx_machine(lacpdu, port);
+			__release_state_machine_lock(port);
 			break;
 
 		case AD_TYPE_MARKER:
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 2c46a15..9182506 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -264,7 +264,7 @@ struct ad_bond_info {
 struct ad_slave_info {
 	struct aggregator aggregator;	    // 802.3ad aggregator structure
 	struct port port;		    // 802.3ad port structure
-	spinlock_t rx_machine_lock; // To avoid race condition between callback and receive interrupt
+	spinlock_t state_machine_lock; // To avoid race condition between callback and receive interrupt
 	u16 id;
 };
 
-- 
1.7.1

