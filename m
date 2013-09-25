From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in ip_tunnel_xmit
Date: Wed, 25 Sep 2013 09:55:50 -0700
Message-ID: <CALnjE+q1=EJGBBC9KC4_hcj2SPhSPQ3xNVt6RVFN2hZPFYM2TA@mail.gmail.com>
References: <20130925055418.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:34846 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750888Ab3IYQzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 12:55:51 -0400
Received: by mail-qc0-f177.google.com with SMTP id x12so4219807qcv.8
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 09:55:51 -0700 (PDT)
In-Reply-To: <20130925055418.GV7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 10:54 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> We might extend the used aera of a skb beyond the total
> headroom when we install the ipip header. Fix this by
> calling skb_cow_head() unconditionally.
>
It is better to call skb_cow_head() from ipip_tunnel_xmit() as it is
consistent with gre.

> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/ip_tunnel.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index ac9fabe..b8ce640 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -641,13 +641,13 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>
>         max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
>                         + rt->dst.header_len;
> -       if (max_headroom > dev->needed_headroom) {
> +       if (max_headroom > dev->needed_headroom)
>                 dev->needed_headroom = max_headroom;
> -               if (skb_cow_head(skb, dev->needed_headroom)) {
> -                       dev->stats.tx_dropped++;
> -                       dev_kfree_skb(skb);
> -                       return;
> -               }
> +
> +       if (skb_cow_head(skb, dev->needed_headroom)) {
> +               dev->stats.tx_dropped++;
> +               dev_kfree_skb(skb);
> +               return;
>         }
>
>         err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
