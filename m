From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] IPv6: Fixed support for blackhole and prohibit routes
Date: Wed, 20 Nov 2013 05:57:26 +0100
Message-ID: <20131120045726.GT16541@order.stressinduktion.org>
References: <1384879773-8800-1-git-send-email-kamala@aristanetwors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54089 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3KTE52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 23:57:28 -0500
Content-Disposition: inline
In-Reply-To: <1384879773-8800-1-git-send-email-kamala@aristanetwors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 10:19:33PM +0530, Kamala R wrote:
> From: Kamala R <kamala@aristanetworks.com>
> 
> The behaviour of blackhole and prohibit routes has been corrected by setting the input and output
> function pointers of the dst variable appropriately. For blackhole routes, they are set to
> dst_discard and for prohibit routes they are set to ip6_pkt_prohibit and ip6_pkt_prohbit_out
> respectively.
> 
> Signed-off-by: Kamala R <kamala@aristanetworks.com>
> ---
>  net/ipv6/route.c |   18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f54e3a1..f2289fd 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1564,21 +1564,25 @@ int ip6_route_add(struct fib6_config *cfg)
>  				goto out;
>  			}
>  		}
> -		rt->dst.output = ip6_pkt_discard_out;
> -		rt->dst.input = ip6_pkt_discard;
> +
>  		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
> +		rt->dst.error = (cfg->fc_type == RTN_BLACKHOLE) ? -EINVAL
> +				: ((cfg->fc_type == RTN_PROHIBIT ? -EACCES
> +				: ((cfg->fc_type == RTN_THROW ? -EAGAIN
> +				: -ENETUNREACH))));

Uh, sorry, I was a bit too unclear. This is rather ugly. I meant merging
the RTN_THROW and default case and just use one dst.error assignment
with a ternary operator where it makes sense.

>  		switch (cfg->fc_type) {
>  		case RTN_BLACKHOLE:
> -			rt->dst.error = -EINVAL;
> +			rt->dst.output = dst_discard;
> +			rt->dst.input = dst_discard;
>  			break;
>  		case RTN_PROHIBIT:
> -			rt->dst.error = -EACCES;
> +			rt->dst.output = ip6_pkt_prohibit_out;
> +			rt->dst.input = ip6_pkt_prohibit;
>  			break;
>  		case RTN_THROW:
> -			rt->dst.error = -EAGAIN;
> -			break;
>  		default:
> -			rt->dst.error = -ENETUNREACH;
> +			rt->dst.output = ip6_pkt_discard_out;
> +			rt->dst.input = ip6_pkt_discard;
>  			break;

case RTN_THROW:
default:
	rt->dst.error = (cfg->fc_type == ...) ? ... : ...;
	rt->dst.output = ....
	rt->dst.input = ....

I also don't mind if you are more verbose and specify each case
independent. Just have a look how it looks more pleasing. ;)

Greetings,

  Hannes
