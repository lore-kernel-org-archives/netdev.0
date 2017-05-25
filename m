From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Thu, 25 May 2017 08:42:21 -0700
Message-ID: <CALx6S379RzD+t=mDHgs+u-BrWgd7Jt4W_C-kNarA7t+HwEJ3jQ@mail.gmail.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com> <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35929 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762180AbdEYPmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 11:42:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id k15so52769129wmh.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 08:42:23 -0700 (PDT)
In-Reply-To: <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 6:24 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Add support for dissection of ip tos and ttl and ipv6 traffic-class
> and hoplimit. Both are dissected into the same struct.
>
> Uses similar call to ip dissection function as with tcp, arp and others.
>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/flow_dissector.h | 11 +++++++++++
>  net/core/flow_dissector.c    | 40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 51 insertions(+)
>
> diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
> index efe34eec..e2663e9 100644
> --- a/include/net/flow_dissector.h
> +++ b/include/net/flow_dissector.h
> @@ -165,6 +165,16 @@ struct flow_dissector_key_tcp {
>         __be16 flags;
>  };
>
> +/**
> + * struct flow_dissector_key_ip:
> + * @tos: tos
> + * @ttl: ttl
> + */
> +struct flow_dissector_key_ip {
> +       __u8    tos;
> +       __u8    ttl;
> +};
> +

Looks like yet more complexity be piled onto flow dissector. Instead
of splitting out individual fields can we just return a pointer to the
IP header and let the caller extract the fields they're interested in?

Tom

>  enum flow_dissector_key_id {
>         FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
>         FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
> @@ -186,6 +196,7 @@ enum flow_dissector_key_id {
>         FLOW_DISSECTOR_KEY_ENC_PORTS, /* struct flow_dissector_key_ports */
>         FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
>         FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
> +       FLOW_DISSECTOR_KEY_IP, /* struct flow_dissector_key_ip */
>
>         FLOW_DISSECTOR_KEY_MAX,
>  };
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5a45943..fc5fc45 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -367,6 +367,40 @@ __skb_flow_dissect_tcp(const struct sk_buff *skb,
>         key_tcp->flags = (*(__be16 *) &tcp_flag_word(th) & htons(0x0FFF));
>  }
>
> +static void
> +__skb_flow_dissect_ipv4(const struct sk_buff *skb,
> +                       struct flow_dissector *flow_dissector,
> +                       void *target_container, void *data, const struct iphdr *iph)
> +{
> +       struct flow_dissector_key_ip *key_ip;
> +
> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_IP))
> +               return;
> +
> +       key_ip = skb_flow_dissector_target(flow_dissector,
> +                                          FLOW_DISSECTOR_KEY_IP,
> +                                          target_container);
> +       key_ip->tos = iph->tos;
> +       key_ip->ttl = iph->ttl;
> +}
> +
> +static void
> +__skb_flow_dissect_ipv6(const struct sk_buff *skb,
> +                       struct flow_dissector *flow_dissector,
> +                       void *target_container, void *data, const struct ipv6hdr *iph)
> +{
> +       struct flow_dissector_key_ip *key_ip;
> +
> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_IP))
> +               return;
> +
> +       key_ip = skb_flow_dissector_target(flow_dissector,
> +                                          FLOW_DISSECTOR_KEY_IP,
> +                                          target_container);
> +       key_ip->tos = ipv6_get_dsfield(iph);
> +       key_ip->ttl = iph->hop_limit;
> +}
> +
>  /**
>   * __skb_flow_dissect - extract the flow_keys struct and return it
>   * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
> @@ -469,6 +503,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>                         }
>                 }
>
> +               __skb_flow_dissect_ipv4(skb, flow_dissector,
> +                                       target_container, data, iph);
> +
>                 if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
>                         goto out_good;
>
> @@ -514,6 +551,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>                                 goto out_good;
>                 }
>
> +               __skb_flow_dissect_ipv6(skb, flow_dissector,
> +                                       target_container, data, iph);
> +
>                 if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
>                         goto out_good;
>
> --
> 2.3.7
>
