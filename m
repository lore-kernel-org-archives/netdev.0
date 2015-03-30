From: Sheng Yong <shengyong1@huawei.com>
Subject: Re: [PATCH RFC 1/3] ipv6: Fix after pmtu events dissapearing host
 routes
Date: Mon, 30 Mar 2015 19:15:46 +0800
Message-ID: <55193062.2040204@huawei.com>
References: <54CF3348.40207@huawei.com> <20150203092845.GT13046@secunet.com> <54D0A8DB.4010106@huawei.com> <20150203120140.GU13046@secunet.com> <54D17D1A.3020706@huawei.com> <20150205072125.GY13046@secunet.com> <54EFD87A.5080907@huawei.com> <20150330103210.GI3311@secunet.com> <20150330103313.GJ3311@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:10409 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbbC3LQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 07:16:31 -0400
In-Reply-To: <20150330103313.GJ3311@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/30/2015 6:33 PM, Steffen Klassert wrote:
> We currently don't clone host routes before we use them.
> If a pmtu event is received on such a route, it gets
> an expires value. As soon as the expiration time is
> elapsed, the route is deleted. As a result, the host
> es not reachable any more.
> 
> We fix this by cloning host routes if they are not local,
> i.e. if pmtu events can happen. Also adjust the route
> deletion because the cached and the original host route
> are on the same fib node.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv6/route.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4688bd4..4318626 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -961,7 +961,7 @@ redo_rt6_select:
>  
>  	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
>  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
> -	else if (!(rt->dst.flags & DST_HOST))
> +	else if (!(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
>  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
>  	else
>  		goto out2;
> @@ -1796,6 +1796,8 @@ static int ip6_route_del(struct fib6_config *cfg)
>  				continue;
>  			if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
>  				continue;
> +			if (!(cfg->fc_flags & RTF_CACHE) && (rt->rt6i_flags & RTF_CACHE))
There is a trivial coding style problem, which makes checkpatch.pl unhappy. The line is
over 80 characters.
> +				continue;
>  			dst_hold(&rt->dst);
>  			read_unlock_bh(&table->tb6_lock);
>  
> @@ -2433,6 +2435,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
>  	if (rtm->rtm_type == RTN_LOCAL)
>  		cfg->fc_flags |= RTF_LOCAL;
>  
> +	if (rtm->rtm_flags & RTM_F_CLONED)
> +		cfg->fc_flags |= RTF_CACHE;
> +
>  	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
>  	cfg->fc_nlinfo.nlh = nlh;
>  	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
> 
