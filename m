From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/5] bonding: keep bond interface carrier off
 until at least one active member
Date: Wed, 21 Jan 2015 00:22:14 -0500
Message-ID: <54BF3786.9050505@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com> <20956.1421702213@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:35682 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbAUFWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 00:22:16 -0500
Received: by mail-qc0-f177.google.com with SMTP id p6so9444960qcv.8
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 21:22:15 -0800 (PST)
In-Reply-To: <20956.1421702213@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 4:16 PM, Jay Vosburgh wrote:
> Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:
>
>> From: Scott Feldman <sfeldma@cumulusnetworks.com>
>>
>> Bonding driver parameter min_links is now used to signal upper-level
>> protocols of bond status. The way it works is if the total number of
>> active members in slaves drops below min_links, the bond link carrier
>> will go down, signaling upper levels that bond is inactive.  When active
>> members returns to >= min_links, bond link carrier will go up (RUNNING),
>> and protocols can resume.  When bond is carrier down, member ports are
>> in stp fwd state blocked (rather than normal disabled state), so
>> low-level ctrl protocols (LACP) can still get in and be processed by
>> bonding driver.
>
> 	Presuming that "stp" is Spanning Tree, is the last sentence
> above actually describing the behavior of a bridge port when a bond is
> the member of the bridge?  I'm not sure I understand what "member ports"
> refers to (bridge ports or bonding slaves).

Ack, maybe replacing the last sentence with something like:
   When bond is carrier down, the slave ports are only forwarding
   low-level control protocols (e.g. LACP PDU) and discarding all other
   packets.

>> @@ -2381,10 +2386,15 @@ int bond_3ad_set_carrier(struct bonding *bond)
>> 		ret = 0;
>> 		goto out;
>> 	}
>> +
>> +	bond_for_each_slave_rcu(bond, slave, iter)
>> +		if (SLAVE_AD_INFO(slave)->aggregator.is_active)
>> +			active_slaves++;
>> +
>> 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
>> -	if (active) {
>> +	if (active && __agg_has_partner(active)) {
>
> 	Why "__agg_has_partner"?  Since the "else" of this clause is:
>
>          } else if (netif_carrier_ok(bond->dev)) {
>                  netif_carrier_off(bond->dev);
>          }
>
> 	I'm wondering if this will do the right thing for the case that
> there are no LACP partners at all (e.g., the switch ports do not have
> LACP enabled), in which case the active aggregator should be a single
> "individual" port as a fallback, but will not have a partner.
>
> 	-J
>

I see your point. The initial thinking was the logical bond carrier 
should not be brought up until the bond has a partner and is ready to 
pass traffic, otherwise we start blackholing frames. Looking over the 
code it seems the aggregator.is_individual flag is only set to true when 
a slave is in half-duplex, this seems odd?

My initial thinking to alleviate the concern is something like the 
following:

if (active && !SLAVE_AD_INFO(slave)->aggregator.is_individual &&
     __agg_has_partner(active)) {
     /* set carrier based on min_links */
} else if (active && SLAVE_AD_INFO(slave)->aggregator.is_individual) {
     /* set bond carrier state according to carrier state of slave */
} else if (netif_carrier_ok(bond->dev)) {
     netif_carrier_off(bond->dev);
}

Maybe I am missing something and there is a simpler option.

Thinking about how to validate this, it seems having a bond with two 
slaves and both slaves in half-duplex will force an aggregator that is 
individual to be selected.

Thoughts?

-Jon
