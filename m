From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Fri, 25 Mar 2016 00:33:41 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603242201200.1795@ja.home.ssi.bg>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37006 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750772AbcCXWds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 18:33:48 -0400
In-Reply-To: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 24 Mar 2016, David Ahern wrote:

> Multipath route lookups should consider knowledge about next hops and not
> select a hop that is known to be failed.

...

> The failed path can be avoided by considering known neighbor information
> when selecting next hops. If the neighbor lookups fails we have no
> knowledge about the nexthop, so give it a shot. If there is an entry
> then only select the nexthop if the state is sane. This is similar to
> what fib_detect_death does for some single path cases.

	fib_detect_death works with alternatives and
the neighbor status is used as the only present info
in kernel.

	But for multipath routes we can also consider the
nexthops as "alternatives", so it depends on how one uses
the multipath mechanism. The ability to fallback to
another nexthop assumes one connection is allowed to
move from one ISP to another. What if the second ISP
decides to reject the connection? What we have is a
broken connection just because the retransmits
were diverted to wrong place in the hurry. So, the
nexthops can be compatible or incompatible. For your
setup they are, for others they are not.

	For multipath setups I recall for the following
possible cases:

1. Every packet from connection hits multipath route
and what we want is the connection to use only one
nexthop. If nexthop fails then the connection fails.
Latest changes for the multipath algorithm chose this
option: use hash to map traffic to nexthop and any
fallbacks to another nexthop are not allowed because
we should follow the hash mapping. Works when nexthops
use different ISPs.

2. Only the first packet hits multipath route. With
the help from CONNMARK all next packets from connection
use the same nexthop by using another unicast route.
The goal here is the multipath route to be used just to
balance connections. This works best when the nexthop
selection was random and not a hash based. This was
how the previous algorithm worked. Fallbacks are
desired because it is fine to select alive nexthop
for the first packet, but wrong for the next packets.

	My preference was for the random selection,
I don't know why we restricted the new algorithm. May be
because in the common case when just a single default
multipath route is created we want to use all nexthops
in a ideal world where all nexthops are alive.

	So, if the kernel used a random selection
your fallback algorithm should help. But it is fragile
for the simple setup with single default multipath route.
May be what we miss is the ability to choose between
random and hash-based selection. Then your patch may be
useful but only for setup 2 (multipath route hit only by
first packet). So, your patch may come with a sysctl var
that explains your current patch logic: "avoid failed nexthops,
never probe them, wait their failed entry to be expired by
neigh_periodic_work and just then we can use the nexthop
by creating new entry to probe the GW". Who will trigger
probes often enough to maintain fresh state?

	Also, one may argue that such decisions should
be done in user space. It is common the direct routers
to answer ARP even while their uplink is down. In
the common case, one may need to ping 2-3 indirect
gateways to decide if a path is alive and then to recreate
the default multipath route.

	More comments below...

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/fib_semantics.c | 34 ++++++++++++++++++++++++++++++++--
>  1 file changed, 32 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d97268e8ff10..28fc6700c2b1 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1563,13 +1563,43 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>  void fib_select_multipath(struct fib_result *res, int hash)
>  {
>  	struct fib_info *fi = res->fi;
> +	struct neighbour *n;
> +	int state;
>  
>  	for_nexthops(fi) {
>  		if (hash > atomic_read(&nh->nh_upper_bound))
>  			continue;
>  
> -		res->nh_sel = nhsel;
> -		return;
> +		state = NUD_NONE;
> +		n = neigh_lookup(&arp_tbl, &nh->nh_gw, fi->fib_dev);

	Sometimes nh_gw is a local IP, you can call
neigh_lookup (or a lockless RCU-BH variant) only for the
nh_scope == RT_SCOPE_LINK case, just like in fib_select_default.

> +		if (n) {
> +			state = n->nud_state;
> +			neigh_release(n);
> +		}
> +		if (!n || (state == NUD_REACHABLE) || (state & NUD_VALID)) {

	NUD_REACHABLE is part of NUD_VALID, so this is shorter:

	if (!n || (state & NUD_VALID)) {

> +			res->nh_sel = nhsel;
> +			return;
> +		}
> +	} endfor_nexthops(fi);
> +
> +	/* try the nexthops again, but covering the entries
> +	 * skipped by the hash
> +	 */
> +	fi = res->fi;
> +	for_nexthops(fi) {
> +		if (hash <= atomic_read(&nh->nh_upper_bound))

	This is dangerous, we can try a RTNH_F_DEAD entry
with nh_upper_bound = -1. This can work with 2 checks:

	if (hash <= atomic_read(&nh->nh_upper_bound))
		break;
	if (atomic_read(&nh->nh_upper_bound) < 0)
		continue;

> +			continue;
> +
> +		state = NUD_NONE;
> +		n = neigh_lookup(&arp_tbl, &nh->nh_gw, fi->fib_dev);
> +		if (n) {
> +			state = n->nud_state;
> +			neigh_release(n);
> +		}
> +		if (!n || (state == NUD_REACHABLE) || (state & NUD_VALID)) {
> +			res->nh_sel = nhsel;
> +			return;
> +		}
>  	} endfor_nexthops(fi);

	If all are failed why not use the nexthop that was
selected by the hash? Even if it is failed, new ARP probe
can succeed.

>  	/* Race condition: route has just become dead. */
> -- 
> 1.9.1

Regards
