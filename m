From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH RFC v2 0/13] vti4: prepare namespace and interfamily support.
Date: Tue, 07 Jan 2014 20:45:17 +0100
Message-ID: <52CC594D.3030408@6wind.com>
References: <20131216091835.GQ31491@secunet.com> <52CC2714.5080600@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:33425 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbaAGTpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:45:32 -0500
Received: by mail-wg0-f48.google.com with SMTP id x13so595643wgg.27
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 11:45:31 -0800 (PST)
In-Reply-To: <52CC2714.5080600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2014 17:11, Christophe Gouault a =E9crit :
> On 12/16/2013 10:18 AM, Steffen Klassert wrote:
>> This patchset prepares vti4 for proper namespace and interfamily sup=
port.
>>
>> Currently the receive hook is in the middle of the decapsulation
>> process, some of the header pointers point still into the IPsec pack=
et
>> others point already into the decapsulated packet. This makes it
>> very unflexible and proper namespace and interfamily support can't
>> be done as it is.
>>
>> The patchset that implements an IPsec protocol multiplexer, so that =
vti
>> can register it's own receive path hooks. Further it makes the i_key
>> usable for vti and changes the vti4 code to do the following:
>>
>> vti uses the IPsec protocol multiplexer to register it's
>> own receive side hooks for ESP, AH and IPCOMP.
>>
>> Vti does the following on receive side:
>>
>> 1. Do an input policy check for the IPsec packet we received.
>>     This is required because this packet could be already
>>     processed by IPsec (tunnel in tunnel or a block policy
>>     is present), so an inbound policy check is needed.
>>
>> 2. Clean the skb to not leak informations on namespace
>>     transitions.
>>
>> 3. Mark the packet with the i_key. The policy and the state
>>     must match this key now. Policy and state belong to the vti
>>     namespace and policy enforcement is done at the further layers.
>>
>> 4. Call the generic xfrm layer to do decryption and decapsulation.
>>
>> 5. Wait for a callback from the xfrm layer to properly update
>>     the device statistics.
>
> Sorry for my late comments, I had to delay my tests due to Christmas =
and
> New Year's celebrations.
>
> I have a few comments about your proposed patches:
>
> In input, the vti tunnel processing does not follow the usual tunnel
> processing. Conventionally, the packets are first decapsulated, then
> only the skbuff interface is changed to the tunnel interface. In the =
vti
> code, the interface is changed before IPsec decryption, hence before
> decapsulation.
>
> It results in a configuration asymmetry when we later support cross
> netns: the outer SAs and SPs must be defined in the outer netns, whil=
e
> the inner SAs and SPs must be defined in the inner netns. This is a
> little disturbing.
>
>> On transmit side:
>>
>> 1. Mark the packet with the o_key. The policy and the state
>>     must match this key now.
>>
>> 2. Do a xfrm_lookup on the original packet with the mark applied.
>>
>> 3. Check if we got an IPsec route.
>>
>> 4. Clean the skb to not leak informations on namespace
>>     transitions.
>>
>> 5. Attach the dst_enty we got from the xfrm_lookup to the skb.
>>
>> 6. Call dst_output to do the IPsec processing.
>>
>> 7. Do the device statistics.
>
> In output, when the route points to a vti interface, the global SPD
> lookup is not bypassed: an SPD lookup is still performed for a global
> SPD (i.e. without applying the vti mark). Then only the packet can en=
ter
> the vti interface, in which a second SPD lookup is done, in the vti
> interface SPD (i.e. after applying the vti mark). Of course if the
> global SPD lookup returned a tunnel mode policy, then the packet may
> finally not enter the vti interface, because a new route is looked up
> after the IPsec encapsulation.
>
> My understanding of the vti interface interest is enabling to use
> routing (possibly dynamic routes) *instead* of complex security
> policies. And in this use case I expect that entering a vti interface
> will *override* the global policies (in the same manner as socket
> policies override the global policies).
>
> Otherwise, if we want to mix global and vti policies on the same
> machine, then we must carefully define global policies that do not ma=
tch
> traffic destined to vti interfaces.
>
> Note that setting the NOXFRM flag on the vti interface does not work
> around this issue, it disables both the global and vti SPD lookup and
> the traffic is finally dropped.

I finally found a way of bypassing the global SPD lookup, by explicitly=
=20
adding a global policy of higher priority than other global policies:

# bypass outbound SPD lookup if packet is destined to vti1
ip xfrm policy add dir out dev vti1 mark 0 priority 0 allow

>> Changes from v1:
>>
>> - Rebased to current net-next.
>> - Fix a rcu lockdep complaint in xfrm protocol
>> registration/deregistration.
>> - Fix usage of a ipv4 specific callback handler in generic code.
>> - Use skb_scrub_packet() to clear the skb in vti_rcv(), suggested by
>>    Nicolas Dichtel.
>> - Add support for IPCOMP.
>> - Support inter address family tunneling.
>>
>> I'd take this into the ipsec-next tree after some testing if noone
>> has further suggestions or objections.
>>
>> I have the ipv6 side ready too, this will be a separate patchset.
>> The ipv6 patchset has dependencies against the ipv4 patchset, so I
>> hold it back until we have got the ipv4 side merged.
>>
