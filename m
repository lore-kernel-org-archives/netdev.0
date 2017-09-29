From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Thu, 28 Sep 2017 21:11:52 -0700
Message-ID: <CALx6S35b6gk39KOXTTzCFiz4S+JOOxcdJGB-+n3nx0x=xxVi8Q@mail.gmail.com>
References: <cover.1506590878.git.amine.kherbouche@6wind.com> <2e611d0f6e0c39ff54bfe464cdf9cf6eeb7843e1.1506590878.git.amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xeb@mail.ru, roopa <roopa@cumulusnetworks.com>, equinox@diac24.net
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:50135 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdI2ELy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 00:11:54 -0400
Received: by mail-qt0-f195.google.com with SMTP id o3so181477qte.6
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 21:11:53 -0700 (PDT)
In-Reply-To: <2e611d0f6e0c39ff54bfe464cdf9cf6eeb7843e1.1506590878.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 2:34 AM, Amine Kherbouche
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
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/net/gre.h              |  1 +
>  include/uapi/linux/if_tunnel.h |  1 +
>  net/ipv4/gre_demux.c           | 27 +++++++++++++++++++++++++++
>  net/ipv4/ip_gre.c              |  3 +++
>  net/ipv6/ip6_gre.c             |  3 +++
>  net/mpls/af_mpls.c             | 36 ++++++++++++++++++++++++++++++++++++
>  6 files changed, 71 insertions(+)
>
> diff --git a/include/net/gre.h b/include/net/gre.h
> index d25d836..aa3c4d3 100644
> --- a/include/net/gre.h
> +++ b/include/net/gre.h
> @@ -35,6 +35,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
>                                        u8 name_assign_type);
>  int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>                      bool *csum_err, __be16 proto, int nhs);
> +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len);
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
> index b798862..40484a3 100644
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
> @@ -122,6 +125,30 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
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

I don't see why MPLS/GRE needs to be a special case in gre_rcv. Can't
we just follow the normal processing patch which calls the proto ops
handler for the protocol in the GRE header? Also, if protocol specific
code is added to rcv function that most likely means that we need to
update the related offloads also (grant it that MPLS doesn't support
GRO but it looks like it supports GSO). Additionally, we'd need to
consider if flow dissector needs a similar special case (I will point
out that my recently posted patches there eliminated TEB as the one
special case in GRE dissection).

Thanks,
Tom

> +       return mpls_forward(skb, skb->dev, NULL, NULL);
> +drop:
> +       kfree_skb(skb);
> +       return NET_RX_DROP;
> +}
> +#else
> +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len)
> +{
> +       kfree_skb(skb);
> +       return NET_RX_DROP;
> +}
> +#endif
> +EXPORT_SYMBOL(mpls_gre_rcv);
> +
>  static int gre_rcv(struct sk_buff *skb)
>  {
>         const struct gre_protocol *proto;
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 9cee986..7a50e4f 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -412,6 +412,9 @@ static int gre_rcv(struct sk_buff *skb)
>                         return 0;
>         }
>
> +       if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC)))
> +               return mpls_gre_rcv(skb, hdr_len);
> +
>         if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
>                 return 0;
>
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index c82d41e..440efb1 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -476,6 +476,9 @@ static int gre_rcv(struct sk_buff *skb)
>         if (hdr_len < 0)
>                 goto drop;
>
> +       if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC)))
> +               return mpls_gre_rcv(skb, hdr_len);
> +
>         if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
>                 goto drop;
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 36ea2ad..4274243 100644
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
> @@ -39,6 +40,36 @@ static int one = 1;
>  static int label_limit = (1 << 20) - 1;
>  static int ttl_max = 255;
>
> +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
> +size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
> +{
> +       return sizeof(struct mpls_shim_hdr);
> +}
> +
> +static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
> +       .encap_hlen     = ipgre_mpls_encap_hlen,
> +};
> +
> +static int ipgre_tunnel_encap_add_mpls_ops(void)
> +{
> +       return ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
> +}
> +
> +static void ipgre_tunnel_encap_del_mpls_ops(void)
> +{
> +       ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
> +}
> +#else
> +static int ipgre_tunnel_encap_add_mpls_ops(void)
> +{
> +       return 0;
> +}
> +
> +static void ipgre_tunnel_encap_del_mpls_ops(void)
> +{
> +}
> +#endif
> +
>  static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>                        struct nlmsghdr *nlh, struct net *net, u32 portid,
>                        unsigned int nlm_flags);
> @@ -2486,6 +2517,10 @@ static int __init mpls_init(void)
>                       0);
>         rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
>                       mpls_netconf_dump_devconf, 0);
> +       err = ipgre_tunnel_encap_add_mpls_ops();
> +       if (err)
> +               pr_err("Can't add mpls over gre tunnel ops\n");
> +
>         err = 0;
>  out:
>         return err;
> @@ -2503,6 +2538,7 @@ static void __exit mpls_exit(void)
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
