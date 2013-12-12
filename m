From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v5 7/11] bonding: rebuild the lock use for bond_3ad_state_machine_handler()
Date: Wed, 11 Dec 2013 18:41:26 -0800
Message-ID: <8562.1386816086@death.nxdomain>
References: <52A7F18A.7060308@huawei.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57272 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3LLCld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 21:41:33 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 11 Dec 2013 19:41:32 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 02E0919D8045
	for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 19:41:24 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC0dagN9765172
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 01:39:36 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC2fTs1017201
	for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 19:41:30 -0700
In-reply-to: <52A7F18A.7060308@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The bond_3ad_state_machine_handler() use the bond lock to protect
>the bond slave list and slave port, so as the before patch said,
>I remove bond lock and replace with RCU.
>
>There was a lot of function need RCU protect, I have two choice
>to make the function in RCU-safe, (1) create new similar functions
>and make the bond slave list in RCU. (2) modify the existed functions
>and make them in read-side critical section, because the RCU
>read-side critical sections may be nested.
>
>I choose (2) because it is no need to create more similar functions.

	A few comments:

	First, the large number of comment-only changes make the actual
functional changes harder to follow (plus there's one indenting mistake,
noted in the patch, below).

	I looked through the locking for handling port->sm_vars and
aggregator->lag_ports after the patches are applied.

	I don't see anything that will mutex changes to
aggregator->lag_ports between bond_3ad_state_machine_handler and
bond_3ad_unbind_slave.  These functions will modify ->lag_ports either
directly (unbind only) or via ad_agg_selection_logic (both functions).

	Even though the slave has been removed from the list by the time
the state machine runs, it appears to be possible for both functions to
manipulate the same aggregator->lag_ports by finding the aggregator via
two different ports that are both members of that aggregator (i.e., port
A of the agg is being unbound, and port B of the agg is running its
state machine).

	The bond_3ad_state_machine_handler calls ad_agg_selection_logic
with either just rcu_read_lock, or rcu_read_lock plus a a port's state
machine lock (for the case that ad_port_selection_logic calls
ad_agg_selection_logic).

	The bond_3ad_unbind_slave calls ad_agg_selection_logic or
modifies lag_ports directly while holding RTNL (inherited from its
caller) and bond->lock for write.

	Prior to this patch, state_machine_handler additionally held
bond->lock for read, thus bond->lock provided mutexing between the two.

	The bond_3ad_lacpdu_recv function still (after your patches are
applied) calls bond_3ad_rx_indication with bond->lock held for read;
this (along with __get_state_machine_lock) protects ->sm_vars in
ad_rx_machine.  ad_rx_machine does not modify lag_ports, only sm_vars.
I think this is safe, particularly against race with _unbind_slave, as
the rx handler is cleared prior to unbind for exactly this reason.
Unless its possible for the rx_indication to already be running before
the removal of rx_handler and still be running when _unbind_slave is
called; I'm not sure on this one, anybody have a definitive answer?

	One place that should have a comment updated is in
__bond_release_one:

__bond_release_one(...)
[...]
	/* Inform AD package of unbinding of slave. */
	if (bond->params.mode == BOND_MODE_8023AD) {
		/* must be called before the slave is
		 * detached from the list
		 */
		bond_3ad_unbind_slave(slave);
	}

	This comment is no longer correct, as by this point, the slave
has already been unlinked.  This unlinking appears to protect the
->sm_vars of the port from being modified concurrently by unbind_slave
and state_machine (as in the above case) because ->sm_vars changes are
limited to the port being operated on only.  I'm not 100% sure on this,
though, if the state_machine could race there and be operating on the
same slave (port) at the time _unbind is also doing so.

	Lastly, bond_3ad_adapter_speed_changed or _duplex_changed are
called with RTNL only, and those functions will modify port->sm_vars
with no further locking (they are not mutexed against 3ad_state_machine
or incoming LACPDUs, which do not hold RTNL).  This one actually looks
like a preexisting problem, not new to this patch.

>The nots in the function is still too old, clean up the nots.
>
>Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_3ad.c | 53 ++++++++++++++++++++++++------------------
> 1 file changed, 31 insertions(+), 22 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 187b1b7..d935da5 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -147,11 +147,12 @@ static inline struct aggregator *__get_first_agg(struct port *port)
> 	struct bonding *bond = __get_bond_by_port(port);
> 	struct slave *first_slave;
>
>-	// If there's no bond for this port, or bond has no slaves
>+	/* If there's no bond for this port, or bond has no slaves */
> 	if (bond == NULL)
> 		return NULL;
>-	first_slave = bond_first_slave(bond);
>-
>+	rcu_read_lock();
>+	first_slave = bond_first_slave_rcu(bond);
>+	rcu_read_unlock();
> 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
> }
>
>@@ -702,9 +703,13 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
> 	struct list_head *iter;
> 	struct slave *slave;
>
>-	bond_for_each_slave(bond, slave, iter)
>-		if (SLAVE_AD_INFO(slave).aggregator.is_active)
>+	rcu_read_lock();
>+	bond_for_each_slave_rcu(bond, slave, iter)
>+		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
>+			rcu_read_unlock();
> 			return &(SLAVE_AD_INFO(slave).aggregator);
>+		}
>+	rcu_read_unlock();
>
> 	return NULL;
> }
>@@ -1471,7 +1476,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 	active = __get_active_agg(agg);
> 	best = (active && agg_device_up(active)) ? active : NULL;
>
>-	bond_for_each_slave(bond, slave, iter) {
>+	rcu_read_lock();
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		agg = &(SLAVE_AD_INFO(slave).aggregator);
>
> 		agg->is_active = 0;
>@@ -1505,7 +1511,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 		active->is_active = 1;
> 	}
>
>-	// if there is new best aggregator, activate it
>+	/* if there is new best aggregator, activate it */
> 	if (best) {
> 		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
> 			 best->aggregator_identifier, best->num_of_ports,
>@@ -1516,7 +1522,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 			 best->lag_ports, best->slave,
> 			 best->slave ? best->slave->dev->name : "NULL");
>
>-		bond_for_each_slave(bond, slave, iter) {
>+		bond_for_each_slave_rcu(bond, slave, iter) {
> 			agg = &(SLAVE_AD_INFO(slave).aggregator);
>
> 			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
>@@ -1526,10 +1532,10 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 				 agg->is_individual, agg->is_active);
> 		}
>
>-		// check if any partner replys
>+		/* check if any partner replys */
> 		if (best->is_individual) {
> 			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
>-				   best->slave ? best->slave->bond->dev->name : "NULL");
>+			best->slave ? best->slave->bond->dev->name : "NULL");

	This was not re-indented properly; the start of the line
("best->slave") was correctly placed; if you don't want it to wrap 80
columns, then the line needs to be split, not shifted to the left.

	-J

> 		}
>
> 		best->is_active = 1;
>@@ -1541,7 +1547,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 			 best->partner_oper_aggregator_key,
> 			 best->is_individual, best->is_active);
>
>-		// disable the ports that were related to the former active_aggregator
>+		/* disable the ports that were related to the former active_aggregator */
> 		if (active) {
> 			for (port = active->lag_ports; port;
> 			     port = port->next_port_in_aggregator) {
>@@ -1565,6 +1571,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
> 		}
> 	}
>
>+	rcu_read_unlock();
>+
> 	bond_3ad_set_carrier(bond);
> }
>
>@@ -2068,18 +2076,18 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 	struct slave *slave;
> 	struct port *port;
>
>-	read_lock(&bond->lock);
>+	rcu_read_lock();
>
>-	//check if there are any slaves
>+	/* check if there are any slaves */
> 	if (!bond_has_slaves(bond))
> 		goto re_arm;
>
>-	// check if agg_select_timer timer after initialize is timed out
>+	/* check if agg_select_timer timer after initialize is timed out */
> 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
>-		slave = bond_first_slave(bond);
>+		slave = bond_first_slave_rcu(bond);
> 		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
>
>-		// select the active aggregator for the bond
>+		/* select the active aggregator for the bond */
> 		if (port) {
> 			if (!port->slave) {
> 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
>@@ -2093,8 +2101,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 		bond_3ad_set_carrier(bond);
> 	}
>
>-	// for each port run the state machines
>-	bond_for_each_slave(bond, slave, iter) {
>+	/* for each port run the state machines */
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		port = &(SLAVE_AD_INFO(slave).port);
> 		if (!port->slave) {
> 			pr_warning("%s: Warning: Found an uninitialized port\n",
>@@ -2114,7 +2122,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 		ad_mux_machine(port);
> 		ad_tx_machine(port);
>
>-		// turn off the BEGIN bit, since we already handled it
>+		/* turn off the BEGIN bit, since we already handled it */
> 		if (port->sm_vars & AD_PORT_BEGIN)
> 			port->sm_vars &= ~AD_PORT_BEGIN;
>
>@@ -2122,9 +2130,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 	}
>
> re_arm:
>+	rcu_read_unlock();
> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>-
>-	read_unlock(&bond->lock);
> }
>
> /**
>@@ -2303,7 +2310,9 @@ int bond_3ad_set_carrier(struct bonding *bond)
> 	struct aggregator *active;
> 	struct slave *first_slave;
>
>-	first_slave = bond_first_slave(bond);
>+	rcu_read_lock();
>+	first_slave = bond_first_slave_rcu(bond);
>+	rcu_read_unlock();
> 	if (!first_slave)
> 		return 0;
> 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
>-- 
>1.8.2.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
