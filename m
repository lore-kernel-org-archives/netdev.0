From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding 802.3ad: Fix the state machine locking
Date: Thu, 03 Mar 2011 12:07:36 -0800
Message-ID: <11685.1299182856@death>
References: <1299143159-9754-1-git-send-email-nils.carlson@ericsson.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Nils Carlson <nils.carlson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34290 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130Ab1CCUHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:07:43 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p23JgqEt026099
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 14:43:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E41B938C803F
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2011 15:07:40 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p23K7fa9475636
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 15:07:41 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p23K7dDt024330
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2011 13:07:41 -0700
In-reply-to: <1299143159-9754-1-git-send-email-nils.carlson@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nils Carlson <nils.carlson@ericsson.com> wrote:

>The current implementation only locked around the rx state machine,
>but the rx state machine reads data touched by other state machines
>as well, so in a very ugly scenario we would see the rx state machine
>reading bad values as data was being overwritten by other state
>machines. This patch moves the bond_3ad locking to protect all the
>state machines from concurrency issues.

	This looks pretty obvious on inspection; I'm surprised it hasn't
come up before.  I haven't tested it, but it seems clear that at least
the port->sm_vars field needs protection.

	I have one suggestion for a comment change, which is below, to
make it cleared what data needs mutexing.  I'd also add the following
into the description somewhere:

	The ad_rx_machine, ad_periodic_machine and
ad_port_selection_logic functions all inspect and alter common fields
within the port structure.  Previous to this patch, only the
ad_rx_machines were mutexed, and the periodic and port_selection could
run unmutexed against an rx_machine trigged by an arriving LACPDU.

	I'm a little torn on the change of nomenclature of "rx" to
"state" lock, mostly because it makes the functional change harder to
follow in the patch.  Could you split this into two patches, one to fix
the locking problem, and one to change the name?

>Signed-off-by: Nils Carlson <nils.carlson@ericsson.com>
>---
> drivers/net/bonding/bond_3ad.c |   32 +++++++++++++++++++-------------
> drivers/net/bonding/bond_3ad.h |    2 +-
> 2 files changed, 20 insertions(+), 14 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 1024ae1..bbc473b 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -281,23 +281,23 @@ static inline int __check_agg_selection_timer(struct port *port)
> }
>
> /**
>- * __get_rx_machine_lock - lock the port's RX machine
>+ * __get_state_machine_lock - lock the port's state machine
>  * @port: the port we're looking at
>  *
>  */
>-static inline void __get_rx_machine_lock(struct port *port)
>+static inline void __get_state_machine_lock(struct port *port)
> {
>-	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
>+	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
> }
>
> /**
>- * __release_rx_machine_lock - unlock the port's RX machine
>+ * __release_state_machine_lock - unlock the port's state machine
>  * @port: the port we're looking at
>  *
>  */
>-static inline void __release_rx_machine_lock(struct port *port)
>+static inline void __release_state_machine_lock(struct port *port)
> {
>-	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
>+	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
> }
>
> /**
>@@ -388,14 +388,14 @@ static u8 __get_duplex(struct port *port)
> }
>
> /**
>- * __initialize_port_locks - initialize a port's RX machine spinlock
>+ * __initialize_port_locks - initialize a port's state machine spinlock
>  * @port: the port we're looking at
>  *
>  */
> static inline void __initialize_port_locks(struct port *port)
> {
> 	// make sure it isn't called twice
>-	spin_lock_init(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
>+	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
> }
>
> //conversions
>@@ -1025,9 +1025,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
> {
> 	rx_states_t last_state;
>
>-	// Lock to prevent 2 instances of this function to run simultaneously(rx interrupt and periodic machine callback)
>-	__get_rx_machine_lock(port);
>-
> 	// keep current State Machine state to compare later if it was changed
> 	last_state = port->sm_rx_state;
>
>@@ -1133,7 +1130,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
> 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
> 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
> 				       port->slave->dev->master->name, port->slave->dev->name);
>-				__release_rx_machine_lock(port);
> 				return;
> 			}
> 			__update_selected(lacpdu, port);
>@@ -1153,7 +1149,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
> 			break;
> 		}
> 	}
>-	__release_rx_machine_lock(port);
> }
>
> /**
>@@ -2155,6 +2150,12 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 			goto re_arm;
> 		}
>
>+		/* Lock around all the state machines to protect data that may
>+		 * be accessed also from the ad_rx_machine running in the
>+		 * interrupt handler.

	The reference to interrupt handler confused me initially; I think
this comment would be better stated as:

		/* Lock around state machines to protect data accessed
		 * by all (e.g., port->sm_vars).  ad_rx_machine may run
		 * concurrently due to incoming LACPDU.
		 */



>+		 */
>+		__get_state_machine_lock(port);
>+
> 		ad_rx_machine(NULL, port);
> 		ad_periodic_machine(port);
> 		ad_port_selection_logic(port);
>@@ -2164,6 +2165,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 		// turn off the BEGIN bit, since we already handled it
> 		if (port->sm_vars & AD_PORT_BEGIN)
> 			port->sm_vars &= ~AD_PORT_BEGIN;
>+
>+		__release_state_machine_lock(port);
> 	}
>
> re_arm:
>@@ -2200,7 +2203,10 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
> 		case AD_TYPE_LACPDU:
> 			pr_debug("Received LACPDU on port %d\n",
> 				 port->actor_port_number);
>+			/* Protect against concurrent state machines */
>+			__get_state_machine_lock(port);
> 			ad_rx_machine(lacpdu, port);
>+			__release_state_machine_lock(port);
> 			break;
>
> 		case AD_TYPE_MARKER:
>diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
>index 2c46a15..9182506 100644
>--- a/drivers/net/bonding/bond_3ad.h
>+++ b/drivers/net/bonding/bond_3ad.h
>@@ -264,7 +264,7 @@ struct ad_bond_info {
> struct ad_slave_info {
> 	struct aggregator aggregator;	    // 802.3ad aggregator structure
> 	struct port port;		    // 802.3ad port structure
>-	spinlock_t rx_machine_lock; // To avoid race condition between callback and receive interrupt
>+	spinlock_t state_machine_lock; // To avoid race condition between callback and receive interrupt

	Perhaps change this comment, also, to "mutex state machine
vs. LACPDU".

	-J

> 	u16 id;
> };
>
>-- 
>1.7.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
