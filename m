From: Erik Nordmark <nordmark@sonic.net>
Subject: Re: [PATCH net] ipv6 addrconf: Implemented enhanced DAD (RFC7527)
Date: Wed, 16 Nov 2016 09:44:24 +0900
Message-ID: <99c143c3-9ec5-0f5f-44ed-6a4c60e723d8@sonic.net>
References: <5863cb78-0050-7b7e-f886-d4d6b2186f16@sonic.net>
 <1ba995e1-2af9-ce9b-7038-e8463dd2a0a8@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:39370 "EHLO c.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbcKPAoc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:44:32 -0500
In-Reply-To: <1ba995e1-2af9-ce9b-7038-e8463dd2a0a8@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/16 1:00 AM, Hannes Frederic Sowa wrote:
> On 15.11.2016 08:57, Erik Nordmark wrote:
>> Implemented RFC7527 Enhanced DAD.
>> IPv6 duplicate address detection can fail if there is some temporary
>> loopback of Ethernet frames. RFC7527 solves this by including a random
>> nonce in the NS messages used for DAD, and if an NS is received with the
>> same nonce it is assumed to be a looped back DAD probe and is ignored.
>> RFC7527 is disabled by default. Can be enabled by setting either one of
>> conf/{all,interface}/ipv6_rfc7527 to non-zero.
>>
>> Signed-off-by: Erik Nordmark <nordmark@arista.com>
>>
>> Index: linux-stable/Documentation/networking/ip-sysctl.txt
>> ===================================================================
>> --- linux-stable.orig/Documentation/networking/ip-sysctl.txt
>> +++ linux-stable/Documentation/networking/ip-sysctl.txt
>> @@ -1713,6 +1713,15 @@ drop_unsolicited_na - BOOLEAN
>>
>>       By default this is turned off.
>>
>> +ipv6_rfc7527 - BOOLEAN
> Could you rename the sysctl to enhanced_dad. As it will anyway show up
> in the ipv6/ directory hierarchy you don't need to prefix it with 'ipv6_'

Thanks for your careful review and in particular finding that 
uninitialized variable.

Yes, I'll rename the sysctl and all the other things to enhanced_dad.

>>       DEVCONF_MAX
>>   };
>>
>> Index: linux-stable/net/ipv6/addrconf.c
>> ===================================================================
>> --- linux-stable.orig/net/ipv6/addrconf.c
>> +++ linux-stable/net/ipv6/addrconf.c
>> @@ -217,6 +217,7 @@ static struct ipv6_devconf ipv6_devconf
>>       .use_oif_addrs_only    = 0,
>>       .ignore_routes_with_linkdown = 0,
>>       .keep_addr_on_down    = 0,
>> +    .ipv6_rfc7527           = 0,
> What is your reason to not enable this by default? I haven't fully
> studied the RFC, but it seems to be backwards compatible.

The concern is that while RFC4861 says that all unknown options must be 
silently ignored, RFC7527 isn't widely implemented yet. Hence if there 
is some broken implementation of RFC4861 it would fail to interoperate 
with Linux if we set this by default.

Perhaps I'm being too conservative?
In any case such broken implementations would need to be fixed to ignore 
unknown options.

>
>>   };
>>
>>   static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>> @@ -262,6 +263,7 @@ static struct ipv6_devconf ipv6_devconf_
>>       .use_oif_addrs_only    = 0,
>>       .ignore_routes_with_linkdown = 0,
>>       .keep_addr_on_down    = 0,
>> +    .ipv6_rfc7527           = 0,
>>   };
>>
>>   /* Check if a valid qdisc is available */
>> @@ -3722,12 +3724,18 @@ static void addrconf_dad_kick(struct ine
>>   {
>>       unsigned long rand_num;
>>       struct inet6_dev *idev = ifp->idev;
>> +    u64 nonce;
>>
>>       if (ifp->flags & IFA_F_OPTIMISTIC)
>>           rand_num = 0;
>>       else
>>           rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
>>
>> +    nonce = 0;
>> +    if (ifp->idev->cnf.ipv6_rfc7527 ||
>> + dev_net((ifp->idev)->dev)->ipv6.devconf_all->ipv6_rfc7527)
> idev should already be in scope, so you can simplify this conditional.

Yes; I'll fix.

>
>
>> +        get_random_bytes(&nonce, 6);
> Maybe:
>
> do
> 	get_random_bytes(&nonce, 6);
> while (!nonce);

Is that because get_random_bytes() will not fill in anything if there is 
insufficient entropy available?


>> @@ -745,6 +756,7 @@ static void ndisc_recv_ns(struct sk_buff
>>       int dad = ipv6_addr_any(saddr);
>>       bool inc;
>>       int is_router = -1;
>> +    u64 nonce;
>>
>>       if (skb->len < sizeof(struct nd_msg)) {
>>           ND_PRINTK(2, warn, "NS: packet too short\n");
>> @@ -789,6 +801,8 @@ static void ndisc_recv_ns(struct sk_buff
>>               return;
>>           }
>>       }
>> +    if (ndopts.nd_opts_nonce)
>> +        memcpy(&nonce, (u8 *)(ndopts.nd_opts_nonce + 1), 6);
> You only initialize 6 bytes of the nonce, with the other 2 being not
> initialized.
Mea culpa. Will fix.

>
>>       inc = ipv6_addr_is_multicast(daddr);
>>
>> @@ -797,6 +811,16 @@ static void ndisc_recv_ns(struct sk_buff
>>   have_ifp:
>>           if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>>               if (dad) {
>> +                if (nonce != 0 && ifp->dad_nonce == nonce) {
>> +                    /* Matching nonce if looped back */
>> +                    if (net_ratelimit())
>> +                        ND_PRINTK(2, notice,
>> +                              "%s: IPv6 DAD loopback for address %pI6c
>> nonce %llu ignored\n",
>> +                               ifp->idev->dev->name,
>> +                               &ifp->addr,
>> +                               nonce);
> If we print the nonce for debugging reasons, we should keep it in
> correct endianess on the wire vs. in the debug output.
How about printing it as colon-separated hex bytes since that is more 
clear than decimal?
Would follow the network byte order in the packet.

Thanks again for the review,
    Erik
