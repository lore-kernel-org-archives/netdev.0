From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Mon, 25 Sep 2017 17:56:18 -0700
Message-ID: <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
References: <20170925173522.99892-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58764 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965341AbdIZA4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 20:56:25 -0400
Content-Disposition: inline
In-Reply-To: <20170925173522.99892-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 05:35:22PM +0000, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> fib6_del() generates WARN_ON() when rt->dst.obsolete > 0. This does not
> make sense because it is possible that the route passed in is already
> deleted by some other thread and rt->dst.obsolete is set to
> DST_OBSOLETE_DEAD.
> So this commit deletes this WARN_ON() and also remove the
> "#ifdef RT6_DEBUG >= 2" condition so that if the route is already
> obsolete, we return right at the beginning of fib6_del().
> 
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index e5308d7cbd75..693bcd7ef6d2 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -1592,13 +1592,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
>  	struct net *net = info->nl_net;
>  	struct rt6_info **rtp;
>  
> -#if RT6_DEBUG >= 2
> -	if (rt->dst.obsolete > 0) {
> -		WARN_ON(fn);
fn should have already been set to NULL if it is removed
from the fib6 tree?

> -		return -ENOENT;
> -	}
> -#endif
> -	if (!fn || rt == net->ipv6.ip6_null_entry)
> +	if (!fn || rt->dst.obsolete > 0 || rt == net->ipv6.ip6_null_entry)
>  		return -ENOENT;
>  
>  	WARN_ON(!(fn->fn_flags & RTN_RTINFO));
> -- 
> 2.14.1.821.g8fa685d3b7-goog
> 
