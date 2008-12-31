From: "Eduard Guzovsky" <eguzovsky@gmail.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some time
Date: Wed, 31 Dec 2008 14:53:04 -0500
Message-ID: <1fd9f5a40812311153y38adff46gd1121d4a510585e1@mail.gmail.com>
References: <20081229.235230.53178944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: berni@birkenwald.de, dlstevens@us.ibm.com, pekkas@netcore.fi,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:42067 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbYLaTxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 14:53:06 -0500
Received: by wf-out-1314.google.com with SMTP id 27so5931917wfd.4
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2008 11:53:04 -0800 (PST)
In-Reply-To: <20081229.235230.53178944.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Thank you for the patch. I tested a slightly modified version of it
(could not test it "verbatim" - we use a 2.6.18 based kernel) - it
works!

Question: I noticed that with your patch ndisc_dst_alloc() can still
return a dst_entry with NULL as a neighbour. Is this Ok?

Suggestion: How about creating a per interface "catch all"
route+neighbour entry for all ipv6 link level multicasts. This entry
should be used when no "specific" route/neighbour entry is configured.
This would prevent cache pollution with useless entries created by
every incoming packet with link level multicast address.

Thanks,

-Ed


On Tue, Dec 30, 2008 at 2:52 AM, David Miller <davem@davemloft.net> wrote:
>
> Eduard, thanks for your analysis and RFC patch.
>
> I agree this is an ugly situation.
>
> Looking over this area the real problem is that the neighbour cache
> can't do anything to apply back pressure on the routing cache when it
> fills up with essentially unused multicast entries like this.
>
> When we hit the upper limits (such as gc_thresh3) for the neighbour
> cache, it tries to do things like neigh_forced_gc().
>
> But this won't accomplish anything since all of these ipv6 multicast
> routes have a reference on the neigh entries filling up the table, so
> the forced GC won't be able to liberate them
>
> So you're absolutely right that the route cache pollution is the core
> problem.
>
> Looking at the IPV4 routing cache we have code which goes:
>
>                int err = arp_bind_neighbour(&rt->u.dst);
>                if (err) {
>  ...
>                        /* Neighbour tables are full and nothing
>                           can be released. Try to shrink route cache,
>                           it is most likely it holds some neighbour records.
>                         */
>
> and then proceeds to try and forcefully flush some routing cache
> entries.
>
> So the real fix is that IPV6 should do something similar.
>
> Something like the following (untested) patch:
>
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index ce532f2..1459ed3 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -155,9 +155,9 @@ static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, const s
>  {
>
>        if (dev)
> -               return __neigh_lookup(&nd_tbl, addr, dev, 1);
> +               return __neigh_lookup_errno(&nd_tbl, addr, dev);
>
> -       return NULL;
> +       return ERR_PTR(-ENODEV);
>  }
>
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 18c486c..0db4129 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -627,6 +627,9 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
>        rt = ip6_rt_copy(ort);
>
>        if (rt) {
> +               struct neighbour *neigh;
> +               int attempts = !in_softirq();
> +
>                if (!(rt->rt6i_flags&RTF_GATEWAY)) {
>                        if (rt->rt6i_dst.plen != 128 &&
>                            ipv6_addr_equal(&rt->rt6i_dst.addr, daddr))
> @@ -646,7 +649,35 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *dad
>                }
>  #endif
>
> -               rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
> +       retry:
> +               neigh = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
> +               if (IS_ERR(neigh)) {
> +                       struct net *net = dev_net(rt->rt6i_dev);
> +                       int saved_rt_min_interval =
> +                               net->ipv6.sysctl.ip6_rt_gc_min_interval;
> +                       int saved_rt_elasticity =
> +                               net->ipv6.sysctl.ip6_rt_gc_elasticity;
> +
> +                       if (attempts-- > 0) {
> +                               net->ipv6.sysctl.ip6_rt_gc_elasticity = 1;
> +                               net->ipv6.sysctl.ip6_rt_gc_min_interval = 0;
> +
> +                               ip6_dst_gc(net->ipv6.ip6_dst_ops);
> +
> +                               net->ipv6.sysctl.ip6_rt_gc_elasticity =
> +                                       saved_rt_elasticity;
> +                               net->ipv6.sysctl.ip6_rt_gc_min_interval =
> +                                       saved_rt_min_interval;
> +                               goto retry;
> +                       }
> +
> +                       if (net_ratelimit())
> +                               printk(KERN_WARNING
> +                                      "Neighbour table overflow.\n");
> +                       dst_free(&rt->u.dst);
> +                       return NULL;
> +               }
> +               rt->rt6i_nexthop = neigh;
>
>        }
>
> @@ -945,8 +976,11 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
>        dev_hold(dev);
>        if (neigh)
>                neigh_hold(neigh);
> -       else
> +       else {
>                neigh = ndisc_get_neigh(dev, addr);
> +               if (IS_ERR(neigh))
> +                       neigh = NULL;
> +       }
>
>        rt->rt6i_dev      = dev;
>        rt->rt6i_idev     = idev;
> @@ -1887,6 +1921,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>  {
>        struct net *net = dev_net(idev->dev);
>        struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
> +       struct neighbour *neigh;
>
>        if (rt == NULL)
>                return ERR_PTR(-ENOMEM);
> @@ -1909,11 +1944,18 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>                rt->rt6i_flags |= RTF_ANYCAST;
>        else
>                rt->rt6i_flags |= RTF_LOCAL;
> -       rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
> -       if (rt->rt6i_nexthop == NULL) {
> +       neigh = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
> +       if (IS_ERR(neigh)) {
>                dst_free(&rt->u.dst);
> -               return ERR_PTR(-ENOMEM);
> +
> +               /* We are casting this because that is the return
> +                * value type.  But a errno encoded pointer is the
> +                * same regardless of the underlying pointer type,
> +                * and that's what we are returning.  So this is OK.
> +                */
> +               return (struct rt6_info *) neigh;
>        }
> +       rt->rt6i_nexthop = neigh;
>
>        ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
>        rt->rt6i_dst.plen = 128;
>
