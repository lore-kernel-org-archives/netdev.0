From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] ipv6: enforce egress device match in per table
 nexthop lookups
Date: Thu, 23 Jun 2016 08:20:20 -0600
Message-ID: <786d9687-922f-6e89-c281-ddacae8f83b2@cumulusnetworks.com>
References: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Beniamino Galvani <bgalvani@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35593 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFWOUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 10:20:22 -0400
Received: by mail-io0-f170.google.com with SMTP id f30so72678713ioj.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 07:20:22 -0700 (PDT)
In-Reply-To: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/16 7:25 AM, Paolo Abeni wrote:
> with the commit 8c14586fc320 ("net: ipv6: Use passed in table for
> nexthop lookups"), net hop lookup is first performed on route creation
> in the passed-in table.
> However device match is not enforced in table lookup, so the found
> route can be later discarded due to egress device mismatch and no
> global lookup will be performed.
> This cause the following to fail:
>
> ip link add dummy1 type dummy
> ip link add dummy2 type dummy
> ip link set dummy1 up
> ip link set dummy2 up
> ip route add 2001:db8:8086::/48 dev dummy1 metric 20
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy1 metric 20
> ip route add 2001:db8:8086::/48 dev dummy2 metric 21
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy2 metric 21
> RTNETLINK answers: No route to host
>
> This change fixes the issue enforcing device lookup in
> ip6_nh_lookup_table()
>
> v1->v2: updated commit message title
>
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Reported-and-tested-by: Beniamino Galvani <bgalvani@redhat.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv6/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 969913d..520b788 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1782,7 +1782,7 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
>  	};
>  	struct fib6_table *table;
>  	struct rt6_info *rt;
> -	int flags = 0;
> +	int flags = RT6_LOOKUP_F_IFACE;
>
>  	table = fib6_get_table(net, cfg->fc_table);
>  	if (!table)
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>
