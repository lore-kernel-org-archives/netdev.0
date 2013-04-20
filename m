From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: change xmit hash functions to use
 skb_flow_dissect
Date: Fri, 19 Apr 2013 17:57:15 -0700
Message-ID: <1366419435.16391.70.camel@edumazet-glaptop>
References: <1366412545-10829-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:34808 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965276Ab3DTA5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 20:57:18 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so12687dan.10
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 17:57:17 -0700 (PDT)
In-Reply-To: <1366412545-10829-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-20 at 01:02 +0200, Nikolay Aleksandrov wrote:
> As Eric suggested earlier, bonding hash functions can make good use of
> skb_flow_dissect. The old use cases should have the same results, but
> there should be good improvement for tunnel users mostly over IPv4.
> I've kept the IPv6 address hashing algorithm and thus if a tunnel is
> used over IPv6 then the addresses will be the same but there still can be
> improvement because the ports from skb_flow_dissect will be mixed in.
> This also fixes a problem with protocol == ETH_P_8021Q load balancing.

Are you sure ? we don't look at skb->vlan_tci

> In case of non-dissectable packet, the algorithms fall back to L2
> hashing.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 114 ++++++++++++++++++----------------------
>  1 file changed, 50 insertions(+), 64 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5e22126..722d8c1 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -77,6 +77,7 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  #include <net/pkt_sched.h>
> +#include <net/flow_keys.h>
>  #include "bonding.h"
>  #include "bond_3ad.h"
>  #include "bond_alb.h"
> @@ -3271,94 +3272,79 @@ static struct notifier_block bond_netdev_notifier = {
>  

> +
> +	layer4_xor = ntohs(flow.port16[0] ^ flow.port16[1]);
> +
> +	if (skb->protocol == htons(ETH_P_IPV6))
> +		return (layer4_xor ^ bond_ipv6_hash(skb)) % count;
> +	else
> +		return (layer4_xor ^ bond_ipv4_hash(&flow)) % count;
>  }
>  

Not sure its worth doing this test, as IPv6 addresses are mixed already.

So just

hash = (__force u32)flow.ports ^
       (__force u32)keys.dst ^
       (__force u32)keys.src;

hash ^= (hash >> 16);
hash ^= (hash >> 8);

return hash % count;
