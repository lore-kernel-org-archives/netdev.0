From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V2] ipv6: handle Redirect ICMP Message with no Redirected Header option
Date: Tue, 20 Aug 2013 13:50:20 +0200
Message-ID: <20130820115020.GB3938@order.stressinduktion.org>
References: <52131725.6000409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34569 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3HTLuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 07:50:22 -0400
Content-Disposition: inline
In-Reply-To: <52131725.6000409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 03:13:41PM +0800, Duan Jiong wrote:
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1178,6 +1178,28 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
>  }
>  EXPORT_SYMBOL_GPL(ip6_redirect);
>  
> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
> +			    u32 mark)
> +{
> +	const struct ipv6hdr *iph = (struct ipv6hdr *)skb_network_header(skb);

Was there a problem with ipv6_hdr?

> +	const struct rd_msg *msg = (struct rd_msg *)skb_transport_header(skb);
> +	struct dst_entry *dst;
> +	struct flowi6 fl6;
> +
> +	memset(&fl6, 0, sizeof(fl6));
> +	fl6.flowi6_oif = oif;
> +	fl6.flowi6_mark = mark;
> +	fl6.flowi6_flags = 0;
> +	fl6.daddr = msg->dest;
> +	fl6.saddr = iph->daddr;
> +
> +	dst = ip6_route_output(net, NULL, &fl6);
> +	if (!dst->error)
> +		rt6_do_redirect(dst, NULL, skb);
> +	dst_release(dst);
> +}
> +EXPORT_SYMBOL_GPL(ip6_redirect_no_header);
> +
>  void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
>  {
>  	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);

Introducing a new function here is the right thing. Maybe you could have
a look how these redirects could be fed to raw sockets, too?

Thanks,

  Hannes
