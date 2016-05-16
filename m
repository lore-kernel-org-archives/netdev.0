From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 net-next 13/14] ip6ip6: Support for GSO/GRO
Date: Mon, 16 May 2016 16:51:28 -0700
Message-ID: <CAKgT0UfL-oTFh78dnP=78P5gS+bfXW9FG0NfcifM0D_JmHTivQ@mail.gmail.com>
References: <1463434389-314297-1-git-send-email-tom@herbertland.com>
	<1463434389-314297-14-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35734 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbcEPXv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:51:29 -0400
Received: by mail-io0-f193.google.com with SMTP id i75so440066ioa.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 16:51:29 -0700 (PDT)
In-Reply-To: <1463434389-314297-14-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 2:33 PM, Tom Herbert <tom@herbertland.com> wrote:
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv6/ip6_offload.c | 24 +++++++++++++++++++++---
>  net/ipv6/ip6_tunnel.c  |  3 +++
>  2 files changed, 24 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 787e55f..332d6a0 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -253,9 +253,11 @@ out:
>         return pp;
>  }
>
> -static struct sk_buff **sit_gro_receive(struct sk_buff **head,
> -                                       struct sk_buff *skb)
> +static struct sk_buff **sit_ip6ip6_gro_receive(struct sk_buff **head,
> +                                              struct sk_buff *skb)
>  {
> +       /* Common GRO receive for SIT and IP6IP6 */
> +
>         if (NAPI_GRO_CB(skb)->encap_mark) {
>                 NAPI_GRO_CB(skb)->flush = 1;
>                 return NULL;
> @@ -298,6 +300,13 @@ static int sit_gro_complete(struct sk_buff *skb, int nhoff)
>         return ipv6_gro_complete(skb, nhoff);
>  }
>
> +static int ip6ip6_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       skb->encapsulation = 1;
> +       skb_shinfo(skb)->gso_type |= SKB_GSO_IPXIP6;
> +       return ipv6_gro_complete(skb, nhoff);
> +}
> +
>  static struct packet_offload ipv6_packet_offload __read_mostly = {
>         .type = cpu_to_be16(ETH_P_IPV6),
>         .callbacks = {
> @@ -310,11 +319,19 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
>  static const struct net_offload sit_offload = {
>         .callbacks = {
>                 .gso_segment    = ipv6_gso_segment,
> -               .gro_receive    = sit_gro_receive,
> +               .gro_receive    = sit_ip6ip6_gro_receive,
>                 .gro_complete   = sit_gro_complete,
>         },
>  };
>
> +static const struct net_offload ip6ip6_offload = {
> +       .callbacks = {
> +               .gso_segment    = ipv6_gso_segment,
> +               .gro_receive    = sit_ip6ip6_gro_receive,
> +               .gro_complete   = ip6ip6_gro_complete,
> +       },
> +};
> +
>  static int __init ipv6_offload_init(void)
>  {
>
> @@ -326,6 +343,7 @@ static int __init ipv6_offload_init(void)
>         dev_add_offload(&ipv6_packet_offload);
>
>         inet_add_offload(&sit_offload, IPPROTO_IPV6);
> +       inet6_add_offload(&ip6ip6_offload, IPPROTO_IPV6);
>
>         return 0;
>  }
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 8076c7a..d205f17 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1238,6 +1238,9 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>         if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
>                 fl6.flowi6_mark = skb->mark;
>
> +       if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
> +               return -1;
> +
>         err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
>                            IPPROTO_IPV6);
>         if (err != 0) {

So one piece you are missing here is
skb_set_inner_ipproto(IPPROTO_IPV6).  Without that the tunnel offload
could be a bit confused as the inner protocol type defaults to
ENCAP_TYPE_ETHER.

- Alex
