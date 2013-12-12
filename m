From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v5 7/11] bonding: rebuild the lock use for bond_3ad_state_machine_handler()
Date: Thu, 12 Dec 2013 13:35:18 -0800
Message-ID: <13092.1386884118@death.nxdomain>
References: <52A7F18A.7060308@huawei.com> <8562.1386816086@death.nxdomain> <52A9724A.7030700@huawei.com> <52A9AFEC.50600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:59145 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab3LLVf0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:35:26 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 12 Dec 2013 14:35:25 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7D5223E40045
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 14:35:23 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBCLZNiI11796782
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 22:35:23 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rBCLcP5Y019518
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 14:38:26 -0700
In-reply-to: <52A9AFEC.50600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dthxman@gmail.com> wrote:

>=E4=BA=8E 2013/12/12 16:22, Ding Tianhong =E5=86=99=E9=81=93:
>> On 2013/12/12 10:41, Jay Vosburgh wrote:
>>> Ding Tianhong <dingtianhong@huawei.com> wrote:
>>>
>>>> The bond_3ad_state_machine_handler() use the bond lock to protect
>>>> the bond slave list and slave port, so as the before patch said,
>>>> I remove bond lock and replace with RCU.
>>>>
>>>> There was a lot of function need RCU protect, I have two choice
>>>> to make the function in RCU-safe, (1) create new similar functions
>>>> and make the bond slave list in RCU. (2) modify the existed functi=
ons
>>>> and make them in read-side critical section, because the RCU
>>>> read-side critical sections may be nested.
>>>>
>>>> I choose (2) because it is no need to create more similar function=
s.
>>>
>>> 	A few comments:
>>>
>>> 	First, the large number of comment-only changes make the actual
>>> functional changes harder to follow (plus there's one indenting mis=
take,
>>> noted in the patch, below).
>>>
>>> 	I looked through the locking for handling port->sm_vars and
>>> aggregator->lag_ports after the patches are applied.
>>>
>>> 	I don't see anything that will mutex changes to
>>> aggregator->lag_ports between bond_3ad_state_machine_handler and
>>> bond_3ad_unbind_slave.  These functions will modify ->lag_ports eit=
her
>>> directly (unbind only) or via ad_agg_selection_logic (both function=
s).
>>>
>>> 	Even though the slave has been removed from the list by the time
>>> the state machine runs, it appears to be possible for both function=
s to
>>> manipulate the same aggregator->lag_ports by finding the aggregator=
 via
>>> two different ports that are both members of that aggregator (i.e.,=
 port
>>> A of the agg is being unbound, and port B of the agg is running its
>>> state machine).
>>>
>>> 	The bond_3ad_state_machine_handler calls ad_agg_selection_logic
>>> with either just rcu_read_lock, or rcu_read_lock plus a a port's st=
ate
>>> machine lock (for the case that ad_port_selection_logic calls
>>> ad_agg_selection_logic).
>>>
>>> 	The bond_3ad_unbind_slave calls ad_agg_selection_logic or
>>> modifies lag_ports directly while holding RTNL (inherited from its
>>> caller) and bond->lock for write.
>>>
>>> 	Prior to this patch, state_machine_handler additionally held
>>> bond->lock for read, thus bond->lock provided mutexing between the =
two.
>>>
>>=20
>> Excellent and detailed analysis, agreed.
>>=20
>
>Hi Jay:
>
>I could not fix this when remove the bond lock and only add RCU here,
>so I think the bond lock should recover here, and together with
>RCU, what do you think of it, do you have any ideas about it?

	I do not see any simple choice other than adding the bond->lock
back to state_machine_handler.  The state machine is not on the transmi=
t
path, so it should not have any substantial effect on performance.

>Regards
>Ding
>
>>> 	The bond_3ad_lacpdu_recv function still (after your patches are
>>> applied) calls bond_3ad_rx_indication with bond->lock held for read=
;
>>> this (along with __get_state_machine_lock) protects ->sm_vars in
>>> ad_rx_machine.  ad_rx_machine does not modify lag_ports, only sm_va=
rs.
>>> I think this is safe, particularly against race with _unbind_slave,=
 as
>>> the rx handler is cleared prior to unbind for exactly this reason.
>>> Unless its possible for the rx_indication to already be running bef=
ore
>>> the removal of rx_handler and still be running when _unbind_slave i=
s
>>> called; I'm not sure on this one, anybody have a definitive answer?
>>>
>>=20
>> I think it will not happen, the removal of rx_handle will not happen=
 until
>> the RCU read-side critical section over, just see netdev_rx_handler_=
unregister(),
>> there is synchronize_net(), and the rx_handler already in read-side =
critical section,
>> so the when _unbind_slave is called, the rx_handler is finish and cl=
ean, nothing
>> will happen, if I miss something, pls tell me.

	No, I had forgotten about the synchronize_net; the code should
be fine.

>>> 	One place that should have a comment updated is in
>>> __bond_release_one:
>>>
>>> __bond_release_one(...)
>>> [...]
>>> 	/* Inform AD package of unbinding of slave. */
>>> 	if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
>>> 		/* must be called before the slave is
>>> 		 * detached from the list
>>> 		 */
>>> 		bond_3ad_unbind_slave(slave);
>>> 	}
>>>
>>> 	This comment is no longer correct, as by this point, the slave
>>> has already been unlinked. =20
>> yes, the comment is too old and need to modify, I will fix it.
>>=20
>>> This unlinking appears to protect the
>>> ->sm_vars of the port from being modified concurrently by unbind_sl=
ave
>>> and state_machine (as in the above case) because ->sm_vars changes =
are
>>> limited to the port being operated on only.  I'm not 100% sure on t=
his,
>>> though, if the state_machine could race there and be operating on t=
he
>>> same slave (port) at the time _unbind is also doing so.
>>=20
>> the state_machine is in read-side critical sector, when the _unbind =
start,
>> the slave already unlink from bond, and at this time, if the state_m=
achine
>> is operating, the bond will not see the slave again, so nothing bad =
will occur.
>>=20
>>>
>>> 	Lastly, bond_3ad_adapter_speed_changed or _duplex_changed are
>>> called with RTNL only, and those functions will modify port->sm_var=
s
>>> with no further locking (they are not mutexed against 3ad_state_mac=
hine
>>> or incoming LACPDUs, which do not hold RTNL).  This one actually lo=
oks
>>> like a preexisting problem, not new to this patch.
>>>
>>=20
>> good catch, it need to be fixed this time, bond_3ad_handle_link_chan=
ge still
>> has the problem and the problem should be fix in net, not net-next, =
I will
>> send it later.

	I agree with leaving this for later; it's not a critical fix.
The code has had this bug since day one, and to my knowledge it has
never been hit.  Changes to duplex or speed will be very rare, and it
would have to race with the state machine simultaneously updating
port->sm_vars.

	-J


>>>> The nots in the function is still too old, clean up the nots.
>>>>
>>>> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>>>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>> drivers/net/bonding/bond_3ad.c | 53 ++++++++++++++++++++++++------=
------------
>>>> 1 file changed, 31 insertions(+), 22 deletions(-)
>>>>
>>>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/=
bond_3ad.c
>>>> index 187b1b7..d935da5 100644
>>>> --- a/drivers/net/bonding/bond_3ad.c
>>>> +++ b/drivers/net/bonding/bond_3ad.c
>>>> @@ -147,11 +147,12 @@ static inline struct aggregator *__get_first=
_agg(struct port *port)
>>>> 	struct bonding *bond =3D __get_bond_by_port(port);
>>>> 	struct slave *first_slave;
>>>>
>>>> -	// If there's no bond for this port, or bond has no slaves
>>>> +	/* If there's no bond for this port, or bond has no slaves */
>>>> 	if (bond =3D=3D NULL)
>>>> 		return NULL;
>>>> -	first_slave =3D bond_first_slave(bond);
>>>> -
>>>> +	rcu_read_lock();
>>>> +	first_slave =3D bond_first_slave_rcu(bond);
>>>> +	rcu_read_unlock();
>>>> 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : N=
ULL;
>>>> }
>>>>
>>>> @@ -702,9 +703,13 @@ static struct aggregator *__get_active_agg(st=
ruct aggregator *aggregator)
>>>> 	struct list_head *iter;
>>>> 	struct slave *slave;
>>>>
>>>> -	bond_for_each_slave(bond, slave, iter)
>>>> -		if (SLAVE_AD_INFO(slave).aggregator.is_active)
>>>> +	rcu_read_lock();
>>>> +	bond_for_each_slave_rcu(bond, slave, iter)
>>>> +		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
>>>> +			rcu_read_unlock();
>>>> 			return &(SLAVE_AD_INFO(slave).aggregator);
>>>> +		}
>>>> +	rcu_read_unlock();
>>>>
>>>> 	return NULL;
>>>> }
>>>> @@ -1471,7 +1476,8 @@ static void ad_agg_selection_logic(struct ag=
gregator *agg)
>>>> 	active =3D __get_active_agg(agg);
>>>> 	best =3D (active && agg_device_up(active)) ? active : NULL;
>>>>
>>>> -	bond_for_each_slave(bond, slave, iter) {
>>>> +	rcu_read_lock();
>>>> +	bond_for_each_slave_rcu(bond, slave, iter) {
>>>> 		agg =3D &(SLAVE_AD_INFO(slave).aggregator);
>>>>
>>>> 		agg->is_active =3D 0;
>>>> @@ -1505,7 +1511,7 @@ static void ad_agg_selection_logic(struct ag=
gregator *agg)
>>>> 		active->is_active =3D 1;
>>>> 	}
>>>>
>>>> -	// if there is new best aggregator, activate it
>>>> +	/* if there is new best aggregator, activate it */
>>>> 	if (best) {
>>>> 		pr_debug("best Agg=3D%d; P=3D%d; a k=3D%d; p k=3D%d; Ind=3D%d; A=
ct=3D%d\n",
>>>> 			 best->aggregator_identifier, best->num_of_ports,
>>>> @@ -1516,7 +1522,7 @@ static void ad_agg_selection_logic(struct ag=
gregator *agg)
>>>> 			 best->lag_ports, best->slave,
>>>> 			 best->slave ? best->slave->dev->name : "NULL");
>>>>
>>>> -		bond_for_each_slave(bond, slave, iter) {
>>>> +		bond_for_each_slave_rcu(bond, slave, iter) {
>>>> 			agg =3D &(SLAVE_AD_INFO(slave).aggregator);
>>>>
>>>> 			pr_debug("Agg=3D%d; P=3D%d; a k=3D%d; p k=3D%d; Ind=3D%d; Act=3D=
%d\n",
>>>> @@ -1526,10 +1532,10 @@ static void ad_agg_selection_logic(struct =
aggregator *agg)
>>>> 				 agg->is_individual, agg->is_active);
>>>> 		}
>>>>
>>>> -		// check if any partner replys
>>>> +		/* check if any partner replys */
>>>> 		if (best->is_individual) {
>>>> 			pr_warning("%s: Warning: No 802.3ad response from the link part=
ner for any adapters in the bond\n",
>>>> -				   best->slave ? best->slave->bond->dev->name : "NULL");
>>>> +			best->slave ? best->slave->bond->dev->name : "NULL");
>>>
>>> 	This was not re-indented properly; the start of the line
>>> ("best->slave") was correctly placed; if you don't want it to wrap =
80
>>> columns, then the line needs to be split, not shifted to the left.
>>>
>>> 	-J
>>>
>>=20
>> yes, I miss it.
>>=20
>> Best Regards
>> Ding
>>=20
>>>> 		}
>>>>
>>>> 		best->is_active =3D 1;
>>>> @@ -1541,7 +1547,7 @@ static void ad_agg_selection_logic(struct ag=
gregator *agg)
>>>> 			 best->partner_oper_aggregator_key,
>>>> 			 best->is_individual, best->is_active);
>>>>
>>>> -		// disable the ports that were related to the former active_agg=
regator
>>>> +		/* disable the ports that were related to the former active_agg=
regator */
>>>> 		if (active) {
>>>> 			for (port =3D active->lag_ports; port;
>>>> 			     port =3D port->next_port_in_aggregator) {
>>>> @@ -1565,6 +1571,8 @@ static void ad_agg_selection_logic(struct ag=
gregator *agg)
>>>> 		}
>>>> 	}
>>>>
>>>> +	rcu_read_unlock();
>>>> +
>>>> 	bond_3ad_set_carrier(bond);
>>>> }
>>>>
>>>> @@ -2068,18 +2076,18 @@ void bond_3ad_state_machine_handler(struct=
 work_struct *work)
>>>> 	struct slave *slave;
>>>> 	struct port *port;
>>>>
>>>> -	read_lock(&bond->lock);
>>>> +	rcu_read_lock();
>>>>
>>>> -	//check if there are any slaves
>>>> +	/* check if there are any slaves */
>>>> 	if (!bond_has_slaves(bond))
>>>> 		goto re_arm;
>>>>
>>>> -	// check if agg_select_timer timer after initialize is timed out
>>>> +	/* check if agg_select_timer timer after initialize is timed out=
 */
>>>> 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond)=
=2Eagg_select_timer)) {
>>>> -		slave =3D bond_first_slave(bond);
>>>> +		slave =3D bond_first_slave_rcu(bond);
>>>> 		port =3D slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
>>>>
>>>> -		// select the active aggregator for the bond
>>>> +		/* select the active aggregator for the bond */
>>>> 		if (port) {
>>>> 			if (!port->slave) {
>>>> 				pr_warning("%s: Warning: bond's first port is uninitialized\n"=
,
>>>> @@ -2093,8 +2101,8 @@ void bond_3ad_state_machine_handler(struct w=
ork_struct *work)
>>>> 		bond_3ad_set_carrier(bond);
>>>> 	}
>>>>
>>>> -	// for each port run the state machines
>>>> -	bond_for_each_slave(bond, slave, iter) {
>>>> +	/* for each port run the state machines */
>>>> +	bond_for_each_slave_rcu(bond, slave, iter) {
>>>> 		port =3D &(SLAVE_AD_INFO(slave).port);
>>>> 		if (!port->slave) {
>>>> 			pr_warning("%s: Warning: Found an uninitialized port\n",
>>>> @@ -2114,7 +2122,7 @@ void bond_3ad_state_machine_handler(struct w=
ork_struct *work)
>>>> 		ad_mux_machine(port);
>>>> 		ad_tx_machine(port);
>>>>
>>>> -		// turn off the BEGIN bit, since we already handled it
>>>> +		/* turn off the BEGIN bit, since we already handled it */
>>>> 		if (port->sm_vars & AD_PORT_BEGIN)
>>>> 			port->sm_vars &=3D ~AD_PORT_BEGIN;
>>>>
>>>> @@ -2122,9 +2130,8 @@ void bond_3ad_state_machine_handler(struct w=
ork_struct *work)
>>>> 	}
>>>>
>>>> re_arm:
>>>> +	rcu_read_unlock();
>>>> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>>>> -
>>>> -	read_unlock(&bond->lock);
>>>> }
>>>>
>>>> /**
>>>> @@ -2303,7 +2310,9 @@ int bond_3ad_set_carrier(struct bonding *bon=
d)
>>>> 	struct aggregator *active;
>>>> 	struct slave *first_slave;
>>>>
>>>> -	first_slave =3D bond_first_slave(bond);
>>>> +	rcu_read_lock();
>>>> +	first_slave =3D bond_first_slave_rcu(bond);
>>>> +	rcu_read_unlock();
>>>> 	if (!first_slave)
>>>> 		return 0;
>>>> 	active =3D __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregat=
or));
>>>> --=20
>>>> 1.8.2.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
