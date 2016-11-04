From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 3/9] ipv6: sr: add support for SRH
 encapsulation and injection with lwtunnels
Date: Fri, 4 Nov 2016 09:26:29 -0700
Message-ID: <CALx6S35TVxfmB-Rc=0HpSkLP9-FKHLcsHf97Y=ro_Q_-G5P1XA@mail.gmail.com>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be> <1478255388-32213-4-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35270 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752551AbcKDQ0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 12:26:31 -0400
Received: by mail-qt0-f196.google.com with SMTP id m48so3075019qta.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 09:26:31 -0700 (PDT)
In-Reply-To: <1478255388-32213-4-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 4, 2016 at 3:29 AM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> This patch creates a new type of interfaceless lightweight tunnel (SEG6),
> enabling the encapsulation and injection of SRH within locally emitted
> packets and forwarded packets.
>
> From a configuration viewpoint, a seg6 tunnel would be configured as follows:
>
>   ip -6 ro ad fc00::1/128 encap seg6 mode encap segs fc42::1,fc42::2,fc42::3 dev eth0
>
> Any packet whose destination address is fc00::1 would thus be encapsulated
> within an outer IPv6 header containing the SRH with three segments, and would
> actually be routed to the first segment of the list. If `mode inline' was
> specified instead of `mode encap', then the SRH would be directly inserted
> after the IPv6 header without outer encapsulation.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---
>  include/linux/seg6_iptunnel.h      |   6 +
>  include/net/seg6.h                 |   3 +
>  include/uapi/linux/lwtunnel.h      |   1 +
>  include/uapi/linux/seg6_iptunnel.h |  41 ++++
>  net/core/lwtunnel.c                |   2 +
>  net/ipv6/Makefile                  |   2 +-
>  net/ipv6/seg6.c                    |   7 +
>  net/ipv6/seg6_iptunnel.c           | 380 +++++++++++++++++++++++++++++++++++++
>  8 files changed, 441 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/seg6_iptunnel.h
>  create mode 100644 include/uapi/linux/seg6_iptunnel.h
>  create mode 100644 net/ipv6/seg6_iptunnel.c
>
> diff --git a/include/linux/seg6_iptunnel.h b/include/linux/seg6_iptunnel.h
> new file mode 100644
> index 0000000..5377cf6
> --- /dev/null
> +++ b/include/linux/seg6_iptunnel.h
> @@ -0,0 +1,6 @@
> +#ifndef _LINUX_SEG6_IPTUNNEL_H
> +#define _LINUX_SEG6_IPTUNNEL_H
> +
> +#include <uapi/linux/seg6_iptunnel.h>
> +
> +#endif
> diff --git a/include/net/seg6.h b/include/net/seg6.h
> index 7c7b8ed..5dac54e 100644
> --- a/include/net/seg6.h
> +++ b/include/net/seg6.h
> @@ -16,6 +16,7 @@
>
>  #include <linux/net.h>
>  #include <linux/ipv6.h>
> +#include <net/lwtunnel.h>
>
>  static inline void update_csum_diff4(struct sk_buff *skb, __be32 from,
>                                      __be32 to)
> @@ -48,5 +49,7 @@ static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
>
>  extern int seg6_init(void);
>  extern void seg6_exit(void);
> +extern int seg6_iptunnel_init(void);
> +extern void seg6_iptunnel_exit(void);
>
>  #endif
> diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
> index a478fe8..453cc62 100644
> --- a/include/uapi/linux/lwtunnel.h
> +++ b/include/uapi/linux/lwtunnel.h
> @@ -9,6 +9,7 @@ enum lwtunnel_encap_types {
>         LWTUNNEL_ENCAP_IP,
>         LWTUNNEL_ENCAP_ILA,
>         LWTUNNEL_ENCAP_IP6,
> +       LWTUNNEL_ENCAP_SEG6,
>         __LWTUNNEL_ENCAP_MAX,
>  };
>
> diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
> new file mode 100644
> index 0000000..da5524a
> --- /dev/null
> +++ b/include/uapi/linux/seg6_iptunnel.h
> @@ -0,0 +1,41 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *      modify it under the terms of the GNU General Public License
> + *      as published by the Free Software Foundation; either version
> + *      2 of the License, or (at your option) any later version.
> + */
> +
> +#ifndef _UAPI_LINUX_SEG6_IPTUNNEL_H
> +#define _UAPI_LINUX_SEG6_IPTUNNEL_H
> +
> +enum {
> +       SEG6_IPTUNNEL_UNSPEC,
> +       SEG6_IPTUNNEL_SRH,
> +       __SEG6_IPTUNNEL_MAX,
> +};
> +#define SEG6_IPTUNNEL_MAX (__SEG6_IPTUNNEL_MAX - 1)
> +
> +struct seg6_iptunnel_encap {
> +       int flags;
> +       struct ipv6_sr_hdr srh[0];
> +};
> +
> +#define SEG6_IPTUN_ENCAP_SIZE(x) ((sizeof(*x)) + (((x)->srh->hdrlen + 1) << 3))
> +
> +#define SEG6_IPTUN_FLAG_ENCAP   0x1
> +
> +static inline size_t seg6_lwt_headroom(struct seg6_iptunnel_encap *tuninfo)
> +{
> +       int encap = !!(tuninfo->flags & SEG6_IPTUN_FLAG_ENCAP);
> +
> +       return ((tuninfo->srh->hdrlen + 1) << 3) +
> +              (encap * sizeof(struct ipv6hdr));
> +}
> +
> +#endif
> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
> index 88fd642..03976e9 100644
> --- a/net/core/lwtunnel.c
> +++ b/net/core/lwtunnel.c
> @@ -39,6 +39,8 @@ static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
>                 return "MPLS";
>         case LWTUNNEL_ENCAP_ILA:
>                 return "ILA";
> +       case LWTUNNEL_ENCAP_SEG6:
> +               return "SEG6";
>         case LWTUNNEL_ENCAP_IP6:
>         case LWTUNNEL_ENCAP_IP:
>         case LWTUNNEL_ENCAP_NONE:
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index c92010d..59ee92f 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -9,7 +9,7 @@ ipv6-objs :=    af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
>                 route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
>                 raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
>                 exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
> -               udp_offload.o seg6.o
> +               udp_offload.o seg6.o seg6_iptunnel.o
>
>  ipv6-offload :=        ip6_offload.o tcpv6_offload.o exthdrs_offload.o
>
> diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
> index 9256e6e..8114ece 100644
> --- a/net/ipv6/seg6.c
> +++ b/net/ipv6/seg6.c
> @@ -198,10 +198,16 @@ int __init seg6_init(void)
>         if (err)
>                 goto out_unregister_genl;
>
> +       err = seg6_iptunnel_init();
> +       if (err)
> +               goto out_unregister_pernet;
> +
>         pr_info("Segment Routing with IPv6\n");
>
>  out:
>         return err;
> +out_unregister_pernet:
> +       unregister_pernet_subsys(&ip6_segments_ops);
>  out_unregister_genl:
>         genl_unregister_family(&seg6_genl_family);
>         goto out;
> @@ -209,6 +215,7 @@ int __init seg6_init(void)
>
>  void seg6_exit(void)
>  {
> +       seg6_iptunnel_exit();
>         unregister_pernet_subsys(&ip6_segments_ops);
>         genl_unregister_family(&seg6_genl_family);
>  }
> diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
> new file mode 100644
> index 0000000..9abeb45
> --- /dev/null
> +++ b/net/ipv6/seg6_iptunnel.c
> @@ -0,0 +1,380 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *        modify it under the terms of the GNU General Public License
> + *        as published by the Free Software Foundation; either version
> + *        2 of the License, or (at your option) any later version.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/skbuff.h>
> +#include <linux/net.h>
> +#include <linux/module.h>
> +#include <net/ip.h>
> +#include <net/lwtunnel.h>
> +#include <net/netevent.h>
> +#include <net/netns/generic.h>
> +#include <net/ip6_fib.h>
> +#include <net/route.h>
> +#include <net/seg6.h>
> +#include <linux/seg6.h>
> +#include <linux/seg6_iptunnel.h>
> +#include <net/addrconf.h>
> +#include <net/ip6_route.h>
> +#ifdef CONFIG_DST_CACHE
> +#include <net/dst_cache.h>
> +#endif
> +
> +struct seg6_lwt {
> +#ifdef CONFIG_DST_CACHE
> +       struct dst_cache cache;
> +#endif
> +       struct seg6_iptunnel_encap tuninfo[0];
> +};
> +
> +static inline struct seg6_lwt *seg6_lwt_lwtunnel(struct lwtunnel_state *lwt)
> +{
> +       return (struct seg6_lwt *)lwt->data;
> +}
> +
> +static inline struct seg6_iptunnel_encap *
> +seg6_encap_lwtunnel(struct lwtunnel_state *lwt)
> +{
> +       return seg6_lwt_lwtunnel(lwt)->tuninfo;
> +}
> +
> +static const struct nla_policy seg6_iptunnel_policy[SEG6_IPTUNNEL_MAX + 1] = {
> +       [SEG6_IPTUNNEL_SRH]     = { .type = NLA_BINARY },
> +};
> +
> +int nla_put_srh(struct sk_buff *skb, int attrtype,
> +               struct seg6_iptunnel_encap *tuninfo)
> +{
> +       struct seg6_iptunnel_encap *data;
> +       struct nlattr *nla;
> +       int len;
> +
> +       len = SEG6_IPTUN_ENCAP_SIZE(tuninfo);
> +
> +       nla = nla_reserve(skb, attrtype, len);
> +       if (!nla)
> +               return -EMSGSIZE;
> +
> +       data = nla_data(nla);
> +       memcpy(data, tuninfo, len);
> +
> +       return 0;
> +}
> +
> +static void set_tun_src(struct net *net, struct net_device *dev,
> +                       struct in6_addr *daddr, struct in6_addr *saddr)
> +{
> +       struct seg6_pernet_data *sdata = seg6_pernet(net);
> +       struct in6_addr *tun_src;
> +
> +       rcu_read_lock();
> +
> +       tun_src = rcu_dereference(sdata->tun_src);
> +
> +       if (!ipv6_addr_any(tun_src)) {
> +               memcpy(saddr, tun_src, sizeof(struct in6_addr));
> +       } else {
> +               ipv6_dev_get_saddr(net, dev, daddr, IPV6_PREFER_SRC_PUBLIC,
> +                                  saddr);
> +       }
> +
> +       rcu_read_unlock();
> +}
> +
> +/* encapsulate an IPv6 packet within an outer IPv6 header with a given SRH */
> +static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
> +{
> +       struct net *net = dev_net(skb_dst(skb)->dev);
> +       struct ipv6hdr *hdr, *inner_hdr;
> +       struct ipv6_sr_hdr *isrh;
> +       int hdrlen, tot_len, err;
> +
> +       hdrlen = (osrh->hdrlen + 1) << 3;
> +       tot_len = hdrlen + sizeof(*hdr);
> +
> +       err = pskb_expand_head(skb, tot_len, 0, GFP_ATOMIC);
> +       if (unlikely(err))
> +               return err;
> +
> +       inner_hdr = ipv6_hdr(skb);
> +
> +       skb_push(skb, tot_len);
> +       skb_reset_network_header(skb);
> +       skb_mac_header_rebuild(skb);
> +       hdr = ipv6_hdr(skb);
> +
> +       /* inherit tc, flowlabel and hlim
> +        * hlim will be decremented in ip6_forward() afterwards and
> +        * decapsulation will overwrite inner hlim with outer hlim
> +        */
> +       ip6_flow_hdr(hdr, ip6_tclass(ip6_flowinfo(inner_hdr)),
> +                    ip6_flowlabel(inner_hdr));
> +       hdr->hop_limit = inner_hdr->hop_limit;
> +       hdr->nexthdr = NEXTHDR_ROUTING;
> +
> +       isrh = (void *)hdr + sizeof(*hdr);
> +       memcpy(isrh, osrh, hdrlen);
> +
> +       isrh->nexthdr = NEXTHDR_IPV6;
> +
> +       hdr->daddr = isrh->segments[isrh->first_segment];
> +       set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
> +
> +       skb_postpush_rcsum(skb, hdr, tot_len);
> +
> +       return 0;
> +}
> +
> +/* insert an SRH within an IPv6 packet, just after the IPv6 header */
> +static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
> +{
> +       struct ipv6hdr *hdr, *oldhdr;
> +       struct ipv6_sr_hdr *isrh;
> +       int hdrlen, err;
> +
> +       hdrlen = (osrh->hdrlen + 1) << 3;
> +
> +       err = pskb_expand_head(skb, hdrlen, 0, GFP_ATOMIC);
> +       if (unlikely(err))
> +               return err;
> +
> +       oldhdr = ipv6_hdr(skb);
> +
> +       skb_pull(skb, sizeof(struct ipv6hdr));
> +       skb_postpull_rcsum(skb, skb_network_header(skb),
> +                          sizeof(struct ipv6hdr));
> +
> +       skb_push(skb, sizeof(struct ipv6hdr) + hdrlen);
> +       skb_reset_network_header(skb);
> +       skb_mac_header_rebuild(skb);
> +
> +       hdr = ipv6_hdr(skb);
> +
> +       memmove(hdr, oldhdr, sizeof(*hdr));
> +
> +       isrh = (void *)hdr + sizeof(*hdr);
> +       memcpy(isrh, osrh, hdrlen);
> +
> +       isrh->nexthdr = hdr->nexthdr;
> +       hdr->nexthdr = NEXTHDR_ROUTING;
> +
> +       isrh->segments[0] = hdr->daddr;
> +       hdr->daddr = isrh->segments[isrh->first_segment];
> +
> +       skb_postpush_rcsum(skb, hdr, sizeof(struct ipv6hdr) + hdrlen);
> +
> +       return 0;
> +}
> +
> +static int seg6_do_srh(struct sk_buff *skb)
> +{
> +       struct dst_entry *dst = skb_dst(skb);
> +       struct seg6_iptunnel_encap *tinfo;
> +       int err = 0;
> +
> +       tinfo = seg6_encap_lwtunnel(dst->lwtstate);
> +
> +       if (likely(!skb->encapsulation)) {
> +               skb_reset_inner_headers(skb);
> +               skb->encapsulation = 1;
> +       }
> +
> +       if (tinfo->flags & SEG6_IPTUN_FLAG_ENCAP) {
> +               err = seg6_do_srh_encap(skb, tinfo->srh);
> +       } else {
> +               err = seg6_do_srh_inline(skb, tinfo->srh);
> +               skb_reset_inner_headers(skb);
> +       }
> +
> +       if (err)
> +               return err;
> +
> +       ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
> +       skb_set_transport_header(skb, sizeof(struct ipv6hdr));
> +
> +       skb_set_inner_protocol(skb, skb->protocol);
> +
> +       return 0;
> +}
> +
> +int seg6_input(struct sk_buff *skb)
> +{
> +       int err;
> +
> +       err = seg6_do_srh(skb);
> +       if (unlikely(err)) {
> +               kfree_skb(skb);
> +               return err;
> +       }
> +
> +       skb_dst_drop(skb);
> +       ip6_route_input(skb);
> +
> +       return dst_input(skb);
> +}
> +
> +int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> +{
> +       struct dst_entry *orig_dst = skb_dst(skb);
> +       struct dst_entry *dst = NULL;
> +       struct seg6_lwt *slwt;
> +       int err = -EINVAL;
> +
> +       err = seg6_do_srh(skb);

Technically we're not allowed by the standard to insert extension
headers when forwarding, only the source host can place EH in packets.
There was a _long_ discussion about this in 6man WG and it appears
that for RFC2460bis the plan is to make this point clear. The
rationale is that inserting extension headers in the middle of the
network break PMTUD, IPsec AH, amongst other things.

I think people are going to do this anyway (especially for something
like SR) so I don't think we should abandon this patch. But, we
probably need a big disclaimer documented that if someone does this
they may see problems in the network (in other words they should only
use this if they know what they are doing).

> +       if (unlikely(err))
> +               goto drop;
> +
> +       slwt = seg6_lwt_lwtunnel(orig_dst->lwtstate);
> +
> +#ifdef CONFIG_DST_CACHE
> +       dst = dst_cache_get(&slwt->cache);
> +#endif
> +
> +       if (unlikely(!dst)) {
> +               struct ipv6hdr *hdr = ipv6_hdr(skb);
> +               struct flowi6 fl6;
> +
> +               fl6.daddr = hdr->daddr;
> +               fl6.saddr = hdr->saddr;
> +               fl6.flowlabel = ip6_flowinfo(hdr);
> +               fl6.flowi6_mark = skb->mark;
> +               fl6.flowi6_proto = hdr->nexthdr;
> +
> +               dst = ip6_route_output(net, NULL, &fl6);
> +               if (dst->error) {
> +                       err = dst->error;
> +                       dst_release(dst);
> +                       goto drop;
> +               }
> +
> +#ifdef CONFIG_DST_CACHE
> +               dst_cache_set_ip6(&slwt->cache, dst, &fl6.saddr);
> +#endif
> +       }
> +
> +       skb_dst_drop(skb);
> +       skb_dst_set(skb, dst);
> +
> +       return dst_output(net, sk, skb);
> +drop:
> +       kfree_skb(skb);
> +       return err;
> +}
> +
> +static int seg6_build_state(struct net_device *dev, struct nlattr *nla,
> +                           unsigned int family, const void *cfg,
> +                           struct lwtunnel_state **ts)
> +{
> +       struct nlattr *tb[SEG6_IPTUNNEL_MAX + 1];
> +       struct seg6_iptunnel_encap *tuninfo;
> +       struct lwtunnel_state *newts;
> +       struct seg6_lwt *slwt;
> +       int tuninfo_len;
> +       int err;
> +
> +       err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
> +                              seg6_iptunnel_policy);
> +
> +       if (err < 0)
> +               return err;
> +
> +       if (!tb[SEG6_IPTUNNEL_SRH])
> +               return -EINVAL;
> +
> +       tuninfo = nla_data(tb[SEG6_IPTUNNEL_SRH]);
> +       tuninfo_len = SEG6_IPTUN_ENCAP_SIZE(tuninfo);
> +
> +       newts = lwtunnel_state_alloc(tuninfo_len + sizeof(*slwt));
> +       if (!newts)
> +               return -ENOMEM;
> +
> +       slwt = seg6_lwt_lwtunnel(newts);
> +
> +#ifdef CONFIG_DST_CACHE
> +       err = dst_cache_init(&slwt->cache, GFP_KERNEL);
> +       if (err) {
> +               kfree(newts);
> +               return err;
> +       }
> +#endif
> +
> +       memcpy(&slwt->tuninfo, tuninfo, tuninfo_len);
> +
Thomas pointed out to me that we are just blindly copying the SR
option from userspace. We really should validate that it is well
formed and acceptable to send. Minimally, we should check that
addresses are valid, the TLVs are well formed, and we need to decide
on rather to allow arbitrary TLVs that are unknown to the kernel. Same
thing should be true for socket options or other interfaces to program
SR.

> +       newts->type = LWTUNNEL_ENCAP_SEG6;
> +       newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
> +                       LWTUNNEL_STATE_INPUT_REDIRECT;
> +       newts->headroom = seg6_lwt_headroom(tuninfo);
> +
> +       *ts = newts;
> +
> +       return 0;
> +}
> +
> +#ifdef CONFIG_DST_CACHE
> +static void seg6_destroy_state(struct lwtunnel_state *lwt)
> +{
> +       dst_cache_destroy(&seg6_lwt_lwtunnel(lwt)->cache);
> +}
> +#endif
> +
> +static int seg6_fill_encap_info(struct sk_buff *skb,
> +                               struct lwtunnel_state *lwtstate)
> +{
> +       struct seg6_iptunnel_encap *tuninfo = seg6_encap_lwtunnel(lwtstate);
> +
> +       if (nla_put_srh(skb, SEG6_IPTUNNEL_SRH, tuninfo))
> +               return -EMSGSIZE;
> +
> +       return 0;
> +}
> +
> +static int seg6_encap_nlsize(struct lwtunnel_state *lwtstate)
> +{
> +       struct seg6_iptunnel_encap *tuninfo = seg6_encap_lwtunnel(lwtstate);
> +
> +       return nla_total_size(SEG6_IPTUN_ENCAP_SIZE(tuninfo));
> +}
> +
> +static int seg6_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
> +{
> +       struct seg6_iptunnel_encap *a_hdr = seg6_encap_lwtunnel(a);
> +       struct seg6_iptunnel_encap *b_hdr = seg6_encap_lwtunnel(b);
> +       int len = SEG6_IPTUN_ENCAP_SIZE(a_hdr);
> +
> +       if (len != SEG6_IPTUN_ENCAP_SIZE(b_hdr))
> +               return 1;
> +
> +       return memcmp(a_hdr, b_hdr, len);
> +}
> +
> +static const struct lwtunnel_encap_ops seg6_iptun_ops = {
> +       .build_state = seg6_build_state,
> +#ifdef CONFIG_DST_CACHE
> +       .destroy_state = seg6_destroy_state,
> +#endif
> +       .output = seg6_output,
> +       .input = seg6_input,
> +       .fill_encap = seg6_fill_encap_info,
> +       .get_encap_size = seg6_encap_nlsize,
> +       .cmp_encap = seg6_encap_cmp,
> +};
> +
> +int __init seg6_iptunnel_init(void)
> +{
> +       return lwtunnel_encap_add_ops(&seg6_iptun_ops, LWTUNNEL_ENCAP_SEG6);
> +}
> +
> +void seg6_iptunnel_exit(void)
> +{
> +       lwtunnel_encap_del_ops(&seg6_iptun_ops, LWTUNNEL_ENCAP_SEG6);
> +}
> --
> 2.7.3
>
