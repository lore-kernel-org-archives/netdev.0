From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4
 route
Date: Thu, 26 Mar 2015 20:27:38 -0400
Message-ID: <20150327002737.GF1051@gospo>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
 <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
 <alpine.LFD.2.11.1503270010400.1733@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Bjornar Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33130 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbbC0A1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 20:27:46 -0400
Received: by ykek76 with SMTP id k76so35556466yke.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 17:27:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1503270010400.1733@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 01:12:36AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 26 Mar 2015, Andy Gospodarek wrote:
> 
> > diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> > index 66c1e4f..7de2924 100644
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -1033,6 +1041,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
> >  		if (fi->fib_nh->nh_oif &&
> >  		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
> >  			goto nla_put_failure;
> > +		if (!ipv6_addr_any(&fi->fib_nh->nh_gw6) &&
> > +		    nla_put(skb, RTA_GATEWAY, 16, &fi->fib_nh->nh_gw6))
> 
> 	RTA_GATEWAY6
> 
> > +			goto nla_put_failure;
> >  #ifdef CONFIG_IP_ROUTE_CLASSID
> >  		if (fi->fib_nh[0].nh_tclassid &&
> >  		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
> > @@ -1060,6 +1071,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
> >  			if (nh->nh_gw &&
> >  			    nla_put_be32(skb, RTA_GATEWAY, nh->nh_gw))
> >  				goto nla_put_failure;
> > +			if (!ipv6_addr_any(&nh->nh_gw6) &&
> > +			    nla_put(skb, RTA_GATEWAY, 16, &nh->nh_gw6))
> 
> 	RTA_GATEWAY6
> 

Thanks for both of these, my original patch overloaded RTA_GATEWAY and I
missed these in the conversion.

> > @@ -193,10 +196,27 @@ static inline int ip_finish_output2(struct sk_buff *skb)
> >  	}
> >  
> >  	rcu_read_lock_bh();
> > -	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
> > -	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
> > -	if (unlikely(!neigh))
> > -		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
> > +
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +	/* If there is an ipv6 gateway specified, use it */
> > +	if (!rt->rt_gateway && !ipv6_addr_any(&rt->rt_gateway6)) {
> 
> 	DST_NOCACHE routes can fill rt_gateway even when
> nh_gw=0 (rt_set_nexthop), so above check can be:
> 
> 	if (rt->rt_uses_gateway && !ipv6_addr_any(&rt->rt_gateway6)) {
> 
> 	Not sure, some places may prefer to see rt_uses_gateway=1
> for v4 and rt_uses_gateway=2 for v6 nexthop. Then above check
> can be just 'if (rt->rt_uses_gateway == 2) {'.
> 

OK, thanks.

> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index be8703d..c654b41 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1400,6 +1400,10 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
> >  			rt->rt_gateway = nh->nh_gw;
> >  			rt->rt_uses_gateway = 1;
> >  		}
> > +		if (!ipv6_addr_any(&nh->nh_gw6)) {
> > +			memcpy(&rt->rt_gateway6, &nh->nh_gw6, sizeof(struct in6_addr));
> > +			rt->rt_uses_gateway = 1;
> > +		}
> >  		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
> >  #ifdef CONFIG_IP_ROUTE_CLASSID
> >  		rt->dst.tclassid = nh->nh_tclassid;
> > @@ -1417,6 +1421,10 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
> >  			rt->dst.flags |= DST_NOCACHE;
> >  			if (!rt->rt_gateway)
> >  				rt->rt_gateway = daddr;
> > +			if (ipv6_addr_any(&rt->rt_gateway6)) {
> > +				memcpy(&rt->rt_gateway6, &nh->nh_gw6, sizeof(struct in6_addr));
> > +				rt->rt_uses_gateway = 1;
> > +			}
> 
> 	Above hunk is not needed, rt_gateway6 is set above.
> 

Excellent, I will drop that too.

> >  			rt_add_uncached_list(rt);
> >  		}
> >  	} else
> > @@ -1488,6 +1496,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> >  	rth->rt_pmtu	= 0;
> >  	rth->rt_gateway	= 0;
> >  	rth->rt_uses_gateway = 0;
> > +	memset(&rth->rt_gateway6, 0, sizeof(struct in6_addr));
> 
> 	We can remove such initializations if
> rt_uses_gateway=2 is used as v6 indication, for example:
> 
> rt_uses_gateway rt_gateway nh_gw   nh_gw6 DST_NOCACHE What
> ===============================================================================
> 0               0          0/LOCAL N      N           Non-gatewayed, cached
> 0               DADDR      0/LOCAL N      Y           Non-gatewayed, not cached
> 2               0          0       GW6    N           Gatewayed, cached
> 2               DADDR      0       GW6    Y           Gatewayed, not cached
> 1               GW         GW      N      Y/N         Gatewayed
> 
> 
> 	May be more places need to be changed:
> 
> - fib_check_nh: validate v6 address type, set nh_dev,
> 	allow only nh->nh_scope == RT_SCOPE_LINK (I assume
> 	we do not plan to use local v6 address in nh_gw6).
> - nh_comp: needs nh_gw6 comparison
> - fib_create_info: more checks are needed around
> 	'if (cfg->fc_scope == RT_SCOPE_HOST) {' check
> 
> 	There are other places that use rt_uses_gateway
> and rt_gateway.
> 
> Regards
> 

Awesome.  Thanks for the thorough review.  I'll check these bits out and
see what else needs to be done for v1 of this series.
