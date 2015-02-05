From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC 1/2] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Thu, 5 Feb 2015 15:56:29 -0800
Message-ID: <20150205235628.GA1916791@devbig242.prn2.facebook.com>
References: <54C78B8D.1070104@huawei.com>
 <20150128121026.GM13046@secunet.com>
 <20150128121150.GN13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57645 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751859AbbBEX5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:57:08 -0500
Content-Disposition: inline
In-Reply-To: <20150128121150.GN13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 01:11:51PM +0100, Steffen Klassert wrote:
> We currently don't clone host routes before we use them.
> If a pmtu event is received on such a route, it gets
> an expires value. As soon as the expiration time is
> elapsed, the route is deleted. As a result, the host
> is not reachable any more.
> 
> We fix this by cloning host routes if they are gatewayed,
> i.e. if pmtu events can happen.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv6/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c910831..3e864e7 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -961,7 +961,7 @@ redo_rt6_select:
>  
>  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
>  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> -	else if (!(rt->dst.flags & DST_HOST))
> +	else if (!(rt->dst.flags & DST_HOST) || (rt->rt6i_flags & RTF_GATEWAY))
>  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
The del path may also require changes.  I am thinking:
1. Create a /128 via gateway route
2. Send some traffic and RTF_CACHE rt is created
3. Delete the /128 route by ip route del.  I suspect the RTF_CACHE route may be
   deleted and the route added in (1) stays.

Thanks
