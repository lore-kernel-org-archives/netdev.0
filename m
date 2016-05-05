From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 03/13] net: l3mdev: Allow send on enslaved
 interface
Date: Thu, 5 May 2016 10:40:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1605051026380.2118@ja.home.ssi.bg>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com> <1462419210-10463-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52923 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756152AbcEEHkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 03:40:31 -0400
In-Reply-To: <1462419210-10463-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 4 May 2016, David Ahern wrote:

> Allow udp and raw sockets to send by oif that is an enslaved interface
> versus the l3mdev/VRF device. For example, this allows BFD to use ifindex
> from IP_PKTINFO on a receive to send a response without the need to
> convert to the VRF index. It also allows ping and ping6 to work when
> specifying an enslaved interface (e.g., ping -I swp1 <ip>) which is
> a natural use case.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  drivers/net/vrf.c   |  2 ++
>  net/ipv4/route.c    |  4 ++++
>  net/l3mdev/l3mdev.c | 20 +++++++++++++++-----
>  3 files changed, 21 insertions(+), 5 deletions(-)
> 

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 8c8c655bb2c4..a1f2830d8110 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2146,6 +2146,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>  	unsigned int flags = 0;
>  	struct fib_result res;
>  	struct rtable *rth;
> +	int master_idx;
>  	int orig_oif;
>  	int err = -ENETUNREACH;
>  
> @@ -2155,6 +2156,9 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>  
>  	orig_oif = fl4->flowi4_oif;
>  
> +	master_idx = l3mdev_master_ifindex_by_index(net, fl4->flowi4_oif);
> +	if (master_idx)
> +		fl4->flowi4_oif = master_idx;

	Changing the flowi4_oif at this point can have
bad effects. I remember for recent commit for  __mkroute_output
where the route caching is disabled if traffic is redirected
to loopback. I think, such change can affect the route
caching, for example, now we use nexthop on master_idx to
cache routes for orig_oif. Such problems with the caching
in the past always caused lookups to return wrong cached result
for other users. But this is only my fears, I don't know
the actual result of this change. May be you are trying to
change flowi4_oif at one place instead of every caller.

Regards
