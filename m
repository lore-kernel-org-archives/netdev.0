From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Thu, 17 Jan 2013 18:21:37 -0800
Message-ID: <1358475697.11051.9.camel@edumazet-glaptop>
References: <20130117035652.GB23782@order.stressinduktion.org>
	 <20130118020612.GA14833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:65043 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab3ARCVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 21:21:42 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so1385810dac.40
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 18:21:41 -0800 (PST)
In-Reply-To: <20130118020612.GA14833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-18 at 03:06 +0100, Hannes Frederic Sowa wrote:

> [PATCH] ipv6: remove unneeded check to pskb_may_pull
> 
> This is already checked by the caller (tunnel64_rcv) and brings ipip6_rcv
> in line with ipip_rcv.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/sit.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index cfba99b..98fe536 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -592,15 +592,10 @@ out:
>  
>  static int ipip6_rcv(struct sk_buff *skb)
>  {
> -	const struct iphdr *iph;
> +	const struct iphdr *iph = ip_hdr(skb);
>  	struct ip_tunnel *tunnel;
>  	int err;
>  
> -	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
> -		goto out;
> -
> -	iph = ip_hdr(skb);
> -
>  	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
>  				     iph->saddr, iph->daddr);
>  	if (tunnel != NULL) {

But we use a 'struct iphdr' here, not a ipv6hdr

So we basically implicitely rely on sizeof(struct iphdr) <=
sizeof(struct ipv6hdr)

I would leave the pskb_may_pull() call and fix it, even if not really
needed.
