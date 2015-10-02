From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 3/4] ip_tunnels: introduce ip6_tunnel_key_init
Date: Thu, 1 Oct 2015 17:11:43 -0700
Message-ID: <CALnjE+p2xtSTpPtPtiHgPZmAdiCzCQn3AnNKCffVe3cKVAk7hg@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
	<bc6c2e24fd657871553a1b1ae8c999c8b9b151d8.1443710454.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33822 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbbJBALn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 20:11:43 -0400
Received: by iow1 with SMTP id 1so67032676iow.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 17:11:43 -0700 (PDT)
In-Reply-To: <bc6c2e24fd657871553a1b1ae8c999c8b9b151d8.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 7:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> We already have ip_tunnel_key_init, this does the same for IPv6. Will be
> used also by openvswitch in the next patch.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> New patch in v2 of the set.
> ---
>  include/net/dst_metadata.h | 18 ++++++------------
>  include/net/ip_tunnels.h   | 40 +++++++++++++++++++++++++++++++---------
>  2 files changed, 37 insertions(+), 21 deletions(-)
>
> diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
> index af9d5382f6cb..30e925aba1a4 100644
> --- a/include/net/dst_metadata.h
> +++ b/include/net/dst_metadata.h
> @@ -85,23 +85,17 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
>  {
>         const struct ipv6hdr *ip6h = ipv6_hdr(skb);
>         struct metadata_dst *tun_dst;
> -       struct ip_tunnel_info *info;
>
>         tun_dst = tun_rx_dst(md_size);
>         if (!tun_dst)
>                 return NULL;
>
> -       info = &tun_dst->u.tun_info;
> -       info->mode = IP_TUNNEL_INFO_IPV6;
> -       info->key.tun_flags = flags;
> -       info->key.tun_id = tunnel_id;
> -       info->key.tp_src = 0;
> -       info->key.tp_dst = 0;
> -
> -       info->key.u.ipv6.src = ip6h->saddr;
> -       info->key.u.ipv6.dst = ip6h->daddr;
> -       info->key.tos = ipv6_get_dsfield(ip6h);
> -       info->key.ttl = ip6h->hop_limit;
> +       tun_dst->u.tun_info.mode = IP_TUNNEL_INFO_IPV6;
> +       ip6_tunnel_key_init(&tun_dst->u.tun_info.key,
> +                           &ip6h->saddr, &ip6h->daddr,
> +                           ipv6_get_dsfield(ip6h), ip6h->hop_limit,
> +                           0, 0, tunnel_id, flags);
> +
>         return tun_dst;
>  }
>
> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
> index f6dafec9102c..087b2e24e5e0 100644
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -179,17 +179,12 @@ int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
>  int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
>                             unsigned int num);
>
> -static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
> -                                     __be32 saddr, __be32 daddr,
> -                                     u8 tos, u8 ttl,
> -                                     __be16 tp_src, __be16 tp_dst,
> -                                     __be64 tun_id, __be16 tun_flags)
> +static inline void __ip_tunnel_key_init(struct ip_tunnel_key *key,
> +                                       u8 tos, u8 ttl,
> +                                       __be16 tp_src, __be16 tp_dst,
> +                                       __be64 tun_id, __be16 tun_flags)
>  {
>         key->tun_id = tun_id;
> -       key->u.ipv4.src = saddr;
> -       key->u.ipv4.dst = daddr;
> -       memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
> -              0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
>         key->tos = tos;
>         key->ttl = ttl;
>         key->tun_flags = tun_flags;
> @@ -207,6 +202,33 @@ static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
>                        0, sizeof(*key) - IP_TUNNEL_KEY_SIZE);
>  }
>
> +static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
> +                                     __be32 saddr, __be32 daddr,
> +                                     u8 tos, u8 ttl,
> +                                     __be16 tp_src, __be16 tp_dst,
> +                                     __be64 tun_id, __be16 tun_flags)
> +{
> +       __ip_tunnel_key_init(key, tos, ttl, tp_src, tp_dst, tun_id,
> +                            tun_flags);
> +       key->u.ipv4.src = saddr;
> +       key->u.ipv4.dst = daddr;
> +       memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
> +              0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
neat: since IP_TUNNEL_KEY_IPV4_PAD not really IPv4 tunnel key padding
anymore, This also needs to be renamed.

otherwise looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
