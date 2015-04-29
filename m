From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 2/6] ipv6: Remove external dependency on
 rt6i_gateway and RTF_ANYCAST
Date: Wed, 29 Apr 2015 14:19:37 -0700
Message-ID: <20150429211937.GB3428281@devbig242.prn2.facebook.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
 <1430255273-3045254-3-git-send-email-kafai@fb.com>
 <alpine.LFD.2.11.1504291106060.1504@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56598 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751371AbbD2VT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 17:19:59 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1504291106060.1504@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Apr 29, 2015 at 11:28:46AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 28 Apr 2015, Martin KaFai Lau wrote:
> 
> > -static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
> > +static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt,
> > +					   struct in6_addr *daddr)
> >  {
> > -	return &rt->rt6i_gateway;
> > +	return (rt->rt6i_flags & RTF_GATEWAY) ? &rt->rt6i_gateway : daddr;
> >  }
> 
> 	Similar change in ipv4 caused problem for places
> that request route to one nexthop but later the transmitted
> IP header contains different destination. Such examples
> were:
> 
> - net/ipv4/raw.c when hdrincl is used
> - xt_TEE.c: I see that it has IPv6 support
> - IPVS: request route to real server but send packet with
> daddr=virtual IP (Direct Route method)
> 
> 	For IPv4 link routes, callers can get a route
> with rt_gateway=0 and rt_nexthop() can return daddr from
> header.
> 
> 	We then solved it with FLOWI_FLAG_KNOWN_NH flag which
> forces a cached route where rt_gateway is filled with requested
> nexthop address:
> 
> commit c27c9322d015
> commit 2ad5b9e4bd31
> commit ad4d3ef8b7eb
> 
> 	Can you check if this series causes the same
> problem for net/ipv6/raw.c (hdrincl=1), xt_TEE.c. IPVS code is
> in __ip_vs_get_out_rt_v6() where the route is resolved
> and then attached to skb with skb_dst_set_noref().
Thanks for the pointers.

I have looked around and I can see your points.  I think we can mostly mimic
the IPv4 approach here.  After a quick thought,  one hurdle is in the
dst_check() since the rt6 does not have the genid like rt4 does.  It is removed
from rt6_info at some point to fix another perf bug, iirc.   I will try some
ways without re-introducing genid.

--Martin
