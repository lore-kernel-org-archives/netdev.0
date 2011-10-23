From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Sun, 23 Oct 2011 17:52:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1110231533410.1499@ja.ssi.bg>
References: <4EA3C91C.3090801@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50535 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755597Ab1JWOvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 10:51:14 -0400
In-Reply-To: <4EA3C91C.3090801@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 23 Oct 2011, Yan, Zheng wrote:

> There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtable).
> It makes xfrm4_fill_dst() modify wrong data structure.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
>  net/ipv4/xfrm4_policy.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index fc5368a..a0b4c5d 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -79,13 +79,13 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
>  	struct rtable *rt = (struct rtable *)xdst->route;
>  	const struct flowi4 *fl4 = &fl->u.ip4;
>  
> -	rt->rt_key_dst = fl4->daddr;
> -	rt->rt_key_src = fl4->saddr;
> -	rt->rt_key_tos = fl4->flowi4_tos;
> -	rt->rt_route_iif = fl4->flowi4_iif;
> -	rt->rt_iif = fl4->flowi4_iif;
> -	rt->rt_oif = fl4->flowi4_oif;
> -	rt->rt_mark = fl4->flowi4_mark;
> +	xdst->u.rt.rt_key_dst = fl4->daddr;
> +	xdst->u.rt.rt_key_src = fl4->saddr;
> +	xdst->u.rt.rt_key_tos = fl4->flowi4_tos;
> +	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;

	May be I'm missing something but I don't see where
flowi4_iif is set for the forwarding case. __xfrm_route_forward
calls xfrm_decode_session which does not appear to set
flowi4_iif. When providing fl4 for output routes flowi4_iif
is always set to 0, so it represents rt_route_iif. But
then there are 2 variants for __ip_route_output_key:

- ip_route_output_slow sets flowi4_iif to loopback and
flowi4_oif to outdev during lookup but never restores them
to original values. It is assumed that caller uses outdev
from dst, not from flowi4_oif.

- for cached route we do not update flowi4_iif and flowi4_oif
in __ip_route_output_key, so the resulting fl4 can not be
used for these values. I assume, the current rules are that
only fl4.saddr and daddr are updated while flowi4_iif and
flowi4_oif are not. It looks wrong flowi code to rely on them.

	Currently, we have 3 values for devices:

rt_iif: indev for input routes, resulting outdev for output routes
which plays the role as indev for loopback traffic.

rt_oif: original outdev key, 0 for input routes, can be 0 for
output routes if socket is not bound to oif

rt_route_iif: indev for input routes, 0 for output routes

	With above rules for flowi4_iif and flowi4_oif
it is impossible to select value for rt_iif from fl4.

	I don't know the xfrm code well, may be after the
mentioned change we damaged rt_oif and rt_route_iif values
for cached dst which can lead to using slow path all the time.
Even if rt_intern_hash() avoids caching similar dsts multiple
times, if cached entry is damaged we will add more and
more new entries after every damage.

> +	xdst->u.rt.rt_iif = fl4->flowi4_iif;
> +	xdst->u.rt.rt_oif = fl4->flowi4_oif;
> +	xdst->u.rt.rt_mark = fl4->flowi4_mark;
>  
>  	xdst->u.dst.dev = dev;
>  	dev_hold(dev);

Regards

--
Julian Anastasov <ja@ssi.bg>
