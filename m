From: David Ward <david.ward@ll.mit.edu>
Subject: Re: [PATCH] Update Neighbor Cache when IPv6 RA is received on a router
Date: Sun, 16 Aug 2009 01:47:09 -0400
Message-ID: <4A879D5D.1010202@ll.mit.edu>
References: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu> <20090816120027.3d510139.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deliverator11.gatech.edu ([130.207.165.83]:48510 "EHLO
	deliverator11.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbZHPGQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 02:16:41 -0400
Received: from deliverator6.gatech.edu (deliverator6.gatech.edu [130.207.160.71])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by deliverator11.gatech.edu (Postfix) with ESMTP id BF7BD17FE6F
	for <netdev@vger.kernel.org>; Sun, 16 Aug 2009 01:47:48 -0400 (EDT)
In-Reply-To: <20090816120027.3d510139.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark, thank you very much for your response.

On 08/15/2009 10:30 PM, Mark Smith wrote:
> Hi David,
>
> On Sat, 15 Aug 2009 20:19:54 -0400
> David Ward <david.ward@ll.mit.edu> wrote:
>
>> When processing a received IPv6 Router Advertisement, the kernel
>> creates or updates an IPv6 Neighbor Cache entry for the sender --
>> but presently this does not occur if IPv6 forwarding is enabled
>> (net.ipv6.conf.*.forwarding = 1), or if IPv6 Router Advertisements
>> are not accepted (net.ipv6.conf.*.accept_ra = 0), because in these
>> cases processing of the Router Advertisement has already halted.
>>
>> This patch allows the Neighbor Cache to be updated in these cases,
>> while still avoiding any modification to routes or link parameters.
>>
>
> I'm a bit confused what benefit this has.

I apologize for not making that clear. It allows routers to utilize the 
Neighbor Cache to keep track of neighboring routers, which are learned 
about through the periodic Router Advertisements. By doing so, 
applications communicating through upper layers can make use of the 
Neighbor Cache, for example, as a basis for initiating dynamic peering 
between neighboring routers. Non-routers are already able to keep track 
of their neighboring routers in the Neighbor Cache; this simply allows 
routers to do the same.

This cannot be achieved through Neighbor Advertisements, because they 
are usually sent in response to a direct Neighbor Solicitation, while 
Router Advertisements are periodically multicast to the all-nodes group.

> Is the intent to avoid a Neighbor Solicitation being triggered when a
> recent RA has already provided the router's link local address,
> therefore reducing by a small mount ND traffic?

No. This patch does not preclude the need to send a Neighbor 
Solicitation to another router to determine reachability. That would 
violate RFC 4861, which states that a Router Advertisement "MUST NOT be 
treated as a reachability confirmation".

In the dynamic router peering scenario, the Neighbor Cache entry could 
be used to learn that the neighboring router exists and is a potential 
peer -- but reachability must still be determined before a peering 
session could actually be attempted.

>> This continues to satisfy RFC 4861, since any entry created in the
>> Neighbor Cache as the result of a received Router Advertisement is
>> still placed in the STALE state.
>>
>> Signed-off-by: David Ward <david.ward@ll.mit.edu>
>> ---
>>  net/ipv6/ndisc.c |   14 ++++++++------
>>  1 files changed, 8 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index 1ba42bd..44b4c87 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -1151,10 +1151,6 @@ static void ndisc_router_discovery(struct
>> sk_buff *skb)
>>                 skb->dev->name);
>>          return;
>>      }
>> -    if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra) {
>> -        in6_dev_put(in6_dev);
>> -        return;
>> -    }
>>
>>      if (!ndisc_parse_options(opt, optlen, &ndopts)) {
>>          in6_dev_put(in6_dev);
>> @@ -1163,6 +1159,10 @@ static void ndisc_router_discovery(struct
>> sk_buff *skb)
>>          return;
>>      }
>>
>> +    /* skip route and link configuration on routers */
>> +    if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
>> +        goto skip_linkparms;
>> +
>>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>>      /* skip link-specific parameters from interior routers */
>>      if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
>> @@ -1283,9 +1283,7 @@ skip_defrtr:
>>          }
>>      }
>>
>> -#ifdef CONFIG_IPV6_NDISC_NODETYPE
>>  skip_linkparms:
>> -#endif
>>
>>      /*
>>       *    Process options.
>> @@ -1312,6 +1310,10 @@ skip_linkparms:
>>                   NEIGH_UPDATE_F_ISROUTER);
>>      }
>>
>> +    /* skip route and link configuration on routers */
>> +    if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra)
>> +        goto out;
>> +
>>  #ifdef CONFIG_IPV6_ROUTE_INFO
>>      if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
>>          struct nd_opt_hdr *p;
>> --
>> 1.6.0.4
