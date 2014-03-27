From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu, 27 Mar 2014 06:06:18 +0100
Message-ID: <20140327050618.GK22086@order.stressinduktion.org>
References: <20140326155047.GG22086@order.stressinduktion.org> <20140326160503.93B6FE6E05@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34259 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaC0FGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 01:06:20 -0400
Content-Disposition: inline
In-Reply-To: <20140326160503.93B6FE6E05@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 05:05:03PM +0100, Michal Kubecek wrote:
> If an IPv6 host route with metrics exists, an attempt to add a
> new route for the same target with different metrics fails but
> rewrites the metrics anyway:
> 
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  rto_min lock 1s
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1500
> RTNETLINK answers: File exists
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  rto_min lock 1.5s
> 
> This is caused by all IPv6 host routes using the metrics in
> their inetpeer (or the shared default). This also holds for the
> new route created in ip6_route_add() which shares the metrics
> with the already existing route and thus ip6_route_add()
> rewrites the metrics even if the new route ends up not being
> used at all.
> 
> Another problem is that old metrics in inetpeer can reappear
> unexpectedly for a new route, e.g.
> 
> 12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
> 12sp0:~ # ip route del fec0::1
> 12sp0:~ # ip route add fec0::1 dev eth0
> 12sp0:~ # ip route change fec0::1 dev eth0 hoplimit 10
> 12sp0:~ # ip -6 route show
> fe80::/64 dev eth0  proto kernel  metric 256
> fec0::1 dev eth0  metric 1024  hoplimit 10 rto_min lock 1s
> 
> Resolve the first problem by moving the setting of metrics down
> into fib6_add_rt2node() to the point we are sure we are
> inserting the new route into the tree. Second problem is
> addressed by introducing new flag DST_KEEP_METRICS which is set
> for a new host route in ip6_route_add() and makes
> ipv6_cow_metrics() always overwrite the metrics in inetpeer
> (even if they are not "new"); it is reset after that.
> 
> v4: fix a typo making a condition always true (thanks to Hannes
> Frederic Sowa)
> 
> v3: rewritten based on David Miller's idea to move setting the
> metrics (and allocation in non-host case) down to the point we
> already know the route is to be inserted. Also rebased to
> net-next as it is quite late in the cycle.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  include/net/dst.h     |  1 +
>  include/net/ip6_fib.h |  3 ++-
>  net/ipv6/ip6_fib.c    | 47 ++++++++++++++++++++++++++++++++++++++++++++---
>  net/ipv6/route.c      | 41 +++++++++--------------------------------
>  4 files changed, 56 insertions(+), 36 deletions(-)
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index e01a826..8cf6772 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -57,6 +57,7 @@ struct dst_entry {
>  #define DST_FAKE_RTABLE		0x0040
>  #define DST_XFRM_TUNNEL		0x0080
>  #define DST_XFRM_QUEUE		0x0100
> +#define DST_KEEP_METRICS	0x0400

Minor nit: 0x0200

You jumped over one bit.

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index fba54a4..4e5b19e 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -149,8 +149,10 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
>  		unsigned long prev, new;
>  
>  		p = peer->metrics;
> -		if (inet_metrics_new(peer))
> +		if (inet_metrics_new(peer) || (dst->flags & DST_KEEP_METRICS)) {
>  			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> +			dst->flags &= ~DST_KEEP_METRICS;
> +		}
>  

I wonder if we can make this more concurrency friendly:

The idea that came to my mind would be to store KEEP_METRICS flag in the
metrics pointer and introduce new DST_METRICS_FORCE_OVERWRITE flag like
DST_METRICS_READ_ONLY.

__DST_METRICS_PTR would have to mask it out, too (so would the check in
dst_metrics_write_ptr).

Then cmpxchg would atomically change status of KEEP_METRICS flag, too.

In fib6_commit_metrics we could then add the flag somehow if dst is
DST_HOST and mx != NULL.

Just a thought, depends if this feature would be useful for other
users, too.

Greetings,

  Hannes
