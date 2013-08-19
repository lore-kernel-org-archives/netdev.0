From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: handle Redirect ICMP Message with no Redirected Header option
Date: Mon, 19 Aug 2013 13:55:12 +0200
Message-ID: <20130819115512.GC9414@order.stressinduktion.org>
References: <5211F97B.4090209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60579 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab3HSLzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 07:55:15 -0400
Content-Disposition: inline
In-Reply-To: <5211F97B.4090209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 19, 2013 at 06:54:51PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> rfc 4861 says the Redirected Header option is optional, so
> the kernel should not drop the Redirect Message that has no
> Redirected Header option. In this patch, the function
> ip6_redirect_no_header() is introduced to deal with that
> condition.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  include/net/ip6_route.h |    1 +
>  net/ipv6/ndisc.c        |    4 +++-
>  net/ipv6/route.c        |   21 +++++++++++++++++++++
>  3 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 260f83f..7966f54 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -135,6 +135,7 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
>  extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
>  			       __be32 mtu);
>  extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
> +extern void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif, u32 mark);
>  extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
>  
>  struct netlink_callback;
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 79aa965..04d31c2 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1369,8 +1369,10 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
>  	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
>  		return;
>  
> -	if (!ndopts.nd_opts_rh)
> +	if (!ndopts.nd_opts_rh) {
> +		ip6_redirect_no_header(skb, dev_net(skb->dev), 0, 0);
>  		return;
> +	}

Can't we just jump down to icmpv6_notify without introducing
ip6_redirect_no_header?

>  
>  	hdr = (u8 *)ndopts.nd_opts_rh;
>  	hdr += 8;
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index b70f897..9934b87 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1178,6 +1178,27 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
>  }
>  EXPORT_SYMBOL_GPL(ip6_redirect);
>  
> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif, u32 mark)
> +{
> +	const struct ipv6hdr *iph = (struct ipv6hdr *) skb_network_header(skb);

const struct ipv6hdr *iph = ipv6_hdr(skb);

Thanks,

  Hannes
