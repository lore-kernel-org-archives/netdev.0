From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Tue, 20 Dec 2011 21:23:53 -0800
Message-ID: <1324445033.20505.2.camel@joe2Laptop>
References: <4EF16AA3.2070303@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51147 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751730Ab1LUFXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 00:23:55 -0500
In-Reply-To: <4EF16AA3.2070303@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 13:12 +0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> If previous condition doesn't meet, the later check will be cancelled.
> So we don't need to do all the calculation.

Not sure about that.

> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
> ---
>  net/ipv4/route.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index f30112f..2872bfb 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2362,10 +2362,10 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  
>  	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
>  	     rth = rcu_dereference(rth->dst.rt_next)) {
> -		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
> -		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
> -		     (rth->rt_route_iif ^ iif) |
> -		     (rth->rt_key_tos ^ tos)) == 0 &&
> +		if (((__force u32)rth->rt_key_dst ^ (__force u32)daddr) == 0 &&
> +		    ((__force u32)rth->rt_key_src ^ (__force u32)saddr) == 0 &&
> +		    rth->rt_route_iif == iif &&
> +		    rth->rt_key_tos == tos &&
>  		    rth->rt_mark == skb->mark &&
>  		    net_eq(dev_net(rth->dst.dev), net) &&
>  		    !rt_is_expired(rth)) {

See:

commit c0b8c32b1c96afc9b32b717927330025cc1c501e
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Thu Apr 10 04:00:28 2008 -0700

    IPV4: use xor rather than multiple ands for route compare
    
    The comparison in ip_route_input is a hot path, by recoding the C
    "and" as bit operations, fewer conditional branches get generated
    so the code should be faster. Maybe someday Gcc will be smart
    enough to do this?
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Acked-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
