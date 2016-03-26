From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Sat, 26 Mar 2016 12:41:25 -0700
Message-ID: <CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
	<1458405122-12565-3-git-send-email-jesse@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34486 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbcCZTl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 15:41:26 -0400
Received: by mail-io0-f171.google.com with SMTP id e3so28439233ioa.1
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2016 12:41:25 -0700 (PDT)
In-Reply-To: <1458405122-12565-3-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 19, 2016 at 9:32 AM, Jesse Gross <jesse@kernel.org> wrote:
> When drivers express support for TSO of encapsulated packets, they
> only mean that they can do it for one layer of encapsulation.
> Supporting additional levels would mean updating, at a minimum,
> more IP length fields and they are unaware of this.
>
This patch completely breaks GRO for FOU and GUE.

> No encapsulation device expresses support for handling offloaded
> encapsulated packets, so we won't generate these types of frames
> in the transmit path. However, GRO doesn't have a check for
> multiple levels of encapsulation and will attempt to build them.
>
> UDP tunnel GRO actually does prevent this situation but it only
> handles multiple UDP tunnels stacked on top of each other. This
> generalizes that solution to prevent any kind of tunnel stacking
> that would cause problems.
>
GUE and FOU regularly create packets that will be both GSO UDP tunnels
and IPIP, SIT, GRE, etc. This is by design. There should be no
ambiguity in the drivers as to what this means. For instance, if
SKB_GSO_UDP_TUNNEL and SKB_GSO_GRE are set that is GRE/UDP packet, a
driver can use ndo_features_check to validate.

So multiple levels of encapsulation with GRO is perfectly valid and I
would suggest to simply revert this patch. The one potential issue we
could have is the potential for GRO to construct a packet which is a
UDP-encapsulation inside another encapsulation, like UDP-encap in GRE.
In this case the GSO flags don't provide enough information to
distinguish say between GRE/UDP (common case) and UDP/GRE (uncommon
case). To make this clear we can set udp_mark in GRE, ipip, and sit
but *not* check for it.

Tom

> Fixes: bf5a755f ("net-gre-gro: Add GRE support to the GRO stack")
> Signed-off-by: Jesse Gross <jesse@kernel.org>
> ---
> v2: No change.
> ---
>  include/linux/netdevice.h |  4 ++--
>  net/core/dev.c            |  2 +-
>  net/ipv4/af_inet.c        | 15 ++++++++++++++-
>  net/ipv4/gre_offload.c    |  5 +++++
>  net/ipv4/udp_offload.c    |  6 +++---
>  net/ipv6/ip6_offload.c    | 15 ++++++++++++++-
>  6 files changed, 39 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index be693b3..f9eebd5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2096,8 +2096,8 @@ struct napi_gro_cb {
>         /* This is non-zero if the packet may be of the same flow. */
>         u8      same_flow:1;
>
> -       /* Used in udp_gro_receive */
> -       u8      udp_mark:1;
> +       /* Used in tunnel GRO receive */
> +       u8      encap_mark:1;
>
>         /* GRO checksum is valid */
>         u8      csum_valid:1;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index edb7179..43c74ca 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4438,7 +4438,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
>                 NAPI_GRO_CB(skb)->same_flow = 0;
>                 NAPI_GRO_CB(skb)->flush = 0;
>                 NAPI_GRO_CB(skb)->free = 0;
> -               NAPI_GRO_CB(skb)->udp_mark = 0;
> +               NAPI_GRO_CB(skb)->encap_mark = 0;
>                 NAPI_GRO_CB(skb)->gro_remcsum_start = 0;
>
>                 /* Setup for GRO checksum validation */
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 9659233..0fefba6 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1380,6 +1380,19 @@ out:
>         return pp;
>  }
>
> +static struct sk_buff **ipip_gro_receive(struct sk_buff **head,
> +                                        struct sk_buff *skb)
> +{
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
>  #define SECONDS_PER_DAY        86400
>
>  /* inet_current_timestamp - Return IP network timestamp
> @@ -1682,7 +1695,7 @@ static struct packet_offload ip_packet_offload __read_mostly = {
>  static const struct net_offload ipip_offload = {
>         .callbacks = {
>                 .gso_segment    = inet_gso_segment,
> -               .gro_receive    = inet_gro_receive,
> +               .gro_receive    = ipip_gro_receive,
>                 .gro_complete   = ipip_gro_complete,
>         },
>  };
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 540866d..dd03161 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -126,6 +126,11 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
>         struct packet_offload *ptype;
>         __be16 type;
>
> +       if (NAPI_GRO_CB(skb)->encap_mark)
> +               goto out;
> +
> +       NAPI_GRO_CB(skb)->encap_mark = 1;
> +
>         off = skb_gro_offset(skb);
>         hlen = off + sizeof(*greh);
>         greh = skb_gro_header_fast(skb, off);
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 8a3405a..8007f73 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -311,14 +311,14 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>         unsigned int off = skb_gro_offset(skb);
>         int flush = 1;
>
> -       if (NAPI_GRO_CB(skb)->udp_mark ||
> +       if (NAPI_GRO_CB(skb)->encap_mark ||
>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>              !NAPI_GRO_CB(skb)->csum_valid))
>                 goto out;
>
> -       /* mark that this skb passed once through the udp gro layer */
> -       NAPI_GRO_CB(skb)->udp_mark = 1;
> +       /* mark that this skb passed once through the tunnel gro layer */
> +       NAPI_GRO_CB(skb)->encap_mark = 1;
>
>         rcu_read_lock();
>         uo_priv = rcu_dereference(udp_offload_base);
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index eeca943..82e9f30 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -258,6 +258,19 @@ out:
>         return pp;
>  }
>
> +static struct sk_buff **sit_gro_receive(struct sk_buff **head,
> +                                       struct sk_buff *skb)
> +{
> +       if (NAPI_GRO_CB(skb)->encap_mark) {
> +               NAPI_GRO_CB(skb)->flush = 1;
> +               return NULL;
> +       }
> +
> +       NAPI_GRO_CB(skb)->encap_mark = 1;
> +
> +       return ipv6_gro_receive(head, skb);
> +}
> +
>  static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         const struct net_offload *ops;
> @@ -302,7 +315,7 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
>  static const struct net_offload sit_offload = {
>         .callbacks = {
>                 .gso_segment    = ipv6_gso_segment,
> -               .gro_receive    = ipv6_gro_receive,
> +               .gro_receive    = sit_gro_receive,
>                 .gro_complete   = sit_gro_complete,
>         },
>  };
> --
> 2.5.0
>
