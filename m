From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net-ipv6: on device mtu change do not add mtu to mtu-less
 routes
Date: Mon, 7 Nov 2016 20:28:29 +0100
Message-ID: <940a49a5-32e3-6da8-21cf-7bce62eec5f1@stressinduktion.org>
References: <1478296314-32396-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:34638 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751218AbcKGT2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 14:28:32 -0500
In-Reply-To: <1478296314-32396-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.11.2016 22:51, Maciej Żenczykowski wrote:
> From: Maciej Żenczykowski <maze@google.com>
> 
> Routes can specify an mtu explicitly or inherit the mtu from
> the underlying device - this inheritance is implemented in
> dst->ops->mtu handlers ip6_mtu() and ip6_blackhole_mtu().
> 
> Currently changing the mtu of a device adds mtu explicitly
> to routes using that device.
> 
> ie.
>   # ip link set dev lo mtu 65536
>   # ip -6 route add local 2000::1 dev lo
>   # ip -6 route get 2000::1
>   local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
> 
>   # ip link set dev lo mtu 65535
>   # ip -6 route get 2000::1
>   local 2000::1 dev lo  table local  src ...  metric 1024  mtu 65535 pref medium
> 
>   # ip link set dev lo mtu 65536
>   # ip -6 route get 2000::1
>   local 2000::1 dev lo  table local  src ...  metric 1024  mtu 65536 pref medium
> 
>   # ip -6 route del local 2000::1
> 
> After this patch the route entry no longer changes unless it already has an mtu.
> There is no need: this inheritance is already done in ip6_mtu()
> 
>   # ip link set dev lo mtu 65536
>   # ip -6 route add local 2000::1 dev lo
>   # ip -6 route add local 2000::2 dev lo mtu 2000
>   # ip -6 route get 2000::1; ip -6 route get 2000::2
>   local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
>   local 2000::2 dev lo  table local  src ...  metric 1024  mtu 2000 pref medium
> 
>   # ip link set dev lo mtu 65535
>   # ip -6 route get 2000::1; ip -6 route get 2000::2
>   local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
>   local 2000::2 dev lo  table local  src ...  metric 1024  mtu 2000 pref medium
> 
>   # ip link set dev lo mtu 1501
>   # ip -6 route get 2000::1; ip -6 route get 2000::2
>   local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
>   local 2000::2 dev lo  table local  src ...  metric 1024  mtu 1501 pref medium
> 
>   # ip link set dev lo mtu 65536
>   # ip -6 route get 2000::1; ip -6 route get 2000::2
>   local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
>   local 2000::2 dev lo  table local  src ...  metric 1024  mtu 65536 pref medium
> 
>   # ip -6 route del local 2000::1
>   # ip -6 route del local 2000::2
> 
> This is desirable because changing device mtu and then resetting it
> to the previous value shouldn't change the user visible routing table.
> 
> Signed-off-by: Maciej Żenczykowski <maze@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/route.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 947ed1ded026..fa90d14302f7 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2758,6 +2758,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
>  	   PMTU discouvery.
>  	 */
>  	if (rt->dst.dev == arg->dev &&
> +	    dst_metric_raw(&rt->dst, RTAX_MTU) &&
>  	    !dst_metric_locked(&rt->dst, RTAX_MTU)) {
>  		if (rt->rt6i_flags & RTF_CACHE) {
>  			/* For RTF_CACHE with rt6i_pmtu == 0
> 

Yep, that makes sense.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
