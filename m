From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next 1/5] bonding: keep bond interface carrier off until at least one active member
Date: Fri, 23 Jan 2015 19:15:36 -0800
Message-ID: <30475.1422069336@famine>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com> <20956.1421702213@famine> <54BF3786.9050505@cumulusnetworks.com> <5368.1421824444@famine> <54C2D39B.7070104@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:43666 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbAXDPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 22:15:42 -0500
In-reply-to: <54C2D39B.7070104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:

>On 1/21/15 2:14 AM, Jay Vosburgh wrote:
>> Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:
>>
>>> On 1/19/15 4:16 PM, Jay Vosburgh wrote:
>>>> Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:
>>>>
>>>>> From: Scott Feldman <sfeldma@cumulusnetworks.com>
>>>>>
>>>>> Bonding driver parameter min_links is now used to signal upper-level
>>>>> protocols of bond status. The way it works is if the total number of
>>>>> active members in slaves drops below min_links, the bond link carrier
>>>>> will go down, signaling upper levels that bond is inactive.  When active
>>>>> members returns to >= min_links, bond link carrier will go up (RUNNING),
>>>>> and protocols can resume.  When bond is carrier down, member ports are
>>>>> in stp fwd state blocked (rather than normal disabled state), so
>>>>> low-level ctrl protocols (LACP) can still get in and be processed by
>>>>> bonding driver.
>>>>
>>>> 	Presuming that "stp" is Spanning Tree, is the last sentence
>>>> above actually describing the behavior of a bridge port when a bond is
>>>> the member of the bridge?  I'm not sure I understand what "member ports"
>>>> refers to (bridge ports or bonding slaves).
>>>
>>> Ack, maybe replacing the last sentence with something like:
>>>   When bond is carrier down, the slave ports are only forwarding
>>>   low-level control protocols (e.g. LACP PDU) and discarding all other
>>>   packets.
>>
>> 	Ah, are you actually referring to the fact that slaves that are
>> up will still deliver packets to listeners that bind directly to the
>> slave or hook in through a rx_handler?  This is, in part, the
>> "RX_HANDLER_EXACT" business in bond_handle_frame and
>> __netif_receive_skb_core.
>>
>> 	The decision for that has nothing to do with the protocol; I
>> seem to recall that FCoE (or maybe it's iSCSI) does its regular traffic
>> reception this way (although via dev_add_pack, not an rx_handler) so it
>> can run traffic regardless of the bonding master's state.
>
>I see, it seems you are basically saying; the slaves are up but when the
>logical bond interface is carrier down there was no code changed in
>bond_handle_frame() to actually drop frames other than LACPDUs. So
>basically having this statement makes no sense until there is code to
>actually drop those additional frames.

	What I'm saying is that the fact that bond_handle_frame() does
not outright drop anything is a feature, not an oversight.  It's done
this way on purpose so that the slave device can be utilized separately
from its participation in the bond.  Off the top of my head, as I recall
this is used by LLDP, FCoE, and probably other "converged" Ethernet
facilities.  I believe some network monitoring tools use this property
as well, but I don't recall the details.

	Frames received on inactive slaves (which these active slaves
under a carrier-off bond are not; more on that in a bit) are marked as
such by the RX_HANDLER_EXACT return, and do not propagate up the stack
in the usual way, but are delivered only to packet listeners that bind
directly to the slave (typically via a dev_add_pack handler, which is
how LACPDUs were received prior to the rx_handler logic being
implemented).

	The bonding inactive slave receive logic used to work the other
way around; anything not explicitly needed by the bond itself would be
dropped in this particular case.  The "deliver to exact match" logic was
added later.

	Now, the possible hole here that I think you're alluding to is
that if the bond sets itself carrier down due to a min_links violation,
the slaves in the active aggregator are not inactive, and there's
nothing in the receive path to prevent incoming packets from being
processed normally if a receiving slave is still up.

	A quick test suggests that this is indeed the case; if I set up
a 802.3ad bond with min_links=3 and two slaves, incoming ICMP ECHOs to
the bond's IP appear to be received by icmp_echo, which calls
icmp_reply, which apparently fails.  I'm basing this conclusion on the
IcmpInErrors, IcmpInEchoReps, IcmpOutErrors, IcmpMsgInType8 and
IcmpMsgOutType0 stat counters all incrementing more or less in lock
step.  I haven't traced the code to see where it fails.

	I'm not sure exactly what ought to be done in that case; one
thought (which I have not tested) is bond_should_deliver_exact_match()
always returns true if the bonding master is carrier down.  

	Transmit appears to not function (at the bond level), so that
part doesn't appear to be an issue.

>>>>> @@ -2381,10 +2386,15 @@ int bond_3ad_set_carrier(struct bonding *bond)
>>>>> 		ret = 0;
>>>>> 		goto out;
>>>>> 	}
>>>>> +
>>>>> +	bond_for_each_slave_rcu(bond, slave, iter)
>>>>> +		if (SLAVE_AD_INFO(slave)->aggregator.is_active)
>>>>> +			active_slaves++;
>>>>> +
>>>>> 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
>>>>> -	if (active) {
>>>>> +	if (active && __agg_has_partner(active)) {
>>>>
>>>> 	Why "__agg_has_partner"?  Since the "else" of this clause is:
>>>>
>>>>           } else if (netif_carrier_ok(bond->dev)) {
>>>>                   netif_carrier_off(bond->dev);
>>>>           }
>>>>
>>>> 	I'm wondering if this will do the right thing for the case that
>>>> there are no LACP partners at all (e.g., the switch ports do not have
>>>> LACP enabled), in which case the active aggregator should be a single
>>>> "individual" port as a fallback, but will not have a partner.
>>>>
>>>> 	-J
>>>>
>>>
>>> I see your point. The initial thinking was the logical bond carrier should
>>> not be brought up until the bond has a partner and is ready to pass
>>> traffic, otherwise we start blackholing frames. Looking over the code it
>>> seems the aggregator.is_individual flag is only set to true when a slave
>>> is in half-duplex, this seems odd?
>>
>> 	The agg.is_individual flag and an "individual" aggregator are
>> subtly different things.
>>
>> 	The is_individual flag is part of the implementation of the
>> standard requirement that half duplex ports are not allowed to enable
>> LACP (and thus cannot aggregate, and end up as "Individual" in
>> standard-ese).  The standard capitalizes "Individual" when it describes
>> the cannot-aggregate property of a port (note that half duplex is only
>> one reason of many for a port being Individual).
>>
>> 	An "individual" aggregator (my usage of 802.1AX 5.3.6 (b)) is an
>> aggregator containing exactly one port that is Individual.  A port can
>> end up as Individual (for purposes of this discussion) either through
>> the is_individual business, or because the bonding port does run LACP,
>> but the link partner does not, and thus no LACPDUs are ever received.
>>
>> 	For either of the above cases (is_individual or no-LACP-parter),
>> then the active aggregator will be an "individual" aggregator, but will
>> not have a parter (__agg_has_partner() will be false).  The standard has
>> a bunch of verbiage about this in 802.1AX 5.3.5 - 5.3.9.
>>
>>> My initial thinking to alleviate the concern is something like the
>>> following:
>>>
>>> if (active && !SLAVE_AD_INFO(slave)->aggregator.is_individual &&
>>>     __agg_has_partner(active)) {
>>>     /* set carrier based on min_links */
>>> } else if (active && SLAVE_AD_INFO(slave)->aggregator.is_individual) {
>>>     /* set bond carrier state according to carrier state of slave */
>>> } else if (netif_carrier_ok(bond->dev)) {
>>>     netif_carrier_off(bond->dev);
>>> }
>>
>> 	I'm not sure you need to care about is_individual or
>> __agg_has_partner at all.  If either of those conditions is true for the
>> active aggregator, it will contain exactly one port, and so if min_links
>> is 2, you'll have carrier off, and if min_links is 1 or less you'll have
>> carrier on.
>>
>> 	If I'm reading the patch right, the real point (which isn't
>> really described very well in the change log) is that you're changing
>> the carrier decision to count only active ports in the active
>> aggregator, not the total number of ports as is currently done.
>>
>> 	I'm not sure why this change is needed:
>>
>> @@ -2381,10 +2386,15 @@ int bond_3ad_set_carrier(struct bonding *bond)
>>   		ret = 0;
>>   		goto out;
>>   	}
>> +
>> +	bond_for_each_slave_rcu(bond, slave, iter)
>> +		if (SLAVE_AD_INFO(slave)->aggregator.is_active)
>> +			active_slaves++;
>> +
>>   	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
>> -	if (active) {
>> +	if (active && __agg_has_partner(active)) {
>>   		/* are enough slaves available to consider link up? */
>> -		if (active->num_of_ports < bond->params.min_links) {
>> +		if (active_slaves < bond->params.min_links) {
>>   			if (netif_carrier_ok(bond->dev)) {
>>   				netif_carrier_off(bond->dev);
>>   				goto out;
>>
>> 	because a port (slave) that loses carrier or whose link partner
>> becomes unresponsive to LACPDUs will be removed from the aggregator.  As
>> I recall, there are no "inactive" ports in an aggregator; all of them
>> have to match in terms of capabilities.
>>
>> 	In other words, I'm unsure of when the count of is_active ports
>> will not match active->num_of_ports.
>>
>> 	Also, the other parts of the patch add some extra updates to the
>> carrier state when a port is enabled or disabled, e.g.,
>>
>> @@ -189,6 +189,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
>>   static inline void __disable_port(struct port *port)
>>   {
>>   	bond_set_slave_inactive_flags(port->slave, BOND_SLAVE_NOTIFY_LATER);
>> +	bond_3ad_set_carrier(port->slave->bond);
>>   }
>>
>> 	Again, I'm not sure why this is necessary, as the cases that
>> disable or enable a port will eventually call bond_3ad_set_carrier.  For
>> example, ad_agg_selection_logic will, when changing active aggregator,
>> individually disable all ports of the old active and then may
>> individually enable ports of the new active if necessary, and then
>> finally call bond_3ad_set_carrier.
>>
>> 	In what situations is the patch's behavior an improvement (i.e.,
>> is there a situation I'm missing that doesn't do it right)?
>
>I think the addition of bond_3ad_set_carrier() to both __enable_port() and
>__disable_port() were optimizations so the bond carrier transition would
>happen faster, though I am not certain.

	I get the impression that these patches have been around for a
while internally; it would be good to validate that there is an actual
performance change in the current mainline, since there does not seem to
be any functionality change.

>>
>> 	The last portion of the patch:
>>
>> --- a/drivers/net/bonding/bond_options.c
>> +++ b/drivers/net/bonding/bond_options.c
>> @@ -1181,6 +1181,7 @@ static int bond_option_min_links_set(struct bonding *bond,
>>   	netdev_info(bond->dev, "Setting min links value to %llu\n",
>>   		    newval->value);
>>   	bond->params.min_links = newval->value;
>> +	bond_set_carrier(bond);
>>
>>   	return 0;
>>   }
>>
>> 	does seem to fix a legitimate bug, in that when min_links is
>> changed, it does not take effect in real time.
>>
>>> Maybe I am missing something and there is a simpler option.
>>>
>>> Thinking about how to validate this, it seems having a bond with two
>>> slaves and both slaves in half-duplex will force an aggregator that is
>>> individual to be selected.
>>>
>>> Thoughts?
>>
>> 	That's one way, yes.  You'll also get an "individual" aggregator
>> if none of the link partners enable LACP.
>>
>
>It seems it might be better to drop the changes to __enable/disable_port
>and bond_3ad_set_carrier from this patch until more testing can be done
>from me, especially if you agree the other changes in this series are of
>benefit.

	I haven't looked at patch 3 in detail yet; patches 2, 4 and 5
appear to be ok.

	For this patch, the patch fragment immediately above (min_links
take effect immediately) looks good.  I think the rest of it still needs
some evaluation.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
