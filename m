From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v2 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Tue, 26 Sep 2017 08:15:46 -0700
Message-ID: <CAJieiUhJCgrykvLNEFaABg6MXKR=FhgbK=bCZF0_QrYFaeG2tw@mail.gmail.com>
References: <cover.1506416988.git.amine.kherbouche@6wind.com> <c40295d24ec5207f5be695a2f888bfa840e2ef2c.1506416988.git.amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:45140 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965145AbdIZPPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:15:47 -0400
Received: by mail-vk0-f45.google.com with SMTP id w23so5557527vkw.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:15:47 -0700 (PDT)
In-Reply-To: <c40295d24ec5207f5be695a2f888bfa840e2ef2c.1506416988.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 2:22 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
> This commit introduces the MPLSoGRE support (RFC 4023), using ip tunnel
> API.
>
> Encap:
>   - Add a new iptunnel type mpls.
>   - Share tx path: gre type mpls loaded from skb->protocol.
>
> Decap:
>   - pull gre hdr and call mpls_forward().
>
> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
> ---
>  include/net/gre.h              |  3 +++
>  include/uapi/linux/if_tunnel.h |  1 +
>  net/ipv4/gre_demux.c           | 22 ++++++++++++++++++++++
>  net/ipv4/ip_gre.c              |  9 +++++++++
>  net/ipv6/ip6_gre.c             |  7 +++++++
>  net/mpls/af_mpls.c             | 40 ++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 82 insertions(+)
>
> diff --git a/include/net/gre.h b/include/net/gre.h
> index d25d836..88a8343 100644
> --- a/include/net/gre.h
> +++ b/include/net/gre.h
> @@ -35,6 +35,9 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
>                                        u8 name_assign_type);
>  int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>                      bool *csum_err, __be16 proto, int nhs);
> +#if IS_ENABLED(CONFIG_MPLS)
> +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len);
> +#endif
>
>  static inline int gre_calc_hlen(__be16 o_flags)
>  {
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index 2e52088..a2f48c0 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -84,6 +84,7 @@ enum tunnel_encap_types {
>         TUNNEL_ENCAP_NONE,
>         TUNNEL_ENCAP_FOU,
>         TUNNEL_ENCAP_GUE,
> +       TUNNEL_ENCAP_MPLS,
>  };
>
>  #define TUNNEL_ENCAP_FLAG_CSUM         (1<<0)
> diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
> index b798862..a6a937e 100644
> --- a/net/ipv4/gre_demux.c
> +++ b/net/ipv4/gre_demux.c
> @@ -23,6 +23,9 @@
>  #include <linux/netdevice.h>
>  #include <linux/if_tunnel.h>
>  #include <linux/spinlock.h>
> +#if IS_ENABLED(CONFIG_MPLS)
> +#include <linux/mpls.h>
> +#endif
>  #include <net/protocol.h>
>  #include <net/gre.h>
>
> @@ -122,6 +125,25 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>  }
>  EXPORT_SYMBOL(gre_parse_header);
>
> +#if IS_ENABLED(CONFIG_MPLS)
> +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len)
> +{
> +       if (unlikely(!pskb_may_pull(skb, gre_hdr_len)))
> +               goto drop;
> +
> +       /* Pop GRE hdr and reset the skb */
> +       skb_pull(skb, gre_hdr_len);
> +       skb_reset_network_header(skb);
> +
> +       mpls_forward(skb, skb->dev, NULL, NULL);

pls check return value

can mpls_gre_rcv be moved to af_mpls.c ?


> +
> +       return 0;
> +drop:
> +       return NET_RX_DROP;
> +}
> +EXPORT_SYMBOL(mpls_gre_rcv);
> +#endif
> +
>  static int gre_rcv(struct sk_buff *skb)
>  {
>         const struct gre_protocol *proto;
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 9cee986..dd4431c 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -412,10 +412,19 @@ static int gre_rcv(struct sk_buff *skb)
>                         return 0;
>         }
>
> +#if IS_ENABLED(CONFIG_MPLS)
> +       if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC))) {
> +               if (mpls_gre_rcv(skb, hdr_len))
> +                       goto drop;
> +               return 0;
> +       }
> +#endif
> +
>         if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
>                 return 0;
>
>         icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
> +

unnecessary new line..

>  drop:
>         kfree_skb(skb);
>         return 0;
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index c82d41e..e52396d 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -476,6 +476,13 @@ static int gre_rcv(struct sk_buff *skb)
>         if (hdr_len < 0)
>                 goto drop;
>
> +#if IS_ENABLED(CONFIG_MPLS)
> +       if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC))) {
> +               if (mpls_gre_rcv(skb, hdr_len))
> +                       goto drop;
> +               return 0;
> +       }

+newline

also would be nice if the IS_ENABLED could be moved to around mpls_gre_rcv.


> +#endif
>         if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
>                 goto drop;
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 36ea2ad..5505074 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -16,6 +16,7 @@
>  #include <net/arp.h>
>  #include <net/ip_fib.h>
>  #include <net/netevent.h>
> +#include <net/ip_tunnels.h>
>  #include <net/netns/generic.h>
>  #if IS_ENABLED(CONFIG_IPV6)
>  #include <net/ipv6.h>
> @@ -39,6 +40,40 @@ static int one = 1;
>  static int label_limit = (1 << 20) - 1;
>  static int ttl_max = 255;
>
> +size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
> +{
> +       return sizeof(struct mpls_shim_hdr);
> +}
> +
> +int ipgre_mpls_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> +                           u8 *protocol, struct flowi4 *fl4)
> +{
> +       return 0;
> +}
> +
> +static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
> +       .encap_hlen     = ipgre_mpls_encap_hlen,
> +       .build_header   = ipgre_mpls_build_header,

There are checks for build header before calling it in iptunnel code,
so, any reason
you can't skip declaring .build_header ?


> +};
> +
> +static int ipgre_tunnel_encap_add_mpls_ops(void)
> +{
> +       int ret = -1;
> +
> +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
> +       ret = ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
> +#endif
> +
> +       return ret;
> +}
> +
> +static void ipgre_tunnel_encap_del_mpls_ops(void)
> +{
> +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
> +       ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
> +#endif
> +}
> +
>  static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>                        struct nlmsghdr *nlh, struct net *net, u32 portid,
>                        unsigned int nlm_flags);
> @@ -2486,6 +2521,10 @@ static int __init mpls_init(void)
>                       0);
>         rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
>                       mpls_netconf_dump_devconf, 0);
> +       err = ipgre_tunnel_encap_add_mpls_ops();
> +       if (err)
> +               pr_err("Can't add mpls over gre tunnel ops\n");
> +

This will throw an error  if CONFIG_NET_IP_TUNNEL is not enabled.
Can you pls put the CONFIG_NET_IP_TUNNEL around
ipgre_tunnel_encap_add_mpls_ops ?
see CONFIG_INET checks in the rest of af_mpls as example.
same for del_ops


>         err = 0;
>  out:
>         return err;
> @@ -2503,6 +2542,7 @@ static void __exit mpls_exit(void)
>         dev_remove_pack(&mpls_packet_type);
>         unregister_netdevice_notifier(&mpls_dev_notifier);
>         unregister_pernet_subsys(&mpls_net_ops);
> +       ipgre_tunnel_encap_del_mpls_ops();
>  }
>  module_exit(mpls_exit);
>
> --
> 2.1.4
>
