From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC net-next 4/4] net: ipv6: Initial support for VRFs
Date: Mon, 21 Sep 2015 17:08:54 -0700
Message-ID: <CALx6S37hPDG1FLYXfLJgYcionA2oj+v1dLFaCVoP91qVrUUh7A@mail.gmail.com>
References: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
	<1442878378-13322-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33740 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529AbbIVAIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:08:55 -0400
Received: by iofh134 with SMTP id h134so956095iof.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 17:08:54 -0700 (PDT)
In-Reply-To: <1442878378-13322-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 4:32 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Add basic support for VRFs to IPv6 stack. This is a good start point.
> ping to and from a VRF works. Basic tcp and udp clients and server all
> work fine with VRFs.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv6/addrconf.c   |  4 +++-
>  net/ipv6/datagram.c   |  4 ++++
>  net/ipv6/icmp.c       |  6 +++++-
>  net/ipv6/ip6_fib.c    |  1 +
>  net/ipv6/ip6_output.c |  6 ++++--
>  net/ipv6/ndisc.c      |  9 +++++++--
>  net/ipv6/route.c      | 17 +++++++++++++++--
>  7 files changed, 39 insertions(+), 8 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 75d3dde32c69..f4677a9c01ac 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -81,6 +81,7 @@
>  #include <net/ip.h>
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
> +#include <net/l3mdev.h>
>  #include <linux/if_tunnel.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/netconf.h>
> @@ -2179,8 +2180,9 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
>         struct fib6_node *fn;
>         struct rt6_info *rt = NULL;
>         struct fib6_table *table;
> +       u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX;
>
> -       table = fib6_get_table(dev_net(dev), RT6_TABLE_PREFIX);
> +       table = fib6_get_table(dev_net(dev), tb_id);
>         if (!table)
>                 return NULL;
>
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 9aadd57808a5..11980ee57507 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -142,6 +142,10 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
>                         err = -EINVAL;
>                         goto out;
>                 }
> +       } else if (sk->sk_bound_dev_if &&
> +                  netif_index_is_l3_master(sock_net(sk),

I suppose I have the same issues with this that were put in the IPv4
code path. Core IPv6 code should not care about any specific network
interfaces other than maybe loopback. Generalizing VPF to be l3m
doesn't really address this point. Have you looked at abstracting more
of this into the ndo functions (i.e. for source address selection) or
routing lookup?

Tom


> +                                           sk->sk_bound_dev_if)) {
> +               fl6.flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
>         }
>
>         sk->sk_v6_daddr = *daddr;
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 6c2b2132c8d3..efb1c00f2270 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -68,6 +68,7 @@
>  #include <net/xfrm.h>
>  #include <net/inet_common.h>
>  #include <net/dsfield.h>
> +#include <net/l3mdev.h>
>
>  #include <asm/uaccess.h>
>
> @@ -496,6 +497,9 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>         else if (!fl6.flowi6_oif)
>                 fl6.flowi6_oif = np->ucast_oif;
>
> +       if (!fl6.flowi6_oif)
> +               fl6.flowi6_oif = l3mdev_master_ifindex(skb->dev);
> +
>         dst = icmpv6_route_lookup(net, skb, sk, &fl6);
>         if (IS_ERR(dst))
>                 goto out;
> @@ -575,7 +579,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>         fl6.daddr = ipv6_hdr(skb)->saddr;
>         if (saddr)
>                 fl6.saddr = *saddr;
> -       fl6.flowi6_oif = skb->dev->ifindex;
> +       fl6.flowi6_oif = l3mdev_fib_oif(skb->dev);
>         fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
>         fl6.flowi6_mark = mark;
>         security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index 418d9823692b..318cf5a34ca5 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -259,6 +259,7 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
>
>         return NULL;
>  }
> +EXPORT_SYMBOL_GPL(fib6_get_table);
>
>  static void __net_init fib6_tables_init(struct net *net)
>  {
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 291a07be5dfb..bbd752cef5c2 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -55,6 +55,7 @@
>  #include <net/xfrm.h>
>  #include <net/checksum.h>
>  #include <linux/mroute6.h>
> +#include <net/l3mdev.h>
>
>  static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
>  {
> @@ -874,7 +875,8 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
>  #ifdef CONFIG_IPV6_SUBTREES
>             ip6_rt_check(&rt->rt6i_src, &fl6->saddr, np->saddr_cache) ||
>  #endif
> -           (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex)) {
> +          (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC) &&
> +             (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex))) {
>                 dst_release(dst);
>                 dst = NULL;
>         }
> @@ -1026,7 +1028,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
>         if (final_dst)
>                 fl6->daddr = *final_dst;
>         if (!fl6->flowi6_oif)
> -               fl6->flowi6_oif = dst->dev->ifindex;
> +               fl6->flowi6_oif = l3mdev_fib_oif(dst->dev);
>
>         return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
>  }
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index dde5a1e5875a..278627b01283 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -67,6 +67,7 @@
>  #include <net/flow.h>
>  #include <net/ip6_checksum.h>
>  #include <net/inet_common.h>
> +#include <net/l3mdev.h>
>  #include <linux/proc_fs.h>
>
>  #include <linux/netfilter.h>
> @@ -147,6 +148,7 @@ struct neigh_table nd_tbl = {
>         .gc_thresh2 =    512,
>         .gc_thresh3 =   1024,
>  };
> +EXPORT_SYMBOL_GPL(nd_tbl);
>
>  static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
>  {
> @@ -441,8 +443,9 @@ static void ndisc_send_skb(struct sk_buff *skb,
>
>         if (!dst) {
>                 struct flowi6 fl6;
> +               int oif = l3mdev_fib_oif(skb->dev);
>
> -               icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
> +               icmpv6_flow_init(sk, &fl6, type, saddr, daddr, oif);
>                 dst = icmp6_dst_alloc(skb->dev, &fl6);
>                 if (IS_ERR(dst)) {
>                         kfree_skb(skb);
> @@ -1487,6 +1490,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>         int rd_len;
>         u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
>         bool ret;
> +       int oif;
>
>         if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
>                 ND_PRINTK(2, warn, "Redirect: no link-local address on %s\n",
> @@ -1501,8 +1505,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>                 return;
>         }
>
> +       oif = l3mdev_fib_oif(dev);
>         icmpv6_flow_init(sk, &fl6, NDISC_REDIRECT,
> -                        &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
> +                        &saddr_buf, &ipv6_hdr(skb)->saddr, oif);
>
>         dst = ip6_route_output(net, NULL, &fl6);
>         if (dst->error) {
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 53617d715188..2996dd957536 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -61,6 +61,7 @@
>  #include <net/nexthop.h>
>  #include <net/lwtunnel.h>
>  #include <net/ip_tunnels.h>
> +#include <net/l3mdev.h>
>
>  #include <asm/uaccess.h>
>
> @@ -1068,6 +1069,8 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>         fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
>         saved_fn = fn;
>
> +       if (fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)
> +               oif = 0;
>  redo_rt6_select:
>         rt = rt6_select(fn, oif, strict);
>         if (rt->rt6i_nsiblings)
> @@ -1165,7 +1168,7 @@ void ip6_route_input(struct sk_buff *skb)
>         int flags = RT6_LOOKUP_F_HAS_SADDR;
>         struct ip_tunnel_info *tun_info;
>         struct flowi6 fl6 = {
> -               .flowi6_iif = skb->dev->ifindex,
> +               .flowi6_iif = l3mdev_fib_oif(skb->dev),
>                 .daddr = iph->daddr,
>                 .saddr = iph->saddr,
>                 .flowlabel = ip6_flowinfo(iph),
> @@ -1189,8 +1192,13 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
>  struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
>                                     struct flowi6 *fl6)
>  {
> +       struct dst_entry *dst;
>         int flags = 0;
>
> +       dst = l3mdev_rt6_dst_by_oif(net, fl6);
> +       if (dst)
> +               return dst;
> +
>         fl6->flowi6_iif = LOOPBACK_IFINDEX;
>
>         if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
> @@ -1772,6 +1780,8 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
>                 idev = in6_dev_get(dev);
>                 if (!idev)
>                         goto out;
> +
> +               cfg->fc_table = l3mdev_fib_table(dev) ? : cfg->fc_table;
>         }
>
>         if (cfg->fc_metric == 0)
> @@ -2492,6 +2502,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>                                     const struct in6_addr *addr,
>                                     bool anycast)
>  {
> +       u32 tb_id;
>         struct net *net = dev_net(idev->dev);
>         struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
>                                             DST_NOCOUNT);
> @@ -2514,7 +2525,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>         rt->rt6i_gateway  = *addr;
>         rt->rt6i_dst.addr = *addr;
>         rt->rt6i_dst.plen = 128;
> -       rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
> +
> +       tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
> +       rt->rt6i_table = fib6_get_table(net, tb_id);
>
>         atomic_set(&rt->dst.__refcnt, 1);
>
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
