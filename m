From: Daniel Walter <sahne@0x90.at>
Subject: Re: [PATCH 1/1] ipv6: RTA_PREFSRC support for ipv6 route source
 address selection
Date: Thu, 14 Apr 2011 16:49:54 +0200
Message-ID: <20110414144954.GA79918@0x90.at>
References: <20110414071057.GB78446@0x90.at>
 <4DA6FE25.70608@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Stephen Clark <sclark46@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.0x90.at ([78.46.59.21]:44074 "EHLO mail.0x90.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758921Ab1DNOtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 10:49:23 -0400
Content-Disposition: inline
In-Reply-To: <4DA6FE25.70608@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2011 at 10:01:09AM -0400, Stephen Clark wrote:
> On 04/14/2011 03:10 AM, Daniel Walter wrote:
> > [ipv6] Add support for RTA_PREFSRC
> >
> > This patch allows a user to select the preferred source address
> > for a specific IPv6-Route. It can be set via a netlink message
> > setting RTA_PREFSRC to a valid IPv6 address which must be
> > up on the device the route will be bound to.
> >
> >
> > Signed-off-by: Daniel Walter<dwalter@barracuda.com>
> > ---
> > Repost patch, after fixing some warnings pointed out on netdev@
> > applies clean against current linux-2.6 HEAD
> >
> >   include/net/ip6_fib.h   |    2 +
> >   include/net/ip6_route.h |    7 ++++
> >   net/ipv6/addrconf.c     |    2 +
> >   net/ipv6/ip6_output.c   |    8 ++--
> >   net/ipv6/route.c        |   72 +++++++++++++++++++++++++++++++++++++++++++++--
> >   5 files changed, 84 insertions(+), 7 deletions(-)
> >
> > ---
> > diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> > index bc3cde0..98348d5 100644
> > --- a/include/net/ip6_fib.h
> > +++ b/include/net/ip6_fib.h
> > @@ -42,6 +42,7 @@ struct fib6_config {
> >
> >   	struct in6_addr	fc_dst;
> >   	struct in6_addr	fc_src;
> > +	struct in6_addr	fc_prefsrc;
> >   	struct in6_addr	fc_gateway;
> >
> >   	unsigned long	fc_expires;
> > @@ -107,6 +108,7 @@ struct rt6_info {
> >   	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
> >   	u32				rt6i_flags;
> >   	struct rt6key			rt6i_src;
> > +	struct rt6key			rt6i_prefsrc;
> >   	u32				rt6i_metric;
> >   	u32				rt6i_peer_genid;
> >
> > diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> > index c850e5f..86b1cb4 100644
> > --- a/include/net/ip6_route.h
> > +++ b/include/net/ip6_route.h
> > @@ -84,6 +84,12 @@ extern int			ip6_route_add(struct fib6_config *cfg);
> >   extern int			ip6_ins_rt(struct rt6_info *);
> >   extern int			ip6_del_rt(struct rt6_info *);
> >
> > +extern int			ip6_route_get_saddr(struct net *net,
> > +						    struct rt6_info *rt,
> > +						    struct in6_addr *daddr,
> > +						    unsigned int prefs,
> > +						    struct in6_addr *saddr);
> > +
> >   extern struct rt6_info		*rt6_lookup(struct net *net,
> >   					    const struct in6_addr *daddr,
> >   					    const struct in6_addr *saddr,
> > @@ -141,6 +147,7 @@ struct rt6_rtnl_dump_arg {
> >   extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
> >   extern void rt6_ifdown(struct net *net, struct net_device *dev);
> >   extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
> > +extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
> >
> >
> >   /*
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 1493534..129d7e1 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -825,6 +825,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
> >   		dst_release(&rt->dst);
> >   	}
> >
> > +	/* clean up prefsrc entries */
> > +	rt6_remove_prefsrc(ifp);
> >   out:
> >   	in6_ifa_put(ifp);
> >   }
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 46cf7be..1f4c096 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -930,10 +930,10 @@ static int ip6_dst_lookup_tail(struct sock *sk,
> >   		goto out_err_release;
> >
> >   	if (ipv6_addr_any(&fl6->saddr)) {
> > -		err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
> > -					&fl6->daddr,
> > -					 sk ? inet6_sk(sk)->srcprefs : 0,
> > -					&fl6->saddr);
> > +		struct rt6_info *rt = (struct rt6_info *) *dst;
> > +		err = ip6_route_get_saddr(net, rt,&fl6->daddr,
> > +					  sk ? inet6_sk(sk)->srcprefs : 0,
> > +					&fl6->saddr);
> >   		if (err)
> >   			goto out_err_release;
> >   	}
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 843406f..af26cc10 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -1325,6 +1325,16 @@ int ip6_route_add(struct fib6_config *cfg)
> >   	if (dev == NULL)
> >   		goto out;
> >
> > +	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
> > +		if (!ipv6_chk_addr(net,&cfg->fc_prefsrc, dev, 0)) {
> > +			err = -EINVAL;
> > +			goto out;
> > +		}
> > +		ipv6_addr_copy(&rt->rt6i_prefsrc.addr,&cfg->fc_prefsrc);
> > +		rt->rt6i_prefsrc.plen = 128;
> > +	} else
> > +		rt->rt6i_prefsrc.plen = 0;
> > +
> >   	if (cfg->fc_flags&  (RTF_GATEWAY | RTF_NONEXTHOP)) {
> >   		rt->rt6i_nexthop = __neigh_lookup_errno(&nd_tbl,&rt->rt6i_gateway, dev);
> >   		if (IS_ERR(rt->rt6i_nexthop)) {
> > @@ -2037,6 +2047,55 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
> >   	return rt;
> >   }
> >
> > +int ip6_route_get_saddr(struct net *net,
> > +			struct rt6_info *rt,
> > +			struct in6_addr *daddr,
> > +			unsigned int prefs,
> > +			struct in6_addr *saddr)
> > +{
> > +	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry*)rt);
> > +	int err = 0;
> > +	if (rt->rt6i_prefsrc.plen)
> > +		ipv6_addr_copy(saddr,&rt->rt6i_prefsrc.addr);
> > +	else
> > +		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
> > +					 daddr, prefs, saddr);
> > +	return err;
> > +}
> > +
> > +/* remove deleted ip from prefsrc entries */
> > +struct arg_dev_net_ip {
> > +	struct net_device *dev;
> > +	struct net *net;
> > +	struct in6_addr *addr;
> > +};
> > +
> > +static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
> > +{
> > +	struct net_device *dev = ((struct arg_dev_net_ip *)arg)->dev;
> > +	struct net *net = ((struct arg_dev_net_ip *)arg)->net;
> > +	struct in6_addr *addr = ((struct arg_dev_net_ip *)arg)->addr;
> > +
> > +	if (((void *)rt->rt6i_dev == dev || dev == NULL)&&
> > +	    rt != net->ipv6.ip6_null_entry&&
> > +	    ipv6_addr_equal(addr,&rt->rt6i_prefsrc.addr)) {
> > +		/* remove prefsrc entry */
> > +		rt->rt6i_prefsrc.plen = 0;
> > +	}
> > +	return 0;
> > +}
> > +
> > +void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
> > +{
> > +	struct net *net = dev_net(ifp->idev->dev);
> > +	struct arg_dev_net_ip adni = {
> > +		.dev = ifp->idev->dev,
> > +		.net = net,
> > +		.addr =&ifp->addr,
> > +	};
> > +	fib6_clean_all(net, fib6_remove_prefsrc, 0,&adni);
> > +}
> > +
> >   struct arg_dev_net {
> >   	struct net_device *dev;
> >   	struct net *net;
> > @@ -2183,6 +2242,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
> >   		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
> >   	}
> >
> > +	if (tb[RTA_PREFSRC])
> > +		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
> > +
> >   	if (tb[RTA_OIF])
> >   		cfg->fc_ifindex = nla_get_u32(tb[RTA_OIF]);
> >
> > @@ -2325,13 +2387,17 @@ static int rt6_fill_node(struct net *net,
> >   #endif
> >   			NLA_PUT_U32(skb, RTA_IIF, iif);
> >   	} else if (dst) {
> > -		struct inet6_dev *idev = ip6_dst_idev(&rt->dst);
> >   		struct in6_addr saddr_buf;
> > -		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
> > -				       dst, 0,&saddr_buf) == 0)
> > +		if (ip6_route_get_saddr(net, rt, dst, 0,&saddr_buf) == 0)
> >   			NLA_PUT(skb, RTA_PREFSRC, 16,&saddr_buf);
> >   	}
> >
> > +	if (rt->rt6i_prefsrc.plen) {
> > +		struct in6_addr saddr_buf;
> > +		ipv6_addr_copy(&saddr_buf,&rt->rt6i_prefsrc.addr);
> > +		NLA_PUT(skb, RTA_PREFSRC, 16,&saddr_buf);
> > +	}
> > +
> >   	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst))<  0)
> >   		goto nla_put_failure;
> 
> What userspace application will be used to set this?

iproute2 already has support for this, since it is using
RTA_PREFSRC for ipv4. 

ip -6 r a 2001:db8:a::/64 via 2001:db8:b::1 src 2001:db8:b::2

