From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2] ip6_tunnel: Clear IP6CB in ip6_tnl_xmit() after encapsulation
Date: Thu, 27 Oct 2016 19:17:49 -0700
Message-ID: <CALx6S36O_MUQw4vWKUoW-ZgCTg9PJrPjNHwuEWTDG9t=BxQv3w@mail.gmail.com>
References: <20161028015241.23258-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35579 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034144AbcJ1CRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 22:17:51 -0400
Received: by mail-qk0-f195.google.com with SMTP id v138so1150065qka.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 19:17:50 -0700 (PDT)
In-Reply-To: <20161028015241.23258-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 6:52 PM, Eli Cooper <elicooper@gmx.com> wrote:
> skb->cb may contain data from previous layers. In the observed scenario,
> the garbage data were misinterpreted as IP6CB(skb)->frag_max_size, so
> that small packets sent through the tunnel are mistakenly fragmented.
>
> This patch clears the control buffer for the next layer, after an IPv6
> header is installed.
>
Nice catch, but can you rectify this with what udp_tunnel6_xmit_skb is
doing. udp_tunnel6_xmit_skb calls ip6tunnel_xmit directly. Looks like
we do

memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
                            | IPSKB_REROUTED);

Is this what we should be doing in ip6_tnl_xmit also, or is
udp_tunnel6_xmit_skb broken because it doesn't zero all the cb?

Thanks,
Tom

> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> ---
> v2: clears the whole IP6CB altogether and does it after encapsulation
>
>  net/ipv6/ip6_tunnel.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 202d16a..1487e17 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1174,6 +1174,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>
>         skb_push(skb, sizeof(struct ipv6hdr));
>         skb_reset_network_header(skb);
> +       memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
>         ipv6h = ipv6_hdr(skb);
>         ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
>                      ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
> --
> 2.10.1
>
