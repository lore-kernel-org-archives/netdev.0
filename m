From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [v2] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Sun, 18 Sep 2016 09:12:38 -0600
Message-ID: <8bce7180-e4c2-808c-20e0-0bd9634b8fc2@cumulusnetworks.com>
References: <0e4071d6-a3cc-37a7-6a32-2169e0e3b305@cumulusnetworks.com>
 <20160916203349.31201-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34573 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933912AbcIRPMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:12:55 -0400
Received: by mail-pa0-f44.google.com with SMTP id wk8so40323941pab.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:12:54 -0700 (PDT)
In-Reply-To: <20160916203349.31201-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/16 2:33 PM, Vincent Bernat wrote:
> Commit 8c14586fc320 ("net: ipv6: Use passed in table for nexthop
> lookups") introduced a regression: insertion of an IPv6 route in a table
> not containing the appropriate connected route for the gateway but which
> contained a non-connected route (like a default gateway) fails while it
> was previously working:
> 
>     $ ip link add eth0 type dummy
>     $ ip link set up dev eth0
>     $ ip addr add 2001:db8::1/64 dev eth0
>     $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     RTNETLINK answers: No route to host
>     $ ip -6 route show table 20
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 
> After this patch, we get:
> 
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     $ ip -6 route show table 20
>     2001:db8:cafe::1 via 2001:db8::6 dev eth0  metric 1024  pref medium
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 

need an explicit Fixes tag here:

Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")

> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> ---
>  net/ipv6/route.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ad4a7ff301fc..2c6c7257ff75 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1994,6 +1994,14 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
>  			if (cfg->fc_table)
>  				grt = ip6_nh_lookup_table(net, cfg, gw_addr);
>  
> +			if (grt) {
> +				if (grt->rt6i_flags & RTF_GATEWAY ||
> +				    (dev && dev != grt->dst.dev)) {
> +					ip6_rt_put(grt);
> +					grt = NULL;
> +				}
> +			}
> +

The if grt check needs to be under the 'if (cfg->fc_table)'


>  			if (!grt)
>  				grt = rt6_lookup(net, gw_addr, NULL,
>  						 cfg->fc_ifindex, 1);
> 
