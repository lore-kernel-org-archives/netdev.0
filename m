From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IPVS-DR problem with neigh lookup in 3.6
Date: Thu, 4 Oct 2012 12:11:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210041107020.2039@ja.ssi.bg>
References: <alpine.LFD.2.00.1210040923010.1618@ja.ssi.bg> <20121004.025808.2302904472507419433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39790 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733Ab2JDJGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 05:06:05 -0400
In-Reply-To: <20121004.025808.2302904472507419433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 4 Oct 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Thu, 4 Oct 2012 09:52:47 +0300 (EEST)
> 
> > 	Is it a good idea to keep rt_gateway always
> > valid and to check RTCF_REDIRECTED where needed?
> 
> What exactly do you mean by this?  rt_gateway can only
> be explicit nexthop or zero for local subnet.
> 
> It cannot take on any other value, otherwise routes are
> not properly sharable.

	Oh, yes, that was the reason for value 0.

> > Because adding rt_dst does not look good, it will not
> > help to callforward_do_filter too.
> 
> Adding rt_dst is not to be seriously considered.

	OK, I'll think more for alternatives. May be
if there is a way to request output route that should
not be cached. Then we can set valid rt_gateway for
such private routes, fnhe can be used for info too
but this route should not be cached there. Or we
should cache the entry in fnhe, so that we can detect
that fnhe is reclaimed.

	Currently, we handle NETDEV_UNREGISTER
both for cached and uncached routes, so users like IPVS
can safely request such special routes. IPVS does the
rt caching itself.

	Now the question is how to request such host routes
via flowi. Archives remember for FLOWI_FLAG_RT_NOCACHE, may be
we can port it to the new caching as FLOWI_FLAG_RT_HOST?
FLOWI_FLAG_RT_HOST will mean: can cache in fnhe if present
or return uncached result as second option.

	BTW, I see another place with problem, ip_forward():

if (opt->is_strictroute && opt->nexthop != rt->rt_gateway)

	may be should be

if (opt->is_strictroute && opt->nexthop != rt->rt_gateway &&
    rt->rt_gateway)

Regards

--
Julian Anastasov <ja@ssi.bg>
