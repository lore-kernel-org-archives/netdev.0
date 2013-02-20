From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Wed, 20 Feb 2013 19:02:42 +0900
Message-ID: <51249F42.3030908@linux-ipv6.org>
References: <1361231718.19353.117.camel@edumazet-glaptop>   <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>   <1361308665.19353.161.camel@edumazet-glaptop>   <20130219214934.GD31871@hmsreliant.think-freely.org>  <1361310958.19353.164.camel@edumazet-glaptop>  <51246E43.5010202@cn.fujitsu.com> <1361343610.19353.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34598 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750872Ab3BTKCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 05:02:46 -0500
In-Reply-To: <1361343610.19353.177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Wed, 2013-02-20 at 14:33 +0800, Gao feng wrote:
> 
>> How can we?
>> one usage of rt6_update_expires and rt6_set_expires
>> is changing rt6->dst.from to rt6->dst.expires, we should release the
>> already holded reference of rt6->dst.from.
>>
> 
> Just don't union the two fields, as Neil did.
> 
> Setting the dst.expires value should not change dst.from at all.
> 
> Something like the (untested, because its too late here) patch ?
> 
>  include/net/dst.h     |   11 +++++------
>  include/net/ip6_fib.h |   21 +++------------------
>  net/ipv6/route.c      |    3 +--
>  3 files changed, 9 insertions(+), 26 deletions(-)
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 3da47e0..3f31a48 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -36,13 +36,12 @@ struct dst_entry {
>  	struct net_device       *dev;
>  	struct  dst_ops	        *ops;
>  	unsigned long		_metrics;
> -	union {
> -		unsigned long           expires;
> -		/* point to where the dst_entry copied from */
> -		struct dst_entry        *from;
> -	};
> +	unsigned long           expires;
> +
> +	/* point to where the dst_entry copied from */
> +	struct dst_entry        *from;
> +
>  	struct dst_entry	*path;
> -	void			*__pad0;
>  #ifdef CONFIG_XFRM
>  	struct xfrm_state	*xfrm;
>  #else

Initialize "from" in dst_alloc().

> @@ -199,13 +185,12 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
>  {
>  	struct dst_entry *new = (struct dst_entry *) from;
>  
> -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from) {
> +	if (rt->dst.from) {
>  		if (new == rt->dst.from)
>  			return;
>  		dst_release(rt->dst.from);
>  	}
>  
> -	rt->rt6i_flags &= ~RTF_EXPIRES;
>  	rt->dst.from = new;
>  	dst_hold(new);
>  }

rt6_set_from can work only for fresh entries.

In fact, I have very similar patch.

--yoshfuji
