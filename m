From: Erik Nordmark <nordmark@sonic.net>
Subject: Re: [PATCH net] ipv6 addrconf: Implemented enhanced DAD (RFC7527)
Date: Mon, 21 Nov 2016 09:10:14 -0800
Message-ID: <ff28e755-be89-c5de-8e1b-3f6adfb1225a@sonic.net>
References: <5863cb78-0050-7b7e-f886-d4d6b2186f16@sonic.net>
 <1ba995e1-2af9-ce9b-7038-e8463dd2a0a8@stressinduktion.org>
 <99c143c3-9ec5-0f5f-44ed-6a4c60e723d8@sonic.net>
 <b9854c18-f71c-2e71-d352-531bca72eeb4@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:46410 "EHLO d.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753343AbcKURKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 12:10:16 -0500
In-Reply-To: <b9854c18-f71c-2e71-d352-531bca72eeb4@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/16 10:49 PM, Hannes Frederic Sowa wrote:
> I thought about even removing the sysctl altogether and enable enhanced
> DAD by default. ;)
>
> I am in favor of enabling it by default.
>
> But given that there could be broken implementations out there, we
> should give users a choice and provide.
OK, I'll make it the default and send out a new version of the patch. I 
was told I should base the patch on net-next instead of linux-stable so 
I'll move it there.
>
> Could you always generate a nonce in the interface structure? You could
> check the sysctl in the send and receive path to attach and check the
> nonce. This has the advantage that you don't need to delete the
> interface and recreate it to enable/disable enhanced dad on an interface
> (also you can get away with the loop around get_random_bytes to make
> sure its value is not zero as we don't depend on a non-zero nonce
> variable to signal enaling of the feature, see below).
The nonce is per interface address and not per interface. Furthermore, 
the RFC says that on a retry of DAD the nodes will end up using a 
different nonce implying that even for the same interface address it 
should pick a different nonce for each DAD attempt.
Note that since there is no automatic retry of DAD (per RFC4862) and 
each try would check the current sysctl setting so I don't think 
pre-generating the nonce would change the behavior.

>> Is that because get_random_bytes() will not fill in anything if there is
>> insufficient entropy available?
> No, just because 0 is a possible return value from the random number
> generator. ;)

Ah - makes sense.

Thanks again for the review,
    Erik

>>>>        inc = ipv6_addr_is_multicast(daddr);
>>>>
>>>> @@ -797,6 +811,16 @@ static void ndisc_recv_ns(struct sk_buff
>>>>    have_ifp:
>>>>            if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>>>>                if (dad) {
>>>> +                if (nonce != 0 && ifp->dad_nonce == nonce) {
>>>> +                    /* Matching nonce if looped back */
>>>> +                    if (net_ratelimit())
>>>> +                        ND_PRINTK(2, notice,
>>>> +                              "%s: IPv6 DAD loopback for address %pI6c
>>>> nonce %llu ignored\n",
>>>> +                               ifp->idev->dev->name,
>>>> +                               &ifp->addr,
>>>> +                               nonce);
>>> If we print the nonce for debugging reasons, we should keep it in
>>> correct endianess on the wire vs. in the debug output.
>> How about printing it as colon-separated hex bytes since that is more
>> clear than decimal?
>> Would follow the network byte order in the packet.
> I would be totally fine with it. It will be probably easier to switch to
> a char[6] array for the nonce then.
