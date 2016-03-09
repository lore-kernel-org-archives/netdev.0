From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 3/4] geneve: support setting IPv6 flow label
Date: Tue, 8 Mar 2016 19:38:58 -0800
Message-ID: <CALx6S37V=wODbied_HeCZBLrJYRtdu9+B4uCWec7v9rVt_NEcA@mail.gmail.com>
References: <cover.1457488298.git.daniel@iogearbox.net>
	<be638e46f291db03ca9f67ea54cfc4837cefc225.1457488298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34709 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbcCIDi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 22:38:59 -0500
Received: by mail-io0-f180.google.com with SMTP id m184so51564809iof.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 19:38:59 -0800 (PST)
In-Reply-To: <be638e46f291db03ca9f67ea54cfc4837cefc225.1457488298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 6:00 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> This work adds support for setting the IPv6 flow label for geneve per
> device and through collect metadata (ip_tunnel_key) frontends. Also here,
> the geneve dst cache does not need any special considerations, for the
> cases where caches can be used, the label is static per cache.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  drivers/net/geneve.c         | 35 +++++++++++++++++++++++++++--------
>  include/uapi/linux/if_link.h |  1 +
>  2 files changed, 28 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 89ccff7..33185b9 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -68,6 +68,7 @@ struct geneve_dev {
>         u8                 tos;         /* TOS override */
>         union geneve_addr  remote;      /* IP address for link partner */
>         struct list_head   next;        /* geneve's per namespace list */
> +       __be32             label;       /* IPv6 flowlabel override */
>         __be16             dst_port;
>         bool               collect_md;
>         struct gro_cells   gro_cells;
> @@ -846,6 +847,7 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
>                 fl6->daddr = info->key.u.ipv6.dst;
>                 fl6->saddr = info->key.u.ipv6.src;
>                 fl6->flowi6_tos = RT_TOS(info->key.tos);
> +               fl6->flowlabel = info->key.label;
>                 dst_cache = &info->dst_cache;
>         } else {
>                 prio = geneve->tos;
> @@ -857,6 +859,7 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
>                 }
>
>                 fl6->flowi6_tos = RT_TOS(prio);
> +               fl6->flowlabel = geneve->label;
>                 fl6->daddr = geneve->remote.sin6.sin6_addr;
>                 dst_cache = &geneve->dst_cache;
>         }
> @@ -998,6 +1001,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>         struct flowi6 fl6;
>         __u8 prio, ttl;
>         __be16 sport;
> +       __be32 label;
>         bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
>         u32 flags = geneve->flags;
>
> @@ -1041,6 +1045,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>
>                 prio = ip_tunnel_ecn_encap(key->tos, iip, skb);
>                 ttl = key->ttl;
> +               label = info->key.label;
>         } else {
>                 err = geneve6_build_skb(dst, skb, 0, geneve->vni,
>                                         0, NULL, flags, xnet);
> @@ -1052,9 +1057,11 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>                 if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
>                         ttl = 1;
>                 ttl = ttl ? : ip6_dst_hoplimit(dst);
> +               label = geneve->label;
>         }
> +
>         udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
> -                            &fl6.saddr, &fl6.daddr, prio, ttl, 0,
> +                            &fl6.saddr, &fl6.daddr, prio, ttl, label,
>                              sport, geneve->dst_port,
>                              !!(flags & GENEVE_F_UDP_ZERO_CSUM6_TX));
>         return NETDEV_TX_OK;
> @@ -1238,6 +1245,7 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
>         [IFLA_GENEVE_REMOTE6]           = { .len = sizeof(struct in6_addr) },
>         [IFLA_GENEVE_TTL]               = { .type = NLA_U8 },
>         [IFLA_GENEVE_TOS]               = { .type = NLA_U8 },
> +       [IFLA_GENEVE_LABEL]             = { .type = NLA_U32 },

It's depressing how many instances there are for processing so many of
these IFLA_*'s in exactly the same way in the stack. I count seven
instances of handling IFLA_*_TTL for example. It would be really nice
if someone wants to figure how to consolidate IP tunnel configuration
to eliminate this replication!

>         [IFLA_GENEVE_PORT]              = { .type = NLA_U16 },
>         [IFLA_GENEVE_COLLECT_METADATA]  = { .type = NLA_FLAG },
>         [IFLA_GENEVE_UDP_CSUM]          = { .type = NLA_U8 },
> @@ -1295,8 +1303,8 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
>
>  static int geneve_configure(struct net *net, struct net_device *dev,
>                             union geneve_addr *remote,
> -                           __u32 vni, __u8 ttl, __u8 tos, __be16 dst_port,
> -                           bool metadata, u32 flags)
> +                           __u32 vni, __u8 ttl, __u8 tos, __be32 label,
> +                           __be16 dst_port, bool metadata, u32 flags)
>  {
>         struct geneve_net *gn = net_generic(net, geneve_net_id);
>         struct geneve_dev *t, *geneve = netdev_priv(dev);
> @@ -1306,7 +1314,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>         if (!remote)
>                 return -EINVAL;
>         if (metadata &&
> -           (remote->sa.sa_family != AF_UNSPEC || vni || tos || ttl))
> +           (remote->sa.sa_family != AF_UNSPEC || vni || tos || ttl || label))
>                 return -EINVAL;
>
>         geneve->net = net;
> @@ -1321,10 +1329,14 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>             (remote->sa.sa_family == AF_INET6 &&
>              ipv6_addr_is_multicast(&remote->sin6.sin6_addr)))
>                 return -EINVAL;
> +       if (label && remote->sa.sa_family != AF_INET6)
> +               return -EINVAL;
> +
>         geneve->remote = *remote;
>
>         geneve->ttl = ttl;
>         geneve->tos = tos;
> +       geneve->label = label;
>         geneve->dst_port = dst_port;
>         geneve->collect_md = metadata;
>         geneve->flags = flags;
> @@ -1367,6 +1379,7 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>         __u8 ttl = 0, tos = 0;
>         bool metadata = false;
>         union geneve_addr remote = geneve_remote_unspec;
> +       __be32 label = 0;
>         __u32 vni = 0;
>         u32 flags = 0;
>
> @@ -1403,6 +1416,10 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>         if (data[IFLA_GENEVE_TOS])
>                 tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
>
> +       if (data[IFLA_GENEVE_LABEL])
> +               label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
> +                       IPV6_FLOWLABEL_MASK;
> +
>         if (data[IFLA_GENEVE_PORT])
>                 dst_port = nla_get_be16(data[IFLA_GENEVE_PORT]);
>
> @@ -1421,8 +1438,8 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>             nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
>                 flags |= GENEVE_F_UDP_ZERO_CSUM6_RX;
>
> -       return geneve_configure(net, dev, &remote, vni, ttl, tos, dst_port,
> -                               metadata, flags);
> +       return geneve_configure(net, dev, &remote, vni, ttl, tos, label,
> +                               dst_port, metadata, flags);
>  }
>
>  static void geneve_dellink(struct net_device *dev, struct list_head *head)
> @@ -1439,6 +1456,7 @@ static size_t geneve_get_size(const struct net_device *dev)
>                 nla_total_size(sizeof(struct in6_addr)) + /* IFLA_GENEVE_REMOTE{6} */
>                 nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
>                 nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
> +               nla_total_size(sizeof(__be32)) +  /* IFLA_GENEVE_LABEL */
>                 nla_total_size(sizeof(__be16)) +  /* IFLA_GENEVE_PORT */
>                 nla_total_size(0) +      /* IFLA_GENEVE_COLLECT_METADATA */
>                 nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_CSUM */
> @@ -1469,7 +1487,8 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
>         }
>
>         if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl) ||
> -           nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
> +           nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos) ||
> +           nla_put_be32(skb, IFLA_GENEVE_LABEL, geneve->label))
>                 goto nla_put_failure;
>
>         if (nla_put_be16(skb, IFLA_GENEVE_PORT, geneve->dst_port))
> @@ -1521,7 +1540,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
>                 return dev;
>
>         err = geneve_configure(net, dev, &geneve_remote_unspec,
> -                              0, 0, 0, htons(dst_port), true,
> +                              0, 0, 0, 0, htons(dst_port), true,
>                                GENEVE_F_UDP_ZERO_CSUM6_RX);
>         if (err)
>                 goto err;
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 6bebc97..249eef9 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -479,6 +479,7 @@ enum {
>         IFLA_GENEVE_UDP_CSUM,
>         IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
>         IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
> +       IFLA_GENEVE_LABEL,
>         __IFLA_GENEVE_MAX
>  };
>  #define IFLA_GENEVE_MAX        (__IFLA_GENEVE_MAX - 1)
> --
> 1.9.3
>
