From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [Patch net] ipv6: initialize route null entry in addrconf_init()
Date: Thu, 4 May 2017 14:28:37 +0200
Message-ID: <CAAeHK+zmMUvt4Lz28k3Oyxi1QFmrTMBe34=6xJDBPxkeivnPeA@mail.gmail.com>
References: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Ahern <dsahern@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:34781 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdEDM2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:28:39 -0400
Received: by mail-yb0-f177.google.com with SMTP id 8so2868792ybw.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 05:28:39 -0700 (PDT)
In-Reply-To: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 4, 2017 at 7:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Andrey reported a crash on init_net.ipv6.ip6_null_entry->rt6i_idev
> since it is always NULL.
>
> This is clearly wrong, we have code to initialize it to loopback_dev,
> unfortunately the order is still not correct.
>
> loopback_dev is registered very early during boot, we lose a chance
> to re-initialize it in notifier. addrconf_init() is called after
> ip6_route_init(), which means we have no chance to correct it.
>
> Fix it by moving this initialization explicitly after
> ipv6_add_dev(init_net.loopback_dev) in addrconf_init().
>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Hi Cong,

This fixes the bug triggered by my reproducer.

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  include/net/ip6_route.h |  1 +
>  net/ipv6/addrconf.c     |  2 ++
>  net/ipv6/route.c        | 26 +++++++++++++++-----------
>  3 files changed, 18 insertions(+), 11 deletions(-)
>
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 9dc2c18..f5e625f 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -84,6 +84,7 @@ struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
>  struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>                                int ifindex, struct flowi6 *fl6, int flags);
>
> +void ip6_route_init_special_entries(void);
>  int ip6_route_init(void);
>  void ip6_route_cleanup(void);
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index a2a370b..77a4bd5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -6573,6 +6573,8 @@ int __init addrconf_init(void)
>                 goto errlo;
>         }
>
> +       ip6_route_init_special_entries();
> +
>         for (i = 0; i < IN6_ADDR_HSIZE; i++)
>                 INIT_HLIST_HEAD(&inet6_addr_lst[i]);
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index a1bf426..2f11366 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -4027,6 +4027,21 @@ static struct notifier_block ip6_route_dev_notifier = {
>         .priority = 0,
>  };
>
> +void __init ip6_route_init_special_entries(void)
> +{
> +       /* Registering of the loopback is done before this portion of code,
> +        * the loopback reference in rt6_info will not be taken, do it
> +        * manually for init_net */
> +       init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
> +       init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> +  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
> +       init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
> +       init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> +       init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
> +       init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> +  #endif
> +}
> +
>  int __init ip6_route_init(void)
>  {
>         int ret;
> @@ -4053,17 +4068,6 @@ int __init ip6_route_init(void)
>
>         ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
>
> -       /* Registering of the loopback is done before this portion of code,
> -        * the loopback reference in rt6_info will not be taken, do it
> -        * manually for init_net */
> -       init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
> -       init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> -  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
> -       init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
> -       init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> -       init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
> -       init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
> -  #endif
>         ret = fib6_init();
>         if (ret)
>                 goto out_register_subsys;
> --
> 2.5.5
>
