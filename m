From: Nils Carlson <nils.carlson@ericsson.com>
Subject: [PATCH 1/2] bonding 802.3ad: Fix the state machine locking v2
Date: Fri, 4 Mar 2011 09:09:11 +0100
Message-ID: <1299226152-23578-1-git-send-email-nils.carlson@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nils Carlson <nils.carlson@ericsson.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:62582 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759077Ab1CDHt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 02:49:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:
* Clarify an unclear comment
* Move a (possible) name change to a separate patch

The ad_rx_machine, ad_periodic_machine and ad_port_selection_logic
functions all inspect and alter common fields within the port structure.
Previous to this patch, only the ad_rx_machines were mutexed, and the
periodic and port_selection could run unmutexed against an ad_rx_machine
trigged by an arriving LACPDU.

This patch remedies the situation by protecting all the state machines
from concurrency. This is accomplished by locking around all the state
machines for a given port, which are executed at regular intervals; and
the ad_rx_machine when handling an incoming LACPDU.

Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>
---
 drivers/net/bonding/bond_3ad.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1024ae1..de30c8d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
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
 
+		/* Lock around state machines to protect data accessed
+		 * by all (e.g., port->sm_vars).  ad_rx_machine may run
+		 * concurrently due to incoming LACPDU.
+		 */
+		__get_rx_machine_lock(port);
+
 		ad_rx_machine(NULL, port);
 		ad_periodic_machine(port);
 		ad_port_selection_logic(port);
@@ -2164,6 +2165,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		// turn off the BEGIN bit, since we already handled it
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
+
+		__release_rx_machine_lock(port);
 	}
 
 re_arm:
@@ -2200,7 +2203,10 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 		case AD_TYPE_LACPDU:
 			pr_debug("Received LACPDU on port %d\n",
 				 port->actor_port_number);
+			/* Protect against concurrent state machines */
+			__get_rx_machine_lock(port);
 			ad_rx_machine(lacpdu, port);
+			__release_rx_machine_lock(port);
 			break;
 
 		case AD_TYPE_MARKER:
-- 
1.7.1

