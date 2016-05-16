From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 net-next 14/14] ip4ip6: Support for GSO/GRO
Date: Mon, 16 May 2016 16:53:40 -0700
Message-ID: <CAKgT0Ud9Oyeu2tt1qnzQAmcZCx6RJuBW8tykpwR1AYEFEKDcCA@mail.gmail.com>
References: <1463434389-314297-1-git-send-email-tom@herbertland.com>
	<1463434389-314297-15-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36644 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbcEPXxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:53:41 -0400
Received: by mail-io0-f196.google.com with SMTP id k129so436844iof.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 16:53:41 -0700 (PDT)
In-Reply-To: <1463434389-314297-15-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 2:33 PM, Tom Herbert <tom@herbertland.com> wrote:
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/inet_common.h |  5 +++++
>  net/ipv4/af_inet.c        | 12 +++++++-----
>  net/ipv6/ip6_offload.c    | 33 ++++++++++++++++++++++++++++++++-
>  net/ipv6/ip6_tunnel.c     |  3 +++
>  4 files changed, 47 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/inet_common.h b/include/net/inet_common.h
> index 109e3ee..5d68342 100644
> --- a/include/net/inet_common.h
> +++ b/include/net/inet_common.h
> @@ -39,6 +39,11 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
>  int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
>                     int *addr_len);
>
> +struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb);
> +int inet_gro_complete(struct sk_buff *skb, int nhoff);
> +struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> +                                netdev_features_t features);
> +
>  static inline void inet_ctl_sock_destroy(struct sock *sk)
>  {
>         if (sk)
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 25040b1..377424e 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1192,8 +1192,8 @@ int inet_sk_rebuild_header(struct sock *sk)
>  }
>  EXPORT_SYMBOL(inet_sk_rebuild_header);
>
> -static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> -                                       netdev_features_t features)
> +struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> +                                netdev_features_t features)
>  {
>         bool udpfrag = false, fixedid = false, encap;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
> @@ -1280,9 +1280,9 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  out:
>         return segs;
>  }
> +EXPORT_SYMBOL(inet_gso_segment);
>
> -static struct sk_buff **inet_gro_receive(struct sk_buff **head,
> -                                        struct sk_buff *skb)
> +struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  {
>         const struct net_offload *ops;
>         struct sk_buff **pp = NULL;
> @@ -1398,6 +1398,7 @@ out:
>
>         return pp;
>  }
> +EXPORT_SYMBOL(inet_gro_receive);
>
>  static struct sk_buff **ipip_gro_receive(struct sk_buff **head,
>                                          struct sk_buff *skb)
> @@ -1449,7 +1450,7 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>         return -EINVAL;
>  }
>
> -static int inet_gro_complete(struct sk_buff *skb, int nhoff)
> +int inet_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         __be16 newlen = htons(skb->len - nhoff);
>         struct iphdr *iph = (struct iphdr *)(skb->data + nhoff);
> @@ -1479,6 +1480,7 @@ out_unlock:
>
>         return err;
>  }
> +EXPORT_SYMBOL(inet_gro_complete);
>
>  static int ipip_gro_complete(struct sk_buff *skb, int nhoff)
>  {
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 332d6a0..22e90e5 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -16,6 +16,7 @@
>
>  #include <net/protocol.h>
>  #include <net/ipv6.h>
> +#include <net/inet_common.h>
>
>  #include "ip6_offload.h"
>
> @@ -268,6 +269,21 @@ static struct sk_buff **sit_ip6ip6_gro_receive(struct sk_buff **head,
>         return ipv6_gro_receive(head, skb);
>  }
>
> +static struct sk_buff **ip4ip6_gro_receive(struct sk_buff **head,
> +                                          struct sk_buff *skb)
> +{
> +       /* Common GRO receive for SIT and IP6IP6 */
> +
> +       if (NAPI_GRO_CB(skb)->encap_mark) {
> +               NAPI_GRO_CB(skb)->flush = 1;
> +               return NULL;
> +       }
> +
> +       NAPI_GRO_CB(skb)->encap_mark = 1;
> +
> +       return inet_gro_receive(head, skb);
> +}
> +
>  static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         const struct net_offload *ops;
> @@ -307,6 +323,13 @@ static int ip6ip6_gro_complete(struct sk_buff *skb, int nhoff)
>         return ipv6_gro_complete(skb, nhoff);
>  }
>
> +static int ip4ip6_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       skb->encapsulation = 1;
> +       skb_shinfo(skb)->gso_type |= SKB_GSO_IPXIP6;
> +       return inet_gro_complete(skb, nhoff);
> +}
> +
>  static struct packet_offload ipv6_packet_offload __read_mostly = {
>         .type = cpu_to_be16(ETH_P_IPV6),
>         .callbacks = {
> @@ -324,6 +347,14 @@ static const struct net_offload sit_offload = {
>         },
>  };
>
> +static const struct net_offload ip4ip6_offload = {
> +       .callbacks = {
> +               .gso_segment    = inet_gso_segment,
> +               .gro_receive    = ip4ip6_gro_receive,
> +               .gro_complete   = ip4ip6_gro_complete,
> +       },
> +};
> +
>  static const struct net_offload ip6ip6_offload = {
>         .callbacks = {
>                 .gso_segment    = ipv6_gso_segment,
> @@ -331,7 +362,6 @@ static const struct net_offload ip6ip6_offload = {
>                 .gro_complete   = ip6ip6_gro_complete,
>         },
>  };
> -
>  static int __init ipv6_offload_init(void)
>  {
>
> @@ -344,6 +374,7 @@ static int __init ipv6_offload_init(void)
>
>         inet_add_offload(&sit_offload, IPPROTO_IPV6);
>         inet6_add_offload(&ip6ip6_offload, IPPROTO_IPV6);
> +       inet6_add_offload(&ip4ip6_offload, IPPROTO_IPIP);
>
>         return 0;
>  }
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index d205f17..00b2832 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1184,6 +1184,9 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>         if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
>                 fl6.flowi6_mark = skb->mark;
>
> +       if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
> +               return -1;
> +
>         err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
>                            IPPROTO_IPIP);
>         if (err != 0) {


The same issue exists here as there was in the IPv6.  You need to call
skb_set_inner_ipprot(skb, IPRPTO_IPIP) so that things don't get
confused and think this is some sort of TEB based tunnel.

Also since you now have a call to iptunnel_handle_offloads() in all
paths you can probably drop the block in ip6_tnl_xmit that was
checking for skb->encapsulation and resetting the inner headers.

- Alex
